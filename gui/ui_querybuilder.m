function ui_querybuilder(op,val,h_cb,str_cb,qrystr)
%GUI dialog for building row restriction queries to subselect data from a GCE Data Structure
%
%syntax: ui_querybuilder(op,val)
%
%input:
%  op = operation ('init' to initialize dialog)
%  s = data structure
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
%last modified: 16-Jan-2015

%check for no input argument - default to 'init' to create dialog
if nargin == 0
   op = 'init';
   val = [];
elseif isstruct(op)
   val = op;
   op = 'init';
end

if strcmp(op,'init')  %build gui
   
   %set defaults for missing input
   if exist('h_cb','var') ~= 1
      h_cb = [];
   end
   
   if exist('str_cb','var') ~= 1
      str_cb = '';
   end
   
   if exist('qrystr','var') ~= 1
      qrystr = '';
   end
   
   %set appropriate dialog title, button name depending on caller mode
   if ~isempty(h_cb) && ~isempty(str_cb)
      vis_closedlg = 'off';
      str_title = 'Data Restriction Query Builder';
      str_eval = 'Accept';
   else
      vis_closedlg = 'on';
      str_title = 'Query Builder';
      str_eval = 'Evaluate';
   end
   
   %check for valid data structure input
   msg = '';
   if isempty(val)
      msg = 'Insufficient arguments for function';
   elseif gce_valid(val,'data') ~= 1
      msg = 'Invalid GCE Data Structure';
   else
      s = val;
   end
   
   if isempty(msg)  %build GUI
      
      numcols = length(s.name);
      strVars = cell(numcols,1);
      for n = 1:numcols
         strVars{n} = [s.name{n},'  (',s.units{n},')'];
      end
      
      res = get(0,'ScreenSize');
      figpos = [max(0,res(3)./2-450) max(50,res(4)./2-180) 900 370];
      
      %set gui constants
      bgcolor = [.95 .95 .95];
      numslots = 30;
      rowbottom = 315;
      rowht = 25;
      numrows = 10;
      
      %init value array
      slotvals = cell(numslots,5);
      
      %initialize form figure
      h_dlg = figure('Visible','off', ...
         'Units','pixels', ...
         'Position',figpos, ...
         'Color',bgcolor, ...
         'Name',str_title, ...
         'KeyPressFcn','figure(gcf)', ...
         'MenuBar','none', ...
         'NumberTitle','off', ...
         'Tag','dlgQueryBuilder', ...
         'ToolBar','none', ...
         'Resize','off', ...
         'DefaultuicontrolUnits','pixels', ...
         'CloseRequestFcn','ui_querybuilder(''close'')');
      
      if mlversion >= 7
         set(h_dlg,'WindowStyle','normal')
         set(h_dlg,'DockControls','off')
      end
      
      %define ui controls
      uicontrol('Parent',h_dlg, ...
         'Style','frame', ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',bgcolor, ...
         'Position',[1 1 figpos(3) figpos(4)]);
      
      uicontrol('Parent',h_dlg, ...
         'Units','pixels', ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[.9 .9 .9], ...
         'Position',[240 85 650 258], ...
         'Style','frame', ...
         'Tag','txtFrame');
      
      h_listVars = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',10, ...
         'Position',[12 117 220 225], ...
         'String',strVars, ...
         'Style','listbox', ...
         'Tag','listVars', ...
         'Value',1, ...
         'Callback','ui_querybuilder(''select'')', ...
         'UserData',s);
      
      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'Position',[12 344 220 18], ...
         'String','Data Structure Columns', ...
         'Style','text', ...
         'Tag','txtVars');
      
      h_cmdCopy = uicontrol('Parent',h_dlg, ...
         'Style','pushbutton', ...
         'FontSize',9, ...
         'ListboxTop',0, ...
         'Position',[12 86 220 25], ...
         'String','Copy Column to Query Builder >>', ...
         'Callback','ui_querybuilder(''copy'')', ...
         'Tag','cmdCopy');
      
      h_slider = uicontrol('Parent',h_dlg, ...
         'Style','slider', ...
         'Position',[868 90 18 246], ...
         'Enable','off', ...
         'Value',numslots, ...
         'Max',numslots, ...
         'Min',numslots-1, ...
         'Sliderstep',[1 numslots], ...
         'Callback','ui_querybuilder(''scroll'')', ...
         'Tag','slider', ...
         'UserData',0);
      
      uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'HorizontalAlignment','center', ...
         'FontSize',10, ...
         'Position',[10 52 100 18], ...
         'String','Match Option:', ...
         'Style','text', ...
         'Tag','txtSep');
      
      h_popSep = uicontrol('Parent',h_dlg, ...
         'Style','popupmenu', ...
         'Position',[110 52 60 20], ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',9, ...
         'String',['ALL';'ANY'], ...
         'Value',1, ...
         'Callback','ui_querybuilder(''parse'')', ...
         'Tag','popSep');
      
      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[180 52 45 18], ...
         'FontSize',10, ...
         'HorizontalAlignment','left', ...
         'BackgroundColor',bgcolor, ...
         'ForegroundColor',[0 0 0], ...
         'String','Query:', ...
         'Tag','txtParse');
      
      h_editQuery = uicontrol('Parent',h_dlg, ...
         'Style','edit', ...
         'Enable','inactive', ...
         'Position',[225 51 610 20], ...
         'FontSize',9, ...
         'HorizontalAlignment','left', ...
         'BackgroundColor',[1 1 1], ...
         'ForegroundColor',[0 0 0], ...
         'String',qrystr, ...
         'Tag','editQuery');
      
      h_cmdEdit = uicontrol('Parent',h_dlg, ...
         'Style','togglebutton', ...
         'Value',0, ...
         'BackgroundColor',[.8 .8 .8], ...
         'FontSize',10, ...
         'Position',[841 51 50 22], ...
         'String','Edit', ...
         'TooltipString','Toggles manual query editing mode on and off', ...
         'Callback','ui_querybuilder(''edit'')', ...
         'Tag','cmdEdit');
      
      uicontrol('Parent',h_dlg, ...
         'FontSize',10, ...
         'Position',[10 10 60 25], ...
         'String','Cancel', ...
         'Callback','ui_querybuilder(''close'')', ...
         'TooltipString','Cancel the query and close the query builder window', ...
         'Tag','cmdClose');
      
      h_chkClose = uicontrol('Parent',h_dlg, ...
         'Style','checkbox', ...
         'Position',[295 10 300 20], ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'String','Close dialog after exporting structure to editor', ...
         'Visible',vis_closedlg, ...
         'Enable',vis_closedlg, ...
         'Value',1, ...
         'Tag','chkClose');
      
      h_cmdParse = uicontrol('Parent',h_dlg, ...
         'FontSize',10, ...
         'Position',[755 10 60 25], ...
         'String','Parse', ...
         'TooltipString','Generate a query string based on the query builder selections', ...
         'Callback','ui_querybuilder(''parse'')', ...
         'Tag','cmdParse');
      
      h_cmdEval = uicontrol('Parent',h_dlg, ...
         'FontSize',10, ...
         'Position',[825 10 65 25], ...
         'String',str_eval, ...
         'Callback','ui_querybuilder(''eval'')', ...
         'UserData',slotvals, ...
         'TooltipString','Evaluate query and generate new data structure', ...
         'Tag','cmdEval');
      
      %init handle arrays for query rows
      h_cmdClr = zeros(numrows,1);
      h_editVar = h_cmdClr;
      h_popEq = h_cmdClr;
      h_editVal = h_cmdClr;
      h_cmdPick = h_cmdClr;
      
      %generate repeating form fields
      for n = 1:numrows
         
         %set position vars
         rowstr = int2str(n);
         rowbot = rowbottom - (rowht * (n-1));
         
         %add clear button
         h = uicontrol('Parent',h_dlg, ...
            'Style','pushbutton', ...
            'Position',[245 rowbot 42 22], ...
            'FontSize',10, ...
            'String','Clear', ...
            'Callback',['ui_querybuilder(''clear'',',rowstr,')'], ...
            'Enable','off', ...
            'Tag',['cmdClr',rowstr]);
         
         h_cmdClr(n) = h;
         
         %add variable field
         h = uicontrol('Parent',h_dlg, ...
            'Style','edit', ...
            'Position',[290 rowbot 170 23], ...
            'BackgroundColor',[1 1 1], ...
            'FontSize',10, ...
            'HorizontalAlignment','left', ...
            'String','', ...
            'Enable','off', ...
            'Tag',['editVar',rowstr]);
         
         h_editVar(n) = h;
         
         %add comparison popup
         h = uicontrol('Parent',h_dlg, ...
            'Style','popupmenu', ...
            'Position',[464 rowbot+3 120 20], ...
            'BackgroundColor',[1 1 1], ...
            'FontSize',10, ...
            'String',' ', ...
            'Tag',['popEq',rowstr], ...
            'Callback','ui_querybuilder(''update'')', ...
            'Enable','off', ...
            'Value',1);
         
         h_popEq(n) = h;
         
         %add value field
         h = uicontrol('Parent',h_dlg, ...
            'Style','edit', ...
            'BackgroundColor',[1 1 1], ...
            'FontSize',10, ...
            'HorizontalAlignment','left', ...
            'Position',[587 rowbot 230 23], ...
            'String','', ...
            'Enable','off', ...
            'Callback','ui_querybuilder(''validate'')', ...
            'Tag',['editVal',rowstr]);
         
         h_editVal(n) = h;
         
         %add pick button
         h = uicontrol('Parent',h_dlg, ...
            'Style','pushbutton', ...
            'Position',[823 rowbot 40 22], ...
            'FontSize',10, ...
            'String','Pick', ...
            'Callback',['ui_querybuilder(''pick'',',rowstr,')'], ...
            'Enable','off', ...
            'TooltipString','Choose criteria from a list', ...
            'Tag',['cmdPick',rowstr]);
         
         h_cmdPick(n) = h;
         
      end
      
      %create structure for caching GUI state data
      uih = struct('h_listVars',h_listVars, ...
         'h_popSep',h_popSep, ...
         'h_editQuery',h_editQuery, ...
         'h_cmdEdit',h_cmdEdit, ...
         'h_cmdCopy',h_cmdCopy, ...
         'h_cmdParse',h_cmdParse, ...
         'h_cmdEval',h_cmdEval, ...
         'h_slider',h_slider, ...
         'h_cmdClr',h_cmdClr, ...
         'h_editVar',h_editVar, ...
         'h_popEq',h_popEq, ...
         'h_editVal',h_editVal, ...
         'h_cmdPick',h_cmdPick, ...
         'h_chkClose',h_chkClose, ...
         'h_cb',h_cb, ...
         'str_cb',str_cb);
      
      %store uih in figure userdata and display dialog
      set(h_dlg, ...
         'UserData',uih, ...
         'Visible','on');
      
      if ~isempty(qrystr)
         ui_querybuilder('unparse')
      else
         drawnow
      end
      
   else
      messagebox('init',msg,[],'Error',[.9 .9 .9])
   end
   
