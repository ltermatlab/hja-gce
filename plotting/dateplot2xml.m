function msg = dateplot2xml(cols,plotwidth,thumbnails,interval,fn_plots,fn_xml,fn_index,pn,pagetitle,param,xsl,nav,fmt,h_fig)
%Generates an XML page and image files to represent time series data plots for a specified interval
%
%syntax: msg = dateplot2xml(cols,plotwidth,thumbnails,interval,fn_plots,fn_xml,fn_index,pn,pagetitle,param,xsl,nav,fmt,h_fig)
%
%inputs:
%  cols = number of colums per page (default = 1)
%  plotwidth = width of primary image or thumbnail image and primary image in pixels
%    (default = [300,figure width])
%  thumbnails = option to use images on HTML page as thumbnails which are hyperlinked
%      to full-size 96dpi images (i.e. generates 2 images per time interval):
%    0 = no
%    1 = yes (default)
%  interval = date interval for plots (see 'dateplots')
%    'native' = native date interval (no scaling)
%    'day' = 1 plot/day
%    'week' = 1 plot/week
%    'month' = 1 plot/month (default)
%    'year' = 1 plot/year
%    'decade' = 1 plot/10 years
%  fn_plots = base filename for plots (default = 'dateplot')
%  fn_xml = name for XML file (default = 'index.xml')
%  fn_index = name of corresponding plot index and dataset details file (default = '')
%  pn = pathname for XML file and images (default = pwd)
%  pagetitle = string to use as the page title (default = figure title)
%  param = string to use as the parameter caption (default = pagetitle)
%  xsl = filname or url of the XSL/XSLT to reference in the XML file (default = '')
%  nav = cell array of label and url pairs for breadcrumb navigation (default = '')
%  fmt = image format (default = png) -- see 'dateplots'
%  h_fig = figure to plot (default = gcf)
%
%outputs:
%  msg = text of any error message
%
%(c)2002-2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 15-Nov-2013

%validate output path
if exist('pn','var') ~= 1
   pn = '';
end
if isempty(pn)
   pn = pwd;
elseif strcmp(pn(end),filesep)
   pn = pn(1:end-1);
end

