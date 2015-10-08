function ui_visualqc(op,data)
%Dialog for assigning and clearing QC/QA flags visually by clicking on data points with the mouse.
%The calling function must pass a structure containing a valid GCE Data Structure and additional
%plot parameters as fields (see arguments), or the structure must be present in the 'userdata'
%property of the active figure. (note: plots of encoded text columns are not supported)
%
%syntax: ui_visualqc(op,qc_data)
%
%inputs:
%  'op' = operation ('init' to initialize the dialog)
%  'qc_data' = data structure containing the following fields:
%     's' - GCE Data Structure
%     'x' - scalar integer indicating x column of plot
%     'y' - array of integers indicating y column(s) of plot
%     'Igroups' - index containing the starting position of each group (plotgroups only)
%     'groupnames' - cell array of group names, descriptions (plotgroups only)
%     'rotate' - value indicating whether plot is rotated with x as the ordinate
%        and y as the abscissa (0 = no, 1 = yes)
%     'scalefactor' - array of value scaling factors for auto-scaled plots (1 = not scaled)
%
%outputs:
%  none
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
%last modified: 03-Jul-2014

if exist('op','var') ~= 1
   op = 'init';
end

if strcmp(op,'init')

   if length(findobj) > 1
      h_fig = gcf;
      h_ax = gca;
      h_dlg = findobj('tag','dlgVisualQC');
   else
      h_dlg = [];
   end

   if ~isempty(h_dlg)

      figure(h_dlg)  %just set focus to existing dialog to avoid multiple instances, update anomalies

   else

      if exist('data','var') ~= 1
         data = get(h_fig,'UserData');  %get data from figure userdata
      end

      %init list of columns, flags
      collist = ' ';
      flaglist = ' ';
      flagcodes = [];
      s = [];

      %validate input
      if isstruct(data)

         if isfield(data,'s') && isfield(data,'x') && isfield(data,'y') && isfield(data,'rotate')

            %add optional fields if necessary
            if ~isfield(data,'Igroups'); data.Igroups = []; end
            if ~isfield(data,'groupnames'); data.groupnames = []; end
            if ~isfield(data,'scalefactor'); data.scalefactor = ones(length(data.y)); end

            s = data.s;

            %generate list of plot columns, flags from input and stored metadata
            if gce_valid(s,'data')
               try
                  if isempty(data.groupnames)
                     collist = s.name(data.y);
                  else
                     collist = data.groupnames;
                  end
               catch
                  %skip group option
               end
               anomstr = lookupmeta(s,'Data','Anomalies');
               flagstr = lookupmeta(s,'Data','Codes');
               if ~isempty(flagstr)
                  if ~isempty(strfind(flagstr,'|'))
                     flaglist = splitstr(flagstr,'|');
                  elseif ~isempty(strfind(flagstr,';'))
                     flaglist = splitstr(flagstr,';');
                  else
                     flaglist = splitstr(flagstr,',');
                  end
                  for n = 1:length(flaglist)
                     tmp = splitstr(flaglist{n},'=');
                     if length(tmp) == 2
                        newcode = tmp{1};
                        flagcodes = [flagcodes ; {newcode(1)}];
                     else
                        flaglist{n} = ' ';
                     end
                  end
                  I = find(~cellfun('isempty',flaglist));
                  if ~isempty(I)
                     flaglist = flaglist(I);
                  else
                     flaglist = ' ';
                  end
               end
            else
               s = [];  %clear variable for validity test
            end
         end
      end

      if ~isempty(s)

         %create dialog
         res = get(0,'ScreenSize');
         figpos = get(h_fig,'Position');
         bgcolor = [.9 .9 .9];

         h_dlg = figure('Name','Visual QC/QA Tool', ...
            'Position',[min(res(3)-505,figpos(1)+figpos(3)-300) ...
               min(res(4)-480,figpos(2)+figpos(4)-370) 500 480], ...
            'Color',[0.95 0.95 0.95], ...
            'KeyPressFcn','figure(gcf)', ...
            'MenuBar','none', ...
            'NumberTitle','off', ...
            'ToolBar','none', ...
            'Tag','dlgVisualQC', ...
            'Resize','off', ...
            'DefaultuicontrolUnits','pixels');

         if mlversion >= 7
            set(h_dlg,'WindowStyle','normal')
            set(h_dlg,'DockControls','off')
         end

         axis off

         uicontrol('Parent',h_dlg, ...
            'Style','frame', ...
            'BackgroundColor',bgcolor, ...
            'ForegroundColor',[0 0 0], ...
            'Position',[5 295 490 180], ...
            'Tag','frame2');

         uicontrol('Parent',h_dlg, ...
            'Style','frame', ...
            'BackgroundColor',bgcolor, ...
            'ForegroundColor',[0 0 0], ...
            'Position',[5 40 490 250], ...
            'Tag','frame1');

         %generate appropriate label for dialog depending on mode
         if isempty(data.Igroups)
            lblcolumn = 'Data Column to Flag';
         else
            lblcolumn = 'Data Group to Flag';
         end

         uicontrol('Parent',h_dlg, ...
            'BackgroundColor',bgcolor, ...
            'FontSize',10, ...
            'FontWeight','bold', ...
            'ForegroundColor',[0 0 0.8], ...
            'Position',[10 438 160 18], ...
            'String',lblcolumn, ...
            'Style','text', ...
            'Tag','lblColumn');

         h_popColumn = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'FontSize',9, ...
            'Position',[170 438 230 20], ...
            'String',collist, ...
            'Style','popupmenu', ...
            'Tag','popColumn', ...
            'Value',1);

         uicontrol('Parent',h_dlg, ...
            'BackgroundColor',bgcolor, ...
            'FontSize',10, ...
            'FontWeight','bold', ...
            'ForegroundColor',[0 0 0.8], ...
            'Position',[10 400 160 18], ...
            'String','Flag Code to Assign', ...
            'Style','text', ...
            'Tag','StaticText1');

         h_popFlags = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'FontSize',9, ...
            'Position',[170 400 230 20], ...
            'String',flaglist, ...
            'Style','popupmenu', ...
            'Tag','popFlags', ...
            'Value',1, ...
            'UserData',flagcodes);

         h_editNewCode = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'HorizontalAlignment','left', ...
            'Callback','ui_visualqc(''newcode'')', ...
            'Position',[170 369 30 20], ...
            'Style','edit', ...
            'Tag','editNewCode');

         uicontrol('Parent',h_dlg, ...
            'BackgroundColor',bgcolor, ...
            'FontSize',10, ...
            'FontWeight','bold', ...
            'ForegroundColor',[0 0 0.8], ...
            'Position',[200 369 20 18], ...
            'String','=', ...
            'Style','text', ...
            'Tag','StaticText1');

         h_editNewDef = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'Position',[220 369 180 20], ...
            'Style','edit', ...
            'HorizontalAlignment','left', ...
            'Tag','editNewDef');

         h_cmdAddCode = uicontrol('Parent',h_dlg, ...
            'Callback','ui_visualqc(''addcode'')', ...
            'Position',[410 369 60 22], ...
            'String','Add Code', ...
            'Tag','cmdAddCode');

         h_cmdPlot = uicontrol('Parent',h_dlg, ...
            'Callback','ui_visualqc(''plot'')', ...
            'FontSize',9, ...
            'FontWeight','bold', ...
            'Position',[125 330 250 25], ...
            'String','Return to Plot Figure and Assign Flags', ...
            'Tag','cmdPlot', ...
            'TooltipString','Activate the plot figure and assign/clear flags using the mouse');

         uicontrol('Parent',h_dlg, ...
            'BackgroundColor',bgcolor, ...
            'FontSize',9, ...
            'FontWeight','bold', ...
            'ForegroundColor',[0 0 0.8], ...
            'Position',[10 300 480 18], ...
            'String','(Note: Left click/drag to assign flags, right click/drag to clear flags)', ...
            'Style','text', ...
            'Tag','StaticText1');

         uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'HorizontalAlignment','left', ...
            'BackgroundColor',bgcolor, ...
            'FontSize',10, ...
            'FontWeight','bold', ...
            'ForegroundColor',[0 0 0.8], ...
            'Position',[15 265 300 18], ...
            'String','Data Anomalies Metadata', ...
            'Tag','StaticText1');

         h_cmdSummarize = uicontrol('Parent',h_dlg, ...
            'Style','pushbutton', ...
            'Position',[20 235 120 22], ...
            'FontSize',9, ...
            'String','Auto-Summarize', ...
            'Tag','cmdSummarize', ...
            'Callback','ui_visualqc(''summarize'')');

         h_chkMissing = uicontrol('Parent',h_dlg, ...
            'Style','checkbox', ...
            'Position',[150 235 120 20], ...
            'FontSize',9, ...
            'ForegroundColor',[0 0 0], ...
            'BackgroundColor',bgcolor, ...
            'String','Include Missing', ...
            'TooltipString','Include a summary of missing values by parameter', ...
            'Value',1, ...
            'Tag','chkMissing');

         uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'Position',[275 234 50 18], ...
            'FontSize',9, ...
            'FontWeight','bold', ...
            'String','Format', ...
            'ForegroundColor',[0 0 .8], ...
            'BackgroundColor',bgcolor);

         %generate date grouping options based on matlab version to accomodate datestr differences
         mlver = mlversion;
         if mlver > 5
            fmtstr = {'no date grouping';'mm/dd/yyyy';'dd-mmm-yyyy';'dd-mmm-yyyy HH:MM:SS';'yyyy-mm-dd HH:MM:SS'};
            fmtdata = {[],'';23,'-';1,' to ';0,' to ';31,' to '};
            fmtval = 2;
         else
            fmtstr = {'no date grouping';'dd-mmm-yyyy';'dd-mmm-yyyy HH:MM:SS'};
            fmtdata = {[],'';1,' to ';0,' to '};
            fmtval = 2;
         end

         h_popSummarize = uicontrol('Parent',h_dlg, ...
            'Style','popupmenu', ...
            'Position',[330 235 150 20], ...
            'BackgroundColor',[1 1 1], ...
            'ForegroundColor',[0 0 0], ...
            'FontSize',9, ...
            'String',fmtstr, ...
            'Value',fmtval, ...
            'Tag','popSummarize', ...
            'UserData',fmtdata);
         
         %check for excessive anomalies text
         errmsg = '';
         if length(anomstr) > 100000
            errmsg = ['Warning: anomalies text exceeding 100000 characters cannot be displayed (remaining ', ...
               int2str(length(anomstr)-100000),' characters truncated)'];
            anomstr = anomstr(1:100000);
         end

         h_editAnomalies = uicontrol('Parent',h_dlg, ...
            'Style','edit', ...
            'HorizontalAlignment','left', ...
            'BackgroundColor',[1 1 1], ...
            'FontSize',9, ...
            'FontWeight','normal', ...
            'ForegroundColor',[0 0 0], ...
            'Position',[20 48 460 180], ...
            'String',anomstr, ...
            'Min',1, ...
            'Max',10, ...
            'Tag','editAnomalies');

         h_cmdCancel = uicontrol('Parent',h_dlg, ...
            'Callback','ui_visualqc(''cancel'')', ...
            'FontSize',9, ...
            'FontWeight','bold', ...
            'Position',[5 5 80 25], ...
            'String','Cancel', ...
            'Tag','cmdCancel', ...
            'TooltipString','Close the tool window and cancel the flag assignment');

         h_chkClose = uicontrol('Parent',h_dlg, ...
            'Style','checkbox', ...
            'FontSize',9, ...
            'FontWeight','bold', ...
            'Position',[120 5 290 20], ...
            'ForegroundColor',[0 0 0], ...
            'BackgroundColor',[.95 .95 .95], ...
            'String','Automatically close plot dialogs on Accept', ...
            'Value',1, ...
            'Tag','chkClose');

         h_cmdEval = uicontrol('Parent',h_dlg, ...
            'Callback','ui_visualqc(''eval'')', ...
            'FontSize',9, ...
            'FontWeight','bold', ...
            'Position',[415 5 80 25], ...
            'String','Accept', ...
            'Tag','cmdEval', ...
            'TooltipString','Accept manual QC assignments and open the structure in a new editor window');

         %cache ui handles for callbacks
         uih = struct( ...
            'h_fig',h_fig, ...
            'h_ax',h_ax, ...
            'data',data, ...
            'flagrows',[NaN NaN], ...
            'unflagrows',[NaN NaN], ...
            'popColumn',h_popColumn, ...
            'popFlags',h_popFlags, ...
            'editNewCode',h_editNewCode, ...
            'editNewDef',h_editNewDef, ...
            'editAnomalies',h_editAnomalies, ...
            'cmdAddCode',h_cmdAddCode, ...
            'cmdSummarize',h_cmdSummarize, ...
            'popSummarize',h_popSummarize, ...
            'chkMissing',h_chkMissing, ...
            'cmdCancel',h_cmdCancel, ...
            'cmdEval',h_cmdEval, ...
            'cmdPlot',h_cmdPlot, ...
            'chkClose',h_chkClose);

         set(h_dlg,'UserData',uih,'Visible','on')
         drawnow
         
         %display truncation warning
         if ~isempty(errmsg)
            messagebox('init',errmsg,'','Warning',[0.95 0.95 0.95],0)
         end

      end

   end  

