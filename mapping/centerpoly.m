function centerpoly(h,x,y)
%Centers the polygon represented by handle 'h' over the coordinates
%given by 'x' and 'y'
%
%syntax:  centerpoly(h,x,y)
%
%input:
%  h = handle of the line object (polygon) to center
%  x = x coordinate to center on (in data units)
%  y = y coordinate to center on (in data units)
%
%output:
%  none
%
%(c)2004 by Wade Sheldon
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
%Department of Marine Sciences
%University of Georgia
%Athens, Georgia  30602-3636
%sheldon@uga.edu
%
%last modified: 08-Sep-2004

if nargin == 3

   if strcmp(get(h,'type'),'line') & length(x)==length(y)

      x0 = get(h,'XData');
      y0 = get(h,'YData');
      ctr0 = geocenter([x0',y0']);

      xdif = ctr0(1) - x;
      ydif = ctr0(2) - y;

      set(h, ...
         'XData',[x0-xdif], ...
         'YData',[y0-ydif])

      drawnow

   end

end
