function movepoly(h)
%Moves a polygon (line object) to new center coordinates selected with the mouse.
%The position is updated on each left click and ends when another button is pressed.
%
%syntax: movepoly(h)
%
%input:
%  h = handle of line object to move
%
%output:
%  none
%
%
%(c)2002,2003,2004 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modifiedl: 09-Sep-2004

if nargin == 1

   if strcmp(get(h,'type'),'line')

      [x,y,btn] = ginput(1);

      while btn == 1

         centerpoly(h,x,y)
         [x,y,btn] = ginput(1);

      end

      refresh(gcf)

   end

end