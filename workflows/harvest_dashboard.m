function [msg,s_xml] = harvest_dashboard(s,pn,time_offset,fn_xml,nav,plot_prefix,xsl_url,html,intervals,cols,thumbnail_size,plotoptions)
%Generates plots and an XML file describing status of each variable to support harvest dashboard web page development
%
%syntax: [msg,s_xml] = harvest_dashboard(s,pn,time_offset,fn_xml,nav,plot_prefix,xsl_url,html,intervals,cols,thumbnail_size,plotoptions)
%
%input:
%  s = GCE Data Structure to report on (struct or string filename; required)
%  pn = path for saving plots and the XML status page (char; required)
%  time_offset = time offset in hours between the system clock and station clock for determining time since
%    the last record (number; required; e.g. 5 for system clock in EST and station clock in UTC)
%  fn_xml = filename(s) and labels for XML status page(s) (2-column cell array; optional; 
%    default = {'index.xml','All Variables';'index2.xml','Selected Variables'})
%  nav = 2-column cell array of navigation labels and links to display on the rendered web page
%    (cell array; optional; default = '')
%  plot_prefix = prefix for plot files (char; optional; default = '')
%  xsl_url = URL(s) for an XSL stylesheet for rendering the XML as a webpage (char or cell array matching fn_xml;
%     optional; default = {'http://gce-lter.marsci.uga.edu/public/xsl/toolbox/harvest_dashboard.xsl'; ...
%         'http://gce-lter.marsci.uga.edu/public/xsl/toolbox/harvest_dashboard_select.xsl'}
%  html = option to generate an HTML file using xsl_url (integer; optional; 0 = no, 1 = yes/default)
%  intervals = three-column cell array of intervals to analyze and plot for each variable, with corresponding
%     percentage limits for missing and/or flagged values for determining yellow or red status. Valid
%     interval settings are 'hour', 'day', 'week', 'month', 'year' and 'all' for all observations, e.g.
%     default = {'day',5,50;'week',5,25;'month',10,25}
%  cols = array of column names or numbers to report on (numeric or cell array; optional;
%     default = all data/calculation columns)
%  thumbnail_size = width of thumbnail images in pixels (integer; optional; default = 250)
%  plotoptions = structure containing plot options with fields:
%     'Color' = RGC color array (3-element array of values between 0-1) - default = [0 0 1] for blue
%     'LineStyle' = line style (character array; '-','--',':','-.','none') - default = '-'
%     'LineWidth' = line width in pixels (number) - default = 1
%     'Marker' = marker symbol (character array: '+','o','*','.','x','square','diamond','v','^','>','<',
%        'pentagram','hexagram','none') - default = 'o'
%     'MarkerSize' = marker size in points - default = 5
%     'MarkerEdgeColor' = marker edge color (3-element RGB array) - default = [0 0 1]
%     'MarkerFaceColor' = marker face color (3-element RGB array) - default = [0 0 1]
%     'FigureWidth' = figure width in pixels (default = 900)
%     'FigureHeight' = figure height in pixels (default = 600)
%
%output:
%  msg = text of any error messages
%
%notes:
%  1) pad_date_gaps should be called prior to harvest_dashboard so missing values are properly tabulated
%  2) 'Q' and 'I' flags are assumed for questionable and invalid values, resp., so if other flag
%     conventions are used the flags should be mapped to 'Q' and 'I' using flag_replace() prior to
%     calling harvest_dashboard() for best results
%  3) the data set will be filtered based on the maximum interval prior to plot generation for accurate
%     assessment of flagged and missing values and determination of Y axis range
%  4) to generate multiple XSLT views of the report, specify multiple fn_xml and xsl_url options, e.g.
%     fn_xml = {'index.xml';'index2.xml'}
%     xsl_url = {'http://gce-lter.marsci.uga.edu/public/xsl/toolbox/harvest_dashboard.xsl'; ...
%        'http://gce-lter.marsci.uga.edu/public/xsl/toolbox/harvest_dashboard_select.xsl'}
%
%(c)2013-2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 13-Apr-2015

%init output
msg = '';

