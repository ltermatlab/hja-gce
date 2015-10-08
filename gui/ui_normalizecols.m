function ui_normalizecols(op,s,h_cb,cb)
%GUI dialog for normalizing a data set by merging multiple related columns into parameter name/value columns
%with records in other specified columns repeated for each original group of parameters
%
%syntax:  ui_normalizecols(op,s)
%
%input:
%  op = operation (default = 'init' to initialize dialog)
%  s = data structure
%
%output:
%  none
%
%(c)2007-2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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

%set default argument to 'init'
if nargin == 0
   op = 'init';
elseif isstruct(op)  %catch call without 'init' argument
   s = op;
   op = 'init';
end

%init data structure variable for validity test if omitted
if exist('s','var') ~= 1
   s = [];
end

%check for call to build gui
if strcmp(op,'init')
   
   %check for valid structure
   if gce_valid(s,'data')
      
      %set empty callback handle if omitted
      if exist('h_cb','var') ~= 1
         h_cb = [];
      end
      
      %set empty callback if omitted
      if exist('cb','var') ~= 1
         cb = '';
      end
      
      %check for stored preferences
      prefs = [];
      if exist('ui_normalizecols.mat','file') == 2
         try
            v = load('ui_normalizecols.mat','-mat');
         catch
            v = struct('null','');
         end
         if isfield(v,'prefs')
            prefs = v.prefs;            
         end
      end
      
      if ~isstruct(prefs)
         prefs = struct('col_parameter','Parameter', ...
            'col_values','Value', ...
            'datatype',1, ...
            'matchunits',0, ...
            'close',1);
      end
      
      %check for prior dialog instance and close
      figpos = [];
      if length(findobj) > 1
         h_dlg = findobj('Tag','dlgNormalizeColumns');
         if ~isempty(h_dlg)
            figpos = get(h_dlg,'Position');  %cache existing figure position
            delete(h_dlg)
         end
      end
      
      %init screen info arrays
      res = get(0,'ScreenSize');
      bgcolor = [.95 .95 .95];
      if isempty(figpos)
         figpos = [max(1,0.5.*(res(3)-620)) max(50,0.5.*(res(4)-520)) 620 520];
      end
      
      h_dlg = figure('Visible','off', ...
         'Color',bgcolor, ...
         'KeyPressFcn','figure(gcf)', ...
         'MenuBar','none', ...
         'Name','Normalize Columns', ...
         'NumberTitle','off', ...
         'Position',figpos, ...
         'Tag','dlgNormalizeColumns', ...
         'ToolBar','none', ...
         'Resize','off', ...
         'CloseRequestFcn','ui_normalizecols(''cancel'')', ...
         'DefaultuicontrolUnits','pixels');
      
      if mlversion >= 7
         set(h_dlg,'WindowStyle','normal')
         set(h_dlg,'DockControls','off')
      end
      
      uicontrol('Parent',h_dlg, ...
         'Style','frame', ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',bgcolor, ...
         'Position',[1 1 figpos(3) figpos(4)]);
      
      %create controls
      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.7], ...
         'ListboxTop',0, ...
         'Position',[29 493 215 18], ...
         'String','Available Columns', ...
         'Style','text', ...
         'Tag','lblAvailable');
      
      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.7], ...
         'ListboxTop',0, ...
         'Position',[310 493 275 18], ...
         'String','Column Selections', ...
         'Style','text', ...
         'Tag','lblSelections');
      
      uicontrol('Parent',h_dlg, ...
         'Style','frame', ...
         'BackgroundColor',[.9 .9 .9], ...
         'ForegroundColor',[0 0 0], ...
         'Position',[290 340 325 150]);
      
      uicontrol('Parent',h_dlg, ...
         'Style','frame', ...
         'BackgroundColor',[.9 .9 .9], ...
         'ForegroundColor',[0 0 0], ...
         'Position',[290 185 325 150]);
      
      uicontrol('Parent',h_dlg, ...
         'Style','frame', ...
         'BackgroundColor',[.9 .9 .9], ...
         'ForegroundColor',[0 0 0], ...
         'Position',[290 50 325 130]);
      
      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[360 468 215 18], ...
         'BackgroundColor',[.9 .9 .9], ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.7], ...
         'ListboxTop',0, ...
         'String','Columns to Replicate', ...
         'Tag','lblRep');
      
      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[360 313 215 18], ...
         'BackgroundColor',[.9 .9 .9], ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.7], ...
         'ListboxTop',0, ...
         'String','Columns to Merge', ...
         'Tag','lblMerge');
      
      %generate initial column list array
      collist = concatcellcols([s.name',repmat({'  ('},length(s.name),1), ...
         s.units',repmat({')'},length(s.name),1)]);
      
      h_listAvailable = uicontrol('Parent',h_dlg, ...
         'Style','listbox', ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'Position',[6 50 275 440], ...
         'String',char(collist), ...
         'Min',1, ...
         'Max',10, ...
         'UserData',(1:length(s.name)), ...
         'Tag','listAvailable', ...
         'Value',1);
      
      h_listMerge = uicontrol('Parent',h_dlg, ...
         'Style','listbox', ...
         'Position',[340 190 265 120], ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'String',' ', ...
         'Min',1, ...
         'Max',10, ...
         'UserData',[], ...
         'Tag','h_listMerge', ...
         'Value',1);
      
      h_listRep = uicontrol('Parent',h_dlg, ...
         'Style','listbox', ...
         'Position',[340 345 265 120], ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'String',' ', ...
         'Min',1, ...
         'Max',10, ...
         'UserData',[], ...
         'Tag','listRep', ...
         'Value',1);
      
      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[300 150 160 18], ...
         'HorizontalAlignment','left', ...
         'BackgroundColor',[.9 .9 .9], ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.7], ...
         'String','Parameter Column Name:', ...
         'Tag','lblCatName');
      
      h_editCatName = uicontrol('Parent',h_dlg, ...
         'Style','edit', ...
         'Position',[460 150 145 20], ...
         'HorizontalAlignment','left', ...
         'FontSize',9, ...
         'BackgroundColor',[1 1 1], ...
         'String',prefs.col_parameter, ...
         'Tag','editCatName', ...
         'UserData','Parameter', ...
         'Callback','ui_normalizecols(''varname'')');
      
      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[300 120 160 18], ...
         'HorizontalAlignment','left', ...
         'BackgroundColor',[.9 .9 .9], ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.7], ...
         'String','Values Column Name:', ...
         'Tag','lblValName');
      
      h_editValName = uicontrol('Parent',h_dlg, ...
         'Style','edit', ...
         'Position',[460 120 145 20], ...
         'HorizontalAlignment','left', ...
         'FontSize',9, ...
         'BackgroundColor',[1 1 1], ...
         'String',prefs.col_values, ...
         'Tag','editValName', ...
         'UserData','Value', ...
         'Callback','ui_normalizecols(''varname'')');
      
      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'HorizontalAlignment','left', ...
         'BackgroundColor',[.9 .9 .9], ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.7], ...
         'Position',[300 90 160 18], ...
         'String','Values Column Datatype:', ...
         'Tag','lblValDataType');
      
      h_popDataType = uicontrol('Parent',h_dlg, ...
         'Style','popupmenu', ...
         'HorizontalAlignment','left', ...
         'Position',[460 92 145 18], ...
         'FontSize',9, ...
         'BackgroundColor',[1 1 1], ...
         'String',{'(default)','floating-point','exponential','string', ...
         'integer (round)','integer (fix)','integer (ceiling)','integer (floor)'}, ...
         'Value',prefs.datatype, ...
         'Tag','editValName', ...
         'UserData',{'','f','e','s','round','fix','ceil','floor'}, ...
         'Callback','ui_normalizecols(''varname'')');
      
      h_chkUnitsMatch = uicontrol('Parent',h_dlg, ...
         'Style','checkbox', ...
         'HorizontalAlignment','left', ...
         'Position',[325 60 260 18], ...
         'FontSize',9, ...
         'ForegroundColor',[0 0 0.7], ...
         'BackgroundColor',[0.9 0.9 0.9], ...
         'String','Require matching Units, Variable Type', ...
         'Tag','chkUnitsMatch', ...
         'Value',prefs.matchunits);
      
      h_cmdAddRep = uicontrol('Parent',h_dlg, ...
         'Position',[299 400 30 22], ...
         'Callback','ui_normalizecols(''val_add'')', ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'String','>', ...
         'ToolTipString','Add selected column to the ''Columns to Replicate'' list', ...
         'Tag','cmdAddRep');
      
      h_cmdRemRep = uicontrol('Parent',h_dlg, ...
         'Position',[299 370 30 22], ...
         'Enable','off', ...
         'Callback','ui_normalizecols(''val_rem'')', ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'ListboxTop',0, ...
         'String','<', ...
         'ToolTipString','Remove selected column from the ''Columns to Replicate'' list', ...
         'Tag','cmdRemRep');
      
      h_cmdAddMerge = uicontrol('Parent',h_dlg, ...
         'Position',[299 255 30 22], ...
         'Callback','ui_normalizecols(''merge_add'')', ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'String','>', ...
         'ToolTipString','Add selected column to the ''Columns to Merge'' list', ...
         'Tag','cmdAddMerge');
      
      h_cmdRemMerge = uicontrol('Parent',h_dlg, ...
         'Position',[299 225 30 22], ...
         'Enable','off', ...
         'Callback','ui_normalizecols(''merge_rem'')', ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'String','<', ...
         'ToolTipString','Remove selected column from the ''Columns to Merge'' list', ...
         'Tag','cmdRemMerge');
      
      h_cmdCancel = uicontrol('Parent',h_dlg, ...
         'Callback','ui_normalizecols(''cancel'')', ...
         'FontSize',9, ...
         'Position',[15 10 60 25], ...
         'String','Cancel', ...
         'TooltipString','Cancel the operation and close the dialog window', ...
         'Tag','cmdCancel');
      
      h_chkClose = uicontrol('Parent',h_dlg, ...
         'Style','checkbox', ...
         'Position',[195 10 280 20], ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'String','Close dialog after exporting the results', ...
         'Value',prefs.close, ...
         'Tag','chkClose');
      
      h_cmdEval = uicontrol('Parent',h_dlg, ...
         'Callback','ui_normalizecols(''eval'')', ...
         'Enable','off', ...
         'FontSize',9, ...
         'ListboxTop',0, ...
         'Position',[550 10 60 25], ...
         'String','Proceed', ...
         'TooltipString','Split the data series and open the structure for editing', ...
         'Tag','cmdEval');
      
      uih = struct( ...
         'listAvailable',h_listAvailable, ...
         'listMerge',h_listMerge, ...
         'listRep',h_listRep, ...
         'cmdAddMerge',h_cmdAddMerge, ...
         'cmdRemMerge',h_cmdRemMerge, ...
         'cmdAddRep',h_cmdAddRep, ...
         'cmdRemRep',h_cmdRemRep, ...
         'editCatName',h_editCatName, ...
         'editValName',h_editValName, ...
         'popDataType',h_popDataType, ...
         'chkUnitsMatch',h_chkUnitsMatch, ...
         'cmdEval',h_cmdEval, ...
         'cmdCancel',h_cmdCancel, ...
         'chkClose',h_chkClose, ...
         'h_cb',h_cb, ...
         'cb',cb, ...
         's',s);
      
      set(h_dlg,'Visible','on','UserData',uih)
      drawnow
      
   else
      msgbox('init','This feature requires a valid data structure as input','','Error',[.9 .9 .9])
   end
   
