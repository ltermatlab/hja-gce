function [s,msg,s_raw] = fetch_ncdc_ghcnd(stationid,template,datestart,dateend,silent,fn_temp,pn_temp,deleteopt,baseurl)
%Retrieves historic climate data from the NOAA NCDC GHCN FTP site for a specified station
%and returns a GCE Data Structure parsed using 'imp_ncdc_ghcnd.m'
%
%syntax: [s,msg,s_raw] = fetch_ncdc_ghcnd(station,tempplate,datestart,dateend,silent,deleteopt,baseurl)
%
%input:
%  stationid = station ID to request (string)
%     (note: for NWS COOP stations pre-pend 'USC00' to the station ID, e.g. 'USC00097808')
%  template = metadata template to use (default = 'NCDC_GHCND')
%  datestart = beginning year and month to return (YYYYMM, default = [] for earliest available)
%  dateend = ending year and month to return (YYYYMM, default = [] for latest available)
%  silent = option to suppress progress bar status updates if GUI mode (0 = no/default, 1 = yes)
%  fn_temp = temporary download filename (default = [station,'_[YYYYMMDD].txt']
%  pn_temp = temporary download path (default = 'Search_Webcache' toolbox subdirectory)
%  deleteopt = option to delete the temporary tabular file if import successful (0 = no, 1 = yes/default)
%  baseurl = base URL for the NCDC FTP server (default = 'ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/daily/')
%
%output:
%  s = GCE data structure
%  msg = text of any error messages
%  s_raw = initial GCE data structure prior to denormalization and application of attribute metadata
%
%notes:
%  1) Parameter definitions in 'ncdc_ghcnd_parameters.mat' are used to translate integers
%     into standard numeric fields and to apply parameter-specific metadata to attributes
%  2) A monotonic time series data set will be generated for the full period of record
%  3) Only quality control information in the QFlags columns will be preserved as QA/QC flags
%  4) The normalized raw table (s_raw) only contains records for non-null (non-NaN) observations
%
%
%(c)2011-2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 29-Oct-2013

%initialize output
s = [];
s_raw = [];

if nargin >= 1
   
   %supply default template if omitted
   if exist('template','var') ~= 1
      template = 'NCDC_GHCND';
   end
   
   %supply default silent option if omitted
   if exist('silent','var') ~= 1 || isempty(silent)
      silent = 0;
   end
   
   %supply default start date or validate
   if exist('datestart','var') ~= 1
      datestart = [];
   end
   if ischar(datestart) && length(datestart) == 6
      datestart = str2double(datestart);  %convert string to integer value
   elseif isempty(datestart)
      datestart = 0;  %set 0 to include all dates
   end
   
   %supply default end date or validate
   if exist('dateend','var') ~= 1
      dateend = [];
   end
   if ischar(dateend) && length(dateend) == 6
      dateend = str2double(dateend);  %convert string to integer value
   elseif isempty(dateend)
      dvec = datevec(now);
      dateend = dvec(1).*100 + dvec(2);  %convert current date to yyyymm integer
   end
   
   %supply default filename if omitted
   if exist('fn_temp','var') ~= 1 || isempty(fn_temp)
      dt = now;
      fn_temp = [stationid,'_',datestr(dt,10),datestr(dt,5),datestr(dt,7),'.txt'];
   end
   
   %generate download path and filename
   if exist('pn_temp','var') ~= 1 || isempty(pn_temp)
      pn_temp = [gce_homepath,filesep,'search_webcache'];
   end      
   if ~isdir(pn_temp)
      %default to current directory if specified directory or standard cache path not present
      pn_temp = pwd;
   end
   
   %supply default delete option if omitted
   if exist('deleteopt','var') ~= 1 || isempty(deleteopt)
      deleteopt = 1;
   end
   
   %supply default baseurl if omitted
   if exist('baseurl','var') ~= 1
      baseurl = 'ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/daily/';
   elseif strcmp(baseurl(end),'/') ~= 1
      baseurl = [baseurl,'/'];  %add terminal slash
   end
      
   %check for existing file downloaded today, otherwise download new file
   if exist([pn_temp,filesep,fn_temp],'file') ~= 2
      [fqfn,status] = urlwrite([baseurl,'all/',stationid,'.dly'],[pn_temp,filesep,fn_temp]);
      if status == 0
         %try pre-pending 'USC00' for NWS COOP stations
         [fqfn,status] = urlwrite([baseurl,'all/USCOO',stationid,'.dly'],[pn_temp,filesep,fn_temp]);
      end
      if status == 1
         %update path for final saved file
         pn_temp = fileparts(fqfn);
      end
   else
      status = 1;
   end
   
   %check for successful download
   if status == 1
           
      %parse the file and return the finalized and raw data structure
      [s,msg,s_raw] = imp_ncdc_ghcnd(fn_temp,pn_temp,template,datestart,dateend,silent,deleteopt);
      
   else
      msg = 'an error occurred downloading the file, or no file was available for the specified station';
   end
   
else
   msg = 'station ID is required';
end