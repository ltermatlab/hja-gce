function [s2,msg] = calc_well_waterlevel(s,col_elevation,col_depth)
%Adds a calculated water level column to a well data set based on sensor elevation and sensor depth
%
%syntax: [s2,msg] = calc_well_waterlevel(s,col_elevation,col_depth)
%
%input:
%  s = data structure to update
%  col_elevation = name or index of column containing sensor elevation relative to NAVD88 datum
%     (default = 'Sensor_Elevation')
%  col_depth = name or index of column containing corrected water depth
%     (default = 'Depth_Corrected')
%
%output:
%  s2 = updated data structure
%  msg = text of any error message
%
%(c)2011 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 09-Aug-2011

s2 = [];
msg = '';

if nargin >= 1 && gce_valid(s,'data')
   
   %validate or look up depth column
   if exist('col_depth','var') ~= 1 || isempty(col_depth)
      col_depth = 'Depth_Corrected';
   end
   if ~isnumeric(col_depth)
      col_depth = name2col(s,col_depth);
   end
   
   %check for corrected pressure column, add depth if not present
   if isempty(col_depth)
      
      col_press = name2col(s,'Pressure_Corrected');  %get index of corrected pressure column

      if ~isempty(col_press)
      
         %get index of latitude column
         col_lat = name2col(s,'Latitude');
         
         %add depth column if latitude present
         if ~isempty(col_lat)
            
            %calculate depth using UNESCO algorithm
            s_tmp = unit_convert(s,col_press,'dbar');  %convert pressure to dbar for calculation
            press = extract(s_tmp,col_press);
            lat = extract(s_tmp,col_lat);
            dep = depth(press,lat);
            
            %add depth column to data set
            s = addcol(s,dep,'Depth_Corrected','m', ...
               'Water depth calculated from corrected well pressure and geographic latitude using UNESCO algorithms', ...
               'f','calculation','continuous',3,'x<0=''Q''',col_press+1);
            
            %copy pressure and latitude flags to Depth_Corrected
            s = copyflags(s,'Depth_Corrected',[col_press,col_lat]);
            
            %return position index
            col_depth = col_press+1;
            
         end
         
      end
      
   end
   
   %validate or look up sensor elevation column
   if exist('col_elevation','var') ~= 1 || isempty(col_elevation)
      col_elevation = 'Sensor_Elevation';
   end
   if ~isnumeric(col_elevation)
      col_elevation = name2col(s,col_elevation);
   end
   
   %check for matched columns
   if ~isempty(col_depth) && ~isempty(col_elevation)
      
      s2 = s;
      
      %convert units to m if necessary
      if ~strcmp(s2.units{col_depth},'m')
         s2 = unit_convert(s2,col_depth,'m');
      end
      if ~strcmp(s2.units{col_elevation},'m');
         s2 = unit_convert(s2,col_elevation,'m');
      end
      
      %check for existing Water_Level column and delete if present
      col_waterlevel = name2col(s2,'Water_Level');
      if ~isempty(col_waterlevel)
         s2 = deletecols(s2,col_waterlevel);
         colpos = col_waterlevel;  %use original column position for new column
      else
         colpos = col_depth + 1;  %add new column after depth
      end
      
      %add calculated water level column
      s2 = add_calcexpr(s2,'Sensor_Elevation + Depth_Corrected','Water_Level','m', ...
         'Water level relative to NAVD88 datum calculated from sensor elevation and corrected water depth above the sensor', ...
         colpos);
      
      %propagate flags from depth, sensor elevation to water level
      if ~isempty(s2)
         s2 = copyflags(s2,[col_depth,col_elevation],'Water_Level');
      end
      
   else
      msg = 'sensor elevation and/or depth column are missing or invalid';
   end
   
else
   msg = 'invalid GCE data structure';
end
return


function DEPTH = depth(P,LAT)
% DEPTH   Computes depth given the pressure at some latitude
%         D=DEPTH(P,LAT) gives the depth D (m) for a pressure P (dbars)
%         at some latitude LAT (degrees).
%
%         This probably works best in mid-latiude oceans, if anywhere!
%
%         Ref: Saunders, Fofonoff, Deep Sea Res., 23 (1976), 109-111
%

%Notes: RP (WHOI) 2/Dec/91
%         I copied this directly from the UNESCO algorithms

% CHECKVALUE: DEPTH = 9712.653 M FOR P=10000 DECIBARS, LATITUDE=30 DEG
%     ABOVE FOR STANDARD OCEAN: T=0 DEG. CELSUIS ; S=35 (IPSS-78)
      X = sin(LAT/57.29578);
%**************************
      X = X.*X;
% GR= GRAVITY VARIATION WITH LATITUDE: ANON (1970) BULLETIN GEODESIQUE
      GR = 9.780318*(1.0+(5.2788E-3+2.36E-5*X).*X) + 1.092E-6.*P;
      DEPTH = (((-1.82E-15*P+2.279E-10).*P-2.2512E-5).*P+9.72659).*P;
      DEPTH=DEPTH./GR;
return