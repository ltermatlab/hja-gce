function [s,msg] = imp_aquatroll(fn,pn,template)
%Imports data from a GCE Aqua TROLL 200 groundwater data logger
%
%syntax: [s,msg] = imp_aquatroll(fn,pn,template)
%
%inputs:
%  fn = file name to import (default = prompted)
%  pn = pathname for fn (default = pwd)
%  template = metadata template (default = 'GCE_AquaTroll_Logger')
%
%outputs:
%  s = GCE Data Structure
%  msg = text of any error messages
%
%(c)2010-2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
%
%This file is part of the GCE Data Toolbox for MATLAB(r) software library.
%
%The GCE Data Toolbox is free software: you can redistribute it and/or modify it under the terms
%of the GNU General Public License as published by the Free Software Foundation, either version 3
%of the License, or (at your option) any later version.
%
%The GCE Data Toolbox is distributed in the hope that it will be useful, but WITHOUT ANY
%WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
%PURPOSE. See the GNU General Public License for more details.
%
%You should have received a copy of the GNU General Public License along with The GCE Data Toolbox
%as 'license.txt'. If not, see <http://www.gnu.org/licenses/>.
%
%contact:
%  Wade Sheldon
%  GCE-LTER Project
%  Department of Marine Sciences
%  University of Georgia
%  Athens, GA 30602-3636
%  sheldon@uga.edu
%
%last modified: 07-Nov-2014

%initialize outputs:
s = [];
msg = '';

%define parameters
curpath = pwd;
format_string = '%d/%d/%d %d:%d:%d %s %f %f %f %f %f %f %f %f %f %f';
format_string2 = '%d/%d/%d %d:%d %f %f %f %f %f %f %f %f %f %f';
column_names = ['Month,Day,Year,Hour,Minute,Second,AMPM,Time_Elapsed,Pressure,Temperature,Depth,' ...
   'Conductivity,Specific_Conductivity,Salinity,Total_Dissolved_Solids,Resistivity,Density'];
column_names2 = ['Month,Day,Year,Hour,Minute,Time_Elapsed,Pressure,Temperature,Depth,' ...
   'Conductivity,Specific_Conductivity,Salinity,Total_Dissolved_Solids,Resistivity,Density'];

missing_codes = '';
if exist('template','var') ~= 1
   template = 'GCE_AquaTroll_Logger';
end

%validate path
if exist('pn','var') ~= 1
   pn = curpath;
elseif ~isdir(pn)
   pn = curpath;
elseif strcmp(pn(end),filesep)
   pn = pn(1:end-1);  %strip terminal file separator
end

%prompt for file if omitted or invalid
if exist('fn','var') ~= 1
   cd(pn)
   [fn,pn] = uigetfile('*.txt;*.asc;*.csv;*.dat','Select a text file to import');
   drawnow
   cd(curpath)
elseif exist([pn,filesep,fn],'file') ~= 2
   [fn,pn] = uigetfile(fn,'Locate the text file to import');
   drawnow
end

