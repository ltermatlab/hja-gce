%% Process and post data 

%% Define function arguments
source          = 'fetch_hi15_208_440';
template        = 'LNDB_Hi15_Daily_1';
sitecode        = 'HI15_208';
profile         = 'LNDB_HJA_Hi15_208_440';
pn_dest_root    = localpath('pn_dest_root');
pn_dest_plot    = localpath('pn_plots_root');
html            = localpath('html');
email           = localpath('email');
pn_dest         = strcat(pn_dest_root,'HI15');
pn_plots        = strcat(pn_dest_root,'HI15');
c               = 2014; % c = clock for real-time processing or yyyy for post processing
fn_dest         = sprintf('hi15_208_dly_%d.mat', c(1));
reprocess       =1;


%% call the harvester
%data_harvester_sql(source,template,sitecode,profile,pn_dest,pn_plots,html,email,fn_dest);
hi15_data_harvester_sql(source, ...
    template, ...
    sitecode, ...
    profile, ...
    pn_dest, ...
    pn_plots, ...
    html, ...
    email, ...
    fn_dest, ...
    reprocess);