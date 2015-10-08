function [s2,msg] = aggr_bindata(s,bincol,bins,emptybinopt,flagopt,agcols,datacols,qcrules)
%Bins data by values in the specified numerical column after aggregation by one or more grouping columns
%and returns statistical analyses of values within bins for the specified data columns. The resultant structure
%will contain all aggregation columns plus columns for upper bin limit, bin middle, bin mean, and all relevant
%statistics for selected data columns. Values outside of the range bin_first:bin_last will be omitted from the analysis.
%
%syntax: [s2,msg] = aggr_bindata(s,bincol,bins,emptybinopt,flagopt,agcols,datacols,qcrules)
%
%inputs:
%  s = data structure to aggregate
%  bincol = name or number of numerical column
%  bins = array containing bin limits and interval ([bin_first,bin_last,interval])
%  emptybinopt = option to include empty bins in the output structure
%     0 = no/default
%     1 = yes
%  flagopt = option for clearing QA/QC flagged values prior to aggregation
%        0 = retain flagged values (default)
%        1 = remove all flagged values (convert to NaN/'')
%        character array = selectively remove only values assigned any flag in the array
%  agcols = array of column names or numbers to aggregate by (none if omitted)
%  datacols = data columns to analyze (all columns except bincol, agcols if omitted)
%  qcrules = 4-column cell array defining Q/C rules to add to the output structure to flag statistics
%       based on precence of missing and/or flagged values in each aggregate, as follows:
%          col 1: type of criteria ('flagged' or 'missing')
%          col 2: numerical criteria (character array containing a number >= 0)
%          col 3: metric ('percent','count','consecutive')
%          col 4: flag to assign (single character)
%       example:
%         {'flagged','0','count','Q'; 'missing','10','percent','Q'} --> 
%            rules: col_Flagged_[colname]>0='Q';col_Percent_Missing_[colname]>10='Q'     
%
%outputs:
%  s2 = aggregated data structure
%  msg = text of any error message
%
%
%(c)2002-2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 25-Jun-2012

%init output
s2 = [];
msg = '';

