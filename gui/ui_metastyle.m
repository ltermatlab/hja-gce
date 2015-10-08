function ui_metastyle(op,data)
%GUI dialog for editing metadata styles used by the GCE Data Toolbox
%
%syntax: ui_metastyle(op,data)
%
%inputs:
%  op = operation (e.g. 'init')
%  data = optional data argument used by callbacks
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
%last modified: 20-Nov-2014

if nargin == 0
   op = 'init';
end

if strcmp(op,'init')
   
   if length(findobj) > 1
      h_dlg = findobj('tag','dlgEditMetaStyles');
   else
      h_dlg = [];
   end
   
   if ~isempty(h_dlg)
      
      figure(h_dlg)
      drawnow
      
   else  %load styles and generate dialog
      
      fh = which('metastyles.mat');
      
      styles = [];
      
      if ~isempty(fh)  %load existing styles
         
         f = load(fh);
         if isfield(f,'styles')
            styles = f.styles;
         end
         
      else  %create demo styles
         
         styles = struct( ...
            'name','New Style', ...
            'label',[], ...
            'level',[], ...
            'metafields',[], ...
            'evalstr',[], ...
            'indent',0, ...
            'wrapcolumn',0, ...
            'newlinechar','', ...
            'columnprefix','', ...
            'nowrap',[], ...
            'description','New Style');
         
         styles(1).label = repmat({''},10,1);
         styles(1).level = zeros(10,1);
         styles(1).evalstr = repmat({''},10,1);
         styles(1).nowrap = zeros(10,1);
         
      end
      
      if ~isempty(styles)
         
         res = get(0,'ScreenSize');
         
         h_dlg = figure('Visible','off', ...
            'Name','Template Editor', ...
            'Position',[(res(3)-346)./2 (res(4)-430)./2 346 430], ...
            'ButtonDownFcn','figure(gcf)', ...
            'Color',[0.95 0.95 0.95], ...
            'MenuBar','none', ...
            'NumberTitle','off', ...
            'Tag','dlgEditMetaStyles', ...
            'ToolBar','none', ...
            'DefaultuicontrolUnits','pixels');
         
         if mlversion >= 7
            set(h_dlg,'WindowStyle','normal')
            set(h_dlg,'DockControls','off')
         end
         
         uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[0.95 0.95 0.95], ...
            'ForegroundColor',[0.6 0.6 0.6], ...
            'Position',[6 47 336 378], ...
            'Style','frame', ...
            'Tag','frame');
         
         uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[0.95 0.95 0.95], ...
            'FontSize',10, ...
            'FontWeight','bold', ...
            'ForegroundColor',[0 0 0.8], ...
            'Position',[12 398 242 22], ...
            'String','Metadata Styles', ...
            'Style','text', ...
            'Tag','txtLabel');
         
         h_listStyles = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'Callback','ui_metastyle(''refresh'')', ...
            'FontSize',9, ...
            'Position',[12 289 264 109], ...
            'String',{styles.name}', ...
            'Style','listbox', ...
            'Tag','listStyles', ...
            'Value',1);
         
         uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[0.95 0.95 0.95], ...
            'FontSize',9, ...
            'FontWeight','bold', ...
            'ForegroundColor',[0 0 0.8], ...
            'Position',[10 248 100 22], ...
            'String','Style Name', ...
            'Style','text', ...
            'Tag','txtName');
         
         uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[0.95 0.95 0.95], ...
            'FontSize',9, ...
            'FontWeight','bold', ...
            'ForegroundColor',[0 0 0.8], ...
            'Position',[10 218 100 22], ...
            'String','Description', ...
            'Style','text', ...
            'Tag','txtDesc');
         
         uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[0.95 0.95 0.95], ...
            'FontSize',9, ...
            'FontWeight','bold', ...
            'ForegroundColor',[0 0 0.8], ...
            'Position',[10 188 100 22], ...
            'String','Wrap Column', ...
            'Style','text', ...
            'Tag','txtWrap');
         
         uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[0.95 0.95 0.95], ...
            'FontSize',9, ...
            'FontWeight','bold', ...
            'ForegroundColor',[0 0 0.8], ...
            'Position',[205 188 100 22], ...
            'String','(characters)', ...
            'Style','text', ...
            'HorizontalAlignment','left', ...
            'Tag','txtWrap2');
         
         uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[0.95 0.95 0.95], ...
            'FontSize',9, ...
            'FontWeight','bold', ...
            'ForegroundColor',[0 0 0.8], ...
            'Position',[10 158 100 22], ...
            'String','Wrap Indent', ...
            'Style','text', ...
            'Tag','txtIdent');
         
         uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[0.95 0.95 0.95], ...
            'FontSize',9, ...
            'FontWeight','bold', ...
            'ForegroundColor',[0 0 0.8], ...
            'Position',[205 158 100 22], ...
            'String','(characters)', ...
            'HorizontalAlignment','left', ...
            'Style','text', ...
            'Tag','txtIdent2');
         
         uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[0.95 0.95 0.95], ...
            'FontSize',9, ...
            'FontWeight','bold', ...
            'ForegroundColor',[0 0 0.8], ...
            'Position',[10 128 100 22], ...
            'String','Column Prefix', ...
            'Style','text', ...
            'Tag','txtPrefix');
         
         uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[0.95 0.95 0.95], ...
            'FontSize',9, ...
            'FontWeight','bold', ...
            'ForegroundColor',[0 0 0.8], ...
            'Position',[10 98 100 22], ...
            'String','Newline Char.', ...
            'Style','text', ...
            'Tag','txtNewline');
         
         h_editName = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'FontSize',9, ...
            'HorizontalAlignment','left', ...
            'Position',[110 251 220 22], ...
            'String',styles(1).name, ...
            'Style','edit', ...
            'Callback','ui_metastyle(''name'')', ...
            'Tag','editName');
         
         h_editDesc = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'FontSize',9, ...
            'HorizontalAlignment','left', ...
            'Position',[110 221 220 22], ...
            'String',styles(1).description, ...
            'Style','edit', ...
            'Callback','ui_metastyle(''fields'')', ...
            'Tag','editDesc');
         
         h_editWrap = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'FontSize',9, ...
            'HorizontalAlignment','left', ...
            'Position',[110 191 90 22], ...
            'String',int2str(styles(1).wrapcolumn), ...
            'Style','edit', ...
            'Callback','ui_metastyle(''fields'')', ...
            'Tag','editWrap');
         
         h_editIndent = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'FontSize',9, ...
            'HorizontalAlignment','left', ...
            'Position',[110 161 90 22], ...
            'String',int2str(styles(1).indent), ...
            'Style','edit', ...
            'Callback','ui_metastyle(''fields'')', ...
            'Tag','editIndent');
         
         h_editPrefix = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'FontSize',9, ...
            'HorizontalAlignment','left', ...
            'Position',[110 131 220 22], ...
            'String',styles(1).columnprefix, ...
            'Style','edit', ...
            'Callback','ui_metastyle(''fields'')', ...
            'Tag','editPrefix');
         
         h_editNewline = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'FontSize',9, ...
            'HorizontalAlignment','left', ...
            'Position',[110 101 220 22], ...
            'String',styles(1).newlinechar, ...
            'Style','edit', ...
            'Callback','ui_metastyle(''fields'')', ...
            'Tag','editNewline');
         
         h_cmdEditStyle = uicontrol('Parent',h_dlg, ...
            'Callback','ui_metastyle(''editdesc'')', ...
            'FontSize',9, ...
            'Position',[22 58 135 25], ...
            'String','Edit Style Definition', ...
            'Tag','cmdEditStyle', ...
            'TooltipString','View and edit style elements in a spreadsheet-style grid');
         
         h_cmdEditMeta = uicontrol('Parent',h_dlg, ...
            'Callback','ui_metastyle(''editmeta'')', ...
            'FontSize',9, ...
            'Position',[187 58 135 25], ...
            'String','View Metadata Fields', ...
            'Tag','cmdEditMeta', ...
            'TooltipString','View metadata field list referenced in the style (edits will be ignored)');
         
         h_cmdCopy = uicontrol('Parent',h_dlg, ...
            'Callback','ui_metastyle(''copy'')', ...
            'FontSize',9, ...
            'Position',[282 374 50 25], ...
            'String','Copy', ...
            'Tag','cmdCopy', ...
            'TooltipString','Copy the selected style');
         
         h_cmdAdd = uicontrol('Parent',h_dlg, ...
            'Callback','ui_metastyle(''add'')', ...
            'FontSize',9, ...
            'Position',[282 346 50 25], ...
            'String','Add', ...
            'Tag','cmdAdd', ...
            'TooltipString','Add a blank style for editing');
         
         h_cmdDelete = uicontrol('Parent',h_dlg, ...
            'Callback','ui_metastyle(''delete'')', ...
            'FontSize',9, ...
            'Position',[282 318 50 25], ...
            'String','Delete', ...
            'Tag','cmdDelete', ...
            'TooltipString','Delete the selected style');
         
         h_cmdSort = uicontrol('Parent',h_dlg, ...
            'Callback','ui_metastyle(''sort'')', ...
            'FontSize',9, ...
            'Position',[282 290 50 25], ...
            'String','Sort', ...
            'Tag','cmdSort', ...
            'TooltipString','Sort list of styles by name');
         
         h_cmdClose = uicontrol('Parent',h_dlg, ...
            'Callback','ui_metastyle(''close'')', ...
            'FontSize',9, ...
            'Position',[8 8 80 25], ...
            'String','Cancel', ...
            'Tag','cmdClose', ...
            'TooltipString','Cancel editing and close the dialog');
         
         h_cmdAccept = uicontrol('Parent',h_dlg, ...
            'Callback','ui_metastyle(''eval'')', ...
            'FontSize',9, ...
            'Position',[262 8 80 25], ...
            'String','Accept', ...
            'Tag','cmdAccept', ...
            'TooltipString','Accept changes and close dialog');
         
         uih = struct('listStyles',h_listStyles, ...
            'cmdCopy',h_cmdCopy, ...
            'cmdAdd',h_cmdAdd, ...
            'cmdDelete',h_cmdDelete, ...
            'cmdSort',h_cmdSort, ...
            'editName',h_editName, ...
            'editDesc',h_editDesc, ...
            'editIndent',h_editIndent, ...
            'editWrap',h_editWrap, ...
            'editNewline',h_editNewline, ...
            'editPrefix',h_editPrefix, ...
            'cmdEditStyle',h_cmdEditStyle, ...
            'cmdEditMeta',h_cmdEditMeta, ...
            'cmdClose',h_cmdClose, ...
            'cmdAccept',h_cmdAccept, ...
            'styles',styles);
         
         set(h_dlg,'UserData',uih,'Visible','on')
         drawnow
         
      end
      
   end
   
