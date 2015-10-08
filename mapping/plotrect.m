function plotrect(coords,lbl,clr)
%Plots a rectangular bounding box around an array of coordinates
%
%syntax:  plotrect(coords,lbl,clr)
%
%inputs:
%  coords = array of coordinates to plot (in appropriate plot units)
%    [lon,lat] in decimal degrees
%    [utm_easting,utm_northing] in meters
%  lbl = label to display centered in the rectangle (default = '')
%  clr = color for box (default = 'r')
%
%output:
%  none
%
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
%last modified: 09-Sep-2004

if ~exist('lbl')
   lbl = '';
end

if ~exist('clr')
   clr = 'r';
end

if nargin >= 1

   minlon = min(coords(:,1));
   maxlon = max(coords(:,1));
   minlat = min(coords(:,2));
   maxlat = max(coords(:,2));

   rect = [minlon minlat ; minlon maxlat ; maxlon maxlat ; maxlon minlat ; minlon minlat];
   midpt = [(maxlon+minlon)./2 (maxlat+minlat)./2];

   hold on;
   plot(rect(:,1),rect(:,2),[clr '-']);
   text(midpt(1),midpt(2),lbl,'Color',[1 0 0],'HorizontalAlignment','center','VerticalAlignment','middle');

end
