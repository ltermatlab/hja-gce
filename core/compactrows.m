function [s2,msg,deletedrows] = compactrows(s,datacols)
%Compacts a GCE Data Structure by eliminating rows in the structure in which all indicated data columns contain NaN or ''
%(note: all columns will be returned regardless of 'datacols' selection)
%
%syntax:  [s2,msg,deletedrows] = compactrows(s,datacols)
%
%inputs:
%  s = GCE Data Structure
%  datacols = array of column names or numbers to evaluate (default = all)
%
%output:
%  s2 = compacted structure
%  msg = text of any error messages
%  deletedrows = number of rows deleted
%
%
%(c)2002-2008 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 25-Feb-2008

s2 = [];
msg = '';
deletedrows = 0;

if nargin >= 1

   if gce_valid(s,'data');

      %select all columns if datacols omitted
      if exist('datacols','var') ~= 1
         datacols = [];
      end
      if isempty(datacols)
         datacols = [1:length(s.name)];
      end

      %validate column selection
      if ~isnumeric(datacols)
         c = name2col(s,datacols);  %perform column name lookups
      else
         maxcol = length(s.name);  %calculate maximum column index
         c = datacols;
         c = c(c>0 & c<=maxcol);  %exclude out-of-range columns
      end

      if ~isempty(c)

         %initialize valid record index
         Icum = zeros(length(s.values{1}),1);

         %loop through columns, adding indices of nonzero elements to Icum
         dtypes = s.datatype;  %extract data type array
         for n = 1:length(c)
            col = c(n);  %get column pointer
            vals = s.values{col};  %extract values
            if strcmp(dtypes{col},'s')
               Ivalid = ~cellfun('isempty',vals);  %get index of non-empty strings
            else
               Ivalid = ~isnan(vals);  %get index of non-NaN numbers
            end
            Icum = Icum + Ivalid;  %add index to cumulative index
         end

         Ifin = find(Icum);  %build final index of rows with >=1 nonzero element

         if length(Ifin) == length(Icum)
            s2 = s;  %no empty rows, revert to original structure
            msg = 'no empty records found';
         else  %subsample structure, update history
            h = s.history;  %buffer history to prevent generic copyrows entry
            deletedrows = length(Icum)-length(Ifin);
            s2 = copyrows(s,Ifin,'y');  %perform subselection
            s2.history = [h ; ...
                  {datestr(now)},{['removed ',int2str(deletedrows), ' rows with empty values in columns ', ...
                        cell2commas(s.name(c),1),' (''compactrows'')']}];
         end

      else
         msg = 'invalid column selections';
      end

   else
      msg = 'invalid data structure';
   end

end