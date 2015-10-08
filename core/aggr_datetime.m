function [s2,msg] = aggr_datetime(s,interval,dtcols,aggrcols,statcols,statopt,flagopt,qcrules,missing_anom,tminmax)
%Performs statistical aggregation on selected data columns at the specified date/time interval
%after optionally grouping by one or more categorical data columns
%
%syntax: [s2,msg] = aggr_datetime(s,interval,dtcols,aggrcols,statcols,statopt,flagopt,qcrules,missing_anom,tminmax)
%
%inputs:
%   s = original data structure
%   interval = date/time interval ('year','month','day','hour')
%   dtcols = ordered array of numerical date/time component columns ('Year','Month','Day','Hour')
%     matching 'interval' (automatically determined if omitted)
%   aggrcols = ordered array of additional columns to sort and aggregate by (default = [])
%   statcols = ordered array of columns to calculate statistics for (default = all columns
%     with variabletype = 'data' or 'calculation')
%   statopt = an array of integers specifying the statistics to calculate for each column in 'statcols':
%       0 = auto {default}
%       1 = count only (default for strings)
%       2 = count, min, max (default for numeric column of non-data/non-calculation variable type)
%       3 = count, min, max, total, median (default integer stats for data/calculation variable type)
%       4 = count, min, max, total, mean/vecavg, stddev, se (default floating-point/exp. stats for data/calculation type)
%       5 = count, min, max, mean/vecavg, stddev, se (same as 4 without total for rates or other non-quantity variables)
%       6 = count, mean/vecavg
%       7 = count, total
%   flagopt = option for clearing QA/QC flagged values in statcols prior to aggregation
%       0 = retain flagged values (default)
%       1 = remove all flagged values (convert to NaN/'')
%       character array = selectively remove only values assigned any flag in the array
%   qcrules = 4-column cell array defining Q/C rules to add to the output structure to flag statistics
%       based on precence of missing and/or flagged values in each aggregate, as follows:
%          col 1: type of criteria ('flagged' or 'missing')
%          col 2: numerical criteria (character array containing a number >= 0)
%          col 3: metric ('percent','count','consecutive')
%          col 4: flag to assign (single character)
%       example:
%          {'flagged','0','count','Q'; 'missing','10','percent','Q'} -->
%             rules: col_Flagged_[colname]>0='Q';col_Percent_Missing_[colname]>10='Q'
%   missing_anom = option to summarize missing values along with flagged values in the data anomalies metadata
%     0 = no (default)
%     1 = yes
%   tminmax = option to include Time_Min_... and Time_Max ... columns when min/max are included
%       0 = no
%       1 = yes (default)
%
%outputs:
%   s2 = new data structure containing the columns in 'aggrcols', 'dtcols' and
%      relevant statistical summary columns (Note: also generates a serial date
%      column if present in the original structure)
%   msg = text of any error messages
%
%notes:
%   1. A scalar value of 'statopt' will be replicated to match the length of 'statcols'
%   2. Values of 'statopt' > 1 will be set to 1 for string columns
%   3. Any columns in 'statcols' that also appear in 'agcols' will be removed
%   4: column properties and metadata are copied or created as appropriate for each summary column
%   5. For floating-point columns with numeric type 'angular' (e.g. wind direction), a vector average
%      will be calculated instead of arithmetic mean and no standard deviation or error will be calculated
%   6. If any missing or flagged values are present, columns Missing_[colname], Percent_Missing_[colname],
%      Flagged_[colname], Percent_Flagged_[colname] will be included regardless of specific qcrules;
%      however, Consecutive_Missing_[colname] and Consecutive_Flagged_[colname] will only be included
%      if corresponding Q/C rules are defined.
%
%(c)2002-2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 17-Apr-2014

s2 = [];

