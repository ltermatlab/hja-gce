function str2 = escape_chars(str,charlist)
%Escapes specified characters in a string to prevent XML/HTML validation errors
%
%syntax: str2 = escape_chars(str,charlist)
%
%inputs:
%   str = character array or cell array of strings to update
%   charlist = 2-column cell array of string substitutions
%     (default = {'&','&amp;';'<','&lt;';'>','&gt;'})
%
%outputs:
%   str2 = updated character array or cell array of strings
%
%(c)2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 16-May-2013

str2 = '';

%check for required input
if nargin >= 1 && ~isempty(str)
   
   %define default characters to escape   
   if exist('charlist','var') ~= 1 || isempty(charlist)
      charlist = { ...
         '&','&amp;'; ...
         '<','&lt;'; ...
         '>','&gt;' ...
         };
   elseif ~iscell(charlist) || size(charlist,2) ~= 2
      charlist = [];
   end
   
   %check for valid charlist
   if ~isempty(charlist)
      
      %init output
      str2 = str;
      
      %loop through character pairs performing substitions
      for n = 1:size(charlist,1)
         str2 = strrep(str2,charlist{n,1},charlist{n,2});
      end
      
   end
   
end
      
