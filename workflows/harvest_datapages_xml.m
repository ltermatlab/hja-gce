function msg = harvest_datapages_xml(pn_base,subdir,harvest_id,html,interval,flagcols)
%Generates xml-based data distribution pages for harvested data files for a specified station
%
%syntax: msg = harvest_datapages_xml(pn_base,subdir,harvest_id,html,interval,flagcols)
%
%inputs:
%  pn_base = base pathname containing files to index (string - required)
%  subdir = array of subdirectories within pn_base to index (empty string or cell array of strings - required)
%  harvest_id = id of a harvest station configuration profile in harvest_info.m (string - required)
%  html = option to transform the xml index to html automatically (resulting in both .xml and .html files)
%    0 = no (default)
%    1 = yes
%  interval = data interval to report (required)
%     '' = automatic based on data/time information or file name (default)
%     character array = data interval text (e.g. '1 hr', 'annual', 'N/A')
%  flagcols = option to instantiate flag columns before indexing (see flags2cols.m):
%    'auto' = 'MD' for data sets with text columns, otherwise 'ED' (default)
%    '' = do not instantiate
%    'M' for multiple text flag columns after the corresponding data column (if flags defined)
%    'MD' same as 'M', except text flags are displayed for all data/calculation columns
%    'MC' same as 'M', except text flags are displayed for all columns
%    'MA' for multiple text flag columns appended after the data columns
%    'MAD' same as 'MA', except text flags are displayed for all data/calculation columns
%    'MAC' same as 'MA', except text flags are displayed for all columns
%    'E' for multiple encoded flag columns after the corresponding data column
%    'ED' same as 'E', except encoded flags are displayed for all data/calculation columns
%    'EC' same as 'E', except encoded flags are displayed for all columns
%    'EA' for multiple encoded flag columns appended after the data columns
%    'EAD' same as 'EA', except encoded flags are displayed for all data/calculation columns
%    'EAC' same as 'EA', except encoded flags are displayed for all columns
%
%outputs:
%  msg = status message
%
%notes:
%  1) edit the configuration function 'harvest_info.m' in the 'demo' directory and save it in 'userdata'
%     to register settings for each station
%  2) harvested files must be in a 'data' directory below pn_base/subdir (or pn_base if no
%     subdirectory is specified) for relative hyperlinks on data and plot index pages to function
%  3) links to data files will be generated by matching the following extensions in the data directory:
%        .csv = Spreadsheet (CSV Text)
%        -meta.txt = Metadata for Spreadsheet
%        .rpt = Tab-delimited Text Report
%        .mat = GCE Data Toolbox File
%        _vars.mat = Standard MATLAB File (variables)
%        .kml = Google Earth KML File
%        -data.htm = Web Table (HTML text)
%        -data.html = Web Table (HTML text)
%        -data.xml = XML File (Text)
%
%(c)2012-2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 23-May-2013

msg = '';

