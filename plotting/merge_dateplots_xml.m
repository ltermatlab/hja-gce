function msg = merge_dateplots_xml(prefix_array,xml_array,caption_array,nav_array,fn_xml,pn,pagetitle,xsl,nav,html,fmt)
%Generates an HTML table of date plot thumbnails based on multiple sets of existing plots in a specified directory
%
%syntax: msg = merge_dateplots_xml(prefix_array,xml_array,caption_array,nav_array,fn_xml,pn,pagetitle,xsl,nav,html,fmt)
%
%input:
%  prefix_array = cell array of plot prefix strings to include (matching date ranges for each plot type
%    will be combined on the same table row for comparisons - 1 table row will be generated per matched prefix)
%  xml_array = cell array of XML files corresponding to each entry in 'prefix_array' for url generation
%  caption_array = array of captions to display for each entry in 'prefix_array'
%  nav_array = array of short captions to display in the navigation bar for each entry in 'prefix_array'
%  fn_xml = name of XML file to generate
%  pn = pathname for plot files to analyze and final XML file
%  pagetitle = string to use as the page title (default = '')
%  xsl = filname or url of the XSL/XSLT to reference in the XML file (default = '')
%  nav = cell array of label and url pairs for breadcrumb navigation (default = '')
%  html = option to transform the xml plot to html automatically (resulting in both .xml and .html files)
%    0 = no (default)
%    1 = yes
%  fmt = image format (default = png) -- see 'dateplots'
%
%output:
%  msg = status message
%
%
%(c)2002-2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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

