function plotbuttons(op)
%Adds a custom toolbar to the bottom of the current plot, providing constrained zoom, pan and date axis
%formatting controls
%
%syntax:  adds axis manipulation buttons to a Matlab figure
%
%input:
%  op = operation to perform
%     'add' - adds buttons to the current figure
%     'remove' - removes buttons from the current figure
%     'hide' - hides buttons on the current figure
%     'show' - displays buttons on the current figure
%     'auto' - sets dateaxis to 'auto', creating the toolbox if necessary
%
%(c)2002-2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 16-May-2013

%check for no input arguments
if nargin == 0
   op = 'add';  %default to add/show
end

%get handle of main button group if present
h_btns = [findobj(gcf,'tag','plotbuttons');findobj(gcf,'tag','popDateAxis')];

%get handles of data axes, omitting any legend axes
h_ax = findobj(gcf,'type','axes');
Ikeep = ones(length(h_ax),1);
for n = 1:length(h_ax)
   if strcmpi(get(h_ax(n),'tag'),'legend')
      Ikeep(n) = 0;  %flag legend axes for omission
   end
end
h_ax = h_ax(find(Ikeep));

%run subroutines based on input argument
switch op

   case 'add'  %add toolbar to current figure

      if length(axis) == 4  %check for 2d plot

         if ~isempty(h_btns)  %switch to show if toolbar already exists

            plotbuttons('show')

         else  %create toolbar controls

            h_fig = gcf; %get handle of current figure window

            %check for multiple data axes, set vertical zoom visibility flag
            if length(h_ax) > 1
               vis = 'off';
               axlims = [];
            else
               vis = 'on';
               axlims = axis;
            end

            %add controls
            uicontrol('parent',h_fig, ...
               'style','frame', ...
               'units','pixels', ...
               'position',[1 1 676 25], ...
               'backgroundcolor',[1 1 1], ...
               'foregroundcolor',[0 0 0], ...
               'tag','plotbuttons');

            uicontrol('parent',h_fig, ...
               'style','text', ...
               'units','pixels', ...
               'position',[2 2 49 18], ...
               'fontsize',9, ...
               'fontweight','bold', ...
               'string','Y-axis:', ...
               'backgroundcolor',[1 1 1], ...
               'tag','plotbuttons');

            uicontrol('parent',h_fig, ...
               'style','pushbutton', ...
               'units','pixels', ...
               'enable',vis, ...
               'position',[50 2 20 22], ...
               'fontsize',9, ...
               'fontweight','bold', ...
               'string','|<', ...
               'backgroundcolor',[.9 .9 .9], ...
               'callback','plotbuttons(''panymin'')', ...
               'tooltipstring','Shift Y axis to minimum value at the current zoom level', ...
               'tag','plotbuttons');

            uicontrol('parent',h_fig, ...
               'style','pushbutton', ...
               'units','pixels', ...
               'enable',vis, ...
               'position',[71 2 20 22], ...
               'fontsize',9, ...
               'fontweight','bold', ...
               'string','<', ...
               'backgroundcolor',[.9 .9 .9], ...
               'callback','plotbuttons(''panydown'')', ...
               'tooltipstring','Shift Y axis down by 50% at the current zoom level', ...
               'tag','plotbuttons');

            uicontrol('parent',h_fig, ...
               'style','pushbutton', ...
               'units','pixels', ...
               'enable',vis, ...
               'position',[92 2 20 22], ...
               'fontsize',9, ...
               'fontweight','bold', ...
               'string','+', ...
               'backgroundcolor',[.9 .9 .9], ...
               'callback','plotbuttons(''shrinky'')', ...
               'tooltipstring','Zoom in (reduce Y axis range by 50%)', ...
               'tag','plotbuttons');

            uicontrol('parent',h_fig, ...
               'style','pushbutton', ...
               'units','pixels', ...
               'enable',vis, ...
               'position',[113 2 20 22], ...
               'fontsize',9, ...
               'fontweight','bold', ...
               'string','-', ...
               'backgroundcolor',[.9 .9 .9], ...
               'callback','plotbuttons(''growy'')', ...
               'tooltipstring','Zoom out (increase Y axis range by 50%)', ...
               'tag','plotbuttons');

            uicontrol('parent',h_fig, ...
               'style','pushbutton', ...
               'units','pixels', ...
               'enable',vis, ...
               'position',[134 2 20 22], ...
               'fontsize',9, ...
               'fontweight','bold', ...
               'string','>', ...
               'backgroundcolor',[.9 .9 .9], ...
               'callback','plotbuttons(''panyup'')', ...
               'tooltipstring','Shift Y axis up by 50% at the current zoom level', ...
               'tag','plotbuttons');

            uicontrol('parent',h_fig, ...
               'style','pushbutton', ...
               'units','pixels', ...
               'enable',vis, ...
               'position',[155 2 20 22], ...
               'fontsize',9, ...
               'fontweight','bold', ...
               'string','>|', ...
               'backgroundcolor',[.9 .9 .9], ...
               'callback','plotbuttons(''panymax'')', ...
               'tooltipstring','Shift Y axis to maximum value at the current zoom level', ...
               'tag','plotbuttons');

            uicontrol('parent',h_fig, ...
               'style','text', ...
               'units','pixels', ...
               'position',[180 2 49 18], ...
               'fontsize',9, ...
               'fontweight','bold', ...
               'string','X-axis:', ...
               'backgroundcolor',[1 1 1], ...
               'tag','plotbuttons');

            uicontrol('parent',h_fig, ...
               'style','pushbutton', ...
               'units','pixels', ...
               'position',[230 2 20 22], ...
               'fontsize',9, ...
               'fontweight','bold', ...
               'string','|<', ...
               'backgroundcolor',[.9 .9 .9], ...
               'callback','plotbuttons(''panxmin'')', ...
               'tooltipstring','Shift X axis to minimum value at the current zoom level', ...
               'tag','plotbuttons');

            uicontrol('parent',h_fig, ...
               'style','pushbutton', ...
               'units','pixels', ...
               'position',[251 2 20 22], ...
               'fontsize',9, ...
               'fontweight','bold', ...
               'string','<', ...
               'backgroundcolor',[.9 .9 .9], ...
               'callback','plotbuttons(''panxleft'')', ...
               'tooltipstring','Shift X axis left by 50% at the current zoom level', ...
               'tag','plotbuttons');

            uicontrol('parent',h_fig, ...
               'style','pushbutton', ...
               'units','pixels', ...
               'position',[272 2 20 22], ...
               'fontsize',9, ...
               'fontweight','bold', ...
               'string','+', ...
               'backgroundcolor',[.9 .9 .9], ...
               'callback','plotbuttons(''shrinkx'')', ...
               'tooltipstring','Zoom in (reduce X axis range by 50%)', ...
               'tag','plotbuttons');

            uicontrol('parent',h_fig, ...
               'style','pushbutton', ...
               'units','pixels', ...
               'position',[293 2 20 22], ...
               'fontsize',9, ...
               'fontweight','bold', ...
               'string','-', ...
               'backgroundcolor',[.9 .9 .9], ...
               'callback','plotbuttons(''growx'')', ...
               'tooltipstring','Zoom out (increase X axis range by 50%)', ...
               'tag','plotbuttons');

            uicontrol('parent',h_fig, ...
               'style','pushbutton', ...
               'units','pixels', ...
               'position',[314 2 20 22], ...
               'fontsize',9, ...
               'fontweight','bold', ...
               'string','>', ...
               'backgroundcolor',[.9 .9 .9], ...
               'callback','plotbuttons(''panxright'')', ...
               'tooltipstring','Shift X axis right by 50% at the current zoom level', ...
               'tag','plotbuttons');

            uicontrol('parent',h_fig, ...
               'style','pushbutton', ...
               'units','pixels', ...
               'position',[335 2 20 22], ...
               'fontsize',9, ...
               'fontweight','bold', ...
               'string','>|', ...
               'backgroundcolor',[.9 .9 .9], ...
               'callback','plotbuttons(''panxmax'')', ...
               'tooltipstring','Shift X axis to maximum value at the current zoom level', ...
               'tag','plotbuttons');

            uicontrol('parent',h_fig, ...
               'style','pushbutton', ...
               'units','pixels', ...
               'position',[368 2 55 22], ...
               'fontsize',9, ...
               'fontweight','bold', ...
               'string','Reset', ...
               'backgroundcolor',[.9 .9 .9], ...
               'callback','plotbuttons(''reset'')', ...
               'tooltipstring','Resets axis limits to default values', ...
               'userdata',axlims, ...
               'tag','plotbuttons');

            uicontrol('parent',h_fig, ...
               'style','pushbutton', ...
               'units','pixels', ...
               'position',[427 2 55 22], ...
               'enable',vis, ...
               'fontsize',9, ...
               'fontweight','bold', ...
               'string','Manual', ...
               'value',0, ...
               'backgroundcolor',[.9 .9 .9], ...
               'callback','plotbuttons(''manual'')', ...
               'tooltipstring','Opens a dialog box for manually setting axis limits', ...
               'tag','plotbuttons');

            uicontrol('parent',h_fig, ...
               'style','text', ...
               'units','pixels', ...
               'position',[490 2 60 18], ...
               'fontsize',9, ...
               'fontweight','bold', ...
               'backgroundcolor',[1 1 1], ...
               'string','Date Axis', ...
               'tag','plotbuttons');

            uicontrol('parent',h_fig, ...
               'style','popupmenu', ...
               'units','pixels', ...
               'position',[550 2 110 22], ...
               'fontsize',9, ...
               'string',char('off','auto','dd-mmm-yyyy','mm/dd/yy','mm/dd/yyyy','mm/dd','mmm dd','mmmyyyy','mm/dd HH:MM','HH:MM','HH:MM:SS'), ...
               'value',2, ...
               'backgroundcolor',[1 1 1], ...
               'callback','plotbuttons(''dateaxis'')', ...
               'userdata',{0,-1,1,2,23,6,[3,7],28,[6,15],15,13}, ...
               'tag','popDateAxis');

            uicontrol('parent',h_fig, ...
               'style','pushbutton', ...
               'units','pixels', ...
               'position',[665 1 12 24], ...
               'fontsize',9, ...
               'fontweight','bold', ...
               'string','<', ...
               'backgroundcolor',[.9 .9 .9], ...
               'foregroundcolor',[0 0 0], ...
               'callback','plotbuttons(''hide'')', ...
               'tooltipstring','Hide the axis zooming toolbar', ...
               'tag','plotbuttons_vis');

            sub_dateaxis;  %autoformat date ticks if appropriate

         end

      end

   case 'remove'  %delete toolbar

      if ~isempty(h_btns)
         h_vis = findobj(gcf,'tag','plotbuttons_vis');
         if ~isempty(h_vis)
            h_btns = [h_btns ; h_vis];
            delete(h_btns)
            drawnow
         end
      end

   case 'hide'  %hide toolbar

      if ~isempty(h_btns)
         h = findobj(gcf,'tag','plotbuttons_vis');
         set(h_btns,'visible','off')
         set(h, ...
            'position',[1 1 10 24], ...
            'string','>', ...
            'tooltipstring','Display the axis zooming toolbar', ...
            'callback','plotbuttons(''show'')')
         drawnow
      end

   case 'show'  %show toolbar

      if ~isempty(h_btns)
         h = findobj(gcf,'tag','plotbuttons_vis');
         set(h, ...
            'position',[665 1 12 24], ...
            'string','<', ...
            'tooltipstring','Hide the axis zooming toolbar', ...
            'callback','plotbuttons(''hide'')')
         set(h_btns,'Visible','on')
         drawnow
      end

   case 'dateaxis'  %toggle x-axis date ticks

      h = findobj(h_btns,'tag','popDateAxis');
      if ~isempty(h)
         if get(h,'Value') > 1
            sub_dateaxis
         else
            set(h_ax,'xticklabelmode','auto')
            drawnow
         end
      end

   case 'manual'  %open ui_axislimits dialog

      ui_axislimits

   case 'auto'

      if isempty(h_btns)
         plotbuttons('add');
      end

      h = findobj(h_btns,'tag','popDateAxis');
      if ~isempty(h)
         set(h,'value',2)
         plotbuttons('dateaxis')
      end

   case 'reset'  %reset axis limits to defaults

      if ~isempty(h_btns)
         h_reset = findobj(h_btns,'String','Reset');
         if ~isempty(h_reset)
            axlims = get(h_reset,'UserData');  %retrieve cached axis limits
         else
            axlims = [];
         end
         for n = 1:length(h_ax)
            axes(h_ax(n))
            set(gca, ...
               'XTickMode','auto', ...
               'XLimMode','auto')
            if length(h_ax) == 1
               set(gca, ...
                  'YTickMode','auto', ...
                  'YLimMode','auto')
               if ~isempty(axlims)
                  axis(axlims)
               end
            end
         end
         h = findobj(h_btns,'tag','popDateAxis');
         sub_clipplottext  %call external routine to prevent text clipping anomalies
         if get(h,'Value') > 0
            sub_dateaxis  %refresh data ticks
         end
      end

   otherwise  %handle axis change callbacks

      h_dateaxis = findobj(h_btns,'tag','popDateAxis');

      for n = 1:length(h_ax)

         %set current axes
         axes(h_ax(n))

         %get axis properties
         ax = axis;

         %check for log scale - scale axis values accordingly for proper adjustment
         xscale = get(h_ax(n),'XScale');
         if strcmp(xscale,'log')
            ax(1:2) = log10(ax(1:2));
         end
         yscale = get(h_ax(n),'YScale');
         if strcmp(yscale,'log')
            ax(3:4) = log10(ax(3:4));
         end

         delx = abs(diff(ax(1:2)));
         dely = abs(diff(ax(3:4)));
         midx = ax(1) + 0.5 .* delx;
         midy = ax(3) + 0.5 .* dely;

         axnew = ax;  %initialize updated axis

         %get axis directions, reverse operations if reversed
         xdir = get(gca,'xdir');
         if strcmp(xdir,'reverse')
            switch(op)
               case 'panxright'
                  op = 'panxleft';
               case 'panxleft'
                  op = 'panxright';
               case 'panxmin'
                  op = 'panxmax';
               case 'panxmax';
                  op = 'panxmin';
            end
         end

         ydir = get(gca,'ydir');
         if strcmp(ydir,'reverse')
            switch(op)
               case 'panyup'
                  op = 'panydown';
               case 'panydown'
                  op = 'panyup';
               case 'panymin'
                  op = 'panymax';
               case 'panymax';
                  op = 'panymin';
            end
         end

         switch op

            case 'growx'  %zoom out x

               offset = delx .* 0.75;
               axnew = [midx-offset midx+offset ax(3:4)];

            case 'growy'  %zoom out y

               offset = dely .* .75;
               axnew = [ax(1:2) midy-offset midy+offset];

            case 'shrinkx'  %zoom in x

               offset = delx .* 0.25;
               axnew = [midx-offset midx+offset ax(3:4)];

            case 'shrinky'   %zoom in y

               offset = dely .* 0.25;
               axnew = [ax(1:2) midy-offset midy+offset];

            case 'panxright'  %shift x axis limits right

               offset = 0.5 .* delx;
               axnew = [ax(1)+offset ax(2)+offset ax(3:4)];

            case 'panxleft'  %shift x axis limits left

               offset = 0.5 .* delx;
               axnew = [ax(1)-offset ax(2)-offset ax(3:4)];

            case 'panxmin'  %shift x axis to minimum data value

               h = findobj(gca,'type','line');

               if ~isempty(h)
                  xdata = get(h(1),'xdata');
                  xmin0 = min(xdata(~isnan(xdata)));
                  for n = 2:length(h)
                     xdata = get(h(n),'xdata');
                     xmin = min(xdata(~isnan(xdata)));
                     if xmin < xmin0
                        xmin0 = xmin;
                     end
                  end
                  if strcmp(xscale,'log')
                     axnew = [log10(xmin0) log10(xmin0)+delx ax(3:4)];
                  else
                     axnew = [xmin0 xmin0+delx ax(3:4)];
                  end
               end

            case 'panxmax'  %shift x axis to maximum data value

               h = findobj(gca,'type','line');

               if ~isempty(h)
                  xdata = get(h(1),'xdata');
                  xmax0 = max(xdata(~isnan(xdata)));
                  for n = 2:length(h)
                     xdata = get(h(n),'xdata');
                     xmax = max(xdata(~isnan(xdata)));
                     if xmax > xmax0
                        xmax0 = xmax;
                     end
                  end
                  if strcmp(xscale,'log')
                     axnew = [log10(xmax0)-delx log10(xmax0) ax(3:4)];
                  else
                     axnew = [xmax0-delx xmax0 ax(3:4)];
                  end
               end

            case 'panyup'  %shift y axis up

               offset = 0.5 .* dely;
               axnew = [ax(1:2) ax(3)+offset ax(4)+offset];

            case 'panydown'  %shift y axis down

               offset = 0.5 .* dely;
               axnew = [ax(1:2) ax(3)-offset ax(4)-offset];

            case 'panymin'  %shift y axis to minimum data value

               h = findobj(gca,'type','line');

               if ~isempty(h)
                  ydata = get(h(1),'ydata');
                  ymin0 = min(ydata(~isnan(ydata)));
                  for n = 2:length(h)
                     ydata = get(h(n),'ydata');
                     ymin = min(ydata(~isnan(ydata)));
                     if ymin < ymin0
                        ymin0 = ymin;
                     end
                  end
                  if strcmp(yscale,'log')
                     axnew = [ax(1:2) log10(ymin0) log10(ymin0)+dely];
                  else
                     axnew = [ax(1:2) ymin0 ymin0+dely];
                  end
               end

            case 'panymax'  %shift y axis to maximum data value

               h = findobj(gca,'type','line');

               if ~isempty(h)
                  ydata = get(h(1),'ydata');
                  ymax0 = max(ydata(~isnan(ydata)));
                  for n = 1:length(h)
                     ydata = get(h(n),'ydata');
                     ymax = max(ydata(~isnan(ydata)));
                     if ymax > ymax0
                        ymax0 = ymax;
                     end
                  end
                  if strcmp(yscale,'log')
                     axnew = [ax(1:2) log10(ymax0)-dely log10(ymax0)];
                  else
                     axnew = [ax(1:2) ymax0-dely ymax0];
                  end
               end

         end

         if sum(ax~=axnew) > 0  %check for changes, update axis limits

            if strcmp(xscale,'log')
               axnew(1:2) = 10 .^ axnew(1:2);
            end
            if strcmp(yscale,'log')
               axnew(3:4) = 10 .^ axnew(3:4);
            end

            set(gca,'XTickMode','auto')
            if sum(ax(3:4)~=axnew(3:4)) > 0  %check for y-limit changes before resetting ticks
               if length(h_ax) == 1  %check for single plots (not supported for multiple)
                  set(gca,'YTickMode','auto')
               end
            end
            axis(axnew)
            if get(h_dateaxis,'Value') > 0  %check for date tick refresh function
               sub_dateaxis
            end
            sub_clipplottext  %call external routine to prevent text clipping anomalies
         end

      end
