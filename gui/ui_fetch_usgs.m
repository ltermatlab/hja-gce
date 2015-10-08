function ui_fetch_usgs(op,h_cb,cb)
%GUI dialog for retrieving data from the USGS WWW server
%
%syntax: ui_fetch_usgs(op,h_cb,cb)
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

   %init optional arguments if missing
   if exist('h_cb','var') ~= 1
      h_cb = [];
   end

   if exist('cb','var') ~= 1
      cb = '';
   end

   %check for other instances of dialog
   if ~isempty(findobj)
      h_dlg = findobj('Tag','dlgFetchUSGS');
   else
      h_dlg = [];
   end

   %set focus to existing dialog if present, otherwise check for net features and create dialog
   if ~isempty(h_dlg)

      figure(h_dlg(1))
      drawnow

   elseif exist('urlwrite','file') == 2

      %init preferences structure
      prefs = struct('baseurl','http://waterdata.usgs.gov/nwis/', ...
         'state','', ...
         'tempfile',0, ...
         'close',1);

      %load preferences file if present
      if exist('ui_fetch_usgs.mat','file') == 2
         v = load('ui_fetch_usgs.mat');
         if isfield(v,'prefs')
            prefs = v.prefs;
         end
      end

      %init screen dimension var
      res = get(0,'ScreenSize');
      bgcolor = [0.9 0.9 0.9];

      %generate array of metadata templates for dropdown menu
      templates = [];
      templatestr = {'<default>'};
      templateval = 1;
      alltemplates = get_templates;
      if ~isempty(alltemplates)
         templates = {alltemplates.template}';
         templatestr = [templatestr ; templates];
         I_default = find(strcmp(templates,'USGS_Generic'));
         if ~isempty(I_default)
            templateval = I_default + 1;
         end
      end

      %generate array of stations by state for dropdown menu
      stations = [];
      states = [];
      statestr = {'<select a state>'};
      stateval = 1;
      if exist('usgs_stations.mat','file') == 2
         v = load('usgs_stations.mat');
         if isfield(v,'data')
            stations = [extract(v.data,'State'), ...
                  extract(v.data,'Station'), ...
                  extract(v.data,'SiteType'), ...
                  extract(v.data,'Description')];
            states = unique(stations(:,1));
            statestr = [statestr ; states];
            if ~isempty(prefs.state)
               I = find(strcmp(statestr,prefs.state));
               if ~isempty(I)
                  stateval = I;
               end
            end
         end
      end

      %create dialog figure, add controls
      h_dlg = figure('Visible','off', ...
         'Name','Retrieve USGS Data', ...
         'Units','pixels', ...
         'Color',[0.95 0.95 0.95], ...
         'Position',[max(0,0.5.*(res(3)-650)) max(30,0.5.*(res(4)-410)) 650 410], ...
         'KeyPressFcn','figure(gcf)', ...
         'MenuBar','none', ...
         'NumberTitle','off', ...
         'Tag','dlgFetchUSGS', ...
         'ToolBar','none', ...
         'Resize','off', ...
         'CloseRequestFcn','ui_fetch_usgs(''cancel'')', ...
         'DefaultuicontrolUnits','pixels');

      if mlversion >= 7
         set(h_dlg,'WindowStyle','normal')
         set(h_dlg,'DockControls','off')
      end

      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[.95 .95 .95], ...
         'ForegroundColor',[0 0 0], ...
         'Position',[1 1 650 410], ...
         'Style','frame', ...
         'Tag','Frame0');

      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'Position',[6 40 640 145], ...
         'Style','frame', ...
         'Tag','Frame1');

      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'Position',[6 190 640 215], ...
         'Style','frame', ...
         'Tag','Frame2');

      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'ListboxTop',0, ...
         'Position',[12 372 130 19], ...
         'String','State/Territory', ...
         'HorizontalAlignment','center', ...
         'Style','text', ...
         'Tag','StaticText1');

      h_popState = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',10, ...
         'ListboxTop',0, ...
         'Position',[144 374 200 22], ...
         'String',statestr, ...
         'Style','popupmenu', ...
         'Tag','popState', ...
         'Callback','ui_fetch_usgs(''lookup'')', ...
         'Value',stateval);

      uicontrol('Parent',h_dlg, ...
         'FontSize',10, ...
         'Position',[560 373 70 24], ...
         'String','Update', ...
         'Callback','ui_fetch_usgs(''update'')', ...
         'TooltipString','Update the station list from the USGS NWIS database', ...
         'Tag','cmdUpdate');

      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'ListboxTop',0, ...
         'HorizontalAlignment','center', ...
         'Position',[12 342 130 19], ...
         'String','Available Stations', ...
         'Style','text', ...
         'Tag','StaticText1');

      h_listStations = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'Position',[144 230 485 135], ...
         'FontSize',8, ...
         'String','<none>', ...
         'Style','listbox', ...
         'Tag','listStations', ...
         'Enable','off', ...
         'Callback','ui_fetch_usgs(''station'')', ...
         'Value',1);

      h_cmdSelect = uicontrol('Parent',h_dlg, ...
         'Enable','off', ...
         'FontSize',10, ...
         'Position',[144 205 485 23], ...
         'String','Copy Selected Station to Request Form', ...
         'Callback','ui_fetch_usgs(''select'')', ...
         'Tag','cmdSelect');

      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'Position',[11 149 80 19], ...
         'String','Station ID', ...
         'Style','text', ...
         'Tag','StaticText1');

      h_editStation = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'Position',[94 150 90 22], ...
         'String','', ...
         'Style','edit', ...
         'Callback','ui_fetch_usgs(''filename'')', ...
         'Tag','editStation');

      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'Position',[190 150 70 19], ...
         'String','Data Type', ...
         'Style','text', ...
         'Tag','StaticText1');

      h_popDataType = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'Position',[260 150 90 22], ...
         'String',{'Real-time';'Daily'}, ...
         'Style','popupmenu', ...
         'Tag','popDataType', ...
         'Value',2, ...
         'Callback','ui_fetch_usgs(''datatype'')', ...
         'UserData',{'realtime','daily'});

      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'Position',[352 150 90 19], ...
         'String','Date Range:', ...
         'Style','text', ...
         'Tag','StaticText1');

      dt = datestr(now,29);
      dt(1:4) = num2str(str2double(datestr(now,10))-10);
      h_editStartDate = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'ListboxTop',0, ...
         'Position',[442 150 84 22], ...
         'String',dt, ...
         'Style','edit', ...
         'Callback','ui_fetch_usgs(''date'')', ...
         'UserData',dt, ...
         'Tag','editStartDate');

      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'Position',[527 150 20 19], ...
         'HorizontalAlignment','center', ...
         'String','to', ...
         'Style','text', ...
         'Tag','StaticText1');

      dt = datestr(now,29);
      h_editEndDate = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'ListboxTop',0, ...
         'Position',[550 150 84 22], ...
         'String',dt, ...
         'Style','edit', ...
         'Callback','ui_fetch_usgs(''date'')', ...
         'UserData',dt, ...
         'Tag','editEndDate');

      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'Position',[15 117 130 19], ...
         'String','USGS Website URL', ...
         'Style','text', ...
         'Tag','StaticText1');

      h_editURL = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'Position',[150 117 484 22], ...
         'Style','edit', ...
         'String',prefs.baseurl, ...
         'Tag','editURL');

      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'Position',[15 84 130 19], ...
         'String','Metadata Template', ...
         'Style','text', ...
         'Tag','StaticText1');

      h_popTemplate = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'Position',[150 84 260 22], ...
         'String',templatestr, ...
         'Style','popupmenu', ...
         'Tag','popTemplate', ...
         'Value',templateval);

      %determine save template checkbox state based on preferences
      if prefs.tempfile == 1
         tempvis = 'on';
      else
         tempvis = 'off';
      end

      h_chkSave = uicontrol('Parent',h_dlg, ...
         'Style','checkbox', ...
         'Position',[25 50 120 22], ...
         'BackgroundColor',bgcolor, ...
         'String','Save Temp File', ...
         'FontSize',10, ...
         'Value',prefs.tempfile, ...
         'Enable',tempvis, ...
         'Callback','ui_fetch_usgs(''savetemp'')', ...
         'Tag','chkSave');

      h_lblFilename = uicontrol('Parent',h_dlg, ...
         'Visible',tempvis, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'Position',[160 50 75 19], ...
         'String','Filename', ...
         'Style','text', ...
         'Tag','StaticText1');

      h_editFilename = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'Position',[236 50 398 22], ...
         'Visible',tempvis, ...
         'Style','edit', ...
         'Tag','editFilename');

      h_chkClose = uicontrol('Parent',h_dlg, ...
         'Style','checkbox', ...
         'Position',[135 10 230 22], ...
         'BackgroundColor',[0.95 0.95 0.95], ...
         'String','Close dialog after retrieving data', ...
         'FontSize',10, ...
         'Value',prefs.close, ...
         'Tag','chkSave');

      h_cmdCancel = uicontrol('Parent',h_dlg, ...
         'FontSize',10, ...
         'Position',[6 10 70 24], ...
         'String','Cancel', ...
         'Callback','ui_fetch_usgs(''cancel'')', ...
         'Tag','cmdCancel');

      h_cmdEval = uicontrol('Parent',h_dlg, ...
         'Enable','off', ...
         'FontSize',10, ...
         'Position',[575 10 70 24], ...
         'String','Proceed', ...
         'Callback','ui_fetch_usgs(''eval'')', ...
         'Tag','cmdEval');

      %check for client or stand-alone mode based on callback handle, set new window checkbox visibility accordingly
      if ~isempty(h_cb)
         windowvis = 'on';
         windowval = 0;
      else
         windowvis = 'off';
         windowval = 1;
      end

      h_chkWindow = uicontrol('Parent',h_dlg, ...
         'Style','checkbox', ...
         'Position',[375 10 150 22], ...
         'Enable',windowvis, ...
         'BackgroundColor',[0.95 0.95 0.95], ...
         'String','Open in new window', ...
         'FontSize',10, ...
         'Value',windowval, ...
         'Tag','chkWindow');

      %cache gui info for subsequent function calls
      uih = struct('h_cb',h_cb, ...
         'cb',cb, ...
         'editStation',h_editStation, ...
         'editFilename',h_editFilename, ...
         'lblFilename',h_lblFilename, ...
         'popState',h_popState, ...
         'listStations',h_listStations, ...
         'popDataType',h_popDataType, ...
         'editURL',h_editURL, ...
         'editStartDate',h_editStartDate, ...
         'editEndDate',h_editEndDate, ...
         'popTemplate',h_popTemplate, ...
         'chkSave',h_chkSave, ...
         'chkClose',h_chkClose, ...
         'chkWindow',h_chkWindow, ...
         'cmdSelect',h_cmdSelect, ...
         'cmdCancel',h_cmdCancel, ...
         'cmdEval',h_cmdEval, ...
         'stations',{stations}, ...
         'states',{states}, ...
         'templates',{templates}, ...
         'lastdatatype',2);

      set(h_dlg,'UserData',uih,'Visible','on')

      %check for prior state selection in saved prefs - look up stations to populate listbox
      if stateval == 1
         drawnow
      else
         ui_fetch_usgs('lookup')
      end

   else  %no net features warning
      messagebox('init',' This dialog requires MATLAB version 6.5 (R13) or higher ', ...
         '','Error',[.9 .9 .9]);
   end

