function ui_batch_import(op,pn)
%GUI dialog for batch processing data files to import them as GCE Data Structures
%
%syntax: ui_batch_import(op,pn)
%
%input:
%  op = operation ('init' to initialize dialog)
%  pn = initial pathname (default = pwd)
%
%
%(c)2012-2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 29-Apr-2015

%default to init
if exist('op','var') ~= 1
   op = 'init';
end

if strcmp(op,'init') %create the dialog
   
   %check for source omitted path
   if exist('pn','var') ~= 1
      pn = '';
   end
   
   %init destination path
   pn2 = '';
   
   %try to look up GCE editor loadpath and savepath
   if length(findobj) > 1
      h_editor = findobj('Tag','dlgDSEditor');  %get handles of open editor windows
      if ~isempty(h_editor)
         if isempty(pn)
            pn = get(findobj(h_editor(1),'Tag','mnuLoad'),'UserData');  %get loadpath from load menu userdata
         end
         pn2 = get(findobj(h_editor(1),'Tag','mnuSave'),'UserData');  %get savepath from save menu userdata
      end
   end
      
   %validate path, defaulting to current directory if invalid
   if isempty(pn)
      pn = pwd;
   elseif ~isdir(pn)
      pn = pwd;
   else
      pn = clean_path(pn);
   end
   
   %assign destination path = sourch path if not looked up from editor instance
   if isempty(pn2)
      pn2 = pn;
   end
   
   %set sync button state based on paths
   if strcmpi(pn,pn2)
      syncval = 1;
      enable_browse2 = 'off';
   else
      syncval = 0;
      enable_browse2 = 'on';
   end
   
   %load the filters database
   filters = get_importfilters;

   %retrieve import filters from imp_filters.mat database
   if isstruct(filters)      
      
      %extract labels and subheadings
      subheadings = extract(filters ,'Subheading');
      filemask = extract(filters,'Filemask');
      
      %get index of valid entries
      if ~isempty(filemask)
         Ivalid = find(~strcmpi('www',filemask));
      else
         Ivalid = [];
      end
      
      %check for valid entries
      if ~isempty(Ivalid)
         
         %filter data to remove invalid entries
         data = copyrows(filters,Ivalid);
         subheadings = subheadings(Ivalid);
         filemask = filemask(Ivalid);
         
         %extract remaining filter information from filtered data set
         labels = extract(data,'Label');
         mfile = extract(data,'Mfile');
         arg1 = extract(data,'Argument1');
         arg2 = extract(data,'Argument2');
         arg3 = extract(data,'Argument3');
         arg4 = extract(data,'Argument4');
         arg5 = extract(data,'Argument5');
         arg6 = extract(data,'Argument6');
         
         %generate filter list by concatenating label and subheading, adding a prompt as the first item to force selection
         subheadings = concatcellcols([repmat({' - '},length(Ivalid),1),subheadings],'');
         filterlist = [{'<select an import filter>'} ; ...
            concatcellcols([labels,subheadings],'')];
         
         %check for legacy imp_filters.mat without arguments 3-6
         nullcol = repmat({''},length(mfile),1);
         if isempty(arg3)
            arg3 = nullcol;
         end
         if isempty(arg4)
            arg4 = nullcol;
         end
         if isempty(arg5)
            arg5 = nullcol;
         end
         if isempty(arg6)
            arg6 = nullcol;
         end
         
         %generate array of mfile name and arguments
         filterdata = [mfile,filemask,arg1,arg2,arg3,arg4,arg5,arg6];
                  
      else  %no valid entries
         
         %return empty arrays on error
         filterlist = [];
         filterdata = [];
         
      end
      
   end
   
   if ~isempty(filterlist) && ~isempty(filterdata)
      
      %close prior instances of the dialog
      if length(findobj) > 1
         h_dlg = findobj('Tag','dlgBatchImport');
         if ~isempty(h_dlg)
            delete(h_dlg)
         end
      end
      
      %define GUI metrics
      bgcolor = [0.9 0.9 0.9];
      res = get(0,'ScreenSize');
      
      %check for open GUI figures, cache current figure handle
      if length(findobj) > 1
         h_fig = gcf;
      else
         h_fig = '';
      end
      
      %create new dialog instance
      h_dlg = figure('Visible','off', ...
         'Color',[0.95 0.95 0.95], ...
         'KeyPressFcn','figure(gcf)', ...
         'CloseRequestFcn','ui_batch_import(''close'')', ...
         'MenuBar','none', ...
         'Name','Batch Import Files', ...
         'NumberTitle','off', ...
         'PaperUnits','points', ...
         'Position',[max(1,0.5.*(res(3)-740)) max(50,0.5.*(res(4)-545)) 740 545], ...
         'Tag','dlgBatchImport', ...
         'ToolBar','none', ...
         'DefaultuicontrolUnits','pixels', ...
         'Resize','off');
      
      %disable figure docking
      if mlversion >= 7
         set(h_dlg,'WindowStyle','normal')
         set(h_dlg,'DockControls','off')
      end
      
      %define ui controls
      uicontrol('Parent',h_dlg, ...
         'Style','frame', ...
         'Units','pixels', ...
         'Position',[5 465 730 75], ...
         'BackgroundColor',bgcolor, ...
         'ForegroundColor',[0 0 0]);
      
      uicontrol('Parent',h_dlg, ...
         'Style','frame', ...
         'Units','pixels', ...
         'Position',[5 40 730 420], ...
         'BackgroundColor',bgcolor, ...
         'ForegroundColor',[0 0 0]);
      
      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[15 509 110 18], ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'HorizontalAlignment','left', ...
         'String','Source Path', ...
         'Tag','lblFile');
      
      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[15 477 110 18], ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'HorizontalAlignment','left', ...
         'String','Destination', ...
         'Tag','lblTitle');
      
      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[15 425 110 18], ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'HorizontalAlignment','left', ...
         'String','Import Filter', ...
         'Tag','lblImportFilter');
      
      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[15 395 110 18], ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'HorizontalAlignment','left', ...
         'String','Syntax Help', ...
         'Tag','lblImportFilter');
      
      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[15 235 110 18], ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'HorizontalAlignment','left', ...
         'String','File Mask', ...
         'Tag','lblFileMask');
      
      h_editPath1 = uicontrol('Parent',h_dlg, ...
         'Style','edit', ...
         'Position',[125 507 550 22], ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'String',pn, ...
         'Tag','editPath1', ...
         'UserData',pn, ...
         'Callback','ui_batch_import(''checkpath'')');
      
      h_cmdBrowse1 = uicontrol('Parent',h_dlg, ...
         'Position',[680 506 50 25], ...
         'Callback','ui_batch_import(''browsepath'')', ...
         'String','Browse', ...
         'TooltipString','Browse to select the path containing files to import', ...
         'Tag','cmdBrowse1', ...
         'UserData',pn);
      
      h_editPath2 = uicontrol('Parent',h_dlg, ...
         'Style','edit', ...
         'Position',[125 476 500 22], ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'String',pn2, ...
         'Tag','editPath2', ...
         'UserData',pn2, ...
         'Enable',enable_browse2, ...
         'Callback','ui_batch_import(''checkpath'')');
      
      h_tglSyncPath = uicontrol('Parent',h_dlg, ...
         'Style','togglebutton', ...
         'Position',[627 474 50 25], ...
         'Callback','ui_batch_import(''syncpath'')', ...
         'String','Sync', ...
         'TooltipString','Automatically copy source path to destination path on changes when toggled on', ...
         'Value',syncval, ...
         'Tag','tglSyncPath');
      
      h_cmdBrowse2 = uicontrol('Parent',h_dlg, ...
         'Position',[680 474 50 25], ...
         'Callback','ui_batch_import(''browsepath'')', ...
         'String','Browse', ...
         'TooltipString','Browse to select a destination path for imported files', ...
         'Tag','cmdBrowse2', ...
         'Enable',enable_browse2, ...
         'UserData',pn);
      
      h_popFilter = uicontrol('Parent',h_dlg, ...
         'Style','popupmenu', ...
         'Position',[125 425 600 22], ...
         'BackgroundColor',[1 1 1], ...
         'ForegroundColor',[0 0 0], ...
         'String',filterlist, ...
         'Fontsize',9, ...
         'Value',1, ...
         'Callback','ui_batch_import(''filter'')', ...
         'Tag','popFilter');
      
      h_listSyntax =  uicontrol('Parent',h_dlg, ...
         'Style','listbox', ...
         'Position',[125 265 600 150], ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'String','', ...
         'Min',1, ...
         'Max',5, ...
         'Enable','off', ...
         'Tag','listSyntax');
      
      h_editFileSpec = uicontrol('Parent',h_dlg, ...
         'Style','edit', ...
         'Position',[125 235 180 22], ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'String','', ...
         'Tag','editFileSpec', ...
         'Callback','ui_batch_import(''controls'')');
      
      h_cmdBrowseFile = uicontrol('Parent',h_dlg, ...
         'Position',[310 234 50 25], ...
         'Callback','ui_batch_import(''browsefiles'')', ...
         'String','Browse', ...
         'TooltipString','Browse to select a file to import', ...
         'Tag','cmdBrowseFile');
      
      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[365 236 350 18], ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','normal', ...
         'ForegroundColor',[0 0 0.8], ...
         'HorizontalAlignment','left', ...
         'String','(file name or file mask for selecting files to import)', ...
         'Tag','lblFileMaskHelp');
      
      h_lblArg1 = uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[15 205 120 18], ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'HorizontalAlignment','left', ...
         'String','', ...
         'Tag','lblArg1');
      
      h_lblArg2 = uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[15 175 120 18], ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'HorizontalAlignment','left', ...
         'String','', ...
         'Tag','lblArg2');
      
      h_lblArg3 = uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[15 145 120 18], ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'HorizontalAlignment','left', ...
         'String','', ...
         'Tag','lblArg3');
      
      h_lblArg4 = uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[15 115 120 18], ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'HorizontalAlignment','left', ...
         'String','', ...
         'Tag','lblArg4');
      
      h_lblArg5 = uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[15 85 120 18], ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'HorizontalAlignment','left', ...
         'String','', ...
         'Tag','lblArg5');
      
      h_lblArg6 = uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[15 55 120 18], ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'HorizontalAlignment','left', ...
         'String','', ...
         'Tag','lblArg6');
      
      h_lblArgHelp1 = uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[315 205 415 18], ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','normal', ...
         'ForegroundColor',[0 0 0.8], ...
         'HorizontalAlignment','left', ...
         'String','', ...
         'Tag','lblArgHelp1');
      
      h_lblArgHelp2 = uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[315 175 415 18], ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','normal', ...
         'ForegroundColor',[0 0 0.8], ...
         'HorizontalAlignment','left', ...
         'String','', ...
         'Tag','lblArgHelp2');
      
      h_lblArgHelp3 = uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[315 145 415 18], ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','normal', ...
         'ForegroundColor',[0 0 0.8], ...
         'HorizontalAlignment','left', ...
         'String','', ...
         'Tag','lblArgHelp3');
      
      h_lblArgHelp4 = uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[315 115 415 18], ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','normal', ...
         'ForegroundColor',[0 0 0.8], ...
         'HorizontalAlignment','left', ...
         'String','', ...
         'Tag','lblArgHelp4');
      
      h_lblArgHelp5 = uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[315 85 415 18], ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','normal', ...
         'ForegroundColor',[0 0 0.8], ...
         'HorizontalAlignment','left', ...
         'String','', ...
         'Tag','lblArgHelp5');
      
      h_lblArgHelp6 = uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[315 55 415 18], ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','normal', ...
         'ForegroundColor',[0 0 0.8], ...
         'HorizontalAlignment','left', ...
         'String','', ...
         'Tag','lblArgHelp6');
      
      h_editArg1 =  uicontrol('Parent',h_dlg, ...
         'Style','edit', ...
         'Position',[125 204 180 22], ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'String','', ...
         'Enable','off', ...
         'Tag','editArg1');
      
      h_editArg2 = uicontrol('Parent',h_dlg, ...
         'Style','edit', ...
         'Position',[125 174 180 22], ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'String','', ...
         'Enable','off', ...
         'Tag','editArg2');
      
      h_editArg3 = uicontrol('Parent',h_dlg, ...
         'Style','edit', ...
         'Position',[125 144 180 22], ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'String','', ...
         'Enable','off', ...
         'Tag','editArg3');
      
      h_editArg4 = uicontrol('Parent',h_dlg, ...
         'Style','edit', ...
         'Position',[125 114 180 22], ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'String','', ...
         'Enable','off', ...
         'Tag','editArg4');
      
      h_editArg5 = uicontrol('Parent',h_dlg, ...
         'Style','edit', ...
         'Position',[125 84 180 22], ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'String','', ...
         'Enable','off', ...
         'Tag','editArg5');
      
      h_editArg6 = uicontrol('Parent',h_dlg, ...
         'Style','edit', ...
         'Position',[125 54 180 22], ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'String','', ...
         'Enable','off', ...
         'Tag','editArg6');
      
      h_cmdClose = uicontrol('Parent',h_dlg, ...
         'Position',[10 10 80 25], ...
         'String','Close', ...
         'Tag','cmdClose', ...
         'TooltipString','Close the dialog', ...
         'Callback','ui_batch_import(''close'')', ...
         'UserData','[ ]');
      
      h_chkClose = uicontrol('Parent',h_dlg, ...
         'Style','checkbox', ...
         'Position',[270 10 250 20], ...
         'BackgroundColor',[0.95 0.95 0.95], ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'String','Close dialog after processing files', ...
         'Value',1, ...
         'Tag','chkClose');
      
      h_cmdProcess = uicontrol('Parent',h_dlg, ...
         'Position',[650 10 80 25], ...
         'String','Process', ...
         'Tag','cmdProcess', ...
         'TooltipString','Batch process files in the source directory with the specified settings', ...
         'Callback','ui_batch_import(''process'')', ...
         'Enable','off');
      
      uih = struct( ...
         'h_fig',h_fig, ...
         'editPath1',h_editPath1, ...
         'editPath2',h_editPath2, ...
         'cmdBrowse1',h_cmdBrowse1, ...
         'tglSyncPath',h_tglSyncPath, ...
         'cmdBrowse2',h_cmdBrowse2, ...
         'editFileSpec',h_editFileSpec, ...
         'cmdBrowseFile',h_cmdBrowseFile, ...
         'listSyntax',h_listSyntax, ...
         'popFilter',h_popFilter, ...
         'lblArg1',h_lblArg1, ...
         'lblArg2',h_lblArg2, ...
         'lblArg3',h_lblArg3, ...
         'lblArg4',h_lblArg4, ...
         'lblArg5',h_lblArg5, ...
         'lblArg6',h_lblArg6, ...
         'lblArgHelp1',h_lblArgHelp1, ...
         'lblArgHelp2',h_lblArgHelp2, ...
         'lblArgHelp3',h_lblArgHelp3, ...
         'lblArgHelp4',h_lblArgHelp4, ...
         'lblArgHelp5',h_lblArgHelp5, ...
         'lblArgHelp6',h_lblArgHelp6, ...
         'editArg1',h_editArg1, ...
         'editArg2',h_editArg2, ...
         'editArg3',h_editArg3, ...
         'editArg4',h_editArg4, ...
         'editArg5',h_editArg5, ...
         'editArg6',h_editArg6, ...
         'cmdClose',h_cmdClose, ...
         'cmdProcess',h_cmdProcess, ...
         'chkClose',h_chkClose);
      
      %add filterdata array separately to avoid redimensioning structure
      uih.filterdata = filterdata;
      
      set(h_dlg,'Visible','on','UserData',uih)
      drawnow
      
   else
      messagebox('init','The import filter database file ''imp_filters.mat'' was not found or invalid','','Error')
   end
   
