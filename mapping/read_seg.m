function mapdata2 = read_seg(mapdata,segs)
%Reads the array of segments specified by 'segs' in 'mapdata'
%(segments can be in any order and repeated to generate replicates)
%
%syntax:  mapdata2 = read_seg(mapdata,segs)
%
%input:
%  mapdata = 2-column array of longitude and latitude
%  segs = array of segment numbers (where segments are blocks of coordinates in mapdata separated by NaN/NaN)
%
%output:
%  mapdata2 = updated map data containing only the specified segments
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


mapdata2 = [];

if nargin == 2
   
   mapdata = fixcoast(mapdata);
   
   I = find(isnan(mapdata(:,1)));
   numsegs = length(I)-1;
   
   if numsegs > 0
      
      if min(segs) > 0 && max(segs) <= numsegs
                  
         for n = 1:length(segs)
            
            mapdata2 = [mapdata2 ; NaN NaN ; mapdata(I(segs(n))+1:I(segs(n)+1)-1,:)];
            
         end
         
         mapdata2 = [mapdata2 ; NaN NaN];
         
      else  %invalid segs
      
	      disp(' ')
   	   disp(['invalid segment array - values must be in the range 1:' int2str(numsegs)])
      	disp(' ')
      
      end        
      
   else  %unsegmented
      
      disp(' ')
      disp('map data is not segmented')
      disp(' ')
      
   end
   
else
   
   disp(' ')
   disp('insufficient argments for function:')
   disp(' ')
   help read_seg
   disp(' ')
   
end

