function ui_sortcolumns(op,val,h_cb,cb)
%GUI dialog for sorting data columns in a GCE Data Structure
%
%syntax: ui_sortcolumns(op,s)
%
%input:
%  op = operation ('init' to initialize dialog)
%  s = data structure
%
%output:
%  none
%
%(c)2002-2012 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 14-Nov-2012

%check for no arguments - default to 'init'
if nargin == 0
   op = 'init';
   val = [];
elseif isstruct(op)
   val = op;
   op = 'init';
end

if strcmp(op,'init')
   
   %get data structure from second argument
   s = val;
   
   %validate data structure
   if gce_valid(s,'data')
      
      if exist('h_cb','var') ~= 1
         h_cb = [];
      end
      
      if exist('cb','var') ~= 1
         cb = '';
      end
      
      %calculate data column metrics
      numcols = length(s.name);
      strVars = cell(numcols,1);
      indx = (1:numcols)';
      for n = 1:numcols
         strVars{n} = [s.name{n},'  (',s.units{n},')'];
      end
      
      %set screen dimensions of dialog
      res = get(0,'ScreenSize');
      figpos = [max(0,res(3)./2-320) max(50,res(4)./2-180) 640 360];
      
      %set gui constants
      bgcolor = [.95 .95 .95];
      rowbottom = 300;
      rowht = 28;
      numrows = 10;
      
      %initialize dialog figure
      h_dlg = figure('Visible','off', ...
         'Units','pixels', ...
         'Position',figpos, ...
         'Color',bgcolor, ...
         'Name','Sort Columns', ...
         'KeyPressFcn','figure(gcf)', ...
         'MenuBar','none', ...
         'NumberTitle','off', ...
         'Tag','dlgSortColumns', ...
         'ToolBar','none', ...
         'Resize','off', ...
         'DefaultuicontrolUnits','pixels');
      
      %disable dock controls on MATLAB 7+
      if mlversion >= 7
         set(h_dlg,'WindowStyle','normal')
         set(h_dlg,'DockControls','off')
      end
      
      %add uicontrols
      uicontrol('Parent',h_dlg, ...
         'Style','frame', ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',bgcolor, ...
         'Position',[1 1 figpos(3) figpos(4)]);
      
      h_listVars = uicontrol('Parent',h_dlg, ...
         'Style','listbox', ...
         'Position',[10 73 265 250], ...
         'BackgroundColor',[1 1 1], ...
         'FontSize',10, ...
         'String',strVars, ...
         'Tag','listVars', ...
         'Value',1, ...
         'Callback','ui_sortcolumns(''varlist'')');
      
      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[5 325 265 18], ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'String','Available Data Columns', ...
         'Tag','label');
      
      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[338 325 170 18], ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'String','Columns to Sort By', ...
         'Tag','label');
      
      uicontrol('Parent',h_dlg, ...
         'Style','text', ...
         'Position',[513 325 100 18], ...
         'BackgroundColor',bgcolor, ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'String','Sort Order', ...
         'Tag','label');
      
      h_cmdCopy = uicontrol('Parent',h_dlg, ...
         'Style','pushbutton', ...
         'Position',[5 45 270 25], ...
         'FontSize',10, ...
         'String','Copy Selected Column to Sort List >>', ...
         'Callback','ui_sortcolumns(''copy'')', ...
         'Tag','cmdCopy');
      
      uicontrol('Parent',h_dlg, ...
         'Style','pushbutton', ...
         'Position',[10 5 60 25], ...
         'FontSize',10, ...
         'String','Cancel', ...
         'Callback','ui_sortcolumns(''close'')', ...
         'TooltipString','Cancel query and close the query builder window', ...
         'Tag','cmdClose');
      
      h_chkClose = uicontrol('Parent',h_dlg, ...
         'Style','checkbox', ...
         'Position',[200 5 280 20], ...
         'BackgroundColor',bgcolor, ...
         'FontSize',9, ...
         'FontWeight','bold', ...
         'String','Close dialog after exporting structure to editor', ...
         'Value',1, ...
         'Tag','chkClose');
      
      h_cmdEval = uicontrol('Parent',h_dlg, ...
         'Style','pushbutton', ...
         'Position',[570 5 65 25], ...
         'FontSize',10, ...
         'String','Evaluate', ...
         'Enable','off', ...
         'Callback','ui_sortcolumns(''eval'')', ...
         'TooltipString','Evaluate query and generate new data structure', ...
         'Tag','cmdEval');
      
      %init handle arrays for query rows
      h_cmdClr = zeros(numrows,1);
      h_editVar = h_cmdClr;
      h_popOrder = h_cmdClr;
      
      %create control set for sorting column options
      for n = 1:numrows
         
         rowstr = int2str(n);
         
         h = uicontrol('Parent',h_dlg, ...
            'Style','pushbutton', ...
            'Position',[290 rowbottom-(rowht*(n-1)) 42 22], ...
            'FontSize',10, ...
            'String','Clear', ...
            'Callback',['ui_sortcolumns(''clear'',',rowstr,')'], ...
            'Enable','off', ...
            'Tag',['cmdClr',rowstr]);
         
         h_cmdClr(n) = h;
         
         h = uicontrol('Parent',h_dlg, ...
            'Style','edit', ...
            'Position',[338 rowbottom-(rowht*(n-1)) 170 22], ...
            'BackgroundColor',[1 1 1], ...
            'FontSize',10, ...
            'HorizontalAlignment','left', ...
            'String','', ...
            'Enable','off', ...
            'Tag',['editVar',rowstr]);
         
         h_editVar(n) = h;
         
         h = uicontrol('Parent',h_dlg, ...
            'Style','popupmenu', ...
            'Position',[513 rowbottom-(rowht*(n-1))+2 120 22], ...
            'BackgroundColor',[1 1 1], ...
            'FontSize',10, ...
            'String',{'Ascending';'Descending'}, ...
            'Tag',['popOrder',rowstr], ...
            'Enable','off', ...
            'Value',1);
         
         h_popOrder(n) = h;
         
      end
      
      %cache uicontrol handles and data structure
      uih = struct('listVars',h_listVars, ...
         'cmdCopy',h_cmdCopy, ...
         'cmdEval',h_cmdEval, ...
         'cmdClr',h_cmdClr, ...
         'editVar',h_editVar, ...
         'popOrder',h_popOrder, ...
         'chkClose',h_chkClose, ...
         'h_cb',h_cb, ...
         's',s, ...
         'cb',cb, ...
         'Ilist',[], ...
         'Isort',[]);
      
      %cache index afterwards to prevent multidimensional structure
      uih.Ilist = indx;
      
      set(h_dlg, ...
         'UserData',uih, ...
         'Visible','on');
      
      drawnow
      
   else
      messagebox('init','Invalid data structure','','Error',[0.95 0.95 0.95])
   end
   
