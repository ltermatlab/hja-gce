function ui_viewmetadata(s,opt)
%Displays various metadata components of a GCE Data Structure in a scrolling list box viewer
%
%syntax: ui_viewmetadata(s,style)
%
%input:
%  s = data structure
%  style = metadata style option
%
%output:
%  none
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
%last modified: 25-Jul-2007

if nargin == 2

   if gce_valid(s) == 1

      if strcmp(opt,'hist')
         str_caption = 'Processing History';
      else
         str_caption = 'Formatted Metadata';
      end

      ui_viewtext('Please wait while the metadata is updated and formatted ...', ...
         0,0,str_caption);

      h_dlg = gcf;

      h_listbox = findobj(h_dlg,'Tag','listbox');

      if ~isempty(h_listbox)

         set(h_dlg,'Pointer','Watch')
         drawnow

         %format cell array of strings
         if strcmp(opt,'hist')
            str = [{s.version};
               {''};
               {'Data Processing History'};
               {'-----------------------'};
               cellstr(listhist(s,1,100,13))];
         else
            str = listmeta(s,opt,'','','cell');
            if isempty(str)
               str = {'(invalid format option)'};
            end
         end

         set(h_listbox,'String',str,'UserData',str)
         set(h_dlg,'Pointer','arrow')

         drawnow

      end

   end

end
