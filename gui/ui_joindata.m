function ui_joindata(op,s0,s1,s1fname,h_fig,h_cb,cb,autodate)
%GUI dialog for joining columns in two GCE Data Structures together based on common values in one or more key columns
%
%syntax: ui_joindata(op,s0,s1,s1fname,h_fig,h_cb,cb,autodate)
%
%input:
%  op = operation (default = 'init')
%  s0 = first data structure to join
%  s1 = second data structure to join
%  s1fname = filename for the second data structure (default = '')
%  h_fig = figure handle of the calling dialog (default = gcf)
%  h_cb = object handle for storing return data (default = [])
%  cb = callback to execute after join (default = '')
%  autodate = option to perform automatic date/time join
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
%last modified: 28-May-2013

%check for omitted startup arguments, set appropriately for command rejection
if nargin == 0
   op = 'init';
   s0 = [];
   s1 = [];
elseif isstruct(op)
   s0 = op;
   op = 'init';
   if exist('s1','var') ~= 1
      s1 = [];
   end
end

%check for create dialog command
if strcmp(op,'init')

   if gce_valid(s0,'data') && gce_valid(s1,'data')

      %apply defaults for omitted optional arguments
      if exist('autodate','var') ~= 1
         autodate = 0;
      elseif autodate ~= 1
         autodate = 0;
      end

      %set match units checkbox option based on autodate
      if autodate == 1
         matchunits = 0;
      else
         matchunits = 1;
      end

      if exist('s1fname','var') ~= 1
         s1fname = '';
      end

      if exist('h_fig','var') ~= 1
         h_fig = [];
      end

      if exist('h_cb','var') ~= 1
         h_cb = [];
      end

      if exist('cb','var') ~= 1
         cb = '';
      end

      %generate available column lists for top pane
      strListA = char(concatcellcols([s0.name',repmat({ ' ('},length(s0.name),1),s0.units', ...
            repmat({')'},length(s0.name),1)]));
      strListB = char(concatcellcols([s1.name',repmat({ ' ('},length(s1.name),1),s1.units', ...
            repmat({')'},length(s1.name),1)]));

      %determine figure size, position based on screen metrics and autodate option
      res = get(0,'ScreenSize');
      if autodate == 1
         fig_ht = 340;
         fig_bot = max(res(4)-830,max(30,(res(4)-720)./2));
         showtopvis = 'on';
      else
         fig_ht = 760;
         fig_bot = max(30,(res(4)-720)./2);
         showtopvis = 'off';
      end
      figpos = [max(0,(res(3)-600)./2) fig_bot 600 fig_ht];

      %create GUI figure
      h_dlg = figure('Visible','off', ...
         'Color',[0.95 0.95 0.95], ...
         'KeyPressFcn','figure(gcf)', ...
         'MenuBar','none', ...
         'Name','Join Data', ...
         'NumberTitle','off', ...
         'Position',figpos, ...
         'Tag','dlgJoinData', ...
         'ToolBar','none', ...
         'Resize','off', ...
         'CloseRequestFcn','ui_joindata(''cancel'')', ...
         'DefaultuicontrolUnits','pixels');

      if mlversion >= 7
         set(h_dlg,'WindowStyle','normal')
         set(h_dlg,'DockControls','off')
      end

      %generate menu options
      h_mnuHelp = uimenu('Parent',h_dlg, ...
         'Label','Help', ...
         'Tag','mnuHelp');

      uimenu('Parent',h_mnuHelp, ...
         'Label','View Documentation', ...
         'Accelerator','H', ...
         'Callback','ui_viewdocs(''init'',''ui_joindata'')', ...
         'Tag','mnuDocs');

      uimenu('Parent',h_mnuHelp, ...
         'Label','About the GCE Data Toolbox', ...
         'Separator','on', ...
         'Callback','ui_aboutgce', ...
         'Tag','mnuAbout');

      %generate other uicontrols
      h_frame = uicontrol('Parent',h_dlg, ...
         'Style','frame', ...
         'BackgroundColor',[.95 .95 .95], ...
         'ForegroundColor',[0 0 0], ...
         'Position',[1 1 figpos(3)-1 fig_ht-1]);

      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[0.95 0.95 0.95], ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.7], ...
         'HorizontalAlignment','left', ...
         'ListboxTop',0, ...
         'Position',[12 717 450 22], ...
         'String','Define Key Columns and Options for Joining Structures', ...
         'Style','text', ...
         'Tag','StaticText');

      h_list0 = uicontrol('Parent',h_dlg, ...
         'Style','listbox', ...
         'Position',[20 590 270 100], ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',10, ...
         'String',strListA, ...
         'Tag','list0', ...
         'Value',1, ...
         'UserData',[1:length(s0.name)]);

      h_list1 = uicontrol('Parent',h_dlg, ...
         'Style','listbox', ...
         'Position',[310 590 270 100], ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',10, ...
         'String',strListB, ...
         'Tag','list1', ...
         'Value',1, ...
         'UserData',[1:length(s1.name)]);

      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[20 691 150 20], ...
         'BackgroundColor',[0.95 0.95 0.95], ...
         'FontSize',10, ...
         'ForegroundColor',[0 0 0.7], ...
         'String','Structure A Columns', ...
         'Tag','StaticText');

      %use up to 100 chars of title as tooltipstring
      tooltipstr = s0.title;
      if length(tooltipstr) > 100
         Ispc = strfind(tooltipstr,' ');
         if ~isempty(Ispc)
            Ispc2 = max(find(Ispc<100));
            if ~isempty(Ispc)
               tooltipstr = [tooltipstr(1:Ispc(Ispc2)),' ...'];
            else
               tooltipstr = [tooltipstr(1:100),'...'];
            end
         else
            tooltipstr = [tooltipstr(1:100),'...'];
         end
      end
      uicontrol('Parent',h_dlg, ...
         'Style','pushbutton', ...
         'Position',[220 692 70 22], ...
         'String','View/Edit', ...
         'Callback','ui_joindata(''viewedit'')', ...
         'TooltipString',['View/edit "',tooltipstr,'"'], ...
         'Tag','mnuViewEdit0', ...
         'UserData',[]);

      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[310 691 150 20], ...
         'BackgroundColor',[0.95 0.95 0.95], ...
         'FontSize',10, ...
         'ForegroundColor',[0 0 0.7], ...
         'String','Structure B Columns', ...
         'Tag','StaticText');

      %use up to 100 chars of title as tooltipstring
      tooltipstr = s1.title;
      if length(tooltipstr) > 100
         Ispc = strfind(tooltipstr,' ');
         if ~isempty(Ispc)
            Ispc2 = max(find(Ispc<100));
            if ~isempty(Ispc)
               tooltipstr = [tooltipstr(1:Ispc(Ispc2)),' ...'];
            else
               tooltipstr = [tooltipstr(1:100),'...'];
            end
         else
            tooltipstr = [tooltipstr(1:100),'...'];
         end
      end
      
      uicontrol('Parent',h_dlg, ...
         'Style','pushbutton', ...
         'Position',[510 692 70 22], ...
         'String','View/Edit', ...
         'Callback','ui_joindata(''viewedit'')', ...
         'TooltipString',['View/edit "',tooltipstr,'"'], ...
         'Tag','mnuViewEdit1', ...
         'UserData',[]);

      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[20 560 100 20], ...
         'BackgroundColor',[0.95 0.95 0.95], ...
         'FontSize',10, ...
         'ForegroundColor',[0 0 0.7], ...
         'String','Rows to Return', ...
         'Tag','StaticText');

      h_popJoinType0 = uicontrol('Parent',h_dlg, ...
         'Style','popupmenu', ...
         'Position',[120 560 170 22], ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',10, ...
         'String',{'Only matching';'All rows';'All rows (Lookup)'}, ...
         'Tag','popJoinType0', ...
         'Callback','ui_joindata(''jointype'')', ...
         'Value',2);

      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[310 562 100 20], ...
         'BackgroundColor',[0.95 0.95 0.95], ...
         'FontSize',10, ...
         'ForegroundColor',[0 0 0.7], ...
         'String','Rows to Return', ...
         'Tag','StaticText');

      h_popJoinType1 = uicontrol('Parent',h_dlg, ...
         'Style','popupmenu', ...
         'Position',[410 562 170 22], ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',10, ...
         'String',{'Only matching';'All rows';'Only matching (Lookup)'}, ...
         'Tag','popJoinType1', ...
         'Callback','ui_joindata(''jointype'')', ...
         'Value',2);

      h_listJoin = uicontrol('Parent',h_dlg, ...
         'Style','listbox', ...
         'Position',[130 450 450 70], ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',10, ...
         'String','', ...
         'Tag','listJoin', ...
         'Value',1);

      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[130 521 400 20], ...
         'BackgroundColor',[0.95 0.95 0.95], ...
         'FontSize',10, ...
         'ForegroundColor',[0 0 0.7], ...
         'String','Key Column Matches for Join', ...
         'Tag','StaticText');

      h_cmdAddJoin = uicontrol('Parent',h_dlg, ...
         'Position',[40 488 70 25], ...
         'FontSize',9, ...
         'String','Add >', ...
         'Tag','cmdAddJoin', ...
         'Callback','ui_joindata(''addjoin'')');

      h_cmdDelJoin = uicontrol('Parent',h_dlg, ...
         'Position',[40 458 70 25], ...
         'String','< Delete', ...
         'FontSize',9, ...
         'Enable','off', ...
         'Tag','cmdDelJoin', ...
         'Callback','ui_joindata(''deljoin'')');

      h_chkMatchUnits = uicontrol('Parent',h_dlg, ...
         'Style','checkbox', ...
         'Position',[130 420 300 20], ...
         'ForegroundColor',[0 0 .8], ...
         'BackgroundColor',[.95 .95 .95], ...
         'FontSize',10, ...
         'String','Require matching units?', ...
         'TooltipString','Option to require matching units for paired join columns', ...
         'Value',matchunits, ...
         'Callback','ui_joindata(''matchunits'')', ...
         'Tag','chkMatchUnits');

      h_chkForce = uicontrol('Parent',h_dlg, ...
         'Style','checkbox', ...
         'Position',[130 395 300 20], ...
         'ForegroundColor',[0 0 .8], ...
         'BackgroundColor',[.95 .95 .95], ...
         'FontSize',10, ...
         'String','Remove duplicated records in key columns?', ...
         'TooltipString','Option to remove duplicate records in key columns to force the join (data may be lost)', ...
         'Value',0, ...
         'Tag','chkForce');

      h_cmdChoose = uicontrol('Parent',h_dlg, ...
         'Position',[220 355 160 25], ...
         'String','Choose Output Columns', ...
         'FontSize',9, ...
         'Enable','off', ...
         'Tag','cmdChoose', ...
         'Callback','ui_joindata(''choose'')');

      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[0.7 0.7 0.7], ...
         'Position',[2 345 figpos(3)-4 2], ...
         'Style','text', ...
         'Tag','txtFrame');

      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[12 315 450 22], ...
         'BackgroundColor',[0.95 0.95 0.95], ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.7], ...
         'HorizontalAlignment','left', ...
         'String','Choose Output Columns for the Joined Structure', ...
         'Tag','StaticText');

      %add 'Show Join' button, but only activate if autodate == 1
      h_cmdShowTop = uicontrol('Parent',h_dlg, ...
         'Style','pushbutton', ...
         'Position',[524 310 70 25], ...
         'String','Show Join', ...
         'FontSize',9, ...
         'Tag','cmdShowTop', ...
         'Visible',showtopvis, ...
         'Enable',showtopvis, ...
         'Callback','ui_joindata(''showtop'')');

      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[20 275 240 20], ...
         'BackgroundColor',[0.95 0.95 0.95], ...
         'FontSize',10, ...
         'ForegroundColor',[0 0 0.7], ...
         'String','Available Columns from A', ...
         'Tag','StaticText');

      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[335 275 170 20], ...
         'BackgroundColor',[0.95 0.95 0.95], ...
         'FontSize',10, ...
         'HorizontalAlignment','left', ...
         'ForegroundColor',[0 0 0.7], ...
         'String','Selected A Columns', ...
         'Tag','StaticText');

      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[465 275 50 20], ...
         'BackgroundColor',[0.95 0.95 0.95], ...
         'FontSize',10, ...
         'HorizontalAlignment','right', ...
         'ForegroundColor',[0 0 0.7], ...
         'String','Prefix:', ...
         'Tag','StaticText');

      h_editPrefix0 = uicontrol('Parent',h_dlg, ...
         'Style','edit', ...
         'Position',[520 276 60 20], ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',10, ...
         'HorizontalAlignment','left', ...
         'String','', ...
         'Callback','ui_joindata(''refreshbot'')', ...
         'Tag','editPrefix0');

      h_listSel0 = uicontrol('Parent',h_dlg, ...
         'Style','listbox', ...
         'Position',[330 194 250 80], ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',10, ...
         'String','', ...
         'Enable','off', ...
         'Callback','ui_joindata(''listclick'')', ...
         'Tag','listSel0', ...
         'Value',1);

      h_listAvail0 = uicontrol('Parent',h_dlg, ...
         'Style','listbox', ...
         'Position',[20 194 250 80], ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',10, ...
         'String','', ...
         'Enable','off', ...
         'Tag','listAvail0', ...
         'Callback','ui_joindata(''listclick'')', ...
         'Value',1);

      h_cmdAdd0 = uicontrol('Parent',h_dlg, ...
         'Position',[280 235 40 25], ...
         'String','Add >', ...
         'FontSize',9, ...
         'Enable','off', ...
         'Tag','cmdAdd0', ...
         'Callback','ui_joindata(''addcola'')');

      h_cmdDel0 = uicontrol('Parent',h_dlg, ...
         'Position',[280 205 40 25], ...
         'Enable','off', ...
         'String','< Del', ...
         'FontSize',9, ...
         'Tag','cmdDel0', ...
         'Callback','ui_joindata(''delcola'')');

      h_cmdDel1 = uicontrol('Parent',h_dlg, ...
         'Position',[280 94 40 25], ...
         'Enable','off', ...
         'String','< Del', ...
         'FontSize',9, ...
         'Tag','cmdDel1', ...
         'Callback','ui_joindata(''delcolb'')');

      h_cmdAdd1 = uicontrol('Parent',h_dlg, ...
         'Position',[280 124 40 25], ...
         'Enable','off', ...
         'String','Add >', ...
         'FontSize',9, ...
         'Tag','cmdAdd1', ...
         'Callback','ui_joindata(''addcolb'')');

      h_listAvail1 = uicontrol('Parent',h_dlg, ...
         'Style','listbox', ...
         'Position',[20 83 250 80], ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',10, ...
         'Enable','off', ...
         'String','', ...
         'Callback','ui_joindata(''listclick'')', ...
         'Tag','listAvail1', ...
         'Value',1);

      h_listSel1 = uicontrol('Parent',h_dlg, ...
         'Position',[330 83 250 80], ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',10, ...
         'Enable','off', ...
         'String','', ...
         'Callback','ui_joindata(''listclick'')', ...
         'Style','listbox', ...
         'Tag','listSel1', ...
         'Value',1);

      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[20 164 240 20], ...
         'BackgroundColor',[0.95 0.95 0.95], ...
         'FontSize',10, ...
         'ForegroundColor',[0 0 0.7], ...
         'String','Available Columns from B', ...
         'Tag','StaticText');

      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[335 164 170 20], ...
         'BackgroundColor',[0.95 0.95 0.95], ...
         'FontSize',10, ...
         'HorizontalAlignment','left', ...
         'ForegroundColor',[0 0 0.7], ...
         'String','Selected B Columns', ...
         'Tag','StaticText');

      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[465 164 50 20], ...
         'BackgroundColor',[0.95 0.95 0.95], ...
         'FontSize',10, ...
         'HorizontalAlignment','right', ...
         'ForegroundColor',[0 0 0.7], ...
         'String','Prefix:', ...
         'Tag','StaticText');

      h_editPrefix1 = uicontrol('Parent',h_dlg, ...
         'Style','edit', ...
         'Position',[520 165 60 20], ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',10, ...
         'HorizontalAlignment','left', ...
         'String','', ...
         'Callback','ui_joindata(''refreshbot'')', ...
         'Tag','editPrefix1');

      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[120 50 110 18], ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.7], ...
         'BackgroundColor',[0.95 0.95 0.95], ...
         'String','Metadata Option');

      h_popMetadata = uicontrol('Parent',h_dlg, ...
         'Position',[230 50 200 20], ...
         'Fontsize',9, ...
         'Style','popupmenu', ...
         'BackgroundColor',[1 1 1], ...
         'String',char({'Merge all metadata','Merge selected metadata','Do not merge metadata'}), ...
         'Value',1, ...
         'Tag','popMetadata', ...
         'TooltipString','Option to specify how to merge structure metadata', ...
         'UserData',{'all','pick','none'});

      h_cmdCancel = uicontrol('Parent',h_dlg, ...
         'Position',[7 7 70 25], ...
         'String','Cancel', ...
         'FontSize',9, ...
         'Tag','cmdCancel', ...
         'Callback','ui_joindata(''cancel'')');

      h_cmdEval = uicontrol('Parent',h_dlg, ...
         'Position',[524 8 70 25], ...
         'Enable','off', ...
         'String','Proceed', ...
         'FontSize',9, ...
         'Tag','cmdEval', ...
         'Callback','ui_joindata(''eval'')');

      %determine string and settings for option checkbox based on context from arguments
      if ~isempty(h_fig)
         if strcmp(get(h_fig,'Tag'),'dlgDSEditor')
            str = 'Open joined structure in a new window';  %set checkbox string for client mode
            optionval = 1;
            vis = 'on';
         else
            optionval = 0;
            str = '';
            vis = 'off';
         end
      else
         str = 'Close dialog after performing the join';  %set checkbox string for stand-alone mode
         optionval = 1;
         vis = 'on';
      end

      h_chkOption = uicontrol('Parent',h_dlg, ...
         'Visible',vis, ...
         'BackgroundColor',[0.95 0.95 0.95], ...
         'FontSize',10, ...
         'ListboxTop',0, ...
         'Position',[180 10 290 22], ...
         'String',str, ...
         'Style','checkbox', ...
         'Value',optionval, ...
         'Tag','chkOption');

      %generate cached ui data structure
      uih = struct( ...
         's0',s0, ...
         's1',s1, ...
         's1fname',s1fname, ...
         'h_fig',h_fig, ...
         'h_cb',h_cb, ...
         'cb',cb, ...
         'frame',h_frame, ...
         'list0',h_list0, ...
         'list1',h_list1, ...
         'listJoin',h_listJoin, ...
         'listAvail0',h_listAvail0, ...
         'listAvail1',h_listAvail1, ...
         'listSel0',h_listSel0, ...
         'listSel1',h_listSel1, ...
         'cmdChoose',h_cmdChoose, ...
         'cmdAddJoin',h_cmdAddJoin, ...
         'cmdDelJoin',h_cmdDelJoin, ...
         'popJoinType0',h_popJoinType0, ...
         'popJoinType1',h_popJoinType1, ...
         'popMetadata',h_popMetadata, ...
         'editPrefix0',h_editPrefix0, ...
         'editPrefix1',h_editPrefix1, ...
         'cmdShowTop',h_cmdShowTop, ...
         'cmdAdd0',h_cmdAdd0, ...
         'cmdDel0',h_cmdDel0, ...
         'cmdAdd1',h_cmdAdd1, ...
         'cmdDel1',h_cmdDel1, ...
         'cmdCancel',h_cmdCancel, ...
         'cmdEval',h_cmdEval, ...
         'chkMatchUnits',h_chkMatchUnits, ...
         'chkForce',h_chkForce, ...
         'chkOption',h_chkOption);

      %cache ui data, enable figure
      set(h_dlg,'UserData',uih,'Visible','on')

      %run auto-date/time join operation if specified
      if autodate == 1
         ui_joindata('autodatejoin')
      else
         drawnow
      end

   else
      messagebox('init','One or both data structures are missing or invalid',[],'Error',[.9 .9 .9])
   end

