function [s,msg] = imp_minitroll(fn,pn,template)
%Import filter for GCE In-Situ MiniTroll water level loggers
%
%syntax:  [s,msg] = imp_minitroll(fn,pn,template)
%
%inputs:
%  fn = file name to import (default = prompted)
%  pn = pathname for fn (default = pwd)
%  template = metadata template (default = 'GCE_MiniTroll_Logger')
%
%outputs:
%  s = GCE Data Structure
%  msg = text of any error messages
%
%(c)2010-2012 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 06-Aug-2012

%initialize outputs:
s = [];
msg = '';

%define parameters
curpath = pwd;
format_string = '%d/%d/%d %d:%d:%d %f %f';
format_string2 = '%2d%2d%2d %2d%2d%2d %f %f';
column_names = 'Month,Day,Year,Hour,Minute,Second,Time_Elapsed,Pressure';
num_header_rows = 36;
missing_codes = '';
if exist('template','var') ~= 1
   template = 'GCE_MiniTroll_Logger';
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
   [fn,pn] = uigetfile('*.txt;*.asc','Select a text file to import');
   drawnow
   cd(curpath)
elseif exist([pn,filesep,fn],'file') ~= 2
   [fn,pn] = uigetfile(fn,'Locate the text file to import');
   drawnow
end

%pass filename, pathname, and static parameters to custom ASCII import filter
if fn ~= 0

   %import the data file
   [s,msg] = imp_ascii(fn,pn,'','',format_string,column_names,num_header_rows,missing_codes);

   %try alternative format string without date delimiters
   if isempty(s)
      [s,msg] = imp_ascii(fn,pn,'','',format_string2,column_names,num_header_rows,missing_codes);
   end

   if ~isempty(s)

      %convert year to 4 digits
      yr = extract(s,'Year');
      if ~isempty(yr)
         yr = 2000 + yr;
         s = update_data(s,'Year',yr,0);
      end

      %reorder columns to put year before month, remove Time_Elapsed
      s = copycols(s,{'Year','Month','Day','Hour','Minute','Second','Pressure'});

      %apply metadata template
      s = apply_template(s,template);

      %try to parse timezone from filename
      [tmp,fn_base] = fileparts(fn);
      ar = splitstr(fn_base,'_');
      tz = '';
      if length(ar) >= 3
         str = ar{end};
         if length(str) == 3
            tz = upper(str);
         end
      end

      %add time zone to units of date column if determined
      hrcol = name2col(s,'Hour');
      if ~isempty(tz)
         s.description{hrcol} = [s.description{hrcol},' ',tz];
      end

      %delete seconds column if all <=2 or same value
      sec = extract(s,'Second');
      if max(sec) <= 2 || length(unique(sec)) == 1
         s = deletecols(s,'Second');
      end

      %generate serial date column
      s = add_datecol(s);

      %add study dates
      s = add_studydates(s);

      %fill metadata tokens
      s = fill_meta_tokens(s);

      %convert date to GMT, regenerate datepart columns if necessary
      if ~isempty(tz) && ~strcmp(tz,'GMT')
         s = unit_convert(s,'Date','serial day (base 1/1/0000) - GMT');
         s = add_datepartcols(s,'Date');
      end

      %convert pressure to m H2O, rename as Depth
      s = unit_convert(s,'Pressure','Pa');

      %generate sensor id based on GCE file naming convention
      sensor = '';
      [Istart,Iend] = regexp(fn,'_Sensor(\d)+_');
      if ~isempty(Istart)
         sensor = fn(Istart+1:Iend-1);
      end

      %add relevant dates to metadata
      d = dir([pn,filesep,fn]);
      if length(d) == 1
         submitdate = datenum(d.date);
      else
         submitdate = now;
      end
      newmeta = {'Dataset','SubmitDate',datestr(submitdate,1); ...
         'Status','ProjectRelease',datestr(submitdate,1); ...
         'Status','PublicRelease',datestr(submitdate+365,1); ...
         'Status','MetadataUpdate',datestr(now,1)};
      s = addmeta(s,newmeta);

      %add well location metadata
      if ~isempty(sensor)
         [s,msg] = add_well_metadata(s,fn,sensor,'Hammock groundwater well pressure measurements');
      else
         msg = 'failed to parse sensor id from filename - hammock metadata not added';
      end

      %fill date gaps
      s = fill_date_gaps(s,'Date',1,1);

   end

end