if nargin >= 5

   %validate output path
   if exist('pn','var') ~= 1
      pn = '';
   end
   if isempty(pn)
      pn = pwd;
   end

   if isdir(pn)

      %validate input
      if length(prefix_array) == length(xml_array) && length(prefix_array) == length(caption_array) && length(prefix_array) == length(nav_array)

         %remove terminal directory separator from path
         if strcmp(pn(end),filesep)
            pn = pn(1:end-1);
         end

         %validate, format prefix_array
         if ischar(prefix_array)
            prefix_array = cellstr(prefix_array);
         end

         %validate plot title string, add markup
         if exist('pagetitle','var') ~= 1
            pagetitle = '';
         end

         %supply default plot extension if omitted
         if exist('fmt','var') ~= 1
            fmt = 'png';
         end

         if exist('xsl','var') ~= 1
            xsl = '';
         end
         
         %default to html mode if omitted
         if exist('html','var') ~= 1 || isempty(html) || ~isnumeric(html) || html ~= 1
            html = 0;
         end

         %get directory listing for thumbnail plots matching spec
         d = dir([pn,filesep,'*_small.',fmt]);

         if ~isempty(d)

            allfiles = {d.name}';
            meta = struct('prefix','','filename','','start',[],'end',[],'interval','');
            rownum = 0;

            %iterate through files, parsing dates and filling in metadata
            for n = 1:length(prefix_array)
               
               %init date interval arrays
               interval = '';
               dnum1 = [];
               dnum2 = [];
               
               %get prefix
               prefix = prefix_array{n};
               
               %get index of plot row based on prefix
               Irows = strncmp(prefix,allfiles,length(prefix));
               
               if ~isempty(Irows)
                  
                  %get filenames and date string
                  files = allfiles(Irows);
                  date_str = strrep(strrep(strrep(files,prefix,''),['_small.',fmt],''),'_','');

                  %parse date format
                  for m = 1:length(files)
                     d = date_str{m};
                     if length(d) == 4  %year format
                        dnum1 = datenum(['01/01/',d]);
                        dnum2 = dnum1;
                        interval = 'year';
                     elseif length(d) == 5  %month/year format
                        dnum1 = datenum(['01-',d(1:3),'-',d(4:5)]);
                        dnum2 = dnum1;
                        interval = 'month';
                     elseif length(d) == 11  %day format
                        dnum1 = datenum(d);
                        dnum2 = dnum1;
                        interval = 'day';
                     elseif ~isempty(strfind(d,'-'))  %date range format
                        [d1,rem] = strtok(d,'-');
                        d2 = strtok(rem,'-');
                        if length(d1) == 8  %weekly or native format
                           dnum1 = datenum([d1(5:6),'/',d1(7:8),'/',d1(1:4)]);
                           dnum2 = datenum([d2(5:6),'/',d2(7:8),'/',d2(1:4)]);
                           interval = 'week';
                        elseif length(d1) == 4  %decade format
                           dnum1 = datenum(['01/01/',d1]);
                           dnum2 = datenum(['01/01/',d2]);
                           interval = 'decade';
                        end
                     end
                     
                     %add parsed info to metadata structure
                     rownum = rownum + 1;
                     meta(rownum).prefix = prefix;
                     meta(rownum).filename = files{m};
                     meta(rownum).start = dnum1;
                     meta(rownum).end = dnum2;
                     meta(rownum).interval = interval;
                     
                  end
                  
               end
               
            end

            if ~isempty(meta)

               %check for consistent interval
               interval = unique({meta.interval});

               if length(interval) == 1 && ~cellfun('isempty',interval)

                  interval = char(interval);

                  %get sorted list of unique start dates
                  startdates = unique([meta.start]);

                  %get list of prefixes in order specified, omitting any not matched
                  matched_prefixes = unique({meta.prefix});
                  prefixes = [];
                  plotcaptions = [];
                  navcaptions = [];
                  for n = 1:length(prefix_array)
                     if ~isempty(strcmp(matched_prefixes,prefix_array{n}))
                        prefixes = [prefixes ; prefix_array(n)];
                        plotcaptions = [plotcaptions ; caption_array(n)];
                        navcaptions = [navcaptions ; nav_array(n)];
                     end
                  end

                  %calculate table size
                  numrows = length(startdates);
                  cols = length(prefixes);

                  %calculate table cell widths
                  cellwidths = fix(repmat(100./cols,1,cols).*10)./10;
                  if sum(cellwidths) ~= 100
                     cellwidths(end) = 100-sum(cellwidths(1:end-1));
                  end

                  %init xml structure
                  s_xml = struct('table','');

                  %init table structure
                  s_table = struct('row','');

                  %generate table
                  for n = 1:numrows

                     Irows = find([meta.start]==startdates(n));

                     switch interval
                        case 'decade'
                           caption = ['Plots for ',datestr(startdates(n),10),' to ',datestr(meta(Irows(1)).end,10)];
                        case 'year'
                           caption = ['Plots for ',datestr(startdates(n),10)];
                        case 'month'
                           caption = ['Plots for ',date2monthyear(startdates(n))];
                        case 'week'
                           caption = ['Plots for ',datestr(startdates(n),1),' to ',datestr(meta(Irows(1)).end,1)];
                        otherwise %day
                           caption = ['Plots for ',datestr(startdates(n),1)];
                     end

                     %add row title
                     s_table.row(n).title = caption;

                     %generate plot cells
                     for m = 1:cols
                        Irow = strcmp(prefixes{m},{meta(Irows).prefix});
                        if ~isempty(Irow)
                           fn = meta(Irows(Irow)).filename;
                           widstr = sprintf('%0.1f%%',cellwidths(m));
                           s_table.row(n).column(m).width = widstr;
                           s_table.row(n).column(m).label = plotcaptions{m};
                           s_table.row(n).column(m).url_thumbnail = fn;
                           s_table.row(n).column(m).url_image = strrep(fn,'_small','');
                        end
                     end

                  end

                  %add table structure to main xml structure
                  s_xml.table = s_table;

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

                  %generate indiv_plots for secondary navigation
                  s_indiv_plots = struct('item','');
                  if html == 1
                     fn_ext = '.html';
                  else
                     fn_ext = '.xml';
                  end
                  for n = 1:length(prefixes)
                     s_indiv_plots.item(n).label = navcaptions{n};
                     s_indiv_plots.item(n).url = [prefixes{n},fn_ext];
                  end

                  %generate xml fragments from nested structures
                  xml_nav = struct2xml(s_nav,'navigation',1,0,3,3);
                  xml_indiv_plots = struct2xml(s_indiv_plots,'indiv_plots',1,0,3,3);
                  xml = struct2xml(s_xml,'plots',1,0,3,3);

                  %generate complete xml
                  if ~isempty(xml)

                     %generate xml preamble
                     xml_pre = '<?xml version="1.0" encoding="ISO-8859-1"?>';
                     if ~isempty(xsl)
                        xml_pre = char(xml_pre,['<?xml-stylesheet type="text/xsl" href="',xsl,'"?>']);  %add xsl reference if specified
                     end

                     %generate appropriate dataset details index name
                     if html == 1
                        fn_data = strrep(fn_xml,'.xml','.html');
                     else
                        fn_data = fn_xml;
                     end
                     
                     %concatenate all xml strings
                     xml = char(xml_pre, ...
                        '<root>', ...
                        ['   <title>',pagetitle,'</title>'], ...
                        '   <parameter>all</parameter>', ...
                        xml_nav, ...
                        xml_indiv_plots, ...
                        xml, ...
                        ['   <url_data>../data/',fn_data,'</url_data>'], ...
                        ['   <date_generated>',datestr(now),'</date_generated>'], ...
                        '</root>');

                     %write xml file to disk
                     fid = fopen([pn,filesep,fn_xml],'w');
                     for cnt = 1:size(xml,1)
                        fprintf(fid,'%s\r',deblank(xml(cnt,:)));
                     end
                     fclose(fid);
                     
                     %transform xml to html
                     if html == 1 && exist([pn,filesep,fn_xml],'file') == 2
                        fn_html = strrep(fn_xml,'.xml','.html');
                        xslt([pn,filesep,fn_xml],xsl,[pn,filesep,fn_html]);
                     end

                     msg = ['successfully generated xml file as ''',pn,filesep,fn_xml,''''];

                  else
                     msg = 'failed to generate xml file';
                  end

               else
                  msg = 'multiple plot intervals are not supported by this function - operation cancelled';
               end

            else
               msg = 'plot filenames could not be parsed - operation cancelled';
            end

         else
            msg = ['no thumbnail plots with the extension ''',fmt,''' were found in the specified directory'];
         end

      else
         msg = 'mismatched prefix, xml, caption and navigation arrays';
      end

   else
      msg = 'invalid output directory';
   end

else
   msg = 'insufficient arguments for function';
end