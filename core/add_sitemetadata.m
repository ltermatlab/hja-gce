function [s2,msg] = add_sitemetadata(s,sitecol,siteprefix,autopolygons)
%Adds or updates site and location metadata based on site, station or location codes or geographic coordinates
%matched to polygon and point location metadata records stored in 'geo_polygons.mat' and 'geo_locations.mat'
%
%Usage Notes:
%1) if geographic coordinate columns are specified, site assignments will be made
%   for each coordinate based on position within bounding polygons in 'geo_polygons.mat'
%   and metadata will be returned for all unique site codes represented
%2) if no sites or locations are matched, the original structure will be return unmodified
%   and 'msg' will contain a warning message
%
%syntax: [s2,msg] = add_sitemetadata(s,cols,siteprefix,autopolygons)
%
%inputs:
%  s = data structure to update
%  cols = name or index of site/transect/location/station columns or geographic coordinate columns
%    notes: 1) if 2 numeric columns are specified, longitude and latitude geographic coordinate columns are assumed
%           2) if 1 or more string columns are specified, names will be checked against sites in
%              'geo_polygons.mat' first, then locations in 'geo_locations.mat'
%           3) if cols is omitted, columns will be selected based on name according to the following precedence:
%              Site, Transect, Location, Station, Latitude & Longitude
%  siteprefix = prefix to add to numeric site values prior to performing geographic lookups (default = 'GCE')
%  autopolygons = option to automatically document bounding polygons when point locations are matched
%     0 = no
%     1 = yes (default)
%
%outputs:
%  s2 = ammended data structure
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

s2 = [];
msg = '';