end


%define subfunctions called by GUI

function sub_dateaxis
%refreshes date ticks on the x-axis of the current plot
%
%(c)2002-2006 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
%
%contact:
%  Wade Sheldon
%  GCE-LTER Project
%  Department of Marine Sciences
%  University of Georgia
%  Athens, GA 30602-3636
%  sheldon@uga.edu
%
%last modified: 07-Dec-2002

xtick = get(gca,'xtick');

%get handles of data axes
h_ax = findobj(gcf,'type','axes');
Ikeep = ones(length(h_ax),1);
for n = 1:length(h_ax)
   if strcmp(get(h_ax(n),'tag'),'legend') || isempty(get(h_ax(n),'XTickLabel'))
      Ikeep(n) = 0;  %flag legend axes for omission
   end
end
h_ax = h_ax(find(Ikeep));

try

   h_gca = gca;  %buffer active axes handle

   %loop through all data axes
   for n = 1:length(h_ax)

      axes(h_ax(n))  %set focus on axis before updating (required for older MATLAB versions)

      if min(xtick) >= 657438 && max(xtick) <= 767376  %check for serial dates between 1/1/1900-1/1/2101
         h = findobj(gcf,'tag','popDateAxis');
         if ~isempty(h)
            val = get(h,'value');
            ud = get(h,'userdata');
            fmt = ud{val};
         else
            fmt = -1;
         end

         if fmt == -1
            int = max(diff(xtick)); %get maximum interval
            if int >= 365
               fmt = 10;  %yyyy
            elseif int >= 30
               fmt = 28;  %mmmyyyy
            elseif int >= 1
               fmt = 23;  %mm/dd/yyyy
            else
               fmt = [6,15];  %mm/dd HH:MM
            end
         end

         if length(fmt) > 1
            str = datestr(xtick,fmt(1));
            num = length(xtick);
            for m = 2:length(fmt)
               str = [str,repmat(' ',num,1),datestr(xtick,fmt(m))];
            end
            set(gca,'xticklabel',str)
         elseif fmt > 0
            set(gca,'xticklabel',datestr(xtick,fmt))
         else
            set(gca,'xticklabelmode','auto')
         end

      else
         set(gca,'xticklabelmode','auto')
      end

   end

   axes(h_gca)  %restore focus to original selected axes

