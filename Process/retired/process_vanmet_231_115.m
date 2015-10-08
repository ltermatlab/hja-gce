%% Process and post data 

%% Define function arguments
source          = 'fetch_vanmet_231_Table115';
template        = 'LNDB_VanMet_2';
sitecode        = 'VANMET_231';
profile         = 'LNDB_VanMet_231_115';
pn_dest_root    = localpath('pn_dest_root');
pn_dest_plot    = localpath('pn_plots_root');
html            = localpath('html');
email           = localpath('email');
pn_dest         = strcat(pn_dest_root,'VANMET');
pn_plots        = strcat(pn_dest_root,'VANMET');
c               = clock; % c = clock for real-time processing or yyyy for post processing
fn_dest         = sprintf('vanmet_231_15min_%d.mat', c(1));

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
