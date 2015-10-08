function [s_sites,s_stations,s_variables,msg] = fetch_climdb_info(contributors,baseurl,pn)
%Retrieves updated status information on sites, stations and variables from the LTER ClimDB/HyroDB web site
%(requires networking and xml functions in MATLAB 6.5/R13 or higher)
%
%syntax: [s_sites,s_stations,s_variables,msg] = fetch_climdb_info(contributors,baseurl,pn)
%
%input:
%  contributors = data contributors ('All','LTER','USFS', or 'USGS')
%  baseurl = base url to use (default = 'http://climhy.lternet.edu/')
%  pn = pathname for temporary .xml files (default = 'search_webcache' toolbox directory)
%
%output:
%  s_sites = GCE Data Structure containing the ClimDB sites report
%  s_stations = GCE Data Structure containing the ClimDB stations report
%  s_variables = GCE Data Structure containing the ClimDB variables report
%  msg = text of any error message
%
%(c)2005-2012 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 07-Mar-2012

%init output
s_sites = [];
s_stations = [];
s_variables = [];
msg = '';

%check for required support files
if exist('urlwrite','file') == 2 && exist('xslt','file') == 2

   %check for required xsl files
   if exist('parse_climdb_sites.xsl','file') == 2 && ...
         exist('parse_climdb_stations.xsl','file') == 2 && ...
         exist('parse_climdb_variables.xsl','file') == 2

      %init module lookup list
      ar_contribs = {'all','0'; ...
            'lter','1'; ...
            'usfs','2'; ...
            'usgs','3'};

      %validate contributors argument, supply default if omitted
      if exist('contributors','var') ~= 1
         contributors = '';
      end
      if isempty(contributors)
         contributors = 'all';
      else
         contributors = lower(contributors);
      end

      %validate baseurl argument, supply default if omitted
      if exist('baseurl','var') ~= 1
         baseurl = '';
      end
      if isempty(baseurl)
         baseurl = 'http://climhy.lternet.edu/';
      elseif strcmp(baseurl(end),'/') ~= 1
         baseurl = [baseurl,'/'];
      end
      url = [baseurl,'products.pl'];
      
      %validate temp path, defaulting to search_webcache if omitted or invalid
      if exist('pn','var') ~= 1
         pn = '';
      else
         pn = clean_path(pn);
      end
      if ~isdir(pn)
         pn = [gce_homepath,filesep,'search_webcache'];
         if ~isdir(pn)
            %fall back to working directory if default cache directory not present
            pn = fileparts(which('fetch_climdb_info')); 
         end
      end
      
      %look up module
      Icontribs = find(strcmp(ar_contribs(:,1),contributors));
      if length(Icontribs) == 1
         module = ar_contribs{Icontribs,2};
      else
         module = '0';
      end

      %generate parameter name/value pair arrays for http posts
      parms_site = {'submit','Sites', ...
            'module',module, ...
            'use','sites', ...
            'sort','code'};

      parms_stat = {'submit','Stations', ...
            'module',module, ...
            'use','stations', ...
            'sort','code'};

      parms_var = {'submit','Variables', ...
            'module',module, ...
            'use','variables', ...
            'sort','code'};

      %request report - save as file
      [fn_site,status_site] = urlwrite(url,[pn,filesep,'climdb_sites.xml'],'get',parms_site);
      if status_site == 1
         [fn_stat,status_stat] = urlwrite(url,[pn,filesep,'climdb_stations.xml'],'get',parms_stat);
         [fn_var,status_var] = urlwrite(url,[pn,filesep,'climdb_variables.xml'],'get',parms_var);
      else
         status_stat = 0;
         status_var = 0;
      end

      %check for return data
      if status_site == 1 && status_stat == 1 && status_var == 1

         %generate temp file names by parsing fully-qualified filenames for reports
         [pn,fn_base_site] = fileparts(fn_site);
         fn_site2 = [pn,filesep,fn_base_site,'.txt'];

         [pn,fn_base_stat] = fileparts(fn_stat);
         fn_stat2 = [pn,filesep,fn_base_stat,'.txt'];

         [pn,fn_base_var] = fileparts(fn_var);
         fn_var2 = [pn,filesep,fn_base_var,'.txt'];

         %use xlst to convert xml to delimited ascii for importing
         try
            url_site = xslt(fn_site,which('parse_climdb_sites.xsl'),fn_site2);
            url_stat = xslt(fn_stat,which('parse_climdb_stations.xsl'),fn_stat2);
            url_var = xslt(fn_var,which('parse_climdb_variables.xsl'),fn_var2);
         catch
            url_site = '';
            url_stat = '';
            url_var = '';
         end

         %check for xslt output
         if ~isempty(url_site) && ~isempty(url_stat) && ~isempty(url_var)

            %load parsed report files
            s_sites = imp_ascii([fn_base_site,'.txt'],pn);
            s_stations = imp_ascii([fn_base_stat,'.txt'],pn);
            s_variables = imp_ascii([fn_base_var,'.txt'],pn);

            %check for valid return data
            if ~isempty(s_sites) && ~isempty(s_stations) && ~isempty(s_variables)

               %init array of date/time fields in stations, variables reports
               dcollist = {'Date_Start','Date_End','Date_Latest'};

               %post-process stations report
               cols = [];
               str_hist = s_stations.history;  %buffer processing history
               for n = 1:length(dcollist)
                  col = name2col(s_stations,dcollist{n},0,'s','datetime');
                  if length(col) == 1
                     d_climdb = extract(s_stations,col);
                     ar = splitstr(d_climdb,'-');
                     numrows = length(ar);
                     d_ml = datenum(str2num(char(ar(1:3:numrows-2))), ...
                        str2num(char(ar(2:3:numrows-1))), ...
                        str2num(char(ar(3:3:numrows))));
                     colname = s_stations.name{col};  %buffer column name
                     desc = s_stations.description{col};  %buffer column description
                     s_stations = deletecols(s_stations,col);  %delete string date column
                     s_stations = addcol(s_stations,d_ml,colname,'Serial date (1 = 1/1/0000)',desc, ...
                        'f','datetime','continuous',8,'',col);  %add corresponding serial date column
                  end
               end

               if ~isempty(cols)
                  s_stations.history = [str_hist ; {datestr(now), ...
                           ['parsed fields from file ''climdb_variables.xml'' and converted dates in columns ',cell2commas(s_variables.name(cols),1), ...
                              ' from YYYY-MM-DD to MATLAB serial date format (''fetch_climdb_info'')']}];
               end

               if gce_valid(s_stations,'data')
                  s_stations = sortdata(s_stations,{'Site','Station'});  %sort by site, station
               else
                  s_stations = [];
               end

               %post-process variables report
               cols = [];
               str_hist = s_variables.history;  %buffer processing history
               for n = 1:length(dcollist)
                  col = name2col(s_variables,dcollist{n},0,'s','datetime');
                  if length(col) == 1
                     d_climdb = extract(s_variables,col);
                     ar = splitstr(d_climdb,'-');
                     numrows = length(ar);
                     d_ml = datenum(str2num(char(ar(1:3:numrows-2))), ...
                        str2num(char(ar(2:3:numrows-1))), ...
                        str2num(char(ar(3:3:numrows))));
                     colname = s_variables.name{col};  %buffer column name
                     desc = s_variables.description{col};  %buffer column description
                     s_variables = deletecols(s_variables,col);  %delete string date column
                     s_variables = addcol(s_variables,d_ml,colname,'Serial date (1 = 1/1/0000)',desc, ...
                        'f','datetime','continuous',8,'',col);  %add corresponding serial date column
                  end
               end

               if ~isempty(cols)
                  s_variables.history = [str_hist ; {datestr(now), ...
                           ['parsed fields from file ''climdb_variables.xml'' and converted dates in columns ',cell2commas(s_variables.name(cols),1), ...
                              ' from YYYY-MM-DD to MATLAB serial date format (''fetch_climdb_info'')']}];
               end

               if gce_valid(s_variables,'data')
                  s_variables = sortdata(s_variables,{'Site','Station','Variable'});  %sort by site, station, variable
               else
                  s_variables = [];
               end

            end

         else
            msg = 'errors occurred parsing the ClimDB report files';
         end

      else
         msg = 'failed to retrieve report files from ClimDB';
      end

   else
      msg = 'required xslt files are not present';
   end

else
   msg = 'this function requires networking and xml features in MATLAB 6.5/R13 or higher';
end