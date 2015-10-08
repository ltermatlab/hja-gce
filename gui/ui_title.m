function ui_title(op,s,h_cb,cb,caption,dlgtitle)
%Dialog called by 'ui_editor' to update the title of a GCE Data Structure or editor window
%
%syntax: ui_title(op,s,h_cb,cb,caption,dlgtitle)
%
%input:
%  op = operation ('init' to initialize dialog)
%  s = data structure
%  h_cb = object handle for storing return data
%  cb = callback to execute upon completion
%  caption = dialog caption
%  dlgtitle = dialog title
%
%output:
%  none
%
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
%last modified: 19-Oct-2012

if nargin == 0
   op = 'init';
end

%check for valid init call
if strcmp(op,'init') && nargin >= 4
   
   %check for prior instance and close
   if length(findobj) > 1
      h_dlg = findobj('tag','dlgDSTitle');
      if ~isempty(h_dlg)
         delete(h_dlg)
      end
   end
   
   if exist('caption','var') ~= 1
      caption = 'Data Structure Title';
   end
   
   if exist('dlgtitle','var') ~= 1
      dlgtitle = 'Edit Title';
   end
   
   %get current title string from structure or function argument
   str = '';
   if gce_valid(s,'data')
      str = s.title;
      datevis = 'on';
   elseif ischar(s)
      str = s;
      datevis = 'off';
   end
   
   %set screen metrics, fonts
   bgcolor = [.95 .95 .95];
   res = get(0,'ScreenSize');
   if strcmp(computer,'PCWIN')
      font = 'Arial';
   else
      font = 'Helvetica';
   end
   
   %init figure
   h_dlg = figure('Units','pixels', ...
      'Position',[max(0,0.5.*(res(3)-660)) max(50,0.5.*(res(4)-170)) 660 170], ...
      'Visible','off', ...
      'Color',bgcolor, ...
      'KeyPressFcn','figure(gcf)', ...
      'MenuBar','none', ...
      'Name',dlgtitle, ...
      'NumberTitle','off', ...
      'DefaultUIControlUnits','pixels', ...
      'CloseRequestFcn','ui_title(''cancel'')', ...
      'Resize','off', ...
      'Tag','dlgDSTitle');
   
   %disable dock controls
   if mlversion >= 7
      set(h_dlg,'WindowStyle','normal')
      set(h_dlg,'DockControls','off')
   end
   
   %define uicontrols
   uicontrol('Parent',h_dlg, ...
      'Position',[5 140 540 20], ...
      'Style','text', ...
      'FontName',font, ...
      'FontSize',10, ...
      'FontWeight','bold', ...
      'BackgroundColor',bgcolor, ...
      'HorizontalAlignment','left', ...
      'String',caption);
   
   %add date button
   uicontrol('Parent',h_dlg, ...
      'Position',[550 140 50 24], ...
      'Style','Pushbutton', ...
      'String','Dates', ...
      'TooltipString','Add date range string to end of title', ...
      'Visible',datevis, ...
      'Callback','ui_title(''adddate'')', ...
      'Tag','AddDate');
   
   %add clear button
   uicontrol('Parent',h_dlg, ...
      'Position',[605 140 50 24], ...
      'Style','pushbutton', ...
      'String','Clear', ...
      'TooltipString','Clear the title edit box', ...
      'Callback','ui_title(''clear'')', ...
      'Tag','Clear');
   
   %add edit box
   h_edit = uicontrol('Parent',h_dlg, ...
      'Style','edit', ...
      'Position',[5 35 650 100], ...
      'BackgroundColor',[1 1 1], ...
      'ForegroundColor',[0 0 0], ...
      'FontName',font, ...
      'FontSize',10, ...
      'HorizontalAlignment','left', ...
      'Max',5, ...
      'Min',1, ...
      'String',str, ...
      'Tag','editbox');
   
   %add accept button
   uicontrol('Parent',h_dlg, ...
      'Style','pushbutton', ...
      'Callback','ui_title(''eval'')', ...
      'Position',[340 5 60 25], ...
      'String','Accept', ...
      'Tag','accept');
   
   %add cancel button
   uicontrol('Parent',h_dlg, ...
      'Style','pushbutton', ...
      'Callback','ui_title(''cancel'')', ...
      'Position',[270 5 60 25], ...
      'String','Cancel', ...
      'Tag','cancel');
   
   %build uicontrol cache structure
   uih = struct('str',str, ...
      'h_cb',h_cb, ...
      'h_edit',h_edit, ...
      'cb',cb, ...
      's',s);
   
   %add cache to figure, turn on visibility
   set(h_dlg,'Visible','on','UserData',uih)
   drawnow
   
else  %handle callbacks
   
   %get active figure handle
   h_dlg = gcf;
   
   %confirm figure is ui_title dialog
   if strcmp(get(h_dlg,'Tag'),'dlgDSTitle')
      
      %get cached info
      uih = get(h_dlg,'userdata');
      
      switch op
         
         case 'cancel'  %close dialog and cancel changes            
            
            delete(h_dlg)
            
            %check for last window
            ui_aboutgce('reopen')
            
         case 'clear'  %clear edit box
            
            set(uih.h_edit,'String','')
            drawnow
            
         case 'adddate'  %add/update date range
            
            %get current title string, add to temporary structure as a new title
            str = deblank(get(uih.h_edit,'String'));
            s_tmp = uih.s;
            s_tmp.title = str;
                  
            %call external function to add date range to title
            [s_tmp,msg] = add_title_dates(s_tmp,1,' to ');
            
            %check for errors
            if ~isempty(s_tmp)               
               set(uih.h_edit,'String',s_tmp.title)
               drawnow
            end
            
            %check for error message, display if present
            if ~isempty(msg)
               messagebox('init',msg,'','Error',[0.95 0.95 0.95])
            end               
            
         case 'eval'  %accept edit and execute callback
            
            %get title
            newtitle = deblank(get(uih.h_edit,'String'));
                        
            %check for non-empty string
            if ~isempty(newtitle)
               
               %close dialog
               delete(h_dlg)
               drawnow

               %check for and concatenate multiple lines
               if size(newtitle,1) > 1
                  tmp = '';
                  for n = 1:size(newtitle,1)
                     tmp = [tmp,deblank(newtitle(n,:)),' '];
                  end
                  newtitle = tmp(1:end-1);
               else  %just deblank
                  newtitle = deblank(newtitle);
               end
               
               %check for diffs
               if ~strcmp(uih.str,newtitle)
                  
                  %get parent figure of callback handle
                  h_fig = parent_figure(uih.h_cb);
                  
                  if ~isempty(h_fig)
                     figure(h_fig)  %set focus
                     set(uih.h_cb,'UserData',newtitle)  %store title in callback handle userdata
                     try
                        eval(uih.cb)  %evaluate callback
                     catch
                        ui_title('error')
                     end
                  else
                     messagebox('init','Warning - original editor window could not be opened', ...
                        '','Error',[.9 .9 .9]);
                  end
                  
               end
               
            else
               ui_title('error')               
            end
            
         case 'error'  %display error
            
            messagebox('init', ...
               'The title could not be updated with the selected options', ...
               '', ...
               'Error', ...
               [.9 .9 .9]);
            
      end
      
   end
   
end
