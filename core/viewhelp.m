function viewhelp(fcn)
%Displays help text for a specified function in a scrollable text viewer
%using the function 'viewtext'
%
%syntax: viewhelp(fcn)
%
%input:
%  fcn = function name
%
%output:
%  none
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
%last modified: 08-Mar-2006

if nargin > 0
   try
      h = help(fcn);
   catch
      h = '';
   end
   if ~isempty(h)
      ar = splitstr(h,char(10),0,0);
      viewtext(ar,0,0,[fcn,' help']);
   end
end