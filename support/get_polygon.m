function [pos,h_line] = get_polygon(shape,colorval)
%Builds an array of positions defining a closed polygon of specified shape
%using points on a 2D plot selected with a mouse.  Returns a 2-column array
%of position values and the graphics handle of the line object used to
%illustrate the polygon.
%
%syntax:  [pos,h_line] = get_polygon(shape,colorval)
%
%input:
%  shape = string specifying the type of boundary polygon to build:
%     'polygon' (default)
%     'rectangle'
%     'circle'
%     'square'
%  colorval = optional argument specifying the color used to display the polygon:
%     'b' = blue 
%     'g' = green
%     'r' = red  
%     'c' = cyan 
%     'm' = magen
%     'y' = yello
%     'k' = black
%     'w' = white
%       
%output:
%  pos = 2-column numeric array of position values
%  h_line = line object handle
%
%notes:
%  1) if shape = 'square' or 'circle' the polygon is built based on two mouse clicks,
%     representing opposite corners or the center and radius, resp.
%
%
%(c)2011-2012 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 09-Nov-2012

pos = [];
h_line = [];

[az,el] = view;

if el == 90 || el == 270  %test for valid 2D plot

   %set default shape argument if omitted
   if exist('shape','var') ~= 1
      shape = 'poly';
   else
      shape = [shape '    '];  %pad input value to avoid string errors
   end

   if strcmp(shape(1,1:4),'rect') ~=1 && strcmp(shape(1,1:4),'circ') ~= 1
      shape = 'poly';
   end

   %validate line color argument or set default
   if exist('colorval','var') == 1
      if length(colorval) == 1
         if ~ischar(colorval)
            colorval = 'w';
         end
      elseif length(colorval) == 3
         if max(colorval) > 1 || min(colorval) < 0
            colorval = 'w';
         end
      end
   else
      colorval = 'w';
   end

   %store and clear other mouse click properties of axis and figure window
   axisbdf = get(gca,'ButtonDownFcn');
   set(gca,'ButtonDownFcn','');

   winbdf = get(gcf,'WindowButtonDownFcn');
   set(gcf,'WindowButtonDownFcn','');

   winbmf = get(gcf,'WindowButtonMotionFcn');
   set(gcf,'WindowButtonMotionFcn','');

   winbuf = get(gcf,'WindowButtonUpFcn');
   set(gcf,'WindowButtonUpFcn','');

   %initialize data arrays
   xdata = [];
   ydata = [];
   zdata = [];
   pos = [];

   %determine z-dimension to plot line over top of any surface objects
   %that are being viewed orthogonally
   ztop = get(gca,'ZLim');
   z = ztop(2) + 1;

   %get axis limits for position validation
   ax = axis;

   h_oldlines = findobj(gca,'Tag','polyline');

   %initialize line object with erasemode off to avoid redraws
   h_line = line('XData',xdata, ...
      'YData',ydata, ...
      'LineStyle','-', ...
      'Color',colorval, ...
      'LineWidth',1, ...
      'EraseMode','none');

   if strcmp(shape(1,1:4),'poly')

      button = 1;

      %get points until auxilary button pressed
      [x,y,button] = ginput(1);

      while button == 1
         %add data to arrays after gating for axis limits, update line
         xdata = [xdata ; max(ax(1),min(x,ax(2)))];
         ydata = [ydata ; max(ax(3),min(y,ax(4)))];
         zdata = [zdata ; z];
         set(h_line,'XData',xdata,'YData',ydata,'ZData',zdata)
         [x,y,button] = ginput(1);  %read next button click (discards right click)
      end

      if ~isempty(xdata)
         %close the polygon
         xdata = [xdata ; xdata(1)];
         ydata = [ydata ; ydata(1)];
         zdata = [zdata ; z];
      end

   else

      cancel = 0;

      %get 2 points to define polygon limits
      [x1,y1,button] = ginput(1);

      if button == 1
         hold on
         h_temp = plot3(x1,y1,z,'wx');
         hold off
         drawnow
      else
         cancel = 1;
      end

      if cancel == 0

         [x2,y2,button] = ginput(1);

         if button == 1
            x = [x1 ; x2];
            y = [y1 ; y2];
            delete(h_temp)
         else
            cancel = 1;
         end

      end

      if cancel == 0

         if strcmp(shape(1,1:4),'rect')  %generate coordinates for rectangle

            xmin = max(min(x),ax(1));
            xmax = min(max(x),ax(2));
            ymin = max(min(y),ax(3));
            ymax = min(max(y),ax(4));

            xdata = [xmin ; xmin ; xmax ; xmax ; xmin];
            ydata = [ymin ; ymax ; ymax ; ymin ; ymin];
            zdata = ones(5,1) .* z;

         else  %generate coordinates for circle

            [xdata,ydata] = circle(x(1),y(1),radcalc(x,y),40);

            zdata = ones(size(xdata,1),1) .* z;

         end

      end

   end

   if ~isempty(xdata)

      %generate line and reset erasemode
      set(h_line, ...
         'XData',xdata, ...
         'YData',ydata, ...
         'ZData',zdata, ...
         'LineWidth',1, ...
         'EraseMode','normal', ...
         'Tag','polyline')

      drawnow

      %assemble output array
      pos = [xdata ydata];

   end

   %restore mouse click properties
   set(gca,'ButtonDownFcn',axisbdf)
   set(gcf,'WindowButtonDownFcn',winbdf)
   set(gcf,'WindowButtonMotionFcn',winbmf)
   set(gcf,'WindowButtonUpFcn',winbuf)

else  %not 2D plot

   disp(' '); disp('LASSO can only be used on 2D plots!'); disp(' ')

end
