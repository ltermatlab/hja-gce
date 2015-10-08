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

xslIndex = localpath('xslIndex');
xslDetails = localpath('xslDetails');
nav_base = localpath('nav_base');

%match id and return settings
switch id
   
   case 'LNDB_HJA_CenMet_105'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'CENMET','../data'}];
      
      %title for the index page
      titlestring = 'Central Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';   
      
   case 'LNDB_HJA_CenMet_115'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'CENMET','../data'}];
      
      %title for the index page
      titlestring = 'Central Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';  
      
    case 'LNDB_HJA_CenMet_160'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'CENMET','../data'}];
      
      %title for the index page
      titlestring = 'Central Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_HJA_CenMet_440'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'CENMET','../data'}];
      
      %title for the index page
      titlestring = 'Central Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
      case 'LNDB_HJA_CenMet_233_a_5min'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'CENMET','../data'}];
      
      %title for the index page
      titlestring = 'Central Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
      case 'LNDB_HJA_CenMet_233_a_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'CENMET','../data'}];
      
      %title for the index page
      titlestring = 'Central Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
      case 'LNDB_HJA_CenMet_233_a_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'CENMET','../data'}];
      
      %title for the index page
      titlestring = 'Central Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
    case 'LNDB_HJA_CS2MET_CLRG'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'CS2MET','../data'}];
      
      %title for the index page
      titlestring = 'Climatic Station Watershed 2';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
   case 'LNDB_HJA_CS2MET_104_105'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'CS2MET','../data'}];
      
      %title for the index page
      titlestring = 'Climatic Station Watershed 2';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
   case 'LNDB_HJA_CS2MET_104_110'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'CS2MET','../data'}];
      
      %title for the index page
      titlestring = 'Climatic Station Watershed 2';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../'; 
    
    case 'LNDB_HJA_CS2MET_104_115'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'CS2MET','../data'}];
      
      %title for the index page
      titlestring = 'Climatic Station Watershed 2';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
    case 'GREEN_GEM_001'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'GREEN','../data'}];
      
      %title for the index page
      titlestring = 'GREEN House Environmental Sensors';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
    case 'LNDB_HJA_GREENA_400_15min'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'GREEN','../data'}];
      
      %title for the index page
      titlestring = 'GREEN House Environmental Sensors';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
    case 'LNDB_HJA_GREENA_400_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'GREEN','../data'}];
      
      %title for the index page
      titlestring = 'GREEN House Environmental Sensors';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
    
    case 'LNDB_HJA_GREENB_401_15min'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'GREEN','../data'}];
      
      %title for the index page
      titlestring = 'GREEN House Environmental Sensors';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
    case 'LNDB_HJA_GREENB_401_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'GREEN','../data'}];
      
      %title for the index page
      titlestring = 'GREEN House Environmental Sensors';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
    case 'LNDB_HJA_GREEN_Combined'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'GREEN','../data'}];
      
      %title for the index page
      titlestring = 'GREEN House Environmental Sensors';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
    
    case 'LNDB_GsWs01_105'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'GSWS01','../data'}];
      
      %title for the index page
      titlestring = 'Gaging Station Watershed 1';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../'; 
      
    case 'LNDB_GsWs02_105'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'GSWS02','../data'}];
      
      %title for the index page
      titlestring = 'Gaging Station Watershed 2';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../'; 
      
   case 'LNDB_GsWs03_105'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'GSWS03','../data'}];
      
      %title for the index page
      titlestring = 'Gaging Station Watershed 3';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../'; 
      
  case 'LNDB_GsWs06_105'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'GSWS06','../data'}];
      
      %title for the index page
      titlestring = 'Gaging Station Watershed 6';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
   case 'LNDB_GsWs07_105'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'GSWS07','../data'}];
      
      %title for the index page
      titlestring = 'Gaging Station Watershed 7';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
   case 'LNDB_GsWs08_105'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'GSWS08','../data'}];
      
      %title for the index page
      titlestring = 'Gaging Station Watershed 8';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
    case 'LNDB_GsWs09_105'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'GSWS09','../data'}];
      
      %title for the index page
      titlestring = 'Gaging Station Watershed 9';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
   case 'LNDB_GsWs10_105'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'GSWS10','../data'}];
      
      %title for the index page
      titlestring = 'Gaging Station Watershed 10';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
   case 'LNDB_GsMack_105'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'GSMACK','../data'}];
      
      %title for the index page
      titlestring = 'Gaging Station at Mack Cr.';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
      case 'LNDB_GsWs01_115'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'GSWS01','../data'}];
      
      %title for the index page
      titlestring = 'Gaging Station Watershed 1';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../'; 
      
    case 'LNDB_GsWs02_115'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'GSWS02','../data'}];
      
      %title for the index page
      titlestring = 'Gaging Station Watershed 2';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../'; 
      
   case 'LNDB_GsWs03_115'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'GSWS03','../data'}];
      
      %title for the index page
      titlestring = 'Gaging Station Watershed 3';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../'; 
      
  case 'LNDB_GsWs06_115'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'GSWS06','../data'}];
      
      %title for the index page
      titlestring = 'Gaging Station Watershed 6';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
   case 'LNDB_GsWs07_115'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'GSWS07','../data'}];
      
      %title for the index page
      titlestring = 'Gaging Station Watershed 7';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
   case 'LNDB_GsWs08_115'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'GSWS08','../data'}];
      
      %title for the index page
      titlestring = 'Gaging Station Watershed 8';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
   case 'LNDB_GsWs10_115'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'GSWS10','../data'}];
      
      %title for the index page
      titlestring = 'Gaging Station Watershed 10';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
   case 'LNDB_GsMack_115'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'GSMACK','../data'}];
      
      %title for the index page
      titlestring = 'Gaging Station at Mack Cr.';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
      case 'LNDB_HJA_Hi15_207_105'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'HI15','../data'}];
      
      %title for the index page
      titlestring = 'HI15 Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
   case 'LNDB_HJA_Hi15_207_440'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'HI15','../data'}];
      
      %title for the index page
      titlestring = 'HI15 Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
   case 'LNDB_HJA_Hi15_208_115'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'HI15','../data'}];
      
      %title for the index page
      titlestring = 'HI15 Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
   case 'LNDB_HJA_Hi15_208_440'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'HI15','../data'}];
      
      %title for the index page
      titlestring = 'HI15 Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
   case 'LNDB_HJA_LOLO_201_103'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'LOLO','../data'}];
      
      %title for the index page
      titlestring = 'Lower Lookout';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
   case 'LNDB_HJA_LOLO_201_107'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'LOLO','../data'}];
      
      %title for the index page
      titlestring = 'Lower Lookout';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
   case 'LNDB_HJA_LOMA_203_103'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'LOMA','../data'}];
      
      %title for the index page
      titlestring = 'Lower Lookout/Mack';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
   case 'LNDB_HJA_LOMA_203_107'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'LOMA','../data'}];
      
      %title for the index page
      titlestring = 'Lower Lookout/Mack';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
   case 'LNDB_HJA_LOUP_204_103'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'LOUP','../data'}];
      
      %title for the index page
      titlestring = 'Lower Upper';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
    case 'LNDB_HJA_LOUP_204_107'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'LOUP','../data'}];
      
      %title for the index page
      titlestring = 'Lower Upper';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
   case 'LNDB_HJA_MCUP_205_103'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'MCUP','../data'}];
      
      %title for the index page
      titlestring = 'McRae Upper';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
   case 'LNDB_HJA_MCUP_205_107'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'MCUP','../data'}];
      
      %title for the index page
      titlestring = 'McRae Upper';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
           
   case 'LNDB_HJA_PHRSC'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'PHRSC','../data'}];
      
      %title for the index page
      titlestring = 'Primet Historic Radiation Shield Comparison';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../'; 
      
  case 'LNDB_HJA_PHRSC_2'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'PHRSC','../data'}];
      
      %title for the index page
      titlestring = 'Primet Historic Radiation Shield Comparison';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_HJA_PriMet_226_105_arch1'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %title for the index page
      titlestring = 'Primary Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';  
      
  case 'LNDB_HJA_PriMet_226_105'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %title for the index page
      titlestring = 'Primary Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';  
      
  case 'LNDB_HJA_PriMet_226_a_5min'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %title for the index page
      titlestring = 'Primary Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../'; 
      
  case 'LNDB_HJA_PriMet_226_a_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %title for the index page
      titlestring = 'Primary Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../'; 
      
  case 'LNDB_HJA_PriMet_226_a_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %title for the index page
      titlestring = 'Primary Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../'; 
      
  case 'LNDB_HJA_PriMet_229_a_5min'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %title for the index page
      titlestring = 'Primary Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../'; 
      
  case 'LNDB_HJA_PriMet_229_a_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %title for the index page
      titlestring = 'Primary Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_HJA_PriMet_229_a_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %title for the index page
      titlestring = 'Primary Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../'; 
      
   case 'LNDB_HJA_PriMet_230_a_5min'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %title for the index page
      titlestring = 'Primary Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../'; 
      
  case 'LNDB_HJA_PriMet_230_a_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %title for the index page
      titlestring = 'Primary Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_HJA_PriMet_230_a_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %title for the index page
      titlestring = 'Primary Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
   case 'LNDB_HJA_PriMet_229_b_5min'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %title for the index page
      titlestring = 'Primary Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../'; 
      
  case 'LNDB_HJA_PriMet_229_b_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %title for the index page
      titlestring = 'Primary Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_HJA_PriMet_229_b_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %title for the index page
      titlestring = 'Primary Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../'; 
      
  case 'LNDB_HJA_PriMet_226_115_a'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %title for the index page
      titlestring = 'Primary Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../'; 
      
  case 'LNDB_HJA_PriMet_226_160_arch1'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %title for the index page
      titlestring = 'Primary Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'fetch_primet_226_160_a'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %title for the index page
      titlestring = 'Primary Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../'; 
      
  case 'LNDB_HJA_PriMet_105'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %title for the index page
      titlestring = 'Primary Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';   
      
      case 'LNDB_HJA_PriMet_230_105'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %title for the index page
      titlestring = 'Primary Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';  
      
   case 'LNDB_HJA_PriMet_115_arch1'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %title for the index page
      titlestring = 'Primary Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';  
      
      case 'LNDB_HJA_PriMet_230_115'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %title for the index page
      titlestring = 'Primary Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';  
      
    case 'LNDB_HJA_PriMet_160'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %title for the index page
      titlestring = 'Primary Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
      case 'LNDB_HJA_PriMet_230_160'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %title for the index page
      titlestring = 'Primary Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';  
      
  case 'LNDB_HJA_PriMet_440'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %title for the index page
      titlestring = 'Primary Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
      case 'LNDB_HJA_PriMet_230_440'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'PRIMET','../data'}];
      
      %title for the index page
      titlestring = 'Primary Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
   case 'LNDB_HJA_RS02_90_5min'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 02','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 02';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
    case 'LNDB_HJA_RS02_90_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 02','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 02';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
    case 'LNDB_HJA_RS02_90_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 02','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 02';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
	  
	case 'LNDB_HJA_RS04_91_5min'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 04','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 04';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
    case 'LNDB_HJA_RS04_91_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 04','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 04';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
    case 'LNDB_HJA_RS04_91_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 04','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 04';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
    case 'LNDB_HJA_RS12_94_5min'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 12','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 12';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
    case 'LNDB_HJA_RS12_94_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 12','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 12';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
    case 'LNDB_HJA_RS12_94_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 12','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 12';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
    case 'LNDB_HJA_RS20_95_5min'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 20','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 20';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
    case 'LNDB_HJA_RS20_95_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 20','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 20';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
    case 'LNDB_HJA_RS20_95_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 20','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 20';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
   case 'LNDB_HJA_RS26_96_5min'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 26','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 26';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
    case 'LNDB_HJA_RS26_96_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 26','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 26';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
    case 'LNDB_HJA_RS26_96_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 26','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 26';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
   case 'LNDB_HJA_RS02_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 02','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 02';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../'; 
      
   case 'LNDB_HJA_RS02_6hr'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 02','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 02';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../'; 
      
  case 'LNDB_HJA_RS02_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 02','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 02';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';  
      
  case 'LNDB_HJA_RS04_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 04','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 04';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';  
      
  case 'LNDB_HJA_RS04_6hr'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 04','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 04';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_HJA_RS04_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 04','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 04';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../'; 
      
  case 'LNDB_HJA_RS05_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 05','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 05';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_HJA_RS05_6hr'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 05','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 05';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_HJA_RS05_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 05','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 05';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_HJA_RS10_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 10','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 10';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_HJA_RS10_6hr'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 10','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 10';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_HJA_RS10_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 10','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 10';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_HJA_RS12_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 12','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 12';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_HJA_RS12_6hr'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 12','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 12';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_HJA_RS12_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 12','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 12';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_HJA_RS20_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 20','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 20';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_HJA_RS20_6hr'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 20','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 20';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_HJA_RS20_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 20','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 20';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_HJA_RS26_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 26','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 26';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_HJA_RS26_6hr'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 26','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 26';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_HJA_RS26_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 26','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 26';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_HJA_RS38_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 38','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 38';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_HJA_RS38_6hr'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 38','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 38';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_HJA_RS38_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 38','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 38';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_HJA_RS86_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 86','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 86';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_HJA_RS86_6hr'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 86','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 86';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_HJA_RS86_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 86','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 86';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_HJA_RS89_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 89','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 89';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_HJA_RS89_6hr'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 89','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 89';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_HJA_RS89_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'RefStand 89','../data'}];
      
      %title for the index page
      titlestring = 'Reference Stand 89';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
           
  case 'LNDB_HJA_UplMet_105'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'UPLMET','../data'}];
      
      %title for the index page
      titlestring = 'Upper Lookout Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';   
      
   case 'LNDB_HJA_UplMet_115'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'UPLMET','../data'}];
      
      %title for the index page
      titlestring = 'Upper Lookout Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';  
      
    case 'LNDB_HJA_UplMet_160'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'UPLMET','../data'}];
      
      %title for the index page
      titlestring = 'Upper Lookout Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_HJA_UplMet_440'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'UPLMET','../data'}];
      
      %title for the index page
      titlestring = 'Upper Lookout Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_HJA_hagg_01_TmpCnd_MP1'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'STREAMCARBON','../data'}];
      
      %title for the index page
      titlestring = 'Stream Carbon Team WS01';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../'; 
      
   case 'LNDB_HJA_hagg_01_TmpCnd_MP2'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'STREAMCARBON','../data'}];
      
      %title for the index page
      titlestring = 'Stream Carbon Team WS01';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_VanMet_228_105'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'VANMET','../data'}];
      
      %title for the index page
      titlestring = 'Vanilla Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';   
      
  case 'LNDB_VanMet_228_115'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'VANMET','../data'}];
      
      %title for the index page
      titlestring = 'Vanilla Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_VanMet_228_160'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'VANMET','../data'}];
      
      %title for the index page
      titlestring = 'Vanilla Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_VanMet_228_440'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'VANMET','../data'}];
      
      %title for the index page
      titlestring = 'Vanilla Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';  
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      case 'LNDB_HJA_VanMet_231_a_5min'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'VANMET','../data'}];
      
      %title for the index page
      titlestring = 'Vanilla Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';   
      
      case 'LNDB_HJA_VanMet_231_a_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'VANMET','../data'}];
      
      %title for the index page
      titlestring = 'Vanilla Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';   
      
      case 'LNDB_HJA_VanMet_231_a_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'VANMET','../data'}];
      
      %title for the index page
      titlestring = 'Vanilla Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';

  case 'LNDB_VanMet_232_a_5min'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'VANMET','../data'}];
      
      %title for the index page
      titlestring = 'Vanilla Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../'; 

  case 'LNDB_VanMet_232_a_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'VANMET','../data'}];
      
      %title for the index page
      titlestring = 'Vanilla Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../'; 

  case 'LNDB_VanMet_232_a_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'VANMET','../data'}];
      
      %title for the index page
      titlestring = 'Vanilla Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';  
      
   case 'LNDB_VanMet_232_b_5min'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'VANMET','../data'}];
      
      %title for the index page
      titlestring = 'Vanilla Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../'; 

    case 'LNDB_VanMet_232_b_hrly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'VANMET','../data'}];
      
      %title for the index page
      titlestring = 'Vanilla Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../'; 

   case 'LNDB_VanMet_232_b_dly'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'VANMET','../data'}];
      
      %title for the index page
      titlestring = 'Vanilla Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';    

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
  case 'LNDB_VanMet_231_105'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'VANMET','../data'}];
      
      %title for the index page
      titlestring = 'Vanilla Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';   
      
  case 'LNDB_VanMet_231_115'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'VANMET','../data'}];
      
      %title for the index page
      titlestring = 'Vanilla Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_VanMet_231_160'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'VANMET','../data'}];
      
      %title for the index page
      titlestring = 'Vanilla Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_VanMet_231_440'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'VANMET','../data'}];
      
      %title for the index page
      titlestring = 'Vanilla Met Station';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';  

      
  case 'LNDB_VARMET_301_105'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'VARA','../data'}];
      
      %title for the index page
      titlestring = 'Vanila Rain Gage and Met';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';  
      
   case 'LNDB_VARMET_301_115'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'VARA','../data'}];
      
      %title for the index page
      titlestring = 'Vanilla Rain Gage and Met';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
    
    case 'LNDB_VARA_301_105'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'VARA','../data'}];
      
      %title for the index page
      titlestring = 'Vanila Rain Gage';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';  
      
   case 'LNDB_VARA_301_115'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'VARA','../data'}];
      
      %title for the index page
      titlestring = 'Vanilla Rain Gage';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
