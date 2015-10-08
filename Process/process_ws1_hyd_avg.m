%% Process and post data 

%% Define function arguments
source          = 'fetch_ws1_hyd_avg';
template        = 'LNDB_Ws1_2';
sitecode        = 'WS1HYDAVG';
profile         = 'LNDB_HJA_WS1_HYD_AVG';
pn_dest_root    = localpath('pn_dest_root');
pn_dest_plot    = localpath('pn_plots_root');
html            = localpath('html');
email           = localpath('email');
pn_dest         = strcat(pn_dest_root,'WS1MET');
pn_plots        = strcat(pn_dest_root,'WS1MET');
c               = clock; % c = clock for real-time processing or yyyy for post processing
fn_dest         = sprintf('ws1_hyd_avg_%d.mat', c(1));

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

%% call gce_fastinsert() and send gce data structure back to database

