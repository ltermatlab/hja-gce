function edit_polygon(op,data,polylabel,polydate,h_map,style)
%Interactive polygon editor application called by 'poly_mgr'
%
%syntax: edit_polygon(op,data,polylabel,polydate,h_map,style)
%
%input:
%  op = operation (default = 'init')
%  data = polygon data structure
%  polylabel = polygon label array
%  h_map = handle of map figure
%  style = polygon style
%    'freeform' = unbounded polygon
%    'polygon' = closed polygon
%
%output:
%  none
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
%last modified: 02-Jun-2013

if ~exist('op')
   op = 'init';
end

if strcmp(op,'init')

   if length(findobj) > 0
      if exist('h_map') ~= 1
         h_map = gcf;
      end
      h_fig = findobj('Tag','edit_polygon');
   else
      h_map = [];
      h_fig = [];
   end

   if ~isempty(h_fig)

      figure(h_fig)  %set focus to existing clipbook

   elseif ~isempty(h_map)  %creat GUI

      if exist('edit_polygon.mat','file') == 2
         vars = load('edit_polygon.mat');
         if isfield(vars,'settings')
            settings = vars.settings;
         else
            settings = [];
         end
      else
         settings = [];
      end

      if isempty(settings)
         settings = struct('insert',0,'polycolor',[],'highlight',[]);
         settings.polycolor = [1 0 0];
         settings.highlight = [0 1 0];
      end

      if exist('style','var') ~= 1
         style = 'freeform';
         if exist('data','var') == 1
            if ~isempty(data)
               if data(1,1) == data(end,1) & data(1,2) == data(end,2)
                  style = 'polygon';
               end
            end
         end
      end
      if strcmp(style,'polygon')
         chkclose = 1;
      else
         chkclose = 0;
      end

      if exist('polylabel','var') ~= 1
         polylabel = '';
      end

      if exist('polydate','var') ~= 1
         polydate = '';
      end

      editmode = 0;
      polydata = [];

      if exist('data','var') == 1 & ~isempty(polylabel) & ~isempty(polydate)
         polydata = data;
         editmode = 1;
      end

      if isempty(polylabel)
         polylabel = 'New Polygon';
      end

      if isempty(polydate)
         polydate = datestr(now,1);
      end

