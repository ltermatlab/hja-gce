function [plotinfo,nav,pagetitle] = harvest_plot_info(id)
%Master plot configuration information retrieval function for use with harvest_plots_xml
%to provide resource-specific details for generating plots and XML plot index pages for a web site
%
%syntax: [plotinfo,nav,pagetitle] = harvest_plot_info(id)
%
%input:
%   id = harvest id for matching when multiple configurations are defined (string - optional; default = 'demo')
%
%output:
%   plotinfo = structure containing settings for 1 or more plots to generate and index
%   nav = cell array of label/url pairs for generating breadcrumb navigation on web pages
%   pagetitle = character array containing title string to use on the plot index page
%
%notes:
%   1) to add support for a new station, copy the 'case' entry for the default case,
%      substitute a unique id for 'default', and edit the individual settings accordingly
%
%contact:
%  Wade Sheldon
%  GCE-LTER Project
%  Department of Marine Sciences
%  University of Georgia
%  Athens, GA 30602-3636
%  sheldon@uga.edu
%
%last modified: 19-Nov-2012

if nargin == 0
   id = 'default';
end

%MATLAB symbols for colors, markers and line styles (from 'help plot'):
%  
%   Color Key:        Marker/Symbol Key:        Line Style Key:
%   b = blue          . = point                 - = solid
%   g = green         o = circle                : = dotted
%   r = red           x = x-mark                -. = dashdot
%   c = cyan          + = plus                  -- = dashed
%   m = magenta       * = star                  '' = no line
%   y = yellow        s = square
%   k = black         d = diamond
%   w = white         v = triangle (down)
%                     ^ = triangle (up)
%                     < = triangle (left)
%                     > = triangle (right)
%                     p = pentagram
%                     h = hexagram

%init plotinfo structure
plotinfo = struct( ...
   'caption','', ...     %page caption
   'fnc','', ...         %plot function to call ('plotdata','plotgroups','plotwind',...)
   'plotprefix','', ...  %distinct plot filename prefix to append to base filename and pre-pend to date interval labels to avoid name conflicts
   'datecol','', ...     %date column for time-series plots (e.g. 'Date')
   'parameters',[], ...  %array of column names to plot (e.g. {'Temp_Air','Precipitation'})
   'groupcol','', ...    %grouping column for plotgroups function (e.g. 'Site')
   'colors',[], ...      %array of MATLAB plot color codes (see color key; e.g. {'b','k'})
   'markers',[], ...     %array of MATLAB plot symbol codes (see marker key; e.g. {'o','^'})
   'linestyles',[], ...  %array of MATLAB plot line style codes (see line style key; e.g. {'-','-'})
   'scale','', ...       %plot scale option (e.g. 'auto','linear','log')
   'rotateaxis',[], ...  %rotate axis option (see 'help plotdata'; 0 = do not rotate, 1 = rotate)
   'ylim',[], ...        %array of Y-axis limits (e.g. [-5 40] or [] for auto)
   'deblank',[], ...     %option to skip empty Y-values and force continuous lines (0 = no, 1 = yes)
   'fn_xml','', ...      %name for the xml index file (e.g. 'airtemp_precip.xml')
   'xsl','', ...         %url of the XSL file to use for rendering the plot index page
   'navigation','' ...   %label to use in breadcrumb navigation
   );


plot_xsl = localpath('plot_xsl');
nav_base = localpath('nav_base');

%match id to plot profile
switch id
   
   case 'LNDB_HJA_CenMet_105'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'CENMET','../data'}];
      
      %define plot page title
      pagetitle = 'Central Met Station';
      
      %parameterize plot options
      plotinfo(1).caption = 'Precipitation';
      plotinfo(1).plotprefix = 'ppt';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'PRECIP_INST_455_0_01','PRECIP_INST_625_0_02'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g'};
      plotinfo(1).markers = {'.','o'};
      plotinfo(1).linestyles = {'-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'ppt.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Precipitation';
      
      plotinfo(2).caption = 'Snow Moisture';
      plotinfo(2).plotprefix = 'swe';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'SWE_INST_0_0_01'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b'};
      plotinfo(2).markers = {'.'};
      plotinfo(2).linestyles = {'-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'swe.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'SWE';
      
      plotinfo(3).caption = 'Snow Depth';
      plotinfo(3).plotprefix = 'snodep';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'SNODEP_MED_0_0_01','SNODEP_INST_0_0_01'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b','g'};
      plotinfo(3).markers = {'.','o'};
      plotinfo(3).linestyles = {'-','-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'snodep.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'Snow Depth';
      
   case 'LNDB_HJA_CenMet_115'  %3-plot GCE example
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'CENMET','../data'}];
      
      %define plot page title
      pagetitle = 'Central Met Station';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_MEAN_150_0_04','AIRTEMP_MEAN_250_0_03','AIRTEMP_MEAN_350_0_02','AIRTEMP_MEAN_450_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r','c'};
      plotinfo(1).markers = {'.','o','x','+'};
      plotinfo(1).linestyles = {'-','-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
   case 'LNDB_HJA_CenMet_160'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'CENMET','../data'}];
      
      %define plot page title
      pagetitle = 'Central Met Station';
      
      plotinfo(1).caption = 'Soil Temperature';
      plotinfo(1).plotprefix = 'soil';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'SOILTEMP_MEAN_0_10_01','SOILTEMP_MEAN_0_20_02','SOILTEMP_0_50_03','SOILTEMP_MEAN_0_100_04'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r','c'};
      plotinfo(1).markers = {'.','o','x','+'};
      plotinfo(1).linestyles = {'-','-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'soil.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Soil Temperature';
     
  case 'LNDB_HJA_CenMet_440'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'CENMET','../data'}];
      
      %define plot page title
      pagetitle = 'Central Met Station';
      
      plotinfo(1).caption = 'Daily Precipitation';
      plotinfo(1).plotprefix = 'pptdaily';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'PRECIP_TOT_455_0_01','PRECIP_TOT_625_0_02'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g'};
      plotinfo(1).markers = {'o','o'};
      plotinfo(1).linestyles = {'','',};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'pptdaily.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Daily Precipitation';
      
   case 'LNDB_HJA_CenMet_233_a_5min'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'CENMET','../data'}];
      
      %define plot page title
      pagetitle = 'Central Met Station';
      
      plotinfo(1).caption = 'Dew Point';
      plotinfo(1).plotprefix = 'dewpt';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'DEWPT_MEAN_150_0_04','DEWPT_MEAN_450_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g'};
      plotinfo(1).markers = {'.','o'};
      plotinfo(1).linestyles = {'-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'dewpt.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Dew Point';

      plotinfo(2).caption = 'Air Temperature';
      plotinfo(2).plotprefix = 'air';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'AIRTEMP_MEAN_150_0_04','AIRTEMP_MEAN_250_0_03','AIRTEMP_MEAN_350_0_02','AIRTEMP_MEAN_450_0_01'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g','r','c'};
      plotinfo(2).markers = {'.','o','x','+'};
      plotinfo(2).linestyles = {'-','-','-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'air.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Air Temperature';
      
      plotinfo(3).caption = 'Relative Humidity';
      plotinfo(3).plotprefix = 'rh';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'RELHUM_MEAN_150_0_04','RELHUM_MEAN_450_0_01'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b','g'};
      plotinfo(3).markers = {'.','o'};
      plotinfo(3).linestyles = {'-','-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'rh.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'RH';
      
      plotinfo(4).caption = 'Soil Temperature';
      plotinfo(4).plotprefix = 'ts';
      plotinfo(4).fnc = 'plotdata';
      plotinfo(4).datecol = 'Date';
      plotinfo(4).parameters = {'SOILTEMP_MEAN_0_10_01','SOILTEMP_MEAN_0_20_02','SOILTEMP_MEAN_0_50_03','SOILTEMP_MEAN_0_100_04'};
      plotinfo(4).groupcol = [];
      plotinfo(4).colors = {'b','g','r','c'};
      plotinfo(4).markers = {'.','o','x','+'};
      plotinfo(4).linestyles = {'-','-','-','-'};
      plotinfo(4).scale = 'linear';
      plotinfo(4).rotateaxis = 0;
      plotinfo(4).ylim = [];
      plotinfo(4).deblank = 0;
      plotinfo(4).fn_xml = 'ts.xml';
      plotinfo(4).xsl = plot_xsl;
      plotinfo(4).navigation = 'Soil Temperature';
      
      plotinfo(5).caption = 'Soil Moisture';
      plotinfo(5).plotprefix = 'soilm';
      plotinfo(5).fnc = 'plotdata';
      plotinfo(5).datecol = 'Date';
      plotinfo(5).parameters = {'SOILWC_MEAN_0_10_01','SOILWC_MEAN_0_20_02','SOILWC_MEAN_0_50_03','SOILWC_MEAN_0_100_04'};
      plotinfo(5).groupcol = [];
      plotinfo(5).colors = {'b','g','r','c'};
      plotinfo(5).markers = {'.','o','x','+'};
      plotinfo(5).linestyles = {'-','-','-','-'};
      plotinfo(5).scale = 'linear';
      plotinfo(5).rotateaxis = 0;
      plotinfo(5).ylim = [];
      plotinfo(5).deblank = 0;
      plotinfo(5).fn_xml = 'soilm.xml';
      plotinfo(5).xsl = plot_xsl;
      plotinfo(5).navigation = 'Soil Moisture';
      
   case 'LNDB_HJA_CenMet_233_a_hrly'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'CENMET','../data'}];
      
      %define plot page title
      pagetitle = 'Central Met Station';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'Hourly_Mean_AIRTEMP_MEAN_150_0_04','Hourly_Mean_AIRTEMP_MEAN_250_0_03','Hourly_Mean_AIRTEMP_MEAN_350_0_02','Hourly_Mean_AIRTEMP_MEAN_450_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r','c'};
      plotinfo(1).markers = {'.','o','x','+'};
      plotinfo(1).linestyles = {'-','-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
   case 'LNDB_HJA_CenMet_233_a_dly'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'CENMET','../data'}];
      
      %define plot page title
      pagetitle = 'Central Met Station';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'Daily_Mean_AIRTEMP_MEAN_150_0_04','Daily_Mean_AIRTEMP_MEAN_250_0_03','Daily_Mean_AIRTEMP_MEAN_350_0_02','Daily_Mean_AIRTEMP_MEAN_450_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r','c'};
      plotinfo(1).markers = {'.','o','x','+'};
      plotinfo(1).linestyles = {'-','-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
    
    case 'LNDB_HJA_CS2MET_CLRG'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'CS2MET','../data'}];
      
      %define plot page title
      pagetitle = 'Climatic Station Watershed 2';
      
      plotinfo(1).caption = 'PPT Difference';
      plotinfo(1).plotprefix = 'pptdiff';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'PPT_N4_DIFF'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'k'};
      plotinfo(1).markers = {'d'};
      plotinfo(1).linestyles = {''};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'pptdiff.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'PPT Diff';
      
      plotinfo(2).caption = 'Battery Supply Level';
      plotinfo(2).plotprefix = 'batt';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'BATTERY_MIN'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b'};
      plotinfo(2).markers = {'.'};
      plotinfo(2).linestyles = {'-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'batt.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Battery Supply Level';
      
      plotinfo(3).caption = 'Gage Level';
      plotinfo(3).plotprefix = 'ppt';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'PPT_N4_INST','PPT_N4_AVG'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b','g'};
      plotinfo(3).markers = {'.','o'};
      plotinfo(3).linestyles = {'-','-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'ppt.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'PPT';
      
   case 'LNDB_HJA_CS2MET_104_105'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'CS2MET','../data'}];
      
      %define plot page title
      pagetitle = 'Climatic Station Watershed 2';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'ta';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIR_150_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'ta.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
      plotinfo(2).caption = 'Relative Humidity';
      plotinfo(2).plotprefix = 'rh';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'RH_150_AVG'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b'};
      plotinfo(2).markers = {'.'};
      plotinfo(2).linestyles = {'-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'rh.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'RH';
      
  case 'LNDB_HJA_CS2MET_104_110'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'CS2MET','../data'}];
      
      %define plot page title
      pagetitle = 'Climatic Station Watershed 2';
      
      plotinfo(1).caption = 'Relative Humidity';
      plotinfo(1).plotprefix = 'rh';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'RH_150_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'rh.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'RH';
    
    case 'LNDB_HJA_CS2MET_104_115'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'CS2MET','../data'}];
      
      %define plot page title
      pagetitle = 'Climatic Station Watershed 2';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'ta';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIR_150_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'ta.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
    case 'GREEN_GEM_001'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'GREEN','../data'}];
      
      %define plot page title
      pagetitle = 'GREEN House Environmental Sensors';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Channel 11';
      plotinfo(1).plotprefix = 'ch11';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'kWh11'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'ch11.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Ch 11';
      
      plotinfo(2).caption = 'Channel 11 (diff)';
      plotinfo(2).plotprefix = 'ch11_dt';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'kWh11_DIFF'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b'};
      plotinfo(2).markers = {'.'};
      plotinfo(2).linestyles = {'-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'ch11_dt.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Ch 11 (diff)';
    
    case 'LNDB_HJA_GREENA_400_15min'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'GREEN','../data'}];
      
      %define plot page title
      pagetitle = 'GREEN House Environmental Sensors';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_OUTDOOR_N_1m_AVG','AIRTEMP_OUTDOOR_S_1m_AVG','SURTEMP_OUTDOOR _N_1m_AVG','SURTEMP_OUTDOOR_S_1m_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r','c'};
      plotinfo(1).markers = {'.','o','x','+'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
      plotinfo(2).caption = 'Relative Humidity';
      plotinfo(2).plotprefix = 'rh';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'RELHUM_OUTDOOR_N_1m_AVG','RELHUM_OUTDOOR_S_1m_AVG'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g'};
      plotinfo(2).markers = {'.','o'};
      plotinfo(2).linestyles = {'-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'rh.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Relative Humidity';
      
    case 'LNDB_HJA_GREENA_400_dly'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'GREEN','../data'}];
      
      %define plot page title
      pagetitle = 'GREEN House Environmental Sensors';
      
      %parameterize plot options
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air_dly';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'Daily_Mean_AIRTEMP_OUTDOOR_N_1m_AVG','Daily_Mean_AIRTEMP_OUTDOOR_S_1m_AVG','Daily_Mean_SURTEMP_OUTDOOR _N_1m_AVG','Daily_Mean_SURTEMP_OUTDOOR_S_1m_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r','c'};
      plotinfo(1).markers = {'.','o','x','+'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air_dly.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
    
    case 'LNDB_HJA_GREENB_401_15min'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'GREEN','../data'}];
      
      %define plot page title
      pagetitle = 'GREEN House Environmental Sensors';
      
      %parameterize plot options
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_INDOOR_FLOOR_1_AVG','AIRTEMP_INDOOR_FLOOR_2_AVG','AIRTEMP_INDOOR_ATTIC_AVG','CAVTEMP_INDOOR_N_FLOOR_1_AVG','CAVTEMP_INDOOR_S_FLOOR_1_AVG','CAVTEMP_INDOOR_N_FLOOR_2_AVG','CAVTEMP_INDOOR_S_FLOOR_2_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r','c','m','y','k'};
      plotinfo(1).markers = {'.','o','x','+','*','s','d'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
      plotinfo(2).caption = 'Relative Humidity';
      plotinfo(2).plotprefix = 'rh';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'RELHUM_INDOOR_FLOOR_1_AVG','RELHUM_INDOOR_FLOOR_2_AVG'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g'};
      plotinfo(2).markers = {'.','o'};
      plotinfo(2).linestyles = {'-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'rh.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Relative Humidity';
    
    case 'LNDB_HJA_GREENB_401_dly'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'GREEN','../data'}];
      
      %define plot page title
      pagetitle = 'GREEN House Environmental Sensors';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air_dly';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'Daily_Mean_AIRTEMP_INDOOR_FLOOR_1_AVG','Daily_Mean_AIRTEMP_INDOOR_FLOOR_2_AVG','Daily_Mean_AIRTEMP_INDOOR_ATTIC_AVG','Daily_Mean_CAVTEMP_INDOOR_N_FLOOR_1_AVG','Daily_Mean_CAVTEMP_INDOOR_S_FLOOR_1_AVG','Daily_Mean_CAVTEMP_INDOOR_N_FLOOR_2_AVG','Daily_Mean_CAVTEMP_INDOOR_S_FLOOR_2_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r','c','m','y','k'};
      plotinfo(1).markers = {'.','o','x','+','*','s','d'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air_dly.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
    case 'LNDB_HJA_GREEN_Combined'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'GREEN','../data'}];
      
      %define plot page title
      pagetitle = 'GREEN House Environmental Sensors';
      
      %parameterize plot options
      plotinfo(1).caption = 'North Side Comparisons';
      plotinfo(1).plotprefix = 'north';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'yesCAVTEMP_INDOOR_N_FLOOR_1_AVG','AIRTEMP_OUTDOOR_N_1m_AVG','SURTEMP_OUTDOOR _N_1m_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r'};
      plotinfo(1).markers = {'.','o','x'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'north.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'North Side Comparisons';
      
      plotinfo(2).caption = 'South Side Comparisons';
      plotinfo(2).plotprefix = 'south';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'yesCAVTEMP_INDOOR_S_FLOOR_1_AVG','AIRTEMP_OUTDOOR_S_1m_AVG','SURTEMP_OUTDOOR _S_1m_AVG'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g','r'};
      plotinfo(2).markers = {'.','o','x'};
      plotinfo(2).linestyles = {'-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'south.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'South Side Comparisons';
    
    case 'LNDB_GsWs01_105'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'GSWS01','../data'}];
      
      %define plot page title
      pagetitle = 'Gaging Station Watershed 1';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Water Temperature';
      plotinfo(1).plotprefix = 'wt';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'WATTEMP_MEAN_0_0_02'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'wt.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Water Temperature';
      
      plotinfo(2).caption = 'Stage Height';
      plotinfo(2).plotprefix = 'sh';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'STAGE_INST_0_0_01'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b'};
      plotinfo(2).markers = {'.'};
      plotinfo(2).linestyles = {'-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'sh.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'STAGE';
      
      plotinfo(3).caption = 'Conductivity';
      plotinfo(3).plotprefix = 'ec';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'EC_INST_0_0_01'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b'};
      plotinfo(3).markers = {'.'};
      plotinfo(3).linestyles = {'-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'ec.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'Conductivity';
      
   case 'LNDB_GsWs02_105'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'GSWS02','../data'}];
      
      %define plot page title
      pagetitle = 'Gaging Station Watershed 2';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Water Temperature';
      plotinfo(1).plotprefix = 'wt';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'WATTEMP_MEAN_0_0_02'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'wt.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Water Temperature';
      
      plotinfo(2).caption = 'Stage Height';
      plotinfo(2).plotprefix = 'sh';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'STAGE_INST_0_0_01'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b'};
      plotinfo(2).markers = {'.'};
      plotinfo(2).linestyles = {'-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'sh.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'STAGE';
      
      plotinfo(3).caption = 'Conductivity';
      plotinfo(3).plotprefix = 'ec';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'EC_INST_0_0_01'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b'};
      plotinfo(3).markers = {'.'};
      plotinfo(3).linestyles = {'-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'ec.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'Conductivity';
      
   case 'LNDB_GsWs03_105'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'GSWS03','../data'}];
      
      %define plot page title
      pagetitle = 'Gaging Station Watershed 3';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Water Temperature';
      plotinfo(1).plotprefix = 'wt';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'WATTEMP_MEAN_0_0_02'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'wt.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Water Temperature';
      
      plotinfo(2).caption = 'Stage Height';
      plotinfo(2).plotprefix = 'sh';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'STAGE_INST_0_0_01'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b'};
      plotinfo(2).markers = {'.'};
      plotinfo(2).linestyles = {'-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'sh.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'STAGE';
      
      plotinfo(3).caption = 'Conductivity';
      plotinfo(3).plotprefix = 'ec';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'EC_INST_0_0_01'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b'};
      plotinfo(3).markers = {'.'};
      plotinfo(3).linestyles = {'-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'ec.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'Conductivity';
      
  case 'LNDB_GsWs06_105'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'GSWS06','../data'}];
      
      %define plot page title
      pagetitle = 'Gaging Station Watershed 6';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Water Temperature';
      plotinfo(1).plotprefix = 'wt';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'WATTEMP_MEAN_0_0_02'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'wt.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Water Temperature';
      
      plotinfo(2).caption = 'Stage Height';
      plotinfo(2).plotprefix = 'sh';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'STAGE_INST_0_0_01'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b'};
      plotinfo(2).markers = {'.'};
      plotinfo(2).linestyles = {'-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'sh.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'STAGE';
      
      plotinfo(3).caption = 'Conductivity';
      plotinfo(3).plotprefix = 'ec';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'EC_INST_0_0_01'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b'};
      plotinfo(3).markers = {'.'};
      plotinfo(3).linestyles = {'-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'ec.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'Conductivity';
      
   case 'LNDB_GsWs07_105'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'GSWS07','../data'}];
      
      %define plot page title
      pagetitle = 'Gaging Station Watershed 7';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Water Temperature';
      plotinfo(1).plotprefix = 'wt';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'WATTEMP_MEAN_0_0_02'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'wt.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Water Temperature';
      
      plotinfo(2).caption = 'Stage Height';
      plotinfo(2).plotprefix = 'sh';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'STAGE_INST_0_0_01'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b'};
      plotinfo(2).markers = {'.'};
      plotinfo(2).linestyles = {'-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'sh.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'STAGE';
      
      plotinfo(3).caption = 'Conductivity';
      plotinfo(3).plotprefix = 'ec';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'EC_INST_0_0_01'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b'};
      plotinfo(3).markers = {'.'};
      plotinfo(3).linestyles = {'-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'ec.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'Conductivity';
      
   case 'LNDB_GsWs08_105'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'GSWS08','../data'}];
      
      %define plot page title
      pagetitle = 'Gaging Station Watershed 8';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Water Temperature';
      plotinfo(1).plotprefix = 'wt';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'WATTEMP_MEAN_0_0_02'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'wt.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Water Temperature';
      
      plotinfo(2).caption = 'Stage Height';
      plotinfo(2).plotprefix = 'sh';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'STAGE_INST_0_0_01'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b'};
      plotinfo(2).markers = {'.'};
      plotinfo(2).linestyles = {'-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'sh.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'STAGE';
      
      plotinfo(3).caption = 'Conductivity';
      plotinfo(3).plotprefix = 'ec';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'EC_INST_0_0_01'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b'};
      plotinfo(3).markers = {'.'};
      plotinfo(3).linestyles = {'-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'ec.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'Conductivity';
      
      case 'LNDB_GsWs09_105'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'GSWS09','../data'}];
      
      %define plot page title
      pagetitle = 'Gaging Station Watershed 9';
      
      plotinfo(1).caption = 'Stage Height';
      plotinfo(1).plotprefix = 'sh';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'STAGE_INST_0_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'sh.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'STAGE';
         
   case 'LNDB_GsWs10_105'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'GSWS10','../data'}];
      
      %define plot page title
      pagetitle = 'Gaging Station Watershed 10';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Water Temperature';
      plotinfo(1).plotprefix = 'wt';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'WATTEMP_MEAN_0_0_02'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'wt.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Water Temperature';
      
      plotinfo(2).caption = 'Stage Height';
      plotinfo(2).plotprefix = 'sh';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'STAGE_INST_0_0_01'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b'};
      plotinfo(2).markers = {'.'};
      plotinfo(2).linestyles = {'-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'sh.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'STAGE';
      
      plotinfo(3).caption = 'Conductivity';
      plotinfo(3).plotprefix = 'ec';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'EC_INST_0_0_01'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b'};
      plotinfo(3).markers = {'.'};
      plotinfo(3).linestyles = {'-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'ec.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'Conductivity';
      
   case 'LNDB_GsMack_105'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'GSMACK','../data'}];
      
      %define plot page title
      pagetitle = 'Gaging Station at Mack Cr.';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Water Temperature';
      plotinfo(1).plotprefix = 'wt';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'WATTEMP_MEAN_0_0_02'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'wt.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Water Temperature';
      
      plotinfo(2).caption = 'Stage Height';
      plotinfo(2).plotprefix = 'sh';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'STAGE_INST_0_0_01','FISHSTAGE_INST_0_0_01'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g'};
      plotinfo(2).markers = {'.','o'};
      plotinfo(2).linestyles = {'-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'sh.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'STAGE';
      
      plotinfo(3).caption = 'Conductivity';
      plotinfo(3).plotprefix = 'ec';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'EC_INST_0_0_01'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b'};
      plotinfo(3).markers = {'.'};
      plotinfo(3).linestyles = {'-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'ec.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'Conductivity';
      
      case 'LNDB_GsWs01_115'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'GSWS01','../data'}];
      
      %define plot page title
      pagetitle = 'Gaging Station Watershed 1';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
