function [s2,msg] = add_sitenames(s,locationcol,colname,colposition)
%Adds a column of site names to a data structure by matching location names to sites in 'geo_locations.mat'
%
%syntax: [s2,msg] = add_sitenames(s,locationcol,colname,colposition)
%
%input:
%  s = data structure to update
%  locationcol = name or index of a column containing location or station codes
%     (default = 'Location' or 'Station')
%  colname = name for the site column (default = 'Site')
%  colposition = position for the site column (default = before locationcol)
%
%output:
%  s2 = updated data structure
%  msg = text of any error message
%
%%(c)2011 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 24-Aug-2011

s2 = [];
msg = '';

if nargin >= 1 && gce_valid(s,'data')
   
   %check for geographic database file
   if exist('geo_locations.mat','file') == 2
      
      %validate location column
      if exist('locationcol','var') ~= 1
         locationcol = [];
      elseif ~isnumeric(locationcol)
         locationcol = name2col(s,locationcol);
      end
      
      %look up location column if not provided/invalid
      if isempty(locationcol)
         Imatch = find((strcmpi(s.name,'station') | strcmpi(s.name,'location')) & strcmp(s.datatype,'s'));
         if ~isempty(Imatch)
            locationcol = Imatch(1);
         end
      elseif ~strcmp(s.datatype{locationcol},'s')
         locationcol = [];  %reject numeric column
      end
      
      if ~isempty(locationcol)
         
         %supply defaults for omitted options
         if exist('colname','var') ~= 1
            colname = 'Site';
         end
         
         if exist('colposition','var') ~= 1
            colposition = locationcol;
         end
                  
         %load geographic database files, extract location and site code arrays
         v = load('geo_locations.mat');         
         if isfield(v,'locations')
            locations_all = {v.locations.Location}';
            sites_all = {v.locations.SiteCode}';
         else
            locations_all = [];            
            sites_all = [];
         end
         
         %extract locations from structure
         locations = extract(s,locationcol);

         if ~isempty(locations) && ~isempty(locations_all)
            
            %get unique list of location names and index of original positions for matches
            [locs,I,J] = unique(locations);
            
            %init sites column
            sites = repmat({''},length(locations),1);
            
            %loop through unique location codes, perform lookups
            for n = 1:length(locs)
               Imatch = find(strcmp(locs{n},locations_all));  %get index of matches
               if ~isempty(Imatch)
                  site = sites_all{Imatch(1)};  %get corresponding sitecode for matched location
                  sites(J==n) = {site};  %copy site code to sites array based on location index
               end
            end
            
            %add history entry for geographic lookup
            s2 = s;  %copy structure to output
            str_hist = ['matched geographic location names in column ',s.name{locationcol}, ...
               ' to registered locations in ''geo_locations.mat'' to generate column ',colname, ...
               ' containing corresponding sites/transects (''add_sitenames'')'];
            s2.history = [s.history ; {datestr(now)},{str_hist}];
            
            %add sites column to data set
            [s2,msg] = addcol(s2,sites,colname,'none',['Geographic site name based on matching location names in column ', ...
               s.name{locationcol},' to registered locations in a geographic database'],'s','nominal','none',0,'',colposition);
         
         else
            msg = 'locations could not be retrieved from ''geo_locations.mat'' or the specified column';
         end         
         
      end
      
   else
      msg = 'geographic database file ''geo_locations.mat'' was not found in the MATLAB path';
   end
   
else
   msg = 'a valid data structure is required';
end