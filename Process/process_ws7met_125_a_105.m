%% Process and post data 

%% Define function arguments
source          = 'fetch_ws7met_125_a_105';
load 'C:\Users\kennedad\Dropbox\matlab\gce_datatools_380_gce_production\userdata\FINAL_AIRTEMP_QC4SIGMA_leap_ak.mat';    %added 20140924 to account for new qc stats file
qc_source       = data;
clear data
template        = 'LNDB_Ws7Met_4';
sitecode        = 'WS7MET_125';
profile         = 'LNDB_HJA_Ws7Met_125_a_5min'; % Doesn't actually exist
%profile_hrly    = 'LNDB_HJA_Ws7Met_233_a_hrly';
%profile_dly     = 'LNDB_HJA_Ws7Met_233_a_dly';
pn_dest_root    = localpath('pn_dest_root');
pn_dest_plot    = localpath('pn_plots_root');
html            = localpath('html');
email           = localpath('email');
pn_dest         = strcat(pn_dest_root,'WS7MET');
pn_plots        = strcat(pn_dest_root,'WS7MET');
c               = 2015; % c = clock for real-time processing or yyyy for post processing
fn_dest         = sprintf('ws7met_125_a_5min_%d.mat', c(1));
%fn_dest_hrly    = sprintf('ws7met_125_a_hrly_%d.mat', c(1));
%fn_dest_dly     = sprintf('ws7met_125_a_dly_%d.mat', c(1));
reprocess       = 1;

%% call the harvester
%data_harvester_sql(source,template,sitecode,profile,pn_dest,pn_plots,html,email,fn_dest);
ws7met_data_harvester_sql(source, ...
    qc_source, ...
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
pn_xml         = strcat(pn_dest_root,'WS7MET\dash\125_a_105');
%fn_dash         = strcat(sitecode,'.xml');
%filenames and corresponding xsl urls
fn_xml = {'index.xml';'index2.xml'};
     xsl_url = {'http://andrewsforest.oregonstate.edu/lter/about/weather/portal/WebHarvestDetails/harvest_dashboard.xsl'; ...
        'http://andrewsforest.oregonstate.edu/lter/about/weather/portal/WebHarvestDetails/harvest_dashboard_select.xsl'};

%load the GCE data structure
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
