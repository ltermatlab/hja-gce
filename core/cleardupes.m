function [s2,msg,deletedrows] = cleardupes(s,cols,logopt)
%Removes rows in a GCE Data Structure in which the contents of all specified columns are duplicated,
%preserving the first instance of each group.
%
%Note that the structure will be sorted by the selected columns, and all columns will be
%returned regardless of the comparison column selections.
%
%syntax: [s2,msg,deletedrows] = cleardupes(s,cols,logopt)
%
%inputs:
%  s = data structure
%  cols = array of column numbers or names to check for duplication (default = all)
%  logopt = processing history logging option
%    'verbose' (default) = full logging of sort and clear operations
%    'simple' = simplified logging or sort and clear operations (no column listings)
%    'silent' = no operations logged (used to suppress sort/clear operations called
%       from other functions)
%
%outputs:
%  s2 = compacted structure (= s if no duplicated rows)
%  msg = text of any error message
%  deletedrows = number of rows deleted
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
%last modified: 21-Apr-2013

s2 = [];
msg = '';
deletedrows = 0;

if nargin >= 1

   if gce_valid(s,'data')

      if exist('logopt','var') ~= 1
         logopt = 'verbose';
      elseif ~strcmp(logopt,'simple') && ~strcmp(logopt,'silent')
         logopt = 'verbose';
      end

      if exist('cols','var') ~= 1
         cols = [];
      end

      if isempty(cols)
         agcols = 1:length(s.name);  %default to all
      elseif ~isnumeric(cols)
         agcols = name2col(s,cols);  %look up column names
      else
         agcols = cols;
      end

      if ~isempty(agcols)

         %sort data in ascending order, with case-sensitive text sorts
         s2 = sortdata(s,agcols,1,1);

         if ~isempty(s2)

            vals = s2.values;
            types = s2.datatype;
            numrows = length(vals{1});
            numcols = length(agcols);

            %produce all-numerical comparison matrix
            compmat = ones(numrows,numcols);
            for n = 1:length(agcols)
               x = vals{agcols(n)};
               if strcmp(types{agcols(n)},'s')  %substitute unique integers for strings
                  Igp = [find([0;strcmp(x(1:length(x)-1),x(2:length(x)))]==0) ; numrows+1];
                  for m = 1:length(Igp)-1
                     compmat(Igp(m):Igp(m+1)-1,n) = m;
                  end
               else
                  compmat(:,n) = x;
               end
            end
            compmat(isnan(compmat)) = -999999999;  %replace NaNs to avoid comparison failures

            %calculate master grouping index by comparing row-to-row diffs and padding array
            if numcols == 1
               I_breaks = [1 ; find([0 ; (abs(compmat(1:numrows-1,:)-compmat(2:numrows,:))')'])];
            else
               I_breaks = [1 ; find([0 ; sum(abs(compmat(1:numrows-1,:)-compmat(2:numrows,:))')'])];
            end

            if length(I_breaks) < numrows  %check for dupes
               str_hist = s2.history;
               s2 = copyrows(s2,I_breaks);
               deletedrows = numrows - length(I_breaks);
               if ~isempty(s2)
                  switch logopt
                  case 'simple'
                     if length(agcols) < length(s2.name)
	                     str_hist = [s.history ; {datestr(now)},{['removed ',int2str(deletedrows), ...
                                    ' row(s) with duplicate values in ',int2str(length(agcols)),' columns (''cleardupes'')']}];
                     else
	                     str_hist = [s.history ; {datestr(now)},{['removed ',int2str(deletedrows), ...
                                    ' row(s) with duplicate values in all columns (''cleardupes'')']}];
                     end
                  case 'silent'
                     str_hist = s.history;
                  otherwise
                     if length(agcols) < length(s2.name)
			               str_hist = [str_hist ; {datestr(now)},{['removed ',int2str(deletedrows), ...
   	   		                     ' row(s) with duplicate values in the column(s) ',cell2commas(s2.name(agcols),1), ...
                                    ' (''cleardupes'')']}];
                     else
			               str_hist = [str_hist ; {datestr(now)},{['removed ',int2str(deletedrows), ...
   	   		                     ' rows() with duplicate values in all columns (''cleardupes'')']}];
                     end
                  end
                  s2.history = str_hist;
                  s2.editdate = datestr(now);
               else
                  msg = 'errors occurred applying the selection index';
               end
            else
               s2 = s;  %no dupes - replace original
               msg = 'no duplicate records found';
            end

         end

      else
         msg = 'column selection is invalid';
      end

   else
      msg = 'invalid GCE s2 Structure';
   end

else
   msg = 'insufficient arguments for function';
end