function [s,msg] = fetch_usgs(stationid,datatype,days,template,pn,fn,clear_provisional,deleteopt,baseurl,baseurl2)
%Fetches data from the USGS NWIS web site for the specified station and time period
%
%syntax: [s,msg] = fetch_usgs(stationid,datatype,days,template,pn,fn,clear_provisional,deleteopt,baseurl,baseurl2)
%
%inputs:
%  stationid = string listing the USGS station id for the request (e.g. '022035975')
%  datatype = type of data to request
%     'daily' = daily data (provisional and accepted) - default
%     'realtime' = provisional real-time data
%  days = number of days of data to request (default = 720 for 'daily', 31 for 'realtime', 3650 for 'archive')
%  template = metadata template to use (default = 'USGS_Generic')
%  pn = path to use for raw data tile (default = [toolbox path]/search_webcache subdirectory)
%  fn = filename to use for raw data (tab-delimited text; default ='usgs_[stationid]_[datatype]_yyyymmdd_hhmm.txt')
%  clear_provisional = option to clear provisional ("P") flags after generating a single 'Provisional'
%     boolean column indicating the presence of provisional values in the record (specify 0 to retain
%     individual P value qualifiers)
%     0 = no
%     1 = yes/default
%  deleteopt = option to delete the USGS RDB file upon successful parsing of the data
%     0 = no/default
%     1 = yes
%  baseurl = base URL for the USGS water data web site (default = 'http://waterdata.usgs.gov/nwis/')
%  baseurl2 = fall-back base URL (default = 'http://waterdata.usgs.gov/usa/nwis/')
%
%outputs:
%  s = GCE Data Structure containing the output
%  msg = text of any error messages
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
%last modified: 11-Jun-2013

s = [];
msg = '';

if nargin >= 2

   %check for MATLAB http functions
   if exist('urlwrite','file') == 2

      if exist('stationid','var') == 1

         %set default urls if omitted
         if exist('baseurl','var') ~= 1
            baseurl = 'http://waterdata.usgs.gov/nwis/';
         elseif ~strcmp(baseurl(end),'/')
            baseurl = [baseurl,'/'];
         end
         if exist('baseurl2','var') ~= 1
            baseurl2 = 'http://waterdata.usgs.gov/usa/nwis/';
         elseif ~strcmp(baseurl(end),'/')
            baseurl2 = [baseurl2,'/'];
         end

         %set default USGS RDB file delete option if omitted
         if exist('deleteopt','var') ~= 1
            deleteopt = 0;
         elseif deleteopt ~= 1
            deleteopt = 0;
         end

         %set default provisional flag handling option if omitted
         if exist('clear_provisional','var') ~= 1
            clear_provisional = 1;
         elseif clear_provisional ~= 0
            clear_provisional = 1;
         end

         %convert numeric station ID to string
         if isnumeric(stationid)
            stationid = num2str(stationid);
         end

         %set default metadata template if omitted
         if exist('template','var') ~= 1
            template = '';
         end
         if isempty(template)
            template = 'USGS_Generic';
         end

         %set default datatype if omitted
         if exist('datatype','var') ~= 1
            datatype = 'daily';
         elseif ~strcmp(datatype,'realtime')
            datatype = 'daily';
         end

         %set flag provisional option for realtime provisional data, otherwise determine provisional based on USGS flags
         if strcmp(datatype,'realtime')
            flag_provisional = 1;
         else
            flag_provisional = 0;
         end

         %set default days to retrieve if omitted
         if exist('days','var') ~= 1
            days = [];
         end
         if isempty(days)
            if strcmp(datatype,'daily')
               days = 720;
            else  %real-time
               days = 31;
            end
         end
         if days < 1
            days = 1;
         end

         if exist('fn','var') ~= 1
            fn = '';
         end

         %validate temp directory, set to blank for default if missing, invalid
         if exist('pn','var') ~= 1 
            pn = '';
         elseif ~isdir(pn)
            pn = '';
         else
            pn = clean_path(pn);  %strip terminal file separator from path
         end

         %check for filename, use timestamp for temp filename if omitted
         if isempty(fn)
            d = now;
            fn = ['usgs_',stationid,'_',datatype,'_',datestr(d,10),datestr(d,5),datestr(d,7),'_',strrep(datestr(d,15),':',''),'.txt'];
         end

         %set or create default temp directory if necessary
         if isempty(pn)
            pn = gce_homepath;  %get toolbox directory
            pn_test = [pn,filesep,'search_webcache'];
            if ~isdir(pn_test)
               status = mkdir(pn,'search_webcache');  %try to create web cache directory
               if status == 1
                  pn = pn_test;
               end
            else
               pn = pn_test;
            end
         end
         
         try

            status = 0;
            while status == 0

               if strcmp(datatype,'daily')
                  url = [baseurl,'dv?format=rdb&period=',int2str(days),'&site_no=',stationid];
               else  %real-time
                  url = [baseurl,'uv?format=rdb&period=',int2str(days),'&site_no=',stationid];
               end

               %execute url, save response as file
               [fname,status] = urlwrite(url,[pn,filesep,fn]);

               if status == 1

                  %parse data
                  [s,msg] = parse_usgs(fn,pn,'',template,'',flag_provisional,clear_provisional);

                  if isempty(s)
                     status = 0;  %try alternate url if possible
                  end

               end

               if status == 0 && strcmp(baseurl,baseurl2) ~= 1
                  baseurl = baseurl2;  %use fall-back url, try again
               else
                  break  %no more urls to try
               end

            end

            if status == 0
               if isempty(strfind(msg,'HTML found'))
                  msg = ['No valid data were retrieved -- examine the temporary file ''',fn,''' for information'];
               else
                  msg = 'No valid data were retrieved';
               end
            elseif deleteopt == 1 && exist([pn,filesep,fn],'file') == 2
               try
                  delete([pn,filesep,fn]);
               catch e
                  msg = ['an error occurred deleting the USGS download file after import (',e.message,')'];
               end
            end

         catch e
            msg = ['unhandled runtime error occurred - please contact the author (',e.message,')'];
         end

      else
         msg = 'invalid USGS station ID';
      end

   else
      msg = 'this operation requires the ''urlwrite'' function available in MATLAB R13/6.5 or higher';
   end

else
   msg = 'insufficient arguments for function';
end