else  %handle callbacks

   h_dlg = findobj('tag','dlgVisualQC');

   if ~isempty(h_dlg)

      uih = get(h_dlg,'UserData');  %get cached structure with uih handles, data

      switch op

         case 'cancel'  %close dialog

            close(h_dlg)
            drawnow
            ui_aboutgce('reopen')  %check for last window

         case 'summarize'  %summarize anomalies

            %get date format, other options
            missingopt = get(uih.chkMissing,'Value');
            fmtdata = get(uih.popSummarize,'UserData');
            fmtval = get(uih.popSummarize,'Value');
            fmt = fmtdata{fmtval,1};
            sep = fmtdata{fmtval,2};

            %get cached data fields
            s2 = uih.data.s;

            %update anomalies if changed
            anomstr = deblank(get(uih.editAnomalies,'String'));
            old_anomstr = lookupmeta(s2,'Data','Anomalies');
            if ~strcmp(anomstr,old_anomstr)
               s2 = addmeta(s2,{'Data','Anomalies',anomstr},1);
            end

            %update anomalies in replica structure
            s2 = add_anomalies(s2,fmt,sep,missingopt);
            anomstr = lookupmeta(s2,'Data','Anomalies');
            clear s2

            %update anomalies field
            set(uih.editAnomalies,'String',anomstr);
            drawnow

         case 'eval'  %open flagged structure in new editor window

            %get cached data fields
            s = uih.data.s;
            flagrows = unique(uih.flagrows(2:end,:),'rows');
            unflagrows = unique(uih.unflagrows(2:end,:),'rows');
            col = uih.data.y;
            colnames = s.name(col);
            loglimit = 100;  %set limit for logging individual flags
            closeopt = get(uih.chkClose,'Value');

            %get anomalies
            anomstr = deblank(get(uih.editAnomalies,'String'));

            %convert multi-row anomalies into single character array
            if size(anomstr,1) > 1
               anomstr = char(concatcellcols(cellstr(anomstr)',' '));
            end
            
            %update anomalies if changed
            old_anomstr = lookupmeta(s,'Data','Anomalies');
            if ~strcmp(anomstr,old_anomstr)
               s = addmeta(s,{'Data','Anomalies',anomstr},1);
               update_anom = 1;
            else
               update_anom = 0;
            end

            %generate info for history from list of flag operations
            metastr = '';
            if ~isempty(flagrows)
               for n = 1:length(col);
                  I = find(flagrows(:,1)==col(n));
                  if ~isempty(I)
                     if ~isempty(metastr)
                        metastr = [metastr,'; '];
                     end
                     if length(I) <= loglimit
                        metastr = [metastr,'flags set on ',colnames{n},' record(s): ', ...
                              cell2commas(strrep(cellstr(int2str(flagrows(I,2))),' ',''),1)];
                     else
                        metastr = [metastr,'flags set on ',int2str(length(I)),' records in ',colnames{n}];
                     end
                  end
               end
            end
            if ~isempty(unflagrows)
               for n = 1:length(col);
                  I = find(unflagrows(:,1)==col(n));
                  if ~isempty(I)
                     if ~isempty(metastr)
                        metastr = [metastr,'; '];
                     end
                     if length(I) <= loglimit
                        metastr = [metastr,'flags cleared on ',colnames{n},' record(s): ', ...
                              cell2commas(strrep(cellstr(int2str(unflagrows(I,2))),' ',''),1)];
                     else
                        metastr = [metastr,'flags cleared on ',int2str(length(I)),' records in ',colnames{n}];
                     end
                  end
               end
            end
            if ~isempty(metastr) || update_anom == 1
               curdate = datestr(now);
               if ~isempty(metastr)
                  metastr = ['QA/QC flags assigned by visual inspection (ui_visualqc); ',metastr];
                  s.history = [s.history ; {curdate},{metastr}];
               end
               if update_anom == 1
                  metastr = 'manually updated data set anomalies metadata field (ui_visualqc)';
                  s.history = [s.history ; {curdate},{metastr}];
               end
               s.editdate = curdate;
            end
            
            %update cached data and close Visual QC window
            uih.data.s = s;
            close(h_dlg)
            drawnow

            %close plot dialogs if specified, otherwise update data structure cached in plot figure
            try
               h_children = findobj(uih.h_fig);  %use findobj to check for closed figure error w/o opening new window
            catch
               h_children = [];
            end
            if ~isempty(h_children)
               figure(uih.h_fig)  %set focus to plot
               if closeopt == 1
                  %get handles of plotting dialogs
                  h_plotdlg1 = findobj('Tag','dlgPlotData');
                  h_plotdlg2 = findobj('Tag','dlgPlotGroups');
                  h_figs = [h_plotdlg1 ; h_plotdlg2 ; uih.h_fig];  %combine all ui handles into array
                  try
                     close(h_figs)  %close all figures, trapping errors
                  catch
                     %no action
                  end
               else
                  set(uih.h_fig,'UserData',uih.data,'WindowButtondownFcn','')  %update cached structure in plot figure, clear fcn
               end
            end

            %check for grouped plot, re-sort by X column
            if ~isempty(uih.data.Igroups)
               s = sortdata(s,uih.data.x,1);
            end

            %open modified structure in new editor window
            ui_editor(s)

         case 'addcode'  %add user-defined QC code to list, metadata

            newcode = deblank(get(uih.editNewCode,'String'));
            newdef = deblank(get(uih.editNewDef,'String'));

            if length(newcode) == 1 && ~isempty(newdef)
               str = [newcode,' = ',newdef];
               allflags = get(uih.popFlags,'String');
               if ischar(allflags)
                  if strcmp(allflags,' ')
                     allflags = [];
                  end
               end
               if ~isempty(allflags)
                  allflags = [allflags ; {str}];
               else
                  allflags = {str};
               end
               allcodes = get(uih.popFlags,'UserData');
               allcodes = [allcodes ; {newcode}];
               s = addmeta(uih.data.s,[{'Data'},{'Codes'},{cell2pipes(allflags)}]);
               if ~isempty(s)
                  uih.data.s = s;
               end
               set(uih.popFlags,'String',allflags,'UserData',allcodes,'Value',length(allcodes))
               set(uih.editNewCode,'String','')
               set(uih.editNewDef,'String','')
               set(h_dlg,'UserData',uih)  %save updates
            else
               messagebox('init', ...
                  'Invalid QA/QC flag code or definition - update cancelled', ...
                  '', ...
                  'Error', ...
                  [.9 .9 .9]);
            end

         case 'newcode'  %validate new user-defined code

            %truncate flag codes if more than 1 character long
            str = deblank(get(uih.editNewCode,'String'));
            if length(str) > 1
               set(uih.editNewCode,'String',str(1))
            end

         case 'plot'  %activate plot

            datacol = get(uih.popColumn,'Value');
            s = uih.data.s;
            xcol = uih.data.x;
            if isempty(uih.data.groupnames)
               col = uih.data.y(datacol);
               ycol = col;
            else
               col = datacol;
               ycol = uih.data.y;
            end

            flagdata = get(uih.popFlags,'UserData');

            if ~isempty(flagdata)

               flag = flagdata{get(uih.popFlags,'Value')};

               if ~strcmp(s.datatype{xcol},'s') && ~strcmp(s.datatype{ycol},'s')
                  %set focus, assign appropriate flagging operation to figure mouse button function
                  try
                     findobj(uih.h_fig);
                     figure(uih.h_fig)
                     axes(uih.h_ax);  %force data axis to be current
                     set(uih.h_fig, ...
                        'WindowButtonDownFcn',['ui_visualqc(''flags'',[{',int2str(col),'},{''',flag,'''},{',int2str(datacol),'}]);'])
                     drawnow
                  catch
                     messagebox('init', ...
                        'Could not set focus to the corresponding plot - operation cancelled', ...
                        [], ...
                        'Error', ...
                        [.9 .9 .9])
                  end
               else
                  messagebox('init', ...
                     'Sorry ... visual QC flagging is not supported for plots based on text columns', ...
                     [], ...
                     'Warning', ...
                     [.9 .9 .9])
               end

            else  %empty flag array
               messagebox('init','A flag code must be assigned to use this feature','','Error',[.9 .9 .9])
            end

         case 'flags'  %process flag inputs from figure

            if exist('data','var') == 1  %check for valid function input

               %retrieve stored values
               flag = data{2};
               s = uih.data.s;
               if isempty(uih.data.groupnames)
                  col = data{1};
                  gp = 0;
                  scalefactor = uih.data.scalefactor(data{3});
                  dtype_y = s.datatype{col};
               else
                  col = uih.data.y;
                  gp = data{1};
                  scalefactor = 1;
                  dtype_y = s.datatype{uih.data.y};
               end
               dtype_x = s.datatype{uih.data.x};
               rotate = uih.data.rotate;

               if ~strcmp(dtype_y,'s') && ~strcmp(dtype_x,'s')

                  %get axis limits
                  xlim = get(uih.h_ax,'Xlim');
                  ylim = get(uih.h_ax,'YLim');

                  %get initial mouse click position
                  pos = get(uih.h_ax,'CurrentPoint');
                  xclick = pos(1,1);
                  yclick = pos(1,2);

                  %check for out-of-bounds click
                  if xclick >= xlim(1) && xclick <= xlim(2) && yclick >= ylim(1) && yclick <= ylim(2)

                     rect = rbbox;

                     %get post-drag mouse position, button press
                     pos = get(uih.h_ax,'CurrentPoint');
                     xclick2 = pos(1,1);
                     yclick2 = pos(1,2);

                     %set color based on mouse button pressed
                     seltype = get(uih.h_fig,'SelectionType');
                     if strcmp(seltype,'normal')  %left button
                        clr = [.8 0 0];
                        fontweight = 'normal';
                     else  %other button - clear flag
                        clr = [1 1 1];
                        fontweight = 'bold';
                     end

                     x = extract(s,uih.data.x);
                     y = extract(s,col);

                     %compute grouping index
                     if gp > 0
                        Igp = [uih.data.Igroups(gp):uih.data.Igroups(gp+1)-1]';
                     else
                        Igp = [1:length(y)]';
                     end

                     %check for minimum rectangle size for drag mode (5 pixels)
                     if rect(3) < 5 && rect(4) < 5
                        dragmode = 0;
                     else
                        dragmode = 1;
                     end

                     cancel = 0;  %init cancel flag

                     %switch click orientation to match rotated plots
                     if rotate == 1
                        tmp = xclick;
                        xclick = yclick;
                        yclick = tmp;
                        tmp2 = xclick2;
                        xclick2 = yclick2;
                        yclick2 = tmp2;
                     end

                     if dragmode == 1

                        %gate ending position to stay within axis limits
                        if rotate == 0
                           xclick2 = max(min(xclick2,xlim(2)),xlim(1));
                           yclick2 = max(min(yclick2,ylim(2)),ylim(1));
                        else
                           yclick2 = max(min(yclick2,xlim(2)),xlim(1));
                           xclick2 = max(min(xclick2,ylim(2)),ylim(1));
                        end

                        %scale yclick to match value scaling
                        if scalefactor > 1
                           yclick = yclick ./ scalefactor;
                           yclick2 = yclick2 ./ scalefactor;
                        end

                        Ix = find(x(Igp)>=min(xclick,xclick2) & x(Igp)<=max(xclick,xclick2));
                        Iy = find(y(Igp)>=min(yclick,yclick2) & y(Igp)<=max(yclick,yclick2));
                        Ixy = intersect(Ix,Iy);  %use set intersection to omit irrelevant points

                        %check for valid data region
                        if ~isempty(Ixy)

                           %get arrays of values based on intersection index
                           xnear = x(Igp(Ixy));
                           ynear = y(Igp(Ixy));

                           %plot flag label
                           if rotate == 0
                              h_flag = text(xnear,ynear.*scalefactor,flag);
                           else
                              h_flag = text(ynear.*scalefactor,xnear,flag);
                           end
                           set(h_flag, ...
                              'fontname','Times', ...
                              'fontsize',9, ...
                              'fontweight',fontweight, ...
                              'horizontalalignment','center', ...
                              'verticalalignment','bottom', ...
                              'color',clr, ...
                              'clipping','on', ...
                              'tag','flags')

                           %process flags in structure
                           flags = s.flags{col};
                           if isempty(flags)
                              flags = repmat(' ',length(s.values{1}),1);  %generate flag array if necessary
                           end
                           if strcmp(seltype,'normal')
                              flags(Igp(Ixy),1) = flag;  %set flag
                              uih.flagrows = [uih.flagrows ; repmat(col,length(Ixy),1) Igp(Ixy(:))];
                           else
                              Iexisting = find(flags(Igp(Ixy),1)~=' ');
                              if ~isempty(Iexisting)  %check for no flag condition to avoid bogus clearing, logging
                                 flags(Igp(Ixy),1) = ' ';  %clear flag
                                 uih.unflagrows = [uih.unflagrows ; ...
                                       repmat(col,length(Igp(Ixy(Iexisting))),1) Igp(Ixy(Iexisting))];
                              end
                              if length(find(flags(:,1)==' ')) == size(flags,1)  %check for all empty flag array
                                 flags = '';  %delete empty array
                              end
                           end

                        else
                           cancel = 1;
                        end

                     else  %point mode

                        %calculate tolerances for nearest point array based on 1% of axis limits
                        if rotate == 0
                           xtol = abs(diff(xlim)).*0.01;
                           ytol = abs(diff(ylim)).*0.01;
                        else
                           ytol = abs(diff(xlim)).*0.01;
                           xtol = abs(diff(ylim)).*0.01;
                        end

                        %scale yclick to match value scaling
                        if scalefactor > 1
                           yclick = yclick ./ scalefactor;
                        end

                        %get indices of data points within tolerance
                        Ix = find(x(Igp)>=(xclick-xtol) & x(Igp)<=(xclick+xtol));
                        Iy = find(y(Igp)>=(yclick-ytol) & y(Igp)<=(yclick+ytol));
                        Ixy = intersect(Ix,Iy);  %use set intersection to omit irrelevant points

                        %check for valid data region
                        if ~isempty(Ixy)

                           %calculate index of nearest point based on minimum of net x/y difference
                           xdiff = x(Igp(Ixy))-xclick;
                           ydiff = y(Igp(Ixy))-yclick;
                           [tmp,Ixymin] = min(abs(xdiff).*abs(ydiff));
                           xnear = x(Igp(Ixy(Ixymin)));
                           ynear = y(Igp(Ixy(Ixymin)));

                           axes(uih.h_ax)  %force current axis selection to plot axis

                           %plot flag label
                           if rotate == 0
                              h_flag = text(xnear,ynear.*scalefactor,flag);
                           else
                              h_flag = text(ynear.*scalefactor,xnear,flag);
                           end
                           set(h_flag, ...
                              'fontname','Times', ...
                              'fontsize',9, ...
                              'fontweight',fontweight, ...
                              'horizontalalignment','center', ...
                              'verticalalignment','bottom', ...
                              'color',clr, ...
                              'clipping','on', ...
                              'tag','flags')

                           %process flags in structure
                           flags = s.flags{col};
                           if isempty(flags)
                              flags = repmat(' ',length(s.values{1}),1);  %generate flag array if necessary
                           end
                           if strcmp(seltype,'normal')
                              flags(Igp(Ixy(Ixymin)),1) = flag;  %set flag
                              uih.flagrows = [uih.flagrows ; col Igp(Ixy(Ixymin))];
                           else
                              if flags(Igp(Ixy(Ixymin)),1) ~= ' '  %check for no flag condition to avoid bogus clearing, logging
                                 flags(Igp(Ixy(Ixymin)),1) = ' ';  %clear flag
                                 uih.unflagrows = [uih.unflagrows ; col Igp(Ixy(Ixymin))];
                              end
                              if length(find(flags(:,1)==' ')) == size(flags,1)  %check for all empty flag array
                                 flags = '';  %delete empty array
                              end
                           end

                        else  %no intersection with data
                           cancel = 1;
                        end

                     end

                     if cancel == 0

                        s.flags{col} = flags;  %update flags in structure

                        %add manual flag to QC criteria if not already present
                        crit = s.criteria{col};
                        if isempty(crit)
                           crit = 'manual';
                        elseif isempty(strfind(crit,'manual'))
                           crit = strrep([crit,';manual'],';;',';');
                        end
                        s.criteria{col} = crit;

                        %update stored structure
                        uih.data.s = s;
                        set(h_dlg,'UserData',uih)

                     end

                  end

               end

            end

      end

   end

end