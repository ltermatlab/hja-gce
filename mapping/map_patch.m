function msg = map_patch(lon,lat,vals,patchsize,cbartitle,clims,cmap)
%Plot data values on a map figure as colored patches
%
%syntax: map_patch(lon,lat,vals,patchsize,cbartitle,clims,colormap)
%
%inputs:
%  lon = array of longitudes in decimal degress
%  lat = array of latitudes in decimal degrees
%  vals = array of data values to plot (must match length of lon, lat)
%  patchsize = 2-element array specifying patch width and height in km (default = [.2 .2])
%  cbartitle = color bar title string (default = 'Value')
%  clims = 2-element array containing value limits for scaling the colormap
%    (default = [min(vals(~isnan(vals))),max(vals(~isnan(vals)))])
%  cmap = name of MATLAB colormap to use (default = 'jet')
%
%outputs:
%  msg = error message
%
%
%(c)2002-2011 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 04-Nov-2011

msg = '';

if nargin >= 3
   
   %validate data
   flag_nodata = 0;
   
   if isempty(vals)
      flag_nodata = 1;
   elseif ~isnumeric(vals)
      flag_nodata = 1;
   elseif isempty(find(~isnan(vals)))
      flag_nodata = 1;
   end
   
   if isempty(lon)
      flag_nodata = 1;
   elseif ~isnumeric(lon)
      flag_nodata = 1;
   elseif isempty(find(~isnan(lon)))
      flag_nodata = 1;
   end
   
   if isempty(lat)
      flag_nodata = 1;
   elseif ~isnumeric(lat)
      flag_nodata = 1;
   elseif isempty(find(~isnan(lat)))
      flag_nodata = 1;
   end
   
   if flag_nodata == 0      
      
      if exist('patchsize','var') ~= 1
         patchsize = [.2 .2];
      elseif length(patchsize)< 2
         patchsize = [patchsize(1) patchsize(1)];
      end
      
      if exist('cbartitle','var') ~= 1
         cbartitle = 'Value';
      end
      
      if exist('clims','var') ~= 1
         clims = [];
      end
      
      if isempty(clims)
         clims = [min(vals(~isnan(vals))),max(vals(~isnan(vals)))];
         if clims(2) <= clims(1)
            clims(2) = clims(1) .* 1.00001;
         end
      elseif length(clims) ~= 2
         clims = [min(vals(~isnan(vals))),max(vals(~isnan(vals)))];
      end
      
      if exist('cmap','var') ~= 1
         cmap = 'jet';
      end
      
      if abs(lon) <= 180
         
         height = patchsize(2)./111.11;   %convert height (km) to degrees of arc
         width = patchsize(1)./111.11;    %convert width (km) to degrees of arc
         
         x = [lon-(width./cos(lat*pi/180))./2 lon+(width./cos(lat*pi/180))./2 ...
               lon+(width./cos(lat*pi/180))./2 lon-(width./cos(lat*pi/180))./2]';
         
         y = [lat+height./2 lat+height./2 lat-height./2 lat-height./2]';
         
         c = (vals * ones(1,4))';
         
      else  %utm meters
         
         height = patchsize(2) .* 1000;   %convert height (km) to m
         width = patchsize(1) .* 1000;    %convert width (km) to m
         
         x = [lon-(width./2) lon+(width./2) ...
               lon+(width./2) lon-(width./2)]';
         
         y = [lat+(height./2) lat+(height./2) lat-(height./2) lat-(height./2)]';
         
         c = (vals * ones(1,4))';
         
      end
      
      eval(['colormap ',cmap,'(128)'])
      caxis(clims)
      
      patch(x,y,c, ...
         'Edgecolor','none', ...
         'Facecolor','flat', ...
         'Tag','map_patch');
      
      h_ax = gca;
      figpos = get(h_ax,'Position');
      
      h_bar = findobj(gcf,'Tag','Colorbar');
      if ~isempty(h_bar)
         flag_existing = 1;
         pos = get(h_bar(1),'Position');
      else
         flag_existing = 0;
      end
      
      h_bar = colorbar;
      cbarpos = get(h_bar,'Position');
      
      if flag_existing == 0
         if mlversion <= 6
            pos = [cbarpos(1)+.05 cbarpos(2) .04 cbarpos(4)];
         else
            pos = [cbarpos(1)+.05 cbarpos(2)-.03 .03 cbarpos(4)+.03];
         end
      end
      
      set(h_bar, ...
         'HitTest','off', ...
         'Position',pos, ...
         'ButtondownFcn','selectmoveresize')
      
      h_title = get(h_bar,'ylabel');
      set(h_title, ...
         'string',cbartitle, ...
         'fontweight','bold', ...
         'fontsize',12, ...
         'interpreter','none', ...
         'buttondownfcn','textedit')
      
      if flag_existing == 0
         set(h_ax,'Position',[figpos(1:2) figpos(3)+.02 figpos(4)])
      end

      axes(h_ax)  %reset data axis to current axis
      
   else
      msg = 'no valid data to plot';
   end
   
else
   msg = 'insufficient arguments for function';   
end
