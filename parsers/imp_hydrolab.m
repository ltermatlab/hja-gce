function [s,msg] = imp_hydrolab(fn,pn,template)
%Import filter for GCE Hydrolab groundwater data logger files
%
%syntax:  [s,msg] = imp_hydrolab(fn,pn,template)
%
%inputs:
%  fn = file name to import (default = prompted)
%  pn = pathname for fn (default = pwd)
%  template = metadata template (default = 'GCE_Hydrolab_Logger')
%
%outputs:
%  s = GCE Data Structure
%  msg = text of any error messages
%
%(c)2010-2011 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 05-Aug-2011

%initialize outputs:
s = [];

%define parameters
curpath = pwd;
missing_codes = '999999';
if exist('template','var') ~= 1
   template = 'GCE_Hydrolab_Logger';
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
   cd(curpath)
elseif exist([pn,filesep,fn],'file') ~= 2
   [fn,pn] = uigetfile(fn,'Locate the text file to import');
end
drawnow

%pass filename, pathname, and static parameters to custom ASCII import filter
if fn ~= 0

   %parse instrument id from first line of logger file
   fid = fopen([pn,filesep,fn],'r');
   str = fgetl(fid);
   ar = splitstr(str,' ');
   sensor = char(ar(end));
   col_names = '';  %init column names string
   num_header_rows = 0;
   while ischar(str)
      num_header_rows = num_header_rows + 1;
      if strncmpi(str,'Date',4)
         col_names = str;
         num_header_rows = num_header_rows + 2;
         break
      end
      str = fgetl(fid);
   end
   fclose(fid);

   %check for successfully parsed header
   if ~isempty(col_names)

      %parse column headers, add flag headings
      ar = splitstr(col_names,',',0);
      ar = ar(1:end-1);  %remove terminal flag to prevent parsing issue
      Iblank = find(cellfun('isempty',ar));
      for n = 1:length(Iblank)
         ar{Iblank(n)} = ['Flag_',ar{Iblank(n)-1}];
      end
      column_names = strrep(cell2commas(ar,0),' ','');  %generate delimited column names string
      column_names = strrep(strrep(column_names,'Date,','Month,Day,Year,'),',Time,',',Hour,Minute,Second,');

      %define format strings
      format_string = '%2d%2d%2d %2d%2d%2d %s %f %s %f %s %f %s %f %s %f %s %f %s %f';
      format_string2 = '%d/%d/%d %d:%d:%d %s %f %s %f %s %f %s %f %s %f %s %f %s %f';

      %import the data file
      [s,msg] = imp_filter(fn,pn,format_string,column_names,num_header_rows,missing_codes,'');

      %try alternative date format string if first format fails
      if isempty(s)
         [s,msg] = imp_filter(fn,pn,format_string2,column_names,num_header_rows,missing_codes,'');
      end

      if ~isempty(s)

         %convert 2 digit year to 4 digits
         yr = extract(s,'Year');
         Ibadyr = find(yr<100);
         if ~isempty(Ibadyr)
            yr(Ibadyr) = yr(Ibadyr) + 2000;
            s = update_data(s,'Year',yr,0);
         end

         %reorder columns to put year before month
         s = copycols(s,{'Year','Month','Day','Hour','Minute','Second','Temp','Flag_Temp','Dep25','Flag_Dep25','SpCond','Flag_SpCond','Sal','Flag_Sal','DO','Flag_DO','DO%','Flag_DO%','pH'});

         %apply metadata template
         [s,msg] = apply_template(s,template);

         if ~isempty(s)

            %try to parse sensor, time zone from filename
            tz = '';
            if length(fn) >= 2
               [tmp,fn_base] = fileparts(fn);
               ar = splitstr(fn_base,'_');
               if length(ar) >= 2
                  str = ar{end};
                  if length(str) == 3;
                     tz = upper(str);
                  end
               end
            end

            %add time zone to hour column description
            hr_col = name2col(s,'Hour');
            if ~isempty(tz) && length(hr_col) == 1
               s.description{hr_col} = [s.description{hr_col},' ',tz];
            end

            %delete seconds column if all <=2 or same value
            sec = extract(s,'Second');
            if max(sec) <= 2 || length(unique(sec)) == 1
               s = deletecols(s,'Second');
            end

            %add serial date column
            s = add_datecol(s,[],[],0);

            %add study dates
            s = add_studydates(s);

            %fill metadata tokens
            s = fill_meta_tokens(s);

            %convert to GMT if necessary, regenerate datepart columns
            if ~isempty(tz) && ~strcmp(tz,'GMT')
               s = unit_convert(s,'Date','serial day (base 1/1/0000) - GMT');
               s = add_datepartcols(s,'Date');
            end

            %convert datalogger flags columns to q/c flags
            s = cols2flags(s);

            %convert pressure units to Pa
            s = unit_convert(s,'Pressure','Pa');

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

            %add well location metadata
            if ~isempty(s)
               [s,msg] = add_well_metadata(s,fn,sensor, ...
                  'Hammock groundwater well pressure, temperature, conductance, salinity and oxygen measurements');
            else
               msg = 'an error occurred finalizing the data structure';
            end

            %fill date gaps
            s = fill_date_gaps(s,'Date',1,1);

         end

      end

   else
      msg = 'unrecognized file format - failed to parse column headings';
   end

else
   msg = 'import cancelled';
end
