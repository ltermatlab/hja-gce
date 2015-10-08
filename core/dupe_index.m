function [I_dupes,msg] = dupe_index(s,cols,nan_opt)
%Returns an index of records in a GCE Data Structure with duplicate values in all or specified columns
%
%syntax: [I_dupes,msg] = dupe_index(s,cols,nan_opt)
%
%input:
%  s = GCE data structure
%  cols = array of column names or numbers to evaluate for duplicates (default = all columns)
%  nan_opt = option to match NaN values in addition to numeric and string values
%     0 = no (NaN ~= NaN)
%     1 = yes (NaN == NaN), default
%
%output:
%  Idupes = logical index of duplicated records (empty if no duplicates found)
%  msg = text of any error message
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
%last modified: 25-Apr-2013

%initialize output
I_dupes = [];
msg = '';

if nargin >= 1
   
   if gce_valid(s,'data')
      
      %supply defaults for omitted arguments
      if exist('cols','var') ~= 1
         cols = [];
      end
      
      if exist('nan_opt','var') ~= 1
         nan_opt = 1;
      end
      
      %validate column selections
      if isempty(cols)
         agcols = (1:length(s.name));  %default to all
      elseif ~isnumeric(cols)
         agcols = name2col(s,cols);  %look up column names
      else
         agcols = cols;
      end

      if ~isempty(agcols)
         
         %add original order column, omitted from sort index
         s2 = addcol(s,(1:length(s.values{1}))','temp_rownum','none','','d', ...
            'ordinal','discrete',0,'',length(s.name)+1);
            
         %sort by agcols in ascending order      
         s2 = sortdata(s2,agcols,1,1);

         if ~isempty(s2)
            
            %retrieve values, metadata
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
                  %substitute large negative number for NaN for comparisons if specified
                  if nan_opt == 1
                     x(isnan(x)) = -999999999;
                  end
                  compmat(:,n) = x;
               end
            end

            %calculate dupe index by comparing row-to-row diffs
            if numcols == 1
               I_dupes = [0 ; (abs(compmat(1:numrows-1,1)-compmat(2:numrows,1))' == 0)'];
            else
               I_dupes = [0 ; (sum(abs(compmat(1:numrows-1,:)-compmat(2:numrows,:))') == 0)'];
            end
            
            %check for dupes, restore original order
            if ~isempty(find(I_dupes))
               I_dupes(find(I_dupes)-1) = 1;  %copy 1's to first dupe
               [tmp,I_order] = sort(extract(s2,'temp_rownum'));  %get original order
               I_dupes = find(I_dupes(I_order));  %return record index numbers after restoring original order
            else
               I_dupes = [];
            end
            
         end
         
      else
         msg = 'invalid columns selections';   
      end
      
   else
      msg = 'invalid GCE Data Structure';
   end
   
else
   msg = 'insufficient arguments for function';
end