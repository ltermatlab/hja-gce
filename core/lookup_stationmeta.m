function [meta,msg,polygons] = lookup_stationmeta(loc)
%Returns formatted site descriptor metadata for a list of GCE-LTER sampling locations
%(requires the file 'geo_locations.mat' be present in the Matlab path)
%
%syntax: [meta,msg] = lookup_stationmeta(locations,autopolygons)
%
%input:
%  locations = cell array of GCE site codes or array of site numbers
%
%outputs:
%  meta = n x 3 cell array of metadata
%  msg = text of any error messages
%  polygons = array of bounding polygons for matched locations
%
%
%(c)2002-2011 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 11-Nov-2011

%init output
meta = [];
msg = '';
polygons = [];

if nargin == 1
   
   if ~isempty(loc) && exist('geo_locations.mat','file') == 2  %look for geographic info data
      
      try
         v = load('geo_locations.mat','-mat');
         locations = v.locations;
      catch
         locations = [];
      end
      
      %check for valid locations structure
      if isstruct(locations) && isfield(locations,'Name');
         
         if ischar(loc)
            loc = cellstr(loc);  %convert string to cell array to avoid syntax errors
         elseif ~iscell(loc)  %lookup codes based on site numbers
            loc = [];
         end
         
         %initialize metadata strings
         locs = '';
         bounds = '';
         phys = '';
         land = '';
         hyd = '';
         topo = '';
         geol = '';
         veg = '';
         
         %init polygons array
         polygons = repmat({''},length(loc),1);
         
         %loop through locations performing lookups
         for n = 1:length(loc)
            
            I = find(strcmp({locations.Location},loc{n}));
            
            if ~isempty(I)
               
               %get site code for matched location
               polygons{n} = locations(I).SiteCode;
               
               %init location string
               locstr = ['|',locations(I).Location,' -- '];
                              
               %format bounding box/point location coordinates
               bounds = [bounds, ...
                  locstr, ...
                  sprintf('%02d %02d %04.1f W, %02d %02d %04.1f N', ...
                  ddeg2dms(abs(locations(I).Longitude)),ddeg2dms(locations(I).Latitude))];
               
               locs = [locs,locstr,locations(I).Name];
               phys = [phys,locstr,locations(I).Physiography];
               land = [land,locstr,locations(I).Landform];
               hyd = [hyd,locstr,locations(I).Hydrography];
               topo = [topo,locstr,locations(I).Topography];
               geol = [geol,locstr,locations(I).Geology];
               veg = [veg,locstr,locations(I).Vegetation];
               
            end
            
         end
         
         %assign metadata fields
         if ~isempty(locs)
            meta = [{'Site'},{'Location'},{locs}; ...
               {'Site'},{'Coordinates'},{bounds} ; ...
               {'Site'},{'Physiography'},{phys} ; ...
               {'Site'},{'Landform'},{land} ; ...
               {'Site'},{'Hydrography'},{hyd} ; ...
               {'Site'},{'Topography'},{topo} ; ...
               {'Site'},{'Geology'},{geol} ; ...
               {'Site'},{'Vegetation'},{veg}];
         end
         
         polygons = unique(polygons);
         
      else
         msg = 'Geographic location file ''geo_locations.mat'' is invalid';
      end
      
   else
      msg = 'Geographic location file ''geo_locations.mat'' could not be loaded';
   end
   
else
   msg = 'insufficient arguments for function';
end
