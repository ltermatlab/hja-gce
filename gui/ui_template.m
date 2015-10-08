function ui_template(op,data)
%GUI dialog for editing metadata templates used by the GCE Data Toolbox
%
%syntax: ui_template(op,data)
%
%input:
%  op = operation ('init' to initialize dialog)
%  data = data structure or template
%
%output:
%  none
%
%(c)2002-2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 27-Aug-2015

if nargin == 0
   op = 'init';
end
if exist('data','var') ~= 1
   data = [];
end

if strcmp(op,'init')
   
   %check for existing dialog
   if length(findobj) > 1
      h_dlg = findobj('tag','dlgEditTemplates');
   else
      h_dlg = [];
   end
   
   if ~isempty(h_dlg)
   
      %switch to open dialog
      figure(h_dlg)
      drawnow
      
   else  %load template and generate dialog
      
      %load stored templates
      templates = get_templates;
      
      %create dummy template if none defined
      if isempty(templates)
         
         templates = struct( ...
            'template','New Template', ...
            'variable',[], ...
            'name',[], ...
            'units',[], ...
            'description',[], ...
            'datatype',[], ...
            'variabletype',[], ...
            'numbertype',[], ...
            'precision',[], ...
            'criteria',[], ...
            'codes',[], ...
            'metadata',[]);
         
         templates(1).variable = {'var1';'var2';'var3';'var4'};
         templates(1).name = {'name1';'name2';'name3';'name4'};
         templates(1).units = {'none';'none';'none';'none'};
         templates(1).description = {'none';'none';'none';'none'};
         templates(1).datatype = {'f';'d';'s';'e'};
         templates(1).variabletype = {'data';'data';'data';'data'};
         templates(1).numbertype = {'continuous';'discrete';'none';'continuous'};
         templates(1).precision = [1;0;0;2];
         templates(1).codes = {'','','',''};
         templates(1).criteria = {'x<0=''I''';'x<0=''Q''';'';'x>1e5=''Q'''};
         templates(1).metadata = {'Dataset','Title',''};
         
      end
      
      %get screen metrics
      res = get(0,'ScreenSize');
      
      %initialize dialog figure
      h_dlg = figure('Visible','off', ...
         'Name','Template Editor', ...
         'Position',[(res(3)-516)./2 (res(4)-580)./2 516 580], ...
         'ButtonDownFcn','figure(gcf)', ...
         'Color',[0.9 0.9 0.9], ...
         'MenuBar','none', ...
         'NumberTitle','off', ...
         'Tag','dlgEditTemplates', ...
         'ToolBar','none', ...
         'CloseRequestFcn','ui_template(''close'')', ...
         'DefaultuicontrolUnits','pixels', ...
         'Resize','off');
      
      %disable dock controls
      if mlversion >= 7
         set(h_dlg,'WindowStyle','normal')
         set(h_dlg,'DockControls','off')
      end
      
      %create frame elements
      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[0.95 0.95 0.95], ...
         'ForegroundColor',[0.4 0.4 0.4], ...
         'Position',[6 44 506 530], ...
         'Style','frame', ...
         'Tag','frame');
      
      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[0.9 0.9 0.9], ...
         'ForegroundColor',[0.4 0.4 0.4], ...
         'Position',[365 95 140 222], ...
         'Style','frame', ...
         'Tag','frame');
      
      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[0.9 0.9 0.9], ...
         'ForegroundColor',[0.4 0.4 0.4], ...
         'Position',[365 328 140 99], ...
         'Style','frame', ...
         'Tag','frame');
      
      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[0.9 0.9 0.9], ...
         'ForegroundColor',[0.4 0.4 0.4], ...
         'Position',[365 438 140 98], ...
         'Style','frame', ...
         'Tag','frame');
      
      %create template list
      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[0.95 0.95 0.95], ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'Position',[15 538 345 22], ...
         'String','Metadata Templates', ...
         'Style','text', ...
         'Tag','txtLabel');
      
      h_listTemplates = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'Callback','ui_template(''select'')', ...
         'FontSize',9, ...
         'Position',[15 95 345 442], ...
         'String',{templates.template}', ...
         'Style','listbox', ...
         'Tag','listTemplates', ...
         'Value',1);
      
      %create template name field
      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[0.95 0.95 0.95], ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0.8], ...
         'Position',[15 58 50 22], ...
         'String','Name', ...
         'Style','text', ...
         'HorizontalAlignment','left', ...
         'Tag','txtLabel');
      
      h_editName = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'Position',[75 58 430 22], ...
         'String',templates(1).template, ...
         'Style','edit', ...
         'Callback','ui_template(''name'')', ...
         'Tag','editName');
      
      %create command buttons
      h_cmdAdd = uicontrol('Parent',h_dlg, ...
         'Callback','ui_template(''add'')', ...
         'FontSize',9, ...
         'Position',[370 505 130 25], ...
         'String','Add Template', ...
         'Tag','cmdAdd', ...
         'TooltipString','Add a blank template');
      
      h_cmdCopy = uicontrol('Parent',h_dlg, ...
         'Callback','ui_template(''copy'')', ...
         'FontSize',9, ...
         'String','Copy Template', ...
         'Position',[370 475 130 25], ...
         'Tag','cmdCopy', ...
         'TooltipString','Add a new template by copying the selected template');
      
      h_cmdDelete = uicontrol('Parent',h_dlg, ...
         'Callback','ui_template(''delete'')', ...
         'FontSize',9, ...
         'String','Delete Template', ...
         'Position',[370 445 130 25], ...
         'Tag','cmdDelete', ...
         'TooltipString','Delete the selected template');
      
      h_cmdImport = uicontrol('Parent',h_dlg, ...
         'Callback','ui_template(''import'')', ...
         'FontSize',9, ...
         'String','Import Templates', ...
         'Position',[370 395 130 25], ...
         'Tag','cmdImport', ...
         'TooltipString','Import template(s) from another template database file');
      
      h_cmdExport = uicontrol('Parent',h_dlg, ...
         'Callback','ui_template(''export'')', ...
         'FontSize',9, ...
         'String','Export Templates', ...
         'Position',[370 365 130 25], ...
         'Tag','cmdExport', ...
         'TooltipString','Export template(s) as a template database file for use in another toolbox instance');
      
      h_cmdSort = uicontrol('Parent',h_dlg, ...
         'Callback','ui_template(''sort'')', ...
         'FontSize',9, ...
         'Position',[370 335 130 25], ...
         'String','Sort Templates', ...
         'Tag','cmdSort', ...
         'TooltipString','Sort the template list alphabetically');
      
      h_cmdEdit = uicontrol('Parent',h_dlg, ...
         'Callback','ui_template(''edit'')', ...
         'FontSize',9, ...
         'Position',[370 285 130 25], ...
         'String','Edit All Metadata', ...
         'Tag','cmdEdit', ...
         'TooltipString','Edit all metadata in the selected template using the Template Editor dialog');
      
      h_cmdEditDesc = uicontrol('Parent',h_dlg, ...
         'Callback','ui_template(''editdesc'')', ...
         'FontSize',9, ...
         'Position',[370 255 130 25], ...
         'String','Edit Attributes', ...
         'Tag','cmdEditDesc', ...
         'TooltipString','Edit attribute descriptors for the selected template');
      
      h_cmdImpDesc = uicontrol('Parent',h_dlg, ...
         'Callback','ui_template(''impdesc'')', ...
         'FontSize',9, ...
         'Position',[370 225 130 25], ...
         'String','Import Attributes', ...
         'Tag','cmdImpDesc', ...
         'UserData',pwd, ...
         'TooltipString','Import attribute descriptors to the selected template from a text file or GCE Data Structure');
      
      h_cmdMergeDesc = uicontrol('Parent',h_dlg, ...
         'Callback','ui_template(''mergedesc'')', ...
         'FontSize',9, ...
         'Position',[370 195 130 25], ...
         'String','Merge Attributes', ...
         'Tag','cmdMergeDesc', ...
         'UserData',pwd, ...
         'TooltipString','Merge attribute descriptors from other templates with the selected template to add additional variables');
      
      h_cmdEditMeta = uicontrol('Parent',h_dlg, ...
         'Callback','ui_template(''editmeta'')', ...
         'Position',[370 165 130 25], ...
         'FontSize',9, ...
         'String','Edit Doc Metadata', ...
         'Tag','cmdEditMeta', ...
         'TooltipString','Edit documentation metadata for the selected template');
      
      h_cmdEditCrit = uicontrol('Parent',h_dlg, ...
         'Callback','ui_template(''editcrit'')', ...
         'Position',[370 135 130 25], ...
         'FontSize',9, ...
         'String','Edit Q/C Criteria', ...
         'Tag','cmdEditCrit', ...
         'TooltipString','Edit quality control flag criteria for the selected template');
      
      h_cmdSyncCrit = uicontrol('Parent',h_dlg, ...
         'Callback','ui_template(''qcsync'')', ...
         'Position',[370 105 130 25], ...
         'FontSize',9, ...
         'String','Sync Q/C Criteria', ...
         'Tag','cmdSyncCrit', ...
         'TooltipString','Synchronize quality control flag criteria in the selected template with matching variables in other templates');
      
      %create cancel button
      h_cmdClose = uicontrol('Parent',h_dlg, ...
         'Callback','ui_template(''close'')', ...
         'FontSize',9, ...
         'Position',[8 8 80 25], ...
         'String','Cancel', ...
         'Tag','cmdClose', ...
         'TooltipString','Cancel editing and close the dialog');
      
      %create accept button
      h_cmdAccept = uicontrol('Parent',h_dlg, ...
         'Callback','ui_template(''eval'')', ...
         'FontSize',9, ...
         'Position',[432 8 80 25], ...
         'String','Accept', ...
         'Tag','cmdAccept', ...
         'TooltipString','Accept changes and close dialog');
      
      %cache form data and uicontrol handles
      uih = struct('listTemplates',h_listTemplates, ...
         'cmdCopy',h_cmdCopy, ...
         'cmdAdd',h_cmdAdd, ...
         'cmdImport',h_cmdImport, ...
         'cmdExport',h_cmdExport, ...
         'cmdDelete',h_cmdDelete, ...
         'cmdSort',h_cmdSort, ...
         'cmdEdit',h_cmdEdit, ...
         'editName',h_editName, ...
         'cmdEditCrit',h_cmdEditCrit, ...
         'cmdSyncCrit',h_cmdSyncCrit, ...
         'cmdEditDesc',h_cmdEditDesc, ...
         'cmdImpDesc',h_cmdImpDesc, ...
         'cmdMergeDesc',h_cmdMergeDesc, ...
         'cmdEditMeta',h_cmdEditMeta, ...
         'cmdClose',h_cmdClose, ...
         'cmdAccept',h_cmdAccept, ...
         'templates',templates);
      
      %activate dialog
      set(h_dlg,'UserData',uih,'Visible','on')
      drawnow      
      
      %check for new template - invoke add method
      if isstruct(data) && isfield(data,'template')
         ui_template('add',data)
      end
      
   end
   
