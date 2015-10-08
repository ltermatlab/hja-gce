function messagebox(op,message,callback,dialogtitle,bgcolor,showcancel)
%Generates a multi-line message box with a user-specified callback and optional cancel button
%
%syntax:  messagebox(op,message,callback,dialogtitle,bgcolor,showcancel)
%
%input:
%  op = operation ('init' to initialize)
%  message = message to display (character array)
%  callback = callback to execute upon pressing 'OK' (default = '')
%  dialogtitle = title of the dialog box (default = 'Message')
%  bgcolor = background color of the dialog box (RGB array, default = [9 9 9])
%  showcancel = option to display a 'Cancel' button (0 = no/default, 1 = yes)
%
%output:
%  none
%
%usage:
%  If op is 'init' the message box is created with the string in 'message' displayed.
%  The 'OK' button closes the box, shifts focus back to the eliciting figure window,
%  and issues the optional 'callback' statement. If specified, the 'Cancel' button just
%  closes the box without executing the callback.
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
%last modified: 26-Apr-2012

if nargin > 0
   
   if strcmp(op,'init')
      
      %check for existing figures
      if length(findobj) > 1
         h = gcf;
      else
         h = [];
      end
      
      %validate input, supply defaults
      if exist('message','var') ~= 1
         message = '';
      elseif iscell(message)
         message = char(message);
      elseif ischar(message)
         if size(message,2) > 120
            msg2 = '';
            for n = 1:size(message,1)
               msg_temp = trimstr(regexprep(message(n,:),'\s+',' '));  %replace all whitespace with a single space
               msg_temp = wordwrap(msg_temp,120,0,'char');  %wrap long strings to 120 character max
               msg2 = char(msg2,msg_temp);
            end
            message = msg2(2:end,:);
         end
      end
      
      %default to no callback
      if exist('callback','var') ~= 1
         callback = '';
      end
      
      %default dialog title
      if exist('dialogtitle','var') ~= 1
         dialogtitle = 'Message';
      end
      
      %default to light gray background
      if exist('bgcolor','var') ~= 1
         bgcolor = [.95 .95 .95];
      end
      
      %set foreground color to black or white depending on darkness of background
      if sum(bgcolor) > 2.4
         fgcolor = [0 0 0];
      else
         fgcolor = [1 1 1];
      end
      
      %default to not showing cancel button
      if exist('showcancel','var') ~= 1
         showcancel = 0;
      elseif showcancel ~= 1
         showcancel = 0;
      end
      
      %set screen resolution constant (maximum 800x600)
      screen = get(0,'screensize');
      screenres = screen(3:4);
      
      %set dialog metrics based on message size, screen size
      lines = size(message,1);
      figw = min(screenres(1)-10,max(size(message,2).*7.5,180));
      figh = 75 + (lines-1).*20;
      lineheight = 20./(figh-20);
      
      %open figure window
      h_msg = figure( ...
         'Visible','off', ...
         'Units','pixels', ...
         'Position',[(screenres(1)-figw)./2 (screenres(2)-figh)./2 figw figh], ...
         'Name',dialogtitle, ...
         'Color',bgcolor, ...
         'NumberTitle','off', ...
         'MenuBar','none', ...
         'KeyPressFcn','messagebox(''eval'')', ...
         'Resize','off', ...
         'Tag','messagebox', ...
         'UserData',h);
      
      %set figure axis position for text
      set(gca, ...
         'Visible','off', ...
         'Position',[0 30./figh 1 1-40./figh])
      
      %add cancel button if specified
      if showcancel == 0
         %show OK button centered
         uicontrol(h_msg, ...
            'Style','pushbutton', ...
            'Units','pixels', ...
            'String','OK', ...
            'Position',[(figw-50)./2 5 50 25], ...
            'Tag','callback', ...
            'UserData',callback, ...
            'Callback','messagebox(''eval'')');
      else
         %show OK and Cancel buttons
         uicontrol(h_msg, ...
            'Style','pushbutton', ...
            'Units','pixels', ...
            'String','Cancel', ...
            'Position',[figw./2-65 5 60 25], ...
            'Tag','cancel', ...
            'Callback','messagebox(''cancel'')');
         uicontrol(h_msg, ...
            'Style','pushbutton', ...
            'Units','pixels', ...
            'String','OK', ...
            'Position',[figw./2+5 5 60 25], ...
            'Tag','callback', ...
            'UserData',callback, ...
            'Callback','messagebox(''eval'')');
      end
      
      %loop through message lines
      for n = 1:lines
         
         %get line, removing trailing blanks
         str = deblank(message(n,:));
         
         %add text based on fractional x/y position
         text(0.5,0.96-lineheight*(n),str, ...
            'FontName','Helvetica', ...
            'FontWeight','bold', ...
            'FontSize',10, ...
            'Color',fgcolor, ...
            'Interpreter','none', ...
            'HorizontalAlignment','center', ...
            'VerticalAlignment','middle')
         
      end
      
      %show dialog
      set(h_msg,'Visible','on')
      drawnow
      
   else  %process other callbacks
      
      %get handle of current figure
      h_msg = gcf;
      
      %check to confirm handle is for messagebox dialog
      if strcmp(get(h_msg,'Tag'),'messagebox')
         
         if strcmp(op,'cancel')  %process cancel
            
            delete(h_msg)
            drawnow
            
         elseif strcmp(op,'eval')  %process button clicks
            
            %get handle of OK button
            h_callback = findobj(h_msg,'Tag','callback');
            
            %get cached callback from dialog
            h = get(h_msg,'UserData');  %get calling figure handle cached in figure userdata
            callback = get(h_callback,'UserData');  %get callback info cached in ok button
            
            %close dialog
            delete(h_msg)
            drawnow
                        
            %execute callback
            if ~isempty(callback)
               
               %set focus to calling figure if specified
               if ~isempty(h)
                  try
                     figure(h)
                  catch
                  end
               end
               
               try
                  eval(callback)
               catch
               end
               
            end
            
            drawnow
            
         end
         
      end
      
   end
   
end