function [s2,msg] = add_latloncoords(s,ecol,ncol,zcol,hcol,position,datum)
%Adds latitude and longitude coordinates (deg) to a GCE Data Structure containing geographic coordinates in UTM (m)
%
%syntax: [s2,msg] = add_latloncoords(s,easting_col,northing_col,zone_col,hem_col,position,datum)
%
%inputs:
%  s = GCE Data Structure
%  easting_col = name or column number containing UTM eastings in m (default = 'UTM_Easting')
%  northing_col = name or column number containing UTM northings in m (default = 'UTM_Northing')
%  zone_col = name or column number containing UTM zones (default = 'UTM_Zone')
%  hem_col = name or column number containing hemispheres (default = 'UTM_Hemisphere' or 'N' if not present)
%  position = starting position for insertion of the columns
%    [] = after last UTM parameter/default
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

      %init empty arrays for omitted utm columns to force lookup
      if exist('ecol','var') ~= 1
         ecol = [];
      end
      if exist('ncol','var') ~= 1
         ncol = [];
      end
      if exist('zcol','var') ~= 1
         zcol = [];
      end
      if exist('hcol','var') ~= 1
         hcol = [];
      end

      %look up easting field by name and metadata if omitted
      if isempty(ecol)
         Icol = find((strncmpi(s.name,'utm_east',8) | strcmpi(s.name,'easting')) & strcmpi(s.variabletype,'coord'));
         if length(Icol) == 1
            if strcmp(s.datatype{Icol},'f') && (strcmpi(s.units{Icol},'m') || strncmpi(s.units{Icol},'meter',5))
               ecol = Icol;
            end
         end
      elseif ischar(ecol)  %look up column from name
         ecol = name2col(s,ecol);
      end

      %look up northing field by name and metadata if omitted
      if isempty(ncol)
         Icol = find((strncmpi(s.name,'utm_north',9) | strcmpi(s.name,'northing')) & strcmpi(s.variabletype,'coord'));
         if length(Icol) == 1
            if strcmp(s.datatype{Icol},'f') && (strcmpi(s.units{Icol},'m') || strncmpi(s.units{Icol},'meter',5))
               ncol = Icol;
            end
         end
      elseif ischar(ncol)  %look up column from name
         ncol = name2col(s,ncol);
      end

      %look up zone field by name and metadata if omitted
      if isempty(zcol)
         Icol = find((strcmpi(s.name,'utm_zone') | strcmpi(s.name,'zone')) & strcmpi(s.variabletype,'coord'));
         if length(Icol) == 1
            if strcmp(s.datatype{Icol},'d') || strcmp(s.datatype{Icol},'s')
               zcol = Icol;
            end
         end
      elseif ischar(zcol)  %look up column from name
         zcol = name2col(s,zcol);
      end

      %look up hemisphere field by name and metadata if omitted
      if isempty(hcol)
         Icol = find((strncmpi(s.name,'utm_hem',7) | strcmpi(s.name,'hemisphere')) & strcmpi(s.variabletype,'coord'));
         if length(Icol) == 1
            if strcmp(s.datatype{Icol},'s')
               hcol = Icol;
            end
         end
      elseif ischar(hcol)  %look up column from name
         hcol = name2col(s,hcol);
      end

      %check for necessary data, calculate lat/lon
      if ~isempty(ecol) && ~isempty(ncol) && ~isempty(zcol)

         %apply default position if not assigned during column lookup
         if isempty(position)
            if ~isempty(hcol)
               position = max([ecol,ncol,zcol,hcol]);
            else
               position = max([ecol,ncol,zcol]);
            end
         elseif position > length(s.name)
            position = length(s.name);
         end

         %extract arrays from structure
         utm_e = extract(s,ecol);
         utm_n = extract(s,ncol);
         utm_z = extract(s,zcol);

         %extract hemisphere from zone or hemisphere column
         if ~isnumeric(utm_z)
            utm_h = char(regexprep(utm_z,'[ 0-9]',''));  %extract alphabetic portion of zone string
            try
               utm_z = fix(str2double(regexprep(utm_z,'[^0-9]','')));  %extract numeric portion of zone string as zone, convert to numeric
            catch
               utm_z = repmat(NaN,length(utm_e),1);
            end
         elseif ~isempty(hcol)
            utm_h = char(extract(s,hcol));
         else  %default to northern hemisphere if omitted
            utm_h = repmat('N',length(utm_e),1);
         end

         %calculate lon,lat
         [lon,lat,msg] = utm2deg(utm_z,utm_e,utm_n,utm_h,datum);

         if ~isempty(lon)
            
            %init output structure, add history entry
            s2 = s;
            s2.history = [s.history ; ...
                  {datestr(now)},{['calculated Latitude and Longitude from UTM coordinates in ',s.name{zcol},', ',s.name{ecol}, ...
                        ' and ',s.name{ncol},' using ',datum,' datum (''add_latloncoords'')']}];
            
            %build arrays of new values, column descriptors to add to output
            vals = {lat,lon};
            colnames = {'Latitude','Longitude'};
            units = {'degrees','degrees'};
            desc = {'Geographic latitude in decimal degrees', ...
                  'Geographic longitude in decimal degrees'};
            dtype = {'f','f'};
            vtype = {'coord','coord'};
            ntype = {'continuous','continuous'};
            prec = [6,6];
            crit = {'x<-90=''I'';x>90=''I''','x<-180=''I'';x>180=''I'''};
            
            %add derived columns to output structure
            for n = 1:length(colnames)
               s2 = addcol(s2,vals{n},colnames{n},units{n},desc{n},dtype{n},vtype{n},ntype{n},prec(n),crit{n},position+n);
            end
            
         else
            msg = ['errors occurred calculating latitude and longitude from UTM: ',msg];
         end

      else
         msg = 'UTM easting, northing and zone columns in appropriate units could not be identified';
      end

   else
      msg = 'invalid GCE Data Structure';
   end

else
   msg = 'insufficient input arguments for function';
end
