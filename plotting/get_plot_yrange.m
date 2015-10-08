function get_plot_yrange(op,h_fig,h_cb,cb,yrange,offset)
%Adds controls to a data plot for interactively selecting an X-axis range and returning data to a calling function
%
%syntax: get_plot_yrange(h_fig,h_cb,cb,yrange,offset)
%
%input:
%   op = operation to perform ('init' to add controls to the plot - required)
%   h_fig = figure handle to add the controls to (numeric ui handle, e.g. gcf - required)
%   h_cb = handle for storing the x-axis range selection (numeric ui handle - required)
%   cb = callback to execute when 'Return' is pressed (string - required)
%   yrange = initial y-axis range to display with green and red lines (1x2 numeric array, optional)
%   offset = offset of control panel from bottom of figure in pixels (integer - optional, default = 100)
%
%output:
%   none
%
%notes:
%   1) the control panel will be attached to the left side of the figure window
%   2) when the 'Return' button is pressed the selected x-axis range will be stored
%      as a 2-element numeric array ([xmin max]) in h_cb, and cb will be evaluated
%
%(c)2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 01-Aug-2013

%check for required arguments
if exist('op','var') ~= 1
   op = 'init';
end

if strcmp(op,'init')
      
   %check for required arguments for creating figure
   if nargin >= 4
      
      %supply default offset if omitted
      if exist('offset','var') ~= 1
         offset = 100;
      end
      
      %supply default xrange if omitted
      if exist('xrange','var') ~= 1 || isempty(yrange) || ~isnumeric(yrange) || length(yrange) ~= 2
         yrange = [NaN NaN];
      end
      
      %set figure units to pixels and get dimenions
      figunits = get(h_fig,'Units');
      set(h_fig,'Units','pixels');
      
      %create controls
      uicontrol('Parent',h_fig, ...
         'Style','frame', ...
         'Position',[1 offset 60 120], ...
         'Backgroundcolor',[0.95 0.95 0.95], ...
         'Foregroundcolor',[0 0 0], ...
         'Tag','plot_yrange');
      
      h_return = uicontrol('Parent',h_fig, ...
         'Style','pushbutton', ...
         'Position',[3 offset+5 56 25], ...
         'String','Return', ...
         'Fontsize',9, ...
         'TooltipString','Return the selected range', ...
         'Callback','get_plot_yrange(''return'')', ...
         'Tag','plot_yrange');
      
      uicontrol('Parent',h_fig, ...
         'Style','pushbutton', ...
         'Position',[3 offset+35 56 25], ...
         'String','End', ...
         'Fontsize',9, ...
         'Callback','get_plot_yrange(''ymax'')', ...
         'TooltipString','Select the end value of the range (maximum Y-axis value)', ...
         'Tag','plot_yrange');
      
      uicontrol('Parent',h_fig, ...
         'Style','pushbutton', ...
         'Position',[3 offset+65 56 25], ...
         'String','Start', ...
         'Fontsize',9, ...
         'TooltipString','Select the start value of the range (minimum Y-axis value)', ...
         'Callback','get_plot_yrange(''ymin'')', ...
         'Tag','plot_yrange');
      
      uicontrol('Parent',h_fig, ...
         'Style','text', ...
         'Position',[3 offset+95 56 18], ...
         'String','Y Range', ...
         'Fontsize',9, ...
         'Backgroundcolor',[0.95 0.95 0.95], ...
         'Foregroundcolor',[0 0 0], ...
         'Tag','plot_yrange');
      
      %restore original figure units
      set(h_fig,'Units',figunits)
      
      %cache input in Return button userdata
      uih = struct('h_cb',h_cb,'cb',cb,'yrange',[]);
      uih.yrange = yrange;      
      set(h_return,'UserData',uih)
      
      %plot initial lines if defined
      get_plot_yrange('lines')      
      
   end
   
else  %handle other callbacks
   
   %get plot figure handle
   h_fig = gcf;
      
   %get Return button handle
   h_return = findobj(h_fig,'Tag','plot_yrange','String','Return');
   
   if length(h_return) == 1
      
      %get cached info
      uih = get(h_return,'Userdata');
      
      %handle callbacks
      if strcmp(op,'return')  %return data to calling function
         
         %get cached values
         h_cb = uih.h_cb;
         cb = uih.cb;
         yrange = uih.yrange;
         
         %clear existing lines
         uih.yrange = [NaN NaN];    
         set(h_return,'UserData',uih)
         get_plot_yrange('lines')
         
         %get handle of figure containing h_cb
         h_fig = parent_figure(h_cb);
         
         %set data and execute callback
         if ~isempty(h_fig)
            figure(h_fig)
            set(h_cb,'Userdata',yrange)
            try
               eval(cb)
            catch
               messagebox('init','An error occurred returning data to the calling figure','','Error',[0.95 0.95 0.95])
            end
         end
         
      elseif strcmp(op,'remove')  %remove controls
         
         %clear controls
         h = findobj(gcf,'Tag','plot_yrange');
         delete(h)
         drawnow         
         
      elseif strcmp(op,'ymin') || strcmp(op,'ymax')  %handle ymin/ymax
         
         %set pointer to full crosshair
         ptr = get(h_fig,'Pointer');
         set(h_fig,'Pointer','fullcrosshair')
         
         %get position from mouse click
         pos = ginput(1);
         
         %restore pointer
         set(h_fig,'Pointer',ptr)
         drawnow
         
         %update appropriate y value in array
         if strcmp(op,'ymin')
            uih.yrange(1) = pos(2);
         else
            uih.yrange(2) = pos(2);
         end         
         set(h_return,'Userdata',uih)
         
         %update lines
         get_plot_yrange('lines')
         
      elseif strcmp(op,'lines')
         
         %delete existing lines
         h_line = findobj(gca,'Tag','yrange_min');
         if ~isempty(h_line)
            delete(h_line)
         end
         
         h_line = findobj(gca,'Tag','yrange_max');
         if ~isempty(h_line)
            delete(h_line)
         end
         
         %get yrange
         yrange = uih.yrange;
         
         %get axis limits for sizing lines
         ax = axis;
         
         %add new start line if defined
         if ~isnan(yrange(1))
            h_line = line([ax(1)-10 ax(2)+10],[yrange(1) yrange(1)]);
            set(h_line,'Linewidth',2,'Color',[0 1 0],'Tag','yrange_min');
         end
         
         %add new end line if defined
         if ~isnan(yrange(2))
            h_line = line([ax(1)-10 ax(2)+10],[yrange(2) yrange(2)]);
            set(h_line,'Linewidth',2,'Color',[1 0 0],'Tag','yrange_max');
         end
         
         drawnow
         
      end         
         
   end
      
end