%       
%       plotinfo(2).caption = 'Stage Height';
%       plotinfo(2).plotprefix = 'sh';
%       plotinfo(2).fnc = 'plotdata';
%       plotinfo(2).datecol = 'Date';
%       plotinfo(2).parameters = {'STAGE'};
%       plotinfo(2).groupcol = [];
%       plotinfo(2).colors = {'b'};
%       plotinfo(2).markers = {'.'};
%       plotinfo(2).linestyles = {'-'};
%       plotinfo(2).scale = 'linear';
%       plotinfo(2).rotateaxis = 0;
%       plotinfo(2).ylim = [];
%       plotinfo(2).deblank = 0;
%       plotinfo(2).fn_xml = 'sh.xml';
%       plotinfo(2).xsl = plot_xsl;
%       plotinfo(2).navigation = 'STAGE';
%       
%       plotinfo(3).caption = 'Conductivity';
%       plotinfo(3).plotprefix = 'ec';
%       plotinfo(3).fnc = 'plotdata';
%       plotinfo(3).datecol = 'Date';
%       plotinfo(3).parameters = {'EC_AVG'};
%       plotinfo(3).groupcol = [];
%       plotinfo(3).colors = {'b'};
%       plotinfo(3).markers = {'.'};
%       plotinfo(3).linestyles = {'-'};
%       plotinfo(3).scale = 'linear';
%       plotinfo(3).rotateaxis = 0;
%       plotinfo(3).ylim = [];
%       plotinfo(3).deblank = 0;
%       plotinfo(3).fn_xml = 'ec.xml';
%       plotinfo(3).xsl = plot_xsl;
%       plotinfo(3).navigation = 'Conductivity';
%       
   case 'LNDB_GsWs02_115'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'GSWS02','../data'}];
      
      %define plot page title
      pagetitle = 'Gaging Station Watershed 2';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
%       
%       plotinfo(2).caption = 'Stage Height';
%       plotinfo(2).plotprefix = 'sh';
%       plotinfo(2).fnc = 'plotdata';
%       plotinfo(2).datecol = 'Date';
%       plotinfo(2).parameters = {'STAGE'};
%       plotinfo(2).groupcol = [];
%       plotinfo(2).colors = {'b'};
%       plotinfo(2).markers = {'.'};
%       plotinfo(2).linestyles = {'-'};
%       plotinfo(2).scale = 'linear';
%       plotinfo(2).rotateaxis = 0;
%       plotinfo(2).ylim = [];
%       plotinfo(2).deblank = 0;
%       plotinfo(2).fn_xml = 'sh.xml';
%       plotinfo(2).xsl = plot_xsl;
%       plotinfo(2).navigation = 'STAGE';
%       
%       plotinfo(3).caption = 'Conductivity';
%       plotinfo(3).plotprefix = 'ec';
%       plotinfo(3).fnc = 'plotdata';
%       plotinfo(3).datecol = 'Date';
%       plotinfo(3).parameters = {'EC_AVG'};
%       plotinfo(3).groupcol = [];
%       plotinfo(3).colors = {'b'};
%       plotinfo(3).markers = {'.'};
%       plotinfo(3).linestyles = {'-'};
%       plotinfo(3).scale = 'linear';
%       plotinfo(3).rotateaxis = 0;
%       plotinfo(3).ylim = [];
%       plotinfo(3).deblank = 0;
%       plotinfo(3).fn_xml = 'ec.xml';
%       plotinfo(3).xsl = plot_xsl;
%       plotinfo(3).navigation = 'Conductivity';
%       
   case 'LNDB_GsWs03_115'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'GSWS03','../data'}];
      
      %define plot page title
      pagetitle = 'Gaging Station Watershed 3';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
%       
%       plotinfo(2).caption = 'Stage Height';
%       plotinfo(2).plotprefix = 'sh';
%       plotinfo(2).fnc = 'plotdata';
%       plotinfo(2).datecol = 'Date';
%       plotinfo(2).parameters = {'STAGE'};
%       plotinfo(2).groupcol = [];
%       plotinfo(2).colors = {'b'};
%       plotinfo(2).markers = {'.'};
%       plotinfo(2).linestyles = {'-'};
%       plotinfo(2).scale = 'linear';
%       plotinfo(2).rotateaxis = 0;
%       plotinfo(2).ylim = [];
%       plotinfo(2).deblank = 0;
%       plotinfo(2).fn_xml = 'sh.xml';
%       plotinfo(2).xsl = plot_xsl;
%       plotinfo(2).navigation = 'STAGE';
%       
%       plotinfo(3).caption = 'Conductivity';
%       plotinfo(3).plotprefix = 'ec';
%       plotinfo(3).fnc = 'plotdata';
%       plotinfo(3).datecol = 'Date';
%       plotinfo(3).parameters = {'EC_AVG'};
%       plotinfo(3).groupcol = [];
%       plotinfo(3).colors = {'b'};
%       plotinfo(3).markers = {'.'};
%       plotinfo(3).linestyles = {'-'};
%       plotinfo(3).scale = 'linear';
%       plotinfo(3).rotateaxis = 0;
%       plotinfo(3).ylim = [];
%       plotinfo(3).deblank = 0;
%       plotinfo(3).fn_xml = 'ec.xml';
%       plotinfo(3).xsl = plot_xsl;
%       plotinfo(3).navigation = 'Conductivity';
%       
  case 'LNDB_GsWs06_115'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'GSWS06','../data'}];
      
      %define plot page title
      pagetitle = 'Gaging Station Watershed 6';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
%       
%       plotinfo(2).caption = 'Stage Height';
%       plotinfo(2).plotprefix = 'sh';
%       plotinfo(2).fnc = 'plotdata';
%       plotinfo(2).datecol = 'Date';
%       plotinfo(2).parameters = {'STAGE'};
%       plotinfo(2).groupcol = [];
%       plotinfo(2).colors = {'b'};
%       plotinfo(2).markers = {'.'};
%       plotinfo(2).linestyles = {'-'};
%       plotinfo(2).scale = 'linear';
%       plotinfo(2).rotateaxis = 0;
%       plotinfo(2).ylim = [];
%       plotinfo(2).deblank = 0;
%       plotinfo(2).fn_xml = 'sh.xml';
%       plotinfo(2).xsl = plot_xsl;
%       plotinfo(2).navigation = 'STAGE';
%       
%       plotinfo(3).caption = 'Conductivity';
%       plotinfo(3).plotprefix = 'ec';
%       plotinfo(3).fnc = 'plotdata';
%       plotinfo(3).datecol = 'Date';
%       plotinfo(3).parameters = {'EC_AVG'};
%       plotinfo(3).groupcol = [];
%       plotinfo(3).colors = {'b'};
%       plotinfo(3).markers = {'.'};
%       plotinfo(3).linestyles = {'-'};
%       plotinfo(3).scale = 'linear';
%       plotinfo(3).rotateaxis = 0;
%       plotinfo(3).ylim = [];
%       plotinfo(3).deblank = 0;
%       plotinfo(3).fn_xml = 'ec.xml';
%       plotinfo(3).xsl = plot_xsl;
%       plotinfo(3).navigation = 'Conductivity';
%       
   case 'LNDB_GsWs07_115'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'GSWS07','../data'}];
      
      %define plot page title
      pagetitle = 'Gaging Station Watershed 7';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
%       
%       plotinfo(2).caption = 'Stage Height';
%       plotinfo(2).plotprefix = 'sh';
%       plotinfo(2).fnc = 'plotdata';
%       plotinfo(2).datecol = 'Date';
%       plotinfo(2).parameters = {'STAGE'};
%       plotinfo(2).groupcol = [];
%       plotinfo(2).colors = {'b'};
%       plotinfo(2).markers = {'.'};
%       plotinfo(2).linestyles = {'-'};
%       plotinfo(2).scale = 'linear';
%       plotinfo(2).rotateaxis = 0;
%       plotinfo(2).ylim = [];
%       plotinfo(2).deblank = 0;
%       plotinfo(2).fn_xml = 'sh.xml';
%       plotinfo(2).xsl = plot_xsl;
%       plotinfo(2).navigation = 'STAGE';
%       
%       plotinfo(3).caption = 'Conductivity';
%       plotinfo(3).plotprefix = 'ec';
%       plotinfo(3).fnc = 'plotdata';
%       plotinfo(3).datecol = 'Date';
%       plotinfo(3).parameters = {'EC_AVG'};
%       plotinfo(3).groupcol = [];
%       plotinfo(3).colors = {'b'};
%       plotinfo(3).markers = {'.'};
%       plotinfo(3).linestyles = {'-'};
%       plotinfo(3).scale = 'linear';
%       plotinfo(3).rotateaxis = 0;
%       plotinfo(3).ylim = [];
%       plotinfo(3).deblank = 0;
%       plotinfo(3).fn_xml = 'ec.xml';
%       plotinfo(3).xsl = plot_xsl;
%       plotinfo(3).navigation = 'Conductivity';
%       
   case 'LNDB_GsWs08_115'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'GSWS08','../data'}];
      
      %define plot page title
      pagetitle = 'Gaging Station Watershed 8';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
%       
%       plotinfo(2).caption = 'Stage Height';
%       plotinfo(2).plotprefix = 'sh';
%       plotinfo(2).fnc = 'plotdata';
%       plotinfo(2).datecol = 'Date';
%       plotinfo(2).parameters = {'STAGE'};
%       plotinfo(2).groupcol = [];
%       plotinfo(2).colors = {'b'};
%       plotinfo(2).markers = {'.'};
%       plotinfo(2).linestyles = {'-'};
%       plotinfo(2).scale = 'linear';
%       plotinfo(2).rotateaxis = 0;
%       plotinfo(2).ylim = [];
%       plotinfo(2).deblank = 0;
%       plotinfo(2).fn_xml = 'sh.xml';
%       plotinfo(2).xsl = plot_xsl;
%       plotinfo(2).navigation = 'STAGE';
%       
%       plotinfo(3).caption = 'Conductivity';
%       plotinfo(3).plotprefix = 'ec';
%       plotinfo(3).fnc = 'plotdata';
%       plotinfo(3).datecol = 'Date';
%       plotinfo(3).parameters = {'EC_AVG'};
%       plotinfo(3).groupcol = [];
%       plotinfo(3).colors = {'b'};
%       plotinfo(3).markers = {'.'};
%       plotinfo(3).linestyles = {'-'};
%       plotinfo(3).scale = 'linear';
%       plotinfo(3).rotateaxis = 0;
%       plotinfo(3).ylim = [];
%       plotinfo(3).deblank = 0;
%       plotinfo(3).fn_xml = 'ec.xml';
%       plotinfo(3).xsl = plot_xsl;
%       plotinfo(3).navigation = 'Conductivity';
%       
   case 'LNDB_GsWs10_115'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'GSWS10','../data'}];
      
      %define plot page title
      pagetitle = 'Gaging Station Watershed 10';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
