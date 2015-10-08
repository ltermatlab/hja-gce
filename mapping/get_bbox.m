function get_bbox(cb,plotopt,clr)
%Returns a bounding box based on dragging a rectangle on a map figure, optionally plotting the result
%(note that this function must be associated with the 'WindowButtonDownFcn' of the map figure)
%
%syntax: get_bbox(cb,plotopt,color)
%
%inputs:
%  cb = callback to execute upon completion (must reference 'bbox' variable to return data)
%  plotopt = option to plot the bounding box after creation
%    0 = no (default)
%    1 = yes
%  color = bounding box color (default = 'g')
%
%outputs:
%  bbox = bounding box coordinates ([minlon,maxlon,minlat,maxlat])
%
%
%(c)2004-2012 by Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 09-Nov-2012

%set defaults for omitted arguments
if exist('cb','var') ~= 1
   cb = 'disp(bbox)';
end

if exist('plotopt','var') ~= 1
   plotopt = 0;
end

if exist('clr','var') ~= 1
   clr = 'g';
end

%get figure and axis handles
h_fig = gcf;
h_ax = get(h_fig,'CurrentAxes');

figunits = get(h_fig,'Units');  %buffer current figure units
set(h_fig,'Units','pixels')    %set units to pixels

pt = get(h_fig,'CurrentPoint');
rec = rbbox([pt 0 0]);

if rec(3) > 1 && rec(4) > 1
   
   axunits = get(h_ax,'Units');         %buffer original units
   set(h_ax,'Units','pixels');           %set axis units = pixels
   axposf = get(h_ax,'Position');       %get axis position
   set(h_ax,'Units',axunits)            %reset original units
   
   %get axis limits
   xlim = get(h_ax,'XLim');
   ylim = get(h_ax,'YLim');
   xdif = abs(xlim(1)-xlim(2));
   ydif = abs(ylim(1)-ylim(2));
   
   %adjust axis position to reflect true size in non-square plots
   ax = axis;
   if abs(ax(1)) <= 360
      ar = get(h_ax,'PlotBoxAspectRatio');
   else
      ar = 1;
   end

   if ar(1) < 1  %reduced y-axis      
      trueht = axposf(3)./ar(1);
      axposf = [axposf(1) axposf(2)+(axposf(4)-trueht).*0.5 axposf(3) trueht];      
   elseif ar(1) > 1  %reduced x-axis      
      truewid = axposf(4).*ar(1);
      axposf = [axposf(1)+(axposf(3)-truewid).*0.5 axposf(2) truewid axposf(4)];      
   end
   
   %get rectangle pos w/in axis
   recposf = [rec(1)-axposf(1) rec(2)-axposf(2) rec(3)+1 rec(4)+1];
   
   %get normalized rect pos
   recposn = [max(0,min(1,recposf(1)./axposf(3))) ...
         max(0,min(1,recposf(2)./axposf(4))) ...
         max(0,min(1,recposf(3)./axposf(3))) ...
         max(0,min(1,recposf(4)./axposf(4)))];
   
   %calculate bounding box in data units
   bbox = [xlim(1)+recposn(1).*xdif, xlim(1)+(recposn(1)+recposn(3)).*xdif, ...
         ylim(1)+recposn(2).*ydif, ylim(1)+(recposn(2)+recposn(4)).*ydif];
   
   if plotopt == 1
      h = findobj(gcf,'tag','boundingbox');
      if ~isempty(h)
         delete(h)
      end
      hold on
      h = plot([bbox(1),bbox(1),bbox(2),bbox(2),bbox(1)],[bbox(3),bbox(4),bbox(4),bbox(3),bbox(3)],[clr,'-']);
      set(h,'tag','boundingbox','linewidth',2)
   end
   
   if ~isempty(cb)
      eval(cb,'')
   end
   
else
   
   %restore original figure units
   set(h_fig,'Units',figunits)

end


