function pn2 = clean_path(pn)
%Removes a terminal file separator from a path string when present for generating fully-qualified file paths
%
%syntax: pn2 = clean_path(pn)
%
%inputs:
%  pn = path name to clean (e.g. from uiputfile or uigetfile)
%
%outputs:
%  pn2 = path without terminal file separator
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
%last modified: 13-Oct-2010

if nargin == 1 && ischar(pn)
   if strcmp(pn(end),filesep)
      pn2 = pn(1:end-1);
   else
      pn2 = pn;
   end
else
   pn2 = '';
end
