function h = plotstations(lon,lat,labels,clr,fontsize,tag)
%Plots station labels on a map, centered over the locations given by lon, lat
%
%syntax: h = plotstations(lon,lat,labels,clr,fontsize,tag)
%
%input:
%  lon = array of longitudes (or UTM eastings)
%  lat = array of latitudes (or UTM northings)
%  labels = cell array of station labels
%  clr = RGB color array for labels (default = [0 0 .8])
%  fontsize = fontsize for labels (default = 8)
%  tag = text object tag (default = 'stationlabel')
%
%output:
%  h = array of text object handles
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
%last modified: 05-Dec-2002

if nargin >= 3

   if ~exist('clr')
      clr = [0 0 .8];
   end

   if ~exist('fontsize')
      fontsize = 8;
   end

   if ~exist('tag')
      tag = 'stationlabel';
   end

   h = repmat(NaN,length(labels),1);

   for n=1:length(labels)

      str = labels{n};

      h(n) = text(lon(n),lat(n),str, ...
         'horizontalalignment','center', ...
         'verticalalignment','middle', ...
         'fontsize',fontsize, ...
         'color',clr, ...
         'clipping','on', ...
         'tag',tag, ...
         'buttondownfcn','textedit');

   end

end
