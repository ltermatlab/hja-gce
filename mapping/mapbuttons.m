function mapbuttons(op)
%Creates map toggle buttons to enable zoom, pan and probe functions via
%mouse clicks.  Also creates a 1-line statusbar to diplay probe positions.
%
%syntax:  mapbuttons(op)
%
%input:
%  op = operation to perform
%    'create' creates the uicontrol objects and activates zoom mode
%    'replace' deletes and recreates the mapbuttons in case of corruption
%    'delete' deletes the map buttons and statusbar
%    'hide' hides the uicontrols for printing purposes
%    'show' makes the uicontrols visible after a 'hide' command
%    'zoom' enables zoom mode
%    'drag' enables drag mode
%    'pan' enables pan mode
%    'probe' enables probe mode
%	'tickdeg' toggles tick mode = decimal degrees
%    'tickdms' toggles tick mode = degress, minutes
%    'tickunf' toggles tick mode = unformatted
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
%last modified: 06-Apr-2006
%
%(Dependencies:  mapclick.m, gpsaxis.m, mapticks.m, mapax.m, degmins.m)

if nargin == 0
   op = 'create';
end

h_fig = gcf;
h_ax = findobj(gcf,'Tag','mapplot');

axlims = axis;
if axlims(1) >= -180 & axlims(2) <= 180 & axlims(3) >= -90 & axlims(4) <= 90  %check for latlon
   tickmode = 'deg';
else
   tickmode = 'utm';
end

hotclr = [0 1 0];
coldclr = [.8 .8 .8];

h_status = findobj(h_fig,'Tag','mapbtn_status');
if ~isempty(h_status)
   uih = get(h_status,'UserData');
else
   uih = [];
end

switch op

case 'zoom'

   if ~isempty(h_status)

      if get(uih.zoom,'Value') == 1
	   	mag = get(uih.zoom,'UserData');
   	   set(uih.zoom,'BackgroundColor',hotclr)
   		set([uih.drag ; uih.pan ; uih.probe ; uih.resize],'Value',0,'BackgroundColor',coldclr)
         set(uih.status,'String','Left-click zooms in on coordinates, right-click zooms out')
         set(h_ax,'ButtonDownFcn','','SelectionHighlight','off')
         set(h_fig, ...
            'WindowButtonDownFcn',['mapclick(''zoom'',' num2str(mag) ')'], ...
            'Pointer','crosshair')
      else
         set(uih.zoom,'BackgroundColor',coldclr)
         set(uih.status,'String','')
         set(h_fig, ...
            'WindowButtonDownFcn','', ...
            'Pointer','arrow')
      end

  		drawnow

   else  %create map buttons first

      mapbuttons('create')
      h_btn = findobj(gcf,'Tag','mapbtn_zoom');
      set(h_btn,'Value',1)
      mapbuttons('zoom')

	end

	h_mnu = findobj(h_fig,'Tag','mnu_mouse');
   h_chk = findobj(h_mnu,'Checked','on');
   set(h_chk,'Checked','off')
   h = findobj(h_mnu,'Tag','mnu_zoom');
   set(h,'Checked','on')

case 'drag'

   if ~isempty(h_status)

      if get(uih.drag,'Value') == 1
   	   set(uih.drag,'BackgroundColor',hotclr)
   		set([uih.zoom ; uih.pan ; uih.probe ; uih.resize],'Value',0,'BackgroundColor',coldclr)
         set(uih.status,'String','Left-click and drag to zoom to the selected rectangle')
         set(h_ax,'ButtonDownFcn','','SelectionHighlight','off')
         set(h_fig, ...
            'WindowButtonDownFcn','mapclick(''drag'')', ...
            'Pointer','fullcrosshair')
      else
         set(uih.drag,'BackgroundColor',coldclr)
         set(uih.status,'String','')
         set(h_fig, ...
            'WindowButtonDownFcn','', ...
            'Pointer','arrow')
         refresh(h_fig)  %refresh to clear residual crosshair pixels
      end

  		drawnow

   else  %create map buttons first

      mapbuttons('create')
      h_btn = findobj(gcf,'Tag','mapbtn_drag');
      set(h_btn,'Value',1)
      mapbuttons('drag')

	end

	h_mnu = findobj(h_fig,'Tag','mnu_mouse');
   h_chk = findobj(h_mnu,'Checked','on');
   set(h_chk,'Checked','off')
   h = findobj(h_mnu,'Tag','mnu_drag');
   set(h,'Checked','on')