if exist(pn,'dir') == 7
   
   %use current figure if not specified
   if exist('h_fig','var') ~= 1
      h_fig = gcf;
   end
   
   %get figure handle, size in pixels
   figunits = get(h_fig,'Units');
   set(h_fig,'Units','pixels')
   figsize = get(h_fig,'Position');
   set(h_fig,'Units',figunits)
   
   %set defaults for other omitted parameters
   if exist('cols','var') ~= 1
      cols = 1;
   end
   
   if exist('plotwidth','var') ~= 1
      plotwidth = [300,figsize(3)];
   elseif length(plotwidth) < 2 || isnan(plotwidth(2))
      plotwidth = [plotwidth,figsize(3)];
   end
   
   if exist('thumbnails','var') ~= 1
      thumbnails = 1;
   end
   
   if exist('nav','var') ~= 1
      nav = '';
   end
   
   if exist('fmt','var') ~= 1
      fmt = 'png';
   end
   
   %use plot title for page title if not specified
   if exist('pagetitle','var') ~= 1
      h_ax = findobj(gcf,'Type','axes');
      for n = 1:length(h_ax)
         pagetitle = get(get(h_ax(n),'title'),'string');
         if size(pagetitle,1) > 1
            pagetitle = char(concatcellcols(trimstr(cellstr(pagetitle)'),' '));
            break
         end
      end
   end
   if ~isempty(pagetitle)
      if size(pagetitle,1) > 1
         strtemp = [cellstr(pagetitle)' ; repmat({' '},1,size(pagetitle,1))];
         pagetitle = deblank([strtemp{:}]);
      end
   end
   
   if exist('param','var') ~= 1
      param = pagetitle;
   end
   
   if exist('interval','var') ~= 1
      interval = 'month';
   end
   
   if exist('fn_plots','var') ~= 1
      fn_plots = 'dateplot';
   end
   
   if exist('fn_xml','var') ~= 1
      fn_xml = 'index.xml';
   end
   
   if exist('fn_index','var') ~= 1
      fn_index = 'index.xml';
   end
   
   if exist('xsl','var') ~= 1
      xsl = '';
   end
   
   %calculate thumbnail resolution based on ratio to figure size
   thumb_res = round((plotwidth(1)./figsize(3)) .* (figsize(3)./900) .* 96);
   image_res = round((plotwidth(2)./figsize(3)) .* 96);
   
   %call function to generate plots
   if thumbnails == 0
      [msg,filenames,dateranges] = dateplots(interval,fn_plots,pn,fmt,image_res,0,h_fig);
   else
      [msg,filenames,dateranges,thumbfiles] = dateplots(interval,fn_plots,pn,fmt,[image_res,thumb_res],1,h_fig);
   end
   
   %check for successful plot generation (return dateplots error message on failure)
   if ~isempty(filenames)
      
      %calculate table metrics, cell widths based on return data
      numrows = ceil(length(filenames)./cols);
      numplots = length(filenames);
      cellwidths = fix(repmat(100./cols,1,cols).*10)./10;
      if sum(cellwidths) ~= 100
         cellwidths(end) = 100-sum(cellwidths(1:end-1));
      end
      
      %init xml structure
      s_xml = struct('table','');
      
      %init table structure
      s_table = struct('row','');
      
      %loop through rows, cols, generating table info
      for n = 1:numrows
         s_table.row(n).title = '';
         for m = 1:cols
            widstr = sprintf('%0.1f%%',cellwidths(m));
            ctr = cols .* (n-1) + m;
            s_table.row(n).column(m).width = widstr;
            if ctr <= numplots
               s_table.row(n).column(m).label = ['Plot for ',dateranges{ctr}];
               if thumbnails ==  0
                  s_table.row(n).column(m).url_thumbnail = '';
               else
                  s_table.row(n).column(m).url_thumbnail = thumbfiles{ctr};
               end
               s_table.row(n).column(m).url_image = filenames{ctr};
            else
               s_table.row(n).column(m).label = '';
               s_table.row(n).column(m).url_thumbnail = '';
               s_table.row(n).column(m).url_image = '';
            end
         end
      end
      
      %add table structure to main xml structure
      s_xml.table = s_table;
      
      %generate navigation structure based on label/url pairs
      numlinks = floor(length(nav)./2);
      s_nav = [];
      for n = 1:numlinks
         ptr = 2 .* (n-1) + 1;
         s_nav.item(n).label = nav{ptr};
         s_nav.item(n).url = nav{ptr+1};
      end
      
      %generate xml fragments from nested structures
      xml_nav = struct2xml(s_nav,'navigation',1,0,3,3);
      xml = struct2xml(s_xml,'plots',1,0,3,3);
      
      %generate complete xml
      if ~isempty(xml)
         
         %generate xml preamble
         xml_pre = '<?xml version="1.0" encoding="ISO-8859-1"?>';
         if ~isempty(xsl)
            xml_pre = char(xml_pre,['<?xml-stylesheet type="text/xsl" href="',xsl,'"?>']);  %add xsl reference if specified
         end
         
         %concatenate all xml strings
         xml = char(xml_pre,'<root>', ...
            ['   <title>',pagetitle,'</title>'], ...
            ['   <parameter>',param,'</parameter>'], ...
            xml_nav, ...
            xml, ...
            ['   <url_plotindex>',fn_index,'</url_plotindex>'], ...
            ['   <url_data>../data/',fn_index,'</url_data>'], ...
            ['   <date_generated>',datestr(now),'</date_generated>'], ...
            '</root>');
         
         %write xml file to disk
         fid = fopen([pn,filesep,fn_xml],'w');
         for cnt = 1:size(xml,1)
            fprintf(fid,'%s\r',deblank(xml(cnt,:)));
         end
         fclose(fid);
         
      end
      
   end
   
else
   msg = 'invalid output directory';
end
