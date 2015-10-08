function [s2,msg] = filter_by_daterange(s,date_start,date_end,comparison)
%Filters a GCE data structure to include one or more specified date ranges
%
%syntax: [s2,msg] = filter_by_daterange(s,date_start,date_end,comparison)
%
%input:
%  s = data structure to filter
%  date_start = array of starting dates for ranges (numeric or string dates)
%  date_end = array of ending dates for ranges (numeric or string dates)
%  comparison = date comparison option:
%     'inclusive' = inclusive comparison (dates within and including date_start/date_end)
%     'exclusive' = exclusive comparison (dates within but exclusing date_start/date_end)
%
%output:
%  s2 = updated structure
%  msg = text of any error message
%
%(c)2009 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 30-Jun-2009

s2 = [];
msg = '';

if nargin >= 3
   
   if exist('comparison','var') ~= 1
      comparison = 'inclusive';
   elseif ~strcmp(comparison,'exclusive')
      comparison = 'inclusive';
   end
   
   %convert cell array dates to char array, and force column orientation
   if iscell(date_start)
      date_start = char(date_start(:));
   elseif isnumeric(date_start)
      date_start = date_start(:);
   end
   
   if iscell(date_end)
      date_end = char(date_end(:));
   elseif isnumeric(date_end)
      date_end = date_end(:);
   end
   
   %generate numeric date arrays, if necessary
   if isnumeric(date_start)
      dt_start = date_start;
   else
      try
         dt_start = datenum(date_start);
      catch
         try
            dt_start = datenum_iso(date_start);
         catch
            dt_start = [];
         end
      end
   end
   
   if isnumeric(date_end)
      dt_end = date_end;
   else
      try
         dt_end = datenum(date_end);
      catch
         try
            dt_end = datenum_iso(date_end);
         catch
            dt_end = [];
         end
      end
   end   
   
   if ~isempty(dt_start) && ~isempty(dt_end) && length(dt_start) == length(dt_end)
      
      dt = get_studydates(s);  %retrieve array of serial dates based on date/time info in data set
   
      if ~isempty(dt)
         
         numrows = length(dt);  %cache original number of data rows
         
         Ifilter = zeros(length(dt),1);  %init record selection array;
         
         %loop through date ranges, flagging records in date range
         if strcmp(comparison,'inclusive')
            for n = 1:length(dt_start)
               Isel = find(dt >= dt_start(n) & dt <= dt_end(n));
               if ~isempty(Isel)
                  Ifilter(Isel) = 1;
               end
            end
         else
            for n = 1:length(dt_start)
               Isel = find(dt > dt_start(n) & dt < dt_end(n));
               if ~isempty(Isel)
                  Ifilter(Isel) = 1;
               end
            end
         end
         
         Ifilter = find(Ifilter);  %generate master filter index
         
         if ~isempty(Ifilter)
            
            s2 = copyrows(s,Ifilter,'Y');  %apply filter
            
            %generate history entry
            str = ['filtered data structure records based on ',int2str(length(dt_start))];
            if length(dt_start) > 1
               str = [str,' user-specified date ranges'];
            else
               str = [str,' user-specified date range'];
            end
            str = [str,', returning ',int2str(length(Ifilter)),' of ',int2str(numrows), ...
               ' records (''filter_by_daterange'')'];
            if length(dt_start) <= 10
               str = [str,':'];
               for n = 1:length(dt_start)
                  str = [str,' ',datestr(dt_start(n)),' to ',datestr(dt_end(n)),','];
               end
               str = [str(1:length(str)-1)];
            end
            
            %update history based on original structure to omit copyrows entry
            s2.history = [s.history ; {datestr(now),str}];
            
         else
            msg = 'no records were found within the specified date range(s)';
         end
         
      else
         msg = 'could not identify date/time columns in the source dataset';
      end
   
   else
      msg = 'invalid or unequal date arrays';
   end
   
else
   msg = 'insufficient arguments';
end
