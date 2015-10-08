function msg = harvest_check(s,days,missing,flagged,daily_missing,daily_flagged,wrap)
%Generates a harvest check email based on user-specified thresholds for missing and flagged values
%
%syntax: msg = harvest_check(s,days,missing,flagged,daily_flagged,wrap)
%
%input:
%  s = data structure to validate (required)
%  days = number of days prior to the current date to check (integer; default = 7, [] for all)
%  missing = threshold for maximum total missing values in any column
%     (integer; default = 0 for any, [] = skip check)
%  flagged = threshold for maximum total flagged values in any column
%     (integer; default = 0 for any, [] = skip check)
%  daily_missing = threshold for maximum missing values in any one day
%     (integer; default = 0 for any, [] = skip check)
%  daily_flagged = threshold for maximum flagged values in any one day
%     (integer; default = 0 for any, [] = skip check)
%  wrap = number of characters per line (integer; default = 100; minimum = 30)
%
%output:
%  msg = text summarizing columns that exceed the specified thresholds
%      (multi-line character array, or empty array if none exceeded)
%
%(c)2012 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 25-Aug-2012

%init output
msg = '';

%check for required data structure
if nargin >= 1
   
   %check for valid data structure to check
   if gce_valid(s,'data')
      
      %validate number of days argument
      if exist('days','var') ~= 1 || ~isnumeric(days)
         days = 7;
      elseif ~isempty(days) && days < 1
         days = 1;
      end
      
      %validate missing check limit
      if exist('missing','var') ~= 1 || ~isnumeric(missing)
         missing = 0;
      end
      
      %validate flagged check limit
      if exist('flagged','var') ~= 1 || ~isnumeric(flagged)
         flagged = 0;
      end
      
      %validate daily_missing check limit
      if exist('daily_missing','var') ~= 1 || ~isnumeric(daily_missing)
         daily_missing = 0;
      end
      
      %validate daily_flagged check limit
      if exist('daily_flagged','var') ~= 1 || ~isnumeric(daily_flagged)
         daily_flagged = 0;
      end
      
      %validate word wrap
      if exist('wrap','var') ~= 1 || ~isnumeric(wrap)
         wrap = 100;
      elseif wrap < 30
         wrap = 30;
      end
      
      %cache title string prior to data subsetting
      titlestr = s.title;
      
      %subset dataset if days specified
      if ~isempty(days)
         dt = get_studydates(s);  %get array of datetime values for each record
         Irecent = find(no_nan(dt) > (now-days));  %get index of dates since days
         if ~isempty(Irecent)
            s = deleterows(s,(1:min(Irecent)));  %delete older dates
         else
            s = [];  %no dates since days - return empty structure
         end
      end
      
      %check for any valid checks to perform
      if ~isempty(s) && (~isempty(missing) || ~isempty(flagged) || ~isempty(daily_missing) || ~isempty(daily_flagged))
         
         %init column name arrays for reporting
         cols_missing = [];
         cols_flagged = [];
         cols_daily_missing = [];
         cols_daily_flagged = [];
         
         %init missing and flagged value totals
         num_missing = [];
         num_flagged = [];
         
         %check for total checks
         if ~isempty(missing) || ~isempty(flagged)
            
            %generate stat structure, including flagged values
            stats = colstats(s,'I');
            
            %generate array of columns exceding total missing
            if ~isempty(missing)
               Imatch = find(stats.missing > missing);
               if ~isempty(Imatch)
                  cols_missing = stats.name(Imatch);
                  num_missing = stats.missing(Imatch);
               end
            end
            
            %generate array of columns exceding total flagged
            if ~isempty(flagged)
               Imatch = find(stats.flagged > flagged);
               if ~isempty(Imatch)
                  cols_flagged = stats.name(Imatch);
                  num_flagged = stats.flagged(Imatch);
               end
            end
            
         end
         
         %check for daily checks
         if ~isempty(daily_flagged) || ~isempty(daily_missing)
            
            %look up or generate day column
            daycol = name2col(s,'Day');
            if isempty(daycol)
               s = add_datepartcols(s);
               daycol = name2col(s,'Day');
            end
            
            %check for day column, perform checks with grouped stats
            if ~isempty(daycol)
               
               %generate daily grouped stats
               stats = colstats(s,'I',daycol);
               
               %generate array of columns exceding daily_missing
               if ~isempty(daily_missing)
                  numdays = size(stats.missing,1);
                  numcols = size(stats.missing,2);
                  matches = zeros(numdays,numcols);
                  for n = 1:numdays
                     Imatch = (stats.missing(n,:) > daily_missing);
                     matches(n,Imatch) = 1;
                  end
                  Imatches = find(sum(matches) > 0);
                  if ~isempty(Imatches)
                     cols_daily_missing = stats.name(Imatches);
                  end
               end
               
               %generate array of columns exceding daily_flagged
               if ~isempty(daily_flagged)
                  numdays = size(stats.flagged,1);
                  numcols = size(stats.flagged,2);
                  matches = zeros(numdays,numcols);
                  for n = 1:numdays
                     Imatch = (stats.flagged(n,:) > daily_flagged);
                     matches(n,Imatch) = 1;
                  end
                  Imatches = find(sum(matches) > 0);
                  if ~isempty(Imatches)
                     cols_daily_flagged = stats.name(Imatches);
                  end
               end
               
            end
            
         end
         
         %check for any column matches, generate message
         if ~isempty(cols_missing) || ~isempty(cols_flagged) || ~isempty(cols_daily_missing) || ~isempty(cols_daily_flagged)
            
            %init mesage
            msg0 = wordwrap(['The data set ''',titlestr,''' failed the following post-harvest quality checks at ', ...
               datestr(now,0),':'],wrap,0,'char');
            
            %generate missing values message
            if ~isempty(missing)
               msg_missing = ['Total missing values > ',int2str(missing),': '];
               if ~isempty(cols_missing)
                  str_missing = concatcellcols([cols_missing', ...
                     repmat({'('},length(cols_missing),1), ...
                     strrep(cellstr(num2str(num_missing')),' ',''), ...
                     repmat({')'},length(cols_missing),1)],'')';
                  msg_missing = wordwrap([msg_missing,cell2commas(str_missing)],wrap,3,'char');
               else
                  msg_missing = [msg_missing,'none'];
               end
            else
               msg_missing = 'Total missing values not checked';
            end
            
            %generate flagged value message
            if ~isempty(flagged)
               msg_flagged = ['Total flagged values > ',int2str(flagged),': '];
               if ~isempty(cols_flagged)
                  str_flagged = concatcellcols([cols_flagged', ...
                     repmat({'('},length(cols_flagged),1), ...
                     strrep(cellstr(num2str(num_flagged')),' ',''), ...
                     repmat({')'},length(cols_flagged),1)],'')';
                  msg_flagged = wordwrap([msg_flagged,cell2commas(str_flagged)],wrap,3,'char');
               else
                  msg_flagged = [msg_flagged,'none'];
               end
            else
               msg_flagged = 'Total flagged values not checked';
            end
            
            %generate daily missing value message
            if ~isempty(daily_missing)
               msg_daily_missing = ['Daily missing values > ',int2str(daily_missing),': '];
               if ~isempty(cols_daily_missing)
                  msg_daily_missing = wordwrap([msg_daily_missing,cell2commas(cols_daily_missing)],wrap,3,'char');
               else
                  msg_daily_missing = [msg_daily_missing,'none'];
               end
            else
               msg_daily_missing = 'Daily missing values not checked';
            end
            
            %generate daily flagged value message
            if ~isempty(daily_flagged)
               msg_daily_flagged = ['Daily flagged values > ',int2str(daily_flagged),': '];
               if ~isempty(cols_daily_flagged)
                  msg_daily_flagged = wordwrap([msg_daily_flagged,cell2commas(cols_daily_flagged)],wrap,3,'char');
               else
                  msg_daily_flagged = [msg_daily_flagged,'none'];
               end
            else
               msg_daily_flagged = 'Daily flagged values not checked';
            end
            
            %generate formatted output message
            msg = char(msg0,' ', ...
               msg_missing,' ', ...
               msg_flagged,' ', ...
               msg_daily_missing,' ', ...
               msg_daily_flagged);
            
         end
         
      elseif isempty(s) && ~isempty(days)
         
         %generate no recent data message
         msg = char(wordwrap(['The data set ''',titlestr,''' failed the following post-harvest quality checks at ', ...
               datestr(now,0),':'],wrap,0,'char'), ...
               ' ', ...
               ['No data more recent then ',datestr(now-days,0),' were present in the data set']);
         
      end
      
   else
      
      %generate no data message
      msg = 'No data were harvested (empty data structure returned from harvester)';
      
   end
   
else
   
   %generate error message
   msg = 'Insufficient arguments for ''harvest_check'' function';
   
end
