function Inull = isnull(values)
%Returns a logical index of null values in any array type (numeric, character, cell array)
%
%syntax: Inull = isnull(values)
%
%input:
%  values = numeric array or cell array of strings
%  
%output:
%  Inull = logical index of null values (NaN or zero-length strings) the same dimensions
%    as values
%
%usage notes:
%  - for numeric arrays this is equivalent to 'isnan'
%  - for character arrays, returns an index of all-blank rows
%  - for cell arrays, returns an index of empty cells or zero-length strings
%
%(c)2010 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 04-Nov-2010

Inull = [];

if nargin == 1
   
   if isnumeric(values)
      
      Inull = isnan(values);  %use isnan directly
      
   elseif ischar(values)
      
      %loop through rows checking for non-empty strings
      nrows = size(values,1);
      Ilen = zeros(nrows,1);      
      for n = 1:nrows
         Ilen(n) = length(find(values(n,:) ~= ' '));  %get length 
      end
      
      %convert numeric array to logical array
      Inull = Ilen == 0;
      
   elseif iscell(values)
      
      %get separate index of empty cells and array of content lengths
      Iempty = cellfun('isempty',values);
      len = cellfun('length',values);
      
      %form combined index of empty/zero-length strings
      Inull = Iempty | len == 0;
      
   end
   
end