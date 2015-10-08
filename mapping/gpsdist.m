function y = gpsdist(coords1,coords2,units)
%Calculates great circle distance between geographic coordinates (longitude/latitude pairs)
%in kilometers, nautical miles or degrees of arc
%
%syntax:  y = gpsdist(coords1,coords2,units)
%
%input:
%  coords1 = 2-column array of longitudes, latitudes in decimal degrees for start point
%  coords2 = 2-column array of longitudes, latitudes in decimal degrees for end point
%  units = distance units (default = 1)
%    0 = degrees of arc
%    1 = kilometers
%    2 = nautical miles
%
%output:
%  y = distance
%
%(c)2002-2009 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 10-Nov-2009

%init output
y = [];

if nargin >= 2
   
   if exist('units','var') ~= 1   %set default units to km
      units = 1;
   end
   
   %convert to degrees to radians
   coords1_rad = abs((coords1)).*(pi/180);
   coords2_rad = abs((coords2)).*(pi/180);
   
   %calculate distance in degrees of arc
   dist = real(acos(sin(coords1_rad(:,2)) .* sin(coords2_rad(:,2)) + ...
      cos(coords1_rad(:,2)) .* cos(coords2_rad(:,2)) .* cos(coords1_rad(:,1) - coords2_rad(:,1))) .* (180/pi));
   
   %perform unit conversions
   if units == 1
      y = dist .* 111.111;   %convert to distance in km
   elseif units == 2
      y = dist .* 60;   %convert to distance in nm
   else
      y = dist;  %degrees of arc
   end
   
end