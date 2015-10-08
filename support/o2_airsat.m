function [o2_sat,msg] = o2_airsat(T,S,units)
%Calculates dissolved oxygen saturation as a function of temperature and salinity at sea-level
%
%syntax: [o2_sat,msg] = o2_saturation(T,S,units)
%
%inputs:
%  T = water temperature (°C)
%  S = water salinity (PSU)
%  units = concentration units of o2_conc:
%    'mg/L' (default)
%    'ml/L'
%
%outputs:
%  o2_sat = dissolved oxygen concentration at saturation
%  msg = text of any error message
%
%notes:
%  1) the algorithm in based on: Garcia and Gordon (1992) "Oxygen solubility in seawater: Better fitting equations", 
%     Limnology & Oceanography, vol 37(6), p1307-1312.
%  2) calculations are only valid for Pressure = 1 atmosphere, and should not be used for water at elevations above sea-level!
%  3) see Sea-Bird Electronics, Inc. Application Note 64 (February 2011) for more information
%     (http://www.seabird.com/application_notes/AN64.htm)
%  
%
%(c)2002-2012 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 10-Oct-2012

%init output variables
o2_sat = [];
msg = '';

%check for required arguments
if nargin >= 2
   
   %set default units if omitted
   if exist('units','var') ~= 1
      units = 'mg/l';
   end
   
   %init conversion factor based on units
   cf = [];
   if strcmpi(units,'mg/l')
      cf = 1.42903;
   elseif strcmpi(units,'ml/l')
      cf = 1;
   end
   
   %check for unsupported units
   if ~isempty(cf)
      
      %force column array orientation to prevent matrix math errors
      T = T(:);
      S = S(:);
      
      %check for matching T, S and o2_conc arrays
      if length(T) == length(S)
         
         %define constants from Garcia and Gordon (1992)
         A0 = 2.00907;
         A1 = 3.22014;
         A2 = 4.0501;
         A3 = 4.94457;
         A4 = -0.256847;
         A5 = 3.88767;
         B0 = -0.00624523;
         B1 = -0.00737614;
         B2 = -0.010341;
         B3 = -0.00817083;
         C0 = -0.000000488682;
         
         %calculate standard temp
         Ts = log((298.15 - T)./(273.15 + T));
         
         try
            
            %calculate O2 saturation conc in ml/l
            o2sat_ml = exp(A0 + A1*Ts + A2*Ts.^2 + A3*Ts.^3 + A4*Ts.^4 + A5*Ts.^5 + ...
               S .* (B0 + B1*Ts + B2*Ts.^2 + B3*Ts.^3) + C0*S.^2);
            
            %apply correction factor for unit conversion if necessary
            if cf ~= 1
               o2_sat = o2sat_ml .* cf;
            else
               o2_sat = o2sat_ml;
            end
            
         catch
            
            %return empty arrays and message on error
            o2_sat = [];
            msg = 'an error occurred calculation oxygen saturation with the supplied input';
            
         end
         
      else         
         msg = 'input arguments must be equal length arrays';         
      end
      
   else      
      msg = 'unsupported units option';      
   end
   
else   
   msg = 'insufficient arguments for function';   
end

