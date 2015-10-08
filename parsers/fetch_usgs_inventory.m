function [s,msg,url] = fetch_usgs_inventory(states,datatypes,bbox,fn,pn,url_base)
%Fetches a USGS monitoring site inventory report and generates a USGS stations dataset
%
%syntax: [s,msg,url] = fetch_usgs_inventory(state,datatypes,bbox,fn,pn,url_base)
%
%input:
%  states = cell array or comma-separated list of state codes (2 column character array, e.g. 'ga', '' for any)
%  datatypes = cell array or comma-separated list of data type codes to query
%    'rt' = real-time and recent daily (default)
%    'peak' = peak streamflow
%    'discharge' = daily discharge
%    'qw' = water quality
%    'gw' = groundwater
%    'any' = any type
%  bbox = geographic bounding box in decimal degrees (4-column array of nw_lon, nw_lat, se_lon, se_lat; default = [])
%  fn = filename for saving the xml file (default = 'usgs_inventory_[states]_[datatypes]_[YYYY]-[MM]-[DD].xml')
%  pn = path for output file (default = 'search_webcache' toolbox directory)
%  url_base = URL base for query (default = 'http://waterdata.usgs.gov/nwis/inventory');
%
%output:
%  s = data structure containing summary information for USGS sites
%  msg = status message
%  url = generated USGS NWIS url (for debugging purposes)
%
%(c)2010-2011 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 07-Apr-2011

%init output
s = [];
msg = '';
url = '';

%check for GUI call
if ~isempty(findobj('tag','dlgFetchUSGS'))
   guimode = 1;
else
   guimode = 0;
end

if guimode == 1; ui_progressbar('init',4,'Generating USGS query'); drawnow; end
%init query type criteria
criteria = '';

%check for data type option, add to criteria
if exist('states','var') ~= 1
   states = '';
elseif ~isempty(states) && ischar(states)
   states = splitstr(states,',');
end

all_states = '';
if ~isempty(states)
   for n = 1:length(states)
      val = deblank(states{n});
      if ~isempty(val) && ~strcmpi(val,'all')
         all_states = [all_states,'state_cd=',lower(val),'&'];
      end
   end
   criteria = [criteria,',state_cd'];
end

%check for data type option, add to criteria
if exist('datatypes','var') ~= 1
   datatypes = '';
elseif ~isempty(datatypes) && ischar(datatypes)
   datatypes = splitstr(datatypes,',');
end

site_types = '';
if ~isempty(datatypes)
   for n = 1:length(datatypes)
      val = deblank(datatypes{n});
      if ~isempty(val) && ~strcmpi(val,'all')
         site_types = [site_types,'data_type=',val,'&'];
      end
   end
   criteria = [criteria,',data_type'];
end

%check for bbox option
if exist('bbox','var') ~= 1
   bbox = [];
end

if length(bbox) == 4
   bbox_str = ['nw_longitude_va=',num2str(bbox(1)),'&', ...
      'nw_latitude_va=',num2str(bbox(2)),'&', ...
      'se_longitude_va=',num2str(bbox(3)),'&', ...
      'se_latitude_va=',num2str(bbox(4)),'&', ...
      'coordinate_format=decimal_degrees&'];
   criteria = [criteria,',lat_long_bounding_box'];
else
   bbox_str = '';
end

%validate url, supply default if omitted
if exist('url_base','var') ~= 1
   url_base = 'http://waterdata.usgs.gov/nwis/inventory';
elseif strcmp(url_base(end),'/')
   url_base = url_base(1:end-1);
end

%strip leading comma off criteria string
if ~isempty(criteria)
   criteria = criteria(2:end);
end

%validate output file name, supply default if omitted
if exist('fn','var') ~= 1
   fn = '';
end
%validate output file name, supply default if omitted
if exist('fn','var') ~= 1
   fn = '';
end
if isempty(fn)
   if ~isempty(datatypes)
      datatypes = datatypes(:)';
      types_list = char(concatcellcols(datatypes,'_'));
   else
      types_list = 'all-types';
   end
   if length(states) > 1
      state_list = char(concatcellcols(states(:)','_'));
   elseif ~isempty(states)
      state_list = char(states);
   else
      state_list = 'all';
   end
   fn = ['usgs_inventory_',state_list,'_',types_list,'_',datestr(now,29),'.xml'];
end

%validate output path, supply default if omitted
if exist('pn','var') ~= 1
   pn = '';
else
   pn = clean_path(pn);
end
if ~isdir(pn)
   pn = [gce_homepath,filesep,'search_webcache'];
   if ~isdir(pn)
      pn = pwd;
   end
end

%build USGS NWIS query url
url = [url_base,'?', ...
   all_states, ...
   site_types, ...
   bbox_str, ...
   'sort_key=site_no&', ...
   'group_key=NONE&', ...
   'format=sitefile_output&', ...
   'sitefile_output_format=xml&', ...
   'column_name=agency_cd&', ...
   'column_name=site_no&', ...
   'column_name=station_nm&', ...
   'column_name=site_tp_cd&', ...
   'column_name=lat_va&', ...
   'column_name=long_va&', ...
   'column_name=dec_lat_va&', ...
   'column_name=dec_long_va&', ...
   'column_name=coord_meth_cd&', ...
   'column_name=coord_acy_cd&', ...
   'column_name=coord_datum_cd&', ...
   'column_name=dec_coord_datum_cd&', ...
   'column_name=district_cd&', ...
   'column_name=state_cd&', ...
   'column_name=county_cd&', ...
   'column_name=country_cd&', ...
   'column_name=alt_va&', ...
   'column_name=alt_meth_cd&', ...
   'column_name=alt_acy_va&', ...
   'column_name=alt_datum_cd&', ...
   'column_name=huc_cd&', ...
   'column_name=data_types_cd&', ...
   'column_name=drain_area_va&', ...
   'column_name=contrib_drain_area_va&', ...
   'column_name=tz_cd&', ...
   'column_name=local_time_fg&', ...
   'column_name=project_no&', ...
   'column_name=rt_bol&', ...
   'list_of_search_criteria=',criteria];

if guimode == 1; ui_progressbar('update',1,'Retrieving station inventory from USGS'); drawnow; end

%execute query, saving results to file
[fn_xml,status] = urlwrite(url,[pn,filesep,fn]);

%generate status message
if ~isempty(fn_xml) && status == 1
   
   if guimode == 1; ui_progressbar('update',2,'Parsing inventory file'); drawnow; end
   
   %check first line of file to verify xml output
   fid = fopen(fn_xml,'r');
   ln = fgetl(fid);
   fclose(fid);
   
   if strncmpi(ln,'<?xml',5)
      
      %apply xsl transform to convert to tabular format
      [tmp,fn_base] = fileparts(fn_xml);
      fn_txt = xslt(fn_xml,'parse_usgs_stations.xsl',[pn,filesep,fn_base,'.txt']);
      
      %import transformed file to create GCE data set
      if guimode == 1; ui_progressbar('update',3,'Generating USGS station dataset'); drawnow; end
      s = imp_usgs_stations([fn_base,'.txt'],pn);
      
      msg = 'successfully retrieved xml report';
      
   else
      msg = 'non-xml data returned - check the output file for information';
   end
   
else
   msg = 'an error occurred retrieving the report';
end

if guimode ==1; ui_progressbar('close'); drawnow; end