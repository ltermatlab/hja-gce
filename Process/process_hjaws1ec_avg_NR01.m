%% Process and post data 

%% Define function arguments
source          = 'fetch_hjaws1ec_avg_NR01';
template        = 'LNDB_Ws1_EcMet_Avg_NR01';
sitecode        = 'WS1ECMET_409';
profile         = 'LNDB_HJA_WS1_EC_MET_NR01';
pn_dest_root    = localpath('pn_dest_root');
pn_dest_plot    = localpath('pn_plots_root');
html            = localpath('html');
email           = localpath('email');
pn_dest         = strcat(pn_dest_root,'WS1MET');
pn_plots        = strcat(pn_dest_root,'WS1MET');
c               = clock; % c = clock for real-time processing or yyyy for post processing
fn_dest         = sprintf('hjaws1ec_avg_1min_NR01_%d.mat', c(1));

%% call the harvester
%data_harvester_sql(source,template,sitecode,profile,pn_dest,pn_plots,html,email,fn_dest);
ws1_data_harvester_sql(source, ...
                    template, ...
                    sitecode, ...
                    profile, ...
                    pn_dest, ...
                    pn_plots, ...
                    html, ...
                    email, ...
                    fn_dest);

% TODO: Create one continually stacked file with complete period of record
