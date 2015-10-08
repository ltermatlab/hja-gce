function [s2,msg] = aggr_stats_text(s,agcols,statcols,statopt,flagopt,qcrules,tminmax,delim,textcount)
%Statistical aggregation function for summarizing both numeric and text columns in a GCE Data Structure
%
%Records are sorted and grouped based on values in one or more specified aggregation columns
%then requested summary statistics are calculated for values within each group for the specified
%columns to generate an aggregated data set. The number and percentage of flagged and
%missing values in each group are also calculated for statistics columns as appropriate and
%added to the output structure.
%
%syntax:  [s2,msg] = aggr_stats_text(s,aggrcols,statcols,statopt,flagopt,qcrules,tminmax,delim,textcount)
%
%inputs:
%   s = original data structure
%   aggrcols = ordered array of columns to sort and aggregate by
%   statcols = ordered array of columns to calculate statistics for
%   statopt = an array of integers specifying the statistics to calculate for each column in 'statcols':
%       0 = auto {default}
%       1 = count, combined only (default for strings)
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
%   tminmax = option to include Time_Min_... and Time_Max ... columns when min/max are included
%       0 = no (default)
%       1 = yes
%   delim = deliminator for combined text columns (string, default = ';')
%   textcount = option to count the number of occurrances of each string when text values are combined
%       (e.g. 'red(10);green(2);purple(3)')
%       0 = no (default)
%       1 = yes
%
%outputs:
%   s2 = new data structure containing the columns in 'aggrcols' and relevant statistical
%      result columns for each original data column specified in 'statcols'
%      e.g.: Num_[col name], Total_[col name], Min_[col name], Max_[col name], Mean_[col name],
%         where [col name] is the original name of each column).
%      Statistics are computed based on data type, variable type and numerical type metadata descriptors.
%      Additional columns Flags_[col name] and Missing_[col name] listing total percentage of
%      flagged or missing values, resp., will be included as appropriate.
%   msg = text of any error messages
%
%notes:
%   1. A scalar value of 'statopt' will be replicated to match the length of 'statcols'
%   2. Values of 'statopt' > 1 will be set to 1 for string columns
%   3. Any columns in 'statcols' that also appear in 'agcols' will be removed
%   4. Column properties and metadata are copied or created as appropriate for each summary column
%   5. For floating-point columns with numeric type 'angular' (e.g. wind direction), a vector average
%      will be calculated instead of arithmetic mean and no standard deviation or error will be calculated
%   6. If any missing or flagged values are present, columns Missing_[colname], Percent_Missing_[colname],
%      Flagged_[colname], Percent_Flagged_[colname] will be included regardless of specific qcrules;
%      however, Consecutive_Missing_[colname] and Consecutive_Flagged_[colname] will only be included
%      if corresponding Q/C rules are defined.
%   7. If tminmax == 1 the get_studydates() function will be used to retrieve serial dates - if none
%      are found the tminmax option will be reset to 0
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
%last modified: 22-Apr-2014

%init output
s2 = [];
msg = '';

