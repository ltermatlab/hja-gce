function str = cell2pipes(c,num,prefix,indent,compact)
%Concatenates elements in a cell array of strings to form a single character array separated with padding spaces
%and pipe characters for word-wrapping by the 'listmeta' function.  Note that multidimensional arrays
%will be concatenated by column and then row.
%
%syntax: str = cell2pipes(c,number,prefix,indent,compact)
%
%inputs:
%  c = cell array of strings
%  number = option to enumerate items (e.g. 1: xxx|2: xxx) (default = 0)
%  prefix = optional prefix to preceed each row (default = '')
%  indent = number of characters to add after each line break for indenting (default = 0)
%  compact = option to compact cell arrays to remove empty cells prior to concatenation
%    0 = no/default
%    1 = yes
%
%output:
%  str = character array
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
%last modified: 06-Mar-2013

str = '';

if nargin >= 1
   
   if ischar(c)
      c = cellstr(c);
   end
   
   if iscell(c)
      
      if exist('compact','var') ~= 1
         compact = 0;
      end
      
      if compact == 1
         I = find(~cellfun('isempty',c));
         if ~isempty(I)
            c = c(I);
         else
            c = [];
         end
      end
      
   end
   
   if ~isempty(c)
      
      n = length(c);      
      
      if exist('indent','var') == 1
         pad = blanks(indent);
      else
         pad = '';
      end
      
      if exist('prefix','var') ~= 1
         prefix = '';
      end
      
      if exist('num','var') ~= 1
         num = 0;
      end
      
      if num == 0
         prf = repmat({['|',pad,prefix]},1,n);
      else
         prf = strrep(cellstr([repmat('|',n,1),repmat([pad,prefix],n,1),int2str([1:n]'),repmat(':',n,1)]),':',': ')';
      end
      
      c2 = [prf ; c(:)'];
      
      str = [c2{:}];
      
   end
   
end
