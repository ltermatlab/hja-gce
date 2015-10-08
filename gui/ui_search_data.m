function ui_search_data(op,data)
%GCE Search Engine dialog for building and querying metadata search indices to identify and retrieve data sets
%for analysis or transformation using GCE Data Toolbox programs. Search indices can include both local and web-based
%data holdings, and support is included for automatic registration, downloading, and local caching
%of public data sets from the GCE data catalog (http://gce-lter.marsci.uga.edu/public/app/data_catalog.asp).
%
%syntax: ui_search_data(op,index)
%
%inputs:
%  op = operation ('init' to initialize the dialog
%  index = initial search index to use (see 'search_index')
%
%outputs:
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
%last modified: 09-Oct-2011

if nargin == 0
   op = 'init';
end

if strcmp(op,'init')

   %use provided index if valid
   index = [];
   if exist('data','var') == 1
      if isstruct(data)
         if isfield(data,'path') && isfield(data,'filename')
            index = data;
         end
      end
   end

   res = get(0,'ScreenSize');
   bgcolor = [0.95 0.95 0.95];

   if length(findobj) > 1
      h_fig = findobj('Tag','dlgSearchData');
      if ~isempty(h_fig)
         if strcmp(get(h_fig,'Visible'),'off')  %check for bad initialization, delete instance
            delete(h_fig)
            h_fig = [];
         end
      end
   else
      h_fig = [];
   end

   if ~isempty(h_fig)  %set focus to existing dialog

      figure(h_fig(end))
      drawnow

   else  %create new dialog

      loadpath = pwd;
      savepath = loadpath;

      %try to get working paths from editor windows
      if ~isempty(findobj)
         h_editor = findobj('Tag','dlgDSEditor');
         if ~isempty(h_editor)
            loadpath = get(findobj(h_editor(1),'Tag','mnuLoad'),'UserData');
            savepath = get(findobj(h_editor(1),'Tag','mnuSave'),'UserData');
         end
      end

      user_registration = [];

      %try to load user registration info
      if exist('gce_user_registration.mat','file') == 2
         v = load('gce_user_registration.mat');
         if isfield(v,'registration')
            user_registration = v.registration;
         end
      end

      if res(4) <= 810
         voffset = 125;  %general vertical offset
         voffset2 = 135;  %command button offset
         hoffset = 90;
         figheight = 685;
      else
         voffset = 0;
         voffset2 = 0;
         hoffset = 0;
         figheight = 810;
      end

      %test for network features
      if exist('urlwrite','file') == 2 || exist('urlwrite','file') == 6
         netfeatures = 'on';
      else
         netfeatures = 'off';
      end

      %init array of supported metadata query fields
      s_metafields = [];
      if exist('search_data.mat','file') == 2
         try
            v = load('search_data.mat');
         catch
            v = struct('null','');
         end
         if isfield(v,'metafields')
            s_metafields = v.metafields;  %overwrite defaults with stored values
         end
      end
      if ~isempty(s_metafields)
         metafields = [{s_metafields.Field}',{s_metafields.Label}',{s_metafields.SearchType}'];
         metafields = [metafields(:,1:3) ; ...
               {'AnyText','Any Text','contains'}];
      else
         metafields = {'Title','Title Text','contains'; ...
               'Abstract','Abstract Text','contains'; ...
               'Methods','Methods Text','contains'; ...
               'Study','Study Text','contains'; ...
               'CoreArea','Core Area','contains'; ...
               'Accession','Accession','starts'; ...
               'AnyText','Any Text','contains'};
      end

      str_popmetafield = concatcellcols([metafields(:,2),repmat({' '},size(metafields,1),1), ...
            strrep(strrep(strrep(metafields(:,3),'contains','Contains'),'exact','Is'),'starts','Begins With'), ...
            repmat({':'},size(metafields,1),1)]);

      h_fig = figure('Name','GCE Data Search Engine', ...
         'Visible','off', ...
         'Position',[max(0,(res(3)-867).*0.5) max(0,(res(4)-figheight).*0.5) 867 figheight], ...
         'Color',[0.85 0.85 0.85], ...
         'KeyPressFcn','figure(gcf)', ...
         'MenuBar','none', ...
         'Tag','dlgSearchData', ...
         'ToolBar','none', ...
         'Resize','off', ...
         'NumberTitle','off', ...
         'CloseRequestFcn','ui_search_data(''close'')', ...
         'DefaultuicontrolUnits','pixels');

      if mlversion >= 7
         set(h_fig,'WindowStyle','normal')
         set(h_fig,'DockControls','off')
      end

      %create menus
      h_mnuFile = uimenu('Parent',h_fig, ...
         'Label','File', ...
         'Tag','mnuFile');

      h_mnuOptions = uimenu('Parent',h_fig, ...
         'Label','Options', ...
         'Tag','mnuOptions');

      h_mnuTools = uimenu('Parent',h_fig, ...
         'Label','Tools', ...
         'Tag','mnuTools');

      h_mnuHelp = uimenu('Parent',h_fig, ...
         'Label','Help', ...
         'Tag','mnuHelp');

      uimenu('Parent',h_mnuFile, ...
         'Label','Load Workspace', ...
         'Accelerator','L', ...
         'Callback','ui_search_data(''loadall'')', ...
         'Tag','mnuLoadAll');

      h_mnuSaveAll = uimenu('Parent',h_mnuFile, ...
         'Label','Save Workspace', ...
         'Accelerator','S', ...
         'Callback','ui_search_data(''saveall'')', ...
         'Tag','mnuSaveAll');

      h_mnuCopy = uimenu('Parent',h_mnuFile, ...
         'Label','Copy Data Sets', ...
         'Separator','on', ...
         'Accelerator','C', ...
         'Tag','mnuCopy', ...
         'Enable','off', ...
         'Callback','ui_search_data(''copy'')');

      h_mnuExport = uimenu('Parent',h_mnuFile, ...
         'Label','Export Data Sets', ...
         'Enable','off', ...
         'Tag','mnuExport');

      h_mnuJoin = uimenu('Parent',h_mnuFile, ...
         'Label','Join Data Sets', ...
         'Separator','on', ...
         'Tag','mnuJoin');

      uimenu('Parent',h_mnuJoin, ...
         'Label','Manual Key Selection', ...
         'Accelerator','J', ...
         'Callback','ui_search_data(''join'')', ...
         'UserData','manual');

      uimenu('Parent',h_mnuJoin, ...
         'Label','Automatic Date/Time Join', ...
         'Callback','ui_search_data(''join'')', ...
         'UserData','auto');

      h_mnuMerge = uimenu('Parent',h_mnuFile, ...
         'Label','Merge Data Sets', ...
         'Tag','mnuMerge', ...
         'Enable','off');

      uimenu('Parent',h_mnuMerge, ...
         'Label','All Records', ...
         'Accelerator','M', ...
         'Tag','mnuMergeDate', ...
         'Callback','ui_search_data(''merge'')', ...
         'UserData','date');

      uimenu('Parent',h_mnuMerge, ...
         'Label','Time-Series Merge (overwrite older records)', ...
         'Tag','mnuMergeDateTrim', ...
         'Callback','ui_search_data(''merge'')', ...
         'UserData','datetrim');

      uimenu('Parent',h_mnuMerge, ...
         'Label','Time-Series Merge (add newer records)', ...
         'Tag','mnuMergeDateTrim2', ...
         'Callback','ui_search_data(''merge'')', ...
         'UserData','datetrim2');

      h_mnuExportText = uimenu('Parent',h_mnuExport, ...
         'Label','Text Format', ...
         'Tag','mnuExportText');

      h_mnuExportML = uimenu('Parent',h_mnuExport, ...
         'Label','MATLAB Format', ...
         'Tag','mnuExportML');

      uimenu('Parent',h_mnuExportText, ...
         'Label','Tab-delimited Data', ...
         'Callback','ui_search_data(''export'')', ...
         'Tag','mnuTextTab', ...
         'UserData','texttab');

      uimenu('Parent',h_mnuExportText, ...
         'Label','Comma-separated Value (CSV)', ...
         'Callback','ui_search_data(''export'')', ...
         'Tag','mnuTextCSV', ...
         'UserData','textcsv');

      uimenu('Parent',h_mnuExportText, ...
         'Label','Comma-delimited Data', ...
         'Callback','ui_search_data(''export'')', ...
         'Tag','mnuTextComma', ...
         'UserData','textcomma');

      uimenu('Parent',h_mnuExportText, ...
         'Label','Space-delimited Data', ...
         'Callback','ui_search_data(''export'')', ...
         'Tag','mnuTextSpace', ...
         'UserData','textspace');

      uimenu('Parent',h_mnuExportML, ...
         'Label','Columns as Variables', ...
         'Callback','ui_search_data(''export'')', ...
         'Tag','mnuMLVars', ...
         'UserData','mlvars');

      uimenu('Parent',h_mnuExportML, ...
         'Label','Single Data Matrix', ...
         'Callback','ui_search_data(''export'')', ...
         'Tag','mnuMLMat', ...
         'UserData','mlmat');

      h_mnuLoadIndex = uimenu('Parent',h_mnuFile, ...
         'Label','Load Search Index', ...
         'Separator','on', ...
         'Tag','mnuLoadIndex');

      uimenu('Parent',h_mnuLoadIndex, ...
         'Label','Local Index File', ...
         'Callback','ui_search_data(''loadindex'')', ...
         'Tag','mnuLoadIndexLocal');

      uimenu('Parent',h_mnuLoadIndex, ...
         'Label','GCE Web Index File (WWW)', ...
         'Callback','ui_search_data(''webload'')', ...
         'Enable',netfeatures, ...
         'Tag','mnuLoadIndexWeb');

      h_mnuMergeIndex = uimenu('Parent',h_mnuFile, ...
         'Label','Merge Search Index', ...
         'Enable','off', ...
         'Tag','mnuMergeIndex');

      uimenu('Parent',h_mnuMergeIndex, ...
         'Label','Local Index File', ...
         'Callback','ui_search_data(''mergeindex'')', ...
         'Tag','mnuMergeIndex');

      uimenu('Parent',h_mnuMergeIndex, ...
         'Label','GCE Web Index File (WWW)', ...
         'Callback','ui_search_data(''webindex'',''merge'')', ...
         'Enable',netfeatures, ...
         'Tag','mnuMergeIndexWeb');

      h_mnuSaveIndex = uimenu('Parent',h_mnuFile, ...
         'Label','Save Search Index', ...
         'Callback','ui_search_data(''saveindex'')', ...
         'Enable','off', ...
         'Tag','mnuSaveIndex');

      h_mnuClearIndex = uimenu('Parent',h_mnuFile, ...
         'Label','Clear Search Index', ...
         'Separator','on', ...
         'Enable','off', ...
         'Callback','ui_search_data(''clearindex'')', ...
         'Tag','mnuClearIndex');

      uimenu('Parent',h_mnuFile, ...
         'Label','Clear Temporary Files', ...
         'Callback','ui_search_data(''clearcache'',''search_temp'')', ...
         'Tag','mnuClearTemp');

      uimenu('Parent',h_mnuFile, ...
         'Label','Clear Web Cache Files', ...
         'Callback','ui_search_data(''clearcache'',''search_webcache'')', ...
         'Enable',netfeatures, ...
         'Tag','mnuClearCache');

      uimenu('Parent',h_mnuFile, ...
         'Label','Close Window', ...
         'Separator','on', ...
         'Accelerator','Q', ...
         'Callback','ui_search_data(''close'')', ...
         'Tag','mnuQuit');

      uimenu('Parent',h_mnuFile, ...
         'Label','Exit MATLAB', ...
         'Separator','on', ...
         'Accelerator','X', ...
         'Callback','ui_search_data(''exit'')', ...
         'Tag','mnuExit');

      h_mnuMetadata = uimenu('Parent',h_mnuOptions, ...
         'Label','Metadata Style', ...
         'Tag','mnuMetadata');

      uimenu('Parent',h_mnuMetadata, ...
         'Label','GCE Standard', ...
         'Checked','on', ...
         'Callback','ui_search_data(''metaformat'')', ...
         'Tag','mnuMetaGCE', ...
         'UserData','GCE');

      uimenu('Parent',h_mnuMetadata, ...
         'Label','LTER FLED', ...
         'Checked','off', ...
         'Callback','ui_search_data(''metaformat'')', ...
         'Tag','mnuMetaFLED', ...
         'UserData','FLED');

      uimenu('Parent',h_mnuMetadata, ...
         'Label','Abbreviated', ...
         'Checked','off', ...
         'Callback','ui_search_data(''metaformat'')', ...
         'Tag','mnuMetaBrief', ...
         'UserData','Brief');

      uimenu('Parent',h_mnuMetadata, ...
         'Label','GCE XML', ...
         'Checked','off', ...
         'Callback','ui_search_data(''metaformat'')', ...
         'Tag','mnuMetaXML', ...
         'UserData','XML');

      uimenu('Parent',h_mnuMetadata, ...
         'Label','None (no metadata)', ...
         'Checked','off', ...
         'Callback','ui_search_data(''metaformat'')', ...
         'Tag','mnuMetaNone', ...
         'UserData','');

      h_mnuFlags = uimenu('Parent',h_mnuOptions, ...
         'Label','Q/C Flag Options', ...
         'Tag','mnuFlags');

      uimenu('Parent',h_mnuFlags, ...
         'Label','Retain all flagged values', ...
         'Checked','off', ...
         'Callback','ui_search_data(''flagopt'')', ...
         'Tag','mnuFlagRetain', ...
         'UserData',{'',''});

      uimenu('Parent',h_mnuFlags, ...
         'Label','Remove all flagged values', ...
         'Checked','off', ...
         'Callback','ui_search_data(''flagopt'')', ...
         'Tag','mnuFlagNullAll', ...
         'UserData',{'null',''});

      uimenu('Parent',h_mnuFlags, ...
         'Label','Remove values flagged ''I'' (invalid)', ...
         'Checked','on', ...
         'Callback','ui_search_data(''flagopt'')', ...
         'Tag','mnuFlagNullI', ...
         'UserData',{'null','I'});

      uimenu('Parent',h_mnuFlags, ...
         'Label','Delete rows with flagged Values', ...
         'Checked','off', ...
         'Callback','ui_search_data(''flagopt'')', ...
         'Tag','mnuFlagCull', ...
         'UserData',{'cull',''});

      uimenu('Parent',h_mnuFlags, ...
         'Label','Delete rows with values flagged ''I'' (invalid)', ...
         'Checked','off', ...
         'Callback','ui_search_data(''flagopt'')', ...
         'Tag','mnuFlagCullI', ...
         'UserData',{'cull','I'});

      h_mnuHeader = uimenu('Parent',h_mnuOptions, ...
         'Label','Text File Header', ...
         'Separator','on', ...
         'Tag','mnuHeader');

      uimenu('Parent',h_mnuHeader, ...
         'Label','Metadata Header', ...
         'Checked','off', ...
         'Callback','ui_search_data(''headerformat'')', ...
         'Tag','mnuHeaderFull', ...
         'UserData','F');

      uimenu('Parent',h_mnuHeader, ...
         'Label','Brief Header (separate metadata)', ...
         'Checked','on', ...
         'Callback','ui_search_data(''headerformat'')', ...
         'Tag','mnuHeaderBrief', ...
         'UserData','SB');

      uimenu('Parent',h_mnuHeader, ...
         'Label','Column Titles (separate metadata)', ...
         'Checked','off', ...
         'Callback','ui_search_data(''headerformat'')', ...
         'Tag','mnuHeaderTitles', ...
         'UserData','ST');

      uimenu('Parent',h_mnuHeader, ...
         'Label','None (separate metadata)', ...
         'Checked','off', ...
         'Callback','ui_search_data(''headerformat'')', ...
         'Tag','mnuHeaderNone', ...
         'UserData','SN');

      h_mnuMergeMeta = uimenu('Parent',h_mnuOptions, ...
         'Label','Metadata Merge Option', ...
         'Separator','on', ...
         'Tag','mnuMergeMeta');

      uimenu('Parent',h_mnuMergeMeta, ...
         'Label','Merge All', ...
         'Checked','on', ...
         'Callback','ui_search_data(''metamerge'')', ...
         'Tag','mnuMergeMetaAll', ...
         'UserData','all');

      uimenu('Parent',h_mnuMergeMeta, ...
         'Label','Merge None', ...
         'Checked','off', ...
         'Callback','ui_search_data(''metamerge'')', ...
         'Tag','mnuMergeMetaNone', ...
         'UserData','none');

      uimenu('Parent',h_mnuMergeMeta, ...
         'Label','Merge Selected Sections', ...
         'Checked','off', ...
         'Callback','ui_search_data(''metamerge'')', ...
         'Tag','mnuMergeMetaPick', ...
         'UserData','pick');

      h_mnuLockFlags = uimenu('Parent',h_mnuOptions, ...
         'Label','Flag Merge Option', ...
         'Tag','mnuLockFlags');

      uimenu('Parent',h_mnuLockFlags, ...
         'Label','Lock Flags', ...
         'Checked','on', ...
         'Callback','ui_search_data(''lockflags'')', ...
         'Tag','mnuLockFlagsYes', ...
         'UserData',1);

      uimenu('Parent',h_mnuLockFlags, ...
         'Label','Do Not Lock Flags', ...
         'Checked','off', ...
         'Callback','ui_search_data(''lockflags'')', ...
         'Tag','mnuLockFlagsNo', ...
         'UserData',0);

      h_mnuMergeDatasetNames = uimenu('Parent',h_mnuOptions, ...
         'Label','Dataset Name Option', ...
         'Tag','mnuMergeDatasetNames');

      uimenu('Parent',h_mnuMergeDatasetNames, ...
         'Label','Add Dataset Name Column on Merge', ...
         'Tag','mnuMergeDatasetNamesAdd', ...
         'Callback','ui_search_data(''datasetnames'')', ...
         'Checked','on', ...
         'UserData',1);

      uimenu('Parent',h_mnuMergeDatasetNames, ...
         'Label','No Dataset Name Column on Merge', ...
         'Tag','mnuMergeDatasetNamesNone', ...
         'Callback','ui_search_data(''datasetnames'')', ...
         'Checked','off', ...
         'UserData',0);

      h_mnuAutoSave = uimenu('Parent',h_mnuOptions, ...
         'Label','Auto-Save Workspace on Close', ...
         'Separator','on', ...
         'Tag','mnuAutoSave');

      uimenu('Parent',h_mnuAutoSave, ...
         'Label','Yes', ...
         'Callback','ui_search_data(''autosave'')', ...
         'Checked','on', ...
         'Tag','mnuAutoSaveYes', ...
         'UserData',1);

      uimenu('Parent',h_mnuAutoSave, ...
         'Label','No', ...
         'Callback','ui_search_data(''autosave'')', ...
         'Checked','off', ...
         'Tag','mnuAutoSaveNo', ...
         'UserData',0);

      h_mnuAutoAdd = uimenu('Parent',h_mnuOptions, ...
         'Label','Auto-Add Integrated Datasets', ...
         'Tag','mnuAutoAdd');

      uimenu('Parent',h_mnuAutoAdd, ...
         'Label','Yes', ...
         'Callback','ui_search_data(''autoadd'')', ...
         'Checked','off', ...
         'Tag','mnuAutoAddYes', ...
         'UserData',1);

      uimenu('Parent',h_mnuAutoAdd, ...
         'Label','No', ...
         'Callback','ui_search_data(''autoadd'')', ...
         'Checked','on', ...
         'Tag','mnuAutoAddNo', ...
         'UserData',0);

      h_mnuAutoDelete = uimenu('Parent',h_mnuOptions, ...
         'Label','Auto-Delete Temp Files', ...
         'Tag','mnuAutoDelete');

      uimenu('Parent',h_mnuAutoDelete, ...
         'Label','Yes', ...
         'Callback','ui_search_data(''autodelete'')', ...
         'Checked','off', ...
         'Tag','mnuAutoDeleteYes', ...
         'UserData',1);

      uimenu('Parent',h_mnuAutoDelete, ...
         'Label','No', ...
         'Callback','ui_search_data(''autodelete'')', ...
         'Checked','on', ...
         'Tag','mnuAutoDeleteNo', ...
         'UserData',0);

      h_mnuShowHideQueries = uimenu('Parent',h_mnuOptions, ...
         'Label','Hide Query History', ...
         'Separator','on', ...
         'Callback','ui_search_data(''showhide'')', ...
         'Tag','mnuShowHideQueries');

      uimenu('Parent',h_mnuTools, ...
         'Label','Update GCE Registration', ...
         'Callback','ui_gce_register(''init'',''ui_search_data(''''register'''',registration)'')', ...
         'Tag','mnuRegister');

      uimenu('Parent',h_mnuTools, ...
         'Label','GCE Data Editor', ...
         'Separator','on', ...
         'Callback','ui_editor(''init'')', ...
         'Tag','mnuEditor');

      uimenu('Parent',h_mnuTools, ...
         'Label','GCE Data Merge Tool', ...
         'Callback','ui_search_data(''mergedata'')', ...
         'Tag','mnuMergeData');

      uimenu('Parent',h_mnuTools, ...
         'Label','GCE Mapping Toolbox', ...
         'Callback','loadmap;');

      uimenu('Parent',h_mnuHelp, ...
         'Label','View Documentation', ...
         'Accelerator','H', ...
         'Callback','ui_viewdocs(''init'',''ui_search_data'')', ...
         'Tag','mnuDocs');

      uimenu('Parent',h_mnuHelp, ...
         'Label','About the GCE Data Toolbox', ...
         'Separator','on', ...
         'Callback','ui_aboutgce', ...
         'Tag','mnuAbout');

      %create uicontrols
      uicontrol('Parent',h_fig, ...
         'BackgroundColor',[.8 .8 .8], ...
         'Position',[1 1 866 809-voffset], ...
         'Style','frame', ...
         'Tag','frame');

      uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'Position',[5 435-voffset 858 370], ...
         'Style','frame', ...
         'Tag','frame');

      h_frmMiddle = uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'Position',[5 315-voffset 858 115], ...
         'Style','frame', ...
         'Tag','frame');

      h_frmBottom = uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'Position',[5 5 858 305-voffset], ...
         'Style','frame', ...
         'Tag','frame');

      uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',11, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.6], ...
         'HorizontalAlignment','left', ...
         'Position',[20 776-voffset 647 25], ...
         'String','Indexed Directories', ...
         'Style','text', ...
         'Tag','StaticText1');

      h_lblDataSets = uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'ForegroundColor',[0 0 0], ...
         'HorizontalAlignment','left', ...
         'Position',[640 776-voffset 150 20], ...
         'String','(0 data sets)', ...
         'Style','text', ...
         'Tag','lblDataSets');

      h_lstPaths = uicontrol('Parent',h_fig, ...
         'BackgroundColor',[1 1 1], ...
         'Position',[15 700-voffset 740 75], ...
         'String','', ...
         'Style','listbox', ...
         'Tag','lstPaths', ...
         'FontSize',9, ...
         'Max',1, ...
         'Max',10, ...
         'Callback','ui_search_data(''showpath'')', ...
         'TooltipString','Pathnames to index', ...
         'Value',1);

      h_cmdAddPath = uicontrol('Parent',h_fig, ...
         'Callback','ui_search_data(''addpath'')', ...
         'FontSize',9, ...
         'Position',[762 751-voffset 90 24], ...
         'String','Add', ...
         'Tag','cmdAddPath', ...
         'TooltipString','Add a directory to the index');

      h_cmdRemPath = uicontrol('Parent',h_fig, ...
         'Callback','ui_search_data(''rempath'')', ...
         'FontSize',9, ...
         'Position',[762 726-voffset 90 24], ...
         'String','Remove', ...
         'Tag','cmdRemPath', ...
         'Enable','off', ...
         'TooltipString','Remove selected directory from the index');

      h_cmdRefresh = uicontrol('Parent',h_fig, ...
         'Callback','ui_search_data(''refresh'')', ...
         'FontSize',9, ...
         'Position',[762 701-voffset 90 24], ...
         'String','Refresh', ...
         'Tag','cmdRefresh', ...
         'Enable','off', ...
         'TooltipString','Refresh the search index, removing missing files and adding new files');

      h_chkSubDir = uicontrol('Parent',h_fig, ...
         'Style','checkbox', ...
         'BackgroundColor',bgcolor, ...
         'FontSize',8, ...
         'Position',[760 676-voffset 100 18], ...
         'String','Subdirectories?', ...
         'Value',1, ...
         'TooltipString','Option to analyze files in the selected directory plus all subdirectories', ...
         'Tag','chkSubDir');

      uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',12, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.6], ...
         'HorizontalAlignment','left', ...
         'Position',[20 670-voffset 647 25], ...
         'String','Search Criteria', ...
         'Style','text', ...
         'Tag','lblMatches');

      h_popMetaField = uicontrol('Parent',h_fig, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',10, ...
         'Position',[25 648-voffset 170 20], ...
         'String',str_popmetafield, ...
         'Value',length(str_popmetafield), ...
         'Style','popupmenu', ...
         'HorizontalAlignment','left', ...
         'TooltipString','Select a general metadata section to search', ...
         'Tag','popMetaField');

      h_editMetaStr = uicontrol('Parent',h_fig, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'Position',[197 645-voffset 167 22], ...
         'Style','edit', ...
         'Tag','editMetaStr');

      h_popDateType = uicontrol('Parent',h_fig, ...
         'Style','popupmenu', ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',10, ...
         'Position',[26 620-voffset 113 20], ...
         'HorizontalAlignment','left', ...
         'String',{'Date Range:';'Contains Date:'}, ...
         'Value',1, ...
         'Callback','ui_search_data(''datetype'')', ...
         'TooltipString','Select a type of date search to perform', ...
         'Tag','popDateType');

      h_editDateStart = uicontrol('Parent',h_fig, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'Position',[140 617-voffset 100 22], ...
         'Style','edit', ...
         'Callback','ui_search_data(''date'')', ...
         'Tag','editDateStart');

      h_lblDateSep = uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'HorizontalAlignment','center', ...
         'Position',[240 617-voffset 25 20], ...
         'String','to', ...
         'Style','text', ...
         'Tag','lblDateSep');

      h_editDateEnd = uicontrol('Parent',h_fig, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'Position',[265 617-voffset 100 22], ...
         'Style','edit', ...
         'Callback','ui_search_data(''date'')', ...
         'Tag','editDateEnd');

      uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'Position',[30 590-voffset 110 20], ...
         'HorizontalAlignment','left', ...
         'String','Author Name:', ...
         'Style','text', ...
         'Tag','StaticText1');

      h_editAuthor = uicontrol('Parent',h_fig, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'Position',[140 590-voffset 225 22], ...
         'Style','edit', ...
         'TooltipString','Enter a partial or complete data set author name', ...
         'Tag','editAuthor');

      uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'Position',[30 563-voffset 110 20], ...
         'HorizontalAlignment','left', ...
         'String','Keywords:', ...
         'Style','text', ...
         'Tag','StaticText1');

      h_editKeyword = uicontrol('Parent',h_fig, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'Position',[140 563-voffset 225 22], ...
         'Style','edit', ...
         'TooltipString','Enter one or more keywords, separated by commas', ...
         'Tag','editKeyword');

      uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'ForegroundColor',[.5 .5 .5], ...
         'FontSize',10, ...
         'Position',[367 563-voffset 60 20], ...
         'HorizontalAlignment','left', ...
         'String','(multiple)', ...
         'Style','text', ...
         'Tag','StaticText1');

      uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'Position',[30 536-voffset 110 20], ...
         'HorizontalAlignment','left', ...
         'String','Species Names:', ...
         'Style','text', ...
         'Tag','StaticText1');

      h_editTaxa = uicontrol('Parent',h_fig, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'Position',[140 536-voffset 225 22], ...
         'Style','edit', ...
         'TooltipString','Enter one or more species names, separated by commas', ...
         'Tag','editTaxa');

      uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'ForegroundColor',[.5 .5 .5], ...
         'FontSize',10, ...
         'Position',[367 536-voffset 60 20], ...
         'HorizontalAlignment','left', ...
         'String','(multiple)', ...
         'Style','text', ...
         'Tag','StaticText1');

      uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'Position',[30 510-voffset 110 20], ...
         'HorizontalAlignment','left', ...
         'String','Data Columns:', ...
         'Style','text', ...
         'Tag','StaticText1');

      h_lblVars = uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'ForegroundColor',[0 0 .8], ...
         'FontSize',9, ...
         'HorizontalAlignment','center', ...
         'Position',[15 475-voffset 110 20], ...
         'String','(0 selected)', ...
         'Style','text', ...
         'Tag','StaticText1');

      h_lstVars = uicontrol('Parent',h_fig, ...
         'BackgroundColor',[1 1 1], ...
         'Position',[140 445-voffset 225 85], ...
         'String','<any variable>', ...
         'FontSize',9, ...
         'Style','listbox', ...
         'ListBoxTop',1, ...
         'Min',1, ...
         'Max',10, ...
         'Tag','lstVars', ...
         'Callback','ui_search_data(''varlist'')', ...
         'TooltipString','Choose one or more variables to search for', ...
         'Value',1);

      uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'ForegroundColor',[.5 .5 .5], ...
         'FontSize',10, ...
         'Position',[367 510-voffset 60 20], ...
         'HorizontalAlignment','left', ...
         'String','(multiple)', ...
         'Style','text', ...
         'Tag','StaticText1');

      uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'HorizontalAlignment','left', ...
         'Position',[420 645-voffset 90 20], ...
         'String','Study Site:', ...
         'Style','text', ...
         'Tag','StaticText1');

      sitestr = {'<any site>'};
      if exist('geo_polygons.mat','file') == 2
         vars = load('geo_polygons.mat');
         if isfield(vars,'polygons')
            polygons = vars.polygons;
            sitecodes = {polygons.SiteCode}';
            sitenames = {polygons.SiteName}';
            str = concatcellcols([sitecodes,sitenames],' - ');
            sitestr = [sitestr ; str];
         end
      end
      h_popSite = uicontrol('Parent',h_fig, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'Position',[513 645-voffset 230 22], ...
         'String',sitestr, ...
         'Style','popupmenu', ...
         'HorizontalAlignment','left', ...
         'Value',1, ...
         'UserData',[{''} ; sitecodes], ...
         'TooltipString','Select a GCE sampling site', ...
         'Tag','popSite');

      uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'HorizontalAlignment','left', ...
         'Position',[420 620-voffset 110 20], ...
         'String','Bounding Box:', ...
         'Style','text', ...
         'Tag','StaticText1');

      uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'Position',[542 615-voffset 45 20], ...
         'String','N Lat', ...
         'Style','text', ...
         'Tag','StaticText1');

      h_editNLat = uicontrol('Parent',h_fig, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'Position',[590 614-voffset 75 22], ...
         'Style','edit', ...
         'String','', ...
         'UserData',[], ...
         'Callback','ui_search_data(''coords'')', ...
         'Tag','editNLat');

      uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'Position',[466 588-voffset 45 20], ...
         'String','W Lon', ...
         'Style','text', ...
         'Tag','StaticText1');

      h_editWLon = uicontrol('Parent',h_fig, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'Position',[513 587-voffset 75 22], ...
         'Style','edit', ...
         'String','', ...
         'UserData',[], ...
         'Callback','ui_search_data(''coords'')', ...
         'Tag','editWLon');

      uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'Position',[739 588-voffset 45 20], ...
         'String','E Lon', ...
         'Style','text', ...
         'Tag','StaticText1');

      h_editELon = uicontrol('Parent',h_fig, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'Position',[665 587-voffset 75 22], ...
         'Style','edit', ...
         'String','', ...
         'UserData',[], ...
         'Callback','ui_search_data(''coords'')', ...
         'Tag','editELon');

      uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'Position',[545 562-voffset 45 20], ...
         'String','S Lat', ...
         'Style','text', ...
         'Tag','StaticText1');

      h_editSLat = uicontrol('Parent',h_fig, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'Position',[590 561-voffset 75 22], ...
         'Style','edit', ...
         'String','', ...
         'UserData',[], ...
         'Callback','ui_search_data(''coords'')', ...
         'Tag','editSLat');

      if exist('gce_studyarea.fig','file') == 2
         vis = 'on';
      else
         vis = 'off';
      end
      h_cmdMap = uicontrol('Parent',h_fig, ...
         'Callback','ui_search_data(''map'')', ...
         'FontSize',9, ...
         'Position',[590 588-voffset 72 22], ...
         'String','Map', ...
         'Tag','cmdMap', ...
         'Enable',vis, ...
         'TooltipString','View bounding box or select bounding box from a map');

      h_radioMapExclusive = uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'Callback','ui_search_data(''bboxoption'')', ...
         'FontSize',9, ...
         'Position',[675 558-voffset 180 18], ...
         'String','Datasets enclosed by bounds', ...
         'Style','radiobutton', ...
         'TooltipString','Data set bounding box must be entirely within these limits', ...
         'Tag','radioMapExclusive', ...
         'Value',1);

      h_radioMapInclusive = uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'Callback','ui_search_data(''bboxoption'')', ...
         'FontSize',9, ...
         'Position',[675 540-voffset 180 18], ...
         'String','Datasets overlapping bounds', ...
         'Style','radiobutton', ...
         'Tag','radioMapInclusive', ...
         'TooltipString','Data set bounding box must overlap these limits', ...
         'Value',0);

      uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'Position',[465 445-voffset 270 85], ...
         'Style','frame', ...
         'Tag','frame');

      uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'ForegroundColor',[0 0 0], ...
         'HorizontalAlignment','left', ...
         'Position',[470 505-voffset 150 20], ...
         'String','Search Options:', ...
         'Style','text', ...
         'Tag','StaticText1');

      h_radioMatchAll = uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'Callback','ui_search_data(''searchtype'')', ...
         'FontSize',10, ...
         'Position',[475 485-voffset 125 18], ...
         'String','Match all criteria', ...
         'Style','radiobutton', ...
         'Tag','radioMatchAll', ...
         'Value',1);

      h_radioMatchAny = uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'Callback','ui_search_data(''searchtype'')', ...
         'FontSize',10, ...
         'Position',[600 485-voffset 125 18], ...
         'String','Match any criteria', ...
         'Style','radiobutton', ...
         'Tag','radioMatchAny', ...
         'Value',0);

      h_chkMatchCase = uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'Position',[475 467-voffset 220 18], ...
         'String','Case sensitive text searches', ...
         'Style','checkbox', ...
         'Value',0, ...
         'Tag','chkMatchCase');

      h_chkSaveQueries = uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'Position',[475 449-voffset 220 18], ...
         'String','Save new queries to history list', ...
         'Style','checkbox', ...
         'Value',1, ...
         'Tag','chkSaveQueries');

      uicontrol('Parent',h_fig, ...
         'Callback','ui_search_data(''resetbbox'')', ...
         'FontSize',9, ...
         'Position',[765 505-voffset 90 24], ...
         'String','Clear Bounds', ...
         'Tag','cmdResetBBox', ...
         'Enable','on', ...
         'TooltipString','Clear all bounding box limit fields');

      uicontrol('Parent',h_fig, ...
         'Callback','ui_search_data(''reset'')', ...
         'FontSize',9, ...
         'Position',[765 480-voffset 90 24], ...
         'String','Clear All', ...
         'Tag','cmdReset', ...
         'Enable','on', ...
         'TooltipString','Clear all search criteria fields');

      h_cmdSearch = uicontrol('Parent',h_fig, ...
         'Callback','ui_search_data(''search'')', ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'Position',[765 445-voffset 90 24], ...
         'String','SEARCH', ...
         'Tag','cmdSearch', ...
         'Enable','off', ...
         'TooltipString','Search for matching data sets');

      h_lblQueryHistory = uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',11, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.6], ...
         'HorizontalAlignment','left', ...
         'Position',[20 400-voffset 240 25], ...
         'String','Query History', ...
         'Style','text', ...
         'Tag','h_lblQueryHistory');

      h_cmdHideHistory = uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',8, ...
         'FontWeight','bold', ...
         'String','X', ...
         'HorizontalAlignment','center', ...
         'Position',[832 408-voffset 20 18], ...
         'TooltipString','Close the query history pane', ...
         'Callback','ui_search_data(''showhide'')', ...
         'Style','pushbutton', ...
         'Tag','h_cmdHIdeHistory');

      h_lstQueries = uicontrol('Parent',h_fig, ...
         'Style','listbox', ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'ForegroundColor',[0 0 0], ...
         'Position',[15 325-voffset 740 75], ...
         'Callback','ui_search_data(''queryclick'')', ...
         'String','', ...
         'Min',1, ...
         'Max',2, ...
         'Value',1, ...
         'Tag','lstQueries');

      h_cmdLoadQuery = uicontrol('Parent',h_fig, ...
         'Style','pushbutton', ...
         'Position',[762 377-voffset 90 24], ...
         'FontSize',9, ...
         'String','Load Query', ...
         'Enable','off', ...
         'Callback','ui_search_data(''loadquery'')', ...
         'ToolTipString','Load the selected query parameters into the respective query criteria fields', ...
         'Tag','cmdLoadQuery');

      h_cmdClearQuery = uicontrol('Parent',h_fig, ...
         'Style','pushbutton', ...
         'Position',[762 352-voffset 90 24], ...
         'String','Clear Query', ...
         'Enable','off', ...
         'FontSize',9, ...
         'Callback','ui_search_data(''clearquery'')', ...
         'ToolTipString','Clear the selected query from the list', ...
         'Tag','cmdClearQuery');

      h_cmdClearQueryAll = uicontrol('Parent',h_fig, ...
         'Style','pushbutton', ...
         'Position',[762 327-voffset 90 24], ...
         'String','Clear All', ...
         'Enable','off', ...
         'FontSize',9, ...
         'Callback','ui_search_data(''clearqueryall'')', ...
         'ToolTipString','Clear all save queries from the list', ...
         'Tag','cmdClearQueryAll');

      h_lblSearchResults = uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',11, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.6], ...
         'HorizontalAlignment','left', ...
         'Position',[20 280-voffset 240 25], ...
         'String','Cumulative Search Results', ...
         'Style','text', ...
         'Tag','h_lblSearchResults');

      h_lblViewMetadata = uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'ForegroundColor',[0 0 0], ...
         'HorizontalAlignment','center', ...
         'Position',[270 278-voffset 270 20], ...
         'String','(double click on title to view metadata)', ...
         'Style','text', ...
         'Tag','h_lblViewMetadata');

      h_lblMatches = uicontrol('Parent',h_fig, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'ForegroundColor',[0 0 0], ...
         'HorizontalAlignment','left', ...
         'Position',[640 278-voffset 150 20], ...
         'String','(0 matches)', ...
         'Style','text', ...
         'Tag','lblMatches');

      h_lstMatches = uicontrol('Parent',h_fig, ...
         'BackgroundColor',[1 1 1], ...
         'Callback','ui_search_data(''matches'')', ...
         'Position',[15 15 740-hoffset 263-voffset], ...
         'String','', ...
         'FontSize',9, ...
         'Style','listbox', ...
         'Tag','lstMatches', ...
         'Min',0, ...
         'Max',2, ...
         'Value',1);

      h_cmdSort = uicontrol('Parent',h_fig, ...
         'Callback','ui_search_data(''sort'')', ...
         'FontSize',9, ...
         'Position',[762-hoffset 255-voffset2 90 24], ...
         'String','Sort', ...
         'Tag','cmdSort', ...
         'Enable','off', ...
         'TooltipString','Sort matched data sets by accession and title');

      h_cmdSelectAll = uicontrol('Parent',h_fig, ...
         'Callback','ui_search_data(''select'')', ...
         'FontSize',9, ...
         'Position',[762-hoffset 230-voffset2 90 24], ...
         'String','Select All', ...
         'Tag','cmdSelectAll', ...
         'Enable','off', ...
         'UserData','all', ...
         'TooltipString','Select all matched data sets');

      h_cmdSelectNone = uicontrol('Parent',h_fig, ...
         'Callback','ui_search_data(''select'')', ...
         'FontSize',9, ...
         'Position',[762-hoffset 205-voffset2 90 24], ...
         'String','Select None', ...
         'Tag','cmdSelectNone', ...
         'Enable','off', ...
         'UserData','none', ...
         'TooltipString','Clear data set selections');

      h_cmdClear = uicontrol('Parent',h_fig, ...
         'Callback','ui_search_data(''clear'')', ...
         'FontSize',9, ...
         'Position',[762-hoffset 180-voffset2 90 24], ...
         'String','Remove', ...
         'Tag','cmdClear', ...
         'Enable','off', ...
         'TooltipString','Remove selected datasets from the list');

      h_cmdClearAll = uicontrol('Parent',h_fig, ...
         'Callback','ui_search_data(''clearall'')', ...
         'FontSize',9, ...
         'Position',[762-hoffset 155-voffset2 90 24], ...
         'String','Remove All', ...
         'Tag','cmdClearAll', ...
         'Enable','off', ...
         'TooltipString','Remove all datasets from the list');

      h_cmdEditor = uicontrol('Parent',h_fig, ...
         'Callback','ui_search_data(''editor'')', ...
         'FontSize',9, ...
         'Position',[762 120 90 24], ...
         'String','View/Edit', ...
         'Tag','cmdEditor', ...
         'Enable','off', ...
         'TooltipString','Open the selected data set(s) using the data structure editor tool');

      h_cmdPlotXY = uicontrol('Parent',h_fig, ...
         'Callback','ui_search_data(''plotxy'')', ...
         'FontSize',9, ...
         'Position',[762 95 90 24], ...
         'String','Plot X/YY', ...
         'Tag','cmdPlotXY', ...
         'Enable','off', ...
         'TooltipString','Create multiple Y vs X line/scatter plots for selected data columns');

      h_cmdPlotGroups = uicontrol('Parent',h_fig, ...
         'Callback','ui_search_data(''plotgroups'')', ...
         'FontSize',9, ...
         'Position',[762 70 90 24], ...
         'String','Plot Groups', ...
         'Tag','cmdPlotGroups', ...
         'Enable','off', ...
         'TooltipString','Create Y vs X line/scatter plots for selected data columns, grouped by a third column');

      h_cmdMapPlot = uicontrol('Parent',h_fig, ...
         'Callback','ui_search_data(''plotmap'')', ...
         'FontSize',9, ...
         'Position',[762 45 90 24], ...
         'String','Map Plot', ...
         'Tag','cmdMapPlot', ...
         'Enable','off', ...
         'TooltipString','Plot data values or locations on vector and raster maps');

      h_cmdSummary = uicontrol('Parent',h_fig, ...
         'Callback','ui_search_data(''summary'')', ...
         'FontSize',9, ...
         'Position',[762 20 90 24], ...
         'String','Summary', ...
         'Tag','cmdSummary', ...
         'Enable','off', ...
         'TooltipString','View a statistical summary of the selected data set');

      uih = struct('mnuMetadata',h_mnuMetadata, ...
         'mnuCopy',h_mnuCopy, ...
         'mnuJoin',h_mnuJoin, ...
         'mnuMerge',h_mnuMerge, ...
         'mnuSaveAll',h_mnuSaveAll, ...
         'mnuExport',h_mnuExport, ...
         'mnuSaveIndex',h_mnuSaveIndex, ...
         'mnuClearIndex',h_mnuClearIndex, ...
         'mnuMergeIndex',h_mnuMergeIndex, ...
         'mnuFlags',h_mnuFlags, ...
         'mnuHeader',h_mnuHeader, ...
         'mnuMergeMeta',h_mnuMergeMeta, ...
         'mnuLockFlags',h_mnuLockFlags, ...
         'mnuMergeDatasetNames',h_mnuMergeDatasetNames, ...
         'mnuShowHideQueries',h_mnuShowHideQueries, ...
         'mnuAutoSave',h_mnuAutoSave, ...
         'mnuAutoAdd',h_mnuAutoAdd, ...
         'mnuAutoDelete',h_mnuAutoDelete, ...
         'lstPaths',h_lstPaths, ...
         'lstMatches',h_lstMatches, ...
         'cmdAddPath',h_cmdAddPath, ...
         'cmdRemPath',h_cmdRemPath, ...
         'cmdRefresh',h_cmdRefresh, ...
         'cmdHideHistory',h_cmdHideHistory, ...
         'chkSubDir',h_chkSubDir, ...
         'cmdSearch',h_cmdSearch, ...
         'popMetaField',h_popMetaField, ...
         'editMetaStr',h_editMetaStr, ...
         'editKeyword',h_editKeyword, ...
         'editAuthor',h_editAuthor, ...
         'editTaxa',h_editTaxa, ...
         'popDateType',h_popDateType, ...
         'lblDateSep',h_lblDateSep, ...
         'editDateStart',h_editDateStart, ...
         'editDateEnd',h_editDateEnd, ...
         'popSite',h_popSite, ...
         'editNLat',h_editNLat, ...
         'lblVars',h_lblVars, ...
         'lstVars',h_lstVars, ...
         'editWLon',h_editWLon, ...
         'editELon',h_editELon, ...
         'editSLat',h_editSLat, ...
         'cmdMap',h_cmdMap, ...
         'chkMatchCase',h_chkMatchCase, ...
         'chkSaveQueries',h_chkSaveQueries, ...
         'radioMapInclusive',h_radioMapInclusive, ...
         'radioMapExclusive',h_radioMapExclusive, ...
         'radioMatchAny',h_radioMatchAny, ...
         'radioMatchAll',h_radioMatchAll, ...
         'frmMiddle',h_frmMiddle, ...
         'frmBottom',h_frmBottom, ...
         'lblQueryHistory',h_lblQueryHistory, ...
         'lstQueries',h_lstQueries, ...
         'cmdLoadQuery',h_cmdLoadQuery, ...
         'cmdClearQuery',h_cmdClearQuery, ...
         'cmdClearQueryAll',h_cmdClearQueryAll, ...
         'lblDataSets',h_lblDataSets, ...
         'lblSearchResults',h_lblSearchResults, ...
         'lblViewMetadata',h_lblViewMetadata, ...
         'lblMatches',h_lblMatches, ...
         'cmdEditor',h_cmdEditor, ...
         'cmdPlotXY',h_cmdPlotXY, ...
         'cmdPlotGroups',h_cmdPlotGroups, ...
         'cmdMapPlot',h_cmdMapPlot, ...
         'cmdSelectAll',h_cmdSelectAll, ...
         'cmdSelectNone',h_cmdSelectNone, ...
         'cmdClear',h_cmdClear, ...
         'cmdClearAll',h_cmdClearAll, ...
         'cmdSort',h_cmdSort, ...
         'cmdSummary',h_cmdSummary, ...
         'index',index, ...
         'loadpath',loadpath, ...
         'savepath',savepath, ...
         'queries',[], ...
         'user_registration',user_registration, ...
         'netfeatures',netfeatures, ...
         'metafields',{metafields});

      %store ui cache data in main figure userdata
      set(h_fig,'UserData',uih,'Visible','on')

      %init prompt flag for loading search index
      promptflag = 0;

      %load default workspace if present
      fn_default = [gce_homepath,filesep,'search_indices',filesep,'search_default.mat'];
      if exist(fn_default,'file') == 2
         ui_search_data('loadall','default')
      else
         ui_search_data('showhide')  %default to hiding the query pane
         promptflag = 1;
      end

      %incorporate index provided on function call
      if ~isempty(index)
         ui_search_data('newindex')
         promptflag = 0;  %reset prompt flag if index provided as input
      else
         drawnow
      end

      %check for matlab 6.5 or higher, prompt for registration info if net access present
      if strcmp(netfeatures,'on') && isempty(user_registration)
         ui_gce_register('init','ui_search_data(''register'',registration)')
      elseif promptflag == 1
         if strcmp(uih.netfeatures,'on')
            confirmdlg('init',char('Please Note: You must load or create a search index before performing searches', ...
               '(see ''Help > View Documentation > Section III'' for instructions)', ...
               '','Would you like to load a pre-generated index of GCE Data Sets?'),'ui_search_data(''webload'')');
         else
            messagebox('init',char('Please Note: You must load or create a search index before performing searches', ...
               '(see ''Help > View Documentation > Section III'' for instructions)'), ...
               '','Information',[.9 .9 .9])
         end
      end

   end