else

   %check for figure dialog without creating empty fig if nothing opened
   if ~isempty(findobj)
      h_dlg = findobj('Tag','dlgFetchUSGS');
   else
      h_dlg = [];
   end

   if ~isempty(h_dlg)

      %get cached gui data
      uih = get(h_dlg,'UserData');

      switch op

         case 'cancel'  %close dialog

            delete(h_dlg)
            drawnow

            if ~isempty(uih.h_cb)
               h_fig = parent_figure(uih.h_cb);
            else
               h_fig = [];
            end

            if ~isempty(h_fig)
               figure(h_fig)
            else
               ui_aboutgce('reopen')  %check for last window
            end

         case 'eval'  %evaluate settings, fetch data

            %get uicontrol field values
            station = deblank(get(uih.editStation,'String'));
            startdate = get(uih.editStartDate,'String');
            enddate = get(uih.editEndDate,'String');
            tempfile = deblank(get(uih.editFilename,'String'));
            savetemp = get(uih.chkSave,'Value');
            closedlg = get(uih.chkClose,'Value');
            newwindow = get(uih.chkWindow,'Value');
            baseurl = get(uih.editURL,'String');

            %set default clear_provisional option
            clear_provisional = 1;

            %look up state string from menu selection
            statelist = get(uih.popState,'String');
            stateval = get(uih.popState,'Value');
            if stateval > 1
               state = statelist{stateval};
            else
               state = '';
            end

            %look up datatype string from menu selection
            datatypes = get(uih.popDataType,'UserData');
            datatype = datatypes{get(uih.popDataType,'Value')};

            %look up template name from menu selection
            Itemplate = get(uih.popTemplate,'Value') - 1;
            if Itemplate > 0
               template = uih.templates{Itemplate};
            else
               template = 'USGS_Generic';  %use default if none selected
            end

            %check for required fields
            if ~isempty(station) && ~isempty(startdate) && ~isempty(enddate) && ~isempty(datatype)

               %update prefs structure
               prefs = struct('baseurl',baseurl, ...
                  'state',state, ...
                  'tempfile',savetemp, ...
                  'close',closedlg);

               %save preferences to toolbox directory - overwriting existing prefs file
               fn = which('ui_fetch_usgs.mat');
               if isempty(fn)
                  pn = [gce_homepath,filesep,'settings'];
                  if ~isdir(pn)
                     pn = fileparts(which('ui_fetch_usgs'));
                  end
                  fn = [pn,filesep,'ui_fetch_usgs.mat'];
               end
               save(fn,'prefs')

               %generate tempfile name if not specified by user
               if isempty(tempfile) || savetemp == 0
                  dt = now;
                  tempfile = ['usgs_',datatype,'_',station,'_', ...
                        datestr(dt,10),datestr(dt,5),datestr(dt,7),'T',strrep(datestr(dt,13),':',''),'.txt'];
               end

               %generate path for temp file
               pn = gce_homepath;  %get toolbox directory
               pn_test = [pn,filesep,'search_webcache'];  %set test directory = search_webcache subdirectory
               if ~isdir(pn_test)
                  status = mkdir(pn,'search_webcache');  %try to create web cache directory
                  if status == 1
                     pn = pn_test;
                  end
               else
                  pn = pn_test;
               end

               %set delete option
               if savetemp == 1
                  deleteopt = 0;
               else
                  deleteopt = 1;
               end

               %fetch data
               set(h_dlg,'Pointer','watch'); drawnow
               [s,msg] = fetch_usgs_dates(station,datatype,startdate,enddate,template,pn,tempfile,clear_provisional,deleteopt,baseurl);
               set(h_dlg,'Pointer','arrow'); drawnow

               %check for return data
               if ~isempty(s)

                  err = 0;

                  %close dialog if appropriate
                  if closedlg == 1
                     close(h_dlg)
                     drawnow
                  end

                  %cache data and execute callback if specified
                  if ~isempty(uih.h_cb) && newwindow == 0
                     h_fig = parent_figure(uih.h_cb);
                     if ~isempty(h_fig)
                        figure(h_fig)
                        set(uih.h_cb,'UserData',s)
                        drawnow
                        if ~isempty(uih.cb)
                           try
                              eval(uih.cb)
                           catch
                              err = 1;
                           end
                        end
                     else
                        err = 1;
                     end
                  else  %open in new editor window
                     if closedlg == 0
                        uih.h_cb = [];  %clear stored handle on new window calls
                        uih.cb = '';
                        set(h_dlg,'UserData',uih)
                     end
                     ui_editor('init',s)
                  end

                  %display error message
                  if err == 1
                     ui_editor('init',s)
                     drawnow
                     messagebox('init','Errors occurred returning the structure to the original window', ...
                        '','Error',[.9 .9 .9])
                  end

               else
                  messagebox('init',['Errors occurred retrieving the data (',msg,')'], ...
                     '','Error',[.9 .9 .9])
               end

            else
               messagebox('init','Data could not be fetched with the selected options', ...
                  '','Error',[.9 .9 .9]);
            end

         case 'select'  %handle station selection actions

            sel = get(uih.listStations,'Value');
            str = get(uih.listStations,'String');
            station = strtok(str{sel},' ');

            %update station string, temp file name
            if ~isempty(station)
               set(uih.editStation,'String',station)
               ui_fetch_usgs('filename')
            end

         case 'datatype'  %handle data type selections, set default days to fetch

            sel = get(uih.popDataType,'Value');

            if sel ~= uih.lastdatatype
               if sel == 1
                  startdate = datestr(now-119,29);  %prior 120 days for real-time
               else
                  startdate = datestr(now,29);
                  startdate(1:4) = num2str(str2double(datestr(now,10))-10);  %prior 10 years for daily
               end
               set(uih.editStartDate,'String',startdate,'UserData',startdate)
               uih.lastdatatype = sel;  %cache selection
               set(h_dlg,'UserData',uih)  %update gui data
               ui_fetch_usgs('filename')  %update temp file name based on data type (if enabled)
            end

         case 'savetemp'  %handle save tempfile selection, toggling filename field accordingly

            if get(uih.chkSave,'Value') == 1
               ui_fetch_usgs('filename')  %init temp file name
               set(uih.editFilename,'Visible','on')
               set(uih.lblFilename,'Visible','on')
            else
               set(uih.editFilename,'Visible','off','String','')
               set(uih.lblFilename,'Visible','off')
            end

            drawnow

         case 'filename'  %handle temp file edits

            station = deblank(get(uih.editStation,'String'));

            if ~isempty(station)
               dt = now;
               datatypes = get(uih.popDataType,'UserData');
               set(uih.editFilename,'String', ...
                  ['usgs_',datatypes{get(uih.popDataType,'Value')},'_',station,'_', ...
                     datestr(dt,10),datestr(dt,5),datestr(dt,7),'T',strrep(datestr(dt,13),':',''),'.txt'])
               ui_fetch_usgs('buttons')
            end

         case 'lookup'  %handle state menu changes, re-populate station list for new state

            %get state selection value
            sel = get(uih.popState,'Value');

            %check for valid selection
            if sel > 1

               str = get(uih.popState,'String');  %look up state string from menu list
               I = find(strcmp(uih.stations(:,1),str{sel}));  %get index of all stations for state

               if ~isempty(I)
                  str = concatcellcols(uih.stations(I,2:4),'  ');  %concat station id, station description
                  set(uih.listStations, ...
                     'String',str, ...
                     'Value',1, ...
                     'Enable','on', ...
                     'Listboxtop',1)
                  set(uih.cmdSelect,'Enable','on')
               else  %no match - clear station list
                  set(uih.listStations, ...
                     'String','<none>', ...
                     'Value',1, ...
                     'Enable','off', ...
                     'Listboxtop',1)
                  set(uih.cmdSelect,'Enable','off')
               end

               ui_fetch_usgs('buttons')  %toggle button state

            else  %no state selected - clear listbox

               set(uih.listStations, ...
                  'String','<none>', ...
                  'Value',1, ...
                  'Enable','off', ...
                  'Listboxtop',1)
               set(uih.cmdSelect,'Enable','off')

            end

         case 'station'  %handle station list clicks - trigger select operation on double click

            if strcmp(get(gcf,'SelectionType'),'open')
               ui_fetch_usgs('select')
            end

         case 'date'  %validate date entries

            h_cbo = gcbo;  %get handle of active edit box
            str = deblank(get(h_cbo,'String'));  %get edit box contents
            err = 0;  %init error flag

            if ~isempty(str)
               try
                  dt = datenum(str);  %try to parse date
               catch
                  dt = [];
               end
               if isempty(dt)
                  ar = splitstr(str,'-');
                  if length(ar) == 3  %check for yyyy-mm-dd format, unsupported by MATLAB
                     try
                        dt = datenum([ar{2},'/',ar{3},'/',ar{1}]);  %convert to mm/dd/yyyy
                     catch
                        dt = [];
                     end
                  else  %unrecognized number of parameters
                     dt = [];
                  end
               end

               %generate date string in YYYY-MM-DD format
               if ~isempty(dt)
                  str = char(sub_date2yyyymmdd(dt));
               else
                  str = '';
               end

               %update control
               if ~isempty(str)
                  set(h_cbo,'String',str,'UserData',str)  %update text field, cache new value
               else
                  set(h_cbo,'String',get(h_cbo,'UserData'))  %replace with last valid entry
                  err = 1;
               end

            end

            %refresh button states
            ui_fetch_usgs('buttons')

            if err == 1
               messagebox('init',' Invalid date format - value reset ','','Error',[.9 .9 .9])
            end

         case 'buttons'  %update button states based on station and days field entries

            %get contents of required fields
            station = deblank(get(uih.editStation,'String'));
            datestart = deblank(get(uih.editStartDate,'String'));
            dateend = deblank(get(uih.editEndDate,'String'));
            url = deblank(get(uih.editURL,'String'));

            %toggle button states depending on field contents
            if ~isempty(station) && ~isempty(datestart) && ~isempty(dateend) && ~isempty(url)
               set(uih.cmdEval,'Enable','on')
               set(uih.chkSave,'Enable','on')
            else
               set(uih.cmdEval,'Enable','off')
               set(uih.chkSave,'Enable','off')
            end

            drawnow

         case 'update'  %update station list

            %check for update within last day
            d = dir(which('usgs_stations.mat'));
            skipupdate = 0;
            if ~isempty(d)
               if datenum(d(1).date) > now-1
                  skipupdate = 1;
               end
            end

            if skipupdate == 0

               %retrieve stations list data set (progressbar will be inititated automatically)
               set(h_dlg,'Pointer','watch'); drawnow
               [s,msg] = update_usgs_stations('rt');
               set(h_dlg,'Pointer','arrow'); drawnow

               if ~isempty(s)

                  %get currently selected state
                  statesel = get(uih.popState,'Value') - 1;
                  if statesel > 1
                     state = uih.states{statesel};
                  else
                     state = '';
                  end

                  %update stations array
                  stations = [extract(s,'State'), ...
                     extract(s,'Station'), ...
                     extract(s,'SiteType'), ...
                     extract(s,'Description')];

                  %build new state selection list
                  states = unique(stations(:,1));
                  statestr = [{'<select a state>'} ; states];
                  if ~isempty(state)
                     stateval = find(strcmp(states,state));
                     if ~isempty(stateval)
                        stateval = stateval + 1;
                     else
                        stateval = 1;
                     end
                  else
                     stateval = 1;
                  end

                  %update cached state and station info
                  uih.stations = stations;
                  uih.states = states;
                  set(h_dlg,'UserData',uih)

                  %update state selection menu
                  set(uih.popState,'String',statestr,'Value',stateval)

                  %refresh GUI and list
                  ui_fetch_usgs('lookup')

                  messagebox('init',['Successfully retrieved information for ',int2str(size(stations,1)),' stations from ', ...
                     int2str(length(states)),' states/territories'],'','Information',[.95 .95 .95]);

               else
                  messagebox('init','An error occurred updating the station list','','Error',[.95 .95 .95])
               end

            else
               messagebox('init','Update cancelled - USGS station list is current','','Warning',[.95 .95 .95])
            end

      end

   end

end


function ar = sub_date2yyyymmdd(dt)
%Converts a MATLAB serial dates to a cell array of strings in YYYY-MM-DD format (ISO 8601)
%
%syntax: str = date2yyyymmdd(dt)

try
   yr = datestr(dt,10);
   mo = datestr(dt,5);
   dy = datestr(dt,7);
   sep = repmat('-',length(dt),1);
   ar = strrep(cellstr([yr,sep,mo,sep,dy]),' ','');
catch
   ar = repmat({''},length(dt),1);  %return empty cell array
end