%check for required arguments
if nargin >= 3
   
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
   
   %supply default emptybinopt if omitted
   if exist('emptybinopt','var') ~= 1
      emptybinopt = 0;
   elseif emptybinopt ~= 1
      emptybinopt = 0;
   end

   %validate input
   if gce_valid(s,'data') && isnumeric(bins) && length(bins) == 3

      %validate agcols
      if exist('agcols','var') ~= 1
         agcols = [];
      elseif ~isnumeric(agcols)
         agcols = name2col(s,agcols);  %look up text column name indices
      end

      %null flags in datacols if selected
      if flagopt ~= 0
         if flagopt == 1
            s = nullflags(s,'',datacols);  %null flags
         elseif ischar(flagopt)
            s = nullflags(s,flagopt,datacols);  %selectively null flags
         end
      end

      %instantiate output data structure
      s2 = s;

      %init grouping index
      I_breaks = [1 ; length(s.values{1})+1];

      %sort structure and generate grouping array if necessary
      if ~isempty(agcols)
         I = find(agcols > 0 & agcols <= length(s2.values));
         if ~isempty(I)
            agcols = agcols(I);
            [s2,I_breaks] = aggr_index(s2,agcols);
            if length(I_breaks) >= length(s2.values{1})
               s2 = [];
               msg = 'invalid grouping columns - no repeating group values to aggregate';
            end
         end
      end

      %perform binning
      if ~isempty(s2)

         %resolve text bin column
         if ~isnumeric(bincol)
            bincol = name2col(s2,bincol);
         end

         %validate bin column
         if length(bincol) == 1
            if strcmp(s2.datatype{bincol},'s')
               bincol = [];
            end
         else
            bincol = [];
         end

         %generate bin limits
         try
            binvals = [bins(1):bins(3):bins(2)];
            if ~isempty(binvals)
               if binvals(end) ~= bins(2)
                  binvals = [binvals,bins(2)];  %append last bin if uneven bins
               end
            end
         catch
            binvals = [];
         end

         if ~isempty(bincol) && ~isempty(binvals)

            if exist('datacols','var') ~= 1
               datacols = [];
            elseif ~isnumeric(datacols)
               datacols = name2col(s2,datacols);
            end

            %default to all non-aggregation/binning columns
            if isempty(datacols)
               datacols = setdiff([1:length(s2.name)],[agcols(:)',bincol]);
            end

            %calculate # of groups
            numgps = length(I_breaks)-1;

            %init bin value columns
            bin = extract(s2,bincol);
            top = binvals(1:end-1);
            bot = binvals(2:end);
            mid = top + (binvals(2:end)-binvals(1:end-1))./2;

            %init loop variables
            bintop = [];
            binmid = [];
            binmean = [];
            Ivalid = [];
            
            %init array for empty bins
            emptybins = [];

            %loop through groups
            for n = 1:numgps
               
               %get grouping index
               Igp = (I_breaks(n):I_breaks(n+1)-1)';
               
               %get bin values w/in group
               vals = bin(Igp);
               
               %check for matched values
               if ~isempty(vals)
                  
                  %loop through bins calculating means and bin stats
                  for m = 1:length(top)
                     
                     %get index of values in bin
                     Ibin = find(vals >= top(m) & vals < bot(m));
                     
                     %generate stats
                     if ~isempty(Ibin)
                        num = length(Ibin);
                        mn = mean(vals(Ibin));
                        Ivalid = [Ivalid ; Igp(Ibin)];
                        bintop = [bintop ; repmat(top(m),num,1)];
                        binmid = [binmid ; repmat(mid(m),num,1)];
                        binmean = [binmean ; repmat(mn,num,1)];
                     elseif emptybinopt == 1
                        %add missing single bin to empty bin array
                        emptybins = [emptybins ; Igp(1),top(m),mid(m),NaN];
                     end
                     
                  end
                  
               elseif emptybinopt == 1
                  
                  %no binning data for group -- add all bins to empty bin array
                  emptybins = [emptybins ;  ...
                        repmat(Igp(1),length(top),1),top(:),mid(:),repmat(NaN,length(top),1)];
                     
               end
            end

            %check for successfully binned data
            if ~isempty(Ivalid)

               %subset structure to remove extra columns
               s2 = copycols(s2,[agcols,datacols]);
               
               %subset structure to contain only valid rows
               s2 = copyrows(s2,Ivalid,'y');

               %determine numerical type, precision for bin columns
               if top(1) == fix(top(1)) && top(2) == fix(top(2))
                  ntype_top = 'discrete';
                  prec_top = 0;
               else
                  ntype_top = 'continuous';
                  prec_top = max([dec_places(top(1)),dec_places(top(2))]);
               end

               if mid(1) == fix(mid(1)) && mid(2) == fix(mid(2))
                  ntype_mid = 'discrete';
                  prec_mid = 0;
               else
                  ntype_mid = 'continuous';
                  prec_mid = max([dec_places(mid(1)),dec_places(mid(2))]);
               end

               %determine position of new columns
               if ~isempty(agcols)
                  pos = length(agcols) + 1;
               else
                  pos = 0;
               end

               %generate column names
               bincolstr = s.name{bincol};
               bincolnames = [bincolstr,'_Bin_Top, ',bincolstr,'_Bin_Middle, ',bincolstr,'_Bin_Mean'];

               %add bin data columns (in reverse order)
               s2 = addcol(s2,binmean, ...
                  [bincolstr,'_Bin_Mean'], ...
                  s.units{bincol}, ...
                  ['Mean value of ',s.name{bincol},' bin'], ...
                  s.datatype{bincol}, ...
                  'calculation', ...
                  s.numbertype{bincol}, ...
                  s.precision(bincol)+1, ...
                  s.criteria{bincol}, ...
                  pos);

               s2 = addcol(s2,binmid, ...
                  [bincolstr,'_Bin_Middle'], ...
                  s.units{bincol}, ...
                  ['Middle value of ',s.name{bincol},' bin'], ...
                  s.datatype{bincol}, ...
                  'ordinal', ...
                  ntype_mid, ...
                  prec_mid, ...
                  '', ...
                  pos);

               s2 = addcol(s2,bintop, ...
                  [bincolstr,'_Bin_Top'], ...
                  s.units{bincol}, ...
                  ['Top value of ',s.name{bincol},' bin'], ...
                  s.datatype{bincol}, ...
                  'ordinal', ...
                  ntype_top, ...
                  prec_top, ...
                  '', ...
                  pos);

               numag = length(agcols);
               emptyrows = size(emptybins,1);

               %append grouping columns and empty values for missing bins if required
               if emptyrows > 0
                  if numag > 0
                     for n = 1:numag
                        vals = s.values{agcols(n)}(emptybins(:,1),1);
                        s2.values{n} = [s2.values{n} ; vals];  %use index to extract vals from existing
                        if ~isempty(s2.flags{n})
                           s2.flags{n} = [s2.flags{n} ; repmat(' ',emptyrows,size(s2.flags{n},2))];
                        end
                     end
                  end
                  s2.values{numag+1} = [s2.values{numag+1} ; emptybins(:,2)];
                  s2.values{numag+2} = [s2.values{numag+2} ; emptybins(:,3)];
                  s2.values{numag+3} = [s2.values{numag+3} ; emptybins(:,4)];
                  offset = numag + 3;
                  for n = 1:length(datacols)
                     if strcmp(s2.datatype{offset+n},'s')
                        vals = repmat({''},emptyrows,1);
                     else
                        vals = repmat(NaN,emptyrows,1);
                     end
                     s2.values{offset+n} = [s2.values{offset+n} ; vals];
                     if ~isempty(s2.flags{offset+n})
                        s2.flags{offset+n} = [s2.flags{offset+n} ; repmat(' ',emptyrows,size(s2.flags{offset+n},2))];
                     end
                  end
               end

               %check for errors  and send to aggr_stats for aggregation
               if gce_valid(s2,'data')

                  %call aggr_stats using 0 for flagopt since already nulled
                  [s2,msg] = aggr_stats(s2,(1:numag+3),(numag+3:length(s2.name)),0,0,qcrules);
                  
                  %finalize output structure if aggregation successful
                  if ~isempty(s2)
                     curdate = datestr(now);
                     if ~isempty(agcols)
                        agstr = [' after sorting and grouping by values in column(s) ', ...
                              cell2commas(s.name(agcols),1)];
                     else
                        agstr = '';
                     end
                     s2.history = [s.history ; {curdate}, ...
                           {['assigned rows to bins based on values in column ',s.name{bincol}, ...
                              ' (minimum = ',num2str(bins(1)),', maximum = ',num2str(bins(2)), ...
                              ' interval = ',num2str(bins(3)),')',agstr, ...
                              '; added calculated columns ',bincolnames,'; copied records within the bin range in column(s) ', ...
                              cell2commas(s2.name,1),' to create a new data structure (''aggr_bindata'')']}];
                     s2.editdate = curdate;
                  else
                     msg = ['an error occurred generating the aggregated data set: ',msg];
                  end
                  
               else
                  s2 = [];
                  msg = 'an error occurred applying the bin selections - operation cancelled';
               end

            else
               s2 = [];
               msg = 'no valid bins were identified in the structure';
            end

         else
            msg = 'specified binning column is invalid or non-numeric';
         end

      else
         msg = 'specified aggregation columns are invalid';
      end

   else
      msg = 'data structure is not valid';
   end

else
   msg = 'insufficient arguments for function';
end