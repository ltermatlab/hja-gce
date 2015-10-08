function ui_editmetadata(op,s,h,cb)
%Dialog for editing metadata stored in a GCE Data Structure (called by 'ui_editor')
%
%syntax:  ui_editmetadata(op,s,h,callback)
%
%input:
%  op = operation
%  s = data structure or metadata array
%  h = handle to use for storing edited metadata (stored in 'UserData')
%  callback = callback string to evaluate after editing
%
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
%last modified: 08-Sep-2014

if nargin >= 1

   if ~ischar(op)  %assume non-string args are data structure or metadata array
      s = op;
      op = 'init';
   end

   if strcmp(op,'init')

      if exist('h','var') ~= 1
         h = [];
      end

      if exist('cb','var') ~= 1
         cb = '';
      end

      if exist('s','var') ~= 1
         meta = [];
      elseif isstruct(s)
         if isfield(s,'metadata')
            meta = s.metadata;
         else
            meta = [];
         end
      elseif iscell(s)
         if size(s,2) == 3
            meta = s;
         else
            meta = [];
         end
      else
         meta = [];
      end

      %set ui defaults
      figsize = [800 635];
      if strcmp(computer,'PCWIN')
         font = 'Courier New';
         fontsize = 9;
      else
         font = 'Courier';
         fontsize = 8;
      end
      bgcolor = [.95 .95 .95];

      res = get(0,'ScreenSize');

      h_dlg = figure('visible','off', ...
         'color',bgcolor, ...
         'name','Metadata Editor', ...
         'numbertitle','off', ...
         'menubar','none', ...
         'toolbar','none', ...
         'keypressfcn','figure(gcf)', ...
         'units','pixels', ...
         'position',[max(0,0.5.*(res(3)-figsize(1))) max(50,0.5.*(res(4)-figsize(2))) figsize(1) figsize(2)], ...], ...
         'resize','off', ...
         'defaultuicontrolunits','pixels', ...
         'closerequestfcn','ui_editmetadata(''cancel'')', ...
         'tag','dlgEditMetadata');

      if mlversion >= 7
         set(h_dlg,'WindowStyle','normal')
         set(h_dlg,'DockControls','off')
      end

      h_mnuFile = uimenu('parent',h_dlg, ...
         'label','File');

      uimenu('parent',h_mnuFile, ...
         'label','New Metadata', ...
         'callback','ui_editmetadata(''new'')');

      h_mnuFileFields = uimenu('parent',h_mnuFile, ...
         'separator','on', ...
         'label','Import Fields');

      if exist('metastyles.mat','file') == 2
         try
            v = load('metastyles.mat');
         catch
            v = struct('null','');
         end
         if isfield(v,'styles')
            style = {v.styles.name};
            stylestr = {v.styles.description};
            if ~isempty(style)
               for n = 1:length(style)
                  uimenu('Parent',h_mnuFileFields, ...
                     'Label',[stylestr{n},' Style'], ...
                     'Callback',['ui_editmetadata(''imp_',style{n},''')']);
               end
            end
         end
      end

      h_mnuImpMetadata = uimenu('parent',h_mnuFile, ...
         'label','Import Metadata');
      
      h_mnuFileMeta = uimenu('parent',h_mnuImpMetadata, ...
         'label','Data Structure File');

      uimenu('parent',h_mnuFileMeta, ...
         'label','Overlay All Fields', ...
         'callback','ui_editmetadata(''loadoverlay'',''file'')');

      uimenu('parent',h_mnuFileMeta, ...
         'label','Overlay Selected Fields', ...
         'callback','ui_editmetadata(''loadoverlaysel'',''file'')');

      uimenu('parent',h_mnuFileMeta, ...
         'label','Overwrite All Fields', ...
         'separator','on', ...
         'callback','ui_editmetadata(''loadoverwrite'',''file'')');

      uimenu('parent',h_mnuFileMeta, ...
         'label','Overwrite Selected Fields', ...
         'callback','ui_editmetadata(''loadoverwritesel'',''file'')');

      %generate template metadata import submenu if templates database present
      templates = get_templates;

      if ~isempty(templates)
         
         h_mnuTemplateMeta = uimenu('parent',h_mnuImpMetadata, ...
            'label','Metadata Template');
         uimenu('parent',h_mnuTemplateMeta, ...
            'label','Overlay All Fields', ...
            'callback','ui_editmetadata(''loadoverlay'',''template'')');
         
         uimenu('parent',h_mnuTemplateMeta, ...
            'label','Overlay Selected Fields', ...
            'callback','ui_editmetadata(''loadoverlaysel'',''template'')');
         
         uimenu('parent',h_mnuTemplateMeta, ...
            'label','Overwrite All Fields', ...
            'separator','on', ...
            'callback','ui_editmetadata(''loadoverwrite'',''template'')');
         
         uimenu('parent',h_mnuTemplateMeta, ...
            'label','Overwrite Selected Fields', ...
            'callback','ui_editmetadata(''loadoverwritesel'',''template'')');
         
      end
      
      uimenu('parent',h_mnuFile, ...
         'label','Export Metadata', ...
         'separator','on', ...
         'callback','ui_editmetadata(''export'')');

      uimenu('parent',h_mnuFile, ...
         'label','Close', ...
         'separator','on', ...
         'callback','ui_editmetadata(''cancel'')');

      h_mnuEdit = uimenu('parent',h_dlg, ...
         'label','Edit');

      h_mnuEditAdd = uimenu('parent',h_mnuEdit, ...
         'label','Add Record', ...
         'callback','ui_editmetadata(''add'')', ...
         'tag','mnuEditAdd', ...
         'userdata',0);

      h_mnuEditCopy = uimenu('parent',h_mnuEdit, ...
         'label','Copy Record', ...
         'callback','ui_editmetadata(''copy'')', ...
         'tag','mnuEditCopy', ...
         'userdata',0);

      uimenu('parent',h_mnuEdit, ...
         'label','Delete Record', ...
         'callback','ui_editmetadata(''delete'')');

      uimenu('parent',h_mnuEdit, ...
         'label','Sort Records', ...
         'callback','ui_editmetadata(''sort'')');

      uimenu('parent',h_mnuEdit, ...
         'label','Combine Matching', ...
         'callback','ui_editmetadata(''combine'')');

      h_mnuEditUndo = uimenu('parent',h_mnuEdit, ...
         'label','Undo Changes', ...
         'separator','on', ...
         'userdata',meta, ...
         'callback','ui_editmetadata(''undo'')');

      uicontrol(h_dlg, ...
         'style','frame', ...
         'position',[1 1 figsize(1)-1 figsize(2)-1], ...
         'foregroundcolor',[0 0 0], ...
         'backgroundcolor',bgcolor);

      uicontrol(h_dlg, ...
         'style','frame', ...
         'position',[figsize(1)-75 300 70 figsize(2)-335], ...
         'foregroundcolor',[0 0 0], ...
         'backgroundcolor',[.9 .9 .9]);

      uicontrol(h_dlg, ...
         'style','text', ...
         'position',[3 figsize(2)-30 figsize(1)-6 22], ...
         'backgroundcolor',bgcolor, ...
         'fontsize',12, ...
         'fontweight','bold', ...
         'string','Metadata Contents (click on rows to view/edit contents)', ...
         'tag','label');

      h_list = uicontrol('parent',h_dlg, ...
         'style','listbox', ...
         'listboxtop',1, ...
         'fontname',font, ...
         'fontsize',fontsize, ...
         'backgroundcolor',[1 1 1], ...
         'string','', ...
         'position',[5 300 figsize(1)-85 figsize(2)-335], ...
         'min',1, ...
         'max',2, ...
         'value',1, ...
         'callback','ui_editmetadata(''display'')', ...
         'tag','listbox');

      h_cmdMoveFirst = uicontrol('parent',h_dlg, ...
         'position',[figsize(1)-70 figsize(2)-70 60 24], ...
         'style','pushbutton', ...
         'string','First', ...
         'callback','ui_editmetadata(''move'')', ...
         'userdata','first', ...
         'tooltipstring','Move selected metadata field to the first position', ...
         'tag','cmdMoveFirst');

      h_cmdMoveUp = uicontrol('parent',h_dlg, ...
         'position',[figsize(1)-70 figsize(2)-95 60 24], ...
        'style','pushbutton', ...
         'string','Up', ...
         'callback','ui_editmetadata(''move'')', ...
         'tooltipstring','Move selected metadata field up one position', ...
         'userdata','up', ...
         'tag','cmdMoveUp');

      h_cmdMoveDown = uicontrol('parent',h_dlg, ...
         'position',[figsize(1)-70 figsize(2)-120 60 24], ...
         'style','pushbutton', ...
         'string','Down', ...
         'callback','ui_editmetadata(''move'')', ...
         'tooltipstring','Move selected metadata field down one position', ...
         'userdata','down', ...
         'tag','cmdMoveDown');

      h_cmdMoveLast = uicontrol('parent',h_dlg, ...
         'position',[figsize(1)-70 figsize(2)-145 60 24], ...
         'style','pushbutton', ...
         'string','Last', ...
         'callback','ui_editmetadata(''move'')', ...
         'tooltipstring','Move selected metadata field to the last position', ...
         'userdata','last', ...
         'tag','cmdMoveLast');

      h_cmdSort = uicontrol('parent',h_dlg, ...
         'position',[figsize(1)-70 figsize(2)-180 60 24], ...
         'style','pushbutton', ...
         'string','Sort', ...
         'tooltipstring','Sort metadata fields alphabetically by Category, Field', ...
         'callback','ui_editmetadata(''sort'')', ...
         'tag','cmdSort');

      h_cmdCombine = uicontrol('parent',h_dlg, ...
         'position',[figsize(1)-70 figsize(2)-205 60 24], ...
         'style','pushbutton', ...
         'string','Combine', ...
         'tooltipstring','Combine metadata fields with the same Category, Field', ...
         'callback','ui_editmetadata(''combine'')', ...
         'tag','cmdCombine');

      h_cmdAdd = uicontrol('parent',h_dlg, ...
         'position',[figsize(1)-70 figsize(2)-240 60 24], ...
         'style','pushbutton', ...
         'string','Add New', ...
         'tooltipstring','Add a new metadata field below the selected field', ...
         'callback','ui_editmetadata(''add'')', ...
         'tag','cmdAdd');

      h_cmdCopy = uicontrol('parent',h_dlg, ...
         'position',[figsize(1)-70 figsize(2)-265 60 24], ...
         'style','pushbutton', ...
         'string','Copy', ...
         'tooltipstring','Copy the selected metadata field', ...
         'callback','ui_editmetadata(''copy'')', ...
         'tag','cmdAdd');

      h_cmdDelete = uicontrol('parent',h_dlg, ...
         'position',[figsize(1)-70 figsize(2)-290 60 24], ...
         'style','pushbutton', ...
         'string','Delete', ...
         'tooltipstring','Delete the selected metadata field', ...
         'callback','ui_editmetadata(''delete'')', ...
         'tag','cmdDelete');

      h_cmdClear1 = uicontrol('parent',h_dlg, ...
         'position',[figsize(1)-70 figsize(2)-315 60 24], ...
         'style','pushbutton', ...
         'string','Clear', ...
         'tooltipstring','Clear the Contents of the selected metadata field', ...
         'callback','ui_editmetadata(''clear'')', ...
         'tag','cmdClear1');

      uicontrol(h_dlg, ...
         'style','text', ...
         'position',[10 261 80 20], ...
         'backgroundcolor',bgcolor, ...
         'fontsize',10, ...
         'fontweight','bold', ...
         'string','Category', ...
         'tag','label');

      uicontrol(h_dlg, ...
         'style','text', ...
         'position',[10 231 80 20], ...
         'backgroundcolor',bgcolor, ...
         'fontsize',10, ...
         'fontweight','bold', ...
         'string','Field', ...
         'tag','label');

      uicontrol(h_dlg, ...
         'style','text', ...
         'position',[10 201 80 20], ...
         'backgroundcolor',bgcolor, ...
         'fontsize',10, ...
         'fontweight','bold', ...
         'string','Contents', ...
         'tag','label');

      uicontrol(h_dlg, ...
         'style','text', ...
         'position',[90 40 figsize(1)-100 20], ...
         'backgroundcolor',bgcolor, ...
         'foregroundcolor',[0 0 .8], ...
         'fontsize',10, ...
         'string','(Note: use | characters to force line breaks in the formatted metadata)', ...
         'tag','label');

      h_editCat = uicontrol(h_dlg, ...
         'style','edit', ...
         'position',[90 260 150 22], ...
         'backgroundcolor',[1 1 1], ...
         'fontname',font, ...
         'fontsize',fontsize, ...
         'string','', ...
         'enable','off', ...
         'horizontalalignment','left', ...
         'callback','ui_editmetadata(''cat'')', ...
         'tag','editCat');

      h_editField = uicontrol(h_dlg, ...
         'style','edit', ...
         'position',[90 230 150 22], ...
         'backgroundcolor',[1 1 1], ...
         'fontname',font, ...
         'fontsize',fontsize, ...
         'string','', ...
         'enable','off', ...
         'horizontalalignment','left', ...
         'callback','ui_editmetadata(''field'')', ...
         'tag','editField');

      h_editContents = uicontrol(h_dlg, ...
         'style','edit', ...
         'position',[90 60 figsize(1)-100 160], ...
         'backgroundcolor',[1 1 1], ...
         'fontname',font, ...
         'fontsize',fontsize, ...
         'string','', ...
         'horizontalalignment','left', ...
         'min',1, ...
         'max',100, ...
         'enable','off', ...
         'callback','ui_editmetadata(''contents'')', ...
         'tag','editContents');

      h_cmdClear2 = uicontrol(h_dlg, ...
         'style','pushbutton', ...
         'position',[figsize(1)-138 228 60 24], ...
         'string','Clear', ...
         'tooltipstring','Clear metadata field contents', ...
         'callback','ui_editmetadata(''clear'')', ...
         'enable','off', ...
         'tag','cmdClear2');

      h_cmdPreview = uicontrol(h_dlg, ...
         'style','pushbutton', ...
         'position',[figsize(1)-73 228 60 24], ...
         'string','Preview', ...
         'tooltipstring','Preview word-wrapped contents to examine line breaks', ...
         'callback','ui_editmetadata(''preview'')', ...
         'tag','cmdPreview', ...
         'enable','off', ...
         'userdata',1);

      h_cmdCancel = uicontrol(h_dlg, ...
         'style','pushbutton', ...
         'position',[10 10 60 24], ...
         'string','Cancel', ...
         'fontweight','bold', ...
         'tooltipstring','Cancel editing and close the dialog window', ...
         'callback','ui_editmetadata(''cancel'')', ...
         'tag','cmdCancel', ...
         'userdata',1);

      h_cmdEval = uicontrol(h_dlg, ...
         'style','pushbutton', ...
         'position',[figsize(1)-70 10 60 24], ...
         'string','Accept', ...
         'fontweight','bold', ...
         'tooltipstring','Accept the changes and update the metadata', ...
         'callback','ui_editmetadata(''eval'')', ...
         'tag','cmdEval', ...
         'userdata',[{meta},{h},{cb}]);

      uih = struct( ...
         'mnuEditAdd',h_mnuEditAdd, ...
         'mnuEditCopy',h_mnuEditCopy, ...
         'mnuEditUndo',h_mnuEditUndo, ...
         'cmdMoveFirst',h_cmdMoveFirst, ...
         'cmdMoveUp',h_cmdMoveUp, ...
         'cmdMoveDown',h_cmdMoveDown, ...
         'cmdMoveLast',h_cmdMoveLast, ...
         'cmdSort',h_cmdSort, ...
         'cmdCombine',h_cmdCombine, ...
         'cmdAdd',h_cmdAdd, ...
         'cmdDelete',h_cmdDelete, ...
         'cmdCopy',h_cmdCopy, ...
         'cmdClear1',h_cmdClear1, ...
         'cmdClear2',h_cmdClear2, ...
         'cmdPreview',h_cmdPreview, ...
         'list',h_list, ...
         'editCat',h_editCat, ...
         'editField',h_editField, ...
         'editContents',h_editContents, ...
         'cmdCancel',h_cmdCancel, ...
         'cmdEval',h_cmdEval);

      set(h_dlg,'UserData',uih,'Visible','on')

      ui_editmetadata('refresh')

   else

      h_dlg = gcf;

      if strcmp(get(h_dlg,'Tag'),'dlgEditMetadata')  %check for valid callback

         %retrieve cached data
         if ~isempty(h_dlg)
            uih = get(h_dlg,'UserData');
            data = get(uih.cmdEval,'UserData');
            meta = data{1};
            h = data{2};
            cb = data{3};
            Isel = get(uih.list,'Value');
         else
            op = 'bogus';
            meta = [];
            h = [];
            cb = '';
            Isel = [];
         end

         if strcmp(op(1:3),'imp')  %catch field import calls

            %parse style
            stylename = op(5:end);
            
            %import fields
            newmeta = meta_fields(stylename);

            if ~isempty(newmeta)
               
               %initialize indices
               num = size(newmeta,1);
               Imatches = [];
               
               %merge with existing metadata if present
               if ~isempty(meta)
                  Imatches = zeros(size(meta,1),1);
                  for n = 1:num
                     %look up matching fields in current metadata, use contents if found
                     Imatch = find(strcmpi(newmeta{n,1},meta(:,1)) & strcmpi(newmeta{n,2},meta(:,2)));
                     if ~isempty(Imatch)
                        Imatches(Imatch) = 1;  %flag meta field as matched
                        newmeta{n,3} = meta{Imatch(1),3};  %use content from existing metadata
                     end
                  end
               end
               
               if ~isempty(Imatches)
                  Iunused = Imatches==0;
                  newmeta = [newmeta ; meta(Iunused,:)];
               elseif ~isempty(meta)  %none matched - append all prior fields
                  newmeta = [newmeta ; meta];
               end
               
               %buffer existing metadata, incorporate revised metadata
               data{1} = newmeta;
               set(uih.mnuEditUndo,'UserData',meta)
               set(uih.cmdEval,'UserData',data)
               set(uih.cmdCancel,'UserData',1)
               
               ui_editmetadata('refresh')
               
            end
            
         elseif strcmp(op(1:3),'loa')  %catch load metadata request
            
            option = s;  %get template or file flag from second input argument
            newmeta = [];  %init new metadata array
            
            %check for template
            if strcmp(option,'template')
               
               template = lookup_template;
               
               if ~isempty(template)
                  ui_editmetadata(op,template)  %re-call function with selected template
               else
                  ui_editmetadata('display')  %refresh display on cancel
               end
               
            elseif strcmp(option,'file')
               
               [fn,pn] = uigetfile('*.mat;*.MAT','Select a Matlab file containing a valid GCE Data Structure or metadata array');
               drawnow
               
               if fn ~= 0  %check for cancel
                  
                  pn = clean_path(pn);
                  try
                     v = load([pn,filesep,fn],'-mat');
                  catch
                     v = struct('null',[]);
                  end
                  
                  %get metadata
                  newmeta = [];
                  if isfield(v,'meta')
                     if iscell(v.meta) && size(v.meta,2) == 3
                        newmeta = v.meta;
                     end
                  elseif isfield(v,'data')
                     if gce_valid(v.data)
                        newmeta = v.data.metadata;
                     end
                  else
                     flds = fieldnames(v);
                     flds = flds(~strcmp(flds,'null'));
                     for n = 1:length(flds)
                        data = v.(flds{n});
                        if gce_valid(data)
                           newmeta = data.metadata;
                           break
                        end
                     end
                  end
                  
               end
               
            else  %named template
               
               templatename = option;  %get template name from second argument
               
               %load template database
               templates = get_templates;
               
               %match template, retrieve metadata
               if ~isempty(templates)
                  Imatch = find(strcmp(templatename,{templates.template}'));
                  if length(Imatch) == 1
                     newmeta = templates(Imatch).metadata;
                  end
               end               
               
            end
            
            %check for empty new metadata array
            if ~isempty(newmeta)
               
               %determine import options from callback operation
               switch op
                  case 'loadoverlay'
                     fields = 'all';
                     importmode = 'overlay';
                  case 'loadoverlaysel'
                     fields = 'selected';
                     importmode = 'overlay';
                  case 'loadoverwrite'
                     fields = 'all';
                     importmode = 'overwrite';
                  otherwise  %'loadoverwritesel'
                     fields = 'selected';
                     importmode = 'overwrite';
               end
               
               %check for empty meta array
               if isempty(meta)
                  meta = {'Dataset','Title',''};
               end
               
               %call import function with specified options               
               meta = import_metadata(meta,newmeta,fields,importmode);
               
               %check for empty newmeta again to catch cancels on user selections
               if ~isempty(meta)
                  
                  %incorporate revised metadata
                  data{1} = meta;
                  set(uih.cmdEval,'UserData',data)
                  set(uih.cmdCancel,'UserData',1)  %set dirty flag
                  
                  ui_editmetadata('refresh')

               else

                  if strcmp(option,'file')
                     messagebox('init', ...
                        ['The file ''',fn,''' does not contain a valid data structure or metadata array'], ...
                        '', ...
                        'Error', ...
                        [.9 .9 .9]);
                  else
                     messagebox('init', ...
                        ['The template ''',template,''' does not contain a valid metadata array'], ...
                        '', ...
                        'Error', ...
                        [.9 .9 .9]);
                  end

               end

            end

         else

            switch op

               case 'cancel'

                  if ~isempty(h_dlg)
                     delete(h_dlg)
                  end
                  ui_aboutgce('reopen')  %check for last window

               case 'display'  %display details for selected metadata row

                  %init truncation warning
                  msg_trunc = '';
                  
                  if Isel > 1
                     
                     %set category and fields
                     set(uih.editCat,'String',meta{Isel-1,1})
                     set(uih.editField,'String',meta{Isel-1,2})
                     
                     %get value field string
                     str = meta{Isel-1,3};
                     
                     %concatenate multiline strings to avoid error
                     if size(str,1) > 1
                        str = concatecellcols(cellstr(str)',' ');
                        str = str{:};
                     end
                     
                     %check for excessive characters that would blow up editbox
                     if length(str) > 100000
                        msg_trunc = ['Warning: text exceeding 100000 characters cannot be displayed (remaining ', ...
                           int2str(length(str)-100000),' characters truncated)'];
                        str = str(1:100000);
                     end
                     
                     %force breaks in displayed text
                     if ~isempty(strfind(str,'|'))
                        set(gcf,'pointer','watch'); drawnow
                        str2 = '';
                        rem = str;
                        while ~isempty(rem)
                           [tmp,rem] = strtok(rem,'|');
                           tmp = deblank(tmp);
                           if ~isempty(tmp)
                              if isempty(str2)
                                 str2 = tmp;
                              else
                                 str2 = char(str2,['|',tmp]);
                              end
                           end
                        end
                        if isempty(str2)
                           str = '';
                        elseif ~strcmp(str(1,1),'|')
                           str = str2;
                        elseif size(str2,1) == 1
                           str = ['|',deblank(str2(1,:))];
                        else
                           str = char(['|',deblank(str2(1,:))],deblank(str2(2:end,:)));
                        end
                     end
                     
                     %pre-wrap text to avoid extra padding rows
                     if size(str,2) > 95
                       str = wordwrap(str,95,0,'char');
                     end
                     
                     %update contents but trap errors if callback fired while dialog being deleted
                     try
                        set(uih.editContents,'String',str)
                        set(gcf,'pointer','arrow')
                     catch
                     end
                     
                  else  %clear fields
                     
                     set(uih.editCat,'String','')
                     set(uih.editField,'String','')
                     set(uih.editContents,'String','')
                     
                  end

                  ui_editmetadata('controls')

                  %display truncation warning
                  if ~isempty(msg_trunc)
                     messagebox('init',msg_trunc,'','Warning',[0.95 0.95 0.95],0)
                  end
                  
               case 'refresh'  %refresh the dialog

                  if exist('s','var') == 1
                     newlistboxtop = s;
                  else
                     newlistboxtop = get(uih.list,'ListboxTop');
                  end

                  set(gcf,'pointer','watch')
                  drawnow

                  %format metadata for listbox

                  %add header
                  if ~isempty(meta)
                     meta = [{'CATEGORY'},{'FIELD'},{'CONTENTS'} ; meta];
                  else
                     meta = [{'CATEGORY'},{'FIELD'},{'CONTENTS'}];
                  end

                  %truncate long value fields
                  Ilong = find(cellfun('length',meta(:,3))>300);
                  if ~isempty(Ilong)
                     for n = 1:length(Ilong)
                        idx = Ilong(n);
                        str = meta{idx,3};
                        meta(idx,3) = {[str(1:300),'...']};
                     end
                  end

                  %generate single-column cell array with fixed-width first 2 columns
                  str = concatcellcols([cellstr([char(meta(:,1)),repmat(' | ',size(meta,1),1),char(meta(:,2)),repmat(' |',size(meta,1),1)]),meta(:,3)],'  ');

                  Isel = get(uih.cmdCancel,'UserData');
                  if Isel > size(meta,1)+1
                     Isel = 1;
                  end

                  set(uih.list,'String',str,'Value',Isel,'ListboxTop',min(size(str,1),newlistboxtop))

                  set(gcf,'pointer','arrow')

                  ui_editmetadata('display')
                  ui_editmetadata('controls')

               case 'controls'  %toggle uicontrol states

                  cmd_buttons = [uih.cmdMoveFirst; ...
                        uih.cmdMoveUp; ...
                        uih.cmdMoveDown; ...
                        uih.cmdMoveLast; ...
                        uih.cmdSort; ...
                        uih.cmdCombine; ...
                        uih.cmdCopy; ...
                        uih.cmdDelete; ...
                        uih.cmdClear1; ...
                        uih.cmdClear2; ...
                        uih.cmdPreview];

                  if ~isempty(meta)
                     pos = Isel - 1;
                     maxpos = size(meta,1);
                     if pos > 0
                        set(uih.editCat,'Enable','on','ForegroundColor',[0 0 0],'BackgroundColor',[1 1 1])
                        set(uih.editField,'Enable','on','ForegroundColor',[0 0 0],'BackgroundColor',[1 1 1])
                        set(uih.editContents,'ForegroundColor',[0 0 0],'BackgroundColor',[1 1 1],'Enable','on')
                        set(cmd_buttons,'Enable','on')
                        if pos == 1
                           set([uih.cmdMoveUp ; uih.cmdMoveFirst],'Enable','off')
                        else
                           set([uih.cmdMoveUp ; uih.cmdMoveFirst],'Enable','on')
                        end
                        if pos == maxpos
                           set([uih.cmdMoveDown ; uih.cmdMoveLast],'Enable','off')
                        else
                           set([uih.cmdMoveDown ; uih.cmdMoveLast],'Enable','on')
                        end
                     else
                        set(uih.editCat,'Enable','off','ForegroundColor',[.9 .9 .9],'BackgroundColor',[.9 .9 .9])
                        set(uih.editField,'Enable','off','ForegroundColor',[.9 .9 .9],'BackgroundColor',[.9 .9 .9])
                        set(uih.editContents,'Enable','off','ForegroundColor',[.9 .9 .9],'BackgroundColor',[.9 .9 .9])
                        set(cmd_buttons,'Enable','off')
                     end
                     set(uih.cmdEval,'Enable','on')
                  else
                     set(uih.editCat,'String','','Enable','off','ForegroundColor',[.9 .9 .9],'BackgroundColor',[.9 .9 .9])
                     set(uih.editField,'String','','Enable','off','ForegroundColor',[.9 .9 .9],'BackgroundColor',[.9 .9 .9])
                     set(uih.editContents,'String','','Enable','off','ForegroundColor',[.9 .9 .9],'BackgroundColor',[.9 .9 .9])
                     set(cmd_buttons,'Enable','off')
                     set(uih.cmdEval,'Enable','off')
                  end

                  drawnow

               case 'new'

                  data{1} = [];
                  set(uih.mnuEditUndo,'UserData',meta)
                  set(uih.cmdEval,'UserData',data)
                  set(uih.cmdCancel,'UserData',1)

                  ui_editmetadata('refresh')

               case 'undo'

                  meta = get(uih.mnuEditUndo,'UserData');

                  data{1} = meta;
                  set(uih.cmdEval,'UserData',data)
                  set(uih.cmdCancel,'UserData',1)

                  ui_editmetadata('refresh')
                  set(uih.list,'ListboxTop',1)

               case 'move'

                  pos = Isel - 1;
                  direction = get(gcbo,'userdata');
                  maxpos = size(meta,1);
                  Ipos = [];
                  newpos = 1;
                  listboxpos = get(uih.list,'ListboxTop');
                  newlistboxpos = listboxpos;
                  numrows = 15;

                  if maxpos > 1
                     switch direction
                        case 'first'
                           if pos > 0  %check for first row
                              if pos < maxpos  %check for last row
                                 Ipos = [pos,1:pos-1,pos+1:maxpos];
                              else
                                 Ipos = [pos,1:pos-1];
                              end
                              newpos = 1;
                              newlistboxpos = 1;
                           end
                        case 'up'
                           if pos > 0  %check for first row
                              if pos > 2  %check for second row
                                 Ipos = [1:pos-2,pos,pos-1,pos+1:maxpos];
                              else
                                 Ipos = [pos,1,pos+1:maxpos];
                              end
                              newpos = pos - 1;
                              if newpos < listboxpos
                                 newlistboxpos = max(1,listboxpos - 1);
                              end
                           end
                        case 'down'
                           if pos < maxpos
                              if pos < maxpos-1  %check for next to last row
                                 Ipos = [1:pos-1,pos+1,pos,pos+2:maxpos];
                              else
                                 Ipos = [1:pos-1,maxpos,pos];
                              end
                              newpos = pos + 1;
                              if newpos > (listboxpos+numrows-1)
                                 newlistboxpos = min(size(meta,1),listboxpos + 1);
                              end
                           end
                        case 'last'
                           if pos < maxpos
                              if pos > 1  %check for first row
                                 Ipos = [1:pos-1,pos+1:maxpos,pos];
                              else
                                 Ipos = [2:maxpos,1];
                              end
                              newpos = maxpos;
                              newlistboxpos = size(meta,1)-numrows+1;
                           end
                     end
                  end

                  if ~isempty(Ipos)
                     newmeta = meta(Ipos,:);
                     data{1} = newmeta;
                     set(uih.cmdEval,'UserData',data)
                     set(uih.cmdCancel','UserData',newpos+1)
                     ui_editmetadata('refresh',newlistboxpos)
                  end

               case 'add'

                  pos = Isel - 1;

                  val = get(uih.mnuEditAdd,'UserData') + 1;
                  set(uih.mnuEditAdd,'UserData',val)

                  if pos > 0
                     newmeta = [meta(pos,1),{['NewField',int2str(val)]},{''}];
                  elseif ~isempty(meta)
                     newmeta = [meta(1,1),{['NewField',int2str(val)]},{''}];
                  else
                     newmeta = [{['NewCategory',int2str(val)]},{['NewField',int2str(val)]},{''}];
                  end

                  if pos == size(meta,1)
                     meta = [meta ; newmeta];
                  elseif pos == 0
                     meta = [newmeta ; meta];
                  else
                     meta = [meta(1:pos,:) ; newmeta ; meta(pos+1:end,:)];
                  end

                  data{1} = meta;
                  set(uih.cmdEval,'UserData',data)
                  set(uih.cmdCancel','UserData',Isel+1)

                  ui_editmetadata('refresh')

               case 'copy'

                  %get selected field position
                  pos = Isel - 1;
                  
                  if pos > 0
                     
                     %copy metadata content
                     newmeta = meta(pos,:);
                     
                     %merge with metadata array
                     if pos == size(meta,1)
                        meta = [meta ; newmeta];
                     elseif pos == 0
                        meta = [newmeta ; meta];
                     else
                        meta = [meta(1:pos,:) ; newmeta ; meta(pos+1:end,:)];
                     end
                     
                     data{1} = meta;
                     set(uih.cmdEval,'UserData',data)
                     set(uih.cmdCancel','UserData',Isel+1)
                     
                     ui_editmetadata('refresh')
                     
                  end

               case 'delete'

                  pos = Isel - 1;

                  if pos > 0

                     liststr = get(uih.list,'String');

                     if pos == 1
                        meta = meta(2:end,:);
                        liststr = [liststr(1,:) ; liststr(3:end,:)];
                     elseif pos == size(meta,1)
                        meta = meta(1:end-1,:);
                        liststr = liststr(1:end-1,:);
                     else
                        meta = [meta(1:pos-1,:) ; meta(pos+1:end,:)];
                        liststr = [liststr(1:pos,:) ; liststr(pos+2:end,:)];
                     end

                     data{1} = meta;
                     set(uih.cmdEval,'UserData',data)
                     set(uih.cmdCancel,'UserData',min(pos,size(meta,1))+1)

                     ui_editmetadata('refresh')

                  end

               case 'sort'  %sort metadata by category, field

                  [tmp,I] = sort(meta(:,2));
                  [tmp,I2] = sort(meta(I,1));
                  I = I(I2);

                  data{1} = meta(I,:);
                  set(uih.cmdEval,'UserData',data)
                  set(uih.cmdCancel,'UserData',find(I == Isel-1)+1)

                  liststr = get(uih.list,'String');

                  if Isel > 1
                     listval = max(1,min(find(I == Isel-1)+1,size(liststr,1)));
                     if isempty(listval)
                        listval = 1;
                     end
                  else
                     listval = 1;
                  end

                  set(uih.list,'String',liststr([1;I+1],:),'Value',listval)

                  drawnow

               case 'eval'  %return metadata to calling function

                  err = 0;

                  if ~isempty(meta)

                     teststr = cellstr([char(meta(:,1)),char(meta(:,2))]);
                     rowdiffs = size(meta,1) - length(unique(teststr));

                     if rowdiffs == 0  %test for duplicated cat/field
                        delete(h_dlg)
                        drawnow
                        if ~isempty(h)
                           try
                              set(h,'UserData',meta)
                           catch
                              err = 1;
                           end
                        end
                        if ~isempty(cb)
                           if err == 0
                              try
                                 eval(cb);
                              catch
                                 err = 1;
                              end
                           end
                        end
                        if err == 1
                           messagebox('init', ...
                              'Errors occurred saving the metadata', ...
                              '', ...
                              'Warning', ...
                              [.9 .9 .9]);
                        end
                     else  %duplicated fields
                        if rowdiffs > 1
                           confirmdlg('init',[{[int2str(rowdiffs),' Category/Field combinations are duplicated --']}; ...
                                 {'Concatenate contents? (press cancel to edit manually)'}],'ui_editmetadata(''evalconcat'')');
                        else
                           confirmdlg('init',[{'1 Category/Field combination is duplicated --'}; ...
                                 {'Concatenate contents? (press cancel to edit manually)'}],'ui_editmetadata(''evalconcat'')');
                        end
                     end
                  end

               case 'evalconcat'

                  teststr = cellstr([char(meta(:,1)),char(meta(:,2))]);
                  flds = unique(teststr);

                  for n = 1:length(flds)
                     I = find(strcmp(teststr,flds{n}));
                     if length(I) > 1
                        str = meta{I(1),3};
                        for m = 2:length(I)
                           str = [str,'|',meta{I(m),3}];  %concatenate
                           meta(I(m),1:3) = [{''},{''},{''}];  %clear contents
                        end
                        meta{I(1),3} = str;  %store concatenated results
                     end
                  end

                  I = ~cellfun('isempty',meta(:,1));
                  meta = meta(I,:);

                  close(h_dlg)
                  drawnow

                  err = 0;
                  if ~isempty(h)
                     try
                        h_fig = parent_figure(h);
                        if ~isempty(h_fig)
                           figure(h_fig)
                           set(h,'UserData',meta)
                           if ~isempty(cb)
                              if err == 0
                                 try
                                    eval(cb)
                                 catch
                                    err = 1;
                                 end
                              end
                           end
                        end
                     catch
                        err = 1;
                     end
                  end
                  if err == 1
                     messagebox('init', ...
                        'Errors occurred saving the metadata - operation cancelled', ...
                        '', ...
                        'Warning', ...
                        [.9 .9 .9]);
                  end

               case 'combine'  %concatenate contents of fields with identical cats/fieldnames

                  meta(:,1) = deblank(meta(:,1));
                  meta(:,2) = deblank(meta(:,2));
                  teststr = concatcellcols([meta(:,1),meta(:,2)],'_');
                  flds = unique(teststr);

                  if length(flds) ~= size(meta,1)  %check for something to do

                     Ikeep = ones(size(meta,1),1);  %init master index for records to keep
                     for n = 1:length(flds)
                        Imatch = find(strcmp(teststr,flds{n}));
                        if length(Imatch) > 1
                           str = meta{Imatch(1),3};
                           for m = 2:length(Imatch)
                              str2 = meta{Imatch(m),3};
                              if ~isempty(str2)
                                 str = [str,'|',str2];  %concatenate
                              end
                              Ikeep(Imatch(m)) = 0;  %remove record from master index to clear contents
                           end
                           meta{Imatch(1),3} = str;  %store concatenated results
                        end
                     end

                     meta = meta(find(Ikeep),:);  %apply master index

                     data{1} = meta;
                     set(uih.cmdEval,'UserData',data)
                     set(uih.cmdCancel,'UserData',1)
                     ui_editmetadata('refresh')

                  end

               case 'cat'  %process category edits

                  str = deblank(get(uih.editCat,'String'));

                  if ~isempty(str)
                     if strcmp(str,meta{Isel-1,1}) ~= 1
                        meta{Isel-1,1} = str;
                        data{1} = meta;
                        set(uih.cmdEval,'UserData',data)
                        set(uih.cmdCancel,'UserData',Isel)
                        ui_editmetadata('refresh')
                     end
                  else
                     set(uih.editCat,'String',meta{Isel-1,1})
                     messagebox('init', ...
                        'Category cannot be blank - previous value restored', ...
                        '', ...
                        'Error', ...
                        [.9 .9 .9])
                  end

               case 'field'  %process field edits

                  str = deblank(get(uih.editField,'String'));

                  if ~isempty(str)
                     if strcmp(str,meta{Isel-1,2}) ~= 1
                        meta{Isel-1,2} = str;
                        data{1} = meta;
                        set(uih.cmdEval,'UserData',data)
                        set(uih.cmdCancel,'UserData',Isel)
                        ui_editmetadata('refresh')
                     end
                  else
                     set(uih.editField,'String',meta{Isel-1,2})
                     messagebox('init', ...
                        'Fieldname cannot be blank - previous value restored', ...
                        '', ...
                        'Error', ...
                        [.9 .9 .9])
                  end

               case 'contents'  %process content edits

                  pos = Isel-1;

                  if pos > 0

                     str = get(uih.editContents,'String');

                     if size(str,1) > 1
                        tmp = str;
                        str = '';
                        for n = 1:size(tmp,1)
                           newstr = deblank(tmp(n,:));
                           if ~isempty(newstr)
                              str = [str,newstr,' '];
                           end
                        end
                     end
                     str = strrep(deblank(str),' |','|');

                     if sum(size(str)==1) == 2  %check for single pipe entry, strip
                        if strcmp(str,'|')
                           str = '';
                        end
                     end

                     if strcmp(str,meta{Isel-1,3}) ~= 1
                        meta{Isel-1,3} = str;
                        data{1} = meta;
                        set(uih.cmdEval,'UserData',data)
                        set(uih.cmdCancel,'UserData',Isel)
                        ui_editmetadata('refresh')
                     else
                        set(uih.editContents,'String',str)  %update editbox contents to reflect re-alignments
                     end

                  else
                     ui_editmetadata('display')
                     ui_editmetadata('controls')
                  end

               case 'clear'  %clear metadata field contents

                  set(uih.editContents,'String','')
                  meta{Isel-1,3} = '';
                  data{1} = meta;
                  set(uih.cmdEval,'UserData',data)
                  set(uih.cmdCancel,'UserData',Isel)
                  ui_editmetadata('refresh')

                  drawnow

               case 'preview'  %generate formatted preview text

                  str = get(uih.editContents,'String');

                  if ~isempty(str)

                     if size(str,1) > 1
                        tmp = str;
                        str = '';
                        for n = 1:size(tmp,1)
                           str = [str,deblank(tmp(n,:)),' '];
                        end
                     end
                     str = deblank(str);

                     str2 = [];
                     rem = str;
                     while ~isempty(rem)
                        [str,rem] = strtok(rem,'|');
                        if ~isempty(str)
                           str2 = [str2 ; {str}];
                        end
                     end

                     if size(str2,1) > 1
                        indent = 3;
                     else
                        indent = 0;
                     end

                     ui_viewtext(str2,80,indent,'Metadata Field Preview',[600 500],'Courier New');

                  end

               case 'export'  %export metadata to file

                  if ~isempty(meta)

                     %concatenate duplicated fields
                     teststr = cellstr([char(meta(:,1)),char(meta(:,2))]);
                     flds = unique(teststr);

                     if length(flds) ~= size(meta,1)  %check for something to do

                        for n = 1:length(flds)
                           I = find(strcmp(teststr,flds{n}));
                           if length(I) > 1
                              str = meta{I(1),3};
                              for m = 2:length(I)
                                 str = [str,'|',meta{I(m),3}];  %concatenate
                                 meta(I(m),1:3) = [{''},{''},{''}];  %clear contents
                              end
                              meta{I(1),3} = str;  %store concatenated results
                           end
                        end

                        I = ~cellfun('isempty',meta(:,1));
                        meta = meta(I,:);

                     end

                     [fn,pn] = uiputfile('*.mat;*.MAT','Select a filename and location for the exported metadata');

                     if ischar(fn) && isdir(pn)
                        pn = clean_path(pn);
                        save([pn,filesep,fn],'meta')
                     elseif fn ~= 0
                        messagebox('init','Invalid pathname specified','','Error',[.9 .9 .9])
                     end

                  end

            end

         end

      end

   end

end