function [sat,o2_sat,msg] = o2_saturation(o2_conc,T,S,units)
%Calculates dissolved oxygen saturation as a function of temperature and salinity at sea-level
%
%syntax: [sat,o2_sat,msg] = o2_saturation(o2_conc,T,S,units)
%
%inputs:
%  o2_conc = dissolved oxygen concentration
%  T = water temperature (°C)
%  S = water salinity (PSU)
%  units = concentration units of o2_conc:
%    'mg/L' (default)
%    'ml/L'
%
%outputs:
%  sat = percent saturation
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
sat = [];
o2_sat = [];

%check for required arguments
if nargin >= 3
   
   %set default units if omitted
   if exist('units','var') ~= 1
      units = 'mg/l';
   end   
   
   %force column array orientation to prevent matrix math errors
   o2_conc = o2_conc(:);
   T = T(:);
   S = S(:);
   
   %check for matching T, S and o2_conc arrays
   if length(T) == length(o2_conc) && length(S) == length(o2_conc)
      
      [o2_sat,msg] = o2_airsat(T,S,units);  %calculate air saturation at T, S
      
      if ~isempty(o2_sat)
         sat = o2_conc./o2_sat .* 100;  %calculation saturation as percent
      end
      
   else
      msg = 'input arguments must be equal length arrays';
   end
   
else
   msg = 'insufficient arguments for function';
end