case 'pan'

   if ~isempty(h_status)

      if get(uih.pan,'Value') == 1
         set(uih.pan,'BackgroundColor',hotclr)
   		set([uih.zoom ; uih.drag ; uih.probe ; uih.resize],'Value',0,'BackgroundColor',coldclr)
         set(uih.status,'String','Click mouse button to center map on location')
         set(h_ax,'ButtonDownFcn','','SelectionHighlight','off')
         set(h_fig, ...
            'WindowButtonDownFcn','mapclick(''pan'')', ...
            'Pointer','fleur')
      else
         set(uih.pan,'BackgroundColor',coldclr)
         set(uih.status,'String','')
         set(h_fig, ...
            'WindowButtonDownFcn','', ...
            'Pointer','arrow')
      end

   	drawnow

	else  %create map buttons first

   	mapbuttons('create')
      h_btn = findobj(gcf,'Tag','mapbtn_pan');
      set(h_btn,'Value',1)
      mapbuttons('pan')

   end

	h_mnu = findobj(h_fig,'Tag','mnu_mouse');
   h_chk = findobj(h_mnu,'Checked','on');
   set(h_chk,'Checked','off')
   h = findobj(h_mnu,'Tag','mnu_pan');
   set(h,'Checked','on')

case 'probe'

   if ~isempty(h_status)

      if get(uih.probe,'Value') == 1
		   set(uih.probe,'BackgroundColor',hotclr)
   		set([uih.zoom ; uih.drag ; uih.pan ; uih.resize],'Value',0,'BackgroundColor',coldclr)
	   	set(uih.status,'String','Click on coordinates to view lon/lat')
         set(h_ax,'ButtonDownFcn','','SelectionHighlight','off')
         set(h_fig, ...
            'WindowButtonDownFcn','mapclick(''probe'')', ...
            'Pointer','cross')
      else
		   set(uih.probe,'BackgroundColor',coldclr)
         set(uih.status,'String','')
         set(h_fig, ...
            'WindowButtonDownFcn','', ...
            'Pointer','arrow')
      end

   	drawnow

   else  %create map buttons first

      mapbuttons('create')
      h_btn = findobj(gcf,'Tag','mapbtn_probe');
      set(h_btn,'Value',1)
      mapbuttons('probe')

   end

	h_mnu = findobj(h_fig,'Tag','mnu_mouse');
   h_chk = findobj(h_mnu,'Checked','on');
   set(h_chk,'Checked','off')
   h = findobj(h_mnu,'Tag','mnu_probe');
   set(h,'Checked','on')

case 'resize'

   if ~isempty(h_status)

      if get(uih.resize,'Value') == 1
		   set(uih.resize,'BackgroundColor',hotclr)
   		set([uih.zoom ; uih.drag ; uih.pan ; uih.probe],'Value',0,'BackgroundColor',coldclr)
         set(uih.status,'String','Click on axis or handles to move/resize')
         set(h_ax, ...
            'Selected','on', ...
            'SelectionHighlight','on', ...
            'ButtonDownFcn','selectmoveresize')
      else
         set(uih.resize,'BackgroundColor',coldclr)
         set(uih.status,'String','')
         set(h_ax, ...
            'Selected','off', ...
            'SelectionHighlight','off', ...
            'ButtonDownFcn','')
      end

      set(h_fig, ...
         'WindowButtonDownFcn','', ...
         'Pointer','arrow')

      refresh

   else  %create map buttons first

      mapbuttons('create')
      h_btn = findobj(gcf,'Tag','mapbtn_resize');
      set(h_btn,'Value',1)
      mapbuttons('resize')

   end

	h_mnu = findobj(h_fig,'Tag','mnu_mouse');
   h_chk = findobj(h_mnu,'Checked','on');
   set(h_chk,'Checked','off')
   h = findobj(h_mnu,'Tag','mnu_resize');
   set(h,'Checked','on')

