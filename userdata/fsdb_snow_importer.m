function [s,msg] = fsdb_snow_importer(fn,pn,template,titlestr)
%Custom text file import filter for the GCE Data Toolbox generated on 15-Jul-2014
%based on a user-defined filter for 'ms00110_PRI.CSV'
%
%syntax:  [s,msg] = fsdb_snow_importer(fn,pn,template,title)
%
%inputs:
%  fn = file name to import (default = prompted)
%  pn = pathname for fn (default = pwd)
%  template = metadata template (default = 'FSDB_Snow')
%  title = data set title (default = 'Import raw output from FSDB')
%
%outputs:
%  s = GCE Data Structure
%  msg = text of any error messages
%
%created: 15-Jul-2014 09:30:28

%initialize outputs:
s = [];
msg = '';

%define runtime variables
curpath = pwd;
format_string = '%q %d %q %q %s %d %q %d %q';
column_names = 'stcode,format,sitecode,probe,date_time,snowmois,fe1,snowdep,fe2';
unitlist = '';
num_header_rows = 1;
delimiter = ',';
missing_codes = '';

%specify empty template unless provided as input
if exist('template','var') ~= 1
   template = 'FSDB_Snow';
end

%specify default title unless provided as input
if exist('titlestr','var') ~= 1
   titlestr = 'Import raw output from FSDB';
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
   filespec = '*.txt;*.asc;*.csv;*.dat;*.prn;*.ans';  %use standard text file specifier
elseif exist([pn,filesep,fn],'file') ~= 2
   filespec = fn;  %use unlocated filename as file specifier
   fn = '';
end

%prompt for file if omitted or invalid
if isempty(fn)
   cd(pn)
   [fn,pn] = uigetfile(filespec,'Select a text file to import');
   cd(curpath)
   drawnow
end

%pass filename, pathname, and static parameters to custom ASCII import filter
if fn ~= 0

   %import the data file
   [s,msg] = imp_ascii(fn,pn,titlestr,template,format_string,column_names,num_header_rows,missing_codes,delimiter);

   %update the title
   if ~isempty(s) && ~isempty(titlestr)
      s = newtitle(s,titlestr);
   end

  %add units if no template specified
  if isempty(template) && ~isempty(unitlist)
     units = splitstr(unitlist,',',0,1);  %split unit string into cell array
     if length(units) == length(s.units)
        s.units = units(:)';  %use parsed units, forcing row array
     end
  end

   %add custom post-processing commands below this line

else
   msg = 'import cancelled';
end
