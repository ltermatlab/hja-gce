function clipplottext
%Clips text on a 2D plot by toggling the visibility on or off based on axis position
%
%syntax: clipplottext
%
%(c)2002-2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 13-Apr-2015

if length(findobj) > 1

   %get handles of data axes
   h_ax = findobj(gcf,'type','axes');
   
   %exclude legend axes for legacy MATLAB versions
   if mlversion < 8.4
      for n = 1:length(h_ax)
         if strcmp(get(h_ax(n),'tag'),'legend')
            h_ax(n) = NaN;  %flag legend axes for omission
         end
      end
      h_ax = h_ax(~isnan(h_ax));
   end

   for n = 1:length(h_ax)
      axes(h_ax(n));
      ht = findobj(gca,'type','text');
      if ~isempty(ht)
         pos = get(ht,'position');
         if length(ht) > 1  %convert cells to double if multiples
            pos = reshape([pos{:}],3,length(ht))';
         end
         ax = axis;
         I = [pos(:,1)<ax(1) | pos(:,1)>ax(2) | pos(:,2)<ax(3) | pos(:,2)>ax(4)];
         Ioff = find(I);
         Ion = find(~I);
         set(ht(Ioff),'visible','off')
         set(ht(Ion),'visible','on')
      end
   end

end