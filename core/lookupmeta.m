function str = lookupmeta(s,catname,fieldname)
%Looks up metadata in a GCE Data or Stat Structure by category and fieldname
%
%syntax: str = lookupmeta(s,catname,fieldname)
%
%inputs:
%  s = structure or nx3 metadata array
%  catname = category name (string)
%  fieldname = field name (string)
%
%output:
%  str = string containing the value of the specified category and field
%
%(c)2002-2011 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 25-May-2011

str = '';

if nargin == 3
   
   if ~isempty(catname) && ~isempty(fieldname)
      
      meta = [];
      
      if isstruct(s)
         if isfield(s,'metadata')
            meta = s.metadata;
         end
      elseif iscell(s)
         meta = s;
      end
      
      if size(meta,2) == 3
         
         I_metafld = [];
         
         I_cat = find(strcmp(meta(:,1),catname));
         if ~isempty(I_cat)
            I_fld = find(strcmp(meta(I_cat,2),fieldname));
            if ~isempty(I_fld)
               I_metafld = I_cat(I_fld(1));
            end
         end
         
         if ~isempty(I_metafld)
            str = meta{I_metafld,3};
         end
         
      end
      
   end
   
end