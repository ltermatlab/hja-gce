function [nav,titlestring,xsl_index,xsl_details,url_base] = harvest_info(id)
%Master harvest configuration information retrieval function for use with harvest_datapages_xml
%to provide resource-specific details for generating XML data distribution pages on a web site
%
%syntax: [nav,titlestring,xsl_index,xsl_details,url_base] = harvest_info(id)
%
%input:
%   id = harvest id for matching when multiple configurations are defined (string; default = 'demo')
%   pn_base = base file system path containing harvest data files to index (string; default = profile default)
%   subdir = array of subdirectories in pn_base to index (cell array of strings; default = profile default)
%
%output:
%   nav = nx2 cell array of strings containing navigation labels and links as parameter/value pairs (required)
%   titlestring = string to display as the index page title (required)
%   xsl_index = url for xsl to use for main index page (required; see [toolbox]/demo/harvest.xsl)
%   xsl_details = url for xsl to use for data set details page (required; see [toolbox]/demo/harvest_details.xsl')
%   url_base = base URL to use for creating download file links (required)
%
%notes:
%   1) to add support for a new station, copy the 'case' entry for the default case,
%      substitute a unique id for 'default', and edit the individual paths and settings accordingly
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

%set default id if omitted
if exist('id','var') ~= 1
   id = 'demo';
end

%define base naviation array of labels and urls for the target web site
nav_base = {'Home','http://gce-lter.marsci.uga.edu/', ...
   'GCE Data Toolbox','https://gce-svn.marsci.uga.edu/trac/GCE_Toolbox'};

%match id and return settings
switch id
   
   case 'demo'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'Demo','http://im.lternet.edu/project/MatlabandMetabase'}];
      
      %title for the index page
      titlestring = 'GCE Data Toolbox Harvest Demo';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = 'http://gce-lter.marsci.uga.edu/public/xsl/toolbox/harvest_index.xsl';
      xsl_details = 'http://gce-lter.marsci.uga.edu/public/xsl/toolbox/harvest_details.xsl';
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';     

   otherwise  %unmatched option - return null results
      
      nav = '';
      titlestring = '';
      xsl_index = '';
      xsl_details = '';
      url_base = '';
      
end