%       if editmode == 0
%          h_probe = findobj(h_map,'Tag','mapbtn_probe');
%          if ~isempty(h_probe)
%             cachedata = get(h_probe,'UserData');
%             if isstruct(cachedata)
%                polydata = cachedata.polydata;
%                polylabel = cachedata.polylabel;
%                polydate = cachedata.polydate;
%             else
%                if exist('data') ~= 1
%                   polydata = [];
%                else
%                   polydata = data;
%                end
%                if exist('polylabel') ~= 1
%                   polylabel = 'New Polygon';
%                elseif isempty(polylabel)
%                   polylabel = 'New Polygon';
%                end
%                if exist('polydate') ~= 1
%                   polydate = datestr(now,1);
%                elseif isempty(polydate)
%                   polydate = datestr(now,1);
%                end
%             end
%          end
%       end

      res = get(0,'ScreenSize');

      h0 = figure('Visible','off', ...
         'Color',[0.9 0.9 0.9], ...
         'Units','pixels', ...
         'Position',[(res(3)-350) (res(4)-450).*0.5 340 500], ...
         'MenuBar','none', ...
         'Name','Edit Polygon', ...
         'NumberTitle','off', ...
         'Tag','edit_polygon', ...
         'ToolBar','none', ...
         'Resize','off', ...
         'KeyPressFcn','figure(gcf)', ...
         'CloseRequestFcn','edit_polygon(''close'')');

      h_list = uicontrol('Parent',h0, ...
         'Units','pixels', ...
         'BackgroundColor',[1 1 1], ...
         'Min',1, ...
         'Max',3, ...
         'Value',0, ...
         'Position',[5 70 260 380], ...
         'String','', ...
         'Style','listbox', ...
         'Callback','edit_polygon(''show'')', ...
         'Tag','lstCoords');

      h_txtInfo = uicontrol('Parent',h0, ...
         'Units','pixels', ...
         'Style','text', ...
         'Position',[5 45 330 18], ...
         'ForegroundColor',[0 0 .8], ...
         'BackgroundColor',[.95 .95 .95], ...
         'Fontsize',10, ...
         'String','Add coordinates using the Maptools "Probe" function', ...
         'Tag','txtInfo');

      h_cmdAll = uicontrol('Parent',h0, ...
         'Units','pixels', ...
         'Position',[10 460 60 28], ...
         'String','All', ...
         'Tag','cmdAll', ...
         'TooltipString','Select all entries in the list', ...
         'Callback','edit_polygon(''all'')');

      h_cmdNone = uicontrol('Parent',h0, ...
         'Units','pixels', ...
         'Position',[75 460 60 28], ...
         'String','None', ...
         'Tag','cmdNone', ...
         'TooltipString','Deselect all entries', ...
         'Callback','edit_polygon(''none'')');

      h_cmdClearSel = uicontrol('Parent',h0, ...
         'Units','pixels', ...
         'Position',[140 460 60 28], ...
         'String','Clear', ...
         'Tag','cmdClearSel', ...
         'TooltipString','Clear selected entries', ...
         'Callback','edit_polygon(''clearsel'')');

      h_cmdClear = uicontrol('Parent',h0, ...
         'Units','pixels', ...
         'Position',[205 460 60 28], ...
         'String','Clear All', ...
         'Tag','cmdClear', ...
         'TooltipString','Clear all entries', ...
         'Callback','edit_polygon(''clear'')');

      h_cmdUndo = uicontrol('Parent',h0, ...
         'Units','pixels', ...
         'Position',[270 460 60 28], ...
         'String','Undo', ...
         'Tag','undo', ...
         'TooltipString','Undo last ''Clear'' action', ...
         'Callback','edit_polygon(''undo'')');
      
      if settings.insert == 1
         bgcolor = [0 .9 0];
      else
         bgcolor = get(h_cmdUndo,'BackgroundColor');
      end
      h_cmdMode = uicontrol('Parent',h0, ...
         'Units','pixels', ...
         'Style','togglebutton', ...
         'Position',[270 410 60 28], ...
         'String','Insert', ...
         'BackgroundColor',bgcolor, ...
         'Value',settings.insert, ...
         'Tag','cmdMode', ...
         'TooltipString','Toggle insert/append mode', ...
         'Callback','edit_polygon(''mode'')');

      h_cmdDisplay = uicontrol('Parent',h0, ...
         'Units','pixels', ...
         'Style','togglebutton', ...
         'Position',[270 375 60 28], ...
         'String','Display', ...
         'Value',1, ...
         'BackgroundColor',[0 .9 0], ...
         'Tag','cmdDisplay', ...
         'TooltipString','Toggle display mode', ...
         'Callback','edit_polygon(''display'')');

      h_cmdMap = uicontrol('Parent',h0, ...
         'Units','pixels', ...
         'Style','pushbutton', ...
         'Position',[270 340 60 28], ...
         'String','Map', ...
         'Tag','cmdMap', ...
         'TooltipString','Show map figure', ...
         'Callback','edit_polygon(''map'')');

      h_cmdFind = uicontrol('Parent',h0, ...
         'Units','pixels', ...
         'Style','pushbutton', ...
         'Position',[270 305 60 28], ...
         'String','Find', ...
         'Tag','cmdFind', ...
         'TooltipString','Find coordinates on the map figure', ...
         'Callback','edit_polygon(''find'')');

      h_cmdPolyColor = uicontrol('Parent',h0, ...
         'Units','pixels', ...
         'Style','pushbutton', ...
         'Position',[270 260 60 28], ...
         'String','Set Color', ...
         'Callback','edit_polygon(''polycolor'')', ...
         'Tag','cmdPolyColor');

      if sum(settings.polycolor) < 3
         bg_polycolor = [1 1 1];
      else
         bg_polycolor = [0 0 0];
      end
      h_txtPolyColor = uicontrol('Parent',h0, ...
         'Units','pixels', ...
         'Style','text', ...
         'Position',[270 243 60 15], ...
         'String','Polygon', ...
         'ForegroundColor',settings.polycolor, ...
         'BackgroundColor',bg_polycolor, ...
         'Tag','txtPolyColor');

      h_cmdCurrentColor = uicontrol('Parent',h0, ...
         'Units','pixels', ...
         'Style','pushbutton', ...
         'Position',[270 205 60 28], ...
         'String','Set Color', ...
         'Callback','edit_polygon(''currentcolor'')', ...
         'Tag','cmdCurrentColor');

      if sum(settings.highlight) < 3
         bg_highlight = [1 1 1];
      else
         bg_highlight = [0 0 0];
      end
      h_txtCurrentColor = uicontrol('Parent',h0, ...
         'Units','pixels', ...
         'Style','text', ...
         'Position',[270 188 60 15], ...
         'String','Highlight', ...
         'ForegroundColor',settings.highlight, ...
         'BackgroundColor',bg_highlight, ...
         'Tag','txtCurrentColor');

      h_chkClose = uicontrol('Parent',h0, ...
         'Units','pixels', ...
         'Style','checkbox', ...
         'Position',[100 12 150 18], ...
         'String','Close Curve (polygon)?', ...
         'Value',chkclose, ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[.9 .9 .9], ...
         'Tag','chkClose');

      h_cmdCancel = uicontrol('Parent',h0, ...
         'Units','pixels', ...
         'Position',[5 10 60 28], ...
         'String','Cancel', ...
         'Callback','edit_polygon(''close'')', ...
         'Tag','cmdCancel');

      h_cmdSave = uicontrol('Parent',h0, ...
         'Units','pixels', ...
         'Position',[275 10 60 28], ...
         'String','Save', ...
         'Callback','edit_polygon(''save'')', ...
         'Tag','cmdSave');

      uih = struct('h_list',h_list, ...
         'h_cmdUndo',h_cmdUndo, ...
         'h_cmdAll',h_cmdAll, ...
         'h_cmdNone',h_cmdNone, ...
         'h_cmdClearSel',h_cmdClearSel, ...
         'h_cmdClear',h_cmdClear, ...
         'h_cmdCancel',h_cmdCancel, ...
         'h_cmdSave',h_cmdSave, ...
         'h_cmdMode',h_cmdMode, ...
         'h_cmdDisplay',h_cmdDisplay, ...
         'h_cmdMap',h_cmdMap, ...
         'h_txtPolyColor',h_txtPolyColor, ...
         'h_cmdPolyColor',h_cmdPolyColor, ...
         'h_txtCurrentColor',h_txtCurrentColor, ...
         'h_cmdCurrentColor',h_cmdCurrentColor, ...
         'h_chkClose',h_chkClose, ...
         'h_txtInfo',h_txtInfo, ...
         'polydata',polydata, ...
         'h_polydata',[], ...
         'h_current',[], ...
         'h_map',h_map, ...
         'polylabel',polylabel, ...
         'polydate',polydate, ...
         'editmode',editmode);

      set(h0,'Visible','on','UserData',uih)

      if ~isempty(polydata)
         edit_polygon('update')
      else
         drawnow
      end

   end

