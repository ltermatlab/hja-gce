function [s2,msg] = depth2waterlevel(s,col_depth,elevation)
%calculates water level in meters from depth based on mooring elevation in m (NAVD88 datum)
%
%syntax: [s2,msg] = depth2waterlevel(s,col_depth,elevation)
%
%input:
%  s = data structure to update
%  col_depth = name or index of depth column (ideally pressure-corrected depth)
%  elevation = mooring elevation in m (NAVD88 datum)
%
%output:
%  s2 = updated structure
%  msg = text of any error message
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
%last modified: 18-Nov-2010

s2 = [];
msg = '';

if nargin == 3 && gce_valid(s,'data') == 1
   
   %look up depth column index
   if ~isnumeric(col_depth)
      col_depth = name2col(s,col_depth);
   end
   
   if ~isempty(col_depth) && length(elevation) == 1
      
      %convert depth units to meters if necessary
      depunits = s.units{col_depth};      
      if ~strcmpi(depunits,'m') && ~strcmpi(depunits,'meters')
         s = unit_convert(s,col_depth,'m');
      end
      
      if ~isempty(s)
         
         %get depth data
         dep = extract(s,col_depth);
         
         %calculate level
         waterlevel = dep + elevation;
         
         %add water level column
         [s2,msg] = addcol(s,waterlevel,'Water_Level','m', ...
            ['Water level calculated from depth of water above a base elevation of ',num2str(elevation)], ...
            'f','calculation','continuous',s.precision(col_depth),'',col_depth+1);
         
         %add calculation metadata
         meta = lookupmeta(s2,'Data','Calculations');
         meta = [meta,'|Water_Level(m) = ',num2str(elevation),' + ',s.name{col_depth},'(',s.units{col_depth},')'];
         s2 = addmeta(s2,{'Data','Calculations',meta});
         
         %propagate flags
         s2 = copyflags(s2,s.name{col_depth},'Water_Level','add');
         
      else
         msg = ['failed to convert units of ',s.name{col_depth},' from ',depunits,' to meters'];
      end
      
   else
      if isempty(col_depth)
         msg = 'invalid depth column';
      else
         msg = 'invalid elevation data';
      end
   end
   
else
   if nargin < 3
      msg = 'insufficient inpug arguments for function';
   else
      msg = 'invalid data structure';
   end
end