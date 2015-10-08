function ui_datagrid(op,s,h,cb,colwid,halign,cache)
%Opens a GCE Data Structure into a metadata-aware grid to allow data values to be viewed and edited
%with changes logged to the structure history
%
%syntax: ui_datagrid(op,s,h,cb,colwid,halign,cache)
%
%inputs:
%  op = operation ('init')
%  s = GCE Data Structure to display/edit
%  h = handle of figure or object to use to store a 3-element cell array containing:
%    element 1: the edited data structure
%    element 2: an integer flag indicating whether any changes were made (flag = 1) or not (flag = 0)
%    element 3: a change log cell array for analysis if element 2 = 1
%  cb = function callback to execute after applying edits (note: the edited structure
%    can be returned via callback by referencing the variable 's')
%  colwid = width of grid columns in pixels (default = 100)
%  halign = horizontal alignment of cells:
%    'auto' = automatically determine based on numeric/non-numeric data (default)
%    'right' = right align
%    'left' = left align
%    'center' = center align
%  cache = user data to cache and return via callback function
%    (note: callback must contain a reference to the 'cache' parameter)
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
%last modified: 02-Feb-2015

if nargin == 0
   op = 'init';
elseif isstruct(op)  %assume init if structure passed as first arg
   s = op;
   op = 'init';
end

