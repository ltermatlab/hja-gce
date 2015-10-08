function [fqfn,msg] = get_file(url,fn,pn,username,password)
%Downloads a file from an HTTP, HTTPS, FTP or file system url and returns a fully qualified local filename 
%
%syntax: [fqfn,msg] = get_eml_file(url,fn,pn,username,password)
%
%input:
%   url = http, https, ftp or file system address of the file
%   fn = filename for the downloaded file
%   pn = pathname for downloading or copying the file (default = [gce_homepath,filesep,'search_webcache'])
%   username = username for HTTPS authentication (default = '')
%   password = password for HTTPS authentication (default = '')
%
%output:
%   fqfn = fully-qualified local filename
%   msg = text of any error message
%
%notes:
%   1) HTTPS downloads depend on access to cURL with SSL libraries in the system path
%
%
%(c)2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 28-Aug-2013


%init output
fqfn = '';
msg = '';

%check for nonempty string url
if nargin >= 2 && ischar(url) && ~isempty(url)
   
   %check for empty path
   if exist('pn','var') ~= 1 || isempty(pn)
      pn = [gce_homepath,filesep,'search_webcache'];
   end
   
   %validate path
   if ~isdir(pn)
      pn = pwd;  %default to working directory if path invalid
   end
   
   %check for empty username/password
   if exist('username','var') ~= 1
      username = '';
   end
   
   if exist('password','var') ~= 1
      password = '';
   end
   
   %init error flag and error object
   err = 0;
   errmsg = [];
   
   %download eml using appropriate method
   if strncmpi(url,'https',5)
      
      %generate curl command to evaluate
      if isempty(username)
         cmd = ['curl -s -X GET "',url,'" -o "',pn,filesep,fn,'"'];
         cmd_insecure = ['curl -k -s -X GET "',url,'" -o "',pn,filesep,fn,'"'];
      else
         cmd = ['curl -s -u ',username,':',password,' -X GET "',url,'" -o "',pn,filesep,fn,'"'];
         cmd_insecure = ['curl -k -s -u ',username,':',password,' -X GET "',url,'" -o "',pn,filesep,fn,'"'];
      end
      
      %run curl command, checking for system or cURL errors
      try
         [status,res] = system(cmd);
      catch errmsg
         err = 1;
      end
      if err == 1 || status > 0
         try
            %fall back to insecure SSL on certificate error
            [status,res] = system(cmd_insecure);
            if status > 0
               err = 1;
            end
         catch errmsg
            err = 1;
         end
      end
      
   elseif strncmpi(url,'http',4)
      
      %use urlwrite to evaluate HTTP URL and save results to a file
      try
         urlwrite(url,[pn,filesep,fn]);
      catch errmsg
         err = 1;
      end
      
   elseif strncmpi(url,'ftp',3)
      
      %use urlwrite to evaluate FTP URL and save results to a file
      try
         urlwrite(url,[pn,filesep,fn]);
      catch errmsg
         err = 1;
      end
      
   elseif exist(url,'file') == 2

      %try to copy file from local or UNC path to specified temp directory
      try        
         copyfile(url,[pn,filesep,fn]);
      catch errmsg
         err = 1;
      end
      
   else
      
      %unsupported option or invalid file path
      err = 1;
      
   end
   
   %check for errors
   if err == 0 && exist([pn,filesep,fn],'file') == 2
      
      fqfn = [pn,filesep,fn];
      
   else
      
      %display error message
      if isobject(errmsg)
         msg = errmsg.message;
         if size(msg,1) == 1
            msg = ['an error occurred retrieving the file: ',msg];
         else
            msg = char('an error occurred retrieving the file:',msg);
         end
      else
         msg = 'failed to retrieve the file from the specified url';
      end
      
   end
   
end