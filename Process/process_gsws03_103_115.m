%% Process and post data 

%% Define function arguments
source          = 'fetch_gsws03_103_115';
template        = 'LNDB_GsWS03_2';
sitecode        = 'GSWS03_103';
profile         = 'LNDB_GsWs03_115';
pn_dest_root    = localpath('pn_dest_root');
pn_dest_plot    = localpath('pn_plots_root');
html            = localpath('html');
email           = localpath('email');
pn_dest         = strcat(pn_dest_root,'GSWS03');
pn_plots        = strcat(pn_dest_root,'GSWS03');
c               = clock; % c = clock for real-time processing or yyyy for post processing
fn_dest         = sprintf('gsws03_103_15min_%d.mat', c(1));

%% call the harvester
%data_harvester_sql(source,template,sitecode,profile,pn_dest,pn_plots,html,email,fn_dest);
hjagage_data_harvester_sql(source, ...
                    template, ...
                    sitecode, ...
                    profile, ...
                    pn_dest, ...
                    pn_plots, ...
                    html, ...
                    email, ...
                    fn_dest);

% %% Call harvest dashboard
% % Add path names for harvest dashboard
% pn_xml         = strcat(pn_dest_root,'GSWS03\dash\103_105');
% fn_dash         = strcat(sitecode,'.xml');
% %filenames and corresponding xsl urls
% fn_xml = {'index.xml';'index2.xml'};
% xsl_url = {'http://andrewsforest.oregonstate.edu/lter/about/weather/portal/WebHarvestDetails/harvest_dashboard.xsl'; ...
%     'http://andrewsforest.oregonstate.edu/lter/about/weather/portal/WebHarvestDetails/harvest_dashboard_select_showbad.xsl'};
% 
% %load the GCE data strucgure
% load(strcat(pn_dest,'\data\',fn_dest));
% % breadcrumb navigation for harvest dashboard webpage 
%        nav = { ...
%            'Home','http://andrewsforest.oregonstate.edu/lter/about/weather/portal/'; ...
%            'Data',''; ...
%            'Portal',''; ...
%            'Gaging Station',''};
%        
%        %generate xml report and plots (see help for other options)
%        msg = gsws03_105_harvest_dashboard( ...
%            data, ...             %data structure to report on (needs Date or date part columns)
%            pn_xml, ...          %destination directory
%            0, ...                %time offset from station clock in hours (0 for none)
%            fn_xml, ...          %name for xml report file
%            nav, ...               %breadcrumb navigation array
%            '', ...              %Plot prefix
%            xsl_url ...          %name for xml report file
%            );
%% Clear the workspace
clear