else  %handle callbacks

   h_fig = findobj('Tag','edit_polygon');

   if ~isempty(h_fig)

      uih = get(h_fig(end),'UserData');
      h_list = uih.h_list;
      h_undo = uih.h_cmdUndo;
      sel = get(h_list,'Value');
      modeflag = get(uih.h_cmdMode,'value');
      dispflag = get(uih.h_cmdDisplay,'value');
      polydata = uih.polydata;
      polycolor = get(uih.h_txtPolyColor,'ForegroundColor');
      currentcolor = get(uih.h_txtCurrentColor,'ForegroundColor');

      switch op

         case 'polycolor'  %set polygon color

            c = uisetcolor(get(uih.h_txtPolyColor,'ForegroundColor'));
            if sum(c) < 3
               bg = [1 1 1];
            else
               bg = [0 0 0];
            end
            set(uih.h_txtPolyColor,'ForegroundColor',c,'BackgroundColor',bg)

            edit_polygon('show')

         case 'currentcolor'  %set polygon color

            c = uisetcolor(get(uih.h_txtCurrentColor,'ForegroundColor'));
            if sum(c) < 3
               bg = [1 1 1];
            else
               bg = [0 0 0];
            end
            set(uih.h_txtCurrentColor,'ForegroundColor',c,'BackgroundColor',bg)

            edit_polygon('show')

         case 'add'  %add coordinates

            if exist('data') == 1

               coords = data;

               %update undo buffer
               set(h_undo,'UserData',[{polydata},{sel}])

               %validate selection
               if isempty(polydata)
                  sel = 0;
               elseif isempty(sel) | modeflag == 0
                  sel = size(polydata,1);  %default to last row if none selected or add mode
               elseif length(sel) > 1
                  sel = max(sel);  %default to below last row if range selected
               end
               %process addition
               if isempty(polydata)
                  polydata = coords;
               elseif modeflag == 1 & sel < size(polydata,1)  %check for middle insert
                  polydata = [polydata(1:sel,:) ; coords ; polydata(sel+1:end,:)];
               else
                  polydata = [polydata ; coords];  %terminal addition
               end

               %update cached data
               uih.polydata = polydata;
               set(h_fig,'UserData',uih)

               %update list
               str = sub_Coords2Str(polydata);
               set(h_list,'String',str,'Value',sel+1);

               %update map display
               edit_polygon('show')

            end

         case 'update'

            %update list
            str = sub_Coords2Str(polydata);
            set(h_list,'String',str,'Value',size(polydata,1))

            %update map display
            edit_polygon('show')

         case 'remove'

            edit_polygon('clearsel')

         case 'mode'  %toggle insert/append mode

            if modeflag == 1
               set(uih.h_cmdMode,'BackgroundColor',[0 .9 0])
            else
               set(uih.h_cmdMode,'BackgroundColor',get(uih.h_cmdUndo,'BackgroundColor'))
               set(uih.h_list,'Value',size(polydata,1))
            end
            drawnow

            edit_polygon('show')

         case 'display'  %toggle display polygon mode

            if dispflag == 1
               set(uih.h_cmdDisplay,'BackgroundColor',[0 .9 0])
            else
               set(uih.h_cmdDisplay,'BackgroundColor',get(uih.h_cmdUndo,'BackgroundColor'))
               uih.h_polydata = [];
               uih.h_current = [];
               set(h_fig,'UserData',uih)
            end
            drawnow

            edit_polygon('show')

         case 'find'  %find coordinates on the map

            if ~isempty(polydata)
               figure(uih.h_map)
               h_btn = findobj('Tag','mapbtn_probe');
               if ~isempty(h_btn)
                  set(h_btn,'Value',1)
                  mapbuttons('probe')
               end
               set(uih.h_map,'WindowButtonDownFcn','edit_polygon(''lookup'')')
               drawnow
            end

         case 'lookup'  %lookup coordinates selected by the 'find' routine

            if ~isempty(polydata)

               %get axis limits
               h_ax = get(uih.h_map,'CurrentAxes');
               xlim = get(h_ax,'Xlim');
               ylim = get(h_ax,'Ylim');

               %get initial mouse click position
               pos = get(h_ax,'CurrentPoint');
               xclick = pos(1,1);
               yclick = pos(1,2);

               %check for out-of-bounds click
               if xclick >= xlim(1) & xclick <= xlim(2) & yclick >= ylim(1) & yclick <= ylim(2)

                  rect = rbbox;

                  %restore probe mode
                  h_btn = findobj(uih.h_map,'Tag','mapbtn_probe');
                  if ~isempty(h_btn)
                     set(h_btn,'Value',1)
                     mapbuttons('probe')
                  end

                  %get post-drag mouse position, button press
                  pos = get(h_ax,'CurrentPoint');
                  xclick2 = pos(1,1);
                  yclick2 = pos(1,2);

                  xmin = min(xclick,xclick2);
                  xmax = max(xclick,xclick2);
                  ymin = min(yclick,yclick2);
                  ymax = max(yclick,yclick2);

                  I = find(polydata(:,1) >= xmin & polydata(:,1) <= xmax & polydata(:,2) >= ymin & polydata(:,2) <= ymax);

                  if ~isempty(I)
                     set(uih.h_list,'Value',I)
                     edit_polygon('show')
                  end

               end

            end

         case 'show'  %show/hide polygon on map

            if dispflag == 1

               if ~isempty(uih.h_map) & ~isempty(polydata)

                  if ~isempty(uih.h_current)
                     try
                        delete(uih.h_current)
                     end
                  end

                  if isempty(uih.h_polydata)
                     uih.h_polydata = line('Parent',get(uih.h_map,'CurrentAxes'), ...
                        'XData',polydata(:,1), ...
                        'YData',polydata(:,2), ...
                        'Linestyle','-', ...
                        'Color',polycolor, ...
                        'Marker','x', ...
                        'MarkerFaceColor',polycolor, ...
                        'MarkerEdgeColor',polycolor, ...
                        'MarkerSize',8, ...
                        'Tag','edit_polygon_poly');
                  else
                     try
                        set(uih.h_polydata, ...
                           'XData',polydata(:,1), ...
                           'YData',polydata(:,2), ...
                           'Color',polycolor, ...
                           'MarkerFaceColor',polycolor, ...
                           'MarkerEdgeColor',polycolor)
                     catch  %refresh line, clearing any prior instances with unknown handles
                        h = findobj(uih.h_map,'Tag','edit_polygon_poly');
                        if ~isempty(h)
                           delete(h)
                        end
                        uih.h_polydata = line('Parent',get(uih.h_map,'CurrentAxes'), ...
                           'XData',polydata(:,1), ...
                           'YData',polydata(:,2), ...
                           'Linestyle','-', ...
                           'Color',polycolor, ...
                           'Marker','x', ...
                           'MarkerFaceColor',polycolor, ...
                           'MarkerEdgeColor',polycolor, ...
                           'MarkerSize',8, ...
                           'Tag','edit_polygon_poly');
                     end
                  end

                  uih.h_current = line('Parent',get(uih.h_map,'CurrentAxes'), ...
                     'XData',polydata(sel,1), ...
                     'YData',polydata(sel,2), ...
                     'LineStyle','none', ...
                     'Color',currentcolor, ...
                     'Marker','o', ...
                     'MarkerSize',8, ...
                     'MarkerFaceColor',currentcolor, ...
                     'MarkerEdgeColor',currentcolor, ...
                     'Tag','edit_polygon_poly');

                  set(h_fig,'UserData',uih)

               else  %remove residual plots
                  if ~isempty(uih.h_map)
                     try
                        h = findobj(get(uih.h_map,'CurrentAxes'),'Tag','edit_polygon_poly');
                        if ~isempty(h)
                           delete(h)
                        end
                     end
                  end
               end

            else  %remove polygons from plot
               if ~isempty(uih.h_map)
                  try
                     h = findobj(get(uih.h_map,'CurrentAxes'),'Tag','edit_polygon_poly');
                     if ~isempty(h)
                        delete(h)
                     end
                  end
               end
            end

            drawnow

         case 'clear'  %clear all coords

            %update undo buffer
            set(h_undo,'UserData',[{polydata},{sel}])

            %update cached coords
            uih.polydata = [];
            set(h_fig,'UserData',uih)

            %update list
            set(h_list,'String','','Value',[])

            %update map display
            edit_polygon('show')

         case 'clearsel'  %clear selected coords

            if ~isempty(sel) & ~isempty(polydata)

               Ifullsel = [1:size(polydata,1)];
               Ifullsel(sel) = NaN;
               Inotsel = find(~isnan(Ifullsel));

               %update undo buffer
               set(uih.h_cmdUndo,'UserData',[{polydata},{sel}])

               %update cached coords
               polydata = polydata(Inotsel,:);
               uih.polydata = polydata;
               set(h_fig,'UserData',uih)

               %update list
               if ~isempty(polydata)
                  newsel = max(1,min(sel)-1);
                  str = sub_Coords2Str(polydata);
                  set(h_list,'String',str,'Value',newsel)
               else
                  set(h_list,'String','','Value',[])
               end

               %update map display
               edit_polygon('show')

            end

         case 'save'  %save coords to polygon manager

            if ~isempty(polydata)

               if get(uih.h_chkClose,'Value') == 1
                  polydata = [polydata ; polydata(1,:)];
               end

               h_mgr = findobj('Tag','dlgPolyMgr');
               if ~isempty(h_mgr)
                  figure(h_mgr)
               elseif ~isempty(uih.h_map)
                  figure(uih.h_map)
                  poly_mgr('init');
                  h_mgr = findobj('Tag','dlgPolyMgr');
               end
               drawnow

               if polydata(1,1) == polydata(end,1) & polydata(1,2) == polydata(end,2)
                  style = 'polygon';
               else
                  style = 'freeform';
               end
               newpolydata = [{uih.polylabel},{style},{uih.polydate},{polydata}];

               if uih.editmode == 0
                  h_create = findobj(h_mgr,'Tag','cmdCreate');
                  set(h_create,'UserData',newpolydata)
                  poly_mgr('newpoly')
               else
                  h_edit = findobj(h_mgr,'Tag','cmdEdit');
                  set(h_edit,'UserData',newpolydata)
                  poly_mgr('edit2')
               end

               edit_polygon('quit')

               h_mgr = findobj('Tag','dlgPolyMgr');
               if ~isempty(h_mgr)
                  figure(h_mgr(1))
               end

            end

         case 'all'  %select all coords

            if ~isempty(polydata)
               set(h_list,'Value',[1:size(polydata,1)])
            end

            %update map display
            edit_polygon('show')

         case 'none'  %select no coords

            set(h_list,'Value',[])

            %update map display
            edit_polygon('show')

         case 'undo'  %undo last clear

            %retrieve/reset undo data
            data = get(h_undo,'UserData');
            set(h_undo,'UserData',[])

            if ~isempty(data)

               %update cached coords
               uih.polydata = data{1};
               set(h_fig,'UserData',uih)

               str = sub_Coords2Str(data{1});
               set(h_list,'String',str,'Value',data{2})

            end

            %update map display
            edit_polygon('show')

         case 'map'  %show map figure

            if ~isempty(uih.h_map)
               if length(findobj) > 1
                  try
                     figure(uih.h_map)
                  end
               end
            end

         case 'close'  %close dialog

            try
               h_probe = findobj(uih.h_map,'Tag','mapbtn_probe');
            catch
               h_probe = [];
            end
            if ~isempty(h_probe)
               cachedata = struct('polydata',[],'polylabel','','polydate','');
               cachedata.polydata = uih.polydata;
               cachedata.polylabel = uih.polylabel;
               cachedata.polydate = uih.polydate;
               set(h_probe,'UserData',cachedata)
               edit_polygon('quit')
            else
               edit_polygon('quit')
               messagebox('init','Warning! Original map figure was closed so data could not be stored', ...
                  '','Warning',[.9 .9 .9]);
            end

         case 'quit'

            settings = struct('insert',modeflag,'polycolor',[],'highlight',[]);
            settings.polycolor = polycolor;
            settings.highlight = currentcolor;
            fn = which('edit_polygon.mat');
            if isempty(fn)
               pn = [gce_homepath,filesep,'settings'];
               if ~isdir(pn)
                  pn = fileparts(which('edit_polygon'));
               end
               fn = [pn,filesep,'edit_polygon.mat'];
            end
            save(fn,'settings')

            delete(h_fig)

            if length(findobj) > 1
               if ~isempty(uih.h_map)
                  try
                     figure(uih.h_map)
                     h = findobj(gcf,'tag','edit_polygon_poly');
                     if ~isempty(h)
                        delete(h)
                     end
                  end
               else
                  figure(gcf)
               end
            end

      end

   end

end


%subfunction to format coords
function str = sub_Coords2Str(coords)

str = '';
if size(coords,2) == 2
   if max(abs(coords(:,1))) < 360
      fmt = '%0.6f';
   else
      fmt = '%0.2f';
   end
   str1 = cellstr(num2str(coords(:,1),fmt));
   str2 = cellstr(num2str(coords(:,2),fmt));
   sep = repmat({', '},length(str1),1);
   try
      str = concatcellcols([str1,sep,str2]);
   catch
      messagebox('init','An error occurred formatting the coordinates','','Error',[.9 .9 .9])
      str = '';
   end
end