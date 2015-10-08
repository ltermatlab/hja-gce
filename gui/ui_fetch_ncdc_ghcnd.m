function ui_fetch_ncdc_ghcnd(op,h_cb,cb)
%GUI dialog for retrieving data from the NOAA NCDC Global Historic Climate Network FTP site
%
%syntax: ui_fetch_ncdc_ghcnd(op,h_cb,cb)
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
%last modified: 07-Jan-2014

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
      h_dlg = findobj('Tag','dlgFetchGHCND');
   else
      h_dlg = [];
   end
   
   %set focus to existing dialog if present, otherwise check for net features and create dialog
   if ~isempty(h_dlg)
      
      figure(h_dlg(1))
      drawnow
      
   elseif exist('urlwrite','file') == 2
      
      %init preferences structure
      prefs = struct('baseurl','ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/daily/', ...
         'state','', ...
         'tempfile',0, ...
         'startdate',[num2str(str2double(datestr(now,10))-30),datestr(now,5)], ...
         'close',1);
      
      %load preferences file if present
      if exist('ui_fetch_ncdc_ghcnd.mat','file') == 2
         v = load('ui_fetch_ncdc_ghcnd.mat');
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
         I_default = find(strcmp(templates,'NCDC_GHCND'));
         if ~isempty(I_default)
            templateval = I_default + 1;
         end
      end
      
      %init station selection variables
      stations = [];
      states = [];
      statestr = {'<select a state/territory>'};
      stateval = 1;
      
      %generate array of stations by state for dropdown menu
      if exist('ncdc_ghcnd_stations.mat','file') == 2
         [stations,states,statestr,stateval,errmsg] = get_ghcnd_stations(prefs);
      else
         errmsg = 'The GHCN station database file ''ncdc_ghcnd_stations.mat'' was not found';
      end
      
      if ~isempty(stations) && isempty(errmsg)
         
         %create dialog figure, add controls
         h_dlg = figure('Visible','off', ...
            'Name','Retrieve GHCN-D Data', ...
            'Units','pixels', ...
            'Color',[0.95 0.95 0.95], ...
            'Position',[max(0,0.5.*(res(3)-650)) max(30,0.5.*(res(4)-415)) 650 415], ...
            'KeyPressFcn','figure(gcf)', ...
            'MenuBar','none', ...
            'NumberTitle','off', ...
            'Tag','dlgFetchGHCND', ...
            'ToolBar','none', ...
            'Resize','off', ...
            'CloseRequestFcn','ui_fetch_ncdc_ghcnd(''cancel'')', ...
            'DefaultuicontrolUnits','pixels');
         
         if mlversion >= 7
            set(h_dlg,'WindowStyle','normal')
            set(h_dlg,'DockControls','off')
         end
         
         uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[.95 .95 .95], ...
            'ForegroundColor',[0 0 0], ...
            'Position',[1 1 650 445], ...
            'Style','frame', ...
            'Tag','Frame0');
         
         uicontrol('Parent',h_dlg, ...
            'BackgroundColor',bgcolor, ...
            'Position',[6 190 640 215], ...
            'Style','frame', ...
            'Tag','Frame2');
         
         uicontrol('Parent',h_dlg, ...
            'BackgroundColor',bgcolor, ...
            'Position',[6 40 640 145], ...
            'Style','frame', ...
            'Tag','Frame1');
         
         uicontrol('Parent',h_dlg, ...
            'BackgroundColor',bgcolor, ...
            'FontSize',10, ...
            'ListboxTop',0, ...
            'Position',[12 372 130 19], ...
            'String','Country - Territory', ...
            'HorizontalAlignment','center', ...
            'Style','text', ...
            'Tag','StaticText1');
         
         h_popState = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'FontSize',10, ...
            'ListboxTop',0, ...
            'Position',[144 374 400 22], ...
            'String',statestr, ...
            'Style','popupmenu', ...
            'Tag','popState', ...
            'Callback','ui_fetch_ncdc_ghcnd(''lookup'')', ...
            'Value',stateval);
         
         h_cmdUpdate = uicontrol('Parent',h_dlg, ...
            'FontSize',10, ...
            'Position',[560 373 70 24], ...
            'String','Update', ...
            'Callback','ui_fetch_ncdc_ghcnd(''update'')', ...
            'TooltipString','Update the station list', ...
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
            'FontSize',9, ...
            'String','<none>', ...
            'Style','listbox', ...
            'Tag','listStations', ...
            'Enable','off', ...
            'Callback','ui_fetch_ncdc_ghcnd(''station'')', ...
            'Value',1);
         
         h_cmdSelect = uicontrol('Parent',h_dlg, ...
            'Enable','off', ...
            'FontSize',10, ...
            'Position',[144 205 485 23], ...
            'String','Copy Selected Station to Request Form', ...
            'Callback','ui_fetch_ncdc_ghcnd(''select'')', ...
            'Tag','cmdSelect');
         
         uicontrol('Parent',h_dlg, ...
            'BackgroundColor',bgcolor, ...
            'FontSize',10, ...
            'Position',[15 149 130 19], ...
            'String','GHCN Station ID', ...
            'Style','text', ...
            'Tag','StaticText1');
         
         h_editStation = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'FontSize',9, ...
            'HorizontalAlignment','left', ...
            'Position',[150 150 100 22], ...
            'String','', ...
            'Style','edit', ...
            'Callback','ui_fetch_ncdc_ghcnd(''filename'')', ...
            'Tag','editStation');
         
         uicontrol('Parent',h_dlg, ...
            'BackgroundColor',bgcolor, ...
            'FontSize',10, ...
            'Position',[260 150 90 19], ...
            'String','Date Range:', ...
            'Style','text', ...
            'Tag','StaticText1');
         
         h_editStartDate = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'FontSize',9, ...
            'HorizontalAlignment','left', ...
            'ListboxTop',0, ...
            'Position',[350 150 70 22], ...
            'String',prefs.startdate, ...
            'Style','edit', ...
            'Callback','ui_fetch_ncdc_ghcnd(''date'')', ...
            'UserData',prefs.startdate, ...
            'Tag','editStartDate');
         
         uicontrol('Parent',h_dlg, ...
            'BackgroundColor',bgcolor, ...
            'FontSize',10, ...
            'Position',[420 150 20 19], ...
            'HorizontalAlignment','center', ...
            'String','to', ...
            'Style','text', ...
            'Tag','StaticText1');
         
         dt = [datestr(now,10),datestr(now,5)];
         h_editEndDate = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'FontSize',9, ...
            'HorizontalAlignment','left', ...
            'ListboxTop',0, ...
            'Position',[440 150 70 22], ...
            'String',dt, ...
            'Style','edit', ...
            'Callback','ui_fetch_ncdc_ghcnd(''date'')', ...
            'UserData',dt, ...
            'Tag','editEndDate');
         
         uicontrol('Parent',h_dlg, ...
            'BackgroundColor',bgcolor, ...
            'FontSize',9, ...
            'Position',[510 150 65 19], ...
            'String','(YYYYMM)', ...
            'Style','text', ...
            'Tag','StaticText1');
         
         uicontrol('Parent',h_dlg, ...
            'BackgroundColor',bgcolor, ...
            'FontSize',10, ...
            'Position',[15 117 130 19], ...
            'String','NCDC FTP site URL', ...
            'Style','text', ...
            'Tag','StaticText1');
         
         h_editURL = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'FontSize',9, ...
            'HorizontalAlignment','left', ...
            'Position',[150 117 360 22], ...
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
            'Position',[150 84 360 22], ...
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
            'Callback','ui_fetch_ncdc_ghcnd(''savetemp'')', ...
            'Tag','chkSave');
         
         h_editFilename = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'FontSize',9, ...
            'HorizontalAlignment','left', ...
            'Position',[150 50 450 22], ...
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
            'Callback','ui_fetch_ncdc_ghcnd(''cancel'')', ...
            'Tag','cmdCancel');
         
         h_cmdEval = uicontrol('Parent',h_dlg, ...
            'Enable','off', ...
            'FontSize',10, ...
            'Position',[575 10 70 24], ...
            'String','Proceed', ...
            'Callback','ui_fetch_ncdc_ghcnd(''eval'')', ...
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
            'popState',h_popState, ...
            'listStations',h_listStations, ...
            'editURL',h_editURL, ...
            'editStartDate',h_editStartDate, ...
            'editEndDate',h_editEndDate, ...
            'popTemplate',h_popTemplate, ...
            'chkSave',h_chkSave, ...
            'chkClose',h_chkClose, ...
            'chkWindow',h_chkWindow, ...
            'cmdUpdate',h_cmdUpdate, ...
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
            ui_fetch_ncdc_ghcnd('lookup')
         end
         
      else
         messagebox('init',errmsg,'','Error',[.9 .9 .9]);
      end
      
   else  %no net features warning
      messagebox('init',' This dialog requires MATLAB version 6.5 (R13) or higher ', ...
         '','Error',[.9 .9 .9]);
   end
   
else
   
   %check for figure dialog without creating empty fig if nothing opened
   if ~isempty(findobj)
      h_dlg = findobj('Tag','dlgFetchGHCND');
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
            
            %generate tempfile path and name from fully-qualified path
            [pn_temp,fn_temp,fn_ext] = fileparts(tempfile);
            if isempty(pn_temp)
               pn_temp = [gce_homepath,filesep,'search_webcache'];
            end
            if ~isdir(pn_temp)
               pn_temp = pwd;
            end
            fn_temp = [fn_temp,fn_ext];
            
            %look up state string from menu selection
            statelist = get(uih.popState,'String');
            stateval = get(uih.popState,'Value');
            if stateval > 1
               state = statelist{stateval};
            else
               state = '';
            end
            
            %look up template name from menu selection
            Itemplate = get(uih.popTemplate,'Value') - 1;
            if Itemplate > 0
               template = uih.templates{Itemplate};
            else
               template = 'NCDC_GHCND';  %use default if none selected
            end
            
            %check for required fields
            if ~isempty(station) && ~isempty(startdate) && ~isempty(enddate)
               
               %update prefs structure
               prefs = struct('baseurl',baseurl, ...
                  'state',state, ...
                  'tempfile',savetemp, ...
                  'startdate',startdate, ...
                  'close',closedlg); 
               
               %save preferences to toolbox directory - overwriting existing prefs file
               fn_pref = which('ui_fetch_ncdc_ghcnd.mat');
               if isempty(fn_pref)
                  pn_pref = [gce_homepath,filesep,'settings'];
                  if ~isdir(pn_pref)
                     pn_pref = fileparts(which('ui_fetch_ncdc_ghcnd'));
                  end
                  fn_pref = [pn_pref,filesep,'ui_fetch_ncdc_ghcnd.mat'];
               end
               save(fn_pref,'prefs')
               
               %generation station id and tempfile delete runtime options
               if savetemp == 1
                  deleteopt = 0;
               else
                  deleteopt = 1;
               end
               
               %fetch data (including normalized table)
               set(h_dlg,'Pointer','watch'); drawnow
               [s,msg,s_normalized] = fetch_ncdc_ghcnd(station,template,startdate,enddate,0, ...
                  fn_temp,pn_temp,deleteopt,baseurl);
               set(h_dlg,'Pointer','arrow'); drawnow
               
               %check for return data
               if ~isempty(s)
                  
                  err = 0;
                  
                  %try to save normalized raw data file to temp directory
                  if savetemp == 1 && ~isempty(s_normalized)
                     try
                        data = s_normalized;
                        [pn_temp,fn_base] = fileparts([pn_temp,filesep,fn_temp]);
                        save([pn_temp,filesep,fn_base,'.mat'],'data')
                     catch
                        %take no action on error
                     end
                  end
                  
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
            
            %get selected station info
            sel = get(uih.listStations,'Value');
            str = get(uih.listStations,'String');
            station_info = str{sel};
            station = strtok(station_info,' ');
            
            %try to parse beginning year of observation
            Idatestart = regexpi(station_info,'\(\d{4}-\d{4}\)');
            if ~isempty(Idatestart)
               mindate = [station_info(Idatestart(1)+1:Idatestart(1)+4),'01'];
               maxdate = [station_info(Idatestart(1)+6:Idatestart(1)+9),'12'];
               set(uih.editStartDate,'String',mindate)
               set(uih.editEndDate,'String',maxdate)
            end            
            
            %update station string, temp file name
            if ~isempty(station)
               set(uih.editStation,'String',station)
               ui_fetch_ncdc_ghcnd('filename')
            end
            
         case 'savetemp'  %handle save tempfile selection, toggling filename field accordingly
            
            %check for save option
            if get(uih.chkSave,'Value') == 1
               ui_fetch_ncdc_ghcnd('filename')  %init temp file name
               set(uih.editFilename,'Visible','on')
            else
               set(uih.editFilename,'Visible','off')
            end
            
            drawnow
            
         case 'filename'  %handle temp file edits
            
            %get station from dialog
            station = deblank(get(uih.editStation,'String'));
            
            %update save filename
            if ~isempty(station)
               dt = now;
               set(uih.editFilename,'String', ...
                  ['ncdc_',station,'_daily_', ...
                  datestr(dt,10),datestr(dt,5),datestr(dt,7),'.txt'])
               ui_fetch_ncdc_ghcnd('buttons')
            end
            
         case 'lookup'  %handle state menu changes, re-populate station list for new state
            
            %get state selection value
            sel = get(uih.popState,'Value');
            
            %check for valid selection
            if sel > 1
               
               str = get(uih.popState,'String');  %look up state string from menu list
               Isel = find(strcmp(uih.stations(:,1),str{sel}));  %get index of all stations for state
               
               if ~isempty(Isel)
                  str = concatcellcols(uih.stations(Isel,2:end),'  ');  %concat station id, station description
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
               
               ui_fetch_ncdc_ghcnd('buttons')  %toggle button state
               
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
               ui_fetch_ncdc_ghcnd('select')
            end
            
         case 'date'  %validate date entries
            
            h_cbo = gcbo;  %get handle of active edit box
            str = deblank(get(h_cbo,'String'));  %get edit box contents
            err = 0;  %init error flag
            
            if ~isempty(str)
               
               if length(str) == 6
                  yr = str2double(str(1:4));
                  mm = str2double(str(5:6));
                  if ~isnan(yr) && ~isnan(mm) && yr <= str2double(datestr(now,10)) && mm >= 1 && mm <= 12
                     dt = datenum([str(5:6),'/01/',str(1:4)]);
                  else
                     dt = [];
                  end
               else
                  try
                     dt = datenum(str);  %try to parse date
                  catch
                     dt = [];
                  end
               end
               
               %generate date string in YYYYMM format
               if ~isempty(dt)
                  str = char(sub_date2yyyymm(dt));
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
            ui_fetch_ncdc_ghcnd('buttons')
            
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
            
            if exist('ncdc_ghcnd_stations.mat','file') == 2
               
               try
                  v = load('ncdc_ghcnd_stations.mat','-mat');
               catch
                  v = struct('null','');
               end
               
               if isfield(v,'data')
                  ui_datagrid('init',v.data,uih.cmdUpdate,'ui_fetch_ncdc_ghcnd(''update2'')',150,'left');
               end
               
            else
               messagebox('init','NCDC station list file (''ncdc_ghcnd_stations.mat'') was not found','','Error',[.9 .9 .9]);
            end
            
         case 'update2'  %apply updates
            
            cd = get(uih.cmdUpdate,'UserData');  %get cached data
            set(uih.cmdUpdate,'UserData',[]);  %clear cache
            
            if iscell(cd) && length(cd) >= 2
              
               %extract data and change flag
               data = cd{1};
               flag = cd{2};
               
               if flag == 1 && gce_valid(data,'data') == 1
                  
                  %save updated station list to disk
                  set(h_dlg,'Pointer','watch'); drawnow
                  fn = which('ncdc_ghcnd_stations.mat');
                  if isempty(fn)
                     pn = [gce_homepath,filesep,'settings'];
                     if ~isdir(pn)
                        pn = fileparts(which('ui_fetch_ncdc_ghcnd'));
                     end
                     fn = [pn,filesep,'ncdc_ghcnd_stations.mat'];
                  end
                  save(fn,'data')
                  set(h_dlg,'Pointer','arrow'); drawnow
                  
                  %look up prior state string from menu selection
                  statelist = get(uih.popState,'String');
                  stateval = get(uih.popState,'Value');
                  if stateval > 1
                     state = statelist{stateval};
                  else
                     state = '';
                  end
                  
                  %update listbox
                  set(uih.popState,'Value',1)
                  set(uih.listStations,'String',{' '},'Value',1)
                  drawnow
                  
                  %generate array of stations by state for dropdown menu
                  [stations,states,statestr,stateval,errmsg] = get_ghcnd_stations(struct('state',state),data);                  
                  
                  if ~isempty(stations) && isempty(errmsg)
                     
                     %update cached states and stations fields in userdata
                     uih.states = states;
                     uih.stations = stations;
                     set(h_dlg,'UserData',uih)
                     
                     %update state list
                     set(uih.popState,'String',statestr,'Value',stateval)
                     
                     %refresh listbox
                     ui_fetch_ncdc_ghcnd('lookup')
                     
                  else
                     messagebox('init',errmsg,'','Error',[0.95 0.95 0.95])
                  end
                  
               end
               
            end
            
      end
      
   end
   
end
return

function ar = sub_date2yyyymm(dt)
%Converts a MATLAB serial dates to a cell array of strings in YYYYMM format
%
%syntax: str = date2yyyymm(dt)

try
   yr = datestr(dt,10);
   mo = datestr(dt,5);
   ar = strrep(cellstr([yr,mo]),' ','');
catch
   ar = repmat({''},length(dt),1);  %return empty cell array
end
return


function [stations,states,statestr,stateval,errmsg] = get_ghcnd_stations(prefs,stationdata)
%Loads the GHCN database and generates station lists and indices
%
%input:
%  prefs = preferences structure from ui_fetch_ncdc_ghcnd.mat
%  stationdata = data structure (optional; default = load from ncdc_ghcnd_stations.mat)
%
%output:
%  stations = station list (cell array)
%  states = country and state/territory key (cell array)
%  statestr = string for the country-territory dropdown menu
%  stateval = index of last country/state selection
%  errmsg = text of any error message loading/parsing the database

%init output
stations = [];
states = [];
stateval = 1;
errmsg = '';

if exist('prefs','var') == 1 && isstruct(prefs)
   
   %init progress bar
   ui_progressbar('init',3,'Initializing NOAA GHCN-D Dialog')
   ui_progressbar('update',1,'Loading GHCN-D Database...')
   drawnow
   
   %load station database
   if exist('stationdata','var') ~= 1
      stationdata = [];
   end
   if ~isstruct(stationdata)
      try
         v = load('ncdc_ghcnd_stations.mat');
      catch e
         v = struct('null','');
         errmsg = ['an error occurred loading ''ncdc_ghcnd_stations.mat'' (',e.message,')'];
      end
      if isfield(v,'data')
         stationdata = v.data;
      end
   end
   
   if ~isempty(stationdata)
      
      ui_progressbar('update',2,'Extracting GHCN-D Stations...')
      
      %get ending year of observations
      maxyear = extract(stationdata,'YearEnd');
      minyear = extract(stationdata,'YearStart');
      
      %check for valid YearEnd column
      if ~isempty(maxyear) && ~isempty(minyear)
         
         %generate ending year of observations
         dvec = datevec(now);
         maxyear(isnan(maxyear)) = dvec(1);
         startdate = cellstr(num2str(minyear,'%4d'));
         enddate = cellstr(num2str(maxyear,'%4d'));
         numrows = length(enddate);
         enddate = concatcellcols([repmat({' ('},numrows,1),startdate,repmat({'-'},numrows,1),enddate,repmat({')'},numrows,1)],'');
         
         %extract other variables
         stationid = extract(stationdata,'StationID');
         location = extract(stationdata,'StationName');
         country = extract(stationdata,'Country');
         
         %generate country-state list
         states = extract(stationdata,'State');
         states(cellfun('isempty',states)) = {'(all states/territories)'};
         country_states = concatcellcols([country states],' - ');
         stations = [country_states, ...
            stationid, ...
            location, ...
            startdate, ...
            enddate];
         
         %get array of unique states for dropdown
         states = unique(country_states);
         
         %generate dropdown list for state selection
         statestr = [{'<select a state/territory>'} ; states];
         if ~isempty(prefs.state)
            Isel = find(strcmp(statestr,prefs.state));
            if ~isempty(Isel)
               stateval = Isel;
            end
         else
            stateval = 1;
         end
         
      else
         errmsg = 'The GHCN station database file ''ncdc_ghcnd_stations.mat'' is invalid';
      end
      
   else
      errmsg = 'The GHCN station database file ''ncdc_ghcnd_stations.mat'' is invalid';
   end
   
   ui_progressbar('close')
   
end

return