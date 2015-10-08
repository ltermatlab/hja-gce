function msg = thumbnail_index_xml(pn,filemask_images,thumbnail_suffix,nav,caption,pagetitle,xsl,fn_index,html)
%Generates an XML index of images and thumbnails for web display
%
%syntax: msg = thumbnail_index_xml(pn,filemask_images,thumbnail_suffix,nav,caption,pagetitle,xsl,fn_index,numcols,html)
%
%input:
%  pn = path containing files to index (string; required)
%  filemask_images = file specifier for images to index (string; required)
%  thumbnail_suffix = filename suffix for thumbnails (string; required)
%  nav = cell array of label and url pairs for breadcrumb navigation (cell array; optional; default = [])
%  caption = caption for breadcrumb navigation (string; optional; default = 'Images')
%  pagetitle = page title text (string; optional; default = caption)
%  xsl = url of the XSL to use for conversion to HTML (string; optional; 
%    default = 'http://gce-lter.marsci.uga.edu/public/xsl/thumbnail_index.xsl')
%  fn_index = filename for index (string; optional; default = 'index.xml')
%  html = option to transform the xml to html to generate an extra .html index file (integer; optional; default = 0)
%    0 = no (default)
%    1 = yes
%
%output:
%  msg = status message
%
%
%(c)2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 17-Aug-2015

%init output
msg = '';

%check for required arguments
if nargin >= 3 && isdir(pn)
   
   %validate input
   if ~isempty(filemask_images) && ~isempty(thumbnail_suffix)
      
      %validate xsl
      if exist('xsl','var') ~= 1
         xsl = 'http://gce-lter.marsci.uga.edu/public/xsl/toolbox/thumbnail_index.xsl';
      end
      
      %validate fn_index
      if exist('fn_index','var') ~= 1 || isempty(fn_index)
         fn_index = 'index.xml';
      end
      
      %validate caption
      if exist('caption','var') ~= 1
         caption = 'Images';
      end
      
      %validate pagetitle
      if exist('pagetitle','var') ~= 1
         pagetitle = caption;
      end
      
      %validate nav
      if exist('nav','var') ~= 1 || ~iscell(nav)
         nav = {caption,''};
      else
         nav = [nav,{caption,''}];
      end
      
      %validate html
      if exist('html','var') ~= 1 || isempty(html)
         html = 0;
      end
      
      %remove trailing separator from path
      pn = clean_path(pn);
      
      %get directory listing of matching files
      d = dir([pn,filesep,filemask_images]);
      
      if ~isempty(d)
         
         %remove thumbnails from index
         idx = ones(length(d),1);
         for n = 1:length(d)
            if strfind(d(n).name,thumbnail_suffix) > 0
               idx(n) = 0;
            end
         end
         d = d(idx==1);
         
         %create base image info structure
         s_image = struct(...
            'filename','', ...
            'width',[], ...
            'height',[], ...
            'filesize',[], ...
            'format',[], ...
            'colortype','', ...
            'bitdepth',[], ...
            'camera_make','', ...
            'camera_model','', ...
            'date_taken','', ...
            'iso',[], ...
            'focal_length',[], ...
            'colorspace',[] ...
            );
         s_thumbnail = struct( ...
            'filename','', ...
            'width',[], ...
            'height',[], ...
            'filesize',[]);
         s_images = struct('original',s_image,'thumbnail',s_thumbnail);
         
         %replicate structure to match number of files
         num_images = length(d);
         s_images = repmat(s_images,num_images,1);
         
         %loop through file list populating structure
         for n = 1:num_images
            
            %get name and size of file from directory listing
            fn = d(n).name;
            filesize = d(n).bytes;
            
            %init image info record
            s_images(n).original.filename = fn;
            s_images(n).original.filesize = filesize;
            
            %get exif metadata
            info = imfinfo([pn,filesep,fn]);
            
            %populate structure record with file info and metadata
            if ~isempty(info)
               
               %populate fixed fields
               s_images(n).original.format = info.Format;
               s_images(n).original.width = info.Width;
               s_images(n).original.height = info.Height;
               s_images(n).original.bitdepth = info.BitDepth;
               s_images(n).original.colortype = info.ColorType;
               
               %check for extra camera fields
               if isfield(info,'Make')
                  s_images(n).original.camera_make = info.Make;
               end
               if isfield(info,'Model')
                  s_images(n).original.camera_model = info.Model;
               end
               if isfield(info,'DigitalCamera')
                  if isfield(info.DigitalCamera,'DateTimeOriginal')
                     s_images(n).original.date_taken = info.DigitalCamera.DateTimeOriginal;
                  end
                  if isfield(info.DigitalCamera,'ISOSpeedRatings')
                     s_images(n).original.iso = info.DigitalCamera.ISOSpeedRatings;
                  end
                  if isfield(info.DigitalCamera,'FocalLength')
                     s_images(n).original.focal_length = info.DigitalCamera.FocalLength;
                  end
                  if isfield(info.DigitalCamera,'ColorSpace')
                     s_images(n).original.colorspace = info.DigitalCamera.ColorSpace;
                  end
               end
               
            end
            
            %check for thumbnail, get metrics
            [~,fn_base,fn_ext] = fileparts(fn);
            fn_thumb = [fn_base,thumbnail_suffix,fn_ext];
            if exist([pn,filesep,fn_thumb],'file') == 2
               info = imfinfo([pn,filesep,fn_thumb]);
               s_images(n).thumbnail.filename = fn_thumb;
               s_images(n).thumbnail.width = info.Width;
               s_images(n).thumbnail.height = info.Height;
               s_images(n).thumbnail.filesize = info.FileSize;
            end
            
         end
                 
         %generate navigation structure based on label/url pairs
         s_nav = [];
         if ~isempty(nav)
            numlinks = floor(length(nav)./2);
            for n = 1:numlinks
               ptr = 2 .* (n-1) + 1;
               s_nav.item(n).label = nav{ptr};
               s_nav.item(n).url = nav{ptr+1};
            end
         end
         
         %generate xml fragments from nested structures
         xml_nav = struct2xml(s_nav,'navigation',1,0,3,3);
         xml = struct2xml(s_images,'image',1,0,3,6);
         
         %generate xml preamble
         xml_pre = '<?xml version="1.0" encoding="ISO-8859-1"?>';
         if ~isempty(xsl)
            xml_pre = char(xml_pre,['<?xml-stylesheet type="text/xsl" href="',xsl,'"?>']);  %add xsl reference if specified
         end
         
         %concatenate all xml strings
         xml = char(xml_pre, ...
            '<root>', ...
            ['   <title>',pagetitle,'</title>'], ...
            xml_nav, ...
            '   <images>', ...
            xml, ...
            '   </images>', ...
            ['   <date_generated>',datestr(now),'</date_generated>'], ...
            '</root>');
         
         %write xml file to disk
         fid = fopen([pn,filesep,fn_index],'w');
         for cnt = 1:size(xml,1)
            fprintf(fid,'%s\r',deblank(xml(cnt,:)));
         end
         fclose(fid);
         
         %transform xml to html
         if html == 1 && exist([pn,filesep,fn_index],'file') == 2
            fn_output = strrep(fn_index,'.xml','.html');
            xslt([pn,filesep,fn_index],xsl,[pn,filesep,fn_output]);
         end
         
         msg = ['successfully generated xml file as ''',pn,filesep,fn_index,''''];
         
      else
         msg = 'no matching files in directory';
      end
      
   else
      msg = 'invalid filemask or thumbnail suffix';
   end
   
else
   if nargin < 4
      msg = 'required arguments were not specified';
   else
      msg = 'invalid source path';
   end
end