%check for required arguments
if nargin >= 2 && ~isempty(time_offset) && isdir(pn)
   
   %check for filename instead of struct input
   if ischar(s) && exist(s,'file') == 2
      fn = s;
      s = [];
      try
         vars = load(fn,'-mat');
      catch e
         vars = struct('null','');
      end
      if isfield(vars,'data');
         s = vars.data;
      else
         msg = ['failed to load data structure from file ',fn,' (',e.message,')'];
      end
   end
   
   %check for valid data structure
   if gce_valid(s,'data')
      
      %set default filename for xml if omitted/empty
      if exist('fn_xml','var') ~= 1 || isempty(fn_xml)
         fn_xml = {'index.xml','All Variables';'index2.xml','Selected Variables'};
      elseif ischar(fn_xml)
         fn_xml = {fn_xml,'All Variables'};  %convert char to cell array
      elseif size(fn_xml,2) == 1
         fn_xml = [fn_xml,repmat({'All Variables'},length(fn_xml),1)];
      end
      
      %set default nav array if omitted/invalid
      if exist('nav','var') ~= 1 || ~iscell(nav) || size(nav,2) ~= 2
         nav = '';
      end
      
      %set default plot_prefix if omitted/empty
      if exist('plot_prefix','var') ~= 1 || isempty(plot_prefix)
         plot_prefix = '';
      elseif strcmp(plot_prefix(end),'_') ~= 1
         plot_prefix = [plot_prefix,'_'];  %add underscore separator
      end
      
      %set default xsl url if omitted/invalid
      if exist('xsl_url','var') ~= 1
         xsl_url = {'http://gce-lter.marsci.uga.edu/public/xsl/toolbox/harvest_dashboard.xsl'; ...
            'http://gce-lter.marsci.uga.edu/public/xsl/toolbox/harvest_dashboard_select.xsl'};
      elseif ischar(xsl_url)
         xsl_url = repmat({xsl_url},length(fn_xml),1);  %convert char to cell array
      end
      
      %set default html option if omitted or no xsl defined
      if exist('html','var') ~= 1 || html ~= 0
         if ~isempty(xsl_url)
            html = 1;
         else
            html = 0;
         end
      end
      
      %set default intervals array if omitted/invalid
      if exist('intervals','var') ~= 1 || isempty(intervals) || ~iscell(intervals) || size(intervals,2) ~= 3
         intervals = {'day',5,50; ...
            'week',5,25; ...
            'month',10,25};
      end
      
      %set default data columns if omitted/empty
      if exist('cols','var') ~= 1 || isempty(cols)
         cols = listdatacols(s);  %get index of data/calculation columns
      elseif ~isnumeric(cols)
         cols = name2col(s,cols);  %look up column names
      end
      
      %remove string columns from cols
      if ~isempty(cols)
         stringcols = find(strcmp('s',get_type(s,'datatype')));
         cols = setdiff(cols,stringcols);
      end
      
      if exist('time_offset','var') ~= 1
         time_offset = 0;
      end
      
      if exist('thumbnail_size','var') ~= 1 || isempty(thumbnail_size)
         thumbnail_size = 250;
      end
      
      %set default plot options if omitted
      if exist('plotoptions','var') ~= 1 || isempty(plotoptions) || ~isstruct(plotoptions)
         plotoptions = struct( ...
            'Color',[0 0 1], ...
            'LineStyle','-', ...
            'LineWidth',1, ...
            'Marker','o', ...
            'MarkerSize',4, ...
            'MarkerEdgeColor',[0 0 1], ...
            'MarkerFaceColor',[0 0 1], ...
            'FigureWidth',900, ...
            'FigureHeight',600 ...
            );
      else  %check for legacy format without figure size fields
         if ~isfield(plotoptions,'FigureWidth')
            plotoptions.FigureWidth = 900;
         end
         if ~isfield(plotoptions,'FigureHeight')
            plotoptions.FigureHeight = 600;
         end
      end
      
      %get study dates
      dt = get_studydates(s);
      
      %check for valid columns to report on
      if ~isempty(dt) && ~isempty(cols)
         
         %generate date metrics for the data set
         date_start = min(no_nan(dt));
         date_end = max(no_nan(dt));
         date_indexed = now + time_offset./24;
         
         %check for max interval < all, filter data set to max interval
         if sum(strcmpi('all',intervals(:,1))) == 0
            dt_start = date_end;
            for n = 1:size(intervals,1)
               switch intervals{n,1}
                  case 'hour'
                     dt_start_new = date_end - 1/24;
                  case 'day'
                     dt_start_new = date_end - 1;
                  case 'week'
                     dt_start_new = date_end - 7/24;
                  case 'month'
                     dvec = datevec(date_end);
                     if dvec(2) > 1
                        dvec(2) = dvec(2) - 1;  %decrement month
                     else  %january
                        dvec(1) = dvec(1) - 1;  %decrement year
                        dvec(2) = 12;
                     end
                     dt_start_new = datenum(dvec);
                  case 'year'
                     dvec = datevec(date_end);
                     dvec(1) = dvec(1)-1;
                     dt_start_new = datenum(dvec);
                  otherwise
                     dt_start_new = dt_start;
               end
               if dt_start_new < dt_start
                  dt_start = dt_start_new;  %update dt_start to new minumum
               end
            end
            if dt_start < date_end
               Idates = find(dt >= dt_start);  %get index of dates within max interval
               s = copyrows(s,Idates);  %filter dataset
               dt = dt(Idates);  %adjust dt array to match filtered data set
               date_start = min(no_nan(dt));  %recalculate date_start
            end
         end
         
         %generate other date metrics post-filtering
         hours_lapsed = (date_indexed - date_end) .* 24;

         %init plots substructure
         s_xml_interval = struct( ...
            'period','', ...
            'period_label','', ...
            'num_records',[], ...
            'min_value','', ...
            'max_value','', ...
            'mean_value','', ...
            'num_missing',[], ...
            'num_flagged',[], ...
            'num_questionable',[], ...
            'num_invalid',[], ...
            'pct_missing',[], ...
            'pct_flagged',[], ...
            'status','', ...
            'fn_thumbnail','', ...
            'fn_plot','');
         
         %init structure element for each interval
         for n = 1:size(intervals,1)
            interval = intervals{n,1};
            switch interval
               case 'hour'
                  interval_label = 'Last Hour';
               case 'day'
                  interval_label = 'Last Day';
               case 'week'
                  interval_label = 'Last Week';
               case 'month'
                  interval_label = 'Last Month';
               case 'year'
                  interval_label = 'Last Year';
               otherwise
                  interval_label = 'All Data';
            end
            s_xml_interval(n).period = interval;
            s_xml_interval(n).period_label = interval_label;
            s_xml_interval(n).num_records = NaN;
            s_xml_interval(n).min_value = '';
            s_xml_interval(n).max_value = '';
            s_xml_interval(n).mean_value = '';
            s_xml_interval(n).num_missing = NaN;
            s_xml_interval(n).num_flagged = NaN;
            s_xml_interval(n).num_questionable = NaN;
            s_xml_interval(n).num_invalid = NaN;
            s_xml_interval(n).pct_missing = NaN;
            s_xml_interval(n).pct_flagged = NaN;
            s_xml_interval(n).status = '';
            s_xml_interval(n).fn_thumbnail = '';
            s_xml_interval(n).fn_plot = '';
                  
         end
         
         %init variable structure
         s_xml_vars = struct('name','', ...
            'units','', ...
            'description','', ...
            'qc_rules','', ...
            'min_value','', ...
            'min_value_valid','', ...
            'max_value','', ...
            'max_value_valid','', ...
            'mean_value_valid','', ...
            'interval',[]);
         s_xml_vars.interval = s_xml_interval;
         
         %replicate structure for all variables
         s_xml_vars = repmat(s_xml_vars,1,length(cols));
         
         %init message array
         msg_array = repmat({''},length(cols),1);
         
         %generate 'clean' data set with values flagged I removed
         s_clean = nullflags(s,'I',cols);
         
         %loop through variables
         for n = 1:length(cols)
            
            %get column pointer
            col = cols(n);
            
            %get column numeric precision
            prec = s.precision(col);
            
            %get value array and flags, padding flags if empty
            [vals,flags] = extract(s,col);
            if isempty(flags)
               flags = repmat(' ',length(vals),1);
            end
            
            %get min/max range for reporting
            ymin = min(no_nan(vals));
            ymax = max(no_nan(vals));
            
            %get 'clean' min/max range for axis scaling, excluding values flagged I
            vals_clean = extract(s_clean,col);
            ymin_clean = min(no_nan(vals_clean));
            ymax_clean = max(no_nan(vals_clean));
            ymean_clean = mean(no_nan(vals_clean));
            
            %populate structure info for variable
            s_xml_vars(n).name = s.name{col};
            s_xml_vars(n).units = s.units{col};
            s_xml_vars(n).description = s.description{col};
            s_xml_vars(n).qc_rules = s.criteria{col};
            s_xml_vars(n).min_value = sprintf(['%0.',int2str(prec),'f'],ymin);
            s_xml_vars(n).min_value_valid = sprintf(['%0.',int2str(prec),'f'],ymin_clean);
            s_xml_vars(n).max_value = sprintf(['%0.',int2str(prec),'f'],ymax);
            s_xml_vars(n).max_value_valid = sprintf(['%0.',int2str(prec),'f'],ymax_clean);
            s_xml_vars(n).mean_value_valid = sprintf(['%0.',int2str(prec),'f'],ymean_clean);
            
           %loop through intervals subsetting array
            for int = 1:size(intervals,1)
               
               %determine starting date to use for subsetting
               switch intervals{int,1}
                  case 'hour'
                     dt_start = date_end - 1/24;
                  case 'day'
                     dt_start = date_end - 1;
                  case 'week'
                     dt_start = date_end - 7;
                  case 'month'
                     dvec = datevec(date_end);
                     dvec_lastmonth = dvec;
                     if dvec(2) > 1
                        dvec_lastmonth(2) = dvec(2)-1;
                     else
                        dvec_lastmonth(1) = dvec(1)-1;
                        dvec_lastmonth(2) = 12;
                     end
                     dt_start = datenum(dvec_lastmonth);
                  case 'year'
                     dvec = datevec(date_end);
                     dvec_lastyear = dvec;
                     dvec_lastyear(1) = dvec_lastyear(1)-1;
                     dt_start = datenum(dvec_lastyear);
                  otherwise  %all
                     dt_start = date_start;
               end
               
               %get index of records to include in interval
               Irec = find(dt >= dt_start);
               
               %subset values and flags
               vals_sub = vals(Irec);
               flags_sub = flags(Irec,:);

               %init min/max/mean strings
               str_minval = '';
               str_maxval = '';
               str_meanval = '';
                  
               %tabulate metrics
               num_records = length(vals_sub);
               if iscell(vals_sub)
                  num_missing = sum(cellfun('isempty',vals_sub));
               else
                  num_missing = sum(isnan(vals_sub));
                  minval = min(no_nan(vals_sub));
                  maxval = max(no_nan(vals_sub));
                  meanval = mean(no_nan(vals_sub));
                  if ~isempty(minval) && ~isnan(minval) && ~isnan(maxval) && ~isnan(meanval)
                     str_minval = sprintf(['%0.',int2str(prec),'f'],minval);
                     str_maxval = sprintf(['%0.',int2str(prec),'f'],maxval);
                     str_meanval = sprintf(['%0.',int2str(prec),'f'],meanval);
                  end
               end
               pct_missing = round((num_missing / num_records) * 10000)/100;  %round to 2 decimal places
               
               %init flag check arrays
               flagged = zeros(size(flags_sub,1),1);
               questionable = flagged;
               invalid = flagged;
               
               %loop through flag array columns, setting 1 flag for matching criteria
               for flagcol = 1:size(flags_sub,2)
                  flagged(flags_sub(:,flagcol) ~= ' ') = 1;
                  questionable(flags_sub(:,flagcol) == 'Q') = 1;
                  invalid(flags_sub(:,flagcol) == 'I') = 1;
               end
               
               %calculate flag stats
               num_flagged = sum(flagged);
               num_questionable = sum(questionable);
               num_invalid = sum(invalid);
               pct_flagged = round((num_flagged / num_records) * 10000)/100;  %round to 2 decimal places
               
               %init plot vars
               fn_thumb = '';
               fn_plot = '';
               fn_prefix = [plot_prefix,s.name{col},'_',intervals{int}];
               
               %generate plot
               if isnumeric(vals_sub) && ~isempty(vals_sub)
                  try
                     %add plot label info to plotoptions
                     plotoptions.variable = s.name{col};
                     plotoptions.units = s.units{col};
                     [fn_thumb,fn_plot] = sub_plotdata(dt(Irec),vals_sub,flags_sub,pn,fn_prefix,plotoptions,thumbnail_size,[ymin_clean ymax_clean]);
                  catch e
                     msg_array{n} = ['an error occurred generating plots for variable ',s.name{col},' (',e.message,')'];
                  end
               else
                  msg_array{n} = ['no plot generated for non-numeric or empty variable ',s.name{col}];
               end
               
               %determine status
               crit1 = intervals{int,2};
               crit2 = intervals{int,3};
               if pct_missing >= crit2 || pct_flagged >= crit2
                  status = 'red';
               elseif pct_missing >= crit1 || pct_flagged >= crit1
                  status = 'yellow';
               else
                  status = 'green';
               end
               
               %populate structure
               s_xml_vars(n).interval(int).num_records = num_records;
               s_xml_vars(n).interval(int).min_value = str_minval;
               s_xml_vars(n).interval(int).max_value = str_maxval;
               s_xml_vars(n).interval(int).mean_value = str_meanval;
               s_xml_vars(n).interval(int).num_missing = num_missing;
               s_xml_vars(n).interval(int).num_flagged = num_flagged;
               s_xml_vars(n).interval(int).num_questionable = num_questionable;
               s_xml_vars(n).interval(int).num_invalid = num_invalid;
               s_xml_vars(n).interval(int).pct_missing = pct_missing;
               s_xml_vars(n).interval(int).pct_flagged = pct_flagged;
               s_xml_vars(n).interval(int).status = status;
               s_xml_vars(n).interval(int).fn_thumbnail = fn_thumb;
               s_xml_vars(n).interval(int).fn_plot = fn_plot;
               
            end
            
         end
         
         %add dataset-level info to outer structure
         s_xml = struct( ...
            'title',s.title, ...
            'navigation','', ...
            'pages','', ...
            'temporal_coverage','', ...
            'variables',[], ...
            'date_generated',datestr(now,31));
         
         %add date coverage info
         s_xml.temporal_coverage = struct( ...
            'date_start',datestr(date_start,31), ...
            'date_end',datestr(date_end,31), ...
            'date_indexed',datestr(date_indexed,31), ...
            'hours_lapsed',hours_lapsed ...
            );
         
         %add navigation
         if ~isempty(nav)
            s_nav = repmat(struct('item',''),size(nav,1),1);
            for cnt = 1:size(nav,1)
               s_nav(cnt).item = struct('label',nav{cnt,1},'url',nav{cnt,2});
            end
            s_xml.navigation = s_nav;
         end
         
         %add page links
         s_pages = repmat(struct('item',''),size(fn_xml,1),1);
         for cnt = 1:size(fn_xml,1)
            page_url = fn_xml{cnt,1};
            if html == 1
               page_url = strrep(page_url,'.xml','.html');
            end
            s_pages(cnt).item = struct('label',fn_xml{cnt,2},'url',page_url);
         end
         s_xml.pages = s_pages;
         
         %add variables structure
         s_xml.variables = struct('variable',s_xml_vars);
         
         %check for variable errors
         msg_array = msg_array(~cellfun('isempty',msg_array));
         if ~isempty(msg_array)
            msg = char(concatcellcols(msg_array','; '));
         end
         
         %generate xml file
         xml = struct2xml(s_xml,'root',1,0,3,0);
         
         for n = 1:size(fn_xml,1)
            
            xml2file(xml,'',0,fn_xml{n,1},pn,xsl_url{n});
            
            %generate html file
            if html == 1
               [~,fn_base] = fileparts(fn_xml{n});
               xslt([pn,filesep,fn_xml{n,1}],xsl_url{n},[pn,filesep,fn_base,'.html']);
            end
            
         end
         
      else
         if isempty(cols)
            msg = 'invalid column list';
         else
            msg = 'no valid date/time information could be identified in the data set';
         end
      end
      
   else
      if isempty(msg)
         msg = 'invalid data structure';
      end
   end
   
else
   if nargin < 2
      msg = 'insufficient arguments for function';
   elseif isempty(time_offset)
      msg = 'invalid time offset';
   else
      msg = 'invalid output directory';
   end
end

return


function [fn_thumb,fn_plot] = sub_plotdata(x,y,flags,pn,fn_prefix,plotoptions,thumbnail_size,ylimits)
%plotting subfunction
%
%input:
%  x = x data for plot
%  y = ydata for plot
%  flags = array of flag characters to plot
%  pn = pathname for saving plots
%  fn_prefix = filename prefix for plots
%  plotoptions = plot options structure
%  thumbnail_size = width of thumbnail plot
%  ylimits = 2-element array of [ymin ymax]
%
%output:
%  fn_thumb = filename of thumbnail plot
%  fn_plot = filename of full plot

%init output
fn_thumb = '';
fn_plot = '';

%get x-axis range
xmin = min(no_nan(x));
xmax = max(no_nan(x));
xrange = xmax - xmin;

%check for valid data to plot
if xrange > 0
   
   %check for invalid or 0 yaxis range
   if isempty(ylimits) || length(ylimits) < 2
      ylimits = [min(y) max(y)];
   end
   if diff(ylimits) <= 0
      ylimits = [min(y)-1 max(y)+1];
   end
   
   %revise grossly out of range values to avoid MATLAB overflow errors
   y_high = ylimits(2) + abs(ylimits(2) * 10);   
   y_low = ylimits(1) - abs(ylimits(1) * 10);
   y(y>y_high) = y_high;
   y(y<y_low) = y_low;
   
   %get figure width, height from plotoptions
   figwidth = plotoptions.FigureWidth;
   figheight = plotoptions.FigureHeight;
   
   %init hidden figure
   h_fig = figure( ...
      'Visible','off', ...
      'Name','Dashboard Plot', ...
      'Color',[1 1 1], ...
      'PaperPositionMode','auto', ...
      'InvertHardcopy','off', ...
      'NumberTitle','off', ...
      'DockControls','off', ...
      'MenuBar','none', ...
      'Units','pixels', ...
      'Position',[50 50 figwidth figheight], ...
      'Resize','off' ...
      );
   
   %generate plot line with specified options
   h_line = plot(x,y);
   set(h_line, ...
      'Color',plotoptions.Color, ...
      'LineStyle',plotoptions.LineStyle, ...
      'LineWidth',plotoptions.LineWidth, ...
      'Marker',plotoptions.Marker, ...
      'MarkerSize',plotoptions.MarkerSize, ...
      'MarkerEdgeColor',plotoptions.MarkerEdgeColor, ...
      'MarkerFaceColor',plotoptions.MarkerFaceColor ...
      )
   
   %get axis handle
   h_ax = get(h_fig,'CurrentAxes');
   
   %set y-axis limits and enable grid
   set(h_ax, ...
      'YGrid','on', ...
      'YLim',ylimits)
   
   %plot flags if present
   Iflags = find((flags(:,1)~=' '));
   if ~isempty(Iflags)
      h_fl = text(x(Iflags),y(Iflags),flags(Iflags,:));
      set(h_fl, ...
         'fontname','Times', ...
         'fontsize',9, ...
         'horizontalalignment','center', ...
         'verticalalignment','bottom', ...
         'color',[.8 0 0], ...
         'clipping','on', ...
         'tag','flags')
   end
   
   %set date ticks based on x-range
   if xrange < 1  %hour
      fmt = 'mm/dd HH:MM';
      xlbl = 'Time';
      xtick = (floor(xmin):0.25/24:ceil(xmax));  %15 min ticks
   elseif xrange < 2  %day
      fmt = 'mm/dd HH:MM';
      xlbl = 'Time';
      xtick = (floor(xmin):3/24:ceil(xmax));  %3 hour ticks
   elseif xrange < 8  %week
      fmt = 'mm/dd HH:MM';
      xlbl = 'Date';
      xtick = (floor(xmin):1:ceil(xmax));  %1 day ticks
   elseif xrange < 32  %month
      fmt = 'yyyy-mm-dd';
      xlbl = 'Date';
      xtick = (floor(xmin):7:ceil(xmax));  %7 day ticks
   else
      fmt = 'yyyy-mm-dd';
      xlbl = 'Date';
      xtick = [];  %auto
   end
   
   %limit ticks to in-range values and generate date ticks
   if ~isempty(xtick)
      xtick = xtick(xtick>=xmin & xtick<=xmax);
      set(gca,'XTick',xtick,'XLim',[xmin xmax])
      datetick('x',fmt,'keepticks','keeplimits');
   else
      set(gca,'XLim',[xmin xmax])
      datetick('x',fmt);
   end
   
   %label axes
   plotlabels(plotoptions.variable,xlbl,plotoptions.units,'','none',h_ax);
   
   %calculate figure metrics for export
   thumb_res = round(thumbnail_size./figwidth .* 96);
   image_res = 96;
   
   %generate filenames
   fn_thumb = [fn_prefix,'_thumb.png'];
   fn_plot = [fn_prefix,'.png'];
   
   %print plots to file
   if mlversion < 8.4
      renderer = '-zbuffer';
   else
      renderer = '-opengl';
   end
   print([pn,filesep,fn_thumb],renderer,'-dpng',['-r',int2str(thumb_res)],'-noui')
   print([pn,filesep,fn_plot],renderer,'-dpng',['-r',int2str(image_res)],'-noui')
   
   %delete figure
   delete(h_fig)
   
end
