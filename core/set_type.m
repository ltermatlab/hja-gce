function [s2,msg] = set_type(s,attribute,value,cols)
%Sets attribute descriptor values for specified columns in a GCE Data Structure
%
%syntax: [s2,msg] = set_type(s,attribute,value,cols)
%
%input:
%  s = structure to update
%  attribute = attribute metadata to update
%     'datatype' = physical data type (= storage type)
%     'variabletype' = variable type (= logical or semantic type)
%     'numbertype' = numerical type
%  value = attribute value to assign (string, e.g. 'calculation' for attribute 'variabletype')
%  cols = names or indices of columns to update
%
%output:
%  s2 = updated structure
%  msg = text of any error message
%
%(c)2002-2010 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 11-Feb-2010

%init output
s2 = [];
msg = '';

if nargin == 4 && gce_valid(s,'data')
   
   if ischar(value) && ~isempty(value)
      
      %validate column selections
      if ~isnumeric(cols)
         cols = name2col(s,cols);
      else
         cols = intersect(cols,(1:length(s.name)));
      end
      
      if ~isempty(cols)
         
         %set attribute by type
         switch attribute
            
            case 'datatype'
               
               s.datatype(cols) = {value};
               
            case 'variabletype'
               
               s.variabletype(cols) = {value};
               
            case 'numbertype'
               
               s.numbertype(cols) = {value};
               
            otherwise
               
               msg = 'invalid attribute type selection';
               
         end
         
         %validate structure
         if ~isempty(s)
            
            [val,stype,msg0] = gce_valid(s,'data');
            
            if val == 1
               
               %copy structure to output, update processing history and edit date
               s2 = s;
               if length(cols) == 1
                  str = ['changed ''',attribute,''' attribute for column ',s2.name{cols},' to ''',value,''' (''set_type'')'];
               else
                  str = ['changed ''',attribute,''' attribute for columns ',cell2commas(s2.name(cols),1),' to ''',value,''' (''set_type'')'];
               end
               s2.history = [s.history ; {datestr(now)},{str}];
               s2.editdate = datestr(now);
               
            else
               msg = ['invalid attribute value: ',msg0];
            end
            
         end
         
      else
         msg = 'invalid attribute value setting';
      end
      
   else
      msg = 'invalid column selections';
   end
   
else
   if nargin < 4
      msg = 'insufficient input for function';
   else
      msg = 'invalid data structure';
   end
end