function [msg,info] = harvest_usgs_general_xml(info,pn_working,pn_data,nav_base,xsl_index,xsl_details,xsl_plots,url_base,clear_provisional,units)
%Harvests USGS gauging station data and generates standard data sets, plots and xml index pages for the web
%
%syntax: [msg,info] = harvest_usgs_general_xml(info,pn_working,pn_data,nav_base,xsl_index,xsl_details,xsl_plots,url_base,clear_provisional,units)
%
%input:
%  info = station information data set structure with attributes:
%     'StationID' = station id label
%     'StationName' = station name
%     'NWIS_ID' = USGS NWIS station id
%     'Template' = metadata template to use
%     'Date_Start' = earliest harvest date for station
%  pn_working = work path for raw data files
%  pn_data = base path for web data files
%  nav_base = base navigation text for breadcrumbs (2-column cell array or labels, urls)
%  xsl_index = url for index page XSL stylesheet (default = 'http://gce-lter.marsci.uga.edu/public/xsl/gce_portal.xsl')
%  xsl_details = url for dataset details page XSL stylesheet
%  xsl_plots = url for plots page XSL stylesheet
%  url_base = base URL to use for creating download file links (default = link to sendfile.asp application for GCE Data Portal)
%  clear_provisional = option to clear provisional ("P") flags after generating a single 'Provisional'
%     boolean column indicating the presence of provisional values in the record (specify 0 to retain
%     individual P value qualifiers)
%     0 = no
%     1 = yes/default
%  units = optional cell array of unit conversions to apply (i.e. nx2 cell array of strings,
%     with parameter names in column 1 and desired units in column 2)
%
%output:
%  msg = status message
%  info = updated station information structure with updated 'Date_Start'
%
%(c)2011 Wade Sheldon
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
%Georgia Coastal Ecosystems LTER Project
%Dept. of Marine Sciences
%University of Georgia
%Athens, GA 30602-3636
%email: sheldon@uga.edu
%
%last modified: 29-Apr-2011

msg = '';

