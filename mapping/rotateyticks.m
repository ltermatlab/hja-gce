function rotateyticks(lbl)
%Converts Y-axis tick labels to text strings rotated at a 90° angle
%
%syntax:  rotateyticks(lbl)
%
%input:
%  lbl = optional character array to use for y-axis tick labels
%
%output:
%  none
%
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
%last modified: 19-Feb-2004

if nargin == 0
   lbl = '';
end

%check for prior labels, delete and regenerate automatic labels if found
h = findobj(gca,'tag','yticklabelstring');
if ~isempty(h)
   delete(h)
   if isempty(lbl)
      set(gca,'yticklabelmode','auto')
   end
end

ax = axis;
xlim = get(gca,'xlim');

tickpos = get(gca,'ytick');
I = find(tickpos >= ax(3) & tickpos <= ax(4));
tickpos = tickpos(I);

if isempty(lbl)
   lbl = get(gca,'yticklabel');
   if ~isempty(I)
      lbl = lbl(I,:);
   end
elseif size(lbl,1) < length(tickpos)  %pad tick labels with blanks to avoid index errors
   lbl = char(lbl,repmat('',length(tickpos)-size(lbl,1),1));
else
   lbl = lbl(1:length(tickpos),:);  %remove excess labels to avoid index errors
end

set(gca,'yticklabel',repmat('   ',length(tickpos),1))  %clear auto ticks if present

pos = [repmat(xlim(1)-0.01*(xlim(2)-xlim(1)),length(tickpos),1),tickpos'];

h = text(pos(:,1),pos(:,2),lbl, ...
   'rotation',90, ...
   'fontname',get(gca,'fontname'), ...
   'fontsize',get(gca,'fontsize'), ...
   'fontangle',get(gca,'fontangle'), ...
   'fontweight',get(gca,'fontweight'), ...
   'fontunits',get(gca,'fontunits'), ...
   'color',get(gca,'ycolor'), ...
   'verticalalignment','baseline', ...
   'horizontalalignment','center', ...
   'tag','yticklabelstring');
