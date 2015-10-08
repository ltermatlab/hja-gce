function h_fig = parent_figure(h)
%Determines the parent figure for any uicontrol handle (returns empty matrix
%if handle or figure don't exist)
%
%syntax: h_fig = parent_figure(h)
%
%
%(c)2002-2006 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 26-Jul-2007

h_fig = [];

if nargin == 1
   
   %check for valid handle and open figures
   if ~isempty(h) & length(findobj) > 1
      
      h_all = findobj;  %get array of all handles
      
      if ~isempty(find(h_all==h))  %check to see if h valid handle
         
         h_type = get(h,'type');
         
         while ~strcmp(h_type,'figure') & ~isempty(h)
            try
               h = get(h,'parent');
               h_type = get(h,'type');
            catch
               h = [];
               h_type = '';
            end
         end
         
         if strcmp(h_type,'figure')
            h_fig = h;
         end
         
      end
      
   end
   
end