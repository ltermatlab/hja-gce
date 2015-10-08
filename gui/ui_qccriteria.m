function ui_qccriteria(op,s,col,flagdefs,h_cb,cb)
%QA/QC criteria editor dialog called by 'ui_editor' and 'ui_template'
%
%syntax: ui_qccriteria(op,s,col,flagdefs,h_cb,cb)
%
%inputs:
%  op = operation ('init' to open dialog)
%  s = data structure to be edited (or metadata-only data structure with
%     required fields 'name', 'datatype', 'criteria', 'metadata')
%  col = column name or number to edit (default = [], all columns editable)
%  flagdefs = character or cell array containing list of flag codes
%     (in the format 'Q = questionable; ...', default = )
%  h_cb = handle to store output in prior to executing callback
%     (output = [{criteria},{col},{flaglist}])
%  cb = callback to execute after accepting edits (only executed if flags or criteria edited)
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
%last modified: 23-Dec-2014

%set default argument to 'init' if omitted to initialize the dialog
if nargin == 0
   op = 'init';
end

%check for initialize command
if strcmp(op,'init')
   
   if nargin >= 2 && isstruct(s)
      
      %check for required structure fields
      %(note: accepts metadata-only input from ui_editor so bypasses normal validation)
      if isfield(s,'criteria') && isfield(s,'name') && isfield(s,'datatype')
         
         %check for callback arguments, supply defaults if omitted
         if exist('h_cb','var') ~= 1
            h_cb = [];
         end
         
         if exist('cb','var') ~= 1
            cb = '';
         end
         
         if exist('col','var') ~= 1
            col = [];
         end
         
         %validate active column, set mode flag to column changes
         if isempty(col)
            col = 1;
            activecolvis = 'on';  %set flag to enable column changes
         else
            activecolvis = 'off';  %set flag to prevent column changes (single criteria edit mode)
            if ~isnumeric(col)
               col = find(strcmp(s.name,col));  %look up column index by name
               if ~isempty(col)
                  col = col(1);
               else
                  col = 1;
               end
            end
         end
         
         %look up flag definitions from structure if not provided as input
         if exist('flagdefs','var') ~= 1
            flagdefs = [];
         end
         if isempty(flagdefs)
            flagdefs = lookupmeta(s,'Data','Codes');
         end
         
         %parse flag list from definition strings
         if ~iscell(flagdefs)
            flaglist = strrep(flagdefs,'Flags: ','');  %strip out legacy code leader
            if ~isempty(strfind(flaglist,'|'))
               flaglist = splitstr(flaglist,'|');
            elseif ~isempty(strfind(flaglist,','))
               flaglist = splitstr(flaglist,',');
            else
               flaglist = cellstr(flaglist);  %no delimiter - assume single entry
            end
         else
            flaglist = flagdefs;
         end
         
         %format flags for listbox string, userdata
         if ~cellfun('isempty',flaglist)
            flaglist0 = flaglist;
            flaglist = [];
            flagcodes = [];
            for n = 1:length(flaglist0)
               tmp = splitstr(flaglist0{n},'=');
               if length(tmp) == 2
                  flaglist = [flaglist ; {[tmp{1},' -- ',tmp{2}]}];
                  flagcodes = [flagcodes ; tmp(1)];
               end
            end
         else
            flaglist = {'Q -- questionable value';'I -- invalid value (out of range)'};
            flagcodes = [{'Q'};{'I'}];
         end
         
         if length(findobj) > 1
            h_fig = gcf;
         else
            h_fig = [];
         end
         
         %init figutre color/size info
         bgcolor = [0.95 0.95 0.95];
         res = get(0,'ScreenSize');
         figpos = [max(5,(res(3)-700).*0.5) max(30,(res(4)-480).*0.5) 700 480];
         
         h_dlg = figure('Visible','off', ...
            'Color',bgcolor,...
            'KeyPressFcn','figure(gcf)',...
            'MenuBar','none',...
            'ToolBar','none',...
            'Name','Q/C Flag Criteria Editor',...
            'NumberTitle','off',...
            'Position',figpos,...
            'Resize','off',...
            'Tag','dlgQCFlags',...
            'DefaultuicontrolUnits','pixels');
         
         %disable docking
         if mlversion >= 7
            set(h_dlg,'WindowStyle','normal')
            set(h_dlg,'DockControls','off')
         end
         
         uicontrol('Parent',h_dlg, ...
            'Style','frame', ...
            'ForegroundColor',[0 0 0], ...
            'BackgroundColor',bgcolor, ...
            'Position',[1 1 figpos(3) figpos(4)]);
         
         uicontrol(...
            'Parent',h_dlg,...
            'BackgroundColor',bgcolor,...
            'Position',[10 45 figpos(3)-18 115],...
            'Style','frame',...
            'Tag','frame2');
         
         uicontrol(...
            'Parent',h_dlg,...
            'BackgroundColor',bgcolor,...
            'Position',[figpos(3)-112 168 103 213],...
            'Style','frame',...
            'Tag','frame3');
         
         uicontrol(...
            'Parent',h_dlg,...
            'BackgroundColor',bgcolor,...
            'Position',[10 425 figpos(3)-18 40],...
            'Style','frame',...
            'Tag','frame4');
         
         uicontrol(...
            'Parent',h_dlg, ...
            'Style','text', ...
            'BackgroundColor',bgcolor,...
            'FontSize',10,...
            'FontWeight','bold',...
            'ForegroundColor',[0 0 0.8],...
            'Position',[40 435 140 20],...
            'String','Data Set Column:',...
            'Tag','lblActiveCol');
         
         if isfield(s,'variable')
            colname = [s.variable',repmat({' - '},length(s.name),1),s.name'];
         else
            colname = s.name';
         end
         activecollist = strrep(concatcellcols([colname,repmat({'  ('},length(s.name),1),s.units', ...
            repmat({')'},length(s.name),1)],''),'(none)','(no units)');
         
         h_popActiveCol = uicontrol(...
            'Parent',h_dlg, ...
            'Style','popupmenu', ...
            'FontSize',10, ...
            'Position',[180 437 480 20], ...
            'BackgroundColor',[1 1 1], ...
            'ForegroundColor',[0 0 0], ...
            'String',activecollist, ...
            'Value',col, ...
            'Enable',activecolvis, ...
            'Callback','ui_qccriteria(''newcol'')', ...
            'UserData',0, ...
            'Tag','popActiveCol');
         
         h_lblListFlags = uicontrol(...
            'Parent',h_dlg,...
            'Style','text',...
            'BackgroundColor',bgcolor,...
            'FontSize',10,...
            'FontWeight','bold',...
            'ForegroundColor',[0 0 0.8],...
            'Position',[120 386 400 20],...
            'String','Q/C Flag Criteria Expressions',...
            'Tag','lblListFlags');
         
         h_listFlags = uicontrol(...
            'Parent',h_dlg,...
            'FontSize',10,...
            'Position',[11 168 570 213],...
            'BackgroundColor',[1 1 1],...
            'String','',...
            'Style','listbox',...
            'Value',1,...
            'Callback','ui_qccriteria(''select'')', ...
            'Tag','listFlags');
         
         h_cmdMoveFirst = uicontrol(...
            'Parent',h_dlg,...
            'FontSize',9,...
            'Position',[595 349 88 25],...
            'String','Move First',...
            'Callback','ui_qccriteria(''movefirst'')', ...
            'TooltipString','Move the selected rule to the top of the list (highest precedence)', ...
            'Tag','cmdMoveFirst');
         
         h_cmdMoveUp = uicontrol(...
            'Parent',h_dlg,...
            'FontSize',9,...
            'Position',[595 320 88 25],...
            'String','Move Up',...
            'TooltipString','Move the selected rule up in the list (increase precedence)', ...
            'Callback','ui_qccriteria(''moveup'')', ...
            'Tag','cmdMoveUp');
         
         h_cmdMoveDown = uicontrol(...
            'Parent',h_dlg,...
            'FontSize',9,...
            'Position',[595 291 88 25],...
            'String','Move Down',...
            'TooltipString','Move the selected rule down in the list (reduce precedence)', ...
            'Callback','ui_qccriteria(''movedown'')', ...
            'Tag','cmdMoveDown');
         
         h_cmdMoveLast = uicontrol(...
            'Parent',h_dlg,...
            'FontSize',9,...
            'Position',[595 262 88 25],...
            'String','Move Last',...
            'TooltipString','Move the selected rule to the bottom of the list (lowest precedence)', ...
            'Callback','ui_qccriteria(''movelast'')', ...
            'Tag','cmdMoveLast');
         
         h_cmdAdd = uicontrol(...
            'Parent',h_dlg,...
            'FontSize',9,...
            'Position',[595 233 88 25],...
            'String','Add New',...
            'Callback','ui_qccriteria(''add'')', ...
            'TooltipString','Add a new criterion', ...
            'Tag','cmdAdd');
         
         h_cmdDelete = uicontrol(...
            'Parent',h_dlg,...
            'FontSize',9,...
            'Position',[595 204 88 25],...
            'String','Delete',...
            'Callback','ui_qccriteria(''delete'')', ...
            'TooltipString','Delete the selected criterion', ...
            'Tag','cmdDelete');
         
         h_cmdImport = uicontrol(...
            'Parent',h_dlg,...
            'FontSize',9,...
            'Position',[595 175 88 25],...
            'String','Import',...
            'Callback','ui_qccriteria(''import'')', ...
            'TooltipString','Import criteria from a metadata template variable', ...
            'Tag','cmdImport');
         
         h_lblValueString = uicontrol(...
            'Parent',h_dlg,...
            'Style','text',...
            'BackgroundColor',bgcolor,...
            'ForegroundColor',[0 0 .8], ...
            'FontSize',9,...
            'FontWeight','bold', ...
            'Position',[12 125 58 21],...
            'String','Value',...
            'Tag','lblValueString');
         
         h_popEquality = uicontrol(...
            'Parent',h_dlg,...
            'Style','popupmenu',...
            'FontSize',9,...
            'BackgroundColor',[1 1 1], ...
            'Position',[70 127 68 23],...
            'String','',...
            'Value',1,...
            'Callback','ui_qccriteria(''update'')', ...
            'Tag','popEquality');
         
         h_editFlagVal = uicontrol(...
            'Parent',h_dlg,...
            'Style','edit',...
            'BackgroundColor',[1 1 1],...
            'FontSize',9,...
            'HorizontalAlignment','left',...
            'Position',[145 128 150 22],...
            'String','',...
            'Callback','ui_qccriteria(''update'')', ...
            'Tag','editFlagVal');
         
         uicontrol(...
            'Parent',h_dlg,...
            'BackgroundColor',bgcolor,...
            'FontSize',9,...
            'FontWeight','bold', ...
            'Position',[295 127 25 21],...
            'String','=',...
            'Style','text',...
            'Tag','text6');
         
         h_popFlagDef = uicontrol(...
            'Parent',h_dlg,...
            'FontSize',9,...
            'BackgroundColor',[1 1 1], ...
            'Position',[320 127 300 23],...
            'String',char(flaglist),...
            'Style','popupmenu',...
            'Value',1,...
            'UserData',flaglist, ...
            'Callback','ui_qccriteria(''update'')', ...
            'Tag','popFlagDef');
         
         h_cmdFlagList = uicontrol(...
            'Parent',h_dlg, ...
            'FontSize',9,...
            'Position',[630 127 50 25], ...
            'String','Flags', ...
            'Callback','ui_qccriteria(''flaglist'')', ...
            'TooltipString','Open a dialog to add or edit flag codes and definitions', ...
            'Tag','cmdFlagList');
         
         h_lblDefinition = uicontrol(...
            'Parent',h_dlg,...
            'Style','text',...
            'BackgroundColor',bgcolor,...
            'FontSize',9,...
            'FontWeight','bold', ...
            'ForegroundColor',[0 0 0.8],...
            'Position',[12 90 98 21],...
            'String','Custom Flags:',...
            'Tag','lblDefinition');
         
         h_editCustom = uicontrol(...
            'Parent',h_dlg,...
            'Style','edit',...
            'BackgroundColor',[1 1 1],...
            'FontSize',9,...
            'HorizontalAlignment','left',...
            'Position',[110 93 512 21],...
            'String','',...
            'Callback','ui_qccriteria(''update'')', ...
            'Tag','editCustom');
         
         uicontrol(...
            'Parent',h_dlg, ...
            'Style','pushbutton', ...
            'FontSize',9,...
            'Position',[630 91 50 25], ...
            'String','Help', ...
            'TooltipString','View the QA/QC flag help documentation', ...
            'Callback','ui_viewdocs(''init'',''dataflag'')', ...
            'Tag','cmdHelp');
         
         uicontrol(...
            'Parent',h_dlg, ...
            'Style','pushbutton', ...
            'FontSize',9,...
            'Position',[110 60 160 25], ...
            'String','Add/Edit QC Flag Function', ...
            'TooltipString','Open a dialog to define criteria based on a GCE Toolbox QC flag function', ...
            'Callback','ui_qccriteria(''addfunc'')', ...
            'Tag','cmdFlagHelp');
         
         %set visibility of custom criteria based on data structure status
         if gce_valid(s,'data') == 1
            qryvis = 'on';
         else
            qryvis = 'off';  %incomplete structure - disable
         end
         
         h_cmdQry = uicontrol( ...
            'Parent',h_dlg, ...
            'Style','pushbutton', ...
            'Position',[280 60 160 25], ...
            'FontSize',9,...
            'String','Add/Edit Custom Criteria', ...
            'TooltipString','Open a dialog to define multi-column custom flag criteria', ...
            'Callback','ui_qccriteria(''addquery'')', ...
            'Visible',qryvis, ...
            'Tag','cmdQry');
         
         h_cmdCancel = uicontrol(...
            'Parent',h_dlg,...
            'FontSize',9,...
            'Position',[10 10 90 25],...
            'String','Cancel',...
            'TooltipString','Close the dialog, discarding any changes', ...
            'Callback','ui_qccriteria(''cancel'')', ...
            'Tag','cmdCancel');
         
         h_cmdEval = uicontrol(...
            'Parent',h_dlg,...
            'FontSize',9,...
            'Position',[600 10 90 25],...
            'String','Accept',...
            'TooltipString','Return the modified criteria expression to the Data Editor and close the dialog', ...
            'Callback','ui_qccriteria(''eval'')', ...
            'Tag','cmdEval');
         
         %define structure for caching state data and uicontrol handles
         uih = struct( ...
            's',s, ...
            'h_fig',h_fig, ...
            'h_cb',h_cb, ...
            'cb',cb, ...
            'col',col, ...
            'criteria',[], ...
            'flagcodes',{flagcodes}, ...
            'flagdefs',{flagdefs}, ...
            'popActiveCol',h_popActiveCol, ...
            'listFlags',h_listFlags, ...
            'cmdEval',h_cmdEval, ...
            'cmdCancel',h_cmdCancel, ...
            'popFlagDef',h_popFlagDef, ...
            'cmdQry',h_cmdQry, ...
            'editFlagVal',h_editFlagVal, ...
            'popEquality',h_popEquality, ...
            'editCustom',h_editCustom, ...
            'lblListFlags',h_lblListFlags, ...
            'lblDefinition',h_lblDefinition, ...
            'lblValueString',h_lblValueString, ...
            'cmdFlagList',h_cmdFlagList, ...
            'cmdAdd',h_cmdAdd, ...
            'cmdDelete',h_cmdDelete, ...
            'cmdMoveFirst',h_cmdMoveFirst, ...
            'cmdMoveDown',h_cmdMoveDown, ...
            'cmdMoveUp',h_cmdMoveUp, ...
            'cmdMoveLast',h_cmdMoveLast, ...
            'cmdImport',h_cmdImport);
         
         uih.criteria = s.criteria;  %add q/c criteria array separately to avoid creating multi-dim structure
         
         set(h_dlg,'UserData',uih)  %store cached info in figure userdata
         
         ui_qccriteria('newcol')  %populate qc criteria list, refresh criteria editing fields
         
         set(h_dlg,'Visible','on'); drawnow
         
      end
      
   end
   
