function [s2,msg] = add_riverdist_gps(s,river,distcol,coordtype)
%Adds geographic coordinate columns to a GCE Data Structure based on river distances
%matched to coordinates of Thalweg lines registered in 'thalweg_ref.mat'
%
%syntax: [s2,msg] = add_riverdist_gps(s,river,distcol,coordtype)
%
%inputs:
%  s = data structure to modify (required)
%  river = river transect in 'thalweg_ref.mat' to match (required)
%  distcol = name or index of column containing transect distances in km
%    (default = 'Distance' or 'Transect_Distance' column in units 'km')
%  coordtype = geographic coordinate type to calculate:
%     'latlon' = latitude and longitude (default)
%     'utm' = UTM in WGS84 datum
%
%outputs:
%  s2 = modified structure
%  msg = text of any error messages
%
%
%(c)2012 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 18-Apr-2012

%init output
s2 = [];
msg = '';

%check for required argument and required function mfile
if nargin >= 2 && (exist('riverdist2gps','file') == 2 || exist('riverdist2gps','file') == 6)
   
   %check for valid data structure
   if gce_valid(s,'data') && ~isempty(river)
      
      %validate coordtype
      if exist('coordtype','var') ~= 1
         coordtype = 'latlon';
      elseif ~strcmpi('utm',coordtype)
         coordtype = 'latlon';
      end
      
      %validate distcol argument
      if exist('distcol','var') ~= 1
         distcol = [];
      elseif ~isnumeric(distcol)
         distcol = name2col(s,distcol);  %resolve column name to index
      elseif ~isempty(distcol) && (distcol <= 0 || distcol > length(s.name))
         distcol = [];
      end
      
      %look up distance column if omitted/invalid
      if isempty(distcol)
         distcol = find((strcmpi('distance',s.name) | strncmpi('transect_dist',s.name,13)) & ...
            (strcmpi('km',s.units) | strcmpi('kilometers',s.units)) & ~strcmp(s.datatype,'s'));
         if ~isempty(distcol)
            distcol = distcol(1);
         end
      end
      
      %check for matched column
      if length(distcol) == 1
         
         %validate units
         distunits = s.units{distcol};
         
         %convert units to km if necessary
         if inlist(distunits,'km,kilometer,kilometers','insensitive')
            dist = extract(s,distcol);
         else
            s_tmp = unit_convert(s,distcol,'km');
            if ~isempty(s_tmp)
               dist = extract(s_tmp,distcol);
            else
               dist = [];
            end
         end
         
         %check for valid distances
         if ~isempty(dist) && sum(~isnan(dist)) > 0
                        
            %call riverdist2gps to get coords in lat/lon using pchip interpolation method
            [lon,lat] = riverdist2gps(dist,river,'pchip');
            
            %check for valid coordinates
            if ~isempty(lon) && ~isempty(lat)
               Ivalid = find(~isnan(lon) & ~isnan(lat));
            else
               Ivalid = [];
            end
            
            %check for valid coordinate matches
            if ~isempty(Ivalid)
               
               %copy input structure to output
               s2 = s;
               
               %add coordinate columns
               if strcmpi('utm',coordtype)
                  
                  %reproject lat/lon to UTM WGS84
                  [utm_z,utm_e,utm_n,hem] = deg2utm(lon,lat,'WGS84');
                  
                  %add columns in reverse order
                  s2 = addcol(s,hem,'UTM_Hemisphere','none','Hemisphere','s','coord','none',0,'',distcol+1);
                  
                  s2 = addcol(s2,utm_z,'UTM_Zone','none','UTM zone number','d','coord','discrete',0, ...
                     'x<1=''I'';x>60=''I''',distcol+1);
                  
                  s2 = addcol(s2,utm_n,'UTM_Northing','m','UTM northing (m north from the equator) based on WGS84 datum', ...
                     'f','coord','continuous',2,'x<0=''Q''',distcol+1);
                  
                  s2 = addcol(s2,utm_e,'UTM_Easting','m','UTM easting (m east of the western UTM zone boundary) based on WGS84 datum', ...
                     'f','coord','continuous',2,'x<0=''Q''',distcol+1);
                  
                  %generate history entry
                  histstr = 'UTM_Easting, UTM_Northing, UTM_Zone and UTM_Hemisphere';
                  
               else  %latlon
                  
                  %add columns in reverse order
                  s2 = addcol(s2,lat,'Latitude','degrees','Geographic latitude in decimal degrees', ...
                     'f','coord','continuous',6,'x<-90=''I'';x>90=''I''',distcol+1);
                  
                  s2 = addcol(s2,lon,'Longitude','degrees','Geographic longitude in decimal degrees', ...
                     'f','coord','continuous',6,'x<-180=''I'';x>180=''I''',distcol+1);
                  
                  %generate history entry
                  histstr = 'Longitude and Latitude';
                  
               end
               
               %check for successful column addition
               if ~isempty(s2)
                  
                  %update structure processing history
                  s2.editdate = datestr(now);
                  
                  s2.history = [s.history ; {datestr(now)}, ...
                     {['added ',histstr,' columns by matching distance values in the ',s.name{distcol}, ...
                     ' column to river transect distance reference data in ''thalweg_ref.mat'' (''add_stationcoords'')']}];
                  
               else
                  msg = 'an error occurred looking up geographic coordinates';
               end
               
            else
               msg = 'no distances were matched for the specified river transect';
            end
            
         else
            msg = 'distance values are invalid or in incompatible units';
         end
         
      else
         msg = 'distance column could not be determined based on attribute descriptors';
      end
      
   else
      msg = 'invalid data structure or river transect';
   end
   
else
   if nargin < 2
      msg = 'data structure and transect are required';
   else
      msg = 'the function ''riverdist2gps.m'' was not found in the search path';
   end
end