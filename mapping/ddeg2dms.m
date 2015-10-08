function dms = ddeg2dms(ddeg)
%Converts geographic coordinates from decimal degrees format to degrees, minutes, seconds
%
%syntax: dms = ddeg2dms(ddeg)
%
%input:
%  ddeg = array of decimal degrees coordinates (either latitude or longitude)
%
%output:
%  dms = 3-column array of degrees, minutes, seconds for each column of coordinates in ddeg
%
%notes:
%  1) if coordinates are preceded by a negative sign (i.e. south longitude or west latitude)
%     the sign of the degree portion alone will be retained
%  2) if an array of lat/lon pairs is provided as input, the output will be a 6-column array, e.g.
%     ddeg = [31.5556 -81.1764; 31.5306  -81.1869];
%     dms = ddeg2dms(ddeg)
%     ans =
%        31.0000   33.0000   20.1600  -81.0000   10.0000   35.0400
%        31.0000   31.0000   50.1600  -81.0000   11.0000   12.8400
%
%(c)2002-2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 15-Mar-2014

%init output
dms = [];

if nargin == 1 && isnumeric(ddeg)
   
   %get metrics of ddeg
   len = size(ddeg,1);
   wid = size(ddeg,2);
   
   %dimension output array
   dms = ones(len,wid*3) .* NaN;
   
   %loop through columns generating 3-column output arrays
   for cnt = 1:wid
      
      %generate array of +/-
      fact = ones(len,1);
      fact(ddeg(:,cnt)<0) = -1;
      
      %convert all negative lat/lon to positive
      ddeg(:,cnt) = abs(ddeg(:,cnt));
      
      %calculate degree portion
      deg = fix(ddeg(:,cnt));
      
      %calculate minutes portion
      minutes = fix((ddeg(:,cnt) - deg).* 60 + 1e-6);
      
      %calculate seconds portion
      seconds = abs((ddeg(:,cnt)-deg).*60 - minutes) .* 60;
      
      %populate output array
      offset = 1+ 3 * (cnt-1);
      dms(:,offset:offset+2) = [deg.*fact minutes seconds];
      
   end
   
end