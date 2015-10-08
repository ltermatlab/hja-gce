function fig = poly_mgr(op)
%Polygon management utility called by 'plotmap'
%
%syntax: poly_mgr
%
%input:
%  none
%
%output:
%  none
%
%(c)2002-2011 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 07-Sep-2011

if ~exist('op')
   op = 'init';
end

if strcmp(op,'init')

   polyinit = struct('list',{''}, ...
      'data',{[]}, ...
      'center',{[]}, ...
      'selection',[], ...
      'display',1, ...
      'color',[1 1 0], ...
      'width',1, ...
      'showcenter',0);

   if length(findobj) > 0
      h_dlg = findobj('Tag','dlgPolyMgr');
   else
      h_dlg = [];
   end

   if ~isempty(h_dlg)
      close(h_dlg)  %clear prior instance
   end

   if ~isempty(findobj(gcf,'Tag','mnuPolygons'))  %check for valid figure

      curpath = pwd;

      %get stored data
      h_fig = gcf;
      h_poly = findobj(h_fig,'Tag','mnuPolygons');
      if ~isempty(h_poly)
         polygons = get(h_poly,'UserData');
      else
         polygons = [];
      end

      %apply defaults if no poly data
      if isempty(polygons)
         polygons = polyinit;
         set(h_poly,'UserData',polygons)
      else  %check for mismatch between coordinate system for polygon data, map and convert
         polygons = check_coord_system(h_fig,polygons); %call subfunction to match polygon data to map coord system
      end

      %update outdated structures
      if ~isfield(polygons,'color')
         polygons.color = [1 0 0];
         polygons.width = 1.5;
	      set(h_poly,'UserData',polygons)
      end
      if ~isfield(polygons,'showcenter')
         polygons.showcenter = 1;
      end

      %create GUI
      res = get(0,'ScreenSize');

      h0 = figure('Visible','off', ...
         'Color',[0.9 0.9 0.9], ...
         'Units','pixels', ...
         'Position',[(res(3)-425) (res(4)-500).*0.5 425 500], ...
         'MenuBar','none', ...
         'Name','Polygon Manager', ...
         'NumberTitle','off', ...
         'Tag','dlgPolyMgr', ...
         'ToolBar','none', ...
         'CloseRequestFc','poly_mgr(''close'')', ...
         'DefaultuicontrolUnits','pixels', ...
         'Resize','off', ...
         'UserData',gcf);

      h1 = uicontrol('Parent',h0, ...
         'Units','pixels', ...
         'BackgroundColor',[1 1 1], ...
         'Min',1, ...
         'Max',3, ...
         'Position',[5 5 340 450], ...
         'String',polygons.list, ...
         'Value',0, ...
         'Style','listbox', ...
         'Tag','lstPolygons', ...
         'UserData',polygons, ...
         'Callback','poly_mgr(''display'')');

      set(h1,'Value',polygons.selection)

      h1 = uicontrol('Parent',h0, ...
         'Position',[5 465 55 28], ...
         'String','Create', ...
         'Tag','cmdCreate', ...
         'TooltipString','Create a new polygon and add it to the list', ...
         'Callback','poly_mgr(''create'')');

      h1 = uicontrol('Parent',h0, ...
         'Position',[65 465 55 28], ...
         'String','Load', ...
         'Tag','cmdLoad', ...
         'TooltipString','Load entries from disk', ...
         'Callback','poly_mgr(''load'')', ...
         'UserData',curpath);

      h1 = uicontrol('Parent',h0, ...
         'Position',[125 465 55 28], ...
         'String','Edit', ...
         'Tag','cmdEdit', ...
         'TooltipString','Edit the selected polygon', ...
         'Callback','poly_mgr(''edit'')', ...
         'UserData',curpath);

      h1 = uicontrol('Parent',h0, ...
         'Position',[185 465 55 28], ...
         'String','Save', ...
         'Tag','cmdSave', ...
         'TooltipString','Save entries to disk', ...
         'Callback','poly_mgr(''save'')', ...
         'UserData',curpath);

      h1 = uicontrol('Parent',h0, ...
         'Position',[245 465 55 28], ...
         'String','Clear', ...
         'Tag','cmdClearSel', ...
         'TooltipString','Clear selected entries', ...
         'Callback','poly_mgr(''clearsel'')');

      h1 = uicontrol('Parent',h0, ...
         'Position',[305 465 55 28], ...
         'String','Clear All', ...
         'Tag','cmdClear', ...
         'TooltipString','Clear all entries', ...
         'UserData',polyinit, ...
         'Callback','poly_mgr(''clear'')');

      h1 = uicontrol('Parent',h0, ...
         'Position',[365 465 55 28], ...
         'String','Undo', ...
         'Tag','undo', ...
         'TooltipString','Undo last ''Clear'' action', ...
         'Callback','poly_mgr(''undo'')');

      h1 = uicontrol('Parent',h0, ...
         'Style','frame', ...
         'Position',[346 6 78 448], ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[.85 .85 .85]);

      h1 = uicontrol('Parent',h0, ...
         'Position',[350 420 70 28], ...
         'String','Select All', ...
         'Tag','cmdAll', ...
         'TooltipString','Select all entries in the list', ...
         'Callback','poly_mgr(''all'')');

      h1 = uicontrol('Parent',h0, ...
         'Position',[350 385 70 28], ...
         'String','Select None', ...
         'Tag','cmdNone', ...
         'TooltipString','Deselect all entries', ...
         'Callback','poly_mgr(''none'')');

      h1 = uicontrol('Parent',h0, ...
         'Position',[350 350 70 28], ...
         'String','Rename', ...
         'Tag','cmdRename', ...
         'TooltipString','Rename selected polygon', ...
         'Callback','poly_mgr(''rename'')');

      h1 = uicontrol('Parent',h0, ...
         'Position',[350 315 70 28], ...
         'String','Export Data', ...
         'Tag','cmdExport', ...
         'TooltipString','Export polygon data as a tab-delimited text file', ...
         'Callback','poly_mgr(''export'')');

      h1 = uicontrol('Parent',h0, ...
         'Position',[350 280 70 28], ...
         'String','Workspace', ...
         'Tag','cmdWorkspace', ...
         'TooltipString','Export polygon data to the base MATLAB workspace', ...
         'Callback','poly_mgr(''workspace'')');

      if polygons.display == 1
         clr = [0 1 0];
      else
         clr = get(h1,'BackgroundColor');
      end

      h1 = uicontrol('Parent',h0, ...
         'Style','togglebutton', ...
         'Position',[350 215 70 28], ...
         'BackgroundColor',clr, ...
         'String','Display', ...
         'Tag','togDisplay', ...
         'Value',polygons.display, ...
         'TooltipString','Display selected polygons on the map', ...
         'Callback','poly_mgr(''display'')');

      h1 = uicontrol('Parent',h0, ...
         'Style','pushbutton', ...
         'Position',[350 180 70 28], ...
         'String','Change Color', ...
         'TooltipString','Change the color used to display polygons', ...
         'Callback','poly_mgr(''color'')');

      h1 = uicontrol('Parent',h0, ...
         'Style','text', ...
         'Position',[350 160 70 18], ...
         'BackgroundColor',[1 1 1], ...
         'ForegroundColor',polygons.color, ...
         'String','Polygon Color', ...
         'Tag','txtColor');

      h1 = uicontrol('Parent',h0, ...
         'Style','text', ...
         'Position',[350 129 35 18], ...
         'String','Width', ...
         'BackgroundColor',[.85 .85 .85], ...
         'ForegroundColor',[0 0 0]);

      h1 = uicontrol('Parent',h0, ...
         'Style','edit', ...
         'Position',[385 130 35 20], ...
         'BackgroundColor',[1 1 1], ...
         'HorizontalAlignment','left', ...
         'String',num2str(polygons.width), ...
         'TooltipString','Change the line width (in pts) for displayed polygons', ...
         'Tag','editWidth', ...
         'Callback','poly_mgr(''display'')');

      h1 = uicontrol('Parent',h0, ...
         'Style','checkbox', ...
         'Position',[358 95 65 30], ...
         'String','Centers', ...
         'Value',polygons.showcenter, ...
         'BackgroundColor',[.85 .85 .85], ...
         'ForegroundColor',[0 0 0], ...
         'Tag','chkShowCtr', ...
         'Callback','poly_mgr(''display'')');

      set(h0,'Visible','on')
      drawnow

      poly_mgr('display')

   else  %bad function call

      errorbox('init','This utility can only be run from a map plot')

   end

