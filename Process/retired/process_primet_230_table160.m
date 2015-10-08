%% Process and post data 

%% Define function arguments
source          = 'fetch_primet_230_table160';
template        = 'LNDB_PriMet_1';
sitecode        = 'PRIMET_230';
profile         = 'LNDB_HJA_PriMet_230_160';
pn_dest_root    = localpath('pn_dest_root');
pn_dest_plot    = localpath('pn_plots_root');
html            = localpath('html');
email           = localpath('email');
pn_dest         = strcat(pn_dest_root,'PRIMET');
pn_plots        = strcat(pn_dest_root,'PRIMET');
c               = clock; % c = clock for real-time processing or yyyy for post processing
fn_dest         = sprintf('primet_230_hrly_%d.mat', c(1));
reprocess       =1;

%% call the harvester
%data_harvester_sql(source,template,sitecode,profile,pn_dest,pn_plots,html,email,fn_dest);
primet_data_harvester_sql(source, ...
    template, ...
    sitecode, ...
    profile, ...
    pn_dest, ...
    pn_plots, ...
    html, ...
    email, ...
    fn_dest, ...
    reprocess);

% TODO: Create one continually stacked file with complete period of record
