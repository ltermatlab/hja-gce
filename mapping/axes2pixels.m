function [fig_pixels,axes_pixels,fig_data,axes_data] = axes2pixels(h_fig)
%Returns the positions of a figure and its current axis object in pixels and data units
%
%syntax: [fig_pixels,axes_pixels,fig_data,axes_data] = axes2pixels(h_fig)
%
%input:
%  h_fig = handle of figure to analyze (default = gcf)
%
%output:
%  fig_pixels = position of the figure in pixels
%  axes_pixels = position of the current axes in pixels
%  fig_data = position of the figure in data units
%  axes_data = position of the current axes in data units
%
%
%(c)2004 by Wade Sheldon
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
%Department of Marine Sciences
%University of Georgia
%Athens, Georgia  30602-3636
%sheldon@uga.edu
%
%last modified: Dec-16-2001

if nargin == 0
   h_fig = gcf;
end

h_ax = get(h_fig,'currentaxes');

%buffer original units
figunits = get(gcf,'units');
axunits = get(gca,'units');

ax = axis;
axes_data = [ax(1),ax(3),ax(2)-ax(1),ax(4)-ax(3)];

set(gcf,'units','pixels')
fig_pixels = get(gcf,'position');
set(gcf,'units',figunits)

set(h_ax,'units','pixels')
axes_pixels = get(gca,'position');
set(h_ax,'units','normal')
axes_norm = get(gca,'position');
set(h_ax,'units',axunits)

w = axes_data(3)./axes_norm(3);
h = axes_data(4)./axes_norm(4);
l = axes_data(1)-0.5*w*(1-axes_norm(3));
b = axes_data(2)-0.5*w*(1-axes_norm(4));

fig_data = [l,b,w,h];
