function [stats,msg] = colstats(data,flagopt,groupcol)
%Calculates basic descriptive statistics for columns in a standard GCE-LTER data structure
%
%syntax:  [stats,msg] = colstats(data,flagopt,groupcol)
%
%input:
%   data = data structure to analyze
%   flagopt = 'I' to include flagged values or 'E' to exclude
%      flagged values (flagopt = 'E' if omitted)
%   groupcol = column number to sort by and calculate group statistics
%      (note: groupcol will be ignored if no repeating elements are present)
%
%output:
%   stats = structure variable containing the fields:
%      'version' - version of 'colstats.m' used to create the structure
%      'title' - original data set title (copied from 'data')
%      'metadata' - original data set metadata (copied from 'data')
%      'history' - audit trail of operations applied to original data (from 'data')
%      'analysisdate' - date statistics run
%      'flagoption' - flag option ('include' or 'exclude')
%      'name' - cell array of column names (from 'data')
%      'units' - cell array of column units (from 'data')
%      'description' - cell array of column descriptions (from 'data')
%      'datatype' - cell array of column data types (from 'data')
%      'variabletype' - cell array of column variable types (from 'data')
%      'numbertype' - cell array of column number types (from 'data')
%      'precision' - array of column precision (from 'data')
%      'criteria' - array of column value flag criteria expressions (from 'data')
%      'group' - 1x4 cell array containing the name, units, data type, and
%          precision of the grouping variable (blanks if ungrouped)
%      'groupvalue' - nx1 array of group values (blank if ungrouped)
%      'observations' - nxm array of total observations for each column (all datatypes)
%      'missing' - nxm array of total missing values for each column (all datatypes)
%      'valid' - nxm array of total non-missing observations for each column (all datatypes)
%      'flagged' - nxm array of total flagged values for each column (all datatypes)
%      'min' - nxm array of column minima (datatype = 'f','e','d')
%      'max' - nxm array of column maxima (datatype = 'f','e','d')
%      'total' - nxm array of column totals (datatype = 'f','e','d')
%      'median' - nxm array of column medians (datatype = 'f','e','d'; variabletype = 'data' or 'calculation')
%      'mean' - nxm array of column means (datatype = 'f','e'; variabletype = 'data' or 'calculation')
%      'stddev' - nxm array of column sample standard deviations (datatype = 'f','e'; variabletype = 'data' or 'calculation')
%      'se' - nxm array of column standard errors (datatype = 'f','e'; variabletype = 'data' or 'calculation')
%   msg = is a message string reporting any errors that occurred
%
%  (Note: missing observations are excluded from the flag count and all statistics)
%
%syntax:  [stats,msg] = colstats(data,flagopt,groupcol)
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
%last modified: 24-Apr-2013

%initialize outputs:
stats = newstruct('stat');

msg = '';

