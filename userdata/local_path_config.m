%Local path configuration file.
%Paths are specific to local installations

clear
% % Development
% pn_dest_root    = 'C:\Users\kennedad\HJA\Portal\'; %Dev machine
% pn_plots_root   = 'C:\Users\kennedad\HJA\Portal\'; %Dev machine
% html            = '1';
% email           = '';
% plot_xsl        = 'http://andrewsforest.oregonstate.edu/lter/about/weather/portal/WebHarvestDetails/harvest_plots.xsl';
% xslIndex        = 'http://andrewsforest.oregonstate.edu/lter/about/weather/portal/WebHarvestDetails/harvest_index.xsl';
% xslDetails      = 'http://andrewsforest.oregonstate.edu/lter/about/weather/portal/WebHarvestDetails/harvest_details.xsl';
% 
% define base navigation for the entire web site
% nav_base        = {'Home','http://andrewsforest.oregonstate.edu/lter/about/weather/portal/', ...
%                     'HJA Data Portal (powered by GCE)','../data/index.html'};
% 
% save userdata\localpaths.mat
% clear

%% Production
pn_dest_root    = '\\Stewartia\WorkSpace\LTERLoggers\HJA\Portal_dev\'; %Production machine
pn_plots_root   = '\\Stewartia\WorkSpace\LTERLoggers\HJA\Portal_dev\'; %Production machine
html            = '1';
email           = '1';
plot_xsl        = 'http://andrewsforest.oregonstate.edu/lter/about/weather/portal/WebHarvestDetails/harvest_plots.xsl';
xslIndex        = 'http://andrewsforest.oregonstate.edu/lter/about/weather/portal/WebHarvestDetails/harvest_index.xsl';
xslDetails      = 'http://andrewsforest.oregonstate.edu/lter/about/weather/portal/WebHarvestDetails/harvest_details.xsl';

%define base navigation for the entire web site
nav_base        = {'Home','http://andrewsforest.oregonstate.edu/lter/about/weather/portal/', ...
                    'HJA Data Portal (powered by GCE)','../data/index.html'};

save userdata\localpaths.mat
clear



%% example
% rawdata = 'C:\data\loggers';
% processed = 'D:\webdata\met\data';
% plots = 'D:\webdata\met\plots';
% save userdata\localpaths.mat
% clear

%include this line in every file: 
%pn = localpath('rawdata')
