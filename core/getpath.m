function pn = getpath(pathtype)
%Retrieves path cache information from the active GCE Data Toolbox editor window
%
%syntax: pn = getpath(pathtype)
%
%inputs:
%  pathtype = type of path
%     'load' = load/import path
%     'save' = save/export path
%
%outputs:
%  pn = pathname
%
%
%(c)2012 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 12-Dec-2012

%init output
pn = '';

if nargin == 1
   
   %check for open windows to avoid opening an empty figure
   if length(findobj) >= 1
      
      %get handles for all open editor windows
      h_fig = findobj('Tag','dlgDSEditor');
      
      if ~isempty(h_fig)
         
         %get tag based on pathtype
         if strcmp(pathtype,'save')
            tag = 'mnuSave';
         else
            tag = 'mnuLoad';
         end
         
         %get relevant path from cache
         h = findobj(h_fig(end),'Tag',tag);
         pn = get(h,'UserData');
         
      end
      
   end
   
end