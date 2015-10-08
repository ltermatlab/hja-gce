function [s,msg] = imp_seaphox(fn,pn,template,titlestr)
%Import filter for SeapHOx logger files
%
%syntax:  [s,msg] = imp_seaphox(fn,pn,template,title)
%
%inputs:
%  fn = file name to import (default = prompted)
%  pn = pathname for fn (default = pwd)
%  template = metadata template (default = 'SeapHOx')
%  title = data set title (default = 'SeapHOx Data Collected from [Study_BeginDate] to [Study_EndDate]')
%
%outputs:
%  s = GCE Data Structure
%  msg = text of any error messages
%
%(c)2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 08-May-2015

%initialize outputs:
s = [];
msg = '';

%define runtime variables
curpath = pwd;
format_string = '%s %f %f %f %f %f %f %f %f %f %f %d %d %f %f %f %f %f %f %f %f %f %f %f %f %f %s %s';
column_names = 'Date,Voltage_Battery,Voltage_Therm,Voltage_FET_INT,Voltage_FET_EXT,Voltage_Isolated,Temp_Controller,Temp_Durafet,Voltage_Pressure,pH_INT,pH_EXT,Optode_Model,Optode_SN,Oxygen_Conc,Oxygen_Sat,Temp_Optode,Dphase,Bphase,Rphase,Dshift,Bshift,Rshift,Temp_Raw,Temp_SBE37,Conductivity_SBE37,Salinity_SBE37,Date_SBE37,Time_SBE37';
unitlist = 'yyyy/mm/dd HH:MM:SS,v,v,v,v,v,°C,°C,mV,pH Units,pH Units,none,none,uM,%,°C,none,none,none,none,none,none,v,°C,S/cm,PSU,dd mmm yyyy,HH:MM:SS';
num_header_rows = 0;
delimiter = '\t';
missing_codes = '';

%specify empty template unless provided as input
if exist('template','var') ~= 1
   template = 'SeapHOx';
end

%specify default title unless provided as input
if exist('titlestr','var') ~= 1
   titlestr = 'SeapHOx Data Collected from [Study_BeginDate] to [Study_EndDate]';
end

%validate path
if exist('pn','var') ~= 1
   pn = curpath;
elseif ~isdir(pn)
   pn = curpath;
else
   pn = clean_path(pn);  %strip terminal file separator
end

%validate filename
if exist('fn','var') ~= 1
   fn = '';
end
if isempty(fn)
   filespec = '*.txt;*.TXT';  %use standard text file specifier
elseif exist([pn,filesep,fn],'file') ~= 2
   filespec = fn;  %use unlocated filename as file specifier
   fn = '';
end

%prompt for file if omitted or invalid
if isempty(fn)
   cd(pn)
   [fn,pn] = uigetfile(filespec,'Select a SeapHOx file to import');
   cd(curpath)
   drawnow
end

%pass filename, pathname, and static parameters to custom ASCII import filter
if fn ~= 0
   
   %init header array
   maxrows = 1000;
   hdr = cell(maxrows,1);
   
   %open file to determine header rows
   try
      fid = fopen([pn,filesep,fn],'r');
      str = fgetl(fid);
      while ischar(str)
         if strncmp('//',str,2) || isempty(deblank(str))
            num_header_rows = num_header_rows + 1;
            if num_header_rows <= maxrows
               hdr{num_header_rows} = str;
            end
         else
            break
         end
         str = fgetl(fid);
      end
      fclose(fid);
   catch e
      msg = e.message;
   end
   
   if num_header_rows > 0

      %import the data file
      [s,msg] = imp_ascii(fn,pn,titlestr,template,format_string,column_names,num_header_rows,missing_codes,delimiter);
      
      %convert Date to serial date
      s = convert_date_format(s,'Date',[]);
      
      %update the title
      if ~isempty(s) && ~isempty(titlestr)
         s = newtitle(s,titlestr);
      end
      
      %fill in metadata tokens in title and astract
      s = fill_meta_tokens(s);
      
      %add header
      newmeta = {'Supplement','Validation',cell2pipes(hdr(~cellfun('isempty',hdr))')};
      s = addmeta(s,newmeta,0,'imp_seaphox');
      
      %add units if no template specified
      if isempty(template) && ~isempty(unitlist)
         units = splitstr(unitlist,',',0,1);  %split unit string into cell array
         if length(units) == length(s.units)
            s.units = units(:)';  %use parsed units, forcing row array
         end
      end
      
      %add custom post-processing commands below this line
      
      
   end
   
else
   msg = 'import cancelled';
end
