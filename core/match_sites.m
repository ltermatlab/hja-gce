function [studysites,msg] = match_sites(lon,lat,sitetype,output)
%Matches GPS coordinates given by longitude and latitude to site polygons in 'geo_polygons.mat'
%using a polygon inclusion algorithm and returns a cell array of site codes
%
%syntax: [studysites,msg] = match_sites(lon,lat,sitetype,output)
%
%inputs:
%  lon = array of longitudes (decimal degrees)
%  lat = array of latitudes (decimal degrees)
%  sitetype = type of registered sites (polygons) to include in the search, e.g.
%    all = all sites in the database
%    transect = only include transects
%    marsh = only include marsh sites
%    land = only include land (terrestrial) sites
%    hammock = only include hammock sites
%  output = output option ('all' returns all matches, 'unique' returns unique site codes)
%
%output:
%  studysites = cell array of matching site code strings ('' = not matched)
%  msg = text of any error message
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

%init output
studysites = '';
msg = '';

%check for required numeric lon and lat
if nargin >= 2 && isnumeric(lon) && isnumeric(lat)

   %force column array format
   lon = lon(:);
   lat = lat(:);

   %check for matching dimensions
   if size(lon,2) == 1 && size(lat,2) == 1 && size(lon,1) == size(lat,1)

      %get index of non-NaN values
      Ivalid = find(~isnan(lon) & ~isnan(lat));

      %check for any valid coordinate pairs
      if ~isempty(Ivalid)

         %set default output option if omitted
         if exist('output','var') ~= 1
            output = 'all';
         elseif ~strcmp(output,'unique')
            output = 'all';
         end

         %set default sitetype option if omitted
         if exist('sitetype','var') ~= 1
            sitetype = 'all';
         end

         %init coordinate array
         polygons = [];

         %check for geographic database file in MATLAB path
         if exist('geo_polygons.mat','file') == 2

            %load geographic database
            try
               v = load('geo_polygons.mat');
            catch
               v = struct('null','');
            end

            %check for polygons variable
            if isfield(v,'polygons') && isstruct(v.polygons)

               %extract polygons variable
               polygons = v.polygons;

               %filter by site type if specified
               if ~strcmpi(sitetype,'all') && isfield(polygons,'SiteType')
                  Imatch = find(strcmpi(sitetype,{polygons.SiteType}));
                  if ~isempty(Imatch)
                     polygons = polygons(Imatch);
                  else
                     polygons = [];
                  end
               end

            end

         end

         %check for valid reference coordinates to check
         if ~isempty(polygons) && isfield(polygons,'Polygon') && isfield(polygons,'SiteCode')

            %limit coordinates to unique lat/lon pairs for efficiency
            [lonlat,Iunique,Iorig] = unique([lon(Ivalid),lat(Ivalid)],'rows');

            %set up lat/lon arrays for analysis
            lon2 = lonlat(:,1);
            lat2 = lonlat(:,2);
            len = length(lon2);
            Irem = (1:len)';  %init todo list
            Idone = zeros(len,1);  %init done list

            %suppress divide by zero warnings thrown by insidepoly in older MATLAB versions
            if mlversion < 7
               try
                  warning off MATLAB:divideByZero
               catch
                  warning off
               end
            end

            %loop through sites checking for coordinates within bounds
            for n = 1:length(polygons)

               poly = polygons(n).Polygon;  %retrieve bounding polygon from structure

               Imatch = find(insidepoly(lon2(Irem),lat2(Irem),poly(:,1),poly(:,2)));  %get index of coords within polygon

               if ~isempty(Imatch)

                  Idone(Irem(Imatch)) = n;  %update done list with polygon index number

                  Irem = find(Idone==0);  %update todo list
                  if isempty(Irem)
                     break  %kill loop if done
                  end

               end

            end

            %generate array of study site codes
            studysites = repmat({''},length(lon),1);  %init empty array
            I = find(Idone>0);  %get index of lat/lon pairs that matched
            for n = 1:length(I)
               Iptr = Iorig == I(n); %get pointer to original array position of valid lat/lon values based on unique index
               studysites(Ivalid(Iptr)) = {polygons(Idone(I(n))).SiteCode};  %copy matched site to matching lat/lon position
            end

            %get index of non-empty study site cells
            I = ~cellfun('isempty',studysites);
            if isempty(I)
               studysites = [];  %return empty matrix
               msg = 'no sites were matched for any coordinate';
            elseif strcmpi(output,'unique')
               studysites = unique(studysites(I));  %generate unique sites
            end

         else
            msg = 'no valid geographic coordinates to look up';
         end

      else
         msg = 'the geographic information file ''geo_polygons.mat'' is invalid or missing';
      end

   end

end