if nargin >= 1
   
   if gce_valid(s,'data')
      
      %copy input structure to output
      s2 = s;
      
      %supply default for sitecol if omitted, or look up column index
      if exist('sitecol','var') ~= 1
         sitecol = [];
      elseif ~isnumeric(sitecol)
         sitecol = name2col(s,sitecol);
      end
      
      if exist('siteprefix','var') ~= 1
         siteprefix = 'GCE';
      end
      
      %set auto lookup flag
      if isempty(sitecol)
         autosites = 1;
      else
         autosites = 0;
      end
      
      %set default autopolygons option
      if exist('autopolygons','var') ~= 1
         autopolygons = 1;
      end
      
      %automatic assignment of site column (look for site or transect column)
      if autosites == 1
         Icol = find(strcmpi(s.name,'site'));
         if isempty(Icol)
            Icol = find(strcmpi(s.name,'transect'));
         end
         if ~isempty(Icol)
            sitecol = Icol(1);  %use first matched column named 'site' or 'transect'
         end
      end
      
      %look for location or station columns
      if autosites == 1
         Icol = find(strcmpi(s.name,'location') | strcmpi(s.name,'station'));
         if ~isempty(Icol)
            sitecol = [sitecol,Icol(1)];  %add matched column to existing sites
         end
      end
      
      %look for lat/lon columns if no sites matched based on name lookups or user specification
      if isempty(sitecol)
         Ilon = find(strncmpi(s.name,'lon',3) & strcmp(s.variabletype,'coord') & ...
            strncmpi(s.units,'deg',3) & ~strcmp(s.datatype,'s'));
         Ilat = find(strncmpi(s.name,'lat',3) & strcmp(s.variabletype,'coord') & ...
            strncmpi(s.units,'deg',3) & ~strcmp(s.datatype,'s'));
         if length(Ilon) == 1 && length(Ilat) == 1
            sitecol = [Ilon,Ilat];
         end
      end
      
      if ~isempty(sitecol)
         
         meta = [];  %init metadata array
         str_hist = 'added geographic metadata based on matching ';  %init history string
         
         if length(sitecol) == 1  %assume site/station code list if a single column index is specified
            
            sitecodes = unique(extract(s,sitecol));
            if isnumeric(sitecodes)
               str = trimstr(cellstr(num2str(sitecodes)));
               sitecodes = concatcellcols([repmat({siteprefix},length(sitecodes),1),str],'');
            end
            
            meta = lookup_sitemetadata(sitecodes);
            
            if ~isempty(meta)
               str_hist = [str_hist,'values in column ',s.name{sitecol}, ...
                  ' to site and transect names registered in ''geo_polygons.mat'''];
            elseif autopolygons == 1
               [meta,msg0,polygons] = lookup_stationmeta(sitecodes);  %get station metadata plus polygons array
               meta0 = lookup_sitemetadata(polygons);  %get metadata for matched polygons
               if ~isempty(meta0)
                  for n = 1:size(meta,1)
                     Ifld = find(strcmp(meta{n,2},meta0(:,2)));
                     if ~isempty(Ifld)
                        meta{n,3} = [meta0{Ifld,3},meta{n,3}];  %pre-pend metadata for sites
                     end
                  end
               end
               str_hist = [str_hist,'values in column ',s.name{sitecol}, ...
                  ' to location and station names registered in ''geo_locations.mat'''];
            else
               meta = lookup_stationmeta(sitecodes);
               str_hist = [str_hist,'values in column ',s.name{sitecol}, ...
                  ' to location and station names registered in ''geo_locations.mat'''];
            end
            
         elseif length(sitecol) >= 2
            
            %get data type for columns
            dtype = get_type(s,'datatype',sitecol);
            vtype = get_type(s,'variabletype',sitecol);
            
            %check for 2 floating-point geographic columns
            if length(sitecol) == 2 && strcmp(dtype{1},'f') == 1 && strcmp(dtype{2},'f') == 1 && ...
                  strcmp(vtype{1},'coord') && strcmp(vtype{2},'coord')
               
               %get lat/lon
               lon = extract(s,sitecol(1));
               lat = extract(s,sitecol(2));
               
               if ~isempty(lon) && ~isempty(lat) && isnumeric(lon) && isnumeric(lat)
                  
                  %verify lat/lon to check for flipped coordinates
                  if max(abs(no_nan(lat))) > 90
                     tmp = lon;
                     lon = lat;
                     lat = tmp;
                  end
                  
                  %perform lookups
                  sitecodes = match_sites(lon,lat,'all','unique'); %get unique lat/lon combinations to speed lookups
                  meta = lookup_sitemetadata(sitecodes);
                  str_hist = [str_hist,'geographic coordinates in columns ',cell2commas(s.name(sitecol),1), ...
                     ' to sites registered in ''geo_polygons.mat'''];
                  
               end
               
            else  %multiple site/location codes
               
               %init array of matched polygons
               allsites = [];
               
               %loop through columns, accumulating all unique site/station codes
               for n = 1:length(sitecol)
                  sitecodes = extract(s,sitecol(n));
                  if isnumeric(sitecodes)
                     %convert to string and add site prefix if numeric site code
                     str = trimstr(cellstr(num2str(sitecodes)));
                     sitecodes = concatcellcols([repmat({siteprefix},length(sitecodes),1),str],'');
                  end
                  allsites = unique([allsites ; unique(sitecodes)]);
               end
               
               if ~isempty(allsites)
                  
                  %perform location/station match
                  [meta_stations,msg0,polygons] = lookup_stationmeta(allsites);
                  
                  %add matched polygons to allsites array to ensure included
                  if ~isempty(polygons)
                     allsites = unique([allsites ; polygons]);
                  end
                  
                  %perform site/transect match
                  meta_sites = lookup_sitemetadata(allsites);
                  
                  %concatenate metadata
                  if ~isempty(meta_sites) || ~isempty(meta_stations)
                     if isempty(meta_sites)
                        meta = meta_stations;
                     else
                        meta = meta_sites;
                        if ~isempty(meta_stations)
                           meta = [meta(:,1) meta(:,2), concatcellcols([meta(:,3) meta_stations(:,3)],'|')];
                        end
                     end
                  else
                     meta = [];
                  end
                  
                  %generate history entry
                  str_hist = [str_hist,'values in columns ',cell2commas(s.name(sitecol),1), ...
                     ' to site and transect names registered in ''geo_polygons.mat'' and location and station ', ...
                     'names registered in ''geo_locations.mat'''];
                  
               end
               
            end
            
         end
         
         %check for successful metadata addition, add history entry and incorporate new metadata
         if ~isempty(meta)
            str_hist = [str_hist,' (''add_sitemetadata'')'];  %add function tract to history entry
            s2.history = [s2.history ; {datestr(now)},{str_hist}];  %update history entry
            s2 = addmeta(s2,meta,0,'add_sitemetadata');  %incorporate new geographic metadata
         else
            msg = 'metadata lookup returned no results - data structure not updated';
         end
         
      else
         msg = 'could not identify valid site, location, station or geographic coordinate columns';
      end
      
   else
      msg = 'invalid data structure';
   end
   
else
   msg = 'insufficient arguments for function';
end