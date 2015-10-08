function insetmap(clr,edge,boxlim)
%Opens a map figure window that displays the specified boundaries or the boundaries
%of the current map figure as a colored patch on a map of Georgia, S. Carolina and Florida.
%
%syntax:  insetmap(patchcolor,edgecolor,boxlimits)
%
%inputs:
%  patchcolor = colorspec to use for face color of the patch (default = [.6 .6 .6])
%  edgecolor = colorspec to use for the edge color of the patch (default = [0 0 0])
%  boxlim = array of lon/lat boundaries (default = axis limits of current axes)
%
%output:
%  none
%
%(c)2002-2010 Wade M. Sheldon
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
%Athens, GA 30602 USA
%
%last modified: 16-Sep-2010

if exist('clr') ~= 1
   clr = [.6 .6 .6];
   edge = [0 0 0];
elseif exist('edge') ~= 1
   edge = [0 0 0];
end

if exist('boxlim') ~= 1
   if length(findobj) > 1
      boxlim = axis;
   else
      boxlim = [];
   end
end

if ~isempty(boxlim) & exist('se_state_outlines.mat','file') == 2

   if min(boxlim) > 180
      boxlim
      [lon,lat] = utm2deg(17,boxlim(1:2)',boxlim(3:4)')
      boxlim = [lon',lat']
   end

   h = findobj('tag','insetmap');
   if ~isempty(h)
      delete(h)
   end

   load se_state_outlines  %load state polygons

   I = find(~isnan(map(:,1)));

   [axlims,ar] = gpsaxis([min(map(I,1)),min(map(I,2));max(map(I,1)),max(map(I,2))],2,0);

   wid = 400 .* ar(1);
   ht = 400 .* ar(2);
   res = get(0,'screensize');

   plotmap(map)
   mapmenu('tickoff')
   h_zoom = findobj(gcf,'tag','mapbtn_zoom');
   if ~isempty(h_zoom)
      set(h_zoom,'Value',1,'BackgroundColor',[0 1 0])
      mapbuttons('zoom')
   end
   mapbuttons('hide')

   set(gcf, ...
      'name','Inset Map', ...
      'position',[10,res(4)-(ht+50),wid,ht], ...
      'tag','insetmap');

   cla
   set(gca, ...
      'color',[1 1 1], ...
      'position',[0 0 1 1], ...
      'plotboxaspectratio',ar, ...
      'xlim',axlims(1:2), ...
      'ylim',axlims(3:4));

   set(get(gca,'title'),'String','')
   set(get(gca,'xlabel'),'String','')
   set(get(gca,'ylabel'),'String','')

   h_p = patch([boxlim(1),boxlim(1),boxlim(2),boxlim(2),boxlim(1)], ...
      [boxlim(3),boxlim(4),boxlim(4),boxlim(3),boxlim(3)], ...
      clr);
   set(h_p, ...
      'edgecolor',edge, ...
   	'tag','insetmappatch')

   line(map(:,1),map(:,2), ...
      'linestyle','-', ...
      'color',[0 0 0], ...
      'marker','none', ...
      'tag','insetmapstates');

   text(boxlim(2),mean(boxlim(3:4)),char(220), ...
      'fontname','Symbol', ...
      'fontsize',14, ...
      'fontweight','bold', ...
      'color',[0 0 0], ...
      'horizontalalignment','left', ...
      'verticalalignment','middle', ...
      'tag','insetmaparrow');

   drawnow

end
