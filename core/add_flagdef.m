function [s2,msg] = add_flagdef(s,flag,flagdef)
%Adds a Q/C flag definition to a GCE Data Structure if not already defined
%
%syntax: [s2,msg] = add_flagdef(s,flag,flagdef)
%
%inputs:
%  s = data structure to update (struct; required)
%  flag = Q/C flag to look up (string character; required)
%  flagdef = Q/C flag definition to add if flag is not listed in the metadata (string; required)
%
%outputs:
%  s2 = updated structure
%  msg = text of any error messages
%
%notes:
%  1) if an existing definition for flag is found in the metadata, the unmodified structure will be return
%
%(c)2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 14-Jan-2015

%init output
s2 = s;
msg = '';

%perform quick validation
if isstruct(s) && isfield(s,'metadata')
   
   if ~isempty(flag) && ischar(flag) && length(flag) == 1 && ~isempty(flagdef)
      
      %add flag code and definition to metadata if necessary
      meta = lookupmeta(s2,'Data','Codes');
      
      %check for existing definition for flag
      if isempty(strfind(meta,[flag,' = ']))
         
         %check for other existing definitions
         if isempty(meta)
            meta = [flag,' = ',flagdef];
         else
            meta = [meta,', ',flag,' = ',flagdef];
         end
         
         %update metadata
         s2 = addmeta(s2,{'Data','Codes',meta},0,'add_flagdef');
         
         if isempty(s2)
            s2 = s;
            msg = 'an error occurred updating the flag definition metadata - update cancelled';
         end
         
      end
      
   else
      msg = 'invalid flag or flag definition';
   end
   
else
   msg = 'invalid data structure';
end