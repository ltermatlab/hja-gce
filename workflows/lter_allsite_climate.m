function [msg,log,s_monthly,s_daily] = lter_allsite_climate(fn_harvestlist,interp_daily,min_year,max_year,fn_daily,fn_monthly,missingchar)
%Workflow that generates integrated daily and monthly climate description datasets for a list of LTER stations
%using the GCE Data Toolbox for MATLAB (https://gce-svn.marsci.uga.edu/trac/GCE_Toolbox)
%
%syntax: [msg,log,s_monthly,s_daily] = lter_allsite_climate(fn_harvestlist,interp_daily,min_year,max_year,fn_daily,fn_monthly,missingchar)
%
%input:
%   fn_harvestlist = fully-qualified filename for a GCE Data Structure file containing
%      a list of stations to harvest (string; optional; default = 'met_station_list.mat') 
%   interp_daily = maximum number of missing values to interpolate for temperature columns in daily data
%      (integer; optional; default = 3)
%   min_year = minimum year to include for monthly summary data sets (default = [] for earliest)
%   max_year = maximum year to include for monthly summary data sets (default = [] for latest)
%   fn_daily = fully-qualified filename for exporting daily data in CSV text format
%      (string; optional; default = '' for none)
%   fn_monthly = fully-qualified filename for exporting monthly data in CSV text format
%      (string; optional; default = '' for none)
%   missingchar = missing value character for text file output (string; optional; default = '')
%
%output:
%   msg = text of any error message
%   log = structure containing a log of harvested station data with fields:
%      'System' = data system ('ClimDB' or 'GHCND')
%      'Site' = LTER site
%      'Station' = Station code
%      'Records' = data records retrieved
%      'DateStart' = starting date of observations
%      'DateEnd' = ending date of observations
%      'Variables' = comma-delimited list of variables retrieved
%   s_monthly = GCE Data Structure containing monthly-aggregated data from all stations
%   s_daily = GCE Data Structure containing integrated daily data from all stations
%
%notes:
%   1) the data structure in fn_harvestlist must contain columns System, Site and Station, where:
%      System = text column containing 'ClimDB' or 'GHCND'
%      Site = text column containing 3-letter LTER site acronyms
%      Station = text column containing station identifiers for the corresponding System 
%        (single string, or comma-delmited list of stations to join on date/time columns)
%
%by Wade Sheldon
%Georgia Coastal Ecosystems LTER
%University of Georgia
%Athens, GA 30602
%email: sheldon@uga.edu
%
%last updated: 27-Jun-2013

%init output
s_monthly = [];
s_daily = [];
msg = [];
log = [];

%validate fn_harvestlist
if exist('fn_harvestlist','var') ~= 1 || isempty(fn_harvestlist)
   fn_harvestlist = 'met_station_list.mat';
end

%validate max_interp
if exist('max_interp','var') ~= 1 || ~isnumeric(interp_daily)
   interp_daily = 3;
elseif isempty(interp_daily)
   interp_daily = 0;
end

%set default years if omitted
if exist('min_year','var') ~= 1
   min_year = [];
end
if exist('max_year','var') ~= 1
   max_year = [];
end

%validate fn_csv_monthly
if exist('fn_monthly','var') ~= 1
   fn_monthly = '';
end

%validate fn_csv_daily
if exist('fn_daily','var') ~= 1
   fn_daily = '';
end

%validate missingchar
if exist('missingchar','var') ~= 1
   missingchar = '';
end

