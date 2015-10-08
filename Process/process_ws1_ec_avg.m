%% Process and post data 

%% Define function arguments
source     = 'fetch_ws1_ec_avg';                                        % name of fetch file that runs sql2gceds()
template   = 'LNDB_Ws1_2';                                              % Name of metadata template
sitecode   = 'WS1ECAVG';                                                % Added to the first column of output data structure
profile    = 'LNDB_HJA_WS1_EC_AVG';                                     % Used to define cases in harvest_info and harvest_plot_info
pn_dest_root    = localpath('pn_dest_root');
pn_dest_plot    = localpath('pn_plots_root');
html            = localpath('html');
email           = localpath('email');
pn_dest         = strcat(pn_dest_root,'WS1MET');
pn_plots        = strcat(pn_dest_root,'WS1MET');
c               = 2014; % c = clock for real-time processing or yyyy for post processing
fn_dest    = sprintf('hjaws1ec_avg_%d.mat', c(1));                % Monthly name of final GCE data structure
% fn_dest    = sprintf('hjaws1ec_avg_arch1_20121115_20130220.mat');                % Monthly name of final GCE data structure

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
