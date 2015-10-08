function addnote(pos,str)
%Adds an annotation to a plot and assigns the 'ButtonDownFcn' to 'editnote' for text editing and repositioning
%
%syntax: addnote(pos,str)
%
%input:
%  pos = initial position of string (default = determined using 'ginput')
%  str = initial string to plot (default = '')
%
%
%(c)2002,2003,2004 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 09-May-2005

h_fig = gcf;

if ~exist('str')
   str = 'Note';
end

if ~exist('pos')

   fcn = get(h_fig,'WindowButtonDownFcn');  %buffer mouse fcn
   set(h_fig,'WindowButtonDownFcn','')  %clear fcn

   [x,y,button] = ginput(1);
   if button == 1
      pos = [x,y];
   else
      pos = [];
   end

   set(h_fig,'WindowButtonDownFcn',fcn)  %restore fcn

end

if ~isempty(pos)

   pos = [pos(:)',zeros(1,3)];  %pad vector to avoid errors

   h = text(pos(1),pos(2),pos(3),str, ...
      'FontName','Helvetica', ...
      'FontUnits','points', ...
      'FontSize',10, ...
      'FontWeight','normal', ...
      'FontAngle','normal', ...
      'Color',[0 0 1], ...
      'Rotation',0, ...
      'ButtonDownFcn','editnote', ...
      'HorizontalAlignment','center', ...
      'VerticalAlignment','middle', ...
      'Interpreter','none', ...
      'Clipping','on', ...
      'Tag','annotation', ...
      'UserData','temp');

   editnote('init',h);

end