function msg = harvest_webplots_xml(fn_data,pn_data,pn_plots,harvest_id,interval,html,date_start,date_end,nullflagsopt,visible)
%Generates web plots for harvested data using stored plot configuration information for a station
%
%syntax:  msg = harvest_webplots_xml(fn_data,pn_data,pn_plots,harvest_id,interval,html,date_start,date_end,nullflagsopt,visible)
%
%input:
%  fn_data = filename of data structure to plot (string - required)
%  pn_data = pathname where fn is located (string - required)
%  pn_plots = pathname where plots and indices should be stored (string - required)
%  harvest_id = id of a harvest station configuration profile in harvest_plot_info.m
%     (string - optional; default = 'default')
%  interval = plotting interval
%    'year' = 1 plot/year
%    'month' = 1 plot/month (default)
%    'week' = 1 plot/week
%    'day' = 1 plot/day
%  html = option to transform the xml plot to html automatically (resulting in both .xml and .html files)
%    0 = no (default)
%    1 = yes
%  date_start = starting date for plots (optional - default = automatic based on data set period)
%  date_end = ending date for plots  (optional - default = automatic based on data set period)
%  nullflags = option to null flags prior to plotting (0 = no/default, character array = flags to null)
%    (default = 'I' to null invalid values but retain other flagged values)
%  visible = plot display option
%    'on' = display plot on the console
%    'off' = do not display (default)
%
%output:
%  msg = status message
%
%(c)2004-2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
%
%This file is part of the GCE Data Toolbox for MATLAB(r) software library.
%
%The GCE Data Toolbox is free software: you can redistribute it and/or modify it under the terms
%of the GNU General Public License as published by the Free Software Foundation, either version 3
%of the License, or (at your option) any later version.
%
%The GCE Data Toolbox is distributed in the hope that it will be useful, but WITHOUT ANY
%WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
%PURPOSE. See the GNU General Public License for more details.
%
%You should have received a copy of the GNU General Public License along with The GCE Data Toolbox
%as 'license.txt'. If not, see <http://www.gnu.org/licenses/>.
%
%contact:
%  Wade Sheldon
%  GCE-LTER Project
%  Department of Marine Sciences
%  University of Georgia
%  Athens, GA 30602-3636
%  sheldon@uga.edu
%
%last modified: 08-Jul-2014

%init output
msg = '';