else  %handle callbacks
   
   h_dlg = [];
   
   %check to see if dialog is the active figure, else ignore callback
   if length(findobj) > 2
      h_dlg = gcf;
      if ~strcmp(get(h_dlg,'Tag'),'dlgNormalizeColumns')
         h_dlg = [];
      end
   end
   
   if ~isempty(h_dlg)
      
      uih = get(h_dlg,'UserData');
      
      switch op
         
         case 'cancel'  %close dialog
            
            delete(h_dlg)
            ui_aboutgce('reopen')  %check for last window
            
         case 'update'  %update form controls
            
            s = uih.s;
            
            if isstruct(s)
               
               %get stored column indices from listboxes
               I_avail = get(uih.listAvailable,'UserData');
               I_merge = get(uih.listMerge,'UserData');
               I_rep = get(uih.listRep,'UserData');
               
               %get data structure attributes
               vars = s.name;
               units = s.units;
               cols = length(s.name);
               varstr = cell(1,cols);
               
               %build variable name list
               for n = 1:cols
                  varstr{n} = [vars{n},'  (',units{n},')'];
               end
               
               %add variables to available list
               if ~isempty(I_avail)
                  s_avail = varstr(I_avail);
               else
                  s_avail = {''};
               end
               
               %add variables to merge list
               if ~isempty(I_merge)
                  s_merge = varstr(I_merge);
               else
                  s_merge = {''};
               end
               
               %add variables to replicate list
               if ~isempty(I_rep)
                  s_rep = varstr(I_rep);
               else
                  s_rep = {''};
               end
               
               %update uicontrols
               set(uih.listAvailable, ...
                  'String',s_avail, ...
                  'Value',max(1,min(get(uih.listAvailable,'Value'),length(I_avail))))
               
               set(uih.listMerge, ...
                  'String',s_merge, ...
                  'Value',max(1,min(get(uih.listMerge,'Value'),length(I_merge))))
               
               set(uih.listRep, ...
                  'String',s_rep, ...
                  'Value',max(1,min(get(uih.listRep,'Value'),length(I_rep))))
               
               %toggle add/remove buttons according to list status
               if isempty(I_avail)
                  set(uih.cmdAddMerge,'Enable','off')
                  set(uih.cmdAddRep,'Enable','off')
               else
                  set(uih.cmdAddMerge,'Enable','on')
                  set(uih.cmdAddRep,'Enable','on')
               end
               
               if isempty(I_merge)
                  set(uih.cmdRemMerge,'Enable','off')
               else
                  set(uih.cmdRemMerge,'Enable','on')
               end
               
               if isempty(I_rep)
                  set(uih.cmdRemRep,'Enable','off')
               else
                  set(uih.cmdRemRep,'Enable','on')
               end
               
               %toggle proceed button according to list status
               if ~isempty(I_merge) && ~isempty(I_rep)
                  set(uih.cmdEval,'Enable','on')
               else
                  set(uih.cmdEval,'Enable','off')
               end
               
               drawnow
               
            end
            
         case 'eval'  %execute normalization with specified settings
            
            %get listbox selections
            I_merge = get(uih.listMerge,'UserData');
            I_rep = get(uih.listRep,'UserData');
            
            %get category and value column names
            str_catcol = get(uih.editCatName,'String');
            str_valcol = get(uih.editValName,'String');
            
            %get datatype conversion option
            dtypelist = get(uih.popDataType,'UserData');
            dtypeval = get(uih.popDataType,'Value');
            dtype = dtypelist{dtypeval};
            
            %get units match option
            unitsval = get(uih.chkUnitsMatch,'Value');
            if unitsval == 1
               unitsopt = 'match';
            else
               unitsopt = 'ignore';
            end
            
            %get close option
            closeval = get(uih.chkClose,'Value');

            %update dialog preferences
            prefs = struct('col_parameter',str_catcol, ...
               'col_values',str_valcol, ...
               'datatype',dtypeval, ...
               'matchunits',unitsval, ...
               'close',closeval);
            
            %save preferences
            fn_prefs = which('ui_normalizecols.mat');
            if isempty(fn_prefs)
               fn_prefs = [gce_homepath,filesep,'settings',filesep,'ui_normalizecols.mat'];
            end
            save(fn_prefs,'prefs')
            
            if ~isempty(I_merge)
               
               set(gcf,'Pointer','watch')
               drawnow
               
               [s2,msg] = normalize_cols(uih.s,I_merge,I_rep,str_catcol,str_valcol,unitsopt,dtype);
               
               set(gcf,'Pointer','arrow')
               drawnow
               
               if ~isempty(s2)
                  
                  if closeval == 1
                     close(h_dlg)
                     drawnow
                  end
                  
                  %check for hooks to calling dialog
                  if isempty(uih.h_cb) && isempty(uih.cb)
                     ui_editor('init',s2);  %send results to editor
                  else
                     err = 0;
                     if ~isempty(uih.h_cb)
                        h_parent = parent_figure(uih.h_cb);
                        if ~isempty(h_parent)
                           set(uih.h_cb,'UserData',s2)
                        else
                           err = 1;
                        end
                     end
                     if err == 0 && ~isempty(uih.cb)
                        try
                           eval(uih.cb)
                        catch
                           err = 1;
                        end
                     end
                     if err == 1  %check for errors - open in new window
                        ui_editor('init',s2)
                        messagebox('init','Errors occurred returning data to the calling window', ...
                           '','Error',[.9 .9 .9])
                     end
                  end
                  
               else
                  messagebox('init',char('Could not perform the analysis with the selected options', ...
                     ['(error: ',msg,')']), ...
                     '','Error',[.9 .9 .9]);
               end
               
            else
               messagebox('init','No columns to merge were specified - operation cancelled',[],'Error',[.9 .9 .9])
            end
            
         case 'copysel'  %copy selected column to a target list
            
            %get handles
            h_source = get(uih.cmdAddMerge,'UserData');
            h_target = get(uih.cmdRemMerge,'UserData');
            h_list = uih.listAvailable;
            
            if ~isempty(h_source) && ~isempty(h_target)
               
               %get indices
               I_target = get(h_target,'UserData');
               I_source = get(h_source,'UserData');
               val = get(h_source,'Value');
               I_sel = I_source(val);
               
               %update indices
               I_target = [I_target,I_sel];
               I_source = setdiff(I_source,I_sel);
               
               %store indices
               set(h_target,'UserData',I_target)
               set(h_source,'UserData',I_source)
               
               %resort master list if adding rows back to list
               if h_target == h_list
                  Ilist = get(h_list,'UserData');
                  Ilist = sort(Ilist);
                  Isel = find(Ilist==I_target(end));
                  set(h_list,'UserData',sort(Ilist),'Value',Isel)
               else
                  set(h_list,'Value',min([val(1),length(I_source)]))
                  set(h_target,'Value',length(I_target))
               end
               
               %update uicontrols
               ui_normalizecols('update');
               
            end
            
         case 'merge_add'  %copy the selected column to the merge list
            
            %assign handles
            set(uih.cmdAddMerge,'UserData',uih.listAvailable);  %source
            set(uih.cmdRemMerge,'UserData',uih.listMerge);  %target
            
            %update listboxes
            ui_normalizecols('copysel')
            
         case 'merge_rem'  %remove the selected column from the merge list
            
            %assign handles
            set(uih.cmdAddMerge,'UserData',uih.listMerge);  %source
            set(uih.cmdRemMerge,'UserData',uih.listAvailable);  %target
            
            %update listboxes
            ui_normalizecols('copysel')
            
         case 'val_add'  %copy the selected column to the replicate list
            
            %assign handles
            set(uih.cmdAddMerge,'UserData',uih.listAvailable);  %source
            set(uih.cmdRemMerge,'UserData',uih.listRep);  %target
            
            %update listboxes
            ui_normalizecols('copysel')
            
         case 'val_rem'  %remove the selected column from the replicate list
            
            %assign handles
            set(uih.cmdAddMerge,'UserData',uih.listRep);  %source
            set(uih.cmdRemMerge,'UserData',uih.listAvailable);  %target
            
            %update listboxes
            ui_normalizecols('copysel')
            
         case 'varname'  %validate variable name selections
            
            h_edit = gcbo;
            
            str = deblank(get(h_edit,'String'));
            
            if isempty(str)
               set(h_edit,'String',get(h_edit,'UserData'))
            end
            
      end
      
   end
   
end