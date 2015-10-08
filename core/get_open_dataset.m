function [s,msg] = get_open_dataset(listwidth)
%Retrieves a data structure from an open editor window selected via listbox
%
%syntax: [s,msg] = get_open_dataset(listwidth)
%
%inputs:
%  listwidth = width of select list in pixels (default = 800 or horizontal screen size if <800)
%
%outputs:
%  s = data structure from the selected editor window
%  msg = text of any error message
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
%last modified: 05-Sep-2006

%init output
s = [];
msg = '';

%check for open figure windows (to avoid creating empty figure using gcf command)
if length(findobj) > 1
   
   %set default list width if omitted
   if exist('listwidth','var') ~= 1
      screenres = get(0,'ScreenSize');
      if screenres(3) >= 800
         listwidth = 800;
      else
         listwidth = screenres(3);
      end
   end
   
   %get handle of current figure (if applicable)
   h_gcf = gcf;
   h_cbo = gcbo;
   if ~isempty(h_cbo)
      h_caller = parent_figure(h_cbo);
   else
      h_caller = [];
   end
   
   %get handles of all open editor windows
   h = findobj('Tag','dlgDSEditor');
   
   if ~isempty(h)
      
      if ~isempty(h_caller)
         h = setdiff(h,h_caller);  %remove caller figure from list
      end
      
      if ~isempty(h)
         
         %generate select list contents using figure titles
         titlestr = [];         
         for n = 1:length(h)
            titlestr = [titlestr ; {get(h(n),'Name')}];
         end
         
         %call list dialog function for data set selection
         I_sel = listdialog('liststring',titlestr, ...
            'selectionmode','single', ...
            'name','Select Data Set', ...
            'promptstring','Select an Open Data Set to Retrieve', ...
            'listsize',[0 0 listwidth 250]);
         
         %check for user cancellation
         if ~isempty(I_sel)
            
            try
            
               figure(h(I_sel))  %set focus to selected figure
               
               ui_editor('senddata','assignin(''caller'',''data'',data)')  %retrieve data using ui_editor function call
               
               if ~isempty(h_caller)  %restore focus to calling figure
                  figure(h_caller)
               else
                  figure(h_gcf)  %restore focus to last current figure
               end
               
               if exist('data','var')
                  if gce_valid(data,'data')
                     s = data;  %assign retrieve data set to output
                  else
                     msg = 'failed to retrieve valid data set from selected editor window';
                  end
               else
                  msg = 'failed to retrieve data set from selected editor window';
               end
               
            catch
               msg = 'errors occurred retrieving data from the selected editor window';
            end
            
         end
         
      else
         msg = 'no other editor windows are currently open';
      end
      
   else
      msg = 'no editor windows are currently open';
   end
   
else
   msg = 'no editor windows are currently open';
end