elseif strcmp(op,'close')  %catch close operation first

   h_dlg = findobj('Tag','dlgPolyMgr');
   h_fig = get(h_dlg,'UserData');

   delete(h_dlg)

   if ~isempty(get(0,'Children'))
      try
   	   if ~isempty(find(h_fig==get(0,'Children')))
            figure(h_fig)
         end
      end
   end

   drawnow

else   %handle other callbacks

   h_dlg = findobj('Tag','dlgPolyMgr');
   h_list = findobj(h_dlg,'Tag','lstPolygons');
   h_undo = findobj(h_dlg,'Tag','undo');
   h_clear = findobj(h_dlg,'Tag','cmdClear');
   h_display = findobj(h_dlg,'Tag','togDisplay');

   h_fig = get(h_dlg,'UserData');
   try
      h_poly = findobj(h_fig,'Tag','mnuPolygons');
   catch
      h_poly = [];
   end

   displaystatus = get(h_display,'Value');
   polyinit = get(h_clear,'UserData');

   polygons = get(h_list,'UserData');
   listsel = get(h_list,'Value');

   if ~isempty(polygons)
      listitems = polygons.list;
      data = polygons.data;
      ctr = polygons.center;
   else
      listitems = '';
      data = [];
      ctr = [];
   end

   switch op

   case 'save'

      curpath = pwd;
      h_save = findobj(h_dlg,'Tag','cmdSave');
      cachepath = get(h_save,'UserData');

      eval(['cd ''',cachepath,''''],['cd ''',curpath,''''])

      [fn,pn] = uiputfile('*.ply','Select a file name and directory');
      figure(h_dlg)
      drawnow

      if fn ~= 0  %check for cancel

         [tmp,basename] = fileparts(fn);

         polydata = polygons;

         eval(['cd ''',pn,''''],['cd ''',curpath,''''])
         eval(['save ''',basename,'.ply'' polydata'])
         eval(['cd ''',curpath,''''])

         figure(h_dlg)
         drawnow

      end

   case 'load'

      error = 0;
      curpath = pwd;
      h_load = findobj(h_dlg,'Tag','cmdLoad');
      cachepath = get(h_load,'UserData');

      if exist(cachepath) == 7
         cd(cachepath)
      end

      [fn,pn] = uigetfile('*.ply','Select a polygon data file to load');
      figure(h_dlg)
      drawnow
      cd(curpath)

      if fn ~= 0

         %load file
         try
            v = load([pn,filesep,fn],'-mat');
         catch
            v = struct('null','');
         end

         if isfield(v,'polydata')

            polydata = v.polydata;

            if isstruct(polydata)

               set(h_load,'UserData',pn)  %update path cache
               set(h_undo,'UserData',polygons)  %save undo info

               polygons = check_coord_system(h_fig,polydata); %call subfunction to match polygon data to map coord system
               set(h_list, ...
                  'String',polygons.list, ...
                  'Value',polygons.selection, ...
                  'UserData',polygons)

               %update dialog controls
               h_wid = findobj(h_dlg,'Tag','editWidth');
               h_showctr = findobj(h_dlg,'Tag','chkShowCtr');
               h_color = findobj(h_dlg,'Tag','txtColor');
               set(h_wid,'String',num2str(polydata.width))
               set(h_showctr,'Value',polydata.showcenter)
               set(h_color,'ForegroundColor',polydata.color)
               set(h_display,'Value',polydata.display)

               poly_mgr('display')  %update figure polygons

            else
               error = 1;
            end

         end

         if error ~= 0
            errorbox('init','Invalid polygon data file')
         end

      end

   case 'clear'

      set(h_undo,'UserData',polygons)
      set(h_list, ...
         'String','', ...
         'Value',[], ...
         'UserData',polyinit)

      poly_mgr('display')  %update figure polygons

   case 'clearsel'

      listsel = get(h_list,'Value');

      if ~isempty(listsel)

         set(h_undo,'UserData',polygons)

         if iscell(listitems)
            fullsel = [1:length(listitems)];
         elseif ~isempty(listitems)
            fullsel = 1;
         else
            fullsel = [];
         end

         notsel = setdiff(fullsel,listsel);

         if ~isempty(notsel)
            polygons.data = polygons.data(notsel);
            polygons.list = polygons.list(notsel);
            polygons.center = polygons.center(notsel);
            polygons.selection = [];
            set(h_list,'String',polygons.list,'Value',[],'UserData',polygons)
         else
            set(h_list, ...
               'String','', ...
               'Value',[], ...
               'UserData',polyinit)
         end

         poly_mgr('display')  %update figure polygons

      end

   case 'export'

      if ~isempty(listsel)

         polydata = struct('list',{listitems(listsel)}, ...
            'data',{data(listsel)}, ...
            'center',{ctr(listsel)});

         writepoly(polydata);
         drawnow

	   else  %no selected items

         errorbox('init','No polygons are selected')

      end

   case 'workspace'

      if ~isempty(listsel)
         polydata = struct('name','','data',[],'center',[]);
         list = polygons.list;
         data = polygons.data;
         centers = polygons.center;
         for n = 1:length(listsel)
            polydata(n).name = list{listsel(n)};
            polydata(n).data = data{listsel(n)};
            polydata(n).center = centers{listsel(n)};
         end
         assignin('base','polygons',polydata);
      end

   case 'all'

      if ~isempty(listitems)
         polygons.selection = [1:length(listitems)];
         set(h_list, ...
            'Value',polygons.selection, ...
            'UserData',polygons)
         drawnow
         poly_mgr('display')
      end

   case 'none'

      polygons.selection = [];
      set(h_list, ...
         'Value',[], ...
         'UserData',polygons)
      poly_mgr('display')

   case 'undo'

      polygons = get(h_undo,'UserData');

      if ~isempty(polygons)

         listitems = polygons.list;
         listsel = polygons.selection;
         displaystatus = polygons.display;

         set(h_list, ...
            'String',listitems, ...
            'Value',listsel, ...
            'UserData',polygons)

         set(h_display,'Value',displaystatus)

         set(h_undo,'UserData',[])

         poly_mgr('display')  %update figure polygons

      end

   case 'display'

      h_color = findobj(h_dlg,'Tag','txtColor');
      polycolor = get(h_color,'ForegroundColor');

      h_wid = findobj(h_dlg,'Tag','editWidth');
      widstr = deblank(get(h_wid,'String'));
      if ~isempty(widstr)
         widthval = str2num(widstr);
         if isempty(widthval)
            widthval = 1;
            set(h_wid,'String','1')
         end
      else
         set(h_wid,'String','1')
         widthval = 1;
      end

      h_showctr = findobj(h_dlg,'Tag','chkShowCtr');
      showctr = get(h_showctr,'value');

      %update stored polygon data
      polygons.width = widthval;
      polygons.color = polycolor;
      polygons.showcenter = showctr;
      set(h_list,'UserData',polygons)
      if ~isempty(h_poly)
         set(h_poly,'UserData',polygons)
      end
      hotclr = [0 1 0];
      coldclr = get(h_undo,'BackgroundColor');

      if displaystatus == 1
         set(h_display,'BackgroundColor',hotclr)
         polygons.display = 1;
      else
         set(h_display,'BackgroundColor',coldclr)
         polygons.display = 0;
      end

      %update stored values
      polygons.selection = listsel;
      set(h_list,'UserData',polygons)
      if ~isempty(h_poly)
         set(h_poly,'UserData',polygons)
      end

      %get first non-legend axis handle on map fig
      try
         h_axes = findobj(h_fig,'Type','axes');
      catch
         h_axes = [];
      end
      h_ax = [];
      if ~isempty(h_axes)
         for n = 1:length(h_axes)
            if strcmp(get(h_axes(n),'Tag'),'legend') ~= 1
               h_ax = h_axes(n);
               break
            end
         end
      end

      if ~isempty(h_ax)

         %clear existing polygons
         h = findobj(h_ax,'Tag','polylines');
         if ~isempty(h)
            delete(h)
         end

         if displaystatus == 1  %show polygons

            if ~isempty(data)

               if ~iscell(data)
                  data = {data};
                  ctr = {ctr};
               end

               for n = 1:length(data)

                  pts = data{n};
                  polyctr = ctr{n};

                  if ~isempty(pts) & length(find(n==listsel)) == 1

                     line('Parent',h_ax, ...
                        'XData',pts(:,1), ...
                        'YData',pts(:,2), ...
                        'LineStyle','-', ...
                        'LineWidth',widthval, ...
                        'Marker','none', ...
                        'Color',polycolor, ...
                        'Tag','polylines');

                     if showctr == 1
                        line('Parent',h_ax, ...
                           'XData',polyctr(:,1), ...
                           'YData',polyctr(:,2), ...
                           'LineStyle','none', ...
                           'Marker','d', ...
                           'Color',polycolor, ...
                           'Tag','polylines');
                     end

                  end

               end

            end

         end

      end

   case 'create'

      h_create = findobj(h_dlg,'Tag','cmdCreate');
      set(h_create,'UserData',[])
      newpoly('init','poly_mgr(''newpoly'')',h_fig,h_create)

   case 'edit'  %initialize polygon editor

      if length(listsel) == 1
         h_edit = findobj(h_dlg,'Tag','cmdEdit');
         set(h_edit,'UserData',[])
         str = polygons.list{listsel};
         if ~isempty(strfind(str,'circle'))
            style = 'circle';
         elseif ~isempty(strfind(str,'rectangle'))
            style = 'rectangle';
         elseif ~isempty(strfind(str,'freeform'))
            style = 'freeform';
         else
            style = 'polygon';
         end
         if strcmp(style,'circle') | strcmp(style,'rectangle')
            oldpolydata = [polygons.list(listsel),{style},{datestr(now)},polygons.data(listsel)];
            polyvert('init',oldpolydata,'poly_mgr(''edit2'')',h_dlg,h_edit);
         else
            edit_polygon('init',polygons.data{listsel},polygons.list{listsel},datestr(now,1),h_fig)
         end
      end

   case 'edit2'  %process polygon edits

      h_edit = findobj(h_dlg,'Tag','cmdEdit');
      newpolydata = get(h_edit,'UserData');

      if ~isempty(newpolydata)
         set(h_edit,'UserData',[]);
         I = find(strcmp(polygons.list,newpolydata{1}));
         if length(I) == 1
            newdata = newpolydata{4};
            olddata = polygons.data{I};
            update = 0;
            if size(newdata,1) ~= size(olddata,1)
               update = 1;
            elseif sum(sum(newdata)) ~= sum(sum(olddata))
               update = 1;
            end
            if update == 1
               polygons.data{I} = newpolydata{4};
               sitename = strtok(newpolydata{1},'(');
               polygons.list{I} = [deblank(sitename),'  (',newpolydata{2},', ',datestr(now,1),')'];
               set(h_list, ...
                  'String',polygons.list, ...
                  'UserData',polygons)
               drawnow
               poly_mgr('display')
            end
         else
            messagebox('init','The original polygon was not found - edit cancelled',[],'Error',[.9 .9 .9]);
         end
      end

   case 'newpoly'  %add new polygon data from external functions

      h_create = findobj(h_dlg,'Tag','cmdCreate');
      newdata = get(h_create,'UserData');

      if ~isempty(newdata)

         if isempty(strfind(newdata{1},'('))
            newname = [newdata{1} '  (' newdata{2} ', ' strtok(newdata{3}) ')'];
         else
            newname = newdata{1};
         end
         newpolygon = newdata{4};

         if ~isempty(newpolygon)

            set(h_undo,'UserData',polygons)  %buffer for undo

            newctr = geocenter(newpolygon);

            if ~isempty(listitems)
               if ~iscell(listitems)
                  listitems = {listitems};
               end
               if ~iscell(data)
                  data = {data};
               end
               if ~iscell(ctr)
                  ctr = {ctr};
               end
               listitems = [listitems {newname}];
               polygons.list = listitems;
               polygons.data = [data {newpolygon}];
               polygons.center = [ctr {newctr}];
               polygons.selection = [polygons.selection length(listitems)];
            else
               listitems = newname;
               polygons = struct('list','', ...
                  'data','', ...
                  'center','', ...
                  'selection',1, ...
                  'display',displaystatus);
               polygons.list = {listitems};
               polygons.data = {newpolygon};
               polygons.center = {newctr};
            end

            set(h_list, ...
               'String',listitems, ...
               'Value',polygons.selection, ...
               'UserData',polygons)
            drawnow

            poly_mgr('display')

         end

      end

   case 'rename'

      if length(listsel) == 1
         h_rename = findobj(h_dlg,'Tag','cmdRename');
         poly_title('init',polygons.list{listsel},h_rename,'poly_mgr(''newtitle'')')
      end

   case 'newtitle'

      h_rename = findobj(h_dlg,'Tag','cmdRename');
      data = get(h_rename,'UserData');
      set(h_rename,'UserData',[])
      if isstruct(data)
         Imatch = find(strcmp(polygons.list,data.old));
      else
         Imatch = [];
      end

      if ~isempty(Imatch)
         polygons.list{Imatch(end)} = data.new;
         set(h_list,'String',polygons.list,'UserData',polygons)
         if ~isempty(h_poly)
            set(h_poly,'UserData',polygons)
         end
         drawnow
      end

   case 'color'

      h_color = findobj(h_dlg,'Tag','txtColor');
      fg = get(h_color,'ForegroundColor');

      c = uisetcolor(fg,'Select a polygon color');

      if length(c) == 3

         if sum(c==[1 1 1]) == 3
            bg = [0 0 0];
         else
            bg = [1 1 1];
         end

         set(h_color, ...
            'ForegroundColor',c, ...
            'BackgroundColor',bg)

         poly_mgr('display')

      end

   end

end
return


%subfunction to reproject polygon data to match map coordinate system
function polygons = check_coord_system(h_map,polygons)

polydata = polygons.data;
if ~isempty(polydata)
   coords = polygons.data{1};
   if ~isempty(coords)
      polycenter = polygons.center;
      xlim = get(get(h_map,'CurrentAxes'),'XLim');  %get current axis limits
      if abs(xlim(1)) > 180  %check for UTM
         if max(abs(coords(:,1))) <= 180  %check for degrees, convert to utm
            for n = 1:length(polydata)
               coords = polydata{n};
               center = polycenter{n};
               if ~isempty(coords)
                  [z,utm_e,utm_n] = deg2utm(coords(:,1),coords(:,2));
                  coords = [utm_e,utm_n];
               end
               if ~isempty(center)
                  [z,utm_e,utm_n] = deg2utm(center(1),center(2));
                  center = [utm_e,utm_n];
               end
               polydata{n} = coords;
               polycenter{n} = center;
            end
            polygons.data = polydata;  %update cached polygons
            polygons.center = polycenter;  %update cached centers
         end
      else  %check for deg
         if max(abs(coords(:,1))) > 180  %check for utm, convert to deg
            for n = 1:length(polydata)
               coords = polydata{n};
               center = polycenter{n};
               if ~isempty(coords)
                  [lon,lat] = utm2deg(17,coords(:,1),coords(:,2));
                  coords = [lon,lat];
               end
               if ~isempty(coords)
                  [lon,lat] = utm2deg(17,coords(:,1),coords(:,2));
                  center = [lon,lat];
               end
               polydata{n} = coords;
               polycenter{n} = center;
            end
            polygons.data = polydata;  %update cached polygons
            polygons.center = polycenter;  %update cached centers
         end
      end
   end
end
