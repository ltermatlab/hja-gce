function h_fig = plotmap(map,bounds,mapedge,mapfill,bgcolor,figname)
%Creates a new figure window and generates a continuous line plot of the coordinates in 'map'
%Data should be a two-column matrix of longitudes and latitudes in decimal degrees, with segments separated by
%rows of NaN.  Negative values should be used for longitudes in the western hemisphere and latitudes 
%in the southern hemisphere.  Use the optional 'bounds', 'mapedge', 'mapfill', 'background', 'figname' to
%customize the map.
%
%Editable plot labels and a toolbar containing map functions will also
%be added to the figure.
%
%syntax:  h_fig = plotmap(map,bounds,mapedge,mapfill,background,figname)
%
%intput:
%  map = 2-column array of longitude and latitude in decimal degrees
%  bounds = initial display bounds ([minlon,maxlon,minlat,maxlat], default = [])
%  mapedge = display color for the map polygon edge (default = [0 0 0])
%  mapfill = display color for the map polygon face (default = [])
%  bgcolor = color of the figure background (default = [1 1 1])
%  figname = name to use for the map figure (default = 'Map Plot')
%
%output:
%  h_fig = handle of the map figure
%
%(c)2002-2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified 04-May-2015

if nargin > 0

   if exist('bounds','var') ~= 1
      bounds = [];
   end

   if isempty(bounds)
      Ivalid = find(~isnan(map(:,1)) & ~isnan(map(:,2)));
      bounds = [min(map(Ivalid,1)) max(map(Ivalid,1)) min(map(Ivalid,2)) max(map(Ivalid,2))];
   end

   if exist('mapedge','var') ~= 1
      mapedge = [0 0 0];
   elseif isempty(mapedge)
      mapedge = [0 0 0];
   end

   if exist('mapfill','var') ~= 1
      mapfill = '';
   end

   if isempty(mapfill,'var')
      mode = 'line';
      mapfill = [0.8235 0.7922 0.6824];
   else
      mode = 'filled';
   end

   if exist('bgcolor','var') ~= 1
      bgcolor = [];
   end

   if isempty(bgcolor,'var')
      bgcolor = [1 1 1];
   end

   if exist('figname','var') ~= 1
      figname = 'Map Plot';
   end

   res = get(0,'ScreenSize');

   h_fig = figure('Visible','off', ...
      'Units','pixels', ...
      'Position',[res(3)*0.1 res(4)*0.1 res(3)*0.8 res(4)*0.8], ...
      'Name',figname, ...
      'NumberTitle','off', ...
      'PaperPositionMode','auto', ...
      'InvertHardcopy','off', ...
      'Toolbar','none', ...
      'Tag','MapPlot', ...
      'Color',[1 1 1]);

   if strcmp(mode,'line')
      line('XData',map(:,1), ...
         'YData',map(:,2), ...
         'LineStyle','-', ...
         'Color',mapedge, ...
         'Tag','mapline')
      box on
   else
      h_patch = fillseg(map,mapfill,mapedge);
      set(h_patch,'Tag','mapfill')
      box on
   end

   set(gca, ...
      'DrawMode','fast', ...
      'Units','normal', ...
      'Position',[.075 .075 .85 .85], ...
      'Layer','top', ...
      'Color',bgcolor, ...
      'Tag','mapplot', ...
      'UserData','degmin')

   Inonan = ~isnan(map(:,1));
   if max(abs(map(Inonan,1))) <= 180
      mapmode = 'deg';
      [ax,ar] = gpsaxis([bounds(1),bounds(3); bounds(2),bounds(4)],2,0);
   else
      mapmode = 'utm';
      ax = bounds;
      ar = 1;
   end

   axis(ax)

   if strcmp(mapmode,'deg')
      mlstr = version;
   	mlversion = str2double(mlstr(1:3));
      if mlversion >= 5
        	set(gca,'PlotBoxAspectRatio',ar)
      else
         set(gca,'AspectRatio',ar)
      end
   else
      axis equal
   end

   set(gcf,'UserData',struct( ...
      'axis',ax, ...
      'aspectratio',ar, ...
      'map',map, ...
      'bounds',bounds, ...
      'mapedge',mapedge, ...
      'mapfill',mapfill, ...
      'bgcolor',bgcolor, ...
      'mode',mode))

   mapmenu

   mapticks

   mapbuttons

   if strcmp(mapmode,'deg')
      plotlabels(figname,'Longitude','Latitude')
   else
      plotlabels(figname,'Easting (m)','Northing (m)')
   end

   set(h_fig,'Visible','on')

end