else
   
   if length(findobj) > 1
      h_dlg = findobj('tag','dlgEditMetaStyles');
   else
      h_dlg = [];
   end
   
   if ~isempty(h_dlg)
      
      uih = get(h_dlg,'UserData');
      Isel = get(uih.listStyles,'value');
      styles = uih.styles;
      
      switch op
         
         case 'close'
            
            close(h_dlg)
            drawnow
            ui_aboutgce('reopen')  %check for last window
            
         case 'add'
            
            newstyle = struct( ...
               'name','New Style', ...
               'label',[], ...
               'level',[], ...
               'metafields',[], ...
               'evalstr',[], ...
               'indent',0, ...
               'wrapcolumn',0, ...
               'newlinechar','', ...
               'columnprefix','', ...
               'nowrap',[], ...
               'description','New Style');
            
            newstyle(1).label = repmat({''},10,1);
            newstyle(1).level = zeros(10,1);
            newstyle(1).evalstr = repmat({''},10,1);
            newstyle(1).nowrap = zeros(10,1);
            
            styles(length(styles)+1) = newstyle;
            
            uih.styles = styles;
            set(h_dlg,'UserData',uih)
            set(uih.listStyles, ...
               'String',{styles.name}', ...
               'Value',length(styles))
            set(uih.editName,'String','New Style')
            
            ui_metastyle('refresh')
            
         case 'copy'
            
            styles(end+1) = styles(Isel);
            styles(end).name = [styles(Isel).name,'_copy'];
            
            uih.styles = styles;
            set(uih.listStyles, ...
               'String',{styles.name}', ...
               'Value',length(styles))
            set(h_dlg,'UserData',uih)
            
            ui_metastyle('refresh')
            
         case 'delete'
            
            I = (1:length(styles)) ~= Isel;
            
            styles = styles(I);
            uih.styles = styles;
            newval = min(Isel,length(styles));
            
            set(uih.listStyles, ...
               'String',{styles.name}', ...
               'Value',newval);
            set(h_dlg,'UserData',uih)
            
            ui_metastyle('refresh')
            
         case 'sort'
            
            templist = get(uih.listStyles,'String');
            Isel = get(uih.listStyles,'Value');
            [~,Isort] = sort(lower(templist));
            Iselnew = find(Isort==Isel);
            
            uih.styles = uih.styles(Isort);
            
            set(uih.listStyles,'String',templist(Isort),'Value',Iselnew,'ListboxTop',1)
            set(h_dlg,'UserData',uih)
            
            drawnow
            
         case 'fields'
            
            styles = uih.styles;
            msg = '';
            tag = get(gcbo,'Tag');
            
            switch tag
               case 'editDesc'
                  str = deblank(get(uih.editDesc,'String'));
                  if ~isempty(str)
                     styles(Isel).description = str;
                  else
                     set(uih.editDesc,'String',styles(Isel).description)
                     msg = 'Style descriptions cannot be blank';
                  end
                  set(uih.editDesc,'String',styles(Isel).description)
               case 'editIndent'
                  str = deblank(get(uih.editIndent,'String'));
                  if ~isempty(str)
                     indent = str2double(str);
                     if ~isempty(indent)
                        indent = abs(fix(indent));
                        styles(Isel).indent = indent;
                        set(uih.editIndent,'String',int2str(indent))
                     else
                        msg = 'Indent must be a valid integer';
                     end
                  else
                     msg = 'Indent must be a valid integer';
                  end
                  if ~isempty(msg)
                     set(uih.editIndent,'String',int2str(styles(Isel).indent))
                  end
               case 'editWrap'
                  str = deblank(get(uih.editWrap,'String'));
                  if ~isempty(str)
                     wrap = str2double(str);
                     if ~isempty(wrap)
                        wrap = abs(fix(wrap));
                        styles(Isel).wrapcolumn = wrap;
                        set(uih.editWrap,'String',int2str(wrap))
                     else
                        msg = 'Wrap column must be a valid integer';
                     end
                  else
                     msg = 'Wrap column must be a valid integer';
                  end
                  if ~isempty(msg)
                     set(uih.editWrap,'String',int2str(styles(Isel).wrapcolumn))
                  end
               case 'editNewline'
                  str = get(uih.editNewline,'String');
                  styles(Isel).newlinechar = str;
               case 'editPrefix'
                  str = get(uih.editPrefix,'String');
                  styles(Isel).columnprefix = str;
            end
            
            uih.styles = styles;
            set(h_dlg,'UserData',uih)
            
            drawnow
            
            if ~isempty(msg)
               messagebox('init',msg,[],'Warning',[.9 .9 .9]);
            end
            
         case 'name'
            
            str = deblank(get(uih.editName,'String'));
            
            if ~isempty(str)
               styles(Isel).name = str;
               uih.styles = styles;
               set(uih.editName,'String',str)
               set(h_dlg,'UserData',uih)
               set(uih.listStyles,'String',{styles.name}')
               drawnow
            else
               messagebox('init','Template names cannot be blank',[],'Error',[.9 .9 .9])
            end
            
         case 'refresh'
            
            styles = uih.styles;
            if strcmp(styles(Isel).name,'xml')
               vis = 'off';
            else
               vis = 'on';
            end
            
            set(uih.editName,'String',styles(Isel).name,'Enable',vis)
            set(uih.editDesc,'String',styles(Isel).description,'Enable',vis)
            set(uih.editIndent,'String',int2str(styles(Isel).indent),'Enable',vis)
            set(uih.editWrap,'String',int2str(styles(Isel).wrapcolumn),'Enable',vis)
            set(uih.editNewline,'String',styles(Isel).newlinechar,'Enable',vis)
            set(uih.editPrefix,'String',styles(Isel).columnprefix,'Enable',vis)
            set(uih.cmdEditStyle,'Enable',vis)
            set(uih.cmdEditMeta,'Enable',vis)
            set(uih.cmdDelete,'Enable',vis)
            set(uih.cmdCopy,'Enable',vis)
            
         case 'editdesc'
            
            if strcmp(styles(Isel).name,'xml') ~= 1
               
               s = newstruct('data');
               s.title = styles(Isel).name;
               s.datafile = [{'none'},{0}];
               
               s.name = [{'IndentLevel'},{'Label'},{'Expression'},{'NoWrap'}];
               s.units = [{'# of leading indents'},{'static text'},{'text & metadata fields'},{'0=wrap,1=nowrap'}];
               s.description = repmat({''},1,4);
               s.datatype = [{'d'},{'s'},{'s'},{'d'}];
               s.numbertype = [{'discrete'},{'none'},{'none'},{'discrete'}];
               s.variabletype = repmat({'nominal'},1,4);
               s.precision = zeros(1,4);
               s.criteria = repmat({''},1,4);
               s.flags = s.criteria;
               s.values = [{styles(Isel).level},{styles(Isel).label},{styles(Isel).evalstr},{styles(Isel).nowrap}];
               
               if gce_valid(s,'data')
                  
                  ui_datagrid('init',s,uih.cmdEditStyle,'ui_metastyle(''editdesc2'',s);', ...
                     200,'left');
                  
               else
                  
                  messagebox('init','The selected style definition is invalid and cannot be edited',[],'Error',[.9 .9 .9]);
                  
               end
               
            else
               
               messagebox('init','Sorry ... the ''xml'' style cannot be edited in this dialog',[],'Error',[.9 .9 .9]);
               
            end
            
         case 'editdesc2'
            
            I = find(strcmp({styles.name},data.title));
            if isempty(I)
               I = find(strcmpi({styles.name},data.title));
            end
            
            if ~isempty(I)
               
               I = I(1);
               
               styles(I).level = extract(data,'IndentLevel');
               styles(I).label = extract(data,'Label');
               styles(I).evalstr = extract(data,'Expression');
               styles(I).nowrap = extract(data,'NoWrap');
               
               %rebuild metadata fields list
               evalstr = styles(Isel).evalstr;
               valchars = [48:57,65:90,97:122];
               flds = [];
               for n = 1:length(evalstr)
                  str = evalstr{n};
                  len = length(str);
                  if len > 1
                     Ius = strfind(str,'_');
                     if ~isempty(Ius);
                        for m = 1:length(Ius)
                           Istart = Ius(m)-1;
                           Iend = Ius(m)+1;
                           while Istart > 0
                              c = str(Istart);
                              if sum(double(c)==valchars) > 0
                                 Istart = Istart - 1;
                              else
                                 break
                              end
                           end
                           Istart = Istart + 1;
                           while Iend <= len
                              c = str(Iend);
                              if sum(double(c)==valchars) > 0
                                 Iend = Iend + 1;
                              else
                                 break
                              end
                           end
                           Iend = Iend - 1;
                           newfld = str(Istart:Iend);
                           flds = [flds ; {newfld}];   %#ok<AGROW>
                        end
                     end
                  end
               end
               styles(I).metafields = flds;
               
               uih.styles = styles;
               set(uih.listStyles, ...
                  'UserData',styles, ...
                  'Value',I)
               set(h_dlg,'UserData',uih)
               
               set(uih.editName,'String',styles(I).name)
               ui_metastyle('refresh')
               
            else
               
               messagebox('init','Original name could not be located - updates cancelled', ...
                  [],'Error',[.9 .9 .9])
               
            end
            
         case 'editmeta'
            
            set(uih.editName,'UserData',styles(Isel).name)
            
            s = newstruct('data');
            s.title = styles(Isel).name;
            s.datafile = [{'none'},{0}];
            
            s.name = {'MetadataFields'};
            s.units = {'category_field'};
            s.description = {''};
            s.datatype = {'s'};
            s.numbertype = {'none'};
            s.variabletype = {'nominal'};
            s.precision = 0;
            s.criteria = {''};
            s.flags = s.criteria;
            flds = styles(Isel).metafields;
            if isempty(flds)
               flds = {'null'};
            end
            s.values = {flds};
            
            if gce_valid(s,'data')
               
               %ui_datagrid('init',s,uih.cmdEditMeta,['ui_metastyle(''editmeta2'');'], ...
               %   200,'left');
               
               ui_datagrid('init',s,uih.cmdEditMeta,'ui_metastyle(''null'');',200,'left');
               
            else
               
               messagebox('init','Selected style is invalid and cannot be edited',[],'Error',[.9 .9 .9]);
               
            end
            
         case 'editmeta2'
            
            tmp = get(uih.cmdEditMeta,'UserData');
            data = tmp{1};
            
            I = find(strcmp({styles.name},data.title));
            if isempty(I)
               I = find(strcmpi({styles.name},data.title));
            end
            
            if ~isempty(I)
               
               I = I(1);  %choose first match if duplicate names
               
               uih.styles(I).metafields = extract(data,'MetadataFields');
               set(h_dlg,'UserData',uih)
               
               %reset selection to edited style
               set(uih.listStyles,'Value',I,'UserData',styles)
               set(uih.editName,'String',styles(I).name)
               ui_metastyle('refresh')
               
            else
               
               messagebox('init','Original style could not be located - updates cancelled', ...
                  [],'Error',[.9 .9 .9])
               
            end
            
         case 'eval'
            
            %buffer for updating editor menus
            newstyles = styles;
            
            %save updated styles
            fh = which('metastyles.mat');
            if isempty(fh)
               pn = [gce_homepath,filesep,'settings'];
               if ~isdir(pn)
                  pn = fileparts(which('ui_metastyle'));
               end
               save([pn,filesep,'metastyles.mat'],'styles');
            else
               bk = load(fh);
               save(fh,'styles')
               if isfield(bk,'styles')
                  styles = bk.styles;     %#ok<NASGU> %restore last backup
                  save([fh,'.bak'],'styles') %save backup
                  styles = newstyles; %revert to new styles
               end
            end
            
            %close dialog
            close(h_dlg)
            
            %update template menu selections in any open editor windows
            h_edit = findobj('tag','dlgDSEditor');
            
            if ~isempty(h_edit)
               
               stylelist = {styles.name};
               stylestr = {styles.description};
               
               %loop through all open editor windows
               for n = 1:length(h_edit)
                  
                  %get tag for main metadata menu
                  h_mnuMeta = findobj(h_edit(n),'Tag','mnuMeta');
                  
                  if ~isempty(h_mnuMeta)
                  
                     %clear current entries
                     h_child = get(h_mnuMeta,'Children');
                     if ~isempty(h_child)
                        delete(h_child)
                     end
                     
                     %generate new entries
                     for m = 1:length(stylestr)
                        uimenu('Parent',h_mnuMeta, ...
                           'Label',stylestr{m}, ...
                           'Callback',['ui_editor(''tool_',stylelist{m},''')'], ...
                           'UserData',stylelist{m});
                     end
                     
                     %add fixed EML entries
                     h_mnuEMLMetadata = uimenu('Parent',h_mnuMeta, ...
                        'Separator','on', ...
                        'Label','EML Metadata');
                     
                     uimenu('Parent',h_mnuEMLMetadata, ...
                        'Label','Map Units to Unit Dictionary', ...
                        'Callback','ui_editor(''tool_emlmetadata'',''yes'')');
                     
                     uimenu('Parent',h_mnuEMLMetadata, ...
                        'Label','No Unit Mapping', ...
                        'Callback','ui_editor(''tool_emlmetadata'',''no'')');                     
                     
                  end
                  
                  %get tag for matlab export menu
                  h_mnuExpMat = findobj(h_edit(n),'Tag','mnuExpMatMatrix');
                  
                  if ~isempty(h_mnuExpMat)
                  
                     %clear current entries
                     h_child = findobj(h_mnuExpMat,'Tag','mnuExpMatStyles');
                     if ~isempty(h_child)
                        delete(h_child)
                     end
                     
                     %generate new entries for metadata styles
                     for m = 1:length(stylelist)
                        if m == 1
                           sep = 'on'; 
                        else
                           sep = 'off'; 
                        end
                        uimenu('Parent',h_mnuExpMat, ...
                           'Label',['Metadata in ',stylestr{m},' Style'], ...
                           'Separator',sep, ...
                           'Callback',['ui_editor(''exp_matlab_mat'',''',stylelist{m},''');'], ...
                           'Tag','mnuExpMatStyles', ...
                           'Enable','on');
                     end
                  end
                  
                  %get tag for matlab export variables menu
                  h_mnuExpMatVars = findobj(h_edit(n),'Tag','mnuExpMatVars');
                  
                  if ~isempty(h_mnuExpMatVars)
                  
                     %delete current entries
                     h_child = findobj(h_mnuExpMatVars,'Tag','mnuExpMatVarsStyles');
                     if ~isempty(h_child)
                        delete(h_child)
                     end
                     
                     %generate new entries
                     for m = 1:length(stylelist)
                        if m == 1
                           sep = 'on';
                        else
                           sep = 'off';
                        end
                        uimenu('Parent',h_mnuExpMatVars, ...
                           'Label',['Metadata in ',stylestr{m},' Style'], ...
                           'Separator',sep, ...
                           'Callback',['ui_editor(''exp_matlab_vars'',''',stylelist{m},''');'], ...
                           'Tag','mnuExpMatVarsStyles', ...
                           'Enable','on');
                     end
                  end
                  
                  %get tag for matlab export variables menu
                  h_mnuExpMatStruct = findobj(h_edit(n),'Tag','mnuExpMatStruct');
                  
                  if ~isempty(h_mnuExpMatStruct)
                  
                     %delete current entries
                     h_child = findobj(h_mnuExpMatStruct,'Tag','mnuExpStructStyles');
                     if ~isempty(h_child)
                        delete(h_child)
                     end
                     
                     %generate new entries
                     for m = 1:length(stylelist)
                        if m == 1
                           sep = 'on';
                        else
                           sep = 'off';
                        end
                        uimenu('Parent',h_mnuExpMatStruct, ...
                           'Label',['Metadata in ',stylestr{m},' Style'], ...
                           'Separator',sep, ...
                           'Callback',['ui_editor(''exp_matlab_struct'',''',stylelist{m},''');'], ...
                           'Tag','mnuExpStructStyles', ...
                           'Enable','on');
                     end
                  end
                  
               end
               
            end
            
            drawnow
            
      end
      
   end
   
end