function mapcolor(op)
%Dialog called by 'mapmenu' for selecting map colors
%
%syntax: mapcolor(op)
%
%input:
%  op = operation (default = 'init')
%
%output:
%  none
%
%(c)2002,2003,2004 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 25-Jul-2008

if ~exist('op')
   op = 'init';
end

if strcmp(op,'init')

   h_fig = gcf;
   h_dlg = findobj('Tag','dlgMapcolor');

   if ~isempty(h_dlg)  %check for prior instance
      close(h_dlg)
   end

   if strcmp(get(h_fig,'Tag'),'MapPlot') | strcmp(get(h_fig,'Tag'),'BBox_Map') %check for valid figure

      h_color = findobj(h_fig,'Tag','mnuColor');
      clr = get(h_color,'UserData');

      res = get(0,'ScreenSize');

      h_dlg = figure('Visible','off', ...
         'Color',[0.9 0.9 0.9], ...
         'KeyPressFcn','figure(gcf)', ...
         'MenuBar','none', ...
         'Name','Map Colors', ...
         'NumberTitle','off', ...
         'Position',[(res(3)-219).*0.5 (res(4)-186).*0.5 219 186], ...
         'Tag','dlgMapcolor', ...
         'ToolBar','none', ...
         'DefaultuicontrolUnits','pixels');

      h = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[0.9 0.9 0.9], ...
         'Position',[19 148 80 18], ...
         'String','Shoreline Color', ...
         'Style','text', ...
         'Tag','lblShore');

      h = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[0.9 0.9 0.9], ...
         'Position',[19 112 80 18], ...
         'String','Land Color', ...
         'Style','text', ...
         'Tag','lblLand');

      h = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[0.9 0.9 0.9], ...
         'Position',[19 77 80 18], ...
         'String','Background', ...
         'Style','text', ...
         'Tag','lblBackground');

      h_shore = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',clr{1}, ...
         'Position',[105 146 26 25], ...
         'Style','frame', ...
         'Tag','Shore');

      h_land = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',clr{2}, ...
         'Position',[105 108 26 25], ...
         'Style','frame', ...
         'Tag','Land');

      h_back = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',clr{3}, ...
         'Position',[105 74 26 25], ...
         'Style','frame', ...
         'Tag','Background');

      h = uicontrol('Parent',h_dlg, ...
         'Units','points', ...
         'Position',[107.25 108.75 39.75 18], ...
         'String','Change', ...
         'Tag','cmdShore', ...
         'Callback','mapcolor(''shore'')');

      h = uicontrol('Parent',h_dlg, ...
         'Units','points', ...
         'Position',[107.25 81 39.75 18], ...
         'String','Change', ...
         'Tag','cmdLand', ...
         'Callback','mapcolor(''land'')');

      h = uicontrol('Parent',h_dlg, ...
         'Units','points', ...
         'Position',[107.25 54.75 39.75 18], ...
         'String','Change', ...
         'Tag','cmdBackground', ...
         'Callback','mapcolor(''background'')');

      h = uicontrol('Parent',h_dlg, ...
         'Units','points', ...
         'Callback','mapcolor(''eval'')', ...
         'Position',[24.75 14.25 50.25 19.5], ...
         'String','Accept', ...
         'Tag','cmdAccept');

      h = uicontrol('Parent',h_dlg, ...
         'Callback','mapcolor(''cancel'')', ...
         'Position',[125 20 67 26], ...
         'String','Cancel', ...
         'Tag','cmdCancel');

      set(h_dlg, ...
         'Visible','on', ...
         'UserData',struct('h_fig',h_fig,'h_color',h_color,'origcolor',{clr}, ...
         'h_shore',h_shore,'h_land',h_land,'h_back',h_back));

   end

else  %handle callbacks

   h_dlg = findobj('Tag','dlgMapcolor');
   vals = get(h_dlg,'UserData');

   switch op

   case 'cancel'

      close(h_dlg)

      figure(vals.h_fig)

      drawnow

   case 'shore'

      c = get(vals.h_shore,'BackgroundColor');
      c = uisetcolor(c,'Choose a shoreline color');

      if length(c) == 3
         set(vals.h_shore,'BackgroundColor',c)
      end

   case 'land'

      c = get(vals.h_land,'BackgroundColor');
      c = uisetcolor(c,'Choose a land color');

      if length(c) == 3
         set(vals.h_land,'BackgroundColor',c)
      end

   case 'background'

      c = get(vals.h_back,'BackgroundColor');
      c = uisetcolor(c,'Choose a background color');

      if length(c) == 3
         set(vals.h_back,'BackgroundColor',c)
      end

   case 'eval'

      c_shore = get(vals.h_shore,'BackgroundColor');
      c_land = get(vals.h_land,'BackgroundColor');
      c_back = get(vals.h_back,'BackgroundColor');

      c_orig = vals.origcolor;

      if sum(c_shore~=c_orig{1})~=0 | sum(c_land~=c_orig{2})~=0 | sum(c_back~=c_orig{3})~=0
         set(vals.h_color,'UserData',[{c_shore},{c_land},{c_back}])
         close(h_dlg)
         figure(vals.h_fig)
         drawnow
         mapmenu('color')
      else
         close(h_dlg)
         figure(vals.h_fig)
         drawnow
      end

   end

end
