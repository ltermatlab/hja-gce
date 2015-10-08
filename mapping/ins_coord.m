function mapdata2 = ins_coord(coords,mapdata,segnum,append,newseg)
%Inserts gps coordinates into a map longitude/latitude array to replace a specified segment
%
%syntax:  mapdata2 = ins_coord(coords,mapdata,segnum,append,newseg)
%
%input:
%  coords = nx2 matrix of lon,lat to insert
%  mapdata = nx2 matrix of lon,lat with segments separated by [NaN NaN]
%  segnum = target segment for insertion
%  append = 1 (or omitted) to append 'coords' after segment, 0 to prepend
%  newseg = 1 to insert 'coords' as a new segment, 0 (or omitted) to 
%           append/prepend to target segment
%
%output:
%  mapdata2 = updated map data array
%
%(c)2002-2005 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 15-Nov-2005

if ~exist('segnum')
   segnum = 1;
end

if ~exist('append')
   append = 1;
end

if ~exist('newseg')
   newseg = 0;
end

if newseg == 1
   pad = [NaN NaN];
else
   pad = [];
end

mapdata2 = [];

mapdata = fixcoast(mapdata);
len = size(mapdata,1);

I = find(isnan(mapdata(:,1)));
segs = length(I)-1;

if segs > 0 & size(coords,2) == 2
   
   if segnum <= segs
      
	   if append == 1
         
    		if I(segnum+1) == len  %last seg
		      mapdata2 = [mapdata(1:len-1,:); pad ; coords ; NaN NaN];
	      else
     		   mapdata2 = [mapdata(1:I(segnum+1)-1,:); pad ; coords ; mapdata(I(segnum+1):len,:)];
   	   end
         
	   else  %prepend
      
    		if I(segnum) == 1  %first seg
		      mapdata2 = [NaN NaN ; coords ; pad ; mapdata(2:len,:)];
	      else
     		   mapdata2 = [mapdata(1:I(segnum),:) ; coords ; pad ; mapdata(I(segnum)+1:len,:)];
   	   end
         
	   end
       
   else
      
   	disp(' ')
      disp(['segment out of range - only ' int2str(segs) ' segments in map data'])
      disp(' ')
      
   end
   
else
   
   disp(' ')
   disp('invalid input arguments')
   disp(' ')
   
end
