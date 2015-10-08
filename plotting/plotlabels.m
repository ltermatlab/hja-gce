function plotlabels(titlestr,xstr,ystr,zstr,interpreter,h_ax)
%Adds the specified title and axis label strings to the current plot 
%and links each string object to the editing function 'textedit.m'.
%
%syntax:  plotlabels(titlestr,xstr,ystr,zstr,interpreter,h_ax)
%
%input:
%  titlestr = title string (default = 'Title')
%  xstr = x-axis label string (default = 'X')
%  ystr = y-axis label string (default = 'Y')
%  zstr = z-axis label string (default = 'Z' for 3D plots)
%  interpreter = text interpreter (default = 'tex')
%  h_ax = handle of plot axis to label (default = gca)
%
%(c)2002-2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 17-Oct-2013

%set default text interpreter if omitted
if exist('interpreter','var') ~= 1 || isempty(interpreter)
   interpreter = 'tex';
end

%set default axis handle if omitted
if exist('h_ax','var') ~= 1 || isempty(h_ax)
   h_ax = gca;
end

%get current axis label handles
h_t = get(h_ax,'Title');
h_x = get(h_ax,'XLabel');
h_y = get(h_ax,'YLabel');
h_z = get(h_ax,'ZLabel');

%set default font characteristics
titlefont = 18;
titleweight = 'bold';
xfont = 14;
xweight = 'bold';
yfont = 14;
yweight = 'bold';
zfont = 14;
zweight = 'bold';

%get existing title string and properties if not specified as input
if exist('titlestr','var') ~= 1
   titlestr = get(h_t,'String');
   if isempty(titlestr)
      titlestr = 'Title';
   else  %use current font size, weight
      titlefont = get(h_t,'FontSize');
      titleweight = get(h_t,'FontWeight');
   end
end

%get existing x-axis label string and properties if not specified as input
if exist('xstr','var') ~= 1
   xstr = get(h_x,'String');  %get current label
   if isempty(xstr)
      xstr = 'X';
   else  %use current font size, weight
      xfont = get(h_x,'FontSize');
      xweight = get(h_x,'FontWeight');
   end
end

%get existing y-axis label string and properties if not specified as input
if exist('ystr','var') ~= 1
   ystr = get(h_y,'String');  %get current label
   if isempty(ystr)
      ystr = 'Y';
   else  %use current font size, weight
      yfont = get(h_y,'FontSize');
      yweight = get(h_y,'FontWeight');
   end
end

%get existing z-axis label string and properties if not specified as input
if exist('zstr','var') ~= 1
   ax = axis;
   if length(ax) < 4
      zstr = get(h_z,'String');
      if isempty(zstr)
         zstr = 'Z';
      else  %use current font size, weight
         zfont = get(h_z,'FontSize');
         zweight = get(h_z,'FontWeight');
      end
   else
      zstr = '';
      zfont = get(h_z,'FontSize');
      zweight = get(h_z,'FontWeight');
   end
end

%generate arrays of handles, properties
handle = [h_t, h_x, h_y, h_z];
valuestr = [{titlestr},{xstr},{ystr},{zstr}];
fontsize = [titlefont, xfont, yfont, zfont];
fontweight = [{titleweight},{xweight},{yweight},{zweight}];

for n = 1:length(handle)
   str = valuestr{n};
   if ~isempty(str)
      set(handle(n), ...
         'String',str, ...
         'FontSize',fontsize(n), ...
         'FontWeight',fontweight{n}, ...
         'Interpreter',interpreter, ...
         'ButtonDownFcn','textedit')
   end
end
