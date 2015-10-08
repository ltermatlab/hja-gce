function [s2,msg] = newtitle(s,titlestr,metaopt)
%Updates the title of a GCE Data or Stat Structure with the specified string
%
%syntax: [s2,msg] = newtitle(s,titlestr,metaopt)
%
%input:
%  s = structure to update
%  titlestr = new title string
%  metaopt = metadata update option:
%    0 = don't update
%    1 = update (default)
%
%output:
%  s2 = updated structure
%  msg = text of any error message
%
%
%(c)2002-2012 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 04-Apr-2012

s2 = [];
msg = '';

if nargin >= 2 && gce_valid(s,'data')

   %validate metadata option
   if exist('metaopt','var') ~= 1
      metaopt = 1;
   elseif metaopt ~= 0
      metaopt = 1;
   end

   if ischar(titlestr)

      s2 = s;
      s2.title = titlestr;
      s2.history = [s.history ; [{datestr(now)},{'updated title (''newtitle'')'}]];

      if metaopt == 1
         s2 = addmeta(s2,[{'Dataset'},{'Title'},{titlestr}],0,'newtitle');
      end
      
   else
      msg = 'non-text title strings are not supported';
   end

else
   msg = 'a valid GCE Data Structure and title string are required';
end