function sites = bbox2sites(bbox,matchtype)
%Returns a list of GCE study sites with bounding polygons intersecting a specified bounding box
%(Note: requires the file 'geo_polygons.mat')
%
%syntax: sites = bbox2sites(bbox,matchtype)
%
%input:
%  bbox = [wlon, elon, slat, nlat] in decimal degrees, where:
%    wlon = west longitude (-180 to 180)
%    elon = east longitdue (-180 to 180)
%    slat = south latitude (-90 to 90)
%    nlat = north latitude (-90 to 90)
%    (note: any NaN values will be interpreted as +/-inf, as appropriate)
%  matchtype = match type option:
%    'rectangle' = match sites based on overlap between bbox and site rectangular bounding box coordinates
%    'polygon' = match sites by testing for overlap of bbox and site polygons by generating a 25x25 matrix
%       of coordinates across bbox (default unless bbox contains NaN values)
%
%output:
%  sites = cell array of GCE site codes
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
%last modified: 31-Aug-2011

sites = [];

if nargin >= 1 & exist('geo_polygons.mat','file') == 2

   if length(bbox) == 4

      %load GCE site info structure
      vars = load('geo_polygons.mat','-mat');
      if isfield(vars,'polygons')
         polygons = vars.polygons;
      else
         polygons = [];
      end

      if ~isempty(polygons)

         %set default match type
         if exist('matchtype','var') ~= 1
            matchtype = 'polygon';
         end
         if sum(isnan(bbox)) > 0
            matchtype = 'rectangle';  %force rectangle match if any infinite bounds
         end

         %supply infinite limits for omitted bounds
         if isnan(bbox(1)); bbox(1) = -inf; end
         if isnan(bbox(2)); bbox(2) = inf; end
         if isnan(bbox(3)); bbox(3) = -inf; end
         if isnan(bbox(4)); bbox(4) = inf; end

         %get bounding box arrays for all GCE sites
         wlon = [polygons.WBoundLon]';
         elon = [polygons.EBoundLon]';
         slat = [polygons.SBoundLat]';
         nlat = [polygons.NBoundLat]';

         %get index of overlapping sites based on bounding box rectangle comparisons first
         %logic: (site W boundary within bbox E-W OR site E boundary within bbox E-W OR site E-W completely overlaps bbox E-W) AND
         %       (site S boundary within bbox N-S OR site N boundary within bbox N-S OR site N-S completely overlaps bbox N-S)
         Imatch = find(((wlon >= bbox(1) & wlon <= bbox(2)) | ...
            (elon >= bbox(1) & elon <= bbox(2)) | ...
            (wlon <= bbox(1) & elon >= bbox(2))) & ...
            ((slat >= bbox(3) & slat <= bbox(4)) | ...
            (nlat >= bbox(3) & nlat <= bbox(4)) | ...
            (slat <= bbox(3) & nlat >= bbox(4))));

         %generate site list using specified method
         if ~isempty(Imatch)

            if strcmp(matchtype,'polygon') %use polygon search method to eliminate false bounding box hits

               %check for coords withing polygons for each matched site
               for n = 1:length(Imatch)

                  idx = Imatch(n);  %buffer index of current site

                  %check for site completely within bbox - skip polygon test
                  if bbox(1) <= wlon(idx) & bbox(2) >= elon(idx) & bbox(3) <= slat(idx) & bbox(4) >= nlat(idx)

                     sites = [sites ; {polygons(idx).SiteCode}];

                  else  %perform polygon search

                     %lookup site polygon
                     poly = polygons(idx).Polygon;

                     %create optimized 25x25 coordinate search grid based on minimum bounding box overlap
                     [lon,lat] = meshgrid(linspace(max(bbox(1),wlon(idx)),min(bbox(2),elon(idx)),25), ...
                        linspace(max(bbox(3),slat(idx)),min(bbox(4),nlat(idx)),25)');

                     %perform polygon analysis for all matrix coords, with ~100m tolerance
                     Ipoly = find(insidepoly(lon(:),lat(:),poly(:,1),poly(:,2),.0001));
                     if ~isempty(Ipoly)
                        sites = [sites ; {polygons(idx).SiteCode}];  %1 or more test polygons within site polygon - add to list
                     end

                  end
               end

            else  %just return bounding box results
               sites = {polygons(Imatch).SiteCode}';
            end

         end

      end

   end

end