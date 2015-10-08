%% Process and post data 

%% Define function arguments
source          = 'fetch_cenmet_225_440';
template        = 'LNDB_CenMet_1';
sitecode        = 'CENMET_225';
profile         = 'LNDB_HJA_CenMet_440';
pn_dest_root    = localpath('pn_dest_root');
pn_dest_plot    = localpath('pn_plots_root');
html            = localpath('html');
email           = localpath('email');
pn_dest         = strcat(pn_dest_root,'CENMET');
pn_plots        = strcat(pn_dest_root,'CENMET');
c               = 2015; % c = clock for real-time processing or yyyy for post processing
fn_dest         = sprintf('cenmet_225_dly_%d.mat', c(1));

%% call the harvester
%data_harvester_sql(source,template,sitecode,profile,pn_dest,pn_plots,html,email,fn_dest);
cenmet_data_harvester_sql(source, ...
                    template, ...
                    sitecode, ...
                    profile, ...
                    pn_dest, ...
                    pn_plots, ...
                    html, ...
                    email, ...
                    fn_dest);

% TODO: Create one continually stacked file with complete period of record
