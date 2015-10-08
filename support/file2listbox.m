function file2listbox(h_listbox,fn,pn)
%Loads an ASCII file and displays it in a uicontrol listbox
%
%syntax: file2listbox(h_listbox,fn,pn)
%
%inputs:
%  h_listbox = uicontrol handle of the listbox (default = first listbox of current figure,
%    or opens with ui_viewtext if no listbox available)
%  fn = filename of text file (prompted if omitted)
%  pn = path name of text file (default = pwd if fn specified, otherwise prompted)
%
%outputs:
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
%last modified: 28-Feb-2005

curpath = pwd;

if exist('h_listbox','var') ~= 1
   if length(findobj) > 1
      h_listbox = findobj(gcf,'Type','uicontrol','Style','listbox');
      if ~isempty(h_listbox)
         h_listbox = h_listbox(1);
      end
   else
      h_listbox = [];
   end
end

if exist('pn','var') ~= 1
   pn = curpath;
end

if exist('fn','var') ~= 1
   fn = '';
end

str = textfile2cell(fn,pn);

if ~isempty(str)
   
   if ~isempty(h_listbox)
      set(h_listbox,'String',str,'UserData',str)
      drawnow
   else
      ui_viewtext(str)
   end
   
end