else  %evaluate other callbacks
   
   h_dlg = [];
   if length(findobj) > 1
      if strcmp(get(gcf,'Tag'),'dlgSortColumns') == 1
         h_dlg = gcf;
         uih = get(h_dlg,'UserData');
      else
         op = '';
      end
   else
      op = '';
   end
   
   if ~isempty(h_dlg)
      
      %get cached data
      s = uih.s;
      Ilist = uih.Ilist;
      Isort = uih.Isort;
      
      %execute specified callback
      switch op
         
         case 'close'  %close dialog
            
            delete(h_dlg)
            drawnow
            ui_aboutgce('reopen')  %check for last window
   
         case 'eval'  %evaluate options and sort data
            
            %init sort arrays
            sortcols = zeros(1,length(Isort));
            sortord = sortcols;
            
            %generate order array from options
            for n = 1:length(Isort)
               sortcols(n) = Isort(n);
               orderval = get(uih.popOrder(n),'Value');
               if orderval == 1
                  sortord(n) = 1;
               else
                  sortord(n) = -1;
               end
            end
            
            %perform sort
            [data,msg] = sortdata(s,sortcols,sortord);
            
            %close dialog and return data
            if ~isempty(data)
               
               %get close window checkbox option
               closeval = get(uih.chkClose,'Value');
               
               if closeval == 1
                  close(h_dlg)
                  drawnow
               end
               
               %execute callback
               if isempty(uih.h_cb)
                  ui_editor('init',data);
               else
                  err = 0;
                  h_fig = parent_figure(uih.h_cb);
                  if ~isempty(h_fig)
                     figure(h_fig)
                     set(uih.h_cb,'userdata',data)
                     try
                        eval(uih.cb)
                     catch
                        err = 1;
                     end
                  else
                     err = 1;
                  end
                  if err == 1
                     ui_editor('init',data)
                     messagebox('init','Could not return structure to original editor window', ...
                        '','Warning',[.9 .9 .9]);
                  end
               end
               
            else
               
               messagebox('init', ...
                  ['Errors occurred sorting the structure (error: ',msg,')'], ...
                  '', ...
                  'Error', ...
                  [.9 .9 .9]);
               
            end
            
         case 'varlist'  %check for double click on variable list
            
            if strcmp(get(gcf,'selectiontype'),'open')
               ui_sortcolumns('copy')
            end
            
         case 'clear'  %clear indicated slot, adjust array
            
            %get input
            slot = val;
            indx = Isort(slot);
            Ilist = sort([Ilist ; indx]);
            
            %regenerate variable list strings
            numcols = length(Ilist);
            strVars = cell(numcols,1);
            for n = 1:numcols
               strVars{n} = [s.name{Ilist(n)},'  (',s.units{Ilist(n)},')'];
            end
            
            %update slots
            if slot == length(Isort)  %last item
               set(uih.cmdClr(slot),'Enable','off')
               set(uih.editVar(slot),'String','','Enable','off')
               set(uih.popOrder(slot),'Enable','off','Value',1)
            else  %delete row, shift subsequent items up
               for n = slot:length(Isort)-1
                  set(uih.editVar(n),'String',get(uih.editVar(n+1),'String'))
                  set(uih.popOrder(n),'Value',get(uih.popOrder(n+1),'Value'))
               end
               set(uih.cmdClr(length(Isort)),'Enable','off')
               set(uih.editVar(length(Isort)),'String','','Enable','off')
               set(uih.popOrder(length(Isort)),'Enable','off','Value',1)
            end
            
            %update list, caches
            set(uih.listVars, ...
               'String',strVars, ...
               'Value',find(Ilist==indx))
            uih.Ilist = Ilist;
            uih.Isort = Isort(Isort~=indx);
            set(h_dlg,'UserData',uih)
            
            %toggle button states
            if slot == 1
               set(uih.cmdEval,'Enable','off')
            end
            if slot == 10 || length(Ilist) == 1
               set(uih.cmdCopy,'Enable','on')
            end
            
            drawnow
            
         case 'copy'  %copy selected column to
            
            slot = length(Isort) + 1;
            
            if slot <= 10
               
               Isel = get(uih.listVars,'Value');  %get selection index, set new selection pointer
               if Isel == length(Ilist)
                  Inew = Isel - 1;
               else
                  Inew = Isel;
               end
               
               indx = Ilist(Isel);  %look up variable index
               Isort = [Isort ; indx];  %add index to sorted list
               Ilist = Ilist(Ilist ~= indx);  %remove index from variable list
               
               %update slots
               set(uih.editVar(slot),'String',s.name{indx},'Enable','inactive')
               set(uih.popOrder(slot),'Enable','on')
               set(uih.cmdClr(slot),'Enable','on')
               
               %regenerate variable list strings
               numcols = length(Ilist);
               strVars = cell(numcols,1);
               for n = 1:numcols
                  strVars{n} = [s.name{Ilist(n)},'  (',s.units{Ilist(n)},')'];
               end
               
               %update list, caches
               set(uih.listVars, ...
                  'String',strVars, ...
                  'Value',Inew);
               uih.Ilist = Ilist;
               uih.Isort = Isort;
               set(h_dlg,'UserData',uih)
               
               %toggle button states
               if slot == 1
                  set(uih.cmdEval,'Enable','on')
               end
               if slot == 10 || isempty(Ilist) %disable copy button when slots filled
                  set(uih.cmdCopy,'Enable','off')
               end
               
               drawnow
               
            end
                        
      end
      
   end
   
end
