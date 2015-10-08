%% Process and post data 

%% Define function arguments
source          = 'fetch_varmet_301_115';
load 'C:\Users\kennedad\Dropbox\matlab\gce_datatools_380_gce_production\userdata\FINAL_AIRTEMP_QC4SIGMA_leap_ak.mat';    %added 20141201 to account for new qc stats file
qc_source       = data;
clear data
template        = 'LNDB_VarMet_2';
qc_template     = 'LNDB_VarMet_QC';
sitecode        = 'VARMET';
profile         = 'LNDB_VARMET_301_115';
pn_dest_root    = localpath('pn_dest_root');
pn_dest_plot    = localpath('pn_plots_root');
html            = localpath('html');
email           = localpath('email');
pn_dest         = strcat(pn_dest_root,'VARA');
pn_plots        = strcat(pn_dest_root,'VARA');
c               = 2015; % c = clock for real-time processing or yyyy for post processing
fn_dest         = sprintf('varmet_301_b_15min_%d.mat', c(1));
reprocess       = 1;

%% call the harvester
%data_harvester_sql(source,template,sitecode,profile,pn_dest,pn_plots,html,email,fn_dest);
varmet_data_harvester_sql_v2(source, ...
    qc_source, ...
    template, ...
    qc_template, ...
    sitecode, ...
    profile, ...
    pn_dest, ...
    pn_plots, ...
    html, ...
    email, ...
    fn_dest, ...
    reprocess);

%% Clear the workspace
clear