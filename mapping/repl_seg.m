function mapdata2 = repl_seg(mapdata,segnum,coords)
%Replaces the contents of segment 'segnum' in 'mapdata' with 'coords'
%(if 'coords' is blank or omitted, the segment will be removed)
%
%syntax:  mapdata2 = repl_seg(mapdata,segnum,coords)
%
%input:
%  mapdata = 2-column array of longitude and latitude
%  segnum = segment number
%  coords = array of new coordinates
%
%output:
%  mapdata2 = updated mapdata
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

if ~exist('coords')
   coords = [NaN NaN];
else
   coords = fixcoast(coords);
end

mapdata2 = [];

mapdata = fixcoast(mapdata);
len = size(mapdata,1);

I = find(isnan(mapdata(:,1)));
segs = length(I)-1;

if segs > 0
   
   if segnum <= segs
      
      if segnum == 1  %first segment
         
         mapdata2 = [coords ; mapdata(I(2)+1:len,:)];
         
      elseif segnum == segs  %last segment
         
         mapdata2 = [mapdata(1:I(segs)-1,:) ; coords];
         
      else  %middle
         
         mapdata2 = [mapdata(1:I(segnum)-1,:) ; coords ; mapdata(I(segnum+1)+1:len,:)];
         
      end
      
   else
      
      disp(' ')
      disp(['invalid segment - only ' int2str(segs) ' segments in map data'])
      disp(' ')
      
   end
   
else
   
   disp(' ')
   disp('data is not segmented')
   disp(' ')
   
end
