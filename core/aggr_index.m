function  [s2,I_breaks] = aggr_index(s,agcols)
%Returns a sorted data structure and grouping index for use in aggregation operations
%
%syntax: [s2,I_breaks] = aggr_index(s,agcols)
%
%inputs:
%  s = data structure to aggregate
%  agcols = array of column numbers or names to aggregate by, in order of precedence
%
%outputs:
%  s2 = sorted structure
%  I_breaks = starting index of each aggregate
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
%last modified:  24-Apr-2013

%init output
s2 = [];
I_breaks = [];

%check for required arguments
if nargin == 2

   %check for valid data structure
   if gce_valid(s,'data')

      %resolve text column names
      if ~isnumeric(agcols)
         agcols = name2col(s,agcols);
      end

      %validate aggregation column selection
      if ~isempty(agcols)
	      I = find(agcols > 0 & agcols <= length(s.values));
   	   if ~isempty(I)
      	   agcols = agcols(I);
         else
            agcols = [];
	      end
      end

      if ~isempty(agcols)

         %sort data structure by aggregation columns
         s2 = sortdata(s,agcols,1,1);

         if ~isempty(s2)

            %get data type and value arrays from structure
            types = s2.datatype;
            vals = s2.values;
            
            %calculate number of rows and columns
            numrows = length(vals{1});
            numcols = length(agcols);

            %init all-numerical comparison matrix
            compmat = ones(numrows,numcols);
            
            %loop through agcols populating comparison matrix
            for n = 1:length(agcols)
               
               %get column value array
               x = vals{agcols(n)};
               
               %check for string data, substitute unique integers
               if strcmp(types{agcols(n)},'s')
                  
                  %get index of start positions of each new group
                  Igp = [find([0;strcmp(x(1:length(x)-1),x(2:length(x)))]==0) ; numrows+1];

                  %use sequential integer for each group
                  for m = 1:length(Igp)-1
                     compmat(Igp(m):Igp(m+1)-1,n) = m; 
                  end
                  
               else %use numeric value                  
                  compmat(:,n) = x;
               end
               
            end

            %calculate master grouping index by comparing row-to-row diffs and padding array
            if numcols == 1
               I_breaks = [1 ; find([0 ; (abs(compmat(1:numrows-1,:)-compmat(2:numrows,:))')']) ; ...
                     numrows+1];
            else
               I_breaks = [1 ; find([0 ; sum(abs(compmat(1:numrows-1,:)-compmat(2:numrows,:))')']) ; ...
                     numrows+1];
            end

         end

      end

   end

end
