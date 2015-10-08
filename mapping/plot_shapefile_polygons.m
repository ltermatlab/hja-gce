function [h_poly,h_labels] = plot_shapefile_polygons(fn,pn,w,c,label,h_fig,utm_zone)
%plots polygons in an ArcGIS shapefile on a MATLAB figure
%
%syntax:  [h_poly,h_labels] = plot_shapefile_polygons(fn,pn,linewidth,color,label,h_fig)
%
%inputs:
%  fn = filename for shapefile to read (default = prompted)
%  pn = pathname for shapefile (default = pwd)
%  utm_zone = UTM zone for conversion to lat/lon if necessary (default = '17N')
%  linewidth = with of polygon line (default = 2)
%  color = color of polygon line and text (default = [0 0 1])
%  label = label to display for each polygon (default = base filename)
%  h_fig = handle of figure for plotting (default = gcf)
%
%outputs:
%  h_poly = array of handles for polygon object
%  h_labels = array of handles for text labels objects
%
%(c)2010 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 28-Jan-2010

h_poly = [];
h_labels = [];
curpath = pwd;

if exist('h_fig','var') ~= 1
   if length(findobj) > 1
      h_fig = gcf;
   else
      h_fig = [];
   end
end

if exist('utm_zone','var') ~= 1
   utm_zone = '17N';
end

if isempty(h_fig)

   warning('no map figure is open for plotting');

elseif exist('shaperead','file') ~= 2

   warning('this function requires the MATLAB Mapping Toolbox ''shaperead'' function')

else

   if exist('label','var') ~= 1
      label = '';
   end
   
   if exist('c','var') ~= 1
      c = [0 0 1];
   end
   
   if exist('w','var') ~= 1
      w = 2;
   end
   
   if exist('pn','var') ~= 1
      pn = curpath;
   elseif exist(pn,'dir') ~= 7
      pn = curpath;
   elseif strcmp(pn(end),filesep)
      pn = pn(1:end-1);  %strip terminal file separator
   end

   if exist('fn','var') ~= 1
      fn = '';
   end
   if isempty(fn)
      filemask = '*.shp';
   elseif exist([pn,filesep,fn],'file') ~= 2
      filemask = fn;
      fn = '';
   end

   if isempty(fn)
      cd(pn)
      [fn,pn] = uigetfile(filemask,'Select a shapefile to read');
      cd(curpath)
      if fn == 0
         fn = '';
      end
   end

   if ~isempty(fn)

      try
         s = shaperead([pn,filesep,fn]);
      catch
         s = [];
         warning([fn,' is not a valid shapefile'])
      end

      if ~isempty(s)
         hold on
         [tmp,fn] = fileparts(fn);
         for n = 1:length(s)
            x = s(n).X';
            y = s(n).Y';
            Ivalid = find(~isnan(x) & ~isnan(y));
            if abs(max(x(Ivalid))) > 180 || abs(max(y(Ivalid))) > 90
               if ischar(utm_zone) && length(utm_zone) <= 3
                  hem = utm_zone(end);
                  zone = fix(str2num(utm_zone(1:end-1)));
               else
                  hem = 'N';
                  zone = 17;
               end
               [x,y] = utm2deg(zone,x,y,hem,'WGS84');
            end
            h = plot(x(Ivalid),y(Ivalid),'w-');
            set(h,'Tag',fn,'LineWidth',w,'Color',c)
            if isempty(label)
               labeln = int2str(n);
            else
               labeln = label;
            end
            t = text(mean(x(Ivalid)),mean(y(Ivalid)),labeln);
            set(t,'Tag',fn,'Color',c,'HorizontalAlignment','center','VerticalAlignment','middle', ...
               'FontSize',9,'FontWeight','bold','ButtonDownFcn','textedit','Interpreter','none')
            h_poly = [h_poly ; h];
            h_labels = [h_labels ; t];
         end
         hold off

      end

   end

end