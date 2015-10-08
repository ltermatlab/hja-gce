function [s,msg] = imp_ncdc_psdi(fn,pn,template,titlestr)
%Parses NCDC Palmer Drought Severity Index from http://www1.ncdc.noaa.gov/pub/data/cirs/climdiv/
%
%syntax:  [s,msg] = imp_ncdc_psdi(fn,pn,template,title)
%
%inputs:
%  fn = file name to import (default = prompted)
%  pn = pathname for fn (default = pwd)
%  template = metadata template (default = 'NCDC_nClimDiv_PSDI')
%  title = data set title (default = 'National Climatic Data Center nClimDiv Statewide Regional Palmer Drought Indices')
%
%outputs:
%  s = GCE Data Structure
%  msg = text of any error messages
%
%last modified: 08-Aug-2014

%initialize outputs:
s = [];

%define runtime variables
curpath = pwd;
format_string = '%2s%2s%2s%4d %f %f %f %f %f %f %f %f %f %f %f %f';
column_names = 'StateCode,Region,IndexCode,Year,Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec';
unitlist = '';
num_header_rows = 0;
delimiter = '';
missing_codes = '-99.99';

%specify empty template unless provided as input
if exist('template','var') ~= 1
   template = 'NCDC_nClimDiv_PSDI';
end

%specify default title unless provided as input
if exist('titlestr','var') ~= 1
   titlestr = 'National Climatic Data Center nClimDiv Statewide Regional Palmer Drought Indices from 1895 to 2014';
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
   [s,msg0] = normalize_cols(s, ...
      {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'}, ...  %cols to normalize
      {'StateCode','Region','IndexCode','Year'}, ...  %cols to replicate
      'Month', ...   %category column name
      'PSDI', ...    %value column name
      'match', ...  %units match option
      'f');          %value column data type
   
   if isempty(msg0)
      %add metadata for Month and PSDI
      s = update_attributes(s,'Month', ...
         {'units','description','variabletype'}, ...
         {'MMM','Calendar month of calculation','datetime'});
      s = update_attributes(s,'PSDI', ...
         {'units','description','variabletype'}, ...
         {'none','Calculated Palmer Drought Severity Index','calc'});
   else
      msg = ['an error occurred normalizing the data (',msg0,')'];
   end
   
else
   msg = 'import cancelled';
end