if nargin >= 2

   %init date/time lookup list
   dtcollist = {'year','month','day','hour'};

   interval = lower(interval);

   if gce_valid(s,'data') && inlist(interval,dtcollist)

      %apply defaults for missing input
      if exist('aggrcols','var') ~= 1
         aggrcols = [];
      elseif ~isnumeric(aggrcols)
         aggrcols = name2col(s,aggrcols);
      end

      %supply default for omitted statcols (all 'data', 'calculation' columns, skipping datetime columns)
      if exist('statcols','var') ~= 1
         statcols = [];
      elseif ~isnumeric(statcols)
         statcols = name2col(s,statcols);
      end      
      if isempty(statcols)
         statcols = listdatacols(s);
         if ~isempty(aggrcols)
            statcols = setdiff(statcols,aggrcols);
         end
      end

      %supply default for omitted statopt (leave validation to aggr_stats.m)
      if exist('statopt','var') ~= 1
         statopt = 0;
      end

      %supply default for omitted flagopt (leave validation to aggr_stats.m)
      if exist('flagopt','var') ~= 1
         flagopt = 0;
      end
      
      %apply default qcrules if omitted, otherwise validate
      if exist('qcrules','var') ~= 1
         qcrules = [];
      end
      if ~isempty(qcrules)
         if iscell(qcrules)
            if size(qcrules,2) == 4
               Ivalid = find(~cellfun('isempty',qcrules(:,1)));
               if ~isempty(Ivalid)
                  qcrules = qcrules(Ivalid,:);
               else
                  qcrules = [];
               end
            else
               qcrules = [];
            end
         else
            qcrules = [];
         end
      end
      
      %supply default missing_anom option if omitted
      if exist('missing_anom','var') ~= 1
         missing_anom = 0;
      end
      
      %supply default tminmax option if omitted
      if exist('tminmax','var') ~= 1 || tminmax ~= 0
         tminmax = 1;
      end

      %get number of date time columns specified
      numdtcols = find(strcmp(dtcollist,interval));

      if exist('dtcols','var') ~= 1
         dtcols = [];
      else
         if ~isnumeric(dtcols)
            dtcols = name2col(s,dtcols);
         end
      end

      %auto-determine dt columns
      if isempty(dtcols)
         dtcols = name2col(s,dtcollist(1:numdtcols));
         if length(dtcols) ~= numdtcols
            dtcols = [];
         end
      elseif ~isnumeric(dtcols)
         dtcols = name2col(s,dtcols);
      end

      %validate dt columns
      if length(strcmp(s.variabletype(dtcols),'datetime')) ~= numdtcols || ...
            length(strcmp(s.datatype(dtcols),'d')) ~= numdtcols
         dtcols = [];
      end

      %try to auto-generate date part columns if omitted/invalid
      if isempty(dtcols)
         s_tmp = add_datepartcols(s);  %generate/regenerate data part columns
         if ~isempty(s_tmp)
            statcol_names = s.name(statcols);  %cache names of statcols
            s = s_tmp;
            dtcols = name2col(s,dtcollist(1:numdtcols));  %look up new positions of relevant dt columns
            statcols = name2col(s,statcol_names);  %look up new positions of stat columns
         end
      end

      if ~isempty(dtcols)

         %perform flag operation before aggregation to preserve history logging
         if flagopt ~= 0
            if ischar(flagopt)
               s = nullflags(s,flagopt);
            elseif flagopt == 1
               s = nullflags(s);
            end
         end

         %append dt cols to aggregate column list
         aggrcols = [aggrcols(:)',dtcols(:)'];

         %generate aggregated stats with specified options
         [s2,msg] = aggr_stats(s,aggrcols,statcols,statopt,0,qcrules,tminmax);

         %check for return data
         if ~isempty(s2)
            
            %generate column name prefices based on interval
            prefixlist = {'Yearly','Monthly','Daily','Hourly'};
            colnames = s2.name(length(aggrcols)+1:end)';
            desc = s2.description(length(aggrcols)+1:end)';
            prefix1 = repmat({[prefixlist{numdtcols},'_']},length(colnames),1);
            prefix2 = repmat(prefixlist(numdtcols),length(colnames),1);
            padstr = repmat({' '},length(colnames),1);
               
            %update column names, descriptions (skipping derived flagged, missing attributes)
            Inull = find(strncmp(colnames,'Flagged_',8) | strncmp(colnames,'Missing_',8) | strncmp(colnames,'Percent_',8) | strncmp(colnames,'Consecutive_',12));
            if ~isempty(Inull)
               [prefix1{Inull}] = deal('');
               [prefix2{Inull}] = deal('');
               padstr(Inull) = {''};
            end
            colnames2 = concatcellcols([prefix1,colnames],'')';
            desc2 = concatcellcols([prefix2,padstr,desc],'');
            s2.name(length(aggrcols)+1:end) = colnames2;
            s2.description(length(aggrcols)+1:end) = desc2;
            
            %update lineage
            s2.history = [s.history ; {datestr(now)}, ...
                  {['performed ',lower(prefixlist{numdtcols}),' statistical aggregation on data columns ',cell2commas(s.name(statcols),1), ...
                        ' by grouping on columns ',cell2commas(s.name(aggrcols),1),' (aggr_datetime)']}];
            s2.editdate = datestr(now);
            
            %update title
            s2 = newtitle(s2,[prefixlist{numdtcols},' Summary of ',s.title]);
            
            %add serial date column if present in original structure
            Idatecol = name2col(s,'Date');
            if ~isempty(Idatecol)
               s_tmp = add_datecol(s2);
               if ~isempty(s_tmp)  %check for validity
                  s2 = s_tmp;
               end
            end
            
            %update data anomalies
            [s2,msg] = add_anomalies(s2,[],'-',missing_anom,[],1);
            
         end

      else
         msg = 'could not determine suitable date/time columns for aggregation';
      end

   else
      if inlist(interval,dtcollist)
         msg = 'invalid GCE Data Structure';
      else
         msg = 'unsupported interval option';
      end
   end

else
   msg = 'insufficient arguments for function';
end