case 'reset'

   ax = [];

   figdata = get(gcf,'UserData');
   if isstruct(figdata)
      if isfield(figdata,'axis')
         ax = figdata.axis;
         ar = figdata.aspectratio;
      end
   end

   if isempty(ax)

	   h0 = get(gca,'children')
      if ~isempty(h0)
         ht = findobj(h0,'type','text');
         h = setdiff(h0,ht);  %get list of non-text handles
      else
         h = [];
      end

   	if length(h) >= 1

      	xdata = get(h(1),'XData');
	      ydata = get(h(1),'YData');
   	   ax = [min(xdata) max(xdata) min(ydata) max(ydata)];

      	for n = 2:length(h)
    	   	xdata = get(h(n),'XData');
	        	ydata = get(h(n),'YData');
   	      ax = [min(ax(1),min(xdata)) max(ax(2),max(xdata)) min(ax(3),min(ydata)) max(ax(4),max(ydata))];
      	end

	   end

   end

   if ~isempty(ax)
      updateaxis('update',[ax(1) ax(3); ax(2) ax(4)])
      r12_axistitles;  %re-generate axis titles in case not properly restored from hgsave file
	end

case 'tickdeg'

   if strcmp(tickmode,'deg')
      if get(uih.tickdeg,'Value') == 1
         set(uih.tickdeg,'Value',1)
         set(uih.tickdms,'Value',0)
         set(uih.ticknon,'Value',0)
         set(h_ax,'UserData','decdeg')
         set(uih.status,'String','')
      else
         set(h_ax,'UserData','hide')
      end
      mapmenu('refreshticks')
      updateaxis
   end

case 'tickdms'

   if strcmp(tickmode,'deg')
      if get(uih.tickdms,'Value') == 1
         set(uih.tickdeg,'Value',0)
         set(uih.tickdms,'Value',1)
         set(uih.ticknon,'Value',0)
         set(h_ax,'UserData','degmin')
         set(uih.status,'String','')
      else
         set(h_ax,'UserData','hide')
      end
      mapmenu('refreshticks')
      updateaxis
   end

case 'ticknon'

   if get(uih.ticknon,'Value') == 1
      set(uih.tickdeg,'Value',0)
   	set(uih.tickdms,'Value',0)
      set(uih.ticknon,'Value',1)
	   set(h_ax,'UserData','none')
      set(uih.status,'String','')
   else
      set(h_ax,'UserData','hide')
   end
   mapmenu('refreshticks')
   updateaxis

case 'refreshticks'

   ticktype = get(h_ax,'UserData');

   set([uih.tickdms;uih.tickdeg;uih.ticknon],'Value',0)

   if strcmp(ticktype,'degmin')
      set(uih.tickdms,'Value',1)
   elseif strcmp(ticktype,'decdeg')
      set(uih.tickdeg,'Value',1)
   else
      set(uih.ticknon,'Value',1)
   end