else
   
   h_dlg = findobj('Tag','dlgBatchImport');
   
   if ~isempty(h_dlg)
      
      uih = get(h_dlg,'UserData');
      
      switch op
         
         case 'close'
            
            %delete figure to close without circular reference to closerequestfcn
            delete(h_dlg)
            drawnow
            
            %check for last window - open startup screen
            if ~isempty(uih.h_fig) && length(findobj)>1
               try
                  figure(uih.h_fig)
               catch
                  ui_aboutgce('reopen')  %check for last window
               end
            else
               ui_aboutgce('reopen')  %check for last window
            end
            
         case 'browsepath'  %browse for source or destination path
            
            %get handle for pressed button
            h_browse = gcbo;
            
            %get tag to deterine which path to update
            strTag = get(h_browse,'Tag');
            
            %get corresponding path handle
            if strcmp(strTag,'cmdBrowse1')
               h_path = uih.editPath1;
               strPrompt = 'Choose a source directory';
            else
               h_path = uih.editPath2;
               strPrompt = 'Choose a destination directory';
            end
            
            %get starting path
            strPath = uigetdir(deblank(get(h_path,'String')),strPrompt);
            
            %check for cancel, update path
            if ischar(strPath) && isdir(strPath)
               set(h_path,'String',strPath,'UserData',strPath)
               ui_batch_import('syncpath')  %call syncpath to copy output path if active
               ui_batch_import('controls')  %update export button state
            end
            
         case 'syncpath'  %toggle sync option
            
            val = get(uih.tglSyncPath,'Value');
            
            if val == 1
               pn = get(uih.editPath1,'String');            
               if isdir(pn)
                  set(uih.editPath2,'String',pn,'UserData',pn);
               end
               set(uih.cmdBrowse2,'Enable','off')
               set(uih.editPath2,'Enable','off')
            else
               set(uih.cmdBrowse2,'Enable','on')
               set(uih.editPath2,'Enable','on')
            end
            
         case 'checkpath'  %validate manual path entries
            
            %get handle for pressed button
            h_browse = gcbo;
            
            %get tag to deterine which path to update
            strTag = get(h_browse,'Tag');
            
            %get corresponding path handle
            if strcmp(strTag,'editPath1')
               h_path = uih.editPath1;
            elseif strcmp(strTag,'editPath2')
               h_path = uih.editPath2;
            else
               h_path = [];
            end
            
            if ~isempty(h_path)
            
               %get starting path
               strPath = trimstr(get(h_path,'String'));
            
               %validate, update path
               if ischar(strPath) && isdir(strPath)
                  set(h_path,'String',strPath,'UserData',strPath)
                  ui_batch_import('syncpath')  %call syncpath to copy output path if active
                  ui_batch_import('controls')  %update export button state
               else
                  set(h_path,'String',get(h_path,'UserData'))  %reset to cached path
                  messagebox('init','Invalid path - value reset','','Error',[0.95 0.95 0.95],0)
               end
               
            end
            
         case 'browsefiles'  %open a file selection dialog for selecting the filespec
            
            %get current filespec
            filespec = get(uih.editFileSpec,'String');
            if isempty(filespec)
               filespec = '*.*';
            end
            
            %get source path
            pn = get(uih.editPath1,'String');
            
            if isdir(pn)
               
               %get file and path using uigetfile
               curpath = pwd;
               cd(pn)
               [fn,pn2] = uigetfile(filespec,'Select a file to import');
               if ~ischar(fn)
                  fn = '';
               end
               cd(curpath)
               drawnow
               
               %update filter spec and path if valid
               if ~isempty(fn)
                  set(uih.editFileSpec,'String',fn)
                  if ~strcmp(pn,pn2)
                     set(uih.editPath1,'String',pn2,'UserData',pn2)
                  end
               end
               
            end
            
         case 'controls'  %toggle status of process button based on batch export field states
            
            %get field values
            strPath1 = deblank(get(uih.editPath1,'String'));
            strPath2 = deblank(get(uih.editPath1,'String'));
            strFileSpec = deblank(get(uih.editFileSpec,'String'));
            filterval = get(uih.popFilter,'Value') - 1;
            
            %validate contents
            if ~isempty(strFileSpec) && isdir(strPath1) && isdir(strPath2) && filterval > 0
               set(uih.cmdProcess,'Enable','on')
            else
               set(uih.cmdProcess,'Enable','off')
            end
            
         case 'filter'  %handle import filter changes
            
            %get filter selection index, offsetting for dummy first row
            sel = get(uih.popFilter,'Value') - 1;
            
            %check for valid selection
            if sel > 0
               
               %get filter info
               filterdata = uih.filterdata(sel,:);
               mfile = filterdata{1};
               filemask = filterdata{2};
               
               %update filemask
               set(uih.editFileSpec,'String',filemask)
               
               %get function help
               [syntax,fn_desc,fnc_help,parms] = parse_gce_syntax(mfile);
               
               %add syntax help
               if ~isempty(fnc_help)
                  set(uih.listSyntax,'String',splitstr(fnc_help,char(10),0,0),'Enable','on')
               end
               
               %get argument name and description for help text (if argument undefined, clear and lock fields)
               if isstruct(parms)
                  
                  %get index of input type arguments
                  Iinput = find(strcmp('input',{parms.type}'));
                  numargs = length(Iinput)-2;
                  
                  %update fields
                  for i = 1:6
                     if i <= numargs
                        inputfld = i+2;  %calculate input field, offsetting for filename, pathname arguments
                        argname = parms(Iinput(inputfld)).name;
                        argdesc = parms(Iinput(inputfld)).description;
                        helpstr = [argname,': ',argdesc];
                        set(uih.(['lblArg',int2str(i)]),'String',argname,'TooltipString',[argname,' argument value'])
                        set(uih.(['lblArgHelp',int2str(i)]),'String',argdesc,'TooltipString',helpstr)
                        set(uih.(['editArg',int2str(i)]),'String',filterdata{i+2},'Enable','on')
                     else
                        set(uih.(['lblArg',int2str(i)]),'String','','TooltipString','')
                        set(uih.(['lblArgHelp',int2str(i)]),'String','','TooltipString','')
                        set(uih.(['editArg',int2str(i)]),'String','','Enable','off')
                     end
                  end
                  
               end               
               
            else  %clear fields if no filter selected
               
               set(uih.listSyntax,'String','','Enable','off')
               
               for i = 1:6
                  set(uih.(['lblArg',int2str(i)]),'String','','TooltipString','')
                  set(uih.(['lblArgHelp',int2str(i)]),'String','','TooltipString','')
                  set(uih.(['editArg',int2str(i)]),'String','','Enable','off')
               end
               
            end
               
            %update control states
            ui_batch_import('controls')
               
         case 'process'  %process files with the specified options
            
            %get path and filespec info
            pn_source = get(uih.editPath1,'String');
            pn_dest = get(uih.editPath2,'String');
            filemask = deblank(get(uih.editFileSpec,'String'));
            
            %get filter selection to determine mfile
            filtersel = get(uih.popFilter,'Value') - 1;
            filterdata = uih.filterdata(filtersel,:);
            mfile = filterdata{1};
            
            %extract arguments, check for numeric or cell array and convert
            arglist = cell(1,6);
            for n = 1:6
               arg = deblank(get(uih.(['editArg',int2str(n)]),'String'));
               if ~isempty(arg)
                  if ~isnan(str2double(arg))
                     %check for number
                     arg = str2double(arg);
                  elseif ~isempty(str2num(arg))
                     %check for numeric array
                     arg = str2num(arg);
                  elseif ~isempty(strfind(arg,'{'))
                     %check for cell array syntax
                     try
                        ar = eval(arg);
                     catch
                        ar = [];
                     end
                     if iscell(ar)
                        arg = ar;
                     end
                  elseif length(arg)>=2 && strcmp(arg(1),'''') && strcmp(arg(end),'''')
                     %check for explicit string syntax
                     arg = arg(2:end-1);
                  end
                  arglist{n} = arg;
               end
            end
            
            %get close option
            chkclose = get(uih.chkClose,'Value');

            %run import function, which generates GUI output dialogs
            [msg,filelist,badfiles] = batch_import(mfile,filemask,pn_source,pn_dest, ...
               arglist{1},arglist{2},arglist{3},arglist{4},arglist{5},arglist{6},0);     
            
            %sync source and destination paths to editor instances as load/save paths
            syncpath(pn_source,'load')
            syncpath(pn_dest,'save')
            
            %close dialog if specified unless errors occur
            if chkclose == 1 && isempty(badfiles)
               ui_batch_import('close')
            end
                        
      end
      
   end
   
end