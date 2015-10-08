function [h_patch,h_text] = compass_rose(x,y,font,fontsize,wid,ht,h_fig)
%Adds a standard 8-point compass rose to a MATLAB figure
%
%syntax: [h_patch,h_text] = compass_rose(x,y,font,fontsize,width,height,h_fig)
%
%inputs:
%  x = x-axis position for center of compass
%  y = y-axis position for center of compass
%  font = font name (default = 'Times')
%  fontsize = font size in points (default = 12)
%  width = width of compass rose in data units (default = 1/15 of x axis length
%    corrected for plotbox aspect ratio)
%  height = height of compass rose in data units (default = 1/15 of y axis length
%    corrected for plotbox aspect ratio)
%  h_fig = figure handle (default = gcf)
%
%outputs:
%  h_patch = handles of patch objects
%  h_text = handles of text labels
%
%(c)2004 Wade M. Sheldon
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
%Dept. of Marine Sciences
%University of Georgia
%Athens, GA 30602
%USA
%sheldon@uga.edu
%
%last modified: 24-Oct-2005

h_patch = [];
h_text = [];

if nargin >= 2

   if exist('h_fig') ~= 1
      h_fig = gcf;
   end

   figure(h_fig)
   ax = axis;
   if diff(ax(1:2)) < 180
      ar = get(gca,'plotboxaspectratio');
   else
      ar = [1 1];
   end
   
   %supply defaults for omitted parameters
   if exist('wid') ~= 1
      wid = abs(diff(ax(1:2)))./15 .* ar(2);
   end
   if exist('ht') ~= 1
      ht = abs(diff(ax(3:4)))./15 .* ar(1);
   end
   
   if exist('font') ~= 1
      font = 'Times';
   end

   if exist('fontsize') ~= 1
      fontsize = 12;
   end

   if wid > 0 & ht > 0

      %delete existing compass rose
      h = findobj(gca,'tag','compass');
      if ~isempty(h)
         delete(h)
      end

      %calculate height/width constants
      wid2 = wid./2;
      wid3 = wid./3;
      wid12 = wid./12;
      ht2 = ht./2;
      ht3 = ht./3;
      ht12 = ht./12;

      %generate underlain black & white patch components
      v1 = [x-wid3,y+ht3; x+wid3,y-ht3; x+wid12,y+ht12; x-wid12,y-ht12; x-wid3,y+ht3];
      v2 = [x-wid3,y+ht3; x+wid3,y-ht3; x-wid12,y-ht12; x+wid12,y+ht12; x-wid3,y+ht3];
      v3 = [x+wid3,y+ht3; x-wid3,y-ht3; x+wid12,y-ht12; x-wid12,y+ht12; x+wid3,y+ht3];
      v4 = [x+wid3,y+ht3; x-wid3,y-ht3; x-wid12,y+ht12; x+wid12,y-ht12; x+wid3,y+ht3];
      h1 = patch(v1(:,1),v1(:,2),[0 0 0]);
      h2 = patch(v2(:,1),v2(:,2),[1 1 1]);
      h3 = patch(v3(:,1),v3(:,2),[0 0 0]);
      h4 = patch(v4(:,1),v4(:,2),[1 1 1]);

      %generate top black & white patch components
      v5 = [x,y+ht2; x,y-ht2; x+wid12,y-ht12; x-wid12,y+ht12; x,y+ht2];
      v6 = [x,y+ht2; x,y-ht2; x-wid12,y-ht12; x+wid12,y+ht12; x,y+ht2];
      v7 = [x-wid2,y; x+wid2,y; x+wid12,y+ht12; x-wid12,y-ht12; x-wid2,y];
      v8 = [x-wid2,y; x+wid2,y; x+wid12,y-ht12; x-wid12,y+ht12; x-wid2,y];
      h5 = patch(v5(:,1),v5(:,2),[0 0 0]);
      h6 = patch(v6(:,1),v6(:,2),[1 1 1]);
      h7 = patch(v7(:,1),v7(:,2),[0 0 0]);
      h8 = patch(v8(:,1),v8(:,2),[1 1 1]);

      %set general patch characteristics
      h_patch = [h1; h2; h3; h4; h5; h6; h7; h8];
      set(h_patch,'edgecolor',[0 0 0],'tag','compass')

      %add text labels
      ht1 = text(x,y+ht2,'N', ...
         'horizontalalignment','center', ...
         'verticalalignment','bottom');
      ht2 = text(x,y-ht2,'S', ...
         'horizontalalignment','center', ...
         'verticalalignment','top');
      ht3 = text(x-wid2,y,'W', ...
         'horizontalalignment','right', ...
         'verticalalignment','middle');
      ht4 = text(x+wid2,y,'E', ...
         'horizontalalignment','left', ...
         'verticalalignment','middle');

      %set general text characteristics
      h_text = [ht1; ht2; ht3; ht4];
      set(h_text, ...
         'fontname',font, ...
         'fontsize',fontsize, ...
         'fontweight','bold', ...
         'tag','compass', ...
         'buttondownfcn','textedit')

   end

end