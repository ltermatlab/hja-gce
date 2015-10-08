function [s2,msg] = aggr_movingdatewindow(s,days,datecol,agcols,statcols,statopt,flagopt,qcrules)
%Generates a smoothed time series data set by statistically summarizing values along a sliding date window
%
%syntax: [s2,msg] = aggr_movingdatewindow(s,days,datecol,agcols,statcols,statopt,flagopt,qcrules)
%
%input:
%  s = data structure to modify (required)
%  days = number of preceeding days to average for each time point (required)
%  datecol = serial date or string date column (default = automatic detection of datetime column)
%  agcols = ordered array of columns to group records by prior to grouping for statistics (default = [])
%  statcols = ordered array of columns to calculate statistics for (default = all numeric, non-datetime columns)
%  statopt = an array of integers specifying the statistics to calculate for each column in 'statcols':
%     0 = auto {default}
%     1 = count only (default for strings)
%     2 = count, min, max (default for numeric column of non-data/non-calculation variable type)
%     3 = count, min, max, total, median (default integer stats for data/calculation variable type)
%     4 = count, min, max, total, mean/vecavg, stddev, se (default floating-point/exp. stats for data/calculation type)
%     5 = count, min, max, mean/vecavg, stddev, se (same as 4 without total for rates or other non-quantity variables)
%     6 = count, mean/vecavg
%     7 = count, total
%  flagopt = option for clearing QA/QC flagged values prior to aggregation
%     0 = retain flagged values (default)
%     1 = remove all flagged values (convert to NaN/'')
%     character array = selectively remove values assigned any flag in the array (e.g. 'IQ')
%  qcrules = 4-column cell array of strings defining Q/C rules to add to the output structure to flag statistics
%     based on the presence of missing and/or flagged values in each aggregate, as follows:
%       col 1: type of criteria ('flagged' or 'missing')
%       col 2: numerical criteria (character array containing a number >= 0)
%       col 3: metric ('percent','count','consecutive')
%       col 4: flag to assign (single character)
%     example:
%        {'flagged','0','count','Q'; 'missing','10','percent','Q'} --> 
%         rules: col_Flagged_[colname]>0='Q';col_Percent_Missing_[colname]>10='Q'     
%
%notes:
%   1. A scalar value of 'statopt' will be replicated to match the length of 'statcols'
%   2. Values of 'statopt' > 1 will be set to 1 for string columns
%   3. Any columns in 'statcols' that also appear in 'agcols' will be removed
%   4. Column properties and metadata are copied or created as appropriate for each summary column
%   5. For floating-point columns with numeric type 'angular' (e.g. wind direction), a vector average
%      will be calculated instead of arithmetic mean and no standard deviation or error will be calculated
%
%output:
%  s2 = modifed structure
%  msg = text of any error message
%
%(c)2008-2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
%
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
%last modified: 25-Jun-2013

%init output
s2 = [];
msg = '';

%check for required input
if nargin >= 2
   
   if gce_valid(s,'data')
      
      %validate input or supply defaults
      if exist('statcols','var') ~= 1
         Icols = find(~strcmp(s.datatype,'s') & ~strcmp(s.variabletype,'datetime'));
         if ~isempty(Icols)
            statcols = Icols;
         end
      elseif ~isnumeric(statcols)
         statcols = name2col(s,statcols);
      end
      
      %default to no aggregation cols (other than derived bin)
      if exist('agcols','var') ~= 1
         agcols = [];
      elseif ~isnumeric(agcols)
         agcols = name2col(s,agcols);
      end
      
      %default to auto stats
      if exist('statopt','var') ~= 1
         statopt = 0;
      end
      
      %default to retain flagged values
      if exist('flagopt','var') ~= 1
         flagopt = 0;
      end
      
      %default to no flagging of derived values
      if exist('qcrules','var') ~= 1
         qcrules = [];
      end
      
      %get serial dates using external function, returning modified structure in case serial date col auto-generated
      if exist('datecol','var') ~= 1
         datecol = [];
      end
      [dt,msg0,s2,datecol] = get_studydates(s,datecol);      

      %check for valid stat cols and serial date
      if ~isempty(statcols) && ~isempty(dt) && ~isempty(datecol)
         
         %sort dataset by dates using serial date array
         [tmp,Isort] = sort(dt);
         s2 = copyrows(s2,Isort);
         
         %get flanking indices for records n days prior to each record in dataset
         Istart = zeros(length(dt),1);  %init start index
         Istart(1) = 1;
         Iend = (1:length(dt))';  %init end index
         for n = 2:length(dt)
            Isub = (Istart(n-1):n);  %get sub index starting with prior match, ending with current record (for speed)
            Istart(n) = Isub(min(find(dt(Isub) >= (dt(n)-days))));  %find first record n days prior to current record
         end
         
         %generate master index for copying records and corresponding array of bins for aggregation
         numrecs = sum(Iend - Istart + 1);  %calculate total number of records (for dimensioning arrays for speed)
         Icopy = zeros(numrecs,1);  %init record copy index
         bins = Icopy;  %init bin array
         Iptr = 1;  %init insert pointer
         for n = 1:length(Istart)
            Inew = (Istart(n):Iend(n))';    %generate sequence of records to copy for bin
            len = length(Inew);             %calculate length of insert
            Icopy(Iptr:Iptr+len-1) = Inew;  %insert sequence into master copy array
            bins(Iptr:Iptr+len-1) = n;      %insert matching bin numbers
            Iptr = Iptr + len;              %increment index pointer to next set
         end
         
         %sub-select to remove unneeded columns
         s2 = copycols(s2,[agcols(:) ; datecol ; statcols(:)]);
         
         %buffer processing history for documenting group copying instead of generic row copying, column addition
         strhist = s2.history;
         
         %copy records acccording to duplication index
         s2 = copyrows(s2,Icopy);
         
         %add history entry for record copying
         s2.history = [strhist ; {datestr(now)},{['copied records to generate groups of observations spanning ',num2str(days), ...
                     ' days prior to each original observation for calculating statistics along a moving date window ', ...
                     '(''moving_date_stats'')']}];
         
         %add bin column after aggregation columns
         s2 = addcol(s2,bins,'DateWindowBin','none','Bin column for aggregated statistics','d', ...
            'interval','discrete',0,'',length(agcols)+1);
         
         %generate stats using generate aggregation function
         [s2,msg] = aggr_stats(s2,(1:length(agcols)+1),(2:length(s2.name)),statopt,flagopt,qcrules);
         
         %delete derived binning column
         if ~isempty(s2)
            strtitle = ['Statistical summary of ',s.title,' using a moving date window of ',num2str(days), ...
                  ' days preceeding each observation'];
            s2 = newtitle(s2,strtitle);
            s2 = deletecols(s2,'DateWindowBin');
         end
         
      else
         if isempty(statcols)
            msg = 'invalid column selection';
         else
            msg = 'invalid date column (or no datetime columns could be determined)';
         end
      end
      
   else
      msg = 'invalid data structure';
   end
   
else
   msg = 'insufficient arguments';
end