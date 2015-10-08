%% Process and post data 

%% Define function arguments
source     = 'fetch_ws1_ec_avg_arch1';                                        % name of fetch file that runs sql2gceds()
template   = 'LNDB_Ws1_2';                                              % Name of metadata template
sitecode   = 'WS1ECAVG';                                                % Added to the first column of output data structure
profile    = 'LNDB_HJA_WS1_EC_AVG_arch1';                                     % Used to define cases in harvest_info and harvest_plot_info
pn_dest    = '\\POPULUS\weather\GCE-HJA\LNDB_TEST\PORTAL\WS1MET';       % Name of destination directory for data  (must exist)
pn_plots   = '\\POPULUS\weather\GCE-HJA\LNDB_TEST\PORTAL\WS1MET';       % Name of destination directory for plots (must exist)
html       = '0';                                           
email      = '';            
%c = clock;                                                      % c = Back populating data, manual file name
%fn_dest    = sprintf('hjaws1ec_avg_arch1_%d.mat', c(1));                % Monthly name of final GCE data structure
fn_dest    = sprintf('hjaws1ec_avg_arch1_20121115_20130220.mat');                % Monthly name of final GCE data structure

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
