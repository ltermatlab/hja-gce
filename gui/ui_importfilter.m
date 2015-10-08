function ui_importfilter(op,fn,pn,h_cb,cb)
%Filtered ASCII import dialog used by the GCE Data Toolbox.
%
%syntax: ui_importfilter(op,fn,pn,h_cb,cb)
%
%(c)2002-2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 24-Nov-2014

if nargin == 0
   op = 'init';
end

if strcmp(op,'init')  %create dialog

   %set defaults for omitted input
   if exist('cb','var') ~= 1
      cb = '';
   end

   if exist('h_cb','var') ~= 1
      h_cb = [];
   end

   if exist('pn','var') ~= 1
      pn = '';
   elseif ~isempty(pn)
      if pn(end) ~= filesep
         pn = [pn,filesep];
      end
   end

   if exist('fn','var') ~= 1
      fn = '';
   end

   %check for open instance of dialog
   if length(findobj) > 1
      h_dlg = findobj('Tag','dlgImportFilter');
   else
      h_dlg = [];
   end

   if ~isempty(h_dlg)  %set focus to prior instance

      figure(h_dlg)
      drawnow

   else  %create new instance

      %get handle of calling dialog
      if length(findobj) > 1
         h_fig = gcf;
      else
         h_fig = [];
      end

      %init array of metadata template names
      templates = {'<New Template>'};
      alltemplates = get_templates;
      if ~isempty(alltemplates)
         templates = [templates ; {alltemplates.template}'];
      end

      %get working directory if no path
      if isempty(pn)
         pn = [pwd,filesep];
         if length(findobj) > 1
            h_ed = findobj('Tag','dlgDSEditor');
            if ~isempty(h_ed)
               h_load = findobj(h_ed(end),'Tag','mnuLoad');
               if ~isempty(h_load)
                  pn = get(h_load,'UserData');
               end
            end
         end
      end

      bgcolor = [0.9 0.9 0.9];
      res = get(0,'ScreenSize');

      %create dialog figure
      h_dlg = figure('Visible','off', ...
         'Position',[max([10,0.5.*(res(3)-800)]) max([20,0.5.*(res(4)-630)]) 800 630], ...
         'Color',[0.95 0.95 0.95], ...
         'Name','Custom ASCII Import', ...
         'NumberTitle','off', ...
         'MenuBar','none', ...
         'ToolBar','none', ...
         'Resize','off', ...
         'DefaultuicontrolUnits','pixels', ...
         'KeyPressFcn','figure(gcf)', ...
         'Tag','dlgImportFilter');

      if mlversion >= 7
         set(h_dlg,'WindowStyle','normal')
         set(h_dlg,'DockControls','off')
      end

      uicontrol('Parent',h_dlg, ...
         'Units','pixels', ...
         'BackgroundColor',bgcolor, ...
         'Position',[5 370 790 250], ...
         'Style','frame', ...
         'Tag','Frame1');

      uicontrol('Parent',h_dlg, ...
         'Units','pixels', ...
         'BackgroundColor',bgcolor, ...
         'Position',[5 45 790 315], ...
         'Style','frame', ...
         'Tag','Frame2');

      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'Position',[16 589 100 18], ...
         'String','File to Import', ...
         'Style','text', ...
         'Tag','StaticText1');

      h_editFile = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'Position',[117 588 610 22], ...
         'String',[pn,fn], ...
         'Style','edit', ...
         'Callback','ui_importfilter(''file'')', ...
         'Tag','editFile');

      h_cmdBrowse = uicontrol('Parent',h_dlg, ...
         'Callback','ui_importfilter(''browse'')', ...
         'FontSize',9, ...
         'Position',[735 588 50 25], ...
         'String','Browse', ...
         'Tag','cmdBrowse');

      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'Position',[16 558 100 18], ...
         'String','Column Names', ...
         'Style','text', ...
         'Tag','StaticText1');

      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'Position',[16 525 100 18], ...
         'String','Column Units', ...
         'Style','text', ...
         'Tag','StaticText1');

      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'Position',[16 461 100 18], ...
         'String','Format String', ...
         'Style','text', ...
         'Tag','StaticText1');

      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'Position',[17 494 100 18], ...
         'String','Header Rows', ...
         'Style','text', ...
         'Tag','StaticText1');

      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'HorizontalAlignment','left', ...
         'ForegroundColor',[0 0 0.8], ...
         'Position',[180 494 70 18], ...
         'String','Delimiter', ...
         'Style','text', ...
         'Tag','StaticText1');

      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'HorizontalAlignment','left', ...
         'ForegroundColor',[0 0 0.8], ...
         'Position',[335 494 100 18], ...
         'String','Missing Values', ...
         'Style','text', ...
         'Tag','StaticText1');

      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'String','(e.g. M,NA,9999)', ...
         'Position',[675 494 100 18], ...
         'Style','text', ...
         'Tag','StaticText1');

      h_editColumns = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'Position',[116 556 670 22], ...
         'String','(auto)', ...
         'Style','edit', ...
         'TooltipString','List of column names to assign (must match number of fields in Format String)', ...
         'Tag','editColumns');

      h_editUnits = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'Position',[116 525 670 22], ...
         'String','(none)', ...
         'Style','edit', ...
         'TooltipString','List of column units to assign (must match number of fields in Format String) - ignored if Metadata Template specified', ...
         'Tag','editUnits');

      h_editHeaderRows = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'Position',[117 492 50 22], ...
         'String','0', ...
         'Style','edit', ...
         'TooltipString','Number of header rows to skip before parsing data values', ...
         'Tag','editHeaderRows');

      h_popDelimiter = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'Position',[240 492 75 22], ...
         'Style','popupmenu', ...
         'String',{'auto';'tab';'comma';'space'}, ...
         'Value',1, ...
         'TooltipString','Field delimiter', ...
         'UserData',{'','\t',',',' '}, ...
         'Tag','editMissing');

      h_editMissing = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'Position',[435 492 230 22], ...
         'Style','edit', ...
         'TooltipString','Missing value codes to replace in the data table with NaN', ...
         'Tag','editMissing');

      h_editFormatString = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'Position',[117 460 610 22], ...
         'HorizontalAlignment','left', ...
         'String','(auto)', ...
         'Style','edit', ...
         'TooltipString','MATLAB formatted input string (e.g. %s %d %f %f, where %s = string, %d = integer, %f = floating-point)', ...
         'Tag','editFormatString');

      uicontrol('Parent',h_dlg, ...
         'Callback','ui_importfilter(''format'')', ...
         'FontSize',9, ...
         'Position',[735 460 50 25], ...
         'String','Help', ...
         'Tag','cmdFormatHelp');

      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'Position',[22 429 120 18], ...
         'String','Metadata Template', ...
         'Style','text', ...
         'Tag','StaticText1');

      h_popTemplate = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'Position',[149 428 275 22], ...
         'String',templates, ...
         'Style','popupmenu', ...
         'Tag','popTemplate', ...
         'Callback','ui_importfilter(''template'')', ...
         'TooltipString','Metadata template to apply after importing the data (use <New Template> to define one)', ...
         'Value',1);

      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'Position',[430 429 120 18], ...
         'String','New Template', ...
         'Style','text', ...
         'Tag','StaticText1');

      h_editTemplate = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1],  ...
         'FontSize',9, ...
         'Position',[550 428 235 22], ...
         'HorizontalAlignment','left', ...
         'String','', ...
         'Style','edit', ...
         'TooltipString','Name for the new template', ...
         'Tag','editTemplate');

      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'Position',[20 400 40 18], ...
         'String','Title', ...
         'Style','text', ...
         'Tag','StaticText1');

      h_editTitle = uicontrol('Parent',h_dlg, ...
         'FontSize',9, ...
         'BackgroundColor',[1 1 1], ...
         'ForegroundColor',[0 0 0], ...
         'Position',[60 375 725 45], ...
         'HorizontalAlignment','left', ...
         'Min',1, ...
         'Max',3, ...
         'String','', ...
         'Style','edit', ...
         'TooltipString','Title to apply to the imported data', ...
         'Tag','editTitle');

      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'HorizontalAlignment','left', ...
         'Position',[18 329 90 18], ...
         'String','File Viewer', ...
         'Style','text', ...
         'Tag','StaticText1');

      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'Position',[217 330 50 18], ...
         'String','Rows:', ...
         'Style','text', ...
         'Tag','StaticText1');

      h_editPreviewRows = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'Position',[267 329 52 22], ...
         'String','100', ...
         'Style','edit', ...
         'Enable','off', ...
         'Callback','ui_importfilter(''preview'')', ...
         'Tag','editPreviewRows');

      h_cmdPreview = uicontrol('Parent',h_dlg, ...
         'Callback','ui_importfilter(''preview'')', ...
         'FontSize',9, ...
         'Position',[320 328 50 25], ...
         'String','Update', ...
         'Enable','off', ...
         'TooltipString','Update the data file preview window', ...
         'Tag','cmdPreview');

      h_cmdParseCols = uicontrol('Parent',h_dlg, ...
         'Position',[398 329 95 25], ...
         'Callback','ui_importfilter(''parse_cols_units'')', ...
         'FontSize',9, ...
         'String','Parse Names', ...
         'TooltipString','Parse currently selected file row to generate a list of column names', ...
         'Enable','off', ...
         'Tag','cmdParseCols');

      h_cmdParseUnits = uicontrol('Parent',h_dlg, ...
         'Position',[495 329 95 25], ...
         'Callback','ui_importfilter(''parse_cols_units'')', ...
         'FontSize',9, ...
         'String','Parse Units', ...
         'TooltipString','Parse currently selected file row to generate a list of column units', ...
         'Enable','off', ...
         'Tag','cmdParseUnits');

      h_cmdSetHeader = uicontrol('Parent',h_dlg, ...
         'Callback','ui_importfilter(''setheader'')', ...
         'Position',[592 329 95 25], ...
         'FontSize',9, ...
         'String','Set Header', ...
         'TooltipString','Set ''Header Rows'' based on the current file row selection', ...
         'Enable','off', ...
         'Tag','cmdSetHeader');

      h_cmdParseFormat = uicontrol('Parent',h_dlg, ...
         'Position',[689 329 95 25], ...
         'Callback','ui_importfilter(''parse_format'')', ...
         'FontSize',9, ...
         'String','Parse Format', ...
         'TooltipString','Parse currently selected file row to generate an import format string', ...
         'Enable','off', ...
         'Tag','cmdParseFormat');

      h_listPreview = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'FontName','Courier', ...
         'FontSize',8, ...
         'Position',[15 54 770 266], ...
         'String','<file not loaded>', ...
         'Style','listbox', ...
         'Tag','listPreview', ...
         'Enable','off', ...
         'Value',1);

      h_chkSave = uicontrol('Parent',h_dlg, ...
         'Style','checkbox', ...
         'FontSize',10, ...
         'BackgroundColor',[.95 .95 .95], ...
         'Position',[200 10 400 25], ...
         'String','Create a custom import filter (.m file) based on these selections', ...
         'Value',1, ...
         'Tag','chkSave');

      h_cmdCancel = uicontrol('Parent',h_dlg, ...
         'Callback','ui_importfilter(''cancel'')', ...
         'FontSize',10, ...
         'Position',[5 10 65 25], ...
         'String','Cancel', ...
         'Tag','cmdCancel');

      h_cmdEval = uicontrol('Parent',h_dlg, ...
         'Callback','ui_importfilter(''eval'')', ...
         'FontSize',10, ...
         'Position',[720 10 65 25], ...
         'String','Proceed', ...
         'Enable','off', ...
         'Tag','cmdEval');

      %init structure of GUI object handles for value retrieval
      uih = struct( ...
         'h_fig',h_fig, ...
         'cmdEval',h_cmdEval, ...
         'cmdCancel',h_cmdCancel, ...
         'cmdBrowse',h_cmdBrowse, ...
         'cmdPreview',h_cmdPreview, ...
         'cmdSetHeader',h_cmdSetHeader, ...
         'cmdParseFormat',h_cmdParseFormat, ...
         'cmdParseCols',h_cmdParseCols, ...
         'cmdParseUnits',h_cmdParseUnits, ...
         'popDelimiter',h_popDelimiter, ...
         'editFile',h_editFile, ...
         'editFormatString',h_editFormatString, ...
         'editColumns',h_editColumns, ...
         'editUnits',h_editUnits, ...
         'editHeaderRows',h_editHeaderRows, ...
         'editMissing',h_editMissing, ...
         'editPreviewRows',h_editPreviewRows, ...
         'editTitle',h_editTitle, ...
         'chkSave',h_chkSave, ...
         'popTemplate',h_popTemplate, ...
         'editTemplate',h_editTemplate, ...
         'listPreview',h_listPreview, ...
         'templates',{templates}, ...
         'pn',pn, ...
         'fn',fn, ...
         'h_cb',h_cb, ...
         'cb',cb);

      set(h_dlg,'UserData',uih,'Visible','on')

      %call button state check routine
      ui_importfilter('buttons')

   end

