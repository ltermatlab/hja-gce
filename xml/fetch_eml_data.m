function [s,msg] = fetch_eml_data(url,pn,xsl,cachedata,username,password,entities)
%Retrieves text data tables described in an EML metadata document and returns a structure containing parsed data
%for analysis in the MATLAB environment. This function downloads an EML document and applies an XSLT stylesheet
%('EMLdataset2mfile.xsl' or equivalent) to generate an m-file function that downloads the data table objects
%and imports the data arrays and key metadata content into MATLAB.
%
%syntax: [s,msg] = fetch_eml_data(url,pn,xsl,cachedata,username,password,entities)
%
%input:
%   url = http, https, ftp or file system address of the EML document
%   pn = pathname to use for downloading files (default = [toolbox]/search_webcache or pwd if not present)
%   xsl = filename or URL of the EML-to-mfile XSLT stylesheet to apply to generate an m-file function
%      from dataTable descriptions in an EML document (default = 'EMLdataset2mfile.xsl' or
%      'http://gce-lter.marsci.uga.edu/public/xsl/toolbox/EMLdataset2mfile.xsl' if not found)
%   cachedata = option to use local copies of data set entities if they exist in pn
%      0 = always download entity files (default)
%      1 = use cached files
%   username = username for HTTPS authentication (default = '')
%   password = password for HTTPS authentication (default = '')
%   entities = cell array of dataTable entities to load (default = [] for all)
%
%output:
%   s = 1xN structure containing metadata and data arrays for each downloadable data table, with fields:
%      project = name of the project responsible for the data set (string; repeated for each dimension of s)
%      packageid = data set packageID (string; repeated for each dimension of s)
%      title = data set title (string; repeated for each dimension of s)
%      abstract = data set abstract (string; repeated for each dimension of s)
%      keywords = data set keywords (string; repeated for each dimension of s)
%      creator = data set creator information (cell array; repeated for each dimension of s)
%      contact = data set contact information (cell array; repeated for each dimension of s)
%      rights = data set intellectual rights information (cell array; repeated for each dimension of s)
%      dates = data set temporal coverage (cell array; repeated for each dimension of s)
%      geography = data set geographic coverage (cell array; cell array of descriptions plus corresponding 
%         numeric arrays of longitude/latitude pairs for NW, NE, SE, SW corners; repeated for each dimension of s)
%      taxa = data set taxonomic coverage (cell array; species and common names only; repeated for each dimension of s)
%      methods = data set methods and instrumentation (cell array; repeated for each dimension of s)
%      sampling = data set sampling description (cell array; repeated for each dimension of s)
%      entity = data set table (entity) name (string) 
%      url = data table (entity) download URL (string)
%      filename = data set file (object) name (string)
%      description = data table (entity) description (string)
%      names = cell array of column names
%      units = cell array of column units
%      definitions = cell array of column definitions
%      datatypes = cell array of column data types
%      scales = cell array of column measurement scale types
%      codes = cell array of column codes and code definitions
%      bounds = cell array of column bounds (e.g. 'value &gt; 0; value &lt; 10')
%      data = cell array of column data arrays (i.e. typed numeric arrays and cell arrays of strings)
%   msg = text of any error message
%
%notes:
%   1. The HTTPS protocol uses cURL with SSL libraries (http://curl.haxx.se/), which must be accessible 
%      in the system path (e.g. in C:\Windows on a Windows system)
%   2. The XSLT stylesheet must generate a valid MATLAB m-file function that returns
%      data as the first output variable and a status message as the second output variable
%      (see 'EMLdataset2mfile.xsl' as an example)
%   3. EML-described storage types are mapped to string, double-precision floating point and integer
%      data types supported by MATLAB (if storageType elements are omitted, type is inferred from 
%      measurementScale elements, with 'ratio' and 'interval' mapped to float, and other types imported
%      as strings for manual conversion in MATLAB)
%
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
%last modified: 18-Jun-2013

%init output
s = [];

%check for required url argument
if nargin >= 1
   
   %validate usedcacheddata input
   if exist('cachedata','var') ~= 1 || isempty(cachedata)
      cachedata = 0;
   end
   
   %validate entities input
   if exist('entities','var') ~= 1
      entities = [];
   end
   
   %validate path
   if exist('pn','var') ~= 1
      pn = '';
   elseif ~isdir(pn)
      pn = '';      
   end
   
   %supply default path if omitted or invalid
   if isempty(pn)
      %check for GCE Data Toolbox homepath function and web cache directory
      if exist('gce_homepath','file') == 2 && isdir([gce_homepath,filesep,'search_webcache'])
         pn = [gce_homepath,filesep,'search_webcache'];
      else
         pn = pwd;  %use working directory as a last resort
      end
   end
   
   %supply default username if omitted
   if exist('username','var') ~= 1
      username = '';
   end
   
   %supply default password if omitted
   if exist('password','var') ~= 1
      password = '';
   end
   
   %use default stylesheet
   if exist('xsl','var') ~= 1
      xsl = '';
   end
   if isempty(xsl)
      %check for default xsl file
      if exist('EMLdataset2mfile.xsl','file') == 2
         xsl = which('EMLdataset2mfile.xsl');
      else
         %use latest version from GCE web site
         xsl = 'http://gce-lter.marsci.uga.edu/public/xsl/toolbox/EMLdataset2mfile.xsl';
      end
   end
   
   %check for non-empty xsl and url
   if ~isempty(url) && ~isempty(xsl)
      
      %call routine to retrieve eml
      if strncmpi('https://',url,8) && ~isempty(username)
         [fqfn,packageId,msg] = get_eml_file(url,pn,username,password);
      else  %skip username/pw for non-ssl         
         [fqfn,packageId,msg] = get_eml_file(url,pn);
      end
      
      %check for success
      if exist(fqfn,'file') == 2
         
         %replace unsupported characters in packageId with underscores to form mfile name
         fn_mfile = regexprep(packageId,'[^a-zA-Z0-9_]*','_');
         
         %apply stylesheet to generate data loading mfile
         xslt(fqfn,xsl,[pn,filesep,fn_mfile,'.m']);
         
         %run mfile
         if exist([pn,filesep,fn_mfile,'.m'],'file') == 2
            curpath = pwd;
            cd(pn)
            [s,msg] = feval(fn_mfile,pn,cachedata,username,password,entities);
            cd(curpath)
         else
            msg = 'failed to generate data loading m-file';
         end
         
      end
      
   else
      msg = 'url argument is empty or default xsl file was not found in the MATLAB path';
   end
   
else
   msg = 'url argument is required';
end
