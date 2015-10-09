function [s,msg] = hobo_test_importer(fn,pn,template,titlestr)
%Custom text file import filter for the GCE Data Toolbox generated on 09-Sep-2014
%based on a user-defined filter for 'RS02_2014_134.csv'
%
%syntax:  [s,msg] = hobo_test_importer(fn,pn,template,title)
%
%inputs:
%  fn = file name to import (default = prompted)
%  pn = pathname for fn (default = pwd)
%  template = metadata template (default = 'HOBO_test')
%  title = data set title (default = '')
%
%outputs:
%  s = GCE Data Structure
%  msg = text of any error messages
%
%created: 09-Sep-2014 14:20:26

%initialize outputs:
s = [];
msg = '';

%define runtime variables
curpath = pwd;
format_string = '%d %s %f %f %s %s %s';
column_names = '';
unitlist = '';
num_header_rows = 2;
delimiter = ',';
missing_codes = '';

%specify empty template unless provided as input
if exist('template','var') ~= 1
   template = 'HOBO_test';
end

%specify default title unless provided as input
if exist('titlestr','var') ~= 1
   titlestr = '';
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
   if gce_valid(s)
       
       if ~isempty(s)
           
           %check new records for duplicate records
           [s,msg] = cleardupes( ...
               s, ...                   %data structure
               {'Date'}, ...               %{data.name{2}}, ...        %date column
               'verbose' ...               %logging option
               );
           %document anomalies (missing values and flags from QA/QC rules)
           [s,msg] = add_anomalies( ...
               s, ...   %data structure to update
               23, ...     %date format (see 'help datestr')
               '-', ...    %date range separator
               1, ...      %option to document missing values
               [] ...      %column selection ([] = all)
               );
           [s,msg] = pad_date_gaps( ...
               s, ...  %data structure to update
               [], ...    %date column ([] = auto)
               1, ...     %remove duplicates option (1 = yes)
               1 ...      %replicate non-data values option (1 = yes)
               );
           [s, msg] = add_datepartcols( ...
               s, ...
               'Date', ...
               '', ...
               '', ...
               '' ...
               );
           cols = {'RecNum','Column5','Column6','Column7','Second'};
           s = deletecols( ...
               s, ...
               cols ...
               );
           
       end
   end

else
   msg = 'import cancelled';
end
