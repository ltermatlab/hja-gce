function h_img = mapimage(img,cmap,wlon,elon,slat,nlat,h_fig,titlestr)
%plot a colormapped raster image on a map plot
%
%syntax:  h_img = mapimage(img,cmap,wlon,elon,slat,nlat,h_fig,{titlestr})
%
%input:
%  img = image data array return from 'imread' or 'geotiffread'
%  cmap = colormap returned from 'imread' or 'geotiffread'
%  wlon = west longitude (or minimum UTM easting)
%  elon = east longitude (or maximum UTM easting)
%  slat = south latitude (or minimum UTM northing)
%  nlat = north latitude (or maximum UTM northing)
%  h_fig = figure handle for plot (default = gcf)
%  titlestr = plot title (default = '')
%
%output:
%  h_img = image object handle
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
%last modified 06-May-2005

if nargin >= 6

   if exist('h_fig') ~= 1
      h_fig = [];
   end

   if ~exist('titlestr')
	   titlestr = 'Map Plot';
   end

   if abs(wlon) <= 180
      mode = 2;
   else
      mode = 0;
   end

   if mode == 2
      [ax,ar] = gpsaxis([wlon slat ; elon nlat],mode,0);
   else
      ax = [wlon elon slat nlat];
      ar = [];
   end

   if isempty(h_fig)
      res = get(0,'ScreenSize');
      h_fig = figure('Visible','off', ...
         'Units','pixels', ...
         'Position',[res(3)*0.1 res(4)*0.1 res(3)*0.8 res(4)*0.8], ...
         'Name',titlestr, ...
         'NumberTitle','off', ...
         'Toolbar','none', ...
         'Tag','MapPlot', ...
         'Color',[1 1 1]);
   end

   I = [size(img,1):-1:1];
   if size(img,2) == 2
      img = img(I,:);
   else
      img = img(I,:,:);
   end

   h_img = image([wlon elon],[slat nlat],img);

   if ~isempty(cmap)
      colormap(cmap)
   end

   if mode == 2
      set(gca, ...
         'DrawMode','fast', ...
         'Units','normal', ...
         'Position',[.075 .075 .85 .85], ...
         'Layer','top', ...
         'Color',[1 1 1], ...
         'XLim',ax(1:2), ...
         'YLim',ax(3:4), ...
         'PlotboxAspectRatio',ar, ...
         'YDir','normal', ...
         'Tag','mapplot', ...
         'UserData','degmin')
   else
      set(gca, ...
         'DrawMode','fast', ...
         'Units','normal', ...
         'Position',[.075 .075 .85 .85], ...
         'Layer','top', ...
         'Color',[1 1 1], ...
         'XLim',ax(1:2), ...
         'YLim',ax(3:4), ...
         'YDir','normal', ...
         'Tag','mapplot', ...
         'UserData','utm')
      axis image
      ar = get(gca,'PlotBoxAspectRatio');
      updateaxis('init',[wlon slat ; elon nlat]);
   end

   set(h_fig,'UserData',struct( ...
      'axis',ax, ...
      'aspectratio',ar, ...
      'map',[], ...
      'bounds',ax, ...
      'mapedge',[0 0 0], ...
      'mapfill',[0 0 0], ...
      'bgcolor',[1 1 1], ...
      'mode','image'))

	mapmenu

	h = findobj(gcf,'Tag','mnuViewOpt');
	set(h,'Enable','off')

   mapticks

   mapbuttons

   if mode == 2
      plotlabels(titlestr,'W. Longitude','N. Latitude');
   else
      plotlabels(titlestr,'Easting (m)','Northing (m)');
   end

   set(h_fig,'Visible','on')
   drawnow

else

   disp(' '); disp('Too few arguments:'); disp(' ') ; help mapimage

end