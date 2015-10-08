function Icols = listdatacols(s,opt)
%Returns an index of data and/or calculation columns (dependent variables) in a GCE Data Structure
%or optionally returns an inverse index (i.e. index of non-data and non-calculation columns)
%
%syntax: Icols = listdatacols(s,option)
%
%inputs:
%  s = data structure to query
%  option = optional function modifier
%    '' = none (default)
%    'inverse' = option to invert the index to list non-data, non-calculation columns
%
%outputs:
%  Icols = index of columns with variable types of 'data' or 'calculation' (or inverse index)
%
%
%(c)2002-2006 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 30-Aug-2006

Icols = [];

if nargin >= 1
   
   if exist('opt','var') ~= 1
      opt = '';
   end

   if gce_valid(s,'data')
      
      Icols = strcmp(s.variabletype,'data') | strcmp(s.variabletype,'calculation');
      
      if isempty(opt)
         Icols = find(Icols);
      else
         switch opt
            case 'inverse'
               Icols = find(~Icols);
            otherwise
               Icols = find(Icols);
         end
      end
      
   end
   
end