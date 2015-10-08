function ui_statreport(op,s,fn,pn)
%GCE Data Toolbox statistical report generator dialog
%
%syntax: ui_statreport(op,s,fn,pn)
%
%input:
%  op = operation ('init' to initialize dialog)
%  s = data structure
%  fn = initial filename (default = '')
%  pn = initial pathname (default = pwd)
%
%output:
%  none
%
%
%(c)2002-2009 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 23-Jan-2009

curpath = pwd;

if exist('op','var') ~= 1
   op = 'init';
end

if strcmp(op,'init')  %create the dialog

   if exist('s','var') ~= 1
      s = [];
   end

   if exist('pn','var') ~= 1
      pn = [curpath,filesep];
   elseif ~strcmp(pn(length(pn)),filesep)
      pn = [pn,filesep];
   end

   formatval = 1;
   if exist('fn','var') ~= 1
      fn = '';
   end

   if isempty(fn)
      vis = 'off';
   else
      [tmp,basename,ext] = fileparts(fn);
      vis = 'on';
      if strcmp(lower(ext),'.csv')
         formatval = 2;
      end
   end

   if gce_valid(s,'data')

      bgcolor = [0.9 0.9 0.9];
      res = get(0,'ScreenSize');
      figpos = [max(1,0.5.*(res(3)-620)) max(30,0.5.*(res(4)-330)) 620 330];

      if length(findobj) > 1
         h_fig = gcf;
      else
         h_fig = '';
      end

      h_dlg = findobj('Tag','dlgExport');
      if ~isempty(h_dlg)
         close(h_dlg)
      end

      h_dlg = figure('Visible','off', ...
         'Color',[0.95 0.95 0.95], ...
         'KeyPressFcn','figure(gcf)', ...
         'MenuBar','none', ...
         'Name','Statistical Report', ...
         'NumberTitle','off', ...
         'PaperUnits','points', ...
         'Position',figpos, ...
         'Tag','dlgStatReport', ...
         'ToolBar','none', ...
         'DefaultuicontrolUnits','pixels', ...
         'Resize','off');

      if mlversion >= 7
         set(h_dlg,'WindowStyle','normal')
         set(h_dlg,'DockControls','off')
      end

      h = uicontrol('Parent',h_dlg, ...
         'Style','frame', ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[0.95 0.95 0.95], ...
         'Position',[1 1 figpos(3) figpos(4)]);

      h = uicontrol('Parent',h_dlg, ...
         'Style','frame', ...
         'Units','pixels', ...
         'Position',[5 165 610 160], ...
         'BackgroundColor',bgcolor, ...
         'ForegroundColor',[0 0 0]);

      h = uicontrol('Parent',h_dlg, ...
         'Style','frame', ...
         'Units','pixels', ...
         'Position',[5 40 610 120], ...
         'BackgroundColor',bgcolor, ...
         'ForegroundColor',[0 0 0]);

      h = uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[15 294 90 18], ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'HorizontalAlignment','left', ...
         'String','Report File', ...
         'Tag','label');

      h = uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[15 252 130 18], ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'HorizontalAlignment','left', ...
         'String','Title Text', ...
         'Tag','label');

      h = uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[15 175 100 18], ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'HorizontalAlignment','left', ...
         'String','File Format', ...
         'Tag','label');

      h = uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[15 130 100 18], ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'HorizontalAlignment','left', ...
         'String','Extra Reports', ...
         'Tag','label');

      h = uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[15 60 160 18], ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'HorizontalAlignment','left', ...
         'String','Display Missing Values As', ...
         'Tag','label');

      h_editFile = uicontrol('Parent',h_dlg, ...
         'Style','edit', ...
         'Position',[95 292 450 22], ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'String',[pn,fn], ...
         'Tag','editFile', ...
         'UserData',fn, ...
         'Callback','ui_statreport(''file'')');

      h_cmdBrowse = uicontrol('Parent',h_dlg, ...
         'Position',[550 291 50 25], ...
         'Callback','ui_statreport(''browse'')', ...
         'String','Browse', ...
         'TooltipString','Browse to select an output file', ...
         'Tag','cmdBrowse', ...
         'UserData',pn);

      h_editTitle = uicontrol('Parent',h_dlg, ...
         'Style','edit', ...
         'Position',[95 208 500 62], ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'Min',1, ...
         'Max',5, ...
         'HorizontalAlignment','left', ...
         'String',['Column statistics report generated ',datestr(now,1),': ',s.title], ...
         'Tag','editTitle', ...
         'UserData','[ ]');

      h_popFormat = uicontrol('Parent',h_dlg, ...
         'Style','popupmenu', ...
         'Position',[115 174 200 22], ...
         'BackgroundColor',[1 1 1], ...
         'String',[ ...
            'Tab-delimited text         '; ...
            'Comma-separated value (CSV)'; ...
            'Comma-delimited text       '; ...
            'Space-delimited text       '], ...
         'Tag','popFormat', ...
         'Value',formatval, ...
         'Callback','ui_statreport(''format'')', ...
         'UserData',[{'tab'},{'\t'};{'csv'},{','};{'del'},{','};{'del'},{'  '}]);

      h_chkFlags = uicontrol('Parent',h_dlg, ...
         'Style','checkbox', ...
         'Position',[115 130 300 20], ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'BackgroundColor',bgcolor, ...
         'String','Column statistics with flagged values excluded', ...
         'Tag','chkFlags', ...
         'Enable','on');

      h_chkGroup = uicontrol('Parent',h_dlg, ...
         'Style','checkbox', ...
         'Position',[115 100 250 20], ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'BackgroundColor',bgcolor, ...
         'String','Column statistics for all rows grouped by', ...
         'Value',0, ...
         'Callback','ui_statreport(''togglegroup'')', ...
         'Tag','chkFlags', ...
         'Enable','on');

      h_popGroup = uicontrol('Parent',h_dlg, ...
         'Style','popupmenu', ...
         'Position',[370 100 145 22], ...
         'BackgroundColor',[1 1 1], ...
         'String',char(s.name'), ...
         'Value',1, ...
         'Enable','off', ...
         'Tag','popGroup');

      h_popGroupFlags = uicontrol('Parent',h_dlg, ...
         'Style','popupmenu', ...
         'Position',[520 100 80 22], ...
         'BackgroundColor',[1 1 1], ...
         'String',char({'All Values';'Unflagged';'Both'}), ...
         'Value',1, ...
         'Enable','off', ...
         'Tag','popGroupFlags');

      h_editMissing = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'ListboxTop',0, ...
         'Position',[175 60 60 22], ...
         'String','', ...
         'Style','edit', ...
         'Tag','editMissing', ...
         'UserData','[ ]');

      h_cmdClose = uicontrol('Parent',h_dlg, ...
         'Position',[10 10 80 25], ...
         'String','Cancel', ...
         'Tag','cmdClose', ...
         'TooltipString','Cancel the report and close the window', ...
         'Callback','ui_statreport(''close'')', ...
         'UserData','[ ]');

      h_chkClose = uicontrol('Parent',h_dlg, ...
         'Style','checkbox', ...
         'Position',[190 10 280 20], ...
         'BackgroundColor',[0.95 0.95 0.95], ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'String','Close dialog after generating the report file', ...
         'Value',1, ...
         'Tag','chkClose');

      h_cmdExport = uicontrol('Parent',h_dlg, ...
         'Position',[530 10 80 25], ...
         'String','Proceed', ...
         'Tag','cmdExport', ...
         'TooltipString','Create the statistical report', ...
         'Callback','ui_statreport(''export'')', ...
         'Enable',vis, ...
         'UserData',s);

      uih = struct( ...
         'cmdBrowse',h_cmdBrowse, ...
         'editFile',h_editFile, ...
         'editTitle',h_editTitle, ...
         'popFormat',h_popFormat, ...
         'editMissing',h_editMissing, ...
         'chkFlags',h_chkFlags, ...
         'chkGroup',h_chkGroup, ...
         'popGroup',h_popGroup, ...
         'popGroupFlags',h_popGroupFlags, ...
         'cmdClose',h_cmdClose, ...
         'cmdExport',h_cmdExport, ...
         'chkClose',h_chkClose);

      set(h_dlg,'Visible','on','UserData',[{h_fig},{uih}])
      drawnow


   else  %bad structure

      messagebox('init','  Invalid GCE Data Structure  ','','Error',[.9 .9 .9]);

   end