else

   %get dialog handle
   h_fig = findobj('tag','dlgSearchData');

   if ~isempty(h_fig)

      %get stored info
      h_fig = h_fig(end);
      uih = get(h_fig,'userdata');

      %init callback data if omitted
      if exist('data','var') ~= 1
         data = '';
      end

      %handle callbacks
      switch op

      case 'close'  %close the dialog, prompting for confirmation if there an index or matches are present

         %check auto-save option
         h_autosave = findobj(uih.mnuAutoSave,'Checked','on');
         autosave = 0;
         if ~isempty(h_autosave)
            if strcmp(get(h_autosave,'Label'),'Yes')
               autosave = 1;
            end
         end

         if ~isempty(get(uih.lstMatches,'String')) || ~isempty(uih.index)
            if strcmp(data,'confirmed')
               confirm = 0;
            elseif autosave == 0
               confirm = 1;
            else
               confirm = 0;
            end
         else
            confirm = 0;
         end

         if confirm == 1
            confirmdlg('init', ...
               'Close the search dialog (results will not be saved)?', ...
               'ui_search_data(''close'',''confirmed'')');
         else
            if autosave == 1
               try
                  ui_search_data('saveall','default')
               catch
                  %skip autosave
               end
            end
            delete(h_fig)
            h_map = findobj('Tag','BBox_Map','Type','figure');
            if ~isempty(h_map)
               try
                  delete(h_map)
               catch
                  %skip delete
               end
            end
            if length(findobj) == 1  %check for other open windows - open startup dialog if none found
               ui_aboutgce('reopen');
            end
         end

      case 'exit'  %exit MATLAB, prompting for confirmation if there an index or matches are present

         if ~isempty(get(uih.lstMatches,'String')) || ~isempty(uih.index)
            if strcmp(data,'confirmed')
               confirm = 0;
            else
               confirm = 1;
            end
         else
            confirm = 0;
         end

         if confirm == 1
            confirmdlg('init', ...
               'Close window and exit MATLAB? (results will not be saved)?', ...
               'ui_search_data(''exit'',''confirmed'')');
         else
            delete(h_fig)
            quit
         end

      case 'register'  %update user registration info

         registration = data;

         if isstruct(registration)

            uih.user_registration = registration;
            set(h_fig,'UserData',uih)

            %prompt to load/create index if none loaded
            if isempty(uih.index)
               if strcmp(uih.netfeatures,'on')
                  confirmdlg('init',char('Please Note: You must load or create a search index before performing searches', ...
                     '(see ''Help > View Documentation > Section III'' for instructions)', ...
                     '','Would you like to load a pre-generated index of GCE Data Sets?'),'ui_search_data(''webload'')');
               else
                  messagebox('init',char('Please Note: You must load or create a search index before performing searches', ...
                     '(see ''Help > View Documentation > Section III'' for instructions)'), ...
                     '','Information',[.9 .9 .9])
               end
            end

         end

      case 'newindex'  %populate the path list and lookup list with values from a new index

         index = uih.index;
         errorstr = '';

         if ~isempty(index)

            if isfield(index,'path') && isfield(index,'filename') && isfield(index,'varname')

               set(h_fig,'pointer','watch'); drawnow

               pns = unique({index.path}');
               str = pns;
               for n = 1:length(pns)
                  numvars = length(find(strcmp({index.path},pns{n})));
                  str{n} = [pns{n},' (',int2str(numvars),' data sets)'];
               end

               allvars = [];
               for n = 1:length(index)
                  allvars = [allvars ; index(n).columns];
               end
               varnames = [{'<any variable>'} ; unique(allvars)];

               set(uih.lstPaths,'String',str,'Value',1,'ListBoxTop',1,'UserData',pns)

               %retain existing column selections if column names present in revised index
               oldvarnames = get(uih.lstVars,'String');
               if ~isempty(oldvarnames)
                  Isel = get(uih.lstVars,'Value');
                  if ~isempty(find(Isel~=1))
                     vals = [];
                     for n = 1:length(Isel)
                        str = oldvarnames{Isel(n)};
                        Imatch = find(strcmp(varnames,str));
                        if ~isempty(Imatch)
                           vals = [vals ; Imatch(1)];
                        end
                     end
                     if isempty(vals)
                        vals = 1;
                     end
                  else
                     vals = 1;
                  end
               else
                  vals = 1;
               end
               set(uih.lstVars,'String',varnames,'Value',vals,'ListboxTop',min(vals))

               ui_search_data('varlist')  %update column list status
               ui_search_data('buttons')  %update button states

               set(h_fig,'pointer','arrow'); drawnow

            else  %invalid index - clear

               uih.index = [];
               set(uih.lstPaths,'String','','Value',1,'UserData',[],'ListBoxTop',1)
               set(uih.lstVars,'String','','UserData',[])
               set(h_fig,'UserData',uih)
               errorstr = 'Invalid search index file';

            end

         else  %empty index - reset dialog
            set(uih.lstPaths,'String','','Value',1,'UserData',[],'ListBoxTop',1)
            set(uih.lstVars,'String','','UserData',[])
         end

         set(uih.lblDataSets,'String',['(',int2str(length(uih.index)),' data sets)'])
         ui_search_data('buttons')

         if ~isempty(errorstr)
            msgbox('Invalid search index file','Error','error')
         end

      case 'saveindex'  %save the in-memory search index to disk

         %switch to default index directory first
         pn = [gce_homepath,filesep,'search_indices'];
         if ~isdir(pn)
            try
               mkdir(gce_homepath,'search_indices');
               if ~isdir(pn)
                  pn = gce_homepath;
               end
            catch
               pn = gce_homepath;
            end
         end

         curpath = pwd;
         cd(pn)
         [fn,pn] = uiputfile('search_index.mat','Select a location and filename for the search index');
         pn = clean_path(pn); %strip terminal file separator
         cd(curpath)
         drawnow

         if fn ~= 0
            index = uih.index;
            uih.savepath = pn;
            set(h_fig,'UserData',uih)
            try
               save([pn,fn],'index')
            catch
               messagebox('init','The index could not be saved to the specified directory','','Error',[.9 .9 .9])
            end
         end

      case 'loadindex'  %load a search index from disk

         curpath = pwd;

         %switch to default index directory first
         pn = [gce_homepath,filesep,'search_indices'];
         if isdir(pn)
            cd(pn)
         else  %use standard loadpath if default dir doesn't exist
            cd(uih.loadpath)
         end

         [fn,pn] = uigetfile('*.mat;*.MAT','Select a search index file to load');
         cd(curpath)
         drawnow

         if fn ~= 0

            cd(pn)
            try
               vars = load(fn,'-mat');
            catch
               vars = struct('null','');
            end
            cd(curpath)

            index = [];
            if isfield(vars,'index')
               index = vars.index;
            end

            if ~isempty(index)
               uih.index = index;
               uih.loadpath = pn;
               set(h_fig,'UserData',uih)
               ui_search_data('newindex')
            else
               messagebox('init','Specified file does not contain a valid search index structure','','Error',[.9 .9 .9])
            end

         end

      case 'webload'  %load a web index from the GCE website after confirming deletion of existing entries

         if ~isempty(uih.index)
            confirmdlg('init','Delete existing index entries and load a new GCE web index?','ui_search_data(''webindex'',''load'')')
         else
            ui_search_data('webindex','load')
         end

      case 'webindex'  %retrieve a web index from the GCE website

         %get load/merge option from second argument
         loadtype = data;
         if isempty(loadtype)
            loadtype = 'merge';
         end

         if strcmp(uih.netfeatures,'on')

            url = 'http://gce-lter.marsci.uga.edu/public/files/catalogs/gce_web_index.mat';

            msg = '';
            index = [];
            oldindex = uih.index;
            curpath = pwd;

            %switch to default index directory first
            pn = [gce_homepath,filesep,'search_indices'];
            if isdir(pn)
               cd(pn)
            else  %use standard loadpath if default dir doesn't exist
               cd(uih.savepath)
            end

            %check for existing index downloaded same day
            d = dir('gce_web_index.mat');
            if ~isempty(d)
               if fix(datenum(d(1).date)) == fix(now)
                  try
                     v = load('gce_web_index.mat','-mat');
                  catch
                     v = struct('null','');
                  end
                  if isfield(v,'index')
                     index = v.index;  %no non-GCE entries, replace entire index
                  end
               end
            end

            if isempty(index)  %retrieve fresh file from web

               set(h_fig,'Pointer','watch'); drawnow
               [fn,status] = urlwrite(url,'gce_web_index.mat');
               set(h_fig,'Pointer','arrow'); drawnow

               if status == 1
                  try
                     v = load('gce_web_index.mat','-mat');
                  catch
                     v = struct('null','');
                  end
                  if isfield(v,'index')
                     index = v.index;
                  else
                     msg = 'File does not contain a valid search index - contact the GCE Information Manager';
                  end
               else
                  msg = 'Web index could not be downloaded - check network status';
               end

            end

            cd(curpath)

            if ~isempty(index)
               if strcmp(loadtype,'load')
                  uih.index = index;
                  set(h_fig,'UserData',uih)
                  ui_search_data('newindex')
               else  %merge
                  %get index of non-GCE web entries for retention
                  Inongce = find(~strncmp({oldindex.path}','http://gce',10));
                  if ~isempty(Inongce)  %merge new web index with non-web entries
                     index = sub_mergeindex(oldindex(Inongce),index);
                  end
                  if ~isempty(index)
                     uih.index = index;
                     set(h_fig,'UserData',uih)
                     ui_search_data('newindex')
                     numpaths = length(get(uih.lstPaths,'String'));
                     set(uih.lstPaths,'Value',numpaths,'ListBoxTop',numpaths)
                  else
                     messagebox('init','The GCE web index is not compatible with the existing index','','Error',[.9 .9 .9])
                  end
               end
            else
               if ~isempty(msg)
                  messagebox('init',msg,'','Error',[.9 .9 .9])
               end
            end

         else
            messagebox('init','Network file access is not supported by this version of MATLAB','','Info',[.9 .9 .9])
         end

      case 'mergeindex'  %loads an index and merges it with the current search index, replacing dupes

         errorflag = 0; %init merge error flag

         if ~isempty(data)  %get merge index from other subroutine

            index2 = data;

         else  %load local index to merge

            index2 = [];
            curpath = pwd;

            %switch to default index directory first
            pn = [gce_homepath,filesep,'search_indices'];
            if isdir(pn)
               cd(pn)
            else  %use standard loadpath if default dir doesn't exist
               cd(uih.loadpath)
            end

            [fn,pn] = uigetfile('*.mat;*.MAT','Select a search index file to merge with the current index');
            cd(curpath)
            drawnow

            if fn ~= 0

               uih.loadpath = pn;

               cd(pn)
               try
                  vars = load(fn,'-mat');
               catch
                  vars = struct('null','');
               end
               cd(curpath)

               if isfield(vars,'index')
                  index2 = vars.index;
               end

            end

         end

         if ~isempty(index2)

            index = uih.index;

            if isempty(index)

               Inew = (1:length(index2));
               Idupes = [];
               uih.index = index2;

            else  %merge with existing entries

               %generate lookup arrays
               allpn = {index.path}';
               allfn = {index.filename}';
               allvar = {index.varname}';

               %init match pointers
               Iadd = zeros(length(index2),1);
               Iupdate = Iadd;
               Idupes = zeros(length(index),1);

               %check for dupes, new records
               for n = 1:length(index2)
                  Idupe = find(strcmp(allpn,index2(n).path) & strcmp(allfn,index2(n).filename) & ...
                     strcmp(allvar,index2(n).varname));
                  if isempty(Idupe)
                     Iadd(n) = 1;
                  else
                     Idupes(Idupe) = 1;
                     Iupdate(n) = 1;
                  end
               end

               Inew = find(Iadd + Iupdate);  %generate index of new records to add/update
               Ikeep = find(~Idupes);  %get index of unmodified records to retain

               if isempty(Ikeep)
                  index = index2;  %all records duplicated - use new index
               elseif ~isempty(Inew)
                  index = sub_mergeindex(index(Ikeep),index2(Inew));  %merge old and new records
               end

               if ~isempty(index)
                  uih.index = index;
               else
                  errorflag = 1;
               end

            end

            if errorflag  == 0
               set(h_fig,'UserData',uih)
               ui_search_data('newindex')
               messagebox('init',['Added ',int2str(length(find(Iadd))),' indexed data sets, updated ', ...
                     int2str(length(find(Iupdate))),' duplicate data sets'],'','Info',[.9 .9 .9])
            else
               messagebox('init',char('The new index is incompatible with the existing index', ...
                  'Use the ''Add'' button to re-index the respective directories'),'','Error',[.9 .9 .9])
            end

         else
            messagebox('init','Specified file does not contain a valid search index structure','','Error',[.9 .9 .9])
         end

      case 'mergedata'  %start up ui_multimerge in save directory

         if ~isempty(uih.savepath)
            ui_multimerge('init',uih.savepath)
         else
            ui_multimerge
         end

      case 'saveall'  %save session info to a file

         save_default = 0;
         if exist('data','var') == 1
            if strcmp(data,'default')
               save_default = 1;
            end
         end

         %get menu selections
         h_metaopt = findobj(uih.mnuMetadata,'Checked','on');
         metaopt = get(h_metaopt,'UserData');
         showhide = get(uih.mnuShowHideQueries,'Label');

         h_headeropt = findobj(uih.mnuHeader,'Checked','on');
         headeropt = get(h_headeropt,'UserData');

         h_flagopt = findobj(uih.mnuFlags,'Checked','on');
         flagopt = get(h_flagopt,'UserData');

         h_metaopt = findobj(uih.mnuMergeMeta,'Checked','on');
         metaopt = get(h_metaopt,'UserData');

         h_lockflagopt = findobj(uih.mnuLockFlags,'Checked','on');
         lockflagopt = get(h_lockflagopt,'UserData');

         h_datasetnames = findobj(uih.mnuMergeDatasetNames,'Checked','on');
         datasetnamesopt = get(h_datasetnames,'UserData');

         h_autosave = findobj(uih.mnuAutoSave,'Checked','on');
         autosaveopt = get(h_autosave,'UserData');

         h_autoadd = findobj(uih.mnuAutoAdd,'Checked','on');
         autoaddopt = get(h_autoadd,'UserData');

         h_autodelete = findobj(uih.mnuAutoDelete,'Checked','on');
         autodeleteopt = get(h_autodelete,'UserData');

         pathstr = get(uih.lstPaths,'String');
         pathlist = get(uih.lstPaths,'UserData');

         %get cached info
         index = uih.index;
         queries = uih.queries;
         loadpath = uih.loadpath;
         savepath = uih.savepath;
         metafields = uih.metafields;
         match_string = get(uih.lstMatches,'String');
         match_data = get(uih.lstMatches,'UserData');

         %only store user reg if not saving default snapshot
         if save_default == 0
            user_registration = uih.user_registration;
         else
            user_registration = [];
         end

         %get editbox values
         metafield = get(uih.popMetaField,'Value');
         metastr = deblank(get(uih.editMetaStr,'String'));
         keyword = deblank(get(uih.editKeyword,'String'));
         author = deblank(get(uih.editAuthor,'String'));
         taxa = deblank(get(uih.editTaxa,'String'));
         date_type = get(uih.popDateType,'Value');
         date_start = get(uih.editDateStart,'UserData');
         date_end = get(uih.editDateEnd,'UserData');

         %get bounding box coords
         wlon = get(uih.editWLon,'UserData');
         elon = get(uih.editELon,'UserData');
         slat = get(uih.editSLat,'UserData');
         nlat = get(uih.editNLat,'UserData');

         %get site selection
         sitelist = get(uih.popSite,'String');
         sitecodes = get(uih.popSite,'UserData');
         siteval = get(uih.popSite,'Value');

         %get selected columns, checking for <any variable> option
         varlist = get(uih.lstVars,'String');
         varsel = get(uih.lstVars,'Value');

         match_case = get(uih.chkMatchCase,'Value');
         save_queries = get(uih.chkSaveQueries','Value');
         subdir = get(uih.chkSubDir,'Value');

         if get(uih.radioMapExclusive,'Value') == 1
            bbox_mode = 'exclusive';
         else
            bbox_mode = 'inclusive';
         end

         if get(uih.radioMatchAll,'Value') == 1
            match_opt = 'all';
         else
            match_opt = 'any';
         end

         curpath = pwd;

         %use default index directory first
         pn = [gce_homepath,filesep,'search_indices'];
         if ~isdir(pn)
            try
               mkdir(gce_homepath,'search_indices');
               if ~isdir(pn)
                  pn = gce_homepath;
               end
            catch
               pn = gce_homepath;
            end
         end

         %check for default option
         if save_default == 0

            if isdir(pn)
               cd(pn)
            else  %use standard loadpath if default dir doesn't exist
               cd(uih.savepath)
            end

            [fn,pn] = uiputfile(['search_settings_',datestr(now,1),'.mat'],'Select a filename and location for saving your workspace');
            pn = clean_path(pn); %strip terminal file separator
            drawnow
            cd(curpath)

         else
            fn = 'search_default.mat';
         end

         if fn ~= 0
            try
               save([pn,filesep,fn],'index','queries','pathlist','pathstr','match_data','match_string','metaopt','headeropt','flagopt', ...
                  'metaopt','lockflagopt','datasetnamesopt','loadpath','savepath','metafields','metafield','metastr','keyword','author','taxa','showhide', ...
                  'date_type','date_start','date_end','wlon','elon','slat','nlat','sitelist','sitecodes','siteval','autosaveopt','autoaddopt','autodeleteopt', ...
                  'varlist','varsel','match_case','bbox_mode','match_opt','save_queries','subdir','user_registration');
               if save_default == 0
                  uih.savepath = pn;
                  set(h_fig,'UserData',uih)
               end
            catch
               messagebox('init','The workspace could not be saved to the specified directory','','Error',[.9 .9 .9])
            end
         end

      case 'loadall'  %load session info from a file, repopulate controls

         load_default = 0;
         if exist('data','var') == 1
            if strcmp(data,'default')
               load_default = 1;
            end
         end

         curpath = pwd;

         %switch to default index directory first
         pn = [gce_homepath,filesep,'search_indices',filesep];
         if isdir(pn)
            cd(pn)
         else  %use standard loadpath if default dir doesn't exist
            cd(uih.loadpath)
         end

         if load_default == 1  %check for default workspace option
            if exist('search_default.mat','file') == 2
               fn = 'search_default.mat';
            else
               fn = '';
            end
         else
            [fn,pn] = uigetfile('*.mat;*.MAT','Select a search workspace file to load');
            drawnow
         end

         cd(curpath)

         if fn ~= 0

            try
               v = load([pn,fn],'-mat');
            catch
               v = struct('null','');
            end

            if isfield(v,'index') && isfield(v,'pathlist') && isfield(v,'pathstr');
               uih.index = v.index;
               set(uih.lstPaths,'String',v.pathstr,'UserData',v.pathlist,'Value',1,'ListBoxTop',1)
            end

            if isfield(v,'queries')
               uih.queries = v.queries;
               set(uih.lstQueries,'String',v.queries,'Value',1,'ListBoxTop',max(1,length(v.queries)),'Value',1,'ListBoxTop',1)
            end

            if isfield(v,'loadpath'); uih.loadpath = v.loadpath; end

            if isfield(v,'savepath'); uih.savepath = v.savepath; end

            if isfield(v,'user_registration')
               if ~isempty(v.user_registration)
                  uih.user_registration = v.user_registration;  %check so don't overwrite file-based user registration
               end
            end

            if isfield(v,'match_data') && isfield(v,'match_string')
               set(uih.lstMatches,'String',v.match_string,'UserData',v.match_data,'Value',1,'ListBoxTop',1);
            end

            %update metadata search list, search value
            if isfield(v,'metafields') && isfield(v,'metafield') && isfield(v,'metastr')
               Imetafield = find(strcmp(uih.metafields(:,1),v.metafields(v.metafield,1)));
               if isempty(Imetafield)  %field missing in current configuration - add selected item to list
                  uih.metafields = [uih.metafields ; v.metafields(v.metafield,:)];
                  Imetafield = size(uih.metafields,1);
                  str_popmetafield = concatcellcols([uih.metafields(:,2),repmat({' '},size(uih.metafields,1),1), ...
                        strrep(strrep(strrep(uih.metafields(:,3),'contains','Contains'),'exact','Is'),'starts','Begins With'), ...
                        repmat({':'},size(uih.metafields,1),1)]);
                  set(uih.popMetaField,'String',str_popmetafield,'Value',Imetafield)
               else
                  set(uih.popMetaField,'Value',Imetafield)
               end
               set(uih.editMetaStr,'String',v.metastr)
            end

            %reset all menu checks
            menuflds = {'metaopt',uih.mnuMetadata; ...
                  'headeropt',uih.mnuHeader; ...
                  'flagopt',uih.mnuFlags; ...
                  'metaopt',uih.mnuMergeMeta; ...
                  'lockflagopt',uih.mnuLockFlags; ...
                  'datasetnamesopt',uih.mnuMergeDatasetNames; ...
                  'autosaveopt',uih.mnuAutoSave; ...
                  'autoaddopt',uih.mnuAutoAdd; ...
                  'autodeleteopt',uih.mnuAutoDelete};
            for n = 1:size(menuflds,1)
               if isfield(v,menuflds{n,1})
                  h_chk = findobj(menuflds{n,2},'UserData',v.(menuflds{n,1}));
                  if ~isempty(h_chk)
                     h_all = findobj(menuflds{n,2});
                     set(h_all,'Checked','off')
                     set(h_chk,'Checked','on')
                  end
               end
            end

            if isfield(v,'keyword'); set(uih.editKeyword,'String',v.keyword); end

            if isfield(v,'author'); set(uih.editAuthor,'String',v.author); end

            if isfield(v,'taxa'); set(uih.editTaxa,'String',v.taxa); end

            if isfield(v,'date_type'); set(uih.popDateType,'Value',v.date_type); end

            if isfield(v,'date_start'); set(uih.editDateStart,'String',datestr(v.date_start),'UserData',v.date_start); end

            if isfield(v,'date_end'); set(uih.editDateEnd,'String',datestr(v.date_end),'UserData',v.date_end); end

            if isfield(v,'wlon') && isfield(v,'elon') && isfield(v,'nlat') && isfield(v,'slat')
               set(uih.editWLon,'String',num2str(v.wlon),'UserData',v.wlon)
               set(uih.editELon,'String',num2str(v.elon),'UserData',v.elon)
               set(uih.editSLat,'String',num2str(v.slat),'UserData',v.slat)
               set(uih.editNLat,'String',num2str(v.nlat),'UserData',v.nlat)
            end

            if isfield(v,'sitelist') && isfield(v,'sitecodes') && isfield(v,'siteval')
               set(uih.popSite,'String',v.sitelist,'UserData',v.sitecodes,'Value',v.siteval)
            end

            if isfield(v,'varlist') && isfield(v,'varsel')
               if ~isempty(v.varsel)
                  boxtop = v.varsel(1);
               else
                  boxtop = 1;
               end
               set(uih.lstVars,'String',v.varlist,'Value',v.varsel,'ListBoxTop',boxtop)
            end

            if isfield(v,'match_case'); set(uih.chkMatchCase,'Value',v.match_case); end

            if isfield(v,'subdir'); set(uih.chkSubDir,'Value',v.subdir); end

            if isfield(v,'match_opt')
               if strcmp(v.match_opt,'all')
                  set(uih.radioMatchAll,'Value',1)
                  set(uih.radioMatchAny,'Value',0)
               else
                  set(uih.radioMatchAll,'Value',0)
                  set(uih.radioMatchAny,'Value',1)
               end
            end

            if isfield(v,'bbox_mode')
               if strcmp(v.bbox_mode,'exclusive')
                  set(uih.radioMapExclusive,'Value',1)
                  set(uih.radioMapInclusive,'Value',0)
               else
                  set(uih.radioMapExclusive,'Value',0)
                  set(uih.radioMapInclusive,'Value',1)
               end
            end

            uih.loadpath = pn;
            set(h_fig,'UserData',uih)
            num_matches = length(get(uih.lstMatches,'String'));
            if num_matches ~= 1
               set(uih.lblMatches,'String',['(',int2str(num_matches),' matches)'])
            else
               set(uih.lblMatches,'String','(1 match)')
            end
            set(uih.lblDataSets,'String',['(',int2str(length(uih.index)),' data sets)'])

            drawnow

            %update button states
            ui_search_data('varlist')
            ui_search_data('buttons')

            %update query window state
            if ~isfield(v,'showhide')
               v.showhide = 'Hide Query History';
            end
            lbl = get(uih.mnuShowHideQueries,'Label');
            if strncmp(v.showhide,'Hide',4) && ~strncmp(lbl,'Hide',4)
               set(uih.mnuShowHideQueries,'Label','Show Query History')
               ui_search_data('showhide')
            elseif strncmp(v.showhide,'Show',4) && ~strncmp(lbl,'Show',4)
               set(uih.mnuShowHideQueries,'Label','Hide Query History')
               ui_search_data('showhide')
            end

            if isfield(v,'save_queries'); set(uih.chkSaveQueries,'Value',v.save_queries); end

         end

      case 'clearcache'  %clear files from temporary cache directories

         cachedir = data;  %get cache dir from function call parameter

         if isempty(strfind(cachedir,'_confirmed'))

            cachepath = [gce_homepath,filesep,cachedir];
            confirmdlg('init',['Remove all .mat and .MAT files from ''',cachepath,'''?'],['ui_search_data(''clearcache'',''',cachedir,'_confirmed'')'])

         else

            msg = '';
            cachepath = [gce_homepath,filesep,strrep(cachedir,'_confirmed','')];

            if isdir(cachepath)
               curpath = pwd;
               cd(cachepath)
               d = dir('*.mat');
               if ~strcmp(computer,'PCWIN')  %include files with upper case extensions on unix/mac systems with case-sensitive filenames
                  d2 = dir('*.MAT');
                  d = [d ; d2];
               end
               if ~isempty(d)
                  try
                     delete *.MAT;
                     numfiles = int2str(length(unique({d.name}')));
                     msg = ['Successfully deleted ',numfiles,' .mat files from ''',cachepath,''''];
                  catch
                     msg = ['An error occurred deleting .mat files from ''',cachepath,''''];
                  end
               else
                  msg = 'Cache directory does not contain any .mat or .MAT files';
               end
               cd(curpath)
            else
               msg = 'Cache directory could not be found';
            end

            if ~isempty(msg)
               messagebox('init',msg,'','Error',[.9 .9 .9])
            end

         end

      case 'search'  %assemble query from user input, execute search

         qrystr = '';  %init query

         metastr = deblank(get(uih.editMetaStr,'String'));
         if ~isempty(metastr); qrystr = [qrystr,uih.metafields{get(uih.popMetaField,'value'),1},' = ',metastr,'; ']; end

         keyword = deblank(get(uih.editKeyword,'String'));
         if ~isempty(keyword); qrystr = [qrystr,'Keywords = ',keyword,'; ']; end

         author = deblank(get(uih.editAuthor,'String'));
         if ~isempty(author); qrystr = [qrystr,'Author = ',author,'; ']; end

         taxa = deblank(get(uih.editTaxa,'String'));
         if ~isempty(taxa); qrystr = [qrystr,'Taxa = ',taxa,'; ']; end

         date_type = get(uih.popDateType,'Value');
         if date_type == 1
            date_start = get(uih.editDateStart,'UserData');
            date_end = get(uih.editDateEnd,'UserData');
            if ~isempty(date_start); qrystr = [qrystr,'DateStart = ',datestr(date_start),'; ']; end
            if ~isempty(date_end); qrystr = [qrystr,'DateEnd = ',datestr(date_end),'; ']; end
         else
            date_contains = get(uih.editDateStart,'UserData');
            if ~isempty(date_contains); qrystr = [qrystr,'DateContains = ',datestr(date_contains),'; ']; end
         end

         %get site selection
         siteval = get(uih.popSite,'Value');
         sitestr = '';
         if siteval > 1
            allsites = get(uih.popSite,'UserData');
            sitestr = allsites{siteval};
            if ~isempty(sitestr); qrystr = [qrystr,'Sites = ',sitestr,'; ']; end
         end

         %get selected columns, checking for <any variable> option
         Ivars = get(uih.lstVars,'Value');
         columns = [];
         if ~isempty(Ivars)
            if isempty(find(Ivars == 1))
               allvars = get(uih.lstVars,'String');
               columns = allvars(Ivars);
               qrystr = [qrystr,'Columns = ',strrep(cell2commas(columns),' ',''),'; '];
            end
         end

         %get bounding box coords
         bbox = [NaN NaN NaN NaN];
         wlon = get(uih.editWLon,'UserData'); if wlon > -180; bbox(1) = wlon; end
         elon = get(uih.editELon,'UserData'); if elon < 180; bbox(2) = elon; end
         slat = get(uih.editSLat,'UserData'); if slat > -90; bbox(3) = slat; end
         nlat = get(uih.editNLat,'UserData'); if nlat < 90; bbox(4) = nlat; end
         if sum(isnan(bbox)) < 4
            bboxstr = sprintf('%0.6f,',bbox);
            qrystr = [qrystr,'BoundingBox = [',bboxstr(1:end-1),']; '];
            if get(uih.radioMapExclusive,'Value') == 1
               qrystr = [qrystr,'BoundingBoxMode = inside; '];
            else
               qrystr = [qrystr,'BoundingBoxMode = intersect; '];
            end
         end

         %add match type selection
         if get(uih.radioMatchAll,'Value') == 1
            qrystr = [qrystr,'MatchType = all; '];
         else
            qrystr = [qrystr,'MatchType = any; '];
         end

         %add case sensitive option as last term
         match_case = get(uih.chkMatchCase,'Value');
         if match_case == 1
            qrystr = [qrystr,'MatchCase = TRUE'];
         else
            qrystr = [qrystr,'MatchCase = FALSE'];
         end

         %execute search using appropriate algorithm
         %dt = now;
         [paths,filenames,varnames,accessions,titles,daterange] = search_data(qrystr,uih.index,'');

         if ~isempty(paths)

            if get(uih.chkSaveQueries,'Value') == 1
               Iqry = find(strcmp(uih.queries,qrystr));
               if ~isempty(Iqry)
                  set(uih.lstQueries,'Value',Iqry,'ListBoxTop',Iqry)
               else
                  uih.queries = [uih.queries ; {qrystr}];
                  set(h_fig,'UserData',uih)
                  len = length(uih.queries);
                  if len > 1
                     listboxtop = length(uih.queries);
                  else
                     listboxtop = 1;
                  end
                  set(uih.lstQueries,'String',uih.queries,'Value',length(uih.queries),'ListBoxTop',listboxtop)
               end
            end

            %build match list string
            prefix = repmat({'local/ '},length(paths),1);  %init with local prefix
            Iweb = find(strncmp(paths,'http',4));  %get index of web paths
            if ~isempty(Iweb)
               [prefix(Iweb)] = deal({'web/ '});  %change label to web
            end
            Inoaccession = find(cellfun('isempty',accessions));  %get index of missing accessions
            if ~isempty(Inoaccession)
               accessions(Inoaccession) = repmat({'[no accession]'},length(Inoaccession),1);  %add [no accession] label
            end
            accessions = concatcellcols([prefix,accessions],' ');  %concatenate web/local prefix, accession
            str = concatcellcols([accessions,titles],' - ');  %concatentate accessions, titles
            str = concatcellcols([str,daterange],'  ');  %concatenate date range string
            oldstr = get(uih.lstMatches,'String');

            if ~isempty(oldstr)  %existing matches, check for dupes and add new matches

               data = get(uih.lstMatches,'UserData');

               %check for duplicated paths, filenames, varnames
               Inew = zeros(length(paths),1);
               for n = 1:length(paths)
                  if isempty(find(strcmp(data.paths,paths{n}) & strcmp(data.filenames,filenames{n}) & ...
                        strcmp(data.varnames,varnames{n})))
                     Inew(n) = 1;
                  end
               end
               Inew = find(Inew);  %index of new matches

               msg = '';  %init warning message

               if ~isempty(Inew)  %add new matches

                  str = str(Inew);
                  paths = paths(Inew);
                  filenames = filenames(Inew);
                  varnames = varnames(Inew);

                  [tmp,Isort] = sortrows(char(str));  %sort new matches

                  %update dataset info fields
                  data.paths = [data.paths ; paths(Isort)];
                  data.filenames = [data.filenames ; filenames(Isort)];
                  data.varnames = [data.varnames ; varnames(Isort)];

                  %update list text
                  newstr = [oldstr ; str(Isort)];

                  %update control, cached data
                  set(uih.lstMatches,'String',newstr,'UserData',data, ...
                     'Value',[length(oldstr)+1:length(newstr)],'ListBoxTop',length(newstr))

               else  %give feedback to user that no new data sets added
                  msg = ['Query matched ',int2str(length(paths)),' data set(s) already in the list -- 0 data sets added'];
               end

               ui_search_data('buttons')  %update button status to catch any state changes

               if ~isempty(msg)
                  messagebox('init',msg,'','Info',[.9 .9 .9]);
               end

            else  %no prior entries, add all

               [tmp,Isort] = sortrows(char(str));
               data = struct('paths',{paths(Isort)},'filenames',{filenames(Isort)},'varnames',{varnames(Isort)});
               set(uih.lstMatches,'String',str(Isort),'UserData',data,'Value',(1:length(str)),'ListBoxTop',length(str))
               ui_search_data('buttons')

            end

            num_paths = length(data.paths);
            if num_paths ~= 1
               set(uih.lblMatches,'String',['(',int2str(num_paths),' matches)'])
            else
               set(uih.lblMatches,'String','(1 match)')
            end

         else
            messagebox('init','No data sets matched the specified criteria','','Info',[.9 .9 .9]);
         end

      case 'metaformat'  %toggle metadata format menu selections

         h_cbo = gcbo;
         ud = get(h_cbo,'UserData');
         h_all = findobj(uih.mnuMetadata);

         set(h_all,'Checked','off')
         set(h_cbo,'Checked','on')

      case 'headerformat'  %toggle header format menu selections

         h_cbo = gcbo;
         ud = get(h_cbo,'UserData');
         h_all = findobj(uih.mnuHeader);

         set(h_all,'Checked','off')
         set(h_cbo,'Checked','on')

      case 'flagopt'  %toggle metadata format menu selections

         h_cbo = gcbo;
         ud = get(h_cbo,'UserData');
         h_all = findobj(uih.mnuFlags);

         set(h_all,'Checked','off')
         set(h_cbo,'Checked','on')

      case 'metamerge'  %toggle metadata merge option selections

         h_cbo = gcbo;
         ud = get(h_cbo,'UserData');
         h_all = findobj(uih.mnuMergeMeta);

         set(h_all,'Checked','off')
         set(h_cbo,'Checked','on')

      case 'lockflags'  %toggle flag lock option selections

         h_cbo = gcbo;
         ud = get(h_cbo,'UserData');
         h_all = findobj(uih.mnuLockFlags);

         set(h_all,'Checked','off')
         set(h_cbo,'Checked','on')

      case 'datasetnames'  %toggle filename merge option selections

         h_cbo = gcbo;
         ud = get(h_cbo,'UserData');
         h_all = findobj(uih.mnuMergeDatasetNames);

         set(h_all,'Checked','off')
         set(h_cbo,'Checked','on')

      case 'autosave'  %toggle auto-save option selections

         h_cbo = gcbo;
         ud = get(h_cbo,'UserData');
         h_all = findobj(uih.mnuAutoSave);

         set(h_all,'Checked','off')
         set(h_cbo,'Checked','on')

         if strcmp(get(h_cbo,'Label'),'No')  %check for no option, delete existing history file
            fn = [gce_homepath,filesep,'search_indices',filesep,'search_default.mat'];
            if exist(fn,'file') == 2
               try
                  delete(fn);
               catch
                  %skip delete
               end
            end
         end

      case 'autoadd'  %toggle auto-add option selections

         h_cbo = gcbo;
         ud = get(h_cbo,'UserData');
         h_all = findobj(uih.mnuAutoAdd);

         set(h_all,'Checked','off')
         set(h_cbo,'Checked','on')

      case 'autodelete'  %toggle auto-delete option selections

         h_cbo = gcbo;
         ud = get(h_cbo,'UserData');
         h_all = findobj(uih.mnuAutoDelete);

         set(h_all,'Checked','off')
         set(h_cbo,'Checked','on')

      case 'showhide'  %show/hide query history window

         lbl = get(uih.mnuShowHideQueries,'Label');
         h_query = [uih.lblQueryHistory; ...
               uih.lstQueries; ...
               uih.cmdLoadQuery; ...
               uih.cmdClearQuery; ...
               uih.cmdClearQueryAll; ...
               uih.cmdHideHistory];
         h_lbls = [uih.lblSearchResults; ...
               uih.lblViewMetadata; ...
               uih.lblMatches];
         h_btns1 = [uih.cmdSelectAll; ...
               uih.cmdSelectNone; ...
               uih.cmdClear; ...
               uih.cmdClearAll; ...
               uih.cmdSort];
         h_btns2 = [uih.cmdEditor; ...
               uih.cmdPlotXY; ...
               uih.cmdPlotGroups; ...
               uih.cmdMapPlot; ...
               uih.cmdSummary];

         pos_mid = get(uih.frmMiddle,'Position');
         voffset = pos_mid(4) + 5;

         res = get(0,'ScreenSize');
         if res(4) <= 810
            voffset2 = -125;  %command button offset
            hoffset = 90;
         else
            voffset2 = 0;
            hoffset = 0;
         end

         if strncmp(lbl,'Hide',4)
            set(uih.mnuShowHideQueries,'Label','Show Query History')
            qryvis = 'off';
         else
            set(uih.mnuShowHideQueries,'Label','Hide Query History')
            qryvis = 'on';
            voffset = -1 .* voffset;
            voffset2 = -1 .* voffset2;
            hoffset = -1 .* hoffset;
         end

         %update frame height
         pos = get(uih.frmBottom,'Position');
         set(uih.frmBottom,'Position',[pos(1:3),pos(4)+voffset])

         %update match list height, width
         pos = get(uih.lstMatches,'Position');
         set(uih.lstMatches,'Position',[pos(1:2),pos(3)+hoffset,pos(4)+voffset])

         %update label positions
         for n = 1:length(h_lbls)
            pos = get(h_lbls(n),'Position');
            set(h_lbls(n),'Position',[pos(1),pos(2)+voffset,pos(3:4)])
         end

         %update button positions
         for n = 1:length(h_btns1)
            pos = get(h_btns1(n),'Position');
            set(h_btns1(n),'Position',[pos(1)+hoffset,pos(2)+voffset,pos(3:4)])
         end

         %update button positions
         for n = 1:length(h_btns2)
            pos = get(h_btns2(n),'Position');
            set(h_btns2(n),'Position',[pos(1),pos(2)+voffset+voffset2,pos(3:4)])
         end

         set(h_query,'Visible',qryvis)

         ui_search_data('buttons')

      case 'addpath'  %index a local directory for addition/update of current index

         subdir = get(uih.chkSubDir,'Value');  %check subdirectory option

         %prompt for path
         curpath = pwd;
         if isdir(uih.loadpath)
            cd(uih.loadpath)
         end
         if exist('uigetdir','file') == 2 || exist('uigetdir','builtin') == 5
            pn = uigetdir(uih.loadpath,'Select a directory of data sets to add to the search index');
         else
            [fn,pn] = uigetfile('*.mat;*.MAT','Select a directory of data sets to add to the search index');
         end
         cd(curpath)

         if pn ~= 0

            if strcmp(pn(end),filesep); pn = pn(1:end-1); end

            uih.loadpath = pn;  %update load path cache

            set(h_fig,'Pointer','watch')
            drawnow

            %index selected path
            index = search_index(pn,uih.index,'refresh',subdir);

            set(h_fig,'Pointer','arrow')
            drawnow

            if ~isempty(index)

               uih.index = index;
               set(h_fig,'UserData',uih)

               %incorporate updated index
               ui_search_data('newindex')

               %update indexed data sets counter
               numpaths = length(get(uih.lstPaths,'String'));
               set(uih.lstPaths,'Value',numpaths,'ListBoxTop',numpaths)

            else
               messagebox('init','No data structures were present in the specified directory','','Info',[.9 .9 .9])
            end

         end

      case 'clearindex'  %clear current index, prompting for confirmation

         if ~isempty(uih.index)

            if strcmp(data,'confirmed')
               confirm = 0;
            else
               confirm = 1;
            end

            if confirm == 1
               confirmdlg('init','Clear the entire search index?','ui_search_data(''clearindex'',''confirmed'')')
            else
               uih.index = [];
               set(h_fig,'UserData',uih)
               ui_search_data('newindex')
            end

         end

      case 'rempath'  %removed selected path and all corresponding data sets from index, update column list

         Isel = get(uih.lstPaths,'Value');

         if ~isempty(Isel)

            pns = get(uih.lstPaths,'UserData');
            index = uih.index;

            for n = 1:length(Isel)
               if ~isempty(index)
                  Ikeep = find(~strcmp({index.path}',pns{Isel(n)}));  %generate index of residual entries
                  if ~isempty(Ikeep)
                     index = index(Ikeep);  %apply index to remove selected path
                  else
                     index = [];
                  end
               end
            end

            %update index, populate listbox
            uih.index = index;
            set(h_fig,'UserData',uih)
            ui_search_data('newindex')

            set(uih.lstPaths,'Value',max(1,Isel(1)-1))

         end

      case 'refresh'  %refresh the search index, removing missing files, re-indexing changed files, adding new files

         if ~isempty(uih.index)

            pns = get(uih.lstPaths,'UserData');
            Ilocal = find(~strncmp(pns,'http',4) & ~strncmp(pns,'ftp',3));
            Iweb = find(strncmpi(pns,'http',4));

            if ~isempty(pns)

               pns = pns(Ilocal);

               set(h_fig,'Pointer','watch')
               drawnow

               index = search_index(pns,uih.index,'refresh',0);

               uih.index = index;

               set(h_fig,'UserData',uih)

               listval = get(uih.lstPaths,'Value');
               topsel = get(uih.lstPaths,'ListBoxTop');

               ui_search_data('newindex')

               numpaths = length(get(uih.lstPaths,'String'));
               set(uih.lstPaths,'Value',max(1,min(listval,numpaths)),'ListBoxTop',max(1,min(topsel,numpaths)))
               set(h_fig,'Pointer','arrow');
               drawnow

               %download and merge new web index if web paths present
               if ~isempty(Iweb)
                  confirmdlg('init','Refresh the GCE Web Index? (requires network access)', ...
                     'ui_search_data(''webindex'',''merge'')')
               end

            else
               messagebox('init','No local file to re-index (download a new web index to refresh remote file info)','','Info',[.9 .9 9])
            end

         end

      case 'select'  %handle select all/select none operations

         h_cbo = gcbo;
         str = get(uih.lstMatches,'String');

         if strcmp(get(h_cbo,'UserData'),'all')
            if ~isempty(str)
               Isel = [1:length(str)]';
               set(uih.lstMatches,'Value',Isel)
            end
         else
            set(uih.lstMatches,'Value',[])
         end

         ui_search_data('buttons')

      case 'map'  %opens a map for selection of a bounding box

         %update current bounding box
         bbox = [NaN NaN NaN NaN];
         wlon = get(uih.editWLon,'UserData'); if wlon > -180; bbox(1) = wlon; end
         elon = get(uih.editELon,'UserData'); if elon < 180; bbox(2) = elon; end
         slat = get(uih.editSLat,'UserData'); if slat > -90; bbox(3) = slat; end
         nlat = get(uih.editNLat,'UserData'); if nlat < 90; bbox(4) = nlat; end

         %open a new map if one not already opened
         h_map = findobj('Tag','BBox_Map','Type','figure');
         if isempty(h_map) && exist('bbox_map.fig','file') == 2
            open bbox_map.fig
            h_map = gcf;
            res = get(0,'ScreenSize');
            pos = get(h_map,'Position');
            pos2 = [res(3)-pos(3)-25 res(4)-pos(4)-75 pos(3) pos(4)];
            set(h_map,'Position',pos2,'Tag','BBox_Map','Name','Bounding Box Map')
            r12_axistitles
            mapbuttons('hide')
         else
            h_map = h_map(1);  %use last opened map if > 1
         end

         if ~isempty(h_map)

            figure(h_map)

            %delete existing bounding rectangles if present
            h = findobj(gcf,'tag','boundingbox');
            if ~isempty(h)
               delete(h)
            end

            %plot existing bounding box if valid
            if isempty(find(isnan(bbox)))
               ax = axis;
               if max(abs(ax)) > 180
                  [utm_z,utm_e,utm_n] = deg2utm([wlon;elon],[slat;nlat]);
                  bbox = [min(utm_e),max(utm_e),min(utm_n),max(utm_n)];
               end
               hold on
               h = plot([bbox(1),bbox(1),bbox(2),bbox(2),bbox(1)],[bbox(3),bbox(4),bbox(4),bbox(3),bbox(3)],'k-');
               set(h,'tag','boundingbox','linewidth',2,'color',[.6 .6 .6])
            end

            %set mouse button down function to get_bbox for rectangular boundary selection and plotting
            set(h_map, ...
               'WindowButtonDownFcn','get_bbox(''ui_search_data(''''bbox'''',bbox)'',1,''k'');', ...
               'Pointer','crosshair')

         else
            messagebox('init','The map file ''bbox_map.fig'' could not be located','','Error',[.9 .9 .9]);
         end

      case 'bbox'  %process bounding box data returns

         bbox = data;

         %pause for 0.5 sec for boundary plotting, switch back to search dialog
         pause(0.5)
         figure(h_fig)

         %check for deg/utm, reproject to lat/lon if necessary
         if max(abs(bbox)) <= 180
            wlon = bbox(1);
            elon = bbox(2);
            slat = bbox(3);
            nlat = bbox(4);
         else
            [lon,lat] = utm2deg(17,[bbox(1);bbox(2)],[bbox(3);bbox(4)]);
            wlon = min(lon);
            elon = max(lon);
            slat = min(lat);
            nlat = max(lat);
         end

         %update bbox fields
         set(uih.editWLon,'String',num2str(wlon),'UserData',wlon)
         set(uih.editELon,'String',num2str(elon),'UserData',elon)
         set(uih.editSLat,'String',num2str(slat),'UserData',slat)
         set(uih.editNLat,'String',num2str(nlat),'UserData',nlat)

      case 'clear'  %clear the selected matches from the list

         Isel = get(uih.lstMatches,'Value');

         if ~isempty(Isel)

            ui_search_data('autodeletetemp',Isel)  %delete temp files if option selected

            str = get(uih.lstMatches,'String');
            data = get(uih.lstMatches,'UserData');
            Ival = setdiff([1:length(str)]',Isel);
            if ~isempty(Ival)
               str = str(Ival);
               data.paths = data.paths(Ival);
               data.filenames = data.filenames(Ival);
               data.varnames = data.varnames(Ival);
            else
               str = '';
               data = [];
            end
            if ~isempty(str)
               val = max(1,min(length(str),min(Isel)-1));
               set(uih.lstMatches,'String',str,'UserData',data,'Value',val,'Listboxtop',val)
            else
               set(uih.lstMatches,'String',str,'UserData',data,'Value',1,'Listboxtop',1);
            end
            num_matches = length(str);
            if num_matches ~= 1
               set(uih.lblMatches,'String',['(',int2str(length(str)),' matches)'])
            else
               set(uih.lblMatches,'String','(1 match)')
            end

            ui_search_data('buttons')

         end

      case 'clearall'  %clear the selected matches from the list

         ui_search_data('autodeletetemp',[1:length(get(uih.lstMatches,'String'))])  %delete temp files if option selected

         set(uih.lstMatches,'String','','UserData','','Value',1,'ListBoxTop',1)
         set(uih.lblMatches,'String','(0 matches)')
         ui_search_data('buttons')

      case 'autodeletetemp'  %delete temp files if autodelete option selected

         Idel = data;  %get selection index from second argument

         h_opt = findobj(uih.mnuAutoDelete,'Checked','on');  %get checked option handle
         ud = get(h_opt,'UserData');

         if ud == 1  %check for yes option
            filedesc = get(uih.lstMatches,'String');  %get file descriptions from match list
            filedata = get(uih.lstMatches,'UserData');  %get file data from match list
            for n = 1:length(Idel)
               if strncmp(filedesc{Idel(n)},'temp',4)  %check for temp flag
                  fn = [filedata.paths{Idel(n)},filesep,filedata.filenames{Idel(n)}];  %create fully-qualified filename
                  if exist(fn,'file') == 2
                     try
                        delete(fn)
                     catch
                        %skip delete
                     end
                  end
               end
            end
         end

      case 'sort'  %sort the match list

         str = get(uih.lstMatches,'String');

         if ~isempty(str)
            Isel = get(uih.lstMatches,'Value');
            ud = get(uih.lstMatches,'UserData');
            [tmp,Isort] = sortrows(char(str));
            str = str(Isort);
            ud.paths = ud.paths(Isort);
            ud.filenames = ud.filenames(Isort);
            ud.varnames = ud.varnames(Isort);
            Inewsel = [];
            for n = 1:length(Isel)
               Inewsel = [Inewsel ; find(Isort==Isel(n))];
            end
            if ~isempty(Inewsel)
               boxtop = min(Inewsel);
            else
               boxtop = 1;
            end
            set(uih.lstMatches, ...
               'String',str,'UserData',ud,'Value',Inewsel,'ListBoxTop',boxtop)
         end

      case 'bboxoption'  %toggle map mode settings

         tagstr = get(gcbo,'Tag');

         if strcmp(tagstr,'radioMapInclusive')
            val_inc = 1;
            val_exc = 0;
         else
            val_inc = 0;
            val_exc = 1;
         end

         set(uih.radioMapInclusive,'Value',val_inc)
         set(uih.radioMapExclusive,'Value',val_exc)
         drawnow

      case 'searchtype'  %toggle search type settings

         tagstr = get(gcbo,'Tag');

         if strcmp(tagstr,'radioMatchAll')
            val_all = 1;
            val_any = 0;
         else
            val_all = 0;
            val_any = 1;
         end

         set(uih.radioMatchAll,'Value',val_all)
         set(uih.radioMatchAny,'Value',val_any)
         drawnow

      case 'resetbbox'  %reset bounding box fields

         h_bbox = [uih.editNLat ; uih.editWLon ; uih.editELon ; uih.editSLat];
         set(h_bbox,'String','','UserData',[])

      case 'reset'  %reset uicontrols

         txtflds = [uih.editMetaStr ; ...
               uih.editKeyword; ...
               uih.editAuthor; ...
               uih.editTaxa; ...
               uih.editDateStart; ...
               uih.editDateEnd; ...
               uih.editWLon; ...
               uih.editELon; ...
               uih.editSLat; ...
               uih.editNLat];

         set(uih.popDateType,'Value',1)
         set(uih.popMetaField,'Value',length(get(uih.popMetaField,'String')))
         set(txtflds,'String','','UserData',[])
         set(uih.popSite,'Value',1)
         set(uih.lstVars,'Value',1)
         set(uih.lblVars,'String','(0 selected)')

         ui_search_data('buttons')

      case 'varlist'  %update variable list label, selections

         Isel = get(uih.lstVars,'Value');

         numvars = length(Isel);
         if numvars > 0
            Itop = find(Isel==1);
            if ~isempty(Itop)
               set(uih.lstVars,'Value',1,'Listboxtop',1)
               numvars = 0;
            end
         end

         set(uih.lblVars,'String',['(',int2str(numvars),' selected)'])

      case 'date'  %validate date entries

         h_cbo = gcbo;

         str = deblank(get(h_cbo,'String'));
         lastval = get(h_cbo,'UserData');

         if ~isempty(str)

            %check for date/time formats
            if length(str) == 4  %check for year only
               yr = str2double(str);
               if ~isnan(yr)
                  if strcmp(get(h_cbo,'Tag'),'editDateEnd')
                     yr = yr + 1;
                  end
                  try
                     dt = datenum(['1/1/',int2str(yr)]);
                  catch
                     dt = [];
                  end
               else
                  dt = [];
               end
            else
               try
                  dt = datenum(str);
               catch
                  dt = [];
               end
            end

            errmsg = '';
            if isempty(dt)
               set(h_cbo,'String',datestr(lastval),'UserData',lastval)
               errmsg = 'Unrecognized date format - value reset';
            else
               set(h_cbo,'String',datestr(dt),'UserData',dt)
               dt_start = get(uih.editDateStart,'UserData');
               dt_end = get(uih.editDateEnd,'UserData');
               if ~isempty(dt_start) && ~isempty(dt_end)
                  if dt_end < dt_start
                     set(h_cbo,'String',datestr(lastval),'UserData',lastval)
                     errmsg = 'Invalid date (ending date cannot preceed starting date)';
                  end
               end
            end

            drawnow

            if ~isempty(errmsg)
               messagebox('init',errmsg,'','Alert',[.9 .9 .9]);
            end

         else
            set(h_cbo,'UserData',[])  %clear indexd dt value
         end

      case 'datetype'  %handle date search type events

         Isel = get(uih.popDateType,'Value');
         if Isel == 2
            set(uih.editDateEnd,'String','','UserData',[])  %clear DateEnd value
         end

         ui_search_data('buttons')


      case 'coords'  %validate coordinate entries

         h_cbo = gcbo;
         str = deblank(get(h_cbo,'String'));

         if ~isempty(str)

            if ~isempty(strfind(get(h_cbo,'Tag'),'Lon'))
               coordtype = 'lon';
            else
               coordtype = 'lat';
            end

            str = strrep(strrep(str,char(176),' '),char(186),' ');
            ar = splitstr(str,' ');

            val = [];
            lastval = get(h_cbo,'UserData');
            deg = [];
            mn = [];
            sec = [];
            sgn = 1;

            if ~isempty(ar) && length(ar) <= 3
               deg = str2double(ar{1});
               if deg < 0
                  sgn = -1;
               end
               mn = 0;
               sec = 0;
               if length(ar) == 3
                  if strcmp(coordtype,'lon')
                     sgn = -1;  %force western hem for dms
                  end
                  mn = str2double(ar{2});
                  sec = str2double(ar{3});
               elseif length(ar) == 2
                  if strcmp(coordtype,'lon')
                     sgn = -1;  %force western hem for dms
                  end
                  sng = -1;  %forst western hem for deg/min
                  mn = str2dboule(ar{2});
               end
            end

            if ~isnan(deg) && ~isnan(mn) && ~isnan(sec)
               val = (abs(deg) + abs(mn)./60 + abs(sec)./3600) .* sgn;
               if strcmp(coordtype,'Lon')
                  if abs(val) > 180
                     val = [];
                  end
               else
                  if abs(val) > 90
                     val = [];
                  end
               end
            end

            if ~isempty(val)
               set(h_cbo,'String',num2str(val),'UserData',val)
               drawnow
            else
               set(h_cbo,'String',num2str(lastval))
               drawnow
               messagebox('init','Invalid geographic coordinate - value reset','','Alert',[.9 .9 .9]);
            end

         else
            set(h_cbo,'String','','UserData',NaN)
         end

      case 'queryclick'

         if strcmp(get(gcf,'SelectionType'),'open')
            ui_search_data('loadquery')
         end

      case 'loadquery'  %parse query string from history list and load uicontrols

         if ~isempty(uih.queries)

            Isel = get(uih.lstQueries,'Value');

            if length(Isel) == 1

               queries = get(uih.lstQueries,'String');
               qry = queries{Isel};
               ar = splitstr(qry,';');  %split query parameters by semicolon delimiters

               %init query terms
               match_case = 0;  %default to case insensitive text searches
               exclusive = 1;   %default to exclusive searches (all terms match)
               metafield = '';
               metastr = '';
               keyword = '';
               author = '';
               taxa = '';
               datestart = [];
               dateend = [];
               datecontains = [];
               site = '';
               columns = [];
               bbox = [];
               bboxmode = 'inside';  %default to datesets inside bbox

               %parse individual query statements
               for n = 1:length(ar)
                  vals = splitstr(ar{n},'=');
                  if length(vals) == 2
                     fld = vals{1};
                     opt = vals{2};
                     switch fld
                        case 'MatchType'
                           if strcmp(opt,'all')
                              exclusive = 1;
                           else
                              exclusive = 0;
                           end
                        case 'MatchCase'
                           if strcmp(opt,'TRUE')
                              match_case = 1;
                           else
                              match_case = 0;
                           end
                        case 'Keywords'
                           keyword = opt;
                        case 'Author'
                           author = opt;
                        case 'Taxa'
                           taxa = opt;
                        case 'DateStart'
                           datestart = datenum(opt);
                        case 'DateEnd'
                           dateend = datenum(opt);
                        case 'DateContains'
                           datecontains = datenum(opt);
                        case 'Sites'
                           site = opt;
                        case 'Columns'
                           columns = splitstr(opt,',');
                        case 'BoundingBox'
                           bbox = str2num(opt);
                        case 'BoundingBoxMode'
                           bboxmode = opt;
                        otherwise  %metadata field
                           metafield = fld;
                           metastr = opt;
                     end
                  end
               end

               %update query option settings
               if exclusive == 1
                  set(uih.radioMatchAll,'Value',1)
                  set(uih.radioMatchAny,'Value',0)
               else
                  set(uih.radioMatchAll,'Value',0)
                  set(uih.radioMatchAny,'Value',1)
               end

               %update case sensitive setting
               set(uih.chkMatchCase,'Value',match_case)

               %update metadata field selection
               Ifld = find(strcmp(uih.metafields(:,1),metafield));
               if ~isempty(Ifld)
                  set(uih.popMetaField,'Value',Ifld(1))
               else
                  set(uih.popMetaField,'Value',1)
               end

               %fill editboxes
               set(uih.editMetaStr,'String',metastr)
               set(uih.editKeyword,'String',keyword)
               set(uih.editAuthor,'String',author)
               set(uih.editTaxa,'String',taxa)

               %fill date search fields, set uicontrols
               if ~isempty(datecontains)
                  set(uih.editDateStart,'String',datestr(datecontains),'UserData',datecontains)
                  set(uih.editDateEnd,'String','','UserData',[],'Visible','off')
                  set(uih.popDateType,'Value',2)
                  set(uih.lblDateSep,'Visible','off')
               else
                  set(uih.editDateStart,'String',datestr(datestart),'UserData',datestart)
                  set(uih.editDateEnd,'String',datestr(dateend),'UserData',dateend,'Visible','on')
                  set(uih.popDateType,'Value',1)
                  set(uih.lblDateSep,'Visible','on')
               end

               %fill bounding box fields
               if isempty(bbox)
                  bbox = [NaN NaN NaN NaN];
               end
               if ~isnan(bbox(1))
                  set(uih.editWLon,'String',num2str(bbox(1)),'UserData',bbox(1))
               else
                  set(uih.editWLon,'String','','UserData',[])
               end
               if ~isnan(bbox(2))
                  set(uih.editELon,'String',num2str(bbox(2)),'UserData',bbox(2))
               else
                  set(uih.editELon,'String','','UserData',[])
               end
               if ~isnan(bbox(3))
                  set(uih.editSLat,'String',num2str(bbox(3)),'UserData',bbox(3))
               else
                  set(uih.editSLat,'String','','UserData',[])
               end
               if ~isnan(bbox(4))
                  set(uih.editNLat,'String',num2str(bbox(4)),'UserData',bbox(4))
               else
                  set(uih.editNLat,'String','','UserData',[])
               end

               %set bounding box radios
               if strcmp(bboxmode,'intersect')
                  set(uih.radioMapInclusive,'Value',1)
                  set(uih.radioMapExclusive','Value',0)
               else  %inside
                  set(uih.radioMapInclusive,'Value',0)
                  set(uih.radioMapExclusive,'Value',1)
               end

               %set site popup, adding site to list if not present
               allsites = get(uih.popSite,'UserData');
               Isite = find(strcmp(allsites,site));
               if ~isempty(Isite)
                  set(uih.popSite,'Value',Isite)
               else
                  str = get(uih.popSite,'String');
                  set(uih.popSite,'String',[str ; {site}],'UserData',[allsites ; {site}]);
               end

               %set column selections, but don't add useless columns that aren't in index
               allvars = get(uih.lstVars,'String');
               Isel = [];
               for n = 1:length(columns)
                  Ivar = find(strcmp(allvars,columns{n}));
                  if ~isempty(Ivar)
                     Isel = [Isel ; Ivar];
                  end
               end
               if isempty(Isel)
                  set(uih.lstVars,'Value',1,'ListBoxTop',1)
                  set(uih.lblVars,'String','(0 selected)')
               else
                  set(uih.lstVars,'Value',Isel,'ListBoxTop',min(Isel))
                  set(uih.lblVars,'String',['(',int2str(length(Isel)),' selected)'])
               end

            end

         end

      case 'clearquery'  %clear selected query from history list

         if ~isempty(uih.queries)
            Isel = get(uih.lstQueries,'Value');
            if ~isempty(Isel)
               str = get(uih.lstQueries,'String');
               Irem = setdiff([1:length(str)]',Isel);
               if ~isempty(Irem)
                  set(uih.lstQueries,'String',str(Irem),'Value',max(1,Isel-1), ...
                     'ListBoxTop',min(length(Irem),get(uih.lstQueries,'ListBoxTop')))
                  uih.queries = uih.queries(Irem);
               else
                  set(uih.lstQueries,'String','','Value',1,'ListBoxTop',1)
                  uih.queries = [];
               end
               set(h_fig,'UserData',uih)
               ui_search_data('buttons')
            end
         end

      case 'clearqueryall'  %clear all stored queries

         if ~isempty(uih.queries)
            uih.queries = [];
            set(h_fig,'UserData',uih)
            set(uih.lstQueries,'String','','Value',1,'ListBoxTop',1)
            ui_search_data('buttons')
         end

      case 'buttons'  %refresh button and menu states according to status of listboxes

         %update upper panel button status based on path listbox
         index_items = [uih.cmdRemPath; ...
               uih.cmdRefresh; ...
               uih.cmdSearch; ...
               uih.mnuSaveIndex; ...
               uih.mnuClearIndex; ...
               uih.mnuMergeIndex];
         if isempty(uih.index)
            vis = 'off';  %disable if no paths
         else
            vis = 'on';  %enable if paths
         end
         set(index_items,'Enable',vis)

         %update query button status based on query listbox
         querybtns = [uih.cmdLoadQuery; ...
               uih.cmdClearQuery; ...
               uih.cmdClearQueryAll];
         if isempty(uih.queries)
            set(querybtns,'Enable','off')
         else
            set(querybtns,'Enable','on')
         end
         if isempty(uih.index)  %disable run query if no active index
            set(uih.cmdLoadQuery,'Enable','off')
         end

         %update lower panel button status and menu status based on matches listbox
         match_items = [uih.mnuExport; ...
               uih.mnuCopy; ...
               uih.mnuJoin; ...
               uih.mnuMerge; ...
               uih.cmdEditor; ...
               uih.cmdPlotXY; ...
               uih.cmdPlotGroups; ...
               uih.cmdMapPlot; ...
               uih.cmdClear; ...
               uih.cmdClearAll; ...
               uih.cmdSelectAll; ...
               uih.cmdSort; ...
               uih.cmdSummary; ...
               uih.cmdSelectNone];
         matchsinglebtns = [uih.cmdPlotXY; ...
               uih.cmdPlotGroups; ...
               uih.cmdMapPlot; ...
               uih.cmdSummary];
         matchtwo = [uih.mnuJoin];
         matchmultiple = [uih.mnuMerge];

         str = get(uih.lstMatches,'String');

         if isempty(str)

            set(match_items,'Enable','off')

         else

            set(match_items,'Enable','on')
            set(uih.mnuSaveAll,'Enable','on')

            %disable buttons requiring single selection if multiple match items selected
            Isel = get(uih.lstMatches,'Value');
            if isempty(Isel)
               set(match_items,'Enable','off')
               set(uih.cmdSelectAll,'Enable','on')
               set(uih.cmdClearAll,'Enable','on')
            elseif length(Isel) == 1
               set(matchmultiple,'Enable','off')
               set(matchtwo,'Enable','off')
            elseif length(Isel) > 1
               set(matchsinglebtns,'Enable','off')
               if length(Isel) > 2
                  set(matchtwo,'Enable','off')
               end
            end

         end

         %set visibility for date fields
         Isel = get(uih.popDateType,'Value');
         if Isel == 1
            vis = 'on';
         else
            vis = 'off';
         end
         set(uih.editDateEnd,'Visible',vis)
         set(uih.lblDateSep,'Visible',vis)

         drawnow

      case 'editor'  %pass selected data sets to ui_editor instances for viewing/editing

         Isel = get(uih.lstMatches,'Value');
         badfiles = 0;

         if ~isempty(Isel)
            userdata = get(uih.lstMatches,'UserData');
            set(h_fig,'Pointer','watch'); drawnow
            for n = 1:length(Isel)
               s = sub_loadstruct(userdata.paths{Isel(n)},userdata.filenames{Isel(n)},userdata.varnames{Isel(n)}, ...
                  uih.user_registration);
               if ~isempty(s)
                  ui_editor('init',s)
                  ui_editor('rename2','title')
               else
                  badfiles = badfiles + 1;
               end
            end
            set(h_fig,'Pointer','arrow'); drawnow
         end

         if badfiles > 0
            messagebox('init',[int2str(badfiles),' structure(s) could not be loaded (try refreshing the search index)'], ...
               '','Warning',[.9 .9 .9])
         end

      case 'showpath'  %catch double clicks on path list to show path details

         if strcmp(get(gcf,'SelectionType'),'open')
            index = uih.index;
            allpaths = get(uih.lstPaths,'UserData');
            pn = allpaths{get(uih.lstPaths,'Value')};
            Ipaths = find(strcmp({index.path},pn));
            if ~isempty(Ipaths)
               index = index(Ipaths);
               numrows = length(Ipaths);
               fn = {index.filename}';
               if strncmp(pn,'http',4)
                  for n = 1:numrows
                     Ipos = max(strfind(fn{n},'='));
                     if ~isempty(Ipos)
                        fn{n} = fn{n}(Ipos+1:end);
                     end
                  end
               end
               str = concatcellcols([fn,repmat({' ('},numrows,1), ...
                     {index.filedate}',repmat({')'},numrows,1),repmat({' - '},numrows,1),{index.title}'],'');
               ui_viewtext(str,0,0,pn)
               figure(gcf)  %force text view to foreground in ML 5.3
            end
         end

      case 'matches'  %catch double clicks on the match list and retrieve metadata

         ud = get(uih.lstMatches,'UserData');

         if ~isempty(ud)

            if strcmp(get(gcf,'SelectionType'),'open')

               h_metaopt = findobj(uih.mnuMetadata,'Checked','on');
               metaopt = get(h_metaopt,'UserData');
               if isempty(metaopt)
                  metaopt = 'GCE';  %use GCE style if metadata disabled for export
               end
               errmsg = '';

               Isel = get(uih.lstMatches,'Value');

               if length(Isel) == 1
                  userdata = get(uih.lstMatches,'UserData');
                  set(h_fig,'Pointer','watch'); drawnow
                  s = sub_loadstruct(userdata.paths{Isel},userdata.filenames{Isel},userdata.varnames{Isel}, ...
                     uih.user_registration);
                  set(h_fig,'Pointer','arrow'); drawnow
                  if ~isempty(s)
                     ui_viewmeta(s,metaopt);
                     h_dlg = gcf;
                     if ~isempty(h_dlg)
                        if strcmp(get(h_dlg,'Tag'),'dlgViewText')
                           try
                              figure(h_dlg)  %force focus for ML 5.3
                           catch
                              figure(h_fig)
                           end
                        end
                     end
                  else
                     errmsg = 'File not found or specified column not present in the .mat file (try refreshing the search index)';
                  end
               end

               if ~isempty(errmsg)
                  messagebox('init',errmsg,'','Error',[.9 .9 .9])
                  figure(gcf)
               end

            else
               ui_search_data('buttons')  %only refresh button state
            end
         end

      case 'plotxy'  %pass data to ui_plotdata for plotting

         Isel = get(uih.lstMatches,'Value');

         errmsg = '';
         if length(Isel) == 1
            userdata = get(uih.lstMatches,'UserData');
            set(h_fig,'Pointer','watch'); drawnow
            s = sub_loadstruct(userdata.paths{Isel},userdata.filenames{Isel},userdata.varnames{Isel}, ...
               uih.user_registration);
            set(h_fig,'Pointer','arrow'); drawnow
            if ~isempty(s)
               ui_plotdata('init',s)
            else
               errmsg = 'The data structure could not be loaded (try refreshing the search index)';
            end
         elseif length(Isel) > 1
            errmsg = 'This function does not support multiple selections';
         end

         if ~isempty(errmsg)
            messagebox('init',errmsg,'','Info',[.9 .9 .9])
         end

      case 'plotgroups'  %pass data to ui_plotgroups for plotting by groups

         Isel = get(uih.lstMatches,'Value');

         errmsg = '';
         if length(Isel) == 1
            userdata = get(uih.lstMatches,'UserData');
            set(h_fig,'Pointer','watch'); drawnow
            s = sub_loadstruct(userdata.paths{Isel},userdata.filenames{Isel},userdata.varnames{Isel}, ...
               uih.user_registration);
            set(h_fig,'Pointer','arrow'); drawnow
            if ~isempty(s)
               ui_plotgroups('init',s)
            else
               errmsg = 'The data structure could not be loaded (try refreshing the search index)';
            end
         elseif length(Isel) > 1
            errmsg = 'This function does not support multiple selections';
         end

         if ~isempty(errmsg)
            messagebox('init',errmsg,'','Info',[.9 .9 .9])
         end

      case 'plotmap'  %pass data to ui_mapdata for plotting on maps

         Isel = get(uih.lstMatches,'Value');

         errmsg = '';
         if length(Isel) == 1
            userdata = get(uih.lstMatches,'UserData');
            set(h_fig,'Pointer','watch'); drawnow
            s = sub_loadstruct(userdata.paths{Isel},userdata.filenames{Isel},userdata.varnames{Isel}, ...
               uih.user_registration);
            set(h_fig,'Pointer','arrow'); drawnow
            if ~isempty(s)
               ui_mapdata('init',s)
            else
               errmsg = 'The data structure could not be loaded (try refreshing the search index)';
            end
         elseif length(Isel) > 1
            errmsg = 'This function does not support multiple selections';
         end

         if ~isempty(errmsg)
            messagebox('init',errmsg,'','Info',[.9 .9 .9])
         end

      case 'summary'  %display summary stats

         Isel = get(uih.lstMatches,'Value');

         errmsg = '';
         if length(Isel) == 1
            userdata = get(uih.lstMatches,'UserData');
            set(h_fig,'Pointer','watch'); drawnow
            s = sub_loadstruct(userdata.paths{Isel},userdata.filenames{Isel},userdata.varnames{Isel}, ...
               uih.user_registration);
            set(h_fig,'Pointer','arrow'); drawnow
            if ~isempty(s)
               viewstats(s,'I');
            else
               errmsg = 'The data structure could not be loaded (try refreshing the search index)';
            end
         elseif length(Isel) > 1
            errmsg = 'This function does not support multiple selections';
         end

         if ~isempty(errmsg)
            messagebox('init',errmsg,'','Info',[.9 .9 .9])
         end

      case 'join'  %join two structures

         %get userdata from menu item to determine manual/automatic option
         strOption = get(gcbo,'UserData');
         if strcmp(strOption,'auto')
            autojoin = 1;
         else
            autojoin = 0;
         end

         %get autoadd option
         autoaddopt = get(findobj(uih.mnuAutoAdd,'Checked','on'),'UserData');

         Isel = get(uih.lstMatches,'Value');

         errmsg = '';
         if length(Isel) == 2
            userdata = get(uih.lstMatches,'UserData');
            set(h_fig,'Pointer','watch'); drawnow
            s1 = sub_loadstruct(userdata.paths{Isel(1)},userdata.filenames{Isel(1)},userdata.varnames{Isel(1)}, ...
               uih.user_registration);
            s2 = sub_loadstruct(userdata.paths{Isel(2)},userdata.filenames{Isel(2)},userdata.varnames{Isel(2)}, ...
               uih.user_registration);
            set(h_fig,'Pointer','arrow'); drawnow
            if ~isempty(s1) && ~isempty(s2)
               if autoaddopt == 1
                  ui_joindata('init',s1,s2,userdata.filenames{Isel(2)},h_fig,uih.mnuJoin,'ui_search_data(''cachetemp'',''join'')',autojoin);
               else
                  ui_joindata('init',s1,s2,userdata.filenames{Isel(2)},[],[],'',autojoin);
               end
            else
               errmsg = 'One or both data structures could not be loaded (try refreshing the search index)';
            end
         elseif length(Isel) > 1
            errmsg = 'This function requires two data set selections';
         end

         if ~isempty(errmsg)
            messagebox('init',errmsg,'','Info',[.9 .9 .9])
         end

      case 'cachetemp'  %cache in-memory dataset from external tool, add to resultset

         if gce_valid(data,'data')
            acc = 'Editor';
         else
            cb = data;  %get callback handle containing cached data
            data = [];  %init data var
            if ~isempty(cb)
               switch cb
                  case 'join'
                     h_cb = uih.mnuJoin;
                     acc = 'Join';
                  case 'merge'
                     h_cb = uih.mnuMerge;
                     acc = 'Merge';
                  otherwise
                     h_cb = '';
                     acc = '';
               end
               if ~isempty(h_cb)
                  data = get(h_cb,'UserData');
               end
            end
         end

         if ~isempty(data)

            if ~strcmp(acc,'Editor')
               ui_editor(data)  %open dataset in editor unless data sent from editor instance
               drawnow
            end

            curpath = pwd;
            toolpath = gce_homepath;

            %create cache directory if doesn't exist
            if isdir([toolpath,filesep,'search_temp'])
               cachepath = [toolpath,filesep,'search_temp'];
            else
               try
                  mkdir(toolpath,'search_temp')
                  cachepath = [toolpath,filesep,'search_temp'];
               catch
                  cachepath = curpath;
               end
            end

            %generate unique filename based on date
            dt = now;
            fn = ['temp_dataset_',datestr(dt,1),'_',strrep(datestr(dt,13),':',''),'.mat'];
            save([cachepath,filesep,fn],'data')

            %update stored match data
            ud = get(uih.lstMatches,'UserData');
            if isempty(ud)
               ud = struct('paths','','filenames','','varnames','');
               ud.paths = {cachepath};
               ud.filenames = {fn};
               ud.varnames = {'data'};
            else
               ud.paths = [ud.paths ; {cachepath}];
               ud.filenames = [ud.filenames ; {fn}];
               ud.varnames = [ud.varnames ; {'data'}];
            end

            %format study dates
            begindatestr = lookupmeta(data,'Study','BeginDate');
            enddatestr = lookupmeta(data,'Study','EndDate');
            studydatestr = '';
            if ~isempty(begindatestr) && ~isempty(enddatestr)
               try
                  begindate = datenum(begindatestr);
                  enddate = datenum(enddatestr);
               catch
                  begindate = [];
                  enddate = [];
               end
            else
               begindate = [];
               enddate = [];
            end

            %try to get dates from data table
            if isempty(begindate) || isempty(enddate)
               dt = get_studydates(data);
               if ~isempty(dt)
                  begindate = min(dt(~isnan(dt)));
                  enddate = max(dt(~isnan(dt)));
               end
            end

            %format date string
            if ~isempty(begindate) && ~isempty(enddate)
                studydatestr = [' (period: ',datestr(begindate,6),'/',datestr(begindate,10), ...
                      ' - ',datestr(enddate,6),'/',datestr(enddate,10),')'];
            end

            %format title
            titlestr = data.title;
            if length(titlestr) > 300
               titlestr = [titlestr(1:297),'...'];
            end

            %generate match list label
            str = [get(uih.lstMatches,'String') ; ...
                  {['temp/  [From ',acc,'] - ',titlestr,studydatestr]}];

            set(uih.lstMatches, ...
               'String',str, ...
               'UserData',ud, ...
               'ListboxTop',length(str), ...
               'Value',length(str))  %add new data set to match list

            ui_search_data('buttons')  %update button status

         end

      case 'merge'  %merge selected data sets

         %get merge type stored in menu userdata
         mergetype = get(gcbo,'UserData');

         %get autoadd option
         autoaddopt = get(findobj(uih.mnuAutoAdd,'Checked','on'),'UserData');

         %get metadata merge option
         h_metaopt = findobj(uih.mnuMergeMeta,'Checked','on');
         metaopt = get(h_metaopt,'UserData');

         %get flag option
         h_flagopt = findobj(uih.mnuFlags,'Checked','on');
         flagopt = get(h_flagopt,'UserData');
         if ~isempty(flagopt)
            flagfnc = flagopt{1};
            flags = flagopt{2};
         end

         %get lock flags option
         h_lockflags = findobj(uih.mnuLockFlags,'Checked','on');
         lockflags = get(h_lockflags,'UserData');

         %get data set name column option
         h_datasetnames = findobj(uih.mnuMergeDatasetNames,'Checked','on');
         datasetnames = get(h_datasetnames,'UserData');

         %get list selections, cached data
         Isel = get(uih.lstMatches,'Value');
         userdata = get(uih.lstMatches,'UserData');

         fn_bad = [];  %init list of bad files

         if length(Isel) >= 2 && ~isempty(userdata)

            %init runtime vars
            filelist = [];
            structlist = [];

            set(h_fig,'Pointer','watch'); drawnow

            for n = 1:length(Isel)

               %get path, file, variable name from index
               pn0 = userdata.paths{Isel(n)};
               fn = userdata.filenames{Isel(n)};
               var = userdata.varnames{Isel(n)};

               %retrieve web-based files
               if strncmp(pn0,'http',4)
                  [pn0,fn] = sub_fetchstruct(pn0,fn,uih.user_registration);  %retrieve cached web file path/file or fetch file
               end

               %add to filelist or bad file list
               if ~isempty(fn)
                  filelist = [filelist ; {[pn0,filesep,fn]}];
                  structlist = [structlist ; {var}];
               else
                  fn_bad = [fn_bad ; {[pn0,filesep,fn]}];
               end

            end

            set(h_fig,'Pointer','arrow'); drawnow

            if length(filelist) >= 2

               set(h_fig,'Pointer','watch'); drawnow

               [s,msg,fn_bad2] = multimerge(filelist,structlist,mergetype,lockflags,metaopt,datasetnames,flagfnc,flags);

               set(h_fig,'Pointer','arrow'); drawnow

               if ~isempty(s)
                  if autoaddopt == 1
                     set(uih.mnuMerge,'UserData',s)
                     ui_search_data('cachetemp','merge')  %open dataset in editor window and add to match list
                  else
                     ui_editor('init',s)
                  end
               end

               fn_bad = [fn_bad ; fn_bad2];

               if isempty(msg) && ~isempty(fn_bad)
                  msg = [length(fn_bad),' file(s) could not be found or could not be merged'];
               end

               if ~isempty(fn_bad)
                  msg = char([msg,'; bad files:'],char(fn_bad));
                  messagebox('init',msg,'','Warning',[.9 .9 .9])
               end

            else
               messagebox('init',[int2str(length(Isel)-length(filelist)),' data set(s) could not be found - insufficient files for merging'],'','Error',[.9 .9 .9])
            end

         else
            messagebox('init','This operation requires two or more data sets','','Info',[.9 .9 .9])
         end

      case 'copy'  %copy selected files to a new directory

         Isel = get(uih.lstMatches,'Value');
         userdata = get(uih.lstMatches,'UserData');

         if ~isempty(Isel) && ~isempty(userdata)

            goodfiles = 0;
            badfiles = 0;
            errmsg = '';

            curpath = pwd;
            if isdir(uih.savepath)
               cd(uih.savepath)
            end
            if exist('uigetdir','file') == 2 || exist('uigetdir','builtin') == 5
               pn = uigetdir(pwd,'Select a location for the data set copies');
            else
               fn = userdata.filenames{Isel(1)};
               if ~isempty(strfind(fn,'='))
                  fn = fliplr(strtok(fliplr(fn),'='));
               end
               [fn,pn] = uiputfile(fn,'Select a location for the data sets copies');
               pn = clean_path(pn); %strip terminal file separator
            end
            drawnow
            cd(curpath)

            if pn ~= 0

               uih.savepath = pn;
               set(h_fig,'UserData',uih,'Pointer','watch'); drawnow

               if length(Isel) > 1
                  ui_progressbar('init',length(Isel),'File Copy Progress')
                  drawnow
                  pbar = 1;
               else
                  pbar = 0;
               end

               if exist('copyfile','file') == 2 || exist('copyfile','builtin') == 5
                  for n = 1:length(Isel)
                     pn0 = userdata.paths{Isel(n)};
                     fn = userdata.filenames{Isel(n)};
                     if strncmp(pn0,'http',4)
                        [pn0,fn] = sub_fetchstruct(pn0,fn,uih.user_registration);  %retrieve cached web file path/file or fetch file
                     end
                     if ~isempty(fn)
                        [status,msg] = copyfile([pn0,filesep,fn],pn);
                        if status == 1
                           goodfiles = goodfiles + 1;
                        else
                           badfiles = badfiles + 1;
                        end
                     else
                        badfiles = badfiles + 1;
                     end
                     if pbar == 1
                        ui_progressbar('update',n)
                        drawnow
                     end
                  end
               else
                  for n = 1:length(Isel)
                     pn0 = userdata.paths{Isel(n)};
                     fn = userdata.filenames{Isel(n)};
                     if strncmp(pn0,'http',4)
                        [pn0,fn] = sub_fetchstruct(pn0,fn,uih.user_registration);  %retrieve cached web file path/file or fetch file
                     end
                     if ~isempty(fn)
                        try
                           if strcmp(computer,'PCWIN')
                              [status,stdio] = system(['copy "',fn,'" "',pn,'"']);
                           else
                              [status,stdio] = system(['cp ',fn,' ',pn]);
                           end
                           goodfiles = goodfiles + 1;
                        catch
                           badfiles = badfiles + 1;
                        end
                     else
                        badfiles = badfiles + 1;
                     end
                     if pbar == 1
                        ui_progressbar('update',n)
                        drawnow
                     end
                  end
               end
               figure(h_fig)
               set(h_fig,'Pointer','arrow'); drawnow

               if badfiles > 0
   	            messagebox('init',[int2str(goodfiles),' file(s) successfully copied to destination, ',int2str(badfiles), ...
      	               ' file(s) could not be found and were skipped'],'','Info',[.9 .9 .9])
               else
   	            messagebox('init',[int2str(goodfiles),' file(s) successfully copied to destination'],'','Info',[.9 .9 .9])
               end

            end
         end

      case 'export'  %export data in text or matlab formats

         Isel = get(uih.lstMatches,'Value');
         userdata = get(uih.lstMatches,'UserData');

         if ~isempty(Isel) && ~isempty(userdata)

            h_cbo = gcbo;
            ud = get(h_cbo,'UserData');  %get format from uimenu item userdata

            missingchar = 'NaN';  %set default missing value code for exp_ascii

            switch ud
            case 'textcomma'
               fmt = 'ascii';
               filefmt = 'comma';
               ext = '.txt';
            case 'textcsv'
               fmt = 'ascii';
               filefmt = 'csv';
               ext = '.csv';
               missingchar = '';
            case 'texttab'
               fmt = 'ascii';
               filefmt = 'tab';
               ext = '.txt';
            case 'textspace'
               fmt = 'ascii';
               filefmt = 'del';
               ext = '.txt';
            case 'mlvars'
               fmt = 'matlab';
               filefmt = 'vars';
               ext = '_vars.mat';
            case 'mlmat'
               fmt = 'matlab';
               filefmt = 'mat';
               ext = '_mat.mat';
            otherwise
               fmt = '';
               filefmt = '';
               ext = '';
            end

            %get other menu options
            h_metaopt = findobj(uih.mnuMetadata,'Checked','on');
            metaopt = get(h_metaopt,'UserData');

            h_headeropt = findobj(uih.mnuHeader,'Checked','on');
            headeropt = get(h_headeropt,'UserData');

            h_flagopt = findobj(uih.mnuFlags,'Checked','on');
            flagopt = get(h_flagopt,'UserData');
            if ~isempty(flagopt)
               flagfnc = flagopt{1};
               flags = flagopt{2};
            end

            %init counters
            badfiles = 0;
            goodfiles = 0;

            %prompt for export path
            curpath = pwd;
            if isdir(uih.savepath)
               cd(uih.savepath)
            end
            if exist('uigetdir','file') == 2 || exist('uigetdir','builtin') == 5
               pn = uigetdir(uih.savepath,'Select a location for the exported files');
            else
               fn = userdata.filenames{Isel(1)};
               if ~isempty(strfind(fn,'='))
                  fn = fliplr(strtok(fliplr(fn),'='));
               end
               [tmp,fn_base] = fileparts(fn);
               [fn,pn] = uiputfile([fn_base,ext],'Select a location for the exported files');
               pn = clean_path(pn); %strip terminal file separator
            end
            drawnow
            cd(curpath)

            if pn ~= 0

               %update save path cache
               uih.savepath = pn;
               set(h_fig,'UserData',uih,'Pointer','watch')

               %init progress bar if 2 or more operations
               if length(Isel) > 1
                  ui_progressbar('init',length(Isel),'Data Export Progress');
                  drawnow
                  pbar = 1;
               else
                  pbar = 0;
               end

               %loop through file list
               for n = 1:length(Isel)

                  pn0 = userdata.paths{Isel(n)};
                  fn = userdata.filenames{Isel(n)};
                  var = userdata.varnames{Isel(n)};

                  %check for web file, get local path, name of cached file
                  if strncmp(pn0,'http',4)
                     [pn0,fn] = sub_fetchstruct(pn0,fn,uih.user_registration);  %retrieve cached web file path/file or fetch file
                  end

                  if ~isempty(fn)

                     fullfn = [pn0,filesep,fn];
                     [pn_base,fn_base,fn_ext] = fileparts(fullfn);

                     if exist(fullfn,'file') == 2

                        try
                           v = load(fullfn,'-mat');
                        catch
                           v = struct('null','');
                        end

                        if isfield(v,var)

                           msg = '';
                           s = v.(var);  %extract relevant structure from file

                           %apply qc flag handling option
                           if ~isempty(flagfnc)
                              if strcmp(flagfnc,'cull')
                                 s = cullflags(s,flags,[],1);
                              else
                                 s = nullflags(s,flags,[],1);
                              end
                           end

                           %run relevant export routine
                           switch fmt
                           case 'ascii'
                              msg = exp_ascii(s,filefmt,[fn_base,ext],pn,'',headeropt,'M',metaopt,'',0,missingchar);
                           case 'matlab'
                              msg = exp_matlab(s,[fn_base,ext],pn,filefmt,metaopt,'E');
                           otherwise
                              msg = 'invalid format';
                           end
                           if isempty(msg)
                              goodfiles = goodfiles + 1;
                           else
                              badfiles = badfiles + 1;
                           end
                        end
                     else
                        badfiles = badfiles + 1;
                     end
                  else
                     badfiles = badfiles + 1;
                  end
                  if pbar == 1
                     ui_progressbar('update',n)
                     drawnow
                  end
               end
               figure(h_fig)
               set(h_fig,'Pointer','arrow')
               drawnow
               if badfiles > 0
                  messagebox('init',[int2str(goodfiles),' data set(s) successfully exported, ',int2str(badfiles), ...
                        ' data set(s) could not be loaded and were skipped'],'','Info',[.9 .9 .9])
               else
                  messagebox('init',[int2str(goodfiles),' data set(s) successfully exported'],'','Info',[.9 .9 .9])
               end
            end
         end

      end
   end
end


%sub-function for loading a file and returning the referenced data structure
function s = sub_loadstruct(path,fn,varname,user_registration)

s = [];

if strncmp(path,'http',4)
   [path,fn] = sub_fetchstruct(path,fn,user_registration);
   if isempty(path)
      path = pwd;  %fall back to webcache to avoid filetest errors on empty paths
   end
end

%load file, extract structure
if exist([path,filesep,fn],'file') == 2
   try
      v = load([path,filesep,fn],'-mat');
   catch
      v = struct('null','');
   end
   if isfield(v,varname)
      s = v.(varname);
   end
end
return


%subfunction for fetching and caching web-based files and returning local path, filename
function [localpath,localfn] = sub_fetchstruct(baseurl,fn,user_registration)

curpath = pwd;
toolpath = gce_homepath;
localpath = '';
localfn = '';

if ~isempty(user_registration)

   %create directory if doesn't exist
   if isdir([toolpath,filesep,'search_webcache'])
      cachepath = [toolpath,filesep,'search_webcache'];
   else
      try
         mkdir(toolpath,'search_webcache')
         cachepath = [toolpath,filesep,'search_webcache'];
      catch
         cachepath = curpath;
      end
   end

   %append terminal slash if not specified
   if strcmp(baseurl(end),'/') ~= 1
      baseurl = [baseurl,'/'];
   end

   %check for script-based filename strings, extract terminal filename and add remainder to baseurl
   if ~isempty(strfind(fn,'='))
      Ieq = strfind(fn,'=');
      if ~isempty(Ieq)
         baseurl = [baseurl,fn(1:Ieq(end))];
         %replace authentitication placeholders with user registration info
         baseurl = strrep(baseurl,'[username]',strrep(user_registration.name,' ','%20'));
         baseurl = strrep(baseurl,'[useremail]',strrep(user_registration.email,' ','%20'));
         baseurl = strrep(baseurl,'[useraffiliation]',strrep(user_registration.affiliation,' ','%20'));
         baseurl = strrep(baseurl,'[usernotify]',int2str(user_registration.notify));
         fn = fn(Ieq(end)+1:end);
      end
      Islash = strfind(fn,'/');
      if ~isempty(Islash)
         baseurl = [baseurl,fn(1:Islash(end))];
         fn = fn(Islash(end)+1:end);
      end
   end

   %check webcache first, fetch file from url if not in cache
   if exist([cachepath,filesep,fn],'file') == 2

      localpath = cachepath;
      localfn = fn;

   else  %retrieve, cache file if valid user registration info and network support functions available

      if ~isempty(user_registration) && exist('urlwrite','file') == 2

         cd(cachepath)

         url = [baseurl,fn];

         [tmp,status] = urlwrite(url,fn);

         if ~isempty(tmp)
            localpath = cachepath;
            localfn = fn;
            try
               v = load(fn,'-mat');
            catch
               delete(fn)
               localpath = '';
               localfn = '';
            end
         else
            localpath = '';
            localfn = '';
         end

         cd(curpath)

      end

   end

end

return


%sub-function for merging indices
function index = sub_mergeindex(index1,index2)

%extract fieldnames from indices
flds1 = fieldnames(index1);
flds2 = fieldnames(index2);

%extract index contents as cell arrays
vals1 = struct2cell(index1);
vals2 = struct2cell(index2);

%add unmatched entries in index2 to index1
fld_diffs1 = setdiff(flds2,flds1);
if ~isempty(fld_diffs1)
   flds1 = [flds1 ; fld_diffs1];
   vals1 = [vals1 ; repmat({''},[length(fld_diffs1),1,size(vals1,3)])];
end

%add unmatched entries in index1 to index2
fld_diffs2 = setdiff(flds1,flds2);
if ~isempty(fld_diffs2)
   flds2 = [flds2 ; fld_diffs2];
   vals2 = [vals2 ; repmat({''},[length(fld_diffs2),1,size(vals2,3)])];
end

%determine sort order for index2
Iorder = zeros(length(flds1),1);
for n = 1:length(flds2)
   Ifld = find(strcmp(flds2,flds1{n}));
   Iorder(n) = Ifld;
end

%generate output index
try
   index = [cell2struct(vals1,flds1,1) , cell2struct(vals2(Iorder,1,:),flds2(Iorder),1)];
catch
   index = [];
end

return