case 'create'

   if isempty(h_status)  %buttons don't already exist

      %increase fig height
      figunits = get(h_fig,'Units');
      set(h_fig,'Units','pixels')
      figpos = get(h_fig,'Position');
      %set(h_fig,'Position',[figpos(1) figpos(2)-20 figpos(3) figpos(4)+40])
      set(h_fig,'Units',figunits)

      %move up axis
      axunits = get(h_ax,'Units');
      set(h_ax,'Units','pixels')
      axpos = get(h_ax,'Position');
      %set(h_ax,'Position',[axpos(1) axpos(2)+40 axpos(3:4)])
      set(h_ax,'Units',axunits)

      h_frame = uicontrol('Parent',h_fig, ...
         'Style','frame', ...
         'Units','pixels', ...
         'Position',[2 2 560 24], ...
         'String','', ...
         'BackgroundColor',[.9 .9 .9], ...
         'ForegroundColor',[0 0 0], ...
         'Tag','mapbtn_frame');

      h_zoom = uicontrol('Parent',h_fig, ...
         'Style','togglebutton', ...
         'Units','pixels', ...
         'Position',[5 4 48 20], ...
         'BackgroundColor',coldclr, ...
         'ForegroundColor',[0 0 0], ...
         'String','Zoom', ...
         'Value',0, ...
         'UserData',2, ...
         'Tag','mapbtn_zoom', ...
         'TooltipString','Toggle axis zooming', ...
         'Callback','mapbuttons(''zoom'')');

      h_drag = uicontrol('Parent',h_fig, ...
         'Style','togglebutton', ...
         'Units','pixels', ...
         'Position',[55 4 48 20], ...
         'BackgroundColor',coldclr, ...
         'ForegroundColor',[0 0 0], ...
         'String','Area', ...
         'Value',0, ...
         'Tag','mapbtn_drag', ...
         'TooltipString','Toggle axis drag-to-zoom', ...
         'Callback','mapbuttons(''drag'')');

      h_pan = uicontrol('Parent',h_fig, ...
         'Style','togglebutton', ...
         'Units','pixels', ...
         'Position',[105 4 48 20], ...
         'BackgroundColor',coldclr, ...
         'ForegroundColor',[0 0 0], ...
         'String','Pan', ...
         'Value',0, ...
         'Tag','mapbtn_pan', ...
         'TooltipString','Toggle axis panning', ...
         'Callback','mapbuttons(''pan'')');

      h_probe = uicontrol('Parent',h_fig, ...
         'Style','togglebutton', ...
         'Units','pixels', ...
         'Position',[155 4 48 20], ...
         'BackgroundColor',coldclr, ...
         'ForegroundColor',[0 0 0], ...
         'String','Probe', ...
         'Value',0, ...
         'Tag','mapbtn_probe', ...
         'TooltipString','Toggle coordinate probing', ...
         'Callback','mapbuttons(''probe'')');

      h_resize = uicontrol('Parent',h_fig, ...
         'Style','togglebutton', ...
         'Units','pixels', ...
         'Position',[205 4 48 20], ...
         'BackgroundColor',coldclr, ...
         'ForegroundColor',[0 0 0], ...
         'String','Resize', ...
         'Value',0, ...
         'Tag','mapbtn_resize', ...
         'TooltipString','Toggle axis move/resize', ...
         'Callback','mapbuttons(''resize'')');

      h_reset = uicontrol('Parent',h_fig, ...
         'Style','pushbutton', ...
         'Units','pixels', ...
         'Position',[265 4 48 20], ...
         'BackgroundColor',coldclr, ...
         'ForegroundColor',[0 0 0], ...
         'String','Reset', ...
         'Tag','mapbtn_reset', ...
         'TooltipString','Reset map boundaries to initial size', ...
         'Callback','mapbuttons(''reset'')');

      if strcmp(tickmode,'deg')
         vis = 'on';
         val = 1;
      else
         vis = 'off';
         val = 0;
      end
      h_tickdms = uicontrol('Parent',h_fig, ...
         'Style','checkbox', ...
         'Units','pixels', ...
         'Position',[325 4 65 20], ...
         'BackgroundColor',[.9 .9 .9], ...
         'ForegroundColor',[0 0 0], ...
         'String','Deg,Min', ...
         'Value',val, ...
         'Enable',vis, ...
         'Tag','mapbtn_tickdms', ...
         'TooltipString','Display ticks in degrees, minutes format', ...
         'Callback','mapbuttons(''tickdms'')');

      h_tickdeg = uicontrol('Parent',h_fig, ...
         'Style','checkbox', ...
         'Units','pixels', ...
         'Position',[390 4 65 20], ...
         'BackgroundColor',[.9 .9 .9], ...
         'ForegroundColor',[0 0 0], ...
         'String','Degrees', ...
         'Value',0, ...
         'Enable',vis, ...
         'Tag','mapbtn_tickdeg', ...
         'TooltipString','Display ticks in decimal degrees format', ...
         'Callback','mapbuttons(''tickdeg'')');

     if strcmp(tickmode,'deg')
        val = 0;
     else
        val = 1;
     end
     h_ticknon = uicontrol('Parent',h_fig, ...
         'Style','checkbox', ...
         'Units','pixels', ...
         'Position',[455 4 78 20], ...
         'BackgroundColor',[.9 .9 .9], ...
         'ForegroundColor',[0 0 0], ...
         'String','Unformatted', ...
         'Value',val, ...
         'Tag','mapbtn_ticknon', ...
         'TooltipString','Display unformatted ticks', ...
         'Callback','mapbuttons(''ticknon'')');

      h_delete = uicontrol('Parent',h_fig, ...
         'Units','pixels', ...
         'Style','pushbutton', ...
         'Position',[552 3 10 22], ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[1 1 1], ...
         'String','<', ...
         'TooltipString','Hide map toolbar', ...
         'Callback','mapbuttons(''hide'')');

      h_status = uicontrol('Parent',h_fig, ...
         'Style','text', ...
         'Units','pixels', ...
         'Position',[570 2 400 18], ...
         'HorizontalAlignment','left', ...
         'String','', ...
         'BackgroundColor',get(h_fig,'Color'), ...
         'ForegroundColor',[0 0 .8], ...
         'Tag','mapbtn_status');

      set(h_status,'UserData', ...
         struct('zoom',h_zoom, ...
         'drag',h_drag, ...
         'pan',h_pan, ...
         'probe',h_probe, ...
         'resize',h_resize, ...
         'status',h_status, ...
         'frame',h_frame, ...
         'tickdeg',h_tickdeg, ...
         'tickdms',h_tickdms, ...
         'ticknon',h_ticknon, ...
         'reset',h_reset, ...
         'delete',h_delete))

      mapbuttons('zoom')

   end

