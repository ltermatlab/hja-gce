function ui_num_replace(op,s,col,h_cb,cb)
%Dialog called by 'ui_editor' for searching and replacing numeric values in a GCE Data Structure
%
%syntax: ui_string_replace(op,s,col,h_cb,cb)
%
%input:
%  op = operation ('init' to initialize dialog)
%  s = data structure
%  col = column to update (default = [])
%  h_cb = object handle for storing return data
%  cb = callback to execute upon completion
%
%output:
%  none
%
%
%(c)2011-2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 17-Apr-2013

if strcmp(op,'init')
   
   if nargin >= 2 && gce_valid(s,'data')
      
      %check for prior instance and close
      if length(findobj) > 1
         h_dlg = findobj('tag','dlgNumReplace');
         if ~isempty(h_dlg)
            delete(h_dlg)
         end
      end
      
      Inum = find(~strcmp(s.datatype,'s')); %get index of non-string columns
      
      if ~isempty(Inum)
         
         if exist('col','var') ~= 1
            col = 0;
         elseif ~isnumeric(col)
            col = name2col(s,col);
         end
         
         if isempty(col)
            colval = 0;
         else
            Ival = find(Inum == col);
            if ~isempty(Ival)
               colval = Ival;
            else
               colval = 0;
            end
         end
         
         bgcolor = [.95 .95 .95];
         res = get(0,'ScreenSize');
         
         h_dlg = figure('Units','pixels', ...
            'Position',[max(0,0.5.*(res(3)-650)) max(50,0.5.*(res(4)-170)) 750 130], ...
            'Visible','off', ...
            'Color',bgcolor, ...
            'KeyPressFcn','figure(gcf)', ...
            'MenuBar','none', ...
            'Name','Search/Replace Number', ...
            'NumberTitle','off', ...
            'DefaultUIControlUnits','pixels', ...
            'Resize','off', ...
            'Tag','dlgNumReplace');
         
         if mlversion >= 7
            set(h_dlg,'WindowStyle','normal')
            set(h_dlg,'DockControls','off')
         end
         
         uicontrol('parent',h_dlg, ...
            'Style','text', ...
            'Position',[15 95 60 18], ...
            'String','Column', ...
            'Fontweight','bold', ...
            'FontSize',10, ...
            'BackgroundColor',bgcolor, ...
            'Tag','lblColumn');
         
         h_popColumn = uicontrol('parent',h_dlg, ...
            'Style','popupmenu', ...
            'Position',[80 98 170 18], ...
            'String',[{'<select column>'} ; s.name(Inum)'], ...
            'Value',colval+1, ...
            'BackgroundColor',[1 1 1], ...
            'FontSize',9, ...
            'Tag','popColumn', ...
            'Callback','ui_num_replace(''buttons'')', ...
            'TooltipString','Column to modify', ...
            'UserData',Inum);
         
         uicontrol('parent',h_dlg, ...
            'Style','text', ...
            'Position',[265 95 70 18], ...
            'Fontweight','bold', ...
            'FontSize',10, ...
            'BackgroundColor',bgcolor, ...
            'String','Criteria', ...
            'Tag','lblOldValue');
         
         h_editOldValue = uicontrol('parent',h_dlg, ...
            'Style','edit', ...
            'Position',[337 95 140 20], ...
            'FontSize',9, ...
            'BackgroundColor',[1 1 1], ...
            'HorizontalAlignment','left', ...
            'String','', ...
            'Callback','ui_num_replace(''buttons'')', ...
            'TooltipString','Scalar value or criteria expression to match', ...
            'Tag','editOldValue');
         
         h_cmdQry = uicontrol('Parent',h_dlg, ...
            'Style','pushbutton', ...
            'Position',[480 94 45 23], ...
            'String','Edit', ...
            'TooltipString','Open a graphical dialog to edit the criteria statement', ...
            'Callback','ui_num_replace(''editquery'')', ...
            'Tag','cmdQry');
         
         uicontrol('parent',h_dlg, ...
            'Style','text', ...
            'Position',[545 95 75 18], ...
            'Fontweight','bold', ...
            'FontSize',10, ...
            'BackgroundColor',bgcolor, ...
            'String','New Value', ...
            'Tag','lblNewValue');
         
         h_editNewValue = uicontrol('parent',h_dlg, ...
            'Style','edit', ...
            'Position',[625 95 90 20], ...
            'FontSize',9, ...
            'BackgroundColor',[1 1 1], ...
            'HorizontalAlignment','left', ...
            'String','', ...
            'Callback','ui_num_replace(''buttons'')', ...
            'TooltipString','New value to substitute', ...
            'Tag','lblNewValue');
         
         uicontrol('parent',h_dlg, ...
            'Style','text', ...
            'Position',[65 55 135 18], ...
            'Fontweight','bold', ...
            'FontSize',10, ...
            'BackgroundColor',bgcolor, ...
            'String','Q/C Flag to Assign', ...
            'Tag','lblFlagCode');
         
         %call function to add standard Q/C flag picking controls and get ui handle
         ui_flagpicker('add',s,[200 53],h_dlg,'');
         h_popFlagChoice = findobj(h_dlg,'Tag','popFlagChoice');
         set(h_popFlagChoice,'TooltipString','Q/C flag to assign to replaced values')
         
         uicontrol('parent',h_dlg, ...
            'Style','text', ...
            'Position',[470 55 100 18], ...
            'Fontweight','bold', ...
            'FontSize',10, ...
            'BackgroundColor',bgcolor, ...
            'String','Log Changes', ...
            'Tag','lblNewValue');
         
         h_editLogOption = uicontrol('parent',h_dlg, ...
            'Style','edit', ...
            'Position',[572 55 90 20], ...
            'FontSize',9, ...
            'BackgroundColor',[1 1 1], ...
            'HorizontalAlignment','left', ...
            'String','100', ...
            'TooltipString','Number of value replacements to individually log to the processing history', ...
            'Tag','lblNewValue');
         
         h_cmdCancel = uicontrol('parent',h_dlg, ...
            'Style','pushbutton', ...
            'Position',[10 10 60 25], ...
            'String','Cancel', ...
            'Callback','ui_num_replace(''cancel'')', ...
            'Tag','cmdCancel');
         
         h_cmdEval = uicontrol('parent',h_dlg, ...
            'Style','pushbutton', ...
            'Position',[680 10 60 25], ...
            'String','Accept', ...
            'Enable','off', ...
            'Callback','ui_num_replace(''eval'')', ...
            'Tag','cmdEval');
         
         %generate structure to cache handles and input data
         uih = struct('popColumn',h_popColumn, ...
            'editOldValue',h_editOldValue, ...
            'editNewValue',h_editNewValue, ...
            'editLogOption',h_editLogOption, ...
            'popFlagChoice',h_popFlagChoice, ...
            'cmdQry',h_cmdQry, ...
            'cmdCancel',h_cmdCancel, ...
            'cmdEval',h_cmdEval, ...
            's',s, ...
            'Inum',[], ...
            'h_cb',h_cb, ...
            'cb',cb);
         uih.Inum = Inum;
         
         set(h_dlg,'Visible','on','UserData',uih)
         drawnow
         
      else
         messagebox('init','This dialog requires a data structure with one or more numeric columns', ...
            '','Error',[.95 .95 .95]);
      end
      
   end
   
else  %handle other callbacks
   
   h_dlg = gcf;
   
   if strcmp(get(h_dlg,'Tag'),'dlgNumReplace')
      
      uih = get(h_dlg,'UserData');
      
      switch op
         
         case 'cancel'
            
            if ~isempty(h_dlg)
               delete(h_dlg)
               drawnow
            end
            
            ui_aboutgce('reopen')  %check for last window
            
         case 'buttons'  %check for valid input, enable/disable accept button
            
            col = get(uih.popColumn,'Value');
            oldval = deblank(get(uih.editOldValue,'String'));
            newval = deblank(get(uih.editNewValue,'String'));
            
            if col > 1 && ~isempty(oldval) && ~isempty(newval)
               set(uih.cmdEval,'Enable','on')
            else
               set(uih.cmdEval,'Enable','off')
            end
            
            drawnow
            
         case 'editquery'  %create/edit criteria using query builder GUI
            
            %get criteria
            qrystr = get(uih.editOldValue,'String');
            
            %call query builder
            ui_querybuilder('init',uih.s,uih.editOldValue,'ui_num_replace(''criteria'')',qrystr)
            
         case 'criteria'  %handle criteria returned from query builder GUI
            
            %get criteria from criteria field userdata
            qrystr = get(uih.editOldValue,'UserData');
            
            %updated editbox
            set(uih.editOldValue,'String',qrystr)
            
            %update button states
            ui_num_replace('buttons')
            
         case 'eval'
            
            %get column selection
            colval = get(uih.popColumn,'Value');
            colindex = uih.Inum;
            col = colindex(colval-1);
            
            %get editbox strings and convert to numeric using generalized str2num to catch expressions
            %and avoid replacing non-numeric input with NaN using str2double
            oldval = str2num(get(uih.editOldValue,'String'));
            newval = str2num(get(uih.editNewValue,'String'));
            
            %check for non-numeric oldval and pass as string expression
            if isempty(oldval)
               oldval = deblank(get(uih.editOldValue,'String'));
            end
            
            %get logging option
            logoption = str2double(get(uih.editLogOption,'String'));
            if isnan(logoption)
               logoption = 0;
            end
            
            %get q/c flag option
            Iflag = get(uih.popFlagChoice,'Value');
            flagcodes = get(uih.popFlagChoice,'Userdata');
            flag = flagcodes{Iflag};
            flagmeta = '';
            
            %generate updated flag metadata in case user has updated the definitions in the dialog
            if ~isempty(flag)
               defs = cellstr(get(uih.popFlagChoice,'String'));  %convert list to cell array
               flagdefs = cell2commas(strrep(defs(2:end),'--','='));  %generate flag def metadata, skipping no flag option
               if ~isempty(flagdefs)
                  flagmeta = [{'Data'},{'Codes'},{flagdefs}];  %format flag codes as metadata field for dialog
               end
            end
            
            if ~isempty(oldval) && ~isempty(newval)
               
               %perform number replacement with specified options
               [s2,msg] = num_replace(uih.s,col,oldval,newval,logoption,flag);
               
               if ~isempty(s2)
                  
                  close(h_dlg)
                  
                  %update flag definitions in metadata
                  if ~isempty(flag) && ~isempty(flagmeta)
                     s2 = addmeta(s2,flagmeta,0,'ui_num_replace');
                  end
                  
                  %get handle of calling figure
                  h_fig = parent_figure(uih.h_cb);
                  
                  if ~isempty(h_fig)
                     figure(h_fig)
                     drawnow
                     set(uih.h_cb,'UserData',s2)
                     try
                        eval(uih.cb)
                     catch
                        messagebox('init','An error occurred returning the updated data structure to the calling editor', ...
                           '','Error',[.95 .95 .95])
                     end
                  else
                     ui_editor('init',s2);
                  end
                  
               else
                  messagebox('init',['An error occurred: ',msg],'','Error',[.95 .95 .95])
               end
               
            else
               messagebox('init','One or both numbers are invalid','','Error',[.95 .95 .95])
            end
            
      end
      
   end
   
end