%   case 'LNDB_VARA_301_160'
%       
%       %station-specific navigation label and url to append to nav_base
%       nav = [nav_base, ...
%          {'VARA','../data'}];
%       
%       %title for the index page
%       titlestring = 'Vanilla Rain Gage';
%       
%       %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
%       xsl_index = xslIndex;
%       xsl_details = xslDetails;
%       
%       %base url for downloads (subdir and filenames will be appended)
%       url_base = '../';  

    case 'LNDB_HJA_WS1_EC_MET_NR01'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'WS1 Met and Flux','../data'}];
      
      %title for the index page
      titlestring = 'Watershed 1 Met and Flux';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
    
    case 'LNDB_HJA_WS1_EC_AVG'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'WS1 Met and Flux','../data'}];
      
      %title for the index page
      titlestring = 'Watershed 1 Met and Flux';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../'; 
      
   case 'LNDB_HJA_WS1_EC_AVG_arch1'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'WS1 Met and Flux','../data'}];
      
      %title for the index page
      titlestring = 'Watershed 1 Met and Flux';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../'; 
      
  case 'LNDB_HJA_WS1_EC_TEMPPROF'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'WS1 Met and Flux','../data'}];
      
      %title for the index page
      titlestring = 'Watershed 1 Met and Flux';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../';
      
  case 'LNDB_HJA_WS1_EC2'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'WS1 Met and Flux','../data'}];
      
      %title for the index page
      titlestring = 'Watershed 1 Met and Flux';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../'; 
      
  case 'LNDB_HJA_WS1_HYD_AVG'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'WS1 Met and Flux','../data'}];
      
      %title for the index page
      titlestring = 'Watershed 1 Met and Flux';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../'; 
      
  case 'LNDB_HJA_WS1_MET_AVG'
      
      %station-specific navigation label and url to append to nav_base
      nav = [nav_base, ...
         {'WS1 Met and Flux','../data'}];
      
      %title for the index page
      titlestring = 'Watershed 1 Met and Flux';
      
      %xsl urls for rendering web page body (must contain a url to a master web scaffolding stylesheet to import)
      xsl_index = xslIndex;
      xsl_details = xslDetails;
      
      %base url for downloads (subdir and filenames will be appended)
      url_base = '../'; 

   otherwise  %unmatched option - return null results
      
      nav = '';
      titlestring = '';
      xsl_index = '';
      xsl_details = '';
      url_base = '';
      
end

