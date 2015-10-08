%% Process and post data 

%% Define function arguments
source          = 'fetch_vanmet_228_160';
template        = 'LNDB_VanMet_1';
sitecode        = 'VANMET_228';
profile         = 'LNDB_VanMet_228_160';
pn_dest_root    = localpath('pn_dest_root');
pn_dest_plot    = localpath('pn_plots_root');
html            = localpath('html');
email           = localpath('email');
pn_dest         = strcat(pn_dest_root,'VANMET');
pn_plots        = strcat(pn_dest_root,'VANMET');
c               = 2013; % c = clock for real-time processing or yyyy for post processing
fn_dest         = sprintf('vanmet_228_hrly_%d.mat', c(1));

%% call the harvester
%data_harvester_sql(source,template,sitecode,profile,pn_dest,pn_plots,html,email,fn_dest);
vanmet_data_harvester_sql(source, ...
                    template, ...
                    sitecode, ...
                    profile, ...
                    pn_dest, ...
                    pn_plots, ...
                    html, ...
                    email, ...
                    fn_dest);

% TODO: Create one continually stacked file with complete period of record
