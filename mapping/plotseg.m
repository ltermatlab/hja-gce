function plotseg(mapdata,segnum,c1,c2)
%Plot a specific segment of a coastline data file using the 'fillseg' function
%
%syntax:  plotseg(mapdata,segnum,fillcolor,edgecolor)
%
%input:
%  mapdata = 2-column array of longitude and latitude
%  segnum = segment number
%  c1 = color for polygon fill
%  c2 = color for polygon edge
%
%output:
%  none
%
%(c)2008 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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

mapdata = fixcoast(mapdata);

I = find(isnan(mapdata(:,1)));

if ~isempty('I')
   if length(I) > segnum
      seg = mapdata(I(segnum):I(segnum+1),:);
      seglen = size(seg,1);
      if ~isempty(seg)
         if ~exist('c1')
            c1 = [.8 .8 .8];
            c2 = [0 0 0];
         elseif ~exist('c2')
            c2 = [0 0 0];
         end
         fillseg(seg,c1,c2);
         hold on
         plot(seg(2,1),seg(2,2),'go',seg(seglen-1,1),seg(seglen-1,2),'rx')
         hold off
      else
         disp(' ')
         disp('no data to plot')
         disp(' ')
      end
   else
      disp(' ')
      disp('invalid segment')
      disp(' ')
   end
else
   disp(' ')
   disp('data is not segmented')
   disp(' ')
end
