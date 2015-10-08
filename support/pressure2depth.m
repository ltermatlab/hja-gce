function depth = pressure2depth(pressure,latitude,p_units)
%Calculates water depth based on water pressure and latitude using a UNESCO algorithm
%
%syntax: depth = pressure2depth(pressure,latitude,p_units)
%
%input:
%  pressure = water pressure
%  latitude = geographic latitude in decimal degrees
%  p_units = pressure units
%    dbar or decibars = decibars (default)
%    mbar or millibars = millibars
%    atm or atmospheres = atmospheres
%    Pa or pascals = pascals
%    cm H20 = centimeters of water
%    feet H2O = feet of water
%    mm Hg or mmHg = millimeters of mercury
%
%output:
%  depth = water depth in meters
%
%notes:
%  1) Based on the function DEPTH in the oceans toolbox available from the Sea-MAT web site at WHOI
%    (http://woodshole.er.usgs.gov/operations/sea-mat/)
%  2) Algorithm reference: Saunders, Fofonoff, Deep Sea Res., 23 (1976), 109-111
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
%last modified: 10-Aug-2011

depth = [];

if nargin >= 2
   
   %supply default for omitted units
   if exist('p_units','var') ~= 1
      p_units = 'dbar';
   end
   
   %perform pressure conversions
   switch p_units
      case 'dbar'
         P = pressure;
      case 'decibars'
         P = pressure;
      case 'mbar'
         P = pressure .* 0.01;
      case 'millibars'
         P = pressure .* 0.01;
      case 'Pa'
         P = pressure .* 0.0001;
      case 'pascals'
         P = pressure .* 0.0001;         
      case 'cm H2O'
         P = pressure .* 0.00980665;
      case 'feet H2O'
         P = pressure .* 0.298907000;
      case 'mmHg'
         P = pressure .* 0.0133322;
      case 'mm Hg'
         P = pressure .* 0.0133322;
      case 'atm'
         P = pressure .* 10.13250027;
      case 'atmospheres'
         P = pressure .* 10.13250027;
      otherwise
         P = [];
   end
   
   if ~isempty(P)
      
      % CHECKVALUE: depth = 9712.653 m FOR P = 10000 decibars, latitude = 30 degrees
      %     ABOVE FOR STANDARD OCEAN: T=0 DEG. CELSUIS ; S=35 (IPSS-78)
      
      X = sin(latitude/57.29578);
      
      X = X.*X;
      
      % GR = GRAVITY VARIATION WITH LATITUDE: ANON (1970) BULLETIN GEODESIQUE
      GR = 9.780318 * (1.0 + (5.2788E-3 + 2.36E-5 * X) .* X) + 1.092E-6 .* P;
      
      depth = (((-1.82E-15 .* P + 2.279E-10) .* P - 2.2512E-5) .* P + 9.72659) .* P;
      
      depth = depth ./ GR;
      
   end
   
end
