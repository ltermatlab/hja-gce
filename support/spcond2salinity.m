function salinity = spcond2salinity(spcond)
%Calculates salinity from specific conductance at 25C
%(note: only appropriate for shallow deployments where pressure is minimal)
%
%syntax: salinity = spcond2salinity(conductivity)
%
%input:
%  spcond = specific conductance (temperature compensated to 25C) in mS/cm
%
%output:
%  salinity = calculated salinity (PSU or unitless)
%
%reference:
%  Schemel, L.E., 2001, Simplified conversions between specific conductance and salinity units for 
%     use with data from monitoring stations. IEP Newsletter, vol. 14, no. 1, p. 17-18.
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

salinity = [];

if nargin == 1 && ~isempty(spcond)
   
   %declare constants
   K1 = 0.0120;
   K2 = -0.2174;
   K3 = 25.3283;
   K4 = 13.7714;
   K5 = -6.4788;
   K6 = 2.5842;
   
   %calculate R ratio
   R = spcond ./ 53.087;
   
   %calculate salinity
   salinity = K1 + (K2 .* R.^0.5) + (K3 .* R) + (K4 .* R.^1.5) + (K5 .* R.^2) + (K6 .* R.^2.5);   
   
end