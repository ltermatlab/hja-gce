function msg = gceds2kml(s,fn,col_lat,col_lon,col_labels,col_balloons,headings,docname,styles,col_styles)
%Creates a Google Earth KML file from a GCE Data Structure containing latitude and longitude columns
%
%syntax: msg = gceds2kml(s,fn,col_lat,col_lon,col_labels,col_balloons,headings,docname,styles,col_styles)
%
%inputs:
%   s = data structure to export
%   fn = filename for saving the table markup (string; required)
%   col_lat = name or index number of geographic latitude column (string or integer; optional;
%     default = first floating-point column with 'coord' variabletype starting with 'lon')
%   col_lon = name or index number of geographic longitude column (string or integer; optional;
%     default = first floating-point column with 'coord' variabletype starting with 'lat')
%   col_labels = name or index number of a column to use as the location label (string or integer;
%     optional; default = [] to use row numbers as location labels)
%   col_balloons = array of column names or index numbers to include in placemark balloons
%     (cell or integer array; optional; default = all columns other than latcol and loncol)
%   headings = array of column headings for display in placemark balloons (cell array; optional;
%      default = column names)
%   docname = document name (string; default = 'Data Set')
%   styles = struct containing style information with fields:
%      'name' = style name (string, e.g. 'default')
%      'icon_url' = URL for the placemark icon (string, e.g. 'http://maps.google.com/mapfiles/kml/paddle/ylw-circle.png')
%      'icon_scale' = icon scale (number, e.g. 1)
%      'line_color' = line color hex code (string, eg. 'ff0000ff')
%      'line_width' = line width (number, e.g. 2)
%      'poly_color' = polygon color hex code (string, e.g. '7f00fffff')
%      'poly_fill' = polygon fill option (number, 0 or 1)
%      'poly_outline' = polygon outline option (number, 0 or 1)
%      'balloon_color' = balloon background color hex code (string, e.g. 'ffffffff')
%      'balloon_text' = balloon text color hex code (string, e.g. 'ff000000')
%   col_styles = name or index number of a column to use as the style name to correspond with styles.name
%   
%
%outputs:
%   msg = text of any error message
%
%notes:
%  1) if styles is omitted, a default structure with values as in the examples will be generated
%  2) the default style will be used for any placemarks that do not have an entry in col_styles or
%     cannot be matched to a style name in styles
%
%(c)2013-2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 24-Oct-2014

%init output
msg = '';

