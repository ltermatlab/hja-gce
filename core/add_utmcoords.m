function [s2,msg] = add_utmcoords(s,latcol,loncol,position,datum)
%Adds geographic coordinates in UTM units to a GCE Data Structure containing coordinates in lat/lon (decimal degrees)
%
%syntax: [s2,msg] = add_utmcoords(s,latcol,loncol,position,datum)
%
%inputs:
%  s = GCE Data Structure
%  latcol = column number or name containing latitudes in decimal degrees
%  loncol = column number or name containing longitudes in decimal degrees
%  position = starting position for insertion of the columns
%    [] = after last lat/lon parameter (default)
%    0 = beginning of dataset
%    >0 insert after specified column
%  datum = reference ellipsoid datum to use:
%     'WGS84' (default)
%     'WGS72'
%     'WGS66'
%     'WGS60'
%     'NAD83'
%     'NAD27'
%     'CLARK1866'
%     'CLARK1800'
%
%outputs:
%  s2 = output structure with inserted columns;
%  msg = text of any error message
%
%
%(c)2002-2009 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 18-Feb-2009

%init output
s2 = [];
msg = '';

if nargin >= 1

   %supply defaults for omitted arguments
   if exist('datum','var') ~= 1
      datum = 'WGS84';
   end

   if exist('position','var') ~= 1
      position = [];
   end

   if gce_valid(s,'data')

      %assign empty array if lat/lon omitted to force column lookup
      if exist('latcol','var') ~= 1
         latcol = [];
      end
      if exist('loncol','var') ~= 1
         loncol = [];
      end

      %look up latitude field by name and metadata if omitted
      if isempty(latcol)
         Icol = find(strncmpi(s.name,'lat',3) & strcmpi(s.variabletype,'coord') & strncmpi(s.units,'deg',3));
         if length(Icol) == 1
            if strcmp(s.datatype{Icol},'f')
               latcol = Icol;
            end
         end
      elseif ischar(latcol)  %look up column from name
         latcol = name2col(s,latcol);
      end

      %look up longitude field by name and metadata if omitted
      if isempty(loncol)
         Icol = find(strncmpi(s.name,'lon',3) & strcmpi(s.variabletype,'coord') & strncmpi(s.units,'deg',3));
         if length(Icol) == 1
            if strcmp(s.datatype{Icol},'f')
               loncol = Icol;
            end
         end
      elseif ischar(loncol)  %look up column from name
         loncol = name2col(s,loncol);
      end

      %check for lat/lon data, calculate utm
      if ~isempty(latcol) && ~isempty(loncol) 
         
         if isempty(position)  %apply default position if not assigned during column lookup
            position = max(loncol,latcol);  %add after lat/lon columns
         elseif position > length(s.name)
            position = length(s.name);
         end

         if strncmpi(s.units{latcol},'deg',3) || strncmpi(s.units{loncol},'deg',3)

            %extract data arrays
            lon = extract(s,loncol);
            lat = extract(s,latcol);

            %calculate utm
            [utm_zone,utm_e,utm_n,utm_hem,msg] = deg2utm(lon,lat,datum);

            if ~isempty(utm_zone)

               %generate zone + hemisphere
               if length(unique(utm_zone)) == 1 && length(unique(utm_hem)) == 1
                  utm_zone_hem = repmat({[int2str(utm_zone(1)),utm_hem(1)]},length(utm_zone),1);  %single zone and hemisphere - use fast replication method
               else
                  utm_zone_hem = cellstr([int2str(utm_zone),utm_hem]);  %use slow string concat method
               end
               
               %define arrays of values, column descriptors to add to structure
               vals = {utm_e,utm_n,utm_zone_hem};
               colnames = {'UTM_Easting','UTM_Northing','UTM_Zone'};
               units = {'m','m','none'};
               desc = {['UTM easting (distance east of the western UTM zone boundary) calculated from Longitude using ',datum,' datum'], ...
                     ['UTM northing (distance north or south from the equator) calculated from Latitude using ',datum,' datum'], ...
                     'UTM zone number and hemisphere'};
               dtype = {'f','f','s'};
               vtype = {'coord','coord','coord'};
               ntype = {'continuous','continuous','none'};
               prec = [2,2,0];
               crit = {'x<0=''I''','x<0=''I''',''};

               %init output structure, add history entry
               s2 = s;
               s2.history = [s2.history ; ...
                     {datestr(now)},{['calculated UTM coordinates from columns ',s.name{loncol},' and ',s.name{latcol},' using ',datum, ...
                           ' datum (''add_utmcoords'')']}];
               
               %add derived columns to output structure
               for n = 1:length(colnames)
                  s2 = addcol(s2,vals{n},colnames{n},units{n},desc{n},dtype{n},vtype{n},ntype{n},prec(n),crit{n},position+n);
               end
               
            else
               msg = ['errors occurred calculating UTM coordinates: ',msg];   
            end

         else
            msg = 'latitude and longitude columns must in be degrees';
         end

      else
         msg = 'latitude and longitude data columns could not be identified or are not in compatible units';
      end

   else
      msg = 'invalid GCE Data Structure';
   end

else
   msg = 'insufficient input arguments for function';
end
