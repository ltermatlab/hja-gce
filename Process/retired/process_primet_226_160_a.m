%% Process and post data 

%% Define function arguments
source          = 'fetch_primet_226_160_a';
template        = 'LNDB_PriMet_226_160_a';
sitecode        = 'PRIMET_226';
profile         = 'LNDB_HJA_PriMet_226_160_a';
pn_dest_root    = localpath('pn_dest_root');
pn_dest_plot    = localpath('pn_plots_root');
html            = localpath('html');
email           = localpath('email');
pn_dest         = strcat(pn_dest_root,'PRIMET');
pn_plots        = strcat(pn_dest_root,'PRIMET');
c               = clock; % c = clock for real-time processing or yyyy for post processing
fn_dest         = sprintf('primet_226_hrly_%d_a.mat', c(1));

%% call the harvester
%data_harvester_sql(source,template,sitecode,profile,pn_dest,pn_plots,html,email,fn_dest);
primet_226_160_a_data_harvester_sql(source, ...
                    template, ...
                    sitecode, ...
                    profile, ...
                    pn_dest, ...
                    pn_plots, ...
                    html, ...
                    email, ...
                    fn_dest);

% TODO: Create one continually stacked file with complete period of record
