function [fqfn,packageId,msg] = get_eml_file(url,pn,username,password)
%Fetches an EML document from an HTTP, HTTPS, FTP or file system url and returns a fully qualified local filename 
%for loading or transformation
%
%syntax: [fqfn,packageId,msg] = get_eml_file(url,pn,username,password)
%
%input:
%   url = http, https, ftp or file system address of the EML document
%   pn = pathname for downloading or copying EML document
%   username = username for HTTPS authentication (default = '')
%   password = password for HTTPS authentication (default = '')
%
%output:
%   fn = fully-qualified local filename
%   packageId = packageId of the EML document
%   msg = text of any error message
%
%notes:
%   1) HTTPS downloads depend on access to cURL with SSL libraries in the system path
%
%contact:
%  Wade Sheldon
%  GCE-LTER Project
%  Department of Marine Sciences
%  University of Georgia
%  Athens, GA 30602-3636
%  sheldon@uga.edu
%
%last modified: 09-Sep-2012


%init output
fqfn = '';
msg = '';
packageId = '';

%check for nonempty string url
if nargin >= 2 && ischar(url) && ~isempty(url)
   
   %check for empty username/password
   if exist('username','var') ~= 1
      username = '';
   end
   
   if exist('password','var') ~= 1
      password = '';
   end
   
   %set temporary filename and path for file
   fn = ['eml_',datestr(now,30),'.xml'];
   if exist('pn','var') ~= 1;
      pn = pwd;  %default to working directory if path omitted
   elseif ~isdir(pn)
      pn = pwd;  %default to working directory if path invalid
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
     
      %validate eml file
      try
         
         valid = 0;
         
         %get packageId from preamble
         packageId = '';
         fid = fopen([pn,filesep,fn],'r');
         ln = fgetl(fid);
         if strfind(ln,'<?xml')
            for n = 1:15
               [Istart,Iend] = regexp(ln,'packageId=\S*');
               if ~isempty(Istart)
                  packageId = ln(Istart+11:Iend-1);
                  valid = 1;
                  break
               else
                  ln = fgetl(fid);
               end
            end
         end
         fclose(fid);
         
         %rename file to [packageId].xml if necessary
         if valid == 1
            if ~strcmpi([pn,filesep,fn],[pn,filesep,packageId,'.xml'])
               try
                  copyfile([pn,filesep,fn],[pn,filesep,packageId,'.xml'])
                  delete([pn,filesep,fn])
                  fqfn = [pn,filesep,packageId,'.xml'];
               catch e
                  fqfn = '';
                  msg = ['a file system error occurred saving the EML file ',e.message];
               end
            end
         else
            fqfn = '';
         end
         
      catch
         msg = 'the url did not return a valid EML file';
      end
      
   else
      
      %display error message
      if isobject(errmsg)
         msg = errmsg.message;
         if size(msg,1) == 1
            msg = ['an error occurred retrieving the xml file: ',msg];
         else
            msg = char('an error occurred retrieving the xml file:',msg);
         end
      else
         msg = 'failed to retrieve xml file from the specified url';
      end
      
   end
   
end