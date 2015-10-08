function ui_multimerge(op,loadpath)
%Dialog for merging multiple GCE Data Structures into a single structure
%(Note: the resultant structure will be opened in the GCE Data Structure Editor)
%
%syntax: ui_multimerge(op,loadpath)
%
%input:
%  op = operation (default = 'init')
%  loadpath = initial path to index (default = pwd)
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

if nargin == 0
   op = 'init';
end

if strcmp(op,'init')

   res = get(0,'ScreenSize');

   if length(findobj) > 1
      h_dlg = findobj('tag','dlgMultiMerge');
   else
      h_dlg = [];
   end

   if ~isempty(h_dlg)

      figure(h_dlg)
      drawnow

   else

      %get loadpath from calling editor window
      if exist('loadpath','var') ~= 1
         loadpath = '';
         if length(findobj) > 1
            h_fig = gcf;
            if strcmp(get(h_fig,'Tag'),'dlgDSEditor')
               loadpath = get(findobj(h_fig,'Tag','mnuLoad'),'UserData');
            end
         end
      end

      %check for valid loadpath, using working directory if empty/invalid
      if isempty(loadpath) || ~isdir(loadpath)
         loadpath = pwd;
         if strcmpi(loadpath,fileparts(which('ui_multimerge')))
            loadpath = '';  %don't index toolbox directory by default
         end
      end

      bgcolor = [0.9 0.9 0.9];
      bgcolor2 = [0.95 0.95 0.95];

      %load or init option preferences structure
      prefs = [];
      if exist('ui_multimerge.mat','file') == 2
         try
            vars = load('ui_multimerge.mat','-mat');
         catch
            vars = struct('null','');
         end
         if isfield(vars,'prefs')
            prefs = vars.prefs;
         end
      end
      if ~isstruct(prefs)
         prefs = struct('MergeType',2, ...
            'Metadata',1, ...
            'FlagOption',1, ...
            'DataSetName',1, ...
            'CloseOption',1);
      end

      %init figure and gui controls
      h_dlg = figure('Name','Batch Structure Merge', ...
         'Visible','off', ...
         'Position',[max(0,(res(3)-800)./2) max(50,(res(4)-450)./2) 800 460], ...
         'Color',bgcolor, ...
         'KeyPressFcn','figure(gcf)', ...
         'MenuBar','none', ...
         'NumberTitle','off', ...
         'Tag','dlgMultiMerge', ...
         'ToolBar','none', ...
         'DefaultuicontrolUnits','pixels', ...
         'CloseRequestFcn','ui_multimerge(''cancel'')');

      if mlversion >= 7
         set(h_dlg,'WindowStyle','normal')
         set(h_dlg,'DockControls','off')
      end

      uicontrol('Parent',h_dlg, ...
         'Style','frame', ...
         'Position',[1 1 800 460], ...
         'BackgroundColor',bgcolor, ...
         'ForegroundColor',[0 0 0], ...
         'Tag','frame');

      uicontrol('Parent',h_dlg, ...
         'Style','frame', ...
         'Position',[7 45 788 410], ...
         'BackgroundColor',bgcolor2, ...
         'ForegroundColor',[0 0 0], ...
         'Tag','frame');

      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor2, ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'Position',[16 416 77 16], ...
         'String','Directory', ...
         'Style','text', ...
         'Tag','StaticText1');

      h_editPath = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'Callback','ui_multimerge(''newpath'')', ...
         'Position',[95 415 570 20], ...
         'Style','edit', ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'String',loadpath, ...
         'Tag','editPath', ...
         'UserData','[ ]');

      h_cmdBrowse = uicontrol('Parent',h_dlg, ...
         'Callback','ui_multimerge(''browse'')', ...
         'FontWeight','bold', ...
         'Position',[670 415 30 20], ...
         'String','...', ...
         'Tag','cmdBrowse', ...
         'TooltipString','Browse to select directory');

      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor2, ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'Position',[87 382 260 16], ...
         'String','Available Files', ...
         'Style','text', ...
         'Tag','StaticText');

      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor2, ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'Position',[518 382 260 16], ...
         'String','Selected Files', ...
         'Style','text', ...
         'Tag','StaticText');

      h_listAvail = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'Position',[20 140 440 240], ...
         'String',' ', ...
         'FontSize',9, ...
         'Style','listbox', ...
         'Min',1, ...
         'Max',10, ...
         'Tag','listAvail', ...
         'UserData','[ ]', ...
         'Callback','ui_multimerge(''listclick'')', ...
         'Value',1);

      h_listSelect = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'Position',[510 140 270 240], ...
         'String',' ', ...
         'FontSize',9, ...
         'Style','listbox', ...
         'Min',1, ...
         'Max',10, ...
         'Tag','listSelect', ...
         'UserData','[ ]', ...
         'Callback','ui_multimerge(''listclick'')', ...
         'Value',1);

      h_cmdAddAll = uicontrol('Parent',h_dlg, ...
         'Callback','ui_multimerge(''addall'')', ...
         'FontWeight','bold', ...
         'Position',[470 310 30 20], ...
         'String','>>', ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'Tag','cmdAddAll', ...
         'TooltipString','Copy all datasets to selected list');

      h_cmdAdd = uicontrol('Parent',h_dlg, ...
         'Callback','ui_multimerge(''add'')', ...
         'FontWeight','bold', ...
         'Position',[470 285 30 20], ...
         'String','>', ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'Tag','cmdAdd', ...
         'TooltipString','Copy current dataset to selected list');

      h_cmdRemoveAll = uicontrol('Parent',h_dlg, ...
         'Callback','ui_multimerge(''remove'')', ...
         'FontWeight','bold', ...
         'Position',[470 260 30 20], ...
         'String','<', ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'Tag','cmdRemove', ...
         'TooltipString','Remove current dataset from selected list');

      h_cmdRemove = uicontrol('Parent',h_dlg, ...
         'Callback','ui_multimerge(''removeall'')', ...
         'FontWeight','bold', ...
         'Position',[470 235 30 20], ...
         'String','<<', ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'Tag','cmdRemove', ...
         'TooltipString','Remove all datasets from selected list');
      
      h_cmdView = uicontrol('Parent',h_dlg, ...
         'Callback','ui_multimerge(''view'')', ...
         'Position',[470 180 30 20], ...
         'FontWeight','bold', ...
         'String','??', ...
         'FontSize',10, ...
         'Tag','cmdView', ...
         'TooltipString','Open the selected data set(s) in the Available Files list to inspect data set contents');

      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[70 99 110 18], ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'BackgroundColor',bgcolor2, ...
         'String','Merge Type');

      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[70 74 110 18], ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'BackgroundColor',bgcolor2, ...
         'String','Metadata Option');

      h_popMergeFcn = uicontrol('Parent',h_dlg, ...
         'Position',[180 100 200 20], ...
         'FontSize',9, ...
         'Style','popupmenu', ...
         'BackgroundColor',[1 1 1], ...
         'String',{'Append data sets in order';'Merge by study date';'Time-series merge (overwrite older)';'Time-series merge (add newer)'}, ...
         'Value',prefs.MergeType, ...
         'Tag','popMergeFcn', ...
         'TooltipString','Option to select the merge type to perform', ...
         'UserData',{'order','date','datetrim','datetrim2'});

      h_popMetadata = uicontrol('Parent',h_dlg, ...
         'Position',[180 75 200 20], ...
         'Fontsize',9, ...
         'Style','popupmenu', ...
         'BackgroundColor',[1 1 1], ...
         'String',char({'Merge all metadata','Merge selected metadata','Do not merge metadata'}), ...
         'Value',prefs.Metadata, ...
         'Tag','popMetadata', ...
         'TooltipString','Option to specify how to merge structure metadata', ...
         'UserData',{'all','pick','none'});

      h_chkFlagOpt = uicontrol('Parent',h_dlg, ...
         'Position',[430 100 300 20], ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'Style','checkbox', ...
         'BackgroundColor',bgcolor2, ...
         'String','Lock QA/QC flags to prevent recalculation?', ...
         'Tag','chkFlagOpt', ...
         'TooltipString','Option to add ''manual'' to all QA/QC flag criteria strings to prevent inappropriate re-flagging', ...
         'Value',prefs.FlagOption);

      h_chkDataSetNameOpt = uicontrol('Parent',h_dlg, ...
         'Position',[430 75 300 20], ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'Style','checkbox', ...
         'BackgroundColor',bgcolor2, ...
         'String','Add DataSetName column listing each data set?', ...
         'Tag','chkDataSetNameOpt', ...
         'TooltipString','Option to add a DataSetName column to identify the source data set for each record', ...
         'Value',prefs.DataSetName);

      h_chkCloseOpt = uicontrol('Parent',h_dlg, ...
         'Position',[270 10 280 20], ...
         'FontSize',10, ...
         'Style','checkbox', ...
         'BackgroundColor',bgcolor, ...
         'String','Close dialog after performing merge?', ...
         'Tag','chkCloseOpt', ...
         'TooltipString','Option to close the dialog after performing the merge (uncheck to perform multiple merges)', ...
         'Value',prefs.CloseOption);

      h_cmdClose = uicontrol('Parent',h_dlg, ...
         'Callback','ui_multimerge(''cancel'')', ...
         'Position',[10 10 70 25], ...
         'String','Cancel', ...
         'FontSize',10, ...
         'Tag','cmdClose', ...
         'TooltipString','Remove file from selected list');

      h_cmdProceed = uicontrol('Parent',h_dlg, ...
         'Callback','ui_multimerge(''eval'')', ...
         'Position',[720 10 70 25], ...
         'String','Proceed', ...
         'FontSize',10, ...
         'Tag','cmdProceed', ...
         'Enable','off', ...
         'TooltipString','Remove file from selected list');

      uih = struct( ...
         'cmdBrowse',h_cmdBrowse, ...
         'cmdProceed',h_cmdProceed, ...
         'cmdClose',h_cmdClose, ...
         'cmdRemove',h_cmdRemove, ...
         'cmdAdd',h_cmdAdd, ...
         'cmdAddAll',h_cmdAddAll, ...
         'cmdRemoveAll',h_cmdRemoveAll, ...
         'cmdView',h_cmdView, ...
         'listAvail',h_listAvail, ...
         'listSelect',h_listSelect, ...
         'chkCloseOpt',h_chkCloseOpt, ...
         'chkFlagOpt',h_chkFlagOpt, ...
         'chkDataSetNameOpt',h_chkDataSetNameOpt, ...
         'popMergeFcn',h_popMergeFcn, ...
         'popMetadata',h_popMetadata, ...
         'editPath',h_editPath, ...
         'index',[], ...
         'str_long',[], ...
         'str_short',[]);

      set(h_dlg, ...
         'UserData',uih, ...
         'Visible','on')

      if ~isempty(loadpath)
         ui_multimerge('newpath');
      else
         drawnow
      end

   end

