function [msg,c,hc,hd] = plot_vertprofile(distance,depth,param,interval,bottom,titles,cmap,mindepth,backgroundcolor,showpoints)
%Creates a vertical profile plot (i.e. filled contours on a depth vs distance plot)
%(note that 'griddata' with the 'linear' method will be used to resample data to
%produce a gridded matrix)
%
%syntax: [msg,c,hc,hd] = plot_vertprofile(distance,depth,param,interval,bottom,titles,cmap,mindepth,backgroundcolor,showpoints)
%
%input:
%  distance = array of transect distance values (numeric array; required)
%  depth = array of depth values (numeric array; required)
%  param = array of data values to plot (numeric array; required)
%  interval = number of contours (e.g. 20) or interval range (numeric array; optional; e.g. [1:2:36]
%    or [] for auto/default)
%  bottom = 2 col array of distance, depth to create bottom profile (nx2 numeric array; optional;
%    default = [] for none)
%  titles = array of plot titles (cell array of strings; optional)
%    titles{1} = plot title (default = 'Vertical Profile')
%    titles{2} = y-axis title (default = 'Depth')
%    titles{3} = x-axis title (default = 'Distance')
%    titles{4} = colobar title (default = 'Value')
%  cmap = colormap data (3 col array of RGB values or MATLAB colormap script; optional; 
%    default = jet(128) - 128-color Jet colormap
%  mindepth = minumum depth to display (number; optional; default = [] for auto)
%  backgroundcolor = plot background color (3 element array of RGB values; optional; 
%    default = [0.9 0.9 0.9])
%  showpoints = option to display the data sampled data points on top of the contours
%    (integer; optional; 0 = no/default; 1 = yes)
%
%output:
%  msg = text of any error message
%  c = contour matrix from 'contourf'
%  hc = handles of contour graphic objects (patches)
%  hd = handle of bottom depth object (patch)
%
%(c)2008-2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 02-May-2015

%init output
msg = '';
c = [];
hc = [];
hd = [];

if nargin >= 3
   
   %set default mindepth if omitted
   if exist('mindepth','var') ~= 1 || isempty(mindepth) || ~isnumeric(mindepth)
      mindepth = [];
   end
   
   %set default background color if omitted
   if exist('backgroundcolor','var') ~= 1 || ~isnumeric(backgroundcolor) || length(backgroundcolor) ~= 3
      backgroundcolor = [0.9 0.9 0.9];
   end
   
   %set default showpoints option if omitted
   if exist('showpoints','var') ~= 1 || isempty(showpoints)
      showpoints = 0;
   end
   
   %generate 3D matrix from arrays
   try
      warning('off','MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId')
      [xi,yi] = meshgrid(unique(distance),unique(depth));
      [xi,yi,zi] = griddata(distance,depth,param,xi,yi,'linear');
      warning('on','MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId')
   catch
      xi = [];
      yi = [];
      zi = [];
      msg = 'an error occurred generating the 3D matrix';
   end
   
   if ~isempty(xi) && ~isempty(yi) && ~isempty(zi)
      
      %validate input/supply defaults
      if ~exist('interval','var')
         interval = [];
      elseif length(interval) == 1  %catch number of intervals option, convert to interval array
         minval = floor(min(no_nan(param)));
         maxval = ceil(max(no_nan(param)));
         stepsize = diff([minval,maxval])./interval;
         interval = (minval:stepsize(1):maxval);
      end
      
      if ~exist('bottom','var')
         bottom = [];
      elseif size(bottom,2) ~= 2 || size(bottom,1) == 1
         bottom = [];
      end
      
      if ~exist('cmap','var')
         cmap = jet(128);
      end
      
      %init title strings
      plottitle = 'Vertical Profile';
      ytitle = 'Depth';
      xtitle = 'Distance';
      cbartitle = 'Value';
      
      %get title strings from array
      if exist('titles','var')
         if iscell(titles)
            plottitle = titles{1};
            if length(titles) > 1
               ytitle = titles{2};
               if length(titles) > 2
                  xtitle = titles{3};
                  if length(titles) > 3
                     cbartitle = titles{4};
                  end
               end
            end
         end
      end
      
      %generate figure and plot window titles
      if length(plottitle) > 70
         figtitle = wordwrap(plottitle,75,0);
         if size(figtitle,1) > 3
            figtitle = figtitle(1:3,1);
            figtitle{3,1} = [figtitle{3,1},'...'];
         end
         figtitle = char(figtitle);
         figtitle = strjust(figtitle,'center');  %center 3-line plot title
         plottitle = [plottitle(1:70),'...'];  %trim title string for figure window
      else
         figtitle = plottitle;
      end
      
      x = xi(1,:);
      y = yi(:,1);
      z = zi;
      
      res = get(0,'ScreenSize');
      if res(3) >= 1000
         wid = 900;
         ht = 640;
      else
         wid = 640;
         ht = 500;
      end
      
      h_fig = figure('Name',plottitle, ...
         'NumberTitle','off', ...
         'Units','pixels', ...
         'Position',[max(0,res(3)./2-wid./2) max(0,res(4)./2-ht./2) wid ht], ...
         'Color',[1 1 1]);
      
      try
         colormap(cmap)
      catch
         msg = 'invalid colormap';
      end

      if ~isempty(interval)
         [c,hc] = contourf(x,y,z,interval);  %generate filled contour plot with user-specified intervals
         caxis([min(interval) max(interval)]);  %set color axis range based on plot interval
      else
         [c,hc] = contourf(x,y,z);  %generate filled contour plot with default intervals
      end
      set(hc,'EdgeColor','none')  %disable contour edges
      
      %set distance axis limits
      xticks = (-100:5:max(no_nan(distance))+5);
      xmin = max(xticks(xticks<min(no_nan(distance))));
      xmax = min(xticks(xticks>max(no_nan(distance))));
      xticks = (xmin:5:xmax);
      
      %get depth axis limits
      ylim = get(gca,'YLim');
      if isempty(mindepth)
         mindepth = ylim(1);
      end      

      %generate bottom topography patch
      if ~isempty(bottom)
         [~,I] = sort(bottom(:,1));
         hd = patch([xlim(1);xlim(1);bottom(I,1);xlim(2);xlim(2)], ...
            [ceil(ylim(2));floor(ylim(1));bottom(I,2);floor(ylim(1));ceil(ylim(2))],[.8 .8 .8]);
         set(hd,'EdgeColor','none','Clipping','on')
      end
      
      %set axis size, options
      figure(h_fig)
      
      %generate y-axis limits
      set(gca, ...
         'Units','normal', ...
         'Position',[.08 .05 .88 .78], ...
         'FontSize',10, ...
         'XTick',xticks, ...
         'XLim',[min(no_nan(distance))-0.1,max(no_nan(distance))+0.1], ...
         'XDir','reverse', ...
         'XAxisLocation','top', ...
         'YDir','reverse', ...
         'YLim',[mindepth ylim(2)], ...
         'Color',backgroundcolor)
      
      %generate feature titles
      h = get(gca,'Title');
      set(h, ...
         'String',figtitle, ...
         'FontSize',16, ...
         'FontWeight','bold', ...
         'Interpreter','none', ...
         'ButtonDownFcn','textedit')
      
      h = get(gca,'XLabel');
      set(h, ...
         'String',xtitle, ...
         'FontSize',12, ...
         'FontWeight','bold', ...
         'Interpreter','none', ...
         'ButtonDownFcn','textedit')
      
      h = get(gca,'YLabel');
      set(h, ...
         'String',ytitle, ...
         'FontSize',12, ...
         'FontWeight','bold', ...
         'Interpreter','none', ...
         'ButtonDownFcn','textedit')
      
      hbar = colorbar('h');
      h = get(hbar,'XLabel');
      set(h, ...
         'String',cbartitle, ...
         'FontSize',12, ...
         'FontWeight','bold', ...
         'Interpreter','none', ...
         'ButtonDownFcn','textedit')
      
      plotmenu;  %add Special plot menu with export and annotation features
      
      if showpoints == 1
         
         %get point metrics
         dist = unique(distance);
         mindep = min(no_nan(depth));
         maxdep = max(no_nan(depth));
         
         %generate vertical lines for distances
         for n = 1:length(dist)
            h = line([dist(n);dist(n)],[mindep-100;maxdep+100], ...
               'LineStyle',':', ...
               'Marker','none', ...
               'Color',[0 0 0]);
            set(h,'Tag','sampling_distance')
         end
         
         %generate points
         line(distance,depth, ...
            'LineStyle','none', ...
            'Marker','o', ...
            'MarkerSize',4, ...
            'MarkerFaceColor',[1 1 1], ...
            'MarkerEdgeColor',[0 0 0], ...
            'Tag','sampling_point');
         
      end
      
   end
   
end