if nargin >= 3 && ischar(fn_data) && ischar(pn_data) && ischar(pn_plots)
   
    %set default plot visibility if omitted
    if exist('visible','var') ~= 1 || isempty(visible) || ~ischar(visible) || ~strcmpi(visible,'off')
        visible = 'off';
    end

   %validate data path
   if isdir(pn_data)
      pn_data = clean_path(pn_data);
   else
      pn_data = '';
   end
   
   %validate plot path
   if isdir(pn_plots)
      pn_plots = clean_path(pn_plots);
   else
      pn_plots = '';
   end
   
   %check for valid paths and data file
   if ~isempty(pn_data) && ~isempty(pn_plots) && exist([pn_data,filesep,fn_data],'file') == 2
      
      %generate filename prefix and xml index name from base filename
      [tmp,fn_prefix] = fileparts(fn_data);
      fn_xml = [fn_prefix,'.xml'];
      
      %set default harvest id if omitted
      if exist('harvest_id','var') ~= 1 || ~ischar(harvest_id) || isempty(harvest_id)
         harvest_id = 'demo';
      end
      
      %set default flag option if omitted
      if exist('nullflagsopt','var') ~= 1
         nullflagsopt = 'I';
      end
      
      %set default interval if omitted
      if exist('interval','var') ~= 1
         interval = 'month';
      end
      
      %set default start date if omitted, otherwise convert to numeric serial date
      if exist('date_start','var') ~= 1
         date_start = [];
      elseif ischar(date_start)
         date_start = datenum(date_start);
      end
      
      %set default end date if omitted, otherwise convert to numeric serial date
      if exist('date_end','var') ~= 1
         date_end = [];
      elseif ischar(date_end)
         date_end = datenum(date_end);
      end
      
      %set default html option if omitted
      if exist('html','var') ~= 1 || html ~= 1
         html = 0;
      end
      
      %retrieve plot info from profile
      [plotinfo,nav,pagetitle] = harvest_plot_info(harvest_id);
      
      %check for new query field, add if not present
      if ~isfield(plotinfo,'query')
         plotinfo(1).query = [];
      end
      
      %check for matching profile in harvest_plot_info.m
      if ~isempty(plotinfo) && ~isempty(nav)
         
         %revise data index url if html mode
         if html == 1
            nav = strrep(nav,'/data/index.xml','/data/index.html');
         end
         
         %load the data file
         try
            v = load([pn_data,filesep,fn_data],'-mat');
         catch
            v = struct('null','');
         end
         
         %check for default data structure variable
         if isfield(v,'data') && gce_valid(v.data)
            s = v.data;
         else
            s = [];
            flds = fieldnames(v);  %get list of all variables in file
            for cnt = 1:length(flds)
               if gce_valid(v.(flds{cnt}))
                  s = v.(flds{cnt});  %return first valid data structure
                  break
               end
            end
         end
         
         %check for valid structure variable
         if ~isempty(s)
            
            %apply flag removal option
            if nullflagsopt ~= 0
               s = nullflags(s,nullflagsopt);
            end
            
            %fill in missing start/end dates if present
            dt = get_studydates(s);
            
            if isempty(date_start) && ~isempty(dt)
               date_start = min(no_nan(dt));
            end
            
            if isempty(date_end) && ~isempty(dt)
               date_end = max (no_nan(dt));
            end
            
            %check for valid start/end dates
            if ~isempty(date_start) && ~isempty(date_end)
               
               %generate plots
               for n = 1:length(plotinfo)
                  
                  %generate plot using options in profile
                  p = plotinfo(n);
                  fnc = p.fnc;
                  
                  %check for query, subset data
                  if ~isempty(p.query)
                     [s_tmp,msg2] = querydata(s,p.query);
                  else
                     s_tmp = s;
                  end
                  
                  %check for return data
                  if ~isempty(s_tmp)
                     
                     %use specific plotting function
                     switch fnc
                        
                        case 'plotdata'  %standard x vs yy
                           
                           if ~strcmp(interval,'year')
                              [msg2,h_fig] = plotdata(s_tmp,p.datecol,p.parameters,p.colors,p.markers,p.linestyles,0,4,p.scale,p.rotateaxis, ...
                                 0,1,1,p.deblank,p.ylim,visible);
                           else
                              [msg2,h_fig] = plotdata(s_tmp,p.datecol,p.parameters,p.colors,repmat({''},1,length(p.colors)),p.linestyles,0,4,p.scale,p.rotateaxis, ...
                                 0,1,1,p.deblank,p.ylim,visible);
                           end
                           
                           if ~isempty(h_fig)
                              ax = axis;
                              axis([date_start,date_end,ax(3:4)]);
                           end
                           
                        case 'plotwind'  %wind speed and direction plot
                           
                           if ~strcmp(interval,'year')
                              [msg2,h_fig] = plotwind(s_tmp,p.datecol,p.parameters{1},p.parameters{2},p.ylim,[date_start,date_end],p.deblank,1,'kd:','b-',4,visible);
                           else
                              [msg2,h_fig] = plotwind(s_tmp,p.datecol,p.parameters{1},p.parameters{2},p.ylim,[date_start,date_end],p.deblank,1,'k-','b-',4,visible);
                           end
                           
                        case 'plotgroups'  %grouped plot
                           
                           if ~strcmp(interval,'year')
                              [msg2,h_fig] = plotgroups(s_tmp,p.datecol,p.parameters{1},p.groupcol,30,p.colors,p.markers,p.linestyles,0,4, ...
                                 p.rotateaxis,p.scale,1,visible);
                           else
                              [msg2,h_fig] = plotgroups(s_tmp,p.datecol,p.parameters{1},p.groupcol,30,p.colors,repmat({''},1,length(p.colors)),p.linestyles,0,4, ...
                                 p.rotateaxis,p.scale,1,visible);
                           end
                           
                           if ~isempty(h_fig)
                              ax = axis;
                              axis([date_start,date_end,ax(3:4)]);
                           end
                           
                        otherwise  %unsupported
                           
                           msg2 = 'unsupported plot function';
                           h_fig = [];
                           
                     end
                     
                  else  %bad query
                     h_fig = [];
                  end
                  
                  %check for plotted figure
                  if ~isempty(h_fig)
                     
                     %set default page title in omitted
                     if ~isempty(pagetitle)
                        titlestr = [pagetitle,' - ',p.caption];
                     else
                        titlestr = p.caption;
                     end
                     
                     %set file extension for index based on html mode
                     if html == 1
                        fn_ext = '.html';
                     else
                        fn_ext = '.xml';
                     end
                     
                     %generate plot index
                     if length(plotinfo) > 1
                        fn_xml_plot = [fn_prefix,'_',p.fn_xml];
                     else  %single plot - use index name instead of parameter name scheme
                        fn_xml_plot = [fn_prefix,'.xml'];
                     end
                     dateplot2xml(3,260,1,interval,[fn_prefix,'_',p.plotprefix],fn_xml_plot,[fn_prefix,fn_ext], ...
                        pn_plots,titlestr,p.caption,p.xsl,nav,'png',h_fig);
                     
                     %close plot figure
                     delete(h_fig)
                     
                     %transform xml to html
                     if html == 1
                        [pn_html,fn_html] = fileparts([pn_plots,filesep,fn_xml_plot]);  %get base filename
                        xslt([pn_plots,filesep,fn_xml_plot],p.xsl,[pn_html,filesep,fn_html,'.html']);  %transform
                     end
                     
                  else
                     msg = char(msg,['errors occurred generating plot ',int2str(n),': ',msg2]);
                  end
                  
               end
               
               %generate combination plot
               if isempty(msg) && length(plotinfo) > 1

                  %get plot metadata
                  p = plotinfo;
                  prefix_array = {p.plotprefix};
                  prefix_array = concatcellcols([repmat({fn_prefix},length(prefix_array),1),prefix_array(:)],'_');
                  caption_array = {p.caption};
                  xml_array = {p.fn_xml};
                  nav_array = {p.navigation};
                  
                  %check for html mode
                  if html == 1
                     xml_array = strrep(xml_array,'.xml','.html'); %convert .xml to .html for html mode
                     nav_array = strrep(nav_array,'../index.xml','../index.html');
                  end
                  
                  %generate xml file array
                  xml_array = concatcellcols([repmat({fn_prefix},length(prefix_array),1),xml_array(:)],'_');
                  
                  %merge dateplots and generate summary xml file
                  merge_dateplots_xml(prefix_array,xml_array,caption_array,nav_array,fn_xml,pn_plots,pagetitle,plotinfo(1).xsl,nav,html,'png');
                  
                  %check for plot index errors and transform xml to html
                  if exist([pn_plots,filesep,fn_xml],'file') ~= 2
                     msg = 'an error occurred merging the plots to create a plot index file';
                  elseif html == 1
                     fn_html = strrep(fn_xml,'.xml','.html');
                     xslt([pn_plots,filesep,fn_xml],plotinfo(1).xsl,[pn_plots,filesep,fn_html]);
                  end
                  
               end
               
            else
               msg = 'could not determine starting and ending dates for the data structure';
            end
            
         else
            %check for message from querydata
            if isempty(msg)
               msg = ['could not identify a suitable data structure in ''',pn_data,''''];
            end
         end
         
      else
         msg = ['no profile in ''harvest_plot_info.m'' matched ''',harvest_id,''''];
      end
      
   else  %bad paths or file
      
      if isempty(pn_data)
         msg = 'invalid data path';
      elseif isempty(pn_plots)
         msg = 'invalid plot path';
      else
         msg = ['invalid data file: ',fn_data,' is not present in ',pn_data];
      end
      
   end
   
else
   msg = 'too few arguments for function';
end