%pass filename, pathname, and static parameters to custom ASCII import filter
if fn ~= 0
   
   %check for .csv version, call subroutine to remove commas mixed with whitespace
   if strfind(lower(fn),'.csv') > 0
      fn = sub_clean_aquatroll(fn,pn);
   end
      
   %load file and determine header rows and grab sensor id
   sensor = '';
   try
      num_header_rows = 0;
      eof = 0;
      fid = fopen([pn,filesep,fn],'r');
      str = fgetl(fid);
      while ischar(str);
         num_header_rows = num_header_rows + 1;
         if strncmp(str,'Date and Time',13) && ~isempty(strfind(str,'Pressure '))
            num_header_rows = num_header_rows + 1;  %add additional row for spacer
            eof = 1;
            break
         elseif ~isempty(strfind(str,'Serial Number'));
            ar = splitstr(str,':');
            if length(ar) == 2
               sensor = ['AT',ar{2}];  %grab sensor serial number to create id
            else  %get serial number without colon separator
               pat = 'Serial Number';
               Istart = strfind(str,pat);
               sensor = trimstr(str(Istart+length(pat)+1:end));
            end
         end
         str = fgetl(fid);
      end
      fclose(fid);
      if eof == 0
         num_header_rows = [];  %clear row counter if 'Date and Time' not found
      end
   catch
      num_header_rows = [];
   end
   
   if ~isempty(num_header_rows)
      
      %import the data file
      [s,msg] = imp_ascii(fn,pn,'',template,format_string,column_names,num_header_rows,missing_codes,' ');
      
      %try alternate format string if fails
      if isempty(s)
         [s,msg] = imp_ascii(fn,pn,'',template,format_string2,column_names2,num_header_rows,missing_codes,' ');
      end
      
      if ~isempty(s)
         
         %convert hours to 24hr format, delete AMPM column
         offset = 0;  %init offset array
         ampm = extract(s,'AMPM');  %extract am/pm         
         if ~isempty(ampm)
            offset = zeros(length(ampm),1);  %init offset array
            hr = extract(s,'Hour');  %extract hours
            Ipm = strcmp(ampm,'PM') & hr ~= 12;  %get index of PM rows except 12pm which doesn't need offset
            offset(Ipm) = 0.5;  %set offset amount to 0.5 days
            I12am = strcmp(ampm,'AM') & hr == 12;  %get index of 12AM rows
            offset(I12am) = -0.5;  %set offset amount to -0.5 days to account for date rollover
         end
         
         %re-order columns to put Year before Month and omit AMPM and Time_Elapsed
         s = copycols(s,{'Year','Month','Day','Hour','Minute','Second','Pressure_Corrected', ...
            'Temp_Water','Depth','Conductivity','Specific_Conductivity','Salinity', ...
            'Total_Dissolved_Solids','Resistivity','Density'});
         
         %delete seconds column if all <=2 or same value
         sec = extract(s,'Second');
         if ~isempty(sec) && (max(sec) <= 2 || length(unique(sec)) == 1)
            s = deletecols(s,'Second');
         end
         
         %generate serial date column, adjust for PM times
         s = add_datecol(s);
         dt0 = extract(s,'Date');
         dt = dt0 + offset;
         s = update_data(s,'Date',dt,0);
         
         %convert dates to GMT, regenerate date part columns
         s = unit_convert(s,'Date','serial day (base 1/1/0000) - GMT');
         s = add_datepartcols(s,'Date');
         
         %add study dates
         s = add_studydates(s);
         
         %fill metadata tokens to include date range, etc in title and abstract
         s = fill_meta_tokens(s);
         
         %convert pressure to Pa
         s = unit_convert(s,'Pressure_Corrected','Pa');
         
         %convert density to kg/m^3
         s = unit_convert(s,'Density','kg/m^3');
         
         %add relevant dates to metadata
         d = dir([pn,filesep,fn]);
         if length(d) == 1
            submitdate = datenum(d.date);
         else
            submitdate = now;
         end
         newmeta = {'Dataset','SubmitDate',datestr(submitdate,1); ...
            'Status','ProjectRelease',datestr(now,1); ...
            'Status','PublicRelease',datestr(now+365,1); ...
            'Status','MetadataUpdate',datestr(now,1)};
         s = addmeta(s,newmeta);
         
         %add well metadata based on sensor and date lookup
         [s,msg] = add_well_metadata(s,fn,sensor, ...
            ['Hammock groundwater well pressure, temperature, conductivity, salinity, density, ', ...
            'resistivity and total suspended solid measurements'], ...
            {'Hammock','Location','Longitude','Latitude','Sensor','Sensor_Elevation'});
         
         %calculate water elevation based on sensor elevation and depth
         depcol = name2col(s,'Depth');
         sensorel = name2col(s,'Sensor_Elevation');
         if ~isempty(depcol) && ~isempty(sensorel)
            s_tmp = unit_convert(s,depcol,'m');
            s_tmp = unit_convert(s_tmp,sensorel,'m');
            s_tmp = add_calcexpr(s_tmp,'Sensor_Elevation + Depth','Water_Elevation','m', ...
               'Water elevation relative to NAVD88 datum calculated from sensor elevation and water depth above the sensor', ...
               depcol+1);
            s_tmp = copyflags(s_tmp,[depcol sensorel],depcol+1);
            if ~isempty(s_tmp)
               s = s_tmp;
            else
               msg = 'an error occurred adding a calculated water elevation column';
            end
         else
            msg = 'columns Depth and Sensor_Elevation were not found so water elevation was not calculated';
         end
         
         %fill date gaps
         s = fill_date_gaps(s,'Date',1,1);
         
      end
      
   else
      msg = 'unrecognized data file format - import failed';
   end
   
end
return


function fn2 = sub_clean_aquatroll(fn,pn)
%function for removing commas in .csv Aquatroll files

fn2 = '';

%check for file
if exist([pn,filesep,fn],'file') == 2
   
   %get base filename
   [pn,fn_base] = fileparts([pn,filesep,fn]);
   
   %generate filename for revised file
   fn2 = [fn_base,'_edit.txt'];
   
   %open original file for read
   fid1 = fopen([pn,filesep,fn],'r');
   
   %open revised file for write
   fid2 = fopen([pn,filesep,fn2],'w');
   
   %loop through file, replacing commas with spaces
   str = fgets(fid1);   
   while ischar(str)
      fprintf(fid2,'%s',strrep(str,',',' '));
      str = fgets(fid1);
   end
   
   %close file handles
   fclose(fid1);
   fclose(fid2);
  
end
return