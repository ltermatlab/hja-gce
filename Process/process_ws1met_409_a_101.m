%% Process and post data 

% %% Define function arguments
% source          = 'fetch_ws1_ec2';
% template        = 'LNDB_WS1_EC2_1';
% sitecode        = 'WS1MET';
% profile         = 'LNDB_HJA_WS1_EC2';
% pn_dest_root    = localpath('pn_dest_root');
% pn_dest_plot    = localpath('pn_plots_root');
% html            = localpath('html');
% email           = localpath('email');
% pn_dest         = strcat(pn_dest_root,'WS1MET');
% pn_plots        = strcat(pn_dest_root,'WS1MET');
% c               = 2015; % c = clock for real-time processing or yyyy for post processing
% fn_dest         = sprintf('ws1met_sub_avg_%d.mat', c(1));

%% Define function arguments
source          = 'fetch_ws1met_409_a_101';
%load 'C:\Users\kennedad\Dropbox\matlab\gce_datatools_380_gce_production\userdata\FINAL_AIRTEMP_QC4SIGMA_leap_ak.mat';    %added 20140924 to account for new qc stats file
%qc_source       = data;
%clear data
template        = 'LNDB_WS1MET';
sitecode        = 'WS1MET_409';
profile         = 'LNDB_HJA_WS1_EC2';
pn_dest_root    = localpath('pn_dest_root');
pn_dest_plot    = localpath('pn_plots_root');
html            = localpath('html');
email           = localpath('email');
pn_dest         = strcat(pn_dest_root,'WS1MET');
pn_plots        = strcat(pn_dest_root,'WS1MET');
c               = 2015; % c = clock for real-time processing or yyyy for post processing
fn_dest         = sprintf('ws1met_409_a_1min_%d.mat', c(1));
reprocess       = 1;

%% call the harvester
%data_harvester_sql(source,template,sitecode,profile,pn_dest,pn_plots,html,email,fn_dest);
ws1met_data_harvester_sql(source, ...
                    template, ...
                    sitecode, ...
                    profile, ...
                    pn_dest, ...
                    pn_plots, ...
                    html, ...
                    email, ...
                    fn_dest, ...
                    reprocess);
                
                %% Call harvest dashboard
% Add path names for harvest dashboard
pn_xml         = strcat(pn_dest_root,'WS1MET\dash\409_a_101');
%fn_dash         = strcat(sitecode,'.xml');
%filenames and corresponding xsl urls
fn_xml = {'index.xml';'index2.xml'};
     xsl_url = {'http://andrewsforest.oregonstate.edu/lter/about/weather/portal/WebHarvestDetails/harvest_dashboard.xsl'; ...
        'http://andrewsforest.oregonstate.edu/lter/about/weather/portal/WebHarvestDetails/harvest_dashboard_select.xsl'};

%load the GCE data strucgure
load(strcat(pn_dest,'\data\',fn_dest));

% breadcrumb navigation for harvest dashboard webpage 
       nav = { ...
           'Home','http://andrewsforest.oregonstate.edu/lter/about/weather/portal/'; ...
           'Data',''; ...
           'Portal',''; ...
           'Climate Station',''};
       
       %generate xml report and plots (see help for other options)
       msg = harvest_dashboard( ...
           data, ...             %data structure to report on (needs Date or date part columns)
           pn_xml, ...          %destination directory
           0, ...                %time offset from station clock in hours (0 for none)
           fn_xml, ...          %name for xml report file
           nav, ...               %breadcrumb navigation array
           '', ...              %Plot prefix
           xsl_url ...          %name for xml report file
           );
%% Clear the workspace
clear

