function [s2,msg] = calc_date_cr10(s,col_year,col_yearday,col_time,timezone)
%Adds a serial date column calculated from year, yearday and integer time columns from a Campbell CR10x logger file
%
%syntax: [s2,msg] = calc_date_cr10(s,col_year,col_yearday,col_time,timezone)
%
%inputs:
%  s = data structure to update
%  col_year = name or index number of the Year column (default = case-insensitive search for a column name 'Year'
%    or column with units 'yyyy')
%  col_yearday = name or index number of the YearDay or JulianDay column for determining day of year (default =
%    case-insensitive search for a column name starting with 'julian' or 'yearday' or having units
%    starting with 'day')
%  col_time = name or index number of the Time column for determmining time of day (default = case-insensitive search
%     for a column name starting with 'time' or having units 'hhmm')
%  timezone = time zone of time observations (default = '' for unspecified)
%
%output:
%  s2 = updated data structure
%  msg = text indicating the status of the processing
%
%(c)2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 15-Jul-2013

s2 = [];

if nargin >= 1 && gce_valid(s,'data')
   
   %init column match indices
   Iyearcol = [];
   Iyeardaycol = [];
   Itimecol = [];
   yearcol = [];
   yeardaycol = [];
   timecol = [];
   
   %look up datetime columns for date calculation based on metadata
   colnames = s.name;
   units = s.units;
   vartypes = s.variabletype;   
   dtcols = find(strcmp(vartypes,'datetime'));
   
   %validate year column
   if exist('col_year','var') ~= 1
      col_year = '';
   elseif ~isnumeric(col_year)
      col_year = name2col(s,col_year);
   end
   
   %validate yearday column
   if exist('col_yearday','var') ~= 1
      col_yearday = '';
   elseif ~isnumeric(col_yearday)
      col_yearday = name2col(s,col_yearday);
   end
   
   %validate time column
   if exist('col_time','var') ~= 1
      col_time = '';
   elseif ~isnumeric(col_time)
      col_time = name2col(s,col_time);
   end
   
   %set default timezone if omitted
   if exist('timezone','var') ~= 1
      timezone = '';
   end
   
   %look up year if not defined
   if ~isempty(col_year)
      %look up specified column
      Iyearcol = find(strcmpi(colnames,col_year));
   end
   if isempty(Iyearcol)
      %search for column
      Iyearcol = find(strcmpi(colnames(dtcols),'year') | strcmpi(units(dtcols),'yyyy'));
   end
   if ~isempty(Iyearcol)
      yearcol = dtcols(Iyearcol(1));
   end
   
   %look up yearday if not defined
   if ~isempty(col_yearday)
      %look up specified column
      Iyeardaycol = find(strcmpi(colnames,col_yearday));
   end
   if isempty(Iyeardaycol)
      %search for column
      Iyeardaycol = find(strcmpi(colnames(dtcols),'yearday') | strncmpi(colnames(dtcols),'jul',3) | strncmpi(units(dtcols),'day',3));
   end
   if ~isempty(Iyeardaycol)
      yeardaycol = dtcols(Iyeardaycol(1));
   end
   
   %look up time if not defined
   if ~isempty(col_time)
      %look up specified column
      Itimecol = find(strcmpi(colnames,col_time));
   end
   if isempty(Itimecol)
      %search for column
      Itimecol = find(strncmpi(colnames(dtcols),'time',4) | strncmpi(colnames(dtcols),'hour',4) | strncmpi(units(dtcols),'hr',2) | strcmpi(units(dtcols),'hhmm'));
   end
   if ~isempty(Itimecol)
      timecol = dtcols(Itimecol(1));
   end
   
   %check for both yearday and time columns
   if length(yearcol) == 1 && length(yeardaycol) == 1 && length(timecol) == 1
      
      %extract arrays
      yr = extract(s,yearcol);
      dy = extract(s,yeardaycol);
      t = extract(s,timecol);
      
      %check for string arrays - convert to double
      if iscell(yr)
         yr = str2double(yr);
      end
      if iscell(dy)
         dy = str2double(dy);
      end
      if iscell(t)
         t = str2double(t);
      end
      
      %add calculated serial date (optionally converted to GMT) to each array
      padzeros = zeros(length(yr),1);
      mo = padzeros;  %use zeros for month
      hr = fix(t./100);  %calc decimal hours
      mi = t-fix(t./100).*100;  %calc minutes
      sc = padzeros;  %use zeros for seconds
      d = datenum(yr,mo,dy,hr,mi,sc);  %calc serial date
      
   else
      d = [];
   end
   
   %add date column if calculated
   if ~isempty(d)
      
      %format time zone if defined
      if ~isempty(timezone)
         timezone = [' - ',timezone];
      end
      
      %get position of first date/time column
      pos = min([yearcol,yeardaycol,timecol]);
      
      %add column
      [s2,msg] = addcol(s,d,'Date', ...
         ['serial day (base 1/1/0000)',timezone], ...
         'Fractional MATLAB serial day (based on 1 = January 1, 0000)', ...
         'f', ...
         'datetime', ...
         'continuous', ...
         7, ...
         '', ...
         pos);
      
      %add specific history entry to replace generic addcol entry
      s2.history = [s.history ; ...
         {datestr(now)},{['calculated MATLAB serial date from year column ''',s.name{yearcol},''', year day column ''', ...
         s.name{yeardaycol},''' and time column ''',s.name{timecol},''' (''calc_date_cr10'')']}];
      
   else
      msg = 'year, yearday and/or time columns are not present or could not be determined';
   end
   
else
   msg = 'invalid data structure';
end