case 'delete'

   if ~isempty(h_status)

      delete([uih.zoom ; uih.drag ; uih.pan ; uih.probe ; uih.resize ; ...
      uih.status ; uih.frame ; uih.delete ; ...
     	uih.reset ; uih.tickdms ; uih.tickdeg ; uih.ticknon])

      %decrease fig height
      %figunits = get(h_fig,'Units');
      %set(h_fig,'Units','pixels')
      %figpos = get(h_fig,'Position');
      %set(h_fig,'Position',[figpos(1) figpos(2)+15 figpos(3) figpos(4)-25])
      %set(h_fig,'Units',figunits)

      %move axis down
      %axunits = get(h_ax,'Units');
      %set(h_ax,'Units','pixels')
      %axpos = get(h_ax,'Position');
      %set(h_ax,'Position',[axpos(1) axpos(2)-25 axpos(3:4)])
      %set(h_ax,'Units',axunits)

      drawnow

   end

case 'replace'

   if ~isempty(h_status)

      delete([uih.zoom ; uih.drag ; uih.pan ; uih.probe ; uih.resize ; ...
   	   uih.status ; uih.frame ; uih.delete ; ...
     		uih.reset ; uih.tickdms ; uih.tickdeg ; uih.ticknon])

      mapbuttons('create')

      mapbuttons('show')

      drawnow

   end

case 'hide'

   h = findobj(h_fig,'Tag','mnu_showhide');

   set(h,'Label','Show Toolbar')

   set([uih.zoom ; uih.drag ; uih.pan ; uih.probe ; uih.resize ; ...
      uih.status ; uih.frame ; uih.delete ; ...
     	uih.reset ; uih.tickdms ; uih.tickdeg ; uih.ticknon], ...
      'Visible','off')

   drawnow

case 'show'

   h = findobj(h_fig,'Tag','mnu_showhide');

   set(h,'Label','Hide Toolbar')

   set([uih.zoom ; uih.drag ; uih.pan ; uih.probe ; uih.resize ; ...
      uih.status ; uih.frame ; uih.delete ; ...
     	uih.reset ; uih.tickdms ; uih.tickdeg ; uih.ticknon], ...
      'Visible','on')

   drawnow

end