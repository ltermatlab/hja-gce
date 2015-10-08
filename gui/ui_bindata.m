function ui_bindata(op,s,h_cb,cb)
%GCE Data Toolbox dialog for calculating statistics on aggregated data binned by values in a specified column.
%
%syntax:  ui_bindata(op,s)
%
%input:
%  op = operation (default = 'init' to initialize dialog)
%  s = data structure
%
%output:
%  none
%
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
%last modified: 25-Jun-2013

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
      h_dlg = findobj('Tag','dlgBinnedStats');
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

         res = get(0,'ScreenSize');
         bgcolor = [.95 .95 .95];
         figpos = [max(1,0.5.*(res(3)-550)) max(50,0.5.*(res(4)-530)) 550 630];

         h_dlg = figure('Visible','off', ...
            'Color',bgcolor, ...
            'KeyPressFcn','figure(gcf)', ...
            'MenuBar','none', ...
            'Name','Binned Statistics', ...
            'NumberTitle','off', ...
            'Position',figpos, ...
            'Tag','dlgBinnedStats', ...
            'ToolBar','none', ...
            'Resize','off', ...
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
            'Style','frame', ...
            'BackgroundColor',[.9 .9 .9], ...
            'ForegroundColor',[0 0 0], ...
            'Position',[240 490 305 110]);

         uicontrol('Parent',h_dlg, ...
            'Style','frame', ...
            'BackgroundColor',[.9 .9 .9], ...
            'ForegroundColor',[0 0 0], ...
            'Position',[240 345 305 135]);

         uicontrol('Parent',h_dlg, ...
            'Style','frame', ...
            'BackgroundColor',[.9 .9 .9], ...
            'ForegroundColor',[0 0 0], ...
            'Position',[240 50 305 285]);

         uicontrol('Parent',h_dlg, ...
            'BackgroundColor',bgcolor, ...
            'FontSize',10, ...
            'FontWeight','bold', ...
            'ForegroundColor',[0 0 0.7], ...
            'ListboxTop',0, ...
            'Position',[4 605 215 18], ...
            'String','Available Columns', ...
            'Style','text', ...
            'Tag','lblAvailable');

         uicontrol('Parent',h_dlg, ...
            'BackgroundColor',bgcolor, ...
            'FontSize',10, ...
            'FontWeight','bold', ...
            'ForegroundColor',[0 0 0.7], ...
            'ListboxTop',0, ...
            'Position',[260 605 260 18], ...
            'String','Column Selections', ...
            'Style','text', ...
            'Tag','lblSelections');

         uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[.9 .9 .9], ...
            'FontSize',10, ...
            'FontWeight','bold', ...
            'ForegroundColor',[0 0 0.7], ...
            'Position',[255 564 85 18], ...
            'String','Bin Column', ...
            'Style','text', ...
            'Tag','lblBinCol');

         collist = concatcellcols([s.name',repmat({'  ('},length(s.name),1), ...
               s.units',repmat({')'},length(s.name),1)]);

         h_popBinCol = uicontrol('Parent',h_dlg, ...
            'Style','popupmenu', ...
            'BackgroundColor',[1 1 1], ...
            'ForegroundColor',[0 0 0], ...
            'FontSize',10, ...
            'Position',[342 566 185 18], ...
            'String',char([{'<select a column>'} ; ...
               collist]), ..., ...
            'Value',1, ...
            'UserData',0, ...
            'Callback','ui_bindata(''bincol'')', ...
            'Tag','popBinCol');

         uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'BackgroundColor',[.9 .9 .9], ...
            'FontSize',10, ...
            'FontWeight','bold', ...
            'ForegroundColor',[0 0 0.7], ...
            'Position',[250 530 65 18], ...
            'String','Start', ...
            'Tag','lblBinStart');

         uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'BackgroundColor',[.9 .9 .9], ...
            'FontSize',10, ...
            'FontWeight','bold', ...
            'ForegroundColor',[0 0 0.7], ...
            'Position',[400 530 50 18], ...
            'String','End', ...
            'Tag','lblBinEnd');

         uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'BackgroundColor',[.9 .9 .9], ...
            'FontSize',10, ...
            'FontWeight','bold', ...
            'ForegroundColor',[0 0 0.7], ...
            'Position',[250 500 60 18], ...
            'String','Interval', ...
            'Tag','lblBinInt');

         h_editBinStart = uicontrol('Parent',h_dlg, ...
            'Style','edit', ...
            'BackgroundColor',[.8 .8 .8], ...
            'ForegroundColor',[0 0 0], ...
            'FontSize',10, ...
            'Position',[315 529 75 20], ...
            'String','', ...
            'Tag','editBinStart');

         h_editBinEnd = uicontrol('Parent',h_dlg, ...
            'Style','edit', ...
            'BackgroundColor',[.8 .8 .8], ...
            'ForegroundColor',[0 0 0], ...
            'FontSize',10, ...
            'Position',[450 529 75 20], ...
            'String','', ...
            'Tag','editBinEnd');

         h_editBinInt = uicontrol('Parent',h_dlg, ...
            'Style','edit', ...
            'BackgroundColor',[.8 .8 .8], ...
            'ForegroundColor',[0 0 0], ...
            'FontSize',10, ...
            'Position',[315 499 75 20], ...
            'String','', ...
            'Tag','editBinInt');

         h_chkEmptyBins = uicontrol('Parent',h_dlg, ...
            'Style','checkbox', ...
            'BackgroundColor',[.9 .9 .9], ...
            'ForegroundColor',[0 0 0], ...
            'FontSize',10, ...
            'Position',[420 500 100 18], ...
            'String','Empty bins?', ...
            'Value',1, ...
            'TooltipString','Option to include a row for every bin even when a group contains no observations', ...
            'Tag','chkEmptyBins');

         uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'BackgroundColor',[.9 .9 .9], ...
            'FontSize',10, ...
            'FontWeight','bold', ...
            'ForegroundColor',[0 0 0.7], ...
            'ListboxTop',0, ...
            'Position',[300 455 215 18], ...
            'String','Group Records By', ...
            'Tag','lblAggregate');

         uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'BackgroundColor',[.9 .9 .9], ...
            'FontSize',10, ...
            'FontWeight','bold', ...
            'ForegroundColor',[0 0 0.7], ...
            'ListboxTop',0, ...
            'Position',[300 310 215 18], ...
            'String','Calculate Statistics For', ...
            'Tag','lblAnalyze');

         h_listAvailable = uicontrol('Parent',h_dlg, ...
            'Style','listbox', ...
            'BackgroundColor',[1 1 1], ...
            'FontSize',10, ...
            'HorizontalAlignment','left', ...
            'Position',[6 50 225 550], ...
            'String',char(collist), ...
            'UserData',[1:length(s.name)], ...
            'Tag','listAvailable', ...
            'Value',1);

         h_listAggregate = uicontrol('Parent',h_dlg, ...
            'Style','listbox', ...
            'BackgroundColor',[1 1 1], ...
            'FontSize',10, ...
            'HorizontalAlignment','left', ...
            'Position',[290 355 245 100], ...
            'String',' ', ...
            'UserData',[], ...
            'Tag','listAggregate', ...
            'Value',1);

         h_listAnalyze = uicontrol('Parent',h_dlg, ...
            'Style','listbox', ...
            'BackgroundColor',[1 1 1], ...
            'FontSize',10, ...
            'HorizontalAlignment','left', ...
            'Position',[290 210 245 100], ...
            'String',' ', ...
            'UserData',[], ...
            'Tag','listAnalyze', ...
            'Value',1);

         h_cmdAddAggr = uicontrol('Parent',h_dlg, ...
            'Callback','ui_bindata(''aggr_add'')', ...
            'FontSize',10, ...
            'FontWeight','bold', ...
            'Position',[249 410 30 22], ...
            'String','>', ...
            'ToolTipString','Add selected column to the ''Aggregate By'' list', ...
            'Tag','cmdAddAggr');

         h_cmdRemAggr = uicontrol('Parent',h_dlg, ...
            'Enable','off', ...
            'Callback','ui_bindata(''aggr_rem'')', ...
            'FontSize',10, ...
            'FontWeight','bold', ...
            'Position',[249 380 30 22], ...
            'String','<', ...
            'ToolTipString','Remove selected column from the ''Aggregate By'' list', ...
            'Tag','cmdRemAggr');

         h_cmdAddStat = uicontrol('Parent',h_dlg, ...
            'Callback','ui_bindata(''stat_add'')', ...
            'FontSize',10, ...
            'FontWeight','bold', ...
            'Position',[249 265 30 22], ...
            'String','>', ...
            'ToolTipString','Add selected column to the ''Calculate Statistics For'' list', ...
            'Tag','cmdAddStat');

         h_cmdRemStat = uicontrol('Parent',h_dlg, ...
            'Enable','off', ...
            'Callback','ui_bindata(''stat_rem'')', ...
            'FontSize',10, ...
            'FontWeight','bold', ...
            'ListboxTop',0, ...
            'Position',[249 235 30 22], ...
            'String','<', ...
            'ToolTipString','Remove selected column from the ''Calculate Statistics For'' list', ...
            'Tag','cmdRemStat');

         h_chkFlags = uicontrol('Parent',h_dlg, ...
            'Position',[260 180 175 20], ...
            'Style','checkbox', ...
            'FontSize',10, ...
            'BackgroundColor',[.9 .9 .9], ...
            'String',' Remove values flagged', ...
            'Value',0, ...
            'Tag','chkFlags', ...
            'TooltipString','Option to remove values assigned the specified flag codes prior to analysis', ...
            'Callback','ui_bindata(''flags'')');

         h_editFlags = uicontrol('Parent',h_dlg, ...
            'Position',[435 180 55 20], ...
            'Style','edit', ...
            'FontSize',10, ...
            'BackgroundColor',[1 1 1], ...
            'ForegroundColor',[0 0 0], ...
            'String','<any>', ...
            'HorizontalAlignment','left', ...
            'Enable','off', ...
            'Tag','editFlags', ...
            'Callback','ui_bindata(''flags'')');

         h_cmdFlags = uicontrol('Parent',h_dlg, ...
            'Position',[496 178 40 22], ...
            'Style','pushbutton', ...
            'String','List', ...
            'Enable','off', ...
            'TooltipString','Choose flag codes from a list', ...
            'Callback','ui_bindata(''pickflags'')', ...
            'Tag','cmdFlags');

         %parse flag codes from metadata
         if gce_valid(s,'data')
            flagstr = lookupmeta(s.metadata,'Data','Codes');
         else
            flagstr = '';
         end
         if ~isempty(flagstr)
            if ~isempty(strfind(flagstr,'|'))
               flaglist = splitstr(flagstr,'|');
            elseif ~isempty(strfind(flagstr,','))
               flaglist = splitstr(flagstr,',');
            else
               flaglist = cellstr(flagstr);  %assume single entry
            end
            flagdefs = [];
            for n = 1:length(flaglist)
               tmp = splitstr(flaglist{n},'=');
               if iscell(tmp) && length(tmp) == 2
                  if ~isempty(tmp{1})
                     flagcode = tmp{1};
                  else
                     flagcode = '?';
                  end
                  flagdefs = [flagdefs ; {flagcode(1)} , tmp(2)];
               end
            end
         else
            flagdefs = {'Q','questionable value';'I','invalid value (out of range)';'E','estimated value'};
         end
         
         %look up 'I' and 'Q' flag code positions if defined for default rule settings
         Iflag1 = find(strcmp(flagdefs(:,1),'I'));
         if isempty(Iflag1)
            Iflag1 = 1;
         else
            Iflag1 = Iflag1(1);
         end
         Iflag2 = find(strcmp(flagdefs(:,1),'Q'));
         if isempty(Iflag2)
            Iflag2 = 1;
         else
            Iflag2 = Iflag2(1);
         end

         %define Q/C rule type array with cols for popupmenu label, criteria type, criteria units
         qcruletypes = {'if number missing >','missing','count'; ...
            'if percent missing >','missing','percent'; ...
            'if consecutive missing >','missing','consecutive'; ...
            'if number flagged >','flagged','count'; ...
            'if percent flagged >','flagged','percent'; ...
            'if consecutive flagged >','flagged','consecutive'};

         uicontrol('Parent',h_dlg, ...
            'Position',[250 148 50 20], ...
            'Style','text', ...
            'Fontsize',10, ...
            'HorizontalAlignment','right', ...
            'BackgroundColor',[.9 .9 .9], ...
            'ForegroundColor',[0 0 0], ...
            'String','Flag as ', ...
            'Tag','txtQC1');

         h_popQCFlag1 = uicontrol('Parent',h_dlg, ...
            'Position',[300 151 40 20], ...
            'Style','popupmenu', ...
            'FontSize',10, ...
            'BackgroundColor',[1 1 1], ...
            'ForegroundColor',[0 0 0], ...
            'String',flagdefs(:,1), ...
            'TooltipString','Select a flag to assign for this Q/C rule', ...
            'Value',Iflag1, ...
            'UserData',flagdefs(:,1), ...
            'Tag','popQCFlag1');

         h_popQCRule1 = uicontrol('Parent',h_dlg, ...
            'Position',[340 151 140 20], ...
            'Style','popupmenu', ...
            'Fontsize',10, ...
            'HorizontalAlignment','center', ...
            'BackgroundColor',[1 1 1], ...
            'ForegroundColor',[0 0 0], ...
            'String',qcruletypes(:,1), ...
            'TooltipString','Select the type of criteria to use for this Q/C rule', ...
            'Value',2, ...
            'Tag','popQCRule1');

         h_editQC1 = uicontrol('Parent',h_dlg, ...
            'Position',[480 148 55 22], ...
            'Style','edit', ...
            'FontSize',10, ...
            'BackgroundColor',[1 1 1], ...
            'HorizontalAlignment','left', ...
            'String','', ...
            'TooltipString','Enter numeric criteria for this Q/C rule (or clear box to omit rule)', ...
            'Callback','ui_bindata(''checknum'')', ...
            'Tag','editQC1');

         uicontrol('Parent',h_dlg, ...
            'Position',[250 118 50 20], ...
            'Style','text', ...
            'Fontsize',10, ...
            'HorizontalAlignment','right', ...
            'BackgroundColor',[.9 .9 .9], ...
            'ForegroundColor',[0 0 0], ...
            'String','Flag as ', ...
            'Tag','txtQC2');

         h_popQCFlag2 = uicontrol('Parent',h_dlg, ...
            'Position',[300 121 40 20], ...
            'Style','popupmenu', ...
            'FontSize',10, ...
            'BackgroundColor',[1 1 1], ...
            'ForegroundColor',[0 0 0], ...
            'String',flagdefs(:,1), ...
            'TooltipString','Select a flag to assign for this Q/C rule', ...
            'Value',Iflag2, ...
            'UserData',flagdefs(:,1), ...
            'Tag','popQCFlag2');

         h_popQCRule2 = uicontrol('Parent',h_dlg, ...
            'Position',[340 121 140 20], ...
            'Style','popupmenu', ...
            'Fontsize',10, ...
            'HorizontalAlignment','center', ...
            'BackgroundColor',[1 1 1], ...
            'ForegroundColor',[0 0 0], ...
            'String',qcruletypes(:,1), ...
            'TooltipString','Select the type of criteria to use for this Q/C rule', ...
            'Value',2, ...
            'Tag','popQCRule2');

         h_editQC2 = uicontrol('Parent',h_dlg, ...
            'Position',[480 118 55 22], ...
            'Style','edit', ...
            'FontSize',10, ...
            'BackgroundColor',[1 1 1], ...
            'HorizontalAlignment','left', ...
            'String','', ...
            'TooltipString','Enter numeric criteria for this Q/C rule (or clear box to omit rule)', ...
            'Callback','ui_bindata(''checknum'')', ...
            'Tag','editQC2');

         uicontrol('Parent',h_dlg, ...
            'Position',[250 88 50 20], ...
            'Style','text', ...
            'Fontsize',10, ...
            'HorizontalAlignment','right', ...
            'BackgroundColor',[.9 .9 .9], ...
            'ForegroundColor',[0 0 0], ...
            'String','Flag as ', ...
            'Tag','txtQC3');

         h_popQCFlag3 = uicontrol('Parent',h_dlg, ...
            'Position',[300 91 40 20], ...
            'Style','popupmenu', ...
            'FontSize',10, ...
            'BackgroundColor',[1 1 1], ...
            'ForegroundColor',[0 0 0], ...
            'String',flagdefs(:,1), ...
            'TooltipString','Select a flag to assign for this Q/C rule', ...
            'Value',Iflag1, ...
            'UserData',flagdefs(:,1), ...
            'Tag','popQCFlag3');

         h_popQCRule3 = uicontrol('Parent',h_dlg, ...
            'Position',[340 91 140 20], ...
            'Style','popupmenu', ...
            'Fontsize',10, ...
            'HorizontalAlignment','center', ...
            'BackgroundColor',[1 1 1], ...
            'ForegroundColor',[0 0 0], ...
            'String',qcruletypes(:,1), ...
            'TooltipString','Select the type of criteria to use for this Q/C rule', ...
            'Value',5, ...
            'Tag','popQCRule3');

         h_editQC3 = uicontrol('Parent',h_dlg, ...
            'Position',[480 88 55 22], ...
            'Style','edit', ...
            'FontSize',10, ...
            'BackgroundColor',[1 1 1], ...
            'HorizontalAlignment','left', ...
            'String','', ...
            'TooltipString','Enter numeric criteria for this Q/C rule (or clear box to omit rule)', ...
            'Callback','ui_bindata(''checknum'')', ...
            'Tag','editQC2');

         uicontrol('Parent',h_dlg, ...
            'Position',[250 58 50 20], ...
            'Style','text', ...
            'Fontsize',10, ...
            'HorizontalAlignment','right', ...
            'BackgroundColor',[.9 .9 .9], ...
            'ForegroundColor',[0 0 0], ...
            'String','Flag as ', ...
            'Tag','txtQC3');

         h_popQCFlag4 = uicontrol('Parent',h_dlg, ...
            'Position',[300 61 40 20], ...
            'Style','popupmenu', ...
            'FontSize',10, ...
            'BackgroundColor',[1 1 1], ...
            'ForegroundColor',[0 0 0], ...
            'String',flagdefs(:,1), ...
            'TooltipString','Select a flag to assign for this Q/C rule', ...
            'Value',Iflag2, ...
            'UserData',flagdefs(:,1), ...
            'Tag','popQCFlag3');

         h_popQCRule4 = uicontrol('Parent',h_dlg, ...
            'Position',[340 61 140 20], ...
            'Style','popupmenu', ...
            'Fontsize',10, ...
            'HorizontalAlignment','center', ...
            'BackgroundColor',[1 1 1], ...
            'ForegroundColor',[0 0 0], ...
            'String',qcruletypes(:,1), ...
            'TooltipString','Select the type of criteria to use for this Q/C rule', ...
            'Value',5, ...
            'Tag','popQCRule3');

         h_editQC4 = uicontrol('Parent',h_dlg, ...
            'Position',[480 58 55 22], ...
            'Style','edit', ...
            'FontSize',10, ...
            'BackgroundColor',[1 1 1], ...
            'HorizontalAlignment','left', ...
            'String','', ...
            'TooltipString','Enter numeric criteria for this Q/C rule (or clear box to omit rule)', ...
            'Callback','ui_bindata(''checknum'')', ...
            'Tag','editQC2');

         h_cmdCancel = uicontrol('Parent',h_dlg, ...
            'Callback','ui_bindata(''cancel'')', ...
            'FontSize',9, ...
            'Position',[15 10 60 25], ...
            'String','Cancel', ...
            'TooltipString','Cancel the operation and close the dialog window', ...
            'Tag','cmdCancel');

         h_chkClose = uicontrol('Parent',h_dlg, ...
            'Style','checkbox', ...
            'Position',[160 10 270 20], ...
            'BackgroundColor',bgcolor, ...
            'FontSize',10, ...
            'String','Close dialog after exporting the results', ...
            'Value',1, ...
            'Tag','chkClose');

         h_cmdEval = uicontrol('Parent',h_dlg, ...
            'Callback','ui_bindata(''eval'')', ...
            'Enable','off', ...
            'FontSize',9, ...
            'ListboxTop',0, ...
            'Position',[480 10 60 25], ...
            'String','Proceed', ...
            'TooltipString','Perform the aggregated statistics and open the structure for editing', ...
            'Tag','cmdEval', ...
            'UserData',s);

         uih = struct( ...
            'popBinCol',h_popBinCol, ...
            'editBinStart',h_editBinStart, ...
            'editBinEnd',h_editBinEnd, ...
            'editBinInt',h_editBinInt, ...
            'listAvailable',h_listAvailable, ...
            'listAggregate',h_listAggregate, ...
            'listAnalyze',h_listAnalyze, ...
            'cmdAddAggr',h_cmdAddAggr, ...
            'cmdRemAggr',h_cmdRemAggr, ...
            'cmdAddStat',h_cmdAddStat, ...
            'cmdRemStat',h_cmdRemStat, ...
            'chkEmptyBins',h_chkEmptyBins, ...
            'chkFlags',h_chkFlags, ...
            'editFlags',h_editFlags, ...
            'cmdFlags',h_cmdFlags, ...
            'popQCFlag1',h_popQCFlag1, ...
            'popQCRule1',h_popQCRule1, ...
            'editQC1',h_editQC1, ...
            'popQCFlag2',h_popQCFlag2, ...
            'popQCRule2',h_popQCRule2, ...
            'editQC2',h_editQC2, ...
            'popQCFlag3',h_popQCFlag3, ...
            'popQCRule3',h_popQCRule3, ...
            'editQC3',h_editQC3, ...
            'popQCFlag4',h_popQCFlag4, ...
            'popQCRule4',h_popQCRule4, ...
            'editQC4',h_editQC4, ...
            'cmdEval',h_cmdEval, ...
            'cmdCancel',h_cmdCancel', ...
            'chkClose',h_chkClose, ...
            'qcruletypes',[], ...
            'flagdefs',[], ...
            's',s, ...
            'h_cb',h_cb, ...
            'cb',cb);

         %update array fields
         uih.qcruletypes = qcruletypes;
         uih.flagdefs = flagdefs;

         set(h_dlg,'Visible','on','UserData',uih)
         drawnow

      end

   end