elseif strcmp(op,'close')  %catch close first
   
   delete(gcf)
   drawnow
   ui_aboutgce('reopen')  %check for last window
   
else  %evaluate other callbacks
   
   %get dialog handle
   h_dlg = [];
   if length(findobj) > 1
      if strcmp(get(gcf,'Tag'),'dlgQueryBuilder') == 1
         h_dlg = gcf;
         uih = get(h_dlg,'UserData');
      else
         op = 'null';
      end
   else
      op = 'null';
   end
   
   %check for valid dialog figure
   if ~isempty(h_dlg)
      
      %set runtime variables
      offset = get(uih.h_slider,'Userdata'); %get scroll offset
      vals = get(uih.h_cmdEval,'UserData');  %get slot value array
      s = get(uih.h_listVars,'UserData');    %get data structure
      
      switch op
         
         case 'scroll'  %handle scroll events
            
            %calculate offset
            offset = size(vals,1)-round(get(uih.h_slider,'Value'));
            
            %update controls
            if offset ~= get(uih.h_slider,'UserData')
               set(uih.h_slider,'Userdata',offset)
               ui_querybuilder('refresh')
            end
            
         case 'parse'  %parse criteria to generate string to evaluate
            
            %check edit toggle button state
            if get(uih.h_cmdEdit,'Value') == 0
               
               %init query string
               qstr = '';
               
               %get separator setting
               sepval = get(uih.h_popSep,'Value');
               if sepval == 1
                  sepstr = ' & ';
               else
                  sepstr = ' | ';
               end
               
               %loop through fields
               for n = 1:size(vals,1)
                  
                  indx = vals{n,1};  %get position index
                  
                  if ~isempty(indx)
                     
                     %get field settings
                     var = s.name{indx};
                     fncdata = vals{n,5};
                     fnc = fncdata{vals{n,2}};
                     val = vals{n,3};
                     
                     %check for non-empty value
                     if ~isempty(val)
                        
                        %check for function type
                        if inlist(fnc,{'strcmp','~strcmp','inlist','~inlist','contains','~contains'})
                           %string functions
                           if ~strcmpi(val,'NaN') && ~strcmpi(val,'null')
                              qstr = [qstr,[fnc,'(',var,',''',val,''')',sepstr]];
                           elseif inlist(fnc,{'strcmp','inlist','contains'})
                              qstr = [qstr,'isnull(',var,')',sepstr];
                           else
                              qstr = [qstr,'~isnull(',var,')',sepstr];
                           end
                        elseif inlist(fnc,{'inarray','~inarray'})  %numeric arrays
                           qstr = [qstr,[fnc,'(',var,',[',val,'])',sepstr]];
                        elseif strcmp(val,'NaN') || isempty(val)  %catch empty string/NaN criteria
                           if strcmp(fnc,'==')
                              qstr = [qstr,'isnull(',var,')',sepstr];
                           else
                              qstr = [qstr,'~isnull(',var,')',sepstr];
                           end
                        else  %numeric comparison
                           qstr = [qstr,[var,fnc,val],sepstr];
                        end
                     end
                  else
                     break
                  end
               end
               
               %strip last ampersand if query string not empty
               if ~isempty(qstr)
                  qstr = qstr(1:end-3);
               end
               
               %update query string
               set(uih.h_editQuery,'String',qstr)
               drawnow
               
            end
            
         case 'unparse'  %attempt to split query string and populate fields
            
            %get query string
            qstr = deblank(get(uih.h_editQuery,'String'));
            
            if ~isempty(qstr)
               
               %get indices of ampersands and pipes
               Iamp = strfind(qstr,'&');
               Ipipe = strfind(qstr,'|');
               
               %check for unsupported mixed connector syntax
               if isempty(Iamp) || isempty(Ipipe)
                  
                  %qstr = strrep(qstr,' ','');
                  if ~isempty(Iamp)
                     ar = splitstr(qstr,'&');
                     connector = '&';
                  elseif ~isempty(Ipipe)
                     ar = splitstr(qstr,'|');
                     connector = '|';
                  else  %single term
                     ar = {qstr};
                     connector = '';
                  end
                  
                  %init array for query terms
                  ar_qry = cell(length(ar),3);
                  
                  %loop through query statements
                  for n = 1:length(ar)
                     
                     str = ar{n};  %get query expression
                     
                     %check for standard string comparison first
                     if strncmpi(str,'strcmp',6) || strncmpi(str,'~strcmp',7) || strncmpi(str,'inlist',6) || ...
                           strncmpi(str,'~inlist',7) || strncmpi(str,'contains',8) || strncmpi(str,'~contains',9) || ...
                           strncmpi(str,'inarray',7) || strncmpi(str,'~inarray',8)
                        
                        op = lower(deblank(strtok(str,'(')));  %parse comparison operation
                        
                        %re-check for supported function after parsing operator
                        if inlist(op,{'strcmp','~strcmp','inlist','~inlist','contains','~contains','inarray','~inarray'})
                           Istart = strfind(str,'(');
                           Iend = strfind(str,')');
                           if ~isempty(Istart) && ~isempty(Iend)
                              if Iend(1) > Istart(1)
                                 [fld,val] = strtok(str(Istart(1)+1:Iend(1)-1),',');
                                 if ~isempty(val)
                                    val = strrep(strrep(strrep(val(2:end),'''',''),'[',''),']','');  %remove quotes/brackets
                                    ar_qry(n,1:3) = [fld,{op},val];
                                 end
                              end
                           end
                        end
                        
                     elseif strncmpi(str,'isnull',6) || strncmpi(str,'~isnull',7)
                        
                        op = lower(deblank(strtok(str,'(')));  %parse comparison operation
                        
                        %re-check for supported function after parsing operator
                        if inlist(op,{'isnull','~isnull'})
                           Istart = strfind(str,'(');
                           Iend = strfind(str,')');
                           if ~isempty(Istart) && ~isempty(Iend)
                              fld = str(Istart+1:Iend-1);
                              dtype = get_type(s,'datatype',fld);
                              if strcmp(dtype,'s')
                                 if strcmpi(op,'isnull')
                                    op = 'strcmp';
                                 else
                                    op = '~strcmp';
                                 end
                                 val = 'null';
                              else
                                 if strcmpi(op,'isnull')
                                    op = '==';
                                 else
                                    op = '~=';
                                 end
                                 val = 'NaN';
                              end
                              ar_qry(n,1:3) = [fld,{op},{val}];
                           end
                        end
                        
                     else %check for numeric comparison term
                        
                        equaldata = [{'<='},{'>='},{'~='},{'=='},{'<'},{'>'}];
                        for m = 1:length(equaldata)
                           if ~isempty(strfind(str,equaldata{m}))
                              op = equaldata{m};
                              break
                           end
                        end
                        if ~isempty(op)
                           str = strrep(str,op,',');
                           ar_tmp = splitstr(str,',');
                           if length(ar_tmp) == 2
                              ar_qry(n,1:3) = [ar_tmp(1),{op},ar_tmp(2)];
                           end
                        end
                        
                     end
                     
                  end
                  
                  %get index of null terms
                  Inull = find(cellfun('isempty',ar_qry(:,1)));
                  
                  %check for unsupported terms
                  if isempty(Inull)
                     vals = cell(30,5);
                     cols = s.name;
                     cnt = 0;
                     for n = 1:size(ar_qry,1)
                        Imatch = find(strcmp(cols,ar_qry{n,1}));
                        if ~isempty(Imatch)
                           cnt = cnt + 1;
                           [equalstr,equaldata] = subfun_popupvals(s.datatype{Imatch});
                           Iequal = find(strcmp(equaldata,ar_qry{n,2}));
                           vals{cnt,1} = Imatch;
                           vals{cnt,2} = Iequal;
                           vals{cnt,3} = ar_qry{n,3};
                           vals{cnt,4} = equalstr;
                           vals{cnt,5} = equaldata;
                        end
                     end
                     if cnt > 0
                        if strcmp(connector,'|')
                           set(uih.h_popSep,'Value',2)
                        else
                           set(uih.h_popSep,'Value',1)  %note: defaults to AND if no connector/single term
                        end
                        set(uih.h_cmdEval,'UserData',vals)
                        ui_querybuilder('refresh')
                        set(uih.h_cmdEdit,'Value',0)
                        ui_querybuilder('edit')
                        ui_querybuilder('parse')
                     else
                        set(uih.h_cmdEdit,'Value',1)
                        ui_querybuilder('edit')
                     end
                  else
                     set(uih.h_cmdEdit,'Value',1)
                     ui_querybuilder('edit')
                  end
                  
               else
                  set(uih.h_cmdEdit,'Value',1)
                  ui_querybuilder('edit')
               end
            end
            
         case 'eval'  %evaluate query
            
            editmode = get(uih.h_cmdEdit,'Value');
            if editmode == 0  %auto mode - refresh query
               ui_querybuilder('parse');
            end
            
            qstr = get(uih.h_editQuery,'String');
            
            if ~isempty(qstr)
               
               if isempty(uih.h_cb) || isempty(uih.str_cb)
                  
                  s2 = querydata(s,qstr);   %perform query
                  
                  if isempty(s2)
                     messagebox('init', ...
                        'The specified query returned no data rows - try broader criteria', ...
                        '', ...
                        'Warning',[.9 .9 .9])
                  else
                     closeval = get(uih.h_chkClose,'Value');
                     if closeval == 1
                        close(h_dlg)
                        drawnow
                     end
                     ui_editor('init',s2);
                  end
                  
               else
                  
                  close(h_dlg)
                  drawnow
                  
                  if ~isempty(uih.h_cb)
                     h_parent = parent_figure(uih.h_cb);
                     if ~isempty(h_parent)
                        figure(h_parent)
                        set(uih.h_cb,'UserData',qstr)
                     end
                  end
                  if ~isempty(uih.str_cb)
                     err = 0;
                     try
                        eval(uih.str_cb)
                     catch
                        err = 1;
                     end
                     if err == 1
                        messagebox('init','Errors occurred returning the query to the original window','','Error',[.9 .9 .9])
                     end
                  else
                     messagebox('init','Data restriction query could not be returned to the original window','','Error',[.9 .9 .9])
                  end
                  
               end
               
            else
               messagebox('init', ...
                  '  No value criteria were assigned  ', ...
                  '', ...
                  'Warning', ...
                  [.9 .9 .9])
            end
            
         case 'edit'  %evaluate manual edit toggle button
            
            editmode = get(uih.h_cmdEdit,'Value');
            
            if editmode == 1
               set(uih.h_cmdEdit,'Value',1,'BackgroundColor',[0 1 0])
               set(uih.h_editQuery,'Enable','on')
               set(uih.h_cmdParse,'Enable','off')
               set(uih.h_popSep,'Enable','off')
               if isempty(get(uih.h_editQuery,'String'))  %parse query if not already done
                  ui_querybuilder('parse');
               end
            else
               set(uih.h_cmdEdit,'Value',0,'BackgroundColor',[.8 .8 .8])
               set(uih.h_editQuery,'Enable','inactive')
               set(uih.h_cmdParse,'Enable','on')
               set(uih.h_popSep,'Enable','on')
            end
            
         case 'refresh'  %refresh slot values based on cached data
            
            %loop through slots refreshing contents
            for n = 1:10
               rownum = n + offset;
               if ~isempty(vals{rownum,1})
                  set(uih.h_cmdClr(n),'Enable','on')
                  set(uih.h_editVar(n), ...
                     'String',s.name{vals{rownum,1}}, ...
                     'Enable','inactive')
                  set(uih.h_popEq(n), ...
                     'Enable','on', ...
                     'String',vals{rownum,4}, ...
                     'UserData',vals{rownum,5}, ...
                     'Value',vals{rownum,2})
                  set(uih.h_editVal(n), ...
                     'Enable','on', ...
                     'String',vals{rownum,3})
                  set(uih.h_cmdPick(n),'Enable','on')
               else
                  set(uih.h_cmdClr(n),'Enable','off')
                  set(uih.h_editVar(n), ...
                     'String','', ...
                     'Enable','off')
                  set(uih.h_popEq(n), ...
                     'Enable','off', ...
                     'String',' ', ...
                     'UserData',[], ...
                     'Value',1)
                  set(uih.h_editVal(n), ...
                     'Enable','off', ...
                     'String','')
                  set(uih.h_cmdPick(n),'Enable','off')
               end
            end
            
            drawnow
            
         case 'pick'  %open pick list for choosing criteria
            
            %get slot info and look up column
            rownum = val;
            rowstr = int2str(rownum);
            col = get(findobj(gcf,'Tag',['editVar',rowstr]),'String');
            
            %get equality function, adjusting row position for offset when scrolling
            fncdata = vals{rownum+offset,5};
            fnc = fncdata{vals{rownum+offset,2}};
            
            %extract column values
            colnum = name2col(s,col);
            data = extract(s,colnum);
            
            %generate pick list values
            if iscell(data)  %text column
               
               listvals = unique(data);  %get all unique values
               Ivalid = ~cellfun('isempty',listvals);
               listvals = listvals(Ivalid); %filter to remove empty values
               
            else  %numeric
               
               %remove NaNs
               data = data(~isnan(data));
               
               %check for valid values
               if ~isempty(data)
                  
                  %look up data type, variable type
                  dtype = get_type(s,'datatype',colnum);
                  vtype = get_type(s,'variabletype',colnum);
                  
                  %check for data/calc column
                  if strcmp(vtype,'data') || strcmp(vtype,'calculation')
                     
                     %get basic stats
                     minval = min(data);
                     maxval = max(data);
                     meanval = mean(data);
                     medianval = median(data);
                     
                     %generate appropriate labels, stats
                     if strcmp(dtype,'d')  %integer
                        
                        lbls = {'minimum:','median:','maximum:'}';
                        nums = [minval,medianval,maxval]';
                        numstr = strjust(num2str(nums),'left');
                        
                     else  %floating-point or exponential
                        
                        %calculate dispersion stats
                        sdval = std(data);
                        sdlow = mean(data) - sdval;
                        sdlow2 = mean(data) - 2 *sdval;
                        sdhigh = mean(data) + sdval;
                        sdhigh2 = mean(data) + 2 * sdval;
                        
                        lbls = {'minimum:','mean-2sd:','mean-1sd:','mean:','median:', ...
                           'mean+1sd:','mean+2sd:','maximum:'}';
                        nums = [minval,sdlow2,sdlow,meanval,medianval,sdhigh,sdhigh2,maxval]';
                        numstr = strjust(num2str(nums),'left');
                        
                     end
                     
                  else  %non-data column
                     
                     %check for integer - list all values
                     if ~isempty(strfind(fnc,'inarray'))
                        
                        lbls = '';
                        nums = unique(data);
                        numstr = num2str(nums(~isnan(nums)));
                        
                     else
                        
                        %get basic metrics
                        minval = min(data);
                        maxval = max(data);
                        medianval = median(data);
                        
                        %generate labels
                        lbls = {'minimum:','median:','maximum:'}';
                        nums = [minval,medianval,maxval]';
                        numstr = strjust(num2str(nums),'left');
                        
                     end
                     
                  end
                  
                  %generate cell array for listbox display
                  if ~isempty(lbls)
                     listvals = cellstr([char(lbls),repmat('  ',size(lbls,1),1),numstr]);
                  else
                     listvals = cellstr(numstr);
                  end
                  
               else
                  listvals = [];
               end
               
            end
            
            if ~isempty(listvals)
               
               %check for text column and list choice
               if ~isempty(strfind(fnc,'inlist')) || ~isempty(strfind(fnc,'inarray'))
                  selmode = 'multiple';
               else
                  selmode = 'single';
               end
               
               %generate list dialog with appropriate selectionmode setting
               Isel = listdialog('liststring',listvals, ...
                  'name','Select Value Criteria', ...
                  'promptstring','Select a value to use as the filter criteria', ...
                  'selectionmode',selmode, ...
                  'listsize',[0 0 300 400]);
               
               %generate field value from selection(s)
               if ~isempty(Isel)
                  
                  %check for list mode (multi-select)
                  if iscell(data) || length(Isel) > 1
                     if length(Isel) == 1
                        crit = listvals{Isel};
                     else
                        %concatenate multiple text terms to form comma-delimited list
                        crit = strrep(cell2commas(listvals(Isel),0),' ','');
                     end
                  else
                     ar = splitstr(listvals{Isel},':');
                     if length(ar) == 2
                        crit = ar{2};
                     else
                        crit = ar{1};
                     end
                  end
                  
                  h_val = findobj(gcf,'Tag',['editVal',rowstr]);
                  set(h_val,'String',crit)
                  ui_querybuilder('validate',h_val);
               end
               
            else
               messagebox('init','The selected column does not contain any non-empty values', ...
                  '','Error',[.9 .9 .9]);
            end
            
         case 'clear'  %clear indicated slot, adjust array
            
            rownum = val + offset;
            
            if rownum == size(vals,1)  %check for last row
               vals(rownum,:) = cell(1,5);
            elseif rownum == 1  %check for first row
               vals = [vals(2:end,:) ; cell(1,5)];
            else  %middle row
               vals = [vals(1:rownum-1,:) ; vals(rownum+1:end,:) ; cell(1,5)];
            end
            
            set(uih.h_cmdEval,'UserData',vals);  %update cached array
            
            Ifree = find(cellfun('isempty',vals(:,1)));  %get index of empty slots
            
            maxrows = size(vals,1);
            if ~isempty(Ifree)
               Ilast = Ifree(1)-1;
            else
               Ilast = maxrows;
            end
            
            if Ilast <= 10  %turn off scrolling
               set(uih.h_slider, ...
                  'Enable','off', ...
                  'Min',maxrows-1, ...
                  'SliderStep',[1 maxrows], ...
                  'Value',maxrows, ...
                  'UserData',0)
            else  %adjust scrollbar
               newmin = maxrows-Ilast+10;
               sliderval = get(uih.h_slider,'Value');
               if sliderval < newmin
                  newval = newmin;
               else
                  newval = sliderval;
               end
               if Ilast-rownum+1 < 10
                  offset = max(0,offset - 1);
               end
               set(uih.h_slider, ...
                  'Min',newmin, ...
                  'SliderStep',[1/(maxrows-newmin) 10/(maxrows-newmin)], ...
                  'Value',newval, ...
                  'UserData',offset)
            end
            
            ui_querybuilder('refresh')  %update slot states
            
            ui_querybuilder('parse')  %update parsed expression
            
         case 'validate'  %validate value entries
            
            %get source handle
            if exist('val','var') ~= 1
               h_cbo = gcbo;
            else
               h_cbo = val;
            end
            
            %get string
            str = deblank(get(h_cbo,'String'));
            
            %init error flag
            err = 0;
            
            if ~isempty(str)
               
               %get cached data and positions
               s = get(uih.h_listVars,'UserData');
               tag = get(h_cbo,'Tag');
               rowstr = tag(8:end);
               col = get(findobj(gcf,'Tag',['editVar',rowstr]),'String');
               colnum = name2col(s,col);
               
               %validate/convert value entries
               if ~isempty(colnum)
                  
                  %get attribute metadata
                  dtype = s.datatype{colnum};
                  vtype = s.variabletype{colnum};

                  %check for numeric column
                  if ~strcmp(dtype,'s')
                     
                     %check for dates
                     if strcmp(vtype,'datetime') && (~isempty(strfind(str,'/')) || ...
                           ~isempty(strfind(str,'-')) || ~isempty(strfind(str,':')))
                        
                        try
                           newstr = num2str(datenum(str),'%0.6f');
                        catch
                           newstr = '';
                        end
                        
                        if ~isempty(newstr)
                           set(h_cbo,'String',newstr)
                        else
                           err = 1;
                           set(h_cbo,'String','')
                           drawnow
                           messagebox('init','Unrecognized date format - value reset','','Error',[.9 .9 .9])
                        end
                        
                     else
                        
                        %validate number or expression
                        try
                           if ~isnan(str2double(str))
                              %preserve formatting of valid numbers
                              newstr = str;
                           else
                              %use str2num to catch expressions that evaluate to numeric
                              newstr = str2num(str);   %#ok<ST2NM>
                           end
                        catch
                           newstr = '';
                        end
                        
                        %check for valid string, update field
                        if ~isempty(newstr)
                           set(h_cbo,'String',newstr)                           
                        else
                           err = 1;
                           set(h_cbo,'String','')
                           drawnow
                           messagebox('init', ...
                              'Criteria must be a valid number or numerical expression', ...
                              '','Error',[.9 .9 .9])
                        end
                        
                     end
                     
                  end
                  
               end
               
               if err == 0
                  ui_querybuilder('update')  %update controls
               end
               
            end
            
         case 'update'  %update cached data after changes
            
            for n = 1:10
               var = get(uih.h_editVar(n),'String');
               if ~isempty(var)
                  eqval = get(uih.h_popEq(n),'Value');
                  valstr = get(uih.h_editVal(n),'String');
                  vals{n+offset,2} = eqval;
                  vals{n+offset,3} = valstr;
               else
                  break
               end
            end
            
            set(uih.h_cmdEval,'UserData',vals);  %update cached array
            
            ui_querybuilder('parse')
            
         case 'select'  %check for double click on select list
            
            if strcmp(get(gcf,'selectiontype'),'open')
               ui_querybuilder('copy');
            end
            
         case 'copy'  %copy selected data column to criteria list
            
            Ifree = find(cellfun('isempty',vals(:,1)));  %get index of empty slots
            
            if ~isempty(Ifree)  %check for free slots
               
               slot = Ifree(1)-offset;   %calculate next free slot
               
               indx = get(uih.h_listVars,'Value');   %get index of selected item
               
               [equalstr,equaldata] = subfun_popupvals(s.datatype{indx});
               vals(slot+offset,:) = [{indx},{1},{''},{equalstr},{equaldata}];
               set(uih.h_cmdEval,'UserData',vals)  %update cached data
               
               if slot <= 10  %fill slot fields directly
                  set(uih.h_cmdClr(slot),'Enable','on')
                  set(uih.h_editVar(slot),'String',s.name{indx},'Enable','inactive')
                  set(uih.h_popEq(slot),'String',equalstr,'UserData',equaldata,'Enable','on')
                  set(uih.h_editVal(slot),'Enable','on')
                  set(uih.h_cmdPick(slot),'Enable','on')
               else  %update scroll data, use refresh call to update fields
                  maxrow = size(vals,1);
                  newmin = maxrow-Ifree(1)+10;
                  set(uih.h_slider, ...
                     'Enable','on', ...
                     'Min',newmin, ...
                     'SliderStep',[1/(maxrow-newmin),10/(maxrow-newmin)], ...
                     'UserData',offset+1, ...
                     'Value',maxrow-(offset+1))
                  ui_querybuilder('refresh')
               end
               
            end
            
         otherwise
            
            %do nothing
            
      end
      
   end
   
end


%define subfunction to populate popup menus for equalities
function [equalstr,equaldata] = subfun_popupvals(str)

if strcmp(str,'s')
   equalstr = char('IS','IS NOT','CONTAINS','EXCLUDES','IN LIST','NOT IN LIST');
   equaldata = {'strcmp','~strcmp','contains','~contains','inlist','~inlist'};
else
   equalstr = char('=','<','<=','>','>=','~=','IN ARRAY','NOT IN ARRAY');
   equaldata = {'==','<','<=','>','>=','~=','inarray','~inarray'};
end