%       
%       plotinfo(2).caption = 'Stage Height';
%       plotinfo(2).plotprefix = 'sh';
%       plotinfo(2).fnc = 'plotdata';
%       plotinfo(2).datecol = 'Date';
%       plotinfo(2).parameters = {'STAGE'};
%       plotinfo(2).groupcol = [];
%       plotinfo(2).colors = {'b'};
%       plotinfo(2).markers = {'.'};
%       plotinfo(2).linestyles = {'-'};
%       plotinfo(2).scale = 'linear';
%       plotinfo(2).rotateaxis = 0;
%       plotinfo(2).ylim = [];
%       plotinfo(2).deblank = 0;
%       plotinfo(2).fn_xml = 'sh.xml';
%       plotinfo(2).xsl = plot_xsl;
%       plotinfo(2).navigation = 'STAGE';
%       
%       plotinfo(3).caption = 'Conductivity';
%       plotinfo(3).plotprefix = 'ec';
%       plotinfo(3).fnc = 'plotdata';
%       plotinfo(3).datecol = 'Date';
%       plotinfo(3).parameters = {'EC_AVG'};
%       plotinfo(3).groupcol = [];
%       plotinfo(3).colors = {'b'};
%       plotinfo(3).markers = {'.'};
%       plotinfo(3).linestyles = {'-'};
%       plotinfo(3).scale = 'linear';
%       plotinfo(3).rotateaxis = 0;
%       plotinfo(3).ylim = [];
%       plotinfo(3).deblank = 0;
%       plotinfo(3).fn_xml = 'ec.xml';
%       plotinfo(3).xsl = plot_xsl;
%       plotinfo(3).navigation = 'Conductivity';
%       
   case 'LNDB_GsMack_115'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'GSMACK','../data'}];
      
      %define plot page title
      pagetitle = 'Gaging Station at Mack Cr.';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
