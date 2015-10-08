function previewdata(op,vals,fstr)
%Displays a preview of formatted data in a scrolling text box control.
%
%syntax: previewdata(op,vals,fstr)
%
%inputs:
%  op = operation ('init' to open dialog)
%  vals = array of values (numerical array or cell array of strings)
%  fstr = format string (see help on 'sprintf' for details)
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
%last modified: 03-Apr-2002

if nargin == 0
   op = 'init';
end

switch op

case 'init'

   if nargin == 3

      if ~iscell(vals)
	      try
      	   len = length(vals);
		      str = cell(len,1);
         	for n = 1:len
      	      str{n} = sprintf(fstr,vals(n));
   	      end
	      catch
         	str = '';
      	end
   	else
	      str = vals;
      end

      if ~isempty(str)

         if length(findobj) > 1
            h_fig = gcf;
         else
            h_fig = [];
         end

         res = get(0,'ScreenSize');

	      if strcmp(computer,'PCWIN')
   	      font = 'Courier New';
      	else
         	font = 'Courier';
         end

         h_dlg = figure('visible','off', ...
            'color',[.95 .95 .95], ...
            'name','Preview', ...
            'numbertitle','off', ...
            'menubar','none', ...
            'toolbar','none', ...
            'keypressfcn','figure(gcf)', ...
            'units','pixels', ...
            'position',[max(0,0.5.*(res(3)-200)) max(50,0.5.*(res(4)-400)) 200 400], ...], ...
            'resize','off', ...
            'tag','dlgPreviewFormat', ...
            'userdata',h_fig);

         h = uicontrol('parent',h_dlg, ...
            'style','listbox', ...
            'backgroundcolor',[1 1 1], ...
            'fontname',font, ...
            'fontsize',10, ...
            'string',str, ...
            'units','pixels', ...
            'position',[1 26 198 373], ...
            'min',1, ...
            'max',2, ...
            'value',1, ...
            'tag','listbox');

         h = uicontrol('parent',h_dlg, ...
            'style','pushbutton', ...
            'string','Close Preview Window', ...
            'units','pixels', ...
            'position',[1 1 198 25], ...
            'callback','previewdata(''close'')', ...
            'tag','close');

         set(h_dlg,'Visible','on');
         drawnow

      end

   end

case 'close'

   h_fig = get(gcbf,'UserData');

   close(gcbf)

   if ~isempty(h_fig)
      eval('figure(h_fig)','error')
   end

end
