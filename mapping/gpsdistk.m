function d = gpsdistk(gps1,gps2)
%Computes distance (in km) between GPS coordinates 'gps1' and 'gps2' 
%using cartographic formula for distance along great circle.  Arguments 'gps1' and 'gps2'
%are pairs of longitude/latitude values in degrees (individual coordinates or
%arrays of coordinates), and output is distance in km.
%
%syntax:  d = gpsdistk(gps1,gps2)
%
%input:
%  gps1 = 2-column array of longitude, latitude for first coordinate
%  gps2 = 2-column array of longitude, latitude for second coordinate
%
%output:
%  d = distance
%
%(c)2002-2005 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 15-Nov-2005

%convert to radians
gps1 = abs((gps1)).*(pi./180);
gps2 = abs((gps2)).*(pi./180);

%initialize output
d = zeros(size(gps1,1),1);

%calculate distance in degrees of arc
d = real(acos(sin(gps1(:,2)) .* sin(gps2(:,2)) + ...
   cos(gps1(:,2)) .* cos(gps2(:,2)) .* cos(abs(gps1(:,1)-gps2(:,1))))) .* (180./pi);

%convert to km
d =  d .* 111.111;