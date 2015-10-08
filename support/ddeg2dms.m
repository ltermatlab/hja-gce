function dms = ddeg2dms(ddeg)
%Converts geographic coordinates from decimal degrees format to degrees, minutes, seconds
%
%syntax: dms = ddeg2dms(ddeg)
%
%input:
%  ddeg = array of decimal degrees coordinates (either latitude or longitude)
%
%output:
%  dms = 3-column array of degrees, minutes, seconds
%
%
%(c)2002-2006 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 08-Sep-2004

dms = [];

if nargin == 1

   ddeg = ddeg(:);  %force column arrangement

   dms = ones(length(ddeg),1) .* NaN;

   if min(ddeg) < 0
      fact = -1;
   else
      fact = 1;
   end

   ddeg = abs(ddeg);

   deg = fix(ddeg);

   minutes = fix((ddeg - deg).* 60 + 1e-6);

   seconds = abs((ddeg-deg).*60 - minutes) .* 60;

   dms = [deg.*fact minutes seconds];

end