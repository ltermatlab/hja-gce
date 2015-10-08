function coords = geocenter(polygon,res)
%Returns the weighted geographic center of a polygon
%
%syntax:  coords = geocenter(polygon,res)
%
%input:
%  polygon = nx2 array of lon,lat
%  res = size of lon,lat grid used for weighting (default = 50)
%
%output:
%  coords = center coordinates
%
%(c)2002,2003,2004 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 12-Jan-2001
%
%dependencies:  insidepoly.m

coords = [];
errormsg = '';

if exist('res','var') ~= 1
   res = 50;
end

if exist('polygon','var') == 1

   if size(polygon,2) == 2

      xmin = min(polygon(:,1));
      xmax = max(polygon(:,1));
      ymin = min(polygon(:,2));
      ymax = max(polygon(:,2));

      [xgrid,ygrid] = meshgrid(linspace(xmin,xmax,res),linspace(ymin,ymax,res));
      xgrid = xgrid(:);
      ygrid = ygrid(:);

      Imatch = find(insidepoly(xgrid,ygrid,polygon(:,1),polygon(:,2)));

      coords = [mean(xgrid(Imatch)) mean(ygrid(Imatch))];

   else
      errormsg = 'This function requires a 2-column array of coordinates';
   end

else
   errormsg = 'Insufficient arguments';
end

if ~isempty(errormsg)
   disp(' '); disp(errormsg); disp(' ')
end
