function mapmenu(op)
%Switchyard function to create custom map menu and handle callbacks
%
%syntax: mapmenu(op)
%
%input:
%  op = operation
%    'init' = create menu items
%    'delete' = delete menu items
%    'replace = replace/update menu items
%
%output:
%  none
%
%(c)2002-2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 04-May-2015
%
%(Dependencies:  mapbuttons.m, mapclick.m, gpsaxis.m, mapticks.m, mapax.m, degmins.m)

if ~exist('op','var')
   op = 'init';
end

h_fig = gcf;
h_ax = findobj(gcf,'Tag','mapplot');

axlims = axis;
if axlims(1) >= -180 && axlims(2) <= 180 && axlims(3) >= -90 && axlims(4) <= 90  %check for latlon
   tickmode = 'deg';
   tickmodevis = 'on';
else
   tickmode = 'utm';
   tickmodevis = 'off';
end

switch op  %handle callbacks

   case 'init'  %build menu

      h_menu = uimenu('Parent',h_fig, ...
         'Label','MapTools', ...
         'Tag','maptools');

      h_load = uimenu('Parent',h_menu, ...
         'Label','Load Map', ...
         'UserData',pwd, ...
         'Tag','mnuLoad');

      uimenu('Parent',h_load, ...
         'Label','Replace Existing Map', ...
         'Callback','mapmenu(''loadover'')');

      uimenu('Parent',h_load, ...
         'Label','Open in New Window', ...
         'Callback','mapmenu(''loadnew'')');

      h_import = uimenu('Parent',h_menu, ...
         'Label','Import Map', ...
         'Visible','off');

      h_importover = uimenu('Parent',h_import, ...
         'Label','Replace Existing Map');

      uimenu('Parent',h_importover, ...
         'Label','Lines', ...
         'Callback','mapmenu(''importoverl'')');

      uimenu('Parent',h_importover, ...
         'Label','Filled Polygons (slower)', ...
         'Callback','mapmenu(''importoverf'')');

      h_importon = uimenu('Parent',h_import, ...
         'Label','Overlay Map');

      uimenu('Parent',h_importon, ...
         'Label','Lines', ...
         'Callback','mapmenu(''importonl'')');

      uimenu('Parent',h_importon, ...
         'Label','Filled Polygons (slower)', ...
         'Callback','mapmenu(''importonf'')');

      uimenu('Parent',h_menu, ...
         'Label','Save Map', ...
         'Callback','mapmenu(''save'')', ...
         'UserData',pwd, ...
         'Tag','mnuSave');

      h_export = uimenu('Parent',h_menu, ...
         'Label','Export Map');

      uimenu('Parent',h_export, ...
         'Label','Copy to Clipboard', ...
         'Callback','print -noui -dmeta');

      h_ExpPS = uimenu('Parent',h_export, ...
         'Separator','on', ...
         'Label','Postscript file');

      h_ExpPNG = uimenu('Parent',h_export, ...
         'Label','PNG file');

      h_ExpJpeg = uimenu('Parent',h_export, ...
         'Label','JPeg file');

      h_ExpTiff = uimenu('Parent',h_export, ...
         'Label','TIFF file');

      uimenu('Parent',h_ExpPS, ...
         'Label','Postscript (color)', ...
         'Callback','exportfig(''psc'');');

      uimenu('Parent',h_ExpPS, ...
         'Label','Postscript (monochrome)', ...
         'Callback','exportfig(''psbw'');');

      uimenu('Parent',h_ExpPS, ...
         'Separator','on', ...
         'Label','EPS level 1 (color)', ...
         'Callback','exportfig(''epsc1'');');

      uimenu('Parent',h_ExpPS, ...
         'Label','EPS level 1 (monochrome)', ...
         'Callback','exportfig(''epsbw1'');');

      uimenu('Parent',h_ExpPS, ...
         'Separator','on', ...
         'Label','EPS level 2 (color)', ...
         'Callback','exportfig(''epsc2'');');

      uimenu('Parent',h_ExpPS, ...
         'Label','EPS level 2 (monochrome)', ...
         'Callback','exportfig(''epsbw2'');');

      uimenu('Parent',h_ExpPNG, ...
         'Label','Low Resolution (96dpi)', ...
         'Callback','exportfig(''pnglow'');');

      uimenu('Parent',h_ExpPNG, ...
         'Label','Medium Resolution (150dpi)', ...
         'Callback','exportfig(''pngmed'');');

      uimenu('Parent',h_ExpPNG, ...
         'Label','High Resolution (300dpi)', ...
         'Callback','exportfig(''pnghigh'');');

      uimenu('Parent',h_ExpPNG, ...
         'Label','Super High Resolution (600dpi)', ...
         'Callback','exportfig(''pngsuper'');');

      uimenu('Parent',h_ExpJpeg, ...
         'Label','Low Resolution (96 dpi)', ...
         'Callback','exportfig(''jpeglow'');');

      uimenu('Parent',h_ExpJpeg, ...
         'Label','Normal Resolution (150dpi)', ...
         'Callback','exportfig(''jpegmed'');');

      uimenu('Parent',h_ExpJpeg, ...
         'Label','High Resolution (300dpi)', ...
         'Callback','exportfig(''jpeghigh'');');

      uimenu('Parent',h_ExpJpeg, ...
         'Label','Super High Resolution (600dpi)', ...
         'Callback','exportfig(''jpegsuper'');');

      h_ExpTiffNoComp = uimenu('Parent',h_ExpTiff, ...
         'Label','No Compression');

      h_ExpTiffComp = uimenu('Parent',h_ExpTiff, ...
         'Label','LZW Compression');

      uimenu('Parent',h_ExpTiffNoComp, ...
         'Label','Low Resolution (96dpi)', ...
         'Callback','exportfig(''tifflnc'');');

      uimenu('Parent',h_ExpTiffNoComp, ...
         'Label','Medium Resolution (150dpi)', ...
         'Callback','exportfig(''tiffmnc'');');

      uimenu('Parent',h_ExpTiffNoComp, ...
         'Label','High Resolution (300dpi)', ...
         'Callback','exportfig(''tiffhnc'');');

      uimenu('Parent',h_ExpTiffNoComp, ...
         'Label','Super High Resolution (600dpi)', ...
         'Callback','exportfig(''tiffhnc'');');

      uimenu('Parent',h_ExpTiffComp, ...
         'Label','Low Resolution (96dpi)', ...
         'Callback','exportfig(''tifflc'');');

      uimenu('Parent',h_ExpTiffComp, ...
         'Label','Medium Resolution (150dpi)', ...
         'Callback','exportfig(''tiffmc'');');

      uimenu('Parent',h_ExpTiffComp, ...
         'Label','High Resolution (300dpi)', ...
         'Callback','exportfig(''tiffhc'');');

      uimenu('Parent',h_ExpTiffComp, ...
         'Label','Super High Resolution (600dpi)', ...
         'Callback','exportfig(''tiffhc'');');

      uimenu('Parent',h_export, ...
         'Label','Matlab Plot File', ...
         'Callback','exportfig(''fig'');');

      h_view = uimenu('Parent',h_menu, ...
         'Label','Map View Options', ...
         'Separator','on', ...
         'Tag','mnuViewOpt');

      data = get(h_fig,'UserData');
      if ~isstruct(data)
         data = struct('mode','line', ...
            'mapedge',[0 0 0], ...
            'mapfill',[1 1 1], ...
            'bgcolor',[1 1 1]);
      end
      if strcmp(data.mode,'line')
         linechk = 'on';
         fillchk = 'off';
      else
         linechk = 'off';
         fillchk = 'on';
      end

      uimenu('Parent',h_view, ...
         'Label','Simple Line Format (faster)', ...
         'Checked',linechk, ...
         'Tag','mnuViewLine', ...
         'Callback','mapmenu(''viewline'')');

      uimenu('Parent',h_view, ...
         'Label','Filled Map Format (requires closed polygons)', ...
         'Checked',fillchk, ...
         'Tag','mnuViewFill', ...
         'Callback','mapmenu(''viewfill'')');

      uimenu('Parent',h_view, ...
         'Label','Set Map Colors', ...
         'Separator','on', ...
         'Callback','mapcolor', ...
         'Tag','mnuColor', ...
         'UserData',[{data.mapedge},{data.mapfill},{data.bgcolor}]);

      h_mouse = uimenu('Parent',h_menu, ...
         'Label','Mouse Function', ...
         'Tag','mnu_mouse');

      uimenu('Parent',h_mouse, ...
         'Label','Zoom (click to change magnification)', ...
         'Tag','mnu_zoom', ...
         'Checked','on', ...
         'Callback','mapmenu(''zoom'')');

      uimenu('Parent',h_mouse, ...
         'Label','Area Drag (drag to change magnification)', ...
         'Tag','mnu_drag', ...
         'Checked','off', ...
         'Callback','mapmenu(''drag'')');

      uimenu('Parent',h_mouse, ...
         'Label','Pan (click to center on coordinates)', ...
         'Tag','mnu_pan', ...
         'Checked','off', ...
         'Callback','mapmenu(''pan'')');

      uimenu('Parent',h_mouse, ...
         'Label','Probe (click to display coordinates)', ...
         'Tag','mnu_probe', ...
         'Checked','off', ...
         'Callback','mapmenu(''probe'')');

      uimenu('Parent',h_mouse, ...
         'Label','Resize Axis within Plot Area', ...
         'Tag','mnu_resize', ...
         'Checked','off', ...
         'Callback','mapmenu(''resize'')');

      uimenu('Parent',h_menu, ...
         'Separator','on', ...
         'Label','Create Site Polygon', ...
         'Callback','edit_polygon');

      uimenu('Parent',h_menu, ...
         'Label','View Site Polygons', ...
         'Callback','poly_mgr', ...
         'Tag','mnuPolygons');

      uimenu('Parent',h_menu, ...
         'Separator','on', ...
         'Label','Annotate Map', ...
         'Callback','addnote');

      h_distbar = uimenu('Parent',h_menu, ...
         'Label','Map Scale', ...
         'Tag','mnu_distbar');

      uimenu('Parent',h_distbar, ...
         'Label','Add', ...
         'Callback','mapscale', ...
         'Tag','mapscale', ...
         'Enable','on', ...
         'UserData',[3 1 .4 9]);

      uimenu('Parent',h_distbar, ...
         'Label','Remove', ...
         'Callback','mapscale(''remove'')', ...
         'Tag','distbar_rem');

      h_compass = uimenu('Parent',h_menu, ...
         'Label','Compass Rose', ...
         'Tag','compass');

      h_compass_add = uimenu('Parent',h_compass, ...
         'Label','Add', ...
         'Tag','compass_add');

      uimenu('Parent',h_compass_add, ...
         'Label','Small', ...
         'Callback','mapmenu(''compass'')', ...
         'Tag','compass_small');

      uimenu('Parent',h_compass_add, ...
         'Label','Medium', ...
         'Callback','mapmenu(''compass'')', ...
         'Tag','compass_medium');

      uimenu('Parent',h_compass_add, ...
         'Label','Large', ...
         'Callback','mapmenu(''compass'')', ...
         'Tag','compass_large');

      uimenu('Parent',h_compass, ...
         'Label','Remove', ...
         'Callback','mapmenu(''compass'')', ...
         'Tag','compass_delete');

      uimenu('Parent',h_menu, ...
         'Label','Create Inset Map', ...
         'Callback','insetmap');

      uimenu('Parent',h_menu, ...
         'Label','Display/Hide CTD Stations', ...
         'Separator','on', ...
         'Callback','ctd_stations', ...
         'Tag','ctd_stations', ...
         'UserData',struct('init',[],'rivermat',[]));

      gce_ed = exist('ui_editor');
      if gce_ed == 2 || gce_ed == 6

         h_locations = uimenu('Parent',h_menu, ...
            'Label','Edit Plotted Locations', ...
            'Tag','locations');

         uimenu('Parent',h_locations, ...
            'Label','Remove', ...
            'Callback','mapmenu(''remove_pts'')', ...
            'Tag','remove_pts');

         uimenu('Parent',h_locations, ...
            'Label','Reposition', ...
            'Callback','mapmenu(''reposition'')', ...
            'Tag','reposition');

         h_ctddataset = uimenu('Parent',h_menu, ...
            'Label','Create CTD Station Dataset', ...
            'Tag','ctddataset');

         uimenu('Parent',h_ctddataset, ...
            'Label','1km Intervals', ...
            'Callback','mapmenu(''ctddata'')', ...
            'UserData',1, ...
            'Tag','ctddataset1');

         uimenu('Parent',h_ctddataset, ...
            'Label','2km Intervals', ...
            'Callback','mapmenu(''ctddata'')', ...
            'UserData',2, ...
            'Tag','ctddataset2');

         uimenu('Parent',h_ctddataset, ...
            'Label','3km Intervals', ...
            'Callback','mapmenu(''ctddata'')', ...
            'UserData',3, ...
            'Tag','ctddataset3');

         uimenu('Parent',h_ctddataset, ...
            'Label','4km Intervals', ...
            'Callback','mapmenu(''ctddata'')', ...
            'UserData',4, ...
            'Tag','ctddataset4');

         uimenu('Parent',h_ctddataset, ...
            'Label','5km Intervals', ...
            'Callback','mapmenu(''ctddata'')', ...
            'UserData',5, ...
            'Tag','ctddataset5');

      end

      uimenu('Parent',h_menu, ...
         'Label','Axis Limits', ...
         'Separator','on', ...
         'Tag','mapaxislims', ...
         'Callback','mapaxis');

      uimenu('Parent',h_menu, ...
         'Label','Axis Gridlines', ...
         'Tag','mnuGrid', ...
         'Callback','mapmenu(''grid'')');

      uimenu('Parent',h_menu, ...
         'Label','Axis Color', ...
         'Callback','mapmenu(''axiscolor'')', ...
         'Tag','mnuAxisColor');

      h_ticks = uimenu('Parent',h_menu, ...
         'Label','Tick Format', ...
         'Separator','on', ...
         'Tag','mnu_ticks');

      uimenu('Parent',h_ticks, ...
         'Label','Degrees, Minutes', ...
         'Tag','mnu_tickdm', ...
         'Enable',tickmodevis, ...
         'Checked',tickmodevis, ...
         'Callback','mapmenu(''tickdm'')');

      uimenu('Parent',h_ticks, ...
         'Label','Decimal Degrees', ...
         'Tag','mnu_tickdd', ...
         'Checked','off', ...
         'Enable',tickmodevis, ...
         'Callback','mapmenu(''tickdd'')');

      if strcmp(tickmodevis,'on')
         checked = 'off';
      else
         checked = 'on';
      end
      uimenu('Parent',h_ticks, ...
         'Label','Unformatted', ...
         'Tag','mnu_ticknon', ...
         'Checked',checked, ...
         'Callback','mapmenu(''ticknon'')');

      uimenu('Parent',h_ticks, ...
         'Label','Hide Ticks', ...
         'Separator','on', ...
         'Tag','mnu_tickoff', ...
         'Checked','off', ...
         'Callback','mapmenu(''tickoff'')');

      uimenu('Parent',h_menu, ...
         'Label','Tick Font', ...
         'Callback','mapmenu(''tickfont'')', ...
         'Tag','mnuTickFont');

      uimenu('Parent',h_menu, ...
         'Label','Reset Boundaries', ...
         'Callback','mapbuttons(''reset'')');

      uimenu('Parent',h_menu, ...
         'Label','Hide Toolbar', ...
         'Separator','on', ...
         'Tag','mnu_showhide', ...
         'Callback','mapmenu(''showhide'')');

      h_refresuimenu('Parent',h_menu, ...
         'Label','Refresh Figure', ...
         'Callback','r12_axistitles; refresh(gcf)');

   case 'zoom'  %select zoom function

      findobj(h_fig,'Tag','mnu_mouse');
      h_mnu = findobj(h,'Tag','mnu_zoom');
      h_chk = findobj(h,'Checked','on');
      h_btn = findobj(h_fig,'Tag','mapbtn_zoom');

      set(h_chk,'Checked','off')

      if h_mnu == h_chk  %zoom already on
         set(h_btn,'Value',0)
      else
         set(h_btn,'Value',1)
      end

      %sync toolbar - use toolbar to implement
      eval(get(h_btn,'Callback'))

   case 'drag'  %select drag function

      findobj(h_fig,'Tag','mnu_mouse');
      h_mnu = findobj(h,'Tag','mnu_drag');
      h_chk = findobj(h,'Checked','on');
      h_btn = findobj(h_fig,'Tag','mapbtn_drag');

      set(h_chk,'Checked','off')

      if h_mnu == h_chk  %zoom already on
         set(h_btn,'Value',0)
      else
         set(h_btn,'Value',1)
      end

      %sync toolbar - use toolbar to implement
      eval(get(h_btn,'Callback'))

   case 'pan'  %select pan function

      findobj(h_fig,'Tag','mnu_mouse');
      h_mnu = findobj(h,'Tag','mnu_pan');
      h_chk = findobj(h,'Checked','on');
      h_btn = findobj(h_fig,'Tag','mapbtn_pan');

      set(h_chk,'Checked','off')

      if h_mnu == h_chk  %zoom already on
         set(h_btn,'Value',0)
      else
         set(h_btn,'Value',1)
      end

      %sync toolbar - use toolbar to implement
      eval(get(h_btn,'Callback'))

   case 'probe'  %select probe function

      findobj(h_fig,'Tag','mnu_mouse');
      h_mnu = findobj(h,'Tag','mnu_probe');
      h_chk = findobj(h,'Checked','on');
      h_btn = findobj(h_fig,'Tag','mapbtn_probe');

      if ~isempty(h_btn)
         set(h_chk,'Checked','off')

         if h_mnu == h_chk  %zoom already on
            set(h_btn,'Value',0)
         else
            set(h_btn,'Value',1)
         end

         %sync toolbar - use toolbar to implement
         eval(get(h_btn,'Callback'))
      end

   case 'resize'  %select axis resize function

      findobj(h_fig,'Tag','mnu_mouse');
      h_mnu = findobj(h,'Tag','mnu_resize');
      h_chk = findobj(h,'Checked','on');
      h_btn = findobj(h_fig,'Tag','mapbtn_resize');

      set(h_chk,'Checked','off')

      if h_mnu == h_chk  %zoom already on
         set(h_btn,'Value',0)
      else
         set(h_btn,'Value',1)
      end

      %sync toolbar - use toolbar to implement
      eval(get(h_btn,'Callback'))

   case 'tickdm'  %degrees, minutes tick format

      if strcmp(tickmode,'deg')
         findobj(h_fig,'Tag','mnu_tickdm');
         set(h,'Checked','on')

         findobj(h_fig,'Tag','mnu_tickdd');
         set(h,'Checked','off')

         findobj(h_fig,'Tag','mnu_ticknon');
         set(h,'Checked','off')

         findobj(h_fig,'Tag','mnu_tickoff');
         set(h,'Checked','off')

         %sync toolbar - use toolbar to implement
         findobj(h_fig,'Tag','mapbtn_tickdms');
         set(h,'Value',1)
         mapbuttons('tickdms')
      end

   case 'tickdd'  %decimal degrees tick format

      if strcmp(tickmode,'deg')
         findobj(h_fig,'Tag','mnu_tickdm');
         set(h,'Checked','off')

         findobj(h_fig,'Tag','mnu_tickdd');
         set(h,'Checked','on')

         findobj(h_fig,'Tag','mnu_ticknon');
         set(h,'Checked','off')

         findobj(h_fig,'Tag','mnu_tickoff');
         set(h,'Checked','off')

         %sync toolbar - use toolbar to implement
         findobj(h_fig,'Tag','mapbtn_tickdeg');
         set(h,'Value',1)
         mapbuttons('tickdeg')
      end

   case 'ticknon'  %unformatted ticks

      findobj(h_fig,'Tag','mnu_tickdm');
      set(h,'Checked','off')

      findobj(h_fig,'Tag','mnu_tickdd');
      set(h,'Checked','off')

      findobj(h_fig,'Tag','mnu_ticknon');
      set(h,'Checked','on')

      findobj(h_fig,'Tag','mnu_tickoff');
      set(h,'Checked','off')

      %sync toolbar - use toolbar to implement
      findobj(h_fig,'Tag','mapbtn_ticknon');
      set(h,'Value',1)
      mapbuttons('ticknon')

   case 'tickoff'  %remove ticks, ticklabels

      findobj(h_fig,'Tag','mnu_tickdm');
      set(h,'Checked','off')

      findobj(h_fig,'Tag','mnu_tickdd');
      set(h,'Checked','off')

      findobj(h_fig,'Tag','mnu_ticknon');
      set(h,'Checked','off')

      findobj(h_fig,'Tag','mnu_tickoff');
      set(h,'Checked','on')

      findobj(h_fig,'Tag','mapbtn_tickdms');
      set(h,'Value',0)

      findobj(h_fig,'Tag','mapbtn_tickdeg');
      set(h,'Value',0)

      findobj(h_fig,'Tag','mapbtn_ticknon');
      set(h,'Value',0)

      mapbuttons('ticknon')

   case 'remove_pts'  %remove point labels

      h_pts = findobj(gca,'Tag','pointlabels');
      if ~isempty(h_pts)
         delete(h_pts)
      end

   case 'reposition'  %reposition point labels

      h_lbls = findobj(gca,'Tag','pointlabels','Type','text');

      if ~isempty(h_lbls)
         ax = axis;
         hoffset = abs(diff(ax(1:2))) ./ 100;
         voffset = abs(diff(ax(3:4))) ./ 1000;
         for n = 1:length(h_lbls)
            offsets = get(h_lbls(n),'UserData');
            if sum(offsets) > 0
               pos = get(h_lbls(n),'Position');
               set(h_lbls(n),'Position',[pos(1)-offsets(1)+hoffset pos(2)-offsets(2)+voffset 0], ...
                  'UserData',[hoffset,voffset])
            end
         end
         drawnow
      end

   case 'grid'

      h_grid = findobj(h_fig,'Tag','mnuGrid');

      if strcmp(get(h_ax,'XGrid'),'off')
         set(h_grid,'Checked','on')
         set(h_ax,'XGrid','on','YGrid','on')
      else
         set(h_grid,'Checked','off')
         set(h_ax,'XGrid','off','YGrid','off')
      end

   case 'showhide'  %toggle toolbar visibility

      findobj(h_fig,'Tag','mnu_showhide');
      lbl = get(h,'Label');

      if strcmp(lbl,'Hide Toolbar')
         set(h,'Label','Show Toolbar')
         cb = 'mapbuttons(''hide'')';
      else
         set(h,'Label','Hide Toolbar')
         cb = 'mapbuttons(''show'')';
      end

      eval(cb)

   case 'refreshticks'  %synchronize menu checks with toolbar state

      findobj(h_fig,'Tag','mnu_ticks');
      h_check = findobj(h,'Checked','on');
      set(h_check,'Checked','off')

      ticktype = get(h_ax,'UserData');

      if strcmp(ticktype,'degmin')
         h_new = findobj(h_fig,'Tag','mnu_tickdm');
      elseif strcmp(ticktype,'decdeg')
         h_new = findobj(h_fig,'Tag','mnu_tickdd');
      elseif strcmp(ticktype,'none')
         h_new = findobj(h_fig,'Tag','mnu_ticknon');
      else
         h_new = findobj(h_fig,'Tag','mnu_tickoff');
      end

      set(h_new,'Checked','on')

   case 'save'

      curpatpwd;
      lastpatcurpath;

      %get cached path
      h_save = findobj(gcf,'Tag','mnuSave');
      if ~isempty(h_save)
         lastpatget(h_save,'UserData');
         if exist(lastpath) ~= 7
            lastpatcurpath;
            set(h_save,'UserData',curpath)  %reset path cache if invalid
         end
      end

      cd(lastpath)
      [fn,pn] = uiputfile('*.fig','Select name and location for file');
      drawnow

      if fn ~= 0
         [tmp,fn1] = fileparts(fn);
         cd(pn)
         saveas(h_fig,[fn1 '.fig'],'fig');
         if ~isempty(h_save)
            set(h_save,'UserData',pn)  %cache save path
         end
      end

      cd(curpath)

   case 'loadover'

      curpatpwd;
      lastpatcurpath;

      %get cached path
      h_load = findobj(gcf,'Tag','mnuLoad');
      if ~isempty(h_load)
         lastpatget(h_load,'UserData');
         if exist(lastpath) ~= 7
            lastpatcurpath;
            set(h_load,'UserData',curpath)  %reset path cache if invalid
         end
      end

      cd(lastpath)
      [fn,pn] = uigetfile('*.fig','Select a figure file to load');
      drawnow

      if fn ~= 0

         [tmp,fn2,ext] = fileparts(fn);

         if strcmp(ext,'.fig') == 1
            h_save = findobj(gcf,'Tag','mnuSave');
            if ~isempty(h_save)
               savepatget(h_save,'UserData');
            end
            cd(pn)
            open(fn)
            center_fig
            r12_axistitles
            close(h_fig)
            h_load = findobj(gcf,'Tag','mnuLoad');
            if ~isempty(h_load)
               set(h_load,'UserData',pn)
            end
            h_save = findobj(gcf,'Tag','mnuSave');
            if ~isempty(h_save)
               set(h_save,'UserData',savepath);
            end
         else
            errorbox('init','Invalid file type')
         end

      end

      cd(curpath)

   case 'loadnew'

      curpatpwd;
      lastpatcurpath;

      %get cached path
      h_load = findobj(gcf,'Tag','mnuSave');
      if ~isempty(h_load)
         lastpatget(h_load,'UserData');
         if isdir(lastpath)
            lastpatcurpath;
            set(h_load,'UserData',curpath)  %reset path cache if invalid
         end
      end

      cd(lastpath)
      [fn,pn] = uigetfile('*.fig','Select a figure file to load');
      drawnow

      if fn ~= 0

         [tmp,fn2,ext] = fileparts(fn);

         if strcmp(ext,'.fig') == 1
            h_save = findobj(gcf,'Tag','mnuSave');
            if ~isempty(h_save)
               savepatget(h_save,'UserData');
            end
            eval(['cd ''' pn ''''])
            open(fn)
            center_fig
            r12_axistitles
            h_load = findobj(gcf,'Tag','mnuLoad');
            if ~isempty(h_load)
               set(h_load,'UserData',pn)
            end
            h_save = findobj(gcf,'Tag','mnuSave');
            if ~isempty(h_save)
               set(h_save,'UserData',savepath);
            end
         else
            errorbox('init','Invalid file type')
         end

      end

      eval(['cd ''' curpath ''''])

   case 'color'

      h_color = findobj(h_fig,'Tag','mnuColor');
      cdata = get(h_color,'UserData');

      h_line = findobj(h_ax,'Tag','mapline');
      if ~isempty(h_line)
         set(h_line,'Color',cdata{1})
      end

      h_fill = findobj(h_ax,'Tag','mapfill');
      if ~isempty(h_fill)
         set(h_fill,'EdgeColor',cdata{1},'FaceColor',cdata{2})
      end

      set(h_ax,'Color',cdata{3})

      drawnow

   case 'viewline'

      h_viewline = findobj(h_fig,'Tag','mnuViewLine');
      h_viewfill = findobj(h_fig,'Tag','mnuViewFill');

      set(h_viewline,'Checked','on')
      set(h_viewfill,'Checked','off')

      mapmenu('redraw')

   case 'viewfill'

      h_viewline = findobj(h_fig,'Tag','mnuViewLine');
      h_viewfill = findobj(h_fig,'Tag','mnuViewFill');

      set(h_viewline,'Checked','off')
      set(h_viewfill,'Checked','on')

      mapmenu('redraw')

   case 'delete'  %delete menu items

      h_menu = findobj(gcf,'Label','MapTools');
      findobj(h_menu);
      delete(h)

   case 'replace'  %replace existing menu (update saved figures)

      h_menu = findobj(gcf,'Label','MapTools');

      if ~isempty(h_menu)
         h_viewline = findobj(gcf,'Tag','mnuViewLine');
         linechk = get(h_viewline,'Checked');
         h_viewfill = findobj(gcf,'Tag','mnuViewFill');
         fillchk = get(h_viewfill,'Checked');
         h_colors = findobj(gcf,'Tag','mnuColor');
         clrdata = get(h_colors,'UserData');
         h_poly = findobj(gcf,'Tag','mnuPolygons');
         poly = get(h_poly,'UserData');
         if strcmp(linechk,'on')
            mode = 'line';
         else
            mode = 'filled';
         end
         data = get(gcf,'UserData');
         if ~isempty(data)
            data.mode = mode;
            data.mapedge = clrdata{1};
            data.mapfill = clrdata{2};
            data.bgcolor = clrdata{3};
         else
            data = struct('mode',mode, ...
               'mapedge',clrdata{1}, ...
               'mapfill',clrdata{2}, ...
               'bgcolor',clrdata{3});
         end
         if ~isfield(data,'axis')
            data.axis = axis;
         end
         if ~isfield(data,'aspectratio')
            if mlversion >= 6
               data.aspectratio = get(gca,'PlotBoxAspectRatio');
            else
               data.aspectratio = get(gca,'AspectRatio');
            end
         end
         if ~isfield(data,'map')
            map = [];
            h_map = findobj(gca,'Tag','mapline');
            if ~isempty(h_map)
               map = [get(h_map(end),'XData')',get(h_map(end),'YData')'];
            end
            data.map = map;
         end
         if ~isfield(data,'bounds')
            map = data.map;
            if ~isempty(map)
               Ivalid = find(~isnan(map(:,1)) & ~isnan(map(:,2)));
            else
               Ivalid = [];
            end
            if ~isempty(Ivalid)
               bounds = [min(map(Ivalid,1)),max(map(Ivalid,1)),min(map(Ivalid,2)),max(map(Ivalid,2))];
            else
               bounds = axis;
            end
            data.bounds = bounds;
         end
         delete(h_menu)
      else
         mode = 'line';
         clrdata = {[0 0 0];[1 1 1];[1 1 1]};
         poly = [];
         data = struct('axis',[], ...
            'aspectratio',[], ...
            'map',[], ...
            'bounds',[], ...
            'mode',mode, ...
            'mapedge',[0 0 0], ...
            'mapfill',[1 1 1], ...
            'bgcolor',[1 1 1]);
         data.axis = gca;
         if mlversion >= 6
            data.aspectratio = get(gca,'PlotBoxAspectRatio');
         else
            data.aspectratio = get(gca,'AspectRatio');
         end
         h_map = findobj(gca,'Tag','mapline');
         if ~isempty(h_map)
            map = [get(h_map(end),'XData')',get(h_map(end),'YData')'];
            data.map = map;
            Ivalid = find(~isnan(map(:,1)) & ~isnan(map(:,2)));
            if ~isempty(Ivalid)
               data.bounds = [min(map(Ivalid,1)),max(map(Ivalid,1)),min(map(Ivalid,2)),max(map(Ivalid,2))];
            else
               data.bounds = gca;
            end
         else
            data.bounds = gca;
         end
         linechk = 'on';
         fillchk = 'off';
      end

      mapmenu

      set(gcf,'userdata',data)

      h_viewline = findobj(gcf,'Tag','mnuViewLine');
      set(h_viewline,'Checked',linechk);

      h_viewfill = findobj(gcf,'Tag','mnuViewFill');
      set(h_viewfill,'Checked',fillchk);

      h_colors = findobj(gcf,'Tag','mnuColor');
      set(h_colors,'UserData',clrdata)

      h_poly = findobj(gcf,'Tag','mnuPolygons');
      set(h_poly,'UserData',poly)

   case 'redraw'

      h_viewline = findobj(h_fig,'Tag','mnuViewLine');
      h_viewfill = findobj(h_fig,'Tag','mnuViewFill');
      h_color = findobj(h_fig,'Tag','mnuColor');

      if strcmp(get(h_viewline,'Checked'),'on')
         mode = 'line';
      else
         mode = 'filled';
      end

      cdata = get(h_color,'UserData');

      data = get(h_fig,'UserData');
      data.mode = mode;
      map = [];
      if isfield(data,'map')
         map = data.map;
      else
         h_map = findobj(gca,'Tag','mapline');
         if ~isempty(h_map)
            map = [get(h_map(end),'XData')',get(h_map(end),'YData')'];
            data.map = map;
            set(h_fig,'UserData',data)
         end
      end

      if ~isempty(map)

         axprop = get(h_ax);

         h_poly = findobj(h_ax,'Tag','polylines','Type','line');
         if ~isempty(h_poly)
            polylines = get(h_poly);
            %remove read-only fields to prevent runtime error recreating lines
            if isfield(polylines,'Type'); polylines = rmfield(polylines,'Type'); end
            if isfield(polylines,'Annotation'); polylines = rmfield(polylines,'Annotation'); end
            if isfield(polylines,'BeingDeleted'); polylines = rmfield(polylines,'BeingDeleted'); end
         else
            polylines = [];
         end

         h_point = findobj(h_ax,'Tag','pointlabels','Type','line');
         if ~isempty(h_point)
            pointlbl = get(h_point);
            pointlbl = rmfield(pointlbl,'Type');
            if isfield(pointlbl,'BeingDeleted')
               pointlbl = rmfield(pointlbl,'BeingDeleted');
            end
         else
            pointlbl = [];
         end

         h_text = findobj(h_ax,'Type','text');
         if ~isempty(h_text)
            textlbl = get(h_text);
            textlbl = rmfield(textlbl,'Type');
            textlbl = rmfield(textlbl,'Extent');
            if isfield(textlbl,'BeingDeleted')
               textlbl = rmfield(textlbl,'BeingDeleted');
            end
         else
            textlbl = [];
         end

         cla
         hold on

         if strcmp(mode,'line')
            line('XData',map(:,1), ...
               'YData',map(:,2), ...
               'LineStyle','-', ...
               'Color',cdata{1}, ...
               'Tag','mapline')
            box on
         else
            fillseg(map,cdata{2},cdata{1});
            set(h,'Tag','mapfill')
            box on
         end

         set(h_ax,'Color',cdata{3})

         drawmode = get(gca,'drawmode');
         set(gca,'drawmode','fast')

         if ~isempty(polylines)
            for n = 1:length(polylines)
               try
                  line(polylines(n));
               catch
               end
            end
         end

         if ~isempty(pointlbl)
            for n = 1:length(pointlbl)
               try
                  line(pointlbl(n));
               catch
               end
            end
         end

         if ~isempty(textlbl)
            for n = 1:length(textlbl)
               try
                  text(textlbl(n));
               end
            end
         end

         set(gca,'drawmode',drawmode)
         set(gcf,'UserData',data)  %update mode setting

      else
         messagebox('init','Original map data could not be retrieved','','Error',[.9 .9 .9])
      end

   case 'tickfont'

      fonts = uisetfont(gca,'Select Axis Label Font Characteristics');

      if isstruct(fonts)
         set(gca,'fontname',fonts.FontName, ...
            'fontunits',fonts.FontUnits, ...
            'fontsize',fonts.FontSize, ...
            'fontweight',fonts.FontWeight, ...
            'fontangle',fonts.FontAngle);
         mapticks
      end

   case 'axiscolor'

      c = uisetcolor(get(gca,'xcolor'));

      if ~isempty(c)
         set(gca,'xcolor',c,'ycolor',c)
         mapticks
      end

   case 'nobar'

      findobj(gca,'tag','distbar');
      if ~isempty(h)
         delete(h)
         drawnow
      end

   case 'ctddata'  %create ctd dataset for editing/plotting

      gce_ed = exist('ui_editor');

      if gce_ed == 2 || gce_ed == 6

         h_cbo = gcbo;
         interval = get(h_cbo,'UserData');

         if interval == 3
            dist_start = -42;
         else
            dist_start = -40;
         end

         [s,msg] = ctd2dataset(interval,dist_start);

         if ~isempty(s)
            ui_editor('init',s)
         else
            messagebox('init',['CTD Data set could not be created (',msg,')'],'','Error',[.9 .9 .9]);
         end

      else
         messagebox('init','This feature requires the GCE Data Toolbox','','Error',[.9 .9 .9]);
      end

   case 'compass'

      tag = get(gcbo,'tag');

      if strcmp(tag,'compass_delete')
         findobj(gca,'tag','compass');
         if ~isempty(h)
            delete(h)
            drawnow
         end
      else
         ax = axis;
         if diff(ax(1:2)) < 180
            ar = get(gca,'plotboxaspectratio');
         else
            ar = [1 1];
         end
         switch tag
            case 'compass_small'
               fact = 20;
               fontsize = 9;
            case 'compass_medium'
               fact = 15;
               fontsize = 11;
            case 'compass_large'
               fact = 10;
               fontsize = 12;
            otherwise
               fact = 0;
               fontsize = 10;
         end
         if fact > 0
            wid = abs(diff(ax(1:2)))./fact .* ar(2);
            ht = abs(diff(ax(3:4)))./fact .* ar(1);
            [x,y,button] = ginput(1);
            if button == 1
               compass_rose(x,y,'Times',fontsize,wid,ht);
            end
            drawnow
         end
      end

end