%check for valid harvest list
if isstruct(fn_harvestlist) || exist(fn_harvestlist,'file') == 2
   
   %init harvestlist
   harvestlist = [];
   
   %check for filename and load
   if ischar(fn_harvestlist)
      try
         v = load(fn_harvestlist,'-mat');
      catch e
         v = struct('null','');
         msg = ['an error occurred loading the harvest list (',e.message,')'];
      end
      if isfield(v,'data')
         harvestlist = v.data;
      end
   end
   
   %validate harvest list
   if gce_valid(harvestlist,'data') && ~isempty(name2col(harvestlist,'System'))
      
      %init log structure and log record pointer
      log = struct('Date','', ...
         'System','', ...
         'Site','', ...
         'Station','', ...
         'Records','', ...
         'DateStart','', ...
         'DateEnd','', ...
         'Variables','');
      logptr = 0;
      
      %extract systems, sites, stations
      systems = extract(harvestlist,'System');
      sites = extract(harvestlist,'Site');
      stations = extract(harvestlist,'Station');
      
      %get unique sitelist
      sitelist = unique(sites);
      
      %init daily column list to extract (name, units, interpolate)
      cols_daily = { ...
         'Site','LTER Site',0; ...
         'Station','Station name',0; ...
         'Date','serial day (base 1/1/0000)',0; ...
         'Year','YYYY',0; ...
         'Month','M',0; ...
         'Day','D',0; ...
         'Daily_AirTemp_AbsMax_C','°C',1; ...
         'Daily_AirTemp_Mean_C','°C',0; ...
         'Daily_AirTemp_AbsMin_C','°C',1; ...
         'Daily_Precip_Total_MM','mm',0 ...
         };
      
      %loop through sites
      for sitenum = 1:length(sitelist)
         
         %get site name and index of records for site
         site = sitelist{sitenum};
         Isite = find(strcmp(site,sites));
         
         %display console status
         disp([datestr(now,0),': harvesting data for site ',site]); drawnow
         
         %init combined daily structure
         s_daily_site = [];
         
         %loop through station list harvesting data
         for n = 1:length(Isite)
            
            %extract harvest info values
            sys = systems{Isite(n)};
            station = stations{Isite(n)};
            
            %init log entry
            logptr = logptr + 1;
            log(logptr).Date = datestr(now,0);
            log(logptr).System = sys;
            log(logptr).Site = site;
            log(logptr).Station = station;
            
            %fetch data
            [s,msg0] = sub_fetch_data(sys,site,station,cols_daily(:,1));
            
            %check for harvested data
            if ~isempty(s)
               
               %extract dates and select target columns
               s_daily_station = copycols(s,cols_daily(:,1));
               dt = extract(s_daily_station,'Date');
               
               %add log entry
               log(logptr).Records = length(dt);
               log(logptr).DateStart = datestr(min(no_nan(dt)),0);
               log(logptr).DateEnd = datestr(max(no_nan(dt)),0);
               log(logptr).Variables = cell2commas(s_daily_station.name);
               log(logptr).Message = msg0;
               
               %get list of data/calc columns for missing column check
               vtype = get_type(s_daily_station,'variabletype');
               datacols = find(strcmp('data',vtype) | strcmp('calculation',vtype));
               
               %check for missing columns, add calculated or empty columns
               for cnt = 1:length(datacols)
                  
                  col = datacols(cnt);
                  colname = cols_daily{col,1};
                  units = cols_daily{col,2};
                  
                  if isempty(name2col(s_daily_station,colname))
                  
                     if strcmp('Daily_AirTemp_Mean_C',colname)
                     
                        %add calculated mean column
                        s_daily_station = add_calcexpr(s_daily_station, ...
                           '(Daily_AirTemp_AbsMax_C + Daily_AirTemp_AbsMin_C) ./ 2', ...  %expression
                           'Daily_AirTemp_Mean_C', ...        %column name
                           '°C', ...                          %units
                           'Daily mean air temperature', ...  %description
                           col, ...           %position
                           0, ...             %replicate scalar
                           '', ...            %criteria
                           'calculation' ...  %variabletype
                           );
                        
                        %set precision to 1
                        s_daily_station = update_attributes(s_daily_station,col,{'precision'},{1});
                     
                     else
                        
                        %add empty column
                        s_daily_station = addcol(s_daily_station, ...
                           NaN, ...           %value to add
                           colname, ...       %column name
                           units, ...         %units
                           colname, ...       %description
                           'f', ...           %data type
                           'data', ...        %variable type
                           'continuous', ...  %numeric type
                           2, ...             %precision
                           '', ...            %q/c criteria
                           col ...            %position
                           );
                     
                     end
                     
                  end
                  
               end
               
               %pad date gaps
               s_daily_station = pad_date_gaps(s_daily_station,'Date',1,1);
               
               %interpolate missing values
               if interp_daily > 0
                  
                  %get columns to interpolate
                  interpcols = find([cols_daily{:,3}]);
                  
                  if ~isempty(interpcols)
                     
                     %interpolate specified columns
                     s_tmp = interp_missing(s_daily_station, ...
                        'Date', ...      %x column
                        interpcols, ...  %columns to interpolate
                        'linear', ...    %regression method
                        interp_daily, ...  %max points to interpolate
                        50, ...          %max changes to log
                        'E', ...         %flag to assign
                        'Value estimated by linear interpolation' ...  %flag definition
                        );
                     
                     %check for valid data from interpolation
                     if ~isempty(s_tmp)
                        s_daily_station = s_tmp;
                     end
                     
                     %fill mean temp separately, calculating from max/min
                     s_daily_station = calc_missing_vals(s_daily_station, ...
                        'Daily_AirTemp_Mean_C', ...   %column to fill
                        '(Daily_AirTemp_AbsMax_C + Daily_AirTemp_AbsMin_C) ./ 2', ...  %ex[ression
                        50, ...          %max changes to log
                        'E', ...         %flag to assign
                        'Value estimated by linear interpolation' ...  %flag definition
                        );
                     
                  end
                  
               end
               
               %append data to output
               if isempty(s_daily_site)
                  s_daily_site = s_daily_station;
               else
                  s_daily_site = merge_by_date(s_daily_site,s_daily_station,'Date','Date',1,0);
               end
               
            else %no data
               
               log(logptr).Records = 0;
               log(logptr).DateStart = '';
               log(logptr).DateEnd = '';
               log(logptr).Variables = [];
               log(logptr).Message = msg0;
               
            end
            
            %add site data to cumulative daily data structure
            if isempty(s_daily)
               s_daily = s_daily_site;
            elseif ~isempty(s_daily_site)
               [s_tmp,msg0] = datamerge(s_daily,s_daily_site,1,1);
               if ~isempty(s_tmp)
                  s_daily = s_tmp;
               else
                  disp(['warning: error integrating data for site ',site,' (',msg0,')']); drawnow
               end                  
            else
               disp(['warning: no valid data generated for site ',site]); drawnow
            end
            
         end
         
      end
      
      %remove Date column
      s_daily = deletecols(s_daily,'Date');
               
      %add meaningful title to daily dataset
      titlestr = ['Long-term daily climate data from LTER sites ',cell2commas(sitelist,1)];
      s_daily = newtitle(s_daily,titlestr,0);
      
      %export daily file
      if ~isempty(s_daily) && ~isempty(fn_daily)

         %display status
         disp([datestr(now,0),': exporting daily data as text file']); drawnow
         
         %export text file
         [pn,fn_base,fn_ext] = fileparts(fn_daily);
         exp_ascii(s_daily, ...
            'comma', ...        %format
            [fn_base,fn_ext], ...  %filename
            pn, ...           %path
            '', ...           %report title
            'T', ...          %header option (column titles only)
            'N', ...          %flag option (do not display)
            '', ...           %metadata style (none)
            '', ...           %row leader (none)
            'no', ...         %row numbers (no)
            missingchar);     %missing value character
      end
      
      %display status
      disp([datestr(now,0),': generating monthly statistics']); drawnow
      
      %call function to generate monthly summary data
      [s_monthly,msg] = lter_climate_monthly(s_daily,min_year,max_year,fn_monthly,missingchar);
      
      %display status
      disp([datestr(now,0),': done processing']); drawnow
      
   elseif isempty(msg)
      msg = 'invalid harvest file structure';
   end
      
else
   msg = 'invalid harvest list structure or filename';
end

return

%define function for retrieving climdb data, joining multiple stations if necessary
function [s,msg] = sub_fetch_data(system,site,station,cols)

s = [];
msg = '';

if ~isempty(system) && ~isempty(site) && ~isempty(station)
   
   %separate stations
   stations = splitstr(station,',');
   
   for n = 1:length(stations)
      
      %get individual station id
      stat = stations{n};
      
      %fetch station data
      if strcmpi(system,'ClimDB')
         [s_tmp,msg] = fetch_climdb_data( ...
            site, ...        %site id
            stat, ...        %station id
            [], ...          %all parameters
            'workflow', ...  %user name for download logging
            'LTER', ...      %affiliation for download logging
            'update LTER site description data', ...  %purpose for download logging
            '1890-01-01', ...    %start date
            datestr(now,29) ...  %end date
            );
      else
         [s_tmp,msg] = fetch_ncdc_ghcnd( ...
            stat, ...              %station id
            'NCDC_GHCND', ...  %metdata template
            [], ...     %start date (earliest)
            [], ...     %end date (now)
            1 ...       %silent option to suppress progress bar
            );
         if ~isempty(s_tmp)
            s_tmp = apply_template(s_tmp,'NCDC_GHCND_ClimDB');  %map variables using template
            s_tmp = addcol(s_tmp,site,'Site','none','LTER site','s','nominal','none',0,'',0);  %add site
         end
      end
      
      %check for valid return data
      if ~isempty(s_tmp)
         
         %remove unneeded columns
         s_tmp = copycols(s_tmp,cols);
         
         %check for prior station data
         if isempty(s)
         
            %no prior station - return temp
            s = s_tmp;
            
         else
            
            %cache station ids
            oldstations = extract(s,'Station');
            newstations = extract(s_tmp,'Station');
            
            %join datasets on site, date/time
            s = joindata(deletecols(s,'Station'), ...
               deletecols(s_tmp,'Station'), ...
               {'Site','Date','Year','Month','Day'}, ...
               {'Site','Date','Year','Month','Day'}, ...
               'full');
            
            %add combined station ids
            s = addcol(s, ...
               {[oldstations{1},'/',newstations{1}]}, ...  %generate combined station id string
               'Station', ...           %column name
               'none', ...              %units
               'Sampling station', ...  %description
               's', ...                 %data type
               'nominal', ...           %variable type
               'none', ...              %numeric type
               0, ...                   %precision
               '', ...                  %criteria
               2 ...                    %column position
               );
         end
         
      end
      
   end
   
else
   msg = 'invalid site or station';
end

return
