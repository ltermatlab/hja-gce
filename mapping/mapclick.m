function mapclick(mode,opt)
%function called by 'mapbuttons.m' to handle mouse clicks on maps
%
%syntax:  mapclick(mode,opt)
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
%last modified:  16-Jul-2005

if nargin == 0
   mode = 'zoom';
end

h_fig = gcf;
h_ax = findobj(h_fig,'Tag','mapplot');
if isempty(h_ax)
   h_ax = gca;
end
axes(h_ax)  %make mapplot current axes

%get position of click (in data units)
clickpos = get(h_ax,'CurrentPoint');
pos = clickpos(1,1:2);

%get axis limits
xlim = get(h_ax,'XLim');
ylim = get(h_ax,'YLim');
xdif = abs(xlim(1)-xlim(2));
ydif = abs(ylim(1)-ylim(2));

%determine plot mode
if abs(xlim(1)) <= 180
   axismode = 'deg';
else
   axismode = 'utm';
end

%check for in-bounds tick
if pos(1) >= min(xlim) & pos(1) <= max(xlim) & ...
      pos(2) >= min(ylim) & pos(2) <= max(ylim)

   %process clicks according to function mode
   switch mode

   case 'zoom'  %click left to zoom in, right to zoom out

      if exist('opt')
         mag = opt;
      else
         mag = 2;
      end

	   %check which button pressed
   	selectype = get(h_fig,'SelectionType');
	   if strcmp(selectype,'alt') ~= 1
   	   btn = 'left';
	   else
   	   btn = 'right';
	   end

      %determine new axis limits
      if strcmp(btn,'left')  %zoom in
         xoffset = xdif ./ mag .* 0.5;
         yoffset = ydif ./ mag .* 0.5;
      else %zoom out
         xoffset = xdif .* mag .* 0.5;
         yoffset = ydif .* mag .* 0.5;
      end

      newax = [pos(1)-xoffset pos(2)-yoffset; ...
            pos(1)+xoffset pos(2)+yoffset];
      if strcmp(axismode,'deg')
         [ax,ar] = gpsaxis(newax,2,0);
      else
         ax = [newax(1,1),newax(2,1),newax(1,2),newax(2,2)];
         ar = [];
      end

      set(gcf,'Pointer','watch'); drawnow
      
      axis(ax)
      if ~isempty(ar)
         set(h_ax,'PlotBoxAspectRatio',ar)
      end

      mapticks
      set(gcf,'Pointer','arrow')

   case 'drag'  %drag rectangle to zoom

      figunits =get(h_fig,'Units');  %buffer current figure units
      set(h_fig,'Units','pixels')    %set units to pixels

      rec = rbbox([get(h_fig,'CurrentPoint') 0 0]);

      if rec(3) > 1 & rec(4) > 1
         
         set(gcf,'Pointer','watch'); drawnow

         figpos = get(h_fig,'Position');
         axunits = get(h_ax,'Units');         %buffer original units
         set(h_ax,'Units',get(h_fig,'Units')) %set axis units = fig units
         axposf = get(h_ax,'Position');       %get axis position
         set(h_ax,'Units',axunits)            %reset original units

         %adjust axis position to reflect true size in non-square plots
         ax = axis;
         ar = get(h_ax,'PlotBoxAspectRatio');  %get aspect ratio
         ar_true = (ar(1)./ar(2))./(axposf(3)./axposf(4));  %calculate axis/figure overall aspect ratio

         %calculate insets for pixel-to-data conversion
         if ar_true > 1  %reduced y-axis
            trueht = axposf(4)./ar_true;
            axposf = [axposf(1) axposf(2)+(axposf(4)-trueht).*0.5 axposf(3) trueht];
         elseif ar_true < 1  %reduced x-axis
            truewid = axposf(3).*ar_true;
            axposf = [axposf(1)+(axposf(3)-truewid).*0.5 axposf(2) truewid axposf(4)];
         end

         %get rectangle pos w/in axis
         recposf = [rec(1)-axposf(1) rec(2)-axposf(2) rec(3) rec(4)];

         %get normalized rect pos
         recposn = [max(0,min(1,recposf(1)./axposf(3))) ...
               max(0,min(1,recposf(2)./axposf(4))) ...
               max(0,min(1,recposf(3)./axposf(3))) ...
               max(0,min(1,recposf(4)./axposf(4)))];

         %calculate new axis limits
         newax = [xlim(1)+recposn(1).*xdif ylim(1)+recposn(2).*ydif; ...
               xlim(1)+(recposn(1)+recposn(3)).*xdif ylim(1)+(recposn(2)+recposn(4)).*ydif];

         %get new axis limits, aspect ratio
         if strcmp(axismode,'deg')
            [ax,ar] = gpsaxis(newax,2,0);
         else
            ax = [newax(1,1),newax(2,1),newax(1,2),newax(2,2)];
         end

         set(h_fig,'Units',figunits)  %reset figure units

         axis(ax)
         
         if strcmp(axismode,'deg')
            set(h_ax,'PlotBoxAspectRatio',ar)  %set aspect ratio unless utm (equal x/y ar already set)
         end

         mapticks

         set(gcf,'Pointer','arrow')

      end

   case 'pan'

      newax = [pos(1)-xdif.*0.5 pos(2)-ydif.*0.5 ; ...
            pos(1)+xdif.*0.5 pos(2)+ydif.*0.5];

      if strcmp(axismode,'deg')
         [ax,ar] = gpsaxis(newax,2,0);
         axis(ax)
         set(h_ax,'PlotBoxAspectRatio',ar)
      else
         axis([newax(1,1),newax(2,1),newax(1,2),newax(2,2)]);
      end

      mapticks

   case 'probe'

      %check for statusbar
      h_statusbar = findobj(gcf,'Tag','mapbtn_status');

      if ~isempty(h_statusbar)

         h_clip = findobj('Tag','edit_polygon');

		   %check which button pressed
   		selectype = get(h_fig,'SelectionType');
	   	if strcmp(selectype,'normal')
   	   	btn = 'left';
		   else
   		   btn = 'right';
	   	end

         if strcmp(btn,'left')

            units = get(h_ax,'UserData');

            if pos(1) < 0
               lonhem = 'W';
            else
               lonhem = 'E';
            end

            if pos(2) > 0
               lathem = 'N';
            else
               lathem = 'E';
            end

            if strcmp(units,'decdeg')
               pos2 = abs(pos);
               str = sprintf('%0.5f%s %s, %0.5f%s %s',pos2(1),char(176),lonhem,pos2(2),char(176),lathem);
            elseif strcmp(units,'degmin')
               pos2 = abs(pos);
               str = sprintf('%0d%s %0.4f'' %s, %0d%s %0.4f'' %s',fix(pos2(1)),char(176),roundsig((pos2(1)-fix(pos2(1))).*60,4), ...
                  lonhem,fix(pos2(2)),char(176),roundsig((pos2(2)-fix(pos(2))).*60,4),lathem);
            else
               str = [num2str(pos(1)),', ',num2str(pos(2))];
            end

            set(h_statusbar,'String',['Coordinate: ' str])

            if ~isempty(h_clip)
               edit_polygon('add',pos)
            end

         else  %remove last point

            set(h_statusbar,'String','')

            if ~isempty(h_clip)
               edit_polygon('remove')
            end

         end

      end

   end

end