if nargin >= 3 && isdir(pn_base)
   
   %convert character subdirectory to cell array
   if ischar(subdir)
      subdir = cellstr(subdir);
   end
      
   %supply default interval option if omitted
   if exist('interval','var') ~= 1
      interval = '';  %automatic interval
   end
   
   %set default html option
   if exist('html','var') ~= 1 || html ~= 1
      html = 0;
   end
   
   %supply default flagcols option if omitted
   if exist('flagcols','var') ~= 1
      flagcols = 'auto';  %automatic flag columns
   end
   
   %retrieve configuration information from harvest_info.m
   [nav,titlestring,xsl_index,xsl_details,url_base] = harvest_info(harvest_id);
   
   %remove terminal file separator from path
   pn_base = clean_path(pn_base);
   
   %validate url_base and navigation array
   if ~isempty(nav) && iscell(nav)
      
      %remove terminal slash on url_base if present
      if ~isempty(url_base) && strcmp(url_base(end),'/')
         url_base = url_base(1:end-1);
      end
      
      %generate navigation structure based on label/url pairs
      numlinks = floor(length(nav)./2);
      s_nav = [];
      for n = 1:numlinks
         ptr = 2 .* (n-1) + 1;
         s_nav.item(n).label = escape_chars(nav{ptr});
         s_nav.item(n).url = escape_chars(nav{ptr+1});
      end
      
      %generate index for each subdirectory
      for n = 1:length(subdir)
         
         %generate data path, base url
         if ~isempty(subdir{n})
            pn_data = [pn_base,filesep,subdir{n},filesep,'data'];
            url_data = [url_base,'/',subdir{n},'/data/'];
         else  %no subdirectory - use pn_base as root directory
            pn_data = [pn_base,filesep,'data'];
            url_data = [url_base,'/data/'];
         end
         
         %validate subdirectory
         if isdir(pn_data)
            
            %index all data sets in the directory
            index = search_index(pn_data,[],'rebuild',0,flagcols);
            
            if ~isempty(index)
               
               %init xml structure
               s_xml = struct('dataset_id','', ...
                  'dataset_title','', ...
                  'url_details','', ...
                  'url_plots','', ...
                  'study_period','', ...
                  'files','', ...
                  'date_index','');
               
               %loop through index info for each file
               for m = 1:length(index)
                  
                  %load indexed data file from source directory
                  v = load([index(m).path,filesep,escape_chars(index(m).filename)]);
                  data = v.(index(m).varname);
                  
                  %get base filename and generate relative plot url
                  [tmp,fn_base] = fileparts(index(m).filename);                          %#ok<ASGLU>
                  if html == 0
                     url_plots = ['../plots/',escape_chars(fn_base),'.xml'];
                  else
                     url_plots = ['../plots/',escape_chars(fn_base),'.html'];
                  end
                  
                  %get study dates for determination of start, end and interval
                  dt = get_studydates(data);
                  
                  %check for date/time info or use metadata if not present
                  if ~isempty(dt)
                     dt = sort(dt);
                     date_start = datestr(min(dt(~isnan(dt))),1);
                     date_end = datestr(max(dt(~isnan(dt))),1);
                     dt_diff = diff(dt);
                     int_min = min(dt_diff(dt_diff>0));
                  else
                     date_start = lookupmeta(data,'Study','BeginDate');
                     date_end = lookupmeta(data,'Study','EndDate');
                     int_min = NaN;
                  end
                  
                  %calculate interval unless specified as input
                  if isempty(interval)
                     
                     %check for filename strings to infer interval if no date-time info
                     if isnan(int_min)
                        
                        if ~isempty(strfind(fn_base,'realtime'))
                           data_interval = '<=60 min';
                        elseif ~isempty(strfind(fn_base,'daily'))
                           data_interval = '1 day';
                        elseif ~isempty(strfind(fn_base,'hourly'))
                           data_interval = '1 hr';
                        elseif ~isempty(strfind(fn_base,'monthly'))
                           data_interval = '1 month';
                        elseif ~isempty(strfind(fn_base,'yearly'))
                           data_interval = '1 year';
                        else
                           data_interval = '(unknown)';
                        end
                        
                     else
                        
                        %calculate from minimum interval
                        if int_min >= 365
                           if int_min == 365
                              data_interval = '1 year';
                           else
                              data_interval = sprintf('%d years',round(int_min./365));
                           end
                        elseif int_min >= 28
                           if int_min == 28
                              data_interval = '1 month';
                           else
                              data_interval = sprintf('%d days',round(int_min));
                           end
                        elseif int_min >= 1
                           data_interval = sprintf('%0.1f day',int_min);
                        elseif int_min >= 1/24
                           data_interval = sprintf('%0.1f hr',int_min.*24);
                        else
                           data_interval = sprintf('%0.1f min',int_min.*24.*60);
                        end
                        
                        %check for unmatched interval
                        if isempty(data_interval)
                           data_interval = '(unknown)';
                        end
                        
                     end
                     
                  else
                     
                     %use user-specified interval string
                     data_interval = interval;
                     
                  end
                  
                  %add subdirectory to index page navigation structure
                  numlinks = length(s_nav.item);
                  s_nav_sub = s_nav;
                  if ~isempty(subdir{n})
                     s_nav_sub.item(numlinks+1).label = subdir{n};
                  else
                     s_nav_sub.item(numlinks+1).label = 'Data';
                  end
                  s_nav_sub.item(numlinks+1).url = '';
                  
                  %add index link to details page navigation structure
                  s_nav_details = s_nav_sub;
                  if html == 0
                     s_nav_details.item(numlinks+1).url = 'index.xml';
                  else
                     s_nav_details.item(numlinks+1).url = 'index.html';
                  end
                  
                  %generate structure for xml creation
                  s_xml(m).dataset_id = fn_base;
                  s_xml(m).dataset_title = data.title;
                  if html == 0
                     s_xml(m).url_details = [fn_base,'.xml'];
                  else
                     s_xml(m).url_details = [fn_base,'.html'];
                  end
                  s_xml(m).url_plots = url_plots;
                  s_xml(m).study_period = struct('date_start',date_start,'date_end',date_end,'interval',data_interval);
                  s_xml(m).date_index = datestr(now,0);
                  
                  %define array of distribution file extensions to match and format descriptions
                  ext_list = {'.csv','Spreadsheet (CSV Text)','spreadsheet format with minimal header'; ...
                     '-meta.txt','Metadata for Spreadsheet','formatted text metadata'; ...
                     '.rpt','Tab-delimited Text Report','data table, metadata, statistics'; ...
                     '.mat','GCE Data Toolbox File','GCE Data Structure for use with the GCE Data Toolbox sofware'; ...
                     '_vars.mat','Standard MATLAB File (variables)','MATLAB file with columns as variables, metadata array'; ...
                     '.kml','Google Earth KML File','Google Earth KML file with placemarks for each data record'; ...
                     '-data.htm','Web Table (HTML text)','web table of data values'; ...
                     '-data.html','Web Table (HTML text)','web table of data values'; ...
                     '-data.xml','XML File (Text)','XML file containing data values in dataset/row/col elements'};
                  
                  %generate sub-structure of file links based on matching distribution files at destination
                  files = struct('label','','description','','url','','filesize','');
                  file_cnt = 0;
                  for f = 1:size(ext_list,1)
                     if exist([index(m).path,filesep,fn_base,ext_list{f,1}],'file') == 2
                        d = dir([index(m).path,filesep,fn_base,ext_list{f,1}]);
                        file_cnt = file_cnt + 1;  %increment file counter for structure dimension
                        files(file_cnt).label = ext_list{f,2};
                        files(file_cnt).description = ext_list{f,3};
                        files(file_cnt).url = [url_data,fn_base,ext_list{f,1}];
                        files(file_cnt).filesize = [sprintf('%0.0f',(d(1).bytes./1024)),'kb'];
                     end
                  end
                  
                  %add file list to master xml structure
                  s_xml(m).files(1).file = files;
                  
                  %call subroutine to convert index to xml
                  [status2,msg2] = sub_index2xml(index(m),files,s_nav_details, ...
                     [fn_base,'.xml'],pn_data,xsl_details,url_plots,html);
                  if status2 == 0
                     msg = char(msg,['failed to create dataset detail page for ',fn_base,'.mat (',msg2,')']);
                  end
                  
               end
               
               %generate xml fragment from nested structure
               xml_nav = struct2xml(s_nav_sub,'navigation',1,0,3,3);
               xml = struct2xml(s_xml,'dataset_summary',1,0,3,3);
               
               %generate complete xml and write to destination
               if ~isempty(xml)
                  
                  %generate xml heading, root element, title element and add navigation and main xml body
                  xml = char('<?xml version="1.0" encoding="ISO-8859-1"?>', ...
                     ['<?xml-stylesheet type="text/xsl" href="',xsl_index,'"?>'], ...
                     '<root>',['   <title>',escape_chars(titlestring),'</title>'],xml_nav,xml,'</root>');
                  
                  %write xml to disl
                  fid = fopen([pn_data,filesep,'index.xml'],'w');
                  for cnt = 1:size(xml,1)
                     fprintf(fid,'%s\r',deblank(xml(cnt,:)));
                  end
                  fclose(fid);
                  
                  %transform xml to html
                  if html == 1
                     try
                        xslt([pn_data,filesep,'index.xml'],xsl_index,[pn_data,filesep,'index.html']);
                        msg = char(msg,['successfully created xml and html data pages for ',pn_data]);
                     catch e
                        msg = char(msg,['successfully created xml data page for ',pn_data], ...
                           'error transforming xml to html:',e.message);
                     end
                  else
                     msg = char(msg,['successfully created xml data page for ',pn_data]);
                  end
                  
               else
                  msg = char(msg,['failed to create data page for ',pn_data]);
               end
               
            else
               msg = char(msg,['no files found in ',pn_data]);
            end
            
         else
            msg = char(msg,['invalid path ',pn_data]);
         end
         
      end
      
   else  %data directory or url error
      
      if isempty(url_base)
         msg = 'invalid base url';
      else
         msg = 'invalid data directory';
      end
      
   end
   
