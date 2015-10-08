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

%define base navigation for the entire web site
nav_base = {'Home','http://gce-lter.marsci.uga.edu/', ...
    'GCE Data Toolbox','https://gce-svn.marsci.uga.edu/trac/GCE_Toolbox'};
 
%match id to plot profile
switch id
   
   case 'demo'  %3-plot GCE example
      
      %append station-specific label and url to base navigation
      nav = [nav_base, ...
         {'Demo','http://im.lternet.edu/project/MatlabandMetabase'}, ...
         {'Data','../data/index.xml'}];
      
      %define plot page title
      pagetitle = 'GCE Data Toolbox Harvest Demo';
      
      %parameterize plot options (1 structure dimension per plot)
      plotinfo(1).caption = 'Air Temperature and Precipitation';
      plotinfo(1).plotprefix = 'airtemp_precip';
      plotinfo(1).fnc = 'plotdata';
      plotinfo(1).datecol = 'Date';
      plotinfo(1).parameters = {'Temp_Air','Precipitation'};
      plotinfo(1).groupcol = [];
      plotinfo(1).colors = {'b','k'};
      plotinfo(1).markers = {'o','^'};
      plotinfo(1).linestyles = {'-','-'};
      plotinfo(1).scale = 'linear';
      plotinfo(1).rotateaxis = 0;
      plotinfo(1).ylim = [-5 40];
      plotinfo(1).deblank = 0;
      plotinfo(1).fn_xml = 'airtemp_precip.xml';
      plotinfo(1).xsl = 'http://gce-lter.marsci.uga.edu/public/xsl/toolbox/harvest_plots.xsl';
      plotinfo(1).navigation = 'Air Temp/Precip';
      
      plotinfo(2).caption = 'PAR, Solar, Humidity, Barometric Pressure';
      plotinfo(2).plotprefix = 'par_solar_rh_baro';
      plotinfo(2).fnc = 'plotdata';
      plotinfo(2).datecol = 'Date';
      plotinfo(2).parameters = {'Total_PAR','Total_Solar_Rad','Humidity','Baro_Press'};
      plotinfo(2).groupcol = [];
      plotinfo(2).colors = {'b','k','c','g'};
      plotinfo(2).markers = {'o','^','s','<'};
      plotinfo(2).linestyles = {'-','-','-','-'};
      plotinfo(2).scale = 'linear';
      plotinfo(2).rotateaxis = 0;
      plotinfo(2).ylim = [0 2000];
      plotinfo(2).deblank = 0;
      plotinfo(2).fn_xml = 'par_solar_rh_baro.xml';
      plotinfo(2).xsl = 'http://gce-lter.marsci.uga.edu/public/xsl/toolbox/harvest_plots.xsl';
      plotinfo(2).navigation = 'PAR/Solar/RH/BP';
      
      plotinfo(3).caption = 'Wind Speed and Direction';
      plotinfo(3).plotprefix = 'wind';
      plotinfo(3).fnc = 'plotwind';
      plotinfo(3).datecol = 'Date';
      plotinfo(3).parameters = {'Wind_Speed','Wind_Dir'};
      plotinfo(3).groupcol = [];
      plotinfo(3).colors = {'b','k'};
      plotinfo(3).markers = {'',''};
      plotinfo(3).linestyles = {'-','-'};
      plotinfo(3).scale = 'linear';
      plotinfo(3).rotateaxis = 0;
      plotinfo(3).ylim = [0 20];
      plotinfo(3).deblank = 0;
      plotinfo(3).fn_xml = 'wind.xml';
      plotinfo(3).xsl = 'http://gce-lter.marsci.uga.edu/public/xsl/toolbox/harvest_plots.xsl';
      plotinfo(3).navigation = 'Wind';
      
   otherwise  %unmatched station id
      
      plotinfo = '';
      nav = [];
      pagetitle = '';
      
end