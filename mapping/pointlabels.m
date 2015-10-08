function [h_line,h_text] = pointlabels(lon,lat,str,sym,clr,offset,fontsize,tag)
%Plots point labels for map coordinates (if 'str' is omitted,
%sequential integers will be used as labels
%
%syntax: [h_line,h_text] = pointlabels(lon,lat,str,symbol,clr,offset,fontsize,tag)
%
%inputs:
%  lon = longitude in decimal degrees
%  lat = latitude in decimal degrees
%  str = cell array of strings to use as labels (default = sequential integers if omitted)
%  sym = symbol to plot at each location (default = '')
%  clr = label color (rgb triplet; default = [1 0 0], i.e. red)
%  offset = 1x2 array of lon and lat offsets (in decimal degrees; scalar values replicated)
%    (default = [0 .002])
%  fontsize = fontsize to use for text (default = 9)
%  tag = tag to assign to text labels (default = 'pointlabels')
%
%outputs:
%  h_line = handle of line object containing points
%  h_text = array of handles of text objects containing labels (1/point)
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
%last modified: 05-Dec-2002

h_points = [];
h_text = [];

if nargin >= 2

   %set default plot symbol
   if exist('sym') ~= 1
      sym = '';
   end

   %set default fontsize
   if exist('fontsize') ~= 1
      fontsize = 9;
   end

   %set default tag string if omitted
   if exist('tag') ~= 1
      tag = 'pointlabels';
   end

   %set default lon,lat offset if omitted
   if ~exist('offset')
      offset = [0 0.002];
   elseif size(offset,2) == 1
      offset = [offset(1) offset(1)];
   end

   %set default text color if omitted
   if ~exist('clr')
      clr = [1 0 0];
   elseif ischar(clr)
      clrstr = clr;
      switch(clrstr)
      case 'k'
         clr = [0 0 0];
      case 'w'
         clr = [1 1 1];
      case 'r'
         clr = [1 0 0];
      case 'g'
         clr = [0 1 0];
      case 'b'
         clr = [0 0 1];
      case 'y'
         clr = [1 1 0];
      case 'c'
         clr = [0 1 1];
      case 'm'
         clr = [1 0 1];
      otherwise
         clr = [0 0 0];
      end
   end

   %set default str if omitted
   if ~exist('str')
      str = int2str([1:length(lon)]');
   elseif isempty(str)
      str = int2str([1:length(lon)]');
   elseif iscell(str)
      str = char(str);
   end
   
   if size(str,1) < length(lon)
      str = repmat(str,ceil(length(lon)./size(str,1)),1);
   end

   hold on;

   if ~isempty(sym)
      h_line = line(lon,lat, ...
         'color',[1 1 1], ...
         'linestyle','none', ...
         'marker',sym, ...
         'markersize',6, ...
         'markerfacecolor',clr, ...
         'markeredgecolor',[0 0 0], ...
         'tag',tag, ...
         'clipping','on');
   end

   h_text = [];

   for n = 1:length(lon)

      lbl = fliplr(deblank(fliplr(deblank(str(n,:)))));

      h2 = text(lon(n)+offset(1),lat(n)+offset(2),lbl, ...
         'tag','textlabels', ...
         'horizontalalignment','center', ...
         'verticalalignment','middle', ...
         'fontsize',fontsize, ...
         'fontweight','bold', ...
         'color',clr, ...
         'clipping','on', ...
         'interpreter','none', ...
         'buttondownfcn','labeledit', ...
         'tag',tag);

      h_text = [h_text ; h2];

   end

   hold off

end