else  %handle other callbacks

   %check active figure tag to ensure only handle callbacks from the appropriate join dialog
   h_dlg = [];
   if length(findobj) > 1
      if strcmp(get(gcf,'Tag'),'dlgJoinData')
         h_dlg = gcf;
      end
   end

   if ~isempty(h_dlg)

      %get cached ui data
      uih = get(h_dlg,'UserData');

      switch op

      case 'cancel'  %handle cancel button press

         delete(h_dlg)
         drawnow
         ui_aboutgce('reopen')  %check for last window

      case 'eval'  %evaluate input, perform join

         %set watch pointer
         set(h_dlg,'Pointer','watch'); drawnow

         %look up column selection indices
         data = get(uih.listJoin,'UserData');
         Isel0 = get(uih.listSel0,'UserData');
         Isel1 = get(uih.listSel1,'UserData');

         %look up option settings
         jtype0 = get(uih.popJoinType0,'Value');
         jtype1 = get(uih.popJoinType1,'Value');
         pref0 = deblank(get(uih.editPrefix0,'String'));
         pref1 = deblank(get(uih.editPrefix1,'String'));
         chkoption = get(uih.chkOption,'Value');
         matchunits = get(uih.chkMatchUnits,'Value');
         chkforce = get(uih.chkForce,'Value');

         %look up metadata merge option
         metaval = get(uih.popMetadata,'Value');
         metaopts = get(uih.popMetadata,'Userdata');
         metamerge = metaopts{metaval};

         %generate appropriate cleardupesopt string based on force join option
         if chkforce == 1
            cleardupesopt = 'key';
         else
            cleardupesopt = 'yes';
         end

         %generate appropriate join type string based on selections
         if jtype0 == 1 && jtype1 == 1
            jtype = 'inner';
         elseif jtype0 == 2 && jtype1 == 2
            jtype = 'full';
         elseif jtype0 == 2
            jtype = 'left';
         elseif jtype0 == 3 || jtype1 == 3
            jtype = 'lookup';
         else
            jtype = 'right';
         end

         %perform join
         try
            [s,msg] = joindata(uih.s0,uih.s1,data(:,1)',data(:,2)', ...
               jtype,Isel0,Isel1,pref0,pref1,uih.s1fname,cleardupesopt,matchunits,metamerge);
         catch e
            s = [];
            msg = ['an unhandled MATLAB error occurred (',e.message,')'];
         end

         set(h_dlg,'Pointer','arrow'); drawnow

         %check for return data
         if ~isempty(s)

            %check for client-mode info, return data as specified
            if ~isempty(uih.h_fig) && ~isempty(uih.h_cb) && ~isempty(uih.cb)

               %close dialog
               delete(h_dlg)
               drawnow

               %check for new window option
               if chkoption == 1
                  ui_editor('init',s)
               else  %process callback info
                  try
                     figure(uih.h_fig)  %set focus to calling dialog
                     set(uih.h_cb,'UserData',s)  %store joined data using specified object handle
                     eval(uih.cb)  %evaluate callback statement
                  catch
                     msg = 'an error occurred returning data to the requesting application';
                     ui_editor('init',s)  %open in new editor window on errors to avoid losing data
                  end
               end

            else

               %close dialog if close option set
               if chkoption == 1
                  delete(h_dlg)
                  drawnow
               end

               %return data to editor
               ui_editor('init',s)

            end

            %display non-fatal error message as warning
            if ~isempty(msg)
               messagebox('init', ...
                  ['Warning: ',msg], ...
                  '', ...
                  'Warning', ...
                  [.9 .9 .9]);
            end

         else  %display joindata error
            messagebox('init', ...
               char('The join could not be performed as specified',['(Error: ',msg,')']), ...
               '', ...
               'Error', ...
               [.9 .9 .9]);
         end

      case 'showtop'   %show/hide top pane of dialog (button only active if autodate == 1)

         %get current pushbutton string
         str = get(gcbo,'String');

         if strcmp(str,'Show Join')
            fig_ht = 750;
            buttonstr = 'Hide Join';
         elseif strcmp(str,'Hide Join')
            fig_ht = 340;
            buttonstr = 'Show Join';
         else
            fig_ht = [];
            buttonstr = '';
         end

         if ~isempty(fig_ht)

            %update button string
            set(uih.cmdShowTop,'String',buttonstr)

            %set figure height to show/hide top pane
            pos = get(h_dlg,'Position');
            set(h_dlg,'Position',[pos(1:3),fig_ht])
            set(uih.frame,'Position',[1 1 pos(3) fig_ht])
            drawnow

         end

      case 'viewedit'  %send data to editor

         %determine which button pressed based on tag
         h_cbo = gcbo;
         tag = get(h_cbo,'Tag');

         %get appropriate structure, generate appropriate callback string
         s = [];
         cb = '';
         if strcmp(tag,'mnuViewEdit0')
            s = uih.s0;
            cb = 'ui_joindata(''updatedata'',data,[])';
         elseif strcmp(tag,'mnuViewEdit1')
            s = uih.s1;
            cb = 'ui_joindata(''updatedata'',[],data)';
         end

         %send to editor in client mode, activating 'Return Data' menu option under 'File'
         if ~isempty(cb)
            ui_editor('init',s,cb,h_cbo)
         end

      case 'updatedata'  %process returned data from editor

         err = 0;
         if ~isempty(s0)
            if gce_valid(s0,'data')
               uih.s0 = s0;
            else
               err = 1;
            end
         elseif ~isempty(s1)
            if gce_valid(s1,'data')
               uih.s1 = s1;
            else
               err = 1;
            end
         end

         if err == 0
            set(h_dlg,'UserData',uih)
            set(uih.list0,'UserData',[1:length(uih.s0.name)]);
            set(uih.list1,'UserData',[1:length(uih.s1.name)]);
            set(uih.listJoin,'UserData',[]);
            h_bottom = [uih.listAvail0 ; uih.listAvail1 ; uih.listSel0 ; uih.listSel1];
            set(h_bottom,'String','','Value',1,'ListboxTop',1,'UserData',[])
            ui_joindata('refreshtop')
         else
            messagebox('init','Invalid data was returned from editor - data sets were not updated')
         end

      case 'autodatejoin'  %automatically add matching date-time fields to join list

         %get indices of unassigned attributes
         I0 = get(uih.list0,'UserData');
         I1 = get(uih.list1,'UserData');

         %get unit match option
         matchunits = get(uih.chkMatchUnits,'Value');

         %check for unassigned attributes
         if ~isempty(I0) && ~isempty(I1)

            %get cached structures, applying indices to remove already selected cols
            s0 = copycols(uih.s0,I0);
            s1 = copycols(uih.s1,I1);

            data = get(uih.listJoin,'UserData');

            %init date/time match field array, match indices
            flds = {'Date','Year','Month','Day','Hour','Minute','Second'};
            Imatch0 = [];
            Imatch1 = [];

            %loop through datetime fields, matching where possible
            for n = 1:length(flds)

               %get indices of datetime fields, matching names case insensitively
               Itmp0 = find(strcmpi(s0.name,flds{n}) & strcmp(s0.variabletype,'datetime'));
               if isempty(Itmp0)  %no match - run beggining string search to check for minor spelling variations
                  Itmp0 = find(strncmpi(s0.name,flds{n},length(flds{n})) & strcmp(s0.variabletype,'datetime'));
               end
               Itmp1 = find(strcmpi(s1.name,flds{n}) & strcmp(s1.variabletype,'datetime'));
               if isempty(Itmp1)  %no match - run beggining string search to check for minor spelling variations
                  Itmp1 = find(strncmpi(s1.name,flds{n},length(flds{n})) & strcmp(s1.variabletype,'datetime'));
               end

               %compare unique matches, confirming datatype, units compatibility
               if length(Itmp0) == 1 && length(Itmp1) == 1
                  if strcmp(s0.datatype{Itmp0},s1.datatype{Itmp1}) && (matchunits == 0 || strcmpi(s0.units{Itmp0},s1.units{Itmp1}))
                     %add resolved column indices to match array
                     Imatch0 = [Imatch0,I0(Itmp0)];
                     Imatch1 = [Imatch1,I1(Itmp1)];
                  end
               end

            end

            %update join list with matches
            if ~isempty(Imatch0) && ~isempty(Imatch1)

               %update indices
               I0 = setdiff(I0,Imatch0);
               I1 = setdiff(I1,Imatch1);

               %update join list
               data = [data ; Imatch0',Imatch1'];

               %update cached info
               set(uih.listJoin,'UserData',data)
               set(uih.list0,'UserData',I0(~isnan(I0)))
               set(uih.list1,'UserData',I1(~isnan(I1)))

               %set full outer join
               set(uih.popJoinType0,'Value',2)
               set(uih.popJoinType1,'Value',2)

               %add auto prefix for structure B to avoid identical attribute names
               pref1 = deblank(get(uih.editPrefix1,'String'));
               if isempty(pref1)
                  set(uih.editPrefix1,'String','B_')
               end

               %refresh uicontrols
               ui_joindata('refreshtop')
               set(uih.listJoin,'ListBoxTop',size(data,1))

               %lock top controls
               %h_ui = [uih.list0 ; uih.list1; uih.listJoin; uih.cmdChoose;
               %   uih.cmdAddJoin; uih.cmdDelJoin; uih.chkForce];
               %set(h_ui,'Enable','off')

               %add unselected columns to data column list
               ui_joindata('choose')

            end

         end

      case 'matchunits'  %check compatibility of existing join condition units if match units toggled on

         %get match units option
         matchunits = get(uih.chkMatchUnits,'Value');

         if matchunits == 1
            %get column selections from lists, menus
            keys = get(uih.listJoin,'UserData');
            if ~isempty(keys)
               s0 = uih.s0;
               s1 = uih.s1;
               Imatch = zeros(size(keys,1),1);
               for n = 1:size(keys,1)
                  if strcmpi(s0.units{keys(n,1)},s1.units{keys(n,2)})
                     Imatch(n) = 1;
                  end
               end
               Imismatch = find(~Imatch);
               if ~isempty(Imismatch)
                  msg = '  The following key column matches have incompatible units:  ';
                  for n = 1:length(Imismatch)
                     msg = char(msg,['A:',s0.name{keys(Imismatch(n),1)},' and B:',s1.name{keys(Imismatch(n),2)}]);
                  end
                  msg = char(msg,'Reset all key matches and output column selections?');
                  messagebox('init',msg,'ui_joindata(''resetall'')','Error',[.95 .95 .95],1)
               end
            end
         end

      case 'resetall'  %resets all key column matches and bottom list selections

         set(uih.list0,'UserData',1:length(uih.s0.name))
         set(uih.list1,'UserData',1:length(uih.s1.name))
         set(uih.listJoin,'UserData',[])
         ui_joindata('refreshtop')
         ui_joindata('choose')

      case 'addjoin'  %validate and add selected columns from A, B to join list

         %get column selections from lists, menus
         sel0 = get(uih.list0,'Value');
         sel1 = get(uih.list1,'Value');
         I0 = get(uih.list0,'UserData');
         I1 = get(uih.list1,'UserData');
         data = get(uih.listJoin,'UserData');
         matchunits = get(uih.chkMatchUnits,'Value');

         %look up column attributes
         s0 = uih.s0;
         s1 = uih.s1;
         dtypematch = strcmp(s0.datatype{I0(sel0)},s1.datatype{I1(sel1)});
         vartypematch = strcmp(s0.variabletype{I0(sel0)},s1.variabletype{I1(sel1)});

         if matchunits == 1
            unitmatch = strcmp(s0.units{I0(sel0)},s1.units{I1(sel1)});
         else
            unitmatch = 1;
         end

         %check for datatype, units compatibility
         if dtypematch == 1 && vartypematch == 1 && unitmatch == 1

            %add new selections to join indices
            data = [data ; I0(sel0) I1(sel1)];

            %flag selections for removal from lists
            I0(sel0) = NaN;
            I1(sel1) = NaN;

            %update stored list indices
            set(uih.listJoin,'UserData',data)
            set(uih.list0,'UserData',I0(~isnan(I0)))
            set(uih.list1,'UserData',I1(~isnan(I1)))

            %repopulate controls with updated values
            ui_joindata('refreshtop')

         else  %not compatible - display appropriate error message

            %build error message based on specific mismatches
            str = 'Selected join columns are not compatible';
            str2 = '';
            if dtypematch == 0
               str2 = [str2,', data types are different'];
            end
            if vartypematch == 0
               str2 = [str2,', variable types are different'];
            end
            if unitmatch == 0
               str2 = [str2,', units are different'];
            end
            if ~isempty(str2)
               str2 = [' - ',str2(3:end)];
            end
            str = char([str,str2],'Use the View/Edit buttons to transform or reclassify columns as appropriate');

            %display error message
            messagebox('init',str,[],'Error',[.9 .9 .9])

         end

      case 'deljoin'  %delete selected join condition

         %get column selections
         sel = get(uih.listJoin,'Value');
         I0 = get(uih.list0,'UserData');
         I1 = get(uih.list1,'UserData');
         data = get(uih.listJoin,'UserData');

         %generate new available column indices
         I0 = sort([I0 data(sel,1)]);
         I1 = sort([I1 data(sel,2)]);

         %update join list data
         if size(data,1) > 1
            data(sel,1) = NaN;
            data = data(~isnan(data(:,1)),:);
         else
            data = [];
         end

         %update list data
         set(uih.listJoin,'UserData',data)
         set(uih.list0,'UserData',I0)
         set(uih.list1,'UserData',I1)

         %repopulate controls with updated values
         ui_joindata('refreshtop')

      case 'refreshtop'  %regenerate uicontrol contents in top pane using stored indices

         %get indices
         I0 = get(uih.list0,'UserData');
         I1 = get(uih.list1,'UserData');
         data = get(uih.listJoin,'UserData');

         %get cached structures
         s0 = uih.s0;
         s1 = uih.s1;

         %generate available cols for A
         if ~isempty(I0)
            strListA = char(concatcellcols([s0.name(I0)',repmat({ ' ('},length(I0),1), ...
                  s0.units(I0)',repmat({')'},length(I0),1)]));
            visA = 'on';
         else
            strListA = '';
            visA = 'off';
         end

         %generate available cols for B
         if ~isempty(I1)
            strListB = char(concatcellcols([s1.name(I1)',repmat({ ' ('},length(I1),1), ...
                  s1.units(I1)',repmat({')'},length(I1),1)]));
            visB = 'on';
            if ~isempty(I0)
               visAdd = 'on';
            else
               visAdd = 'off';
            end
         else
            strListB = '';
            visB = 'off';
            if isempty(I0)
               visAdd = 'off';
            else
               visAdd = 'on';
            end
         end

         %generate join list
         if ~isempty(data)
            strJoin = char(concatcellcols([s0.name(data(:,1))',repmat({' = '}, ...
                  size(data,1),1),s1.name(data(:,2))']));
            visJoin = 'on';
            visDel = 'on';
            visChoose = 'on';
         else
            strJoin = '';
            visJoin = 'off';
            visDel = 'off';
            visChoose = 'off';
         end

         %update controls with new content
         set(uih.list0, ...
            'String',strListA, ...
            'Enable',visA, ...
            'Value',max(1,min(length(I0),get(uih.list0,'Value'))), ...
            'ListBoxTop',max(1,min(length(I0),get(uih.list0,'ListBoxTop'))))
         set(uih.list1, ...
            'String',strListB, ...
            'Enable',visB, ...
            'Value',max(1,min(length(I1),get(uih.list1,'Value'))), ...
            'ListBoxTop',max(1,min(length(I1),get(uih.list1,'ListBoxTop'))))
         set(uih.listJoin, ...
            'String',strJoin, ...
            'Enable',visJoin, ...
            'Value',max(1,size(data,1)), ...
            'ListBoxTop',max(1,get(uih.listJoin,'ListBoxTop')))

         %update button states
         set(uih.cmdAddJoin,'Enable',visAdd)
         set(uih.cmdDelJoin,'Enable',visDel)
         set(uih.cmdChoose,'Enable',visChoose)

         drawnow

      case 'choose'  %copy residual (non-join) columns to bottom pane lists

         data = get(uih.listJoin,'UserData');

         if ~isempty(data)

            Iavail0 = [1:length(uih.s0.name)];
            Iavail1 = [1:length(uih.s1.name)];

            Iavail0(data(:,1)') = NaN;
            Iavail1(data(:,2)') = NaN;

            %add all columns not in join list to available col lists
            set(uih.listAvail0,'UserData',Iavail0(~isnan(Iavail0)))
            set(uih.listAvail1,'UserData',Iavail1(~isnan(Iavail1)))

            %remove any selected columns that are in join list
            Isel0 = get(uih.listSel0,'UserData');
            Isel1 = get(uih.listSel1,'UserData');
            for n = 1:size(data,1)
               if ~isempty(Isel0)
                  Ibad0 = find(Isel0==data(n,1));
                  if ~isempty(Ibad0)
                     Isel0(Ibad0) = NaN;
                  end
               end
               if ~isempty(Isel1)
                  Ibad1 = find(Isel1==data(n,2));
                  if ~isempty(Ibad1)
                     Isel1(Ibad1) = NaN;
                  end
               end
            end

            %update selected lists
            set(uih.listSel0,'UserData',Isel0(~isnan(Isel0)))
            set(uih.listSel1,'UserData',Isel1(~isnan(Isel1)))

         else  %no key selections - clear bottom lists

            set(uih.listAvail0,'UserData',[])
            set(uih.listAvail1,'UserData',[])
            set(uih.listSel0,'UserData',[])
            set(uih.listSel1,'UserData',[])

         end

         ui_joindata('refreshbot')

      case 'listclick'  %handle list double clicks, using uicontrol tags to identify active list

         if strcmp(get(gcf,'SelectionType'),'open')
            tagname = get(gcbo,'tag');
            switch tagname
               case 'listAvail0'
                  arg = 'addcola';
               case 'listSel0'
                  arg = 'delcola';
               case 'listAvail1'
                  arg = 'addcolb';
               case 'listSel1'
                  arg = 'delcolb';
               otherwise
                  arg = '';
            end
            if ~isempty(arg)
               ui_joindata(arg)
            end
         end

      case 'addcola'  %handle output column additions for A

         %get column selection, list indices
         val = get(uih.listAvail0,'Value');
         Iavail0 = get(uih.listAvail0,'UserData');
         Isel0 = get(uih.listSel0,'UserData');

         %update indices
         Isel0 = [Isel0 Iavail0(val)];
         Iavail0(val) = NaN;
         Iavail0 = Iavail0(~isnan(Iavail0));

         %cache updated indices
         set(uih.listAvail0,'UserData',Iavail0)
         set(uih.listSel0,'UserData',Isel0)

         %repopulate uicontrols in bottom pane
         ui_joindata('refreshbot')

      case 'delcola'  %handle output column deletions for A

         %get column selection, list indices
         val = get(uih.listSel0,'Value');
         Iavail0 = get(uih.listAvail0,'UserData');
         Isel0 = get(uih.listSel0,'UserData');

         %update indices
         Iavail0 = sort([Iavail0 Isel0(val)]);
         Isel0(val) = NaN;
         Isel0 = Isel0(~isnan(Isel0));

         %cache updated indices
         set(uih.listAvail0,'UserData',Iavail0)
         set(uih.listSel0,'UserData',Isel0)

         %repopulate uicontrols in bottom pane
         ui_joindata('refreshbot')

      case 'addcolb'  %handle output column additions for B

         %get column selection, list indices
         val = get(uih.listAvail1,'Value');
         Iavail1 = get(uih.listAvail1,'UserData');
         Isel1 = get(uih.listSel1,'UserData');

         %update indices
         Isel1 = [Isel1 Iavail1(val)];
         Iavail1(val) = NaN;
         Iavail1 = Iavail1(~isnan(Iavail1));

         %cache updated indices
         set(uih.listAvail1,'UserData',Iavail1)
         set(uih.listSel1,'UserData',Isel1)

         %repopulate uicontrols in bottom pane
         ui_joindata('refreshbot')

      case 'delcolb'  %handle output column deletions for B

         %get column selection, list indices
         val = get(uih.listSel1,'Value');
         Iavail1 = get(uih.listAvail1,'UserData');
         Isel1 = get(uih.listSel1,'UserData');

         %update indices
         Iavail1 = sort([Iavail1 Isel1(val)]);
         Isel1(val) = NaN;
         Isel1 = Isel1(~isnan(Isel1));

         %cache updated indices
         set(uih.listAvail1,'UserData',Iavail1)
         set(uih.listSel1,'UserData',Isel1)

         %repopulate uicontrols in bottom pane
         ui_joindata('refreshbot')
         
      case 'jointype'  %validate join type selections
         
         %get jointype selections
         h_gcbo = gcbo;  %get handle of control clicked on
         val = get(h_gcbo,'Value');
         val0 = get(uih.popJoinType0,'Value');
         val1 = get(uih.popJoinType1,'Value');
         
         %check for Lookup option for either structure, set for other structure
         if val == 3
            %set 1 option to Lookup - force Lookup for both join types
            set(uih.popJoinType0,'Value',3)
            set(uih.popJoinType1,'Value',3)
         else
            %revert Lookup option for other selection to avoid conflict
            if h_gcbo == uih.popJoinType0 && val1 == 3
               set(uih.popJoinType1,'Value',2)
            elseif val0 == 3
               set(uih.popJoinType0,'Value',2)
            end
         end

      case 'refreshbot'  %repopulate uicontrols in bottom pane using stored column indices

         %get all indices
         Iavail0 = get(uih.listAvail0,'UserData');
         Isel0 = get(uih.listSel0,'UserData');
         Iavail1 = get(uih.listAvail1,'UserData');

         %get cached preference settings
         Isel1 = get(uih.listSel1,'UserData');
         pref0 = get(uih.editPrefix0,'String');
         pref1 = get(uih.editPrefix1,'String');

         %get structures
         s0 = uih.s0;
         s1 = uih.s1;

         %update available list for A
         if ~isempty(Iavail0)
            strAvail0 = char(concatcellcols([s0.name(Iavail0)',repmat({ ' ('},length(Iavail0),1), ...
                  s0.units(Iavail0)',repmat({')'},length(Iavail0),1)]));
            visAvail0 = 'on';
            visAdd0 = 'on';
         else
            strAvail0 = '';
            visAdd0 = 'off';
            visAvail0 = 'off';
         end

         %update available list for B
         if ~isempty(Iavail1)
            strAvail1 = char(concatcellcols([s1.name(Iavail1)',repmat({ ' ('},length(Iavail1),1), ...
                  s1.units(Iavail1)',repmat({')'},length(Iavail1),1)]));
            visAvail1 = 'on';
            visAdd1 = 'on';
         else
            strAvail1 = '';
            visAvail1 = 'off';
            visAdd1 = 'off';
         end

         %update selected list for A
         if ~isempty(Isel0)
            strSel0 = char(concatcellcols([repmat({pref0},length(Isel0),1),s0.name(Isel0)',repmat({ ' ('},length(Isel0),1), ...
                  s0.units(Isel0)',repmat({')'},length(Isel0),1)]));
            visSel0 = 'on';
            visDel0 = 'on';
         else
            strSel0 = '';
            visSel0 = 'off';
            visDel0 = 'off';
         end

         %update selected list for B
         if ~isempty(Isel1)
            strSel1 = char(concatcellcols([repmat({pref1},length(Isel1),1),s1.name(Isel1)',repmat({ ' ('},length(Isel1),1), ...
                  s1.units(Isel1)',repmat({')'},length(Isel1),1)]));
            visSel1 = 'on';
            visDel1 = 'on';
         else
            strSel1 = '';
            visSel1 = 'off';
            visDel1 = 'off';
         end

         %update list contents, settings
         set(uih.listAvail0, ...
            'String',strAvail0, ...
            'Value',max(1,min(length(Iavail0),get(uih.listAvail0,'Value'))), ...
            'Enable',visAvail0, ...
            'ListBoxTop',max(1,get(uih.listAvail0,'ListBoxTop')))
         set(uih.listAvail1, ...
            'String',strAvail1, ...
            'Value',max(1,min(length(Iavail1),get(uih.listAvail1,'Value'))), ...
            'Enable',visAvail1, ...
            'ListBoxTop',max(1,get(uih.listAvail1,'ListBoxTop')))
         set(uih.listSel0, ...
            'String',strSel0, ...
            'Value',max(1,length(Isel0)), ...
            'Enable',visSel0, ...
            'ListBoxTop',max(1,get(uih.listSel0,'ListBoxTop')))
         set(uih.listSel1, ...
            'String',strSel1, ...
            'Value',max(1,length(Isel1)), ...
            'Enable',visSel1, ...
            'ListBoxTop',max(1,get(uih.listSel1,'ListBoxTop')))

         %toggle button states
         set(uih.cmdAdd0,'Enable',visAdd0)
         set(uih.cmdAdd1,'Enable',visAdd1)
         set(uih.cmdDel0,'Enable',visDel0)
         set(uih.cmdDel1,'Enable',visDel1)

         %update eval button state
         if ~isempty(Isel0) && ~isempty(Isel1)
            set(uih.cmdEval,'Enable','on')
         else
            set(uih.cmdEval,'Enable','off')
         end

         drawnow

      end

   end

end