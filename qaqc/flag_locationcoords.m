function Iflag = flag_locationcoords(loc,lon,lat,tol,caseoption,reffile)
%Returns an index of location codes with coordinates that differ by more the specified tolerance from reference coordinates
%
%syntax: Iflag = flag_locationcoords(location,longitude,latitude,tolerance,caseoption,ref_file)
%
%inputs:
%  location = cell array of location codes
%  longitude = array of longitudes (decimal degrees)
%  latitude = array of latitudes (decimal degrees)
%  tolerance = deviation tolerance in km (default = 0.5, minimum 0.001)
%  caseoption = case sensitivity option for location lookups
%     'sensitive' = case-sensitive lookup (default)
%     'insensitive' = not case-sensitive
%  ref_file = reference database filename (default = 'geo_locations.mat')
%     note: must contain a structure named 'locations' with fields 'Location', 'Longitude', 'Latitude'
%       and either be in the default MATLAB search path or include the full path
%
%outputs:
%  Iflag = logical index of locations with coordinates that differ by more the 'tolerance'
%     from reference coordinates
%
%
%(c)2002-2006 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project-2005 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 01-Mar-2008

Iflag = [];

if nargin >= 3

   %apply default tolerance if omitted
   if exist('tol','var') ~= 1
      tol = 0.5;
   elseif tol < 0.001
      tol = 0.001;  %override tolerance <1m
   end

   %apply default case-sensitivity option if omitted
   if exist('caseoption','var') ~= 1
      caseoption = 'sensitive';
   elseif ~strcmp(caseoption,'insensitive')
      caseoption = 'sensitive';
   end

   %apply default location database if omitted
   if exist('reffile','var') ~= 1
      reffile = 'geo_locations.mat';
   end

   %validate input
   if iscell(loc) & isnumeric(lon) & isnumeric(lat)

      if length(lon) == length(lat) & length(lon) == length(loc)

         %init reference vars
         loc0 = '';
         lon0 = [];
         lat0 = [];

         %load reference database
         if exist(reffile,'file') == 2
            try
               vars = load(reffile,'-mat');
            catch
               vars = struct('null','');
            end
            if isfield(vars,'locations')
               locations = vars.locations;
               if isstruct(locations)
                  if isfield(locations,'Location') & isfield(locations,'Longitude') & isfield(locations,'Latitude')
                     try
                        loc0 = {locations.Location}';
                        lon0 = [locations.Longitude]';
                        lat0 = [locations.Latitude]';
                     catch
                        loc0 = '';
                        lon0 = [];
                        lat0 = [];
                     end
                  end
               end
            end
         end

         %check for valid location and coordinate arrays from reference database
         if ~isempty(loc0) & ~isempty(lon0) & ~isempty(lat0)

            %get index of valid data to evaluate
            Ivalid = find(~cellfun('isempty',loc) & ~isnan(lon) & ~isnan(lat));

            if ~isempty(Ivalid)

               %init master match index
               len = length(Ivalid);
               Imatchall = zeros(len,1);

               %look up locations in database
               if strcmp(caseoption,'sensitive')
                  for n = 1:len
                     Imatch = find(strcmp(loc0,loc{Ivalid(n)}));
                     if ~isempty(Imatch)
                        Imatchall(n) = Imatch(1);
                     end
                  end
               else  %case insensitive lookups
                  for n = 1:len
                     Imatch = find(strcmpi(loc0,loc{Ivalid(n)}));
                     if ~isempty(Imatch)
                        Imatchall(n) = Imatch(1);
                     end
                  end
               end

               %get index of matched locations in reference database (index positions correspond to Ivalid positions
               %and index values are pointers to positions in reference database arrays)
               Ivalid2 = find(Imatchall);

               %check distance offsets for matched coordinates
               if ~isempty(Ivalid2)
                  c1 = [lon(Ivalid(Ivalid2)),lat(Ivalid(Ivalid2))];  %get lat/lon from original dataset arrays
                  c2 = [lon0(Imatchall(Ivalid2)),lat0(Imatchall(Ivalid2))];  %get lat/lon from reference data sets
                  d = sub_gpsdistk(c1,c2);  %get array of point-to-point distances between lat/lon pairs
                  Iflag = zeros(length(loc),1);  %init flag array
                  Iflag(Ivalid(Ivalid2(d>tol))) = 1;  %set flags for records exceeding tolerance, resolving to master selection index
                  Iflag = Iflag == 1;  %convert to logical array
               end

            end

         end

      end

   end

end


function d = sub_gpsdistk(gps1,gps2)
%Computes distance (in km) between GPS coordinates 'gps1' and 'gps2' using the
%cartographic formula for distance along great circle.  Arguments 'gps1' and 'gps2'
%are pairs of longitude/latitude values in degrees (individual coordinates or
%arrays of coordinates), and output is distance in km.
%
%syntax:  d = gpsdistk(gps1,gps2)
%
%
%(c)2002-2006 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
%
%contact:
%  Wade Sheldon
%  GCE-LTER Project
%  Department of Marine Sciences
%  University of Georgia
%  Athens, GA 30602-3636
%  sheldon@uga.edu
%
%modified 15-Nov-2005

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