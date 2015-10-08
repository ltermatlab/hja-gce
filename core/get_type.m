function types = get_type(s,attribute,cols)
%Returns the specified attribute descriptor for specified columns in a GCE Data Structure
%
%syntax: types = get_type(s,attribute,cols)
%
%input:
%  s = data structure to query
%  attribute = attribute metadata to query
%    'datatype' = physical data type (= storage type)
%    'variabletype' = variable type (= logical type)
%    'numerbertype' = numerical type
%  cols = names or indices of columns to query (default = all)
%
%output:
%  types = attribute descriptors (character array if 1 column specified, otherwise cell array of strings)
%
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
%last modified: 28-Oct-2014

%init output
types = '';

%check for required input
if nargin >= 2
   
   if gce_valid(s,'data')
      
      %look up number of columns in data set
      numcols = length(s.name);
      
      %default to all columns
      if exist('cols','var') ~= 1 || isempty(cols)
         cols = [];
      end
      if isempty(cols)
         cols = (1:numcols);
      elseif ~isnumeric(cols)
         cols = name2col(s,cols);
      end
      
      %remove invalid columns
      cols = intersect(cols,(1:length(s.name)));
      
      %look up column metadata
      if ~isempty(cols)
         switch(attribute)
            case 'datatype'
               types = s.datatype(cols);
            case 'variabletype'
               types = s.variabletype(cols);
            case 'numbertype'
               types = s.numbertype(cols);
         end
      end
      
      %convert cell array to character array if 1 column specified
      if length(cols) == 1
         types = char(types);
      end
      
   end
   
end