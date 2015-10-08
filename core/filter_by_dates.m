function [s2,msg] = filter_by_dates(s,dates,datecol,tol,matchtype,showmatch)
%Filters a dataset to only include records for a specified set of dates
%matched within a specified tolerance
%
%syntax: [s2,msg] = filter_by_dates(s,dates,datecol,tolerance,matchtype,showmatch)
%
%inputs:
%  s = data structure
%  dates = array of MATLAB serial dates or date strings to filter by
%  datecol = data column in s to use for determining record dates
%    (default = determined automatically by 'get_studydates' function)
%  tolerance = match tolerance for selecting records, in decimal minutes
%    (default = 1, specify 0 for exact match)
%  matchtype = match type option
%    'all' = match all records within tolerance (default)
%    'closest' = match only closest records within tolerance
%  showmatch = option to include a column of target dates matched for each row
%    0 = no (default)
%    1 = yes
%
%outputs:
%  s2 = compacted structure (= s if no duplicated rows)
%  msg = text of any error message
%
%
%(c)2010 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 22-Feb-2010

%init output
s2 = [];
msg = '';

if nargin >= 2 && gce_valid(s,'data')
   
   %supply defaults for omitted arguments
   if exist('datecol','var') ~= 1
      datecol = [];
   end
   
   if exist('tol','var') ~= 1
      tol = [];
   end
   if isempty(tol)
      tol = 1;
   end
   
   if exist('matchtype','var') ~= 1
      matchtype = '';
   end
   if ~strcmpi(matchtype,'closest')
      matchtype = 'all';
   end
   
   if exist('showmatch','var') ~= 1
      showmatch = 0;
   end
   
   %convert tolerance to decimal days
   dy_tol =  tol ./ (60 .* 24);
   
   %convert string dates to numeric
   dt_dates = [];
   if ~isnumeric(dates)
      try
         dt_dates = datenum(dates);
      catch
         try
            dt_dates = datenum_iso(dates);  %try ISO date variants
         catch
            dt_dates = [];
         end
      end
   else
      dt_dates = dates;
   end
   
   if ~isempty(dt_dates)
      
      %get study dates as numeric date array
      [dt,msg] = get_studydates(s,datecol);
      
      %check for valid dates
      if ~isempty(dt)
         
         if ~isempty(find(~isnan(dt)))
            
            %init runtime vars
            num = length(dt_dates);
            Imatch = repmat({[]},num,2);

            %loop through filter dates
            if dy_tol > 0  
               if strcmpi(matchtype,'all')
                  for n = 1:num
                     dt_test = dt_dates(n);
                     Imatch0 = find(dt > dt_test-dy_tol & dt < dt_test+dy_tol);
                     if ~isempty(Imatch0)
                        Imatch{n,1} = Imatch0;
                        Imatch{n,2} = repmat(dt_test,length(Imatch0),1);
                     end
                  end
               else  %only closest 1 match
                  for n = 1:num
                     dt_test = dt_dates(n);
                     dt_diff = dt - dt_test;
                     [min_diff,Imatch0] = min(abs(dt_diff));
                     if ~isempty(Imatch0)
                        Imatch{n,1} = Imatch0;
                        Imatch{n,2} = repmat(dt_test,length(Imatch0),1);
                     end
                  end
               end
            else
               for n = 1:num
                  dt_test = dt_dates(n);
                  Imatch0 = find(dt == dt_test);
                  if ~isempty(Imatch0)
                     Imatch{n,1} = Imatch0;
                     Imatch{n,2} = repmat(dt_test,length(Imatch0),1);
                  end
               end
            end
            
            %concat hits
            Ifilter = cat(1,Imatch{:,1});
            
            if ~isempty(Ifilter)
               
               %concat date matches
               dt_matched = cat(1,Imatch{:,2});
               str_matched = cellstr(datestr(dt_matched));
               
               [s2,msg] = copyrows(s,Ifilter);
               
               %update processing history
               if dy_tol > 0
                  hist_str = ['filtered data set records based on ',int2str(length(dt_dates)), ...
                     ' date values matched within a tolerance of ',num2str(tol),' minutes, returning ', ...
                     int2str(length(s2.values{1})),' of ',int2str(length(s.values{1})), ...
                     ' records (''filter_by_dates'')'];
               else
                  hist_str = ['filtered data set records based on ',int2str(length(dt_dates)), ...
                     ' date values, returning ',int2str(length(s2.values{1})),' of ',int2str(length(s.values{1})), ...
                     ' records (''filter_by_dates'')'];
               end               
               s2.history = [s.history ; {datestr(now)},{hist_str}];      
               
               %add matched filter date column
               if showmatch == 1
                  s2 = addcol(s2,str_matched,'Filter_Date','YYYY-MMM-DD hh:mm:ss','Filter date matched for record', ...
                     's','datetime','none',0,'');
               end
               
            else
               msg = 'no matching dates were found';
            end
            
         else
            msg = 'no valid study dates were identified in the data structure';
         end
         
      end
      
   else
      msg = 'invalid date array';
   end
   
else
   if nargin < 2
      msg = 'insufficient arguments for function';
   else
      msg = 'invalid data structure';
   end
end
