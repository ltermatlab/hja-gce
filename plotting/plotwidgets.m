function plotwidgets(op,h_fig)
%Creates or removes standard GCE plot menus and toolbars from a MATLAB figure
%
%syntax: plotwidgets(op,h_fig)
%
%inputs:
%  op = option
%    'add' or 'on' = add toolbars, menus (default)
%    'remove' or 'off' = removes toolbars, menus
%    'refresh' = removes and then regenerates toolbars, menus
%  h_fig = handle of figure to modify (default = gcf)
%
%outputs:
%  none
%
%
%(c)2002-2008 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 20-Dec-2008

if nargin == 0
   op = 'add';
end

if exist('h_fig','var') ~= 1
   h_fig = gcf;
end

%get handles for tools, axis labels
h_mnu = findobj(h_fig,'Tag','mnuGCETools');
h_tool = findobj(h_fig,'Tag','plotbuttons');
h_t = get(gca,'Title');
h_x = get(gca,'XLabel');
h_y = get(gca,'YLabel');
h_z = get(gca,'ZLabel');

switch op
   case 'add'
      if isempty(h_mnu)
         plotmenu;
      end
      if isempty(h_tool)
         plotbuttons('add');
      end
      plotlabels;
   case 'remove'
      if ~isempty(h_mnu)
         h = findobj(h_mnu);
         delete(h)
      end
      if ~isempty(h_tool)
         plotbuttons('remove')
      end
      set([h_t,h_x,h_y,h_z],'ButtonDownFcn','')
   case 'refresh'
      plot_widgets('remove')
      plot_widgets('add')
   case 'off'  %catch remove variant
      plot_widgets('remove')
   case 'on'  %catch add variant
      plot_widgets('add')
end