function ar = sitearea(coords,output,units)
%Calculates the surface area entrained by a site polygon in lat/lon degrees or utm.
%(Note: the Mapping Toolbox function 'areaint' will be used for integration if present, otherwise
%'polyarea' will be used on reprojected utm coordinates)
%
%syntax: area = sitearea(coords,output,units)
%
%inputs:
%  coords = array of coordinates (numerical array of lon, lat pairs, or utm easting, northing, zone)
%  units = units of coordinates:
%    'deg' = degrees (default if all coords <= 180)
%    'utm' = utm/WGS84 (default if any coords > 180)
%  output = output units:
%    'm2' = square m
%    'km2' = square km (default)
%    'hectares' = hectares
%
%outputs:
%  ar = surface area
%
%(c)2004 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 02-Sep-2004

ar = [];

if nargin >= 1

   if size(coords,2) >= 2

      ar_m2 = [];  %init intermediate result var

      if exist('output') ~= 1
         output = 'km2';
      end

      if exist('units') ~= 1
         if max(max(abs(coords(:,1:2)))) <= 180
            units = 'deg';
         else
            units = 'utm';
         end
      end

      if exist('areaint') == 2 | exist('areaint') == 6  %check for mapping toolbox function, use areaint
         if strcmp(units,'utm')
            if size(coords,2) < 3
               coords = [coords , repmat(17,size(coords,1),1)];
            end
            [lon,lat] = utm2deg(coords(:,3),coords(:,1),coords(:,2));
         else
            lon = coords(:,1);
            lat = coords(:,2);
         end
         ar_m2 = areaint(lat,lon,almanac('earth','ellipsoid','meters'),'degrees');
      else  %convert to utm meters, use standard polyarea
         if strcmp(units,'deg')
            [utmz,utme,utmn] = deg2utm(coords(:,1),coords(:,2));
            if ~isempty(utme) & ~isempty(utmn)
               coords = [utme , utmn];
            end
         end
         ar_m2 = polyarea(coords(:,1),coords(:,2));
      end

      if ~isempty(ar_m2)
         switch output
            case 'km2'
               ar = ar_m2 .* 1e-6;
            case 'm2'
               ar = ar_m2;
            case 'hectares'
               ar = ar_m2 .* 0.0001;
         end
      end

   end

end