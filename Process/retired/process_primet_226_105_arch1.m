%% Process and post data 

%% Define function arguments
source          = 'fetch_primet_226_105_arch1';
load 'C:\Users\kennedad\Dropbox\matlab\gce_datatools_380_gce_production\userdata\FINAL_AIRTEMP_QC4SIGMA_leap_ak.mat';    %added 20140924 to account for new qc stats file
qc_source       = data;
clear data
template        = 'LNDB_PriMet_226_105_arch1'; %template provided in data_harvester()
sitecode        = 'PRIMET_226';
profile         = 'LNDB_HJA_PriMet_226_105_arch1';
pn_dest_root    = localpath('pn_dest_root');
pn_dest_plot    = localpath('pn_plots_root');
html            = localpath('html');
email           = localpath('email');
pn_dest         = strcat(pn_dest_root,'PRIMET');
pn_plots        = strcat(pn_dest_root,'PRIMET');
c               = 2013; % c = clock for real-time processing or yyyy for post processing
fn_dest         = sprintf('primet_226_5min_%d.mat', c(1));
reprocess       = 1;

%% call the harvester
% Because there was a massive overhaul at this logger, this is a specific
% workflow. It will be retired after completion of this processing.
%data_harvester_sql(source,template,sitecode,profile,pn_dest,pn_plots,html,email,fn_dest);
primet_226_105_arch1_data_harvester_sql_v2(source, ...
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