else  %handle other callbacks
   
   %get dialog handle
   if length(findobj) > 1
      h_dlg = findobj('tag','dlgEditTemplates');
   else
      h_dlg = [];
   end
   
   %check for valid dialog
   if ~isempty(h_dlg)
      
      %get cached dialog data
      uih = get(h_dlg,'UserData');
      templates = uih.templates;

      %get selected list value
      Isel = get(uih.listTemplates,'value');
      
      %handle callbacks
      switch op
         
         case 'close'  %close dialog
            
            delete(h_dlg)
            drawnow
            ui_aboutgce('reopen')  %check for last window
            
         case 'add'  %add new template
            
            %init blank template
            template = [];
            
            %get template from data input argument or instantiate empty template
            if exist('data','var') == 1 && isstruct(data)
               template = data;
            else
               template.template = 'New Template';
               template.variable = {''};
               template.name = {''};
               template.units = {''};
               template.description = {''};
               template.datatype = {'u'};
               template.variabletype = {''};
               template.numbertype = {''};
               template.precision = 0;
               template.criteria = {''};
               template.codes = {''};
               template.metadata = {'Dataset','Title',''};
            end
            
            %calculate position at end of current templates
            Ipos = length(templates)+1;
            
            try
               templates(Ipos).template = template.template;
               templates(Ipos).variable = template.variable;
               templates(Ipos).name = template.name;
               templates(Ipos).units = template.units;
               templates(Ipos).description = template.description;
               templates(Ipos).datatype = template.datatype;
               templates(Ipos).variabletype = template.variabletype;
               templates(Ipos).numbertype = template.numbertype;
               templates(Ipos).precision = template.precision;
               templates(Ipos).criteria = template.criteria;
               templates(Ipos).codes = template.codes;
               templates(Ipos).metadata = template.metadata;
            catch
               templates = [];
            end
            
            %check for concatenation error
            if ~isempty(templates)
               uih.templates = templates;
               set(h_dlg,'UserData',uih)
               set(uih.listTemplates, ...
                  'String',{templates.template}', ...
                  'Value',length(templates))
               set(uih.editName,'String',template.template)
            else
               messagebox('init','An error occurred adding the specified template','','Error',[.9 .9 .9])
            end
            
         case 'copy'  %copy existing template
            
            templates(end+1) = templates(Isel);
            templates(end).template = [templates(Isel).template,'_copy'];
            
            uih.templates = templates;
            set(uih.listTemplates, ...
               'String',{templates.template}', ...
               'Value',length(templates))
            set(uih.editName,'String',templates(end).template)
            set(h_dlg,'UserData',uih)
            
            drawnow
            
         case 'import' %import template(s) from a file
            
            %cache selected template
            tempname = templates(Isel).template;
            
            %import templates, prompting for filename and template selections
            [templates,msg] = import_templates('','',templates);
            
            %check for successful import
            if ~isempty(templates)
               
               %update cached templates structure
               uih.templates = templates;
               
               %look up prior template selection in new structure
               Isel = find(strcmp(tempname,{templates.template}'));
               if isempty(Isel)
                  Isel = 1;  %default to 1 if not matched
               end
               
               %update list dialog
               set(uih.listTemplates, ...
                  'String',{templates.template}', ...
                  'Value',Isel)
               
               %update name editbox
               set(uih.editName,'String',templates(Isel).template)
               
               %store updated cache in figure handle
               set(h_dlg,'UserData',uih)
               drawnow
               
            end
            
            %display status message
            if ~isempty(msg)
               messagebox('init',msg,'','Information',[0.95 0.95 0.95],0)
            end
            
         case 'export'  %export template database
            
            %get index of templates to export
            Isel = listdialog('liststring',{templates.template}', ...
               'name','Select Templates', ...
               'promptstring','Select Templates for Export', ...
               'selectionmode','multiple', ...
               'listsize',[0 0 300 500]);
            
            %apply selection and save templates unless cancelled
            if ~isempty(Isel)
               templates = templates(Isel);
               [fn,pn] = uiputfile('imp_templates.mat','Select a location for saving the file');
               if ischar(fn)
                  save([pn,filesep,fn],'templates')
               end
            end
            
         case 'delete'  %delete template
            
            %check for last template and cancel deletion
            if length(templates) > 1
            
               I = (1:length(templates)) ~= Isel;
               
               templates = templates(I);
               uih.templates = templates;
               newval = min(Isel,length(templates));
               
               %update list and template name fields
               set(uih.listTemplates, ...
                  'String',{templates.template}', ...
                  'Value',newval);
               set(uih.editName,'String',templates(newval).template)
               
               set(h_dlg,'UserData',uih)
               drawnow
               
            else
               messagebox('init','At least one template is required - delete cancelled','','Warning',[0.95 0.95 0.95])
            end
            
         case 'sort'  %sort templates alphabetically by name
            
            templist = get(uih.listTemplates,'String');
            Isel = get(uih.listTemplates,'Value');
            [tmp,Isort] = sort(lower(templist));
            Iselnew = find(Isort==Isel);
            
            uih.templates = uih.templates(Isort);
            
            set(uih.listTemplates,'String',templist(Isort),'Value',Iselnew,'ListboxTop',1)
            set(h_dlg,'UserData',uih)
            
            drawnow
            
         case 'name'  %rename template selection
            
            str = deblank(get(uih.editName,'String'));
            
            if ~isempty(str)
               templates(Isel).template = str;
               uih.templates = templates;
               set(h_dlg,'UserData',uih)
               set(uih.listTemplates,'String',{templates.template}')
               drawnow
            else
               messagebox('init','Template names cannot be blank',[],'Error',[.9 .9 .9])
            end
            
         case 'mergedesc'  %merge attributes from other templates with the selected template
            
            %generate list of other templates
            Isel = get(uih.listTemplates,'Value');
            Irem = setdiff((1:length(templates)),Isel);
            str = {templates(Irem).template}';
            
            %get index of templates to merge
            Imerge = listdialog('liststring',str, ...
               'name','Select Templates', ...
               'promptstring','Select Templates to Merge', ...
               'selectionmode','multiple', ...
               'listsize',[0 0 300 500]);
            
            %apply selection and save templates unless cancelled
            if ~isempty(Imerge)
               
               %set dirty flag
               numchanges = 0;

               %get template structure fields
               flds = fieldnames(templates);
               
               %loop through templates to merge
               for cnt = 1:length(Imerge)
                  
                  %resolve point to original template struct
                  ptr = Irem(Imerge(cnt));
                  
                  %get index of new attributes based on variable match
                  [vars,Inew] = setdiff(templates(ptr).variable,templates(Isel).variable);
                  
                  %check for any new attributes
                  if ~isempty(Inew)

                     %increment new variable counter
                     numchanges = numchanges + length(Inew);
                     
                     %loop through templates fields adding non-duplicated attribute metadata fields
                     for n = 1:length(flds)
                        
                        %get field name
                        fld = flds{n};
                        
                        %check for scalar template name field
                        if ~strcmp('template',fld) && ~strcmp('metadata',fld)
                           oldvals = templates(Isel).(fld);
                           newvals = templates(ptr).(fld);
                           templates(Isel).(fld) = [oldvals ; newvals(Inew)];
                        end
                        
                     end
                     
                  end
                  
               end         
               
               %update cached templates and generate alert
               if numchanges > 0
                  uih.templates = templates;
                  set(h_dlg,'UserData',uih)
                  if numchanges == 1
                     msg = '1 new variable was added from the selected template(s)';
                  else
                     msg = [int2str(numchanges),' new variables were added from the selected template(s)'];
                  end
               else
                  msg = 'No new variables were found in the specified template(s)';
               end
               messagebox('init',msg,'','Information',[0.95 0.95 0.95])
               
            end          
            
         case 'qcsync'  %synchronize Q/C rules in the selected template to the corresponding attributes in other templates
            
            %generate list of other templates
            Isel = get(uih.listTemplates,'Value');
            Irem = setdiff((1:length(templates)),Isel);
            str = {templates(Irem).template}';
            
            %get index of templates to sync
            Imerge = listdialog('liststring',str, ...
               'name','Select Templates', ...
               'promptstring','Select Templates to Merge', ...
               'selectionmode','multiple', ...
               'listsize',[0 0 300 500]);
            
            %apply selection and save templates unless cancelled
            if ~isempty(Imerge)
               
               %set dirty flag
               numchanges = 0;

               %loop through templates to merge
               for cnt = 1:length(Imerge)
                  
                  %resolve pointer to original template struct
                  ptr = Irem(Imerge(cnt));
                  
                  %get index of common attributes based on variable match
                  [vars,Imatch,Isource] = intersect(templates(ptr).name,templates(Isel).name);
                  
                  %check for any new attributes
                  if ~isempty(Imatch)

                     %loop through templates variables copying q/c criteria
                     for n = 1:length(Imatch)
                        
                        %get criteria for matching variables
                        oldcrit = templates(ptr).criteria{Imatch(n)};
                        newcrit = templates(Isel).criteria{Isource(n)};
                        
                        %copy criteria if different
                        if ~strcmp(oldcrit,newcrit)
                           templates(ptr).criteria{Imatch(n)} = newcrit;
                           numchanges = numchanges + 1;
                        end
                        
                     end
                     
                  end
                  
               end         
               
               %update cached templates and generate alert
               if numchanges > 0
                  uih.templates = templates;
                  set(h_dlg,'UserData',uih)
                  if numchanges == 1
                     msg = '1 Q/C criteria expression was updated in the selected template(s)';
                  else
                     msg = [int2str(numchanges),' Q/C criteria expressions were updated in the selected template(s)'];
                  end
               else
                  msg = 'No Q/C criteria differences were found in matching variables';
               end
               messagebox('init',msg,'','Information',[0.95 0.95 0.95])
               
            end              
            
         case 'impdesc'  %import column descriptors from a data structure on disk
            
            %prompt for file
            curpath = pwd;
            pn = get(uih.cmdImpDesc,'UserData');  %get path cache
            cd(pn)
            [fn,pn] = uigetfile('*.*','Select a text file or GCE Data Structure containing descriptors to import');
            cd(curpath)
            drawnow
            
            %init error message string
            msg = '';
            
            %check for cancel
            if ischar(fn)
               
               %update path cache
               set(uih.cmdImpDesc,'UserData',pn)
               
               %check for matlab file extension
               if strfind(lower(fn),'.mat') > 0
                  
                  %load data structure
                  s = imp_datastruct(fn,pn);
                  
                  if ~isempty(s)
                     
                     %get templates from cached form data
                     templates = uih.templates;
                     
                     %check for attribute metadata columns
                     varcol = name2col(s,'Variable');
                     dtypecol = name2col(s,'DataType');
                     vtypecol = name2col(s,'VariableType');
                     
                     %populate template attribute descriptors
                     if ~isempty(varcol) && ~isempty(dtypecol) && ~isempty(vtypecol)
                        
                        %extract attribute metadata columns, setting defaults for missing fields
                        vars = extract(s,varcol);
                        dtypes = extract(s,dtypecol);
                        vtypes = extract(s,vtypecol);
                        
                        %look up array length and init dummy array of null strings
                        numvars = length(vars);
                        nullstr = repmat({''},numvars,1);
                        
                        colnames = extract(s,'Name');
                        if isempty(colnames); colnames = vars; end
                        
                        desc = extract(s,'Description');
                        if isempty(desc); desc = vars; end
                        
                        ntypes = extract(s,'NumberType');
                        if isempty(ntypes); ntypes = repmat({'unspecified'},numvars,1); end
                        
                        units = extract(s,'Units');
                        if isempty(units); units = nullstr; end
                        
                        prec = extract(s,'Precision');
                        if isempty(prec); prec = zeros(numvars,1); end
                        
                        crit = extract(s,'Criteria');
                        if isempty(crit); crit = nullstr; end
                        
                        codes = extract(s,'Codes');
                        if isempty(codes); codes = nullstr; end
                        
                        
                        %populate template using data table values
                        templates(Isel).variable = vars;
                        templates(Isel).name = colnames;
                        templates(Isel).units = units;
                        templates(Isel).description = desc;
                        templates(Isel).datatype = dtypes;
                        templates(Isel).variabletype = vtypes;
                        templates(Isel).numbertype = ntypes;
                        templates(Isel).precision = prec;
                        templates(Isel).criteria = crit;
                        templates(Isel).codes = codes;
                        
                     else
                        
                        %populate template by copying attribute metadata from data structure
                        templates(Isel).variable = s.name';
                        templates(Isel).name = s.name';
                        templates(Isel).units = s.units';
                        templates(Isel).description = s.description';
                        templates(Isel).datatype = s.datatype';
                        templates(Isel).variabletype = s.variabletype';
                        templates(Isel).numbertype = s.numbertype';
                        templates(Isel).precision = s.precision';
                        templates(Isel).criteria = s.criteria';
                        
                        %init codes array for metadata lookup
                        codes = repmat({''},length(s.name),1);
                        
                        %parse codes from metadata, match to data columns
                        valuecodes = lookupmeta(s.metadata,'Data','ValueCodes');
                        if ~isempty(valuecodes)
                           ar = splitstr(valuecodes,'|');
                           colnames = s.name;
                           for n = 1:length(ar)
                              [colname,codedefs] = strtok(ar{n},':');
                              Imatch = find(strcmp(colname,colnames));
                              if length(Imatch) == 1
                                 codes{Imatch} = trimstr(codedefs(2:end));
                              end
                           end
                        end
                        
                        %add matched codes to template
                        templates(Isel).codes = codes;
                        
                     end
                     
                  else
                     templates = [];
                     msg = ['''',fn,''' does not contain a valid data structure'];
                  end
                  
               else  %text file
                  
                  %parse template
                  [template,msg] = make_template(templates(Isel).template,fn,pn);
                  
                  %populate template fields
                  if ~isempty(template)
                     templates(Isel).variable = template.variable;
                     templates(Isel).name = template.name;
                     templates(Isel).units = template.units;
                     templates(Isel).description = template.description;
                     templates(Isel).datatype = template.datatype;
                     templates(Isel).variabletype = template.variabletype;
                     templates(Isel).numbertype = template.numbertype;
                     templates(Isel).precision = template.precision;
                     templates(Isel).criteria = template.criteria;
                     templates(Isel).codes = template.codes;
                  end
                  
               end                  

               %update cached templates and refresh dialog
               if ~isempty(templates)                  
                  uih.templates = templates;
                  set(h_dlg,'UserData',uih)  %update stored values
                  ui_template('editdesc')  %open new descriptors for editing                  
               elseif ~isempty(msg)                  
                  messagebox('init',msg,'','Import Error',[.9 .9 .9])                  
               end
               
            end
            
         case 'edit'  %open template in the data structure editor for editing
            
            %get template
            template = templates(Isel);
            
            %get criteria from template for column reference check
            crit = template.criteria;

            %update column references in Q/C rules to match variable==name format
            if ~isempty(regexp(crit,'col_'))
               colnames = template.name;            %get column names
               varnames = template.variable;        %get variable names
               len = cellfun('length',colnames);    %get column name lengths
               [len,Isort] = sort(len);             %get sort index on name length
               colnames = colnames(flipud(Isort));  %sort names in reverse length order to avoid substring sbustitutions
               varnames = varnames(flipud(Isort));  %sort variable names to match
               for n = 1:length(colnames)
                  colname = colnames{n};
                  varname = varnames{n};
                  crit = strrep(crit,['col_',colname],['col_',varname,'==',colname]);
               end
            end
            
            %instantiate empty structure
            s = newstruct('data');
            s.title = template.template;
            s.metadata = template.metadata;
            s.datafile = [{'none'},{0}];
            s.name = concatcellcols([template.variable,template.name],'==')';
            s.units = template.units';
            s.description = template.description';
            s.datatype = template.datatype';
            s.variabletype = template.variabletype';
            s.numbertype = template.numbertype';
            s.precision = template.precision';
            s.criteria = crit';
            s.values = repmat({[]},1,length(s.name));
            s.flags = repmat({''},1,length(s.name));
            
            %open editor instance
            ui_editor('init',newstruct,['ui_template(''edit2'',''',templates(Isel).template,''')'], ...
               uih.cmdEdit)
            
            %call template editing operation
            ui_editor('addtemplate',s)
            
         case 'edit2'   %handle returned data from the data structure editor
            
            %get template name from data argument
            template = data;
            
            %get template data from button userdata
            newtemplate = get(uih.cmdEdit,'UserData');
            
            %clear cached data
            set(uih.cmdEditDesc,'UserData',[])
            
            %get index of edited template
            Isel = find(strcmp(template,{templates.template}'));
            
            if ~isempty(Isel)
               
               %split variable and name
               numvars = length(newtemplate.name);
               names = repmat({''},numvars,1);
               vars = names;
               for n = 1:numvars
                  ar = splitstr(newtemplate.name{n},'=');
                  if ~isempty(ar)
                     vars{n} = ar{1};
                     if length(ar) >= 2
                        names{n} = ar{2};
                     else
                        names{n} = ar{1};
                     end
                  end
               end
               
               %init codes array for metadata lookup
               codes = repmat({''},length(newtemplate.name),1);
               
               %parse codes from metadata, match to data columns
               valuecodes = lookupmeta(newtemplate.metadata,'Data','ValueCodes');
               if ~isempty(valuecodes)
                  ar = splitstr(valuecodes,'|');
                  colnames = names;
                  for n = 1:length(ar)
                     [colname,codedefs] = strtok(ar{n},':');
                     Imatch = find(strcmp(colname,colnames));
                     if length(Imatch) == 1
                        codes{Imatch} = trimstr(codedefs(2:end));
                     end
                  end
               end
               
               %remove variable name from q/c criteria
               crit = newtemplate.criteria';
               crit = regexprep(crit,'col_\w+==','col_');
               
               %update template fields
               templates(Isel).metadata = newtemplate.metadata;
               templates(Isel).variable = vars;
               templates(Isel).name = names;
               templates(Isel).units = newtemplate.units';
               templates(Isel).description = newtemplate.description';
               templates(Isel).datatype = newtemplate.datatype';
               templates(Isel).variabletype = newtemplate.variabletype';
               templates(Isel).numbertype = newtemplate.numbertype';
               templates(Isel).precision = newtemplate.precision';
               templates(Isel).criteria = crit;
               templates(Isel).codes = codes;

               %store changes
               uih.templates = templates;
               set(uih.listTemplates, ...
                  'UserData',templates, ...
                  'Value',Isel)
               set(uih.editName,'String',templates(Isel).template)
               set(h_dlg,'UserData',uih)
               drawnow
               
            end
            
         case 'editdesc'  %edit attribute descriptors using ui_datagrid by converting template to data structure
            
            %instantiate empty structure
            s = newstruct('data');
            s.title = templates(Isel).template;
            s.metadata = templates(Isel).metadata;
            s.datafile = [{'none'},{0}];
            
            %remove fields not supported by data structure spec
            template = rmfield(templates(Isel),'metadata');
            template = rmfield(template,'template');
            
            %get array of structure fieldnames
            names = {'Variable','Name','Units','Description','DataType','VariableType','NumberType','Precision','Criteria','Codes'};
            desc = {'Variable name in the source data file', ...
               'Column name to assign', ...
               'Column measurement units (none or blank for non-numeric)', ...
               'Description of the column', ...
               'Data storage type: f for floating-point, d for decimal integer, e for exponential, s for string', ...
               'Variable type: data, calculation, nominal, ordinal, logical, datetime, coord, code, text', ...
               'Numerical type: none for non-numeric, continuous for ratio floating-point/exponential, discrete for integer, angular', ...
               'Number of digits to display for numerical data types (0 for integer or string)', ...
               'Quality control critieria/rules', ...
               'Value codes to assign (format: code = description, code = description, etc.}'};
            
            numcols = length(names);
            
            %populate structure with template info
            s.name = names;
            s.units = desc;
            s.description = repmat({''},1,numcols);
            dtype = repmat({'s'},1,numcols);
            ntype = repmat({'none'},1,numcols);
            Iprec = find(strcmp(names,'Precision'));
            dtype{Iprec} = 'd';
            ntype{Iprec} = 'discrete';
            s.datatype = dtype;
            s.numbertype = ntype;
            s.variabletype = repmat({'nominal'},1,numcols);
            s.precision = zeros(1,numcols);
            s.criteria = repmat({''},1,numcols);
            s.flags = s.criteria;
            
            vals = cell(1,numcols);
            numrows = length(template.name);
            
            for n = 1:length(names)
               v = template.(lower(names{n}));
               if size(v,1) == 1
                  if ischar(v)
                     v = [cellstr(v) ; repmat({''},numrows-1,1)];
                  else
                     v = [v ; zeros(numrows-1,1)];
                  end
               end
               vals(n) = {v};
            end
            s.values = vals;
            
            if gce_valid(s,'data')
               ui_datagrid('init',s,uih.cmdEditDesc,'ui_template(''editdesc2'',s);', ...
                  160,'left',templates(Isel).template);
            else
               messagebox('init','Selected template is invalid and cannot be edited',[],'Error',[.9 .9 .9]);
            end
            
         case 'editdesc2'  %handle column descriptor edits
            
            template = sortdata(data,[1,2],[1 1]);  %sort fields by variable, name
            
            I = find(strcmp({templates.template},template.title));
            if isempty(I)
               I = find(strcmpi({templates.template},template.title));
            end
            
            if ~isempty(I)
               
               I = I(1);
               
               %validate datatypes
               dtype = extract(template,'datatype');
               Ibad = find((strcmp(dtype,'s') | ...
                  strcmp(dtype,'f') | ...
                  strcmp(dtype,'d') | ...
                  strcmp(dtype,'e')) == 0);
               if ~isempty(Ibad)
                  dtype(Ibad) = {'u'};
               end
               
               %validate numbertypes
               ntype = extract(template,'numbertype');
               Ibad = find((strcmp(ntype,'none') | ...
                  strcmp(ntype,'continuous') | ...
                  strcmp(ntype,'discrete') | ...
                  strcmp(ntype,'angular')) == 0);
               if ~isempty(Ibad)
                  ntype(Ibad) = {'unspecified'};
               end
               
               %valiadate variabletypes
               vtype = extract(template,'variabletype');
               Ibad = find((strcmp(vtype,'code') | ...
                  strcmp(vtype,'data') | ...
                  strcmp(vtype,'calculation') | ...
                  strcmp(vtype,'datetime') | ...
                  strcmp(vtype,'coord') | ...
                  strcmp(vtype,'ordinal') | ...
                  strcmp(vtype,'nominal') | ...
                  strcmp(vtype,'logical') | ...
                  strcmp(vtype,'text')) == 0);
               if ~isempty(Ibad)
                  vtype(Ibad) = {'unspecified'};
               end
               
               templates(I).variable = extract(template,'variable');
               templates(I).name = extract(template,'name');
               templates(I).units = extract(template,'units');
               templates(I).description = extract(template,'description');
               templates(I).datatype = dtype;
               templates(I).variabletype = vtype;
               templates(I).numbertype = ntype;
               templates(I).precision = extract(template,'precision');
               templates(I).criteria = extract(template,'criteria');
               templates(I).codes = extract(template,'codes');
               
               uih.templates = templates;
               set(uih.listTemplates, ...
                  'UserData',templates, ...
                  'Value',I)
               set(uih.editName,'String',templates(I).template)
               set(h_dlg,'UserData',uih)
               drawnow
               
            else
               
               messagebox('init','Original template could not be located - updates cancelled', ...
                  [],'Error',[.9 .9 .9])
               
            end
            
         case 'editcrit'  %open q/c criteria for editing
            
            %convert template entry to empty data structure
            temp = uih.templates(Isel);
            s = newstruct('data');
            s.title = temp.template;
            s.metadata = temp.metadata;
            s.variable = temp.variable';
            s.name = temp.name';
            s.units = temp.units';
            s.description = temp.description';
            s.datatype = temp.datatype';
            s.variabletype = temp.variabletype';
            s.numbertype = temp.numbertype';
            s.precision = temp.precision';
            s.criteria = temp.criteria';
            s.flags = repmat({''},1,length(s.name));
            vals = repmat({{''}},1,length(s.name));
            vals(~strcmp(s.datatype,'s')) = {NaN};
            s.values = vals;
            s.editdate = datestr(now);
            
            %open criteria in editor app
            ui_qccriteria('init',s,[],'',[],'ui_template(''editcrit2'',data)')
            
         case 'editcrit2'  %handle q/c criteria edits
            
            temp = uih.templates;
            if iscell(data) && length(data) == 3
               crit = data{1};
               flaglist = data{3};
               if length(crit) == length(temp(Isel).criteria)
                  temp(Isel).criteria = crit';
                  meta = temp(Isel).metadata;
                  if ~isempty(meta)
                     meta = addmeta(meta,{'Data','Codes',flaglist});
                  else
                     meta = {'Data','Codes',flaglist};
                  end
                  temp(Isel).metadata = meta;
                  uih.templates = temp;
                  set(h_dlg,'userdata',uih)
               else
                  messagebox('init','An error occurred updating the Q/C critieria - changes cancelled','','Error',[.9 .9 .9])
               end
            end
            
         case 'editmeta'  %open metadata for editing
            
            set(uih.editName,'UserData',templates(Isel).template)
            
            ui_editmetadata('init',templates(Isel).metadata,uih.cmdEditMeta,'ui_template(''editmeta2'');');
            
         case 'editmeta2'  %handle metadata updates
            
            meta = get(uih.cmdEditMeta,'UserData');
            template = get(uih.editName,'UserData');
            
            set(uih.cmdEditMeta,'UserData',[])
            set(uih.editName,'UserData',[])
            
            I = find(strcmp({templates.template},template));
            if isempty(I)
               I = find(strcmpi({templates.template},template));
            end
            
            if ~isempty(I)
               
               uih.templates(I).metadata = meta;
               set(h_dlg,'UserData',uih)
               drawnow
               
            else
               
               messagebox('init','Original template could not be located - updates cancelled', ...
                  [],'Error',[.9 .9 .9])
               
            end
            
         case 'select'  %handle list selection callbacks
            
            set(uih.editName,'String',templates(Isel).template)
            drawnow
            
         case 'eval'  %apply selections and save templates
            
            %call get_templates to copy defaults to userdata if not present
            get_templates;
            if ~isempty(templates)
               fh = which('imp_templates.mat');  %get location of existing templates file
            else
               fh = '';
            end
            
            %check for existing imp_templates.mat
            if isempty(fh)
               
               %no existing file - add new file in userdata directory
               pn = [gce_homepath,filesep,'userdata'];
               if ~isdir(pn)
                  pn = fileparts(which('ui_template'));  %save new file to same path as GUI if userdata not present
               end              
               save([pn,filesep,'imp_templates.mat'],'templates');
               
            else  %existing file
                              
               bk = get_templates;   %load prior templates before saving revisions
               
               save(fh,'templates')  %save revised templates
               
               %back up prior templates
               if ~isempty(bk)
                  templates = bk;  %rename prior templates variable
                  save([fh,'.bak'],'templates') %save prior templates to backup file
               end
               
            end
            
            ui_template('close')
            
      end
      
   end
   
end
