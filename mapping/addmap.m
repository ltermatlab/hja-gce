function h_ax = addmap(map,bounds,mapedge,mapfill,bgcolor,figname)
%Adds a map to the current figure and generates a continuous line plot of the coordinates in 'map'.
%Editable plot labels and a toolbar containing map functions will also be added to the figure.
%
%syntax:  h_ax = addmap(map,bounds,mapedge,mapfill,background,title)
%
%input:
%  map = map data (2-column array of longitudes and latitudes in decimal degrees,
%    with segments separated by rows of NaN.  Negative values should be used for
%    longitudes in the western hemisphere and latitudes in the southern hemisphere
%  bounds = array of bounding coordinates to use for initial axis limits
%    (default = [min(map(:,1)) max(map(:,1)) min(map(:,2)) max(map(:,2))])
%  mapedge = RGB color array to use for map polygon edge color (default = [0 0 0])
%  mapfill = RGB color array to use for map fill (default = [0.8235 0.7922 0.6824])
%  bgcolor = RGB color array to use for the plot background (default = [1 1 1])
%  title = plot title
%
%output:
%  h_ax = handle of the plot axis
%
%(c)2004 by Wade Sheldon
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
%Department of Marine Sciences
%University of Georgia
%Athens, Georgia  30602-3636
%sheldon@uga.edu
%
%last modified: 03-Mar-2000

if nargin > 0

   if ~exist('bounds')
      bounds = [min(map(:,1)) max(map(:,1)) min(map(:,2)) max(map(:,2))];
   elseif isempty(bounds)
      bounds = [min(map(:,1)) max(map(:,1)) min(map(:,2)) max(map(:,2))];
   end

   if ~exist('mapedge')
      mapedge = [0 0 0];
   elseif isempty(mapedge)
      mapedge = [0 0 0];
   end

   if ~exist('mapfill')
      mode = 'line';
      mapfill = [0.8235 0.7922 0.6824];
   elseif isempty(mapfill)
      mode = 'line';
      mapfill = [0.8235 0.7922 0.6824];
   else
      mode = 'patch';
   end

   if ~exist('bgcolor')
      bgcolor = [1 1 1];
   elseif isempty(bgcolor)
      bgcolor = [1 1 1];
   end

   if ~exist('figname')
      figname = 'Map Plot';
   end

   h_fig = gcf;
   h_ax = findobj(gcf,'Tag','mapplot');
   if ~isempty(h_ax)
      delete(h_ax)
   end

   h_ax = axes( ...
      'DrawMode','fast', ...
      'Units','normal', ...
      'Position',[.1 .1 .8 .8], ...
      'Layer','top', ...
      'Tag','mapplot', ...
      'UserData','degmin');

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

   [ax,ar] = gpsaxis([bounds(1) bounds(3); bounds(2) bounds(4)],2,0);

   axis(ax)

   mlstr = version;
	mlversion = str2num(mlstr(1:3));

   if mlversion >= 5
     	set(h_ax,'PlotBoxAspectRatio',ar)
   else
      set(h_ax,'AspectRatio',ar)
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

   mapticks

   h_mapmenu = findobj(gcf,'Tag','mapmenu');
   h_btnframe = findobj(gcf,'Tag','mapbtn_frame');

   if isempty(h_mapmenu)
      mapmenu
   end

   if isempty(h_btnframe)
      mapbuttons
   end

   plotlabels(figname,'Longitude','Latitude')

   drawnow

end
