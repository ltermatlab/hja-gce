function ui_progressbar(op,data,titlestr)
%Creates a graphical progress bar to illustrate the status of long-running processes
%
%syntax: ui_proressbar(op,data,title)
%
%inputs:
%  op = operation:
%    'init' to create to dialog (deletes any prior instances)
%    'update' to update the bar
%    'close' to close the dialog
%  data = data to display
%    for op = 'init', total number of steps to track
%    for op = 'update', current step to plot
%  title = title string to display above the progress bar (default = 'Current Progress')
%
%outputs:
%  none
%
%
%(c)2002-2012 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 08-Jun-2012

switch op

   case 'init'  %initialize dialog

      if nargin >= 2

         %set default title if omitted
         if exist('titlestr','var') ~= 1
            titlestr = 'Current Progress';
         end

         %check for prior instance and delete
         if ~isempty(findobj)
            h_dlg = findobj('Tag','dlgProgressBar');
         else
            h_dlg = [];
         end

         if ~isempty(h_dlg)
            delete(h_dlg)
         end

         %get screen metrics
         res = get(0,'ScreenSize');

         %generate dialog figure
         h_dlg = figure('Name','Progress', ...
            'Position',[(res(3)-450).*0.5 (res(4)-90).*0.5 450 90], ...
            'Color',[.95 .95 .95], ...
            'NumberTitle','off', ...
            'Menubar','none', ...
            'Toolbar','none', ...
            'Resize','off', ...
            'Units','pixels', ...
            'Tag','dlgProgressBar', ...
            'UserData',data);

         %disable docking
         if mlversion >= 7
            set(h_dlg,'WindowStyle','normal')
            set(h_dlg,'DockControls','off')
         end

         %add axis for progress bar
         axes('Parent',h_dlg, ...
            'Units','normalized', ...
            'Position',[0.1 0.25 0.8 0.25], ...
            'Xtick',[], ...
            'Ytick',[], ...
            'Color',[1 1 1], ...
            'Xlim',[0 data], ...
            'Ylim',[0 1], ...
            'Box','on');

         %add initial title
         title(titlestr,'Fontsize',11,'HorizontalAlignment','center');

      end

   case 'close'  %close dialog

      h_dlg = findobj('Tag','dlgProgressBar');

      if ~isempty(h_dlg)
         delete(h_dlg)
         drawnow
      end

   case 'update'  %update dialog

      h_dlg = findobj('Tag','dlgProgressBar');

      if length(h_dlg) == 1

         %get axis handle
         h_ax = get(h_dlg,'CurrentAxes');

         %calculate steps
         steps = data;
         totalsteps = get(h_dlg,'UserData');
         steps = min(steps,totalsteps);

         %get handle for existing bar and delete
         h_bar = findobj(h_ax,'Tag','bar');
         if ~isempty(h_bar)
            delete(h_bar)
         end

         %update title
         if exist('titlestr','var') == 1
            set(get(h_ax,'Title'),'String',titlestr,'Interpreter','none')
         end

         %add revised bar
         h_bar = patch([0 ; 0 ; steps ; steps ; 0],[0 1 1 0 0],[0 0 .8]);
         set(h_bar,'Tag','bar');

         drawnow

         %auto-close after pausing if exceed maximum steps
         if steps >= totalsteps
            pause(0.5)
            ui_progressbar('close')
         end

      end

end