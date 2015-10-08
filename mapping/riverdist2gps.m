function [lon,lat] = riverdist2gps(distance,river,method)
%Returns geographic coordinates for transect distances along Thalweg lines for a specified river
%based on reference transect data in 'thalweg_ref.mat'
%
%syntax: [lon,lat] = riverdist2gps(dist,river,method)
%
%input:
%  distance = array of transect distances in km (required)
%  river = river Thalweg line to use (required)
%  method = interpolation method to use for matching coordinates
%    (see interp1.m; default = 'nearest' if omitted or if errors occur with alternative method)
%
%output:
%  lon = geographic longitude in decimal degrees
%  lat = geographic latitude in decimal degrees
%
%(c)2012 Wade M. Sheldon
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
%Dept. of Marine Sciences
%University of Georgia
%Athens, GA 30602
%email: sheldon@uga.edu
%
%last modified: 18-Apr-2012

%init output
lon = [];
lat = [];

%check for required arguments and presence of reference file
if nargin >= 2 && exist('thalweg_ref.mat','file') == 2
   
   if ~isempty(distance) && ~isempty(river)
      
      %set default method if omitted
      if exist('method','var') ~= 1
         method = 'nearest';
      end
      
      %load Thalweg reference data
      try
         v = load('thalweg_ref.mat');
      catch
         v = struct('null','');
      end
      
      %get array of Thalweg variables for matching to river
      rivers = fieldnames(v);
      
      %match river
      Iriver = find(strcmpi(river,rivers));
      
      %check for match
      if length(Iriver) == 1
         
         %extract Thalweg reference data array (lon,lat,distance)
         refdata = v.(rivers{Iriver});
         
         %get reference arrays as variables
         lon_ref = refdata(:,1);
         lat_ref = refdata(:,2);
         dist_ref = refdata(:,3);
         
         %get index of unique distances to prevent interp1 error
         [dist_ref,Iref] = unique(dist_ref);
         lon_ref = lon_ref(Iref);
         lat_ref = lat_ref(Iref);
         
         %init output arrays
         lon = ones(length(distance),1) .* NaN;
         lat = lon;
         
         %get index of valid dist
         Ivalid = find(~isnan(distance));

         if ~isempty(Ivalid)
      
            %match lon using interp1 with specified method
            try
               lon_match = interp1(dist_ref,lon_ref,distance(Ivalid),method);
            catch
               if ~strcmp('nearest',method)
                  lon_match = interp1(dist_ref,lon_ref,distance(Ivalid),'nearest');  %fall back to nearest method
               else
                  lon_match = ones(length(Ivalid),1) .* NaN;  %return all NaN on error
               end
            end
            
            %match lat using interp1 with specified method
            try
               lat_match = interp1(dist_ref,lat_ref,distance(Ivalid),method);
            catch
               if ~strcmp('nearest',method)
                  lat_match = interp1(dist_ref,lat_ref,distance(Ivalid),'nearest');  %fall back to nearest method
               else
                  lat_match = ones(length(Ivalid),1) .* NaN;  %return all NaN on error
               end
            end
            
            %add matched longitudes to output
            lon(Ivalid) = lon_match;
            
            %add matched latitudes to output
            lat(Ivalid) = lat_match;            
         
         end
         
      end      
      
   end
   
end