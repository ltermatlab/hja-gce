function ui_calc_missing(op,s,h_cb,cb)
%GCE Data Toolbox dialog for filling in missing values in a data column using calculated values
%based on 'calc_missing_vals.m'
%
%syntax:  ui_calc_missing(op,s)
%
%input:
%  op = operation (default = 'init' to initialize dialog)
%  s = data structure
%
%output:
%  none
%
%
%(c)2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
elseif isstruct(op)
   s = op;
   op = 'init';
end

if exist('s','var') ~= 1
   s = [];
end

if strcmp(op,'init')  %build gui
   
   if gce_valid(s,'data')
      
      if exist('h_cb','var') ~= 1
         h_cb = [];
      end
      
      if exist('cb','var') ~= 1
         cb = '';
      end
      
      %check for settings file
      prefs = [];
      if exist('ui_calc_missing.mat','file') == 2
         try
            v = load('ui_calc_missing.mat','-mat');
         catch
            v = struct('null','');
         end
         if isfield(v,'prefs')
            prefs = v.prefs;
         end
      end
      
      %init default preferences if omitted
      if isempty(prefs)
         prefs = struct('log_option',50, ...
            'flag_code','C', ...
            'flag_def','calculated data value', ...
            'new_window',0, ...
            'save_calc',1, ...
            'calculations',[]);
      end
      
      %generate initial column index and formatted list
      numcols = length(s.name);
      Icols = (1:numcols)';
      collist = concatcellcols([s.name',repmat({'  ('},numcols,1), ...
         s.units',repmat({')'},numcols,1)]);
      
      %init screen info arrays
      res = get(0,'ScreenSize');
      bgcolor = [.9 .9 .9];
      figpos = [max(1,0.5.*(res(3)-640)) max(50,0.5.*(res(4)-530)) 600 600];
      
      h_dlg = figure('Visible','off', ...
         'Color',[0.95 0.95 0.95], ...
         'KeyPressFcn','figure(gcf)', ...
         'MenuBar','none', ...
         'Name','Calculate Missing Values', ...
         'NumberTitle','off', ...
         'Position',figpos, ...
         'Tag','dlgCalcMissing', ...
         'ToolBar','none', ...
         'Resize','off', ...
         'CloseRequestFcn','ui_calc_missing(''cancel'')', ...
         'DefaultuicontrolUnits','pixels');
      
      if mlversion >= 7
         set(h_dlg,'WindowStyle','normal')
         set(h_dlg,'DockControls','off')
      end
      
      uicontrol('Parent',h_dlg, ...
         'Style','frame', ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[0.95 0.95 0.95], ...
         'Position',[1 1 figpos(3) figpos(4)]);
      
      uicontrol('Parent',h_dlg, ...
         'Style','frame', ...
         'BackgroundColor',[.9 .9 .9], ...
         'ForegroundColor',[0 0 0], ...
         'Position',[5 44 590 235]);
      
      uicontrol('Parent',h_dlg, ...
         'Style','frame', ...
         'BackgroundColor',[.9 .9 .9], ...
         'ForegroundColor',[0 0 0], ...
         'Position',[5 283 590 312]);
      
      %create controls
      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.7], ...
         'ListboxTop',0, ...
         'Position',[10 570 265 18], ...
         'String','Available Columns', ...
         'Style','text', ...
         'Tag','lblAvailable');
      
      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.7], ...
         'ListboxTop',0, ...
         'Position',[325 570 265 18], ...
         'String','Selected Columns', ...
         'Style','text', ...
         'Tag','lblSelections');
      
      h_listAvailable = uicontrol('Parent',h_dlg, ...
         'Style','listbox', ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',10, ...
         'HorizontalAlignment','left', ...
         'Position',[15 290 265 275], ...
         'String',collist, ...
         'UserData',Icols, ...
         'Tag','listAvailable', ...
         'Value',1);
      
      h_listCalc = uicontrol('Parent',h_dlg, ...
         'Style','listbox', ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',10, ...
         'HorizontalAlignment','left', ...
         'Position',[322 290 265 275], ...
         'String',' ', ...
         'UserData',[], ...
         'Tag','listCalc', ...
         'Value',1);
      
      h_cmdAddVal = uicontrol('Parent',h_dlg, ...
         'Callback','ui_calc_missing(''val_add'')', ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'Position',[285 435 30 22], ...
         'String','>', ...
         'ToolTipString','Add selected column to the ''Selected Columns'' list', ...
         'Tag','cmdAddVal');
      
      h_cmdRemVal = uicontrol('Parent',h_dlg, ...
         'Enable','off', ...
         'Callback','ui_calc_missing(''val_rem'')', ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'Position',[285 405 30 22], ...
         'String','<', ...
         'ToolTipString','Remove selected column from the ''Selected Columns'' list', ...
         'Tag','cmdRemVal');
      
      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[.9 .9 .9], ...
         'Position',[20 248 120 18], ...
         'HorizontalAlignment','left', ...
         'String','Calculation:', ...
         'Tag','lblMethod');
      
      calcs = [{'<select a previously used calculation>'} ; prefs.calculations];
      
      h_popOldCalcs = uicontrol('Parent',h_dlg, ...
         'Style','popupmenu', ...
         'Position',[135 250 455 20], ...
         'BackgroundColor',[1 1 1], ...
         'String',calcs, ...
         'FontSize',9, ...
         'Value',1, ...
         'Callback','ui_calc_missing(''calcs'')', ...
         'Tag','popOldCalcs');
      
      h_editExpr = uicontrol('Parent',h_dlg, ...
         'Style','edit', ...
         'BackgroundColor',[1 1 1], ...
         'ForegroundColor',[0 0 0], ...
         'FontSize',10, ...
         'Position',[135 148 455 95], ...
         'Min',1, ...
         'Max',3, ...
         'HorizontalAlignment','left', ...
         'Callback','ui_calc_missing(''val_expr'')', ...
         'TooltipString','MATLAB expression to evaluate that returns a compatible array or scalar value', ...
         'Tag','editExpr');
      
      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'FontSize',9, ...
         'ForegroundColor',[0 0 0.7], ...
         'BackgroundColor',[.9 .9 .9], ...
         'Position',[150 125 435 18], ...
         'String','(MATLAB expression referencing data columns, operators and functions)', ...
         'HorizontalAlignment','left', ...
         'Tag','lblExprHelp');
      
      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[.9 .9 .9], ...
         'Position',[20 88 120 18], ...
         'String','Log Changes:', ...
         'HorizontalAlignment','left', ...
         'Tag','lblLogOption');
      
      h_editLogOption = uicontrol('Parent',h_dlg, ...
         'Style','edit', ...
         'BackgroundColor',[1 1 1], ...
         'ForegroundColor',[0 0 0], ...
         'FontSize',10, ...
         'Position',[135 88 50 22], ...
         'HorizontalAlignment','left', ...
         'String',int2str(prefs.log_option), ...
         'UserData',prefs.log_option, ...
         'Callback','ui_calc_missing(''val_integer'')', ...
         'TooltipString','Maximum number of individual value changes to log', ...
         'Tag','editLogOption');
      
      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'FontSize',9, ...
         'ForegroundColor',[0 0 0.7], ...
         'BackgroundColor',[.9 .9 .9], ...
         'Position',[190 90 150 18], ...
         'String','(0 for none, INF for all)', ...
         'HorizontalAlignment','left', ...
         'Tag','lblLogOptionHelp');
      
      h_chkSaveCalc = uicontrol('Parent',h_dlg, ...
         'Style','checkbox', ...
         'FontSize',10, ...
         'BackgroundColor',[.9 .9 .9], ...
         'Position',[360 90 220 20], ...
         'String','Save Calculation to History', ...
         'Value',prefs.save_calc, ...
         'HorizontalAlignment','left', ...
         'Tag','lblLogOption');
      
      uicontrol('parent',h_dlg, ...
         'Style','text', ...
         'Position',[20 57 120 18], ...
         'Fontweight','bold', ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[.9 .9 .9], ...
         'String','Q/C Flag to Assign:', ...
         'Tag','lblFlagCode');
      
      %call function to add standard Q/C flag picking controls and get ui handle
      ui_flagpicker('add',s,[135 58 380 25],h_dlg,'');
      h_popFlagChoice = findobj(h_dlg,'Tag','popFlagChoice');
      
      %check for default E flag and select or add to list if not present
      flagcodes = get(h_popFlagChoice,'UserData');
      Iflag = find(strcmp(flagcodes,prefs.flag_code));
      if ~isempty(Iflag)
         set(h_popFlagChoice,'Value',Iflag(1))  %use first matched C code
      else
         flagcodes = [flagcodes ; {prefs.flag_code}];
         defs = char(get(h_popFlagChoice,'String'),[prefs.flag_code,' -- ',prefs.flag_def]);
         set(h_popFlagChoice,'String',defs,'UserData',flagcodes,'Value',length(flagcodes))
      end
      
      h_cmdCancel = uicontrol('Parent',h_dlg, ...
         'Callback','ui_calc_missing(''cancel'')', ...
         'FontSize',9, ...
         'Position',[10 10 60 25], ...
         'String','Cancel', ...
         'TooltipString','Cancel the operation and close the dialog window', ...
         'Tag','cmdCancel');
      
      h_chkNewWindow = uicontrol('Parent',h_dlg, ...
         'Style','checkbox', ...
         'Position',[155 12 310 20], ...
         'BackgroundColor',[0.95 0.95 0.95], ...
         'FontSize',10, ...
         'String','Open updated structure in a new editor window', ...
         'Value',prefs.new_window, ...
         'Tag','chkNewWindow');
      
      h_cmdEval = uicontrol('Parent',h_dlg, ...
         'Callback','ui_calc_missing(''eval'')', ...
         'Enable','off', ...
         'FontSize',9, ...
         'ListboxTop',0, ...
         'Position',[530 10 60 25], ...
         'String','Proceed', ...
         'TooltipString','Evaluate calculation and fill missing values in selected columns', ...
         'Tag','cmdEval');
      
      uih = struct( ...
         'editExpr',h_editExpr, ...
         'popFlagChoice',h_popFlagChoice, ...
         'popOldCalcs',h_popOldCalcs, ...
         'listAvailable',h_listAvailable, ...
         'listCalc',h_listCalc, ...
         'editLogOption',h_editLogOption, ...
         'cmdAddVal',h_cmdAddVal, ...
         'cmdRemVal',h_cmdRemVal, ...
         'cmdEval',h_cmdEval, ...
         'cmdCancel',h_cmdCancel, ...
         'chkNewWindow',h_chkNewWindow, ...
         'chkSaveCalc',h_chkSaveCalc, ...
         'h_cb',h_cb, ...
         'cb',cb, ...
         's',s, ...
         'prefs',prefs);
      
      set(h_dlg,'Visible','on','UserData',uih)
      
      %update button states to reflect initial settings
      ui_calc_missing('buttons')
      drawnow
      
   end
   
