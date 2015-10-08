function [s,msg] = locations2dataset(locations)
%Generates a data set in GCE data structure format from a geographic location structure
%
%syntax: [s,msg] = locations2dataset(locations)
%
%input:
%  locations = geographic structure (default = 'locations' in 'geo_locations.mat')
%
%output:
%  s = data structure
%  msg = text of any error message
%
%
%(c)2005-2010 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 16-Sep-2010

s = [];
msg = '';

if mlversion >= 6.5

   if exist('locations') ~= 1
      locations = [];
   end

   if isempty(locations) & exist('geo_locations.mat','file') == 2
      v = load('geo_locations.mat');
      if isfield(v,'locations')
         locations = v.locations;
      end
   end

   if ~isempty(locations)

      flds = {'Location','none','s','nominal','none',0 ; ...
            'Name','none','s','nominal','none',0 ; ...
            'TypeCode','none','s','nominal','none',0 ; ...
            'TypeName','none','s','nominal','none',0 ; ...
            'SiteCode','none','s','nominal','none',0 ; ...
            'SiteNumber','none','d','code','none',0 ; ...
            'Description','none','s','nominal','none',0 ; ...
            'TransectDistance','km','f','calculation','continuous',0 ; ...
            'Longitude','degrees','f','coord','continuous',5 ; ...
            'Latitude','degrees','f','coord','continuous',5 ; ...
            'UTM_zone','none','d','coord','discrete',0 ; ...
            'UTM_easting','m','f','coord','continuous',2 ; ...
            'UTM_northing','m','f','coord','continuous',2 ; ...
            'UTM_datum','none','s','coord','none',0 };

      s = newstruct;
      s = newtitle(s,['Geographic data set generated ',datestr(now,1)]);

      for n = 1:size(flds,1)
         if isfield(locations,flds{n,1})
            if strcmp(flds{n,3},'s')
               data = {locations.(flds{n,1})}';
            else
               data = [locations.(flds{n,1})]';
            end
            [s,msg] = addcol(s,data, ...
               flds{n,1},flds{n,2},flds{n,1},flds{n,3},flds{n,4},flds{n,5},flds{n,6},'',n);
            if isempty(s)
               break
            end
         end
      end

   else
      msg = 'no geographic location data was found';
   end

else
   msg = 'this function requires MATLAB 6.5 or higher';
end