else  %handle other callbacks
   
   h_dlg = gcf;
   
   %check for valid dialog before processing callbacks
   if strcmp(get(h_dlg,'Tag'),'dlgQCFlags')
      
      uih = get(h_dlg,'UserData');
      flaglist = get(uih.listFlags,'String');
      Isel = get(uih.listFlags,'Value');
      
      switch op
         
         case 'cancel'  %shut down dialog
            
            delete(h_dlg)
            if ~isempty(uih.h_fig)
               try
                  figure(uih.h_fig)
               catch
               end
               drawnow
            end
            ui_aboutgce('reopen')  %check for last window
            
         case 'eval'  %evaluate and return data
            
            %update criteria for active column, reload uih array
            colnum = get(uih.popActiveCol,'Value');
            ui_qccriteria('update_cache',colnum)
            uih = get(h_dlg,'UserData');
            
            %get original structure, all criteria
            s = uih.s;
            criteria = uih.criteria;
            
            %get cached flag definitions, reformat as comma-delimited list (F = def, ...)
            flagstr = get(uih.popFlagDef,'String');
            if ~isempty(flagstr)
               flagdefs = cell2commas(strrep(cellstr(flagstr),'--','='));
            else
               flagdefs = '';
            end
            
            %check for single-criteria mode (ui_editor), extract single criteria
            if strcmp(get(uih.popActiveCol,'Enable'),'off')
               oldcriteria = s.criteria{colnum};
               criteria = criteria{colnum};  %return criteria string instead of array
               colnum = s.name{colnum};  %return column name instead of number (in case reordered during edit)
            else
               colnum = [];  %clear column selection
               oldcriteria = s.criteria;
            end
            
            %check for changes
            dirtyflag = 0;
            if ~strcmp(uih.flagdefs,flagdefs)
               dirtyflag = 1;
            else
               if ~isempty(colnum)
                  if ~strcmp(criteria,oldcriteria)
                     dirtyflag = 1;
                  end
               else
                  if length(criteria) ~= length(oldcriteria)
                     dirtyflag = 1;
                     disp('different length')
                  else
                     for n = 1:length(criteria)
                        if ~strcmp(criteria{n},s.criteria{n})
                           dirtyflag = 1;
                           break
                        end
                     end
                  end
               end
            end
            
            %shut down dialog
            close(h_dlg)
            drawnow
            
            %get cached return handles, commands
            h_fig = uih.h_fig;
            h_cb = uih.h_cb;
            cb = uih.cb;
            
            %set focus to original figure
            if isempty(h_fig)
               h_fig = parent_figure(h_cb);  %lookup figure handle from callback object handle
            end
            if ~isempty(h_fig)
               figure(h_fig)
               drawnow
            end
            
            %send results to calling dialog window if criteria or flags edited
            if dirtyflag == 1 && ~isempty(cb)
               data = [{criteria},{colnum},{flagdefs}];
               try
                  if ~isempty(h_cb)
                     set(h_cb,'UserData',data) %cache info in callback handle
                  end
                  eval(cb)  %execute callback
               catch
                  messagebox('init','An error occurred returning the updated Q/C criteria to the calling dialog', ...
                     '','Error',[.9 .9 .9]);
               end
            end
            
         case 'update_cache'  %update cached criteria for active column
            
            if exist('s','var') == 1
               
               %get column to update from second argument
               col = s;
               
               %retrieve and format criteria
               crit = get(uih.listFlags,'String');
               if ~isempty(crit)
                  crit = concatcellcols(crit(:)',';');
               else
                  crit = '';
               end
               
               %update cached data
               criteria = uih.criteria;
               criteria(col) = crit;
               uih.criteria = criteria;
               set(h_dlg,'UserData',uih)
               
            end
            
         case 'newcol'  %generate flag list for new column selection
            
            lastcol = get(uih.popActiveCol,'UserData');
            col = get(uih.popActiveCol,'Value');
            
            if col ~= lastcol
               
               %update cached criteria array for last column before switching unless first call (lastcol = 0)
               if lastcol > 0
                  ui_qccriteria('update_cache',lastcol)
               end
               
               %update last column pointer
               set(uih.popActiveCol,'UserData',col)
               
               %look up column data type, set Value/String lable
               dtype = uih.s.datatype{col};
               if strcmp(dtype,'s')
                  set(uih.lblValueString,'String','String')
                  set(uih.popEquality,'String',{'IS','IS NOT','IN','NOT IN'}','Value',1)
               else
                  set(uih.lblValueString,'String','Value')
                  set(uih.popEquality,'String',{'<','<=','==','>','>=','~=','IN','NOT IN'},'Value',1)
               end
               
               %split criteria for new column into array
               crit = splitstr(uih.criteria{col},';');
               
               set(uih.listFlags,'String',crit,'Value',1)
               
               ui_qccriteria('select');
               
            end
            
         case 'select'  %handle list record selections
            
            %check value/string lable for field type
            if strcmp(get(uih.lblValueString,'String'),'String')
               mode = 'string';
            else
               mode = 'value';
            end
            
            %get criteria string for selection
            str = flaglist{Isel};
            
            if ~isempty(str)
               
               %init form field strings
               equalstr = '';
               valstr = '';
               flagstr = '';
               custstr = str;
               refreshlist = 0;
               str = strrep(strrep(strrep(strrep(str,'>=','>>'),'<=','<<'),'~=','~~'),'==','eq');  %protect equal signs in equality expression
               tmp = splitstr(str,'=');  %split criteria expression and flag code
               
               %check for valid criteria
               if length(tmp) == 2
                  
                  str1 = strrep(strrep(strrep(strrep(tmp{1},'>>','>='),'<<','<='),'~~','~='),'eq','==');  %restore equality substitutions
                  str2 = tmp{2};
                  str = strrep(strrep(strrep(strrep(str,'>>','>='),'<<','<='),'~~','~='),'eq','==');  %restore orig string for use as custom string
                  
                  if strcmp(mode,'value')
                     
                     %check for simple conditional format
                     if str1(1) == 'x' && length(str1) > 1
                        
                        if ~isempty(strfind('<>=~',str1(2)))
                           custstr = '';  %clear custom string - parse equality statement instead
                           flagstr = strrep(str2,'''','');
                           if ~isempty(str1)
                              for n = 2:length(str1)
                                 if n <= 3 && ~isempty(strfind('<>=~',str1(n)))
                                    equalstr = [equalstr,str1(n)];
                                 elseif ~isempty(str1(n))
                                    if ~isempty(strfind('+-.0123456789eE',str1(n)))  %check for valid numeric string characters
                                       valstr = [valstr,str1(n)];
                                    else  %non-numeric character - treat as custom flag expression
                                       custstr = str;
                                       break
                                    end
                                 end
                              end
                           end
                        end
                        
                     elseif strncmpi(str1,'flag_inarray(',13)
                        
                        %check for tolerance option - use custom func
                        if isempty(strfind(str,'],'))
                           
                           Istart = regexp(str1,'flag_inarray\(x,\[.+\]\)');
                           
                           if ~isempty(Istart)
                              custstr = '';  %clear custom string - parse equality statement instead
                              flagstr = strrep(str2,'''','');
                              equalstr = 'IN';
                              valstr = str1(17:length(str1)-2);
                           else
                              custstr = str;
                           end
                           
                        else
                           custstr = str;
                        end
                        
                     elseif strncmpi(str1,'flag_notinarray(',16)
                        
                        %check for tolerance option - use custom func
                        if isempty(strfind(str,'],'))
                           
                           Istart = regexp(str1,'flag_notinarray\(x,\[.+\]\)');
                           
                           if ~isempty(Istart)
                              custstr = '';  %clear custom string - parse equality statement instead
                              flagstr = strrep(str2,'''','');
                              equalstr = 'NOT IN';
                              valstr = str1(20:length(str1)-2);
                           else
                              custstr = str;
                           end
                           
                        else
                           custstr = str;
                        end
                        
                     end
                     
                  else  %string criteria
                     
                     %check for supported criteria syntax for IS, IS NOT, IN, NOT IN string q/c rules
                     if strncmpi(str1,'strcmp(x,',9)
                        
                        [Istart,Iend] = regexp(str1,'strcmp\(x,''.+''\)');
                        
                        if ~isempty(Istart)
                           custstr = '';  %clear custom string - parse equality statement instead
                           flagstr = strrep(str2,'''','');
                           equalstr = 'IS';
                           valstr = str1(Istart+10:Iend-2);
                        else
                           custstr = str;
                        end
                        
                     elseif strncmpi(str1,'~strcmp(x,',10)
                        
                        [Istart,Iend] = regexp(str1,'~strcmp\(x,''.+''\)');
                        
                        if ~isempty(Istart)
                           custstr = '';  %clear custom string - parse equality statement instead
                           flagstr = strrep(str2,'''','');
                           equalstr = 'IS NOT';
                           valstr = str1(Istart+11:Iend-2);
                        else
                           custstr = str;
                        end
                        
                     elseif strncmpi(str1,'flag_inlist(x,',14)
                        
                        %check for case sensitivity option - use custom func
                        if isempty(strfind(str1,'sensitive'')'))
                           
                           %check for old cell array syntax - convert and set flag for refreshing list
                           if ~isempty(strfind(str1,'{'))
                              refreshlist = 1;
                              str1 = strrep(strrep(strrep(str1,''',''',','),'{',''),'}','');
                           end
                           
                           [Istart,Iend] = regexp(str1,'flag_inlist\(x,''.+''\)');
                           
                           if ~isempty(Istart)
                              custstr = '';  %clear custom string - parse equality statement instead
                              flagstr = strrep(str2,'''','');
                              equalstr = 'IN';
                              valstr = strrep(str1(Istart+15:Iend-2),'''','');
                           else
                              custstr = str;
                           end
                           
                        else
                           custstr = str;
                        end
                        
                     elseif strncmpi(str1,'flag_notinlist(x,',17)
                        
                        %check for case sensitivity option - use custom func
                        if isempty(strfind(str1,'sensitive'')'))
                           
                           %check for old cell array syntax - convert and setflag for refreshing list
                           if ~isempty(strfind(str1,'{'))
                              refreshlist = 1;
                              str1 = strrep(strrep(strrep(str1,''',''',','),'{',''),'}','');
                           end
                           
                           [Istart,Iend] = regexp(str1,'flag_notinlist\(x,''.+''\)');
                           
                           if ~isempty(Istart)
                              custstr = '';  %clear custom string - parse equality statement instead
                              flagstr = strrep(str2,'''','');
                              equalstr = 'NOT IN';
                              valstr = strrep(str1(Istart+18:Iend-2),'''','');
                           else
                              custstr = str;
                           end
                           
                        else  %unmatched pattern - use custom flag field
                           custstr = str;
                        end
                        
                     else
                        custstr = str;
                     end
                     
                  end
                  
               end
               
               %check for custom criteria string (not cleared in the presence of simple conditional)
               if ~isempty(custstr)
                  
                  %populate custom criteria field, disable conditional fields
                  set(uih.editCustom,'String',str,'Enable','on','BackgroundColor',[1 1 1])
                  set(uih.popEquality,'Value',1,'Enable','off')
                  set(uih.editFlagVal,'String','','Enable','off')
                  set(uih.popFlagDef,'Value',1,'Enable','off')
                  
               else
                  
                  %populate conditional fields, disable custom criteria field
                  flagval = find(strcmp(uih.flagcodes,flagstr));
                  equalval = find(strcmp(get(uih.popEquality,'String'),equalstr));
                  
                  if ~isempty(flagval)
                     set(uih.popFlagDef,'Value',flagval(1),'Enable','on')
                  else
                     tmp = splitstr(str,'=');
                     if length(tmp) == 2
                        newcode = strrep(tmp{2},'''','');
                        newcode = newcode(1);
                     else
                        newcode = '?';
                     end
                     flagval = length(uih.flagcodes) + 1;
                     flaglist = [get(uih.popFlagDef,'UserData') ; {[newcode,' -- unspecified']}];
                     uih.flagcodes = [uih.flagcodes ; {newcode}];
                     set(h_dlg,'UserData',uih)
                     set(uih.popFlagDef,'String',char(flaglist),'Value',flagval,'UserData',flaglist,'Enable','on')
                  end
                  
                  if ~isempty(equalval)
                     set(uih.popEquality,'Value',equalval,'Enable','on')
                  else
                     set(uih.popEquality,'Value',1,'Enable','on')
                  end
                  
                  %toggle field states
                  set(uih.editFlagVal,'String',valstr,'Enable','on')
                  set(uih.editCustom,'String','','Enable','off','BackgroundColor',[.8 .8 .8])
                  
                  %check for list refresh flag
                  if refreshlist == 1
                     ui_qccriteria('update');
                  end
                  
               end
               
            else
               set(uih.editFlagVal,'String','','Enable','on')
               set(uih.editCustom,'String','','Enable','on','BackgroundColor',[1 1 1])
            end
            
         case 'flaglist'  %open flag code editor dialog
            
            flagdefs = cell2commas(strrep(cellstr(get(uih.popFlagDef,'String')),'--','='));
            
            flagmeta = [{'Data'},{'Codes'},{flagdefs}];  %format flag codes as metadata field for dialog
            ui_flagdefs('init',flagmeta,uih.cmdFlagList,'ui_qccriteria(''flaglist2'')')
            
         case 'flaglist2'  %handle return data from flag code editor dialog
            
            %get cached return data
            data = get(uih.cmdFlagList,'UserData');
            
            if ~isempty(data)
               
               %parse and format return data
               flaglist = data{1};
               
               if ~isempty(flaglist)
                  flaglist0 = splitstr(flaglist,',');
                  flaglist = [];
                  flagcodes = [];
                  for n = 1:length(flaglist0)
                     tmp = splitstr(flaglist0{n},'=');
                     if length(tmp) == 2
                        flaglist = [flaglist ; {[tmp{1},' -- ',tmp{2}]}];
                        flagcodes = [flagcodes ; tmp(1)];
                     end
                  end
               else
                  flaglist = {' '};
                  flagcodes = {''};
               end
               
               %look up prior selected code in revised code list for resetting popup menu
               oldlist = get(uih.popFlagDef,'UserData');
               oldval = get(uih.popFlagDef,'Value');
               
               if ~isempty(oldlist)
                  newval = find(strcmp(flaglist,oldlist{oldval}));
                  if isempty(newval)
                     newval = 1;
                  else
                     newval = newval(1);
                  end
               else
                  newval = 1;
               end
               
               %cache new data, update uicontrols
               uih.flagcodes = flagcodes;
               set(uih.popFlagDef,'String',char(flaglist),'Value',newval,'UserData',cellstr(flaglist))
               set(h_dlg,'UserData',uih)
               
               %refresh uicontrol selection
               ui_qccriteria('select')
               
            end
            
         case 'update' %apply edits and update uicontrol values
            
            %get field contents
            strFlagval = deblank(get(uih.editFlagVal,'String'));
            strCustom = deblank(get(uih.editCustom,'String'));
            
            if ~isempty(strFlagval)
               eq = get(uih.popEquality,'Value');
               eqdata = get(uih.popEquality,'String');
               flag = uih.flagcodes{get(uih.popFlagDef,'Value')};
               mode = get(uih.lblValueString,'String');
               if strcmp(mode,'Value')
                  switch eqdata{eq}
                     case 'IN'
                        flagstr = ['flag_inarray(x,[',strFlagval,'])=''',flag,''''];
                     case 'NOT IN'
                        flagstr = ['flag_notinarray(x,[',strFlagval,'])=''',flag,''''];
                     otherwise
                        if ~isempty(str2double(strFlagval))
                           flagstr = ['x',eqdata{eq},strFlagval,'=''',flag,''''];
                        else
                           messagebox('init','Flag comparison value must be a valid number',[],'Error',[.9 .9 .9])
                        end
                  end
               else
                  switch eqdata{eq}
                     case 'IS NOT'
                        flagstr = ['~strcmp(x,''',strFlagval,''')=''',flag,''''];
                     case 'IN'
                        flagstr = ['flag_inlist(x,''',strFlagval,''')=''',flag,''''];
                     case 'NOT IN'
                        flagstr = ['flag_notinlist(x,''',strFlagval,''')=''',flag,''''];
                     otherwise  %IS
                        flagstr = ['strcmp(x,''',strFlagval,''')=''',flag,''''];
                  end
               end
               flaglist{Isel} = flagstr;
               set(uih.listFlags,'String',flaglist)
            elseif ~isempty(strCustom)
               flaglist{Isel} = strCustom;
               set(uih.listFlags,'String',flaglist)
            end
            
            ui_qccriteria('select')
            
         case 'addfunc'  %add custom function defined using the 'ui_flagfunction' dialog
            
            strCustom = deblank(get(uih.editCustom,'String'));
            
            ui_flagfunction('init',strCustom,Isel);
            
         case 'addfunc2'  %process custom function return data
            
            %get custom function syntax from second argument
            if exist('s','var') == 1
               fnc = s;
            else
               fnc = '';
            end
            
            %get position from third argument
            if exist('col','var') == 1
               pos = col;
            else
               pos = 0;
            end
            
            if ~isempty(fnc)
               if Isel ~= pos || strcmp(get(uih.editCustom,'Enable'),'off')
                  ui_qccriteria('add')  %add new entry if selection changed by user or field not enabled
               end
               set(uih.editCustom,'String',fnc)
               ui_qccriteria('update')
            end
            
         case 'addquery'  %add query statement using the 'ui_querybuilder' dialog
            
            %get custom criteria string
            strCustom = deblank(get(uih.editCustom,'String'));
            
            %remove column name prefixes and flag assignment from expression
            if ~isempty(strCustom)
               strQry = strrep(strCustom,'col_','');  %strip column name prefixes
               strQry = regexprep(strQry,'=''\S{1}''','');  %strip off flag assignment
            else
               strQry = '';
            end
            
            %cache column position
            set(uih.editCustom,'UserData',Isel)
            
            %call ui_querybuilder
            ui_querybuilder('init',uih.s,uih.cmdQry,'ui_qccriteria(''addquery2'')',strQry)
            
         case 'addquery2'  %process query statement return data
            
            %get cached query and clear
            strQry = get(uih.cmdQry,'UserData');
            set(uih.cmdQry,'UserData','')
            
            %get cached column position and clear
            pos = get(uih.editCustom,'UserData');
            set(uih.editCustom,'UserData',[])
            
            if ~isempty(strQry)
               
               %add column placeholders to column names
               colnames = uih.s.name;
               len = cellfun('length',colnames);
               [len,Isort] = sort(len);
               colnames = colnames(Isort(end:-1:1));  %sort column names in reverse length order
               for n = 1:length(colnames)
                  strQry = strrep(strQry,colnames{n},['col_',colnames{n}]);
               end
               
               %get position from third argument
               if isempty(pos) || ~isnumeric(pos)
                  pos = Isel;
               elseif pos > length(get(uih.listFlags,'String'))
                  pos = 0;
               end
               
               %get custom criteria string
               strCustom = deblank(get(uih.editCustom,'String'));
               
               %parse flag assignment from custom criteria string
               strFlag = '';
               if ~isempty(strCustom)
                  [Istart,Iend] = regexp(strCustom,'=''\S{1}''');
                  if ~isempty(Istart)
                     strFlag = strCustom(Istart:Iend);
                  end
               end
               
               %validate flag and generate default if empty
               if isempty(strFlag) || isempty(strfind(strFlag,'='))
                  flagcodes = uih.flagcodes;
                  if ~isempty(flagcodes)
                     strFlag =  ['=''',uih.flagcodes{1},''''];
                  else
                     strFlag = '=''?''';
                  end
               end
               
               %add new criteria entry if selection changed by user or field not enabled
               if Isel ~= pos || strcmp(get(uih.editCustom,'Enable'),'off')
                  ui_qccriteria('add')
               end
               
               %update custom criteria
               set(uih.editCustom,'String',[strQry,strFlag])
               ui_qccriteria('update')
               
            end
            
         case 'add'  %add new criteria
            
            flaglist = [flaglist ; {''}];
            set(uih.listFlags,'String',flaglist,'Value',length(flaglist))
            set(uih.editCustom,'String','','Enable','on','BackgroundColor',[1 1 1])
            set(uih.popEquality,'Value',1,'Enable','on')
            set(uih.editFlagVal,'String','','Enable','on')
            set(uih.popFlagDef,'Value',1,'Enable','on')
            
         case 'delete'  %delete selected criteria
            
            if length(flaglist) > 1
               Iall = (1:length(flaglist))';
               Ilist = Iall(Iall~=Isel);
               set(uih.listFlags,'String',flaglist(Ilist),'Value',max(1,Isel-1))
            else
               set(uih.listFlags,'String',{''},'Value',1)
               set(uih.editCustom,'String','','Enable','on','BackgroundColor',[1 1 1])
               set(uih.popEquality,'Value',1,'Enable','on')
               set(uih.editFlagVal,'String','','Enable','on')
               set(uih.popFlagDef,'Value',1,'Enable','on')
            end
            
            ui_qccriteria('select')
            
         case 'movefirst'  %move selected criteria to first position
            
            if Isel > 1 && length(flaglist) > 1
               Iall = (1:length(flaglist))';
               Ilist = [Isel;Iall(Iall~=Isel)];
               flaglist = flaglist(Ilist);
               set(uih.listFlags,'String',flaglist,'Value',1)
            end
            
         case 'movedown'  %move selected criteria down in the list
            
            if Isel < length(flaglist) && length(flaglist) > 1
               Iall = (1:length(flaglist))';
               Ilist = [Iall(Iall<Isel) ; Isel+1 ; Isel ; Iall(Iall>Isel+1)];
               flaglist = flaglist(Ilist);
               set(uih.listFlags,'String',flaglist,'Value',Isel+1)
            end
            
         case 'moveup'  %move selected criteria up in the list
            
            if Isel > 1 && length(flaglist) > 1
               Iall = (1:length(flaglist))';
               Ilist = [Iall(Iall<Isel-1) ; Isel ; Isel-1 ; Iall(Iall>Isel)];
               flaglist = flaglist(Ilist);
               set(uih.listFlags,'String',flaglist,'Value',Isel-1)
            end
            
         case 'movelast'  %move selected criteria to bottom of the list
            
            if Isel < length(flaglist) && length(flaglist) > 1
               Iall = (1:length(flaglist))';
               Ilist = [Iall(Iall~=Isel);Isel];
               flaglist = flaglist(Ilist);
               set(uih.listFlags,'String',flaglist,'Value',length(flaglist))
            end
            
         case 'import'  %import rules from a template variables
            
            ar = parse_template_qcrules;
            
            if ~isempty(ar)
               
               %look up records matching the active column name
               currentcol = uih.s.name{get(uih.popActiveCol,'Value')};
               Icurrent = find(strncmpi(currentcol,ar,length(currentcol)));               
               if ~isempty(Icurrent)
                  Icurrent = Icurrent(1);
               else
                  Icurrent = 1;
               end
               
               %prompt for a rule set
               Isel = listdialog('liststring',ar, ...
                  'name','Q/C Rule Selection', ...
                  'promptstring','Select a Q/C ruleset to import', ...
                  'selectionmode','single', ...
                  'initialvalue',Icurrent, ...
                  'listsize',[0 0 600 500]);
               
               if ~isempty(Isel)
                  
                  %parse rules from list
                  str = ar{Isel};
                  [~,str] = strtok(str,':');
                  newrules = splitstr(str(3:end),';',1,1);
                  
                  %display dialog for choosing which rules to import
                  Isel = listdialog('liststring',newrules, ...
                     'name','Q/C Rule Import', ...
                     'promptstring','Select individual rules to import', ...
                     'selectionmode','multiple', ...
                     'initialvalie',[], ...
                     'listsize',[0 0 400 400]);
                  
                  if ~isempty(Isel)
                     
                     %filter newrules based on selection
                     newrules = newrules(Isel);
                     
                     %get existing rules
                     oldrules = get(uih.listFlags,'String');
                     
                     %merge rules
                     if ~isempty(oldrules) && sum(~cellfun('isempty',oldrules)) > 0
                        rules = [oldrules ; newrules];
                        pos = length(oldrules) + 1;
                     else
                        rules = newrules;
                        pos = 1;
                     end
                     
                     %update controls
                     set(uih.listFlags,'String',rules,'Value',pos)
                     ui_qccriteria('select')
                     
                  end
                  
               end
               
            else
               messagebox('init','Could not retrieve metadata template criteria','','Error',[0.9 0.9 0.9],0)
            end
            
      end
      
   end
   
end