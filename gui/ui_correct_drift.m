function ui_correct_drift(op,s,h_cb,cb)
%GCE Data Toolbox dialog for correcting data set columns for sensor drift using 'correct_drift.m'
%
%syntax:  ui_correct_drift(op,s)
%
%input:
%  op = operation (default = 'init' to initialize dialog)
%  s = data structure
%
%output:
%  none
%
%
%(c)2011-2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 18-Apr-2014

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

   %check for prior instance of dialog
   if length(findobj) > 1
      h_dlg = findobj('Tag','dlgCorrectDrift');
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

         %check for valid datecol column
         I_validdatecol = find(strcmp(s.variabletype,'datetime')' & inlist(s.datatype,{'f','s'}));

         if ~isempty(I_validdatecol)

            %generate date column list array
            datecollist = concatcellcols([s.name(I_validdatecol)',repmat({'  ('},length(I_validdatecol),1), ...
                  s.units(I_validdatecol)',repmat({')'},length(I_validdatecol),1)]);
               
            %generate default datecol selection if there is 1 valid column starting with 'date'
            I_dateval = find(strncmpi(s.name(I_validdatecol),'date',4));
            if length(I_dateval) == 1
               dateval = I_dateval + 1;
            else
               dateval = 1;
            end

            %generate general column list array
            Idatacols = find(inlist(s.variabletype,{'data','calculation'}) & ~strcmp(s.datatype,'s')');
            collist = concatcellcols([s.name(Idatacols)',repmat({'  ('},length(Idatacols),1), ...
                  s.units(Idatacols)',repmat({')'},length(Idatacols),1)]);

            %init screen info arrays
            res = get(0,'ScreenSize');
            bgcolor = [.95 .95 .95];
            figpos = [max(1,0.5.*(res(3)-530)) max(50,0.5.*(res(4)-530)) 560 530];

            h_dlg = figure('Visible','off', ...
               'Color',bgcolor, ...
               'KeyPressFcn','figure(gcf)', ...
               'MenuBar','none', ...
               'Name','Correct Drift', ...
               'NumberTitle','off', ...
               'Position',figpos, ...
               'Tag','dlgCorrectDrift', ...
               'ToolBar','none', ...
               'Resize','off', ...
               'CloseRequestFcn','ui_correct_drift(''cancel'')', ...
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
               'Position',[4 503 245 18], ...
               'String','Available Columns', ...
               'Style','text', ...
               'Tag','lblAvailable');

            uicontrol('Parent',h_dlg, ...
               'BackgroundColor',bgcolor, ...
               'FontSize',10, ...
               'FontWeight','bold', ...
               'ForegroundColor',[0 0 0.7], ...
               'ListboxTop',0, ...
               'Position',[280 503 260 18], ...
               'String','Column Selections', ...
               'Style','text', ...
               'Tag','lblSelections');

            uicontrol('Parent',h_dlg, ...
               'Style','frame', ...
               'BackgroundColor',[.9 .9 .9], ...
               'ForegroundColor',[0 0 0], ...
               'Position',[270 420 285 80]);

            uicontrol('Parent',h_dlg, ...
               'Style','frame', ...
               'BackgroundColor',[.9 .9 .9], ...
               'ForegroundColor',[0 0 0], ...
               'Position',[270 215 285 195]);

            uicontrol('Parent',h_dlg, ...
               'Style','frame', ...
               'BackgroundColor',[.9 .9 .9], ...
               'ForegroundColor',[0 0 0], ...
               'Position',[6 44 549 165]);

            uicontrol('Parent',h_dlg, ...
               'BackgroundColor',[.9 .9 .9], ...
               'FontSize',10, ...
               'FontWeight','bold', ...
               'ForegroundColor',[0 0 0], ...
               'Position',[280 464 260 18], ...
               'HorizontalAlignment','left', ...
               'String','Date Column:', ...
               'Style','text', ...
               'Tag','lblDateCol');

            h_popDateCol = uicontrol('Parent',h_dlg, ...
               'Style','popupmenu', ...
               'BackgroundColor',[1 1 1], ...
               'ForegroundColor',[0 0 0], ...
               'FontSize',9, ...
               'Position',[320 440 225 18], ...
               'String',char([{'<select a column>'} ; datecollist]), ...
               'Value',dateval, ...
               'Callback','ui_correct_drift(''buttons'')', ...
               'Tag','popDateCol', ...
               'UserData',0);

            uicontrol('Parent',h_dlg, ...
               'Style','text', ...
               'BackgroundColor',[.9 .9 .9], ...
               'FontSize',10, ...
               'FontWeight','bold', ...
               'ForegroundColor',[0 0 0], ...
               'ListboxTop',0, ...
               'Position',[320 385 215 18], ...
               'String','Columns to Correct', ...
               'Tag','lblCorrect');

            h_listAvailable = uicontrol('Parent',h_dlg, ...
               'Style','listbox', ...
               'BackgroundColor',[1 1 1], ...
               'FontSize',10, ...
               'HorizontalAlignment','left', ...
               'Position',[7 215 255 285], ...
               'String',char(collist), ...
               'UserData',Idatacols, ...
               'Tag','listAvailable', ...
               'Callback','ui_correct_drift(''listclick'')', ...
               'Value',1);

            h_listCorrect = uicontrol('Parent',h_dlg, ...
               'Style','listbox', ...
               'BackgroundColor',[1 1 1], ...
               'FontSize',10, ...
               'HorizontalAlignment','left', ...
               'Position',[320 225 225 160], ...
               'String',' ', ...
               'UserData',[], ...
               'Callback','ui_correct_drift(''listclick'')', ...
               'Tag','listCorrect', ...
               'Value',1);

            h_cmdAddVal = uicontrol('Parent',h_dlg, ...
               'Callback','ui_correct_drift(''val_add'')', ...
               'FontSize',10, ...
               'FontWeight','bold', ...
               'Position',[279 315 30 22], ...
               'String','>', ...
               'ToolTipString','Add selected column to the ''Correct'' list', ...
               'Tag','cmdAddVal');

            h_cmdRemVal = uicontrol('Parent',h_dlg, ...
               'Enable','off', ...
               'Callback','ui_correct_drift(''val_rem'')', ...
               'FontSize',10, ...
               'FontWeight','bold', ...
               'Position',[279 285 30 22], ...
               'String','<', ...
               'ToolTipString','Remove selected column from the ''Correct'' list', ...
               'Tag','cmdRemVal');
            
            uicontrol('Parent',h_dlg, ...
               'Style','text', ...
               'FontSize',10, ...
               'FontWeight','bold', ...
               'ForegroundColor',[0 0 0], ...
               'BackgroundColor',[.9 .9 .9], ...
               'Position',[15 175 150 18], ...
               'HorizontalAlignment','left', ...
               'String','Correction Method:', ...
               'Tag','lblMethod');
            
            methods = {'constant','Constant offset'; ...
               'linear','Linearly-varying offset'; ...
               'custom','Custom-weighted offset'};
            
            h_popMethod = uicontrol('Parent',h_dlg, ...
               'Style','popupmenu', ...
               'BackgroundColor',[1 1 1], ...
               'ForegroundColor',[0 0 0], ...
               'FontSize',9, ...
               'Position',[155 177 200 18], ...
               'String',methods(:,2), ...
               'Value',1, ...
               'Callback','ui_correct_drift(''val_offset'')', ...
               'Tag','popMethod', ...
               'UserData',methods(:,1));
            
            uicontrol('Parent',h_dlg, ...
               'Style','text', ...
               'FontSize',10, ...
               'FontWeight','bold', ...
               'ForegroundColor',[0 0 0], ...
               'BackgroundColor',[.9 .9 .9], ...
               'Position',[380 175 100 18], ...
               'String','Log Changes:', ...
               'Tag','lblLogOption');
            
            h_editLogOption = uicontrol('Parent',h_dlg, ...
               'Style','edit', ...
               'BackgroundColor',[1 1 1], ...
               'ForegroundColor',[0 0 0], ...
               'FontSize',10, ...
               'Position',[480 173 40 22], ...
               'String','50', ...
               'UserData',50, ...
               'Callback','ui_correct_drift(''val_integer'')', ...
               'TooltipString','Maximum number of individual value changes to log', ...
               'Tag','editLogOption');

            h_lblOffset = uicontrol('Parent',h_dlg, ...
               'Style','text', ...
               'FontSize',10, ...
               'FontWeight','bold', ...
               'ForegroundColor',[0 0 0], ...
               'BackgroundColor',[.9 .9 .9], ...
               'Position',[20 135 130 18], ...
               'HorizontalAlignment','left', ...
               'String','Correction Value:', ...
               'Tag','lblOffset');
            
            h_editOffset = uicontrol('Parent',h_dlg, ...
               'Style','edit', ...
               'BackgroundColor',[1 1 1], ...
               'ForegroundColor',[0 0 0], ...
               'FontSize',10, ...
               'Position',[155 133 320 22], ...
               'HorizontalAlignment','left', ...
               'String','', ...
               'UserData','', ...
               'Callback','ui_correct_drift(''val_offset'')', ...
               'TooltipString','', ...
               'Tag','editOffset');

            h_cmdPickOffset = uicontrol('Parent',h_dlg, ...
               'Style','pushbutton', ...
               'FontSize',9, ...
               'Position',[485 133 50 25], ...
               'String','Pick', ...
               'TooltipString','Choose the offset on a plot of the selected variables', ...
               'Callback','ui_correct_drift(''pickoffset'')', ...
               'Tag','cmdPickOffset', ...
               'Enable','off');

            uicontrol('Parent',h_dlg, ...
               'Style','text', ...
               'FontSize',10, ...
               'FontWeight','bold', ...
               'ForegroundColor',[0 0 0], ...
               'BackgroundColor',[.9 .9 .9], ...
               'Position',[20 99 130 18], ...
               'HorizontalAlignment','left', ...
               'String','Date/Time Range:', ...
               'Tag','lblDateRange');
            
            uicontrol('Parent',h_dlg, ...
               'Style','text', ...
               'FontSize',10, ...
               'FontWeight','bold', ...
               'ForegroundColor',[0 0 0], ...
               'BackgroundColor',[.9 .9 .9], ...
               'Position',[301 99 27 18], ...
               'HorizontalAlignment','center', ...
               'String','to', ...
               'Tag','lblTo');
            
            h_editDateStart = uicontrol('Parent',h_dlg, ...
               'Style','edit', ...
               'BackgroundColor',[1 1 1], ...
               'ForegroundColor',[0 0 0], ...
               'FontSize',10, ...
               'Position',[155 98 145 22], ...
               'HorizontalAlignment','left', ...
               'String','', ...
               'UserData','', ...
               'Callback','ui_correct_drift(''val_date'')', ...
               'TooltipString','Starting date/time for drift corrections', ...
               'Tag','editDateStart');

            h_editDateEnd = uicontrol('Parent',h_dlg, ...
               'Style','edit', ...
               'BackgroundColor',[1 1 1], ...
               'ForegroundColor',[0 0 0], ...
               'FontSize',10, ...
               'Position',[330 98 145 22], ...
               'HorizontalAlignment','left', ...
               'String','', ...
               'UserData','', ...
               'Callback','ui_correct_drift(''val_date'')', ...
               'TooltipString','Starting date/time for drift corrections', ...
               'Tag','editDateEnd');
            
            h_cmdPickDate = uicontrol('Parent',h_dlg, ...
               'Style','pushbutton', ...
               'FontSize',9, ...
               'Position',[485 97 50 25], ...
               'String','Pick', ...
               'TooltipString','Choose the date range on a plot of the selected variables', ...
               'Callback','ui_correct_drift(''pickdate'')', ...
               'Tag','cmdPickDate', ...
               'Enable','off');

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
            ui_flagpicker('add',s,[155 58 380 25],h_dlg,'');
            h_popFlagChoice = findobj(h_dlg,'Tag','popFlagChoice');
            
            %check for default E flag and select or add to list if not present
            flagcodes = get(h_popFlagChoice,'UserData');
            Iflag = find(strcmp(flagcodes,'C'));
            if ~isempty(Iflag)
               set(h_popFlagChoice,'Value',Iflag(1))  %use first matched E code
            else
               flagcodes = [flagcodes ; {'C'}];
               defs = char(get(h_popFlagChoice,'String'),'C -- data value corrected for sensor drift');
               set(h_popFlagChoice,'String',defs,'UserData',flagcodes,'Value',length(flagcodes))
            end
            
            h_cmdCancel = uicontrol('Parent',h_dlg, ...
               'Callback','ui_correct_drift(''cancel'')', ...
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
               'Callback','ui_correct_drift(''eval'')', ...
               'Enable','off', ...
               'FontSize',9, ...
               'ListboxTop',0, ...
               'Position',[490 10 60 25], ...
               'String','Proceed', ...
               'TooltipString','Split the data series and open the structure for editing', ...
               'Tag','cmdEval');

            uih = struct( ...
               'popDateCol',h_popDateCol, ...
               'popMethod',h_popMethod, ...
               'popFlagChoice',h_popFlagChoice, ...
               'listAvailable',h_listAvailable, ...
               'listCorrect',h_listCorrect, ...
               'editLogOption',h_editLogOption, ...
               'editDateStart',h_editDateStart, ...
               'editDateEnd',h_editDateEnd, ...
               'editOffset',h_editOffset, ...
               'lblOffset',h_lblOffset, ...
               'cmdPickDate',h_cmdPickDate, ...
               'cmdPickOffset',h_cmdPickOffset, ...
               'cmdAddVal',h_cmdAddVal, ...
               'cmdRemVal',h_cmdRemVal, ...
               'cmdEval',h_cmdEval, ...
               'cmdCancel',h_cmdCancel, ...
               'chkNewWindow',h_chkNewWindow, ...
               'h_cb',h_cb, ...
               'cb',cb, ...
               's',s, ...
               'I_validdatecol',I_validdatecol);

            set(h_dlg,'Visible','on','UserData',uih)
            
            ui_correct_drift('buttons')  %update button states to reflect initial settings
            drawnow

         else
            messagebox('init','This feature requires a data structure with a floating-point or string date/time column', ...
               '','Error',[.9 .9 .9])
         end

      end

   end

else  %handle callbacks

   h_dlg = [];  
   
   %get dialog handle
   if length(findobj) > 2
      h_dlg = findobj('Tag','dlgCorrectDrift');
   end

   %check for dialog handle
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
               I_correct = get(uih.listCorrect,'UserData');

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

               if ~isempty(I_correct)
                  s_correct = varstr(I_correct);
               else
                  s_correct = {''};
               end

               set(uih.listAvailable, ...
                  'String',s_avail, ...
                  'Value',max(1,min(get(uih.listAvailable,'Value'),length(I_avail))))

               set(uih.listCorrect, ...
                  'String',s_correct, ...
                  'Value',max(1,min(get(uih.listCorrect,'Value'),length(I_correct))))

               if isempty(I_correct)
                  set(uih.cmdRemVal,'Enable','off')
               else
                  set(uih.cmdRemVal,'Enable','on')
               end

               ui_correct_drift('buttons')  %update button states

            end

         case 'buttons'  %set button states depending on uicontrol selections
            
            %get uicontrol handles
            datecol = get(uih.popDateCol,'Value') - 1;
            I_avail = get(uih.listAvailable,'UserData');
            I_correct = get(uih.listCorrect,'UserData');
                        
            %toggle add/remove buttons according to list status
            if isempty(I_avail)
               set(uih.cmdAddVal,'Enable','off')
            else
               set(uih.cmdAddVal,'Enable','on')
            end
            
            %toggle proceed button according to list status
            if datecol > 0 && ~isempty(I_correct)
               set(uih.cmdPickDate,'Enable','on')
               set(uih.cmdPickOffset,'Enable','on')
               dtmin = deblank(get(uih.editDateStart,'String'));
               dtmax = deblank(get(uih.editDateEnd,'String'));
               offset = deblank(get(uih.editOffset,'String'));
               if ~isempty(dtmin) && ~isempty(dtmax) && ~isempty(offset)
                  set(uih.cmdEval,'Enable','on')
               else
                  set(uih.cmdEval,'Enable','off')
               end
            else
               set(uih.cmdEval,'Enable','off')
               set(uih.cmdPickDate,'Enable','off')
               set(uih.cmdPickOffset,'Enable','off')
            end
            
            %get method selection
            I_method = get(uih.popMethod,'Value');
            methods = get(uih.popMethod,'UserData');
            method = char(methods(I_method));
            
            %update correction value label
            if strcmp(method,'custom')
               str = 'Weighting Array:';
               tooltip = 'Weighted array of offsets to apply from the beginning to end of the range, scaled to match the date range';
            elseif strcmp(method,'constant')
               str = 'Offset Value:';
               tooltip = 'Constant offset value to apply to all values in the date range';
            else
               str = 'Maximum Offset:';
               tooltip = 'Maximum offset to apply at the end of the date range, linearly scaled from 0 at the beginning of the range';
            end
            set(uih.lblOffset,'String',str)
            set(uih.editOffset,'TooltipString',tooltip)
            
            drawnow
            
         case 'listclick'  %handle list click events
            
            tag = get(gcbo,'Tag');
            
            if strcmpi(get(gcf,'SelectionType'),'open')
               if strcmp(tag,'listAvailable')
                  ui_correct_drift('val_add')
               else
                  ui_correct_drift('val_rem')
               end
            end
            
         case 'pickdate'  %enable choosing date range on a plot of the selected variables
            
            %determine date column
            datecolsel = get(uih.popDateCol,'Value') - 1;
            I_validdatecol = uih.I_validdatecol;
            datecol = I_validdatecol(datecolsel);
            
            %look up list of variables to plot
            ycols = get(uih.listCorrect,'UserData');
            
            %look up current start date
            datestart = trimstr(get(uih.editDateStart,'String'));
            if ~isempty(datestart)
               dstart = datenum(datestart);
            else
               dstart = NaN;
            end
            
            %look up current end date
            dateend = trimstr(get(uih.editDateEnd,'String'));
            if ~isempty(dateend)
               dend = datenum(dateend);
            else
               dend = NaN;
            end
            
            %set initial x range
            xrange = [dstart dend];            
            
            %generate plot
            [msg,h_plot] = plotdata(uih.s,datecol,ycols,'','','',1,5,'linear',0,1,1,2);
            
            if ~isempty(h_plot)
               
               %set plot tag for subsequent handle lookup
               set(h_plot,'Tag','correct_drift_plot')
            
               %add X range toolbar
               get_plot_xrange('init',h_plot,uih.cmdPickDate,'ui_correct_drift(''pickdate_update'')',xrange)
            
               drawnow
               
            else
               messagebox('init',['Plot error: ',msg],'','Error',[0.95 0.95 0.95])               
            end
               
         case 'pickdate_update'
            
            %close plot
            h_plot = findobj('Tag','correct_drift_plot');
            if ~isempty(h_plot)
               delete(h_plot)
            end
            
            %set focus to main dialog
            figure(h_dlg);
            
            %get bounding box from Pick button
            xrange = get(uih.cmdPickDate,'UserData');
            set(uih.cmdPickDate,'UserData',[])
            
            %validate and update date selections
            if length(xrange) == 2
               
               try
                  datestart = datestr(xrange(1),0);
                  dateend = datestr(xrange(2),0);
               catch
                  datestart = '';
                  dateend = '';
               end
               
               set(uih.editDateStart,'String',datestart);
               set(uih.editDateEnd,'String',dateend);  
               
               ui_correct_drift('buttons')
               
            end
            
         case 'pickoffset'  %enable choosing offset on a plot of the selected variables
            
            %determine date column
            datecolsel = get(uih.popDateCol,'Value') - 1;
            I_validdatecol = uih.I_validdatecol;
            datecol = I_validdatecol(datecolsel);
            
            %look up list of variables to plot
            ycols = get(uih.listCorrect,'UserData');
            
            %generate plot
            [msg,h_plot] = plotdata(uih.s,datecol,ycols,'','','',1,5,'linear',0,1,1,2);
            
            if ~isempty(h_plot)
               
               %set plot tag for subsequent handle lookup
               set(h_plot,'Tag','correct_drift_plot')
            
               %add X range toolbar
               get_plot_yrange('init',h_plot,uih.cmdPickOffset,'ui_correct_drift(''pickoffset_update'')',[])
            
               drawnow
               
            else
               messagebox('init',['Plot error: ',msg],'','Error',[0.95 0.95 0.95])               
            end
            
         case 'pickoffset_update'
            
            %close plot
            h_plot = findobj('Tag','correct_drift_plot');
            if ~isempty(h_plot)
               delete(h_plot)
            end
            
            %set focus to main dialog
            figure(h_dlg);
            
            %get bounding box from Pick button
            yrange = get(uih.cmdPickOffset,'UserData');
            set(uih.cmdPickOffset,'UserData',[])
            
            %validate and update date selections
            if length(yrange) == 2
               offset = yrange(1)-yrange(2);
               if ~isnan(offset)
                  set(uih.editOffset,'String',num2str(offset))
                  ui_correct_drift('buttons')
               end
            end
            
         case 'eval'  %evaluate input and perform corrections

            %determine date column
            datecolsel = get(uih.popDateCol,'Value') - 1;
            I_validdatecol = uih.I_validdatecol;
            datecol = I_validdatecol(datecolsel);
            
            %look up group and correctolation selections
            ycols = get(uih.listCorrect,'UserData');

            %get method selection
            I_method = get(uih.popMethod,'Value');
            methods = get(uih.popMethod,'UserData');
            method = char(methods(I_method));
            
            %get and validate date range
            datestart = get(uih.editDateStart,'String');
            dateend = get(uih.editDateEnd,'String');
            try
               datediff = datenum(dateend) - datenum(datestart);
            catch
               datediff = 0;
            end
            if datediff > 0
               daterange = {datestart,dateend};
            else
               daterange = [];
            end
            
            %get correction
            str_offset = trimstr(get(uih.editOffset,'String'));
            try
               offset = str2num(str_offset);
            catch
               offset = [];
            end
            
            %get log option
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
                              
            if datecol > 0 && ~isempty(ycols) && ~isempty(offset) && ~isempty(daterange)

               set(gcf,'Pointer','watch')
               drawnow

               s2 = uih.s;  %get cached structure
               
               %update flag definitions in metadata in case new code added
               if ~isempty(flag) && ~isempty(flagmeta)
                  s2 = addmeta(s2,flagmeta,0,'ui_correct_drift');
               end

               %perform corrections
               [s2,msg] = correct_drift(s2,ycols,method,offset,daterange,datecol,flag,logopt);
               
               set(gcf,'Pointer','arrow')
               drawnow

               if ~isempty(s2)

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

               messagebox('init','Date range or offset are invalid - operation cancelled', ...
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
               ui_correct_drift('update');

            end

         case 'val_add'

            %assign handles
            set(uih.cmdAddVal,'UserData',uih.listAvailable);  %source
            set(uih.cmdRemVal,'UserData',uih.listCorrect);  %target

            %update listboxes
            ui_correct_drift('copysel')

         case 'val_rem'

            %assign handles
            set(uih.cmdAddVal,'UserData',uih.listCorrect);  %source
            set(uih.cmdRemVal,'UserData',uih.listAvailable);  %target

            %update listboxes
            ui_correct_drift('copysel')
            
         case 'val_date'  %validate date entries
            
            h_cb = gcbo;  %get handle of control
            
            str = trimstr(get(h_cb,'String'));
            lastval = get(h_cb,'UserData');
            
            if ~isempty(str)
               try
                  dt = datenum(str);
               catch
                  dt = NaN;
               end
            else
               dt = NaN;
            end

            if ~isnan(dt)
               set(h_cb,'String',str,'UserData',str)  %update trimmed string and stored number
            elseif ~isempty(str)
               set(h_cb,'String',lastval)  %reset string
               messagebox('init','Entry must be a valid date - change cancelled',[],'Error',[.95 .95 .95]);
            else
               set(h_cb,'String','')  %clear any spaces in empty string
            end                        
            
            ui_correct_drift('buttons')

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

            ui_correct_drift('buttons')

         case 'val_offset'  %validate offset
            
            %get handle of control
            h_cb = uih.editOffset;

            %get string and cached last entry
            str = trimstr(get(h_cb,'String'));
            
            %get method selection
            I_method = get(uih.popMethod,'Value');
            methods = get(uih.popMethod,'UserData');
            method = char(methods(I_method));
            
            %validate
            if ~isempty(str)
               try
                  val = str2num(str);  %convert string to scalar number or array
                  if length(val) > 1 && ~strcmp(method,'custom')
                     val = [];  %reject array input unless method = custom
                  end
               catch
                  val = [];
               end
            else
               val = [];
            end

            %update uicontrol
            if ~isempty(val)
               set(h_cb,'String',str,'UserData',str)  %update trimmed string and stored number
            elseif ~isempty(str)
               set(h_cb,'String','')  %reset string
               messagebox('init','Invalid correction value for the specified method - value reset',[],'Error',[.95 .95 .95]);
            else
               set(h_cb,'String','')  %clear string in case whitespace present
            end            
            
            ui_correct_drift('buttons')

      end

   end

end
