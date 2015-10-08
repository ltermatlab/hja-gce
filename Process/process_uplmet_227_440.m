%% Process and post data 

%% Define function arguments
source          = 'fetch_uplmet_227_440';
load 'C:\Users\kennedad\Dropbox\matlab\gce_datatools_380_gce_production\userdata\FINAL_AIRTEMP_QC4SIGMA_leap_ak.mat';    %added 20141202 to account for new qc stats file
qc_source       = data;
clear data
template        = 'LNDB_UplMet_1';
sitecode        = 'UPLMET_227';
profile         = 'LNDB_HJA_UplMet_440';
pn_dest_root    = localpath('pn_dest_root');
pn_dest_plot    = localpath('pn_plots_root');
html            = localpath('html');
email           = localpath('email');
pn_dest         = strcat(pn_dest_root,'UPLMET');
pn_plots        = strcat(pn_dest_root,'UPLMET');
c               = 2015; % c = clock for real-time processing or yyyy for post processing
fn_dest         = sprintf('uplmet_227_dly_%d.mat', c(1));
reprocess       = 1;

%% call the harvester
%uplmet_data_harvester_sql(source,template,sitecode,profile,pn_dest,pn_plots,html,email,fn_dest,reprocess);
uplmet_data_harvester_sql_v2(source, ...
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

%% Add path names for harvest dashboard
pn_xml         = strcat(pn_dest_root,'UPLMET\dash\227_a_440');
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
