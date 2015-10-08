function ui_text_prompt(op,h_cb,cb,str,prompt,dlg_title,width)
%Opens a dialog box to prompt for a character array
%
%syntax: ui_text_prompt(op,h_cb,cb,str,prompt,title,width)
%
%inputs:
%  op = operation ('init' to open dialog)
%  h_cb = uicontrol handle to use to store the entered string
%  cb = callback statement to execute upon hitting "Accept" button
%  str = default string or list of options to display (default = '')
%  prompt = prompt to display (default = 'Text:')
%  title = dialog title (default = 'Text Prompt')
%  width = dialog width in pixels (default = 400)
%
%outputs:
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
%last modified: 24-Feb-2012

if nargin == 0
   op = 'init';
end

%init dialog
if strcmp(op,'init')
   
   if nargin >= 3
      
      %validate default string
      if exist('str','var') ~= 1
         str = '';
      elseif ~iscell(str) && size(str,1) > 1
         str = cellstr(str);  %check for character array as list
      end
      
      %set default string for dialog
      if ischar(str)
         default = str;
      else
         default = str{1};
      end
      
      %validate prompt
      if exist('prompt','var') ~= 1
         prompt = 'Text:';
      end
      
      %validate title
      if exist('dlg_title','var') ~= 1
         dlg_title = 'Text Prompt';
      end
      
      %validate width
      if exist('width','var') ~= 1
         width = 400;
      elseif width < 200
         width = 200;
      end
      
      %check for prior instance and close
      if length(findobj) > 1
         h_dlg = findobj('tag','dlgTextPrompt');
         if ~isempty(h_dlg)
            delete(h_dlg)
         end
      end
      
      if nargin >= 3
         
         %init dialog color and font attributes
         bgcolor = [.95 .95 .95];
         res = get(0,'ScreenSize');
         if strcmp(computer,'PCWIN')
            font = 'Arial';
         else
            font = 'Helvetica';
         end
         
         %open dialog figure
         h_dlg = figure('Units','pixels', ...
            'Position',[max(0,0.5.*(res(3)-width)) max(50,0.5.*(res(4)-170)) width 130], ...
            'Visible','off', ...
            'Color',bgcolor, ...
            'KeyPressFcn','figure(gcf)', ...
            'MenuBar','none', ...
            'Name',dlg_title, ...
            'NumberTitle','off', ...
            'DefaultUIControlUnits','pixels', ...
            'CloseRequestFcn','ui_text_prompt(''cancel'')', ...
            'Tag','dlgTextPrompt');
         
         %turn of dock controls
         if mlversion >= 7
            set(h_dlg,'WindowStyle','normal')
            set(h_dlg,'DockControls','off')
         end
         
         %init uicontrols
         uicontrol('Parent',h_dlg, ...
            'Position',[10 90 290 22], ...
            'Style','text', ...
            'HorizontalAlign','left', ...
            'FontName',font, ...
            'FontSize',10, ...
            'FontWeight','bold', ...
            'BackgroundColor',bgcolor, ...
            'HorizontalAlignment','left', ...
            'String',prompt);
         
         %create popup menu behind text box if str contains list
         if iscell(str)
            h_popup = uicontrol('Parent',h_dlg, ...
               'Style','popupmenu', ...
               'Position',[30 63 width-42 20], ...
               'BackgroundColor',[1 1 1], ...
               'ForegroundColor',[0 0 0], ...
               'FontName',font, ...
               'FontSize',10, ...
               'SelectionHighlight','off', ...
               'HorizontalAlignment','left', ...
               'String',str, ...
               'Value',1, ...
               'Callback','ui_text_prompt(''addtext'')', ...
               'TooltipString','Select predefined options from a list', ...
               'Tag','popupmenu');
         else
            h_popup = [];
         end
         
         %generate edit box
         h_text = uicontrol('Parent',h_dlg, ...
            'Style','edit', ...
            'Position',[30 60 width-60 23], ...
            'BackgroundColor',[1 1 1], ...
            'ForegroundColor',[0 0 0], ...
            'FontName',font, ...
            'FontSize',10, ...
            'HorizontalAlignment','left', ...
            'String',default, ...
            'Callback','ui_text_prompt(''eval'')', ...
            'Tag','editbox');
         
         %generate accept button
         uicontrol('Parent',h_dlg, ...
            'Style','pushbutton', ...
            'Callback','ui_text_prompt(''eval'')', ...
            'Position',[width./2+20 10 60 25], ...
            'String','Accept', ...
            'Tag','accept');
         
         %gneerate cancel button
         uicontrol('Parent',h_dlg, ...
            'Style','pushbutton', ...
            'Callback','ui_text_prompt(''cancel'')', ...
            'Position',[width./2-80 10 60 25], ...
            'String','Cancel', ...
            'Tag','cancel');
         
         %generate object cache
         data = struct('h_cb',h_cb, ...
            'h_text',h_text, ...
            'h_popup',h_popup, ...
            'cb',cb, ...
            'str','');
         
         %add string element separately to avoid multi-dimensional structure if cell array
         data.str = str;
         
         %init dialog
         set(h_dlg,'Visible','on','UserData',data)
         drawnow
         
      end
      
   end
   
else
   
   %get dialog handle
   h_dlg = findobj('Tag','dlgTextPrompt');
   
   if ~isempty(h_dlg)
      
      %get cached ui data
      data = get(h_dlg,'UserData');
      
      switch op
         
         case 'cancel'  %cancel operation
            
            delete(h_dlg)
            drawnow
            
            ui_aboutgce('reopen')  %check for last window
            
         case 'addtext'  %add selection from popup menu to edit box
            
            if ~isempty(data.h_popup)
               val = get(data.h_popup,'Value');
               newstr = data.str{val};
               set(data.h_text,'String',newstr)
               drawnow
            end
            
         case 'eval'  %evaluate callback
            
            %get selection contents
            newstr = get(data.h_text,'String');
            
            close(h_dlg)
            drawnow
            
            %check for non-empty string, execute callback
            if ~isempty(newstr) && ~isempty(data.cb)
               
               %get handle of callback parent figure
               h_fig = parent_figure(data.h_cb);
               
               if ~isempty(h_fig)
                  figure(h_fig)  %set focus to callback figure
                  set(data.h_cb,'UserData',newstr)  %store string in userdata
                  try
                     eval(data.cb)  %execute callback
                  catch
                     messagebox('init','An error occurred returning the text',[],'Error',[.9 .9 .9]);
                  end
               end
               
            end
            
      end
      
   end
   
end
