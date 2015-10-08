function coords = corner_coord(axlims)
%Returns an array of SW and NE corner coordinates for a set of axis limits in degrees and utm
%
%syntax: coords = corner_coord(axlims)
%
%input:
%  axlims = axis limits (default = axis)
%
%output:
%  coords = [sw_lon,sw_lat,sw_utmzone,sw_easting,sw_northing, ...
%          ne_lon,ne_lat,ne_utmzome,ne_easting,ne_northing]
%
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

if ~exist('axlims')
   axlims = axis;
end

[sw_zone,sw_e,sw_n] = deg2utm(axlims(1),axlims(3));
[ne_zone,ne_e,ne_n] = deg2utm(axlims(2),axlims(4));

coords = [axlims(1),axlims(3),sw_zone,sw_e,sw_n,axlims(2),axlims(4),ne_zone,ne_e,ne_n];