else

   h_dlg = findobj('Tag','dlgStatReport');

   if ~isempty(h_dlg)

      data = get(h_dlg,'UserData');
      h_fig = data{1};
      uih = data{2};

      switch op

         case 'close'

            close(h_dlg)
            drawnow

            if ~isempty(h_fig) & length(findobj)>1
               try
                  figure(h_fig)
               catch
                  ui_aboutgce('reopen')  %check for last window
               end
            else
               ui_aboutgce('reopen')  %check for last window
            end

         case 'file'  %update manual changes to file name

            str = get(uih.editFile,'String');

            [pn,fn,ext] = fileparts(str);

            if ~isempty(fn)
               if exist(pn) == 7
                  set(uih.editFile,'UserData',[fn,ext])
                  set(uih.cmdBrowse,'UserData',[pn,filesep])
                  set(uih.cmdExport,'Enable','on')
                  if ~isempty(ext)
                     filetypes = get(uih.popFormat,'UserData');
                     I = find(strcmp(filetypes(:,1),ext(2:end)));
                     if ~isempty(I)
                        set(uih.popFormat,'Value',I(1))
                     end
                  end
               else
                  set(uih.editFile,'String',[get(uih.cmdBrowse,'UserData'),get(uih.editFile,'UserData')])
                  drawnow
                  messagebox('init','Invalid path specified -- selection reset','','Error',[.9 .9 .9]);
               end
            else
               set(uih.editFile,'UserData','')
               set(uih.cmdExport,'Enable','off')
            end

         case 'browse'  %browse for export file

            pn = get(uih.cmdBrowse,'UserData');
            fn = get(uih.editFile,'UserData');

            if ~isempty(fn)
               [pname,basename,ext] = fileparts(fn);
               if ~isempty(fn)
                  mask = [fn,'; *',ext];
               else
                  mask = '*.txt; *.asc; *.csv; *.rpt';
               end
            else
               mask = '*.txt; *.asc; *.csv; *.rpt';
            end

            try
               cd(pn)
            catch
               cd(curpath)
            end

            [fn,pn] = uiputfile(mask,'Select a file name and location');

            cd(curpath)

            if fn ~= 0  %check for cancel
               set(uih.editFile,'String',[pn,fn],'UserData',fn)
               set(uih.cmdBrowse,'UserData',pn)
               set(uih.cmdExport,'Enable','on')
               [pn,fn,ext] = fileparts(fn);
               if ~isempty(ext)
                  filetypes = get(uih.popFormat,'UserData');
                  I = find(strcmp(filetypes(:,1),ext(2:end)));
                  if ~isempty(I)
                     set(uih.popFormat,'Value',I(1))
                  end
               end
            end

            drawnow

         case 'export'

            s = get(uih.cmdExport,'UserData');
            fn = get(uih.editFile,'UserData');
            pn = get(uih.cmdBrowse,'UserData');

            formatlist = get(uih.popFormat,'UserData');

            formatval = get(uih.popFormat,'Value');
            flagval = get(uih.chkFlags,'Value');
            groupval = get(uih.chkGroup,'Value');
            if groupval == 1
               groupcol = get(uih.popGroup,'Value');
               groupflag = get(uih.popGroupFlags,'Value');
            else
               groupcol = 0;
               groupflag = 0;
            end

            titlestr = get(uih.editTitle,'String');
            if size(titlestr,1) > 1  %concatenate multiple rows
               str = titlestr;
               titlestr = '';
               for n = 1:size(str,1)
                  titlestr = [titlestr,deblank(titlestr(n,:)),' '];
               end
            end
            titlestr = deblank(titlestr);

            missingstr = deblank(get(uih.editMissing,'String'));

            set(gcf,'pointer','watch')
            drawnow

            msg = '';
            msg2 = '';

            %delete existing file to avoid appending
            curpath = pwd;
            try
               cd(pn)
               if exist(fn) == 2
                  delete(fn)
               end
            end
            cd(curpath)

            %generate stat structure, export report with selected options
            stats = colstats(s,'I',0);
            exp_ascii(stats, ...
               formatlist{formatval,1}, ...
               fn, ...
               pn, ...
               titlestr, ...
               'B', ...
               'N', ...
               '', ...
               '', ...
               'N', ...
               missingstr, ...
               formatlist{formatval,2});

            if flagval == 1
               stats = colstats(s,'E',0);
               exp_ascii(stats, ...
                  formatlist{formatval,1}, ...
                  fn, ...
                  pn, ...
                  titlestr, ...
                  'B', ...
                  'N', ...
                  '', ...
                  '', ...
                  'N', ...
                  missingstr, ...
                  formatlist{formatval,2});
            end

            if groupval == 1
               stats1 = [];
               stats2 = [];
               if groupflag == 1
                  stats1 = colstats(s,'I',groupcol);
               elseif groupflag == 2
                  stats1 = colstats(s,'E',groupcol);
               else  %both include & exclude reports
                  stats1 = colstats(s,'I',groupcol);
                  stats2 = colstats(s,'E',groupcol);
               end
               if ~isempty(stats1)
                  exp_ascii(stats1, ...
                     formatlist{formatval,1}, ...
                     fn, ...
                     pn, ...
                     titlestr, ...
                     'B', ...
                     'N', ...
                     '', ...
                     '', ...
                     'N', ...
                     missingstr, ...
                     formatlist{formatval,2});
               end
               if ~isempty(stats2)
                  exp_ascii(stats2, ...
                     formatlist{formatval,1}, ...
                     fn, ...
                     pn, ...
                     titlestr, ...
                     'B', ...
                     'N', ...
                     '', ...
                     '', ...
                     'N', ...
                     missingstr, ...
                     formatlist{formatval,2});
               end

            end

            set(gcf,'pointer','arrow')
            drawnow

            syncpath(pn,'save')  %update path cache

            %report errors
            if ~isempty(msg) | ~isempty(msg)
               if ~isempty(msg)
                  messagebox('init',msg,'','Error',[.9 .9 .9])
               else
                  messagebox('init',msg2,'','Error',[.9 .9 .9])
               end
            else
               closeval = get(uih.chkClose,'Value');
               if closeval == 1
                  ui_statreport('close')
               end
            end

         case 'togglegroup'

            val = get(uih.chkGroup,'Value');

            if val == 0
               set(uih.popGroup,'Enable','off')
               set(uih.popGroupFlags,'Enable','off')
            else
               set(uih.popGroup,'Enable','on')
               set(uih.popGroupFlags,'Enable','on')
            end

      end

   end

end