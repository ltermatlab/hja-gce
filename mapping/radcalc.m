function rad = radcalc(xarray,yarray)
%Returns the radius of the circle with origin x(1),y(1) and peripheral point x(2),y(2)
%
%syntax:  rad = radcalc(xarray,yarray)
%
%input:
%  xarray = array of x values for circle origins
%  yarray = array of y values for cirlce origins
%
%output:
%  rad = radius (in units of xarray/yarray)
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
%last modified: 25-Jul-2008

rad = [];

if length(xarray) == 2 & length(yarray) == 2

   rad = sqrt((xarray(1)-xarray(2))^2 + (yarray(1)-yarray(2))^2);

else

   disp(' ');
   disp('Incorrect number of coordinate pairs or mismatched arrays!');
   disp(' ')

end