%       
%       plotinfo(2).caption = 'Stage Height';
%       plotinfo(2).plotprefix = 'sh';
%       plotinfo(2).fnc = 'plotdata';
%       plotinfo(2).datecol = 'Date';
%       plotinfo(2).parameters = {'STAGE','FISHSTAGE'};
%       plotinfo(2).groupcol = [];
%       plotinfo(2).colors = {'b','g'};
%       plotinfo(2).markers = {'.','o'};
%       plotinfo(2).linestyles = {'-','-'};
%       plotinfo(2).scale = 'linear';
%       plotinfo(2).rotateaxis = 0;
%       plotinfo(2).ylim = [];
%       plotinfo(2).deblank = 0;
%       plotinfo(2).fn_xml = 'sh.xml';
%       plotinfo(2).xsl = plot_xsl;
%       plotinfo(2).navigation = 'STAGE';
%       
%       plotinfo(3).caption = 'Conductivity';
%       plotinfo(3).plotprefix = 'ec';
%       plotinfo(3).fnc = 'plotdata';
%       plotinfo(3).datecol = 'Date';
%       plotinfo(3).parameters = {'EC_AVG'};
%       plotinfo(3).groupcol = [];
%       plotinfo(3).colors = {'b'};
%       plotinfo(3).markers = {'.'};
%       plotinfo(3).linestyles = {'-'};
%       plotinfo(3).scale = 'linear';
%       plotinfo(3).rotateaxis = 0;
%       plotinfo(3).ylim = [];
%       plotinfo(3).deblank = 0;
%       plotinfo(3).fn_xml = 'ec.xml';
%       plotinfo(3).xsl = plot_xsl;
%       plotinfo(3).navigation = 'Conductivity';
%       
%       plotinfo(4).caption = 'Precipitation';
%       plotinfo(4).plotprefix = 'ppt';
%       plotinfo(4).fnc = 'plotdata';
%       plotinfo(4).datecol = 'Date';
%       plotinfo(4).parameters = {'PPT_SH_INST'};
%       plotinfo(4).groupcol = [];
%       plotinfo(4).colors = {'b'};
%       plotinfo(4).markers = {'.'};
%       plotinfo(4).linestyles = {'-'};
%       plotinfo(4).scale = 'linear';
%       plotinfo(4).rotateaxis = 0;
%       plotinfo(4).ylim = [];
%       plotinfo(4).deblank = 0;
%       plotinfo(4).fn_xml = 'ppt.xml';
%       plotinfo(4).xsl = plot_xsl;
%       plotinfo(4).navigation = 'Precipitation';
      
   case 'LNDB_HJA_Hi15_207_105'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'HI15','../data'}];
      
      %define plot page title
      pagetitle = 'HI15 Met Station';
      
      plotinfo(1).caption = 'PPT Difference';
      plotinfo(1).plotprefix = 'pptdiff';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'PRECIP_DIFF_455_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'k'};
      plotinfo(1).markers = {'d'};
      plotinfo(1).linestyles = {''};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'pptdiff.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'PPT Diff';
      
      plotinfo(2).caption = 'Gage Level';
      plotinfo(2).plotprefix = 'ppt';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'PRECIP_INST_455_0_01'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b'};
      plotinfo(2).markers = {'.'};
      plotinfo(2).linestyles = {'-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'ppt.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'PPT';
      
   case 'LNDB_HJA_Hi15_207_440'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'HI15','../data'}];
      
      %define plot page title
      pagetitle = 'HI15 Met Station';
      
      plotinfo(1).caption = 'Snow Lysimeter';
      plotinfo(1).plotprefix = 'lys';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'LYS_TOT_0_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'k'};
      plotinfo(1).markers = {'d'};
      plotinfo(1).linestyles = {''};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'lys.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Snow Lysimeter';
      
   case 'LNDB_HJA_Hi15_208_440'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'HI15','../data'}];
      
      %define plot page title
      pagetitle = 'HI15 Met Station';
      
      plotinfo(1).caption = 'Max Air Temperature';
      plotinfo(1).plotprefix = 'lys';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_MAX_150_0_02'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'k'};
      plotinfo(1).markers = {'d'};
      plotinfo(1).linestyles = {''};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'lys.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Max Air Temperature';
      
   case 'LNDB_HJA_Hi15_208_115'  %3-plot GCE example
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'HI15','../data'}];
      
      %define plot page title
      pagetitle = 'HI15 Met Station';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_MEAN_150_0_02','AIRTEMP_MEAN_450_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g'};
      plotinfo(1).markers = {'.','o'};
      plotinfo(1).linestyles = {'-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
      plotinfo(2).caption = 'Relative Humidity';
      plotinfo(2).plotprefix = 'rh';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'RELHUM_MEAN_150_0_02','RELHUM_MEAN_450_0_01'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g'};
      plotinfo(2).markers = {'.','o'};
      plotinfo(2).linestyles = {'-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'rh.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Relative Humidity';
  
   case 'LNDB_HJA_LOLO_201_103'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'LOLO','../data'}];
      
      %define plot page title
      pagetitle = 'Lower Lookout';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Water and Air Temperature';
      plotinfo(1).plotprefix = 'airh2o';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIR_SN_AVG','H2O_SN_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g'};
      plotinfo(1).markers = {'.','o'};
      plotinfo(1).linestyles = {'-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'airh2o.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air and H2O';
      
   case 'LNDB_HJA_LOLO_201_107'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'LOLO','../data'}];
      
      %define plot page title
      pagetitle = 'Lower Lookout';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Water and Air Temperature';
      plotinfo(1).plotprefix = 'airh2o';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIR_SN_AVG','H2O_SN_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g'};
      plotinfo(1).markers = {'.','o'};
      plotinfo(1).linestyles = {'-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'airh2o.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air and H2O';
      
   case 'LNDB_HJA_LOMA_203_103'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'LOMA','../data'}];
      
      %define plot page title
      pagetitle = 'Lower Lookout/Mack';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Water and Air Temperature';
      plotinfo(1).plotprefix = 'airh2o';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIR_SN_AVG','H2O_SN_MACK_AVG','H2O_SN_LOOK_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','k'};
      plotinfo(1).markers = {'.','o','+'};
      plotinfo(1).linestyles = {'-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'airh2o.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air and H2O';
      
   case 'LNDB_HJA_LOMA_203_107'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'LOMA','../data'}];
      
      %define plot page title
      pagetitle = 'Lower Lookout/Mack';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Water and Air Temperature';
      plotinfo(1).plotprefix = 'airh2o';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIR_SN_AVG','H2O_SN_MACK_AVG','H2O_SN_LOOK_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','k'};
      plotinfo(1).markers = {'.','o','+'};
      plotinfo(1).linestyles = {'-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'airh2o.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air and H2O';
      
   case 'LNDB_HJA_LOUP_204_103'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'LOUP','../data'}];
      
      %define plot page title
      pagetitle = 'Lower Upper';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Water and Air Temperature';
      plotinfo(1).plotprefix = 'airh2o';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIR_SN_AVG','H2O_SN_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g'};
      plotinfo(1).markers = {'.','o'};
      plotinfo(1).linestyles = {'-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'airh2o.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air and H2O';
      
   case 'LNDB_HJA_LOUP_204_107'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'LOUP','../data'}];
      
      %define plot page title
      pagetitle = 'Lower Upper';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Water and Air Temperature';
      plotinfo(1).plotprefix = 'airh2o';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIR_SN_AVG','H2O_SN_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g'};
      plotinfo(1).markers = {'.','o'};
      plotinfo(1).linestyles = {'-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'airh2o.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air and H2O';
      
   case 'LNDB_HJA_MCUP_205_103'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'MCUP','../data'}];
      
      %define plot page title
      pagetitle = 'McRae Upper';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Water and Air Temperature';
      plotinfo(1).plotprefix = 'airh2o';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIR_SN_AVG','H2O_SN_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g'};
      plotinfo(1).markers = {'.','o'};
      plotinfo(1).linestyles = {'-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'airh2o.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air and H2O';
      
  case 'LNDB_HJA_MCUP_205_107'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'MCUP','../data'}];
      
      %define plot page title
      pagetitle = 'McRae Upper';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Water and Air Temperature';
      plotinfo(1).plotprefix = 'airh2o';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIR_SN_AVG','H2O_SN_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g'};
      plotinfo(1).markers = {'.','o'};
      plotinfo(1).linestyles = {'-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'airh2o.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air and H2O';
      
   case 'LNDB_HJA_PHRSC'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'PHRSC','../data'}];
      
      %define plot page title
      pagetitle = 'Primet Historic Radiation Shield Comparison';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'ta';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'Cotton_Avg','Gill_AF_Avg','Gill_Lg_Avg','Gill_Sh_Avg','HJA_Lg_Avg','HJA_Sh_Avg','RMY_ASP_Avg'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r','c','m','y','k'};
      plotinfo(1).markers = {'.','o','x','+','*','s','d'};
      plotinfo(1).linestyles = {'-','-','-','-','-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'ta.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
      plotinfo(2).caption = 'Radation';
      plotinfo(2).plotprefix = 'rad';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'CM3_Up_Avg','CM3_Dn_Avg'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g'};
      plotinfo(2).markers = {'.','o'};
      plotinfo(2).linestyles = {'-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'rad.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Radiation';
      
      plotinfo(3).caption = 'Wind Speed and Direction';
      plotinfo(3).plotprefix = 'wind';
      plotinfo(3).fnc = 'plotwind';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'WINDSP_AVG','WINDDIR_AVG'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'',''};
      plotinfo(3).markers = {'',''};
      plotinfo(3).linestyles = {'',''};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'wind.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'Wind';
      
  case 'LNDB_HJA_PHRSC_2'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'PHRSC','../data'}];
      
      %define plot page title
      pagetitle = 'Primet Historic Radiation Shield Comparison';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Maximum Air Temperature';
      plotinfo(1).plotprefix = 'ta';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'Cotton_Max','Gill_AF_Max','Gill_Lg_Max','Gill_Sh_Max','HJA_Lg_Max','HJA_Sh_Max','RMY_ASP_Max'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r','c','m','y','k'};
      plotinfo(1).markers = {'.','o','x','+','*','s','d'};
      plotinfo(1).linestyles = {'-','-','-','-','-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'tmax.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Maximum Air Temperature';
      
      plotinfo(2).caption = 'Maximum Radation';
      plotinfo(2).plotprefix = 'rad';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'CM3_Up_Max','CM3_Dn_Max'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g'};
      plotinfo(2).markers = {'.','o'};
      plotinfo(2).linestyles = {'-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'radmax.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Maximum Radiation';
      
  case 'LNDB_HJA_PriMet_226_105_arch1'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %define plot page title
      pagetitle = 'Primary Met Station';
           
      plotinfo(1).caption = 'Snow Moisture';
      plotinfo(1).plotprefix = 'swe';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'SWE_INST_0_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'swe.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'SWE';
      
      plotinfo(2).caption = 'Snow Depth';
      plotinfo(2).plotprefix = 'snodep';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'SNODEP_INST_0_0_01','SNODEP_MED_0_0_01'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g'};
      plotinfo(2).markers = {'.','o'};
      plotinfo(2).linestyles = {'-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'snodep.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Snow Depth';
      
      plotinfo(3).caption = 'Preciptiation';
      plotinfo(3).plotprefix = 'ppt_tb';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'PRECIP_TOT_100_0_01'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b'};
      plotinfo(3).markers = {'.'};
      plotinfo(3).linestyles = {'-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'ppt_tb.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'Precipitation';
      
  case 'LNDB_HJA_PriMet_226_105'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %define plot page title
      pagetitle = 'Primary Met Station';
           
      plotinfo(1).caption = 'Snow Moisture';
      plotinfo(1).plotprefix = 'swe';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'SWE_INST'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'swe.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'SWE';
      
      plotinfo(2).caption = 'Snow Depth';
      plotinfo(2).plotprefix = 'snodep';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'SNODEP_MED'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b'};
      plotinfo(2).markers = {'.'};
      plotinfo(2).linestyles = {'-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'snodep.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Snow Depth';
      
  case 'LNDB_HJA_PriMet_226_a_5min'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %define plot page title
      pagetitle = 'Primary Met Station';
      
      plotinfo(1).caption = 'Snow Depth'; 
      plotinfo(1).plotprefix = 'snodep';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date'  ;
      plotinfo(1).parameters = {'SNODEP_MED_0_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'snodep.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Snow Depth';
      
      plotinfo(2).caption = 'Air Temperature';
      plotinfo(2).plotprefix = 'air';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'AIRTEMP_MEAN_150_0_04','AIRTEMP_MEAN_250_0_03','AIRTEMP_MEAN_350_0_02','AIRTEMP_MEAN_450_0_01'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g','r','c'};
      plotinfo(2).markers = {'.','o','x','+'};
      plotinfo(2).linestyles = {'-','-','-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [-20 40];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'air.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Air Temperature';
      
      plotinfo(3).caption = 'Relative Humidity';
      plotinfo(3).plotprefix = 'rh';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'RELHUM_MEAN_150_0_04','RELHUM_MEAN_450_0_01'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b','g'};
      plotinfo(3).markers = {'.','o'};
      plotinfo(3).linestyles = {'-','-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'rh.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'RH';
	  
	case 'LNDB_HJA_PriMet_226_a_hrly'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %define plot page title
      pagetitle = 'Primary Met Station';
      
      plotinfo(1).caption = 'Snow Depth';
      plotinfo(1).plotprefix = 'snodep';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date'  ;
      plotinfo(1).parameters = {'Hourly_Mean_SNODEP_MED_0_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g'};
      plotinfo(1).markers = {'.','o'};
      plotinfo(1).linestyles = {'-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'snodep.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Snow Depth';
	  
	case 'LNDB_HJA_PriMet_226_a_dly'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %define plot page title
      pagetitle = 'Primary Met Station';
      
      plotinfo(1).caption = 'Snow Depth';
      plotinfo(1).plotprefix = 'snodep';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date'  ;
      plotinfo(1).parameters = {'Daily_Mean_SNODEP_MED_0_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g'};
      plotinfo(1).markers = {'.','o'};
      plotinfo(1).linestyles = {'-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'snodep.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Snow Depth';
      
      plotinfo(2).caption = 'Air Temperature';
      plotinfo(2).plotprefix = 'air';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'Daily_Mean_AIRTEMP_MEAN_150_0_04','Daily_Mean_AIRTEMP_MEAN_250_0_03','Daily_Mean_AIRTEMP_MEAN_350_0_02','Daily_Mean_AIRTEMP_MEAN_450_0_01'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g','r','c'};
      plotinfo(2).markers = {'.','o','x','+'};
      plotinfo(2).linestyles = {'-','-','-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [-20 40];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'air.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Air Temperature';
      
    case 'LNDB_HJA_PriMet_230_a_5min'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %define plot page title
      pagetitle = 'Primary Met Station';
      
      plotinfo(1).caption = 'Snow Water Equivalent';
      plotinfo(1).plotprefix = 'swe';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'SWE_INST_0_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'swe.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'SWE';
      
      plotinfo(2).caption = 'Precipitation';
      plotinfo(2).plotprefix = 'ppt';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'PRECIP_TOT_100_0_01'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b'};
      plotinfo(2).markers = {'o'};
      plotinfo(2).linestyles = {''};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'ppt.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Precipitation';
      
      plotinfo(3).caption = 'Downwelling Solar Radiation';
      plotinfo(3).plotprefix = 'rad';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'SOLAR_MEAN_100_0_01'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b'};
      plotinfo(3).markers = {'.'};
      plotinfo(3).linestyles = {'-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'rad.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'Radiation';
      
      plotinfo(4).caption = 'Soil Temperature';
      plotinfo(4).plotprefix = 'soil';
      plotinfo(4).fnc = 'plotdata';
      plotinfo(4).datecol = 'Date';
      plotinfo(4).parameters = {'SOILTEMP_MEAN_0_10_01','SOILTEMP_MEAN_0_20_02','SOILTEMP_MEAN_0_50_03','SOILTEMP_MEAN_0_100_04'};
      plotinfo(4).groupcol = [];
      plotinfo(4).colors = {'b','g','r','c'};
      plotinfo(4).markers = {'.','o','x','+'};
      plotinfo(4).linestyles = {'-','-','-','-'};
      plotinfo(4).scale = 'linear';
      plotinfo(4).rotateaxis = 0;
      plotinfo(4).ylim = [-20 40];
      plotinfo(4).deblank = 0;
      plotinfo(4).fn_xml = 'soil.xml';
      plotinfo(4).xsl = plot_xsl;
      plotinfo(4).navigation = 'Soil Temperature';
      
      plotinfo(5).caption = 'Barometric Pressure';
      plotinfo(5).plotprefix = 'bp';
      plotinfo(5).fnc = 'plotdata';
      plotinfo(5).datecol = 'Date';
      plotinfo(5).parameters = {'ATMPRESS_INST_0_0_01'};
      plotinfo(5).groupcol = [];
      plotinfo(5).colors = {'b'};
      plotinfo(5).markers = {'.'};
      plotinfo(5).linestyles = {'-'};
      plotinfo(5).scale = 'linear';
      plotinfo(5).rotateaxis = 0;
      plotinfo(5).ylim = [];
      plotinfo(5).deblank = 0;
      plotinfo(5).fn_xml = 'bp.xml';
      plotinfo(5).xsl = plot_xsl;
      plotinfo(5).navigation = 'Pressure';

      plotinfo(6).caption = 'Soil Water Content';
      plotinfo(6).plotprefix = 'wcr';
      plotinfo(6).fnc = 'plotdata';
      plotinfo(6).datecol = 'Date';
      plotinfo(6).parameters = {'SOILWC_MEAN_0_10_01','SOILWC_MEAN_0_20_02','SOILWC_MEAN_0_50_03','SOILWC_MEAN_0_100_04'};
      plotinfo(6).groupcol = [];
      plotinfo(6).colors = {'b','g','r','c'};
      plotinfo(6).markers = {'.','o','x','+'};
      plotinfo(6).linestyles = {'-'};
      plotinfo(6).scale = 'linear';
      plotinfo(6).rotateaxis = 0;
      plotinfo(6).ylim = [];
      plotinfo(6).deblank = 0;
      plotinfo(6).fn_xml = 'wcr.xml';
      plotinfo(6).xsl = plot_xsl;
      plotinfo(6).navigation = 'Soil Moisture';
      
  case 'LNDB_HJA_PriMet_230_a_hrly'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %define plot page title
      pagetitle = 'Primary Met Station';
      
      plotinfo(1).caption = 'Snow Water Equivalent';
      plotinfo(1).plotprefix = 'swe';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'Hourly_Mean_SWE_INST_0_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'swe.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'SWE';
      
  case 'LNDB_HJA_PriMet_230_a_dly'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %define plot page title
      pagetitle = 'Primary Met Station';
      
      plotinfo(1).caption = 'Snow Water Equivalent';
      plotinfo(1).plotprefix = 'swe';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'Daily_Mean_SWE_INST_0_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'swe.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'SWE';
      
      plotinfo(2).caption = 'Precipitation';
      plotinfo(2).plotprefix = 'ppt';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'Daily_Total_PRECIP_TOT_100_0_01'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b'};
      plotinfo(2).markers = {'o'};
      plotinfo(2).linestyles = {''};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'ppt.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Precipitation';
      
  case 'LNDB_HJA_PriMet_115_arch1'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %define plot page title
      pagetitle = 'Primary Met Station';
      
      %parameterize plot options
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_MEAN_150_0_04','AIRTEMP_MEAN_250_0_03','AIRTEMP_MEAN_350_0_02','AIRTEMP_MEAN_450_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r','c'};
      plotinfo(1).markers = {'.','o','x','+'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [-20 40];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
  %parameterize plot options
      plotinfo(2).caption = 'Shortwave Radiation';
      plotinfo(2).plotprefix = 'sw';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'SOLAR_MEAN_100_0_01'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b'};
      plotinfo(2).markers = {'.'};
      plotinfo(2).linestyles = {'-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'sw.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Shortwave Radiation';
      
      %parameterize plot options
      plotinfo(3).caption = 'Barometric Pressure';
      plotinfo(3).plotprefix = 'bp';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'ATMPRESS_INST_0_0_01'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b'};
      plotinfo(3).markers = {'.'};
      plotinfo(3).linestyles = {'-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'bp.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'Barometric Pressure';
      
  case 'LNDB_HJA_PriMet_226_115_a'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %define plot page title
      pagetitle = 'Primary Met Station';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_MEAN_150_0_04','AIRTEMP_MEAN_250_0_03','AIRTEMP_MEAN_350_0_02','AIRTEMP_MEAN_450_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r','c'};
      plotinfo(1).markers = {'.','o','x','+'};
      plotinfo(1).linestyles = {'-','-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [-20 40];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
 case 'LNDB_HJA_PriMet_230_115'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %define plot page title
      pagetitle = 'Primary Met Station';
      
      plotinfo(1).caption = 'Barometric Pressure';
      plotinfo(1).plotprefix = 'bp';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'BP_INST'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'bp.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Barometric Pressure';
      
      plotinfo(2).caption = 'Incoming Solar Radiation';
      plotinfo(2).plotprefix = 'k_down';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'SOLAR_AVG'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b'};
      plotinfo(2).markers = {'.'};
      plotinfo(2).linestyles = {'-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'k_down.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Incoming Solar Radiation';
      
  case 'LNDB_HJA_PriMet_226_160_a'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %define plot page title
      pagetitle = 'Primary Met Station';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Dew Point';
      plotinfo(1).plotprefix = 'dewpt';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'DEWPT_150_AVG','DEWPT_450_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g'};
      plotinfo(1).markers = {'.','o'};
      plotinfo(1).linestyles = {'-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'dewpt.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Dew Point';

      plotinfo(2).caption = 'Relative Humidity';
      plotinfo(2).plotprefix = 'rh';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'RH_150_AVG','RH_450_AVG'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g'};
      plotinfo(2).markers = {'.','o'};
      plotinfo(2).linestyles = {'-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'rh.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'RH';
      
      plotinfo(3).caption = 'Vapor Pressure Deficit';
      plotinfo(3).plotprefix = 'vpd';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'VPD_150_AVG','VPD_450_AVG'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b','g'};
      plotinfo(3).markers = {'.','o'};
      plotinfo(3).linestyles = {'-','-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'vpd.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'VPD';
      
  case 'LNDB_HJA_PriMet_226_160_arch1'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %define plot page title
      pagetitle = 'Primary Met Station';

      plotinfo(1).caption = 'Relative Humidity';
      plotinfo(1).plotprefix = 'rh';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'RELHUM_MEAN_0_150_04','RELHUM_MEAN_0_450_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g'};
      plotinfo(1).markers = {'.','o'};
      plotinfo(1).linestyles = {'-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'rh.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'RH';
      
      plotinfo(2).caption = 'Soil Temmperature';
      plotinfo(2).plotprefix = 'soil';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'SOILTEMP_MEAN_0_10_04','SOILTEMP_MEAN_0_20_03','SOILTEMP_MEAN_0_50_02','SOILTEMP_MEAN_0_100_01'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g','r','c'};
      plotinfo(2).markers = {'.','o','x','+'};
      plotinfo(2).linestyles = {'-','-','-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'soil.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Soil Temperature';
      
      case 'LNDB_HJA_PriMet_230_160'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %define plot page title
      pagetitle = 'Primary Met Station';
      
      plotinfo(1).caption = 'Soil Temperature';
      plotinfo(1).plotprefix = 'ts';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'SOIL_10_AVG','SOIL_20_AVG','SOIL_50_AVG','SOIL_100_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r','c'};
      plotinfo(1).markers = {'.','o','x','+'};
      plotinfo(1).linestyles = {'-','-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'ts.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Soil Temperature';
      
      plotinfo(2).caption = 'Soil Moisture';
      plotinfo(2).plotprefix = 'soilm';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'WCR_10_AVG','WCR_20_AVG','WCR_50_AVG','WCR_100_AVG'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g','r','c'};
      plotinfo(2).markers = {'.','o','x','+'};
      plotinfo(2).linestyles = {'-','-','-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'soilm.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Soil Moisture';
      
  case 'LNDB_HJA_PriMet_440'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %define plot page title
      pagetitle = 'Primary Met Station';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIR_150_AVG','AIR_250_AVG','AIR_350_AVG','AIR_450_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r','c'};
      plotinfo(1).markers = {'.','o','x','+'};
      plotinfo(1).linestyles = {'-','-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [-20 40];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
      case 'LNDB_HJA_PriMet_230_440'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %define plot page title
      pagetitle = 'Primary Met Station';
      
      plotinfo(1).caption = 'Soil Temperature';
      plotinfo(1).plotprefix = 'ts';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'SOIL_10_AVG','SOIL_20_AVG','SOIL_50_AVG','SOIL_100_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r','c'};
      plotinfo(1).markers = {'.','o','x','+'};
      plotinfo(1).linestyles = {'-','-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'ts.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Soil Temperature';
      
      plotinfo(2).caption = 'Soil Moisture';
      plotinfo(2).plotprefix = 'wcr';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'WCR_10_AVG','WCR_20_AVG','WCR_50_AVG','WCR_100_AVG'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g','r','c'};
      plotinfo(2).markers = {'.','o','x','+'};
      plotinfo(2).linestyles = {'-','-','-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'wcr.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Soil Moisture';
      
      plotinfo(3).caption = 'Precipitation';
      plotinfo(3).plotprefix = 'ppt';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'TB_PRECIP_TOT_in'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b'};
      plotinfo(3).markers = {'o'};
      plotinfo(3).linestyles = {''};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'ppt.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'Precipitation';
      
  case 'LNDB_HJA_PriMet_229_a_5min'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %define plot page title
      pagetitle = 'Primary Met Station';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_MEAN_150_0_06','AIRTEMP_MEAN_250_0_07','AIRTEMP_MEAN_350_0_08','AIRTEMP_MEAN_450_0_09'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r','c'};
      plotinfo(1).markers = {'.','o','x','+'};
      plotinfo(1).linestyles = {'-','-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
       
      plotinfo(2).caption = 'Total Radiation';
      plotinfo(2).plotprefix = 'radtot';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'RAD_OUT_AVG','RAD_IN_AVG'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g'};
      plotinfo(2).markers = {'.','o'};
      plotinfo(2).linestyles = {'-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'radtot.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Radiation Totals';
       
      plotinfo(3).caption = 'Longwave Radiation';
      plotinfo(3).plotprefix = 'IR01';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'LW_OUT_MEAN_600_0_02','LW_IN_MEAN_600_0_02'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b','g'};
      plotinfo(3).markers = {'.','o'};
      plotinfo(3).linestyles = {'-','-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'IR01.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'IR01';
       
      plotinfo(4).caption = 'Net Radiation';
      plotinfo(4).plotprefix = 'netrad';
      plotinfo(4).fnc = 'plotdata';
      plotinfo(4).datecol = 'Date';
      plotinfo(4).parameters = {'NR_TOT_MEAN_600_0_02'};
      plotinfo(4).groupcol = [];
      plotinfo(4).colors = {'b'};
      plotinfo(4).markers = {'.'};
      plotinfo(4).linestyles = {'-'};
      plotinfo(4).scale = 'linear';
      plotinfo(4).rotateaxis = 0;
      plotinfo(4).ylim = [];
      plotinfo(4).deblank = 0;
      plotinfo(4).fn_xml = 'netrad.xml';
      plotinfo(4).xsl = plot_xsl;
      plotinfo(4).navigation = 'Net Radiation';
       
      plotinfo(5).caption = 'Shortwave Radiation';
      plotinfo(5).plotprefix = 'SR01';
      plotinfo(5).fnc = 'plotdata';
      plotinfo(5).datecol = 'Date';
      plotinfo(5).parameters = {'SW_OUT_MEAN_600_0_02','SW_IN_MEAN_600_0_02'};
      plotinfo(5).groupcol = [];
      plotinfo(5).colors = {'b','g'};
      plotinfo(5).markers = {'.','o'};
      plotinfo(5).linestyles = {'-','-'};
      plotinfo(5).scale = 'linear';
      plotinfo(5).rotateaxis = 0;
      plotinfo(5).ylim = [];
      plotinfo(5).deblank = 0;
      plotinfo(5).fn_xml = 'SR01.xml';
      plotinfo(5).xsl = plot_xsl;
      plotinfo(5).navigation = 'SR01';
      
  case 'LNDB_HJA_PriMet_229_a_hrly'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %define plot page title
      pagetitle = 'Primary Met Station';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'Hourly_Mean_AIRTEMP_MEAN_150_0_06','Hourly_Mean_AIRTEMP_MEAN_250_0_07','Hourly_Mean_AIRTEMP_MEAN_350_0_08','Hourly_Mean_AIRTEMP_MEAN_450_0_09'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r','c'};
      plotinfo(1).markers = {'.','o','x','+'};
      plotinfo(1).linestyles = {'-','-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
       
      plotinfo(2).caption = 'Total Radiation';
      plotinfo(2).plotprefix = 'radtot';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'Hourly_Mean_RAD_OUT_AVG','Hourly_Mean_RAD_IN_AVG'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g'};
      plotinfo(2).markers = {'.','o'};
      plotinfo(2).linestyles = {'-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'radtot.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Radiation Totals';
       
      plotinfo(3).caption = 'Longwave Radiation';
      plotinfo(3).plotprefix = 'IR01';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'Hourly_Mean_LW_OUT_MEAN_600_0_02','Hourly_Mean_LW_IN_MEAN_600_0_02'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b','g'};
      plotinfo(3).markers = {'.','o'};
      plotinfo(3).linestyles = {'-','-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'IR01.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'IR01';
       
      plotinfo(4).caption = 'Net Radiation';
      plotinfo(4).plotprefix = 'netrad';
      plotinfo(4).fnc = 'plotdata';
      plotinfo(4).datecol = 'Date';
      plotinfo(4).parameters = {'Hourly_Mean_NR_TOT_MEAN_600_0_02'};
      plotinfo(4).groupcol = [];
      plotinfo(4).colors = {'b'};
      plotinfo(4).markers = {'.'};
      plotinfo(4).linestyles = {'-'};
      plotinfo(4).scale = 'linear';
      plotinfo(4).rotateaxis = 0;
      plotinfo(4).ylim = [];
      plotinfo(4).deblank = 0;
      plotinfo(4).fn_xml = 'netrad.xml';
      plotinfo(4).xsl = plot_xsl;
      plotinfo(4).navigation = 'Net Radiation';
       
      plotinfo(5).caption = 'Shortwave Radiation';
      plotinfo(5).plotprefix = 'SR01';
      plotinfo(5).fnc = 'plotdata';
      plotinfo(5).datecol = 'Date';
      plotinfo(5).parameters = {'Hourly_Mean_SW_OUT_MEAN_600_0_02','Hourly_Mean_SW_IN_MEAN_600_0_02'};
      plotinfo(5).groupcol = [];
      plotinfo(5).colors = {'b','g'};
      plotinfo(5).markers = {'.','o'};
      plotinfo(5).linestyles = {'-','-'};
      plotinfo(5).scale = 'linear';
      plotinfo(5).rotateaxis = 0;
      plotinfo(5).ylim = [];
      plotinfo(5).deblank = 0;
      plotinfo(5).fn_xml = 'SR01.xml';
      plotinfo(5).xsl = plot_xsl;
      plotinfo(5).navigation = 'SR01';
      
  case 'LNDB_HJA_PriMet_229_a_dly'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %define plot page title
      pagetitle = 'Primary Met Station';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'Daily_Mean_AIRTEMP_MEAN_150_0_06','Daily_Mean_AIRTEMP_MEAN_250_0_07','Daily_Mean_AIRTEMP_MEAN_350_0_08','Daily_Mean_AIRTEMP_MEAN_450_0_09'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r','c'};
      plotinfo(1).markers = {'.','o','x','+'};
      plotinfo(1).linestyles = {'-','-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
  case 'LNDB_HJA_PriMet_229_b_5min'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %define plot page title
      pagetitle = 'Primary Met Station';
      
      plotinfo(1).caption = 'Wind Speed and Direction';
      plotinfo(1).plotprefix = 'wind';
      plotinfo(1).fnc = 'plotwind';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'WSPD_SNC_MEAN_1000_0_02','WDIR_SNC_MEAN_1000_0_02'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'',''};
      plotinfo(1).markers = {'',''};
      plotinfo(1).linestyles = {'',''};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'wind.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Wind';
      
%       plotinfo(2).caption = 'Air Temperature (sonic)';
%       plotinfo(2).plotprefix = 'tsnc';
%       plotinfo(2).fnc = 'plotdata';
%       plotinfo(2).datecol = 'Date';
%       plotinfo(2).parameters = {'WAIR_SNC_MEAN_1000_0_02'};
%       plotinfo(2).groupcol = [];
%       plotinfo(2).colors = {'b'};
%       plotinfo(2).markers = {'.'};
%       plotinfo(2).linestyles = {'-'};
%       plotinfo(2).scale = 'linear';
%       plotinfo(2).rotateaxis = 0;
%       plotinfo(2).ylim = [];
%       plotinfo(2).deblank = 0;
%       plotinfo(2).fn_xml = 'tsnc.xml';
%       plotinfo(2).xsl = plot_xsl;
%       plotinfo(2).navigation = 'Temperature (sonic)';
      
  case 'LNDB_HJA_PriMet_229_b_hrly'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %define plot page title
      pagetitle = 'Primary Met Station';
      
      plotinfo(1).caption = 'Wind Speed and Direction';
      plotinfo(1).plotprefix = 'wind';
      plotinfo(1).fnc = 'plotwind';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'Hourly_Mean_WSPD_SNC_MEAN_1000_0_02','Hourly_VecAvg_WDIR_SNC_MEAN_1000_0_02'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'',''};
      plotinfo(1).markers = {'',''};
      plotinfo(1).linestyles = {'',''};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'wind.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Wind';
      
%       plotinfo(2).caption = 'Air Temperature (sonic)';
%       plotinfo(2).plotprefix = 'tsnc';
%       plotinfo(2).fnc = 'plotdata';
%       plotinfo(2).datecol = 'Date';
%       plotinfo(2).parameters = {'Hourly_Mean_WAIR_SNC_MEAN_1000_0_02'};
%       plotinfo(2).groupcol = [];
%       plotinfo(2).colors = {'b'};
%       plotinfo(2).markers = {'.'};
%       plotinfo(2).linestyles = {'-'};
%       plotinfo(2).scale = 'linear';
%       plotinfo(2).rotateaxis = 0;
%       plotinfo(2).ylim = [];
%       plotinfo(2).deblank = 0;
%       plotinfo(2).fn_xml = 'tsnc.xml';
%       plotinfo(2).xsl = plot_xsl;
%       plotinfo(2).navigation = 'Temperature (sonic)';
      
  case 'LNDB_HJA_PriMet_229_b_dly'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %define plot page title
      pagetitle = 'Primary Met Station';
      
      plotinfo(1).caption = 'Wind Speed and Direction';
      plotinfo(1).plotprefix = 'wind';
      plotinfo(1).fnc = 'plotwind';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'Daily_Mean_WSPD_SNC_MEAN_1000_0_02','Daily_VecAvg_WDIR_SNC_MEAN_1000_0_02'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'',''};
      plotinfo(1).markers = {'',''};
      plotinfo(1).linestyles = {'',''};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'wind.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Wind';
      
%       plotinfo(2).caption = 'Air Temperature (sonic)';
%       plotinfo(2).plotprefix = 'tsnc';
%       plotinfo(2).fnc = 'plotdata';
%       plotinfo(2).datecol = 'Date';
%       plotinfo(2).parameters = {'Daily_Mean_AIR_SNC_MEAN_1000_0_02'};
%       plotinfo(2).groupcol = [];
%       plotinfo(2).colors = {'b'};
%       plotinfo(2).markers = {'.'};
%       plotinfo(2).linestyles = {'-'};
%       plotinfo(2).scale = 'linear';
%       plotinfo(2).rotateaxis = 0;
%       plotinfo(2).ylim = [];
%       plotinfo(2).deblank = 0;
%       plotinfo(2).fn_xml = 'tsnc.xml';
%       plotinfo(2).xsl = plot_xsl;
%       plotinfo(2).navigation = 'Temperature (sonic)';
      
case 'LNDB_HJA_RS02_90_5min'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 02','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 02';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_MEAN_225_0_02','AIRTEMP_MEAN_225_0_03'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r'};
      plotinfo(1).markers = {'.','o','x'};
      plotinfo(1).linestyles = {'-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
      plotinfo(2).caption = 'Soil Temperature';
      plotinfo(2).plotprefix = 'soilt';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'SOILTEMP_MEAN_0_10_01','SOILTEMP_MEAN_0_20_02','SOILTEMP_MEAN_0_30_03'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g','r'};
      plotinfo(2).markers = {'.','o','x'};
      plotinfo(2).linestyles = {'-','-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'soilt.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Soil Temperature';
      
      plotinfo(3).caption = 'Battery Supply Voltage';
      plotinfo(3).plotprefix = 'batt';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'BATTERY_AVG'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b'};
      plotinfo(3).markers = {'.'};
      plotinfo(3).linestyles = {'-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'batt.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'Battery Supply Voltage';
      
  case 'LNDB_HJA_RS02_90_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 02','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 02';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'Hourly_Mean_AIRTEMP_MEAN_225_0_02','Hourly_Mean_AIRTEMP_MEAN_225_0_03'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r'};
      plotinfo(1).markers = {'.','o','x'};
      plotinfo(1).linestyles = {'-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
      plotinfo(2).caption = 'Soil Temperature';
      plotinfo(2).plotprefix = 'soilt';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'Hourly_Mean_SOILTEMP_MEAN_0_10_01','Hourly_Mean_SOILTEMP_MEAN_0_20_02','Hourly_Mean_SOILTEMP_MEAN_0_30_03'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g','r'};
      plotinfo(2).markers = {'.','o','x'};
      plotinfo(2).linestyles = {'-','-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'soilt.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Soil Temperature';
      
  case 'LNDB_HJA_RS02_90_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 02','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 02';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air_dly';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'Daily_Mean_AIRTEMP_MEAN_225_0_02','Daily_Mean_AIRTEMP_MEAN_225_0_03'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r'};
      plotinfo(1).markers = {'.','o','x'};
      plotinfo(1).linestyles = {'-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air_dly.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
      plotinfo(2).caption = 'Soil Temperature';
      plotinfo(2).plotprefix = 'soilt';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'Daily_Mean_SOILTEMP_MEAN_0_10_01','Daily_Mean_SOILTEMP_MEAN_0_20_02','Daily_Mean_SOILTEMP_MEAN_0_30_03'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g','r'};
      plotinfo(2).markers = {'.','o','x'};
      plotinfo(2).linestyles = {'-','-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'soilt.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Soil Temperature';

case 'LNDB_HJA_RS04_91_5min'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 04','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 04';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_MEAN_225_0_02','AIRTEMP_MEAN_225_0_03'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g'};
      plotinfo(1).markers = {'.','o'};
      plotinfo(1).linestyles = {'-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
      plotinfo(2).caption = 'Soil Temperature';
      plotinfo(2).plotprefix = 'soilt';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'SOILTEMP_MEAN_0_10_01','SOILTEMP_MEAN_0_20_02','SOILTEMP_MEAN_0_30_03'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g','r'};
      plotinfo(2).markers = {'.','o','x'};
      plotinfo(2).linestyles = {'-','-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'soilt.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Soil Temperature';
      
      plotinfo(3).caption = 'Battery Supply Voltage';
      plotinfo(3).plotprefix = 'batt';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'BATTERY_AVG'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b'};
      plotinfo(3).markers = {'.'};
      plotinfo(3).linestyles = {'-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'batt.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'Battery Supply Voltage';
      
  case 'LNDB_HJA_RS04_91_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 04','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 04';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'Hourly_Mean_AIRTEMP_MEAN_225_0_02','Hourly_Mean_AIRTEMP_MEAN_225_0_03'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g'};
      plotinfo(1).markers = {'.','o'};
      plotinfo(1).linestyles = {'-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
      plotinfo(2).caption = 'Soil Temperature';
      plotinfo(2).plotprefix = 'soilt';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'Hourly_Mean_SOILTEMP_MEAN_0_10_01','Hourly_Mean_SOILTEMP_MEAN_0_20_02','Hourly_Mean_SOILTEMP_MEAN_0_30_03'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g','r'};
      plotinfo(2).markers = {'.','o','x'};
      plotinfo(2).linestyles = {'-','-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'soilt.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Soil Temperature';
      
  case 'LNDB_HJA_RS04_91_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 04','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 04';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air_dly';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'Daily_Mean_AIRTEMP_MEAN_225_0_02','Daily_Mean_AIRTEMP_MEAN_225_0_03'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g'};
      plotinfo(1).markers = {'.','o'};
      plotinfo(1).linestyles = {'-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air_dly.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
      plotinfo(2).caption = 'Soil Temperature';
      plotinfo(2).plotprefix = 'soilt';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'Daily_Mean_SOILTEMP_MEAN_0_10_01','Daily_Mean_SOILTEMP_MEAN_0_20_02','Daily_Mean_SOILTEMP_MEAN_0_30_03'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g','r'};
      plotinfo(2).markers = {'.','o','x'};
      plotinfo(2).linestyles = {'-','-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'soilt.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Soil Temperature';
      
 case 'LNDB_HJA_RS12_94_5min'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 12','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 12';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_MEAN_225_0_02','AIRTEMP_MEAN_225_0_03'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r'};
      plotinfo(1).markers = {'.','o','x'};
      plotinfo(1).linestyles = {'-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
      plotinfo(2).caption = 'Soil Temperature';
      plotinfo(2).plotprefix = 'soilt';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'SOILTEMP_MEAN_0_10_01','SOILTEMP_MEAN_0_20_02','SOILTEMP_MEAN_0_30_03'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g','r'};
      plotinfo(2).markers = {'.','o','x'};
      plotinfo(2).linestyles = {'-','-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'soilt.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Soil Temperature';
      
      plotinfo(3).caption = 'Battery Supply Voltage';
      plotinfo(3).plotprefix = 'batt';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'BATTERY_AVG'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b'};
      plotinfo(3).markers = {'.'};
      plotinfo(3).linestyles = {'-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'batt.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'Battery Supply Voltage';
      
  case 'LNDB_HJA_RS12_94_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 12','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 12';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'Hourly_Mean_AIRTEMP_MEAN_225_0_02','Hourly_Mean_AIRTEMP_MEAN_225_0_03'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r'};
      plotinfo(1).markers = {'.','o','x'};
      plotinfo(1).linestyles = {'-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
      plotinfo(2).caption = 'Soil Temperature';
      plotinfo(2).plotprefix = 'soilt';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'Hourly_Mean_SOILTEMP_MEAN_0_10_01','Hourly_Mean_SOILTEMP_MEAN_0_20_02','Hourly_Mean_SOILTEMP_MEAN_0_30_03'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g','r'};
      plotinfo(2).markers = {'.','o','x'};
      plotinfo(2).linestyles = {'-','-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'soilt.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Soil Temperature';
      
  case 'LNDB_HJA_RS12_94_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 12','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 12';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air_dly';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'Daily_Mean_AIRTEMP_MEAN_225_0_02','Daily_Mean_AIRTEMP_MEAN_225_0_03','Daily_Mean_AIRTEMP_MEAN_225_0_04'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r'};
      plotinfo(1).markers = {'.','o','x'};
      plotinfo(1).linestyles = {'-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air_dly.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
      plotinfo(2).caption = 'Soil Temperature';
      plotinfo(2).plotprefix = 'soilt';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'Daily_Mean_SOILTEMP_MEAN_0_10_01','Daily_Mean_SOILTEMP_MEAN_0_20_02','Daily_Mean_SOILTEMP_MEAN_0_30_03'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g','r'};
      plotinfo(2).markers = {'.','o','x'};
      plotinfo(2).linestyles = {'-','-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'soilt.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Soil Temperature';
      
 case 'LNDB_HJA_RS20_95_5min'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 20','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 20';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_MEAN_225_0_02','AIRTEMP_MEAN_225_0_03'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r'};
      plotinfo(1).markers = {'.','o','x'};
      plotinfo(1).linestyles = {'-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
      plotinfo(2).caption = 'Soil Temperature';
      plotinfo(2).plotprefix = 'soilt';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'SOILTEMP_MEAN_0_10_01','SOILTEMP_MEAN_0_20_02','SOILTEMP_MEAN_0_30_03'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g','r'};
      plotinfo(2).markers = {'.','o','x'};
      plotinfo(2).linestyles = {'-','-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'soilt.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Soil Temperature';
      
      plotinfo(3).caption = 'Battery Supply Voltage';
      plotinfo(3).plotprefix = 'batt';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'BATTERY_AVG'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b'};
      plotinfo(3).markers = {'.'};
      plotinfo(3).linestyles = {'-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'batt.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'Battery Supply Voltage';
      
  case 'LNDB_HJA_RS20_95_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 20','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 20';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'Hourly_Mean_AIRTEMP_MEAN_225_0_02','Hourly_Mean_AIRTEMP_MEAN_225_0_03'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r'};
      plotinfo(1).markers = {'.','o','x'};
      plotinfo(1).linestyles = {'-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
      plotinfo(2).caption = 'Soil Temperature';
      plotinfo(2).plotprefix = 'soilt';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'Hourly_Mean_SOILTEMP_MEAN_0_10_01','Hourly_Mean_SOILTEMP_MEAN_0_20_02','Hourly_Mean_SOILTEMP_MEAN_0_30_03'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g','r'};
      plotinfo(2).markers = {'.','o','x'};
      plotinfo(2).linestyles = {'-','-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'soilt.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Soil Temperature';
      
  case 'LNDB_HJA_RS20_95_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 20','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 20';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air_dly';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'Daily_Mean_AIRTEMP_MEAN_225_0_02','Daily_Mean_AIRTEMP_MEAN_225_0_03'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r'};
      plotinfo(1).markers = {'.','o','x'};
      plotinfo(1).linestyles = {'-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air_dly.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
      plotinfo(2).caption = 'Soil Temperature';
      plotinfo(2).plotprefix = 'soilt';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'Daily_Mean_SOILTEMP_MEAN_0_10_01','Daily_Mean_SOILTEMP_MEAN_0_20_02','Daily_Mean_SOILTEMP_MEAN_0_30_03'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g','r'};
      plotinfo(2).markers = {'.','o','x'};
      plotinfo(2).linestyles = {'-','-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'soilt.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Soil Temperature';
      
  case 'LNDB_HJA_RS26_96_5min'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 26','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 26';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_MEAN_225_0_02','AIRTEMP_MEAN_225_0_03'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r'};
      plotinfo(1).markers = {'.','o','x'};
      plotinfo(1).linestyles = {'-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
      plotinfo(2).caption = 'Soil Temperature';
      plotinfo(2).plotprefix = 'soilt';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'SOILTEMP_MEAN_0_10_01','SOILTEMP_MEAN_0_20_02','SOILTEMP_MEAN_0_30_03'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g','r'};
      plotinfo(2).markers = {'.','o','x'};
      plotinfo(2).linestyles = {'-','-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'soilt.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Soil Temperature';
      
      plotinfo(3).caption = 'Battery Supply Voltage';
      plotinfo(3).plotprefix = 'batt';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'BATTERY_AVG'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b'};
      plotinfo(3).markers = {'.'};
      plotinfo(3).linestyles = {'-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'batt.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'Battery Supply Voltage';
      
  case 'LNDB_HJA_RS26_96_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 26','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 26';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'Hourly_Mean_AIRTEMP_MEAN_225_0_02','Hourly_Mean_AIRTEMP_MEAN_225_0_03'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r'};
      plotinfo(1).markers = {'.','o','x'};
      plotinfo(1).linestyles = {'-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
      plotinfo(2).caption = 'Soil Temperature';
      plotinfo(2).plotprefix = 'soilt';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'Hourly_Mean_SOILTEMP_MEAN_0_10_01','Hourly_Mean_SOILTEMP_MEAN_0_20_02','Hourly_Mean_SOILTEMP_MEAN_0_30_03'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g','r'};
      plotinfo(2).markers = {'.','o','x'};
      plotinfo(2).linestyles = {'-','-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'soilt.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Soil Temperature';
      
  case 'LNDB_HJA_RS26_96_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 26','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 26';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air_dly';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'Daily_Mean_AIRTEMP_MEAN_225_0_02','Daily_Mean_AIRTEMP_MEAN_225_0_03'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r'};
      plotinfo(1).markers = {'.','o','x'};
      plotinfo(1).linestyles = {'-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air_dly.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
      plotinfo(2).caption = 'Soil Temperature';
      plotinfo(2).plotprefix = 'soilt';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'Daily_Mean_SOILTEMP_MEAN_0_10_01','Daily_Mean_SOILTEMP_MEAN_0_20_02','Daily_Mean_SOILTEMP_MEAN_0_30_03'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g','r'};
      plotinfo(2).markers = {'.','o','x'};
      plotinfo(2).linestyles = {'-','-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'soilt.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Soil Temperature';
      
 case 'LNDB_HJA_RS02_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 02','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 02';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_MEAN_225_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
  case 'LNDB_HJA_RS02_6hr'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 02','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 02';
      
      plotinfo(1).caption = 'Soil Temperature';
      plotinfo(1).plotprefix = 'soilt';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'SOILTEMP_MEAN_0_10_01','SOILTEMP_MEAN_0_20_02','SOILTEMP_MEAN_0_30_03'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r'};
      plotinfo(1).markers = {'.','o','x'};
      plotinfo(1).linestyles = {'-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'soilt.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Soil Temperature';
      
  case 'LNDB_HJA_RS02_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 02','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 02';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'airdly';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_MEAN_225_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'airdly.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
  case 'LNDB_HJA_RS04_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 04','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 04';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_MEAN_225_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
  case 'LNDB_HJA_RS04_6hr'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 04','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 04';
      
      plotinfo(1).caption = 'Soil Temperature';
      plotinfo(1).plotprefix = 'soilt';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'SOILTEMP_MEAN_0_10_01','SOILTEMP_MEAN_0_20_02','SOILTEMP_MEAN_0_30_03'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r'};
      plotinfo(1).markers = {'.','o','x'};
      plotinfo(1).linestyles = {'-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'soilt.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Soil Temperature';
      
  case 'LNDB_HJA_RS04_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 04','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 04';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'airdly';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_MEAN_225_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'airdly.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
  case 'LNDB_HJA_RS05_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 05','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 05';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_MEAN_225_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
  case 'LNDB_HJA_RS05_6hr'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 05','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 05';
      
      plotinfo(1).caption = 'Soil Temperature';
      plotinfo(1).plotprefix = 'soilt';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'SOILTEMP_MEAN_0_10_01','SOILTEMP_MEAN_0_20_02','SOILTEMP_MEAN_0_30_03'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r'};
      plotinfo(1).markers = {'.','o','x'};
      plotinfo(1).linestyles = {'-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'soilt.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Soil Temperature';
      
  case 'LNDB_HJA_RS05_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 05','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 05';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'airdly';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_MEAN_225_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'airdly.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
  case 'LNDB_HJA_RS10_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 10','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 10';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_MEAN_225_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
  case 'LNDB_HJA_RS10_6hr'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 10','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 10';
      
      plotinfo(1).caption = 'Soil Temperature';
      plotinfo(1).plotprefix = 'soilt';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'SOILTEMP_MEAN_0_10_01','SOILTEMP_MEAN_0_20_02','SOILTEMP_MEAN_0_30_03'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r'};
      plotinfo(1).markers = {'.','o','x'};
      plotinfo(1).linestyles = {'-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'soilt.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Soil Temperature';
      
  case 'LNDB_HJA_RS10_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 10','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 10';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'airdly';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_MEAN_225_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'airdly.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
  case 'LNDB_HJA_RS12_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 12','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 12';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_MEAN_225_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
  case 'LNDB_HJA_RS12_6hr'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 12','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 12';
      
      plotinfo(1).caption = 'Soil Temperature';
      plotinfo(1).plotprefix = 'soilt';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'SOILTEMP_MEAN_0_10_01','SOILTEMP_MEAN_0_20_02','SOILTEMP_MEAN_0_30_03'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r'};
      plotinfo(1).markers = {'.','o','x'};
      plotinfo(1).linestyles = {'-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'soilt.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Soil Temperature';
      
  case 'LNDB_HJA_RS12_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 12','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 12';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'airdly';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_MEAN_225_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'airdly.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
  case 'LNDB_HJA_RS20_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 20','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 20';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_MEAN_225_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
  case 'LNDB_HJA_RS20_6hr'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 20','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 20';
      
      plotinfo(1).caption = 'Soil Temperature';
      plotinfo(1).plotprefix = 'soilt';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'SOILTEMP_MEAN_0_10_01','SOILTEMP_MEAN_0_20_02','SOILTEMP_MEAN_0_30_03'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r'};
      plotinfo(1).markers = {'.','o','x'};
      plotinfo(1).linestyles = {'-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'soilt.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Soil Temperature';
      
  case 'LNDB_HJA_RS20_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 20','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 20';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'airdly';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_MEAN_225_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'airdly.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
  case 'LNDB_HJA_RS26_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 26','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 26';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_MEAN_225_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
  case 'LNDB_HJA_RS26_6hr'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 26','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 26';
      
      plotinfo(1).caption = 'Soil Temperature';
      plotinfo(1).plotprefix = 'soilt';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'SOILTEMP_MEAN_0_10_01','SOILTEMP_MEAN_0_20_02','SOILTEMP_MEAN_0_30_03'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r'};
      plotinfo(1).markers = {'.','o','x'};
      plotinfo(1).linestyles = {'-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'soilt.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Soil Temperature';
      
  case 'LNDB_HJA_RS26_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 26','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 26';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'airdly';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_MEAN_225_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'airdly.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
  case 'LNDB_HJA_RS38_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 38','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 38';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_MEAN_225_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
  case 'LNDB_HJA_RS38_6hr'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 38','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 38';
      
      plotinfo(1).caption = 'Soil Temperature';
      plotinfo(1).plotprefix = 'soilt';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'SOILTEMP_MEAN_0_10_01','SOILTEMP_MEAN_0_20_02','SOILTEMP_MEAN_0_30_03'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r'};
      plotinfo(1).markers = {'.','o','x'};
      plotinfo(1).linestyles = {'-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'soilt.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Soil Temperature';
      
  case 'LNDB_HJA_RS38_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 38','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 38';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'airdly';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_MEAN_225_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'airdly.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
  case 'LNDB_HJA_RS86_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 86','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 86';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_MEAN_225_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
      plotinfo(2).caption = 'Relative Humidity';
      plotinfo(2).plotprefix = 'rh';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'RELHUM_MEAN_225_0_01'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b'};
      plotinfo(2).markers = {'.'};
      plotinfo(2).linestyles = {'-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'rh.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Relative Humidity';
      
  case 'LNDB_HJA_RS86_6hr'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 86','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 86';
      
      plotinfo(1).caption = 'Soil Temperature';
      plotinfo(1).plotprefix = 'soilt';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'SOILTEMP_MEAN_0_10_01','SOILTEMP_MEAN_0_20_02','SOILTEMP_MEAN_0_30_03'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r'};
      plotinfo(1).markers = {'.','o','x'};
      plotinfo(1).linestyles = {'-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'soilt.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Soil Temperature';
      
  case 'LNDB_HJA_RS86_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 86','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 86';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'airdly';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_MEAN_225_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'airdly.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
  case 'LNDB_HJA_RS89_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 89','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 89';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_MEAN_225_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
      plotinfo(2).caption = 'Relative Humidity';
      plotinfo(2).plotprefix = 'rh';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'RELHUM_MEAN_225_0_01'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b'};
      plotinfo(2).markers = {'.'};
      plotinfo(2).linestyles = {'-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'rh.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Relative Humidity';
      
  case 'LNDB_HJA_RS89_6hr'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 89','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 89';
      
      plotinfo(1).caption = 'Soil Temperature';
      plotinfo(1).plotprefix = 'soilt';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'SOILTEMP_MEAN_0_10_01','SOILTEMP_MEAN_0_20_02','SOILTEMP_MEAN_0_30_03'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r'};
      plotinfo(1).markers = {'.','o','x'};
      plotinfo(1).linestyles = {'-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'soilt.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Soil Temperature';
      
  case 'LNDB_HJA_RS89_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 89','../data'}];
      
      %define plot page title
      pagetitle = 'Reference Stand 89';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'airdly';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_MEAN_225_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'airdly.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
  case 'LNDB_HJA_hagg_01_TmpCnd_MP1'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'STREAMCARBON','../data'}];
      
      %define plot page title
      pagetitle = 'Stream Carbon Team WS01';
      
      plotinfo(1).caption = 'Stream Temperature';
      plotinfo(1).plotprefix = 'st';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'T_STR'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'st.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Stream Temperature';
      
  case 'LNDB_HJA_hagg_01_TmpCnd_MP2'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'STREAMCARBON','../data'}];
      
      %define plot page title
      pagetitle = 'Stream Carbon Team WS01';
      
      plotinfo(1).caption = 'Temperature';
      plotinfo(1).plotprefix = 'st';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'T_G1'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'st.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Temperature';
      
  case 'LNDB_HJA_UplMet_105'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'UPLMET','../data'}];
      
      %define plot page title
      pagetitle = 'Upper Lookout Met Station';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Precipitation';
      plotinfo(1).plotprefix = 'ppt';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'PPT_SA_INST','PPT_SH_INST'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g'};
      plotinfo(1).markers = {'.','o'};
      plotinfo(1).linestyles = {'-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'ppt.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Precipitation';
      
      plotinfo(2).caption = 'Snow Moisture';
      plotinfo(2).plotprefix = 'swe';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'SWE_INST'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b'};
      plotinfo(2).markers = {'.'};
      plotinfo(2).linestyles = {'-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'swe.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'SWE';
      
      plotinfo(3).caption = 'Snow Depth';
      plotinfo(3).plotprefix = 'snodep';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'SNODEP_INST','SNODEP_MED'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b','g'};
      plotinfo(3).markers = {'.','o'};
      plotinfo(3).linestyles = {'-','-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'snodep.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'Snow Depth';
      
      plotinfo(4).caption = 'Snow Lysimeter';
      plotinfo(4).plotprefix = 'snolys';
      plotinfo(4).fnc = 'plotdata';
      plotinfo(4).datecol = 'Date';
      plotinfo(4).parameters = {'LYS_TB_TOT'};
      plotinfo(4).groupcol = [];
      plotinfo(4).colors = {'b'};
      plotinfo(4).markers = {'o'};
      plotinfo(4).linestyles = {''};
      plotinfo(4).scale = 'linear';
      plotinfo(4).rotateaxis = 0;
      plotinfo(4).ylim = [];
      plotinfo(4).deblank = 0;
      plotinfo(4).fn_xml = 'snolys.xml';
      plotinfo(4).xsl = plot_xsl;
      plotinfo(4).navigation = 'Snow Lysimeter';
      
      plotinfo(5).caption = 'Precipitation (Diff)';
      plotinfo(5).plotprefix = 'pptdiff';
      plotinfo(5).fnc = 'plotdata';
      plotinfo(5).datecol = 'Date';
      plotinfo(5).parameters = {'PPT_SH_DIFF','PPT_SA_DIFF'};
      plotinfo(5).groupcol = [];
      plotinfo(5).colors = {'b','g'};
      plotinfo(5).markers = {'o','x'};
      plotinfo(5).linestyles = {'',''};
      plotinfo(5).scale = 'linear';
      plotinfo(5).rotateaxis = 0;
      plotinfo(5).ylim = [];
      plotinfo(5).deblank = 0;
      plotinfo(5).fn_xml = 'pptdiff.xml';
      plotinfo(5).xsl = plot_xsl;
      plotinfo(5).navigation = 'Precipitation (Diff)';
      
   case 'LNDB_HJA_UplMet_115'  %3-plot GCE example
      
      %append station-specific label and url to base navigation
     nav = [nav_base, ...
         {'UPLMET','../data'}];
      
      %define plot page title
      pagetitle = 'Upper Lookout Met Station';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIR_150_AVG','AIR_250_AVG','AIR_350_AVG','AIR_350A_AVG','AIR_450_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r','c','m'};
      plotinfo(1).markers = {'.','o','x','+','*'};
      plotinfo(1).linestyles = {'-','-','-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
      plotinfo(2).caption = 'Radiation';
      plotinfo(2).plotprefix = 'solar';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'SOLAR_AVG'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b'};
      plotinfo(2).markers = {'.'};
      plotinfo(2).linestyles = {'-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'solar.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Radiation';
      
      plotinfo(3).caption = 'Barametric Pressure';
      plotinfo(3).plotprefix = 'p';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'BP_INST'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b'};
      plotinfo(3).markers = {'.'};
      plotinfo(3).linestyles = {'-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'p.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'Barametric Pressure';
      
   case 'LNDB_HJA_UplMet_160'  %3-plot GCE example
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'UPLMET','../data'}];
      
      %define plot page title
      pagetitle = 'Upper Lookout Met Station';
      
      %parameterize plot options (1 structure dimension per plot)
      
      plotinfo(1).caption = 'Soil Temperature';
      plotinfo(1).plotprefix = 'soil';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'SOIL_10_AVG','SOIL_20_AVG','SOIL_50_AVG','SOIL_100_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r','c'};
      plotinfo(1).markers = {'.','o','x','+'};
      plotinfo(1).linestyles = {'-','-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'soil.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Soil Temperature';
      
      plotinfo(2).caption = 'Relative Humidity';
      plotinfo(2).plotprefix = 'rh';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'RH_150_AVG','RH_450_AVG'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g'};
      plotinfo(2).markers = {'.','o'};
      plotinfo(2).linestyles = {'-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'rh.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'RH';
      
  case 'LNDB_HJA_UplMet_440'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'UPLMET','../data'}];
      
      %define plot page title
      pagetitle = 'Upper Lookout Met Station';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Daily Precipitation';
      plotinfo(1).plotprefix = 'pptdaily';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'PPT_SA_TOT','PPT_SH_TOT'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g'};
      plotinfo(1).markers = {'o','o'};
      plotinfo(1).linestyles = {'','',};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'pptdaily.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Daily Precipitation';
      
  case 'LNDB_VanMet_228_105'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'VANMET','../data'}];
      
      %define plot page title
      pagetitle = 'Vanilla Met Station';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'SWE';
      plotinfo(1).plotprefix = 'swe';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'SWE_INST'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'swe.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'SWE';
      
      plotinfo(2).caption = 'Snow Depth';
      plotinfo(2).plotprefix = 'snodep';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'SNODEP_MED'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b'};
      plotinfo(2).markers = {'.'};
      plotinfo(2).linestyles = {'-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'snodep.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Snow Depth';
      
  case 'LNDB_VanMet_228_115'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'VANMET','../data'}];
      
      %define plot page title
      pagetitle = 'Vanilla Met Station';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIR_150_AVG','AIR_250_AVG','AIR_350_AVG','AIR_450_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r','c'};
      plotinfo(1).markers = {'.','o','x','+'};
      plotinfo(1).linestyles = {'-','-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
      plotinfo(2).caption = 'Radiation';
      plotinfo(2).plotprefix = 'solar';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'SOLAR_AVG'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b'};
      plotinfo(2).markers = {'.'};
      plotinfo(2).linestyles = {'-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'solar.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Radiation';
      
  case 'LNDB_VanMet_228_160'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'VANMET','../data'}];
      
      %define plot page title
      pagetitle = 'Vanilla Met Station';
      
      plotinfo(1).caption = 'Soil Temperature';
      plotinfo(1).plotprefix = 'soil';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'SOIL_10_AVG','SOIL_20_AVG','SOIL_50_AVG','SOIL_100_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r','c'};
      plotinfo(1).markers = {'.','o','x','+'};
      plotinfo(1).linestyles = {'-','-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'soil.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Soil Temperature';
      
      plotinfo(2).caption = 'Relative Humidity';
      plotinfo(2).plotprefix = 'rh';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'RH_150_AVG','RH_450_AVG'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g'};
      plotinfo(2).markers = {'.','o'};
      plotinfo(2).linestyles = {'-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'rh.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'RH';
      
      plotinfo(1).caption = 'Wind Speed and Direction';
      plotinfo(1).plotprefix = 'wind';
      plotinfo(1).fnc = 'plotwind';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'WSPD_PRO_10m_AVG','WDIR_PRO_10m_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'',''};
      plotinfo(1).markers = {'',''};
      plotinfo(1).linestyles = {'',''};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'wind.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Wind';
      
  case 'LNDB_VanMet_228_440'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'VANMET','../data'}];
      
      %define plot page title
      pagetitle = 'Vanilla Met Station';
      
      plotinfo(1).caption = 'Max Air Temperature';
      plotinfo(1).plotprefix = 'airmax';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIR_150_MAX','AIR_250_MAX','AIR_350_MAX','AIR_450_MAX'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r','c'};
      plotinfo(1).markers = {'.','o','x','+'};
      plotinfo(1).linestyles = {'-','-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'airmax.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Max Air Temperature';
      
      plotinfo(2).caption = 'Avg Air Temperature';
      plotinfo(2).plotprefix = 'air';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'AIR_150_AVG','AIR_250_AVG','AIR_350_AVG','AIR_450_AVG'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g','r','c'};
      plotinfo(2).markers = {'.','o','x','+'};
      plotinfo(2).linestyles = {'-','-','-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'air.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Avg Air Temperature';
      
      plotinfo(3).caption = 'Min Air Temperature';
      plotinfo(3).plotprefix = 'airmin';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'AIR_150_MIN','AIR_250_MIN','AIR_350_MIN','AIR_450_MIN'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b','g','r','c'};
      plotinfo(3).markers = {'.','o','x','+'};
      plotinfo(3).linestyles = {'-','-','-','-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'airmin.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'Min Air Temperature';
      
     case 'LNDB_HJA_VanMet_231_a_5min'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'VANMET','../data'}];
      
      %define plot page title
      pagetitle = 'Vanilla Met Station';
      
      plotinfo(1).caption = 'SWE';
      plotinfo(1).plotprefix = 'swe';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'SWE_INST_0_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'swe.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'SWE';
      
      plotinfo(2).caption = 'Snow Depth';
      plotinfo(2).plotprefix = 'snodep';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'SNODEP_MED_0_0_01','SNODEP_INST_0_0_01'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g'};
      plotinfo(2).markers = {'.','o'};
      plotinfo(2).linestyles = {'-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'snodep.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Snow Depth';
       
      plotinfo(3).caption = 'Air Temperature';
      plotinfo(3).plotprefix = 'airmean';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'AIRTEMP_MEAN_150_0_04','AIRTEMP_MEAN_250_0_03','AIRTEMP_MEAN_350_0_02','AIRTEMP_MEAN_350A_0_05','AIRTEMP_MEAN_450_0_01'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b','g','r','c','m'};
      plotinfo(3).markers = {'.','o','x','+','*'};
      plotinfo(3).linestyles = {'-','-','-','-','-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'airmean.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'Air Temperature';
      
      plotinfo(4).caption = 'Radiation';
      plotinfo(4).plotprefix = 'solar';
      plotinfo(4).fnc = 'plotdata';
      plotinfo(4).datecol = 'Date';
      plotinfo(4).parameters = {'SOLAR_MEAN_850_0_01'};
      plotinfo(4).groupcol = [];
      plotinfo(4).colors = {'b'};
      plotinfo(4).markers = {'.'};
      plotinfo(4).linestyles = {'-'};
      plotinfo(4).scale = 'linear';
      plotinfo(4).rotateaxis = 0;
      plotinfo(4).ylim = [];
      plotinfo(4).deblank = 0;
      plotinfo(4).fn_xml = 'solar.xml';
      plotinfo(4).xsl = plot_xsl;
      plotinfo(4).navigation = 'Radiation';
      
      plotinfo(5).caption = 'Relative Humidity';
      plotinfo(5).plotprefix = 'rh';
      plotinfo(5).fnc = 'plotdata';
      plotinfo(5).datecol = 'Date';
      plotinfo(5).parameters = {'RELHUM_MEAN_150_0_04','RELHUM_MEAN_450_0_01'};
      plotinfo(5).groupcol = [];
      plotinfo(5).colors = {'b','g'};
      plotinfo(5).markers = {'.','o'};
      plotinfo(5).linestyles = {'-','-'};
      plotinfo(5).scale = 'linear';
      plotinfo(5).rotateaxis = 0;
      plotinfo(5).ylim = [];
      plotinfo(5).deblank = 0;
      plotinfo(5).fn_xml = 'rh.xml';
      plotinfo(5).xsl = plot_xsl;
      plotinfo(5).navigation = 'RH';
      
      plotinfo(6).caption = 'Soil Temperature';
      plotinfo(6).plotprefix = 'ts';
      plotinfo(6).fnc = 'plotdata';
      plotinfo(6).datecol = 'Date';
      plotinfo(6).parameters = {'SOILTEMP_MEAN_0_10_01','SOILTEMP_MEAN_0_20_02','SOILTEMP_MEAN_0_50_03','SOILTEMP_MEAN_0_100_04'};
      plotinfo(6).groupcol = [];
      plotinfo(6).colors = {'b','g','r','c'};
      plotinfo(6).markers = {'.','o','x','+'};
      plotinfo(6).linestyles = {'-','-','-','-'};
      plotinfo(6).scale = 'linear';
      plotinfo(6).rotateaxis = 0;
      plotinfo(6).ylim = [];
      plotinfo(6).deblank = 0;
      plotinfo(6).fn_xml = 'ts.xml';
      plotinfo(6).xsl = plot_xsl;
      plotinfo(6).navigation = 'Soil Temperature';
      
      plotinfo(7).caption = 'Soil Moisture';
      plotinfo(7).plotprefix = 'soilm';
      plotinfo(7).fnc = 'plotdata';
      plotinfo(7).datecol = 'Date';
      plotinfo(7).parameters = {'SOILWC_MEAN_0_10_01','SOILWC_MEAN_0_20_02','SOILWC_MEAN_0_50_03','SOILWC_MEAN_0_100_04'};
      plotinfo(7).groupcol = [];
      plotinfo(7).colors = {'b','g','r','c'};
      plotinfo(7).markers = {'.','o','x','+'};
      plotinfo(7).linestyles = {'-','-','-','-'};
      plotinfo(7).scale = 'linear';
      plotinfo(7).rotateaxis = 0;
      plotinfo(7).ylim = [];
      plotinfo(7).deblank = 0;
      plotinfo(7).fn_xml = 'soilm.xml';
      plotinfo(7).xsl = plot_xsl;
      plotinfo(7).navigation = 'Soil Moisture';
      
  case 'LNDB_HJA_VanMet_231_a_hrly'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'VANMET','../data'}];
      
      %define plot page title
      pagetitle = 'Vanilla Met Station';
      
      plotinfo(1).caption = 'SWE';
      plotinfo(1).plotprefix = 'swe';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'Hourly_Mean_SWE_INST_0_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'swe.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'SWE';
      
      plotinfo(2).caption = 'Snow Depth';
      plotinfo(2).plotprefix = 'snodep';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'Hourly_Mean_SNODEP_MED_0_0_01','Hourly_Mean_SNODEP_INST_0_0_01'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g'};
      plotinfo(2).markers = {'.','o'};
      plotinfo(2).linestyles = {'-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'snodep.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Snow Depth';
      
  case 'LNDB_HJA_VanMet_231_a_dly'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'VANMET','../data'}];
      
      %define plot page title
      pagetitle = 'Vanilla Met Station';
      
      plotinfo(1).caption = 'SWE';
      plotinfo(1).plotprefix = 'swe';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'Daily_Mean_SWE_INST_0_0_01'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'swe.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'SWE';
      
      plotinfo(2).caption = 'Snow Depth';
      plotinfo(2).plotprefix = 'snodep';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'Daily_Mean_SNODEP_MED_0_0_01','Daily_Mean_SNODEP_INST_0_0_01'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g'};
      plotinfo(2).markers = {'.','o'};
      plotinfo(2).linestyles = {'-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'snodep.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Snow Depth';
      
  case 'LNDB_VanMet_231_105'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'VANMET','../data'}];
      
      %define plot page title
      pagetitle = 'Vanilla Met Station';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'SWE';
      plotinfo(1).plotprefix = 'swe';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'SWE_INST'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'swe.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'SWE';
      
      plotinfo(2).caption = 'Snow Depth';
      plotinfo(2).plotprefix = 'snodep';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'SNODEP_MED','SNODEP_INST'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g'};
      plotinfo(2).markers = {'.','o'};
      plotinfo(2).linestyles = {'-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'snodep.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Snow Depth';
      
      plotinfo(3).caption = 'Wind Speed and Direction';
      plotinfo(3).plotprefix = 'wind';
      plotinfo(3).fnc = 'plotwind';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'WSPD_PRO_10m_AVG','WDIR_PRO_10m_AVG'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'',''};
      plotinfo(3).markers = {'',''};
      plotinfo(3).linestyles = {'',''};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'wind.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'Wind';
      
  case 'LNDB_VanMet_231_115'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'VANMET','../data'}];
      
      %define plot page title
      pagetitle = 'Vanilla Met Station';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'air';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIR_150_AVG','AIR_250_AVG','AIR_350_AVG','AIR_350A_AVG','AIR_450_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r','c','m'};
      plotinfo(1).markers = {'.','o','x','+','*'};
      plotinfo(1).linestyles = {'-','-','-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'air.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
      plotinfo(2).caption = 'Radiation';
      plotinfo(2).plotprefix = 'solar';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'SOLAR_AVG'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b'};
      plotinfo(2).markers = {'.'};
      plotinfo(2).linestyles = {'-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'solar.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Radiation';
      
      plotinfo(3).caption = 'Relative Humidity';
      plotinfo(3).plotprefix = 'rh';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'RH_150_AVG','RH_450_AVG'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b','g'};
      plotinfo(3).markers = {'.','o'};
      plotinfo(3).linestyles = {'-','-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'rh.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'RH';
      
  case 'LNDB_VanMet_231_160'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'VANMET','../data'}];
      
      %define plot page title
      pagetitle = 'Vanilla Met Station';
      
      plotinfo(1).caption = 'Soil Temperature';
      plotinfo(1).plotprefix = 'ts';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'SOIL_10_AVG','SOIL_20_AVG','SOIL_50_AVG','SOIL_100_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r','c'};
      plotinfo(1).markers = {'.','o','x','+'};
      plotinfo(1).linestyles = {'-','-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'ts.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Soil Temperature';
      
      plotinfo(2).caption = 'Soil Moisture';
      plotinfo(2).plotprefix = 'soilm';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'WCR_10_INST','WCR_20_INST','WCR_50_INST','WCR_100_INST'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g','r','c'};
      plotinfo(2).markers = {'.','o','x','+'};
      plotinfo(2).linestyles = {'-','-','-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'soilm.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Soil Moisture';
      
  case 'LNDB_VanMet_232_a_5min'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'VANMET','../data'}];
      
      %define plot page title
      pagetitle = 'Vanilla Met Station';
      
      plotinfo(1).caption = 'Longwave Radiation';
      plotinfo(1).plotprefix = 'IR01';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'LW_OUT_MEAN_600_0_02','LW_IN_MEAN_600_0_02'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g'};
      plotinfo(1).markers = {'.','o'};
      plotinfo(1).linestyles = {'-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'IR01.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'IR01';
       
      plotinfo(2).caption = 'Net Radiation';
      plotinfo(2).plotprefix = 'netrad';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'NR_TOT_MEAN_600_0_02'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b'};
      plotinfo(2).markers = {'.'};
      plotinfo(2).linestyles = {'-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'netrad.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Net Radiation';
       
      plotinfo(3).caption = 'Shortwave Radiation';
      plotinfo(3).plotprefix = 'SR01';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'SW_IN_MEAN_600_0_02','SW_OUT_MEAN_600_0_02'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b','g'};
      plotinfo(3).markers = {'.','o'};
      plotinfo(3).linestyles = {'-','-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'SR01.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'SR01';

  case 'LNDB_VanMet_232_a_hrly'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'VANMET','../data'}];
      
      %define plot page title
      pagetitle = 'Vanilla Met Station';
      
      plotinfo(1).caption = 'Longwave Radiation';
      plotinfo(1).plotprefix = 'IR01';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'Hourly_Mean_LW_OUT_MEAN_600_0_02','Hourly_Mean_LW_IN_MEAN_600_0_02'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g'};
      plotinfo(1).markers = {'.','o'};
      plotinfo(1).linestyles = {'-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'IR01.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'IR01';
       
      plotinfo(2).caption = 'Net Radiation';
      plotinfo(2).plotprefix = 'netrad';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'Hourly_Mean_NR_TOT_MEAN_600_0_02'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b'};
      plotinfo(2).markers = {'.'};
      plotinfo(2).linestyles = {'-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'netrad.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Net Radiation';
       
      plotinfo(3).caption = 'Shortwave Radiation';
      plotinfo(3).plotprefix = 'SR01';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'Hourly_Mean_SW_IN_MEAN_600_0_02','Hourly_Mean_SW_OUT_MEAN_600_0_02'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b','g'};
      plotinfo(3).markers = {'.','o'};
      plotinfo(3).linestyles = {'-','-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'SR01.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'SR01';

  case 'LNDB_VanMet_232_a_dly'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'VANMET','../data'}];
      
      %define plot page title
      pagetitle = 'Vanilla Met Station';
      
      plotinfo(1).caption = 'Longwave Radiation';
      plotinfo(1).plotprefix = 'IR01';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'Daily_Mean_LW_OUT_MEAN_600_0_02','Daily_Mean_LW_IN_MEAN_600_0_02'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g'};
      plotinfo(1).markers = {'.','o'};
      plotinfo(1).linestyles = {'-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'IR01.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'IR01';
       
      plotinfo(2).caption = 'Net Radiation';
      plotinfo(2).plotprefix = 'netrad';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'Daily_Mean_NR_TOT_MEAN_600_0_02'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b'};
      plotinfo(2).markers = {'.'};
      plotinfo(2).linestyles = {'-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'netrad.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Net Radiation';
       
      plotinfo(3).caption = 'Shortwave Radiation';
      plotinfo(3).plotprefix = 'SR01';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'Daily_Mean_SW_IN_MEAN_600_0_02','Daily_Mean_SW_OUT_MEAN_600_0_02'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b','g'};
      plotinfo(3).markers = {'.','o'};
      plotinfo(3).linestyles = {'-','-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'SR01.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'SR01';
      
  case 'LNDB_VanMet_232_b_5min'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'VANMET','../data'}];
      
      %define plot page title
      pagetitle = 'Vanilla Met Station';
      
      plotinfo(1).caption = 'Wind Speed and Direction';
      plotinfo(1).plotprefix = 'wind';
      plotinfo(1).fnc = 'plotwind';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'WSPD_SNC_MEAN_1000_0_02','WDIR_SNC_MEAN_1000_0_02'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'',''};
      plotinfo(1).markers = {'',''};
      plotinfo(1).linestyles = {'',''};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'wind.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Wind';
      
  case 'LNDB_VanMet_232_b_hrly'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'VANMET','../data'}];
      
      %define plot page title
      pagetitle = 'Vanilla Met Station';
      
      plotinfo(1).caption = 'Wind Speed and Direction';
      plotinfo(1).plotprefix = 'wind';
      plotinfo(1).fnc = 'plotwind';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'Hourly_Mean_WSPD_SNC_MEAN_1000_0_02','Hourly_VecAvg_WDIR_SNC_MEAN_1000_0_02'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'',''};
      plotinfo(1).markers = {'',''};
      plotinfo(1).linestyles = {'',''};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'wind.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Wind';

  case 'LNDB_VanMet_232_b_dly'
      
      %append station-specific label and url to base navigation
       nav = [nav_base, ...
         {'VANMET','../data'}];
      
      %define plot page title
      pagetitle = 'Vanilla Met Station';
      
      plotinfo(1).caption = 'Wind Speed and Direction';
      plotinfo(1).plotprefix = 'wind';
      plotinfo(1).fnc = 'plotwind';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'Daily_Mean_WSPD_SNC_MEAN_1000_0_02','Daily_VecAvg_WDIR_SNC_MEAN_1000_0_02'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'',''};
      plotinfo(1).markers = {'',''};
      plotinfo(1).linestyles = {'',''};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'wind.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Wind';
     
  case 'LNDB_VARMET_301_105'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'VARA','../data'}];
      
      %define plot page title
      pagetitle = 'Vanilla Rain Gage';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Precipitation';
      plotinfo(1).plotprefix = 'ppt';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'PRECIP_INST_455_0_02'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'ppt.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Precipitation';
      
      plotinfo(2).caption = 'Snow Moisture';
      plotinfo(2).plotprefix = 'swe';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'SWE_MEAN_0_0_05'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b'};
      plotinfo(2).markers = {'.'};
      plotinfo(2).linestyles = {'-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'swe.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'SWE';
      
      plotinfo(3).caption = 'Snow Depth';
      plotinfo(3).plotprefix = 'snodep';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'SNODEP_MED_0_0_05'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b'};
      plotinfo(3).markers = {'.'};
      plotinfo(3).linestyles = {'-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'snodep.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'Snow Depth';
      
      plotinfo(4).caption = 'Precipitation (Diff)';
      plotinfo(4).plotprefix = 'pptdiff';
      plotinfo(4).fnc = 'plotdata';
      plotinfo(4).datecol = 'Date';
      plotinfo(4).parameters = {'PRECIP_DIFF_455_0_02'};
      plotinfo(4).groupcol = [];
      plotinfo(4).colors = {'b'};
      plotinfo(4).markers = {'x'};
      plotinfo(4).linestyles = {''};
      plotinfo(4).scale = 'linear';
      plotinfo(4).rotateaxis = 0;
      plotinfo(4).ylim = [];
      plotinfo(4).deblank = 0;
      plotinfo(4).fn_xml = 'pptdiff.xml';
      plotinfo(4).xsl = plot_xsl;
      plotinfo(4).navigation = 'Precipitation (Diff)';
      
  case 'LNDB_VARMET_301_115'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'VARA','../data'}];
      
      %define plot page title
      pagetitle = 'Vanilla Rain Gage';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'ta';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_MEAN_450_0_10'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'ta.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
    
    case 'LNDB_VARA_301_105'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'VARA','../data'}];
      
      %define plot page title
      pagetitle = 'Vanilla Rain Gage';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Precipitation';
      plotinfo(1).plotprefix = 'ppt';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'PRECIP_INST_455_0_02'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'ppt.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Precipitation';
      
      plotinfo(2).caption = 'Snow Moisture';
      plotinfo(2).plotprefix = 'swe';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'SWE_MEAN_0_0_05'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b'};
      plotinfo(2).markers = {'.'};
      plotinfo(2).linestyles = {'-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'swe.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'SWE';
      
      plotinfo(3).caption = 'Snow Depth';
      plotinfo(3).plotprefix = 'snodep';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'SNODEP_MED_0_0_05'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b'};
      plotinfo(3).markers = {'.'};
      plotinfo(3).linestyles = {'-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'snodep.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'Snow Depth';
      
      plotinfo(4).caption = 'Precipitation (Diff)';
      plotinfo(4).plotprefix = 'pptdiff';
      plotinfo(4).fnc = 'plotdata';
      plotinfo(4).datecol = 'Date';
      plotinfo(4).parameters = {'PRECIP_DIFF_455_0_02'};
      plotinfo(4).groupcol = [];
      plotinfo(4).colors = {'b'};
      plotinfo(4).markers = {'x'};
      plotinfo(4).linestyles = {''};
      plotinfo(4).scale = 'linear';
      plotinfo(4).rotateaxis = 0;
      plotinfo(4).ylim = [];
      plotinfo(4).deblank = 0;
      plotinfo(4).fn_xml = 'pptdiff.xml';
      plotinfo(4).xsl = plot_xsl;
      plotinfo(4).navigation = 'Precipitation (Diff)';
      
  case 'LNDB_VARA_301_115'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'VARA','../data'}];
      
      %define plot page title
      pagetitle = 'Vanilla Rain Gage';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'ta';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'AIRTEMP_MEAN_450_0_10'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'ta.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
%   case 'LNDB_VARA_301_160'
%       
%       %append station-specific label and url to base navigation
%       nav = [nav_base, ...
%          {'VARA','../data'}];
%       
%       %define plot page title
%       pagetitle = 'Vanilla Rain Gage';
%       
%       plotinfo(1).caption = 'Snow Depth';
%       plotinfo(1).plotprefix = 'snodep';
%       plotinfo(1).fnc = 'plotdata';
%       plotinfo(1).datecol = 'Date';
%       plotinfo(1).parameters = {'SNODEP_MED'};
%       plotinfo(1).groupcol = [];
%       plotinfo(1).colors = {'b'};
%       plotinfo(1).markers = {'.'};
%       plotinfo(1).linestyles = {'-'};
%       plotinfo(1).scale = 'linear';
%       plotinfo(1).rotateaxis = 0;
%       plotinfo(1).ylim = [];
%       plotinfo(1).deblank = 0;
%       plotinfo(1).fn_xml = 'snodep.xml';
%       plotinfo(1).xsl = plot_xsl;
%       plotinfo(1).navigation = 'Snow Depth';
      
case 'LNDB_HJA_WS1_EC_AVG_arch1'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'WS1 Met and Flux','../data'}];
      
      %define plot page title
      pagetitle = 'Watershed 1 Met and Flux';
     
      plotinfo(1).caption = 'Air Temperature (sonic)';
      plotinfo(1).plotprefix = 'tsnc';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'Ts_top_Avg','Ts_sub_Avg'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g'};
      plotinfo(1).markers = {'.','o'};
      plotinfo(1).linestyles = {'-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'tsnc.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature (sonic)';
      
%       plotinfo(2).caption = 'CO2';
%       plotinfo(2).plotprefix = 'co2';
%       plotinfo(2).fnc = 'plotdata';
%       plotinfo(2).datecol = 'Date';
%       plotinfo(2).parameters = {'CO2mmol_top_Avg'};
%       plotinfo(2).groupcol = [];
%       plotinfo(2).colors = {'b'};
%       plotinfo(2).markers = {'.'};
%       plotinfo(2).linestyles = {'-'};
%       plotinfo(2).scale = 'linear';
%       plotinfo(2).rotateaxis = 0;
%       plotinfo(2).ylim = [];
%       plotinfo(2).deblank = 0;
%       plotinfo(2).fn_xml = 'co2.xml';
%       plotinfo(2).xsl = plot_xsl;
%       plotinfo(2).navigation = 'CO2';
%       
%       plotinfo(2).caption = 'H2O';
%       plotinfo(2).plotprefix = 'h2o';
%       plotinfo(2).fnc = 'plotdata';
%       plotinfo(2).datecol = 'Date';
%       plotinfo(2).parameters = {'H2Ommol_top_Avg'};
%       plotinfo(2).groupcol = [];
%       plotinfo(2).colors = {'b'};
%       plotinfo(2).markers = {'.'};
%       plotinfo(2).linestyles = {'-'};
%       plotinfo(2).scale = 'linear';
%       plotinfo(2).rotateaxis = 0;
%       plotinfo(2).ylim = [];
%       plotinfo(2).deblank = 0;
%       plotinfo(2).fn_xml = 'h2o.xml';
%       plotinfo(2).xsl = plot_xsl;
%       plotinfo(2).navigation = 'H2O';
%       
%       plotinfo(4).caption = 'Pressure';
%       plotinfo(4).plotprefix = 'p';
%       plotinfo(4).fnc = 'plotdata';
%       plotinfo(4).datecol = 'Date';
%       plotinfo(4).parameters = {'press_li7500_top_Avg'};
%       plotinfo(4).groupcol = [];
%       plotinfo(4).colors = {'b'};
%       plotinfo(4).markers = {'.'};
%       plotinfo(4).linestyles = {'-'};
%       plotinfo(4).scale = 'linear';
%       plotinfo(4).rotateaxis = 0;
%       plotinfo(4).ylim = [];
%       plotinfo(4).deblank = 0;
%       plotinfo(4).fn_xml = 'p.xml';
%       plotinfo(4).xsl = plot_xsl;
%       plotinfo(4).navigation = 'Pressure';
      
  case 'LNDB_HJA_WS1_EC_AVG'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'WS1 Met and Flux','../data'}];
      
      %define plot page title
      pagetitle = 'Watershed 1 Met and Flux';
      
      plotinfo(1).caption = 'Wind Speed';
      plotinfo(1).plotprefix = 'ws';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'WSpd_mean_top','WSpd_mean_sub'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g'};
      plotinfo(1).markers = {'.','o'};
      plotinfo(1).linestyles = {'-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'ws.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Wind Speed';
      
      plotinfo(2).caption = 'Wind Direction';
      plotinfo(2).plotprefix = 'wd';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'WDir_mean_sub_azcor','WDir_mean_top_azcor'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','g'};
      plotinfo(2).markers = {'o','o'};
      plotinfo(2).linestyles = {'',''};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [0 360];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'wd.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Wind Direction';
      
      plotinfo(3).caption = 'Wind Direction (Std)';
      plotinfo(3).plotprefix = 'wds';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'WDir_std_sub','WDir_std_top'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b','g'};
      plotinfo(3).markers = {'o','o'};
      plotinfo(3).linestyles = {'',''};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [0 180];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'wds.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'Wind Direction (Std)';
      
      plotinfo(4).caption = 'Uz (Avg)';
      plotinfo(4).plotprefix = 'uz';
      plotinfo(4).fnc = 'plotdata';
      plotinfo(4).datecol = 'Date';
      plotinfo(4).parameters = {'Uz_top_Avg','Uz_sub_Avg'};
      plotinfo(4).groupcol = [];
      plotinfo(4).colors = {'b','g'};
      plotinfo(4).markers = {'.','o'};
      plotinfo(4).linestyles = {'-','-'};
      plotinfo(4).scale = 'linear';
      plotinfo(4).rotateaxis = 0;
      plotinfo(4).ylim = [];
      plotinfo(4).deblank = 0;
      plotinfo(4).fn_xml = 'uz.xml';
      plotinfo(4).xsl = plot_xsl;
      plotinfo(4).navigation = 'Uz (Avg)';
      
      plotinfo(5).caption = 'Air Temperature (sonic)';
      plotinfo(5).plotprefix = 'tsnc';
      plotinfo(5).fnc = 'plotdata';
      plotinfo(5).datecol = 'Date';
      plotinfo(5).parameters = {'Ts_top_Avg','Ts_sub_Avg'};
      plotinfo(5).groupcol = [];
      plotinfo(5).colors = {'b','g'};
      plotinfo(5).markers = {'.','o'};
      plotinfo(5).linestyles = {'-','-'};
      plotinfo(5).scale = 'linear';
      plotinfo(5).rotateaxis = 0;
      plotinfo(5).ylim = [];
      plotinfo(5).deblank = 0;
      plotinfo(5).fn_xml = 'tsnc.xml';
      plotinfo(5).xsl = plot_xsl;
      plotinfo(5).navigation = 'Air Temperature (sonic)';
      
      plotinfo(6).caption = 'CO2';
      plotinfo(6).plotprefix = 'co2';
      plotinfo(6).fnc = 'plotdata';
      plotinfo(6).datecol = 'Date';
      plotinfo(6).parameters = {'CO2mmol_top_Avg'};
      plotinfo(6).groupcol = [];
      plotinfo(6).colors = {'b'};
      plotinfo(6).markers = {'.'};
      plotinfo(6).linestyles = {'-'};
      plotinfo(6).scale = 'linear';
      plotinfo(6).rotateaxis = 0;
      plotinfo(6).ylim = [];
      plotinfo(6).deblank = 0;
      plotinfo(6).fn_xml = 'co2.xml';
      plotinfo(6).xsl = plot_xsl;
      plotinfo(6).navigation = 'CO2';
      
      plotinfo(7).caption = 'H2O';
      plotinfo(7).plotprefix = 'h2o';
      plotinfo(7).fnc = 'plotdata';
      plotinfo(7).datecol = 'Date';
      plotinfo(7).parameters = {'H2Ommol_top_Avg'};
      plotinfo(7).groupcol = [];
      plotinfo(7).colors = {'b'};
      plotinfo(7).markers = {'.'};
      plotinfo(7).linestyles = {'-'};
      plotinfo(7).scale = 'linear';
      plotinfo(7).rotateaxis = 0;
      plotinfo(7).ylim = [];
      plotinfo(7).deblank = 0;
      plotinfo(7).fn_xml = 'h2o.xml';
      plotinfo(7).xsl = plot_xsl;
      plotinfo(7).navigation = 'H2O';
      
      plotinfo(8).caption = 'Pressure';
      plotinfo(8).plotprefix = 'p';
      plotinfo(8).fnc = 'plotdata';
      plotinfo(8).datecol = 'Date';
      plotinfo(8).parameters = {'press_li7500_top_Avg'};
      plotinfo(8).groupcol = [];
      plotinfo(8).colors = {'b'};
      plotinfo(8).markers = {'.'};
      plotinfo(8).linestyles = {'-'};
      plotinfo(8).scale = 'linear';
      plotinfo(8).rotateaxis = 0;
      plotinfo(8).ylim = [];
      plotinfo(8).deblank = 0;
      plotinfo(8).fn_xml = 'p.xml';
      plotinfo(8).xsl = plot_xsl;
      plotinfo(8).navigation = 'Pressure';
      
      plotinfo(9).caption = 'Global Radiation';
      plotinfo(9).plotprefix = 'kup';
      plotinfo(9).fnc = 'plotdata';
      plotinfo(9).datecol = 'Date';
      plotinfo(9).parameters = {'SR01Dn_Avg'};
      plotinfo(9).groupcol = [];
      plotinfo(9).colors = {'b'};
      plotinfo(9).markers = {'.'};
      plotinfo(9).linestyles = {'-'};
      plotinfo(9).scale = 'linear';
      plotinfo(9).rotateaxis = 0;
      plotinfo(9).ylim = [];
      plotinfo(9).deblank = 0;
      plotinfo(9).fn_xml = 'kup.xml';
      plotinfo(9).xsl = plot_xsl;
      plotinfo(9).navigation = 'Global Radiation';
      
      plotinfo(10).caption = 'Reflected (Downwelling)';
      plotinfo(10).plotprefix = 'kdown';
      plotinfo(10).fnc = 'plotdata';
      plotinfo(10).datecol = 'Date';
      plotinfo(10).parameters = {'SR01Up_Avg', 'IR01DnCo_Avg'};
      plotinfo(10).groupcol = [];
      plotinfo(10).colors = {'b','g'};
      plotinfo(10).markers = {'.','o'};
      plotinfo(10).linestyles = {'-','-'};
      plotinfo(10).scale = 'linear';
      plotinfo(10).rotateaxis = 0;
      plotinfo(10).ylim = [];
      plotinfo(10).deblank = 0;
      plotinfo(10).fn_xml = 'kdown.xml';
      plotinfo(10).xsl = plot_xsl;
      plotinfo(10).navigation = 'Reflected (Downwelling)';
      
      plotinfo(11).caption = 'Terrestrial Upwelling';
      plotinfo(11).plotprefix = 'idown';
      plotinfo(11).fnc = 'plotdata';
      plotinfo(11).datecol = 'Date';
      plotinfo(11).parameters = {'IR01UpCo_Avg'};
      plotinfo(11).groupcol = [];
      plotinfo(11).colors = {'b'};
      plotinfo(11).markers = {'.'};
      plotinfo(11).linestyles = {'-'};
      plotinfo(11).scale = 'linear';
      plotinfo(11).rotateaxis = 0;
      plotinfo(11).ylim = [];
      plotinfo(11).deblank = 0;
      plotinfo(11).fn_xml = 'idown.xml';
      plotinfo(11).xsl = plot_xsl;
      plotinfo(11).navigation = 'Terrestrial Upwelling';
      
      plotinfo(12).caption = 'Albedo';
      plotinfo(12).plotprefix = 'al';
      plotinfo(12).fnc = 'plotdata';
      plotinfo(12).datecol = 'Date';
      plotinfo(12).parameters = {'Albedo_AVG'};
      plotinfo(12).groupcol = [];
      plotinfo(12).colors = {'b'};
      plotinfo(12).markers = {'.'};
      plotinfo(12).linestyles = {'-'};
      plotinfo(12).scale = 'linear';
      plotinfo(12).rotateaxis = 0;
      plotinfo(12).ylim = [];
      plotinfo(12).deblank = 0;
      plotinfo(12).fn_xml = 'idown.xml';
      plotinfo(12).xsl = plot_xsl;
      plotinfo(12).navigation = 'Albedo';
      
  case 'LNDB_HJA_WS1_EC_MET_NR01'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'WS1 Met and Flux','../data'}];
      
      %define plot page title
      pagetitle = 'Watershed 1 Met and Flux';
      
      plotinfo(1).caption = 'Global Radiation';
      plotinfo(1).plotprefix = 'kup';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'SR01Up_Avg'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'kup.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Global Radiation';
      
  case 'LNDB_HJA_WS1_EC_TEMPPROF'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'WS1 Met and Flux','../data'}];
      
      %define plot page title
      pagetitle = 'Watershed 1 Met and Flux';
      
      plotinfo(1).caption = 'Air Temperature';
      plotinfo(1).plotprefix = 'ta';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'Tair_1m_AVG','Tair_4m_AVG','Tair_7m_AVG','Tair_12m_AVG','Tair_18m_AVG','Tair_23m_AVG','Tair_29m_AVG','Tair_37m_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','r','c','m','y','k','b'};
      plotinfo(1).markers = {'','','','','','','',''};
      plotinfo(1).linestyles = {'-','-','-','-','-','-','-','--'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'ta.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Air Temperature';
      
  case 'LNDB_HJA_WS1_EC2'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'WS1 Met and Flux','../data'}];
      
      %define plot page title
      pagetitle = 'Watershed 1 Met and Flux';
      
      plotinfo(1).caption = 'Wind Speed and Direction';
      plotinfo(1).plotprefix = 'wind';
      plotinfo(1).fnc = 'plotwind';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'WSpd_mean_sub','WDir_mean_sub'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'',''};
      plotinfo(1).markers = {'',''};
      plotinfo(1).linestyles = {'',''};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'wind.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Wind';
      
      plotinfo(2).caption = 'CO2 Concentration';
      plotinfo(2).plotprefix = 'co2_sub';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'CO2mmol_sub_Avg'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b'};
      plotinfo(2).markers = {'.'};
      plotinfo(2).linestyles = {'-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'co2_sub.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'CO2 (sub)';
      
      plotinfo(3).caption = 'H2O Vapor Concentration';
      plotinfo(3).plotprefix = 'h2o_sub';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'H2Ommol_sub_Avg'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b'};
      plotinfo(3).markers = {'.'};
      plotinfo(3).linestyles = {'-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'h2o_sub.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'H2O Vapor (sub)';
      
      plotinfo(4).caption = 'Soil/Water Temperature';
      plotinfo(4).plotprefix = 'tw';
      plotinfo(4).fnc = 'plotdata';
      plotinfo(4).datecol = 'Date';
      plotinfo(4).parameters = {'Ts_9_clea_AVG','Ts_9_shad_AVG','Twater_10_AVG'};
      plotinfo(4).groupcol = [];
      plotinfo(4).colors = {'b','g','c'};
      plotinfo(4).markers = {'.','o',''};
      plotinfo(4).linestyles = {'-','-','-'};
      plotinfo(4).scale = 'linear';
      plotinfo(4).rotateaxis = 0;
      plotinfo(4).ylim = [];
      plotinfo(4).deblank = 0;
      plotinfo(4).fn_xml = 'tw.xml';
      plotinfo(4).xsl = plot_xsl;
      plotinfo(4).navigation = 'Soil/Water Temperature';
    
  case 'LNDB_HJA_WS1_HYD_AVG'
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'WS1 Met and Flux','../data'}];
      
      %define plot page title
      pagetitle = 'Watershed 1 Met and Flux';
      
      plotinfo(1).caption = 'Water Temperature';
      plotinfo(1).plotprefix = 'tw';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'Ts_9_clea_AVG','Ts_9_shad_AVG','Twater_10_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','g','c'};
      plotinfo(1).markers = {'.','o',''};
      plotinfo(1).linestyles = {'-','-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'tw.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Water Temperature';
      
  case 'LNDB_HJA_WS1_MET_AVG'
      
      %append station-specific label and url to base navigation
     nav = [nav_base, ...
         {'WS1 Met and Flux','../data'}];
      
      %define plot page title
      pagetitle = 'Watershed 1 Met and Flux';
      
      plotinfo(1).caption = 'Pressure';
      plotinfo(1).plotprefix = 'p';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'Baro_Pres_AVG'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b'};
      plotinfo(1).markers = {'.'};
      plotinfo(1).linestyles = {'-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'p.xml';
      plotinfo(1).xsl = plot_xsl;
      plotinfo(1).navigation = 'Pressure';
      
      plotinfo(2).caption = 'Battery Supply Level';
      plotinfo(2).plotprefix = 'batt';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'logger_V_AVG'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b'};
      plotinfo(2).markers = {'.'};
      plotinfo(2).linestyles = {'-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'batt.xml';
      plotinfo(2).xsl = plot_xsl;
      plotinfo(2).navigation = 'Battery Supply Level';
      
      plotinfo(3).caption = 'Radiation';
      plotinfo(3).plotprefix = 'rad';
      plotinfo(3).fnc = 'plotdata';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'K_down_AVG','K_up_AVG','NetRad_AVG','CGR4_LWm2_AVG'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b','g','r','c'};
      plotinfo(3).markers = {'','','',''};
      plotinfo(3).linestyles = {'-','-','-','-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'rad.xml';
      plotinfo(3).xsl = plot_xsl;
      plotinfo(3).navigation = 'Radiation';
      
      plotinfo(4).caption = 'Sensor Temperature';
      plotinfo(4).plotprefix = 'tsen';
      plotinfo(4).fnc = 'plotdata';
      plotinfo(4).datecol = 'Date';
      plotinfo(4).parameters = {'Tgasinlet_AVG','CGR4_TmpC_AVG'};
      plotinfo(4).groupcol = [];
      plotinfo(4).colors = {'b','g'};
      plotinfo(4).markers = {'.','o'};
      plotinfo(4).linestyles = {'-','-'};
      plotinfo(4).scale = 'linear';
      plotinfo(4).rotateaxis = 0;
      plotinfo(4).ylim = [];
      plotinfo(4).deblank = 0;
      plotinfo(4).fn_xml = 'tsen.xml';
      plotinfo(4).xsl = plot_xsl;
      plotinfo(4).navigation = 'Sensor Temperature';
      
      plotinfo(5).caption = 'Air Temperature';
      plotinfo(5).plotprefix = 'ta';
      plotinfo(5).fnc = 'plotdata';
      plotinfo(5).datecol = 'Date';
      plotinfo(5).parameters = {'Tair_1m_AVG','Tair_4m_AVG','Tair_7m_AVG','Tair_12m_AVG','Tair_18m_AVG','Tair_23m_AVG','Tair_29m_AVG','Tair_37m_AVG'};
      plotinfo(5).groupcol = [];
      plotinfo(5).colors = {'b','g','r','c','m','y','k','m'};
      plotinfo(5).markers = {'','','','','','','','.'};
      plotinfo(5).linestyles = {'-','-','-','-','-','-','-','-'};
      plotinfo(5).scale = 'linear';
      plotinfo(5).rotateaxis = 0;
      plotinfo(5).ylim = [];
      plotinfo(5).deblank = 0;
      plotinfo(5).fn_xml = 'ta.xml';
      plotinfo(5).xsl = plot_xsl;
      plotinfo(5).navigation = 'Air Temperature';
      
      plotinfo(6).caption = 'Precipitation';
      plotinfo(6).plotprefix = 'ppt';
      plotinfo(6).fnc = 'plotdata';
      plotinfo(6).datecol = 'Date';
      plotinfo(6).parameters = {'Raingauge_TOT'};
      plotinfo(6).groupcol = [];
      plotinfo(6).colors = {'b'};
      plotinfo(6).markers = {'o'};
      plotinfo(6).linestyles = {''};
      plotinfo(6).scale = 'linear';
      plotinfo(6).rotateaxis = 0;
      plotinfo(6).ylim = [];
      plotinfo(6).deblank = 0;
      plotinfo(6).fn_xml = 'ppt.xml';
      plotinfo(6).xsl = plot_xsl;
      plotinfo(6).navigation = 'PPT';
          
   otherwise  %unmatched station id
      
      plotinfo = '';
      nav = [];
      pagetitle = '';
      
      
end