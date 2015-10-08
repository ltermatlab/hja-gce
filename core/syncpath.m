function syncpath(pn,pathtype)
%Synchronizes path cache information between GCE Data Toolbox editor windows
%
%syntax: syncpath(pn,pathtype)
%
%inputs:
%  pn = pathname to cache
%  pathtype = type of path
%     'load' = load/import path
%     'save' = save/export path
%
%outputs:
%  none
%
%
%(c)2002-2011 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 15-Mar-2011

if nargin == 2

    if length(findobj) >= 1  %check for open windows

        if isdir(pn)  %check path validity

            h_fig = findobj('Tag','dlgDSEditor');  %get handles for all open editor windows

            if strcmp(pathtype,'save')
                tag = 'mnuSave';
            else
                tag = 'mnuLoad';
            end

            %update relevant cache
            for n = 1:length(h_fig)
                h = findobj(h_fig(n),'Tag',tag);
                if ~isempty(h)
                    set(h,'UserData',pn)
                end
            end

        end

    end

end