else  %handle callbacks
   
   h_dlg = [];
   
   %get dialog handle
   if length(findobj) > 2
      h_dlg = gcf;
      if ~strcmp(get(h_dlg,'Tag'),'dlgCalcMissing')
         h_dlg = [];
      end
   end
   
   %check for valid dialog handle
   if ~isempty(h_dlg)
      
      uih = get(h_dlg,'UserData');
      
      switch op
         
         case 'cancel'  %close dialog
            
            delete(h_dlg)
            ui_aboutgce('reopen')  %check for last window
            
         case 'update'  %update uicontrol contents after selection operations
            
            s = uih.s;
            
            if isstruct(s)
               
               I_avail = get(uih.listAvailable,'UserData');
               I_calc = get(uih.listCalc,'UserData');
               
               vars = s.name;
               units = s.units;
               cols = length(s.name);
               varstr = cell(1,cols);
               
               for n = 1:cols
                  varstr{n} = [vars{n},'  (',units{n},')'];
               end
               
               if ~isempty(I_avail)
                  s_avail = varstr(I_avail);
               else
                  s_avail = {''};
               end
               
               if ~isempty(I_calc)
                  s_calc = varstr(I_calc);
               else
                  s_calc = {''};
               end
               
               set(uih.listAvailable, ...
                  'String',s_avail, ...
                  'Value',max(1,min(get(uih.listAvailable,'Value'),length(I_avail))))
               
               set(uih.listCalc, ...
                  'String',s_calc, ...
                  'Value',max(1,min(get(uih.listCalc,'Value'),length(I_calc))))
               
               if isempty(I_calc)
                  set(uih.cmdRemVal,'Enable','off')
               else
                  set(uih.cmdRemVal,'Enable','on')
               end
               
               ui_calc_missing('buttons')  %update button states
               
            end
            
         case 'buttons'  %set button states depending on uicontrol selections
            
            %get uicontrol handles
            I_avail = get(uih.listAvailable,'UserData');
            I_calc = get(uih.listCalc,'UserData');
            strExpr = trimstr(get(uih.editExpr,'String'));
            
            %toggle add/remove buttons according to list status
            if isempty(I_avail)
               set(uih.cmdAddVal,'Enable','off')
            else
               set(uih.cmdAddVal,'Enable','on')
            end
            
            %toggle proceed button according to list status
            if ~isempty(strExpr) && ~isempty(I_calc)
               set(uih.cmdEval,'Enable','on')
            else
               set(uih.cmdEval,'Enable','off')
            end
            
            drawnow
            
         case 'eval'  %evaluate input and perform calculations
            
            %look up column selections
            ycols = get(uih.listCalc,'UserData');
            
            %look up expression
            expr = get(uih.editExpr,'String');
            
            %get save calc option
            savecalc = get(uih.chkSaveCalc,'Value');
            
            %concatenate multiple lines
            if size(expr,1) > 1
               str = expr;
               expr = '';
               for n = 1:size(str,1)
                  expr = [expr,deblank(str(n,:)),' '];
               end
            end
            expr = deblank(expr);
            
            %get log option
            logopt = get(uih.editLogOption,'UserData');
            
            %get q/c flag option
            Iflag = get(uih.popFlagChoice,'Value');
            flagcodes = get(uih.popFlagChoice,'Userdata');
            flag = flagcodes{Iflag};
            if Iflag > 1
               flagdefs = cellstr(get(uih.popFlagChoice,'String'));
               flagdef = regexprep(flagdefs{Iflag},'\w -- ','');
            else
               flagdef = '';
            end
            
            if ~isempty(expr) && ~isempty(ycols)
               
               set(gcf,'Pointer','watch')
               drawnow
               
               %perform calculations
               [s2,msg] = calc_missing_vals(uih.s,ycols,expr,logopt,flag,flagdef);
               
               set(gcf,'Pointer','arrow')
               drawnow
               
               if ~isempty(s2)
                  
                  %get new window option
                  newwindow = get(uih.chkNewWindow,'Value');
                  
                  %close dialog
                  delete(h_dlg)
                  drawnow
                  
                  %check for existing preferences file
                  fn_prefs = which('ui_calc_missing.mat');
                  if isempty(fn_prefs)
                     %generate filename in userdata if not found
                     fn_prefs = [gce_homepath,filesep,'settings',filesep,'ui_calc_missing.mat'];
                  end
                  
                  %get prior preferences
                  prefs = uih.prefs;
                  
                  %update preferences
                  prefs.log_option = logopt;
                  prefs.flag_code = flag;
                  prefs.flag_def = flagdef;
                  prefs.new_window = newwindow;
                  prefs.save_calc = savecalc;
                  
                  %update calculations list
                  if savecalc == 1
                     calcs = unique([prefs.calculations ; {expr}]);
                     prefs.calculations = calcs;
                  end
                  
                  %save preferences
                  if exist(fn_prefs,'file') == 2
                     save(fn_prefs,'prefs','-append')
                  else
                     save(fn_prefs,'prefs')
                  end
                  
                  %check for error/warning message before returning data
                  if isempty(msg)
                     
                     %check for hooks to calling dialog
                     if newwindow == 1 || isempty(uih.h_cb) || isempty(uih.cb)
                        ui_editor('init',s2);  %send results to editor if new window specified or no callbacks
                        if ~isempty(msg)
                           messagebox('init',['Warning: ',msg],'','Warning',[.95 .95 .95]);
                        end
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
                              '','Error',[.95 .95 .95])
                        elseif ~isempty(msg)
                           messagebox('init',['Warning: ',msg],'','Warning',[.95 .95 .95]);
                        end
                     end
                     
                  else
                     %display status/warning message
                     messagebox('init',msg,'','Warning',[.9 .9 .9]);
                  end
                  
               else
                  messagebox('init',char('Could not perform the analysis with the selected options', ...
                     ['(error: ',msg,')']), ...
                     '','Error',[.9 .9 .9]);
               end
               
            else
               messagebox('init','Invalid column selections or expression - operation cancelled', ...
                  '','Error',[.9 .9 .9])
            end
            
         case 'copysel'  %copy selected entries between select lists
            
            %get handles
            h_source = get(uih.cmdAddVal,'UserData');
            h_target = get(uih.cmdRemVal,'UserData');
            h_list = uih.listAvailable;
            
            if ~isempty(h_source) && ~isempty(h_target)
               
               %get indices
               I_target = get(h_target,'UserData');
               I_source = get(h_source,'UserData');
               I_sel = I_source(get(h_source,'Value'));
               
               %update indices
               I_target = [I_target;I_sel];
               I_source = I_source(I_source~=I_sel);
               
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
                  set(h_target,'Value',length(I_target))
               end
               
               %update uicontrols
               ui_calc_missing('update');
               
            end
            
         case 'calcs'  %handle changes to prior calculation popup menu
            
            %get selection
            Isel = get(uih.popOldCalcs,'Value');
            
            %check for valid option
            if Isel > 1
               
               %get calculation from preferences structure
               calc = uih.prefs.calculations{Isel-1};
               
               %update calculation editbox
               set(uih.editExpr,'String',calc)
               
               %update button states
               ui_calc_missing('buttons')
               
            end
            
         case 'val_add'  %handle additions to select listbox
            
            %assign handles
            set(uih.cmdAddVal,'UserData',uih.listAvailable);  %source
            set(uih.cmdRemVal,'UserData',uih.listCalc);  %target
            
            %update listboxes
            ui_calc_missing('copysel')
            
         case 'val_rem'  %handle removal from select listbox
            
            %assign handles
            set(uih.cmdAddVal,'UserData',uih.listCalc);  %source
            set(uih.cmdRemVal,'UserData',uih.listAvailable);  %target
            
            %update listboxes
            ui_calc_missing('copysel')
            
         case 'val_expr'  %validate expression entries
            
            h_cb = gcbo;  %get handle of control
            
            str = trimstr(get(h_cb,'String'));
            
            set(h_cb,'String',str)  %update trimmed string
            
            ui_calc_missing('buttons')
            
         case 'val_integer'  %validate integer entries
            
            h_cb = gcbo;  %get handle of control
            
            str = trimstr(get(h_cb,'String'));
            lastval = num2str(get(h_cb,'UserData'));
            
            if ~isempty(str)
               val = round(str2double(str));
            else
               val = NaN;
            end
            
            if ~isnan(val)
               set(h_cb,'String',str,'UserData',val)  %update trimmed string and stored number
            else
               set(h_cb,'String',lastval)  %reset string
               messagebox('init','Entry must be a valid integer - change cancelled',[],'Error',[.95 .95 .95]);
            end
            
      end
      
   end
   
end