if nargin >= 3

   %supply defaults for omitted parameters
   if exist('xsl_index','var') ~= 1
      xsl_index = 'http://gce-lter.marsci.uga.edu/public/xsl/gce_portal.xsl';
   end
   
   if exist('xsl_details','var') ~= 1
      xsl_details = 'http://gce-lter.marsci.uga.edu/public/xsl/gce_portal_details_new.xsl';
   end
   
   if exist('xsl_plots','var') ~= 1
      xsl_plots = 'http://gce-lter.marsci.uga.edu/public/xsl/gce_portal_plots.xsl';
   end
   
   if exist('url_base','var') ~= 1
      url_base = 'http://gce-lter.marsci.uga.edu/public/app/send_file.asp?accession=portal&filename=';
   end
   
   %set default provisional flag handling option if omitted
   if exist('clear_provisional','var') ~= 1
      clear_provisional = 1;
   elseif clear_provisional ~= 0
      clear_provisional = 1;
   end

   %validate units array
   if exist('units','var') ~= 1
      units = [];
   elseif ~iscell(units) || size(units,2) ~= 2
      units = [];
   end

   if exist('nav_base','var') ~= 1
      nav_base = '';
   end

   %validate required input fields
   if gce_valid(info,'data') && isdir(pn_working) && isdir(pn_data)

      %strip terminal file separators if present
      if strcmp(pn_working(end),filesep)
         pn_working = pn_working(1:end-1);
      end

      if strcmp(pn_data(end),filesep)
         pn_data = pn_data(1:end-1);
      end

      %extract columns from info structure
      stationids = extract(info,'StationID');
      stationname = extract(info,'StationName');
      nwis = extract(info,'NWIS_ID');
      template = extract(info,'Template');
      datestart = extract(info,'Date_Start');

      %validate info fields
      if ~isempty(stationids) && ~isempty(stationname) && ~isempty(nwis) && ~isempty(datestart)

         %init status arrays
         goodstations = [];
         badstations = [];

         %generate date string (yyyy-mm-dd) for end date of harvests
         dt_str = datestr(now,29);

         %loop through stations
         for n = 1:length(stationids)

            stationlabel = stationids{n};
            stationid = lower(stationlabel);

            %use default template if not specified
            if isempty(template{n})
               template{n} = 'USGS_Generic';
            end

            %use default start date if not specified
            if isempty(datestart{n})
               datestart{n} = '1890-01-01';
            end

            %generate base filename
            fn_base = ['usgs_',stationid,'_daily'];

            %fetch all daily data for station
            [s,msg] = fetch_usgs_dates(nwis{n},'daily',datestart{n},dt_str,template{n},pn_working,[fn_base,'_',dt_str,'.txt'], ...
               clear_provisional);

            %update cached min station date if not specified
            if ~isempty(s)

               %perform unit conversions if matching parameters found
               if ~isempty(units)
                  for cnt = 1:size(units,1)
                     Icol = name2col(s,units{cnt,1});
                     newunits = units{cnt,2};
                     if length(Icol) == 1 && ~isempty(newunits)
                        s_tmp = unit_convert(s,Icol,newunits);
                        if ~isempty(s_tmp)
                           s = s_tmp;
                        end
                     end
                  end
               end

               %fill gaps and remove dupes to create a monotonic time series
               s_tmp = fill_date_gaps(s,'Date',1,1);
               if ~isempty(s_tmp)
                  s = s_tmp;
               end

               %document anomalies
               s = add_anomalies(s,23,'-',1,listdatacols(s));

               goodstations = [goodstations ; stationids(n)];

               %generate current decade, current year strings for queries
               str_year = datestr(now,10);
               str_decade = [str_year(1:3),'0'];

               %look up date range for data set
               dt = get_studydates(s);
               dt = dt(~isnan(dt));
               datestart{n} = datestr(min(dt),29);  %update starting harvest data
               str_maxdate = datestr(max(dt),1);  %format max date string for all data sets

               %generate date range text
               str_daterange_all = [' for ',datestr(min(dt),1),' to ',str_maxdate];
               str_daterange_decade = [' for 01-Jan-',str_decade,' to ',str_maxdate];
               str_daterange_current = [' for 01-Jan-',str_year,' to ',str_maxdate];

               %generate dataset filenames
               fn_all = lower([fn_base,'_',datestr(min(dt),28),'-',datestr(max(dt),28)]);
               fn_decade = lower([fn_base,'_jan',str_decade,'-',datestr(max(dt),28)]);
               fn_year = lower([fn_base,'_jan',str_year,'-',datestr(max(dt),28)]);

               %generate current decade, current year data sets
               s_decade = querydata(s,['Year >= ',str_decade]);
               s_year = querydata(s,['Year = ',str_year]);

               %generate appropriate titles for data sets
               str_title = ['Daily hydrologic data from ',stationname{n},' (USGS ',nwis{n},')'];
               s = newtitle(s,[str_title,str_daterange_all]);
               s_decade = newtitle(s_decade,[str_title,str_daterange_decade]);
               s_year = newtitle(s_year,[str_title,str_daterange_current]);

               %define base pathnames for data, generating directory structure if necessary
               pn_base = [pn_data,filesep,stationid];
               if exist(pn_base,'dir') ~= 7
                  status = mkdir(pn_data,stationid);
                  if status == 1
                     status = mkdir([pn_data,filesep,stationid],'data');
                     status = mkdir([pn_data,filesep,stationid],'plots');
                  end
               else
                  status = 1;
               end

               %save data files, clearing prior data sets, plots
               if status == 1

                  pn_datafiles = [pn_data,filesep,stationid,filesep,'data'];
                  pn_plots = [pn_data,filesep,stationid,filesep,'plots'];

                  %delete prior files at destination
                  try
                     delete([pn_datafiles,filesep,'*.htm'])
                     delete([pn_datafiles,filesep,fn_base,'*.*'])
                     delete([pn_plots,filesep,'*.htm'])
                     delete([pn_plots,filesep,fn_base,'*.*'])
                  catch
                     msg = char(msg,'error deleting old files');
                  end

                  %save all years data set
                  data = s;
                  save([pn_datafiles,filesep,fn_all,'.mat'],'data')
                  
                  %generate plots
                  sub_plotdata(data,'year',fn_all,pn_plots,nav_base,stationlabel,xsl_plots,str_title);  %generate plots

                  %save decade data set
                  if ~isempty(s_decade)
                     data = s_decade;
                     save([pn_datafiles,filesep,fn_decade,'.mat'],'data')
                     sub_plotdata(data,'year',fn_decade,pn_plots,nav_base,stationlabel,xsl_plots,str_title);  %generate plots
                  end

                  %save current year data set
                  if ~isempty(s_year)
                     data = s_year;
                     save([pn_datafiles,filesep,fn_year,'.mat'],'data')
                     sub_plotdata(data,'month',fn_year,pn_plots,nav_base,stationlabel,xsl_plots,str_title);  %generate plots
                  end

                  %generate distribution files
                  gce_distribfiles(pn_datafiles,pn_datafiles,[fn_base,'*.mat'],'MD','E','alldata',1);  %generate distribution files

                  %generate index pages
                  msg0 = portal_datapages_xml(pn_data,stationlabel,nav_base,str_title,xsl_index,xsl_details,url_base,'','MD',0);
                  
                  if ~isempty(msg0)
                     msg = msg0;
                  end

               else
                  msg = ['an error occurred creating data subdirectories at ''',pn_datafiles,''''];
                  break
               end

            else
               badstations = [badstations , stationids(n)];
            end

         end

         %update start dates in info file
         info = update_data(info,'Date_Start',datestart);

         %generate output message
         if isempty(msg)
            if ~isempty(goodstations)
               str_good = cell2commas(goodstations,1);
            else
               str_good = 'no stations';
            end
            if ~isempty(badstations)
               str_bad = [', failed to harvest ',cell2commas(badstations,1)];
            else
               str_bad = '';
            end
            msg = ['successfully harvested data from ',str_good,str_bad,' at ',datestr(now)];
         end

      else
         msg = 'station information dataset is invalid';
      end

   else
      msg = 'invalid pathname(s)';
   end

else
   msg = 'insufficient arguments for function';
end


%subfunction for generating and indexing plots
function msg = sub_plotdata(data,interval,fn_base,pn_webplots,nav_base,stationid,xsl_plots,titlestr)

data = nullflags(data,'I');  %remove invalid flagged data
data = clearflags(data,'P');  %clear P flags if present for plotting

nav_plots = [nav_base,{stationid,'../data/index.xml'}];

%generate plot
if ~isempty(name2col(data,'Daily_Total_Precipitation'))
   plotlabel = 'Discharge and Precipitation';
   [msg,h] = plotdata(data,'Date',{'Daily_Max_Discharge','Daily_Mean_Discharge','Daily_Min_Discharge','Daily_Total_Precipitation'}, ...
      {'b','g','c','k'},{'^','o','v','^'},{':','-',':','-'},0,4,'auto');
else
   plotlabel = 'Discharge';
   [msg,h] = plotdata(data,'Date',{'Daily_Max_Discharge','Daily_Mean_Discharge','Daily_Min_Discharge'}, ...
      {'b','g','c'},{'^','o','v'},{':','-',':'},0,4,'auto');
end

if ~isempty(h)
   dateplot2xml(3,300,1,interval,fn_base,[fn_base,'.xml'],[fn_base,'.xml'],pn_webplots, ...
      titlestr,plotlabel,xsl_plots,nav_plots,'png',h);
   delete(h)
   drawnow
else
   msg = char(msg,['plot error: ',msg]);
end