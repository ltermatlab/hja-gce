function [s2,msg] = add_stationcoords(s,coordtype,col)
%Adds geographic coordinate columns to a data structure by matching station or location codes to entries
%in the GCE geographic database (cached in file 'geo_locations.mat').
%
%Note that existing columns named 'Latitude' and 'Longitude' or 'UTM_Northing, 'UTM_Easting',
%'UTM_Zone' and 'UTM_Hemisphere' will be replaced with matched coordinates
%
%syntax: [s2,msg] = add_stationcoords(s,coordtype,col)
%
%inputs:
%  s = data structure to modify
%  coordtype = type of coordinate columns to add
%     'latlon' = latitude and longitude in decimal degrees (default)
%     'utm' = UTM easting and northing in m and UTM zone (WGS84 datum)
%  col = name or index of column containing station or location codes
%
%outputs:
%  s2 = modified structure
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
%last modified: 18-Nov-2011

s2 = [];
msg = '';

if nargin >= 1 && exist('geo_locations.mat','file') == 2

   if gce_valid(s,'data')

      if exist('coordtype','var') ~= 1
         coordtype = 'latlon';
      elseif ~strcmp(coordtype,'utm')
         coordtype = 'latlon';
      end

      if exist('col','var') ~= 1
         col = [];
      elseif ~isnumeric(col)
         col = name2col(s,col);
      end

      if isempty(col)
         Imatch = find((strcmpi(s.name,'station') | strcmpi(s.name,'location')) & ...
            strcmp(s.datatype,'s'));
         if ~isempty(Imatch)
            col = Imatch(1);
         end
      elseif ~strcmp(s.datatype{col},'s')
         col = [];
      end

      if ~isempty(col)

         v = load('geo_locations.mat');

         if isfield(v,'locations')

            %get locations, stations arrays
            locations = v.locations;
            stat = extract(s,col);

            %init runtime vars
            nrows = length(stat);
            Imatch = zeros(nrows,1);

            %extract station codes
            locs = {locations.Location};

            %build index of matching stations
            for n = 1:nrows
               Imatch0 = find(strcmpi(locs,stat{n}));
               if ~isempty(Imatch0)
                  Imatch(n) = Imatch0(1);
               end
            end

            %generate index of matched locations
            Ivalid = find(Imatch);

            if ~isempty(Ivalid)

               %init lon/lat arrays
               lon = repmat(NaN,nrows,1);
               lat = lon;
               lon(Ivalid) = [locations(Imatch(Ivalid)).Longitude];
               lat(Ivalid) = [locations(Imatch(Ivalid)).Latitude];

               %add coordinates in requested units, deleting existing coordinate columns
               if strcmp(coordtype,'latlon')
                  s2 = deletecols(s,{'Longitude','Latitude'});
                  col = name2col(s2,s.name{col});  %get updated column position
                  s2 = addcol(s2,lat,'Latitude','degrees','Geographic latitude in decimal degrees', ...
                     'f','coord','continuous',6,'x<-90=''I'';x>90=''I''',col+1);
                  s2 = addcol(s2,lon,'Longitude','degrees','Geographic longitude in decimal degrees', ...
                     'f','coord','continuous',6,'x<-180=''I'';x>180=''I''',col+1);
                  histstr = 'Longitude and Latitude';
               else  %utm
                  s2 = deletecols(s,{'UTM_Hemisphere','UTM_Zone','UTM_Northing','UTM_Easting'});
                  col = name2col(s2,s.name{col});  %get updated column position
                  [utm_z,utm_e,utm_n,hem] = deg2utm(lon,lat,'WGS84'); %reproject lat/lon to UTM WGS84
                  s2 = addcol(s,hem,'UTM_Hemisphere','none','Hemisphere','s','coord','none',0,'',col+1);
                  s2 = addcol(s2,utm_z,'UTM_Zone','none','UTM zone number','d','coord','discrete',0, ...
                     'x<1=''I'';x>60=''I''',col+1);
                  s2 = addcol(s2,utm_n,'UTM_Northing','m','UTM northing (m north from the equator) based on WGS84 datum', ...
                     'f','coord','continuous',2,'x<0=''Q''',col+1);
                  s2 = addcol(s2,utm_e,'UTM_Easting','m','UTM easting (m east of the western UTM zone boundary) based on WGS84 datum', ...
                     'f','coord','continuous',2,'x<0=''Q''',col+1);
                  histstr = 'UTM_Easting, UTM_Northing, UTM_Zone and UTM_Hemisphere';
               end

               s2.editdate = datestr(now);
               s2.history = [s.history ; {datestr(now)}, ...
                     {['added ',histstr,' columns by matching values in the ',s.name{col}, ...
                           ' column to entries in the GCE geographic database (''add_stationcoords'')']}];

            else
               msg = 'no matchings stations or locations were identified';
            end

         else
            msg = 'geographic database file ''geo_locations.mat'' is invalid';
         end

      else
         msg = 'station or location column was invalid or could not be determined';
      end

   else
      msg = 'invalid data structure';
   end

else

   if nargin <= 1
      msg = 'insufficient arguments for functions';
   else
      msg = 'required geographic database file ''geo_locations.mat'' could not be located';
   end

end