if nargin >= 2 && gce_valid(s,'data') && ~isempty(fn)
   
   %set default docname if omitted
   if exist('docname','var') ~= 1
      docname = 'Data Set';
   end
   
   %set default placemark_url if omitted
   if exist('styles','var') ~= 1 || isempty(styles) || ~isstruct(styles)
      styles = struct( ...
         'name','default', ...
         'icon_url','http://maps.google.com/mapfiles/kml/paddle/ylw-circle.png', ...
         'icon_scale',1, ...
         'line_color','ff0000ff', ...
         'line_width',2, ...
         'poly_color','7f00fffff', ...
         'poly_fill',1, ...
         'poly_outline',1, ...
         'balloon_color','ffffffff', ...
         'balloon_text','ff000000');
   end
   
   %check for lat column
   if exist('col_lat','var') ~= 1
      col_lat = [];
   elseif ~isnumeric(col_lat)
      col_lat = name2col(s,col_lat);
   end
   
   %check for lon column
   if exist('col_lon','var') ~= 1
      col_lon = [];
   elseif ~isnumeric(col_lon)
      col_lon = name2col(s,col_lon);
   end
   
   %check for empty lat/lon columns and attempt lookup
   if isempty(col_lon) || isempty(col_lat)
      
      %get attribute metadata for lookups
      vtypes = get_type(s,'variabletype');
      colnames = s.name;
      
      %look up lon column, taking first match
      if isempty(col_lon)
         col_lon = find(strncmpi('lon',colnames,3) & strcmp('coord',vtypes));
         if ~isempty(col_lon)
            col_lon = col_lon(1);
         end
      end
      
      %look up lat column, taking first match
      if isempty(col_lat)
         col_lat = find(strncmpi('lat',colnames,3) & strcmp('coord',vtypes));
         if ~isempty(col_lat)
            col_lat = col_lat(1);
         end
      end
      
   end
   
   %check for matched lat/lon columns
   if ~isempty(col_lat) && ~isempty(col_lon)
      
      %chech for omitted col_labels
      if exist('col_labels','var') ~= 1
         col_labels = [];
      elseif ~isnumeric(col_labels)
         if ~strcmp(col_labels,'none')
            col_labels = name2col(s,col_labels);
         end
      end
      
      %check for omitted col_balloons and choose remaining columns, otherwise validate selection
      if exist('col_balloons','var') ~= 1 || isempty(col_balloons)
         col_balloons = setdiff((1:length(s.name)),[col_lat col_lon]);
      elseif ~isnumeric(col_balloons)
         col_balloons = name2col(s,col_balloons);
      else
         Ivalid = col_balloons >= 1 & col_balloons <= length(s.name);
         col_balloons = col_balloons(Ivalid);
      end
      
      %check for omitted headings, use defaults
      if exist('headings','var') ~= 1 || ~iscell(headings) || length(headings) ~= length(col_balloons)
         headings = s.name(col_balloons);
      end
      
      %check for omitted style column use default
      if exist('col_styles','var') ~= 1
         col_styles = [];
      end
      
      %extract lat/lon
      lat = extract(s,col_lat);
      lon = extract(s,col_lon);
      
      %extract style list
      if ~isempty(col_styles)
         style_list = extract(s,col_styles);
      else
         style_list = [];
      end
      if isempty(style_list) || ~iscell(style_list)
         style_list = repmat({'default'},length(lon),1);
      end
      
      %check for string coordinate format
      if iscell(lat)
         lat = coordstr2ddeg(lat);
      end
      if iscell(lon)
         lon = coordstr2ddeg(lon);
      end
      
      %get index of valid rows
      try
         Ivalid = find(~isnan(lat) & ~isnan(lon));
      catch e
         Ivalid = [];
         msg = ['invalid latitude or longitude data (',e.message,')'];
      end
      
      if ~isempty(Ivalid)
         
         %subset coordinates
         lon = lon(Ivalid);
         lat = lat(Ivalid);
         style_list = style_list(Ivalid);

         %subset dataset to include only balloon columns
         s2 = copycols(s,col_balloons,'Y',1);

         %subset data rows to remove non-georeference data
         s2 = copyrows(s2,Ivalid,'Y');
         
         %convert columns to string
         [s2,msg0] = convert_datatype(s2,(1:length(s2.name)),'s');
         
         if ~isempty(s2)
            
            %generate placemark labels
            if ~isempty(col_labels)
               if ischar(col_labels) && strcmpi(col_labels,'none')
                  labels = repmat({''},length(lon),1);
                  labels2 = '';
               else   
                  s_tmp = convert_datatype(s,col_labels(1),'s');  %convert label column to string if necessary
                  labels = extract(s_tmp,col_labels(1));  %extract labels from original dataset in case not in balloon cols
                  labels = labels(Ivalid);  %remove labels for invalid rows
                  labels2 = '';             %skip balloon heading to avoid redundant text
               end
            else
               labels = strrep(cellstr(int2str(Ivalid)),' ','');
               labels2 = cellstr([repmat('Record ',length(labels),1),char(labels)]);
            end
            
            %extract balloon columns
            num_balloons = length(s2.name);
            data_balloons = extract(s2,(1:num_balloons));
            
            %extract units, generate unit strings for data/calculation columns with valid unit strings
            units = strrep(strrep(s2.units,'unspecified',''),'none','');
            vtypes = s2.variabletype;
            Iunits = find(~strcmpi('none',units) & (strcmp('data',vtypes) | strcmp('calculation',vtypes)));
            data_units = repmat({''},1,length(s2.name));
            for n = 1:length(Iunits)
               data_units{Iunits(n)} = ['&nbsp;',units{Iunits(n)}];
            end
            
            %init KML style            
            kml_style = cell(length(styles),1);
            
            %generate styles for each dimension of style
            for n = 1:length(styles)
               kml_style{n} = { ...
                  ['     <Style id="',styles(n).name,'">']; ...
                  '       <IconStyle>'; ...
                  ['         <scale>',num2str(styles(n).icon_scale),'</scale>']; ...
                  ['         <Icon><href>',styles(n).icon_url,'</href></Icon>']; ...
                  '       </IconStyle>'; ...
                  '       <LabelStyle>'; ...
                  '         <scale>1</scale>'; ...
                  '       </LabelStyle>'; ...
                  '       <LineStyle>'; ...
                  ['         <color>',styles(n).line_color,'</color>']; ...
                  '         <colorMode>normal</colorMode>'; ...
                  ['         <width>',num2str(styles(n).line_width),'</width>']; ...
                  '       </LineStyle>'; ...
                  '       <PolyStyle>'; ...
                  ['         <color>',styles(n).poly_color,'</color>']; ...
                  '         <colorMode>normal</colorMode>'; ...
                  ['         <fill>',num2str(styles(n).poly_fill),'</fill>']; ...
                  ['         <outline>',num2str(styles(n).poly_outline),'</outline>']; ...
                  '       </PolyStyle>'; ...
                  '       <BalloonStyle>'; ...
                  ['         <bgColor>',styles(n).balloon_color,'</bgColor>']; ...
                  ['         <textColor>',styles(n).balloon_text,'</textColor>']; ...
                  '       </BalloonStyle>'; ...
                  '     </Style>' ...
                  };
            end
            
            %generate single-column cell array for inclusion in kml
            kml_style = reshape([kml_style{:}],[],1);
            
            %open file, write header
            try
               fid = fopen(fn,'w');
            catch e
               fid = [];
               msg = ['an error occurred opening the file ''',fn,''' for writing (',e.message,')'];
            end
            
            if ~isempty(fid)
               
               %get title for doc heading
               str_title = s.title;
               
               %get abstract
               str_abstract = lookupmeta(s,'Dataset','Abstract');
               if isempty(str_abstract)
                  str_abstract = str_title;
               else
                  str_abstract = [str_title,char(13),'<br/> Abstract: ',str_abstract];
               end
               
               %get investigator - add to abstract
               str_investigator = lookupmeta(s,'Dataset','Investigator');
               if ~isempty(str_investigator)
                  str_abstract = [str_abstract,'<br/> Investigator: ',strrep(str_investigator,'|','  ')];
               end
               
               %generate header
               fprintf(fid,'%s\r\n','<?xml version="1.0" encoding="UTF-8" ?>');
               fprintf(fid,'%s\r\n','<kml xmlns="http://www.opengis.net/kml/2.2">');
               fprintf(fid,'%s\r\n','   <Document>');
               fprintf(fid,'%s\r\n',['     <name>',docname,'</name>']);
               fprintf(fid,'%s\r\n',['     <Snippet>',str_title,'</Snippet>']);
               if ~isempty(str_abstract)
                  fprintf(fid,'%s\r\n',['      <description>',str_abstract,'</description>']);
               end
               
               %generate style
               fprintf(fid,'%s\r\n',kml_style{:});
               
               %generate placemarks
               for rownum = 1:length(Ivalid)
                  
                  %open placemark
                  fprintf(fid,'%s\r\n','      <Placemark>');
                  fprintf(fid,'%s\r\n',['         <name>',labels{rownum},'</name>']);
                  
                  %open balloon
                  if ~isempty(labels2)
                     fprintf(fid,'%s',['         <description><![CDATA[<strong>',labels2{rownum},'</strong><ul style="padding:0 6px">']);
                  else
                     fprintf(fid,'%s','         <description><![CDATA[<ul style="padding:0 6px">');
                  end
                  
                  %generate balloon text
                  if num_balloons > 1
                     for col = 1:length(headings)
                        hdr = headings{col};
                        val = data_balloons{col}{rownum};
                        if ~isempty(hdr)
                           %add field label if specified
                           str = ['<li><strong>',hdr,':</strong>&nbsp;',val,data_units{col},'</li>'];
                        else
                           str = ['<li>',val,data_units{col},'</li>'];
                        end
                        fprintf(fid,'%s',str);
                     end
                  else
                     hdr = headings{1};
                     val = data_balloons{rownum};
                     if ~isempty(hdr)
                        %add field label if specified
                        str = ['<li><strong>',hdr,':</strong>&nbsp;',val,data_units{1},'</li>'];
                     else
                        str = ['<li>',val,data_units{1},'</li>'];
                     end
                     fprintf(fid,'%s',str);
                  end
                  
                  %close balloon
                  fprintf(fid,'%s\r\n','</ul>]]></description>');
                  
                  %add style
                  fprintf(fid,'%s\r\n',['         <styleUrl>#',style_list{rownum},'</styleUrl>']);
                  
                  %add point coordinates
                  fprintf(fid,'%s\r\n','         <Point>');
                  fprintf(fid,'%s\r\n',['            <coordinates>',sprintf('%0.6f,%0.6f',lon(rownum),lat(rownum)),'</coordinates>']);
                  fprintf(fid,'%s\r\n','         </Point>');
                  fprintf(fid,'%s\r\n','      </Placemark>');
                  
               end
               
               %close file
               fprintf(fid,'%s\r\n','  </Document>');
               fprintf(fid,'%s\r\n','</kml>');
               fclose(fid);
               
            end
            
         else
            msg = ['an error occurred converting balloon columns to string (',msg0,')'];
         end
         
      else
         if isempty(msg)
            msg = 'no valid coordinates are present in the data set';
         end
      end
      
   else
      msg = 'no geographic coordinate columns were found or specified columns are invalid';
   end
   
else  %bad input
   
   if nargin < 2
      msg = 'insufficient input';
   elseif isempty(fn)
      msg = 'filename is required';
   else
      msg = 'invalid data structure';
   end
   
end