if nargin >= 1

   cancel = 0;
   flagoptstr = '';

   %apply default flag option or validate flagopt
   if exist('flagopt','var') ~= 1
      flagopt = 'E';
      flagoptstr = 'excluded';
   else  %use default if
      flagopt = upper(flagopt);
      if strcmp(flagopt,'I')
         flagoptstr = 'included';
      elseif strcmp(flagopt,'E')
         flagoptstr = 'excluded';
      else
         cancel = 1;
         msg = 'invalid flag option';
      end
   end

   if exist('groupcol','var') ~= 1
      groupcol = [];
   elseif isstr(groupcol)
      groupcol = name2col(data,groupcol);
   elseif groupcol < 1 | groupcol > length(data.name)
      groupcol = [];
      msg = 'invalid grouping column';
   end

   %validate data structure
   if ~isstruct(data)
      cancel = 1;
      msg = 'invalid data structure';
   elseif ~isfield(data,'values') | ~isfield(data,'name') | ~isfield(data,'units') ...
         | ~isfield(data,'precision') | ~isfield(data,'datatype')
      cancel = 1;
      msg = 'unrecognizable data structure format';
   end

   if cancel == 0  %validation successful, calculate stats

      numrows = length(data.values{1});
      numcols = length(data.name);

      if isempty(groupcol)

         Igp = [1 ; numrows+1];
	      groupname = '';
         groupunits = '';
         grouptype = '';
         groupprec = '';

      else  %generate grouping index, save group info

         data2 = sortdata(data,groupcol,1,1);  %presort by grouping column

         x = data2.values{groupcol};
         if strcmp(data2.datatype{groupcol},'s')
            Igp = [find([0;strcmp(x(1:length(x)-1),x(2:length(x)))]==0) ; numrows+1];
         else
            Igp = [find([0;x(1:length(x)-1)==x(2:length(x))]==0) ; numrows+1];
         end

         if length(Igp) < (length(x)+1)  %check for repeating records
            data = data2;  %update structure with sorted copy
            groupname = data.name{groupcol};
      	   groupunits = data.units{groupcol};
            grouptype = data.datatype{groupcol};
            groupprec = data.precision(groupcol);
         else  %no repeating records - ignore grouping
            groupcol = [];
            Igp = [1 ; numrows+1];
            groupname = '';
            groupunits = '';
            grouptype = '';
            groupprec = '';
            msg = 'grouping criteria ignored - no repeating values in grouping column';
         end

      end

      %initialize arrays
      groupval = '';
      numrows = ones(length(Igp)-1,numcols) .* NaN;
      valid = numrows;
      missing = numrows;
      flagged = numrows;
      minval = numrows;
      maxval = numrows;
      medianval = numrows;
      meanval = numrows;
      stddevval = numrows;
      se = numrows;
      total = numrows;

      allvals = data.values;

      %perform calcs for each group by column
      for g = 1:length(Igp)-1

         %get value of group
         if ~isempty(groupcol)
            group = allvals{groupcol};  %get data column values
            if isempty(groupval)
               groupval = group(Igp(g));
            else
               groupval = [groupval ; group(Igp(g))];
            end
         else
            groupval = {''};
         end

         %run calcs for each column
         for n = 1:numcols

            type = lower(data.datatype{n});
            vartype = lower(data.variabletype{n});
            ntype = lower(data.numbertype{n});
            units = lower(data.units{n});
            vals = allvals{n};
            vals = vals(Igp(g):Igp(g+1)-1);  %apply grouping index

            %get index of non-missing values, calculate counters
            if strcmp(type,'s')  %string column
               I = find(~cellfun('isempty',vals));
            else  %integer or floating-point number
               I = find(~isnan(vals));
            end
            numrows(g,n) = length(vals);
            valid(g,n) = length(I);
            missing(g,n) = length(vals) - valid(g,n);

            %count flags, build appropriate flag index
            I_fl = [1:length(I)]';  %initialize default index (all values)
            flags = data.flags{n};  %retrieve flag array
            if ~isempty(flags)
               flags = flags(Igp(g):Igp(g+1)-1,:);  %apply grouping index
               flags = flags(I,:);  %filter out flags for missing values to match I array
               I_unflagged = find(flags(:,1)==' ');  %get index of unflagged vals
               flagged(g,n) = size(flags,1) - length(I_unflagged);  %count flags
               if strcmp(flagopt,'E')  %use unflagged index if flags excluded
                  I_fl = I_unflagged;
               end
          	else  %substitute dummy subindex if flagopt = 'I'
               flagged(g,n) = 0;
	         end

            %apply cumulative index
            vals = vals(I(I_fl));

            %calculate remaining statistics
            if ~strcmp(type,'s') & ~isempty(vals)  %integer or floating-point column

               %calculate range
               minval(g,n) = min(vals);
               maxval(g,n) = max(vals);

               if strcmp(vartype,'data') | strcmp(vartype,'calculation')  %check for data/calc field

                  num = length(vals);
                  
                  if num > 1

                     medianval(g,n) = median(vals);
                     tot = sum(vals);
                     total(g,n) = tot;

                     if (strcmp(type,'f') | strcmp(type,'e'))  %floating-point or exp
                        if strcmp(ntype,'continuous')
                           mn = mean(vals);
                           sd = std(vals);
                           meanval(g,n) = mn;
                           stddevval(g,n) = sd;
                           se(g,n) = sd ./ sqrt(num);
                        elseif strcmp(ntype,'angular')
                           meanval(g,n) = angleavg(vals,units);
                        end
                     end

                  else  %scalar value - skip stats, dispersion analysis

                     medianval(g,n) = vals;
                     total(g,n) = vals;
                     meanval(g,n) = vals;

                  end

               end

            end

         end

         if ~isfield(data,'description')
            data.description = data.name;
         end

         curdate = datestr(now);
         stats.title = ['Column statistics: ' data.title];
         stats.metadata = data.metadata;
         stats.history = [data.history ; {curdate},{'column statistics performed (''colstats'')'}];
         stats.analysisdate = curdate;
         stats.flagoption = flagoptstr;
         stats.name = data.name;
         stats.units = data.units;
         stats.description = data.description;
         stats.datatype = data.datatype;
         stats.variabletype = data.variabletype;
         stats.numbertype = data.numbertype;
         stats.precision = data.precision;
         stats.criteria = data.criteria;
         stats.group = [{groupname},{groupunits},{grouptype},{groupprec}];
         stats.groupvalue = groupval;
         stats.observations = numrows;
         stats.missing = missing;
         stats.valid = valid;
         stats.flagged = flagged;
         stats.min = minval;
         stats.max = maxval;
         stats.total = total;
         stats.median = medianval;
         stats.mean = meanval;
         stats.stddev = stddevval;
         stats.se = se;

      end

   end

else

   msg = 'this function requires a data structure as input';

end