else  %handle callbacks

   h_dlg = [];

   if length(findobj) > 2
      h_dlg = gcf;
      if ~strcmp(get(h_dlg,'Tag'),'dlgBinnedStats')
         h_dlg = [];
      end
   end

   if ~isempty(h_dlg)

      uih = get(h_dlg,'UserData');

      switch op

         case 'cancel'  %close dialog

            close(h_dlg)
            ui_aboutgce('reopen')  %check for last window

         case 'update'  %update list contents

            s = get(uih.cmdEval,'UserData');

            if isstruct(s)

               %get column indices
               bincol = get(uih.popBinCol,'Value') - 1;
               I_avail = get(uih.listAvailable,'UserData');
               I_aggr = get(uih.listAggregate,'UserData');
               I_analyze = get(uih.listAnalyze,'UserData');

               %get column names, attributes
               vars = s.name;
               units = s.units;
               cols = length(s.name);
               varstr = cell(1,cols);

               %add unit strings
               for n = 1:cols
                  varstr{n} = [vars{n},'  (',units{n},')'];
               end

               if ~isempty(I_avail)
                  s_avail = varstr(I_avail);
               else
                  s_avail = {''};
               end

               if ~isempty(I_aggr)
                  s_aggr = varstr(I_aggr);
               else
                  s_aggr = {''};
               end

               if ~isempty(I_analyze)
                  s_analyze = varstr(I_analyze);
               else
                  s_analyze = {''};
               end

               %store column indices
               set(uih.listAvailable, ...
                  'String',s_avail, ...
                  'Value',max(1,min(get(uih.listAvailable,'Value'),length(I_avail))))

               set(uih.listAggregate, ...
                  'String',s_aggr, ...
                  'Value',max(1,min(get(uih.listAggregate,'Value'),length(I_aggr))))

               set(uih.listAnalyze, ...
                  'String',s_analyze, ...
                  'Value',max(1,min(get(uih.listAnalyze,'Value'),length(I_analyze))))

               %toggle add/remove buttons according to list status
               if isempty(I_avail)
                  set(uih.cmdAddAggr,'Enable','off')
                  set(uih.cmdAddStat,'Enable','off')
               else
                  set(uih.cmdAddAggr,'Enable','on')
                  set(uih.cmdAddStat,'Enable','on')
               end

               if isempty(I_aggr)
                  set(uih.cmdRemAggr,'Enable','off')
               else
                  set(uih.cmdRemAggr,'Enable','on')
               end

               if isempty(I_analyze)
                  set(uih.cmdRemStat,'Enable','off')
               else
                  set(uih.cmdRemStat,'Enable','on')
               end

               binerr = 0;
               if bincol > 0
                  set([uih.editBinStart ; uih.editBinEnd ; uih.editBinInt], ...
                     'BackgroundColor',[1 1 1],'Enable','on')
                  if sum(I_avail==bincol) == 0
                     bincol = 0;
                     binerr = 1;
                     set(uih.popBinCol,'Value',1,'UserData',0)
                     set([uih.editBinStart ; uih.editBinEnd ; uih.editBinInt], ...
                        'String','','BackgroundColor',[.8 .8 .8],'Enable','off')
                  end
               else
                  set([uih.editBinStart ; uih.editBinEnd ; uih.editBinInt], ...
                     'String','','BackgroundColor',[.8 .8 .8],'Enable','off')
               end

               %toggle proceed button according to list status
               if bincol > 0 && ~isempty(I_analyze) && ~isempty(get(uih.editBinStart,'String')) ...
                     && ~isempty(get(uih.editBinEnd,'String')) && ~isempty(get(uih.editBinInt,'String'))
                  set(uih.cmdEval,'Enable','on')
               else
                  set(uih.cmdEval,'Enable','off')
               end

               drawnow

               if binerr == 1
                  messagebox('init','Bin column selection is no longer valid - menu reset', ...
                     '','Error',[.9 .9 .9])
               end

            end

         case 'eval'  %evaluate input and generated derived structure

            s = uih.s;

            %get uicontrol settings, stored indices
            bincol = get(uih.popBinCol,'Value') - 1;
            binstart = str2num(get(uih.editBinStart,'String'));
            binend = str2num(get(uih.editBinEnd,'String'));
            binint = str2num(get(uih.editBinInt,'String'));
            I_aggr = get(uih.listAggregate,'UserData');
            I_stat = get(uih.listAnalyze,'UserData');
            emptybinopt = get(uih.chkEmptyBins,'Value');

            %handle q/c flag removal options
            flagopt = get(uih.chkFlags,'Value');
            flagchars = deblank(get(uih.editFlags,'String'));
            if flagopt == 1 && strcmp(flagchars,'<any>') ~= 1
               %if remove flags checked and codes specified, use flag chars instead of integer option
               flagopt = flagchars;
            end

            %generate qcrules array
            qcrules = [];
            qcruletypes = uih.qcruletypes;
            qcflagdefs = uih.flagdefs;

            %process criteria 1
            crit = deblank(get(uih.editQC1,'String'));
            if ~isempty(crit)
               ruleval = get(uih.popQCRule1,'Value');
               flagval = get(uih.popQCFlag1,'Value');
               qcrules = [qcrules ; {qcruletypes{ruleval,2} crit qcruletypes{ruleval,3} qcflagdefs{flagval,1}}];
            end

            %process criteria 2
            crit = deblank(get(uih.editQC2,'String'));
            if ~isempty(crit)
               ruleval = get(uih.popQCRule2,'Value');
               flagval = get(uih.popQCFlag2,'Value');
               qcrules = [qcrules ; {qcruletypes{ruleval,2} crit qcruletypes{ruleval,3} qcflagdefs{flagval,1}}];
            end

            %process criteria 3
            crit = deblank(get(uih.editQC3,'String'));
            if ~isempty(crit)
               ruleval = get(uih.popQCRule3,'Value');
               flagval = get(uih.popQCFlag3,'Value');
               qcrules = [qcrules ; {qcruletypes{ruleval,2} crit qcruletypes{ruleval,3} qcflagdefs{flagval,1}}];
            end

            %process criteria 4
            crit = deblank(get(uih.editQC4,'String'));
            if ~isempty(crit)
               ruleval = get(uih.popQCRule4,'Value');
               flagval = get(uih.popQCFlag4,'Value');
               qcrules = [qcrules ; {qcruletypes{ruleval,2} crit qcruletypes{ruleval,3} qcflagdefs{flagval,1}}];
            end

            if bincol > 0 && ~isempty(binstart) && ~isempty(binend) && ~isempty(binint)

               set(gcf,'Pointer','watch')
               drawnow

               [s2,msg] = aggr_bindata(s,bincol,[binstart,binend,binint],emptybinopt,flagopt,I_aggr,I_stat,qcrules);

               set(gcf,'Pointer','arrow')
               drawnow

               if ~isempty(s2)

                  closeval = get(uih.chkClose,'Value');
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
               messagebox('init','Bin column or bin limits are invalid - operation cancelled', ...
                  '','Error',[.9 .9 .9])
            end

         case 'checknum'  %validate q/c criteria limit

            h_edit = gcbo;  %get handle of active editbox
            str = deblank(get(h_edit,'String'));  %get editbox contents

            if ~isempty(str)
               val = str2num(str);
               if isempty(val) || val < 0
                  set(h_edit,'String',get(h_edit,'UserData'))  %restore last good value
                  messagebox('init','Flagged value limit must be a positive integer - field reset', ...
                     '','Error',[.9 .9 .9])
               else
                  set(h_edit,'UserData',str)  %buffer new good value
               end
               drawnow
            else
               set(h_edit,'String','','UserData','')  %clear entry and stored last value
            end

         case 'copysel'  %perform list copy operations, identifying source/target based on cached handles

            %get handles
            h_source = get(uih.cmdAddAggr,'UserData');
            h_target = get(uih.cmdRemAggr,'UserData');
            h_list = uih.listAvailable;

            if ~isempty(h_source) && ~isempty(h_target)

               %get indices
               I_target = get(h_target,'UserData');
               I_source = get(h_source,'UserData');
               I_sel = I_source(get(h_source,'Value'));

               %update indices
               I_target = [I_target,I_sel];
               I_source = I_source(find(I_source~=I_sel));

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
               ui_bindata('update');

            end

         case 'aggr_add'

            %assign handles
            set(uih.cmdAddAggr,'UserData',uih.listAvailable);  %source
            set(uih.cmdRemAggr,'UserData',uih.listAggregate);  %target

            %update listboxes
            ui_bindata('copysel')

         case 'aggr_rem'

            %assign handles
            set(uih.cmdAddAggr,'UserData',uih.listAggregate);  %source
            set(uih.cmdRemAggr,'UserData',uih.listAvailable);  %target

            %update listboxes
            ui_bindata('copysel')

         case 'stat_add'

            %assign handles
            set(uih.cmdAddAggr,'UserData',uih.listAvailable);  %source
            set(uih.cmdRemAggr,'UserData',uih.listAnalyze);  %target

            %update listboxes
            ui_bindata('copysel')

         case 'stat_rem'

            %assign handles
            set(uih.cmdAddAggr,'UserData',uih.listAnalyze);  %source
            set(uih.cmdRemAggr,'UserData',uih.listAvailable);  %target

            %update listboxes
            ui_bindata('copysel')

         case 'bincol'  %handle bin column changes

            bincol = get(uih.popBinCol,'Value') - 1;

            if bincol ~= get(uih.popBinCol,'UserData')

               if bincol > 0

                  s = get(uih.cmdEval,'UserData');

                  if ~strcmp(s.datatype{bincol},'s')

                     Iavail = get(uih.listAvailable,'UserData');

                     err = 0;
                     if ~isempty(Iavail)
                        if isempty(find(Iavail==bincol))
                           err = 1;
                        end
                     else
                        err = 1;
                     end

                     if err == 1
                        bincol = 0;
                        set(uih.popBinCol,'Value',bincol+1)
                        set(uih.cmdEval,'Enable','off')
                        set([uih.editBinStart ; uih.editBinEnd ; uih.editBinInt], ...
                           'String','','BackgroundColor',[.8 .8 .8],'Enable','off')
                        messagebox('init','Invalid bin selection column - menu reset', ...
                           '','Error',[.9 .9 .9])
                     else
                        vals = s.values{bincol};
                        vals = vals(~isnan(vals));
                        binstart = floor(min(vals));
                        binend = ceil(max(vals));
                        binint = ceil((binend-binstart)./20);
                        set(uih.editBinStart,'String',num2str(binstart))
                        set(uih.editBinEnd,'String',num2str(binend))
                        set(uih.editBinInt,'String',num2str(binint))
                     end

                     set(uih.popBinCol,'UserData',bincol)  %update last value cache

                  else

                     set(uih.popBinCol,'Value',1,'UserData',0)
                     set([uih.editBinStart ; uih.editBinEnd ; uih.editBinInt], ...
                        'String','','BackgroundColor',[.8 .8 .8],'Enable','off')
                     drawnow
                     messagebox('init','Bin column must be numerical - menu reset', ...
                        '','Error',[.9 .9 .9])

                  end

               end

               ui_bindata('update')

            end

         case 'pickflags'  %open dialog to choose flags to remove prior to aggregation

            flagdefs = uih.flagdefs;

            if ~isempty(flagdefs)

               str = concatcellcols(flagdefs,' = ');
               Isel = listdialog('liststring',str, ...
                  'name','Choose Flags', ...
                  'promptstring','Choose Q/C Flags for Value Removal', ...
                  'selectionmode','multiple', ...
                  'initialvalue',1, ...
                  'listsize',[0 0 500 300]);

               %check for cancel
               if ~isempty(Isel)
                  flags = [flagdefs{Isel,1}];
                  set(uih.editFlags,'String',flags)
               end

            end

         case 'flags'  %validate flag selections on change

            flags = deblank(get(uih.editFlags,'String'));
            if isempty(flags)
               flags = '<any>';
            end

            flagopt = get(uih.chkFlags,'Value');
            if flagopt == 1
               enable = 'on';
            else
               enable = 'off';
            end

            set(uih.editFlags,'Enable',enable,'String',flags)
            set(uih.cmdFlags,'Enable',enable)
            drawnow

      end

   end

end
