function msg = gcepoly2kml(coords,fn,vertices)
%Creates a Google Earth KML file from a GCE geographic polygon structure with fields 'SiteCode' and 'Polygon'
%
%syntax: msg = gcepoly2kml(coords,fn,vertices)
%
%input:
%  coords = coordinate structure minimally containing the fields:
%     SiteCode = site code (string)
%     Polygon = polygon (2-column array of longitude, latitude in dec. degrees)
%  fn = filename of shapefile (prompted if omitted)
%  vertices = maximum number of polygon vertices (geo_simplify.m will be used to simplify
%     the polygon if necessary; default = [] for all)
%
%output:
%  msg = status message
%
%(c)2012 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 24-Dec-2012

if nargin >= 2 && ~isempty(fn)
   
   if isstruct(coords) && isfield(coords,'SiteCode') && isfield(coords,'Polygon')
      
      %set default vertices if omitted
      if exist('vertices','var') ~= 1
         vertices = [];
      end
      
      %init KML style
      style = {'    <Style id="custom-style">'; ...
         '      <BalloonStyle>'; ...
         '        <bgColor>ffcbe9e8</bgColor>'; ...
         '        <textColor>ff000000</textColor>'; ...
         '      </BalloonStyle>'; ...
         '      <LineStyle>'; ...
         '        <color>ff00ffff</color>'; ...
         '        <colorMode>normal</colorMode>'; ...
         '        <width>2</width>'; ...
         '      </LineStyle>'; ...
         '      <IconStyle>'; ...
         '        <color>ff0000ee</color>'; ...
         '        <colorMode>normal</colorMode>'; ...
         '        <scale>0.6</scale>'; ...
         '      </IconStyle>'; ...
         '      <PolyStyle>'; ...
         '        <color>7f00ffff</color>'; ...
         '        <colorMode>normal</colorMode>'; ...
         '        <fill>1</fill>'; ...
         '        <outline>1</outline>'; ...
         '      </PolyStyle>'; ...
         '    </Style>'};
      
      %open file, write header
      try
         fid = fopen(fn,'w');
      catch
         fid = [];
      end
      
      if ~isempty(fid)
         
         %generate header
         fprintf(fid,'%s\r\n','<?xml version="1.0" encoding="UTF-8" ?>');
         fprintf(fid,'%s\r\n','<kml xmlns="http://www.opengis.net/kml/2.2">');
         fprintf(fid,'%s\r\n','   <Document>');
         
         %generate style
         fprintf(fid,'%s\r\n',style{:});
         
         %generate placemarks
         for n = 1:length(coords)
            lonlat = sub_formatcoords(coords(n).Polygon,vertices);
            fprintf(fid,'%s\r\n','      <Placemark>');
            fprintf(fid,'%s\r\n',['         <name>',coords(n).SiteCode,'</name>']);
            fprintf(fid,'%s\r\n',['         <styleUrl>#custom-style</styleUrl>']);
            fprintf(fid,'%s\r\n',['         <Polygon id="',coords(n).SiteCode,'">']);
            fprintf(fid,'%s\r\n',['            <extrude>0</extrude>']);
            fprintf(fid,'%s\r\n',['            <tessellate>1</tessellate>']);
            fprintf(fid,'%s\r\n',['            <altitudeMode>clampToGround</altitudeMode>']);
            fprintf(fid,'%s\r\n',['            <outerBoundaryIs><LinearRing>']);
            fprintf(fid,'%s\r\n',['               <coordinates>',lonlat,'</coordinates>']);
            fprintf(fid,'%s\r\n',['            </LinearRing></outerBoundaryIs>']);
            fprintf(fid,'%s\r\n',['         </Polygon>']);
            fprintf(fid,'%s\r\n',['      </Placemark>']);
         end
         
         %close file
         fprintf(fid,'%s\r\n','  </Document>');
         fprintf(fid,'%s\r\n','</kml>');
         fclose(fid);
         
      else
         msg = 'invalid filename';
      end
      
   else
      msg = 'invalid coordinates structure';
   end
   
else
   msg = 'insufficient input';
end
return


function latlon = sub_formatcoords(polygon,vertices)
%generates coordinates formatted for KML from an array of lon/lat values

%init output
num = size(polygon,1);
latlon = repmat({''},1,num);

%check for simplify option
if ~isempty(vertices) && exist('geo_simplify','file') == 2 && num > vertices
   [lon,lat] = geo_simplify(polygon(:,1),polygon(:,2),vertices);
   if ~isempty(lon)
      polygon = [lon,lat];    %update polygon
      num = size(polygon,1);  %recalculate size
   end
end

%format coordinates
for n = 1:num
   latlon{n} = sprintf('%0.6f,%0.6f',polygon(n,1),polygon(n,2));
end

%convert to character array
latlon = char(concatcellcols(latlon,' '));