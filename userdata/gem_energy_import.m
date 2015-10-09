function [s,msg] = gem_energy_import(fn,pn,template,titlestr)
%Custom text file import filter for the GCE Data Toolbox generated on 17-Jul-2014
%based on a user-defined filter for 'GREENHouse_1.csv'
%
%syntax:  [s,msg] = gem_energy_import(fn,pn,template,title)
%
%inputs:
%  fn = file name to import (default = prompted)
%  pn = pathname for fn (default = pwd)
%  template = metadata template (default = 'GEM_v1')
%  title = data set title (default = 'GEM derived energy data from GREEN House')
%
%outputs:
%  s = GCE Data Structure
%  msg = text of any error messages
%
%created: 17-Jul-2014 09:08:09

%initialize outputs:
s = [];
msg = '';

%define runtime variables
curpath = pwd;
format_string = '%s %d %f %s %s %s %s %s %s %s %s %d %d %d %d %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f';
column_names = 'Date/Time,Seconds,Volt,T1,T2,T3,T4,T5,T6,T7,T8,Cnt1,Cnt2,Cnt3,Cnt4,P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12,P13,P14,P15,P16,P17,P18,P19,P20,P21,P22,P23,P24,P25,P26,P27,P28,P29,P30,P31,P32,kWh1,kWh2,kWh3,kWh4,kWh5,kWh6,kWh7,kWh8,kWh9,kWh10,kWh11,kWh12,kWh13,kWh14,kWh15,kWh16,kWh17,kWh18,kWh19,kWh20,kWh21,kWh22,kWh23,kWh24,kWh25,kWh26,kWh27,kWh28,kWh29,kWh30,kWh31,kWh32';
unitlist = '';
num_header_rows = 1;
delimiter = ',';
missing_codes = '';

%specify empty template unless provided as input
if exist('template','var') ~= 1
   template = 'GEM_v1';
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

else
   msg = 'import cancelled';
end
