function updateaxis(op,gps,mode,bound)
%Updates map plot axis limits to a geographically-correct aspect ratio
%
%syntax: updateaxis(op,gps,mode,bound)
%
%input:
%  op = 'init' or 'update'
%  gps = matrix of lon,lat or utm easting,northing to determine bounding coordinates
%  mode = 'gpsaxis' mode (0 = use prevailing aspect ratio, 1 = use 1:1 AR,
%         2 = calculate AR for tight plot)
%  bound = 'gpsaxis' boundary (whitespace around plot in km)
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
%last modified: 12-Apr-2006

if exist('op') ~= 1
   op = 'update';
end

mlstr = version;
mlversion = str2num(mlstr(1:3));

if strcmp(op,'init')

   if exist('gps') ~= 1

      if exist('mode') ~= 1
         if abs(gps(1,1)) <= 360
            mode = 2;
         else
            mode = 0;
         end
      else
         mode = 2;
      end

      if exist('bound') ~= 1
         bound = 0;
      end

      [ax,ar] = gpsaxis(gps,mode,bound);

      axis(ax)

      if mlversion >= 5
         set(gca,'PlotBoxAspectRatio',ar)
      else
         set(gca,'AspectRatio',ar)
      end

      data = get(gcf,'UserData');
      data.axis = ax;
      data.aspectratio = ar;

      set(gcf,'UserData',data)

      mapticks

   end

elseif strcmp(op,'update')

   if exist('gps') ~= 1
      lon = get(gca,'XLim');
      lat = get(gca,'YLim');
   else
      lon = gps(:,1)';
      lat = gps(:,2)';
   end

   if abs(lon(1)) <= 360
      [ax,ar] = gpsaxis([lon(1) lat(1);lon(2) lat(2)],2,0);
      if mlversion >= 5
         set(gca,'XLim',ax(1:2),'YLim',ax(3:4),'PlotBoxAspectRatio',ar)
      else
         set(gca,'XLim',ax(1:2),'YLim',ax(3:4),'AspectRatio',ar)
      end
   else
      axis([lon,lat])
   end

   mapticks

end