%check for required input
if nargin >= 3
   
   %check for valid data structure
   if gce_valid(s,'data')
      
      %validate agcols
      if ~isnumeric(agcols)
         agcols = name2col(s,agcols);  %look up indices for text column names
      else
         %validate columns (ensure in-range columns, and no overlap)
         Ivalid = find(agcols > 0 & agcols <= length(s.values));
         if ~isempty(Ivalid)
            agcols = agcols(Ivalid);
         else
            agcols = [];
         end
      end
      
      %validate statcols
      if ~isnumeric(statcols)
         statcols = name2col(s,statcols); %replace column names with column numbers
      else
         Ivalid = find(statcols > 0 & statcols <= length(s.values));
         if ~isempty(Ivalid)
            statcols = statcols(Ivalid);
         else
            statcols = [];
         end
      end
      
      if ~isempty(agcols) && ~isempty(statcols)
         
         %remove any cols in statcols that are also in agcols
         statcols = setdiff(statcols,agcols);
         
         if ~isempty(statcols)
            
            %assign default flagopt if omitted, invalid
            if exist('flagopt','var') ~= 1
               flagopt = 0;
            end
            
            %validate stat options, apply defaults if omitted
            if exist('statopt','var') ~= 1
               statopt = [];
            end
            if isempty(statopt)|| ~isnumeric(statopt)
               statopt = zeros(1,length(statcols));
            else
               statopt = fix(statopt);    %force integers
               statopt(statopt > 7) = 0;  %set invalid statopt selections to 0 = auto
               if length(statopt) == 1
                  statopt = repmat(statopt,1,length(statcols));  %replicate scalar statopt
               elseif length(statopt) < length(statcols)
                  %copy first option to fill in missing options if length of statopt < statcols
                  statopt = repmat(statopt,1,ceil(length(statcols)./length(statopt)));
               end
            end
            
            %validate qcrules, apply defaults if omitted
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
            if isempty(qcrules)
               qcrules = repmat({''},1,4);  %generate dummy rule to prevent indexing error
            end
            
            %check for tminmax option
            if exist('tminmax','var') ~= 1 || tminmax ~= 1
               tminmax = 0;
            end
            
            %check for delim option
            if exist('delim','var') ~= 1
               delim = ';';
            end
            
            %check for text count option
            if exist('textcount','var') ~= 1 || textcount ~= 1
               textcount = 0;
            end
            
            %check for Q/C rules referencing consecutive metrics and set flags to compute indices
            calc_consec_miss = 0;
            calc_consec_flagged = 0;
            if sum(strcmp('consecutive',qcrules(:,3)) & strcmp('missing',qcrules(:,1))) > 0
               calc_consec_miss = 1;
            end
            if sum(strcmp('consecutive',qcrules(:,3)) & strcmp('flagged',qcrules(:,1))) > 0
               calc_consec_flagged = 1;
            end
            
            %call function to sort structure and return a grouping index for the specified columns
            [s,I_breaks] = aggr_index(s,agcols);
               
            %apply flag removal option to columns in statcols if specified
            if flagopt ~= 0
               if ischar(flagopt)
                  s = nullflags(s,flagopt,statcols);
               elseif flagopt == 1
                  s = nullflags(s,'',statcols);
               end
            end
            
            %check for errors nulling flags and perform aggregation
            if ~isempty(s)
               
               %define q/c criteria options array for generating rule reference columns
               qc_options = {'col_','count'; ...
                  'col_Percent_','percent'; ...
                  'col_Consecutive_','consecutive'};
               
               %cache data types and value arrays for comparisons
               types = s.datatype;
               vals = s.values;
               
               %calculate metrics for data set and selections
               numrows = length(vals{1});
               numcols = length(agcols);
               numstats = length(statcols);
               
               %generate dt array for tminmax option
               dt = [];
               if tminmax == 1
                  dt = get_studydates(s);
               end
               if isempty(dt)
                  tminmax = 0;  %override option in case of invalid dt array
                  dt = ones(numrows,1) .* NaN;
               end
               
               %check for unique grouping index where no aggregation possible
               if length(I_breaks) < numrows
                  
                  %initialize new columns for groups using maximum possible cols for bounds
                  %(i.e. num, min, tmin, max, tmax, tot, median, mean, sd, se, alltext
                  %missing, consec_missing, pct_missing, flagged, pct_flagged, consec_flagged)
                  newdata = cell(1,numcols+numstats.*17);
                  newnames = newdata;
                  newprec = zeros(1,length(newnames));
                  newtypes = newdata;
                  newvartypes = newdata;
                  newnumtypes = newdata;
                  newunits = newdata;
                  newdesc = newdata;
                  newcrit = repmat({''},1,length(newnames));
                  
                  %copy each aggregation column to output
                  for n = 1:numcols
                     pos = agcols(n);
                     x = vals{pos};
                     newnames{n} = s.name{pos};
                     newdata{n} = x(I_breaks(1:length(I_breaks)-1));
                     newprec(n) = s.precision(pos);
                     newtypes{n} = types{pos};
                     newvartypes{n} = s.variabletype{pos};
                     newnumtypes{n} = s.numbertype{pos};
                     newunits{n} = s.units{pos};
                     newdesc{n} = s.description{pos};
                  end
                  
                  %calculate number of aggregates for looping and generating output arrays
                  numgps = (I_breaks(2:length(I_breaks))-I_breaks(1:length(I_breaks)-1));
                  
                  %initialize column counter
                  colpos = length(agcols) + 1;
                  
                  %loop through columns in statcols calculating relevant stats for each group
                  for n = 1:numstats
                     
                     %initialize stat arrays
                     mn = ones(length(numgps),1) .* NaN;
                     minval = mn;
                     tminval = mn;
                     maxval = mn;
                     tmaxval = mn;
                     sd = mn;
                     se = mn;
                     tot = mn;
                     med = mn;
                     obs = zeros(length(numgps),1);
                     miss = obs;
                     consec_miss = obs;
                     flags = obs;
                     consec_flags = obs;
                     critstr = '';
                     alltext = repmat({''},length(numgps),1);
                     
                     %get column characteristics
                     pos = statcols(n);
                     coltype = lower(types{pos});
                     vartype = lower(s.variabletype{pos});
                     if strcmp(vartype,'data')
                        %convert vartype to calculation if data, otherwise return original for derived fields
                        vartype = 'calculation';
                     end
                     numtype = lower(s.numbertype{pos});
                     units = lower(s.units{pos});
                     prec = s.precision(pos);
                     
                     %get column data and flags
                     x = s.values{pos};
                     if flagopt ~= 1
                        f = s.flags{pos};  %get flags
                     else
                        f = [];
                     end
                     
                     %override stat option for strings
                     if strcmp(coltype,'s')
                        statopt(n) = 1;
                     end
                     
                     %set automatic stat options for numeric data
                     if statopt(n) == 0
                        if strcmp(vartype,'data') || strncmp(vartype,'calc',4)
                           if strcmp(coltype,'f') || strcmp(coltype,'e')  %floating-point, exponential
                              if strcmp(numtype,'continuous') || strcmp(numtype,'angular')
                                 statopt(n) = 4;
                              else  %unknown/mixed type - range only
                                 statopt(n) = 2;
                              end
                           elseif strcmp(coltype,'d')  %integer
                              statopt(n) = 3;
                           else  %unclassified datatype data/calc - range only
                              statopt(n) = 2;
                           end
                        else  %non-data/calc numeric column (e.g. datetime, coord, code) - range only
                           statopt(n) = 2;
                        end
                     end
                     
                     %generate relevant statistics based on options
                     if statopt(n) > 1  %calculate numeric stats
                        
                        %check for reduced stats options versus full stats
                        if statopt(n) < 4 || statopt(n) == 7
                           fullstats = 0;
                        else
                           fullstats = 1;
                        end
                        
                        %loop through groups
                        for m = 1:length(I_breaks)-1
                           
                           I = (I_breaks(m):I_breaks(m+1)-1)';  %get group index
                           v = x(I);                            %get array values
                           
                           Imissing = isnan(v);        %get missing value index
                           miss(m) = sum(Imissing);    %total missing values
                           if calc_consec_miss == 1
                              tmp = max(diff([0;find(~Imissing)]))-1;
                              if ~isempty(tmp)
                                 consec_miss(m) = tmp;  %calc consecutive missing
                              end
                           end
                           
                           v = v(~Imissing);        %remove missing values
                           dt_v = dt(I(~Imissing));   %get corresponding date/time values
                           obs(m) = length(v);      %calculate non-missing observations
                           
                           %calculate stats
                           if ~isempty(v)
                              [minval(m),Iminval] = min(v);  %minimum
                              tminval(m) = dt_v(Iminval);    %date/time of minumum
                              [maxval(m),Imaxval] = max(v);  %maximum
                              tmaxval(m) = dt_v(Imaxval);    %date/tiem of maximum
                              tot(m) = sum(v);     %total
                              if fullstats == 0
                                 med(m) = median(v);  %median
                              else  %full stats
                                 if ~strcmp(numtype,'angular')
                                    if length(v) > 1  %check for minimum values for SD/SE
                                       mn(m) = mean(v);  %arithmetic mean
                                       if statopt ~= 6  %check for mean-only option
                                          sd(m) = std(v);  %standard deviation
                                          se(m) = std(v)./sqrt(length(v));  %standard error
                                       end
                                    else  
                                       mn(m) = v;  %use scalar value as mean, skip SD,SE
                                    end
                                 else
                                    mn(m) = angleavg(v,units);  %calculate unit vector average
                                 end
                              end
                           end
                           
                           %count flagged values
                           if ~isempty(f)
                              Iflagged = f(I,1)~=' ';    %get index of unflagged values
                              flags(m) = sum(Iflagged);  %total flag count
                              if calc_consec_flagged == 1
                                 tmp = max(diff([0;find(~Iflagged)]))-1;
                                 if ~isempty(tmp)
                                    consec_flags(m) = tmp;  %calc consecutive flagged
                                 end
                              end
                           end
                           
                        end
                        
                     else  %enumerate and concatenate text only (cell or numeric)
                        
                        %loop through groups
                        for m = 1:length(I_breaks)-1
                           
                           %get group index
                           I = (I_breaks(m):I_breaks(m+1)-1)';
                           v = x(I);
                           
                           %get index of missing values
                           if iscell(v)
                              Imissing = cellfun('isempty',v);  %get index of empty string values
                           else
                              Imissing = isnan(v);  %get index of missing numeric values (NaN0
                           end

                           %calculate metrics
                           miss(m) = sum(Imissing);  %count missing values
                           if calc_consec_miss == 1
                              tmp = max(diff([0;find(~Imissing)]))-1;
                              if ~isempty(tmp)
                                 consec_miss(m) = tmp;  %calc consecutive missing
                              end
                           end
                           obs(m) = sum(~Imissing);  %count observations
                           
                           %concatenate strings
                           if iscell(v)
                              [str,Ia,Ic] = unique(v);
                              if ~isempty(v)
                                 if textcount == 0
                                    alltext(m) = concatcellcols(str(Ia)',delim);
                                 else
                                    str_temp = [str{1},'(',int2str(length(find(Ic==1))),')'];
                                    for nstr = 2:length(Ia)                                       
                                       str_temp = [str_temp,delim,str{nstr},'(',int2str(length(find(Ic==nstr))),')'];
                                    end
                                    alltext{m} = str_temp;
                                 end
                              end
                           end
                           
                           %count flagged values
                           if ~isempty(f)
                              Iflagged = f(I,1)~=' ';    %get index of unflagged values
                              flags(m) = sum(Iflagged);  %total flag count
                              if calc_consec_flagged == 1
                                 tmp = max(diff([0;find(~Iflagged)]))-1;
                                 if ~isempty(tmp)
                                    consec_flags(m) = tmp;  %calc consecutive flagged
                                 end
                              end
                           end
                           
                        end
                        
                     end
                     
                     %format tminval and tmaxval in hh:mm:ss format
                     if tminmax == 1
                        try
                           str_tminval = datestr(tminval,13);
                           str_tmaxval = datestr(tmaxval,13);
                        catch
                           tminmax = 0;
                        end
                     end
                     
                     %calc missing value totals and percents if missing values present or missing rules specified
                     if sum(miss) > 0 || sum(strcmpi(qcrules(:,1),'missing')) > 0
                        
                        %calc percent missing, checking for divide by zero condition
                        totmiss = miss + obs;  %calc total N from missing plus observed
                        pctmiss = zeros(length(miss),1);  %init percent
                        Inonzero = find(totmiss>0);  %get index of zero tot
                        pctmiss(Inonzero) = miss(Inonzero) ./ totmiss(Inonzero) .* 100;  %calc pct only for non-zero tot
                        
                        %generate attribute info for num missing
                        newdata{colpos} = miss;
                        newnames{colpos} = ['Missing_' s.name{pos}];
                        newprec(colpos) = 0;
                        newtypes{colpos} = 'd';
                        newvartypes{colpos} = 'calculation';
                        newnumtypes{colpos} = 'discrete';
                        newunits{colpos} = 'count';
                        newdesc{colpos} = ['Number of missing observations of ' s.description{pos}];
                        colpos = colpos + 1;  %increment column position counter
                        
                        %generate attribute info for percent missing
                        newdata{colpos} = pctmiss;
                        newnames{colpos} = ['Percent_Missing_' s.name{pos}];
                        newprec(colpos) = 2;
                        newtypes{colpos} = 'f';
                        newvartypes{colpos} = 'calculation';
                        newnumtypes{colpos} = 'continuous';
                        newunits{colpos} = '%';
                        newdesc{colpos} = ['Percent missing observations of ' s.description{pos}];
                        colpos = colpos + 1;  %increment column position counter
                                                                        
                        %generate consecutive missing values column if requested
                        if calc_consec_miss == 1
                           %generate attribute info for consecutive missing
                           newdata{colpos} = consec_miss;
                           newnames{colpos} = ['Consecutive_Missing_' s.name{pos}];
                           newprec(colpos) = 0;
                           newtypes{colpos} = 'd';
                           newvartypes{colpos} = 'calculation';
                           newnumtypes{colpos} = 'discrete';
                           newunits{colpos} = 'count';
                           newdesc{colpos} = ['Largest consecutive number of missing observations of ' s.description{pos}];
                           colpos = colpos + 1;  %increment column position counter                           
                        end
                        
                        %loop through q/c criteria options adding rules
                        for opt = 1:size(qc_options,1)
                           Irules = find(strcmpi(qcrules(:,1),'missing') & strcmpi(qcrules(:,3),qc_options{opt,2}));
                           if ~isempty(Irules)
                              for cnt = 1:length(Irules)
                                 critstr = [critstr,';',qc_options{opt,1},'Missing_',s.name{pos},'>',qcrules{Irules(cnt),2},'=''',qcrules{Irules(cnt),4},''''];
                              end
                           end
                        end
                        
                     end
                     
                     %add flagged value total & percent cols if flagged values present or flag rules specified
                     if sum(flags) > 0 || sum(strcmpi(qcrules(:,1),'flagged')) > 0
                        
                        %calc percent flagged, checking for divide by zero condition
                        totflag = flags + obs;  %calc total N from missing plus observed
                        pctflag = zeros(length(flags),1);  %init percent
                        Inonzero = find(totflag>0);  %get index of zero tot
                        pctflag(Inonzero) = flags(Inonzero) ./ totflag(Inonzero) .* 100;  %calc pct only for non-zero tot
                        
                        %generate attribute info for number flagged
                        newdata{colpos} = flags;
                        newnames{colpos} = ['Flagged_' s.name{pos}];
                        newprec(colpos) = 0;
                        newtypes{colpos} = 'd';
                        newvartypes{colpos} = 'calculation';
                        newnumtypes{colpos} = 'discrete';
                        newunits{colpos} = 'count';
                        newdesc{colpos} = ['Number of QC/QA-flagged observations of ' s.description{pos}];
                        colpos = colpos + 1;  %increment column position counter
                        
                        %generate attribute info for percent flagged
                        newdata{colpos} = pctflag;
                        newnames{colpos} = ['Percent_Flagged_' s.name{pos}];
                        newprec(colpos) = 2;
                        newtypes{colpos} = 'f';
                        newvartypes{colpos} = 'calculation';
                        newnumtypes{colpos} = 'continuous';
                        newunits{colpos} = '%';
                        newdesc{colpos} = ['Percent QC/QA-flagged observations of ' s.description{pos}];
                        colpos = colpos + 1;  %increment column position counter
                        
                        %generate attribute info for consecutive flagged
                        if calc_consec_flagged == 1
                           newdata{colpos} = consec_flags;
                           newnames{colpos} = ['Consecutive_Flagged_' s.name{pos}];
                           newprec(colpos) = 0;
                           newtypes{colpos} = 'd';
                           newvartypes{colpos} = 'calculation';
                           newnumtypes{colpos} = 'discrete';
                           newunits{colpos} = 'count';
                           newdesc{colpos} = ['Largest consecutive number of QC/QA-flagged observations of ' s.description{pos}];
                           colpos = colpos + 1;  %increment column position counter
                        end
                        
                        %loop through q/c criteria options adding rules
                        for opt = 1:size(qc_options,1)
                           Irules = find(strcmpi(qcrules(:,1),'flagged') & strcmpi(qcrules(:,3),qc_options{opt,2}));
                           if ~isempty(Irules)
                              for cnt = 1:length(Irules)
                                 critstr = [critstr,';',qc_options{opt,1},'Flagged_',s.name{pos},'>',qcrules{Irules(cnt),2},'=''',qcrules{Irules(cnt),4},''''];
                              end
                           end
                        end
                        
                     end
                     
                     %remove leading semicolon from criteria string if present
                     if strncmp(critstr,';',1)
                        critstr = critstr(2:end);
                     end
                     
                     %add number of observations for all stat options
                     newdata{colpos} = obs;
                     newnames{colpos} = ['Num_' s.name{pos}];
                     newprec(colpos) = 0;
                     newtypes{colpos} = 'd';
                     newvartypes{colpos} = 'calculation';
                     newnumtypes{colpos} = 'discrete';
                     newunits{colpos} = 'count';
                     newdesc{colpos} = ['Observations of ' s.description{pos}];
                     
                     %increment column counter
                     colpos = colpos + 1;
                     
                     %add concatenated text if text column
                     if strcmp(coltype,'s')
                        
                        newdata{colpos} = alltext;
                        newnames{colpos} = ['Combined_' s.name{pos}];
                        newprec(colpos) = 0;
                        newtypes{colpos} = 's';
                        newvartypes{colpos} = 'text';
                        newnumtypes{colpos} = 'none';
                        newunits{colpos} = 'none';
                        
                        %generate column description based on options
                        if textcount == 0
                           str = ['All unique values of ' s.description{pos}, ...
                              ' combined into a single string delimited by "',delim,'"'];
                        else
                           str = ['All unique values of ' s.description{pos}, ...
                              ' combined into a single string delimited by "',delim, ...
                              '", including the total observations of each in parentheses'];
                        end
                        newdesc{colpos} = str;

                        %increment column counter
                        colpos = colpos + 1;
                     
                     end
                     
                     %add min, max unless mean only or total only requested
                     if statopt(n) >= 2 && statopt(n) <= 5
                        
                        newdata{colpos} = minval;
                        newnames{colpos} = ['Min_' s.name{pos}];
                        newprec(colpos) = prec;
                        newtypes{colpos} = coltype;
                        newvartypes{colpos} = vartype;
                        newnumtypes{colpos} = numtype;
                        newunits{colpos} = s.units{pos};
                        newdesc{colpos} = ['Minimum ' s.description{pos}];
                        newcrit{colpos} = critstr;
                        
                        colpos = colpos + 1; %increment column counter
                        
                        if tminmax == 1
                           
                           newdata{colpos} = cellstr(str_tminval);
                           newnames{colpos} = ['Time_Min_' s.name{pos}];
                           newprec(colpos) = 0;
                           newtypes{colpos} = 's';
                           newvartypes{colpos} = 'datetime';
                           newnumtypes{colpos} = 'none';
                           newunits{colpos} = 'hh:mm:ss';
                           newdesc{colpos} = ['Time of Minimum ' s.description{pos}];
                           newcrit{colpos} = '';

                           colpos = colpos + 1; %increment column counter
                        
                        end
                        
                        newdata{colpos} = maxval;
                        newnames{colpos} = ['Max_' s.name{pos}];
                        newprec(colpos) = prec;
                        newtypes{colpos} = coltype;
                        newvartypes{colpos} = vartype;
                        newnumtypes{colpos} = numtype;
                        newunits{colpos} = s.units{pos};
                        newdesc{colpos} = ['Maximum ' s.description{pos}];
                        newcrit{colpos} = critstr;
                        
                        colpos = colpos + 1; %increment column counter
                        
                        if tminmax == 1
                           
                           newdata{colpos} = cellstr(str_tmaxval);
                           newnames{colpos} = ['Time_Max_' s.name{pos}];
                           newprec(colpos) = 0;
                           newtypes{colpos} = 's';
                           newvartypes{colpos} = 'datetime';
                           newnumtypes{colpos} = 'none';
                           newunits{colpos} = 'hh:mm:ss';
                           newdesc{colpos} = ['Time of Maximum ' s.description{pos}];
                           newcrit{colpos} = '';

                           colpos = colpos + 1; %increment column counter
                        
                        end
                        
                     end
                     
                     %add total if requested
                     if statopt(n)== 3 || statopt(n) == 4 || statopt(n) == 7
                        
                        newdata{colpos} = tot;
                        newnames{colpos} = ['Total_' s.name{pos}];
                        newprec(colpos) = prec;
                        newtypes{colpos} = coltype;
                        newvartypes{colpos} = vartype;
                        newnumtypes{colpos} = numtype;
                        newunits{colpos} = s.units{pos};
                        newdesc{colpos} = ['Total ' s.description{pos}];
                        newcrit{colpos} = critstr;
                        
                        colpos = colpos + 1; %increment column counter
                        
                     end
                     
                     %add median only for integer stats
                     if statopt(n) == 3
                        
                        newdata{colpos} = med;
                        newnames{colpos} = ['Median_' s.name{pos}];
                        newprec(colpos) = prec;
                        newtypes{colpos} = coltype;
                        newvartypes{colpos} = vartype;
                        newnumtypes{colpos} = numtype;
                        newunits{colpos} = s.units{pos};
                        newdesc{colpos} = ['Median ' s.description{pos}];
                        newcrit{colpos} = critstr;
                        
                        colpos = colpos + 1; %increment column counter
                        
                     end
                     
                     %add mean or vector average if requested
                     if statopt(n) == 4 || statopt(n) == 5 || statopt(n) == 6
                        
                        %set column name, description based on mean type
                        if ~strcmp(numtype,'angular') %arithmetic mean
                           newnames{colpos} = ['Mean_' s.name{pos}];
                           newdesc{colpos} = ['Mean ' s.description{pos}];
                        else  %angular mean
                           newnames{colpos} = ['VecAvg_' s.name{pos}];
                           newdesc{colpos} = ['Vector Average ' s.description{pos}];
                        end
                        
                        newdata{colpos} = mn;
                        newprec(colpos) = prec+1;
                        newtypes{colpos} = coltype;
                        newvartypes{colpos} = vartype;
                        newnumtypes{colpos} = numtype;
                        newunits{colpos} = s.units{pos};
                        newcrit{colpos} = critstr;
                        
                        colpos = colpos + 1; %increment column counter
                        
                     end
                     
                     %add standard deviation and standard error for non-angular floating-point columns
                     if statopt(n) == 4 || statopt(n) == 5
                        
                        if ~strcmp(numtype,'angular') %check for non-angular numbers
                           
                           newdata{colpos} = sd;
                           newdata{colpos+1} = se;
                           
                           newnames{colpos} = ['StdDev_' s.name{pos}];
                           newnames{colpos+1} = ['SE_' s.name{pos}];
                           
                           newprec(colpos) = prec+1;
                           newprec(colpos+1) = prec+2;
                           
                           newtypes{colpos} = coltype;
                           if ~strcmp(coltype,'d')
                              newtypes{colpos} = coltype;
                              newtypes{colpos+1} = coltype;
                              newnumtypes{colpos} = numtype;
                              newnumtypes{colpos+1} = numtype;
                           else  %force floating-point, continuous for stats on integer columns
                              newtypes{colpos} = 'f';
                              newtypes{colpos+1} = 'f';
                              newnumtypes{colpos} = 'continuous';
                              newnumtypes{colpos+1} = 'continuous';
                           end
                           
                           newvartypes{colpos} = vartype;
                           newvartypes{colpos+1} = vartype;
                           
                           newunits{colpos} = s.units{pos};
                           newunits{colpos+1} = s.units{pos};
                           
                           newdesc{colpos} = ['Sample Standard Deviation of ' s.description{pos}];
                           newdesc{colpos+1} = ['Standard Error of ' s.description{pos}];
                           
                           newcrit{colpos} = critstr;
                           newcrit{colpos+1} = critstr;
                           
                           colpos = colpos + 2; %increment column counter
                           
                        end
                        
                     end
                     
                  end
                  
                  %truncate unused columns
                  I_used = (1:colpos-1);
                  newdata = newdata(I_used);
                  newnames = newnames(I_used);
                  newprec = newprec(I_used);
                  newtypes = newtypes(I_used);
                  newvartypes = newvartypes(I_used);
                  newnumtypes = newnumtypes(I_used);
                  newunits = newunits(I_used);
                  newdesc = newdesc(I_used);
                  newcrit = newcrit(I_used);
                  
                  %generate history strings
                  aglist = cell2commas(s.name(agcols),1);
                  if length(agcols) > 1
                     agstr = ['aggregated on columns ' aglist];
                  else
                     agstr = ['aggregated on column ' aglist];
                  end
                  
                  %generate list of columns summarized
                  statlist = cell2commas(s.name(statcols),1);
                  if length(statcols) > 1
                     statstr = ['; summary statistics calculated for columns ' statlist];
                  else
                     statstr = ['; summary statistics calculated for column ' statlist];
                  end
                  
                  %init output structure
                  s2 = s;
                  
                  %put new values into return structure, update headers and history
                  curdate = datestr(now);
                  s2.createdate = curdate;
                  s2.editdate = curdate;
                  s2.history = [s.history ; {curdate},{[agstr statstr ' (''aggr_stats'')']}];
                  s2.name = newnames;
                  s2.units = newunits;
                  s2.description = newdesc;
                  s2.datatype = newtypes;
                  s2.variabletype = newvartypes;
                  s2.numbertype = newnumtypes;
                  s2.precision = newprec;
                  s2.values = newdata;
                  s2.criteria = newcrit;
                  s2.flags = repmat({''},1,length(newdata));
                  
                  %update dataset and metadata title
                  titlestr = ['Statistical analysis of data aggregated by ' aglist ': ' s.title];
                  s2 = newtitle(s2,titlestr);
                  
                  %update flags if qcrules defined
                  if sum(~cellfun('isempty',qcrules(:,1))) > 0
                     [s2,msg2] = dataflag(s2);
                     if ~isempty(msg2)
                        msg = 'errors occurred evaluating Q/C critieria';
                     end
                  end
                  
               else
                  msg = 'no repeating group values to aggregate';
               end
               
            else
               msg = 'an error occurred removing flagged values';
            end
            
         else
            msg = 'invalid statistical column selections';
         end
         
      else
         msg = 'invalid aggregation and/or statistics column selections';
      end
      
   else
      msg = 'invalid GCE data structure';
   end
   
else
   msg = 'insufficient arguments for function';
end