%% Join and plot data

%% Define function arguments
pn_dest_root    = localpath('pn_dest_root');
pn_dest_plot    = localpath('pn_plots_root');
pn_dest         = strcat(pn_dest_root,'MISC\GREEN');
pn_plots        = strcat(pn_dest_root,'MISC\GREEN');
profile         = 'LNDB_HJA_GREEN_Combined';
c               = clock; % c = clock for real-time processing or yyyy for post processing
fn_dest_s0      = sprintf('GREEN_401_a_15min_%d.mat', c(1));
fn_dest_s1      = sprintf('GREEN_400_a_15min_%d.mat', c(1));
load(strcat(pn_dest,'\data\',fn_dest_s0)); s0 = data;
clear data
load(strcat(pn_dest,'\data\',fn_dest_s1)); s1 = data;
clear data
key0            ='Date';
key1            ='Date';
jointype        ='inner';
cols0           =[];
cols1           =[];
prefix0         ='400_';
prefix1         ='401_';
s1name          =[];
cleardupes      =[];
matchunits      =1;
metamerge       ='all';



%% Call the Join function
[dummy,msg] = joindata(s0, ...
    s1, ...
    key0, ...
    key1, ...
    jointype, ...
    prefix0, ...
    prefix1, ...
    matchunits, ...
    metamerge);


%% Plot functions here

%index the destination directory to create/update XML index and data set summary pages
harvest_datapages_xml( ...
    pn_dest, ...     %base pathname containing files to index
    '', ...          %subdirectories in pn_dest to index
    profile, ...     %profile name in harvest_info.m
    html, ...        %set HTML format option to transform XML to HTML
    '', ...          %set interval to automatic
    'MD' ...         %flag display format ('MD' = flag columns for all data/calc columns)
    );

%generate plots using stored configuration info in demo/harvest_plot_info.m if pn_plots provided
if ~isempty(dummy) && ~isempty(pn_plots)
    fn_dest = dummy;
    
    msg = harvest_webplots_xml( ...
        fn_dest, ...   %filename of data structure to plot
        pn_data, ...   %pathname containing fn_dest
        pn_plots, ...  %pathname for plot files
        profile, ...   %profile name in harvest_plot_info.m
        'month', ...   %plot interval
        html ...       %set HTML format option to transform XML to HTML
        );
    
end













