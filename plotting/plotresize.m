function plotresize(h)
%Toggles plot select/move/resize for plot axes on a figure
%
%syntax:  plotresize(h)
%
%inputs:
%  h = figure to modify (default = gcf)
%
%outputs:
%  none
%
%(c)2002-2006 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 10-Feb-2006

%use current figure if not specified
if exist('h','var') ~= 1
   h = gcf;
end

%get menu item handle
h_menu = findobj(h,'Tag','mnuResizePlots');

if ~isempty(h_menu)

   %get axes handles, except legend
   h_ax = findobj(h,'Type','axes');
   h_legend = findobj(h,'Tag','legend');
   if ~isempty(h_legend)
      h_ax = setdiff(h_ax,h_legend);
   end

   %check state, set/unset selectmoveresize
   chk = get(h_menu,'Checked');
   if strcmp(chk,'off')
      set(h_menu,'Checked','on')
      fcn = 'selectmoveresize';
      hl = 'on';
   else
      set(h_menu,'Checked','off')
      fcn = '';
      hl = 'off';
   end

   %update axes
   for n = 1:length(h_ax)
      set(h_ax(n),'ButtonDownFcn',fcn,'SelectionHighlight',hl)
   end

end