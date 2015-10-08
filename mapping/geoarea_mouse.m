function [geoarea,coords] = geoarea_mouse(units)
%Calculates geographic surface area of a rectangle selected with the mouse
%
%syntax: [geoarea,coords] = geoarea_mouse(units)
%
%input:
%  units = surface area units
%    'm2' = square meters
%    'km2' = square km (default)
%    'hectares' = hectares
%
%output:
%  geoarea = surface area constained by the polygon
%  coords = array of polygon vertices
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
%last modified: 09-Sep-2004

geoarea = [];
coords = [];

if exist('units') ~= 1
   units = 'km2';
elseif ~strcmp(units,'m2') & ~strcmp(units,'hectares')
   units = 'km2';
end

btn = 1;
[x,y,button] = ginput(1);

if button == 1
   h = line(x,y);
   set(h,'marker','x','markersize',10,'color',[.8 0 0],'linestyle','-','linewidth',2)
   while button == 1
      coords = [coords ; x,y];
      set(h,'xdata',coords(:,1),'ydata',coords(:,2))
      drawnow
      [x,y,button] = ginput(1);
   end
   coords = [coords ; coords(1,:)];
   set(h,'xdata',coords(:,1),'ydata',coords(:,2))
   drawnow
   delete(h)
   drawnow
end

if size(coords,1) > 2
   geoarea = sitearea(coords,units);
end