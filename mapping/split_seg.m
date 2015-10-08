function mapdata2 = split_seg(mapdata,pos)
%Inserts NaN values to split a longitude/latitude array at specified positions
%
%syntax: mapdata2 = split_seg(mapdata,pos)
%
%input:
%  mapdata = 2-column array of longitude/latitude values
%  pos = array of row positions
%
%output:
%  mapdata2 = modified array
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
   
	mapdata2 = mapdata(1:pos(1),:);

	for n = 2:length(pos)   
	   mapdata2 = [mapdata2 ; NaN NaN ; mapdata(pos(n-1)+1:pos(n),:)];   
	end

	mapdata2 = [mapdata2 ; NaN NaN ; mapdata(pos(length(pos))+1:size(mapdata,1),:)];

end