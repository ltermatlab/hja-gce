%% Process and post data 

%% Define function arguments
source          = 'fetch_refstand_05_dly';
load 'C:\Users\kennedad\Dropbox\matlab\gce_datatools_380_gce_production\userdata\FINAL_REFSTAND_AIRTEMP_QC4SIGMA_leap_ak.mat';    %added 20140924 to account for new qc stats file
qc_source       = data;
clear data
template        = 'LNDB_RefStand_Daily_1';
sitecode        = 'RS05_005';
profile         = 'LNDB_HJA_RS05_dly';
pn_dest_root    = localpath('pn_dest_root');
pn_dest_plot    = localpath('pn_plots_root');
html            = localpath('html');
email           = localpath('email');
pn_dest         = strcat(pn_dest_root,'RS\RS05');
pn_plots        = strcat(pn_dest_root,'RS\RS05');
fn_dest         = sprintf('RS05_005_dly.mat');
reprocess       = 1;


%% call the harvester
%data_harvester_sql(source,template,sitecode,profile,pn_dest,pn_plots,html,email,fn_dest);
refstand_data_harvester_sql(source, ...
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