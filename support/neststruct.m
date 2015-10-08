function s = neststruct(s1,s2,key,fname)
%Nests a child structure in a specified field of a parent structure based on matching values in a shared key field
%
%syntax: s = neststruct(s_parent,s_child,keyfield,fieldname)
%
%inputs:
%  s_parent = the outer (parent) structure
%  s_child = the nested (child) structure
%  keyfield = the name of the shared key field
%  fieldname = the name of the field to store the matching
%    child structures in (will be overwritten if it exists)
%
%output:
%  s = the resultant nested structure
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
%last modified: 08-Jul-2002

s = [];

if nargin == 4

   %validate inputs
   if isstruct(s1) & isstruct(s2)
      if isfield(s1,key) & isfield(s2,key)
         s = s1;  %initialize output structure
         num = length(s1);
         eval(['vals={s2.',key,'}'';'])  %extract key field values as cell array
         eval(['s(1).',fname,'=[];'])  %add new field to output structure
         for n = 1:num  %loop through dimensions of parent structure
            parentval = getfield(s1(n),key);
            if ischar(parentval)
               I = find(strcmp(parentval,vals));
            elseif isnumeric(parentval)
               try  %try extracting comp values as numeric array
                  I = find(parentval==[vals{:}]);
               catch
                  I = [];
               end
            else
               I = [];
            end
            if ~isempty(I)
               s(n) = setfield(s(n),fname,s2(I));  %nest matching elements
            end
         end
      end
   end

end
