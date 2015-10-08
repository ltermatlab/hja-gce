function [meta,msg] = lookup_sitemetadata(sitecode)
%Returns formatted site descriptor metadata for a list of GCE-LTER sampling sites
%(requires the file 'geo_polygons.mat' be present in the Matlab path)
%
%syntax: [meta,msg] = lookup_sitemetadata(sitecode)
%
%input:
%  sitecode = cell array of GCE site codes or array of site numbers
%
%outputs:
%  meta = n x 3 cell array of metadata
%  msg = text of any error messages
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
%last modified: 16-Nov-2011

meta = [];
msg = '';

if nargin == 1

   if ~isempty(sitecode) && exist('geo_polygons.mat','file') == 2  %look for geographic info data

      try
         v = load('geo_polygons.mat','-mat');
         polygons = v.polygons;
      catch
         polygons = [];
      end

      if ~isempty(polygons)

         if ischar(sitecode)
            sitecode = cellstr(sitecode);  %convert string to cell array to avoid syntax errors
         elseif ~iscell(sitecode)  %lookup codes based on site numbers
            sitenum = sitecode;
            sitecode = [];
            for n = 1:length(sitenum)
               I = find([polygons.SiteNumber]==sitenum(n));
               if ~isempty(I)
                  sitecode = [sitecode ; {polygons(I(1)).SiteCode}];
               end
            end
         end

         %initialize metadata strings
         loc = '';
         bounds = '';
         phys = '';
         land = '';
         hyd = '';
         topo = '';
         geol = '';
         veg = '';

         for n = 1:length(sitecode)

            I = find(strcmp({polygons.SiteCode},sitecode{n}));

            if ~isempty(I)

               sitestr = ['|',polygons(I).SiteCode,' -- '];

               %format bounding box/point location coordinates
               if polygons(I).WBoundLon ~= polygons(I).EBoundLon
                  bounds = [bounds, ...
                     sitestr, ...
                     sprintf('|  NW: %02d %02d %04.1f W, %02d %02d %04.1f N', ...
                     ddeg2dms(abs(polygons(I).WBoundLon)),ddeg2dms(polygons(I).NBoundLat)), ...
                     sprintf('|  NE: %02d %02d %04.1f W, %02d %02d %04.1f N', ...
                     ddeg2dms(abs(polygons(I).EBoundLon)),ddeg2dms(polygons(I).NBoundLat)), ...
                     sprintf('|  SE: %02d %02d %04.1f W, %02d %02d %04.1f N', ...
                     ddeg2dms(abs(polygons(I).EBoundLon)),ddeg2dms(polygons(I).SBoundLat)), ...
                     sprintf('|  SW: %02d %02d %04.1f W, %02d %02d %04.1f N', ...
                     ddeg2dms(abs(polygons(I).WBoundLon)),ddeg2dms(polygons(I).SBoundLat))];
               else
                  bounds = [bounds, ...
                     sitestr, ...
                     sprintf('|  %02d %02d %04.1f W, %02d %02d %04.1f N', ...
                     ddeg2dms(abs(polygons(I).WBoundLon)),ddeg2dms(polygons(I).NBoundLat))];
               end

               loc = [loc,sitestr,polygons(I).SiteName,', ',polygons(I).SiteLocation];
               phys = [phys,sitestr,polygons(I).Physiography];
               land = [land,sitestr,polygons(I).Landform];
               hyd = [hyd,sitestr,polygons(I).Hydrography];
               topo = [topo,sitestr,polygons(I).Topography];
               geol = [geol,sitestr,polygons(I).Geology];
               veg = [veg,sitestr,polygons(I).Vegetation];

            end

         end

         %assign metadata fields
         if ~isempty(loc)
            meta = [{'Site'},{'Location'},{loc}; ...
               {'Site'},{'Coordinates'},{bounds} ; ...
               {'Site'},{'Physiography'},{phys} ; ...
               {'Site'},{'Landform'},{land} ; ...
               {'Site'},{'Hydrography'},{hyd} ; ...
               {'Site'},{'Topography'},{topo} ; ...
               {'Site'},{'Geology'},{geol} ; ...
               {'Site'},{'Vegetation'},{veg}];
         end

      else
         msg = 'Site information file ''geo_polygons.mat'' is invalid';
      end

   else
      msg = 'Site information file ''geo_polygons.mat'' could not be loaded';
   end

else
   msg = 'insufficient arguments for function';
end
