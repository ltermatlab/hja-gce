function [s,msg] = fetch_noaa_hads(nesdis,days,template,deletetemp,trim_partial,max_trim,pn_temp,fn_temp,baseurl)
%Retrieves data arrays from the NOAA HADS NESDIS data server and returns a GCE data structure
%(requires 'parse_noaa_hads' and 'urlwrite' in MATLAB R13 and higher for HTTP data access)
%
%syntax: [s,msg] = fetch_noaa_hads(nesdis,days,template,deletetemp,trim_partial,max_trim,pn_temp,fn_temp,baseurl)
%
%input:
%  nesdis = NOAA NESDIS ID (e.g. '3B036592' for Marsh Landing) - required
%  days = number of days of data to request (0-7, with 0 = data for current day) - required
%  template = metadata template to apply (default = '' for none)
%  deletetemp = option to delete raw data file after successful retrieval and parsing
%     0 = no
%     1 = yes (default)
%  trim_partial = option to trim incomplete beginning and ending records to prevent data merge issues
%     0 = no
%     1 = yes (default)
%  max_trim = maximum number of leading and trailing partial records to trim (default = [] for number of data
%     and calculation columns - 1; ignored if trim_partial = 0)
%  pn_temp = path for temporary download file (default = 'search_webcache' toolbox subdirectory)
%  fn_temp = name for temporary download file (default = 'nesdis_[nesdis]_YYYYMMDDThhmmss.txt')
%  baseurl = base url for the NOAA web application
%    (default = 'http://amazon.nws.noaa.gov/nexhads2/servlet/DecodedData')
%
%output:
%  s = data structure
%  msg = text of any error message
%
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
%last modified: 17-Jan-2013

s = [];
msg = '';

if nargin >= 2

   if exist('urlwrite','file') == 2

      %set default template if omitted
      if exist('template','var') ~= 1
         template = '';
      end

      %set default delete option if omitted, invalid
      if exist('deletetemp','var') ~= 1
         deletetemp = 1;
      elseif deletetemp ~= 0
         deletetemp = 1;
      end

      %set default trim_partial option if omitted
      if exist('trim_partial','var') ~= 1
         trim_partial = 1;
      elseif trim_partial ~= 0
         trim_partial = 1;
      end

      %set default max_trim option if omitted
      if exist('max_trim','var') ~= 1
         max_trim = [];
      end

      %set default path if omitted or invalid
      if exist('pn_temp','var') ~= 1
         pn_temp = '';
      elseif ~isdir(pn_temp)
         pn_temp = '';
      else  %strip terminal file separator
         if strcmp(pn_temp(end),filesep)
            pn_temp = pn_temp(1:end-1);
         end
      end

      %set or create default temp directory if necessary
      if isempty(pn_temp)
         pn_temp = gce_homepath;  %get toolbox directory
         pn_test = [pn_temp,filesep,'search_webcache'];
         if ~isdir(pn_test)
            status = mkdir(pn_temp,'search_webcache');  %try to create web cache directory
            if status == 1
               pn_temp = pn_test;
            end
         else
            pn_temp = pn_test;
         end
      end

      %set default filename if omitted
      if exist('fn_temp','var') ~= 1
         fn_temp = '';
      end
      if isempty(fn_temp)
         %generate temp file name
         dt = now;
         fn_temp = ['nesdis_',nesdis,'_',datestr(dt,10),datestr(dt,5),datestr(dt,7), ...
               'T',strrep(datestr(dt,13),':',''),'.txt'];
      end

      %set default base url if omitted
      if exist('baseurl','var') ~= 1
         baseurl = '';
      end
      if isempty(baseurl)
         baseurl = 'http://amazon.nws.noaa.gov/nexhads2/servlet/DecodedData';
      end

      %validate days option, proceed
      if isnumeric(days)

         if days > 0
            days = ceil(days);  %round up partial day requests
         end

         %generate http post data array for NOAA web app
         parms = {'sinceday',int2str(days), ...
               'of','1', ...
               'extraids',nesdis, ...
               'hsa','nil', ...
               'state','nil', ...
               'data','Decoded Data'};

         %request data from NOAA
         [fn2,status] = urlwrite(baseurl,[pn_temp,filesep,fn_temp],'POST',parms);

         %check status of download, parse file
         if status == 1 && ~isempty(fn2)
            [s,msg] = parse_noaa_hads(fn_temp,pn_temp,template,trim_partial,max_trim);  %call external parsing function
            if ~isempty(s) && deletetemp == 1   %delete temp file if successful and specified
               try
                  delete([pn_temp,filesep,fn_temp]);  %delete temp file if parsing successful
               end
            end
         else
            msg = 'no data was retrieved from NOAA';
         end

      else
         msg = 'invalid number of days';
      end

   else
      msg = 'this function requires ''urlwrite'' for HTTP data access (MATLAB R13 or higher)';
   end

else
   msg = 'insufficient arguments for function';
end