%check for init
if strcmp(op,'init')

   %validate s parameter
   if exist('s','var') ~= 1 || gce_valid(s,'data') ~= 1 || isempty(s.values) || size(s.values{1},1) == 0
      s = [];
   end

   if ~isempty(s)

      %init ui defaults
      defaults = struct('maxcols',10,'maxrows',25,'logging',100,'halign','auto');
      
      %check for saved defaults, load if present
      if exist('ui_datagrid.mat','file') == 2
         v = load('ui_datagrid.mat');
         if isfield(v,'defaults')
            defaults = v.defaults;  %overwrite with saved defaults if available
         end
      end

      %get screen metrics
      res = get(0,'screensize');

      %validate horizontalalignment argument
      if exist('halign','var') ~= 1
         halign = defaults.halign;
      elseif ~ischar(halign)
         halign = defaults.halign;
      end

      %assign alignment and menu options
      align_auto = 'off';
      align_left = 'off';
      align_right = 'off';
      align_center = 'off';
      if strcmp(halign,'auto')
         align_auto = 'on';
         if length(find(strcmp(s.datatype,'s'))) >= ceil(length(s.name) .* 0.5)
            halign = 'left';  %majority text - use left align
         else
            halign = 'right';
         end
      elseif strcmp(halign,'left')
         align_left = 'on';
      elseif strcmp(halign,'center')
         align_center = 'on';
      else
         halign = 'right';
         align_right = 'on';
      end

      %validate column width argument
      if exist('colwid','var') ~= 1
         colwid = '';
      elseif ~isnumeric(colwid)
         colwid = '';
      end
      if isempty(colwid)
         if length(s.name) < 5
            colwid = 150;
         else
            colwid = 100;
         end
      else
         colwid = min(colwid,floor(res(3)./3));
      end

      %set default grid size
      r = defaults.maxrows;
      c = max(2,min(defaults.maxcols,floor((res(3)-100)/colwid)));

      %get structure parms
      numcols = length(s.values);
      numrows = length(s.values{1});
      c = min(c,numcols);
      r = min(r,max(10,numrows));
      vals = s.values;
      index = (1:numrows)';
      flags = s.flags;
      marks = zeros(size(vals{1},1),1);

      %validate callback, calling function handle
      if exist('h','var') ~= 1
         h = [];
      end

      if exist('cb','var') ~= 1
         cb = '';
         savestr = 'Send to Editor';
         accelstr = 's';
      else
         savestr = 'Return to Editor';
         accelstr = 'r';
      end

      if exist('cache','var') ~= 1
         cache = [];
      end

      %init figure size parms
      figwd = c .* (colwid+1) + 95;
      fight = r .* 21 + 62;

      %init manual row/col setting option arrays
      ar_cols = 5:15;
      ar_rows = (10:5:40);

      if mlversion < 7
         resizeval = 'on';
      else
         resizeval = 'off';
      end

      h_fig = figure( ...
         'visible','off', ...
         'name','Data Editor', ...
         'units','pixels', ...
         'position',[max(0,(res(3)-figwd)./2) max(30,(res(4)-fight)./2) figwd fight], ...
         'color',[0.95 0.95 0.95], ...
         'backingstore','on', ...
         'doublebuffer','on', ...
         'numbertitle','off', ...
         'resize',resizeval, ...
         'toolbar','none', ...
         'menubar','none', ...
         'keypressfcn','figure(gcf)', ...
         'closerequestfcn','ui_datagrid(''close'')', ...
         'tag','dlgDataGrid', ...
         'defaultuicontrolunits','pixels');

      if mlversion >= 7
         try
            set(h_fig,'WindowStyle','normal')
            set(h_fig,'DockControls','off')
         catch
         end
      end

      %generate grid based on rows, cols
      [grid,rowtitles,coltitles,colunits,h_sldHoriz,h_sldVert,h_cmdMarkNone,h_cmdMarkAll] = sub_makegrid(r,c, ...
         colwid,numrows,numcols,halign,h_fig);

      h_mnuFile = uimenu('parent',h_fig, ...
         'label','File', ...
         'tag','mnuFile');

      h_mnuEdit = uimenu('parent',h_fig, ...
         'label','Edit', ...
         'tag','mnuEdit');

      h_mnuOptions = uimenu('parent',h_fig, ...
         'label','Options', ...
         'tag','mnuOptions');

      uimenu('parent',h_mnuFile, ...
         'label',savestr, ...
         'tag','mnuSave', ...
         'accelerator',accelstr, ...
         'callback','ui_datagrid(''save'')');

      uimenu('parent',h_mnuFile, ...
         'label','Close', ...
         'tag','mnuClose', ...
         'separator','on', ...
         'callback','ui_datagrid(''close'')');

      h_mnuInsert = uimenu('parent',h_mnuEdit, ...
         'label','Insert Empty Record', ...
         'tag','mnuInsert');

      uimenu('parent',h_mnuInsert, ...
         'label','Beginning of Data Set', ...
         'accelerator','b', ...
         'tag','mnuInsertTop', ...
         'callback','ui_datagrid(''insert'',''top'')');

      uimenu('parent',h_mnuInsert, ...
         'label','End of Data Set', ...
         'accelerator','e', ...
         'tag','mnuInsertBot', ...
         'callback','ui_datagrid(''insert'',''bot'')');

      uimenu('parent',h_mnuInsert, ...
         'label','Before Selected Row', ...
         'accelerator','i', ...
         'tag','mnuInsertSel', ...
         'callback','ui_datagrid(''insert'',''sel'')');

      uimenu('parent',h_mnuEdit, ...
         'label','Update QC Flags', ...
         'accelerator','f', ...
         'tag','mnuFlags', ...
         'callback','ui_datagrid(''flags'')');

      h_mnuMarkAll = uimenu('parent',h_mnuEdit, ...
         'label','Select All Rows', ...
         'accelerator','a', ...
         'separator','on', ...
         'tag','mnuMarkAll', ...
         'callback','ui_datagrid(''markall'')');

      h_mnuMarkNone = uimenu('parent',h_mnuEdit, ...
         'label','Clear All Selections', ...
         'accelerator','n', ...
         'tag','mnuMarkNone', ...
         'callback','ui_datagrid(''marknone'')');

      h_mnuCopyRows = uimenu('parent',h_mnuEdit, ...
         'label','Copy Selected Rows', ...
         'accelerator','c', ...
         'separator','on', ...
         'tag','mnuCopyRows', ...
         'callback','ui_datagrid(''copyrows'')');

      h_mnuDelRows = uimenu('parent',h_mnuEdit, ...
         'label','Delete Selected Rows', ...
         'accelerator','x', ...
         'tag','mnuDelRows', ...
         'callback','ui_datagrid(''delrows'')');

      uimenu('parent',h_mnuEdit, ...
         'label','Undo Changes', ...
         'accelerator','u', ...
         'tag','mnuUndo', ...
         'separator','on', ...
         'callback','ui_datagrid(''undo'')');

      h_mnuView = uimenu('parent',h_mnuOptions, ...
         'label','Record View', ...
         'tag','mnuView');

      uimenu('parent',h_mnuView, ...
         'label','All Records', ...
         'checked','on', ...
         'tag','mnuAllRecs', ...
         'userdata','all', ...
         'callback','ui_datagrid(''viewmode'')');

      h_mnuFlagged = uimenu('parent',h_mnuView, ...
         'label','Flagged Records', ...
         'tag','mnuFlagRecs');
      
      uimenu('parent',h_mnuFlagged, ...
         'Label','Flags in Any Column', ...
         'userdata','flag', ...
         'callback','ui_datagrid(''viewmode'')');

      uimenu('parent',h_mnuFlagged, ...
         'Label','Flags in Selected Column(s)', ...
         'userdata','flagsel', ...
         'callback','ui_datagrid(''viewmode'')');

      uimenu('parent',h_mnuFlagged, ...
         'label','No Flags in Any Column', ...
         'separator','on', ...
         'userdata','noflag', ...
         'callback','ui_datagrid(''viewmode'')');

      uimenu('parent',h_mnuFlagged, ...
         'label','No Flags in Selected Column(s)', ...
         'userdata','noflagsel', ...
         'callback','ui_datagrid(''viewmode'')');

      h_mnuDupes = uimenu('parent',h_mnuView, ...
         'label','Duplicate Records', ...
         'tag','mnuDupes');

      uimenu('parent',h_mnuDupes, ...
         'label','All Columns Duplicated', ...
         'tag','mnuDupesAll', ...
         'userdata','dupes_all', ...
         'callback','ui_datagrid(''viewmode'')');

      uimenu('parent',h_mnuDupes, ...
         'label','Non-data Columns Duplicated', ...
         'tag','mnuDupesNonData', ...
         'userdata','dupes_nondata', ...
         'callback','ui_datagrid(''viewmode'')');

      uimenu('parent',h_mnuDupes, ...
         'label','Date/time Columns Duplicated', ...
         'tag','mnuDupesDate', ...
         'userdata','dupes_date', ...
         'callback','ui_datagrid(''viewmode'')');

      h_mnuCustomView = uimenu('parent',h_mnuView, ...
         'label','Custom View Criteria', ...
         'separator','on', ...
         'tag','mnuCustomView', ...
         'userdata',[], ...
         'callback','ui_datagrid(''customview'')');

      h_mnuLogs = uimenu('parent',h_mnuOptions, ...
         'label','Copy/Delete Logging', ...
         'tag','mnuLogs', ...
         'userdata',defaults.logging);

      if defaults.logging == 0; vis = 'on'; else vis = 'off'; end
      uimenu('parent',h_mnuLogs, ...
         'label','Only Log Record Totals', ...
         'checked',vis, ...
         'tag','mnuLogTot', ...
         'userdata',0, ...
         'callback','ui_datagrid(''logopt'')');

      if defaults.logging == 100; vis = 'on'; else vis = 'off'; end
      uimenu('parent',h_mnuLogs, ...
         'label','Log Up To 100 Records', ...
         'checked',vis, ...
         'tag','mnuLog100', ...
         'userdata',100, ...
         'callback','ui_datagrid(''logopt'')');

      if defaults.logging == 1000; vis = 'on'; else vis = 'off'; end
      uimenu('parent',h_mnuLogs, ...
         'label','Log Up To 1000 Records', ...
         'checked',vis, ...
         'tag','mnuLog1000', ...
         'userdata',1000, ...
         'callback','ui_datagrid(''logopt'')');

      if defaults.logging == inf; vis = 'on'; else vis = 'off'; end
      uimenu('parent',h_mnuLogs, ...
         'label','Log All Records', ...
         'checked',vis, ...
         'tag','mnuLogAll', ...
         'userdata',Inf, ...
         'callback','ui_datagrid(''logopt'')');

      h_mnuAlign = uimenu('parent',h_mnuOptions, ...
         'label','Cell Alignment');

      h_mnuAlignAuto = uimenu('parent',h_mnuAlign, ...
         'label','Automatic', ...
         'checked',align_auto, ...
         'callback','ui_datagrid(''align'')', ...
         'tag','mnuAlignAuto', ...
         'userdata','auto');

      h_mnuAlignLeft = uimenu('parent',h_mnuAlign, ...
         'label','Left', ...
         'checked',align_left, ...
         'callback','ui_datagrid(''align'')', ...
         'tag','mnuAlignLeft', ...
         'userdata','left');

      h_mnuAlignRight = uimenu('parent',h_mnuAlign, ...
         'label','Right', ...
         'checked',align_right, ...
         'callback','ui_datagrid(''align'')', ...
         'tag','mnuAlignRight', ...
         'userdata','right');

      h_mnuAlignCenter = uimenu('parent',h_mnuAlign, ...
         'label','Center', ...
         'checked',align_center, ...
         'callback','ui_datagrid(''align'')', ...
         'tag','mnuAlignCenter', ...
         'userdata','center');

      h_mnuGridSize = uimenu('parent',h_mnuOptions, ...
         'label','Grid Size', ...
         'separator','on', ...
         'tag','mnuGridSize');

      h_mnuGridCols = uimenu('parent',h_mnuGridSize, ...
         'label','Columns', ...
         'tag','mnuGridCols');

      h_mnuGridRows = uimenu('parent',h_mnuGridSize, ...
         'label','Rows', ...
         'tag','mnuGridRows');

      for n = 1:length(ar_cols)
         uimenu('parent',h_mnuGridCols, ...
            'label',int2str(ar_cols(n)), ...
            'callback','ui_datagrid(''gridcols'')', ...
            'userdata',ar_cols(n));
      end

      for n = 1:length(ar_rows)
         uimenu('parent',h_mnuGridRows, ...
            'label',int2str(ar_rows(n)), ...
            'callback','ui_datagrid(''gridrows'')', ...
            'userdata',ar_rows(n));
      end

      uimenu('parent',h_mnuOptions, ...
         'label','Save Grid Layout', ...
         'callback','ui_datagrid(''defaults'')', ...
         'tag','mnuDefaults');

      uih = struct( ...
         's',s, ...
         'h',h, ...
         'cb',cb, ...
         'cache',cache, ...
         'r',r, ...
         'c',c, ...
         'colwid',colwid, ...
         'halign',halign, ...
         'log',[], ...
         'vals',{vals}, ...
         'flags',{flags}, ...
         'marks',{marks}, ...
         'grid',{grid}, ...
         'index',index, ...
         'sldHoriz',h_sldHoriz, ...
         'sldVert',h_sldVert, ...
         'coltitles',coltitles, ...
         'colunits',colunits, ...
         'rowtitles',rowtitles, ...
         'cmdMarkAll',h_cmdMarkAll, ...
         'cmdMarkNone',h_cmdMarkNone, ...
         'mnuMarkAll',h_mnuMarkAll, ...
         'mnuMarkNone',h_mnuMarkNone, ...
         'mnuCopyRows',h_mnuCopyRows, ...
         'mnuDelRows',h_mnuDelRows, ...
         'mnuView',h_mnuView, ...
         'mnuLog',h_mnuLogs, ...
         'mnuAlign',h_mnuAlign, ...
         'mnuAlignAuto',h_mnuAlignAuto, ...
         'mnuAlignLeft',h_mnuAlignLeft, ...
         'mnuAlignRight',h_mnuAlignRight, ...
         'mnuAlignCenter',h_mnuAlignCenter, ...
         'mnuGridSize',h_mnuGridSize, ...
         'mnuCustomView',h_mnuCustomView);

      set(h_fig,'userdata',uih,'visible','on')

      if ~isempty(s)
         ui_datagrid('refresh')
      else
         drawnow
      end

      if mlversion < 7
         set(h_fig, ...
            'Resize','on', ...
            'ResizeFcn','ui_datagrid(''resize'')')
      end

   else  %invalid/omitted data structure

      messagebox('init', ...
         'Data structure is invalid or contains no data', ...
         '', ...
         'Error', ...
         [.9 .9 .9])

   end