else  %input error
   
   if nargin < 3
      msg = 'insufficient arguments for function';
   else
      msg = 'invalid base pathname or subdirectory input';
   end
   
end


%subfunction to generate dataset detail pages from indices
function [status,msg] = sub_index2xml(index,files,s_nav,fn_xml,pn_xml,xsl,url_plots,html)
%input:
%  index = index structure from search_index.m (struct)
%  files = structure of file download information (struct)
%  s_nav = structure containing navigation breadcrumbs to include (struct)
%  fn_xml = filename for the xml output (string)
%  pn_xml = pathname for the xml output (string)
%  xsl = filename or url of the xsl file for displaying fn_xml
%  url_plots = url of the corresponding plot page
%  html = option to transform and cache html from the xml and xsl (0 = no, 1 = yes/default)
%
%output:
%  status = status code (1 = success, 0 = error occurred)
%  msg = text of any error message

msg = '';
status = 1;

if isdir(pn_xml) && length(index) == 1
   
   %parse filename to get base filename/id
   [tmp,fn_base] = fileparts(index.filename);                                           %#ok<ASGLU>
   
   %init xml structure
   s_xml = struct('dataset_id',fn_base, ...
      'title',index.title, ...
      'contributor',index.author, ...
      'abstract',index.abstract, ...
      'keywords','', ...
      'study_type','Monitoring', ...
      'study_period','', ...
      'bounding_box','', ...
      'study_sites','', ...
      'columns','', ...
      'table_size',index.records, ...
      'metadata_files','', ...
      'data_files','', ...
      'url_plots',url_plots, ...
      'date_index',datestr(now,0));
   
   %generate keyword list
   kw = index.keywords;
   if ~isempty(kw)
      s_kw = struct('keyword','');
      [s_kw(1:length(kw)).keyword] = deal(kw{:});
      s_xml.keywords = s_kw';
   end
   
   %generate study period info
   date_start = index.date_start;
   date_end = index.date_end;
   s_period = struct('date_start','','date_end','');
   if ~isnan(date_start)
      s_period.date_start = datestr(date_start,1);
   else
      s_period.date_start = '';
   end
   if ~isnan(index.date_end)
      s_period.date_end = datestr(date_end,1);
   else
      s_period.date_end = '';
   end
   s_xml.study_period = s_period;
   
   %generate site info structure based on geographic lookups
   s_sites = '';
   sites = index.sites;
   if ~isempty(sites)
      %check for geographic lookup data
      if exist('geo_polygons.mat','file') == 2 && exist('geo_locations.mat','file') == 2
         v = load('geo_polygons.mat'); polygons = v.polygons;
         v = load('geo_locations.mat'); locations = v.locations;
         if ischar(sites)
            sites = cellstr(sites);
         end
         for n = 1:length(sites)
            Isite = find(strcmp({polygons.SiteCode},sites{n}));  %look for matching sites
            if ~isempty(Isite)
               s_sites(1).site(n).sitecode = sites{n};
               s_sites(1).site(n).sitename = polygons(Isite).SiteName;
               s_sites(1).site(n).location = polygons(Isite).SiteLocation;
               s_sites(1).site(n).url = '';
            else
               Isite = find(strcmpi({locations.Location},sites{n}));  %look for matching locations
               if ~isempty(Isite)
                  s_sites(1).site(n).sitecode = locations(Isite).Location;
                  s_sites(1).site(n).sitename = locations(Isite).Name;
                  s_sites(1).site(n).location = locations(Isite).TypeName;
                  s_sites(1).site(n).url = '';
               else
                  s_sites(1).site(n).sitecode = sites{n};
                  s_sites(1).site(n).sitename = '';
                  s_sites(1).site(n).location = '';
                  s_sites(1).site(n).url = '';
               end
            end
         end
      else  %no lookup data - just use codes from index
         for n = 1:length(sites)
            s_sites(1).site(n).sitecode = sites{n};
            s_sites(1).site(n).sitename = '';
            s_sites(1).site(n).location = '';
            s_sites(1).site(n).url = '';
         end
      end
   else
      s_sites = '';
   end
   
   %add site info to xml structure
   s_xml.study_sites = s_sites;
   
   %format coordinates
   if ~isnan(index.wboundlon)
      str_wlon = sprintf('%0.5f�',index.wboundlon);
   else
      str_wlon = 'unspecified';
   end
   if ~isnan(index.eboundlon)
      str_elon = sprintf('%0.5f�',index.eboundlon);
   else
      str_elon = 'unspecified';
   end
   if ~isnan(index.nboundlat)
      str_nlat = sprintf('%0.5f�',index.nboundlat);
   else
      str_nlat = 'unspecified';
   end
   if ~isnan(index.sboundlat)
      str_slat = sprintf('%0.5f�',index.sboundlat);
   else
      str_slat = 'unspecified';
   end
   
   %add bounding box to xml structure
   s_xml.bounding_box = struct('wboundlon',str_wlon, ...
      'nboundlat',str_nlat, ...
      'eboundlon',str_elon, ...
      'sboundlat',str_slat);
   
   %generate attribute list
   cols = index.columns;
   units = index.units;
   datatypes = index.datatypes;
   vartypes = index.variabletypes;
   desc = index.descriptions;
   numcols = length(cols);
   colnums = num2cell(1:numcols);
   s_cols = [];
   [s_cols(1).column(1:numcols).number] = deal(colnums{:});
   [s_cols(1).column(1:numcols).name] = deal(cols{:});
   [s_cols(1).column(1:numcols).units] = deal(units{:});
   [s_cols(1).column(1:numcols).datatype] = deal(datatypes{:});
   [s_cols(1).column(1:numcols).variabletype] = deal(vartypes{:});
   [s_cols(1).column(1:numcols).description] = deal(desc{:});
   
   %add column info to xml structre
   s_xml.columns = s_cols';

   %look up metadata file - split files into s_data and s_metadata
   Imeta = strncmpi('Metadata',{files.label},8);
   s_meta = files(Imeta);
   s_data = files(~Imeta);
   
   %add file info to master xml structure
   if ~isempty(s_data)
      s_xml.data_files(1).file = s_data;
   else
      s_xml.data_files(1).file = '';
   end
   
   %generate metadata download list
   if ~isempty(s_meta)
      s_xml.metadata_files.file = s_meta;
   else
      s_xml.metadata_files.file = '';
   end
   
   %generate xml fragment from structure
   xml_nav = struct2xml(s_nav,'navigation',1,0,3,3);
   xml = struct2xml(s_xml,'dataset_details',1,0,3,3);
   
   %generate complete xml file and write to destination
   if ~isempty(xml) && ~isempty(xml_nav)
      
      %generate xml heading
      xml = char('<?xml version="1.0" encoding="ISO-8859-1"?>', ...
         ['<?xml-stylesheet type="text/xsl" href="',xsl,'"?>'], ...
         '<root>','   <title>Dataset Details</title>',xml_nav,xml,'</root>');
      
      %write content to xml file
      fid = fopen([pn_xml,filesep,fn_xml],'w');
      for cnt = 1:size(xml,1)
         fprintf(fid,'%s\r',deblank(xml(cnt,:)));
      end
      fclose(fid);
      
      %check for transform option
      if html == 1
         [pn_html,fn_html] = fileparts([pn_xml,filesep,fn_xml]);  %parse filename
         try
            xslt([pn_xml,filesep,fn_xml],xsl,[pn_html,filesep,fn_html,'.html']);  %transform xml
         catch e
            status = 0;
            msg = ['an error occurred transforming the XML files (',e.message,')'];
         end
      end
   else
      status = 0;  %flag error
      msg = 'an error occurred generating the XML file';
   end
   
else
   status = 0;  %flag error
   msg = 'invalid output path or dataset index';
end

