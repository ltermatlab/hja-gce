function rec2paral(h,topoff)
%Shifts the top of a rectangle or parallelogram represented by the line handle 'h' by the amount 'topoffset'
%
%syntax:  rec2paral(h,topoffset)
%
%input:
%  h = line handle
%  topoff = top offset amount
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
%last modified: 25-Jul-2008


if nargin == 2
   
   if strcmp(get(h,'type'),'line')
      
      x = get(h,'xdata');
      y = get(h,'ydata');
      
      if length(x) == 4 || length(x) == 5
         
         xmin = min(x);
         xmax = max(x);
         ymin = min(y);
         ymax = max(y);
         
         Iy = (y == ymin);
         
         xbot = x(Iy);
         xtop = x(~Iy);
         
         x2 = [ min(xbot) , min(xtop)+topoff , max(xtop)+topoff , max(xbot) , min(xbot) ];
         y2 = [ ymin , ymax , ymax , ymin , ymin];
         
         set(h, ...
            'XData',x2, ...
            'YData',y2);
         
         drawnow
            
      end
      
   end
      
end
