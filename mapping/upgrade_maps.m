function upgrade_maps(pn)
%Upgrades maps figures to include the latest versions of the GCE polygon database, map menus and buttons
%
%syntax: upgrade_maps(pn)
%
%inputs:
%  pn = pathname (default = pwd)
%
%outputs:
%  none
%
%(c)2005 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%
%last modified: 13-Apr-2005

if exist('pn') ~= 1
   pn = pwd;
end

curpath = pwd;

cd(pn)
d = dir('*.fig');
v = load('gce_sites.ply','-mat');
polydata = v.polydata;

for n = 1:length(d)
   try
      open(d(n).name)
      h_fig = gcf;
      center_fig(h_fig,0)
      h_poly = findobj(h_fig,'Tag','mnuPolygons');
      set(h_poly,'userdata',polydata)
      mapmenu replace
      mapbuttons replace
      hgsave(h_fig,d(n).name)
      close(h_fig)
      disp(['successfully updated ',d(n).name])
      drawnow
   catch
      disp(['failed to update ',d(n).name])
      drawnow
   end
end

cd(curpath)