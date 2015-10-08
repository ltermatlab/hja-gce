function [lon,lat,loncol2,latcol2] = lookup_coords(s,loncol,latcol)
%Looks up geographic coordinates in a GCE Data structure and returns arrays on longitude and latitude in decimal degrees
%
%syntax: [lon,lat,loncol,latcol] = lookup_coords(s,loncol,latcol)
%
%inputs:
%  s = data structure to evaluate
%  loncol = longitude column (default = first column with name 'lon*', datatype 'f' and variabletype 'coord'
%    or reprojected from column with name 'utm_east*')
%  latcol = longitude column (default = first column with name 'lat*', datatype 'f' and variabletype 'coord'
%    or reprojected from column with name 'utm_north*')
%
%outputs:
%  lon = longitude in decimal degrees (-180 to 180)
%  lat = latitude in decimal degrees (-90 to 90)
%
%
%(c)2002-2006 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 25-Mar-2008

lon = [];
lat = [];
loncol2 = [];
latcol2 = [];

if nargin >= 1
   
   if gce_valid(s,'data')
      
      if exist('loncol','var') ~= 1
         loncol = [];
      end
      
      if exist('latcol','var') ~= 1
         latcol = [];
      end      
      
      if isempty(loncol)  %look up latitude field by name and metadata
         Icol = find(strncmpi(s.name,'lon',3) & strcmpi(s.variabletype,'coord'));
         if length(Icol) == 1
            if strcmp(s.datatype{Icol},'f') & ~isempty(strfind(lower(s.units{Icol}),'deg'))
               loncol = Icol;
            end
         end
      elseif isstr(loncol)  %look up column from name
         loncol = name2col(s,loncol);
      end
      
      if isempty(latcol)  %look up latitude field by name and metadata
         Icol = find(strncmp(lower(s.name),'lat',3) & strcmp(lower(s.variabletype),'coord'));
         if length(Icol) == 1
            if strcmp(s.datatype{Icol},'f') & ~isempty(strfind(lower(s.units{Icol}),'deg'))
               latcol = Icol;
            end
         end
      elseif isstr(latcol)  %look up column from name
         latcol = name2col(s,latcol);
      end
      
      if ~isempty(latcol) & ~isempty(loncol)  %validate lat/lon
         
         if strcmp(s.variabletype{latcol},'coord') & strcmp(s.variabletype{loncol},'coord') & ...
               ~isempty(strfind(lower(s.units{latcol}),'deg')) & ~isempty(strfind(lower(s.units{loncol}),'deg'))
            lon = extract(s,loncol);
            lat = extract(s,latcol);
         else
            msg = 'latitude and longitude must be valid geographic data columns in degrees';
         end
         
      elseif isempty(latcol) & isempty(loncol) & length(find(strncmp(lower(s.name),'utm',3))) > 0
         
         %try to calc lat/lon from utm using external function
         s_tmp = add_latloncoords(s);
         
         if ~isempty(s_tmp)
            loncol = name2col(s_tmp,'Longitude');
            latcol = name2col(s_tmp,'Latitude');
            lon = extract(s_tmp,loncol);
            lat = extract(s_tmp,latcol);
         end
         
      end
      
      %copy column indices to output
      loncol2 = loncol;
      latcol2 = latcol;
            
   end
   
end