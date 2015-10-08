function [s2,msg] = add_studysites(s,sitetype,colname,loncol,latcol)
%Adds a column of GCE site codes to a data structure by matching values in geographic coordinate columns
%to site polygons from the GCE geographic database tables (cached in 'gce_coordinates_all.mat').
%
%syntax: [s2,msg] = add_studysites(s,sitetype,colname,loncol,latcol)
%
%inputs:
%  s = structure to modify
%  sitetype = type of registered sites (polygons) to include in the search, e.g.
%     all = all sites in the database (default)
%     transect = only include transects
%     marsh = only include marsh sites
%     land = only include land (i.e. terrestrial) sites
%     hammock = only include hammock sites
%  colname = name for the new column (default = 'Site')
%  loncol = name or index of column containing longitude data (default = [] for auto-determined)
%  latcol = name or index of column containing latitude data (default = [] for auto-determined)
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
%last modified: 30-Aug-2011

%init output
s2 = [];
msg = '';

if nargin >= 1
   
   %default to all types if omitted
   if exist('sitetype','var') ~= 1
      sitetype = 'all';
   elseif isempty(sitetype)
      sitetype = 'all';
   end
   
   %default to 'Site' for column name if omitted
   if exist('colname','var') ~= 1
      colname = 'Site';
   end
   
   %default to coordinate column lookup if omitted
   if exist('loncol','var') ~= 1
      loncol = [];
   elseif ~isnumeric(loncol)  %look up column from name
      loncol = name2col(s,loncol);
   end
   
   if exist('latcol','var') ~= 1
      latcol = [];
   elseif ~isnumeric(latcol)  %look up column from name
      latcol = name2col(s,latcol);
   end
   
   %look up longitude column based on metadata if omitted or invalid
   if isempty(loncol)  %look up latitude field by name and metadata
      Icol = find(strncmpi(s.name,'lon',3) & strcmpi(s.variabletype,'coord') & strncmpi(s.units,'deg',3));
      if length(Icol) == 1
         if strcmp(s.datatype{Icol},'f')
            loncol = Icol;
         end
      end
   end
   
   %look up latitude column based on metadata if omitted or invalid
   if isempty(latcol)  %look up latitude field by name and metadata
      Icol = find(strncmpi(s.name,'lat',3) & strcmpi(s.variabletype,'coord') & strncmpi(s.units,'deg',3));
      if length(Icol) == 1
         if strcmp(s.datatype{Icol},'f')
            latcol = Icol;
         end
      end
   end
   
   lon = [];
   lat = [];
   coldesc = 'Site name determined by geographic lookup of location coordinates';
   
   %validate lat/lon
   if ~isempty(latcol) && ~isempty(loncol)  %validate lat/lon
      
      if strcmp(s.variabletype{latcol},'coord') && strcmp(s.variabletype{loncol},'coord') && ...
            strncmp(s.units{latcol},'deg',3) && strncmp(s.units{loncol},'deg',3)
         lon = extract(s,loncol);
         lat = extract(s,latcol);
         coldesc = ['Site name determined by geographic lookup of location coordinates in ',s.name{loncol}, ...
            ' and ',s.name{latcol}];
      else
         msg = 'latitude and longitude must be valid geographic data columns in degrees';
      end
      
   elseif isempty(latcol) && isempty(loncol) && ~isempty(find(strncmpi(s.name,'utm',3)))
      
      %try to calc lat/lon from utm using geographic reprojection function
      s_tmp = add_latloncoords(s);      
      if ~isempty(s_tmp)
         lon = extract(s_tmp,'Longitude');
         lat = extract(s_tmp,'Latitude');
      end
      Icol = find(strncmpi(s.name,'utm',3));
      loncol = max(Icol);  %get column position for last UTM component for calculating new colum position
      latcol = loncol;
      
   end
   
   %check for successful lon/lat lookup and extraction
   if ~isempty(lon) && ~isempty(lat)
      
      %call geographic lookup function with specified site type option, returning all matches
      sitecodes = match_sites(lon,lat,sitetype,'all');
      
      %check for return data
      if ~isempty(sitecodes) && length(sitecodes) == length(lon)
         
         %add Site column
         s2 = addcol(s, ...
            sitecodes, ...
            colname, ...
            'none', ...
            coldesc, ...
            's', ...
            'code', ...
            'none', ...
            0, ...
            '', ...
            max(loncol,latcol)+1);
         
         %generate history entry string
         if strcmpi(sitetype,'all')
            histstr = 'all sites';
         else
            histstr = [sitetype,' sites'];
         end
         
         %add history entry
         if ~isempty(s2)
            s2.editdate = datestr(now);
            s2.history = [s.history ; {datestr(now)}, ...
               {['added calculated Site column at position ',int2str(max(loncol,latcol)+1), ...
               ' based on matching geographic information in columns ',s.name{loncol}, ...
               ' and ',s.name{latcol},' to site bounding polygons for ',histstr,' in the ', ...
               'GCE geographic database (''add_studysites'')']}];
         end
         
      else         
         msg = 'failed to match any sites with the specified option';         
      end
      
   else      
      if isempty(msg)
         msg = 'compatible latitude and longitude columns could not be identified';
      end      
   end
   
else   
   msg = 'insufficient arguments for function';   
end