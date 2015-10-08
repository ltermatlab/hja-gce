function guihelp(fcn)
%Opens MATLAB help text for a specified function in a scrollable GUI dialog
%
%syntax: guihelp(fcn)
%
%input:
%  fcn = name of a MATLAB function m-file
%
%output:
%  none
%
%(c)2008 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 11-Jan-2008

if nargin == 1
   try
      str = help(fcn);
   catch
      str = '';
   end
   if ~isempty(str)
      str = strrep(str,char(10),char(13));
      str = strrep(str,char(9),'   ');
      str = splitstr(str,char(13),0,0);
      viewtext(str,0,0,['Function help for ''',fcn,''''])
   else
      disp([fcn,' is not a valid MATLAB function'])
   end
end