function textedit(op)
%Text editing dialog box, to be used as a callback function associated with text objects.
%
%syntax:  textedit(op)
%
%input:
%  op = operation (default = 'init')
%
%output:
%  none
%
%(c)2002-2005 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 06-May-2005

if nargin == 0

   h_dlg = findobj('Tag','dlgTextEdit');
   if ~isempty(h_dlg)
      close(h_dlg)
   end

   h_cbo = gcbo;

   objtype = get(h_cbo,'Type');

   if strcmp(lower(objtype),'text')
      str = get(h_cbo,'String');
      fontname = get(h_cbo,'FontName');
      fontunits = get(h_cbo,'FontUnits');
      fontsize = get(h_cbo,'FontSize');
      fontweight = get(h_cbo,'FontWeight');
      fontangle = get(h_cbo,'FontAngle');
      fontcolor = get(h_cbo,'Color');
      fontrotate = get(h_cbo,'Rotation');
      interpreter = get(h_cbo,'Interpreter');
   else
      str = '';
      fontname = 'Helvetica';
      fontunits = 'points';
      fontsize = 10;
      fontweight = 'normal';
      fontangle = 'normal';
      fontcolor = [0 0 0];
      fontrotate = 0;
      interpreter = 'none';
   end

   if fontcolor ~= [1 1 1]
      backcolor = [1 1 1];
   else
      backcolor = [.6 .6 .6];
   end

   if strcmp(interpreter,'tex')
      texval = 1;
   else
      texval = 0;
   end

   res = get(0,'ScreenSize');

   h_dlg = figure('Units','pixels', ...
      'Position',[max(0,0.5.*(res(3)-750)) max(50,0.5.*(res(4)-270)) 750 200], ...
      'Visible','off', ...
      'Color',[0.8 0.8 0.8], ...
      'KeyPressFcn','figure(gcf)', ...
      'MenuBar','none', ...
      'Name','Edit Text', ...
      'NumberTitle','off', ...
      'Tag','dlgTextEdit', ...
      'DefaultUicontrolUnits','pixels', ...
      'UserData',gcf);

   h1 = uicontrol('Parent',h_dlg, ...
      'Style','edit', ...
      'Position',[5 40 740 120], ...
      'BackgroundColor',backcolor, ...
      'ForegroundColor',fontcolor, ...
      'FontName',fontname, ...
      'FontUnits',fontunits, ...
      'FontSize',fontsize, ...
      'FontWeight',fontweight, ...
      'FontAngle',fontangle, ...
      'HorizontalAlignment','left', ...
      'Max',5, ...
      'Min',1, ...
      'String',str, ...
      'Tag','EditBox', ...
      'UserData',h_cbo);

   h1 = uicontrol('Parent',h_dlg, ...
      'Style','pushbutton', ...
      'Position',[5 5 60 25], ...
      'Callback','textedit(''cancel'')', ...
      'String','Cancel', ...
      'Tag','cancel');

   h1 = uicontrol('Parent',h_dlg, ...
      'Style','pushbutton', ...
      'Position',[685 5 60 24], ...
      'Callback','textedit(''eval'')', ...
      'String','Accept', ...
      'Tag','accept');

   h1 = uicontrol('Parent',h_dlg, ...
      'Style','pushbutton', ...
      'Position',[5 170 80 24], ...
      'Callback','textedit(''font'')', ...
      'String','Font Attributes', ...
      'Tag','font');

   h1 = uicontrol('Parent',h_dlg, ...
      'Style','pushbutton', ...
      'Callback','textedit(''color'')', ...
      'Position',[100 170 80 24], ...
      'String','Text Color', ...
      'Tag','color');

   h1 = uicontrol('Parent',h_dlg, ...
      'Style','text', ...
      'FontSize',10, ...
      'Position',[210 170 90 20], ...
      'BackgroundColor',[0.8 0.8 0.8], ...
      'String',' Rotation (�)');

   h1 = uicontrol('Parent',h_dlg, ...
      'Style','edit', ...
      'Position',[300 170 50 20], ...
      'BackgroundColor',[1 1 1], ...
      'String',num2str(fontrotate), ...
      'Tag','Rotate');

   h1 = uicontrol('Parent',h_dlg, ...
      'Style','checkbox', ...
      'Position',[400 170 120 20], ...
      'FontSize',10, ...
      'BackgroundColor',[0.8 0.8 0.8], ...
      'HorizontalAlignment','left', ...
      'String','TeX Interpreter', ...
      'Value',texval, ...
      'Tag','texval');

   set(h_dlg,'Visible','on')

else

   h_dialog = findobj('Tag','dlgTextEdit');
   h_fig = get(h_dialog,'UserData');
   h_edit = findobj(h_dialog,'Tag','EditBox');

   if strcmp(op,'cancel')

      close(h_dialog)
      figure(h_fig)

   elseif strcmp(op,'font')

      uisetfont(h_edit,'Font Attributes');

   elseif strcmp(op,'color')

      uisetcolor(h_edit,'Font Color');

   elseif strcmp(op,'eval')

      str = get(h_edit,'String');
      fontname = get(h_edit,'FontName');
      fontunits = get(h_edit,'FontUnits');
      fontsize = get(h_edit,'FontSize');
      fontweight = get(h_edit,'FontWeight');
      fontangle = get(h_edit,'FontAngle');
      fontcolor = get(h_edit,'ForegroundColor');

      h_rotate = findobj(h_dialog,'Tag','Rotate');
      rotatestr = get(h_rotate,'String');
      fontrotate = 0;
      if ~isempty(rotatestr)
         fontrotate = str2num(rotatestr);
      end

      h_interp = findobj(h_dialog,'Tag','texval');
      texval = get(h_interp,'Value');
      if texval == 1
         interpreter = 'tex';
      else
         interpreter = 'none';
      end

      h_cbo = get(h_edit,'UserData');

      set(h_cbo, ...
         'String',str, ...
         'FontName',fontname, ...
         'FontUnits',fontunits, ...
         'FontSize',fontsize, ...
         'FontWeight',fontweight, ...
         'FontAngle',fontangle, ...
         'Color',fontcolor, ...
         'Rotation',fontrotate, ...
         'Interpreter',interpreter);

      close(h_dialog)
      figure(h_fig)
      refresh(h_fig)

   end

end