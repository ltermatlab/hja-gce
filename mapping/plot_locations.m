function plot_locations(lon,lat,types,labels,h_map,sym,clr)
%Plots sampling locations on a map and generates a figure legend
%
%syntax: plot_locations(lon,lat,types,labels,h_map,symbols,colors)
%
%input:
%  lon = array of longitudes (or UTM eastings for UTM map)
%  lat = array of latitudes (or UTM northings for UTM map)
%  types = cell array of location type strings
%  labels = cell array of location type labels (default = types)
%  h_map = handle of map to annotation (default = gcf)
%  sym = cell array of plot symbols (default = auto series)
%  clr = cell array of color codes (default = auto series)
%
%output:
%  none
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
%last modified: 21-Oct-2004

if nargin >= 3

   if isnumeric(lon) & isnumeric(lat) & (size(lon,1)==size(lat,1))

      if exist('h_map') ~= 1
         h_map = gcf;
      else
         figure(h_map)
      end

      %validate types array
      if iscell(types)
         types = types(:);  %force column orientation
      elseif ischar(types)
         types = cellstr(types);
      elseif isnumeric(types)
         try
            types = types(:);  %force column orientation
            types = strrep(cellstr(num2str(types)),' ','');  %convert numbers to cell array of strings
         catch
            types = '';
         end
      end
      
      %generate list of unique tpes for legend
      if ~isempty(types)
         typelist = unique(types);
         if length(types) == 1
            types = repmat(types,length(lon),1);  %replicate scalar type code
         elseif length(types) < length(lon)
            types = [types ; repmat({''},length(lon)-length(types),1)];  %pad type codes to length of lon
         end
      else
         typelist = '';
      end

      if exist('labels','var') ~= 1
         labels = '';
      elseif length(labels) ~= length(types)
         labels = '';
      elseif isnumeric(labels)
         labels = cellstr(num2str(labels(:)));
      end

      if exist('sym','var') ~= 1
         sym = '';
      elseif ischar(sym)
         if ~isempty(sym)
            sym = cellstr(sym);
         end
      end

      if ~iscell(sym)
         symlist = {'d' 'o' 's' 'v' '^' '<' '>' 'p' 'h' '*' 'x'};
         sym = symlist;
      else
         symlist = sym;  %use provided symbols as master symbol list
      end
      while length(sym) < length(typelist)
         sym = [sym symlist];
      end

      if exist('clr','var') ~= 1
         clr = '';
      elseif ischar(clr)
         if ~isempty(clr)
            clr = cellstr(clr);
         end
      end

      if ~iscell(clr)
         clrlist = {'b' 'r' 'k' 'g' 'y' 'm' 'w'};
         clr = clrlist;
      else
         clrlist = clr;  %use provided colors as master color list
      end
      while length(clr) < length(typelist)
         clr = [clr clrlist];
      end

      figure(gcf)
      h_lines = [];
      for n = 1:length(typelist)
         I = find(strcmp(types,typelist{n}));
         if ~isempty(I)
            hold on
            h = plot(lon(I,1),lat(I,1),['k',sym{n}]);
            h_lines = [h_lines ; h];
            set(h, ...
               'clipping','on', ...
               'markerfacecolor',clr{n}, ...
               'markersize',6, ...
               'tag',typelist{n})
            if ~isempty(labels)
               pointlabels(lon(I,1),lat(I,1),labels(I),'',clr{n},[0 .001],9,typelist{n});
            end
         end
      end

      h = legend(h_lines,typelist,2);
      set(h,'color',[1 1 1])

   else
      warning('mismatched longitude, latitude and location type arrays')
   end

else
   warning('insufficient arguments for function')
end