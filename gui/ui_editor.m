function ui_editor(op,s,cb,h_cb)
%GCE Data Toolbox data structure editor for managing and analyzing data stored in GCE Data Structures
%
%syntax: ui_editor(op,s,cb,h_cb)
%
%input:
%  op = operation (default = 'init')
%  s = initial data structure to edit, or fully-qualified filename of .mat file
%      containing a data structure variable named 'data'
%  cb = callback to execute upon saving data (when calling ui_editor from another GUI)
%  h_db = UI handle for storing the updated data (typically a UI handle of the calling GUI)
%
%output
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
%last modified: 27-Aug-2015

%default to 'init' if no input arguments
if nargin == 0
   op = 'init';
   s = [];
elseif isstruct(op)  %assume 'init' omitted and first argument is data structure
   s = op;
   op = 'init';
else
   if isempty(op)
      op = 'init';
   end
   if exist('s','var') ~= 1
      s = [];
   end
end

errmsg = '';    %initialize error message
curpath = pwd;  %cache the working directory

if strcmp(op,'init')  %build the gui

   %check for filename of structure to load passed as second argument
   if ~isempty(s) && ischar(s) && exist(s,'file') == 2
      try
         fn = s;
         var = load(fn,'-mat');
      catch
         var = struct('null','');
      end
      if isfield(var,'data') && gce_valid(var.data) == 1
         s = var.data;
      end
   end

   %check for callback info for tool calls
   if exist('cb','var') ~= 1
      cb = '';
   end
   if exist('h_cb','var') ~= 1
      h_cb = [];
   end

   stylestr = '';
   stylelist = [];
   if exist('metastyles.mat','file') == 2
      try
         v = load('metastyles.mat');
         stylelist = {v.styles.name};
         stylestr = {v.styles.description};
      catch
         stylelist = {''};
         stylestr = {''};
      end
   end

   bgcolor = [.95 .95 .95];  %background color value for fig, text
   res = get(0,'ScreenSize');  %get screen resolution for figure placement
   mlversionstr = version;  %get MATLAB version
   mlversion = str2double(mlversionstr(1));  %truncate to major version number

   %check for other instances, cascade windows
   if length(findobj) > 1
      h = findobj('Tag','dlgDSEditor');
      if ~isempty(h)
         pos = get(h(1),'Position');
         for n = 2:length(h)
            newpos = get(h(n),'Position');
            pos = [max(pos(1),newpos(1)) min(pos(2),newpos(2)) pos(3:4)];
         end
         figpos = [min(res(3)-485,pos(1)+25) max(50,pos(2)-25) 495 625];
         uih = get(h(length(h)),'UserData');  %get saved state info from last open editor window
         loadpath = get(uih.mnuLoad,'UserData');  %get load path
         savepath = get(uih.mnuSave,'UserData');  %get save path
         clear uih
      end
   else
      h = [];
   end

   %if no prior instances, set default position
   if isempty(h)
      figpos = [10 res(4)-680 495 625];
      loadpath = curpath;
      savepath = curpath;
   end

   %create figure
   h_fig = figure('Visible','off', ...
      'Color',bgcolor, ...
      'KeyPressFcn','figure(gcf)', ...
      'MenuBar','none', ...
      'Name','Data Structure Editor', ...
      'NumberTitle','off', ...
      'Position',figpos, ...
      'Tag','dlgDSEditor', ...
      'ToolBar','none', ...
      'Resize','off', ...
      'DefaultuicontrolUnits','pixels', ...
      'CloseRequestFcn','ui_editor(''quit'')');

   if mlversion >= 7
      set(h_fig,'WindowStyle','normal')
      set(h_fig,'DockControls','off')
   end

   %define supported date formats for conversion options   
   dateformats = {NaN,'MATLAB serial date'; ...
      -1,'Spreadsheet serial date'; ...
      0,'dd-mmm-yyyy HH:MM:SS'; ...
      1,'dd-mmm-yyyy'; ...
      2,'mm/dd/yy'; ...
      3,'mmm'; ...
      4,'m'; ...
      5,'mm'; ...
      6,'mm/dd'; ...
      7,'dd'; ...
      8,'ddd'; ...
      9,'d'; ...
      10,'yyyy'; ...
      11,'yy'; ...
      12,'mmmyy'; ...
      13,'HH:MM:SS'; ...
      14,'HH:MM:SS PM'; ...
      15,'HH:MM'; ...
      16,'HH:MM PM'; ...
      17,'QQ-YY'; ...
      18,'QQ'; ...
      19,'dd/mm'; ...
      20,'dd/mm/yy'; ...
      21,'mmm.dd,yyyy HH:MM:SS'; ...
      22,'mmm.dd,yyyy'; ...
      23,'mm/dd/yyyy'; ...
      24,'dd/mm/yyyy'; ...
      25,'yy/mm/dd'; ...
      26,'yyyy/mm/dd'; ...
      27,'QQ-YYYY'; ...
      28,'mmmyyyy'; ...
      29,'yyyy-mm-dd'; ...
      30,'yyyymmddTHHMMSS'; ...
      31,'yyyy-mm-dd HH:MM:SS'};
   
   %create menu structure
   h_mnuFile = uimenu('Parent',h_fig, ...
      'Label','File', ...
      'Tag','mnuFile');

   h_mnuEdit = uimenu('Parent',h_fig, ...
      'Label','Edit', ...
      'Tag','mnuEdit');

   h_mnuMetadata = uimenu('Parent',h_fig, ...
      'Label','Metadata', ...
      'Tag','mnuMetadata');

   h_mnuTools = uimenu('Parent',h_fig, ...
      'Label','Tools', ...
      'Tag','mnuTools');

   h_mnuMisc = uimenu('Parent',h_fig, ...
      'Label','Misc', ...
      'Tag','mnuMisc');

   h_mnuWindow = uimenu('Parent',h_fig, ...
      'Label','Window', ...
      'Tag','mnuWindow');

   h_mnuHelp = uimenu('Parent',h_fig, ...
      'Label','Help', ...
      'Tag','mnuHelp');

   if ~isempty(cb) && ~isempty(s)
      ud = struct('cb',cb,'h_cb',h_cb);
      uimenu('Parent',h_mnuFile, ...
         'Label','Return Data', ...
         'Tag','mnuReturnData', ...
         'Callback','ui_editor(''return'')', ...
         'UserData',ud);
      sep = 'on';
   else
      sep = 'off';
   end

   h_mnuLoad = uimenu('Parent',h_mnuFile, ...
      'Label','Load Data Structure', ...
      'Separator',sep, ...
      'Tag','mnuLoad', ...
      'UserData',loadpath);

   uimenu('Parent',h_mnuLoad, ...
      'Label','Load Structure from File', ...
      'Accelerator','L', ...
      'Callback','ui_editor(''load'',''file'')');

   uimenu('Parent',h_mnuLoad, ...
      'Label','Load Structure from Workspace', ...
      'Callback','ui_editor(''load'',''var'')');

   h_mnuImport = uimenu('Parent',h_mnuFile, ...
      'Label','Import Data', ...
      'Tag','mnuImport');

   h_mnuImpAscii = uimenu('Parent',h_mnuImport, ...
      'Label','Delimited Text File (ASCII)', ...
      'Tag','mnuImpAscii');

   uimenu('Parent',h_mnuImpAscii, ...
      'Label','Simple Parsing', ...
      'Accelerator','I', ...
      'Tag','mnuImpAsciiAuto', ...
      'Callback','ui_editor(''imp_ascii'')');

   uimenu('Parent',h_mnuImpAscii, ...
      'Label','Custom Parsing', ...
      'Tag','mnuImpAsciiCust', ...
      'Callback','ui_editor(''imp_ascii_cust'')');

   h_mnuImpMatlabFile = uimenu('Parent',h_mnuImport, ...
      'Label','MATLAB Data File', ...
      'Tag','mnuImpMatlab');

   uimenu('Parent',h_mnuImpMatlabFile, ...
      'Label','Individual Arrays', ...
      'Tag','mnuImpMatlabVarsArrays', ...
      'Callback','ui_editor(''imp_matlab'')');

   uimenu('Parent',h_mnuImpMatlabFile, ...
      'Label','Structure Arrays', ...
      'Tag','mnuImpMatlabVarsStruct', ...
      'Callback','ui_editor(''imp_matlab_struct'')');

   h_mnuImpMatlabVars = uimenu('Parent',h_mnuImport, ...
      'Label','MATLAB Workspace Variables', ...
      'Tag','mnuImpMatlabVars');
   
   uimenu('Parent',h_mnuImpMatlabVars, ...
      'Label','Individual Arrays', ...
      'Tag','mnuImpMatlabVarsArrays', ...
      'Callback','ui_editor(''imp_matlab_vars'',''arrays'')');

   uimenu('Parent',h_mnuImpMatlabVars, ...
      'Label','Structure Arrays', ...
      'Tag','mnuImpMatlabVarsStruct', ...
      'Callback','ui_editor(''imp_matlab_vars'',''struct'')');

   if exist('urlwrite','file') == 2 || exist('urlwrite','file') == 6
      fetchvis = 'on';
   else
      fetchvis = 'off';
   end

   uimenu('Parent',h_mnuImport, ...
      'Label','LTER ClimDB Data (WWW)', ...
      'Separator','on', ...
      'Enable',fetchvis, ...
      'Callback','ui_fetch_climdb(''init'',findobj(gcf,''Tag'',''mnuHarvestClimdb''),''ui_editor(''''imp_fetchclimdb'''')'')', ...
      'Tag','mnuHarvestClimdb');
   
   uimenu('Parent',h_mnuImport, ...
      'Label','EML Data Table (WWW)', ...
      'Enable',fetchvis, ...
      'Callback','ui_editor(''imp_emldata'')', ...
      'Tag','mnuFetchEMLData');

   uimenu('Parent',h_mnuImport, ...
      'Label','USGS NWIS Data (WWW)', ...
      'Enable',fetchvis, ...
      'Callback','ui_fetch_usgs(''init'',findobj(gcf,''Tag'',''mnuHarvestUSGS''),''ui_editor(''''imp_fetchusgs'''')'')', ...
      'Tag','mnuHarvestUSGS');

   uimenu('Parent',h_mnuImport, ...
      'Label','NOAA NCDC GHCN-D Data (WWW)', ...
      'Enable',fetchvis, ...
      'Callback','ui_fetch_ncdc_ghcnd(''init'',findobj(gcf,''Tag'',''mnuHarvestNCDC''),''ui_editor(''''imp_ncdc'''')'')', ...
      'Tag','mnuHarvestNCDC');

   %check for extra Data Turbine dependencies, override fetchvis if 'on'
   if exist('DTsource2gce.m','file') ~= 2 || exist('DTget.m','file') ~= 2
      fetchvis = 'off';
   end
   uimenu('Parent',h_mnuImport, ...
      'Label','Data Turbine Channel Data (WWW)', ...
      'Enable',fetchvis, ...
      'Callback','ui_fetch_dataturbine(''init'',findobj(gcf,''Tag'',''mnuHarvestDT''),''ui_editor(''''imp_dataturbine'''')'')', ...
      'Tag','mnuHarvestDT');

   h_mnuLoadTemp = uimenu('Parent',h_mnuFile, ...
      'Label','Import Metadata', ...
      'Tag','mnuLoadTemp', ...
      'Enable','off', ...
      'UserData',0);

   h_mnuLoadTempData = uimenu('Parent',h_mnuLoadTemp, ...
      'Label','Existing Data Structure', ...
      'Tag','mnuLoadTempDS');
   
   uimenu('Parent',h_mnuLoadTempData, ...
      'Label','All Metadata', ...
      'Tag','mnuLoadTempDataAll', ...
      'Callback','ui_editor(''loadfile'',''all'')');

   uimenu('Parent',h_mnuLoadTempData, ...
      'Label','Column Metadata & Selected Documentation', ...
      'Tag','mnuLoadTempDataSel', ...
      'Callback','ui_editor(''loadfile'',''selected'')');

   uimenu('Parent',h_mnuLoadTempData, ...
      'Label','Column Metadata Only', ...
      'Tag','mnuLoadTempDataNone', ...
      'Callback','ui_editor(''loadfile'',''attributes'')');

   uimenu('Parent',h_mnuLoadTempData, ...
      'Label','Documentation Only', ...
      'Tag','mnuLoadTempDataNone', ...
      'Callback','ui_editor(''loadfile'',''doc_all'')');

   uimenu('Parent',h_mnuLoadTempData, ...
      'Label','Selected Documentation Only', ...
      'Tag','mnuLoadTempDataNone', ...
      'Callback','ui_editor(''loadfile'',''doc_selected'')');

   h_mnuLoadTempStd = uimenu('Parent',h_mnuLoadTemp, ...
      'Label','Standard Template', ...
      'Tag','mnuLoadTempStd');

   uimenu('Parent',h_mnuLoadTempStd, ...
      'Label','All Metadata', ...
      'Tag','mnuLoadTempDataAll', ...
      'Callback','ui_editor(''template'',''all'')');

   uimenu('Parent',h_mnuLoadTempStd, ...
      'Label','Column Metadata & Selected Documentation', ...
      'Tag','mnuLoadTempDataSel', ...
      'Callback','ui_editor(''template'',''selected'')');

   uimenu('Parent',h_mnuLoadTempStd, ...
      'Label','Column Metadata Only', ...
      'Tag','mnuLoadTempDataNone', ...
      'Callback','ui_editor(''template'',''attributes'')');

   uimenu('Parent',h_mnuLoadTempStd, ...
      'Label','Documentation Only', ...
      'Tag','mnuLoadTempDataNone', ...
      'Callback','ui_editor(''template'',''doc_all'')');

   uimenu('Parent',h_mnuLoadTempStd, ...
      'Label','Selected Documentation Only', ...
      'Tag','mnuLoadTempDataNone', ...
      'Callback','ui_editor(''template'',''doc_selected'')');

   uimenu('Parent',h_mnuFile, ...
      'Label','Batch Import Files', ...
      'Separator','on', ...
      'Callback','ui_batch_import(''init'')');
   
   uimenu('Parent',h_mnuFile, ...
      'Label','Batch Export Files', ...
      'Callback','ui_exportasc(''init'',[])');

   h_mnuImpJoin = uimenu('Parent',h_mnuFile, ...
      'Label','Join Data Sets', ...
      'Separator','on', ...
      'Enable','off', ...
      'Tag','mnuImpJoin');

   h_mnuImpJoinMan = uimenu('Parent',h_mnuImpJoin, ...
      'Label','Manual Key Selection');

   h_mnuImpJoinAuto = uimenu('Parent',h_mnuImpJoin, ...
      'Label','Automatic Date/Time Join');

   uimenu('Parent',h_mnuImpJoinMan, ...
      'Label','Data Structure File', ...
      'Accelerator','J', ...
      'Callback','ui_editor(''imp_join'')');

   uimenu('Parent',h_mnuImpJoinMan, ...
      'Label','Open Data Structure', ...
      'Callback','ui_editor(''imp_join_open'')');

   uimenu('Parent',h_mnuImpJoinAuto, ...
      'Label','Data Structure File', ...
      'Callback','ui_editor(''imp_join2'')');

   uimenu('Parent',h_mnuImpJoinAuto, ...
      'Label','Open Data Structure', ...
      'Callback','ui_editor(''imp_join_open2'')');

   h_mnuImpMerge = uimenu('Parent',h_mnuFile, ...
      'Label','Merge Data Sets', ...
      'Enable','off', ...
      'Tag','mnuImpMerge');

   h_mnuImpDS1 = uimenu('Parent',h_mnuImpMerge, ...
      'Label','Append New Data', ...
      'Tag','mnuImpDS');

   uimenu('Parent',h_mnuImpDS1, ...
      'Label','Data Structure File', ...
      'Accelerator','A', ...
      'Callback','ui_editor(''imp_ds1'')');

   uimenu('Parent',h_mnuImpDS1, ...
      'Label','Open Data Structure', ...
      'Callback','ui_editor(''imp_ds1_open'')');

   h_mnuImpDS2 = uimenu('Parent',h_mnuImpMerge, ...
      'Label','Prepend New Data', ...
      'Tag','mnuImpDS2');

   uimenu('Parent',h_mnuImpDS2, ...
      'Label','Data Structure File', ...
      'Callback','ui_editor(''imp_ds2'')');

   uimenu('Parent',h_mnuImpDS2, ...
      'Label','Open Data Structure', ...
      'Callback','ui_editor(''imp_ds2_open'')');

   h_mnuImpDS3 = uimenu('Parent',h_mnuImpMerge, ...
      'Separator','on', ...
      'Label','Time-Series Merge (overwrite older records)', ...
      'Tag','mnuImpDS3');

   uimenu('Parent',h_mnuImpDS3, ...
      'Label','Data Structure File', ...
      'Accelerator','R', ...
      'Callback','ui_editor(''imp_ds3'')');

   uimenu('Parent',h_mnuImpDS3, ...
      'Label','Open Data Structure', ...
      'Callback','ui_editor(''imp_ds3_open'')');

   h_mnuImpDS4 = uimenu('Parent',h_mnuImpMerge, ...
      'Label','Time-Series Merge (add newer records)', ...
      'Tag','mnuImpDS4');

   uimenu('Parent',h_mnuImpDS4, ...
      'Label','Data Structure File', ...
      'Callback','ui_editor(''imp_ds4'')');

   uimenu('Parent',h_mnuImpDS4, ...
      'Label','Open Data Structure', ...
      'Callback','ui_editor(''imp_ds4_open'')');

   %include menu items for additional filters based on entries in 'imp_filters.mat'
   impfilt = get_importfilters;
   
   if isstruct(impfilt)
      lbl = extract(impfilt,'Label');
      subheads = extract(impfilt,'Subheading');
      if ~isempty(lbl)
         grps = unique(lbl);
         [tmp,Isort] = sort(lower(grps));
         grps = grps(Isort);  %sort groups alphabetically ignoring case
         toprow = 0;
         for n = 1:length(grps)
            if toprow == 0
               toprow = 1;
               sep = 'on';
            else
               sep = 'off';
            end
            I = find(strcmp(lbl,grps{n}));
            if length(I) > 1
               h = uimenu('Parent',h_mnuImport, ...
                  'Label',grps{n}, ...
                  'Separator',sep);
               for m = 1:length(I)
                  uimenu('Parent',h, ...
                     'Label',subheads{I(m)}, ...
                     'Callback',['ui_editor(''imp_filter'',''',lbl{I(m)},'_',subheads{I(m)},''')']);
               end
            elseif length(I) == 1
               subhead = subheads{I};
               if ~isempty(subhead)
                  h = uimenu('Parent',h_mnuImport, ...
                     'Label',lbl{I}, ...
                     'Separator',sep);
                  uimenu('Parent',h, ...
                     'Label',subhead, ...
                     'Callback',['ui_editor(''imp_filter'',''',lbl{I},'_',subhead,''')']);
               else
                  uimenu('Parent',h_mnuImport, ...
                     'Label',lbl{I}, ...
                     'Callback',['ui_editor(''imp_filter'',''',lbl{I},''')'], ...
                     'Separator',sep);
               end
            end
         end
      end
   end

   h_mnuSave = uimenu('Parent',h_mnuFile, ...
      'Label','Save Data Structure', ...
      'Tag','mnuSave', ...
      'Separator','on', ...
      'Enable','off', ...
      'UserData',savepath);
   
   h_mnuSaveDefault = uimenu('Parent',h_mnuSave, ...
      'Label','Standard File', ...
      'Accelerator','S', ...
      'Callback','ui_editor(''save'')', ...
      'Tag','mnuSaveDefault', ...
      'UserData','');

   h_mnuSaveVar = uimenu('Parent',h_mnuSave, ...
      'Label','Named Variable', ...
      'Callback','ui_editor(''save_var'')', ...
      'Tag','mnuSaveVar', ...
      'UserData','data');

   h_mnuSaveTemplate = uimenu('Parent',h_mnuFile, ...
      'Label','Save Metadata Template', ...
      'Tag','mnuSaveTemplate', ...
      'Callback','ui_editor(''save_template'')', ...
      'Enable','off');

   h_mnuExport = uimenu('Parent',h_mnuFile, ...
      'Label','Export Data/Metadata', ...
      'Tag','mnuExport', ...
      'Separator','on', ...
      'Enable','off');

   h_mnuExpAscii = uimenu('Parent',h_mnuExport, ...
      'Label','Text File', ...
      'Tag','mnuExpAscii');

   uimenu('Parent',h_mnuExpAscii, ...
      'Label','Standard Text File (*.txt,*.csv)', ...
      'Accelerator','E', ...
      'Callback','ui_editor(''exp_ascii'')', ...
      'Tag','mnuExpAsciiStd');

   h_mnuSaveHeader = uimenu('Parent',h_mnuExpAscii, ...
      'Label','Toolbox ASCII Import File', ...
      'Tag','mnuSaveHeader');

   uimenu('Parent',h_mnuSaveHeader, ...
      'Label','Header Only', ...
      'Tag','mnuSaveHeaderOnly', ...
      'Callback','ui_editor(''exp_header'')');

   uimenu('Parent',h_mnuSaveHeader, ...
      'Label','Header and Data', ...
      'Tag','mnuSaveHeaderData', ...
      'Callback','ui_editor(''exp_header_data'')');

   uimenu('Parent',h_mnuSaveHeader, ...
      'Label','Header, Data and All Flags', ...
      'Tag','mnuSaveHeaderFlags', ...
      'Callback','ui_editor(''exp_header_flags'')');   

   uimenu('Parent',h_mnuSaveHeader, ...
      'Label','Header, Data and Manual Flags', ...
      'Tag','mnuSaveHeaderFlags', ...
      'Callback','ui_editor(''exp_header_manual'')');   

   h_mnuExpAsciiHTML = uimenu('Parent',h_mnuExpAscii, ...
      'Label','XML/HTML File', ...
      'Tag','mnuExpHTML');

   uimenu('Parent',h_mnuExpAsciiHTML, ...
      'Label','Google Earth KML/XML File', ...
      'Callback','ui_editor(''exp_kml'')', ...
      'Tag','mnuExpHTMLKML');
   
   uimenu('Parent',h_mnuExpAsciiHTML, ...
      'Label','Standard XML File', ...
      'Callback','ui_editor(''exp_xml'')', ...
      'Tag','mnuExpHTMLXML');
   
   uimenu('Parent',h_mnuExpAsciiHTML, ...
      'Label','HTML File (column-oriented table)', ...
      'Separator','on', ...
      'Callback','ui_editor(''exp_html'',''column'')', ...
      'Tag','mnuExpHTMLCol');
   
   uimenu('Parent',h_mnuExpAsciiHTML, ...
      'Label','HTML File (row-oriented table)', ...
      'Callback','ui_editor(''exp_html'',''row'')', ...
      'Tag','mnuExpHTMLRow');
   
   uimenu('Parent',h_mnuExpAscii, ...
      'Label','LTER ClimDB/HydroDB File', ...
      'Separator','on', ...
      'Callback','ui_editor(''exp_climdb'')', ...
      'Tag','mnuExpClimdb');
   
   h_mnuExpMat = uimenu('Parent',h_mnuExport, ...
      'Label','MATLAB File', ...
      'Tag','mnuExpMat');
   
   h_mnuExpMatStruct = uimenu('Parent',h_mnuExpMat, ...
      'Label','Struct Variable', ...
      'Tag','mnuExpMatStruct');

   h_mnuExpMatVars = uimenu('Parent',h_mnuExpMat, ...
      'Label','Individual Array Variables', ...
      'Tag','mnuExpMatVars');
   
   h_mnuExpMatMatrix = uimenu('Parent',h_mnuExpMat, ...
      'Label','Matrix Variable', ...
      'Tag','mnuExpMatMatrix');
   
   uimenu('Parent',h_mnuExpMatVars, ...
      'Label','No Metadata', ...
      'Tag','mnuExpMatVarsNometa', ...
      'Callback','ui_editor(''exp_matlab_vars'','''')');

   if exist('stylelist','var') == 1 && exist('stylestr','var') == 1 %check for existing metadata styles
      for n = 1:length(stylelist)
         if n == 1
            sep = 'on';
         else
            sep = 'off';
         end
         uimenu('Parent',h_mnuExpMatVars, ...
            'Label',['Metadata in ',stylestr{n},' Style'], ...
            'Separator',sep, ...
            'Callback',['ui_editor(''exp_matlab_vars'',''',stylelist{n},''');'], ...
            'Tag','mnuExpMatVarsStyles');
      end
   end
   
   uimenu('Parent',h_mnuExpMatStruct, ...
      'Label','No Metadata', ...
      'Tag','mnuExpStructNometa', ...
      'Callback','ui_editor(''exp_matlab_struct'','''')');

   if exist('stylelist','var') == 1 && exist('stylestr','var') == 1 %check for existing metadata styles
      for n = 1:length(stylelist)
         if n == 1
            sep = 'on';
         else
            sep = 'off';
         end
         uimenu('Parent',h_mnuExpMatStruct, ...
            'Label',['Metadata in ',stylestr{n},' Style'], ...
            'Separator',sep, ...
            'Callback',['ui_editor(''exp_matlab_struct'',''',stylelist{n},''');'], ...
            'Tag','mnuExpStructStyles', ...
            'Enable','on');
      end
   end
   
   uimenu('Parent',h_mnuExpMatMatrix, ...
      'Label','No Metadata', ...
      'Tag','mnuExpMatNometa', ...
      'Callback','ui_editor(''exp_matlab_mat'','''')');

   if exist('stylelist','var') == 1 && exist('stylestr','var') == 1 %check for existing metadata styles
      for n = 1:length(stylelist)
         if n == 1
            sep = 'on';
         else
            sep = 'off';
         end
         uimenu('Parent',h_mnuExpMatMatrix, ...
            'Label',['Metadata in ',stylestr{n},' Style'], ...
            'Separator',sep, ...
            'Callback',['ui_editor(''exp_matlab_mat'',''',stylelist{n},''');'], ...
            'Tag','mnuExpMatStyles', ...
            'Enable','on');
      end
   end
   
   h_mnuExpEML = uimenu('Parent',h_mnuExport, ...
      'Label','EML Data Package', ...
      'Separator','on', ...
      'Callback','ui_editor(''exp_eml'')', ...
      'Tag','mnuExpEML');
   
   h_mnuExpWS = uimenu('Parent',h_mnuExport, ...
      'Label','Copy Structure to Workspace', ...
      'Separator','on', ...
      'Accelerator','B', ...
      'Callback','ui_editor(''tool_ws'')', ...
      'Tag','mnuExpWS');

   h_mnuExpWSCol = uimenu('Parent',h_mnuExport, ...
      'Label','Copy Columns to Workspace', ...
      'Tag','mnuExpWSCol');

   uimenu('Parent',h_mnuExpWSCol, ...
      'Label','All Columns', ...
      'Callback','ui_editor(''tool_wscol_all'')', ...
      'Tag','mnuExpWSCol_All');

   uimenu('Parent',h_mnuExpWSCol, ...
      'Label','Selected Column(s)', ...
      'Callback','ui_editor(''tool_wscol_sel'')', ...
      'Tag','mnuExpWSCol_Sel');

   uimenu('Parent',h_mnuExport, ...
      'Separator','on', ...
      'Label','Copy Structure to Search Engine', ...
      'Callback','ui_editor(''tool_searcheng'')', ...
      'Tag','mnuExpSearchEng');

   uimenu('Parent',h_mnuExport, ...
      'Label','Move Structure to Search Engine', ...
      'Callback','ui_editor(''tool_searchengmove'')', ...
      'Tag','mnuExpSearchEngMove');

   h_mnuClone = uimenu('Parent',h_mnuFile, ...
      'Label','Clone Data Structure', ...
      'Separator','on', ...
      'Tag','mnuClone', ...
      'Enable','off');
   
   uimenu('Parent',h_mnuClone, ...
      'Label','All Columns', ...
      'Callback','ui_editor(''tool_clone'',''all'')');

   uimenu('Parent',h_mnuClone, ...
      'Label','Selected Columns', ...
      'Callback','ui_editor(''tool_clone'',''selected'')');

   uimenu('Parent',h_mnuFile, ...
      'Label','Clear Data', ...
      'Separator','on', ...
      'Tag','mnuClear', ...
      'Callback','ui_editor(''clear'')');

   h_mnuQuit = uimenu('Parent',h_mnuFile, ...
      'Label','Close Window', ...
      'Accelerator','Q', ...
      'Tag','mnuQuit', ...
      'UserData',0, ...
      'Callback','ui_editor(''quit'')');

   uimenu('Parent',h_mnuFile, ...
      'Label','Exit MATLAB', ...
      'Separator','on', ...
      'Tag','mnuQuitAll', ...
      'Accelerator','X', ...
      'UserData',0, ...
      'Callback','close_gdt(''quit'')');

   h_mnuTitle = uimenu('Parent',h_mnuEdit, ...
      'Label','View/Edit Title', ...
      'Accelerator','T', ...
      'Tag','mnuTitle', ...
      'Callback','ui_editor(''title'')', ...
      'Enable','off');

   h_mnuEditData = uimenu('Parent',h_mnuEdit, ...
      'Label','View/Edit Data', ...
      'Accelerator','D', ...
      'Tag','mnuEditData', ...
      'Callback','ui_editor(''tool_editdata'')', ...
      'Enable','off');

   h_mnuAddCol = uimenu('Parent',h_mnuEdit, ...
      'Label','Add Data Columns', ...
      'Tag','mnuAddCol', ...
      'Separator','on', ...
      'Enable','off');

   h_mnuAddVars = uimenu('Parent',h_mnuAddCol, ...
      'Label','Add/Update Column(s) from Workspace', ...
      'Tag','mnuAddVars');

   uimenu('Parent',h_mnuAddVars, ...
      'Label','Update Existing Columns', ...
      'Callback','ui_editor(''tool_addvar'',''update'')', ...
      'Tag','mnuAddVarsUpdate');

   uimenu('Parent',h_mnuAddVars, ...
      'Label','Add as New Columns', ...
      'Callback','ui_editor(''tool_addvar'',''new'')', ...
      'Tag','mnuAddVarsNew');

   h_mnuCalc = uimenu('Parent',h_mnuAddCol, ...
      'Label','Add Calculated Column(s)', ...
      'Separator','on', ...
      'Tag','mnuCalc', ...
      'Callback','ui_editor(''tool_calc'')');

   uimenu('Parent',h_mnuAddCol, ...
      'Label','Add Empty Integer Column', ...
      'Separator','on', ...
      'Tag','mnuAddIntCol', ...
      'Callback','ui_editor(''tool_addintcol'')');

   uimenu('Parent',h_mnuAddCol, ...
      'Label','Add Empty Floating-Point Column', ...
      'Tag','mnuAddFPCol', ...
      'Callback','ui_editor(''tool_addfpcol'')');

   uimenu('Parent',h_mnuAddCol, ...
      'Label','Add Empty Text Column', ...
      'Tag','mnuAddStrCol', ...
      'Callback','ui_editor(''tool_addstrcol'')');

   h_mnuCopyCol = uimenu('Parent',h_mnuEdit, ...
      'Label','Copy Data Columns', ...
      'Tag','mnuCopyCol', ...
      'Enable','off');

   uimenu('parent',h_mnuCopyCol, ...
      'Label','All Columns', ...
      'Tag','mnuCopyColAll', ...
      'Callback','ui_editor(''tool_copycol'',''all'')');

   uimenu('parent',h_mnuCopyCol, ...
      'Label','Selected Column(s)', ...
      'Tag','mnuCopyColSelected', ...
      'Callback','ui_editor(''tool_copycol'',''selected'')');

   h_mnuConvertDataType = uimenu('Parent',h_mnuEdit, ...
      'Label','Convert Column Data Types', ...
      'Tag','mnuConvertDataType', ...
      'Separator','on', ...
      'Enable','off');

   h_mnuConvertDataTypeAll = uimenu('Parent',h_mnuConvertDataType, ...
      'Label','All Columns', ...
      'Tag','mnuConverDataTypeAll');

   h_mnuConvertDataTypeSel = uimenu('Parent',h_mnuConvertDataType, ...
      'Label','Selected Column(s)', ...
      'Tag','mnuConverDataTypeSel');

   uimenu('Parent',h_mnuConvertDataTypeSel, ...
      'Label','To String', ...
      'Callback','ui_editor(''tool_convert'',''s_sel'')');

   uimenu('Parent',h_mnuConvertDataTypeSel, ...
      'Label','To Floating-Point', ...
      'Callback','ui_editor(''tool_convert'',''f_sel'')');

   uimenu('Parent',h_mnuConvertDataTypeSel, ...
      'Label','To Exponential', ...
      'Callback','ui_editor(''tool_convert'',''e_sel'')');

   uimenu('Parent',h_mnuConvertDataTypeSel, ...
      'Label','To Integer (round closest)', ...
      'Separator','on', ...
      'Callback','ui_editor(''tool_convert'',''dr_sel'')');

   uimenu('Parent',h_mnuConvertDataTypeSel, ...
      'Label','To Integer (round up)', ...
      'Callback','ui_editor(''tool_convert'',''du_sel'')');

   uimenu('Parent',h_mnuConvertDataTypeSel, ...
      'Label','To Integer (round down)', ...
      'Callback','ui_editor(''tool_convert'',''dd_sel'')');

   uimenu('Parent',h_mnuConvertDataTypeSel, ...
      'Label','To Integer (truncate)', ...
      'Callback','ui_editor(''tool_convert'',''dt_sel'')');

   uimenu('Parent',h_mnuConvertDataTypeAll, ...
      'Label','To String', ...
      'Callback','ui_editor(''tool_convert'',''s_all'')');

   uimenu('Parent',h_mnuConvertDataTypeAll, ...
      'Label','To Floating-Point', ...
      'Callback','ui_editor(''tool_convert'',''f_all'')');

   uimenu('Parent',h_mnuConvertDataTypeAll, ...
      'Label','To Exponential', ...
      'Callback','ui_editor(''tool_convert'',''e_all'')');

   uimenu('Parent',h_mnuConvertDataTypeAll, ...
      'Label','To Integer (round closest)', ...
      'Separator','on', ...
      'Callback','ui_editor(''tool_convert'',''dr_all'')');

   uimenu('Parent',h_mnuConvertDataTypeAll, ...
      'Label','To Integer (round up)', ...
      'Callback','ui_editor(''tool_convert'',''du_all'')');

   uimenu('Parent',h_mnuConvertDataTypeAll, ...
      'Label','To Integer (round down)', ...
      'Callback','ui_editor(''tool_convert'',''dd_all'')');

   uimenu('Parent',h_mnuConvertDataTypeAll, ...
      'Label','To Integer (truncate)', ...
      'Callback','ui_editor(''tool_convert'',''dt_all'')');

   h_mnuPrec = uimenu('Parent',h_mnuEdit, ...
      'Label','Set Precision As Displayed', ...
      'Enable','off');
   
   h_mnuPrecAll = uimenu('Parent',h_mnuPrec, ...
      'Label','All Columns');
   
   h_mnuPrecSel = uimenu('Parent',h_mnuPrec, ...
      'Label','Selected Column(s)');

   uimenu('Parent',h_mnuPrecAll, ...
      'Label','Round to Nearest Digit', ...
      'Tag','mnuPrecRound', ...
      'Callback',['confirmdlg(''init'',''Round all numeric values to displayed precision? (data may be lost)'',', ...
      '''ui_editor(''''tool_fixprec_all'''',''''round'''')'')']);

   uimenu('Parent',h_mnuPrecAll, ...
      'Label','Round Up (ceiling)', ...
      'Tag','mnuPrecCeil', ...
      'Callback',['confirmdlg(''init'',''Round all numeric values up to displayed precision? (data may be lost)'',', ...
      '''ui_editor(''''tool_fixprec_all'''',''''ceil'''')'')']);

   uimenu('Parent',h_mnuPrecAll, ...
      'Label','Round Down (floor)', ...
      'Tag','mnuPrecFloor', ...
      'Callback',['confirmdlg(''init'',''Round all numeric values down to displayed precision? (data may be lost)'',', ...
      '''ui_editor(''''tool_fixprec_all'''',''''floor'''')'')']);

   uimenu('Parent',h_mnuPrecAll, ...
      'Label','Truncate (fix)', ...
      'Tag','mnuPrecFix', ...
      'Callback',['confirmdlg(''init'',''Truncate all numeric values to displayed precision? (data may be lost)'',', ...
      '''ui_editor(''''tool_fixprec_all'''',''''fix'''')'')']);

   uimenu('Parent',h_mnuPrecSel, ...
      'Label','Round to Nearest Digit', ...
      'Tag','mnuPrecRound', ...
      'Callback',['confirmdlg(''init'',''Round numeric values in selected columns to displayed precision? (data may be lost)'',', ...
      '''ui_editor(''''tool_fixprec_sel'''',''''round'''')'')']);

   uimenu('Parent',h_mnuPrecSel, ...
      'Label','Round Up (ceiling)', ...
      'Tag','mnuPrecCeil', ...
      'Callback',['confirmdlg(''init'',''Round numeric values in selected columns to displayed precision? (data may be lost)'',', ...
      '''ui_editor(''''tool_fixprec_sel'''',''''ceil'''')'')']);

   uimenu('Parent',h_mnuPrecSel, ...
      'Label','Round Down (floor)', ...
      'Tag','mnuPrecFloor', ...
      'Callback',['confirmdlg(''init'',''Round numeric values in selected columns to displayed precision? (data may be lost)'',', ...
      '''ui_editor(''''tool_fixprec_sel'''',''''floor'''')'')']);

   uimenu('Parent',h_mnuPrecSel, ...
      'Label','Truncate (fix)', ...
      'Tag','mnuPrecFix', ...
      'Callback',['confirmdlg(''init'',''Truncate numeric values in selected columns to displayed precision? (data may be lost)'',', ...
      '''ui_editor(''''tool_fixprec_sel'''',''''fix'''')'')']);

   h_mnuEditCoalesce = uimenu('Parent',h_mnuEdit, ...
      'Label','Coalesce Multiple Columns', ...
      'Separator','on', ...
      'Enable','off');

   uimenu('Parent',h_mnuEditCoalesce, ...
      'Label','Delete Coalesced Columns', ...
      'Callback',['confirmdlg(''init'',''Delete original columns after coalescing values? (only the first column will be retained)'',', ...
      '''ui_editor(''''tool_coalesce'''',''''delete'''')'')']);

   uimenu('Parent',h_mnuEditCoalesce, ...
      'Label','Retain Original Columns', ...
      'Callback','ui_editor(''tool_coalesce'',''retain'')');

   h_mnuEditConcat = uimenu('Parent',h_mnuEdit, ...
      'Label','Concatenate Column Values', ...
      'Enable','off');

   uimenu('Parent',h_mnuEditConcat, ...
      'Label','No Separator', ...
      'Callback','ui_editor(''tool_concat'','''')');

   uimenu('Parent',h_mnuEditConcat, ...
      'Label','Underscore Separator (_)', ...
      'Callback','ui_editor(''tool_concat'',''_'')');

   uimenu('Parent',h_mnuEditConcat, ...
      'Label','Dash Separator (-)', ...
      'Callback','ui_editor(''tool_concat'',''-'')');

   uimenu('Parent',h_mnuEditConcat, ...
      'Label','Slash Separator (/)', ...
      'Callback','ui_editor(''tool_concat'',''/'')');

   uimenu('Parent',h_mnuEditConcat, ...
      'Label','Colon Separator (:)', ...
      'Callback','ui_editor(''tool_concat'','':'')');

   uimenu('Parent',h_mnuEditConcat, ...
      'Label','Semicolon Separator (;)', ...
      'Callback','ui_editor(''tool_concat'','';'')');

   uimenu('Parent',h_mnuEditConcat, ...
      'Label','Space Separator ( )', ...
      'Callback','ui_editor(''tool_concat'','' '')');

   h_mnuEditSplitStr = uimenu('Parent',h_mnuEdit, ...
      'Label','Split Column Values', ...
      'Enable','off');

   uimenu('Parent',h_mnuEditSplitStr , ...
      'Label','Underscore Separator (_)', ...
      'Callback','ui_editor(''tool_splitstr'',''_'')');

   uimenu('Parent',h_mnuEditSplitStr , ...
      'Label','Dash Separator (-)', ...
      'Callback','ui_editor(''tool_splitstr'',''-'')');

   uimenu('Parent',h_mnuEditSplitStr , ...
      'Label','Slash Separator (/)', ...
      'Callback','ui_editor(''tool_splitstr'',''/'')');

   uimenu('Parent',h_mnuEditSplitStr , ...
      'Label','Colon Separator (:)', ...
      'Callback','ui_editor(''tool_splitstr'','':'')');

   uimenu('Parent',h_mnuEditSplitStr , ...
      'Label','Semicolon Separator (;)', ...
      'Callback','ui_editor(''tool_splitstr'','';'')');

   uimenu('Parent',h_mnuEditSplitStr , ...
      'Label','Space Separator ( )', ...
      'Callback','ui_editor(''tool_splitstr'','' '')');

   h_mnuEditEncode = uimenu('Parent',h_mnuEdit, ...
      'Label','Encode Text Columns as Integers', ...
      'Separator','on', ...
      'Tag','mnuEditEncode', ...
      'Enable','off');

   uimenu('Parent',h_mnuEditEncode, ...
      'Label','Update Existing Code Definitions', ...
      'Tag','mnuEditEncodeReconcile', ...
      'Callback','ui_editor(''tool_encode'')');

   uimenu('Parent',h_mnuEditEncode, ...
      'Label','Append to Existing Code Definitions', ...
      'Tag','mnuEditEncodeAppend', ...
      'Callback','ui_editor(''tool_encode2'')');

   h_mnuEditDecode = uimenu('Parent',h_mnuEdit, ...
      'Label','Decode Coded Columns', ...
      'Tag','mnuEditDecode', ...
      'Enable','off');

   uimenu('Parent',h_mnuEditDecode, ...
      'Label','All Coded Columns', ...
      'Tag','mnuEditDecodeAll', ...
      'Callback','ui_editor(''tool_decode'',''all'')');

   uimenu('Parent',h_mnuEditDecode, ...
      'Label','Selected Column(s)', ...
      'Tag','mnuEditDecodeSelected', ...
      'Callback','ui_editor(''tool_decode'',''selected'')');
   
   h_mnuSort = uimenu('Parent',h_mnuEdit, ...
      'Label','Sort Records', ...
      'Accelerator','O', ...
      'Separator','on', ...
      'Tag','mnuSort', ...
      'Callback','ui_editor(''tool_sort'')', ...
      'Enable','off');

   h_mnuReplace = uimenu('Parent',h_mnuEdit, ...
      'Label','Search/Replace Data Values', ...
      'Tag','mnuReplace', ...
      'Enable','off');

   uimenu('Parent',h_mnuReplace, ...
      'Label','Search/Replace Text', ...
      'Tag','mnuReplaceText', ...
      'Callback','ui_editor(''tool_replace'',''text'')');

   uimenu('Parent',h_mnuReplace, ...
      'Label','Search/Replace Number', ...
      'Tag','mnuReplaceNum', ...
      'Callback','ui_editor(''tool_replace'',''num'')');

   h_mnuInterp = uimenu('Parent',h_mnuEdit, ...
      'Label','Interpolate Missing Values', ...
      'Tag','mnuInterp', ...
      'Callback','ui_editor(''tool_interp'')', ...
      'Enable','off');

   h_mnuCalcMissing = uimenu('Parent',h_mnuEdit, ...
      'Label','Calculate Missing Values', ...
      'Tag','mnuCalcMissing', ...
      'Callback','ui_editor(''tool_calcmissing'')', ...
      'Enable','off');

   h_mnuCorrectDrift = uimenu('Parent',h_mnuEdit, ...
      'Label','Correct for Sensor Drift', ...
      'Tag','mnuCorrectDrift', ...
      'Callback','ui_editor(''tool_drift'')', ...
      'Enable','off');

   h_mnuClearDupes = uimenu('Parent',h_mnuEdit, ...
      'Label','Remove Duplicate Records', ...
      'Separator','on', ...
      'Tag','mnuClearDupes', ...
      'Enable','off');

   uimenu('Parent',h_mnuClearDupes, ...
      'Label','All Columns Duplicated', ...
      'Callback','ui_editor(''tool_cleardupes'')', ...
      'Tag','mnuClearDupesAll');

   uimenu('Parent',h_mnuClearDupes, ...
      'Label','Non-data Columns Duplicated', ...
      'Callback','ui_editor(''tool_cleardupes_nd'')', ...
      'Tag','mnuClearDupesNonData');

   uimenu('Parent',h_mnuClearDupes, ...
      'Label','Date/Time Columns Duplicated', ...
      'Callback','ui_editor(''tool_cleardupes_dt'')', ...
      'Tag','mnuClearDupesDateTime');

   h_mnuClearBlanks = uimenu('Parent',h_mnuEdit, ...
      'Label','Remove Empty Records', ...
      'Tag','mnuClearBlanks', ...
      'Enable','off');

   uimenu('Parent',h_mnuClearBlanks, ...
      'Label','All Columns Empty', ...
      'Callback','ui_editor(''tool_clearblanks'')', ...
      'Tag','mnuClearBlanksData');

   uimenu('Parent',h_mnuClearBlanks, ...
      'Label','All Data Columns Empty', ...
      'Callback','ui_editor(''tool_clearblanks2'')', ...
      'Tag','mnuClearBlanksData');

   uimenu('Parent',h_mnuClearBlanks, ...
      'Label','Selected Columns Empty', ...
      'Callback','ui_editor(''tool_clearblanks3'')', ...
      'Tag','mnuClearBlanksData');
   
   h_mnuTrimBlanks = uimenu('Parent',h_mnuEdit, ...
      'Label','Remove Leading/Trailing Blanks', ...
      'Tag','mnuTrimBlanks', ...
      'Enable','off');
   
   uimenu('Parent',h_mnuTrimBlanks, ...
      'Label','All String Columns', ...
      'Callback','ui_editor(''tool_trimstr'',''all'')', ...
      'Tag','mnuClearBlanksData');

   uimenu('Parent',h_mnuTrimBlanks, ...
      'Label','Selected String Columns', ...
      'Callback','ui_editor(''tool_trimstr'',''selected'')', ...
      'Tag','mnuClearBlanksData');
   
   h_mnuClearBlankCols = uimenu('Parent',h_mnuEdit, ...
      'Label','Remove Empty Columns', ...
      'Tag','mnuClearBlankCols', ...
      'Callback','ui_editor(''tool_clearblankcols'')', ...
      'Enable','off');

   h_mnuUnitConv = uimenu('Parent',h_mnuEdit, ...
      'Label','Unit Conversion Functions', ...
      'Separator','on', ...
      'Tag','mnuUnitConv');

   h_mnuUnitsE2M = uimenu('Parent',h_mnuUnitConv, ...
      'Label','Convert English Units to Metric', ...
      'Tag','mnuUnitsE2M', ...
      'Callback','ui_editor(''tool_units_e2m'')', ...
      'Enable','off');

   h_mnuUnitsM2E = uimenu('Parent',h_mnuUnitConv, ...
      'Label','Convert Metric Units to English', ...
      'Tag','mnuUnitsM2E', ...
      'Callback','ui_editor(''tool_units_m2e'')', ...
      'Enable','off');

   uimenu('Parent',h_mnuUnitConv, ...
      'Label','View/Edit Unit Conversions', ...
      'Tag','mnuUnitsEdit1', ...
      'Separator','on', ...
      'Callback','edit_unitconv(''conversions'')');

   uimenu('Parent',h_mnuUnitConv, ...
      'Label','View/Edit English<->Metric Conversions', ...
      'Tag','mnuUnitsEdit2', ...
      'Callback','edit_unitconv(''englishmetric'')');

   h_mnuDateFnc = uimenu('Parent',h_mnuEdit, ...
      'Label','Date Functions', ...
      'Enable','off');
   
   h_mnuConvertDate = uimenu('Parent',h_mnuDateFnc, ...
      'Label','Convert Date/Time Format', ...
      'Tag','mnuConvertDate');
     
   for n = 1:size(dateformats,1)
      uimenu('Parent',h_mnuConvertDate, ...
         'Label',dateformats{n,2}, ...
         'Callback',['ui_editor(''tool_convertdate'',',num2str(dateformats{n,1}),')']);
   end

   h_mnuConvertTimeCSI = uimenu('Parent',h_mnuDateFnc, ...
      'Label','Convert Campbell Time Format', ...
      'Tag','mnuConvertTimeCSI');
   
   uimenu('Parent',h_mnuConvertTimeCSI, ...
      'Label','hhmm (integer)', ...
      'Callback','ui_editor(''tool_timeCSI'',''hhmm'')');
     
   uimenu('Parent',h_mnuConvertTimeCSI, ...
      'Label','hh:mm:ss (string)', ...
      'Separator','on', ...
      'Callback','ui_editor(''tool_timeCSI'',''hh:mm:ss'')');
     
   uimenu('Parent',h_mnuConvertTimeCSI, ...
      'Label','hh:mm:ss PM (string)', ...
      'Callback','ui_editor(''tool_timeCSI'',''hh:mm:ss PM'')');
   
   uimenu('Parent',h_mnuConvertTimeCSI, ...
      'Label','hh:mm (string)', ...
      'Callback','ui_editor(''tool_timeCSI'',''hh:mm'')');
     
   uimenu('Parent',h_mnuConvertTimeCSI, ...
      'Label','hh:mm PM (string)', ...
      'Callback','ui_editor(''tool_timeCSI'',''hh:mm PM'')');
     
   h_mnuAddDateCols = uimenu('Parent',h_mnuDateFnc, ...
      'Label','Date Components from Date Column', ...
      'Separator','on', ...
      'Tag','mnuAddDateCols');

   uimenu('Parent',h_mnuAddDateCols, ...
      'Label','Automatic', ...
      'Callback','ui_editor(''tool_datecols'',[])');

   uimenu('Parent',h_mnuAddDateCols, ...
      'Label','Year, Month, Day', ...
      'Callback','ui_editor(''tool_datecols'',[1 2 3])');

   uimenu('Parent',h_mnuAddDateCols, ...
      'Label','Year, Month, Day, Hour', ...
      'Callback','ui_editor(''tool_datecols'',[1 2 3 4])');

   uimenu('Parent',h_mnuAddDateCols, ...
      'Label','Year, Month, Day, Hour, Minute', ...
      'Callback','ui_editor(''tool_datecols'',[1 2 3 4 5])');

   uimenu('Parent',h_mnuAddDateCols, ...
      'Label','Year, Month, Day, Hour, Minute, Second', ...
      'Callback','ui_editor(''tool_datecols'',[1 2 3 4 5 6])');

   h_mnuAddDateCol = uimenu('Parent',h_mnuDateFnc, ...
      'Label','Date from Date Components', ...
      'Tag','mnuAddDateCol');

   uimenu('Parent',h_mnuAddDateCol, ...
      'Label','Numeric Serial Date (MATLAB)', ...
      'Callback','ui_editor(''tool_date'',[])');

   uimenu('Parent',h_mnuAddDateCol, ...
      'Label','Numeric Serial Date (spreadsheet)', ...
      'Callback','ui_editor(''tool_date'',-1)');
   
   uimenu('Parent',h_mnuAddDateCol, ...
      'Label','Year, Year Day, Time (Campbell CR10x)', ...
      'Separator','on', ...
      'Callback','ui_editor(''tool_date'',''cr10'')');

   uimenu('Parent',h_mnuAddDateCol, ...
      'Label','DD-MMM-YYYY hh:mm:ss', ...
      'Separator','on', ...
      'Callback','ui_editor(''tool_date'',0)');

   uimenu('Parent',h_mnuAddDateCol, ...
      'Label','DD-MMM-YYYY', ...
      'Callback','ui_editor(''tool_date'',1)');

   uimenu('Parent',h_mnuAddDateCol, ...
      'Label','MM/DD/YY', ...
      'Callback','ui_editor(''tool_date'',2)');

   uimenu('Parent',h_mnuAddDateCol, ...
      'Label','MM/DD/YYYY', ...
      'Callback','ui_editor(''tool_date'',23)');

   uimenu('Parent',h_mnuAddDateCol, ...
      'Label','DD/MM/YYYY', ...
      'Callback','ui_editor(''tool_date'',24)');

   uimenu('Parent',h_mnuAddDateCol, ...
      'Label','YYYY/MM/DD', ...
      'Callback','ui_editor(''tool_date'',26)');

   uimenu('Parent',h_mnuAddDateCol, ...
      'Label','YYYY-MM-DD hh:mm:ss', ...
      'Callback','ui_editor(''tool_date'',31)');

   uimenu('Parent',h_mnuAddDateCol, ...
      'Label','YYYY-MM-DD (ISO date)', ...
      'Separator','on', ...
      'Callback','ui_editor(''tool_date'',29)');

   uimenu('Parent',h_mnuAddDateCol, ...
      'Label','YYYYMMDDThhmmss (ISO datetime)', ...
      'Callback','ui_editor(''tool_date'',30)');

   uimenu('Parent',h_mnuAddDateCol, ...
      'Label','YYYYMMDD (ClimDB)', ...
      'Callback','ui_editor(''tool_date'',3)');

   h_mnuAddYeardayCol = uimenu('Parent',h_mnuDateFnc, ...
      'Label','Year Day from Date/Time Column(s)', ...
      'Tag','mnuAddYeardayCol');

   uimenu('Parent',h_mnuAddYeardayCol, ...
      'Label','Fractional Day', ...
      'Callback','ui_editor(''tool_yeardaycol'','''')');

   uimenu('Parent',h_mnuAddYeardayCol, ...
      'Label','Round to Nearest Day', ...
      'Callback','ui_editor(''tool_yeardaycol'',''round'')');

   uimenu('Parent',h_mnuAddYeardayCol, ...
      'Label','Truncate (fix)', ...
      'Callback','ui_editor(''tool_yeardaycol'',''fix'')');

   uimenu('Parent',h_mnuAddYeardayCol, ...
      'Label','Round Down (floor)', ...
      'Callback','ui_editor(''tool_yeardaycol'',''floor'')');

   uimenu('Parent',h_mnuAddYeardayCol, ...
      'Label','Round Up (ceiling)', ...
      'Callback','ui_editor(''tool_yeardaycol'',''ceil'')');

   uimenu('Parent',h_mnuAddYeardayCol, ...
      'Label','Year, YearDay and Hours', ...
      'Separator','on', ...
      'Callback','ui_editor(''tool_yeardaycol'',''year_yearday_hours'')');

   h_mnuFillDateGaps = uimenu('Parent',h_mnuDateFnc, ...
      'Label','Expand Date Gaps (time series data)', ...
      'Separator','on', ...
      'Tag','mnuFillDateGaps');
   
   h_mnuFillDateGaps1min = uimenu('Parent',h_mnuFillDateGaps, ...
      'Label','60 sec Minimum Interval', ...
      'Tag','mnuFillDateGaps1min');

   h_mnuFillDateGaps20hz = uimenu('Parent',h_mnuFillDateGaps, ...
      'Label','0.05 sec Minimum Interval (20Hz)', ...
      'Tag','mnuFillDateGaps20hz');

   uimenu('Parent',h_mnuFillDateGaps1min, ...
      'Label','Replicate Values in Non-data Columns', ...
      'Tag','mnuFillDateGapsRepl', ...
      'Callback','ui_editor(''tool_filldates'',1)');

   uimenu('Parent',h_mnuFillDateGaps1min, ...
      'Label','Do Not Replicate Values', ...
      'Tag','mnuFillDateGapsNoRepl', ...
      'Callback','ui_editor(''tool_filldates'',0)');

   uimenu('Parent',h_mnuFillDateGaps20hz, ...
      'Label','Replicate Values in Non-data Columns', ...
      'Tag','mnuFillDateGapsRepl', ...
      'Callback','ui_editor(''tool_filldates_20hz'',1)');

   uimenu('Parent',h_mnuFillDateGaps20hz, ...
      'Label','Do Not Replicate Values', ...
      'Tag','mnuFillDateGapsNoRepl', ...
      'Callback','ui_editor(''tool_filldates_20hz'',0)');

   h_mnuGeoFnc = uimenu('Parent',h_mnuEdit, ...
      'Label','Geographic Functions', ...
      'Enable','off');

   h_mnuDegUTM = uimenu('Parent',h_mnuGeoFnc, ...
      'Label','Calculate UTM from Latitude/Longitude');

   h_mnuUTMDeg = uimenu('Parent',h_mnuGeoFnc, ...
      'Label','Calculate Latitude/Longitude from UTM');

   %generage menus for geographic reprojection with datum options
   datumlist = {'WGS84','WGS72','WGS66','WGS60','NAD83','NAD27','CLARK1866','CLARK1800'};
   for n = 1:length(datumlist)
      datum = datumlist{n};
      uimenu('Parent',h_mnuDegUTM, ...
         'Label',[datum,' Datum'], ...
         'Callback',['ui_editor(''tool_deg2utm'',''',datum,''')']);
      uimenu('Parent',h_mnuUTMDeg, ...
         'Label',[datum,' Datum'], ...
         'Callback',['ui_editor(''tool_utm2deg'',''',datum,''')']);
   end

   uimenu('Parent',h_mnuGeoFnc, ...
      'Label','Lookup Study Sites from Locations', ...
      'Separator','on', ...
      'Callback','ui_editor(''tool_addsites_location'')', ...
      'Tag','mnuAddSitesLocations');

   h_mnuAddSites = uimenu('Parent',h_mnuGeoFnc, ...
      'Label','Lookup Study Sites from Coordinates', ...
      'Tag','mnuAddSites');

   uimenu('Parent',h_mnuAddSites, ...
      'Label','Any Site Type', ...
      'Callback','ui_editor(''tool_addsites'','''')');

   uimenu('Parent',h_mnuAddSites, ...
      'Label','Only Marsh Sites', ...
      'Callback','ui_editor(''tool_addsites'',''marsh'')');

   uimenu('Parent',h_mnuAddSites, ...
      'Label','Only Cruise Transects', ...
      'Callback','ui_editor(''tool_addsites'',''transect'')');

   uimenu('Parent',h_mnuAddSites, ...
      'Label','Only Terrestrial Sites', ...
      'Callback','ui_editor(''tool_addsites'',''land'')');

   uimenu('Parent',h_mnuAddSites, ...
      'Label','Only Hammocks', ...
      'Callback','ui_editor(''tool_addsites'',''hammock'')');

   h_mnuAddStatCoord = uimenu('Parent',h_mnuGeoFnc, ...
      'Label','Lookup Coordinates for Stations/Locations', ...
      'Tag','mnuAddStatCoord');

   uimenu('Parent',h_mnuAddStatCoord, ...
      'Label','Latitude/Longitude', ...
      'Tag','mnuAddStatCoordLL', ...
      'Callback','ui_editor(''tool_addstatcoord_latlon'')');

   uimenu('Parent',h_mnuAddStatCoord, ...
      'Label','UTM (WGS84)', ...
      'Tag','mnuAddStatCoordUTM', ...
      'Callback','ui_editor(''tool_addstatcoord_utm'')');

   %add menu tree for looking up stations/locations based on lat/lon if reference file present
   if exist('geo_locations.mat','file') == 2
      try
         v = load('geo_locations.mat','-mat');
      catch
         v = struct('null','');
      end
      if isfield(v,'locations')
         locations = v.locations;
         if isfield(locations,'TypeCode') && isfield(locations,'TypeName')
            [typecodes,I,J] = unique({locations.TypeCode});
            typenames = {locations(I).TypeName};
            h_mnuAddLocations = uimenu('Parent',h_mnuGeoFnc, ...
               'Separator','on', ...
               'Label','Lookup Stations/Locations from Coordinates');
            h_mnuAddLocations1 = uimenu('Parent',h_mnuAddLocations, ...
               'Label','Fine Criteria (<=0.5km)');
            h_mnuAddLocations2 = uimenu('Parent',h_mnuAddLocations, ...
               'Label','Medium Criteria (<=1km)');
            h_mnuAddLocations3 = uimenu('Parent',h_mnuAddLocations, ...
               'Label','Coarse Criteria (<=2km)');
            uimenu('Parent',h_mnuAddLocations1, ...
               'Label','Any Location Type', ...
               'Callback','ui_editor(''tool_addloc1'','''')');
            uimenu('Parent',h_mnuAddLocations2, ...
               'Label','Any Location Type', ...
               'Callback','ui_editor(''tool_addloc2'','''')');
            uimenu('Parent',h_mnuAddLocations3, ...
               'Label','Any Location Type', ...
               'Callback','ui_editor(''tool_addloc3'','''')');
            for n = 1:length(typecodes)
               if n == 1
                  separator = 'on';
               else
                  separator = 'off';
               end
               uimenu('Parent',h_mnuAddLocations1, ...
                  'Label',typenames{n}, ...
                  'Separator',separator, ...
                  'Callback',['ui_editor(''tool_addloc1'',''',typecodes{n},''')']);
               uimenu('Parent',h_mnuAddLocations2, ...
                  'Label',typenames{n}, ...
                  'Separator',separator, ...
                  'Callback',['ui_editor(''tool_addloc2'',''',typecodes{n},''')']);
               uimenu('Parent',h_mnuAddLocations3, ...
                  'Label',typenames{n}, ...
                  'Separator',separator, ...
                  'Callback',['ui_editor(''tool_addloc3'',''',typecodes{n},''')']);
            end
         end
      end
   end

   %add menu items for looking up transect distances if reference file present
   if exist('thalweg_ref.mat','file') == 2
      try
         thalweg = load('thalweg_ref.mat','-mat');
      catch
         thalweg = [];
      end
      if ~isempty(thalweg)
         transects = fieldnames(thalweg);
         if ~isempty(transects)
            transects = sort(transects);
            h_mnuAddTransects = uimenu('Parent',h_mnuGeoFnc, ...
               'Label','Lookup Transect Distances from Coordinates');
            h_mnuAddTransects1 = uimenu('Parent',h_mnuAddTransects, ...
               'Label','Fine Criteria (<=0.5km)');
            h_mnuAddTransects2 = uimenu('Parent',h_mnuAddTransects, ...
               'Label','Medium Criteria (<=1km)');
            h_mnuAddTransects3 = uimenu('Parent',h_mnuAddTransects, ...
               'Label','Coarse Criteria (<=2km)');
            uimenu('Parent',h_mnuAddTransects1, ...
               'Label','Any Transect', ...
               'Callback','ui_editor(''tool_addtransects1'','''')');
            uimenu('Parent',h_mnuAddTransects2, ...
               'Label','Any Transect', ...
               'Callback','ui_editor(''tool_addtransects2'','''')');
            uimenu('Parent',h_mnuAddTransects3, ...
               'Label','Any Transect', ...
               'Callback','ui_editor(''tool_addtransects3'','''')');
            for n = 1:length(transects)
               if n == 1
                  separator = 'on';
               else
                  separator = 'off';
               end
               uimenu('Parent',h_mnuAddTransects1, ...
                  'Label',[transects{n},' Transect'], ...
                  'Separator',separator, ...
                  'Callback',['ui_editor(''tool_addtransects1'',''',transects{n},''')']);
               uimenu('Parent',h_mnuAddTransects2, ...
                  'Label',[transects{n},' Transect'], ...
                  'Separator',separator, ...
                  'Callback',['ui_editor(''tool_addtransects2'',''',transects{n},''')']);
               uimenu('Parent',h_mnuAddTransects3, ...
                  'Label',[transects{n},' Transect'], ...
                  'Separator',separator, ...
                  'Callback',['ui_editor(''tool_addtransects3'',''',transects{n},''')']);
            end
            h_mnuAddRiverGPS = uimenu('Parent',h_mnuGeoFnc, ...
               'Label','Lookup Coordinates from Transect Distances');
            h_mnuAddRiverGPSLatLon = uimenu('Parent',h_mnuAddRiverGPS, ...
               'Label','Latitude/Longitude');
            h_mnuAddRiverGPSUTM = uimenu('Parent',h_mnuAddRiverGPS, ...
               'Label','UTM (WGS84)');
            for n = 1:length(transects)
               uimenu('Parent',h_mnuAddRiverGPSLatLon, ...
                  'Label',[transects{n},' Transect'], ...
                  'Callback',['ui_editor(''tool_riverdist2latlon'',''',transects{n},''')']);
               uimenu('Parent',h_mnuAddRiverGPSUTM, ...
                  'Label',[transects{n},' Transect'], ...
                  'Callback',['ui_editor(''tool_riverdist2utm'',''',transects{n},''')']);
            end
         end
      end
   end

   h_mnuFlagFnc = uimenu('Parent',h_mnuEdit, ...
      'Label','Q/C Flag Functions', ...
      'Enable','off');

   uimenu('Parent',h_mnuFlagFnc, ...
      'Label','View/Edit Q/C Flag Definitions', ...
      'Callback','ui_editor(''flagdefs'')');

   h_mnuReFlag = uimenu('Parent',h_mnuFlagFnc, ...
      'Label','Recalculate Q/C Flags', ...
      'Accelerator','F', ...
      'Callback','ui_editor(''tool_reflag'')');

   h_mnuManualQC = uimenu('Parent',h_mnuFlagFnc, ...
      'Label','Manually Assign or Clear Q/C Flags', ...
      'Callback','ui_editor(''tool_qaqc'',''all'')');
   
   h_mnuCopyFlags = uimenu('Parent',h_mnuFlagFnc , ...
      'Label','Copy Q/C Flags to Dependent Columns', ...
      'Callback','ui_editor(''tool_copyflags'')');

   h_mnuLockFlags = uimenu('Parent',h_mnuFlagFnc, ...
      'Label','Lock Q/C Flags (disable auto-update)', ...
      'Separator','on', ...
      'Tag','mnuLockFlags');

   uimenu('Parent',h_mnuLockFlags, ...
      'Label','All Columns', ...
      'Callback','ui_editor(''lockflags'',''lock_all'')', ...
      'Tag','mnuLockFlagsAll');

   uimenu('Parent',h_mnuLockFlags, ...
      'Label','Data Columns Only', ...
      'Callback','ui_editor(''lockflags'',''lock_data'')', ...
      'Tag','mnuLockFlagsData');

   uimenu('Parent',h_mnuLockFlags, ...
      'Label','Selected Columns Only', ...
      'Callback','ui_editor(''lockflags'',''lock_sel'')', ...
      'Tag','mnuLockFlagsSel');

   h_mnuUnLockFlags = uimenu('Parent',h_mnuFlagFnc, ...
      'Label','Unlock Q/C Flags (restore auto-update)', ...
      'Tag','mnuUnLockFlags');

   uimenu('Parent',h_mnuUnLockFlags, ...
      'Label','All Columns', ...
      'Callback','ui_editor(''lockflags'',''unlock_all'')', ...
      'Tag','mnuUnLockFlagsAll');

   uimenu('Parent',h_mnuUnLockFlags, ...
      'Label','Data Columns Only', ...
      'Callback','ui_editor(''lockflags'',''unlock_data'')', ...
      'Tag','mnuUnLockFlagsData');

   uimenu('Parent',h_mnuUnLockFlags, ...
      'Label','Selected Columns Only', ...
      'Callback','ui_editor(''lockflags'',''unlock_sel'')', ...
      'Tag','mnuUnLockFlagsSel');

   h_mnuCodes2Flags = uimenu('Parent',h_mnuFlagFnc, ...
      'Label','Create Q/C Criteria for Coded Columns', ...
      'Separator','on', ...
      'Tag','mnuCodes2Flags');

   uimenu('Parent',h_mnuCodes2Flags, ...
      'Label','All Coded Columns', ...
      'Callback','ui_editor(''tool_codeflags'',''all'')');

   uimenu('Parent',h_mnuCodes2Flags, ...
      'Label','Selected Columns', ...
      'Callback','ui_editor(''tool_codeflags'',''selected'')');

   h_mnuFlags = uimenu('Parent',h_mnuFlagFnc , ...
      'Label','Convert Q/C Flags to Text Columns', ...
      'Separator','on', ...
      'Tag','mnuFlags');

   h_mnuFlagsE = uimenu('Parent',h_mnuFlagFnc , ...
      'Label','Convert Q/C Flags to Numeric Columns', ...
      'Tag','mnuFlags');

   h_mnuCols2Flags = uimenu('Parent',h_mnuFlagFnc , ...
      'Label','Convert Text Columns to Q/C Flags', ...
      'Tag','mnuFlags');

   h_mnuCols2FlagsUnmapped = uimenu('Parent',h_mnuCols2Flags, ...
      'Label','Single-character Flags', ...
      'Tag','mnuCols2Flags1');

   h_mnuCols2FlagsMapped = uimenu('Parent',h_mnuCols2Flags, ...
      'Label','Multi-character Flags', ...
      'Tag','mnuCols2Flags2');

   uimenu('Parent',h_mnuFlags, ...
      'Label','Convert Selected Flags', ...
      'Tag','mnuFlags0', ...
      'Callback','ui_editor(''tool_flags0'')');

   h_mnuCols2FlagsAll = uimenu('Parent',h_mnuFlags, ...
      'Label','Convert All Flags', ...
      'Tag','mnuCols2FlagsAll');

   uimenu('Parent',h_mnuCols2FlagsAll, ...
      'Label','Multiple Columns (only columns with flags)', ...
      'Tag','mnuFlags2', ...
      'Callback','ui_editor(''tool_flags2'')');

   uimenu('Parent',h_mnuCols2FlagsAll, ...
      'Label','Multiple Columns (all data columns)', ...
      'Tag','mnuFlags3', ...
      'Callback','ui_editor(''tool_flags3'')');

   uimenu('Parent',h_mnuCols2FlagsAll, ...
      'Label','Multiple Columns (all data columns and other flags)', ...
      'Tag','mnuFlags3+', ...
      'Callback','ui_editor(''tool_flags3+'')');

   uimenu('Parent',h_mnuCols2FlagsAll, ...
      'Label','Multiple Columns (all data columns, missing = M)', ...
      'Tag','mnuFlags4', ...
      'Callback','ui_editor(''tool_flags4'')');

   uimenu('Parent',h_mnuCols2FlagsAll, ...
      'Label','Multiple Columns (all data columns and other flags, missing = M)', ...
      'Tag','mnuFlags4+', ...
      'Callback','ui_editor(''tool_flags4+'')');

   uimenu('Parent',h_mnuCols2FlagsAll, ...
      'Label','Multiple Columns (all columns)', ...
      'Tag','mnuFlags3', ...
      'Callback','ui_editor(''tool_flags5'')');

   uimenu('Parent',h_mnuCols2FlagsAll, ...
      'Label','Single Column (all flags concatenated)', ...
      'Separator','on', ...
      'Tag','mnuFlags1', ...
      'Callback','ui_editor(''tool_flags1'')');

   uimenu('Parent',h_mnuFlagsE, ...
      'Label','Convert Selected Flags', ...
      'Tag','mnuFlags0', ...
      'Callback','ui_editor(''tool_flags0E'')');

   h_mnuCols2FlagsAllE = uimenu('Parent',h_mnuFlagsE, ...
      'Label','Convert All Flags', ...
      'Tag','mnuCols2FlagsAllE');

   uimenu('Parent',h_mnuCols2FlagsAllE, ...
      'Label','Multiple Columns (only columns with flags)', ...
      'Tag','mnuFlags2E', ...
      'Callback','ui_editor(''tool_flags2E'')');

   uimenu('Parent',h_mnuCols2FlagsAllE, ...
      'Label','Multiple Columns (all data columns)', ...
      'Tag','mnuFlags3E', ...
      'Callback','ui_editor(''tool_flags3E'')');

   uimenu('Parent',h_mnuCols2FlagsAllE, ...
      'Label','Multiple Columns (all data columns and other flags)', ...
      'Tag','mnuFlags3E+', ...
      'Callback','ui_editor(''tool_flags3E+'')');

   uimenu('Parent',h_mnuCols2FlagsAllE, ...
      'Label','Multiple Columns (all data columns, missing = M)', ...
      'Tag','mnuFlags4', ...
      'Callback','ui_editor(''tool_flags4E'')');

   uimenu('Parent',h_mnuCols2FlagsAllE, ...
      'Label','Multiple Columns (all data columns and other flags, missing = M)', ...
      'Tag','mnuFlags4E+', ...
      'Callback','ui_editor(''tool_flags4E+'')');

   uimenu('Parent',h_mnuCols2FlagsAllE, ...
      'Label','Multiple Columns (all columns)', ...
      'Tag','mnuFlags5E', ...
      'Callback','ui_editor(''tool_flags5E'')');

   uimenu('Parent',h_mnuCols2FlagsUnmapped, ...
      'Label','Overwrite Existing Flags', ...
      'Tag','mnuCols2Flags1', ...
      'Callback','ui_editor(''tool_cols2flags1'')');

   uimenu('Parent',h_mnuCols2FlagsUnmapped, ...
      'Label','Merge With Existing Flags', ...
      'Tag','mnuCols2Flags0', ...
      'Callback','ui_editor(''tool_cols2flags0'')');

   uimenu('Parent',h_mnuCols2FlagsMapped, ...
      'Label','Overwrite Existing Flags', ...
      'Tag','mnuCols2Flags1', ...
      'Callback','ui_editor(''tool_cols2flagsmap1'')');

   uimenu('Parent',h_mnuCols2FlagsMapped, ...
      'Label','Merge With Existing Flags', ...
      'Tag','mnuCols2Flags0', ...
      'Callback','ui_editor(''tool_cols2flagsmap0'')');

   h_mnuClrFlagVals = uimenu('Parent',h_mnuFlagFnc , ...
      'Label','Remove Data with Q/C Flags', ...
      'Separator','on');

   uimenu('Parent',h_mnuFlagFnc , ...
      'Label','Remove Q/C Flag Assignments', ...
      'Callback','ui_editor(''tool_clrflags'')');

   uimenu('Parent',h_mnuFlagFnc , ...
      'Label','Replace Q/C Flag Assignments', ...
      'Callback','ui_editor(''tool_replace'',''flags'')');

   h_mnuClrFlagVals0 = uimenu('Parent',h_mnuClrFlagVals, ...
      'Label','Selectively Remove Values', ...
      'Callback','ui_editor(''tool_clrflags0'')');

   h_mnuClrFlagValsNull = uimenu('Parent',h_mnuClrFlagVals, ...
      'Separator','on', ...
      'Label','Null All Flagged Values');

   uimenu('Parent',h_mnuClrFlagValsNull, ...
      'Label','Remove Flags', ...
      'Callback','ui_editor(''tool_clrflags1clear'')');

   uimenu('Parent',h_mnuClrFlagValsNull, ...
      'Label','Retain and Lock Flags', ...
      'Callback','ui_editor(''tool_clrflags1keep'')');

   uimenu('Parent',h_mnuClrFlagVals, ...
      'Label','Delete All Rows with Flagged Values', ...
      'Callback','ui_editor(''tool_clrflags2'')');
   
   h_mnuTaxonomic = uimenu('Parent',h_mnuEdit, ...
      'Label','Taxonomic Functions', ...
      'Enable','off', ...
      'Tag','mnuTaxonomic');
   
   h_mnuTaxonomicITIS = uimenu('Parent',h_mnuTaxonomic, ...
      'Label','Lookup ITIS TSN');
   
   uimenu('Parent',h_mnuTaxonomicITIS, ...
      'Label','Scientific Name (Selected Column)', ...
      'Callback','ui_editor(''tool_itis'',''scientific'')');
   
   uimenu('Parent',h_mnuTaxonomicITIS, ...
      'Label','Common Name (Selected Column)', ...
      'Callback','ui_editor(''tool_itis'',''common'')');      

   h_mnuUndo = uimenu('Parent',h_mnuEdit, ...
      'Label','Undo Changes', ...
      'Accelerator','U', ...
      'Tag','mnuUndo', ...
      'Separator','on', ...
      'Callback','ui_editor(''undo'')', ...
      'UserData',s);

   h_mnuHistory = uimenu('Parent',h_mnuMetadata, ...
      'Label','View Processing History', ...
      'Accelerator','H', ...
      'Callback','ui_editor(''tool_hist'')', ...
      'Enable','off');

   h_mnuEditMeta = uimenu('Parent',h_mnuMetadata, ...
      'Label','View/Edit Metadata', ...
      'Separator','on', ...
      'Tag','mnuEditMeta', ...
      'Accelerator','M', ...
      'Callback','ui_editor(''editmeta'')', ...
      'Enable','off');

   h_mnuMeta = uimenu('Parent',h_mnuMetadata, ...
      'Label','View Formatted Metadata', ...
      'Enable','off', ...
      'Tag','mnuMeta');

   %add menu items for all metadata styles registered in metastyles.mat
   if ~isempty(stylestr)
      for n = 1:length(stylestr)
         uimenu('Parent',h_mnuMeta, ...
            'Label',stylestr{n}, ...
            'Callback',['ui_editor(''tool_',stylelist{n},''')'], ...
            'UserData',stylelist{n});
      end
   end
   
   %add EML metadata display option
   h_mnuEMLMetadata = uimenu('Parent',h_mnuMeta, ...
      'Separator','on', ...
      'Label','EML Metadata');
   
   uimenu('Parent',h_mnuEMLMetadata, ...
      'Label','Map Units to Unit Dictionary', ...
      'Callback','ui_editor(''tool_emlmetadata'',''yes'')');

   uimenu('Parent',h_mnuEMLMetadata, ...
      'Label','No Unit Mapping', ...
      'Callback','ui_editor(''tool_emlmetadata'',''no'')');

   h_mnuStudyDateMeta = uimenu('Parent',h_mnuMetadata, ...
      'Label','Add/Update Study Date Metadata', ...
      'Separator','on', ...
      'Enable','off', ...
      'Tag','mnuStudyDateMeta', ...
      'Callback','ui_editor(''tool_studydates'')');

   h_mnuSiteMeta = uimenu('Parent',h_mnuMetadata, ...
      'Label','Add/Update Site/Station Metadata', ...
      'Enable','off', ...
      'Tag','mnuSiteMeta', ...
      'Callback','ui_editor(''tool_sitemeta'')');

   h_mnuFlagDefs = uimenu('Parent',h_mnuMetadata, ...
      'Label','Add/Update Q/C Flag Definitions, Data Anomalies', ...
      'Enable','off', ...
      'Callback','ui_editor(''flagdefs'')');

   h_mnuAnomalies = uimenu('Parent',h_mnuMetadata, ...
      'Label','Document Flagged Values as Anomalies', ...
      'Enable','off', ...
      'Separator','on', ...
      'Tag','mnuAnomalies');

   h_mnuAnomMissing = uimenu('Parent',h_mnuMetadata, ...
      'Label','Document Flagged and Missing Values as Anomalies', ...
      'Enable','off', ...
      'Tag','mnuAnomMissing');

   uimenu('Parent',h_mnuAnomalies, ...
      'Label','No date grouping', ...
      'Callback','ui_editor(''tool_anomalies''); ui_editor(''flagdefs'')', ...
      'UserData',{[],''});

   uimenu('Parent',h_mnuAnomMissing, ...
      'Label','No date grouping', ...
      'Callback','ui_editor(''tool_anom_missing''); ui_editor(''flagdefs'')', ...
      'UserData',{[],''});

   if mlversion > 5  %check for unsupported datestr parameter in ML 5
      uimenu('Parent',h_mnuAnomalies, ...
         'Label','By date (mm/dd/yyyy-mm/dd/yyyy)', ...
         'Callback','ui_editor(''tool_anomalies''); ui_editor(''flagdefs'')', ...
         'UserData',{23,'-'});
      uimenu('Parent',h_mnuAnomMissing, ...
         'Label','By date (mm/dd/yyyy-mm/dd/yyyy)', ...
         'Callback','ui_editor(''tool_anom_missing''); ui_editor(''flagdefs'')', ...
         'UserData',{23,'-'});
   end

   uimenu('Parent',h_mnuAnomalies, ...
      'Label','By date (dd-mmm-yyyy to dd-mm-yyyy)', ...
      'Callback','ui_editor(''tool_anomalies''); ui_editor(''flagdefs'')', ...
      'UserData',{1,' to '});

   uimenu('Parent',h_mnuAnomalies, ...
      'Label','By date (dd-mmm-yyyy HH:MM:SS to dd-mm-yyyy HH:MM:SS)', ...
      'Callback','ui_editor(''tool_anomalies''); ui_editor(''flagdefs'')', ...
      'UserData',{0,'-'});

   uimenu('Parent',h_mnuAnomMissing, ...
      'Label','By date (dd-mmm-yyyy to dd-mm-yyyy)', ...
      'Callback','ui_editor(''tool_anom_missing''); ui_editor(''flagdefs'')', ...
      'UserData',{1,' to '});

   uimenu('Parent',h_mnuAnomMissing, ...
      'Label','By date (dd-mmm-yyyy HH:MM:SS to dd-mm-yyyy HH:MM:SS)', ...
      'Callback','ui_editor(''tool_anom_missing''); ui_editor(''flagdefs'')', ...
      'UserData',{0,'-'});

   if mlversion > 5  %check for unsupported datestr parameter in ML 5
      uimenu('Parent',h_mnuAnomalies, ...
         'Label','By date (yyyy-mm-dd HH:MM:SS to yyyy-mm-dd HH:MM:SS)', ...
         'Callback','ui_editor(''tool_anomalies''); ui_editor(''flagdefs'')', ...
         'UserData',{31,' to '});
      uimenu('Parent',h_mnuAnomMissing, ...
         'Label','By date (yyyy-mm-dd HH:MM:SS to yyyy-mm-dd HH:MM:SS)', ...
         'Callback','ui_editor(''tool_anom_missing''); ui_editor(''flagdefs'')', ...
         'UserData',{31,' to '});
   end

   h_mnuEditAutoNum = uimenu('Parent',h_mnuMetadata, ...
      'Label','Automatically Assign Numerical Descriptors', ...
      'Enable','off', ...
      'Tag','mnuEditAutoNum', ...
      'Callback','ui_editor(''tool_autonum'')');

   h_mnuToolsMetadataCodes = uimenu('Parent',h_mnuMetadata, ...
      'Label','Generate Code Definition Dataset', ...
      'Separator','on', ...
      'Enable','off', ...
      'Tag','mnuToolsMetadataCodesAuto');
   
   h_mnuToolsMetadataCodesAuto = uimenu('Parent',h_mnuToolsMetadataCodes, ...
      'Label','All Coded Columns', ...
      'Tag','mnuToolsMetadataCodesSel');
   
   h_mnuToolsMetadataCodesSel = uimenu('Parent',h_mnuToolsMetadataCodes, ...
      'Label','Selected Column(s)', ...
      'Tag','mnuToolsMetadataCodesSel');
   
   uimenu('Parent',h_mnuToolsMetadataCodesAuto, ...
      'Label','Automatic Metadata', ...
      'Callback','ui_editor(''tool_codes2data'',''auto'')');

   uimenu('Parent',h_mnuToolsMetadataCodesAuto, ...
      'Label','Selected Metadata', ...
      'Callback','ui_editor(''tool_codes2data'',''autoprompt'')');

   uimenu('Parent',h_mnuToolsMetadataCodesSel, ...
      'Label','Automatic Metadata', ...
      'Callback','ui_editor(''tool_codes2data'',''selected'')');

   uimenu('Parent',h_mnuToolsMetadataCodesSel, ...
      'Label','Selected Metadata', ...
      'Callback','ui_editor(''tool_codes2data'',''selectedprompt'')');

   h_mnuToolsPlot = uimenu('Parent',h_mnuTools, ...
      'Label','Plotting', ...
      'Enable','off');

   h_mnuToolsQuery = uimenu('Parent',h_mnuTools, ...
      'Label','Filtering', ...
      'Enable','off');

   h_mnuToolsStats = uimenu('Parent',h_mnuTools, ...
      'Label','Statistics', ...
      'Enable','off');

   h_mnuToolsResample = uimenu('Parent',h_mnuTools, ...
      'Label','Transformation', ...
      'Enable','off');

   h_mnuToolsSpec = uimenu('Parent',h_mnuTools, ...
      'Label','Specialized', ...
      'Enable','off');

   h_mnuHarvesters = uimenu('Parent',h_mnuTools, ...
      'Label','Data Harvesting', ...
      'Separator','on');
   
   uimenu('Parent',h_mnuHarvesters, ...
      'Label','Start Harvesters', ...
      'Callback','ui_editor(''harvesters'',''start'')', ...
      'Tag','mnuHarvestStart');
   
   uimenu('Parent',h_mnuHarvesters, ...
      'Label','Stop Harvesters', ...
      'Callback','ui_editor(''harvesters'',''stop'')', ...
      'Tag','mnuHarvestStop');
   
   uimenu('Parent',h_mnuHarvesters, ...
      'Label','List Harvesters', ...
      'Separator','on', ...
      'Callback','ui_editor(''harvesters'',''list'')', ...
      'Tag','mnuHarvestList');
   
   uimenu('Parent',h_mnuHarvesters, ...
      'Label','Edit Harvesters', ...
      'Callback','ui_editor(''harvesters'',''edit'')', ...
      'Tag','mnuHarvestEdit');
   
   uimenu('Parent',h_mnuHarvesters, ...
      'Label','View Harvest Log', ...
      'Separator','on', ...
      'Callback','ui_editor(''harvesters'',''log'')', ...
      'Tag','mnuHarvestLog');
   
   uimenu('Parent',h_mnuTools, ...
      'Label','Data Merge Tool', ...
      'Separator','on', ...
      'Tag','mnuMerge', ...
      'Callback','ui_multimerge(''init'')');

   uimenu('Parent',h_mnuTools, ...
      'Label','Data Search Engine', ...
      'Callback','ui_search_data(''init'')');

   uimenu('Parent',h_mnuTools, ...
      'Label','Mapping Toolbox', ...
      'Callback','loadmap;');

   h_mnuPlot = uimenu('Parent',h_mnuToolsPlot, ...
      'Label','2D Line/Symbol (multiple Y)', ...
      'Tag','mnuPlot', ...
      'Callback','ui_editor(''tool_plot'')', ...
      'Enable','off');

   h_mnuPlotGroups = uimenu('Parent',h_mnuToolsPlot, ...
      'Label','2D Line/Symbol (single Y, split by groups)', ...
      'Tag','mnuPlotGroups', ...
      'Callback','ui_editor(''tool_plotgroups'')', ...
      'Enable','off');

   %check for existence of required mapping support file (.m or .p)
   if exist('plotmap','file') > 0
      mapvis = 'on';
   else
      mapvis = 'off';
   end

   h_mnuMapData = uimenu('Parent',h_mnuToolsPlot, ...
      'Label','Map Plot', ...
      'Tag','mnuMapData', ...
      'Visible',mapvis, ...
      'Callback','ui_editor(''tool_mapdata'')', ...
      'Enable','off');

   h_mnuContourData = uimenu('Parent',h_mnuToolsPlot, ...
      'Label','Vertical Profile Contour Plot', ...
      'Tag','mnuContourData', ...
      'Callback','ui_editor(''tool_contourdata'')', ...
      'Enable','off');

   h_mnuQuery = uimenu('Parent',h_mnuToolsQuery, ...
      'Label','Filter/Subset Data by Column Values (Query Builder)', ...
      'Tag','mnuQuery', ...
      'Callback','ui_editor(''tool_query'')');

   uimenu('Parent',h_mnuToolsResample, ...
      'Label','Split Compound Columns (Denormalize)', ...
      'Tag','mnuSplitSeries', ...
      'Callback','ui_editor(''tool_split'')');

   uimenu('Parent',h_mnuToolsResample, ...
      'Label','Combine Multiple Columns (Normalize)', ...
      'Tag','mnuNormalizeCols', ...
      'Callback','ui_editor(''tool_normalize'')');

   h_mnuResampleStats = uimenu('Parent',h_mnuToolsResample, ...
      'Label','Statistical Data Reduction', ...
      'Separator','on', ...
      'Tag','mnuResampleStats');

   uimenu('Parent',h_mnuResampleStats, ...
      'Label','Group/Aggregate Data', ...
      'Tag','mnuResampleAggrStats', ...
      'Callback','ui_editor(''tool_aggrstat'')');

   uimenu('Parent',h_mnuResampleStats, ...
      'Label','Bin Data', ...
      'Tag','mnuResampleBinStats', ...
      'Callback','ui_editor(''tool_binstat'')');

   uimenu('Parent',h_mnuResampleStats, ...
      'Label','Date/Time Resampling', ...
      'Tag','mnuResampleAggrDateTime', ...
      'Callback','ui_editor(''tool_aggrdatetime'')');

   h_mnuViewStats = uimenu('Parent',h_mnuToolsStats, ...
      'Label','View Column Statistics', ...
      'Tag','mnuViewStats');

   uimenu('Parent',h_mnuViewStats, ...
      'Label','Exclude Flagged Values', ...
      'Callback','ui_editor(''tool_viewstats1'')');

   uimenu('Parent',h_mnuViewStats, ...
      'Label','Include Flagged Values', ...
      'Callback','ui_editor(''tool_viewstats2'')');

   uimenu('Parent',h_mnuToolsStats, ...
      'Label','Column Statistics Report', ...
      'Tag','mnuColStats', ...
      'Callback','ui_editor(''tool_colstats'')');

   uimenu('Parent',h_mnuToolsStats, ...
      'Separator','on', ...
      'Label','Statistics for Grouped Data', ...
      'Tag','mnuAggrStats', ...
      'Callback','ui_editor(''tool_aggrstat'')');

   uimenu('Parent',h_mnuToolsStats, ...
      'Label','Statistics for Binned Data', ...
      'Tag','mnuBinStats', ...
      'Callback','ui_editor(''tool_binstat'')');

   uimenu('Parent',h_mnuToolsStats, ...
      'Label','Statistics for Date/Time Intervals', ...
      'Tag','mnuAggrDateTime', ...
      'Callback','ui_editor(''tool_aggrdatetime'')');

   uimenu('Parent',h_mnuToolsStats, ...
      'Label','Statistics for Moving Date Interval', ...
      'Tag','mnuAggrDateTime', ...
      'Callback','ui_editor(''tool_aggrmovingdate'')');

   uimenu('Parent',h_mnuToolsSpec, ...
      'Label','Top/Bottom Values (Vertical Profiles)', ...
      'Tag','mnuTopBottom', ...
      'Callback','ui_editor(''tool_topbottom'')');

   h_mnuCTDDataset = uimenu('Parent',h_mnuToolsSpec, ...
      'Label','Create CTD Station Dataset for Mapping', ...
      'Tag','mnuCTDDataset');

   uimenu('Parent',h_mnuCTDDataset, ...
      'Label','1km Intervals', ...
      'Callback','ui_editor(''tool_ctddataset'',1)', ...
      'Tag','mnuCTDDataset1');

   uimenu('Parent',h_mnuCTDDataset, ...
      'Label','2km Intervals', ...
      'Callback','ui_editor(''tool_ctddataset'',2)', ...
      'Tag','mnuCTDDataset2');

   uimenu('Parent',h_mnuCTDDataset, ...
      'Label','3km Intervals', ...
      'Callback','ui_editor(''tool_ctddataset'',3)', ...
      'Tag','mnuCTDDataset3');

   uimenu('Parent',h_mnuCTDDataset, ...
      'Label','4km Intervals', ...
      'Callback','ui_editor(''tool_ctddataset'',4)', ...
      'Tag','mnuCTDDataset4');

   uimenu('Parent',h_mnuCTDDataset, ...
      'Label','5km Intervals', ...
      'Callback','ui_editor(''tool_ctddataset'',5)', ...
      'Tag','mnuCTDDataset5');

   uimenu('Parent',h_mnuMisc, ...
      'Label','Add/Edit Import Filters', ...
      'Tag','mnuEditImpTemp', ...
      'Callback','ui_edit_filters');

   uimenu('Parent',h_mnuMisc, ...
      'Label','Add/Edit Metadata Templates', ...
      'Tag','mnuEditTemp', ...
      'Callback','ui_template(''init'')');

   uimenu('Parent',h_mnuMisc, ...
      'Label','Add/Edit Metadata Styles', ...
      'Tag','mnuEditStyles', ...
      'Callback','ui_metastyle(''init'')');

   uimenu('Parent',h_mnuMisc, ...
      'Label','Update Registration', ...
      'Tag','mnuEditReg', ...
      'Separator','on', ...
      'Callback','ui_gce_register');

   h_mnuUpdateGeo = uimenu('Parent',h_mnuMisc, ...
      'Label','Update Geographic Databases', ...
      'Tag','mnuUpdateGeo', ...
      'Separator','on');

   uimenu('Parent',h_mnuUpdateGeo, ...
      'Label','Point Locations', ...
      'Tag','mnuUpdateGeoLocations', ...
      'Callback','ui_edit_geodatabase(''init'',''geo_locations'')');

   uimenu('Parent',h_mnuUpdateGeo, ...
      'Label','Site Polygons', ...
      'Tag','mnuUpdateGeoPolygons', ...
      'Callback','ui_edit_geodatabase(''init'',''geo_polygons'')');

   uimenu('Parent',h_mnuWindow, ...
      'Label','New Window', ...
      'Accelerator','N', ...
      'Tag','mnuNew', ...
      'Callback','ui_editor(''init'')');

   h_mnuWindowName = uimenu('Parent',h_mnuWindow, ...
      'Separator','on', ...
      'Label','Rename');

   h_mnuArrangeWindow = uimenu('Parent',h_mnuWindow, ...
      'Separator','on', ...
      'Label','Arrange');

   uimenu('Parent',h_mnuArrangeWindow, ...
      'Label','Cascade', ...
      'Callback','ui_editor(''window'',''cascade'')');

   uimenu('Parent',h_mnuArrangeWindow, ...
      'Label','Tile', ...
      'Callback','ui_editor(''window'',''tile'')');

   uimenu('Parent',h_mnuArrangeWindow, ...
      'Label','Stack', ...
      'Callback','ui_editor(''window'',''stack'')');

   uimenu('Parent',h_mnuWindow, ...
      'Label','Choose', ...
      'Callback','ui_editor(''window'',''choose'')');

   h_mnuWindowNameTitle = uimenu('Parent',h_mnuWindowName, ...
      'Label','Use Structure Title', ...
      'Callback','ui_editor(''rename2'',''title'')', ...
      'Enable','off');

   uimenu('Parent',h_mnuWindowName, ...
      'Label','Custom Name', ...
      'Callback',['ui_title(''init'',get(gcf,''Name''),gcbo,''ui_editor(''''rename'''');'',', ...
      '''Data Structure Editor Window Name'',''Edit Window Name'')'], ...
      'Tag','mnuRename');

   uimenu('Parent',h_mnuWindowName, ...
      'Separator','on', ...
      'Label','Reset Window Name', ...
      'Callback','ui_editor(''rename2'',''reset'')');
   
   uimenu('Parent',h_mnuWindow, ...
      'Label','Close Other', ...
      'Separator','on', ...
      'Callback','ui_editor(''closewindow'',''other'')');
   
   uimenu('Parent',h_mnuWindow, ...
      'Label','Close All', ...
      'Callback','ui_editor(''closewindow'',''all'')');
   
   uimenu('Parent',h_mnuHelp, ...
      'Label','View Documentation', ...
      'Accelerator','H', ...
      'Callback','ui_viewdocs(''init'',''ui_editor'')');

   uimenu('Parent',h_mnuHelp, ...
      'Label','About the Data Toolbox', ...
      'Separator','on', ...
      'Callback','ui_aboutgce');

   %create ui controls
   uicontrol('Parent',h_fig, ...
      'Style','frame', ...
      'Position',[2 2 figpos(3)-2 figpos(4)-2], ...
      'BackgroundColor',bgcolor, ...
      'ForegroundColor',[0 0 0], ...
      'Tag','frame');

   h_lblVarList = uicontrol('Parent',h_fig, ...
      'BackgroundColor',bgcolor, ...
      'HorizontalAlignment','left', ...
      'FontSize',10, ...
      'FontWeight','bold', ...
      'ForegroundColor',[0 0 0.8], ...
      'Position',[15 592 360 20], ...
      'String','Column List (select to display properties)', ...
      'Style','text', ...
      'Tag','lblVarList');

   h_listVars = uicontrol('Parent',h_fig, ...
      'FontSize',10, ...
      'BackgroundColor',[1 1 1], ...
      'Callback','ui_editor(''display'')', ...
      'Position',[25 332 350 260], ...
      'String',' ', ...
      'Style','listbox', ...
      'Tag','listVars', ...
      'Min',1, ...
      'Max',10, ...
      'Value',1, ...
      'Enable','off', ...
      'UserData',s);

   uicontrol('Parent',h_fig, ...
      'Style','frame', ...
      'BackgroundColor',[.9 .9 .9], ...
      'ForegroundColor',[.25 .25 .25], ...
      'Position',[382 332 96 261]);

   h_lblColumnName = uicontrol('Parent',h_fig, ...
      'BackgroundColor',bgcolor, ...
      'Fontsize',10, ...
      'FontWeight','bold', ...
      'ForegroundColor',[0 0 0.8], ...
      'HorizontalAlignment','left', ...
      'Position',[15 302 120 20], ...
      'String','Column Name', ...
      'Style','text', ...
      'Tag','lblVarname');

   uicontrol('Parent',h_fig, ...
      'BackgroundColor',bgcolor, ...
      'Fontsize',10, ...
      'FontWeight','bold', ...
      'ForegroundColor',[0 0 0.8], ...
      'HorizontalAlignment','left', ...
      'Position',[15 271 120 20], ...
      'String','Column Units', ...
      'Style','text', ...
      'Tag','lblUnits');

   uicontrol('Parent',h_fig, ...
      'BackgroundColor',bgcolor, ...
      'Fontsize',10, ...
      'FontWeight','bold', ...
      'ForegroundColor',[0 0 0.8], ...
      'Position',[15 243 130 20], ...
      'HorizontalAlignment','left', ...
      'String','Description', ...
      'Style','text', ...
      'Tag','lblDescription');

   uicontrol('Parent',h_fig, ...
      'BackgroundColor',bgcolor, ...
      'Fontsize',10, ...
      'FontWeight','bold', ...
      'ForegroundColor',[0 0 0.8], ...
      'Position',[15 133 120 20], ...
      'HorizontalAlignment','left', ...
      'String','Data Type', ...
      'Style','text', ...
      'Tag','lblDatatype');

   uicontrol('Parent',h_fig, ...
      'BackgroundColor',bgcolor, ...
      'Fontsize',10, ...
      'FontWeight','bold', ...
      'ForegroundColor',[0 0 0.8], ...
      'Position',[15 103 120 20], ...
      'HorizontalAlignment','left', ...
      'String','Variable Type', ...
      'Style','text', ...
      'Tag','lblVartype');

   uicontrol('Parent',h_fig, ...
      'BackgroundColor',bgcolor, ...
      'Fontsize',10, ...
      'FontWeight','bold', ...
      'ForegroundColor',[0 0 0.8], ...
      'Position',[15 73 120 20], ...
      'HorizontalAlignment','left', ...
      'String','Numerical Type', ...
      'Style','text', ...
      'Tag','lblNumbertype');

   uicontrol('Parent',h_fig, ...
      'BackgroundColor',bgcolor, ...
      'Fontsize',10, ...
      'FontWeight','bold', ...
      'ForegroundColor',[0 0 0.8], ...
      'Position',[15 43 120 20], ...
      'HorizontalAlignment','left', ...
      'String','Precision', ...
      'Style','text', ...
      'Tag','lblPrecision');

   uicontrol('Parent',h_fig, ...
      'BackgroundColor',bgcolor, ...
      'Fontsize',10, ...
      'FontWeight','bold', ...
      'ForegroundColor',[0 0 0.8], ...
      'Position',[15 13 120 20], ...
      'HorizontalAlignment','left', ...
      'String','Flag Criteria', ...
      'Style','text', ...
      'Tag','lblCriteria');

   h_editVarname = uicontrol('Parent',h_fig, ...
      'Fontsize',10, ...
      'BackgroundColor',[1 1 1], ...
      'Callback','ui_editor(''varname'')', ...
      'HorizontalAlignment','left', ...
      'Position',[120 301 360 22], ...
      'Style','edit', ...
      'Enable','off', ...
      'TooltipString','Name of the data set column', ...
      'Tag','editVarname');

   h_editUnits = uicontrol('Parent',h_fig, ...
      'Fontsize',10, ...
      'BackgroundColor',[1 1 1], ...
      'Callback','ui_editor(''units'')', ...
      'HorizontalAlignment','left', ...
      'Position',[120 270 295 22], ...
      'Style','edit', ...
      'Enable','off', ...
      'TooltipString','Units of measurement of the data set column (blank or none if not relevant)', ...
      'Tag','editUnits');

   h_editDesc = uicontrol('Parent',h_fig, ...
      'Fontsize',10, ...
      'BackgroundColor',[1 1 1], ...
      'Callback','ui_editor(''desc'')', ...
      'HorizontalAlignment','left', ...
      'Max',2, ...
      'Position',[40 165 445 75], ...
      'Style','edit', ...
      'String',' ', ...
      'Enable','off', ...
      'Tag','editDesc');

   h_popDatatype = uicontrol('Parent',h_fig, ...
      'Fontsize',10, ...
      'BackgroundColor',[1 1 1], ...
      'Callback','ui_editor(''datatype'')', ...
      'Position',[130 135 290 20], ...
      'HorizontalAlignment','left', ...
      'String',[ ...
      'floating-point number (f)'; ...
      'exponential number (e)   '; ...
      'integer (d)              '; ...
      'alphanumeric string (s)  '; ...
      'unspecified              '], ...
      'Style','popupmenu', ...
      'Tag','popDatatype', ...
      'UserData',[{'f'},{'e'},{'d'},{'s'},{'u'}], ...
      'Enable','off', ...
      'TooltipString','Physical data type (storage type) of the data set column', ...
      'Value',5);

   h_popVartype = uicontrol('Parent',h_fig, ...
      'Fontsize',10, ...
      'BackgroundColor',[1 1 1], ...
      'Callback','ui_editor(''vartype'')', ...
      'Position',[130 105 290 20], ...
      'String',{ ...
         'measurements (data)'; ...
         'calculations (calculation)'; ...
         'categorical values (nominal)'; ...
         'order/positional values (ordinal)'; ...
         'boolean/true-false (logical)'; ...
         'date or time (datetime)'; ...
         'geographic coordinates (coord)'; ...
         'coded values (code)'; ...
         'free text (text)'; ...
         'unspecified' ...
         }, ...
      'Style','popupmenu', ...
      'HorizontalAlignment','left', ...
      'Tag','popVartype', ...
      'UserData',{ ...
         'data', ...
         'calculation', ...
         'nominal', ...
         'ordinal', ...
         'logical', ...
         'datetime', ...
         'coord', ...
         'code', ...
         'text', ...
         'unspecified' ...
         }, ...
      'Enable','off', ...
      'TooltipString','Variable type (semantic type) of the data set column', ...
      'Value',10);

   h_cmdEditCodes = uicontrol('Parent',h_fig, ...
      'Position',[425 102 60 23], ...
      'String','Codes', ...
      'Enable','off', ...
      'Visible','off', ...
      'Callback','ui_editor(''tool_editcodes'')', ...
      'TooltipString','Edit code definitions in a GUI dialog', ...
      'Tag','cmdEditCodes');

   h_popNumtype = uicontrol('Parent',h_fig, ...
      'Fontsize',10, ...
      'BackgroundColor',[1 1 1], ...
      'Callback','ui_editor(''numtype'')', ...
      'Position',[130 75 290 20], ...
      'String',[ ...
      'continuous/ratio (continuous)'; ...
      'discrete/interval (discrete) '; ...
      'angular scale (angular)      '; ...
      'non-numeric (none)           '; ...
      'unspecified                  '], ...
      'Style','popupmenu', ...
      'HorizontalAlignment','left', ...
      'Tag','popNumtype', ...
      'UserData',[{'continuous'},{'discrete'},{'angular'},{'none'},{'unspecified'}], ...
      'Enable','off', ...
      'TooltipString','Numeric type of the data set column', ...
      'Value',5);

   h_editPrec = uicontrol('Parent',h_fig, ...
      'Fontsize',10, ...
      'BackgroundColor',[1 1 1], ...
      'Callback','ui_editor(''prec'')', ...
      'HorizontalAlignment','left', ...
      'Position',[130 42 40 22], ...
      'Style','edit', ...
      'Enable','off', ...
      'TooltipString','Digits of precision to display for the data set column (0 for integer and string)', ...
      'Tag','editPrec');

   uicontrol('Parent',h_fig, ...
      'BackgroundColor',bgcolor, ...
      'Fontsize',10, ...
      'FontWeight','normal', ...
      'HorizontalAlignment','left', ...
      'ForegroundColor',[0 0 0.8], ...
      'Position',[175 43 150 20], ...
      'String','decimal places', ...
      'Style','text', ...
      'Tag','lblPrecision2');

   h_editCrit = uicontrol('Parent',h_fig, ...
      'Fontsize',10, ...
      'BackgroundColor',[1 1 1], ...
      'Callback','ui_editor(''crit'')', ...
      'HorizontalAlignment','left', ...
      'Position',[130 13 300 22], ...
      'Style','edit', ...
      'Enable','off', ...
      'Tag','editCrit', ...
      'TooltipString','Quality control flag criteria (rules) for the data set column', ...
      'UserData',0);

   h_cmdEditCrit = uicontrol('Parent',h_fig, ...
      'Position',[435 13 50 23], ...
      'String','Edit', ...
      'Enable','off', ...
      'Callback','ui_editor(''critedit'')', ...
      'TooltipString','Edit QA/QC criteria in a GUI dialog', ...
      'Tag','cmdEditCrit');

   h_cmdConvert = uicontrol('Parent',h_fig, ...
      'Callback','ui_editor(''unitconv'')', ...
      'Position',[420 269 60 25], ...
      'String','Convert', ...
      'TooltipString','Perform unit conversions on the data column', ...
      'Enable','off', ...
      'Tag','cmdConvert');

   h_cmdMoveFirst = uicontrol('Parent',h_fig, ...
      'Callback','ui_editor(''movefirst'')', ...
      'Position',[387 565 85 23], ...
      'String','Move First', ...
      'TooltipString','Move selected variable to the top of the list', ...
      'Enable','off', ...
      'Tag','cmdMoveFirst', ...
      'UserData',1);

   h_cmdMoveUp = uicontrol('Parent',h_fig, ...
      'Callback','ui_editor(''moveup'')', ...
      'Position',[387 541 85 23], ...
      'String','Move Up', ...
      'TooltipString','Move selected variable up the list', ...
      'Enable','off', ...
      'Tag','cmdMoveUp');

   h_cmdMoveDown = uicontrol('Parent',h_fig, ...
      'Callback','ui_editor(''movedown'')', ...
      'Position',[387 517 85 23], ...
      'String','Move Down', ...
      'TooltipString','Move selected variable down the list', ...
      'Enable','off', ...
      'Tag','cmdMoveDown');

   h_cmdMoveLast = uicontrol('Parent',h_fig, ...
      'Callback','ui_editor(''movelast'')', ...
      'Position',[387 493 85 23], ...
      'String','Move Last', ...
      'TooltipString','Move selected variable to the bottom of the list', ...
      'Enable','off', ...
      'Tag','cmdMoveLast');

   h_cmdPreview = uicontrol('Parent',h_fig, ...
      'Callback','ui_editor(''preview'')', ...
      'Position',[387 463 85 23], ...
      'String','Preview', ...
      'TooltipString','Preview data formatted based on current settings (first 1000 rows)', ...
      'Enable','off', ...
      'Tag','cmdPreview');

   h_cmdHist = uicontrol('Parent',h_fig, ...
      'Callback','ui_editor(''histogram'')', ...
      'Position',[387 439 85 23], ...
      'String','Histogram', ...
      'TooltipString','View a frequency histogram of the selected column (flagged values removed)', ...
      'Enable','off', ...
      'Tag','cmdHist');

   h_cmdQAQC = uicontrol('Parent',h_fig, ...
      'Callback','ui_editor(''tool_qaqc'',''selected'')', ...
      'Position',[387 415 85 23], ...
      'String','Manual QC', ...
      'TooltipString','Manually assign or clear QA/QC flags for selected data column(s)', ...
      'Enable','off', ...
      'Tag','cmdQAQC');

   h_cmdAdd = uicontrol('Parent',h_fig, ...
      'Callback','ui_editor(''addcol'')', ...
      'Position',[387 385 85 23], ...
      'String','Add', ...
      'TooltipString','Add a variable to the data structure', ...
      'Enable','on', ...
      'Tag','cmdAdd');

   h_cmdDelete = uicontrol('Parent',h_fig, ...
      'Callback','ui_editor(''delete'')', ...
      'Position',[387 361 85 23], ...
      'String','Delete', ...
      'TooltipString','Delete the selected variable(s) from the data structure', ...
      'Enable','off', ...
      'Tag','cmdDelete');

   h_cmdRestore = uicontrol('Parent',h_fig, ...
      'Callback','ui_editor(''restore'')', ...
      'Position',[387 337 85 23], ...
      'String','Restore', ...
      'TooltipString','Restore deleted variables to the list', ...
      'Enable','off', ...
      'Tag','cmdRestore');

   uih = struct( ...
      'listVars',h_listVars, ...
      'lblVarList',h_lblVarList, ...
      'lblColumnName',h_lblColumnName, ...
      'editVarname',h_editVarname, ...
      'editDesc',h_editDesc, ...
      'editUnits',h_editUnits, ...
      'editPrec',h_editPrec, ...
      'editCrit',h_editCrit, ...
      'popDatatype',h_popDatatype, ...
      'popVartype',h_popVartype, ...
      'popNumtype',h_popNumtype, ...
      'cmdMoveFirst',h_cmdMoveFirst, ...
      'cmdMoveUp',h_cmdMoveUp, ...
      'cmdMoveDown',h_cmdMoveDown, ...
      'cmdMoveLast',h_cmdMoveLast, ...
      'cmdAdd',h_cmdAdd, ...
      'cmdDelete',h_cmdDelete, ...
      'cmdRestore',h_cmdRestore, ...
      'cmdQAQC',h_cmdQAQC, ...
      'cmdHist',h_cmdHist, ...
      'cmdPreview',h_cmdPreview, ...
      'cmdEditCodes',h_cmdEditCodes, ...
      'cmdEditCrit',h_cmdEditCrit, ...
      'cmdConvert',h_cmdConvert, ...
      'mnuLoad',h_mnuLoad, ...
      'mnuSave',h_mnuSave, ...
      'mnuSaveDefault',h_mnuSaveDefault, ...
      'mnuSaveVar',h_mnuSaveVar, ...
      'mnuSaveTemplate',h_mnuSaveTemplate, ...
      'mnuLoadTemp',h_mnuLoadTemp, ...
      'mnuFile',h_mnuFile, ...
      'mnuImpMerge',h_mnuImpMerge, ...
      'mnuImpJoin',h_mnuImpJoin, ...
      'mnuExport',h_mnuExport, ...
      'mnuExpAscii',h_mnuExpAscii, ...
      'mnuExpMat',h_mnuExpMat, ...
      'mnuExpMatVars',h_mnuExpMatVars, ...
      'mnuExpEML',h_mnuExpEML, ...
      'mnuExpWS',h_mnuExpWS, ...
      'mnuExpWSCol',h_mnuExpWSCol, ...
      'mnuClone',h_mnuClone, ...
      'mnuAddCol',h_mnuAddCol, ...
      'mnuCopyCol',h_mnuCopyCol, ...
      'mnuConvertDataType',h_mnuConvertDataType, ...
      'mnuToolsPlot',h_mnuToolsPlot, ...
      'mnuToolsQuery',h_mnuToolsQuery, ...
      'mnuToolsResample',h_mnuToolsResample, ...
      'mnuToolsStats',h_mnuToolsStats, ...
      'mnuToolsSpec',h_mnuToolsSpec, ...
      'mnuPlot',h_mnuPlot, ...
      'mnuPlotGroups',h_mnuPlotGroups, ...
      'mnuMapData',h_mnuMapData, ...
      'mnuContourData',h_mnuContourData, ...
      'mnuSort',h_mnuSort, ...
      'mnuReplace',h_mnuReplace, ...
      'mnuInterp',h_mnuInterp, ...
      'mnuCalcMissing',h_mnuCalcMissing, ...
      'mnuCorrectDrift',h_mnuCorrectDrift, ...
      'mnuCalc',h_mnuCalc, ...
      'mnuTitle',h_mnuTitle, ...
      'mnuEditMeta',h_mnuEditMeta, ...
      'mnuEditData',h_mnuEditData, ...
      'mnuClearDupes',h_mnuClearDupes, ...
      'mnuClearBlanks',h_mnuClearBlanks, ...
      'mnuClearBlankCols',h_mnuClearBlankCols, ...
      'mnuEditEncode',h_mnuEditEncode, ...
      'mnuEditDecode',h_mnuEditDecode, ...
      'mnuPrec',h_mnuPrec, ...
      'mnuEditCoalesce',h_mnuEditCoalesce, ...
      'mnuEditConcat',h_mnuEditConcat, ...
      'mnuEditSplitStr',h_mnuEditSplitStr, ...
      'mnuTrimBlanks',h_mnuTrimBlanks, ...
      'mnuUnitsM2E',h_mnuUnitsM2E, ...
      'mnuUnitsE2M',h_mnuUnitsE2M, ...
      'mnuDateFnc',h_mnuDateFnc, ...
      'mnuFlagFnc',h_mnuFlagFnc, ...
      'mnuFlagDefs',h_mnuFlagDefs, ...
      'mnuFlags',h_mnuFlags, ...
      'mnuCopyFlags',h_mnuCopyFlags, ...
      'mnuManualQC',h_mnuManualQC, ...
      'mnuClrFlagVals0',h_mnuClrFlagVals0, ...
      'mnuReFlag',h_mnuReFlag, ...
      'mnuGeoFnc',h_mnuGeoFnc, ...
      'mnuTaxonomic',h_mnuTaxonomic, ...
      'mnuMeta',h_mnuMeta, ...
      'mnuHist',h_mnuHistory, ...
      'mnuStudyDateMeta',h_mnuStudyDateMeta, ...
      'mnuSiteMeta',h_mnuSiteMeta, ...
      'mnuAnomalies',h_mnuAnomalies, ...
      'mnuAnomMissing',h_mnuAnomMissing, ...
      'mnuEditAutoNum',h_mnuEditAutoNum, ...
      'mnuQuery',h_mnuQuery, ...
      'mnuQuit',h_mnuQuit, ...
      'mnuUndo',h_mnuUndo, ...
      'mnuWindowNameTitle',h_mnuWindowNameTitle, ...
      'mnuToolsMetadataCodes',h_mnuToolsMetadataCodes, ...
      'mnuHarvesters',h_mnuHarvesters);
   
   %check for user extension function in path
   if exist('extensions','file') == 2 || exist('extensions','file') == 6
      %call extension function to add toolbox menus
      try
         extensions('menus')
      catch
         %do nothing on error
      end
   end
   
   set(h_fig, ...
      'Visible','on', ...
      'UserData',uih)

   if isempty(s)
      drawnow
   else
      if gce_valid(s,'data')
         if ~isempty(s.name)  %check for empty structure
            ui_editor('newdata');
         end
      else
         drawnow
         messagebox('init','Data structure is invalid and cannot be displayed',[],'Error',[.95 .95 .95])
      end
   end

else  %process callbacks

   %check for valid editor instance
   if length(findobj) > 1  %check for no figure condition
      h_fig = gcf;
      if ~strcmp(get(h_fig,'Tag'),'dlgDSEditor')
         h_fig = [];
      end
   else
      h_fig = [];
   end

   if ~isempty(h_fig)

      %buffer optional input argument if present
      if exist('s','var') == 1
         argument = s;
      else
         argument = '';
      end

      %get stored handles, data structure
      uih = get(h_fig,'UserData');
      d = get(uih.editVarname,'UserData');
      s = get(uih.listVars,'UserData');

      %get pointer for current list item(s)
      rownum = get(uih.listVars,'Value');
      colptrs = get(uih.cmdMoveFirst,'UserData');
      if ~isempty(colptrs)
         ptr = colptrs(rownum);
      else
         ptr = 0;
      end

      %check for external tool calls first
      if strncmp(op,'tool_',5)

         %get cached info, apply all pending edits and column deletions/reordering before passing data to routines
         flag = get(uih.editCrit,'UserData');
         [data,msg,colptrs2] = subfun_dsupdate(s,d,colptrs,flag);
         ptr = colptrs2(rownum);  %update ptr array to reflect column deletes, re-ordering

         %check for error messages before continuing
         if ~isempty(msg)

            messagebox('init',msg,'','Error',[.95 .95 .95])

         elseif ~isempty(data)  %call external tools

            msg = '';  %initialize output message
            data2 = [];  %initialize output structure
            overwrite = 1;  %default to updating existing editor data

            %parse specific tool callback from operator
            if length(op) > 6
               op2 = op(6:end);
            else
               op2 = '';
            end

            %run specified callbacks
            switch op2
               case 'editdata'  %send structure to 'ui_datagrid'
                  ui_datagrid('init',data,uih.mnuEditData,'ui_editor(''editdata'')')
                  overwrite = 0;
               case 'calc'  %send structure to 'ui_calculator'
                  ui_calculator('init',data,uih.mnuCalc,'ui_editor(''addcalc'')');
               case 'viewstats1';  %send structre to 'viewstats'
                  viewstats(data,'E');  %exclude flags
                  overwrite = 0;
               case 'viewstats2'  %send structure to 'viewstats'
                  viewstats(data,'I');  %include flags
                  overwrite = 0;
               case 'colstats'  %send structure to 'ui_statreport'
                  ui_statreport('init',data,'',get(uih.mnuSave,'UserData'));
                  overwrite = 0;
               case 'aggrstat'  %send structure to 'ui_aggrstats'
                  h_mnuReturnData = findobj(h_fig,'Tag','mnuReturnData');  %check for 'Return Data' menu item
                  if ~isempty(h_mnuReturnData)
                     h_mnuToolsStats = uih.mnuToolsStats;
                     ui_aggrstats('init',data,h_mnuToolsStats,'ui_editor(''tool_returnstats'')');
                  else
                     ui_aggrstats('init',data);
                  end
                  overwrite = 0;
               case 'binstat'  %send structure to 'ui_bindata'
                  h_mnuReturnData = findobj(h_fig,'Tag','mnuReturnData');  %check for 'Return Data' menu item
                  if ~isempty(h_mnuReturnData)
                     h_mnuToolsStats = uih.mnuToolsStats;
                     ui_bindata('init',data,h_mnuToolsStats,'ui_editor(''tool_returnstats'')');
                  else
                     ui_bindata('init',data);
                  end
                  overwrite = 0;
               case 'aggrdatetime'  %send structure to ui_aggrdatetime
                  h_mnuReturnData = findobj(h_fig,'Tag','mnuReturnData');  %check for 'Return Data' menu item
                  if ~isempty(h_mnuReturnData)
                     h_mnuToolsStats = uih.mnuToolsStats;
                     ui_aggrdatetime('init',data,h_mnuToolsStats,'ui_editor(''tool_returnstats'')');
                  else
                     ui_aggrdatetime('init',data)
                  end
                  overwrite = 0;
               case 'aggrmovingdate'  %send structure to ui_aggrmovingdatewindow
                  h_mnuReturnData = findobj(h_fig,'Tag','mnuReturnData');  %check for 'Return Data' menu item
                  if ~isempty(h_mnuReturnData)
                     h_mnuToolsStats = uih.mnuToolsStats;
                     ui_aggrdatetime('init',data,h_mnuToolsStats,'ui_editor(''tool_returnstats'')');
                  else
                     ui_aggrmovingdate('init',data)
                  end
                  overwrite = 0;
               case 'returnstats'  %process stat summary return data (callback mode)
                  data2 = get(uih.mnuToolsStats,'UserData');
                  set(uih.mnuToolsStats,'UserData',[])
                  if gce_valid(data2,'data') ~= 1
                     data2 = [];
                     msg = 'Invalid data set returned from statistical analysis';
                  else
                     msg = '';
                  end
               case 'topbottom'  %send to 'ui_topbottom'
                  ui_topbottom('init',data);
                  overwrite = 0;
               case 'query'  %send structure to 'ui_querybuilder'
                  h_mnuReturnData = findobj(h_fig,'Tag','mnuReturnData');  %check for 'Return Data' menu item
                  if ~isempty(h_mnuReturnData)  %menu present - operating in callback mode (return data to current instance)
                     h_mnuQuery = uih.mnuToolsQuery;
                     ui_querybuilder('init',data,h_mnuQuery,'ui_editor(''tool_returnquery'')');
                  else  %stand-alone mode (return data as new instance)
                     ui_querybuilder('init',data);
                  end
                  overwrite = 0;
               case 'returnquery'  %process query return data (callback mode)
                  qry = get(uih.mnuToolsQuery,'UserData');
                  set(uih.mnuToolsQuery,'UserData','')
                  if ~isempty(qry)
                     [data2,numrows,qry,msg] = querydata(data,qry);
                     if ~isempty(data2)
                        msg = ['Query was successful, returning ',int2str(numrows),' of ',int2str(length(data.values{1})),' rows'];
                     end
                  else
                     msg = 'Query was not returned from the Query Bulder';
                  end
               case 'split'  %send structure to 'ui_splitseries'
                  ui_splitseries('init',data);
                  overwrite = 0;
               case 'normalize'  %send structure to 'ui_normalizecols'
                  ui_normalizecols('init',data);
                  overwrite = 0;
               case 'plot'   %send structure to 'ui_plotdata'
                  ui_plotdata('init',data);
                  overwrite = 0;
               case 'plotgroups'   %send structure to 'ui_plotdata'
                  ui_plotgroups('init',data);
                  overwrite = 0;
               case 'mapdata'   %send structure to 'ui_mapdata'
                  ui_mapdata('init',data);
                  overwrite = 0;
               case 'contourdata'  %send structure to 'ui_plotvertprofile'
                  ui_plotvertprofile('init',data);
                  overwrite = 0;
               case 'cleardupes'  %clear duplicate records
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg,deletedrows] = cleardupes(data);
                  set(gcf,'pointer','arrow'); drawnow
                  if ~isempty(data2)
                     if deletedrows == 0  %catch no dupes
                        data2 = [];
                     else
                        msg = [int2str(deletedrows),' records with duplicate values in all columns were deleted'];
                     end
                  end
               case 'cleardupes_nd'  %clear duplicate records (non-data dupes)
                  set(gcf,'pointer','watch'); drawnow
                  Inondata = listdatacols(data,'inverse');
                  [data2,msg,deletedrows] = cleardupes(data,Inondata);
                  set(gcf,'pointer','arrow'); drawnow
                  if ~isempty(data2)
                     if deletedrows == 0  %catch no dupes
                        data2 = [];
                     else
                        msg = [int2str(deletedrows),' records with duplicate values in all non-data columns were deleted'];
                     end
                  end
               case 'cleardupes_dt'  %clear duplicate records (date-time dupes)
                  set(gcf,'pointer','watch'); drawnow
                  Idt = find(strcmp('datetime',data.variabletype));
                  [data2,msg,deletedrows] = cleardupes(data,Idt);
                  set(gcf,'pointer','arrow'); drawnow
                  if ~isempty(data2)
                     if deletedrows == 0  %catch no dupes
                        data2 = [];
                     else
                        msg = [int2str(deletedrows),' records with duplicate date/time columns were deleted'];
                     end
                  end
               case 'clearblanks'  %clear empty records (all columns)
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg,deletedrows] = compactrows(data,[]);
                  set(gcf,'pointer','arrow'); drawnow
                  if ~isempty(data2)
                     if deletedrows == 0  %catch no blanks
                        data2 = [];
                     else
                        msg = [int2str(deletedrows),' records with NaN/null entries in all columns were deleted'];
                     end
                  end
               case 'clearblanks2'  %clear empty records (data columns)
                  Idata = listdatacols(data);
                  if ~isempty(Idata)
                     set(gcf,'pointer','watch'); drawnow
                     [data2,msg,deletedrows] = compactrows(data,Idata);
                     set(gcf,'pointer','arrow'); drawnow
                     if ~isempty(data2)
                        if deletedrows == 0  %catch no blanks
                           data2 = [];
                        else
                           msg = [int2str(deletedrows),' records with NaN/null entries in all data and calculation columns were deleted'];
                        end
                     end
                  else
                     data2 = [];
                     msg = 'no data or calculation columns are present in the data set';
                  end
               case 'clearblanks3'  %clear empty records (selected columns)
                  if ~isempty(ptr)
                     set(gcf,'pointer','watch'); drawnow
                     [data2,msg,deletedrows] = compactrows(data,ptr);
                     set(gcf,'pointer','arrow'); drawnow
                     if ~isempty(data2)
                        if deletedrows == 0  %catch no blanks
                           data2 = [];
                        else
                           if deletedrows > 1
                              msg = [int2str(deletedrows),' records with NaN/null entries in the selected column(s) were deleted'];
                           else
                              msg = '1 record with NaN/null entries in the selected column(s) were deleted';
                           end
                        end
                     end
                  else
                     data2 = [];
                     msg = 'no columns were selected';
                  end
               case 'clearblankcols'  %remove empty columns
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = compactcols(data,[]);
                  %override output if no columns deleted to preserve undo cache
                  if ~isempty(data2)
                     if length(data2.name) == length(data.name)
                        data2 = [];
                     end
                  end
                  set(gcf,'pointer','arrow'); drawnow
               case 'trimstr'  %trim string columns
                  if strcmp('selected',argument)
                     cols = ptr;
                  else
                     cols = [];
                  end
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = trim_textcols(data,cols);
                  set(gcf,'pointer','arrow'); drawnow                  
               case 'fixprec_all'  %round all columns to display precision
                  if ~isempty(argument)
                     opt = argument;
                     set(gcf,'pointer','watch'); drawnow
                     [data2,msg] = fixprec(data,[],opt);
                     set(gcf,'pointer','arrow'); drawnow
                  else
                     data2 = [];
                     msg = 'invalid rounding option';
                  end
               case 'fixprec_sel'  %round selected columns to display precision
                  if ~isempty(argument)
                     opt = argument;
                     set(gcf,'pointer','watch'); drawnow
                     [data2,msg] = fixprec(data,ptr,opt);
                     set(gcf,'pointer','arrow'); drawnow
                  else
                     data2 = [];
                     msg = 'invalid rounding option';
                  end
               case 'coalesce'  %coalesce values in multiple columns
                  if length(ptr) > 1
                     set(gcf,'pointer','watch'); drawnow
                     if strcmp(argument,'delete')
                        deletecol = 1;
                     else
                        deletecol = 0;
                     end
                     [data2,msg] = coalesce_cols(data,ptr(1),ptr(2:end),1,'',deletecol);
                     set(gcf,'pointer','arrow'); drawnow
                     if ~isempty(msg)
                        msg = ['An error occurred coalescing column values: ',msg];
                     end
                  else
                     msg = 'This function requires multiple column selections';
                  end
               case 'concat'  %concatenate selected columns
                  separator = argument;
                  if length(ptr) > 1
                     set(gcf,'pointer','watch'); drawnow
                     [data2,msg] = concat_cols(data,ptr,separator);
                     set(gcf,'pointer','arrow'); drawnow
                  else
                     msg = 'This function requires multiple column selections';
                  end
               case 'splitstr'  %split selected string column
                  delim = argument;
                  if length(ptr) == 1 && strcmp(data.datatype{ptr},'s')
                     set(gcf,'pointer','watch'); drawnow
                     [data2,msg] = split_cols(data,ptr,delim);
                     set(gcf,'pointer','arrow'); drawnow
                  else
                     msg = 'This function requires a single text column selection';
                  end
               case 'sort'  %send structure to 'ui_sortcolumns'
                  ui_sortcolumns('init',data,uih.mnuSort,'ui_editor(''sortcols'')');
               case 'replace'  %send structure to ui_string_replace or ui_num_replace
                  if strcmp(argument,'text')
                     ui_string_replace('init',data,ptr,'data',uih.mnuReplace,'ui_editor(''replace'')');
                  elseif strcmp(argument,'flags')
                     ui_string_replace('init',data,ptr,'flags',uih.mnuReplace,'ui_editor(''replace'')');                     
                  else  %numbers
                     ui_num_replace('init',data,ptr,uih.mnuReplace,'ui_editor(''replace'')');
                  end
               case 'interp'  %send structure to 'ui_interp_missing'
                  ui_interp_missing('init',data,uih.mnuInterp,'ui_editor(''interp'')');
               case 'calcmissing'  %send structure to 'ui_calc_missing'
                  ui_calc_missing('init',data,uih.mnuCalcMissing,'ui_editor(''calcmissing'')');
               case 'drift'  %send structure to 'ui_correct_drift'
                  ui_correct_drift('init',data,uih.mnuCorrectDrift,'ui_editor(''drift'')');
               case 'addvar'  %add vars from Matlab workspace
                  ws = evalin('base','whos');
                  if ~isempty(ws)
                     Ivalid = find(strcmp({ws.class},'cell') | strcmp({ws.class},'double'));
                  else
                     Ivalid = [];
                  end
                  if ~isempty(Ivalid)
                     ws = ws(Ivalid);
                     numrows = length(s.values{1});
                     varnames = cell(length(ws),1);
                     str = varnames;
                     for n = 1:length(Ivalid)
                        sz = ws(n).size;
                        if (sz(1) == numrows && sz(2) == 1) || (sz(1) == 1 && sz(2) == numrows)
                           varnames{n} = ws(n).name;
                           str{n} = [ws(n).name,' (',ws(n).class,' array)'];
                        end
                     end
                     Ivars = find(~cellfun('isempty',varnames));
                     if ~isempty(Ivars)
                        varnames = varnames(Ivars);
                        str = str(Ivars);
                        Isel = listdialog('liststring',str, ...
                           'name','Add Workspace Variables', ...
                           'promptstring','Select workspace variables to add', ...
                           'listsize',[0 0 300 380]);
                        if ~isempty(Isel)
                           data2 = data;
                           if strcmp(argument,'update')
                              updatecols = 1;
                           else
                              updatecols = 0;
                           end
                           for n = 1:length(Isel)
                              newdata = evalin('base',varnames{Isel(n)},'[]');
                              Icol = name2col(data2,varnames{Isel(n)});
                              if updatecols == 1 && ~isempty(Icol)
                                 data2 = update_data(data2,Icol(1),newdata,50,'R');
                              else
                                 data2 = addcol(data2,newdata,varnames{Isel(n)},'unspecified');
                              end
                              if isempty(data2)
                                 msg = ['an error occurred importing ''',varnames{Isel(n)},''' from the workspace'];
                              end
                           end
                        end
                     else
                        msg = 'No compatible variables matching the current number of data rows were found in the workspace';
                     end
                  else
                     msg = 'No compatible variables were found in the workspace';
                  end
               case 'copycol'  %copy selected columns
                  numcols = length(data.name);
                  if strcmp(argument,'all')
                     cols = (1:numcols);
                  else
                     cols = ptr;  %get column selections
                  end
                  [data2,msg] = copycols(data,[1:numcols,cols(:)'],'Y');
                  if ~isempty(data2)
                     for cnt = 1:length(cols)
                        colpos = numcols+cnt;
                        data2 = rename_column(data2,colpos,[data2.name{colpos},'_copy'],[],0);
                     end
                     if isempty(data2)
                        msg = 'An error occurred renaming the copied column(s)';
                     end
                  end
               case 'addintcol'  %add integer column
                  [data2,msg] = addcol(data,repmat(NaN,length(data.values{1}),1), ...
                     'NewColumn','unspecified','','d','unspecified','discrete',0,'',length(data.name)+1);
               case 'addfpcol'  %add integer column
                  [data2,msg] = addcol(data,repmat(NaN,length(data.values{1}),1), ...
                     'NewColumn','unspecified','','f','unspecified','continuous',2,'',length(data.name)+1);
               case 'addstrcol'  %add text column
                  [data2,msg] = addcol(data,repmat({''},length(data.values{1}),1), ...
                     'NewColumn','unspecified','','s','unspecified','none',0,'',length(data.name)+1);
               case 'units_m2e'  %perform metric-to-english conversions
                  [data2,msg] = unit_convert(data,(1:length(data.name)),'english');
               case 'units_e2m'  %perform english-to-metric conversions
                  [data2,msg] = unit_convert(data,(1:length(data.name)),'metric');
               case 'convertdate'  %perform date conversion
                  fmt = argument;
                  if isnan(fmt)
                     fmt = [];  %catch matlab format option
                  end
                  set(gcf,'pointer','watch'); drawnow                  
                  [data2,msg] = convert_date_format(data,ptr,fmt);
                  set(gcf,'pointer','arrow'); drawnow
               case 'timeCSI'  %perform CSI time conversion
                  fmt = argument;
                  set(gcf,'pointer','watch'); drawnow                  
                  [data2,msg] = convert_csi_time(data,ptr,fmt);
                  set(gcf,'pointer','arrow'); drawnow                  
               case 'date'  %add formatted date column from date components
                  fmt = argument;
                  set(gcf,'pointer','watch'); drawnow
                  if strcmp(fmt,'cr10')
                     [data2,msg] = calc_date_cr10(data);
                  else
                     [data2,msg] = add_datecol(data,fmt);
                  end
                  set(gcf,'pointer','arrow'); drawnow
               case 'datecols' %add date part columns from date
                  if isempty(argument); argument = []; end
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = add_datepartcols(data,[],[],argument);
                  set(gcf,'pointer','arrow'); drawnow
               case 'yeardaycol' %add year day column
                  opt = argument;
                  set(gcf,'pointer','watch'); drawnow
                  if strcmp(opt,'year_yearday_hours')
                     [data2,msg] = add_year_yearday_hours(data);
                  else
                     [data2,msg] = add_yeardaycol(data,opt);
                  end
                  set(gcf,'pointer','arrow'); drawnow
               case 'filldates'  %fill in date gaps
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg,dupe_flag] = pad_date_gaps(data,[],0,argument);
                  set(gcf,'pointer','arrow'); drawnow
                  if dupe_flag == 1
                     msg = '';
                     data2 = [];
                     confirmdlg('init','Duplicate date/time values present - proceed anyway? (removes duplicate records)', ...
                        ['ui_editor(''tool_filldates_dupes'',',int2str(argument),')'])
                  end
               case 'filldates_dupes'  %fill in date gaps despite duplicate values
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = pad_date_gaps(data,[],1,argument);
                  set(gcf,'pointer','arrow'); drawnow
               case 'filldates_20hz'  %fill in date gaps
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg,dupe_flag] = pad_date_gaps(data,[],0,argument,1/1200);
                  set(gcf,'pointer','arrow'); drawnow
                  if dupe_flag == 1
                     msg = '';
                     data2 = [];
                     confirmdlg('init','Duplicate date/time values present - proceed anyway? (removes duplicate records)', ...
                        ['ui_editor(''tool_filldates_20Hz_dupes'',',int2str(argument),')'])
                  end
               case 'filldates_20hz_dupes'  %fill in date gaps despite duplicate values
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = pad_date_gaps(data,[],1,argument,1/1200);
                  set(gcf,'pointer','arrow'); drawnow
               case 'encode'  %encode text columns
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = encodestrings(data);
                  if ~isempty(msg)
                     data2 = [];  %clear data to avoid update in case of no text columns
                  end
                  set(gcf,'pointer','arrow'); drawnow
               case 'encode2'  %encode text columns
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = encodestrings(data,0);
                  if ~isempty(msg)
                     data2 = [];  %clear data to avoid update in case of no text columns
                  end
                  set(gcf,'pointer','arrow'); drawnow
               case 'decode'  %decode coded columns
                  if strcmp(argument,'selected')
                     cols = ptr;  %get column selections if selected columns option
                  else
                     cols = [];  %default to all coded columns otherwise
                  end
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = decodecols(data,cols);  %run decode function
                  set(gcf,'pointer','arrow'); drawnow
               case 'convert'  %convert column data types
                  set(gcf,'pointer','watch'); drawnow
                  args = splitstr(argument,'_');
                  if strcmp(args{2},'sel')
                     cols = ptr;
                  else
                     cols = 1:length(data.name);
                  end
                  integeropt = '';
                  switch args{1}
                     case 'f'
                        dtype = 'f';
                     case 'e'
                        dtype = 'e';
                     case 's'
                        dtype = 's';
                     case 'dr'
                        dtype = 'd';
                        integeropt = 'round';
                     case 'du'
                        dtype = 'd';
                        integeropt = 'ceil';
                     case 'dd'
                        dtype = 'd';
                        integeropt = 'floor';
                     case 'dt'
                        dtype = 'd';
                        integeropt = 'fix';
                     otherwise
                        dtype = '';
                  end
                  if ~isempty(dtype)
                     [data2,msg] = convert_datatype(data,cols,dtype,integeropt);
                  else
                     data2 = [];
                     msg = 'unsupported conversion option';
                  end
                  set(gcf,'pointer','arrow'); drawnow
               case 'autonum'  %automatically determine numerical types, precisions
                  data2 = assign_numtype(data,10000);
                  msg = '';
                  if isempty(data2)
                     msg = 'could not determine numerical types of columns';
                  end
               case 'sitemeta'  %add/update site metadata
                  [data2,msg] = add_sitemetadata(data);
               case 'studydates'  %add/update study dates
                  [data2,msg] = add_studydates(data);
                  if isempty(msg)
                     msg = 'Successfully updated study date metadata based on values in date/time columns';
                  end
               case 'addsites_location'  %add site column from location names
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = add_sitenames(data);
                  set(gcf,'pointer','arrow'); drawnow
               case 'addsites'  %add site column from lat/lon
                  set(gcf,'pointer','watch'); drawnow
                  sitetype = argument;  %get site type restriction from second argument
                  if isempty(sitetype)
                     [data2,msg] = add_studysites(data,'all');
                  else
                     [data2,msg] = add_studysites(data,sitetype);
                  end
                  set(gcf,'pointer','arrow'); drawnow
               case 'addloc1'  %add locations from lat/lon (0.5km resolution)
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = add_locations(data,0.5,0.25,argument);
                  set(gcf,'pointer','arrow'); drawnow
               case 'addloc2'  %add locations from lat/lon (1km resolution)
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = add_locations(data,1,0.5,argument);
                  set(gcf,'pointer','arrow'); drawnow
               case 'addloc3'  %add locations from lat/lon (2km resolution)
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = add_locations(data,2,1,argument);
                  set(gcf,'pointer','arrow'); drawnow
               case 'addtransects1'  %add transects from lat/lon (1km resolution)
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = add_transect_dist(data,[],[],argument,2,0.5);
                  set(gcf,'pointer','arrow'); drawnow
               case 'addtransects2'  %add transects from lat/lon (2km resolution)
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = add_transect_dist(data,[],[],argument,1,1);
                  set(gcf,'pointer','arrow'); drawnow
               case 'addtransects3'  %add transects from lat/lon (2km resolution)
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = add_transect_dist(data,[],[],argument,1,2);
                  set(gcf,'pointer','arrow'); drawnow
               case 'riverdist2latlon'  %add latlon from river distance
                  set(gcf,'pointer','watch'); drawnow
                  river = argument;
                  [data2,msg] = add_riverdist_gps(data,river,[],'latlon');
                  set(gcf,'pointer','arrow'); drawnow
               case 'riverdist2utm'  %add latlon from river distance
                  set(gcf,'pointer','watch'); drawnow
                  river = argument;
                  [data2,msg] = add_riverdist_gps(data,river,[],'utm');
                  set(gcf,'pointer','arrow'); drawnow
               case 'reflag'  %regenerate QC flags
                  [data2,msg] = dataflag(data);
               case 'codeflags'  %generate q/c criteria for coded columns
                  option = argument;
                  set(gcf,'pointer','watch'); drawnow
                  if strcmp(option,'selected')
                     cols = ptr;  %get column selections
                     [data2,msg] = codes2criteria(data,cols);
                  else
                     [data2,msg] = codes2criteria(data);
                  end
                  set(gcf,'pointer','arrow'); drawnow
               case 'copyflags'  %open custom flag copying dialog
                  ui_copyflags('init',data,uih.mnuCopyFlags,'ui_editor(''copyflags'');');
               case 'clrflags'  %open custom flag removal dialog (mode = 'flags')
                  ui_clearflags('init',data,'flags',uih.mnuClrFlagVals0,'ui_editor(''clrflags'');');
               case 'clrflags0'  %open custom flag value removal dialog (mode = 'values')
                  ui_clearflags('init',data,'values',uih.mnuClrFlagVals0,'ui_editor(''clrflags'');');
               case 'clrflags1clear'  %null flagged values clearing flags
                  [data2,msg] = nullflags(data,'',[],0,1);
                  if isempty(data2)
                     msg = 'could not null flagged values';
                  end
               case 'clrflags1keep'  %null flagged values retaining flags
                  [data2,msg] = nullflags(data,'',[],0,0);
                  if isempty(data2)
                     msg = 'could not null flagged values';
                  end
               case 'clrflags2'  %remove rows with nulled values
                  data2 = cullflags(data);
                  msg = '';
                  if isempty(data2)
                     messagebox('init', ...
                        'Function cancelled -- all rows would be removed', ...
                        '', ...
                        'Message', ...
                        [.95 .95 .95]);
                  else
                     delrows = length(data.values{1}) - length(data2.values{1});
                     if delrows ~= 1
                        str = [int2str(delrows),' rows'];
                     else
                        str = '1 row';
                     end
                     messagebox('init', ...
                        [str,' with flagged values deleted from the structure'], ...
                        '', ...
                        'Message', ...
                        [.95 .95 .95]);
                  end
               case 'flags0'  %open dialog for selective conversion
                  ui_clearflags('init',data,'flags2cols',uih.mnuClrFlagVals0,'ui_editor(''clrflags'');',1);
               case 'flags1'  %create compound data column of value flags
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = flags2cols(data,'single',0);
                  set(gcf,'pointer','arrow'); drawnow
               case 'flags2'  %create flag columns for any columns with flagged vals
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = flags2cols(data,'mult',0);
                  set(gcf,'pointer','arrow'); drawnow
               case 'flags3'  %create flag columns for all data columns
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = flags2cols(data,'alldata',0);
                  set(gcf,'pointer','arrow'); drawnow
               case 'flags3+'  %create flag columns for all data columns
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = flags2cols(data,'mult+data',0);
                  set(gcf,'pointer','arrow'); drawnow
               case 'flags4'  %create flag columns for all data columns plus missing=M (ClimDB)
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = flags2cols(data,'alldata',0,1);
                  set(gcf,'pointer','arrow'); drawnow
               case 'flags4+'  %create flag columns for all data columns plus missing=M (ClimDB)
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = flags2cols(data,'mult+data',0,1);
                  set(gcf,'pointer','arrow'); drawnow
               case 'flags5'  %create flag columns for all columns
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = flags2cols(data,'all',0);
                  set(gcf,'pointer','arrow'); drawnow
               case 'flags0E'  %open dialog for selection conversion
                  ui_clearflags('init',data,'flags2cols',uih.mnuClrFlagVals0,'ui_editor(''clrflags'');',2);
               case 'flags2E'  %create flag columns for any columns with flagged vals
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = flags2cols(data,'mult',0,0,1,1);
                  set(gcf,'pointer','arrow'); drawnow
               case 'flags3E'  %create flag columns for all data columns
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = flags2cols(data,'alldata',0,0,1,1);
                  set(gcf,'pointer','arrow'); drawnow
               case 'flags3E+'  %create flag columns for all data columns
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = flags2cols(data,'mult+data',0,0,1,1);
                  set(gcf,'pointer','arrow'); drawnow
               case 'flags4E'  %create flag columns for all data columns plus missing=M (ClimDB)
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = flags2cols(data,'alldata',0,1,1,1);
                  set(gcf,'pointer','arrow'); drawnow
               case 'flags4E+'  %create flag columns for all data columns plus missing=M (ClimDB)
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = flags2cols(data,'mult+data',0,1,1,1);
                  set(gcf,'pointer','arrow'); drawnow
               case 'flags5E'  %create flag columns for all columns
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = flags2cols(data,'all',0,0,1,1);
                  set(gcf,'pointer','arrow'); drawnow
               case 'cols2flags0'  %convert flag columns to QA/QC flags (merge)
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = cols2flags(data);
                  set(gcf,'pointer','arrow'); drawnow
               case 'cols2flags1'  %convert flag columns to QA/QC flags (overwrite)
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = cols2flags(data,[],[],1);
                  set(gcf,'pointer','arrow'); drawnow
               case 'cols2flagsmap0'  %convert flag columns to QA/QC flags (merge)
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = cols2flags_mapped(data);
                  set(gcf,'pointer','arrow'); drawnow
               case 'cols2flagsmap1'  %convert flag columns to QA/QC flags (overwrite)
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = cols2flags_mapped(data,[],[],[],1);
                  set(gcf,'pointer','arrow'); drawnow
               case 'deg2utm'  %calculate utm columns from lat/lon
                  datum = argument;
                  if ~isempty(datum)
                     set(gcf,'pointer','watch'); drawnow
                     [data2,msg] = add_utmcoords(data,[],[],[],datum);
                     set(gcf,'pointer','arrow'); drawnow
                  else
                     msg = 'invalid datum for reprojection';
                  end
               case 'utm2deg'  %calculate lat/lon columns from UTM
                  datum = argument;
                  if ~isempty(datum)
                     set(gcf,'pointer','watch'); drawnow
                     [data2,msg] = add_latloncoords(data,[],[],[],[],[],datum);
                     set(gcf,'pointer','arrow'); drawnow
                  else
                     msg = 'invalid datum for reprojection';
                  end
               case 'addstatcoord_latlon'  %lookup station coords in latlon
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = add_stationcoords(data,'latlon');
                  set(gcf,'pointer','arrow'); drawnow
               case 'addstatcoord_utm'  %lookup station coords in latlon
                  set(gcf,'pointer','watch'); drawnow
                  [data2,msg] = add_stationcoords(data,'utm');
                  set(gcf,'pointer','arrow'); drawnow
               case 'hist'  %display processing history               
                  ui_viewmeta(data,'hist');
                  overwrite = 0;
               case 'qaqc'  %manually assign QA/QC flags
                  if strcmp(argument,'selected')
                     cols = ptr;  %get selected column index
                     ui_manual_qc('init',data,cols,uih.mnuManualQC,'ui_editor(''qaqc'')');
                  else  %all
                     ui_manual_qc('init',data,[],uih.mnuManualQC,'ui_editor(''qaqc'')');
                  end
                  overwrite = 0;
               case 'editcodes'  %invoke code editor dialog
                  dtype = get_type(data,'datatype',ptr);
                  vtype = get_type(data,'variabletype',ptr);
                  if inlist(dtype,{'s','d'}) == 1 && strcmp(vtype,'code')
                     ui_editcodes(data,ptr,uih.cmdEditCodes,'ui_editor(''editcodes'')')
                  else
                     messagebox('init', ...
                        'Codes can only be defined for coded alphanumeric string and integer columns', ...
                        [], ...
                        'Error', ...
                        [.95 .95 .95]);
                  end
               case 'ws'  %copy structure to Matlab workspace
                  assignin('base','data',data)
                  messagebox('init', ...
                     char([{'The data structure was successfully copied to'}; ...
                     {'the base MATLAB workspace as ''data'''}]), ...
                     [], ...
                     'Message', ...
                     [.95 .95 .95]);
               case 'searcheng'  %copy data to Search Engine
                  h_dlg = findobj('Tag','dlgSearchData');
                  if isempty(h_dlg)
                     ui_search_data('init')
                  else
                     figure(h_dlg(1))
                  end
                  ui_search_data('cachetemp',data)
               case 'clone'  %copy data to a new editor instance
                  if strcmp(argument,'selected')
                     %prompt for column(s) to include
                     collist = concatcellcols([(data.name)',repmat({' ('},length(data.name),1), ...
                        (data.units)',repmat({')'},length(data.name),1)],'');
                     collist = strrep(strrep(collist,' (none)',''),' ()','');
                     Isel = listdialog( ...
                        'liststring',collist, ...
                        'name','Column Selection', ...
                        'promptstring','Select Columns to Include', ...
                        'selectionmode','multiple', ...
                        'listsize',[0 0 400 500]);
                     if ~isempty(Isel)
                        ui_editor('init',copycols(data,Isel))
                     end
                  else
                     ui_editor('init',data)
                  end
               case 'searchengmove'  %copy data to Search Engine
                  h_dlg = findobj('Tag','dlgSearchData');
                  if isempty(h_dlg)
                     ui_search_data('init')
                  else
                     figure(h_dlg(1))
                  end
                  try
                     ui_search_data('cachetemp',data)
                     delete(h_fig)
                  catch
                     msg = 'An error occurred moving the structure - operation cancelled';
                  end
               case 'wscol_all'  %copy columns to Matlab workspace
                  cnt_errors = 0;
                  for n = 1:length(data.name)
                     try
                        assignin('base',data.name{n},extract(data,n));
                     catch
                        cnt_errors = cnt_errors + 1;
                     end
                  end
                  overwrite = 0;
                  msg = '';
                  if cnt_errors > 0
                     msg = 'Errors occurred copying some data columns to the base MATLAB workspace';
                  else
                     messagebox('init', ...
                        'All data columns were successfully copied to the base MATLAB workspace as named variables', ...
                        [], ...
                        'Message', ...
                        [.95 .95 .95]);
                  end
               case 'wscol_sel'  %copy selected columns to Matlab workspace
                  cnt_errors = 0;
                  for n = 1:length(ptr)
                     try
                        assignin('base',data.name{ptr(n)},extract(data,ptr(n)));
                     catch
                        cnt_errors = cnt_errors + 1;
                     end
                  end
                  overwrite = 0;
                  msg = '';
                  if cnt_errors > 0
                     msg = 'Errors occurred copying some data columns to the base MATLAB workspace';
                  else
                     if length(ptr) > 1
                        msgstr = [int2str(length(ptr)),' selected data columns were successfully copied to', ...
                           ' the base MATLAB workspace'];
                     else
                        msgstr = 'The selected data column was successfully copied to the base MATLAB workspace';
                     end
                     messagebox('init', ...
                        msgstr, ...
                        [], ...
                        'Message', ...
                        [.95 .95 .95]);
                  end
               case 'anomalies'  %summarize flags as anomalies
                  h_cb = gcbo;
                  parms = get(h_cb,'UserData');
                  if iscell(parms) && length(parms) == 2
                     fmt = parms{1};
                     sep = parms{2};
                     set(gcf,'pointer','watch'); drawnow
                     [data2,msg] = add_anomalies(data,fmt,sep,0,-1);
                     set(gcf,'pointer','arrow'); drawnow
                  else
                     msg = 'an error occurred retrieving the date format parameters for the selected option';
                  end
               case 'anom_missing'  %summarize flags & missing values as anomalies
                  h_cb = gcbo;
                  parms = get(h_cb,'UserData');
                  if iscell(parms) && length(parms) == 2
                     fmt = parms{1};
                     sep = parms{2};
                     set(gcf,'pointer','watch'); drawnow
                     [data2,msg] = add_anomalies(data,fmt,sep,1,-1);
                     set(gcf,'pointer','arrow'); drawnow
                  else
                     msg = 'an error occurred retrieving the date format parameters for the selected option';
                  end
               case 'ctddataset'  %create ctd station dataset
                  if ~isempty(argument)
                     if argument == 3
                        dist_start = -42;
                     else
                        dist_start = -40;
                     end
                  else
                     dist_start = -40;
                  end
                  [data2,msg] = ctd2dataset(argument,dist_start);
                  overwrite = 0;
               case 'codes2data'  %generate code definition data set
                  switch argument
                     case 'autoprompt'  %auto columns, manual metadata
                        [data2,msg] = codes2dataset(data,[],'prompt');
                     case 'selected'    %selected columns, auto metadata
                        [data2,msg] = codes2dataset(data,ptr,[]);
                     case 'selectedprompt'  %selected column, manual metadata
                        [data2,msg] = codes2dataset(data,ptr,'prompt');
                     otherwise  %auto columns, auto metadata
                        [data2,msg] = codes2dataset(data);
                  end
                  overwrite = 0;
               case 'itis'  %add ITIS TSN column
                  if strcmp(argument,'common')
                     [data2,msg] = add_itis_tsn(data,ptr,'common');
                  else  %scientific
                     [data2,msg] = add_itis_tsn(data,ptr,'scientific');
                  end
               case 'emlmetadata'  %generate EML metadata
                  if strcmp(argument,'yes')
                     mapunits = 1;
                  else
                     mapunits = 0;
                  end
                  accession = lookupmeta(data,'Dataset','Accession');
                  [xml,s_eml,msg] = gceds2eml(data,accession,'','','data','csv',[],'B','MD+','NaN','',mapunits);
                  if ~isempty(xml) && ~isempty(s_eml)
                     viewtext(char(xml),0,0,'EML Metadata Preview');
                  end
               otherwise  %handle metadata view calls, passing format string parsed from op to viewer
                  ui_viewmeta(data,op(6:end));
                  overwrite = 0;
            end

            %handle returned data
            if ~isempty(data2)
               if overwrite == 0
                  ui_editor('init',data2);  %send tool-generated data files to new editor instance
               else   %incorporate new data
                  s = get(uih.listVars,'UserData');
                  set(uih.mnuUndo,'UserData',s)  %cache undo data
                  set(uih.listVars,'UserData',data2)
                  ui_editor('newdata')
                  set(uih.mnuQuit,'UserData',1)  %set dirty flag *after* update
               end
               if ~isempty(msg)  %put up any nonfatal tool-generated error message
                  messagebox('init', ...
                     msg, ...
                     [], ...
                     'Information', ...
                     [.95 .95 .95]);
               end
            elseif ~isempty(msg) %alert user to any tool-generated error messages
               messagebox('init', ...
                  char('Could not perform the selected operation',['(Error: ',msg,')']), ...
                  [], ...
                  'Error', ...
                  [.95 .95 .95]);
            end

         else
            messagebox('init', ...
               char('Could perform the selected operation because the edited structure failed validation', ...
               ['(Error: ',msg,')']), ...
               [], ...
               'Error', ...
               [.95 .95 .95]);
         end

      elseif strncmp(op,'imp_',4)  %check for import filter calls

         if strncmp(op,'imp_join',8) || strncmp(op,'imp_ds',6)  %catch merge/join calls first

            %init secondary data structure
            s2 = [];

            %check for open data set callback
            if isempty(strfind(op,'_open'))  %prompt for file-based data set

               %get last used load path
               pn = get(uih.mnuLoad,'UserData');
               cd(pn)
               if strcmp(op,'imp_join')
                  [fn,pn] = uigetfile('*.mat;*.MAT','Select a MATLAB file containing the data structure to join');
               else
                  [fn,pn] = uigetfile('*.mat;*.MAT','Select a MATLAB file containing the data structure to merge');
               end
               cd(curpath)

               if pn ~= 0
                  syncpath(pn,'load')  %cache selected path
               end
               drawnow

               if fn ~= 0
                  s2 = imp_datastruct(fn,pn);  %run external filter to load specified file
               else
                  fn = '';
               end

            else  %prompt for open data set via external function call
               s2 = get_open_dataset;
               fn = 'in-memory data set';
            end

            if ~isempty(s2)  %incorporate data

               set(gcf,'pointer','watch')
               drawnow

               %apply edits before merging
               s_old = s;
               flag = get(uih.editCrit,'UserData');
               [s1,msg] = subfun_dsupdate(s_old,d,colptrs,flag);

               if isempty(msg)  %check for validation errors

                  if strncmp(op,'imp_join',8)

                     set(gcf,'pointer','arrow')
                     drawnow

                     %determine auto date/time join option based on argument
                     if strcmp(op,'imp_join2') || strcmp(op,'imp_join_open2')
                        autojoin = 1;
                     else
                        autojoin = 0;
                     end

                     %send structure to external app, use callback to incorporate
                     ui_joindata('init',s1,s2,fn,h_fig,uih.mnuImpJoin,'ui_editor(''procjoin'')',autojoin)

                  else

                     if strncmp(op,'imp_ds3',7)
                        [s,msg] = merge_by_date(s1,s2);  %merge by date, overwrite older
                     elseif strncmp(op,'imp_ds4',7)
                        [s,msg] = merge_by_date(s1,s2,[],[],0,1,'newer');  %merge by date, add newer
                     elseif strncmp(op,'imp_ds1',7)
                        [s,msg] = datamerge(s1,s2,1,1);  %append data, pad mismatches
                     else
                        [s,msg] = datamerge(s1,s2,2,1);  %prepend data, pad mismatches
                     end

                     set(gcf,'pointer','arrow')
                     drawnow

                     if ~isempty(s)
                        if ~isempty(s_old)  %cache prior structure
                           set(uih.mnuUndo,'UserData',s_old)
                        else  %no cache - cache new structure
                           set(uih.mnuUndo,'UserData',s)
                        end
                        set(uih.listVars,'UserData',s)
                        ui_editor('newdata')
                     else
                        messagebox('init', ...
                           char(['Could not merge the data in ''',fn,''''],['(Error: ',msg,')']), ...
                           [], ...
                           'Error', ...
                           [.95 .95 .95]);
                     end
                  end

               else
                  messagebox('init', ...
                     char('Could not perform the operation because the edited structure failed validation', ...
                     ['(Error: ',msg,')']), ...
                     [], ...
                     'Error', ...
                     [.95 .95 .95]);
               end

            else  %no data set specified or invalid data type

               if isempty(strfind(op,'_open'))  %file-based integration failure
                  if ~isempty(fn)
                     messagebox('init', ...
                        'No valid data structures were found or none was selected - operation cancelled', ...
                        [], ...
                        'Error', ...
                        [.95 .95 .95]);
                  end
               else  %no active data set specified
                  messagebox('init', ...
                     'No other data structures are open or none was selected - operation cancelled', ...
                     [], ...
                     'Info', ...
                     [.95 .95 .95]);
               end

            end

            set(gcf,'pointer','arrow')
            drawnow

         elseif strcmp(op,'imp_emldata')  %fetch EML data
            
            h_cb = findobj(h_fig,'Tag','mnuFetchEMLData');            
            ui_fetch_eml_data('init',h_cb,'ui_editor(''imp_emldata2'',cachedata)')
            
         elseif strcmp(op,'imp_emldata2')  %process fetched EML data
            
            %get url from ui_text_prompt
            h_cb = findobj(h_fig,'Tag','mnuFetchEMLData');
            urlinfo = get(h_cb,'userdata');
            cachedata = argument;  %get cachedata option from function call
            if isempty(cachedata)
               cachedata = 0;
            end            
            set(h_cb,'userdata','')  %clear userdata

            %check for cancel
            if iscell(urlinfo)
               
               %extract url, username, password
               url = urlinfo{1};
               username = urlinfo{2};
               password = urlinfo{3};
               
               %extract entity option
               if length(urlinfo) >= 4
                  entityopt = urlinfo{4};
               else
                  entityopt = 'all';
               end
               
               %get entities
               if strcmpi('selected',entityopt)
                  [entities,entitydesc] = fetch_eml_entities(url,[gce_homepath,filesep,'search_webcache'], ...
                     'EMLdatasetEntities.xsl',username,password);
                  if length(entities) > 1
                     if ~isempty(entitydesc) && length(entitydesc) == length(entities)
                        str = concatcellcols([entities,entitydesc],' -- ');
                     else
                        str = entities;
                     end
                     Isel = listdialog('name','Select Entities', ...
                        'promptstring','Select EML dataTable entities to load', ...
                        'selectionmode','multiple', ...
                        'liststring',str, ...
                        'listsize',[0 0 750 250]);
                     if ~isempty(Isel)
                        entities = entities(Isel);
                     else
                        return
                     end
                  end
               else
                  entities = [];
               end
               
               %set focus to editor window
               figure(h_fig)
               set(h_fig,'pointer','watch'); drawnow

               %fetch eml data
               [s_raw,msg] = fetch_eml_data(url,[gce_homepath,filesep,'search_webcache'], ...
                  'EMLdataset2mfile.xsl',cachedata,username,password,entities);
               
               %check for return data - convert to Data Structure(s)
               if isempty(msg)
                  [s2,msg] = eml2gce(s_raw);
               else
                  s2 = [];
               end
               
               set(h_fig,'pointer','arrow'); drawnow
               
               %check for valid return data
               if ~isempty(s2)
                  
                  %cache prior structure for undo
                  s_old = s;
                  if ~isempty(s_old)
                     set(uih.mnuUndo,'UserData',s_old)
                  else  %no cache - cache new structure
                     set(uih.mnuUndo,'UserData',s2{1})
                  end
                  
                  %cache new data for refreshing dialog
                  set(uih.listVars,'Value',1,'ListboxTop',1,'UserData',s2{1})
                  set(h_fig,'Name','Data Structure Editor')  %reset window name
                  
                  %update dialog with new data
                  ui_editor('newdata')
                  
                  %open additional data structures in new editor windows
                  if length(s2) > 1
                     for cnt = 2:length(s2)
                        ui_editor('init',s2{cnt})
                     end
                  end
                  
               else  %error
                  
                  if isempty(msg)
                     msg = 'The EML document specified was invalid or not available online';
                  else
                     if size(msg,1) == 1
                        msg = ['An error occurred parsing the data: ',msg];
                     else
                        msg = char('An error occurred parsing the data: ',msg);
                     end
                  end                     
                  messagebox('init',msg,'','Error',[0.9 0.9 0.9])
                  
               end
               
            end
            
         elseif strcmp(op,'imp_ascii_cust')  %use filtered ASCII import dialog

            ui_importfilter('init','','',findobj(h_fig,'Tag','mnuImpAsciiCust'),'ui_editor(''imp_ascii_cust2'')');

         elseif strcmp(op,'imp_ascii_cust2') || strcmp(op,'imp_fetchusgs') || ...
               strcmp(op,'imp_fetchclimdb') || strcmp(op,'imp_ncdc') || strcmp(op,'imp_dataturbine')

            %process external GUI import dialog results
            if strcmp(op,'imp_ascii_cust2')
               h_data = findobj(h_fig,'Tag','mnuImpAsciiCust');
            elseif strcmp(op,'imp_fetchusgs')
               h_data = findobj(h_fig,'Tag','mnuHarvestUSGS');
            elseif strcmp(op,'imp_ncdc')
               h_data = findobj(h_fig,'Tag','mnuHarvestNCDC');
            elseif strcmp(op,'imp_dataturbine')
               h_data = findobj(h_fig,'Tag','mnuHarvestDT');
            else
               h_data = findobj(h_fig,'Tag','mnuHarvestClimdb');
            end
            
            %get data from external dialog and clear cache
            s2 = get(h_data,'UserData');
            set(h_data,'UserData',[])

            if gce_valid(s2,'data')

               s_old = s;
               if ~isempty(s_old)  %cache prior structure
                  set(uih.mnuUndo,'UserData',s_old)
               else  %no cache - cache new structure
                  set(uih.mnuUndo,'UserData',s2)
               end
               set(uih.listVars,'Value',1,'ListboxTop',1,'UserData',s2)  %cache new data
               set(h_fig,'Name','Data Structure Editor')  %reset window name

               ui_editor('newdata')

            else
               messagebox('init','No data was returned from the import dialog','','Error',[.95 .95 .95])
            end

         else  %use external filters

            %init optional arguments
            arglist = [];
            numargs = 0;

            %populate arguments based on function
            switch op
               
               case 'imp_ascii'
                  filemask = '*.txt;*.csv;*.dat;*.asc;*.ans;*.prn';
                  fileprompt = 'Select an ASCII data file to import';
                  fnc = 'imp_ascii';
                  
               case 'imp_matlab'
                  filemask = '*.mat;*.MAT';
                  fileprompt = 'Select a MATLAB data file to import';
                  fnc = 'imp_matlab';
                  
               case 'imp_matlab_struct'
                  filemask = '*.mat;*.MAT';
                  fileprompt = 'Select a MATLAB data file to import';
                  fnc = 'imp_struct';                 
                  
               case 'imp_matlab_vars'
                  
                  filemask = 'workspace';
                  fileprompt = '';

                  if strcmp(argument,'struct')
                     fnc = 'imp_struct';
                  else
                     fnc = 'imp_matlab';
                  end
                  
               case 'imp_filter'
                  
                  filemask = '';
                  fileprompt = '';
                  fnc = '';
                  
                  %load import filter info from imp_filters.mat database
                  impfilt = get_importfilters;
                  
                  if isstruct(impfilt)
                     
                     %initialize argument list based on fields in imp_filters, skipping first 5 metadata fields
                     arglist = cell(1,length(impfilt.name)-5);
                     
                     %parse entry information from callback argument
                     if isempty(strfind(argument,'_'))
                        lbl = argument;
                        subhead = '';
                     else
                        [lbl,rem] = strtok(argument,'_');
                        subhead = rem(2:end);
                     end
                     
                     %look up filter entry in database
                     lbls = extract(impfilt,'Label');
                     if isempty(subhead)
                        I = find(strcmp(lbls,lbl));
                     else
                        subheads = extract(impfilt,'Subheading');
                        I = find(strcmp(lbls,lbl) & strcmp(subheads,subhead));
                     end
                     
                     %check for filter match
                     if ~isempty(I)
                        
                        %force single match
                        I = I(1);
                        
                        %extract filemask
                        masks = extract(impfilt,'Filemask');
                        if length(masks) >= I; filemask = masks{I}; end
                        
                        %extract file prompt
                        prompts = extract(impfilt,'Fileprompt');
                        if length(prompts) >= I; fileprompt = prompts{I}; end
                        
                        %extract function name
                        fncs = extract(impfilt,'Mfile');
                        if length(fncs) >= I; fnc = fncs{I}; end
                        
                        %extract arguments, check for numeric or cell array and convert
                        for n = 1:length(arglist)
                           args = extract(impfilt,['Argument',int2str(n)]);
                           if length(args) >= I
                              arg = args{I};
                              if ~isempty(arg)
                                 if ~isnan(str2double(arg))
                                    arg = str2double(arg);
                                 elseif ~isempty(str2num(arg))
                                    arg = str2num(arg);
                                 elseif ~isempty(strfind(arg,'{'))
                                    try
                                       ar = eval(arg);
                                    catch
                                       ar = [];
                                    end
                                    if iscell(ar)
                                       arg = ar;
                                    end
                                 elseif length(arg)>=2 && strcmp(arg(1),'''') && strcmp(arg(end),'''')
                                    %strip off leading/trailing apostrophes around numbers
                                    arg = arg(2:end-1);
                                 end
                              end
                              arglist{n} = arg;
                           end
                        end
                        
                        %calculate number of arguments based on last non-empty entry in arglist
                        Iargs = find(~cellfun('isempty',arglist));
                        if ~isempty(Iargs)
                           numargs = max(Iargs);
                        end
                        
                     end
                     
                  end
                  
               otherwise
                  filemask = '';
            end
           
            %check for valid filemask indicated matched function
            if ~isempty(filemask)
               if strcmpi(filemask,'workspace')
                  fn = 'workspace';  %set imp_matlab fn as 'workspace'
                  pn = '';
               elseif strcmpi(filemask,'www')
                  fn = 'www';  %set www as filename to support filters that retrieve data via url
                  pn = '';
               else  %prompt for file
                  pn = get(uih.mnuLoad,'UserData');
                  cd(pn)
                  [fn,pn] = uigetfile(filemask,fileprompt);
                  cd(curpath)
                  if pn ~= 0
                     syncpath(pn,'load')  %cache path
                  end
                  drawnow
               end
            else
               fn = 0;
            end

            %check for parsed filemask
            if ischar(fn)

               set(gcf,'pointer','watch')
               drawnow

               %execute function call with up to 10 specified arguments, trapping errors
               try
                  if strcmp(fn,'www')
                     %eval without fn and pn arguments
                     if numargs == 0
                        [s2,msg] = feval(fnc);
                     elseif numargs == 1
                        [s2,msg] = feval(fnc,arglist{1});
                     elseif numargs == 2
                        [s2,msg] = feval(fnc,arglist{1},arglist{2});
                     elseif numargs == 3
                        [s2,msg] = feval(fnc,arglist{1},arglist{2},arglist{3});
                     elseif numargs == 4
                        [s2,msg] = feval(fnc,arglist{1},arglist{2},arglist{3},arglist{4});
                     elseif numargs == 5
                        [s2,msg] = feval(fnc,arglist{1},arglist{2},arglist{3},arglist{4},arglist{5});                        
                     elseif numargs == 6
                        [s2,msg] = feval(fnc,arglist{1},arglist{2},arglist{3},arglist{4},arglist{5},arglist{6});                        
                     elseif numargs == 7
                        [s2,msg] = feval(fnc,arglist{1},arglist{2},arglist{3},arglist{4},arglist{5},arglist{6},arglist{7});                        
                     elseif numargs == 8
                        [s2,msg] = feval(fnc,arglist{1},arglist{2},arglist{3},arglist{4},arglist{5},arglist{6},arglist{7},arglist{8});                        
                     elseif numargs == 9
                        [s2,msg] = feval(fnc,arglist{1},arglist{2},arglist{3},arglist{4},arglist{5},arglist{6},arglist{7},arglist{8},arglist{9});                        
                     else  %10 arguments
                        [s2,msg] = feval(fnc,arglist{1},arglist{2},arglist{3},arglist{4},arglist{5},arglist{6},arglist{7},arglist{8},arglist{9},arglist{10});                        
                     end
                  else  %file-based
                     if numargs == 0
                        [s2,msg] = feval(fnc,fn,pn);
                     elseif numargs == 1
                        [s2,msg] = feval(fnc,fn,pn,arglist{1});
                     elseif numargs == 2
                        [s2,msg] = feval(fnc,fn,pn,arglist{1},arglist{2});
                     elseif numargs == 3
                        [s2,msg] = feval(fnc,fn,pn,arglist{1},arglist{2},arglist{3});
                     elseif numargs == 4
                        [s2,msg] = feval(fnc,fn,pn,arglist{1},arglist{2},arglist{3},arglist{4});
                     elseif numargs == 5
                        [s2,msg] = feval(fnc,fn,pn,arglist{1},arglist{2},arglist{3},arglist{4},arglist{5});                        
                     elseif numargs == 6
                        [s2,msg] = feval(fnc,fn,pn,arglist{1},arglist{2},arglist{3},arglist{4},arglist{5},arglist{6});                        
                     elseif numargs == 7
                        [s2,msg] = feval(fnc,fn,pn,arglist{1},arglist{2},arglist{3},arglist{4},arglist{5},arglist{6},arglist{7});                        
                     elseif numargs == 8
                        [s2,msg] = feval(fnc,fn,pn,arglist{1},arglist{2},arglist{3},arglist{4},arglist{5},arglist{6},arglist{7},arglist{8});                        
                     elseif numargs == 9
                        [s2,msg] = feval(fnc,fn,pn,arglist{1},arglist{2},arglist{3},arglist{4},arglist{5},arglist{6},arglist{7},arglist{8},arglist{9});                        
                     else  %10 arguments
                        [s2,msg] = feval(fnc,fn,pn,arglist{1},arglist{2},arglist{3},arglist{4},arglist{5},arglist{6},arglist{7},arglist{8},arglist{9},arglist{10});                        
                     end
                  end
               catch
                  s2 = [];
                  if exist(fnc,'file') == 2
                     msg = ['the import filter ''',fnc,''' returned an error - use Misc > Add/Edit Import Filters to review input arguments'];
                  else
                     msg = ['the import filter ''',fnc,''' was not found in the MATLAB path - use Misc > Add/Edit Import Filters to review MFile name'];
                  end
               end

               set(gcf,'pointer','arrow')
               drawnow

               if ~isempty(s2) && gce_valid(s2)  %incorporate data

                  s_old = s;
                  if ~isempty(s_old)  %cache prior structure
                     set(uih.mnuUndo,'UserData',s_old)
                  else  %no cache - cache new structure
                     set(uih.mnuUndo,'UserData',s2)
                  end
                  set(uih.listVars,'Value',1,'ListboxTop',1,'UserData',s2)  %cache new data
                  set(uih.mnuFile,'UserData',fn)  %cache filename
                  set(h_fig,'Name','Data Structure Editor')  %reset window name

                  ui_editor('newdata')

                  if ~isempty(msg)
                     messagebox('init',msg,[],'Message',[.95 .95 .95]);
                     drawnow
                  end

               else  %bad file or filter

                  if ischar(s2)
                     msg2 = s2;  %catch filters that return a string as first argument
                  elseif ~strcmpi(fn,'workspace') && ~strcmpi(fn,'www')
                     msg2 = char(['Could not import the file ''',fn,''''],['(Error: ',msg,')']);
                  else
                     if strcmpi(fn,'workspace')
                        msg2 = char('Could not import variables from the MATLAB workspace',['(Error: ',msg,')']);
                     else
                        msg2 = char('Could not import remote data using the specified filter',['(Error: ',msg,')']);
                     end
                  end
                  messagebox('init',msg2,[],'Message',[.95 .95 .95]);
                  drawnow

               end

            end

         end
         
      elseif strcmp(op(1,1:3),'exp')  %check for export filter calls

         pn = get(uih.mnuSave,'UserData');
         msg = '';  %initialize error message str

         %process structure edits unless matlab mat or struct export (i.e. prompt for file and variable name only on first pass)
         if ~strcmp(op,'exp_matlab_mat') && ~strcmp(op,'exp_matlab_struct')
            s = get(uih.listVars,'UserData');
            flag = get(uih.editCrit,'UserData');
            [data,msg] = subfun_dsupdate(s,d,colptrs,flag);
         else
            data = 1;  %init dummy data variable for validation test for first pass when exporting mat or struct to prevent redundant processing
         end

         if isempty(msg)

            if ~isempty(data)

               switch op
                  
                  case 'exp_ascii'  %open ASCII export dialog
                     
                     ui_exportasc('init',data,pn);
                     
                  case 'exp_climdb'  %open ClimDB export dialog
                     
                     ui_expclimdb('init',data);
                     
                  case 'exp_eml'  %open EML export dialog
                     
                     ui_export_eml('init',data);
                     
                  case {'exp_header','exp_header_data','exp_header_flags','exp_header_manual'}  %text import header
                     
                     %get cached save path
                     pn = getpath('save');  
                     
                     %prompt for file
                     curpath = pwd;
                     cd(pn) 
                     [fn,pn] = uiputfile('*.txt','Select a name and location for the file');  %prompt for file
                     cd(curpath)
                     drawnow
                     
                     %check for cancel
                     if ischar(fn)
                        
                        %generate file with default options
                        set(h_fig,'Pointer','watch'); drawnow
                        if strcmp(op,'exp_header_data')  %header with data
                           msg = exp_header(data,fn,pn,1,0);
                        elseif strcmp(op,'exp_header_flags')  %header with data and all flags
                           msg = exp_header(data,fn,pn,1,1);
                        elseif strcmp(op,'exp_header_manual')  %header with data and manual flags
                           msg = exp_header(data,fn,pn,1,2);
                        else  %header only
                           msg = exp_header(data,fn,pn,0,0);
                        end
                        if isempty(msg)
                           msg = 'an error occurred generating the text import header file';
                        end
                        set(h_fig,'Pointer','arrow'); drawnow
                        
                        %update cached path
                        syncpath(pn,'save')
                        
                     end
                     
                  case {'exp_html','exp_xml','exp_kml'}  %html/xml
                     
                     %get cached save path
                     pn = getpath('save');  
                     
                     %base new filename on cached loaded/imported filename
                     lastfn = get(uih.mnuFile,'UserData');
                     basefn = '';
                     if ~strcmpi(lastfn,'www') && ~isempty(lastfn)
                        [tmp,basefn] = fileparts(lastfn);
                     end
                     
                     %generate filespec
                     if strcmp(op,'exp_html')
                        if isempty(basefn)
                           filespec = '*.htm;*.html';
                        else
                           filespec = [basefn,'.html'];
                        end
                     elseif strcmp(op,'exp_kml')
                        if isempty(basefn)
                           filespec = '*.kml';
                        else
                           filespec = [basefn,'.kml'];
                        end
                     else
                        if isempty(basefn)
                           filespec = '*.xml';
                        else
                           filespec = [basefn,'.xml'];
                        end
                     end
                     
                     %prompt for file
                     curpath = pwd;
                     cd(pn) 
                     [fn,pn] = uiputfile(filespec,'Select a name and location for the file');  %prompt for file
                     cd(curpath)
                     drawnow
                     
                     %check for cancel
                     if ischar(fn)
                        
                        %generate file with default options
                        set(h_fig,'Pointer','watch'); drawnow
                        if strcmp(op,'exp_html')  %html
                           [str,msg] = gceds2html(data,[],[],argument,'data-table',1,'',[pn,filesep,fn]);
                        elseif strcmp(op,'exp_kml')  %google earth kml
                           str = 'kml';  %set dummy string for error check
                           msg = gceds2kml(data,[pn,filesep,fn]);
                        else  %xml
                           [str,msg] = gceds2xml(data,[],[],'',[pn,filesep,fn]);
                        end
                        if isempty(str) && isempty(msg)
                           msg = 'an error occurrect generating the KML, HTML or XML file';
                        end
                        set(h_fig,'Pointer','arrow'); drawnow
                        
                        %update cached path
                        syncpath(pn,'save')
                        
                     end
                     
                  case 'exp_matlab_vars'  %export variables
                     
                     set(gcf,'pointer','watch')
                     msg = exp_matlab(data,'',pn,'vars',argument,'E','alldata');
                     set(gcf,'pointer','arrow')
                     drawnow
                     
                  case {'exp_matlab_mat','exp_matlab_struct'}  %prompt for variable name for mat or struct export
                                          
                     %get cached save path
                     pn = getpath('save');  
                     
                     %prompt for file
                     curpath = pwd;
                     cd(pn) 
                     [fn,pn] = uiputfile('*.mat','Select a name and location for the file');  %prompt for file
                     cd(curpath)
                     drawnow
                     
                     %check for cancel
                     if ischar(fn)
                        if exist([pn,filesep,fn],'file') == 2
                           try
                              vars = load([pn,filesep,fn],'-mat');
                              varlist = fieldnames(vars);
                           catch
                              varlist = 'data';
                           end
                        else
                           varlist = 'data';
                        end
                        ui_text_prompt('init',uih.mnuExpMat,['ui_editor(''',op,'2'',{''',fn,''',''',pn,''',''',argument,'''})'], ...
                            varlist,'Variable Name','Variable Name',400)
                     end
                     
                  case {'exp_matlab_mat2','exp_matlab_struct2'}  %process mat or struct export
                     
                     %get cached info from menu handle and function argument
                     cachedata = argument;
                     varname = get(uih.mnuExpMat,'UserData');
                     set(uih.mnuExpMat,'UserData',[])
                     
                     if ~isempty(varname) && iscell(cachedata) && length(cachedata) >= 3
                        
                        %determine format from operation
                        if strcmp(op,'exp_matlab_mat2')
                           fmt = 'mat';
                           flagopt = 'E';
                        else
                           fmt = 'struct';
                           flagopt = 'S';
                        end
                        
                        %get cached file, path, variable names
                        fn = cachedata{1};
                        pn = cachedata{2};
                        metastyle = cachedata{3};                        
                     
                        %export data
                        set(gcf,'pointer','watch')
                        msg = exp_matlab(data,fn,pn,fmt,metastyle,flagopt,'alldata',varname);
                        set(gcf,'pointer','arrow')
                        drawnow
                     
                     end
                     
                  otherwise
                     msg = 'invalid export filter specified';
                     
               end

               %report filter-generated error or info messages
               if ~isempty(msg)
                  if ~strcmp(op,'exp_metabase') && ~strncmp(op,'exp_header',10)
                     msg = char(['Could not create the export file (error: ',msg,')']);
                     titlestr = 'Error';
                  else
                     titlestr = 'Information';
                  end
                  messagebox('init',msg,[],titlestr,[.95 .95 .95]);
               end

            end

         else  %edited structure failed validation

            %report filter-generated error messages
            if ~isempty(msg)
               messagebox('init', ...
                  char('Could not create the export file because the edited structure failed validation', ...
                  ['(Error: ',msg,')']), ...
                  [], ...
                  'Error', ...
                  [.95 .95 .95]);
            end

         end
         
      elseif strcmp(op,'template')  %process metadata template calls
         
         template = lookup_template;  %select template using external function
         
         %check for cancel
         if ~isempty(template)
            
            metaopt = argument;  %get doc metadata import option from argument
            
            %apply edits before evaluating template
            flag = get(uih.editCrit,'UserData');
            [data,msg] = subfun_dsupdate(s,d,colptrs,flag);
               
            if ~isempty(data) && isempty(msg)  %check for validation problems
               
               set(h_fig,'Pointer','watch'); drawnow
   
               [data2,msg] = apply_template(data,template,metaopt,0);
               
               set(h_fig,'Pointer','arrow'); drawnow

               if ~isempty(data2)
                  
                  set(uih.mnuUndo,'UserData',s)  %cache undo data
                  set(uih.listVars,'UserData',data2)  %cache new structure
                  set(uih.mnuQuit','UserData',1)  %set dirty flag
                  ui_editor('newdata');
                  
               end
               
            end
            
            if ~isempty(msg)
               messagebox('init',msg,[],'Warning',[0.95 0.95 0.95])
            end
            
         end

      else  %process editor callbacks

         switch op

            case 'quit'  %conditional quit routine

               try
                  flag = get(uih.mnuQuit,'UserData');
               catch
                  flag = 0;
               end

               if flag == 0
                  ui_editor('exit');
               else
                  confirmdlg('init','Close the Editor Window? (changes will be lost)','ui_editor(''exit'')');
               end

            case 'exit'  %close the figure unconditionally

               if ~isempty(h_fig)
                  delete(h_fig)
                  if length(findobj) == 1  %check for other open windows - launch startup dialog if none
                     ui_aboutgce('reopen');
                  end
               end
               
            case 'closewindow'  %confirm handle window close events
               
               if strcmp(argument,'other')
                  h_all = findobj('Tag','dlgDSEditor');
                  if length(h_all) > 1
                     str = 'Close all other open editor windows? (changes will be lost)';
                  else
                     str = '';
                  end
               else
                  str = 'Close all open editor windows? (changes will be lost)';
               end
               
               %check for skip if only one window open
               if ~isempty(str)
                  confirmdlg('init',str,['ui_editor(''closewindow2'',''',argument,''')'])
               end
               
            case 'closewindow2'  %perform window close events
               
               %get array of figure handles
               h_current = gcf;
               h_all = findobj('Tag','dlgDSEditor');
               
               %set array of handles based on argument
               if strcmp(argument,'other')
                  h = setdiff(h_all,h_current);
               else
                  h = h_all;
               end
               
               %close all specified windows without save prompting
               delete(h);
               
               %check for other open windows - launch startup dialog if none
               if length(findobj) == 1
                  ui_aboutgce('reopen');
               end

            case 'return'  %return data to other tool that called ui_editor in client mode (e.g. ui_joindata)

               h = findobj(h_fig,'Tag','mnuReturnData');  %get handle of menu object

               if ~isempty(h)

                  ud = get(h,'UserData');  %get cached callback info

                  %apply pending edits to data
                  flag = get(uih.editCrit,'UserData');
                  data = subfun_dsupdate(s,d,colptrs,flag);

                  if ~isempty(data)

                     h_parent = parent_figure(ud.h_cb);  %get parent figure of callback object

                     if ~isempty(h_parent)
                        figure(h_parent)  %set focus
                        if ~isempty(ud.h_cb)
                           set(ud.h_cb,'UserData',data)  %cache data set in callback figure
                        end
                        err = 0;
                        try
                           eval(ud.cb)  %evaluate cached callback statement
                        catch
                           err=1;
                        end
                        if err == 0
                           %shut down editor instance
                           figure(h_fig)
                           ui_editor('exit')
                           figure(h_parent)
                        else
                           messagebox('init','Errors occurred returning data to the calling program','','Error',[.95 .95 .95])
                        end
                     else
                        messagebox('init','Errors occurred returning data to the calling program','','Error',[.95 .95 .95])
                     end

                  else
                     %check for template editing
                     if strfind(ud.cb,'ui_template') > 0
                        messagebox('init','Could not return template - valid Data Types, Variable Types and Numerical Types are required','','Error',[.95 .95 .95])                        
                     else
                        messagebox('init','Could not return empty data structure to the calling program','','Error',[.95 .95 .95])
                     end
                  end

               end

            case 'senddata'  %send active data set to calling non-gui function (using secondary argument as callback which must reference 'data')

               if ~isempty(argument)

                  %check for data return argument in callback text
                  if ~isempty(strfind(argument,'data'))

                     flag = get(uih.editCrit,'UserData');
                     [data,msg] = subfun_dsupdate(s,d,colptrs,flag);

                     err = 0;
                     try
                        eval(argument)  %execute callback, even if dataset empty
                     catch
                        err = 1;
                     end

                     if err == 1
                        messagebox('init','An error occurred returning data to an external program','','Error',[.95 .95 .95])
                     end

                  end

               end

            case 'revert'  %revert to cached data

               s = get(uih.mnuUndo,'UserData');

               if ~isempty(s)
                  set(uih.listVars,'Value',1,'ListboxTop',1,'UserData',s)
                  ui_editor('newdata')
               end

            case 'newdata'  %process data structure, fill in uicontrols

               s = get(uih.listVars,'UserData');

               if ~isempty(s)

                  numcols = length(s.name);
                  rownum = rownum(1);  %use first row in multi-row selections for comparison
                  oldcolname = get(uih.editVarname,'String');

                  if ~isempty(s.units{1})
                     str = [s.name{1},'  (',s.units{1},')'];
                  else
                     str = s.name{1};
                  end
                  for n = 2:numcols
                     if ~isempty(s.units{n})
                        str = char(str,[s.name{n},'  (',s.units{n},')']);
                     else
                        str = char(str,s.name{n});
                     end
                  end

                  %determine new list selection, top position
                  if rownum <= length(s.name) && ~isempty(oldcolname)
                     if strcmp(s.name{rownum},oldcolname)
                        newrownum = rownum;
                     else
                        Icol = find(strcmp(s.name,oldcolname));
                        if length(Icol) == 1
                           newrownum = Icol;
                        else
                           newrownum = 1;
                        end
                     end
                  elseif rownum >= length(s.name)
                     newrownum = 1;
                  else
                     newrownum = rownum;
                  end

                  if newrownum > 1
                     listboxtop = get(uih.listVars,'ListBoxTop');
                     if listboxtop > length(s.name)
                        listboxtop = 1;
                     end
                  else
                     listboxtop = 1;
                  end

                  set(uih.listVars, ...
                     'String',cellstr(str), ...
                     'Value',newrownum, ...
                     'ListBoxTop',listboxtop)  %fill list control

                  set(uih.cmdMoveFirst,'UserData',(1:numcols)')  %store column order pointer array

                  %store copies of descriptors in a structure for editing
                  d = struct( ...
                     'metadata',[], ...
                     'title',s.title, ...
                     'name',{s.name}, ...
                     'description',{s.description}, ...
                     'units',{s.units}, ...
                     'datatype',{s.datatype}, ...
                     'variabletype',{s.variabletype}, ...
                     'numbertype',{s.numbertype}, ...
                     'precision',[s.precision], ...
                     'criteria',{s.criteria});

                  set(uih.editVarname,'UserData',d)

               else  %clear controls for new structure

                  set(uih.listVars,'String','','Value',1)
                  set(uih.cmdMoveFirst,'UserData',[])
                  set(uih.editVarname,'UserData',[])

               end

               %clear update flags
               set(uih.mnuQuit,'UserData',0)
               set(uih.editCrit,'UserData',0)

               ui_editor('rename2','title')

               %controls
               ui_editor('display');

            case 'refresh'  %refreshes the list to reflect editbox changes

               numcols = length(colptrs);

               if ~isempty(d.units{colptrs(1)})
                  str = [d.name{colptrs(1)},'  (',d.units{colptrs(1)},')'];
               else
                  str = d.name{colptrs(1)};
               end
               for n = 2:numcols
                  if ~isempty(d.units{colptrs(n)})
                     str = char(str,[d.name{colptrs(n)},'  (',d.units{colptrs(n)},')']);
                  else
                     str = char(str,d.name{colptrs(n)});
                  end
               end

               %fill list control
               set(uih.listVars, ...
                  'String',cellstr(str), ...
                  'Value',rownum, ...
                  'ListboxTop',get(uih.listVars,'ListboxTop'))
               
               %call control refresh to pick up unit changes and enable/disable convert button
               ui_editor('controls')

            case 'display'  %update edit fields, popups

               %init code list edit button visibility
               codevis = 'off';

               %check for single or multiple selection mode
               if length(ptr) == 1

                  d = get(uih.editVarname,'UserData');

                  %get cell arrays for popup menus
                  datalist = get(uih.popDatatype,'UserData');
                  varlist = get(uih.popVartype,'UserData');
                  numlist = get(uih.popNumtype,'UserData');

                  if ~isempty(d)

                     %get index for matching strings
                     dataval = find(strcmp(datalist,d.datatype{ptr}));
                     if isempty(dataval); dataval = length(datalist); end

                     varval = find(strcmp(varlist,d.variabletype{ptr}));
                     if isempty(varval); varval = length(varlist); end

                     numval = find(strcmp(numlist,d.numbertype{ptr}));
                     if isempty(numval); numval = length(numlist); end

                     %fill uicontrols
                     set(uih.editVarname,'String',d.name{ptr});
                     set(uih.editDesc,'String',d.description{ptr});
                     set(uih.editUnits,'String',d.units{ptr});
                     set(uih.editPrec,'String',int2str(d.precision(ptr)));
                     set(uih.editCrit,'String',d.criteria{ptr});
                     set(uih.popDatatype,'Value',dataval)
                     set(uih.popVartype,'Value',varval)
                     set(uih.popNumtype,'Value',numval)

                     %override numeric type for strings
                     if strcmp(d.datatype{ptr},'s')
                        set(uih.popNumtype,'Value',find(strcmp(numlist,'none')))
                     end

                     %toggle code list edit button visibility
                     if strcmp(varlist{varval},'code')
                        codevis = 'on';
                     end

                  else  %empty structure

                     set(uih.editVarname,'String','');
                     set(uih.editDesc,'String','');
                     set(uih.editUnits,'String','');
                     set(uih.editPrec,'String',0);
                     set(uih.editCrit,'String','');
                     set(uih.popDatatype,'Value',length(datalist))
                     set(uih.popVartype,'Value',length(varlist))
                     set(uih.popNumtype,'Value',length(numlist))

                  end

               end

               %set visibility of code button
               set(uih.cmdEditCodes,'Visible',codevis)

               ui_editor('controls')

            case 'undo'

               s_old = get(uih.mnuUndo,'UserData');

               if ~isempty(s_old)
                  confirmdlg('init', ...
                     'Discard changes since last load/import or edit operation?', ...
                     'ui_editor(''revert'')')
               else
                  messagebox('init', ...
                     'Undo cancelled - no prior structure data to restore', ...
                     '', ...
                     'Information', ...
                     [.95 .95 .95]);
               end

            case 'movefirst'  %move selected column to the top of the list

               if rownum > 1  %skip proc if already at top

                  numrows = length(colptrs);

                  %adjust pointers
                  if rownum < numrows
                     newcolptrs = [rownum ; (1:rownum-1)' ; (rownum+1:numrows)'];
                  else  %bottom
                     newcolptrs = [rownum ; (1:rownum-1)'];
                  end

                  %update list and stored pointers
                  str = get(uih.listVars,'String');
                  set(uih.listVars,'String',str(newcolptrs),'Value',1)
                  set(uih.cmdMoveFirst,'UserData',colptrs(newcolptrs))
                  set(uih.mnuQuit,'UserData',1)

                  drawnow

               end

            case 'moveup'  %move selected column up in list

               if rownum > 1  %skip proc if already at top

                  numrows = length(colptrs);

                  %adjust pointers
                  if rownum < numrows
                     if rownum > 2
                        newcolptrs = [(1:rownum-2)'; rownum ; rownum - 1 ; (rownum+1:numrows)'];
                     else
                        newcolptrs = [2 ; 1 ; (3:numrows)'];
                     end
                  else  %bottom
                     newcolptrs = [(1:numrows-2)'; rownum ; rownum-1];
                  end

                  %update list and stored pointers
                  str = get(uih.listVars,'String');
                  set(uih.listVars,'String',str(newcolptrs),'Value',rownum-1)
                  set(uih.cmdMoveFirst,'UserData',colptrs(newcolptrs))
                  set(uih.mnuQuit,'UserData',1)

                  drawnow

               end

            case 'movedown'  %move selected column down in list

               numrows = length(colptrs);  %get number of columns in list

               if rownum < numrows  %skip proc if already at bottom

                  %adjust pointers
                  if rownum > 1  %test for top row
                     if rownum < numrows-1  %not penultimate row
                        newcolptrs = [ (1:rownum-1)' ; rownum+1 ; rownum ; (rownum+2:numrows)' ];
                     else  %penultimate row
                        newcolptrs = [ (1:rownum-1)' ; rownum+1 ; rownum ];
                     end
                  else  %top row
                     newcolptrs = [ 2 ; 1 ; (3:numrows)' ];
                  end

                  %update list and stored pointers
                  str = get(uih.listVars,'String');
                  set(uih.listVars,'String',str(newcolptrs),'Value',rownum+1)
                  set(uih.cmdMoveFirst,'UserData',colptrs(newcolptrs))
                  set(uih.mnuQuit,'UserData',1)

                  drawnow

               end

            case 'movelast'  %move selected column to bottom of list

               numrows = length(colptrs);  %get number of columns in list

               if rownum < numrows  %skip proc if already at bottom

                  %adjust pointers
                  if rownum > 1
                     newcolptrs = [ (1:rownum-1)' ; (rownum+1:numrows)'; rownum];
                  else  %top row
                     newcolptrs = [ (2:numrows)' ; 1 ];
                  end

                  %update list and stored pointers
                  str = get(uih.listVars,'String');
                  set(uih.listVars,'String',str(newcolptrs),'Value',numrows)
                  set(uih.cmdMoveFirst,'UserData',colptrs(newcolptrs))
                  set(uih.mnuQuit,'UserData',1)

                  drawnow

               end

            case 'delete'  %remove the selected rows

               if length(colptrs)-length(rownum) > 0  %check for minimum 1 residual column

                  %clear the pointer for the row and update the listbox
                  newcolptrs = (1:length(colptrs))';
                  newcolptrs = setdiff(newcolptrs,rownum');

                  %update list and stored pointers
                  str = get(uih.listVars,'String');
                  listtop = get(uih.listVars,'ListboxTop'); %get listbox top row
                  listtop = min(listtop,length(newcolptrs)); %calc listbox top row, accounting for new list size
                  set(uih.listVars,'String',str(newcolptrs),'Value',max(1,min(length(newcolptrs),min(rownum))),'ListboxTop',listtop)
                  set(uih.cmdMoveFirst,'UserData',colptrs(newcolptrs))
                  set(uih.mnuQuit,'UserData',1)  %update dirty flag

                  ui_editor('display')

               else

                  messagebox('init', ...
                     '  Data structures must contain at least one column - delete cancelled ', ...
                     '', ...
                     'Error', ...
                     [.95 .95 .95]);

               end

            case 'restore'  %restore all deleted variables used cached info

               numcols = length(s.name);

               if length(colptrs) < numcols  %check for deleted columns

                  %create index of missing pointers
                  allptrs = 1:numcols;
                  [allptrsmat,colptrsmat] = meshgrid(allptrs,colptrs);
                  if length(colptrs) > 1
                     I = find(sum(allptrsmat==colptrsmat)==0)';
                  else
                     I = find((allptrsmat==colptrsmat)==0)';
                  end

                  if ~isempty(I)

                     newcolptrs = sort([colptrs ; I]);  %create sorted list of all columns

                     set(uih.cmdMoveFirst,'UserData',newcolptrs)  %store column order pointer array

                     ui_editor('refresh')
                     ui_editor('display')

                  end

               end

            case 'unitconv'  %launch unit conversion dialog

               flag = get(uih.editCrit,'UserData');
               data = subfun_dsupdate(s,d,colptrs,flag);

               if ~isempty(data)  %call external tools
                  ui_unitconv('init',data,get(uih.listVars,'Value'),uih.cmdConvert,'ui_editor(''convert'')')
               end

            case 'convert'  %process unit conversions

               data2 = get(uih.cmdConvert,'UserData');

               if ~isempty(data2)
                  val = get(uih.listVars,'Value');
                  s = get(uih.listVars,'UserData');
                  if length(s.name) ~= length(data2.name)  %check for post-dialog invocation edits
                     val = 1;
                  end
                  set(uih.mnuUndo,'UserData',s)  %cache undo data
                  set(uih.listVars,'UserData',data2,'Value',val)
                  ui_editor('newdata')
                  set(uih.mnuQuit,'UserData',1)  %set dirty flag *after* update
                  set(uih.editCrit,'UserData',1)  %set reflag flag
                  ui_editor('display')
               end

            case 'controls'  %conditionally enable menus and controls

               %build arrays of uih handles for state toggling
               h_btns = [uih.cmdMoveFirst ; ...
                  uih.cmdMoveUp ; ...
                  uih.cmdMoveDown ; ...
                  uih.cmdMoveLast ; ...
                  uih.cmdHist ; ...
                  uih.cmdPreview ; ...
                  uih.cmdConvert ; ...
                  uih.cmdEditCrit ; ...
                  uih.cmdEditCodes ];

               h_editboxes = [uih.editVarname ; ...
                  uih.editDesc ; ...
                  uih.editUnits ; ...
                  uih.editPrec ; ...
                  uih.editCrit];

               h_popups = [uih.popDatatype ; ...
                  uih.popVartype ; ...
                  uih.popNumtype];

               h = struct2cell(uih);

               %check for active column pointer
               if length(ptr) == 1

                  if ~isempty(d)  %check for data

                     set(cat(1,h{:}),'Enable','on') %enable all menus and controls

                     if ~isempty(s.values{1})
                        set(uih.cmdAdd,'Enable','off')  %turn off add button if data in structure
                     else
                        set(uih.cmdAdd,'Enable','on')
                     end
                     
                     %turn off Convert button for string columns and invalid units
                     if strcmp(d.datatype{ptr},'s') || isempty(d.units{ptr}) || strcmpi(d.units{ptr},'none') || strcmpi(d.units{ptr},'unspecified')
                        set(uih.cmdConvert,'Enable','off') 
                     end                     

                  else

                     set(cat(1,h{:}),'Enable','off')
                     set(uih.cmdAdd,'Enable','on')
                     set(uih.mnuFile,'Enable','on')
                     set(uih.mnuLoad,'Enable','on')
                     set(uih.mnuQuit','Enable','on')

                     if ~isempty(get(uih.mnuUndo,'UserData'))
                        set(uih.mnuUndo,'Enable','on')
                     end

                  end

               else

                  set(h_btns,'Enable','off')
                  set(h_editboxes,'Enable','off','String','')

                  for n = 1:length(h_popups)
                     set(h_popups(n),'Enable','off','Value',length(get(h_popups(n),'UserData')))
                  end

               end

               %check for deleted columns, toggle restore button state
               if ~isempty(s)
                  if length(colptrs) < length(s.name);
                     set(uih.cmdRestore,'Enable','on')
                  else
                     set(uih.cmdRestore,'Enable','off')
                  end
               else
                  set(uih.cmdRestore,'Enable','off')
               end

               drawnow
               
            case 'addtemplate' %add a metadata template as an empty structure
               
               %check for structure as argument
               if ~isempty(argument)
                  
                  %buffer existing data
                  s_orig = s;
                  s = argument;
                  
                  %init empty structure
                  d = struct( ...
                     'metadata','', ...
                     'title','', ...
                     'name','', ...
                     'description','', ...
                     'units','', ...
                     'datatype','', ...
                     'variabletype','', ...
                     'numbertype','', ...
                     'precision','', ...
                     'criteria','');
                  
                  %populate structure
                  d.metadata = s.metadata;
                  d.title = s.title;
                  d.name = s.name;
                  d.description = s.description;
                  d.units = s.units;
                  d.datatype = s.datatype;
                  d.variabletype = s.variabletype;
                  d.numbertype = s.numbertype;
                  d.precision = s.precision;
                  d.criteria = s.criteria;
                  
                  %format variablelist
                  varlist = concatcellcols([d.name' repmat({'  ('},length(d.name),1) ...
                     d.units' repmat({')'},length(d.name),1)],'')';
                  
                  %update cached values
                  set(uih.editVarname,'UserData',d)
                  set(uih.listVars,'String',varlist,'Value',1,'UserData',s)
                  set(uih.cmdMoveFirst,'UserData',(1:length(s.name))')
                  
                  if isempty(s_orig)
                     set(uih.mnuUndo,'UserData',s)
                  else
                     set(uih.mnuUndo,'UserData',s_orig)
                  end
                  
                  %update figure name
                  set(h_fig,'Name','Template Attributes Editor')
                  
                  %update dialog labels and fields to reflect new functionality
                  set(uih.lblVarList,'String','Template Variable Name and Column Name List')
                  set(uih.lblColumnName,'String','Variable==Name')
                  pos = get(uih.editVarname,'Position');
                  set(uih.editVarname, ...
                     'Position',[pos(1)+15,pos(2),pos(3)-15,pos(4)], ...
                     'TooltipString','Template variable name to match and data set column name to assign')
                  pos = get(uih.editUnits,'Position');
                  set(uih.editUnits,'Position',[pos(1)+15,pos(2),pos(3)-15,pos(4)])

                  %get menu handles
                  h_mnuFile = findobj(h_fig,'Type','uimenu','Label','File');
                  h_mnuFileChildren = findobj(h_mnuFile,'Type','uimenu');
                  h_mnuEdit = findobj(h_fig,'Type','uimenu','Label','Edit');
                  h_mnuMeta = findobj(h_fig,'Type','uimenu','Label','Metadata');
                  h_mnuMetaChildren = findobj(h_mnuMeta,'Type','uimenu');
                  h_mnuTools = findobj(h_fig,'Type','uimenu','Label','Tools');
                  h_mnuMisc = findobj(h_fig,'Type','uimenu','Label','Misc');
                  
                  %disable unsupported menus
                  set(h_mnuFileChildren,'Visible','off')
                  set(h_mnuFile,'Visible','on')
                  set(h_mnuEdit,'Visible','off')
                  set(h_mnuMetaChildren,'Visible','off')
                  set(h_mnuMeta,'Visible','on')
                  set(h_mnuTools,'Visible','off')
                  set(h_mnuMisc,'Visible','off')
                  
                  %unlock supported menu options
                  set(findobj(h_mnuFile,'Label','Exit MATLAB'),'Visible','on')
                  set(findobj(h_mnuEdit,'Label','Undo Changes'),'Visible','on')
                  h_return = findobj(h_mnuFile,'Label','Return Data');
                  if ~isempty(h_return); set(h_return,'Visible','on'); end
                  h_edit = findobj(h_mnuMeta,'Label','View/Edit Metadata');
                  if ~isempty(h_edit); set(h_edit,'Visible','on'); end
                  h_flagdef = findobj(h_mnuMeta,'Label','Add/Update Q/C Flag Definitions, Data Anomalies');
                  if ~isempty(h_flagdef); set(h_flagdef,'Visible','on'); end
                  
                  %disable or hide unsupported buttons, adjust field sizes
                  set(uih.cmdQAQC,'ForegroundColor',[0.7 0.7 0.7],'Callback','','TooltipString','Not supported for templates')
                  set(uih.cmdHist,'ForegroundColor',[0.7 0.7 0.7],'Callback','','TooltipString','Not supported for templates')
                  set(uih.cmdPreview,'ForegroundColor',[0.7 0.7 0.7],'Callback','','TooltipString','Not supported for templates')
                  set(uih.cmdConvert,'Visible','off','Callback','')
                  pos = get(uih.editUnits,'Position');
                  set(uih.editUnits,'Position',[pos(1) pos(2) pos(3)+65 pos(4)])
                  
                  ui_editor('display')

               end
               
            case 'addcol'  %add new column to empty data structure

               s_orig = s;
               s = newstruct;

               if isempty(d)

                  d = struct( ...
                     'metadata',[], ...
                     'title','New data structure template', ...
                     'name',[], ...
                     'description',[], ...
                     'units',[], ...
                     'datatype',[], ...
                     'variabletype',[], ...
                     'numbertype',[], ...
                     'precision',0, ...
                     'criteria',[]);

                  d.name = {'Column1'};
                  d.description = {'unspecified'};
                  d.units = {'unspecified'};
                  d.datatype = {'u'};
                  d.variabletype = {'unspecified'};
                  d.numbertype = {'unspecified'};
                  d.criteria = {''};

                  s.metadata = [];
                  s.name = d.name;
                  s.description = d.description;
                  s.units = d.units;
                  s.datatype = d.datatype;
                  s.variabletype = d.variabletype;
                  s.numbertype = d.numbertype;
                  s.precision = d.precision;
                  s.criteria = d.criteria;

                  varlist = {'Column1  (unspecified)'};
                  colptrs = 1;

               else  %add column to existing structure

                  d.name = [d.name,{['Column',int2str(length(d.name)+1)]}];
                  d.description = [d.description,{'unspecified'}];
                  d.units = [d.units,{'unspecified'}];
                  d.datatype = [d.datatype,{'u'}];
                  d.variabletype = [d.variabletype,{'unspecified'}];
                  d.numbertype = [d.numbertype,{'unspecified'}];
                  d.precision = [d.precision,0];
                  d.criteria = [d.criteria,{''}];

                  s.metadata = d.metadata;
                  s.name = d.name;
                  s.description = d.description;
                  s.units = d.units;
                  s.datatype = d.datatype;
                  s.variabletype = d.variabletype;
                  s.numbertype = d.numbertype;
                  s.precision = d.precision;
                  s.criteria = d.criteria;

                  varlist = [get(uih.listVars,'String');{['Column',int2str(length(d.name)),'  (unspecified)']}];
                  colptrs = [colptrs ; length(s.name)];

               end

               s.values = cell(1,length(d.name));
               s.flags = repmat({''},1,length(d.name));

               set(uih.editVarname,'UserData',d)
               set(uih.listVars,'String',varlist,'Value',length(colptrs),'UserData',s)
               set(uih.cmdMoveFirst,'UserData',colptrs)

               if isempty(s_orig)
                  set(uih.mnuUndo,'UserData',s)
               else
                  set(uih.mnuUndo,'UserData',s_orig)
               end

               ui_editor('display')

            case 'window'  %handle window reposition or choose callbacks

               h = findobj('Tag','dlgDSEditor');  %get handles of all open editor windows

               if ~isempty(h)

                  h = flipud(sort(h));  %reverse index to list windows in order opened

                  if strcmp(argument,'choose')

                     if length(h) > 1

                        %generate select list contents using figure titles
                        titlestr = [];
                        for n = 1:length(h)
                           titlestr = [titlestr ; {get(h(n),'Name')}];
                        end

                        %get screen metrics
                        screenres = get(0,'ScreenSize');
                        if screenres(3) >= 800
                           listwidth = 800;
                        else
                           listwidth = screenres(3);
                        end

                        I_current = find(h == h_fig);

                        %call list dialog function for data set selection
                        I_sel = listdialog('liststring',titlestr, ...
                           'selectionmode','single', ...
                           'name','Select Window', ...
                           'initialvalue',I_current, ...
                           'promptstring','Select an Editor Window to Open', ...
                           'listsize',[0 0 listwidth 250]);

                        %check for user cancellation
                        if ~isempty(I_sel)
                           try
                              figure(h(I_sel))
                           catch
                              messagebox('init','The selected data set editor window could not be activated','','Error',[.95 .95 .95])
                           end
                        end

                     else
                        messagebox('init','No other data set editor windows are currently open','','Information',[.95 .95 .95])
                     end

                  else  %handle window choice/reposition operations

                     %get screen and figure metrics
                     res = get(0,'ScreenSize');
                     figsize = get(h(1),'Position');

                     %check for other windows
                     if ~isempty(h)

                        %reposition active figure first
                        h0 = setdiff(h,h_fig);
                        h = [h_fig ; h0(:)];

                        %handle specific reposition scenarios
                        switch argument

                           case 'cascade'  %set active window to top left, re-cascade other open windows

                              for n = length(h):-1:1
                                 figpos = [min(res(3)-485,25.*(n-1)+10), ...
                                    max(50,res(4)-680-25.*(n-1)), ...
                                    figsize(3:4)];
                                 set(h(n),'Position',figpos)
                                 figure(h(n))
                              end

                           case 'tile'  %tile as many windows as possible on screen, stack remaining in last slot

                              max_horiz = floor(res(3)./(figsize(3)+10));
                              max_vert = floor(res(4)./(figsize(4)+50));
                              num_figs = length(h);

                              cnt = 0;  %init figure counter
                              for m = 1:max_vert
                                 voffset = 670.*(m-1);
                                 for n = 1:max_horiz
                                    hoffset = 505.*(n-1);
                                    cnt = cnt + 1;  %increment figure counter
                                    if cnt <= num_figs
                                       newpos = [hoffset+10,res(4)-680-voffset,figsize(3:4)];
                                       set(h(cnt),'Position',newpos)
                                       figure(h(cnt))
                                    else
                                       break
                                    end
                                 end
                              end

                              %check for remaining unpositioned windows
                              cnt = cnt + 1;
                              if cnt <= num_figs
                                 for n = cnt:num_figs
                                    hoffset = 505 .* (max_horiz-1);
                                    voffset = 670 .* (max_vert-1);
                                    set(h(n),'Position',[hoffset+10,res(4)-680-voffset,figsize(3:4)])
                                 end
                              end

                           case 'stack'  %stack all windows at top left

                              for n = 1:length(h)
                                 figpos = [min(res(3)-485,10), ...
                                    max(50,res(4)-680), ...
                                    figsize(3:4)];
                                 set(h(n),'Position',figpos)
                                 figure(h(n))
                              end

                        end

                     end

                     figure(h_fig)
                     drawnow

                  end

               end

            case 'clear'  %conditionally create new structure

               if get(uih.mnuQuit,'UserData') == 1  %check dirty flag

                  confirmdlg('init', ...
                     'Discard changes and create an empty data structure?', ...
                     'ui_editor(''newstruct'')');

               else

                  set(uih.mnuLoadTemp,'UserData',0)  %clear load template flag
                  ui_editor('newstruct')

               end

            case 'newstruct'

               if ~isempty(s)
                  set(uih.mnuUndo,'UserData',s)
               end

               set(uih.listVars,'UserData',[])
               set(h_fig,'Name','Data Structure Editor')

               ui_editor('newdata')

            case 'load'  %conditionally load data file from file or workspace

               if get(uih.mnuQuit,'UserData') == 1  %check dirty flag
                  if strcmp(argument,'var')
                     cb = 'ui_editor(''loadvar'')';
                  else
                     cb = 'ui_editor(''loadfile'')';
                  end
                  confirmdlg('init','    Discard changes and load a new structure?    ',cb);
               else
                  set(uih.mnuLoadTemp,'UserData',0)  %clear load template flag
                  if strcmp(argument,'var')
                     ui_editor('loadvar');
                  else
                     ui_editor('loadfile');
                  end
               end

            case 'loadvar'  %unconditionally load structure from workspace

               %get list of workspace variables
               w = evalin('base','whos');
               if ~isempty(w)
                  Istruct = find(strcmp({w.class},'struct'));
               else
                  Istruct = [];
               end

               if ~isempty(Istruct)

                  w = w(Istruct);  %select only structure variables

                  %open list selection dialog
                  str = concatcellcols([{w.name}',repmat({'  ('},length(Istruct),1), ...
                     trimstr(cellstr(num2str([w.bytes]'))),repmat({' bytes)'},length(Istruct),1)],'');
                  Isel = listdialog('liststring',str, ...
                     'name','Workspace Structure Variables', ...
                     'promptstring','Select a Structure to Load', ...
                     'selectionmode','single', ...
                     'listsize',[0 0 250 300]);

                  %load variable if one selected
                  if length(Isel) == 1

                     %retrieve variable from workspace
                     varname = w(Isel).name;
                     s = evalin('base',varname,'[]');
                     set(uih.mnuSaveVar,'UserData',varname)  %cache name for variable saving

                     %validate variable
                     if gce_valid(s,'data')
                     
                        set(uih.mnuUndo,'UserData',s)  %reset undo cache with loaded data

                        set(uih.listVars,'Value',1,'ListboxTop',1,'UserData',s)  %cache new structure
                        set(uih.mnuQuit,'UserData',0)   %clear dirty flag
                        set(h_fig,'Name','Data Structure Editor')  %reset window name to default

                        ui_editor('newdata')

                     else
                        messagebox('init',[' ''',varname,''' is not a valid GCE Data Structure '],'','Error',[.95 .95 .95]);
                     end

                  end

               else
                  messagebox('init',' No valid data structures were found in the workspace ','','Error',[.95 .95 .95]);
               end

            case 'loadfile'  %unconditionally load data file

               %get cached load path, prompt for file
               pn = get(uih.mnuLoad,'UserData');
               cd(pn)
               [fn,pn] = uigetfile('*.mat;*.MAT','Select a file to load');
               cd(curpath)
               if pn ~= 0
                  syncpath(pn,'load');  %cache path unless cancelled
               end
               drawnow

               %check for cancel
               if fn ~= 0

                  s_old = s;  %buffer original structure for template mode
                  err = 0;
                  vars = [];

                  try
                     vars = load([pn,filesep,fn],'-mat');
                  catch
                     err = 1;
                  end

                  if err == 0 && isstruct(vars)

                     s = [];  %init structure variable
                     cancel = 0;  %initialize list selection cancel flag
                     Isel = [];  %init multi-structure array index
                     
                     %loop through variables check for valid GCE structures
                     vnames = fieldnames(vars);
                     Istruct = zeros(length(vnames),1);  %init match index
                     for n = 1:length(vnames)
                        if gce_valid(vars.(vnames{n}),'data');  %check variable
                           Istruct(n) = 1;  %flag variable
                        end
                     end
                     Istruct = find(Istruct);  %get index of valid GCE structure variables
                     
                     %check for any valid structures
                     if ~isempty(Istruct)
                        
                        %check for multiple structures, invoke selection dialog to pick which to load
                        if length(Istruct) > 1
                           Isel = listdialog('liststring',vnames(Istruct), ...
                              'selectionmode','multiple', ...
                              'promptstring','Select data structures from the list to load', ...
                              'name','Select Variable', ...
                              'listsize',[0 0 300 350]);
                        else
                           Isel = 1; %only 1 - automatically select
                        end
                        
                        %check for valid selection
                        if ~isempty(Isel)
                           
                           %look up variable name from list
                           varname = vnames{Istruct(Isel(1))};
                           
                           %get variable from load structure
                           data = vars.(varname);
                           if gce_valid(data,'data')
                              s = data;
                              try
                                 set(uih.mnuSaveVar,'UserData',varname)  %cache name for variable saving
                              catch
                                 %do nothing on error if prior window closed
                              end
                           end
                           
                           %open additional structures in new editor instances
                           if length(Isel) > 1
                              for cnt = 2:length(Isel)
                                 ui_editor('init',vars.(vnames{Istruct(Isel(cnt))}))
                              end
                              figure(h_fig)  %restore focus to first editor instance
                           end
                           
                        else
                           cancel = 1;  %set list selection cancel flag
                        end

                     end

                     %check for loaded structure
                     if ~isempty(s)

                        tempflag = argument;  %check for metadata only option (non-empty argument)

                        if isempty(tempflag)  %load entire structure
                           
                           data2 = s;
                           msg = '';

                        else %use as a template
                           
                           %set documentation metadata option for apply_template
                           if strcmpi(tempflag,'all') || strcmpi(tempflag,'selected')
                              metaopt = tempflag;
                           else
                              metaopt = 'none';
                           end

                           %apply edits before evaluating template
                           flag = get(uih.editCrit,'UserData');
                           [data,msg] = subfun_dsupdate(s_old,d,colptrs,flag);
                           
                           %check for validation problems
                           if ~isempty(data) && isempty(msg)
                              [data2,msg] = apply_template(data,s,metaopt,0);  %perform template lookups                              
                           end

                        end
                        
                        if ~isempty(data2)
                                                     
                           set(uih.listVars,'Value',1,'ListboxTop',1,'UserData',data2)  %cache new structure
                           set(h_fig,'Name',data2.title)  %reset window name to title
                           
                           %cache undo info based on load type
                           if ~isempty(tempflag)
                              set(uih.mnuUndo,'UserData',data)  %cache original structure for undo
                              set(uih.mnuQuit,'UserData',1)     %set dirty flag
                           else
                              set(uih.mnuUndo,'UserData',data2)  %init undo cache with new loaded data
                              set(uih.mnuQuit,'UserData',0)      %clear dirty flag
                              set(uih.mnuFile,'UserData',fn)     %cache filename 
                           end
                           
                           ui_editor('newdata')  %run new data subroutine to init GUI
                           
                        end
                        
                        %check for error message
                        if ~isempty(msg)
                           messagebox('init',msg,[],'Warning',[0.95 0.95 0.95])
                        end

                     elseif cancel == 0  %display error unless user-cancelled list selection

                        if ~isempty(Isel)
                           msg = ['The variable ''',vnames{Isel},''' is not a valid GCE Data Structure'];
                        else
                           msg = ['No GCE Data Structures are present in ''',fn,''''];
                        end
                        messagebox('init',msg,'','Error',[.95 .95 .95]);

                     end

                  else

                     messagebox('init', ...
                        ['''',fn,''' is not a valid MATLAB data file'], ...
                        '', ...
                        'Error', ...
                        [.95 .95 .95]);

                  end

               end

            case 'save'  %save the data structure

               pn = get(uih.mnuSave,'UserData');

               %base new filename on cached loaded/imported filename
               lastfn = get(uih.mnuFile,'UserData');
               if isempty(lastfn)
                  filemask = '*.mat;*.MAT';
               else
                  [tmp,basefn,ext] = fileparts(lastfn);
                  if ~strcmpi(ext,'.mat')
                     filemask = [basefn,'.mat'];
                  else
                     filemask = lastfn;
                  end
               end

               %prompt for save path/filename
               cd(pn)
               [fn,pn] = uiputfile(filemask,'Select a file name and location');
               cd(curpath)
               drawnow
               pn = clean_path(pn); %strip terminal file separator

               %check for cancel
               if ischar(fn) && isdir(pn)

                  syncpath(pn,'save')  %cache path
                  flag = get(uih.editCrit,'UserData');

                  [data,msg] = subfun_dsupdate(s,d,colptrs,flag);

                  if ~isempty(data) && isempty(msg)
                     try
                        save([pn,filesep,fn],'data');  %create new standard data file with structure as 'data'
                        set(uih.mnuFile,'UserData',fn)  %update last filename cache
                        set(uih.mnuQuit,'UserData',0)   %clear dirty flag
                     catch
                        messagebox('init', ...
                           'A system error occurred - file not saved (check write permissions)',...
                           [], ...
                           'Error', ...
                           [.95 .95 .95]);
                     end

                  else
                     messagebox('init', ...
                        char('Could not complete the save because errors occurred validating the structure', ...
                        ['(Error: ',msg,')']),...
                        [], ...
                        'Error', ...
                        [.95 .95 .95]);
                  end

               elseif fn ~= 0  %bad directory
                  messagebox('init','The specified path is not valid','','Error',[.95 .95 .95])
               end
               
            case 'save_var'  %save structure as named variable
               
               defaultvar = get(uih.mnuSaveVar,'UserData');  %get cached variable name
               
               pn = get(uih.mnuSave,'UserData');

               %base new filename on cached loaded/imported filename
               lastfn = get(uih.mnuFile,'UserData');
               if isempty(lastfn)
                  filemask = '*.mat;*.MAT';
               else
                  [tmp,basefn,ext] = fileparts(lastfn);
                  if ~strcmpi(ext,'.mat')
                     filemask = [basefn,'.mat'];
                  else
                     filemask = lastfn;
                  end
               end

               %prompt for path/filename
               cd(pn)
               [fn,pn] = uiputfile(filemask,'Select a file name and location');
               cd(curpath)
               drawnow
               pn = clean_path(pn); %strip terminal file separator               
               
               %check for cancel
               if ischar(fn) && isdir(pn)
                  
                  %cache pathname
                  set(uih.mnuSaveDefault,'UserData',[pn,filesep,fn])
                  
                  %init variable list
                  vars = '';
                  
                  %check for existing file
                  if exist([pn,filesep,fn],'file') == 2
                     try
                        varlist = whos('-file',[pn,filesep,fn]);
                     catch
                        varlist = [];
                     end
                     if ~isempty(varlist)
                        %generate cell array list with default as item 1 if matched
                        vars = {varlist.name}';
                        Idefault = find(strcmp(defaultvar,vars));
                        if ~isempty(Idefault)
                           othervars = setdiff(vars,{defaultvar});
                           vars = [{defaultvar} ; othervars(:)];  %move cached variable to top of list
                        else
                           vars = [{defaultvar} ; vars(:)];  %add cached variable name to top of list
                        end
                     end
                  end
                  
                  %use default variable name if not updating existing file
                  if isempty(vars)
                     vars = defaultvar;
                  end
                  
                  %call text prompt dialog
                  ui_text_prompt('init',uih.mnuSaveVar,'ui_editor(''save_var2'')', ...
                     vars,'Specify a MATLAB variable name','Save Variable');
                  
               elseif fn ~= 0  %bad directory
                  messagebox('init','The specified path is not valid','','Error',[.95 .95 .95])
               end
               
            case 'save_var2'  %save structure as named variable based on prompted text
               
               %get and clear cached path and filename
               fqfn = get(uih.mnuSaveDefault,'UserData');
               set(uih.mnuSaveDefault,'UserData','');
               
               %get cached variable name
               varname = get(uih.mnuSaveVar,'UserData');
               varname = strrep(trimstr(varname),' ','_');
               
               if ~isempty(fqfn) && ~isempty(varname)
                  
                  %split up fully qualified filename
                  [pn,fn_base,fn_ext] = fileparts(fqfn);
                  fn = [fn_base,fn_ext];

                  %cache path
                  syncpath(pn,'save')

                  %finalize data structure
                  flag = get(uih.editCrit,'UserData');
                  [data,msg] = subfun_dsupdate(s,d,colptrs,flag);
                  
                  if ~isempty(data) && isempty(msg)
                     
                     try
                        eval([varname,' = data;'])  %assign data to new variable name
                        if exist([pn,filesep,fn],'file') ~= 2
                           save([pn,filesep,fn],varname);  %create new file
                        else
                           save([pn,filesep,fn],varname,'-APPEND');  %append data array to existing file
                        end
                        set(uih.mnuFile,'UserData',fn)  %update last filename cache
                        set(uih.mnuQuit,'UserData',0)   %clear dirty flag
                     catch
                        messagebox('init', ...
                           'A system error occurred - file not saved (verify file type and write permissions)',...
                           [], ...
                           'Error', ...
                           [.95 .95 .95]);
                     end

                  else
                     messagebox('init', ...
                        char('Could not complete the save because errors occurred validating the structure', ...
                        ['(Error: ',msg,')']),...
                        [], ...
                        'Error', ...
                        [.95 .95 .95]);
                  end
                  
               end

            case 'save_template'  %save current structure metadata as a template

               %apply cached updates
               flag = get(uih.editCrit,'UserData');
               [data,msg] = subfun_dsupdate(s,d,colptrs,flag);

               %check for error
               if isempty(msg)

                  %init template
                  template = [];
                  template.template = ['New Template ',datestr(now,1)];

                  %add column descriptors as template variables
                  template.variable = data.name';
                  template.name = data.name';
                  template.units = data.units';
                  template.description = data.description';
                  template.datatype = data.datatype';
                  template.variabletype = data.variabletype';
                  template.numbertype = data.numbertype';
                  template.precision = data.precision';
                  template.criteria = strrep(strrep(data.criteria',';manual',''),'manual','');

                  %parse codes from metadata, match to data columns
                  valuecodes = lookupmeta(data.metadata,'Data','ValueCodes');
                  codes = repmat({''},length(data.name),1);
                  if ~isempty(valuecodes)
                     ar = splitstr(valuecodes,'|');
                     colnames = data.name;
                     for n = 1:length(ar)
                        [colname,codedefs] = strtok(ar{n},':');
                        Imatch = find(strcmp(colname,colnames));
                        if length(Imatch) == 1
                           codes{Imatch} = trimstr(codedefs(2:end));
                        end
                     end
                  end
                  
                  %add matched codes to template
                  template.codes = codes;                  
               
                  %add documentation metadata
                  template.metadata = data.metadata;

                  %call GUI template editor and add new template
                  ui_template('init')
                  ui_template('add',template)
                  drawnow

               else

                  messagebox('init', ...
                     char('Could not complete the save because errors occurred validating the structure metadata', ...
                     ['(Error: ',msg,')']),...
                     [], ...
                     'Error', ...
                     [.95 .95 .95]);

               end

            case 'varname'  %process column name edits

               if ~isempty(d)

                  varnames = d.name;
                  newstr = deblank(get(uih.editVarname,'String'));

                  if ~isempty(newstr)  %check for blank entry

                     newstr = strrep(newstr,' ','_');  %replace blanks with underscores

                     %ensure unique variable names by appending numbers to dupes
                     if ~isempty(find(strcmp(d.name(colptrs),newstr)))
                        app = 2;
                        newstr2 = [newstr,'_',int2str(app)];
                        while ~isempty(find(strcmp(d.name(colptrs),newstr2)))
                           app = app + 1;
                           newstr2 = [newstr,'_',int2str(app)];
                        end
                        newstr = newstr2;
                     end

                     %update column name references in criteria strings
                     critcols = [];
                     for n = 1:length(d.name)
                        crit = d.criteria{n};
                        colname = d.name{ptr};
                        if ~isempty(strfind(crit,['col_',colname]))
                           critcols = [critcols,n];
                           d.criteria{n} = strrep(crit, ...
                              ['col_',colname],['col_',newstr]);
                        end
                     end
                     
                     %update column name references in code definitions
                     codes = lookupmeta(d.metadata,'Data','ValueCodes');
                     colname0 = regexprep(d.name{ptr},'\w+==','');
                     if ~isempty(strfind(codes,['|',colname0,':']))
                        codes = strrep(codes, ...
                           ['|',colname0,':'], ...
                           ['|',regexprep(newstr,'\w+==',''),':']);
                        d.metadata = addmeta(s.metadata,{'Data','ValueCodes',codes});
                     end

                     %update stored values
                     varnames{ptr} = newstr;
                     d.name = varnames;
                     set(uih.editVarname,'String',newstr,'UserData',d);

                     set(uih.mnuQuit,'UserData',1)  %dirty flag

                     ui_editor('refresh')  %regenerate column list

                     if ~isempty(critcols)
                        msg = ['Column name change synchronized with QA/QC criteria for column(s): ', ...
                           cell2commas(d.name(critcols),1)];
                        messagebox('init',msg,[],'Warning',[.95 .95 .95]);
                     end

                  else  %reset blank name

                     set(uih.editVarname,'String',varnames{ptr})
                     drawnow

                     messagebox('init','Column names cannot be blank -- name reset to prior value','','Invalid Entry',[.95 .95 .95]);

                  end

               end

            case 'prec'  %process description edits

               if ~isempty(d)

                  newnum = fix(str2double(deblank(get(uih.editPrec,'String'))));

                  if ~isnan(newnum)

                     %validate against datatype
                     dtype = d.datatype{ptr};
                     val = 1;
                     if newnum > 0 && (strcmp(dtype,'s') || strcmp(dtype,'d'))
                        val = 0;
                        newnum = 0;
                     end

                     if val == 1
                        %update stored values
                        d.precision(ptr) = newnum;
                        set(uih.editVarname,'UserData',d);
                        set(uih.editPrec,'String',int2str(newnum))  %update field in case modified
                        set(uih.mnuQuit,'UserData',1)  %dirty flag
                     else
                        set(uih.editPrec,'String',int2str(newnum))  %reset field
                        drawnow
                        messagebox('init', ...
                           'Selected precision is incompatable with the column datatype - value reset', ...
                           '', ...
                           'Warning', ...
                           [.95 .95 .95]);
                     end

                  else  %reset non-integer directly

                     set(uih.editPrec,'String',int2str(d.precision(ptr)))

                     messagebox('init', ...
                        '  Precision must be a valid integer  ', ...
                        '', ...
                        'Invalid Entry', ...
                        [.95 .95 .95]);

                  end

               end

            case 'lockflags'  %process flag lock/unlock requests

               %handle various callback operations based on second argument
               if ~isempty(argument)

                  dirty = 0;  %set update flag
                  reflag = 0;  %set reflag flag
                  crit = d.criteria;
                  vartype = d.variabletype;

                  switch argument
                     case 'lock_all'  %lock flags for all columns
                        for n = 1:length(crit)
                           if isempty(crit{n})
                              crit{n} = 'manual';
                           elseif isempty(strfind(crit{n},'manual'))
                              crit{n} = [crit{n},';manual'];
                           end
                        end
                        dirty = 1;
                     case 'lock_data'  %lock flags for data/calculation columns
                        for n = 1:length(crit)
                           if strcmp(vartype{n},'data') || strcmp(vartype{n},'calculation')
                              if isempty(crit{n})
                                 crit{n} = 'manual';
                              elseif isempty(strfind(crit{n},'manual'))
                                 crit{n} = [crit{n},';manual'];
                              end
                              dirty = 1;
                           end
                        end
                     case 'lock_sel'  %lock flags for selected columns
                        for n = 1:length(ptr)
                           if isempty(crit{ptr(n)})
                              crit{ptr(n)} = 'manual';
                           elseif isempty(strfind(crit{ptr(n)},'manual'))
                              crit{ptr(n)} = [crit{ptr(n)},';manual'];
                           end
                        end
                        dirty = 1;
                     case 'unlock_all'  %unlock flags for all columns
                        for n = 1:length(crit)
                           if ~isempty(strfind(crit{n},'manual'))
                              crit{n} = strrep(strrep(crit{n},';manual',''),'manual','');
                           end
                        end
                        dirty = 1;
                        reflag = 1;
                     case 'unlock_data'  %unlock flags for all data/calculation columns
                        for n = 1:length(crit)
                           if strcmp(vartype{n},'data') || strcmp(vartype{n},'calculation')
                              if ~isempty(strfind(crit{n},'manual'))
                                 crit{n} = strrep(strrep(crit{n},';manual',''),'manual','');
                              end
                              dirty = 1;
                              reflag = 1;
                           end
                        end
                     case 'unlock_sel'  %unlock flags for selected columns
                        for n = 1:length(ptr)
                           if ~isempty(strfind(crit{ptr(n)},'manual'))
                              crit{ptr(n)} = strrep(strrep(crit{ptr(n)},';manual',''),'manual','');
                           end
                        end
                        dirty = 1;
                        reflag = 1;
                  end

                  %update stored values if modified
                  if dirty == 1
                     d.criteria = crit;
                     set(uih.editVarname,'UserData',d);
                     if reflag == 1
                        set(uih.editCrit,'UserData',1)  %reflag flag
                     end
                     set(uih.mnuQuit,'UserData',1)  %dirty flag
                     ui_editor('display')  %refresh GUI
                  end

               end

            case 'crit'  %process criteria edits

               if ~isempty(d)

                  newstr = deblank(get(uih.editCrit,'String'));
                  d.criteria{ptr} = newstr;

                  %update stored values
                  set(uih.editVarname,'UserData',d);
                  set(uih.editCrit,'UserData',1)  %reflag flag
                  set(uih.mnuQuit,'UserData',1)  %dirty flag

               end

            case 'datatype'  %process data type edits

               if ~isempty(d)

                  %get cell arrays for popup menus
                  datalist = get(uih.popDatatype,'UserData');
                  newval = get(uih.popDatatype,'Value');
                  newdtype = datalist{newval};

                  %validate selection
                  if isempty(s.values{ptr})  %check for no data condition - skip val
                     val = 1;
                  elseif strcmp(newdtype,'u')  %check for unspecified
                     val = 1;
                  elseif strcmp(newdtype,'s')  %validate string dtype
                     if iscell(s.values{ptr})
                        val = 1;
                     else  %non-cell data - invalid
                        val = 0;
                     end
                  elseif ~iscell(s.values{ptr})  %validate non-string dtype
                     val = 1;
                  else  %cell array - invalid
                     val = 0;
                  end

                  if val == 1
                     d.datatype{ptr} = newdtype;
                     if strcmp(newdtype,'s')  %set numbertype, precision for strings
                        d.numbertype{ptr} = 'none';
                        d.precision(ptr) = 0;
                        set(uih.popNumtype,'Value',find(strcmp(get(uih.popNumtype,'Userdata'),'none')))
                        set(uih.editPrec,'String','0')
                     elseif strcmp(newdtype,'d')  %set numbertype, precision for integers
                        d.numbertype{ptr} = 'discrete';
                        d.precision(ptr) = 0;
                        set(uih.popNumtype,'Value',find(strcmp(get(uih.popNumtype,'Userdata'),'discrete')))
                        set(uih.editPrec,'String','0')
                     elseif strcmp(newdtype,'f') || strcmp(newdtype,'e')
                        if ~(strcmp(d.numbertype{ptr},'continuous') || strcmp(d.numbertype{ptr},'angular'))
                           d.numbertype{ptr} = 'continuous';
                           set(uih.popNumtype,'Value',find(strcmp(get(uih.popNumtype,'Userdata'),'continuous')))
                        end
                     end
                     set(uih.editVarname,'UserData',d);
                     set(uih.mnuQuit,'UserData',1)
                  else
                     set(uih.popDatatype,'Value',find(strcmp(datalist,d.datatype{ptr})))
                     drawnow
                     messagebox('init', ...
                        'Data type selection is not compatible with the column values -- selection reset', ...
                        '', ...
                        'Warning', ...
                        [.95 .95 .95]);
                  end

               end

            case 'vartype'  %process variable type edits

               if ~isempty(d)

                  %get cell arrays for popup menus
                  varlist = get(uih.popVartype,'UserData');
                  newval = get(uih.popVartype,'Value');

                  %update cached value
                  d.variabletype{ptr} = varlist{newval};
                  set(uih.editVarname,'UserData',d);
                  set(uih.mnuQuit,'UserData',1)

                  if strcmp(varlist{newval},'code')
                     set(uih.cmdEditCodes,'Visible','on')
                  else
                     set(uih.cmdEditCodes,'Visible','off')
                  end

               else
                  set(uih.cmdEditCodes,'Visible','off')
               end

            case 'numtype'  %process number type edits

               if ~isempty(d)

                  %get cell arrays for popup menus
                  numlist = get(uih.popNumtype,'UserData');
                  newval = get(uih.popNumtype,'Value');
                  newtype = numlist{newval};

                  %validate new selection
                  dtype = d.datatype{ptr};
                  val = 1;
                  if strcmp(dtype,'s') && ~strcmp(newtype,'none')
                     val = 0;
                     newtype = 'none';
                  elseif strcmp(dtype,'d') && ~strcmp(newtype,'discrete')
                     val = 0;
                     newtype = 'discrete';
                  elseif (strcmp(dtype,'f') || strcmp(dtype,'e')) && ...
                        (strcmp(newtype,'discrete') || strcmp(newtype,'none'))
                     val = 0;
                     newtype = d.numbertype{ptr};  %restore prior value
                  end

                  if val == 1
                     d.numbertype{ptr} = newtype;  %update numbertype
                     set(uih.editVarname,'UserData',d);
                     set(uih.mnuQuit,'UserData',1)
                  else
                     set(uih.popNumtype,'Value',find(strcmp(numlist,newtype)))
                     drawnow
                     messagebox('init', ...
                        'This numerical type is not compatible with the column data type -- selection reset', ...
                        '', ...
                        'Warning', ...
                        [.95 .95 .95]);
                  end

               end

            case 'desc'  %process description edits

               if ~isempty(d)

                  %reformat text to 1-line string with insignificant whitespace removed
                  newstr = clean_str(get(uih.editDesc,'String'));

                  %update field with reformatted string
                  set(uih.editDesc,'String',newstr)
                  drawnow

                  %update stored values
                  d.description{ptr} = newstr;  %update cached metadata
                  set(uih.editVarname,'UserData',d)
                  set(uih.mnuQuit,'UserData',1)  %dirty flag

               end

            case 'units'  %process units edits

               if ~isempty(d)

                  %update stored values
                  d.units{ptr} = deblank(get(uih.editUnits,'String'));
                  set(uih.editVarname,'UserData',d)
                  set(uih.mnuQuit,'UserData',1)  %dirty flag

                  ui_editor('refresh')  %regenerate variable list

               end

            case 'editdata'  %process edited data

               figure(h_fig)
               drawnow

               tmp = get(uih.mnuEditData,'userdata');
               if iscell(tmp)
                  data = tmp{1};
                  dirtyflag = tmp{2};
               else
                  dirtyflag = 0;
               end
               set(uih.mnuEditData,'userdata',[]);  %clear cache

               if dirtyflag == 1
                  s = get(uih.listVars,'UserData');
                  set(uih.mnuUndo,'UserData',s)  %cache undo data
                  set(uih.listVars,'UserData',data)
                  ui_editor('newdata')
                  set(uih.mnuQuit,'UserData',1)  %set dirty flag *after* update
               end

            case 'editmeta'  %send metadata to external editor

               if ~isempty(d.metadata)
                  meta = d.metadata;
               else
                  meta = s.metadata;
               end

               ui_editmetadata('init',meta,uih.mnuEditMeta,'ui_editor(''updatemeta'')');

            case 'updatemeta'  %process edited metadata

               meta = get(uih.mnuEditMeta,'UserData');
               d.metadata = meta;
               set(uih.editVarname,'UserData',d);

            case 'title'  %send structure to external title editor dialog

               flag = get(uih.editCrit,'UserData');
               [data,msg] = subfun_dsupdate(s,d,colptrs,flag);

               if ~isempty(data) && isempty(msg)
                  ui_title('init',data,uih.mnuTitle,'ui_editor(''newtitle'')');
               else
                  messagebox('init',msg,'','Error',[0.95 0.95 0.95])
               end

            case 'newtitle'  %process edited title

               newtitle = get(uih.mnuTitle,'UserData');
               if ~isempty(newtitle)  %update title in cached structure
                  d.title = newtitle;
                  d2 = s;
                  if ~isempty(d.metadata)
                     d2.metadata = d.metadata;
                  end
                  d2 = addmeta(d2,[{'Dataset'},{'Title'},{newtitle}],1);
                  if ~isempty(d2)
                     d.metadata = d2.metadata;
                  end
                  set(uih.editVarname,'UserData',d)
                  ui_editor('rename2','title')
               end

            case 'procjoin'  %process new data returned from ui_joindata

               s_old = s;
               s = get(uih.mnuImpJoin,'UserData');
               set(uih.mnuImpJoin,'UserData',[])

               if ~isempty(s)
                  if ~isempty(s_old)  %cache prior structure
                     set(uih.mnuUndo,'UserData',s_old)
                  else  %no cache - cache new structure
                     set(uih.mnuUndo,'UserData',s)
                  end
                  set(uih.listVars,'UserData',s)
                  ui_editor('newdata')
               else
                  messagebox('init', ...
                     'No results were returned from join operation', ...
                     [], ...
                     'Error', ...
                     [.95 .95 .95]);
               end

            case 'qaqc'  %process modified structure returned from ui_dataflag

               s_old = s;
               s = get(uih.mnuManualQC,'UserData');
               set(uih.mnuManualQC,'UserData',[])

               if ~isempty(s)
                  if ~isempty(s_old)  %cache prior structure
                     set(uih.mnuUndo,'UserData',s_old)
                  else  %no cache - cache new structure
                     set(uih.mnuUndo,'UserData',s)
                  end
                  set(uih.listVars,'UserData',s)
                  ui_editor('newdata')
               else
                  messagebox('init', ...
                     'Warning - manual QA/QC flags were not assigned', ...
                     [], ...
                     'Error', ...
                     [.95 .95 .95]);
               end

            case 'copyflags'  %process updated data returned from ui_copyflags

               data2 = get(uih.mnuCopyFlags,'UserData');
               set(uih.mnuCopyFlags,'UserData',[])

               if ~isempty(data2)
                  s = get(uih.listVars,'UserData');
                  set(uih.mnuUndo,'UserData',s)  %cache undo data
                  set(uih.listVars,'UserData',data2)
                  ui_editor('newdata')
                  set(uih.mnuQuit,'UserData',1)  %set dirty flag *after* update
               else
                  messagebox('init','Errors occurred updating structure after flag propagation (cancelled)', ...
                     '','Warning',[.95 .95 .95]);
               end

            case 'clrflags'  %process updated data returned from ui_clearflags

               data2 = get(uih.mnuClrFlagVals0,'UserData');
               set(uih.mnuClrFlagVals0,'UserData',[])

               if ~isempty(data2)
                  s = get(uih.listVars,'UserData');
                  set(uih.mnuUndo,'UserData',s)  %cache undo data
                  set(uih.listVars,'UserData',data2)
                  ui_editor('newdata')
                  set(uih.mnuQuit,'UserData',1)  %set dirty flag *after* update
               else
                  messagebox('init','Errors occurred updating structure after flags or flagged data removal (cancelled)', ...
                     '','Warning',[.95 .95 .95]);
               end

            case 'addcalc'  %process new data returned from ui_calculator

               data2 = get(uih.mnuCalc,'UserData');
               set(uih.mnuCalc,'UserData',[])

               if ~isempty(data2)
                  s = get(uih.listVars,'UserData');
                  set(uih.mnuUndo,'UserData',s)  %cache undo data
                  set(uih.listVars,'UserData',data2)
                  ui_editor('newdata')
                  set(uih.mnuQuit,'UserData',1)  %set dirty flag *after* update
               else
                  messagebox('init','Errors occurred updating structure after column additions', ...
                     '','Warning',[.95 .95 .95]);
               end

            case 'sortcols'  %process sorted data structure sent from ui_sortcolumns

               data2 = get(uih.mnuSort,'userdata');
               set(uih.mnuSort,'UserData',[])

               if ~isempty(data2)
                  s = get(uih.listVars,'UserData');
                  set(uih.mnuUndo,'UserData',s)  %cache undo data
                  set(uih.listVars,'UserData',data2)
                  ui_editor('newdata')
                  set(uih.mnuQuit,'UserData',1)  %set dirty flag *after* update
               else
                  messagebox('init','Errors occurred applying column sorting selections', ...
                     '','Warning',[.95 .95 .95]);
               end

            case 'replace' %process return data from ui_string_replace or ui_num_replace

               data2 = get(uih.mnuReplace,'userdata');
               set(uih.mnuReplace,'UserData',[])

               if ~isempty(data2)
                  s = get(uih.listVars,'UserData');
                  set(uih.mnuUndo,'UserData',s)  %cache undo data
                  set(uih.listVars,'UserData',data2)
                  ui_editor('newdata')
                  set(uih.mnuQuit,'UserData',1)  %set dirty flag *after* update
               else
                  messagebox('init','Errors occurred replacing values or flags in the selected column', ...
                     '','Warning',[.95 .95 .95]);
               end

            case 'interp'  %process interpolated data structure sent from ui_interp_missing

               data2 = get(uih.mnuInterp,'userdata');
               set(uih.mnuInterp,'UserData',[])

               if ~isempty(data2)
                  s = get(uih.listVars,'UserData');
                  set(uih.mnuUndo,'UserData',s)  %cache undo data
                  set(uih.listVars,'UserData',data2)
                  ui_editor('newdata')
                  set(uih.mnuQuit,'UserData',1)  %set dirty flag *after* update
               end

            case 'calcmissing'  %process gap-filled data structure sent from ui_calc_missing

               data2 = get(uih.mnuCalcMissing,'userdata');
               set(uih.mnuCalcMissing,'UserData',[])

               if ~isempty(data2)
                  s = get(uih.listVars,'UserData');
                  set(uih.mnuUndo,'UserData',s)  %cache undo data
                  set(uih.listVars,'UserData',data2)
                  ui_editor('newdata')
                  set(uih.mnuQuit,'UserData',1)  %set dirty flag *after* update
               end

            case 'drift'  %process drift-corrected data structure sent from ui_correct_drift

               data2 = get(uih.mnuCorrectDrift,'userdata');
               set(uih.mnuCorrectDrift,'UserData',[])

               if ~isempty(data2)
                  s = get(uih.listVars,'UserData');
                  set(uih.mnuUndo,'UserData',s)  %cache undo data
                  set(uih.listVars,'UserData',data2)
                  ui_editor('newdata')
                  set(uih.mnuQuit,'UserData',1)  %set dirty flag *after* update
               end

            case 'histogram'  %preview formatted data column as histogram

               msg = plothistogram(s,ptr,15,'e');
               if ~isempty(msg)
                  messagebox('init', ...
                     ['Could not plot histogram (Error: ',msg,')'], ...
                     '', ...
                     'Error', ...
                     [.95 .95 .95]);
               end

            case 'preview'  %preview formatted data column

               vals = extract(s,ptr);

               dtype = d.datatype{ptr};
               prec = d.precision(ptr);

               switch dtype
                  case 's'
                     fstr = '%s';
                  case 'f'
                     fstr = ['%0.',int2str(prec),'f'];
                  case 'e'
                     fstr = ['%0.',int2str(prec),'e'];
                  case 'd'
                     fstr = '%d';
                     vals = round(vals);
                  otherwise
                     fstr = '';
               end

               if ~isempty(fstr)
                  previewdata('init',vals(1:min(1000,length(vals))),fstr);
               end

            case 'flagdefs'  %edit QC flag definitions, data anomalies in external editor

               if ~isempty(d)
                  if ~isempty(d.metadata)
                     meta = d.metadata;
                  else
                     meta = s.metadata;
                  end
                  ui_flagdefs('init',meta,uih.mnuFlagDefs,'ui_editor(''flagdefs2'')')
               end

            case 'flagdefs2'  %process edited QC flag definitions, anomalies

               data = get(uih.mnuFlagDefs,'UserData');
               if ~isempty(data)
                  flagdefs = data{1};
                  anom = data{2};
                  if ~isempty(d.metadata)
                     meta = d.metadata;
                  else
                     meta = s.metadata;
                  end
                  if ~isempty(meta)
                     Idata = find(strcmp(meta(:,1),'Data'));
                     if ~isempty(Idata)
                        Icodes = find(strcmp(meta(Idata,2),'Codes'));
                        Ianom = find(strcmp(meta(Idata,2),'Anomalies'));
                        if ~isempty(Icodes)
                           meta{Idata(Icodes),3} = flagdefs;
                        else
                           meta = [meta ; {'Data'},{'Codes'},{flagdefs}];
                        end
                        if ~isempty(Ianom)
                           meta{Idata(Ianom),3} = anom;
                        else
                           meta = [meta ; {'Data'},{'Anomalies'},{anom}];
                        end
                     else
                        meta = [meta ; {'Data'},{'Codes'},{flagdefs}; {'Data'},{'Anomalies'},{anom}];
                     end
                  else
                     meta = [{'Data'},{'Codes'},{flagdefs}; {'Data'},{'Anomalies'},{anom}];
                  end

                  %update stored values
                  d.metadata = meta;
                  set(uih.editVarname,'UserData',d);
                  set(uih.mnuQuit,'UserData',1)  %dirty flag

               end

            case 'critedit'  %edit criteria string in external editor

               if ~isempty(d)
                  flag = get(uih.editCrit,'UserData');
                  [data,msg] = subfun_dsupdate(s,d,colptrs,flag);
                  flagcodes = lookupmeta(data,'Data','Codes');
                  ui_qccriteria('init',data,d.name{ptr},flagcodes,uih.cmdEditCrit,'ui_editor(''critedit2'')')
               end

            case 'critedit2'  %process criteria string edits

               tmp = get(uih.cmdEditCrit,'UserData');

               if ~isempty(tmp)

                  critstr = tmp{1};
                  colname = tmp{2};
                  flaglist = tmp{3};

                  %validate column info based on name (in case column focus shifted after invoked editor)
                  if ~strcmp(d.name{ptr},colname)
                     I = find(strcmp(d.name,colname));
                     if length(I) == 1
                        colnum = I;
                     else
                        colnum = [];
                     end
                  else
                     colnum = ptr;
                  end

                  if ~isempty(colnum)

                     if isempty(d.metadata)
                        flagcodes = lookupmeta(s,'Data','Codes');
                     else
                        flagcodes = lookupmeta(d.metadata,'Data','Codes');
                     end

                     if iscell(flaglist)
                        flagcodes2 = cell2commas(flaglist);
                     else
                        flagcodes2 = flaglist;
                     end

                     if ~strcmp(flagcodes,flagcodes2)
                        if ~isempty(d.metadata)
                           s.metadata = d.metadata;
                        end
                        newmeta = addmeta(s.metadata,[{'Data'},{'Codes'},{flagcodes2}]);  %pass metadata only to avoid validation error if working on empty template
                        if ~isempty(newmeta)
                           d.metadata = newmeta;
                        end
                     end

                     d.criteria{colnum} = critstr;

                     %update stored values
                     set(uih.editVarname,'UserData',d);
                     set(uih.editCrit,'UserData',1)  %reflag flag
                     set(uih.mnuQuit,'UserData',1)  %dirty flag

                     if colnum == ptr
                        set(uih.editCrit,'String',critstr)
                        drawnow
                     else
                        set(uih.listVars,'Value',colnum)
                        ui_editor('display')
                     end

                  else  %column not found
                     messagebox('init','Original column deleted or renamed -- QA/QC criteria could not be updated', ...
                        [],'Error',[.95 .95 .95])
                  end

               end

            case 'editcodes'  %process returned data from value code edits

               %get return data from data grid
               cb_data = get(uih.cmdEditCodes,'UserData');

               %check for valid data format
               if iscell(cb_data) && length(cb_data) >= 2

                  %check for changes based on second parameter flag
                  if cb_data{2} == 1

                     %extract code data set
                     codes = cb_data{1};

                     if gce_valid(codes,'data')

                        codes = compactrows(codes,1);  %remove any entries with empty code names
                        colname = regexprep(codes.name{1},'\w+==','');  %remove variable prefix if in template editor mode
                        codenames = extract(codes,1);
                        codevals = extract(codes,2);

                        Inull = find(cellfun('isempty',codevals));
                        if ~isempty(Inull)
                           codevals(Inull) = {'unspecified'};  %supply default for any missing code definitions
                        end

                        if ~isempty(codenames) && ~isempty(codevals)

                           %get existing metadata array
                           if ~isempty(d.metadata)
                              meta = d.metadata;
                           else
                              meta = s.metadata;
                           end

                           %add/update code list in metadata and just return Data/ValueCodes fragment
                           newmeta = update_codes(meta,colname,codenames,codevals,'fragment');

                           %incorporate new value code metadata
                           d.metadata = addmeta(meta,{'Data','ValueCodes',newmeta});  %update metadata with new codelist
                           set(uih.editVarname,'UserData',d);  %update cached metadata
                           set(uih.mnuQuit,'UserData',1)  %dirty flag

                        end

                     else
                        messagebox('init','An error occurred retrieving the edited code list',[],'Error',[.95 .95 .95])
                     end

                  end

               end

            case 'rename'  %process editor window name edits

               h_newname = findobj(h_fig,'Tag','mnuRename');
               newname = deblank(get(h_newname,'UserData'));
               if ~isempty(newname)
                  set(h_fig,'Name',newname)
                  set(h_newname,'UserData','')
                  drawnow
               end

            case 'rename2'  %use structure title for window name or reset to default

               if isempty(argument)
                  argument = 'title';
               end

               if ~isempty(d)

                  if strcmp(argument,'title')
                     if ~isempty(d.title)
                        newtitle = d.title;
                     else
                        newtitle = s.title;
                     end
                  else
                     newtitle = 'Data Structure Editor';
                  end

                  if ~isempty(newtitle)
                     set(h_fig,'Name',newtitle)
                  end

               end
               
            case 'extension'  %handle toolbox extension callbacks

               arg = argument; %get argument to use as operator

               if ~isempty(arg) && (exist('extensions','file') == 2 || exist('extensions','file') == 6)

                  %process structure edits
                  s = get(uih.listVars,'UserData');
                  flag = get(uih.editCrit,'UserData');
                  [data,msg] = subfun_dsupdate(s,d,colptrs,flag);

                  %cache undo data
                  set(uih.mnuUndo,'UserData',data)

                  %send data to extension
                  if ~isempty(data) && isempty(msg)
                     extensions(arg,data);
                  else
                     messagebox('init',msg,[],'Error',[0.95 0.95 0.95],0)
                  end

               end
               
            case 'extension_return'  %handle data returned from an extension callback
               
               data = argument;  %get return data
               
               set(uih.listVars,'UserData',data)  %cache new structure
               set(uih.mnuQuit','UserData',1)  %set dirty flag
               ui_editor('newdata');  %incorporate new data
               
            case 'harvesters'  %handle harvester management operations
               
               %check for editing operations
               if strncmp('edit',argument,4)
                  
                  %get name of active harvest_timers.mat file
                  fn = which('harvest_timers.mat');
                  
                  %check for file
                  if ~isempty(fn)                     
                     if strcmp('edit',argument)
                        try
                           vars = load(fn,'-mat');
                           harvesters = vars.data;
                           ui_datagrid('init',harvesters,uih.mnuHarvesters,'ui_editor(''harvesters'',''edit2'')',200);
                        catch e
                           messagebox('init',['Harvest timers database file ',fn,' could not be opened (',e.message,')'], ...
                              '','Error',[0.95 0.95 0.95])
                        end
                     else  %return data
                        harvesters = get(uih.mnuHarvesters,'UserData');
                        set(uih.mnuHarvesters,'UserData',[])
                        if iscell(harvesters) && length(harvesters) >= 2 && harvesters{2} > 0
                           output = struct('data',harvesters{1});  %#ok<NASGU>
                           save(fn,'-struct','output')
                        end
                     end
                  else
                     messagebox('init','Harvest timers database ''harvest_timers.mat'' is not present in the MATLAB path', ...
                        '','Error',[0.95 0.95 0.95])
                  end
                  
               elseif strcmp('log',argument)
                  
                  fn = which('harvest_logs.mat');
                  log = [];
                  msg = '';
                  
                  %check for file in path
                  if ~isempty(fn)
                     
                     try
                        vars = load(fn,'-mat');
                     catch e
                        vars = struct('null','');
                        msg = ['An error occurred loading the file ''',fn,''' (',e.message,')'];                        
                     end
                     
                     %validate data variable
                     if isfield(vars,'data')
                        log = vars.data;
                        if gce_valid(log,'data') ~= 1
                           log = [];
                           msg = ['The log file ''',fn,''' is invalid'];
                        end
                     elseif isempty(msg)
                        msg = ['The log file ''',fn,''' is invalid'];
                     end
                     
                  else
                     msg = 'The log file ''harvest_logs.mat'' was not found in the path';
                  end
                        
                  %display log or error message
                  if ~isempty(log) && isempty(msg)
                     dt = extract(log,'Date');
                     name = extract(log,'Harvester');
                     entry = extract(log,'Entry');
                     try
                        str = concatcellcols([dt,concatcellcols([name,entry],' - ')],': ');
                        viewtext(str,100,22,'Data Harvesting Log')
                     catch e
                        msg = ['An error occurred rendering the log information in ''',fn,''' (',e.message,')'];
                     end
                  end
                  
                  if ~isempty(msg)
                     messagebox('init',msg,'','Error',[0.95 0.95 0.95])
                  end                  
                  
               else  %other operations
                  
                  switch argument
                     
                     case 'start'
                        
                        %start all harvesters
                        msg = start_harvesters;
                        
                     case 'stop'
                        
                        %get list of all running timers
                        t = timerfind;
                        
                        if ~isempty(t)
                        
                           %build cell array of timer names
                           names = t.Name;
                           if ischar(names)
                              names = cellstr(names);
                           end
                           
                           %select timers to stop
                           if length(t) > 1
                              %bring up listbox for selecting timers to stop
                              Isel = listdialog('liststring',names, ...
                                 'name','Running Harvesters', ...
                                 'promptstring','Select harvesters to stop', ...
                                 'selectionmode','multiple');
                           else
                              %stop only running harvesters
                              Isel = 1;
                           end
                           
                           %stop selected timer(s)
                           if ~isempty(Isel)
                              msg = stop_harvesters(names(Isel));
                           end
                           
                        else
                           msg = 'No timers are currently running';
                        end
                        
                     case 'list'
                        
                        %list all harvesters running
                        msg = list_harvesters;
                                                
                     otherwise
                        
                        msg = '';
                        
                  end
                  
                  if ~isempty(msg)
                     messagebox('init',msg,'','Information',[0.95 0.95 0.95])
                  end
                  
               end
               
         end

      end

   end

end

if ~isempty(errmsg)
   disp(errmsg)
end

return

function [s,msg,Inew] = subfun_dsupdate(s,d,Icols,flag)
%Subfunction for performing data structure updates based on based on metadata revisions
%
%input:
%  s = cached data structure
%  d = metadata structure with all run-time updates
%  Icols = array of column indices reflecting deletions and re-ordering of original columns
%  flag = option to apply flag updates on changes (Q/C criteria dirty flag)
%
%output:
%  s = updated data structure
%  msg = status message
%  Inew = updated column index

%init output
msg = '';
Inew = Icols;  %init updated column index

%initialize edit history string
editstr = '';

%check for metadata update (results in population of metadata field)
if ~isempty(d.metadata)
   s.metadata = d.metadata;
   s.history = [s.history ; ...
      {datestr(now)},{'manually edited data set metadata (''ui_editmetadata'')'}];
end

%check for description changes, log updates without displaying before/after text
Ied = find(~strcmp(s.description,d.description));
if ~isempty(Ied)
   s.description = d.description;
   if length(Ied) > 1
      editstr = [editstr,'Descriptions of columns ',cell2commas(s.name(Ied),1),' edited; '];
   else
      editstr = [editstr,'Description of column ',s.name{Ied},' edited; '];
   end
end

%generate array of columns with revised Q/C criteria for recalculating
Iflagcrit = find(~strcmp(s.criteria(Icols),d.criteria(Icols)));
flagcols = '';
if ~isempty(Iflagcrit)
   flagcols = d.name(Icols(Iflagcrit));  %get array of column names (reflecting any run-time changes)
end

%check for text attribute metadata changes, log and apply
flds = {'name','units','datatype','variabletype','numbertype','criteria','precision'};
fldnames = {'Name','Units','Data Type','Variable Type','Numeric Type','Q/C Criteria','Precision'};
for n = 1:length(flds)
   fld = flds{n};
   [meta_ar,str] = subfun_fieldchanges(s.(fld)(Icols),d.(fld)(Icols),s.name(Icols),fldnames{n});
   if ~isempty(str)
      s.(fld)(Icols) = meta_ar;
      editstr = [editstr,str];
   end
end

%initialize history buffer flag
bufferhist = 0;

%check for deletes
if length(Icols) < length(s.name)
   reorder = 1;  %set copycols flag
   if isempty(find(diff(Icols)<0))  %check for reordering
      bufferhist = 1;  %set flag to buffer history prior to copycols to prevent logging (no reorder)
   end
   [I1,I2] = meshgrid((1:length(s.name)),Icols);
   if size(I1,1) > 1
      Idel = find(~sum(I1==I2));
   else
      Idel = find(I1~=I2);
   end
   if ~isempty(Idel)
      if length(Idel) > 1
         delstr = cell2commas(s.name(Idel),1);
         editstr = [editstr, 'deleted columns ',delstr,' from data structure; '];
      else
         delstr = s.name{Idel};
         editstr = [editstr, 'deleted column ',delstr,' from data structure; '];
      end
   end
elseif sum(Icols' ~= (1:length(s.name))) > 0
   reorder = 1;
else
   reorder = 0;
end

%check for empty structure, create 1 blank data row to avoid errors calling tools
if isempty(s.values{1})
   s.values = repmat({NaN},1,length(s.name));
   Istr = find(strcmp(s.datatype,'s'));
   if ~isempty(Istr)
      for n = 1:length(Istr)
         s.values{Istr(n)} = {''};
      end
   end
   s.flags = repmat({''},1,length(s.name));
end

%check for title update
if ~strcmp(s.title,d.title)
   editstr = 'edited data set title in structure and metadata; ';
   s.title = d.title;
   [s,msg] = addmeta(s,[{'Dataset'},{'Title'},{d.title}],1);  %perform silent addition/update of title in metadata
end

%check for any edits and update history
if ~isempty(editstr)
   editstr = [editstr(1:end-2),' (''ui_editor'')'];
   s.history = [s.history ; {datestr(now)},{editstr}];
end

%check for column re-ordering
if reorder == 1
   
   %generate updated column index for return
   Inew = 1:length(Icols);
   
   %check for template mode (editing attribute metadata only) and set flag to skip validation
   Ieq = strfind(s.name,'==');
   if ~isempty(find(~cellfun('isempty',Ieq)))
      skip_validation = 'Y';
   else
      skip_validation = 'N';
   end
   
   %apply field selections, checking for buffer history option
   if bufferhist == 1
      str_hist = s.history;
      s = copycols(s,Icols,'y',skip_validation);
      s.history = str_hist;
   else
      s = copycols(s,Icols,'y',skip_validation);
   end
   
end

%validate revised structure
if gce_valid(s,'data') == 0
   s = [];
elseif flag == 1 && ~isempty(flagcols)
   [s,msg] = dataflag(s,flagcols);  %update QC flags if criteria edited
end

return


function [meta_ar,editstr] = subfun_fieldchanges(meta_ar,meta_ar2,colnames,fldname)
%Check for attribute metadata changes, update and generate history entry
%
%input:
%  meta_ar = array of original structure attribute descriptors
%  meta_ar2 = array of revised attribute descriptors
%  fldname = field name string to use for describing metadata updates in history
%
%output:
%  meta_ar = updated metadata array
%  editstr = history entry (character array)

%init str_update
editstr = '';

%get index of field changes
if iscell(meta_ar)
   Ied = find(~strcmp(meta_ar,meta_ar2));
else
   Ied = find(meta_ar~=meta_ar2);
end

%check for any changes
if ~isempty(Ied)
   
   %init cell array for edit entries
   str_temp = repmat({''},1,length(Ied));
   
   %loop through changes
   if strcmpi(fldname,'name')
      for n = 1:length(Ied)
         str_temp{n} = ['Name of column ',colnames{Ied(n)},' changed to ',meta_ar2{Ied(n)},'; '];
      end
   elseif iscell(meta_ar)
      for n = 1:length(Ied)
         str_temp{n} = [fldname,' of column ',colnames{Ied(n)},' changed from ''', ...
            meta_ar{Ied(n)},''' to ''',meta_ar2{Ied(n)},'''; '];
      end
   else
      for n = 1:length(Ied)
         str_temp{n} = [fldname,' of column ',colnames{Ied(n)},' changed from ', ...
            num2str(meta_ar(Ied(n))),' to ',num2str(meta_ar2(Ied(n))),'; '];
      end
   end
      
   %convert cell to character array
   editstr = [str_temp{:}];
   editstr = editstr(1:end-1); %strip terminal semicolon
   
   %update metadata array
   meta_ar = meta_ar2;
   
end