else

   h_dlg = findobj('tag','dlgMultiMerge');

   if ~isempty(h_dlg)

      uih = get(h_dlg,'UserData');

      switch op

         case 'cancel'  %cancel merge

            delete(h_dlg)
            drawnow
            ui_aboutgce('reopen')  %check for last window

         case 'eval'  %evaluate input, perform specified merge

            %get field values, settings
            Isel = get(uih.listSelect,'UserData');

            mergetype_val = get(uih.popMergeFcn,'Value');
            mergetype_list = get(uih.popMergeFcn,'UserData');
            mergetype = mergetype_list{mergetype_val};

            metamerge_val = get(uih.popMetadata,'Value');
            metamerge_list = get(uih.popMetadata,'UserData');
            metamerge = metamerge_list{metamerge_val};

            closeopt = get(uih.chkCloseOpt,'Value');
            flagopt = get(uih.chkFlagOpt,'Value');
            datasetnameopt = get(uih.chkDataSetNameOpt,'Value');

            prefs = struct('MergeType',mergetype_val, ...
               'Metadata',metamerge_val, ...
               'FlagOption',flagopt, ...
               'DataSetName',datasetnameopt, ...
               'CloseOption',closeopt);

            if ~isempty(Isel)

               %save dialog preferences
               pn = [gce_homepath,filesep,'settings'];
               if ~isdir(pn)
                  pn = fileparts(which('ui_multimerge'));
               end
               save([pn,filesep,'ui_multimerge.mat'],'prefs')

               %build filelist, structure list from index
               index = uih.index;
               pns = {index(Isel).path}';
               fns = {index(Isel).filename}';
               filelist = concatcellcols([pns,fns],filesep);
               structlist = {index(Isel).varname}';

               set(gcf,'Pointer','watch'); drawnow

               %perform specified merge
               [s,msg] = multimerge(filelist,structlist,mergetype,flagopt,metamerge,datasetnameopt);

               set(gcf,'Pointer','arrow'); drawnow

               %open merged structure
               if ~isempty(s)
                  if closeopt == 1
                     delete(h_dlg)
                     drawnow
                  end
                  ui_editor('init',s)
               end

               if ~isempty(msg)
                  messagebox('init',msg,'','Warning',[.9 .9 .9]);
               end

            else
               msg = messagebox('init',' No files selected to merge ',[],'Error',[.9 .9 .9]);
            end

         case 'listclick'  %handle list double clicks

            seltype = get(gcf,'SelectionType');

            if strcmp(seltype,'open') && length(get(gcbo,'Value')) == 1  %check for double click, single selection
               listtag = get(gcbo,'Tag');
               if strcmp(listtag,'listAvail')
                  ui_multimerge('add')
               elseif strcmp(listtag,'listSelect')
                  ui_multimerge('remove')
               end
            end

         case 'addall'  %add all selected datasets to select list

            set(uih.listAvail,'Value',(1:length(get(uih.listAvail,'String')))')
            ui_multimerge('add')

         case 'removeall'  %remove all selected datasets from select list

            set(uih.listSelect,'Value',(1:length(get(uih.listSelect,'String')))')
            ui_multimerge('remove')

         case 'add'  %add selected datasets to select list

            Iavail = get(uih.listAvail,'UserData');

            if ~isempty(Iavail)

               Isel = get(uih.listSelect,'UserData');  %get cached index for select list
               val = get(uih.listAvail,'Value'); %get current list selections
               Inew = Iavail(val);  %create index of selected datasets
               Iavail = setdiff(Iavail,Inew);  %generate index of residual datasets

               Isel = [Isel;Inew];  %add selected datasets to target list

               %update list uicontrols
               if ~isempty(Iavail)
                  set(uih.listAvail, ...
                     'String',uih.str_long(Iavail), ...
                     'Value',min(max(val),length(Iavail)), ...
                     'UserData',Iavail, ...
                     'ListboxTop',min(get(uih.listAvail,'ListboxTop'),length(Iavail)), ...
                     'Enable','on')
               else  %no residual datasets
                  set(uih.listAvail, ...
                     'String','', ...
                     'Value',1, ...
                     'UserData',Iavail, ...
                     'ListboxTop',1, ...
                     'Enable','off')
               end

               set(uih.listSelect, ...
                  'String',uih.str_short(Isel), ...
                  'Value',max(1,length(Isel)), ...
                  'UserData',Isel, ...
                  'Enable','on')

               ui_multimerge('buttons')  %update button state

            end

         case 'remove'  %remove dataset from select list

            Isel = get(uih.listSelect,'UserData');

            if ~isempty(Isel)

               Iavail = get(uih.listAvail,'UserData');
               val = get(uih.listSelect,'Value');
               Inew = Isel(val);

               Isel = setdiff(Isel,Inew);
               Iavail = sort([Iavail;Inew]);

               set(uih.listAvail, ...
                  'String',uih.str_long(Iavail), ...
                  'Value',find(Iavail==max(Inew)), ...
                  'UserData',Iavail, ...
                  'ListboxTop',get(uih.listAvail,'ListboxTop'), ...
                  'Enable','on')

               if ~isempty(Isel)
                  set(uih.listSelect, ...
                     'String',uih.str_short(Isel), ...
                     'Value',min(max(val),length(Isel)), ...
                     'ListboxTop',min(get(uih.listSelect,'ListboxTop'),length(Isel)), ...
                     'UserData',Isel, ...
                     'Enable','on')
               else
                  set(uih.listSelect, ...
                     'String','', ...
                     'Value',1, ...
                     'UserData',Isel, ...
                     'ListboxTop',1, ...
                     'Enable','off')
               end

               ui_multimerge('buttons')

            end
            
         case 'view'  %check for excessive variable selections before calling 'view_confirm'
            
            val = get(uih.listAvail,'Value'); %get current list selections
            
            if length(val) <= 5
               ui_multimerge('view_confirm')
            else
               msg = ['Open all ',int2str(length(val)),' selected data sets in independent editor windows?'];
               confirmdlg('init',msg,'ui_multimerge(''view_confirm'')')
            end

         case 'view_confirm'  %open selected data sets in the GUI editor window
            
            %get cached available columns info
            Iavail = get(uih.listAvail,'UserData');

            if ~isempty(Iavail)

               %get individual selections
               val = get(uih.listAvail,'Value'); %get current list selections
               Isel = Iavail(val);  %create index of selected datasets

               %build filelist, structure list from index
               index = uih.index;
               pns = {index(Isel).path}';
               fns = {index(Isel).filename}';
               filelist = concatcellcols([pns,fns],filesep);
               structlist = {index(Isel).varname}';
               
               %loop through variables opening in editor instances
               for cnt = 1:length(val)
                  try
                     vars = load(filelist{cnt},'-mat');  %load file
                     s = vars.(structlist{cnt});  %retrieve data structure variable
                  catch
                     s = [];
                  end                  
                  if ~isempty(s)
                     ui_editor('init',s)
                  end
               end
               
            end

         case 'browse'  %browse for import directory

            %get last path
            lastpath = get(uih.editPath,'String');
            if isempty(lastpath)
               lastpath = pwd;
            end

            %use directory browsing control if present, otherwise prompt for a .mat file
            if exist('uigetdir','builtin') == 5 || exist('uigetdir','file') == 2
               pn = uigetdir(lastpath,'Select a directory containing data sets to merge');
            else
               curpath = pwd;
               cd(lastpath)
               if ispc
                  filespec = '*.mat';
               else
                  filespec = '*.mat;*.MAT';
               end
               [fn,pn] = uigetfile(filespec,'Select a directory containing data sets to merge');
               cd(curpath)
            end
            drawnow

            %check for cancel, update path field
            if pn ~= 0
               set(uih.editPath,'String',pn)  %update path field, cached last path
               ui_multimerge('newpath')
            end

         case 'newpath'  %validate path changes

            newpath = deblank(get(uih.editPath,'String'));
            lastpath = get(uih.editPath,'UserData');

            %check for valid path
            if isdir(newpath)

               %check for path change
               set(uih.editPath,'String',newpath,'UserData',newpath)  %update cached path
               ui_multimerge('refresh')  %update dialog

            else  %invalid path - reset field

               set(uih.editPath,'String',lastpath) %reset field to last value
               drawnow

               messagebox('init','  The specified path is invalid (field reset)  ',[],'Error',[.9 .9 .9]);

            end

         case 'refresh'  %refresh lists to reflect files in new directory

            pn = get(uih.editPath,'String');

            set(h_dlg,'Pointer','watch'); drawnow

            %generate brief index of files
            index = search_index(pn,[],'minimal',0);

            %generate strings, pointer arrays for listboxes based on index
            if ~isempty(index)
               [tmp,Isort] = sortrows({index.filename}');
               index = index(Isort);
               str_long = concatcellcols([strrep(concatcellcols([{index.filename}',{index.varname}'],': '), ...
                     ': data',''),{index.title}'],' -- ');
               str_short = strrep(concatcellcols([{index.filename}',{index.varname}'],': '), ...
                  ': data','');
               flist = (1:length(index));
            else
               str_long = '';
               str_short = '';
               flist = [];
            end

            %update listboxes
            set(uih.listAvail, ...
               'String',str_long, ...
               'Value',1, ...
               'UserData',(1:length(flist))')
            set(uih.listSelect, ...
               'String','', ...
               'Value',1, ...
               'UserData',[])

            %update cached info
            uih.index = index;
            uih.str_long = str_long;
            uih.str_short = str_short;
            set(h_dlg,'UserData',uih)

            set(h_dlg,'Pointer','arrow'); drawnow

            %update button states
            ui_multimerge('buttons')

         case 'buttons'  %update button states after dialog changes

            %set states based on available files list
            if isempty(get(uih.listAvail,'Userdata'))
               set(uih.cmdAdd,'Enable','off')
               set(uih.cmdAddAll','Enable','off')
               set(uih.cmdView,'Enable','off')
            else
               set(uih.cmdAdd,'Enable','on')
               set(uih.cmdAddAll','Enable','on')
               set(uih.listAvail,'Enable','on')
               set(uih.cmdView,'Enable','on')
            end

            %set states based on selected files list
            if isempty(get(uih.listSelect,'Userdata'))
               set(uih.cmdRemove,'Enable','off')
               set(uih.cmdRemoveAll,'Enable','off')
            else
               set(uih.cmdRemove,'Enable','on')
               set(uih.cmdRemoveAll,'Enable','on')
            end

            %set states of Proceed button based on path and selected files
            if isempty(get(uih.editPath,'String'))
               set(uih.cmdProceed,'Enable','off')
            elseif isempty(get(uih.listSelect,'String'))
               set(uih.cmdProceed,'Enable','off')
            else
               set(uih.cmdProceed,'Enable','on')
            end

      end

   end

end
