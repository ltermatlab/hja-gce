function [coords,shapes,attributes] = shapefile2gcepoly(fn,pn,id_field,utm_zone,utm_datum,numeric_prefix)
%Creates a GCE geographic coordinate structure for polygons stored in an ArcGIS shapefile
%(note: converts UTM coordinates to decimal degrees if necessary using the indicated zone and datum)
%
%syntax: [coords,shapes,attributes] = shapefile2gcepoly(fn,pn,id_field,utm_zone,utm_datum,numeric_prefix)
%
%input:
%  fn = filename of shapefile (prompted if omitted)
%  pn = pathname of shapefile (prompoted if omitted/invalid)
%  id_field = field name of ID code attribute to use as a site code
%  utm_zone = UTM zone (default = '17N')
%  utm_datum = UTM datum (default = 'WGS84', see 'utm2deg')
%  numeric_prefix = text to prepend to numeric site code ids (default = '')
%
%output:
%  coords = coordinate structure minimally containing the fields:
%     SiteCode = site code (string)
%     Polygon = polygon (2-column array of longitude, latitude in dec. degrees)
%  shapes = shape structure returned from 'shaperead'
%  attributes = attributes structure returned from 'shaperead'
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
%last modified: 07-Dec-2010

coords = [];
shapes = [];
attributes = [];

if exist('shaperead','file') ~= 2

   warning('this function requires the MATLAB Mapping Toolbox ''shaperead'' function')

else

   %validate path
   curpath = pwd;
   if exist('pn','var') ~= 1
      pn = curpath;
   elseif exist(pn,'dir') ~= 7
      pn = curpath;
   else
      pn = clean_path(pn);  %strip terminal file separator
   end

   %validate filename, prompt if omitted/invalid
   if exist('fn','var') ~= 1
      fn = '';
   end
   if isempty(fn)
      filemask = '*.shp';
   elseif exist([pn,filesep,fn],'file') ~= 2
      filemask = fn;
      fn = '';
   end

   %prompt for filename
   if isempty(fn)
      cd(pn)
      [fn,pn] = uigetfile(filemask,'Select a shapefile to read');
      cd(curpath)
      if fn == 0
         fn = '';
      end
   end

   if ~isempty(fn)
      
      %supply defaults for missing input
      if exist('utm_zone','var') ~= 1
         utm_zone = '17N';
      end
      
      if exist('utm_datum','var') ~= 1
         utm_datum = 'WGS84';
      end         

      if exist('numeric_prefix','var') ~= 1
         numeric_prefix = '';
      end
      
      %call shaperead
      try
         [shapes,attributes] = shaperead([pn,filesep,fn]);
      catch
         shapes = [];
         attributes = [];
         warning([fn,' is not in supported shapefile format'])
      end

      %check for successful parsing
      if ~isempty(shapes) && ~isempty(attributes)
         
         %generate select list of attribute fields if id field omitted
         if exist('id_field','var') ~= 1 || isempty(id_field)
            fields = fieldnames(attributes);
            Isel = listdialog('liststring',fields, ...
               'name','Choose ID field', ...
               'promptstring','Select a polygon ID field', ...
               'selectionmode','single');
            drawnow
            if ~isempty(Isel)
               id_field = fields{Isel};
            else
               id_field = '';
            end
         end
                  
         %get id attributes (or array of empty strings if field not found)
         if isfield(attributes,id_field)
            att = {attributes.(id_field)}';
         else
            att = repmat({''},length(shapes),1);
         end

         %get index of polygons
         Ipolys = find(strcmpi({shapes.Geometry},'Polygon'));

         if ~isempty(Ipolys)

            %init output
            coords = struct('SiteCode','','Polygon',[]);

            %subset structure and attributes to only include polygons
            s = shapes(Ipolys);
            att = att(Ipolys);

            %loop through features, getting coords from polygons
            for n = 1:length(s)

               %get coord arrays
               x = s(n).X';
               y = s(n).Y';

               %get index of valid points
               Ivalid = find(~isnan(x) & ~isnan(y));

               %check for utm, convert to dec degrees
               if abs(max(x(Ivalid))) > 180 || abs(max(y(Ivalid))) > 90
                  if ischar(utm_zone) && length(utm_zone) <= 3
                     hem = utm_zone(end);
                     zone = fix(str2double(utm_zone(1:end-1)));
                  else
                     hem = 'N';
                     zone = 17;
                  end
                  [x,y] = utm2deg(zone,x,y,hem,utm_datum);
               end

               %look up or generate id
               id = att{n};
               if isempty(id)
                  id = ['Polygon',int2str(n)];
               elseif isnumeric(id)
                  id = [numeric_prefix,num2str(id)];  %convert numeric ids to strings
               end
               
               %build array of lat/lon
               poly = [x(Ivalid),y(Ivalid)];
               
               coords(n).SiteCode = id;
               coords(n).Polygon = poly;               

            end

         else  %no polygons
            warning(['no valid polygons were present in ',fn])
         end

      else  %s and/or a empty
         warning(['shapes and attributes could not be parsed from ',fn])
      end

   end
   
end
