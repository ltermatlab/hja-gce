function copypointlabels(h_fig1,h_fig2,tag)
%Copies point labels on a GCE map figure to another map figure
%
%syntax: copypointlabels(h_fig1,h_fig2,tag)
%
%input:
%  h_fig1 = handle of source figure
%  h_fig2 = handle of destination figure
%  tag = tag used for point labels (default = 'pointlabels')
%
%output:
%  none
%
%(c)2008 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 25-Jul-2008

if nargin >= 2
   
   if exist('tag') ~= 1
      tag = 'pointlabels';
   end
   
   hax = get(h_fig1,'currentaxes');
   hax2 = get(h_fig2,'currentaxes');
   
   h = findobj(hax,'tag',tag);

   for n = 1:length(h)
      s = get(h(n));
      flds = fieldnames(s);
      for m = 1:length(flds)
         switch s.Type
            case 'line'
               h0 = line('XData',s.XData, ...
                  'YData',s.YData, ...
                  'ZData',s.ZData, ...
                  'Color',s.Color, ...
                  'EraseMode',s.EraseMode, ...
                  'LineStyle',s.LineStyle, ...
                  'LineWidth',s.LineWidth, ...
                  'Marker',s.Marker, ...
                  'MarkerEdgeColor',s.MarkerEdgeColor, ...
                  'MarkerFaceColor',s.MarkerFaceColor, ...
                  'MarkerSize',s.MarkerSize, ...
                  'Tag',s.Tag);
            case 'text'
               h0 = text('BackgroundColor',s.BackgroundColor, ...
                  'Clipping',s.Clipping, ...
                  'Color',s.Color, ...
                  'EdgeColor',s.EdgeColor, ...
                  'EraseMode',s.EraseMode, ...
                  'FontAngle',s.FontAngle, ...
                  'FontName',s.FontName, ...
                  'FontSize',s.FontSize, ...
                  'FontUnits',s.FontUnits, ...
                  'FontWeight',s.FontWeight, ...
                  'HorizontalAlignment',s.HorizontalAlignment, ...
                  'Interpreter',s.Interpreter, ...
                  'LineStyle',s.LineStyle, ...
                  'LineWidth',s.LineWidth, ...
                  'Margin',s.Margin, ...
                  'Position',s.Position, ...
                  'Rotation',s.Rotation, ...
                  'String',s.String, ...
                  'Tag',s.Tag, ...
                  'Units',s.Units, ...
                  'UserData',s.UserData, ...
                  'VerticalAlignment',s.VerticalAlignment, ...
                  'Visible',s.Visible);                  
         end
      end
   end
   
end