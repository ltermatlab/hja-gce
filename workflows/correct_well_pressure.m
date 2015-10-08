function [s2,msg] = correct_well_pressure(s,col_pressure,col_atm,colname,pressure_t0,calc_depth)
%Corrects groundwater well pressure for atmospheric pressure, optionally offset from pressure at time 0
%
%syntax: [s2,msg] = correct_well_pressure(s,col_pressure,col_atm,colname,pressure_t0,calc_depth)
%
%inputs:
%  s = data structure to update
%  col_pressure = name or index of groundwater pressure column (default = 'Pressure')
%  col_atm = name or index of atmospheric pressure column (default = 'Pressure_Atm', 
%     units must match col_pressure)
%  colname = column name for corrected pressure (default = 'Pressure_Corrected');
%  pressure_t0 = pressure at time 0 in units of col_pressure (default = 0 for no zero correction)
%  calc_depth = option to calculate depth (Depth_Corrected) from corrected pressure at latitude using UNESCO algorithms
%     0 = no
%     1 = yes (default unless column 'Depth_Corrected' already present)
%
%outputs:
%
%  s2 = updated structure
%  msg = text of any error message
%
%
%(c)2010 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
   
   %use defaults for omitted arguments
   if exist('col_pressure','var') ~= 1
      col_pressure = 'Pressure';
   end
   
   if exist('col_atm','var') ~= 1
      col_atm = 'Pressure_Atm';
   end
   
   if exist('colname','var') ~= 1
      colname = '';
   end
   if isempty(colname)
      colname = 'Pressure_Corrected';
   end
   
   if exist('pressure_t0','var') ~= 1
      pressure_t0 = 0;
   end
   
   if exist('calc_depth','var') ~= 1      
      %check for existing Depth column
      depcol = name2col(s,'Depth_Corrected');
      latcol = name2col(s,'Latitude');
      if isempty(depcol) && ~isempty(latcol)
         calc_depth = 1;
      else
         calc_depth = 0;
      end
   end
   
   %resolve column indices
   if ~isnumeric(col_pressure)
      col_pressure = name2col(s,col_pressure);
   end
   
   if ~isnumeric(col_atm)
      col_atm = name2col(s,col_atm);
   end
   
   if length(col_pressure) == 1 && length(col_atm) == 1
      
      press_units = s.units{col_pressure};
      
      %check units compatibility
      if strcmpi(press_units,s.units{col_atm})
         s2 = s;
      else  %attempt to harmonize units
         s_tmp = unit_convert(s,col_atm,press_units);
         if ~isempty(s_tmp)
            s2 = s_tmp;
         else
            s2 = [];            
         end
      end
         
      if ~isempty(s2)
         
         %generate conversion equation
         if pressure_t0 > 0
            eqn = [s.name{col_pressure},' - (',s.name{col_atm},' - ',num2str(pressure_t0),')'];
         else
            eqn = [s.name{col_pressure},' - ',s.name{col_atm}];
         end
       
         %generate column description, q/c criteria
         coldesc = ['Groundwater well pressure corrected for atmospheric pressure using the equation: ',eqn];
         colcrit = s.criteria{col_pressure};
        
         %add calculated column
         [s2,msg] = add_calcexpr(s2,eqn,colname,press_units,coldesc,col_pressure+1,0,colcrit);

         %get indices of depth and latitude columns
         depcol = name2col(s2,'Depth_Corrected');
         latcol = name2col(s2,'Latitude');
         
         %add depth column if specified
         if calc_depth == 1 && ~isempty(latcol)
            if ~isempty(depcol)
               s2 = deletecols(s2,'Depth_Corrected');  %delete existing depth column
            end
            s_tmp = unit_convert(s2,colname,'dbar');  %convert pressure to dbar for calculation
            press = extract(s_tmp,colname);
            lat = extract(s2,latcol);
            dep = depth(press,lat);
            pos = name2col(s2,colname);
            s2 = addcol(s2,dep,'Depth_Corrected','m', ...
               'Water depth calculated from corrected well pressure and geographic latitude using UNESCO algorithms', ...
               'f','calculation','continuous',3,'x<0=''Q''',pos(1)+1);
         end
         
         %refresh column indices for flag copying
         col_corr = name2col(s2,colname);
         col_pressure = name2col(s2,s.name{col_pressure});
         col_atm = name2col(s2,s.name{col_atm});
         col_dep = name2col(s2,'Depth_Corrected');
         
         %propagate flags
         if ~isempty(s2)
            [s2,msg] = copyflags(s2,[col_pressure,col_atm],col_corr);
            if ~isempty(col_dep)
               [s2,msg] = copyflags(s2,col_corr,col_dep);
            end
         end
         
      else
         msg = 'units of atmospheric pressure do not match well pressure and could not be converted';
      end
               
   else
      msg = 'well or atmospheric pressure columns were not identified or invalid';
   end
   
else
   if nargin < 1
      msg = 'insufficient arguments';
   else
      msg = 'invalid data structure';
   end
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
