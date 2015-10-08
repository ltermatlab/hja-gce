function [entities,entitydesc] = fetch_eml_entities(url,pn,xsl,username,password)
%Retrieves a list of dataTable entities described in an EML metadata document as a cell array
%This function downloads an EML document and applies an XSLT stylesheet ('EMLdatasetEntities.xsl' 
%or equivalent) to generate an m-file to return the entiy list as a MATLAB cell array of strings
%
%syntax: [entities,entitydesc] = fetch_eml_entities(url,pn,xsl,username,password)
%
%input:
%   url = http, https, ftp or file system address of the EML document
%   pn = pathname to use for downloading files (default = [toolbox]/search_webcache or pwd if not present)
%   xsl = filename or URL of the EML-to-mfile XSLT stylesheet to apply to generate an m-file function
%      from dataTable descriptions in an EML document (default = 'EMLdataset2mfile.xsl' or
%      'http://gce-lter.marsci.uga.edu/public/xsl/toolbox/EMLdataset2mfile.xsl' if not found)
%   username = username for HTTPS authentication (default = '')
%   password = password for HTTPS authentication (default = '')
%
%output:
%   entities = cell array of entity names for compatible data tables ([] if none are identified)
%   entitydesc = cell array of entiy descriptions for compatible data tables ([] if none are identified)
%
%notes:
%   1. The HTTPS protocol uses cURL with SSL libraries (http://curl.haxx.se/), which must be accessible 
%      in the system path (e.g. in C:\Windows on a Windows system)
%   2. The XSLT stylesheet must generate a valid MATLAB m-file function that returns
%      data as the first output variable and a status message as the second output variable
%      (see 'EMLdatasetEntities.xsl' as an example)
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
entities = [];
entitydesc = [];

%check for required url argument
if nargin >= 1
   
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
      if exist('EMLdatasetEntities.xsl','file') == 2
         xsl = which('EMLdatasetEntities.xsl');
      else
         %use latest version from GCE web site
         xsl = 'http://gce-lter.marsci.uga.edu/public/xsl/toolbox/EMLdatasetEntities.xsl';
      end
   end
   
   %check for non-empty xsl and url
   if ~isempty(url) && ~isempty(xsl)
      
      %call routine to retrieve eml
      if strncmpi('https://',url,8) && ~isempty(username)
         [fqfn,packageId] = get_eml_file(url,pn,username,password);
      else  %skip username/pw for non-ssl         
         [fqfn,packageId] = get_eml_file(url,pn);
      end
      
      %check for success
      if exist(fqfn,'file') == 2
         
         %replace unsupported characters in packageId with underscores to form mfile name
         fn_mfile = [regexprep(packageId,'[^a-zA-Z0-9_]*','_'),'_entities'];
         
         %apply stylesheet to generate data loading mfile
         xslt(fqfn,xsl,[pn,filesep,fn_mfile,'.m']);
         
         %run mfile
         if exist([pn,filesep,fn_mfile,'.m'],'file') == 2
            curpath = pwd;
            cd(pn)
            [entities,entitydesc] = feval(fn_mfile);
            cd(curpath)
         end
         
      end
      
   end
   
end