else

   h_fig = gcf;

   if strcmp(get(h_fig,'tag'),'dlgDataGrid')

      uih = get(h_fig,'userdata');  %get handle and property cache structure

      %get slider positions from control userdata
      hoffset = get(uih.sldHoriz,'userdata');
      voffset = get(uih.sldVert,'userdata');

      switch op

      case 'close'  %close the dialog

         delete(h_fig)
         drawnow

         if ~isempty(uih.h)
            try
               figure(uih.h)
            catch
               ui_aboutgce('reopen')  %check for last window
            end
         else
            ui_aboutgce('reopen')  %check for last window
         end

      case 'gridcols'  %resize number of rows

         %get new fig size
         pos = get(h_fig,'position');

         %look up cached values
         c = uih.c;
         r = uih.r;
         numcols = length(uih.s.values);

         %get new number rows/cols in grid
         c_new = min(numcols,get(gcbo,'UserData'));
         r_new = r;

         if c_new ~= c  %row/col change - regenerate uicontrols

            %calc new fig width to show an even array of uicontrols
            colwid = uih.colwid;
            figwd_new = c_new .* (colwid+1) + 95;
            fight_new = r_new .* 21 + 62;

            set(h_fig,'Position',[pos(1),pos(2)+(pos(4)-fight_new),figwd_new,fight_new])
            ui_datagrid('resize')

         end

      case 'gridrows'  %resize number of rows

         %get new fig size
         pos = get(h_fig,'position');

         %look up cached values
         c = uih.c;
         r = uih.r;

         %get new number rows/cols in grid
         c_new = c;
         r_new = get(gcbo,'UserData');

         if r_new ~= r  %row/col change - regenerate uicontrols

            %calc new fig width to show an even array of uicontrols
            colwid = uih.colwid;
            figwd_new = c_new .* (colwid+1) + 95;
            fight_new = r_new .* 21 + 62;

            set(h_fig,'Position',[pos(1),pos(2)+(pos(4)-fight_new),figwd_new,fight_new])
            ui_datagrid('resize')

         end

      case 'resize'  %resize the window

         %get new fig size
         pos = get(h_fig,'position');

         %look up cached values
         c = uih.c;
         r = uih.r;
         colwid = uih.colwid;
         numcols = length(uih.s.values);
         numrows = length(uih.s.values{1});

         %calc new number rows/cols in grid
         c_new = min(numcols,max(1,floor((pos(3) - 95) ./ (colwid + 1))));
         r_new = max(10,floor((pos(4) - 62) ./ 21));

         %calc new fig width to show an even array of uicontrols
         figwd_new = c_new .* (colwid+1) + 95;
         fight_new = r_new .* 21 + 62;

         if c_new ~= c || r_new ~= r  %row/col change - regenerate uicontrols

            %delete prior ui_controls
            delete(uih.coltitles);
            delete(uih.colunits);
            delete(uih.rowtitles);
            delete(uih.grid(:));
            delete(uih.sldHoriz);
            delete(uih.sldVert);
            delete(uih.cmdMarkNone);
            delete(uih.cmdMarkAll);

            %call subfunction to generate uicontrols
            [grid,rowtitles,coltitles,colunits,h_sldHoriz,h_sldVert,h_cmdMarkNone,h_cmdMarkAll] = sub_makegrid(r_new,c_new, ...
               colwid,numrows,numcols,uih.halign,h_fig);

            %reset slider values to match prior values
            hoffset = min(numcols-c_new,hoffset);
            voffset = min(numrows-r_new,voffset);
            set(h_sldHoriz,'userdata',hoffset,'value',hoffset)
            set(h_sldVert,'userdata',voffset,'value',get(h_sldVert,'max')-voffset)
            set(h_fig,'Position',[pos(1),pos(2)+(pos(4)-fight_new),figwd_new,fight_new])

            %update cached uicontrol handles
            uih.r = r_new;
            uih.c = c_new;
            uih.grid = grid;
            uih.rowtitles = rowtitles;
            uih.coltitles = coltitles;
            uih.colunits = colunits;
            uih.sldHoriz = h_sldHoriz;
            uih.sldVert = h_sldVert;
            uih.cmdMarkNone = h_cmdMarkNone;
            uih.cmdMarkAll = h_cmdMarkAll;

            %update fig position, userdata
            set(h_fig,'UserData',uih)

            %call slider sub to update slider info and fill controls with appropriate view indices
            ui_datagrid('slider','current')

         else %no row/col change - just enforce fig size
            set(h_fig,'Position',[pos(1),pos(2)+(pos(4)-fight_new),figwd_new,fight_new])
         end

      case 'scrollv'  %test for change in vert scroll, refresh fields

         %calculate offset based on slider position, update if changed and trigger refresh
         voffset = (get(uih.sldVert,'max') - round(get(uih.sldVert,'value')));
         if voffset ~= get(uih.sldVert,'userdata')
            set(uih.sldVert,'userdata',voffset)
            ui_datagrid('refresh')
         end

      case 'scrollh'  %test for change in horiz scroll, refresh fields

         %calculate offset based on slider position, update if changed and trigger refresh
         hoffset = round(get(uih.sldHoriz,'value'));
         if hoffset ~= get(uih.sldHoriz,'userdata')
            set(uih.sldHoriz,'userdata',hoffset)
            ui_datagrid('refresh')
         end

      case 'defaults'  %save settings

         h_chk = findobj(uih.mnuAlign,'checked','on');
         halign = get(h_chk(1),'userdata');

         %generate settings filename
         fn = which('ui_datagrid.mat');
         if isempty(fn)
            pn = [gce_homepath,filesep,'settings'];
            if ~isdir(pn)
               pn = fileparts(which('ui_datagrid'));
            end
            fn = [pn,filesep,'ui_datagrid.mat'];
         end

         defaults = struct('maxcols',uih.c,'maxrows',uih.r,'logging',get(uih.mnuLog,'userdata'),'halign',halign); %#ok<NASGU>

         save(fn,'defaults')

      case 'customview'  %open query builder dialog to create custom filter

         query = get(uih.mnuCustomView,'UserData');  %look up last query
         ui_querybuilder('init',uih.s,uih.mnuCustomView,'ui_datagrid(''customview2'')',query)  %call querybuilder

      case 'customview2'  %handle return from querybuilder

         query = get(uih.mnuCustomView,'UserData');

         %check for return query, set custom view checkmark and call view routine
         if ~isempty(query)
            h_v = findobj(uih.mnuView);
            set(h_v,'checked','off')
            set(uih.mnuCustomView,'checked','on')
            ui_datagrid('view')
         end

      case 'viewmode'  %toggle data view menu settings

         %get menu item, stored data
         h_cbo = gcbo;

         %toggle menu checks
         h_v = findobj(uih.mnuView);
         set(h_v,'checked','off')
         set(h_cbo,'checked','on')

         %reset check marks
         uih.marks = zeros(size(uih.vals{1},1),1);
         set(h_fig,'userdata',uih)

         ui_datagrid('view')

      case 'view'  %update view indices, refresh grid

         %initialize cancel flag
         cancel = 0;
         
         %check for position input
         if exist('s','var') ~= 1
            pos = 'top';
         else
            pos = s;
         end

         %get current view menu option
         h_chk = findobj(uih.mnuView,'checked','on');
         viewmode = get(h_chk(1),'userdata');

         msg = ''; %init error message

         vals = uih.vals;  %get cached value array

         %build appropriate index
         if strcmp(viewmode,'flag') || strcmp(viewmode,'flagsel') || strcmp(viewmode,'noflag') || strcmp(viewmode,'noflagsel')

            flags = uih.flags;  %get flags
            Isel = ones(length(vals{1}),1);  %build default index (all selected)
            
            %check for selected columns - subset flag arrays for indexing
            if strcmp(viewmode,'flagsel') || strcmp(viewmode,'noflagsel')

               Icols = listdialog( ...
                  'liststring',uih.s.name, ...
                  'name','Column Selection', ...
                  'promptstring','Select Columns to Check for Flags', ...
                  'selectionmode','multiple', ...
                  'listsize',[0 0 300 500]);
               
               if ~isempty(Icols)
                  flags = flags(Icols);
               else
                  flags = [];
               end
               
            end
            
            %check for cancel of selection
            if ~isempty(flags)
               
               for n = 1:length(flags)  %loop through columns
                  f = flags{n};  %get flag column
                  if ~isempty(f)
                     I_fl = find(f(:,1)~=' ');
                     if ~isempty(I_fl)
                        Isel(I_fl) = 0;
                     end
                  end
               end
               
               %generate appropriate row index
               if strcmp(viewmode,'noflag') || strcmp(viewmode,'noflagsel')
                  index = find(Isel);   %use non-flag index
               else
                  index = find(~Isel);  %invert index to reference flagged rows
               end
               
            else
               cancel = 1;  %set flag to cancel view change
            end
            
         elseif strcmp(viewmode,'dupes_all') || strcmp(viewmode,'dupes_nondata') || strcmp(viewmode,'dupes_date')

            %generate updated structure
            data = uih.s;
            data.values = vals;
            data.flags = uih.flags;

            %get index for requested dupe type
            if strcmp(viewmode,'dupes_all')
               [index,msg] = dupe_index(data);
            else
               if strcmp(viewmode,'dupes_date')
                  vtype = get_type(data,'variabletype');
                  cols = find(strcmp(vtype,'datetime'));
                  lbl = 'date/time';
               else  %non-data
                  cols = listdatacols(data,'inverse');
                  lbl = 'non-data';
               end
               if ~isempty(cols)
                  [index,msg] = dupe_index(data,cols);
               else
                  index = [];
                  msg = ['No ',lbl,' columns are present in the structure!'];
               end
            end
            if ~isempty(msg)
               msg = ['An error occurred calculating the duplicate record view index: ',msg];
            end

         elseif strcmp(viewmode,'all') || isempty(viewmode)

            index = (1:size(vals{1},1))';

         else  %custom query

            %use custom view userdata as query
            query = viewmode;

            %generate temporary structure containing updated values, flags for indexing
            s_tmp = uih.s;
            s_tmp.values = uih.vals;
            s_tmp.flags = uih.flags;

            %run query, return index
            [I_inc,msg] = query_index(s_tmp,query);
            if ~isempty(I_inc)
               index = I_inc;
            else
               index = [];
               if ~isempty(msg)
                  msg = ['An error occurred calculating the custom index (',msg,')'];
               end
            end

         end
         
         if cancel == 0
            
            %update cached index
            uih.index = index;
            set(h_fig,'userdata',uih)
            
            %update slider
            ui_datagrid('slider',pos)
            
            if ~isempty(msg)
               messagebox('init',msg,[],'Error',[.9 .9 .9]);
            end
            
         end

      case 'slider'  %update vertical scrollbar after view change

         pos = s;
         numrows = length(uih.index);
         r = uih.r;
         minvstep = ceil((numrows-r)./ceil(numrows./5e5));  %calculate min step size to avoid scrolling issues with >500k records

         if numrows > r
            sldmax = max(1,numrows-r);
            if strcmp(pos,'top')
               val = sldmax;
            elseif strcmp(pos,'bottom')
               val = get(uih.sldVert,'min');
            else  %base on current position
               val = max(0,min(sldmax-voffset,max(1,numrows-r)));
            end
            set(uih.sldVert, ...
               'max',sldmax, ...
               'sliderstep',[1./max(1,min(minvstep,numrows-r)) r./max(1,min(minvstep,numrows-r))], ...
               'value',val, ...
               'userdata',max(1,numrows-r)-val, ...
               'enable','on')
         else
            set(uih.sldVert, ...
               'max',1, ...
               'sliderstep',[0 1], ...
               'value',1, ...
               'userdata',0, ...
               'enable','off')
         end

         ui_datagrid('refresh')

      case 'align'  %process cell alignment calls

         h_cb = gcbo;
         h_sel = findobj(uih.mnuAlign,'checked','on');

         if h_cb ~= h_sel
            set(h_sel,'checked','off')
            set(h_cb,'checked','on')
            halign = get(h_cb,'userdata');
            if strcmp(halign,'auto')
               s = uih.s;
               if length(find(strcmp(s.datatype,'s'))) >= ceil(length(s.name) .* 0.5)
                  halign = 'left';  %majority text - use left align
               else
                  halign = 'right';
               end
            end
            uih.halign = halign;
            %set(uih.colunits,'horizontalalignment',halign)
            %set(uih.coltitles,'horizontalalignment',halign)
            drawnow
            set(uih.grid(:),'horizontalalignment',halign)
            set(h_fig,'userdata',uih)
         end

      case 'insert'  %add blank row

         pos = s;

         vals = uih.vals;
         index = uih.index;
         flags = uih.flags;
         dtype = uih.s.datatype;
         Ipos = [];

         switch pos
         case 'sel'  %check for insert at selection first
            Isel = find(uih.marks);
            if ~isempty(Isel)
               if length(Isel) > 1
                  Ionscreen = find((Isel >= voffset) & (Isel <= voffset+uih.r));  %look for onscreen selected record
                  if ~isempty(Ionscreen)
                     Ipos = Isel(Ionscreen(1));
                  else
                     Ipos = Isel(1); %none found - use first selected
                  end
               else
                  Ipos = Isel(1); %only one selected
               end
            else
               Ipos = [];
            end
         case 'top'
            Ipos = 1;
         case 'bot'
            Ipos = length(index) + 1;
         end

         if ~isempty(Ipos)

            if Ipos == 1  %insert at top

               for n = 1:length(vals)
                  if strcmp(dtype{n},'s')
                     vals{n} = [{''} ; vals{n}];
                  else
                     vals{n} = [NaN ; vals{n}];
                  end
                  if ~isempty(flags{n})
                     flags{n} = char('',flags{n});
                  end
               end
               valrows = size(vals{1},1);
               index = [index ; valrows];  %add new row to index
               uih.vals = vals;
               uih.index = index;
               uih.flags = flags;
               uih.marks = [0 ; uih.marks];
               uih.log = [uih.log ; {'insert'},{1},{[]},{[]}];
               set(h_fig,'userdata',uih)
               ui_datagrid('slider','top')

            elseif Ipos > length(index) %insert at bottom

               for n = 1:length(vals)
                  if strcmp(dtype{n},'s')
                     vals{n} = [vals{n} ; {''}];
                  else
                     vals{n} = [vals{n} ; NaN];
                  end
                  if ~isempty(flags{n})
                     flags{n} = char(flags{n},'');
                  end
               end
               valrows = size(vals{1},1);
               index = [index ; valrows];  %add new row to index
               uih.vals = vals;
               uih.index = index;
               uih.flags = flags;
               uih.marks = [uih.marks ; 0];
               uih.log = [uih.log ; {'insert'},{valrows},{[]},{[]}];
               set(h_fig,'userdata',uih)
               ui_datagrid('slider','bottom')

            else  %insert in middle

               for n = 1:length(vals)
                  if strcmp(dtype{n},'s')
                     v = vals{n};
                     v = [v(1:Ipos-1) ; {''} ; v(Ipos:end)];
                     vals{n} = v;
                  else
                     v = vals{n};
                     v = [v(1:Ipos-1) ; NaN ; v(Ipos:end)];
                     vals{n} = v;
                  end
                  if ~isempty(flags{n})
                     f = flags{n};
                     f = char(f(1:Ipos-1,:),'',f(Ipos:end,:));
                     flags{n} = f;
                  end
               end
               valrows = size(vals{1},1);
               index = [index ; valrows];  %add new row to index
               marks = uih.marks;
               marks = [marks(1:Ipos-1) ; 0 ; marks(Ipos:end)];

               uih.vals = vals;
               uih.index = index;
               uih.flags = flags;
               uih.marks = marks;
               uih.log = [uih.log ; {'insert'},{Ipos},{[]},{[]}];
               set(h_fig,'userdata',uih)
               ui_datagrid('slider','mid')

            end

         else
            messagebox('init','Insert cancelled - no records are selected','','Warning',[.9 .9 .9]);
         end

      case 'flags'  %update QC flags

         set(h_fig,'pointer','watch')

         data = uih.s;
         data.values = uih.vals;
         data.flags = uih.flags;

         data = dataflag(data);
         uih.flags = data.flags;

         set(h_fig,'userdata',uih,'pointer','arrow')

         ui_datagrid('view','current')

      case 'check'  %process row checks

         h_cbo = gcbo;
         pos = get(h_cbo,'userdata');

         bg = get(uih.grid(pos,:),'backgroundcolor');
         if iscell(bg)
            bg = cat(1,bg{:});
         end
         Iind = uih.index;

         if get(h_cbo,'value') == 1
            uih.marks(Iind(voffset+pos)) = 1;
            Ibg = sum(bg')==3;
            set(uih.grid(pos,Ibg),'backgroundcolor',[.85 .85 .85])
         else
            uih.marks(Iind(voffset+pos)) = 0;
            Ibg = sum(bg')==(3.*0.85);
            set(uih.grid(pos,Ibg),'backgroundcolor',[1 1 1])
         end
         drawnow

         set(h_fig,'userdata',uih)

      case 'markall'  %check all visible rows

         Ion = find(strcmp(get(uih.rowtitles,'enable'),'on'));

         if ~isempty(Ion)

            uih.marks = zeros(size(uih.vals{1},1),1);  %initialize to clear non-visible marks
            uih.marks(uih.index) = 1;  %set marks based on index of visible rows
            set(h_fig,'userdata',uih)
            set(uih.rowtitles(Ion)','value',1)

            %get index of non-flagged cells based on backgroundcolor
            h_all = uih.grid(Ion,:);
            bg = get(h_all,'backgroundcolor');
            bg = cat(1,bg{:});
            Ibg = sum(bg')==3;

            drawnow

            %set background of non-flagged cells to gray
            set(h_all(Ibg),'backgroundcolor',[.85 .85 .85])

         end

      case 'marknone'  %clear checks

         %reset all marks just to be sure
         uih.marks = zeros(size(uih.vals{1},1),1);
         set(h_fig,'userdata',uih)

         %get index of enabled rows
         Ion = find(strcmp(get(uih.rowtitles,'enable'),'on'));

         if ~isempty(Ion)

            set(uih.rowtitles(Ion)','value',0)  %toggle checks off

            %get index of non-flagged cells based on backgroundcolor
            h_all = uih.grid(Ion,:);
            bg = get(h_all,'backgroundcolor');
            bg = cat(1,bg{:});
            Ibg = sum(bg')==(3.*0.85);

            drawnow

            %set background of non-flagged cells to gray
            set(h_all(Ibg),'backgroundcolor',[1 1 1])

         end

      case 'logopt'  %process logging option callbacks

         h_cbo = gcbo;
         set(uih.mnuLog,'userdata',get(h_cbo,'userdata'))
         set(findobj(uih.mnuLog),'checked','off')
         set(h_cbo,'checked','on')

      case 'copyrows'  %copy marked rows

         Isel = find(uih.marks);

         if ~isempty(Isel)

            vals = uih.vals;
            flags = uih.flags;
            oldnumrows = size(vals{1},1);

            %append values, flags
            for n = 1:length(vals)
               vals{n} = [vals{n} ; vals{n}(Isel)];
               if ~isempty(flags{n})
                  flags{n} = char(flags{n},flags{n}(Isel,:));
               end
            end

            %update stored data
            uih.vals = vals;
            uih.flags = flags;
            uih.index = [uih.index ; (oldnumrows+1:size(vals{1},1))'];
            uih.marks = [zeros(oldnumrows,1) ; ones(length(Isel),1)];
            uih.log = [uih.log ; {'copy'} , {Isel} , {oldnumrows+1} , {[]}];

            %update slider parms
            numrows = length(uih.index);
            r = uih.r;
            sldmax = max(1,numrows-r);
            minvstep = ceil((numrows-r)./ceil(numrows./5e5));  %calculate min step size to avoid scrolling issues with >500k records
            
            if sldmax == 1
               sldval = 1;
            else
               sldval = 0;
            end
            set(uih.sldVert, ...
               'max',sldmax, ...
               'sliderstep',[1./max(1,min(minvstep,numrows-r)) r./max(1,min(minvstep,numrows-r))], ...
               'value',sldval, ...
               'userdata',sldmax-sldval)

            %update grid
            set(h_fig,'userdata',uih)
            ui_datagrid('refresh')

         end

      case 'delrows'  %delete marked rows

         Inonmark = find(~uih.marks);
         Imark = find(uih.marks);

         if ~isempty(Imark)

            if isempty(Inonmark)

               messagebox('init', ...
                  'Data Structures must contain at least one row', ...
                  '', ...
                  'Error', ...
                  [.9 .9 .9])

            else

               vals = uih.vals;
               flags = uih.flags;

               %delete data rows, flag rows
               for n = 1:length(vals)
                  vals{n} = vals{n}(Inonmark);
                  if ~isempty(flags{n})
                     flags{n} = flags{n}(Inonmark,:);
                  end
               end

               %update stored data
               uih.log = [uih.log ; {'delete'} , {Imark} , {[]} , {[]}];
               uih.vals = vals;
               uih.flags = flags;
               uih.marks = uih.marks(Inonmark);

               %update grid
               set(h_fig,'userdata',uih)

               %update view/recalc index
               ui_datagrid('view','current')

            end

         end

      case 'undo'  %undo changes

         %restore original data, parms
         uih.vals = uih.s.values;  %restore values
         uih.marks = zeros(size(uih.vals{1},1),1);  %clear mark vector
         uih.index = (1:size(uih.vals{1},1))';  %reset
         uih.flags = uih.s.flags ; %restore flags
         uih.log = [];  %clear log

         %reset to all record view
         set(findobj(uih.mnuView),'checked','off')
         set(findobj(uih.mnuView,'userdata','all'),'checked','on')

         %recalculate slider stats
         numrows = size(uih.vals{1},1);
         r = uih.r;
         minvstep = ceil((numrows-r)./ceil(numrows./5e5));  %calculate min step size to avoid scrolling issues with >500k records
         
         set(uih.sldVert, ...
            'max',max(1,numrows-r), ...
            'sliderstep',[1./max(1,min(minvstep,numrows-r)) r./max(1,min(minvstep,numrows-r))], ...
            'value',max(1,numrows-r))
         set(h_fig,'userdata',uih)

         ui_datagrid('refresh')
         refresh(h_fig)

      case 'edit'  %process value edits

         h_cbo = gcbo;
         pos_grid = get(h_cbo,'userdata');

         str = deblank(get(uih.grid(pos_grid(1),pos_grid(2)),'string'));

         %adjust pos for offsets
         pos = [uih.index(pos_grid(1)+voffset) pos_grid(2)+hoffset];
         dtype = uih.s.datatype{pos(2)};

         if strcmp(dtype,'s')
            oldval = ['''',uih.vals{pos(2)}{pos(1)},''''];
            if strcmp(oldval,str) ~= 1
               uih.vals{pos(2)}{pos(1)} = str;
               uih.log = [uih.log ; uih.s.name(pos(2)) , {pos(1)} , {oldval} , {['''',str,'''']}];
               set(h_fig,'userdata',uih)
            end
         else
            oldval = uih.vals{pos(2)}(pos(1));
            if strcmp(uih.s.variabletype{pos(2)},'datetime') && ~isempty(strfind(str,'/'))  %check for numerical datetime field
               try
                  newval = datenum(str);
               catch
                  newval = str2num(str); %#ok<ST2NM>
               end
            else
               newval = str2num(str); %#ok<ST2NM>
            end
            if isempty(newval) || length(newval) > 1  %NaN string contents
               newval = NaN;
               set(h_cbo,'string','NaN')  %post formatted number to grid
               if strcmp(dtype,'d')
                  fstr = '%0d';
               else
                  prec = uih.s.precision(pos(2));
                  fstr = ['%0.',int2str(prec),dtype];
               end
            elseif strcmp(dtype,'d')
               if ~isempty(strfind(str,'.'))
                  newval = round(newval);  %round to remove decimals
               end
               set(h_cbo,'string',int2str(newval))  %post formatted number to grid
               fstr = '%0d';
            else  %exponential or floating point
               prec = uih.s.precision(pos(2));
               if strcmp(dtype,'e')
                  newval = roundsig(newval,prec+1);  %round based on significant digits
               else
                  newval = round(newval.*10^prec)./10^prec; %round based on precision
               end
               fstr = ['%0.',int2str(prec),dtype];
               set(h_cbo,'string',sprintf(fstr,newval))  %post formatted number to grid
            end
            if oldval ~= newval
               uih.vals{pos(2)}(pos(1)) = newval;
               uih.log = [uih.log ; ...
                     uih.s.name(pos(2)) , {pos(1)} , {sprintf(fstr,oldval)} , {sprintf(fstr,newval)}];
               set(h_fig,'userdata',uih)
            end
         end

      case 'refresh'  %fill edit boxes

         %get index of relevant columns, grab metadata
         Isel = (hoffset+1:hoffset+uih.c);
         dtype = uih.s.datatype(Isel);
         prec = uih.s.precision(Isel);
         colnames = uih.s.name(Isel);
         coldesc = uih.s.description(Isel);
         units = uih.s.units(Isel);

         %grab stored arrays, values
         grid = uih.grid;
         r = uih.r;
         c = uih.c;
         rowtitles = uih.rowtitles;
         coltitles = uih.coltitles;
         colunits = uih.colunits;

         %get data values, apply index
         index = uih.index;
         vals = uih.vals;
         marks = uih.marks;
         flags = uih.flags;
         flagbgcolor = [.8 0 0];
         flagfgcolor = [1 1 1];
         colorvals = [1 1 1 ; .85 .85 .85];
         maxrow = length(index);

         %loop through cell columns, format and display values
         for n = 1:c

            %generate format string based on datatype, precision
            fgcolor = [0 0 .7];
            if strcmp(dtype{n},'s')
               fstr = '%s';
               fgcolor = [0 .7 0];
            elseif strcmp(dtype{n},'d')
               fstr = '%0d';
            else
               fstr = ['%0.',int2str(prec(n)),dtype{n}];
            end

            %generate flag index for display
            if isempty(flags{hoffset+n})
               Iflags = zeros(min(r,maxrow-voffset),1);
            else
               Iflags = flags{hoffset+n}(index(voffset+1:min(voffset+r,length(index))),1) ~= ' ';
            end
            Iflags = Iflags + 1;  %convert to color index

            %display column name/description as tooltip
            desc = coldesc{n};
            tooltip = colnames{n};
            if ~isempty(desc) && ~strcmp(desc,'none')
               tooltip = [tooltip,' - ',desc];
            end
            set(coltitles(n),'string',[colnames{n},' '],'foregroundcolor',fgcolor,'tooltipstring',tooltip)

            %display units if available
            if ~isempty(units{n})
               unitstr = ['(',units{n},')'];
            else
               unitstr = '';
            end
            set(colunits(n),'string',unitstr,'foregroundcolor',fgcolor,'tooltipstring',unitstr)

            %loop through rows and format contents
            if maxrow > 0
               if strcmp(dtype{n},'s')
                  for m = 1:r
                     if voffset+m <= maxrow
                        Irow = index(voffset+m);
                        str = vals{hoffset+n}{Irow};
                        set(rowtitles(m),'string',int2str(Irow),'value',marks(Irow),'enable','on')
                        if Iflags(m) == 1
                           set(grid(m,n), ...
                              'string',str, ...
                              'foregroundcolor',[0 0 0], ...
                              'backgroundcolor',colorvals(marks(Irow)+1,:), ...
                              'tooltipstring','', ...
                              'enable','on')
                        else
                           set(grid(m,n), ...
                              'string',str, ...
                              'foregroundcolor',flagfgcolor, ...
                              'backgroundcolor',flagbgcolor, ...
                              'tooltipstring',['flag = ',unique(flags{hoffset+n}(Irow,:))], ...
                              'enable','on')
                        end
                     else
                        set(rowtitles(m),'string','','value',0,'enable','off')
                        set(grid(m,n), ...
                           'string','', ...
                           'backgroundcolor',colorvals(2,:), ...
                           'tooltipstring','', ...
                           'enable','off')
                     end
                  end
               else
                  for m = 1:r
                     if voffset+m <= maxrow
                        Irow = index(voffset+m);
                        newval = vals{hoffset+n}(Irow);
                        if ~isnan(newval)
                           if ~strcmp(dtype{n},'d')
                              str = sprintf(fstr,newval);
                           else  %integer - force round to avoid sprintf cast to type 'g'
                              str = sprintf(fstr,round(newval));
                           end
                        else
                           str = 'NaN';
                        end
                        set(rowtitles(m),'string',int2str(Irow),'value',marks(Irow),'enable','on')
                        if Iflags(m) == 1
                           set(grid(m,n), ...
                              'string',str, ...
                              'foregroundcolor',[0 0 0], ...
                              'backgroundcolor',colorvals(marks(Irow)+1,:), ...
                              'tooltipstring','', ...
                              'enable','on')
                        else
                           set(grid(m,n), ...
                              'string',str, ...
                              'foregroundcolor',flagfgcolor, ...
                              'backgroundcolor',flagbgcolor, ...
                              'tooltipstring',['flag = ',unique(flags{hoffset+n}(Irow,:))], ...
                              'enable','on')
                        end
                     else
                        set(rowtitles(m),'string','','value',0,'enable','off')
                        set(grid(m,n), ...
                           'string','', ...
                           'backgroundcolor',colorvals(2,:), ...
                           'tooltipstring','', ...
                           'enable','off')
                     end
                  end
               end
            else  %no visible rows
               set(rowtitles,'string','','value',0,'enable','off')
               set(grid(:,n),'string','','backgroundcolor',colorvals(2,:))
               set(grid(:,n),'enable','off')
            end
         end

         if maxrow > r
            set(uih.sldVert,'enable','on')
         else
            set(uih.sldVert,'enable','off')
         end

         drawnow

      case 'save'  %open structure in editor

         s = uih.s;
         log = uih.log;

         s.values = uih.vals;
         s.flags = uih.flags;
         cache = uih.cache;  %retrieve cached data set by calling function
         logopt = get(uih.mnuLog,'userdata');

         set(h_fig,'pointer','watch'); drawnow
         if ~isempty(log)
            dirty = 1;
            str = [];
            for n = 1:size(uih.log,1)
               if strcmp(log{n,1},'delete')
                  if length(log{n,2}) < logopt
                     str = [str ; {['deleted record(s) ',cell2commas(strrep(cellstr(int2str(log{n,2})),' ',''),1)]}];
                  else
                     str = [str ; {['deleted ',int2str(length(log{n,2})),' record(s)']}];
                  end
               elseif strcmp(log{n,1},'copy')
                  if length(log{n,2}) < logopt
                     str = [str ; {['copied record(s) ',cell2commas(strrep(cellstr(int2str(log{n,2})),' ',''),1), ...
                                 ' to position ',int2str(log{n,3})]}];
                  else
                     str = [str ; {['copied ',int2str(length(log{n,2})),' records(s) to position ',int2str(log{n,3})]}];
                  end
               elseif strcmp(log{n,1},'insert')
                  str = [str ; {['inserted blank record at position ',int2str(log{n,2})]}];
               else
                  str = [str ; {['changed ''',log{n,1},''' row ',int2str(log{n,2}),' from ',log{n,3},' to ',log{n,4}]}];
               end
            end
            s.history = [s.history ; ...
                  {datestr(now)},{['edited structure data (''ui_datagrid''): ',cell2commas(str)]}];
            s = dataflag(s);
         else
            dirty = 0;
         end

         set(h_fig,'pointer','arrow'); drawnow

         if isempty(uih.cb)

            ui_editor('init',s)

         else

            close(h_fig)
            drawnow
            err = 0;

            %cache structure in uih handle if specified
            if ~isempty(uih.h)
               h_parent = parent_figure(uih.h);
               if ~isempty(h_parent)
                  figure(h_parent)
                  try
                     set(uih.h,'userdata',[{s},{dirty},{log}])
                     %evaluate callback if specified
                     if ~isempty(uih.cb)
                        try
                           eval(uih.cb)
                        catch
                           err = 1;
                        end
                     end
                  catch
                     err = 1;
                  end
               else
                  err = 1;
               end
            else
               try
                  eval(uih.cb)
               catch
                  err = 1;
               end
            end

            if err == 1
               ui_editor('init',s)
               drawnow
               if err == 1
                  messagebox('init', ...
                     'Warning - could not return structure to original editor window', ...
                     '', ...
                     'Warning', ...
                     [.9 .9 .9])
               end
            end

         end

      end

   end

end


%define subfun to generate grid of editbox controls
function [grid,rowtitles,coltitles,colunits,h_sldHoriz,h_sldVert,h_cmdMarkNone,h_cmdMarkAll] = sub_makegrid(r,c,colwid,numrows,numcols,halign,h_fig)

rowtitles = zeros(1,r);
coltitles = zeros(1,c);
colunits = zeros(1,c);
grid = zeros(r,c);
bot = 24 + 21.*r;
fontsize = 8;
minvstep = ceil((numrows-r)./ceil(numrows./5e5));  %calculate min step size to avoid scrolling issues with >500k records

if numcols > c
   vis = 'on';
   stepsize = [1./max(1,numcols-c) c./max(1,numcols-c)];
else
   vis = 'off';
   stepsize = [0 1];
end

h_sldHoriz = uicontrol('parent',h_fig, ...
   'style','slider', ...
   'position',[4 4 c.*(colwid+1)+90 18], ...
   'min',0, ...
   'max',max(1,numcols-c), ...
   'sliderstep',stepsize, ...
   'value',0, ...
   'callback','ui_datagrid(''scrollh'')', ...
   'interruptible','on', ...
   'enable',vis, ...
   'userdata',0, ...
   'tag','sldHoriz');

if numrows > r
   vis = 'on';
else
   vis = 'off';
end

h_sldVert = uicontrol('parent',h_fig, ...
   'style','slider', ...
   'position',[c.*(colwid+1)+75 25 18 r.*21+36], ...
   'min',0, ...
   'max',max(1,numrows-r), ...
   'sliderstep',[1./max(1,min(minvstep,numrows-r)) r./max(1,min(minvstep,numrows-r))], ...
   'value',max(1,numrows-r), ...
   'callback','ui_datagrid(''scrollv'')', ...
   'enable',vis, ...
   'interruptible','on', ...
   'userdata',0, ...
   'tag','sldVert');

h_cmdMarkNone = uicontrol('parent',h_fig, ...
   'style','pushbutton', ...
   'fontweight','bold', ...
   'foregroundcolor',[0 0 .7], ...
   'backgroundcolor',[.85 .85 .85], ...
   'horizontalalignment','center', ...
   'position',[3 bot 70 18], ...
   'string','None', ...
   'tag','cmdMarkNone', ...
   'tooltipstring','Clear all row selections', ...
   'callback','ui_datagrid(''marknone'')');

h_cmdMarkAll = uicontrol('parent',h_fig, ...
   'style','pushbutton', ...
   'fontweight','bold', ...
   'foregroundcolor',[0 0 .7], ...
   'backgroundcolor',[.85 .85 .85], ...
   'horizontalalignment','center', ...
   'position',[3 bot+19 70 18], ...
   'string','All', ...
   'tag','cmdMarkAll', ...
   'tooltipstring','Select all rows in the current record view (including offscreen rows)', ...
   'callback','ui_datagrid(''markall'')');

for m = 1:c

   lft = 74 + (colwid+1).*(m-1);

   h1 = uicontrol('parent',h_fig, ...
      'style','text', ...
      'fontsize',fontsize, ...
      'fontweight','bold', ...
      'foregroundcolor',[0 0 .7], ...
      'backgroundcolor',[.85 .85 .85], ...
      'horizontalalignment','left', ...
      'position',[lft bot colwid 18], ...
      'tag','units', ...
      'string','');

   colunits(m) = h1;

   h1 = uicontrol('parent',h_fig, ...
      'style','text', ...
      'fontsize',fontsize, ...
      'fontweight','bold', ...
      'foregroundcolor',[0 0 .7], ...
      'backgroundcolor',[.85 .85 .85], ...
      'horizontalalignment','left', ...
      'position',[lft bot+19 colwid 18], ...
      'tag','cols', ...
      'string','');

   coltitles(m) = h1;

end

for n = 1:r

   bot = 24 + 21.*(r-n);

   h1 = uicontrol('parent',h_fig, ...
      'style','checkbox', ...
      'foregroundcolor',[0 0 .7], ...
      'backgroundcolor',[.85 .85 .85], ...
      'fontsize',fontsize, ...
      'fontweight','bold', ...
      'horizontalalignment','center', ...
      'position',[3 bot 70 20], ...
      'string',int2str(n), ...
      'value',0, ...
      'callback','ui_datagrid(''check'')', ...
      'userdata',n, ...
      'tag','row');

   rowtitles(n) = h1;

   for m = 1:c

      lft = 74 + (colwid+1).*(m-1);

      h1 = uicontrol('parent',h_fig, ...
         'style','edit', ...
         'fontsize',fontsize, ...
         'foregroundcolor',[0 0 0], ...
         'backgroundcolor',[1 1 1], ...
         'horizontalalignment',halign, ...
         'position',[lft bot colwid 20], ...
         'callback','ui_datagrid(''edit'')', ...
         'interruptible','off', ...
         'busyaction','queue', ...
         'string','', ...
         'tag','cell', ...
         'userdata',[n,m]);

      grid(n,m) = h1;

   end

end