else

   %get handle of dialog
   h_dlg = findobj('Tag','dlgImportFilter');

   if ~isempty(h_dlg)

      %get cached GUI data
      uih = get(h_dlg,'UserData');
      curpath = pwd;

      switch op

      case 'cancel'  %close dialog without evaluating

         figure(h_dlg)
         close(h_dlg)
         drawnow

         if ~isempty(uih.h_cb)
            h_fig = parent_figure(uih.h_cb);
            if ~isempty(h_fig)
               figure(h_fig)
               drawnow
            else
               ui_aboutgce('reopen')  %check for last window
            end
         end

      case 'eval'  %import file

         %get dialog values from uicontrols
         fstr = deblank(get(uih.editFormatString,'String'));
         if strcmp(fstr,'(auto)')
            fstr = '';
         end

         collist = deblank(get(uih.editColumns,'String'));
         if strcmp(collist,'(auto)')
            collist = '';
         end

         unitlist = deblank(get(uih.editUnits,'String'));
         if strcmp(unitlist,'(none)')
            unitlist = '';
         end

         headerrows = str2double(get(uih.editHeaderRows,'String'));
         if isempty(headerrows)
            headerrows = 0;
         else
            headerrows = fix(headerrows);
         end
         
         %get delimiter from popupmenu list
         delimval = get(uih.popDelimiter,'Value');
         delimopt = get(uih.popDelimiter,'UserData');
         delim = delimopt{delimval};

         missing = deblank(get(uih.editMissing,'String'));

         titlestr = deblank(get(uih.editTitle,'String'));

         saveopt = get(uih.chkSave,'Value');

         Itemplate = get(uih.popTemplate,'Value');
         new_template = 0;
         if Itemplate > 1
            template = uih.templates{Itemplate};
         else
            template = trimstr(get(uih.editTemplate,'String'));
            if ~isempty(template)
               template = strrep(template,' ','_');
               new_template = 1;
            end
         end

         %perform data import
         set(h_dlg,'Pointer','watch'); drawnow

         if new_template == 0
            [s,msg] = imp_ascii(uih.fn,uih.pn,'',template,fstr,collist,headerrows,missing,delim);
         else  %pass blank template to force auto-evaluation of column data types
            [s,msg] = imp_ascii(uih.fn,uih.pn,'','',fstr,collist,headerrows,missing,delim);
         end
         set(h_dlg,'Pointer','arrow'); drawnow

         if ~isempty(s)

            %generate title
            if ~isempty(titlestr)
               s = newtitle(s,titlestr,1);
            else
               titlestr = lookupmeta(s,'Dataset','Title');
               if ~isempty(titlestr)
                  s.title = titlestr;
               end
            end
            
            %add units if no template or new template specified
            if (new_template == 1 || isempty(template)) && ~isempty(unitlist)
               units = splitstr(unitlist,',',0,1);  %split unit string into cell array
               if length(units) == length(s.units)
                  s.units = units(:)';  %use parsed units, forcing row array
               end
            end

            %close dialog
            delete(h_dlg)
            drawnow

            err = 0;
            msg = '';

            %evaluate callback
            if isempty(uih.h_cb)
               err = 1;
            else
               h_fig = parent_figure(uih.h_cb);
               if ~isempty(h_fig)
                  figure(h_fig)
                  set(uih.h_cb,'UserData',s)
               end
               if ~isempty(uih.cb)
                  try
                     eval(uih.cb)
                  catch
                     err = 1;
                  end
                  if err == 1
                     msg = 'An error occurred executing the callback function - structure opened in a new editor window';
                  end
               end
            end

            if err == 1
               ui_editor('init',s)
               if ~isempty(msg)
                  messagebox('init',msg,'','Warning',[.9 .9 .9]);
               end
            end

            %synchronize load path with open editor windows
            syncpath(uih.pn,'load')

            %check for option to save import filter as .m file - call subroutine
            if saveopt == 1
               drawnow
               subfun_makemfile(s,fstr,collist,headerrows,delim,missing,template,unitlist,new_template,titlestr,uih.fn);
            elseif new_template == 1
               subfun_addtemplate(s,template)
            end

         else
            messagebox('init',msg,'','Error',[.9 .9 .9])
         end

      case 'format'  %open format string help

         if exist('ui_importfilter.mat','file') == 2
            try
               v = load('ui_importfilter.mat','-mat');
            catch
               v = struct('null','');
            end
            if isfield(v,'formathelp');
               viewtext(v.formathelp,0,0,'Format String Help')
            end
         else
            messagebox('init','Settings file ''ui_import_filter.mat'' was not found - help not available', ...
               [],'','Error',[.95 .95 .95])
         end

      case 'browse'  %browse for a data file

         cd(uih.pn)
         [fn,pn] = uigetfile('*.txt;*.csv;*.asc;*.dat;*.ans;*.prn','Select an ASCII file to import');
         cd(curpath)
         drawnow

         if fn ~= 0

            uih.fn = fn;
            uih.pn = pn;
            set(h_dlg,'UserData',uih)
            set(uih.editFile,'String',[pn,fn])

            ui_importfilter('buttons')

            ui_importfilter('fileview')

         end

      case 'file'  %open a manually-entered data file

         fnpn = get(uih.editFile,'String');

         if ~isempty(fnpn)
            if exist(fnpn,'file') == 2
               [pn,basefn,ext] = fileparts(fnpn);
               uih.fn = [basefn,ext];
               uih.pn = pn;
               set(h_dlg,'UserData',uih)
            end
         end

         ui_importfilter('buttons')

         ui_importfilter('fileview')

      case 'preview'  %update file preview

         %get rows option from dialog
         numrows = str2double(get(uih.editPreviewRows,'String'));
         if ~isempty(numrows)
            numrows = fix(numrows);
         else
            numrows = 0;
         end

         if numrows > 0

            set(h_dlg,'Pointer','watch'); drawnow
            str = cellstr(int2str((1:numrows)'));
            errmsg = '';

            %try to read file, generate formatted preview
            try
               fid = fopen([uih.pn,filesep,uih.fn],'r');
               for n = 1:numrows
                  ln = fgetl(fid);
                  if ~isempty(ln)
                     if ln ~= -1  %check for eof
                        str{n} = [str{n},':  ',strrep(ln,char(9),'<tab>')];  %generate preview line with row number, <tab> tokens
                     else
                        str = str(1:n-1);  %truncate array
                        break
                     end
                  end
               end
               fclose(fid);
               set(uih.listPreview,'String',str)
               drawnow
            catch
               errmsg = 'The file could not be opened for reading - preview cancelled';
            end

            set(h_dlg,'Pointer','arrow'); drawnow
            
            if ~isempty(errmsg)
               messagebox('init',errmsg,'','Error',[0.9 0.9 0.9]);
            end

         else
            set(uih.listPreview,'String','<no file loaded>','Value',1,'ListboxTop',1)
            drawnow
         end

         ui_importfilter('buttons')

      case 'setheader'  %set header rows based on current row

         numrows = get(uih.listPreview,'Value');
         set(uih.editHeaderRows,'String',int2str(numrows))
         drawnow

      case 'parse_format'  %parse format string from current row

         %get string from preview record
         str = get(uih.listPreview,'String');
         rownum = get(uih.listPreview,'Value');

         if ~isempty(str)
            
            ln = trimstr(str{rownum});  %get selected row from preview
            
            [tmp,ln] = strtok(ln,' ');  %strip row number
            
            ln = trimstr(ln);  %remove leading space
            
            %determine delimiter
            if ~isempty(strfind(ln,'<tab>'))
               delim = 'tab';
               ln = strrep(ln,'<tab>',',');  %replace tabs with commas for field parsing
            elseif ~isempty(strfind(ln,','))
               delim = 'comma';
            else
               delim = 'space';
               ln = regexprep(ln,'\s*',',');  %replace sequences of spaces with single comma
            end
            
            %split fields into array
            ar = splitstr(ln,',',0);
            
            if ~isempty(ar)
               
               %update delimiter menu selection based on parsed delimiter
               delims = get(uih.popDelimiter,'String');
               Idelim = find(strcmp(delim,delims));
               if isempty(Idelim)
                  Idelim = 1;  %set auto if not matched
               end
               set(uih.popDelimiter,'Value',Idelim)
                  
               %init format string
               fstr = '';
               
               %loop through fields sniffing format
               for n = 1:length(ar)
                  tkn = upper(ar{n});
                  if ~isempty(tkn)
                     if ~isnan(str2double(tkn(1))) && (~isempty(strfind(tkn,'E+')) || ~isempty(strfind(tkn,'E-')))
                        fstr = [fstr,'%e '];  %check for exponential notation if first character numeric
                     elseif strcmp(tkn,'NAN')
                        fstr = [fstr,'%f '];  %catch NaN - default to f
                     elseif ~isnan(str2double(tkn))
                        if ~isempty(strfind(tkn,'.'))
                           fstr = [fstr,'%f '];
                        else
                           fstr = [fstr,'%d '];
                        end
                     else  %string or empty field
                        if isempty(strfind(tkn,'"'))
                           fstr = [fstr,'%s '];
                        else
                           fstr = [fstr,'%q '];
                        end
                     end
                  else
                     fstr = [fstr,'%s '];
                  end
               end
               
               %update format string editbox
               set(uih.editFormatString,'String',deblank(fstr))
               
               drawnow
               
            end
            
         end

      case 'parse_cols_units'  %parse column names or units from current row
         
         %get handle of button that was pushed to determine field to update
         tag = get(gcbo,'Tag');

         %get row from preview listbox
         str = get(uih.listPreview,'String');
         rownum = get(uih.listPreview,'Value');

         if ~isempty(str)

            %remove leading row number and leading/trailing spaces
            ln = trimstr(str{rownum});
            [tmp,ln] = strtok(ln,' ');
            
            %replace encoded tabs with commas
            ln = strrep(ln,'<tab>',',');  
            
            %check for space-delimited names only - replace with commas
            if isempty(strfind(ln,','))
               ln = regexprep(ln,'\s*',',');
            end

            %split names
            ln = regexprep(ln,'"\s*','"');  %remove padding between quotes and text 
            ar = splitstr(ln,',',0)';  %split string on commas, preserving empty fields
            ar = strrep(strrep(strrep(ar,'(',''),')',''),'"','');  %remove parentheses and quotes
            
            %fill in 'none' for empty fields
            ar(cellfun('isempty',ar)) = {'none'}';
            
            %update field
            if ~isempty(ar)
               str = char(concatcellcols(ar,','));  %convert array to comma-delimited string
               if ~isempty(str)
                  if strcmp(tag,'cmdParseCols')
                     set(uih.editColumns,'String',str)
                  else  %units
                     set(uih.editUnits,'String',str)
                  end
                  drawnow
               end
            end
            
         end

      case 'buttons'  %update button status

         fn = get(uih.editFile,'String');

         if isempty(fn)
            vis = 'off';
         elseif exist(fn,'file') ~= 2
            vis = 'off';
         else
            vis = 'on';
         end

         set(uih.cmdPreview,'Enable',vis)
         set(uih.listPreview,'Enable',vis)
         set(uih.editPreviewRows,'Enable',vis)
         set(uih.cmdEval,'Enable',vis)

         if ~strcmp(get(uih.editPreviewRows,'String'),'0')
            set(uih.cmdSetHeader,'Enable',vis)
            set(uih.cmdParseFormat,'Enable',vis)
            set(uih.cmdParseCols,'Enable',vis)
            set(uih.cmdParseUnits,'Enable',vis)
         else
            set(uih.cmdSetHeader,'Enable','off')
            set(uih.cmdParseFormat,'Enable','off')
            set(uih.cmdParseCols,'Enable','off')
            set(uih.cmdParseCols,'Enable','off')
         end

         drawnow

      case 'fileview'

         if ~strcmp(uih.editPreviewRows,'0') && strcmpi(get(uih.listPreview,'Enable'),'on')
            ui_importfilter('preview')
         else
            set(uih.listPreview,'String','<no file loaded>','Value',1,'ListboxTop',1)
         end

         drawnow

      case 'template'

         templateval = get(uih.popTemplate,'Value');

         if templateval > 1
            set(uih.editTemplate,'String','','Enable','off')
         else
            set(uih.editTemplate,'Enable','on')
         end

      end

   end

end

%subfunction for generating custom import filter
function subfun_makemfile(s,fstr,collist,headerrows,delim,missing,template,unitlist,new_template,titlestr,filename)

%escape commas in collist and unitlist
collist = strrep(collist,'''','''''');
unitlist = strrep(unitlist,'''','''''');
titlestr = strrep(titlestr,'''','''''');

%prompt for filename and path (default to userdata directory)
curpath = pwd;
pn = [gce_homepath,filesep,'userdata'];
if isdir(pn)
   cd(pn)
end
[fn,pn] = uiputfile('*.m','Select a name and location for the new import filter');
cd(curpath)
drawnow

%check for cancel
if ischar(fn)

   %open .m file for writing
   [tmp,fn_base] = fileparts(fn);
   fid = fopen([pn,filesep,fn_base,'.m'],'w');

   %generate program
   fprintf(fid,'%s\r\n',['function [s,msg] = ',fn_base,'(fn,pn,template,titlestr)']);
   fprintf(fid,'%s\r\n',['%Custom text file import filter for the GCE Data Toolbox generated on ',datestr(now,1)]);
   fprintf(fid,'%s\r\n',['%based on a user-defined filter for ''',filename,'''']);
   fprintf(fid,'%s\r\n','%');
   fprintf(fid,'%s\r\n',['%syntax:  [s,msg] = ',fn_base,'(fn,pn,template,title)']);
   fprintf(fid,'%s\r\n','%');
   fprintf(fid,'%s\r\n','%inputs:');
   fprintf(fid,'%s\r\n','%  fn = file name to import (default = prompted)');
   fprintf(fid,'%s\r\n','%  pn = pathname for fn (default = pwd)');
   fprintf(fid,'%s\r\n',['%  template = metadata template (default = ''',template,''')']);
   fprintf(fid,'%s\r\n',['%  title = data set title (default = ''',titlestr,''')']);
   fprintf(fid,'%s\r\n','%');
   fprintf(fid,'%s\r\n','%outputs:');
   fprintf(fid,'%s\r\n','%  s = GCE Data Structure');
   fprintf(fid,'%s\r\n','%  msg = text of any error messages');
   fprintf(fid,'%s\r\n','%');
   fprintf(fid,'%s\r\n',['%created: ',datestr(now)]);
   fprintf(fid,'%s\r\n','');
   fprintf(fid,'%s\r\n','%initialize outputs:');
   fprintf(fid,'%s\r\n','s = [];');
   fprintf(fid,'%s\r\n','msg = '''';');
   fprintf(fid,'%s\r\n','');
   fprintf(fid,'%s\r\n','%define runtime variables');
   fprintf(fid,'%s\r\n','curpath = pwd;');
   fprintf(fid,'%s\r\n',['format_string = ''',fstr,''';']);
   fprintf(fid,'%s\r\n',['column_names = ''',collist,''';']);
   fprintf(fid,'%s\r\n',['unitlist = ''',unitlist,''';']);
   fprintf(fid,'%s\r\n',['num_header_rows = ',int2str(headerrows),';']);
   fprintf(fid,'%s\r\n',['delimiter = ''',delim,''';']);
   fprintf(fid,'%s\r\n',['missing_codes = ''',missing,''';']);
   fprintf(fid,'%s\r\n','');
   fprintf(fid,'%s\r\n','%specify empty template unless provided as input');
   fprintf(fid,'%s\r\n','if exist(''template'',''var'') ~= 1');
   fprintf(fid,'%s\r\n',['   template = ''',template,''';']);
   fprintf(fid,'%s\r\n','end');
   fprintf(fid,'%s\r\n','');
   fprintf(fid,'%s\r\n','%specify default title unless provided as input');
   fprintf(fid,'%s\r\n','if exist(''titlestr'',''var'') ~= 1');
   fprintf(fid,'%s\r\n',['   titlestr = ''',titlestr,''';']);
   fprintf(fid,'%s\r\n','end');
   fprintf(fid,'%s\r\n','');
   fprintf(fid,'%s\r\n','%validate path');
   fprintf(fid,'%s\r\n','if exist(''pn'',''var'') ~= 1');
   fprintf(fid,'%s\r\n','   pn = curpath;');
   fprintf(fid,'%s\r\n','elseif ~isdir(pn)');
   fprintf(fid,'%s\r\n','   pn = curpath;');
   fprintf(fid,'%s\r\n','else');
   fprintf(fid,'%s\r\n','   pn = clean_path(pn);  %strip terminal file separator');
   fprintf(fid,'%s\r\n','end');
   fprintf(fid,'%s\r\n','');
   fprintf(fid,'%s\r\n','%validate filename');
   fprintf(fid,'%s\r\n','if exist(''fn'',''var'') ~= 1');
   fprintf(fid,'%s\r\n','   fn = '''';');
   fprintf(fid,'%s\r\n','end');
   fprintf(fid,'%s\r\n','if isempty(fn)');
   fprintf(fid,'%s\r\n','   filespec = ''*.txt;*.asc;*.csv;*.dat;*.prn;*.ans'';  %use standard text file specifier');
   fprintf(fid,'%s\r\n','elseif exist([pn,filesep,fn],''file'') ~= 2');
   fprintf(fid,'%s\r\n','   filespec = fn;  %use unlocated filename as file specifier');
   fprintf(fid,'%s\r\n','   fn = '''';');
   fprintf(fid,'%s\r\n','end');
   fprintf(fid,'%s\r\n','');
   fprintf(fid,'%s\r\n','%prompt for file if omitted or invalid');
   fprintf(fid,'%s\r\n','if isempty(fn)');
   fprintf(fid,'%s\r\n','   cd(pn)');
   fprintf(fid,'%s\r\n','   [fn,pn] = uigetfile(filespec,''Select a text file to import'');');
   fprintf(fid,'%s\r\n','   cd(curpath)');
   fprintf(fid,'%s\r\n','   drawnow');
   fprintf(fid,'%s\r\n','end');
   fprintf(fid,'%s\r\n','');
   fprintf(fid,'%s\r\n','%pass filename, pathname, and static parameters to custom ASCII import filter');
   fprintf(fid,'%s\r\n','if fn ~= 0');
   fprintf(fid,'%s\r\n','');
   fprintf(fid,'%s\r\n','   %import the data file');
   fprintf(fid,'%s\r\n','   [s,msg] = imp_ascii(fn,pn,titlestr,template,format_string,column_names,num_header_rows,missing_codes,delimiter);');
   fprintf(fid,'%s\r\n','');
   fprintf(fid,'%s\r\n','   %update the title');
   fprintf(fid,'%s\r\n','   if ~isempty(s) && ~isempty(titlestr)');
   fprintf(fid,'%s\r\n','      s = newtitle(s,titlestr);');
   fprintf(fid,'%s\r\n','   end');
   fprintf(fid,'%s\r\n','');
   fprintf(fid,'%s\r\n','  %add units if no template specified');
   fprintf(fid,'%s\r\n','  if isempty(template) && ~isempty(unitlist)');
   fprintf(fid,'%s\r\n','     units = splitstr(unitlist,'','',0,1);  %split unit string into cell array');
   fprintf(fid,'%s\r\n','     if length(units) == length(s.units)');
   fprintf(fid,'%s\r\n','        s.units = units(:)'';  %use parsed units, forcing row array');
   fprintf(fid,'%s\r\n','     end');
   fprintf(fid,'%s\r\n','  end');
   fprintf(fid,'%s\r\n','');
   fprintf(fid,'%s\r\n','   %add custom post-processing commands below this line');
   fprintf(fid,'%s\r\n','');
   fprintf(fid,'%s\r\n','else');
   fprintf(fid,'%s\r\n','   msg = ''import cancelled'';');
   fprintf(fid,'%s\r\n','end');

   fclose(fid);

   %generate status message
   msg = ['Your custom text file import filter was created and saved as ''',fn_base,'.m'''];
   msg2 = '';

   %add custom import filter to master list
   filters = get_importfilters;
   
   if isstruct(filters)
      
      %insert entry for new filter
      data2 = insertrows(filters,{'User-Defined Text File Format',[fn_base,' (',datestr(now,1),')'], ...
         '*.txt;*.asc;*.csv;*.ans;*.prn;*.dat','Specify a text file to import',fn_base,template}, ...
         {'Label','Subheading','Filemask','Fileprompt','Mfile','Argument1'});
      
      %backup and save filters database
      if ~isempty(data2)
         data = filters;
         fn2 = which('imp_filters.mat');
         save([fn2,'.bak'],'data')  %back up existing filters
         data = data2;
         save(fn2,'data')  %save updated import filters
         edit_importfilters('eval',data);  %call edit_importfilters without envoking GUI dialog
         msg2 = 'and added to the standard list of filters in ''imp_filters.mat''';
      end
      
   end

   %display error messages
   if ~isempty(msg2)
      msg = char(msg,msg2);
   end

   %check for new template flag, call template editor GUI
   if new_template == 1
      subfun_addtemplate(s,template)
   end

   %display new filter status message
   messagebox('init',msg,'','Information',[.9 .9 .9])

end


%subfunction for adding new metadata template
function subfun_addtemplate(s,template_name)

template.template = template_name;
if gce_valid(s,'data')
   template.variable = s.name';
   template.name = s.name';
   template.units = s.units';
   template.description = s.description';
   template.datatype = s.datatype';
   template.variabletype = s.variabletype';
   template.numbertype = s.numbertype';
   template.precision = s.precision';
   template.criteria = s.criteria';
   template.codes = repmat({''},length(s.name),1);
   template.metadata = s.metadata;
else
   template.variable = {''};
   template.name = {''};
   template.units = {''};
   template.description = {''};
   template.datatype = {'u'};
   template.variabletype = {''};
   template.numbertype = {''};
   template.precision = 0;
   template.criteria = {''};
   template.codes = repmat({''},length(s.name),1);
   template.metadata = [];
end

ui_template('init',template)
drawnow
