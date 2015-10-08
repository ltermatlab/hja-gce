function spcond = salinity2spcond(salinity)
%Calculates specific conductance at 25C from salinity measurements
%(note: only appropriate for shallow deployments where pressure is minimal)
%
%syntax: spcond = salinity2spcond(salinity)
%
%input:
%  salinity = calculated salinity (PSU or unitless)
%
%output:
%  spcond = specific conductance (temperature compensated to 25C) in mS/cm
%
%reference:
%  Schemel, L.E., 2001, Simplified conversions between specific conductance and salinity units for 
%     use with data from monitoring stations. IEP Newsletter, vol. 14, no. 1, p. 17?18.
%     (http://sfbay.wr.usgs.gov/publications/pdf/schemel_2001_conversions.pdf)
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
%last modified: 22-Jul-2011

spcond = [];

if nargin == 1 && ~isempty(salinity)
   
   %declare constants
   J1 = -16.072;
   J2 = 4.1495;
   J3 = -0.5345;
   J4 = 0.0261;
   
   %calculate conductance in microS/cm
   spcond_uS = (salinity./35) .* 53087 + salinity .* (salinity - 35) .* (J1 + (J2 .* salinity^0.5) + ...
      (J3 .* salinity) + (J4 .* salinity^1.5));
   
   %convert to mS
   spcond = spcond_uS ./ 1000;
   
end