catch
   set(gca,'xticklabelmode','auto')  %restore auto ticks on error
end

function sub_clipplottext
%Manually clip text on a 2D plot by toggling the visibility on or off based on axis position
%
%(c)2002-2006 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
%
%last modified: 06-Jan-2003

if length(findobj) > 1

   %get handles of data axes
   h_ax = findobj(gcf,'type','axes');
   Ikeep = ones(length(h_ax),1);
   for n = 1:length(h_ax)
      if strcmp(get(h_ax(n),'tag'),'legend')
         Ikeep(n) = 0;  %flag legend axes for omission
      end
   end
   h_ax = h_ax(find(Ikeep));

   for n = 1:length(h_ax)
      axes(h_ax(n));  %give focus to axes before updating - required for older MATLAB versions
      ht = findobj(gca,'type','text');
      if ~isempty(ht)
         pos = get(ht,'position');
         if length(ht) > 1  %convert cells to double if multiples
            pos = reshape([pos{:}],3,length(ht))';
         end
         ax = axis;
         Ioff = (pos(:,1)<ax(1) | pos(:,1)>ax(2) | pos(:,2)<ax(3) | pos(:,2)>ax(4));
         Ion = ~Ioff;
         set(ht(Ioff),'visible','off')
         set(ht(Ion),'visible','on')
      end
   end

end

