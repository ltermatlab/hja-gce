function [s2,msg] = daterange2flags(s,datecol,dates,cols,flag)
%Assigns Q/C flags by date range and locks flags to prevent automatic recalculation
%
%syntax: [s2,msg] = daterange2flags(s,datecol,dates,cols,flag)
%
%input:
%  s = data structure to modify
%  datecol = index or name of column containing date information (MATLAB serial date or
%     formatted date string)
%  dates = 2-column array of starting and ending dates for time periods to flag
%     (MATLAB serial date number or cell array of formatted date strings)
%  cols = array of column names or numbers to flag (all columns if cols = [])
%  flag = flag character to assign (1 character string, default = 'Q')
%
%output:
%  s2 = updated data structure
%  msg = text of any error message
%
%
%(c)2009-2011 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 17-Oct-2011

%init output
s2 = [];
msg = '';

%check for required input
if nargin >= 3 && gce_valid(s,'data')
   
   %assign defaults for omitted arguments
   if exist('cols','var') ~= 1
      cols = 1:length(s.name);
   end
   
   if exist('flag','var') ~= 1
      flag = 'Q';
   end
   
   %get numeric dates from structure
   [dt,msg0] = get_studydates(s,datecol);
   
   if ~isempty(dt)
      
      %look up column indices or validate numeric indices
      if ~isnumeric(cols)
         cols = name2col(s,cols);
      elseif ~isempty(cols)
         cols = setdiff((1:length(s.name)),cols);
      else
         cols = 1:length(s.name);  %default to all if empty array
      end
      
      %check for valid data columns
      if ~isempty(cols)
         
         %check for valid date range matrix
         if size(dates,2) == 2
            
            %validate flag
            if ischar(flag) && ~isempty(flag)
               flag = flag(1);
            else
               flag = '';
            end
            
            if ~isempty(flag)
               
               %generate numeric serial dates
               if iscell(dates)
                  
                  dates0 = dates;  %buffer original strings
                  dates = repmat(NaN,size(dates0,1),2);  %init numeric matrix
                  
                  %loop through date range elements, converting to numeric
                  for n = 1:size(dates,1)
                     try  %try standard matlab formats
                        dstart = datenum(dates0{n,1});
                        dend = datenum(dates0{n,2});
                     catch
                        try  %try iso formats
                           dstart = datenum_iso(dates0{n,1});
                           dend = datenum_iso(dates0{n,2});
                        catch  %conversion failed = leave as NaN
                           dstart = NaN;
                           dend = NaN;
                        end
                     end
                     
                     %update numeric data matrix if date range valid
                     if dend > dstart
                        dates(n,1) = dstart;
                        dates(n,2) = dend;
                     end
                     
                  end
                  
                  %check for any unconverted dates
                  if sum(sum(isnan(dates))) > 0
                     dates = [];
                  end
                  
               elseif ~isnumeric(dates)
                  dates = [];  %unsupported data type
               end
               
               %check for valid date ranges
               if ~isempty(dates)

                  numrows = length(s.values{1});  %get length of data structure value arrays
                  flags = repmat(' ',numrows,1);  %init flag array
                  
                  %build indices of dataset dates within range, update flag array
                  for n = 1:size(dates,1)
                     d1 = dates(n,1);
                     d2 = dates(n,2);
                     Imatch = find(dt >= d1 & dt <= d2);                       
                     if ~isempty(Imatch)
                        flags(Imatch,1) = flag;
                     else
                        dates(n,1:2) = NaN;
                     end
                  end
                  dates = dates(~isnan(dates(:,1)),:);

                  %check for assigned flags, apply to data structure
                  if ~isempty(find(flags ~= ' '))
                     
                     %generate column string
                     if length(cols) > 1
                        colstr = 'columns ';
                     else
                        colstr = 'column ';
                     end
                     
                     %generate date range string
                     if size(dates,1) > 1
                        dstr = ' for date ranges ';
                     else
                        dstr = ' for date range ';
                     end
                     for n = 1:size(dates,1)
                        dstr = [dstr,datestr(dates(n,1)),' to ',datestr(dates(n,2)),' and '];
                     end
                     dstr = dstr(1:length(dstr)-5);  %remove trailing " and "
                        
                     %generate history string
                     str = ['assigned flag ''',flag,''' to ',colstr, ...
                        cell2commas(s.name(cols),1),dstr];
                     
                     %add history entry
                     s2 = add_history(s,str,'daterange2flags');
                     
                     %add flags (automatically locking criteria)
                     s2 = dataflag(s2,cols,flags);
                     
                  else  %no matching dates - return unmodified structure and message
                     
                     s2 = s;
                     msg = 'no matching dates found - structure not updated';
                     
                  end
                  
               else
                  msg = 'one or more date ranges are invalid';
               end
               
            else
               msg = 'invalid flag character';
            end
            
         else
            msg = 'invalid date range input';
         end
         
      else
         msg = 'invalid data column selections';
      end
      
   else
      msg = ['an error occurred - ',msg0];
   end
   
else
   
   if nargin < 5
      msg = 'required input is missing';
   else
      msg = 'invalid data structure';
   end
   
end

