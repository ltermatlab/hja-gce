function stations = thalweg2stations(transect,prefix,interval,datum)
%Generates a structure of CTD profiling station descriptions and coordinates from a Thalweg reference data set
%consisting of longitude, latitude and distance arrays
%
%syntax: stations = thalweg2stations(transect,prefix,interval,datum)
%
%input:
%  transect = transect label (variable name) in thalweg_ref.mat (string; required)
%  prefix = prefix code for the station labels (string; required)
%  interval = distance interval for looking up stations (integer; required)
%  datum = geographic datum to use for UTM projection (string; default = 'WGS84')
%
%output:
%  stations = structure with fields 'code', 'description', 'longitude', 'latitude', 'distance', 
%    'utm_zone', 'utm_easting', 'utm_northing'
%
%(c)2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 04-May-2015

stations = [];

%check for required input and thalweg file
if nargin >= 3 && exist('thalweg_ref.mat','file') == 2
   
   %validate datum
   if exist('datum','var') ~= 1
      datum = 'WGS84';
   end
   
   %validate input
   if ischar(transect) && ischar(prefix) && isnumeric(interval) && ~isempty(prefix) && ~isempty(interval)
      
      %load thalwegs
      try
         v = load('thalweg_ref.mat');
      catch
         v = struct('null');
      end
      
      %get variable (transect) names
      flds = fieldnames(v);
      
      %look up transect
      Imatch = find(strcmpi(transect,flds));
      
      %check for match
      if ~isempty(Imatch)
         
         %get thalweg reference transect coordinates and distance
         gps = v.(flds{Imatch(1)});
         lon = gps(:,1);
         lat = gps(:,2);
         dist = gps(:,3);
         
         %calculate target interval array
         dist0 = (ceil(min(dist)):interval:floor(max(dist)))';
         
         %interpolate to get matching longitudes at target distances
         lon0 = interp1(dist,lon,dist0,'pchip');
         
         %interpolate to get matching latitudes at target distances
         lat0 = interp1(dist,lat,dist0,'pchip');
         
         %init array of labels
         num = length(dist0);         
         
         stations = repmat(struct('code','','description','','longitude',[],'latitude',[],'distance',[], ...
            'utm_zone','','utm_easting',[],'utm_northing',[],'datum',datum),num,1);         
         
         %generate station labels
         for n = 1:num
            
            %generate +/- sign
            if dist0(n) < 0
               sgn = '-';
            else
               sgn = '+';
            end
            
            %generate station code
            stations(n).code = [prefix,sgn,sprintf('%02.0f',abs(dist0(n)))];
            
            %generate station description
            stations(n).description = ['Nominal ',int2str(dist0(n)),'km CTD profiling station for the GCE ',transect,' River transect'];
            
            %add lon/lat/distance
            stations(n).longitude = lon0(n);
            stations(n).latitude = lat0(n);
            stations(n).distance = dist0(n);
            
            %add utm coords
            [utm_zone,utm_east,utm_north] = deg2utm(lon0(n),lat0(n),datum);
            stations(n).utm_zone = utm_zone;
            stations(n).utm_easting = utm_east;
            stations(n).utm_northing = utm_north;
            
         end
         
      end
      
   end
   
end