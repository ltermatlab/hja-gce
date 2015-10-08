function h_db = distbar(pos,distmajor,distminor,distheight,fontsize,fontweight,barcolor,retain)
%Creates a checked distance bar with alternating checked ticks for a map plot.
%The function returns an array of graphics handles for all the elements of
%the distance bar.
%
%syntax:  h_db = distbar(pos,distmajor,distminor,distheight,fontsize,fontweight,color,retain)
%
%inputs:
%  pos = position for top-left corner of distance bar objects (in data units)
%  distmajor = total length of bar in km
%  distminor = length of minor tick patches in km
%  distheight = height of bar in km
%  fontsize = fontsize for bar labels (default = axis fontsize)
%  fontweight = fontweight for bar labels (default = axis fontweight)
%  barcolor = RBG color array for outline and labels (default = [0 0 0])
%  retain = option to retain existing distance bars
%    0 = no (default)
%    1 = yes
%
%output:
%  h_db = array of object handles for distance bar elements
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
%last modified: 08-Feb-2004

if nargin >= 2

   if isempty(pos)
      [x,y] = ginput(1);
      pos = [x,y];
      drawnow
   end

   ax = axis;
   if min(ax) >= -180 & max(ax) <= 180  %assume decimal degrees
      scalefactor = (ax(2)-ax(1)) ./ gpsdistk([ax(1) mean([ax(3),ax(4)])],[ax(2) mean([ax(3),ax(4)])]);
   else  %assume meters
      scalefactor = 1000;
   end

   wid_major = distmajor .* scalefactor;

   if ~exist('retain')
      retain = 0;
   elseif retain ~= 0
      retain = 1;
   end

   if ~exist('barcolor')
      barcolor = [0 0 0];
   end

   if ~exist('fontweight')
      fontweight = get(gca,'fontweight');
   elseif ~isstr('fontweight')
      fontweight = get(gca,'fontweight');
   end

   if ~exist('fontsize')
      fontsize = get(gca,'fontsize');
   end

   if exist('distminor') ~= 1
      wid_minor = wid_major;
   else
      wid_minor = distminor .* scalefactor;
   end

   if exist('distheight') ~= 1
      ht_bar = (ax(4)-ax(3)) .* 0.02;
   else
      ht_bar = distheight .* scalefactor;
   end

   if retain == 0
      h = findobj(gcf,'tag','distbar');
      if ~isempty(h)
         delete(h)
      end
   end

   h_db = patch([pos(1) pos(1)+wid_major pos(1)+wid_major pos(1)], ...
      [pos(2) pos(2) pos(2)-ht_bar pos(2)-ht_bar],[0 0 0]);

   if wid_minor < wid_major  %create alternating stripes

      stripes = ceil(distmajor ./ distminor);  %calc maximum number of stripes to draw

      for n = 1:stripes

         xpos = [pos(1)+wid_minor.*(n-1) min(pos(1)+wid_minor.*(n-1)+wid_minor,pos(1)+wid_major) ...
               min(pos(1)+wid_minor.*(n-1)+wid_minor,pos(1)+wid_major) pos(1)+wid_minor.*(n-1)];

         if floor(n./2) == n./2  %even # of stripes
            ypos = [pos(2) pos(2) pos(2)-ht_bar./2 pos(2)-ht_bar./2];
         else
            ypos = [pos(2)-ht_bar./2 pos(2)-ht_bar./2 pos(2)-ht_bar pos(2)-ht_bar];
         end

         h = patch(xpos,ypos,[1 1 1]);

         h_db = [h_db ; h];

      end

   end

   %create black boundary
   h = line('XData',[pos(1) pos(1)+wid_major pos(1)+wid_major pos(1)], ...
      'YData',[pos(2) pos(2) pos(2)-ht_bar pos(2)-ht_bar], ...
      'Color',barcolor, ...
      'LineWidth',1);

   h_db = [h_db ; h];

   if fontsize > 0

      fontname = get(gca,'fontname');

      h = text(pos(1),pos(2)-ht_bar.*1.05,'0', ...
         'HorizontalAlignment','center', ...
         'VerticalAlignment','top', ...
         'FontName',fontname, ...
         'FontSize',fontsize, ...
         'FontWeight',fontweight, ...
         'Color',barcolor, ...
         'Clipping','on');

      h_db = [h_db ; h];

      h = text(pos(1)+wid_major,pos(2)-ht_bar.*1.05,[num2str(distmajor) ' km'], ...
         'HorizontalAlignment','left', ...
         'VerticalAlignment','top', ...
         'FontName',fontname, ...
         'FontSize',fontsize, ...
         'Fontweight',fontweight, ...
         'Color',barcolor, ...
         'Clipping','on');

      h_db = [h_db ; h];

      set(h_db,'Tag','distbar','ButtonDownFcn','textedit')

   end

else  %too few arguments

   h_db = [];

end
