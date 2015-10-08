function ui_export_eml(op,data)
%Dialog for generating EML metadata and associated text data distribution files
%
%syntax: msg = ui_export_eml(op,data)
%
%input:
%  op = operation ('init' to open dialog)
%  data = data structure to export
%
%output:
%  none
%
%
%(c)2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 10-Sep-2014

if exist('op','var') ~= 1
   op = 'init';
end

if strcmp(op,'init')
   
   if exist('data','var') ~= 1
      data = [];
   end
   
   if gce_valid(data,'data')
      
      %get accession
      acc = lookupmeta(data,'Dataset','Accession');
      if isempty(acc)
         acc = 'data';
      end
      
      %set default preferences
      prefs = struct( ...
         'path',getpath('save'), ...
         'format','csv', ...
         'header','B', ...
         'flags','MD+', ...
         'missingchar','NaN', ...
         'mapunits',1, ...
         'public',1, ...
         'table',0, ...
         'authsystem','knb', ...
         'dateformat','yyyy-mm-dd HH:MM:SS' ...
         );
      
      %load cached preferences if available
      if exist('ui_export_eml.mat','file') == 2
         try
            v = load('ui_export_eml.mat');
         catch e
            v = struct('null','');
            messagebox('init',['Settings file ''ui_export_eml.mat'' could not be opened (',e.message,')'], ...
               '','Error',[0.95 0.95 0.95])
         end
         if isfield(v,'prefs')
            prefs = v.prefs;
            if ~isdir(prefs.path)
               prefs.path = '';  %clear path if not valid on the current system
            end
            if ~isfield(prefs,'table')
               prefs.table = 0;  %add missing table preference
            end
         end
      end         
      
      %set screen metrics
      res = get(0,'ScreenSize');      
      bgcolor = [0.9 0.9 0.9];
      
      %create dialog figure
      h_dlg = figure('Name','Export EML Dataset', ...
         'Color',[0.95 0.95 0.95], ...
         'KeyPressFcn','figure(gcf)', ...
         'MenuBar','none', ...
         'NumberTitle','off', ...
         'Position',[(res(3)-600).*0.5 (res(4)-345).*0.5 700 345], ...
         'Tag','dlgExpEML', ...
         'ToolBar','none', ...
         'Visible','off', ...
         'Resize','off', ...
         'CloseRequestFcn','ui_export_eml(''cancel'')');
      
      if mlversion >= 7
         set(h_dlg,'WindowStyle','normal')
         set(h_dlg,'DockControls','off')
      end
      
      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'ForegroundColor',[0 0 0], ...
         'Position',[10 45 680 157], ...
         'Style','frame', ...
         'Tag','frame');
      
      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'ForegroundColor',[0 0 0], ...
         'Position',[10 215 680 125], ...
         'Style','frame', ...
         'Tag','frame');
      
      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'ForegroundColor',[0 0 .8], ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'Position',[20 304 85 20], ...
         'String','Export Path', ...
         'HorizontalAlignment','left', ...
         'Style','text', ...
         'Tag','lblFile');
      
      h_editPath = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'Position',[105 305 538 22], ...
         'String',prefs.path, ...
         'Style','edit', ...
         'Callback','ui_export_eml(''path'')', ...
         'Tag','editPath');
      
      h_cmdBrowse = uicontrol('Parent',h_dlg, ...
         'Callback','ui_export_eml(''browse'')', ...
         'FontSize',12, ...
         'FontWeight','bold', ...
         'Position',[645 304 30 21], ...
         'String','...', ...
         'TooltipString','Browse to select a path for saving the data and metadata files', ...
         'Tag','cmdBrowse', ...
         'UserData',prefs.path);
      
      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'ForegroundColor',[0 0 .8], ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'Position',[20 264 80 20], ...
         'String','File Name', ...
         'HorizontalAlignment','left', ...
         'Style','text', ...
         'Tag','lblFile');
      
      h_editFile = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'Callback','ui_export_eml(''buttons'')', ...
         'FontSize',10, ...
         'HorizontalAlignment','left', ...
         'Position',[105 265 200 22], ...
         'String','', ...
         'TooltipString','Specify a filename for the data file (EML file will be generated with a .xml suffix)', ...
         'Style','edit', ...
         'Tag','editFile');
      
      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'ForegroundColor',[0 0 .8], ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'Position',[325 264 85 20], ...
         'String','Entity Name', ...
         'HorizontalAlignment','left', ...
         'Style','text', ...
         'Tag','lblEntity');
      
      h_editEntity = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'Callback','ui_export_eml(''buttons'')', ...
         'FontSize',10, ...
         'HorizontalAlignment','left', ...
         'Position',[410 265 260 22], ...
         'String',acc, ...
         'TooltipString','Specify an entity name for the data table', ...
         'Style','edit', ...
         'Tag','editEntity');
      
      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'ForegroundColor',[0 0 .8], ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'Position',[20 229 80 20], ...
         'String','Data URL', ...
         'HorizontalAlignment','left', ...
         'Style','text', ...
         'Tag','lblURL');
      
      h_editURL = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',10, ...
         'HorizontalAlignment','left', ...
         'Position',[105 230 565 22], ...
         'String','', ...
         'TooltipString','Specify a URL for downloading the data entity (optional)', ...
         'Style','edit', ...
         'Tag','editURL');
      
      %define format list and look up preference
      fmtstr = { ...
         'CSV (spreadsheet)', ...
         'Comma-delimited Text', ...
         'Tab-delimited Text', ...
         'Space-delimited Text' ...
         };
      fmtlist = {'csv','comma','tab','space'};
      fmtval = find(strcmp(prefs.format,fmtstr));
      if isempty(fmtval)
         fmtval = 1;
      end
      
      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'ForegroundColor',[0 0 .8], ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'Position',[20 162 90 20], ...
         'HorizontalAlignment','left', ...
         'String','File Format', ...
         'Style','text', ...
         'Tag','lblFormat');
      
      h_popFormat = uicontrol('Parent',h_dlg, ...
         'Style','popupmenu', ...
         'BackgroundColor',[1 1 1], ...
         'ForegroundColor',[0 0 0], ...
         'FontSize',10, ...
         'HorizontalAlignment','left', ...
         'Position',[105 162 200 25], ...
         'String',fmtstr, ...
         'TooltipString','Specify an export format for the data file', ...
         'Value',fmtval, ...
         'UserData',fmtlist, ...
         'Tag','popFormat');
      
      %define header format list and look up preference
      fmtstr = { ...
         '1-line header (column names)', ...
         '5-line header (title, column names, units, variable types)', ...
         'no header' ...
         };
      fmtlist = {'T','B','N'};
      fmtval = find(strcmp(prefs.header,fmtlist));
      if isempty(fmtval)
         fmtval = 1;
      end
      
      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'ForegroundColor',[0 0 .8], ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'Position',[20 127 90 20], ...
         'HorizontalAlignment','left', ...
         'String','Header', ...
         'Style','text', ...
         'Tag','lblHeader');
      
      h_popHeader = uicontrol('Parent',h_dlg, ...
         'Style','popupmenu', ...
         'BackgroundColor',[1 1 1], ...
         'ForegroundColor',[0 0 0], ...
         'FontSize',10, ...
         'HorizontalAlignment','left', ...
         'Position',[105 127 385 25], ...
         'String',fmtstr, ...
         'TooltipString','Specify a data file header style', ...
         'Value',fmtval, ...
         'UserData',fmtlist, ...
         'Tag','popHeader');
      
      h_chkTableOnly = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'ForegroundColor',[0 0 0.8], ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'Position',[510 127 140 22], ...
         'Value',prefs.table, ...
         'String','dataTable Only', ...
         'TooltipString','Check to generate dataTable and STMML trees rather than a full EML document', ...
         'Style','checkbox', ...
         'Tag','chkTableOnly');
      
      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'ForegroundColor',[0 0 .8], ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'Position',[325 162 85 20], ...
         'HorizontalAlignment','left', ...
         'String','Flag Option', ...
         'Style','text', ...
         'Tag','lblFlags');
      
      %define flag options
      flagstr = { ...
         'Text flag columns (auto)'; ...
         'Text flag columns (data/calc)'; ...
         'Text flag columns (data/calc + others)'; ...
         'Integer flag columns (auto)'; ...
         'Integer flag columns (data/calc)'; ...
         'No flags (ignore)' ...
         };
      flaglist = {'M','MD','MD+','E','ED','N'};
      flagval = find(strcmp(prefs.flags,flaglist));
      if isempty(flagval)
         flagval = 1;
      end
      
      h_popFlags = uicontrol('Parent',h_dlg, ...
         'Style','popupmenu', ...
         'BackgroundColor',[1 1 1], ...
         'ForegroundColor',[0 0 0], ...
         'FontSize',10, ...
         'HorizontalAlignment','left', ...
         'Position',[410 162 260 25], ...
         'String',flagstr, ...
         'TooltipString','Specify an option for including value flags in the data table and EML', ...
         'Value',flagval, ...
         'UserData',flaglist, ...
         'Tag','popFlags');
      
      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'ForegroundColor',[0 0 .8], ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'Position',[20 92 80 20], ...
         'String','Package ID', ...
         'HorizontalAlignment','left', ...
         'Style','text', ...
         'Tag','lblPackageID');
      
      h_editPackageID = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'Callback','ui_export_eml(''buttons'')', ...
         'FontSize',10, ...
         'HorizontalAlignment','left', ...
         'Position',[105 93 200 22], ...
         'String','', ...
         'TooltipString','Specify a Package ID for the EML document', ...
         'Style','edit', ...
         'Tag','editPackageID');
      
      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'ForegroundColor',[0 0 .8], ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'Position',[325 92 85 20], ...
         'String','AuthSystem', ...
         'HorizontalAlignment','left', ...
         'Style','text', ...
         'Tag','lblAuthSystem');
      
      h_editAuthSystem = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'ForegroundColor',[0 0 0], ...
         'FontSize',10, ...
         'FontWeight','normal', ...
         'Position',[410 93 80 22], ...
         'String',prefs.authsystem, ...
         'TooltipString','Specify a user authentication to use for EML access from Metacat', ...
         'HorizontalAlignment','left', ...
         'Style','edit', ...
         'Tag','editAuthSystem');
      
      h_chkPublic = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'ForegroundColor',[0 0 0.8], ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'Position',[510 92 120 22], ...
         'Value',prefs.public, ...
         'String','Public Access', ...
         'TooltipString','Check for public access to the EML document and data entity', ...
         'Style','checkbox', ...
         'Tag','chkPublic');
      
      %define supported date formats for conversion options
      dateformats = { ...
         NaN,'<no conversion>'; ...
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
      
      %look up date format index
      formatval = find(strcmp(prefs.dateformat,dateformats(:,2)));
      if isempty(formatval)
         formatval = find(strcmp('yyyy-mm-dd HH:MM:SS',dateformats(:,2)));
      end
      
      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'ForegroundColor',[0 0 .8], ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'Position',[18 55 88 20], ...
         'String','Date Format', ...
         'HorizontalAlignment','left', ...
         'Style','text', ...
         'Tag','lblDateFormat');
      
      h_popDateFormat = uicontrol('Parent',h_dlg, ...
         'Style','popupmenu', ...
         'Position',[105 56 200 22], ...
         'BackgroundColor',[1 1 1], ...
         'String',dateformats(:,2), ...
         'TooltipString','Format for MATLAB serial dates', ...
         'Tag','popDateFormat', ...
         'Value',formatval, ...
         'UserData',[dateformats{:,1}]');
                 
      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'ForegroundColor',[0 0 .8], ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'Position',[325 55 85 20], ...
         'String','Missing Char', ...
         'HorizontalAlignment','left', ...
         'Style','text', ...
         'Tag','lblMissingChar');
      
      h_editMissingChar = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'ForegroundColor',[0 0 0], ...
         'FontSize',10, ...
         'FontWeight','normal', ...
         'Position',[410 56 80 22], ...
         'String',prefs.missingchar, ...
         'TooltipString','Characters to use to represent missing numeric values (blank for none)', ...
         'HorizontalAlignment','left', ...
         'Style','edit', ...
         'Tag','editMissingChar');
      
      h_chkMapUnits = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'ForegroundColor',[0 0 0.8], ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'Position',[510 56 120 22], ...
         'Value',prefs.mapunits, ...
         'String','Map Units', ...
         'TooltipString','Map data column units to equivalent EML Unit Dictionary units', ...
         'Style','checkbox', ...
         'Tag','chkMapUnits');
      
      h_cmdCancel = uicontrol('Parent',h_dlg, ...
         'Callback','ui_export_eml(''cancel'')', ...
         'FontSize',10, ...
         'Position',[10 10 80 26], ...
         'String','Cancel', ...
         'Tag','cmdCancel');
      
      h_chkClose = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[0.95 0.95 0.95], ...
         'ForegroundColor',[0 0 0.8], ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'Position',[200 10 300 22], ...
         'Value',1, ...
         'String','Close dialog after performing export?', ...
         'TooltipString','Option to automatically close the dialog after successfully exporting the package', ...
         'Style','checkbox', ...
         'Tag','chkClose');         
      
      h_cmdEval = uicontrol('Parent',h_dlg, ...
         'Callback','ui_export_eml(''eval'')', ...
         'Enable','off', ...
         'FontSize',10, ...
         'Position',[610 10 80 26], ...
         'String','Proceed', ...
         'Tag','cmdEval');
      
      uih = struct('data',data, ...
         'popFlags',h_popFlags, ...
         'popFormat',h_popFormat, ...
         'editPath',h_editPath, ...
         'editFile',h_editFile, ...         
         'editEntity',h_editEntity, ...
         'editURL',h_editURL, ...
         'popHeader',h_popHeader, ...
         'editPackageID',h_editPackageID, ...
         'chkTableOnly',h_chkTableOnly, ...
         'chkPublic',h_chkPublic, ...
         'editAuthSystem',h_editAuthSystem, ...
         'editMissingChar',h_editMissingChar, ...
         'chkMapUnits',h_chkMapUnits, ...
         'cmdBrowse',h_cmdBrowse, ...
         'popDateFormat',h_popDateFormat, ...
         'cmdCancel',h_cmdCancel, ...
         'chkClose',h_chkClose, ...
         'cmdEval',h_cmdEval);
      
      set(h_dlg,'UserData',uih,'Visible','on')
      
      ui_export_eml('buttons')
      
   end
   
