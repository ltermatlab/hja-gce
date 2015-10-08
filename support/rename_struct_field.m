function s2 = rename_struct_field(s,fld_old,fld_new)
%Renames a structure field without re-ordering the existing fields
%
%syntax: s2 = rename_struct_field(s,fld_old,fld_new)
%
%inputs:
%  s = original structure
%  fld_old = old fieldname
%  fld_new = new fieldname
%
%outputs:
%  s2 = modified structure
%
%(c)2004 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%Wade Sheldon
%Dept. of Marine Sciences
%University of Georgia
%Athens, GA 30602-3636
%
%last modified: 20-Aug-2004

s2 = [];

if nargin == 3
   
   flds = fieldnames(s);
   
   for n = 1:length(flds)
      if strcmp(flds{n},fld_old)
         for m = 1:length(s)
            s2(m).(fld_new) = s(m).(fld_old);
         end
      else
         for m = 1:length(s)
            s2(m).(flds{n}) = s(m).(flds{n});
         end
      end
   end
   
end