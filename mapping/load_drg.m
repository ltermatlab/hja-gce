function load_drg(fn,pn,mapinfo)
%Loads a clipped USGS DRG map file in TIFF format, and uses the
%information in the structure 'mapinfo' to plot the image as a map
%
%   'fn' is the name of the TIFF file
%   'pn' is the path name
%   'mapinfo' is the map information structure (if omitted, the
%      function will look for a file 'mapinfo.mat' in the path
%
%syntax:  load_drg(fn,pn,mapinfo)
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
%last modified 28-Feb-2001

curpath = pwd;
error = 0;

if ~exist('pn')
   pn = curpath;
else
   eval(['cd ''' pn ''''],'pn = curpath;')
end

if ~exist('fn')
   [fn,pn] = uigetfile('*.tif','Select a clipped USGS DRG TIFF file to load');
   if fn == 0
      fn = '';
   end
elseif exist(fn) ~= 2
   exist(fn)
   fn = '';
end

if exist('mapinfo') ~= 1
   if exist('mapinfo.mat') == 2
      load mapinfo.mat
   end
else
   if ~isstruct(mapinfo)
      mapinfo = '';
   elseif ~isfield(mapinfo,'quadname')
      mapinfo = '';
   end
end

if ~isempty(fn) & ~isempty(mapinfo)

   files = {mapinfo.filename};

   I = find(strcmp(lower(files),lower(fn)));

   if ~isempty(I)

      w = mapinfo(I(1)).west;
      e = mapinfo(I(1)).east;
      s = mapinfo(I(1)).south;
      n = mapinfo(I(1)).north;
      str = mapinfo(I(1)).quadname;

      eval(['[img,cmap] = imread(''' fn ''',''tiff'');'],'error = 1;')

      if error == 0

         mapimage(img,cmap,w,e,s,n,str)

      end

   end

end

eval(['cd ''' curpath ''''])

