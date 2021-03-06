function ui_interp_missing(op,s,h_cb,cb)
%GCE Data Toolbox dialog for filling in gaps in a data set using one-dimensional interpolation
%using the function 'interp_missing'
%
%syntax:  ui_interp_missing(op,s)
%
%input:
%  op = operation (default = 'init' to initialize dialog)
%  s = data structure
%
%output:
%  none
%
%
%(c)2010-2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 24-Jun-2013

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

   if length(findobj) > 1
      h_dlg = findobj('Tag','dlgInterpMissing');
   else
      h_dlg = [];
   end

   if ~isempty(h_dlg)  %set focus to existing dialog

      figure(h_dlg)
      drawnow

   else  %create new dialog

      if gce_valid(s,'data')

         if exist('h_cb','var') ~= 1
            h_cb = [];
         end

         if exist('cb','var') ~= 1
            cb = '';
         end

         %check for valid x column
         I_validxcol = find(strcmp(s.datatype,'f') | strcmp(s.datatype,'e'));

         if ~isempty(I_validxcol)

            %generate x column list array
            xcollist = concatcellcols([s.name(I_validxcol)',repmat({'  ('},length(I_validxcol),1), ...
                  s.units(I_validxcol)',repmat({')'},length(I_validxcol),1)]);

            %generate general column list array
            collist = concatcellcols([s.name',repmat({'  ('},length(s.name),1), ...
                  s.units',repmat({')'},length(s.name),1)]);
               
            %get cached preferences
            prefs = [];
            if exist('ui_interp_missing.mat','file') == 2
               try
                  v = load('ui_interp_missing.mat','-mat');
               catch
                  v = struct('null','');
               end
               if isfield(v,'prefs')
                  prefs = v.prefs;
               end
            end
            
            %define default settings if omitted
            if isempty(prefs)
               prefs = struct( ...
                  'method','pchip', ...
                  'maxgap',10, ...
                  'log',50, ...
                  'flag','E' ...
                  );
            end

            %init screen info arrays
            res = get(0,'ScreenSize');
            bgcolor = [.95 .95 .95];
            figpos = [max(1,0.5.*(res(3)-560)) max(50,0.5.*(res(4)-560)) 560 560];

            h_dlg = figure('Visible','off', ...
               'Color',bgcolor, ...
               'KeyPressFcn','figure(gcf)', ...
               'MenuBar','none', ...
               'Name','Interpolate Missing Values', ...
               'NumberTitle','off', ...
               'Position',figpos, ...
               'Tag','dlgInterpMissing', ...
               'ToolBar','none', ...
               'Resize','off', ...
               'CloseRequestFcn','ui_interp_missing(''cancel'')', ...
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
               'Position',[4 533 245 18], ...
               'String','Available Columns', ...
               'Style','text', ...
               'Tag','lblAvailable');

            uicontrol('Parent',h_dlg, ...
               'BackgroundColor',bgcolor, ...
               'FontSize',10, ...
               'FontWeight','bold', ...
               'ForegroundColor',[0 0 0.7], ...
               'ListboxTop',0, ...
               'Position',[280 533 260 18], ...
               'String','Column Selections', ...
               'Style','text', ...
               'Tag','lblSelections');

            uicontrol('Parent',h_dlg, ...
               'Style','frame', ...
               'BackgroundColor',[.9 .9 .9], ...
               'ForegroundColor',[0 0 0], ...
               'Position',[270 450 285 80]);

            uicontrol('Parent',h_dlg, ...
               'Style','frame', ...
               'BackgroundColor',[.9 .9 .9], ...
               'ForegroundColor',[0 0 0], ...
               'Position',[270 305 285 135]);

            uicontrol('Parent',h_dlg, ...
               'Style','frame', ...
               'BackgroundColor',[.9 .9 .9], ...
               'ForegroundColor',[0 0 0], ...
               'Position',[270 160 285 135]);

            uicontrol('Parent',h_dlg, ...
               'Style','frame', ...
               'BackgroundColor',[.9 .9 .9], ...
               'ForegroundColor',[0 0 0], ...
               'Position',[5 44 550 110]);

            uicontrol('Parent',h_dlg, ...
               'BackgroundColor',[.9 .9 .9], ...
               'FontSize',10, ...
               'FontWeight','bold', ...
               'ForegroundColor',[0 0 0], ...
               'Position',[280 494 260 18], ...
               'HorizontalAlignment','left', ...
               'String','X Column for Interpolation:', ...
               'Style','text', ...
               'Tag','lblXCol');

            h_popXCol = uicontrol('Parent',h_dlg, ...
               'Style','popupmenu', ...
               'BackgroundColor',[1 1 1], ...
               'ForegroundColor',[0 0 0], ...
               'FontSize',9, ...
               'Position',[320 470 225 18], ...
               'String',char([{'<select a column>'} ; xcollist]), ...
               'Value',1, ...
               'Callback','ui_interp_missing(''xcol'')', ...
               'Tag','popXCol', ...
               'UserData',0);

            uicontrol('Parent',h_dlg, ...
               'Style','text', ...
               'BackgroundColor',[.9 .9 .9], ...
               'FontSize',10, ...
               'FontWeight','bold', ...
               'ForegroundColor',[0 0 0], ...
               'ListboxTop',0, ...
               'Position',[320 415 215 18], ...
               'String','Group By (optional)', ...
               'Tag','lblGroup');

            uicontrol('Parent',h_dlg, ...
               'Style','text', ...
               'BackgroundColor',[.9 .9 .9], ...
               'FontSize',10, ...
               'FontWeight','bold', ...
               'ForegroundColor',[0 0 0], ...
               'ListboxTop',0, ...
               'Position',[320 270 215 18], ...
               'String','Interpolate', ...
               'Tag','lblInterp');

            h_listAvailable = uicontrol('Parent',h_dlg, ...
               'Style','listbox', ...
               'BackgroundColor',[1 1 1], ...
               'FontSize',10, ...
               'HorizontalAlignment','left', ...
               'Position',[6 160 255 370], ...
               'String',char(collist), ...
               'UserData',(1:length(s.name)), ...
               'Tag','listAvailable', ...
               'Value',1);

            h_listGroup = uicontrol('Parent',h_dlg, ...
               'Style','listbox', ...
               'BackgroundColor',[1 1 1], ...
               'FontSize',10, ...
               'HorizontalAlignment','left', ...
               'Position',[320 315 225 100], ...3
               'String',' ', ...
               'UserData',[], ...
               'Tag','listGroup', ...
               'Value',1);

            h_listInterp = uicontrol('Parent',h_dlg, ...
               'Style','listbox', ...
               'BackgroundColor',[1 1 1], ...
               'FontSize',10, ...
               'HorizontalAlignment','left', ...
               'Position',[320 170 225 100], ...
               'String',' ', ...
               'UserData',[], ...
               'Tag','listInterp', ...
               'Value',1);

            h_cmdAddGroup = uicontrol('Parent',h_dlg, ...
               'Callback','ui_interp_missing(''group_add'')', ...
               'FontSize',10, ...
               'FontWeight','bold', ...
               'Position',[279 370 30 22], ...
               'String','>', ...
               'ToolTipString','Add selected column to the ''Group By'' list', ...
               'Tag','cmdAddGroup');

            h_cmdRemGroup = uicontrol('Parent',h_dlg, ...
               'Enable','off', ...
               'Callback','ui_interp_missing(''group_rem'')', ...
               'FontSize',10, ...
               'FontWeight','bold', ...
               'Position',[279 340 30 22], ...
               'String','<', ...
               'ToolTipString','Remove selected column from the ''Group By'' list', ...
               'Tag','cmdRemGroup');

            h_cmdAddVal = uicontrol('Parent',h_dlg, ...
               'Callback','ui_interp_missing(''val_add'')', ...
               'FontSize',10, ...
               'FontWeight','bold', ...
               'Position',[279 225 30 22], ...
               'String','>', ...
               'ToolTipString','Add selected column to the ''Interpolate'' list', ...
               'Tag','cmdAddVal');

            h_cmdRemVal = uicontrol('Parent',h_dlg, ...
               'Enable','off', ...
               'Callback','ui_interp_missing(''val_rem'')', ...
               'FontSize',10, ...
               'FontWeight','bold', ...
               'ListboxTop',0, ...
               'Position',[279 195 30 22], ...
               'String','<', ...
               'ToolTipString','Remove selected column from the ''Interpolate'' list', ...
               'Tag','cmdRemVal');
            
            %add radio buttons for selecting interpolation values
            uicontrol('Parent',h_dlg, ...
               'Style','text', ...
               'FontSize',10, ...
               'FontWeight','bold', ...
               'ForegroundColor',[0 0 0], ...
               'BackgroundColor',[.9 .9 .9], ...
               'Position',[15 125 150 18], ...
               'HorizontalAlignment','left', ...
               'String','Interpolation Values:', ...
               'Tag','lblValues');
            
            h_radioAll = uicontrol('Parent',h_dlg, ...
               'Style','radio', ...
               'Position',[170 125 150 18], ...
               'FontSize',10, ...
               'ForegroundColor',[0 0 0], ...
               'BackgroundColor',[.9 .9 .9], ...
               'HorizontalAlignment','left', ...
               'Value',1, ...
               'String','All non-missing values', ...
               'Tag','radioAll', ...
               'TooltipString','Use all non-missing values for each variable for performing the interpolation', ...
               'Callback','ui_interp_missing(''radiobutton'')');
            
            h_radioDay = uicontrol('Parent',h_dlg, ...
               'Style','radio', ...
               'Position',[330 125 200 18], ...
               'FontSize',10, ...
               'ForegroundColor',[0 0 0], ...
               'BackgroundColor',[.9 .9 .9], ...
               'HorizontalAlignment','left', ...
               'Value',0, ...
               'String','Same time of day (time series)', ...
               'Tag','radioDay', ...
               'TooltipString','Only use values for each variable recorded at the same time of day for interpolating a time series (assumes X = Date)', ...
               'Callback','ui_interp_missing(''radiobutton'')');
            
            uicontrol('Parent',h_dlg, ...
               'Style','text', ...
               'FontSize',10, ...
               'FontWeight','bold', ...
               'ForegroundColor',[0 0 0], ...
               'BackgroundColor',[.9 .9 .9], ...
               'Position',[15 95 150 18], ...
               'HorizontalAlignment','left', ...
               'String','Interpolation Method:', ...
               'Tag','lblMethod');
            
            %define methods
            methods = {'nearest','Nearest neighbor'; ...
               'linear','Linear interpolation'; ...
               'spline','Piecewise cubic spline'; ...
               'pchip','Shape-preserving cubic'};
            
            %look up method in preferences
            methodval = find(strcmp(prefs.method,methods(:,1)));
            if isempty(methodval)
               methodval = 4;
            end
            
            h_popMethod = uicontrol('Parent',h_dlg, ...
               'Style','popupmenu', ...
               'BackgroundColor',[1 1 1], ...
               'ForegroundColor',[0 0 0], ...
               'FontSize',9, ...
               'Position',[165 97 200 18], ...
               'String',methods(:,2), ...
               'Value',methodval, ...
               'Tag','popMethod', ...
               'UserData',methods(:,1));
            
            uicontrol('Parent',h_dlg, ...
               'Style','text', ...
               'FontSize',10, ...
               'FontWeight','bold', ...
               'ForegroundColor',[0 0 0], ...
               'BackgroundColor',[.9 .9 .9], ...
               'Position',[400 95 110 18], ...
               'String','Maximum Gap:', ...
               'Tag','lblMaxGap');
            
            h_editMaxPoints = uicontrol('Parent',h_dlg, ...
               'Style','edit', ...
               'BackgroundColor',[1 1 1], ...
               'ForegroundColor',[0 0 0], ...
               'FontSize',10, ...
               'Position',[510 95 40 18], ...
               'String',int2str(prefs.maxgap), ...
               'UserData',prefs.maxgap, ...
               'Callback','ui_interp_missing(''val_integer'')', ...
               'TooltipString','Maximum number of continous records to interpolate', ...
               'Tag','editMaxPoints');

            uicontrol('parent',h_dlg, ...
               'Style','text', ...
               'Position',[15 57 120 18], ...
               'Fontweight','bold', ...
               'FontSize',9, ...
               'HorizontalAlignment','left', ...
               'ForegroundColor',[0 0 0], ...
               'BackgroundColor',[.9 .9 .9], ...
               'String','Q/C Flag to Assign:', ...
               'Tag','lblFlagCode');
            
            %call function to add standard Q/C flag picking controls and get ui handle
            ui_flagpicker('add',s,[135 55],h_dlg,'');
            h_popFlagChoice = findobj(h_dlg,'Tag','popFlagChoice');
            
            %check for default E flag and select or add to list if not present
            flagcodes = get(h_popFlagChoice,'UserData');
            Iflag = find(strcmp(prefs.flag,flagcodes));
            if ~isempty(Iflag)
               set(h_popFlagChoice,'Value',Iflag(1))  %use first matched E code
            else
               flagcodes = [flagcodes ; {'E'}];
               defs = char(get(h_popFlagChoice,'String'),'E -- data value estimated by interpolation');
               set(h_popFlagChoice,'String',defs,'UserData',flagcodes,'Value',length(flagcodes))
            end
            
            uicontrol('Parent',h_dlg, ...
               'Style','text', ...
               'FontSize',10, ...
               'FontWeight','bold', ...
               'ForegroundColor',[0 0 0], ...
               'BackgroundColor',[.9 .9 .9], ...
               'Position',[410 57 100 18], ...
               'String','Log Changes:', ...
               'Tag','lblLogOption');
            
            h_editLogOption = uicontrol('Parent',h_dlg, ...
               'Style','edit', ...
               'BackgroundColor',[1 1 1], ...
               'ForegroundColor',[0 0 0], ...
               'FontSize',10, ...
               'Position',[510 57 40 18], ...
               'String',int2str(prefs.log), ...
               'UserData',prefs.log, ...
               'Callback','ui_interp_missing(''val_integer'')', ...
               'TooltipString','Maximum number of individual value changes to log', ...
               'Tag','editLogOption');

            h_cmdCancel = uicontrol('Parent',h_dlg, ...
               'Callback','ui_interp_missing(''cancel'')', ...
               'FontSize',9, ...
               'Position',[15 10 60 25], ...
               'String','Cancel', ...
               'TooltipString','Cancel the operation and close the dialog window', ...
               'Tag','cmdCancel');

            h_chkNewWindow = uicontrol('Parent',h_dlg, ...
               'Style','checkbox', ...
               'Position',[135 12 310 20], ...
               'BackgroundColor',bgcolor, ...
               'FontSize',10, ...
               'String','Open updated structure in a new editor window', ...
               'Value',0, ...
               'Tag','chkNewWindow');

            h_cmdEval = uicontrol('Parent',h_dlg, ...
               'Callback','ui_interp_missing(''eval'')', ...
               'Enable','off', ...
               'FontSize',9, ...
               'ListboxTop',0, ...
               'Position',[490 10 60 25], ...
               'String','Proceed', ...
               'TooltipString','Split the data series and open the structure for editing', ...
               'Tag','cmdEval');

            uih = struct( ...
               'popXCol',h_popXCol, ...
               'popMethod',h_popMethod, ...
               'popFlagChoice',h_popFlagChoice, ...
               'radioAll',h_radioAll, ...
               'radioDay',h_radioDay, ...
               'listAvailable',h_listAvailable, ...
               'listGroup',h_listGroup, ...
               'listInterp',h_listInterp, ...
               'editMaxPoints',h_editMaxPoints, ...
               'editLogOption',h_editLogOption, ...
               'cmdAddGroup',h_cmdAddGroup, ...
               'cmdRemGroup',h_cmdRemGroup, ...
               'cmdAddVal',h_cmdAddVal, ...
               'cmdRemVal',h_cmdRemVal, ...
               'cmdEval',h_cmdEval, ...
               'cmdCancel',h_cmdCancel, ...
               'chkNewWindow',h_chkNewWindow, ...
               'h_cb',h_cb, ...
               'cb',cb, ...
               's',s, ...
               'I_validxcol',I_validxcol);

            set(h_dlg,'Visible','on','UserData',uih)
            drawnow

         else
            msgbox('init','This feature requires a data structure with a floating-point or exponential column for interpolation','','Error',[.9 .9 .9])
         end

      end

   end

else  %handle callbacks

   h_dlg = [];

   if length(findobj) > 2
      h_dlg = gcf;
      if ~strcmp(get(h_dlg,'Tag'),'dlgInterpMissing')
         h_dlg = [];
      end
   end

   if ~isempty(h_dlg)

      uih = get(h_dlg,'UserData');

      switch op

         case 'cancel'  %close dialog

            delete(h_dlg)
            ui_aboutgce('reopen')  %check for last window

         case 'update'

            s = uih.s;

            if isstruct(s)

               xcol = get(uih.popXCol,'Value') - 1;
               I_avail = get(uih.listAvailable,'UserData');
               I_group = get(uih.listGroup,'UserData');
               I_interp = get(uih.listInterp,'UserData');

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

               if ~isempty(I_group)
                  s_group = varstr(I_group);
               else
                  s_group = {''};
               end

               if ~isempty(I_interp)
                  s_interp = varstr(I_interp);
               else
                  s_interp = {''};
               end

               set(uih.listAvailable, ...
                  'String',s_avail, ...
                  'Value',max(1,min(get(uih.listAvailable,'Value'),length(I_avail))))

               set(uih.listGroup, ...
                  'String',s_group, ...
                  'Value',max(1,min(get(uih.listGroup,'Value'),length(I_group))))

               set(uih.listInterp, ...
                  'String',s_interp, ...
                  'Value',max(1,min(get(uih.listInterp,'Value'),length(I_interp))))

               %toggle add/remove buttons according to list status
               if isempty(I_avail)
                  set(uih.cmdAddGroup,'Enable','off')
                  set(uih.cmdAddVal,'Enable','off')
               else
                  set(uih.cmdAddGroup,'Enable','on')
                  set(uih.cmdAddVal,'Enable','on')
               end

               %set remove group button and day values options accordingly based on group selection
               diurnalerr = 0;
               if isempty(I_group)
                  set(uih.cmdRemGroup,'Enable','off')
                  set(uih.radioDay,'Enable','on')
               else
                  set(uih.cmdRemGroup,'Enable','on')
                  set(uih.radioAll,'Value',1)
                  radioday = get(uih.radioDay,'Value');
                  if radioday == 1
                     diurnalerr = 1;  %set flag for warning user about diurnal setting override
                  end
                  set(uih.radioDay,'Value',0,'Enable','off')  %disable day option - not supported for grouped data                  
               end

               if isempty(I_interp)
                  set(uih.cmdRemVal,'Enable','off')
               else
                  set(uih.cmdRemVal,'Enable','on')
               end

               xcolerr = 0;
               I_validxcol = uih.I_validxcol;
               if xcol > 0
                  if isempty(find(I_avail==I_validxcol(xcol)))
                     xcol = 0;
                     xcolerr = 1;
                     set(uih.popXCol,'Value',1)
                  end
               end

               %toggle proceed button according to list status
               if xcol > 0 && ~isempty(I_interp)
                  set(uih.cmdEval,'Enable','on')
               else
                  set(uih.cmdEval,'Enable','off')
               end

               drawnow

               if xcolerr == 1
                  messagebox('init','Split column selection is no longer valid - menu reset', ...
                     '','Error',[.9 .9 .9])
               elseif diurnalerr == 1
                  messagebox('init','Grouping data is not supported for Interpolation Value = ''Same time of day'' - option reset', ...
                     '','Error',[.9 .9 .9])
               end

            end

         case 'eval'

            %determine x column
            xcolsel = get(uih.popXCol,'Value') - 1;
            I_validxcol = uih.I_validxcol;
            xcol = I_validxcol(xcolsel);
            
            %look up group and interpolation selections
            gpcols = get(uih.listGroup,'UserData');
            ycols = get(uih.listInterp,'UserData');

            %get interpolation values selection
            if get(uih.radioDay,'Value') == 1
               diurnal = 1;
            else
               diurnal = 0;
            end
            
            %get method selection
            I_method = get(uih.popMethod,'Value');
            methods = get(uih.popMethod,'UserData');
            method = char(methods(I_method));
            
            %get max points, log option
            maxpts = get(uih.editMaxPoints,'UserData');
            logopt = get(uih.editLogOption,'UserData');

            %get q/c flag option
            Iflag = get(uih.popFlagChoice,'Value');
            flagcodes = get(uih.popFlagChoice,'Userdata');
            flag = flagcodes{Iflag};
            flagmeta = '';
            
            %generate updated flag metadata in case user has updated the definitions in the dialog
            if ~isempty(flag)
               defs = cellstr(get(uih.popFlagChoice,'String'));  %convert list to cell array
               flagdefs = cell2commas(strrep(defs(2:end),'--','='));  %generate flag def metadata, skipping no flag option
               if ~isempty(flagdefs)
                  flagmeta = [{'Data'},{'Codes'},{flagdefs}];  %format flag codes as metadata field for dialog
               end
            end
                 
            if xcol > 0 && ~isempty(ycols)

               set(gcf,'Pointer','watch')
               drawnow

               s2 = uih.s;  %get cached structure
               
               %update flag definitions in metadata in case new code added
               if ~isempty(flag) && ~isempty(flagmeta)
                  s2 = addmeta(s2,flagmeta,0,'ui_interp_missing');
               end
               
               %perform interpolations               
               if isempty(gpcols)
                  if diurnal == 1
                     %use diurnal interpolation
                     [s2,msg] = interp_missing_diurnal(s2,xcol,ycols,xcol,method,maxpts,logopt,flag);
                  else
                     %use all-values interpolation
                     [s2,msg] = interp_missing(s2,xcol,ycols,method,maxpts,logopt,flag);
                  end
               else
                  %use grouped interpolation
                  [s2,msg] = interp_missing2(s2,xcol,ycols,gpcols,method,maxpts,logopt,flag);
               end
               
               set(gcf,'Pointer','arrow')
               drawnow

               if ~isempty(s2)

                  %update preferences
                  prefs = struct( ...
                     'method',method, ...
                     'maxgap',maxpts, ...
                     'log',logopt, ...
                     'flag',flag ...
                     );
                  
                  %save preferences
                  fn = which('ui_interp_missing.mat');
                  if isempty(fn)
                     fn = [gce_homepath,filesep,'settings',filesep,'ui_interp_missing.mat'];
                  end
                  save(fn,'prefs')
                  
                  %get new window option
                  newwindow = get(uih.chkNewWindow,'Value');

                  delete(h_dlg)
                  drawnow

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

                  messagebox('init',char('Could not perform the analysis with the selected options', ...
                     ['(error: ',msg,')']), ...
                     '','Error',[.9 .9 .9]);

               end

            else

               messagebox('init','Split column selection invalid - operation cancelled', ...
                  '','Error',[.9 .9 .9])

            end

         case 'copysel'

            %get handles
            h_source = get(uih.cmdAddGroup,'UserData');
            h_target = get(uih.cmdRemGroup,'UserData');
            h_list = uih.listAvailable;

            if ~isempty(h_source) && ~isempty(h_target)

               %get indices
               I_target = get(h_target,'UserData');
               I_source = get(h_source,'UserData');
               I_sel = I_source(get(h_source,'Value'));

               %update indices
               I_target = [I_target,I_sel];
               I_source = I_source(I_source~=I_sel);

               %store indices
               set(h_target,'UserData',I_target)
               set(h_source,'UserData',I_source)

               %resort master list if adding rows back to list
               if h_target == h_list
                  Ilist = get(h_list,'UserData');
                  [Ilist,I] = sort(Ilist);
                  Isel = find(Ilist==I_target(end));
                  set(h_list,'UserData',sort(Ilist),'Value',Isel)
               else
                  set(h_target,'Value',length(I_target))
               end

               %update uicontrols
               ui_interp_missing('update');

            end

         case 'group_add'

            %assign handles
            set(uih.cmdAddGroup,'UserData',uih.listAvailable);  %source
            set(uih.cmdRemGroup,'UserData',uih.listGroup);  %target

            %update listboxes
            ui_interp_missing('copysel')

         case 'group_rem'

            %assign handles
            set(uih.cmdAddGroup,'UserData',uih.listGroup);  %source
            set(uih.cmdRemGroup,'UserData',uih.listAvailable);  %target

            %update listboxes
            ui_interp_missing('copysel')

         case 'val_add'

            %assign handles
            set(uih.cmdAddGroup,'UserData',uih.listAvailable);  %source
            set(uih.cmdRemGroup,'UserData',uih.listInterp);  %target

            %update listboxes
            ui_interp_missing('copysel')

         case 'val_rem'

            %assign handles
            set(uih.cmdAddGroup,'UserData',uih.listInterp);  %source
            set(uih.cmdRemGroup,'UserData',uih.listAvailable);  %target

            %update listboxes
            ui_interp_missing('copysel')
            
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
            
         case 'radiobutton'  %handle interpolation value radio button clicks
            
            if gcbo == uih.radioAll
               set(uih.radioAll,'Value',1)
               set(uih.radioDay,'Value',0)
            else
               set(uih.radioAll,'Value',0)
               set(uih.radioDay,'Value',1)
            end
            drawnow

         case 'xcol'

            xcol = get(uih.popXCol,'Value') - 1;
            get(uih.popXCol,'UserData');

            %check for value change
            if xcol ~= get(uih.popXCol,'UserData')

               %check for valid selection
               if xcol > 0

                  Iavail = get(uih.listAvailable,'UserData');
                  I_validxcol = uih.I_validxcol;

                  err = 0;
                  if ~isempty(Iavail)
                     if isempty(find(Iavail==I_validxcol(xcol)))
                        err = 1;
                     end
                  else
                     err = 1;
                  end

                  if err == 1
                     set(uih.popXCol,'Value',get(uih.popXCol,'UserData')+1)
                     messagebox('init','X column already selected for group or output - selection reset', ...
                        '','Error',[.9 .9 .9])
                  else
                     set(uih.popXCol,'UserData',xcol)  %update cached value
                  end

               else
                  set(uih.popXCol,'UserData',0)
               end

            end

            ui_interp_missing('update')  %refresh controls, toggle command button states

      end

   end

end
