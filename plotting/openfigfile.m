function openfigfile(fn,pn)
%Opens a MATLAB .fig file, prompting for the filename if omitted
%
%syntax: openfilefile(fn,pn)
%
%input:
%  fn = filename of figure
%  pn = pathname of figure
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

curpath = pwd;
filemask = '*.fig';

if exist('pn','var') ~= 1
   pn = curpath;
elseif exist(pn,'dir') ~= 7
   pn = curpath;
end

if exist('fn','var') ~= 1
   fn = '';
elseif exist([pn,filesep,fn]) ~= 2
   filemask = fn;
   fn = '';
end

if isempty(fn)
   cd(pn)
   [fn,pn] = uigetfile(filemask,'Select a figure file to open');
   cd(curpath)
   drawnow
   if fn == 0
      fn = '';
   end
end

if ~isempty(fn)
   try
      open([pn,filesep,fn])
   catch
      disp(['errors occurred opening ',fn])
   end
end