function [lon,lat,dist] = gps2thalweg(lon0,lat0,dist0,res)
%Generates a high resolution Thalweg line from an array of GPS locations along a river channel
%
%syntax: [lon,lat,dist] = gps2thalweg(lon0,lat0,dist0,res)
%
%input:
%   lon0 = array of initial GPS longitudes, progressing from downriver to upriver (decimal degrees)
%   lat0 = array of initial GPS latitudes, progressing from downriver to upriver (decimal degrees)
%   dist0 = starting downriver distance (km)
%   res = target resolution (default = 0.01km)
%
%output:
%   lon = interpolated array of Thalweg longitudes (decimal degrees)
%   lat = interpolated array of Thalweg latitudes (decimal degrees)
%   dist = array of cumulative distances for each coordinate (km)
%
%
%(c)2012-2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 04-Jun-2013

%init output
lon = [];
lat = [];
dist = [];

%check for required arguments
if nargin >= 3 && isnumeric(lon0) && isnumeric(lat0) && isnumeric(dist0) && length(lon0)==length(lat0)
   
   if exist('res','var') ~= 1
      res = 0.01;
   end
   
   %estimate end-to-end distance of GPS path by dead reckoning from specified coordinates
   dist_test = max(cumsum([0 ; gpsdistk([lon0(1:end-1) lat0(1:end-1)],[lon0(2:end) lat0(2:end)])]));
   
   %calculate number of intermediate points based on overall end-to-end distance, multiplying by 50 to allow for curves
   pts = (dist_test ./ res) .* 50;
   
   %initialize starting coordinate index
   idx = (1:length(lon0))';
   
   %initialize high resolution coordinate index
   idx2 = linspace(1,idx(end),pts)';
   
   %interpolate longitudes to match index
   lon2 = interp1(idx,lon0,idx2,'pchip');
   
   %intperolate latitudes to match index
   lat2 = interp1(idx,lat0,idx2,'pchip');
   
   %calculate point-to-point distance array
   dist_p2p = [0 ; gpsdistk([lon2(1:end-1) lat2(1:end-1)],[lon2(2:end) lat2(2:end)])];
   
   %calculate cumulative distance, adding initial distance 
   dist2 = cumsum(dist_p2p) + dist0;
   
   %get unique distances to prevent interpolation errors
   [dist2,Idist2] = unique(dist2);
   
   %calculate target distance array based on initial and terminal distances and resolution
   dist = (dist0:res:max(dist2))';
   
   %interpolate to get matching longitudes at target distances
   lon = interp1(dist2,lon2(Idist2),dist,'pchip');
   
   %interpolate to get matching latitudes at target distances
   lat = interp1(dist2,lat2(Idist2),dist,'pchip');
   
   %recalculate distances for final lon/lat to account for distorations along bends
   dist = cumsum([0 ; gpsdistk([lon(1:end-1) lat(1:end-1)],[lon(2:end) lat(2:end)])]) + dist0;
   
end


