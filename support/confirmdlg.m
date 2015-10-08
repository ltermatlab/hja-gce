function confirmdlg(op,querystr,callback)
%Confirmation dialog that executes a 'callback' statement if the 'OK' button is pressed
%
%syntax:  confirmdlg(op,querystr,callback)
%
%input:
%  op = operation ('init' to initialize dialog)
%  querystr = query string (i.e. user prompt)
%  callback = callback string to execute (default = '')
%
%output:
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
%last modified: 08-Sep-2014

if nargin == 0
   op = 'init';
end

if strcmp(op,'init')
   
   %check for required input
   if exist('querystr','var') == 1 && exist('callback','var') == 1
      
      %get calling figure handle
      h_fig = gcf;
      
      %check for prior instance - shut down if found
      h_dlg = findobj('Tag','dlgConfirm');
      if ~isempty(h_dlg)
         close(h_dlg)
      end
      
      %format query string
      if iscell(querystr)
         querystr = char(querystr);
      end
      if size(querystr,1) > 1
         querystr = strjust(querystr,'center');
      end
      
      %get screen metrics
      screenres = get(0,'ScreenSize');
      figwidth = max(min(size(querystr,2).*9,screenres(3)),200);
      figheight = 50 + size(querystr,1).* 30;
      center = [screenres(3)./2 screenres(4)./2];
      bgcolor = [0.9 0.9 0.9];
      
      %open figure dialog
      h_dlg = figure('Name','Confirmation', ...
         'Color',[0.9 0.9 0.9], ...
         'Visible','off', ...
         'Units','pixels', ...
         'Position',[center(1)-figwidth./2 center(2)-40 figwidth figheight], ...
         'Menubar','none', ...
         'NumberTitle','off', ...
         'Resize','off', ...
         'DefaultUiControlUnits','pixels', ...
         'KeypressFcn','confirmdlg(''ok'')', ...
         'Tag','dlgConfirm');
      
      uicontrol(h_dlg, ...
         'Style','text', ...
         'Position',[1 40 figwidth-2 size(querystr,1).*25], ...
         'String',querystr, ...
         'FontSize',11, ...
         'HorizontalAlignment','center', ...
         'BackgroundColor',bgcolor, ...
         'ForegroundColor',[0 0 0]);
      
      uicontrol(h_dlg, ...
         'Style','pushbutton', ...
         'Position',[figwidth.*0.33-30 10 60 25], ...
         'String','Cancel', ...
         'Callback','confirmdlg(''cancel'')');
      
      uicontrol(h_dlg, ...
         'Style','pushbutton', ...
         'Position',[figwidth.*0.66-30 10 60 25], ...
         'String','OK', ...
         'Tag','cmdOK', ...
         'Callback','confirmdlg(''ok'')');
      
      uih = struct( ...
         'h_fig',h_fig, ...
         'callback',callback ...
         );
      
      set(h_dlg,'UserData',uih,'Visible','on')
      drawnow
      
   end
   
else  %handle callback
   
   %get dialog handle
   h_dlg = gcf;
   
   if strcmp(get(h_dlg,'Tag'),'dlgConfirm')
      
      %get cached info
      uih = get(h_dlg,'UserData');
      
      %shut down dialog and switch to calling figure
      delete(h_dlg)
      figure(uih.h_fig)
      drawnow
      
      %execute callback if ok pushed
      if strcmp(op,'ok')
         try
            eval(uih.callback)
         catch
            %do nothing on error
         end
      end
      
   end
   
end