else  %handle callbacks
   
   if length(findobj) > 1
      
      h_dlg = gcf;
      
      if strcmp(get(h_dlg,'Tag'),'dlgExpEML')
         
         uih = get(h_dlg,'UserData');
         
         switch op
            
            case 'cancel'
               
               delete(h_dlg)
               ui_aboutgce('reopen')  %check for last window
               
            case 'eval'
               
               %get file path and filename
               strPath = deblank(get(uih.editPath,'String'));
               strFile = deblank(get(uih.editFile,'String'));
               if isdir(strPath) && ~isempty(strFile)
                  fn_data = [clean_path(strPath),filesep,strFile];
               else
                  fn_data = '';
               end
               
               %get other text fields
               entity = deblank(get(uih.editEntity,'String'));
               packageid = deblank(get(uih.editPackageID,'String'));
               authsystem = deblank(get(uih.editAuthSystem,'String'));
               missingchar = deblank(get(uih.editMissingChar,'String'));
               url = deblank(get(uih.editURL,'String'));
               
               %get checkboxes
               tableonly = get(uih.chkTableOnly,'Value');
               public_access = get(uih.chkPublic,'Value');
               mapunits = get(uih.chkMapUnits,'Value');
               closeopt = get(uih.chkClose,'Value');
               
               %get format option from popup menu
               strOptions = get(uih.popFormat,'UserData');
               valOptions = get(uih.popFormat,'Value');
               fmt = strOptions{valOptions};
               
               %get flag option from popup menu
               strOptions = get(uih.popFlags,'UserData');
               valOptions = get(uih.popFlags,'Value');
               flagopt = strOptions{valOptions};
                              
               %get header option from popup menu
               strOptions = get(uih.popHeader,'UserData');
               valOptions = get(uih.popHeader,'Value');
               hdropt = strOptions{valOptions};
                              
               %get date format option
               dateformats = get(uih.popDateFormat,'String');
               dateformatlist = get(uih.popDateFormat,'UserData');
               dateformatval = get(uih.popDateFormat,'Value');
               datefmt = dateformatlist(dateformatval);
               
               prefs = struct( ...
                  'path',strPath, ...
                  'format',fmt, ...
                  'header',hdropt, ...
                  'flags',flagopt, ...
                  'missingchar',missingchar, ...
                  'table',tableonly, ...
                  'mapunits',mapunits, ...
                  'public',public_access, ...
                  'authsystem',authsystem, ...
                  'dateformat',dateformats{dateformatval} ...
                  );                                                         %#ok<NASGU>
      
               %cache preferences
               fn = which('ui_export_eml.mat');
               if isempty(fn)
                  fn = [gce_homepath,filesep,'settings',filesep,'ui_export_eml.mat'];
               end
               save(fn,'prefs')     
               
               %generate access element structure
               if public_access == 1
                  s_access = struct('attrib_authSystem',authsystem, ...
                          'attrib_order','allowFirst', ...
                          'attrib_scope','document', ...
                          'allow',struct('principal','public','permission','read'));
               else
                  s_access = struct('attrib_authSystem',authsystem, ...
                          'attrib_order','allowFirst', ...
                          'attrib_scope','document', ...
                          'allow',struct('principal','public','permission','none'));
               end
               
               %perform export
               set(h_dlg,'Pointer','watch'); drawnow
               
               %check for table only option
               if tableonly == 1
                  
                  %generate table and stmml metadata in struct format and export file
                  [s_table,s_stmml,~,msg] = gceds2eml_table(uih.data, ...
                     fn_data,url,entity,fmt,datefmt,hdropt,flagopt,missingchar,'',mapunits);

                  %check for results, export as xml files
                  if ~isempty(s_table)
                     [pn,fn_base] = fileparts(fn_data);
                     xml = struct2xml_attrib(s_table,'dataTable',0,100,3,3,'');
                     xml2file(xml,'',0,[fn_base,'_',entity,'.xml'],pn);  %save xml file with entity suffix
                     if ~isempty(s_stmml)
                        xml_stmml = struct2xml_attrib(s_stmml,'',0,100,3,6,'');  %convert stmml struct to xml text
                        xml_stmml = char( ...
                           '<metadata  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:stmml="http://www.xml-cml.org/schema/stmml-1.1">', ...
                           '   <stmml:unitList xsi:schemaLocation="http://www.xml-cml.org/schema/stmml-1.1 http://gce-lter.marsci.uga.edu/public/files/schemas/eml-210/stmml.xsd">', ...
                           xml_stmml, ...
                           '   </stmml:unitList>', ...
                           '</metadata>' ...
                           );
                        xml2file(xml_stmml,'',0,[fn_base,'_',entity,'_stmml.xml'],pn);  %save stmml file
                     end
                  end
                  
               else  %full eml
                  [~,~,msg] = gceds2eml(uih.data, ...
                     packageid,fn_data,url,entity,fmt,datefmt,hdropt,flagopt,missingchar,'',mapunits,s_access);
               end
               
               set(h_dlg,'Pointer','arrow'); drawnow
               
               %display status message
               if ~isempty(msg)
                  messagebox('init',msg,'','Information',[0.95 0.95 0.95],0)
               elseif closeopt == 1
                  ui_export_eml('cancel')
               end
               
            case 'browse'  %browse to select a path
               
               %get working directory
               curpath = pwd;
               
               %get current entry
               pn = deblank(get(uih.editPath,'String'));
               if isempty(pn)
                  pn = curpath;
               end
               
               %prompt for directory
               pn = uigetdir(pn,'Specify a base directory for exporting the dataset file');
               
               %check for cancel and update field
               if pn ~= 0
                  set(uih.editPath,'String',pn)
                  ui_export_eml('buttons')
               end
               
            case 'path'  %validate path
               
               %get path
               strPath = deblank(get(uih.editPath,'String'));
               
               %check for invalid path
               if ~isempty(strPath) && ~isdir(strPath)
                  set(uih.editPath,'String','')
                  messagebox('init','Invalid directory','','Error',[0.95 0.95 0.95])
               end
               
               %update button states
               ui_export_eml('buttons')
               
            case 'buttons'  %update button states
               
               %get required text fields
               flds = [uih.editPath ; ...
                  uih.editFile ; ...
                  uih.editEntity ; ...
                  uih.editPackageID ; ...
                  uih.editAuthSystem];
               
               numflds = length(flds);
               
               %check for non-empty strings in all required fields
               val = zeros(numflds,1);               
               for n = 1:numflds
                  str = deblank(get(flds(n),'String'));
                  if ~isempty(str)
                     val(n) = 1;
                  end
               end
               
               %check for any empty required fields, toggle Accept button accordingly
               if sum(val) == numflds
                  set(uih.cmdEval,'Enable','on')
               else
                  set(uih.cmdEval,'Enable','off')
               end
               drawnow
               
         end
         
      end
      
   end
   
end