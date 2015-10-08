function poly_title(op,str,h_cb,cb,caption,dlgtitle)
%Dialog called by 'poly_mgr' to update the title of a polygon
%
%syntax: poly_title(op,str,h_cb,cb,caption,dlgtitle)
%
%input:
%  op = operation (default = 'init')
%  str = new title
%  h_cb = handle of callback object
%  cb = callback to execute upon completion
%  caption = dialog caption to display
%  dlgtitle = title of dialog box
%
%output:
%  none
%
%(c)2004 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 28-Jun-2004

switch op

   case 'init'

      %check for prior instance and close
      if length(findobj) > 1
         h_dlg = findobj('tag','dlgPolyTitle');
         if ~isempty(h_dlg)
            delete(h_dlg)
         end
      end

      if nargin >= 4

         if exist('caption') ~= 1
            caption = 'Polygon Title';
         end

         if exist('dlgtitle') ~= 1
            dlgtitle = 'Edit Title';
         end

         if exist('str') ~= 1
            str = '';
         end

         bgcolor = [.95 .95 .95];
         res = get(0,'ScreenSize');
         if strcmp(computer,'PCWIN')
            font = 'Arial';
         else
            font = 'Helvetica';
         end

         h_dlg = figure('Units','pixels', ...
            'Position',[max(0,0.5.*(res(3)-600)) max(50,0.5.*(res(4)-170)) 600 170], ...
            'Visible','off', ...
            'Color',bgcolor, ...
            'KeyPressFcn','figure(gcf)', ...
            'MenuBar','none', ...
            'Name',dlgtitle, ...
            'NumberTitle','off', ...
            'DefaultUIControlUnits','pixels', ...
            'Tag','dlgPolyTitle');

         h1 = uicontrol('Parent',h_dlg, ...
            'Position',[5 140 590 20], ...
            'Style','text', ...
            'FontName','font', ...
            'FontSize',10, ...
            'FontWeight','bold', ...
            'BackgroundColor',bgcolor, ...
            'HorizontalAlignment','left', ...
            'String',caption);

         h_edit = uicontrol('Parent',h_dlg, ...
            'Style','edit', ...
            'Position',[5 35 590 100], ...
            'BackgroundColor',[1 1 1], ...
            'ForegroundColor',[0 0 0], ...
            'FontName','font', ...
            'FontSize',10, ...
            'HorizontalAlignment','left', ...
            'Max',5, ...
            'Min',1, ...
            'String',str, ...
            'Tag','editbox');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','pushbutton', ...
            'Callback','poly_title(''eval'')', ...
            'Position',[310 5 60 25], ...
            'String','Accept', ...
            'Tag','accept');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','pushbutton', ...
            'Callback','poly_title(''cancel'')', ...
            'Position',[230 5 60 25], ...
            'String','Cancel', ...
            'Tag','cancel');

         data = struct('str',str,'h_cb',h_cb,'h_edit',h_edit,'cb',cb);

         set(h_dlg,'Visible','on','UserData',data)
         drawnow

      end

   case 'cancel'

      h_dlg = findobj('Tag','dlgPolyTitle');

      if ~isempty(h_dlg)
         close(h_dlg)
         drawnow
      end

   case 'eval'

      h_dlg = findobj('Tag','dlgPolyTitle');

      if ~isempty(h_dlg)

         data = get(h_dlg,'UserData');

         newtitle = get(data.h_edit,'String');

         close(h_dlg)
         drawnow

         if ~isempty(newtitle)
            try
               set(data.h_cb,'UserData',struct('old',data.str,'new',newtitle))  %cache new title
               eval(data.cb)
            catch
               poly_title('error')
            end
         else
            poly_title('error')
         end

      end

   case 'error'

      messagebox('init', ...
         'The title could not be updated with the selected options', ...
         '', ...
         'Error', ...
         [.9 .9 .9]);


end
