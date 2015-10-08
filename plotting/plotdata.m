function [msg,h_fig] = plotdata(s,xcol,ycols,colors,markers,styles,fillmarkers,markersize,scale,rotateaxis,sortx,dateaxis_opt,flags,deblank,axlims,visible)
%Generates 2D symbol/line plots of values in a GCE-LTER data structure
%
%syntax:  [msg,h_fig] = plotdata(s,xcol,ycols,colors,markers,linestyles,fillmarkers,markersize,scale,rotateaxis,sortx,dateaxis,flags,deblank,axlims,visible)
%
%inputs:
%   s = the data structure
%   xcol = the column numbers or names to use as independent variables
%      (note: length must be 1 or match the length of ycols)
%   ycols = the column numbers or names to use as dependent variables
%   colors = cell array of Matlab color values - see 'help plot' (default = auto)
%   markers = cell array of Matlab marker styles - see 'help plot' (default = auto)
%   linestyles = cell array of Matlab line styles - see 'help plot' (default = '-')
%   fillmarkers = option to fill marker symbols with the specified color
%      0 = no
%      1 = yes/default
%      (or array of 0,1 matching ycols)
%   markersize = fontsize for marker symbols (default = 5)
%   scale = y-axis scale option:
%      'linear' = linear (default)
%      'log' = log scale
%      'auto' = automatically scale data values by powers of 10 so that
%         low values will be in scale (scale factor appended to column names)
%   rotateaxis = option to rotate the axis so that x values appear on the ordinate
%      and y values appear along the abscissa, and the y-axis is reversed (e.g. depth plots)
%      0 = do not rotate (default)
%      1 = rotate
%   sortx = x-axis sorting option:
%      0 = do not sort rows by values in the X column
%      1 = sort rows by values in the X column
%   dateaxis = option to display xaxis ticks as formatted date strings if
%       xcol contains Matlab serial date values (0 = no; 1 = yes/default; ignored
%       if xcol does not contain valid datetime values)
%   flags = option to plot QC flag characters above respective data points
%       0 = no
%       1 = yes - plotted as characters (default)
%       2 = yes - plotted as red symbols on top of data values
%   deblank = option to remove NaN or blank values prior to plotting (1 = yes, 0 = no/default)
%   axlims = 1x4 array of axis limits (xmin xmax ymin ymax)
%      or 1x2 array of y-axis limits (ymin ymax)
%   visible = plot visibility option for batch plotting
%      'on' = display plot on console (default)
%      'off' = do not display
%
%   (note: 'linestyles', 'markers', and 'colors' will be re-used if insufficient values are
%        supplied)
%
%outputs:
%   msg = text of any error messages
%   h_fig = handle of the plot figure
%
%
%(c)2002-2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 15-Nov-2014

msg = '';
h_fig = [];

if nargin >= 3

   if gce_valid(s,'data') == 1  %valid data structure
      
      %perform name-to-column substitutions
      if ~isnumeric(xcol)
         xcol = name2col(s,xcol);
      end
      if ~isnumeric(ycols)
         ycols = name2col(s,ycols);
      end

      %cache number of columns to plot      
      num_ycols = length(ycols);
      
      %check for xsort before proceeding
      if exist('sortx','var') == 1
         if sortx == 1
            s2 = sortdata(s,xcol,1);
            if ~isempty(s2)
               s = s2;
            end
         end
      end

      %check for deblank option
      if exist('deblank','var') ~= 1
         deblank = 0;
      elseif deblank ~= 1  %check for invalid option
         deblank = 0;
      end

      %check for axis rotation option
      if exist('rotateaxis','var') ~= 1 
         rotateaxis = 0;
      elseif ischar(rotateaxis)
         rotateaxis = 0;
      end

      %initialize default arrays for symbols and colors
      markers0 = [ ...
         {'o'}; ...
         {'d'}; ...
         {'^'}; ...
         {'v'}; ...
         {'<'}; ...
         {'>'}; ...
         {'s'}; ...
         {'p'}; ...
         {'h'}; ...
         {'x'}; ...
         {'+'}; ...
         {'*'}; ...
         {'.'}];

      colors0 = [ ...
         {'b'},{[0 0 1]}; ...
         {'g'},{[0 1 0]}; ...
         {'k'},{[0 0 0]}; ...
         {'r'},{[1 0 0]}; ...
         {'c'},{[0 1 1]}; ...
         {'m'},{[1 0 1]}; ...
         {'y'},{[1 1 0]}];

      %set default for flag display if omitted
      if exist('flags','var') ~= 1 || isempty(flags)
         flags = 1;
      end
      
      %set default visibility if omitted
      if exist('visible','var') ~= 1 || isempty(visible) || ~ischar(visible) || ~strcmpi(visible,'off')
          visible = 'on';
      end

      %default to date axis labeling if x column datetime
      if exist('dateaxis_opt','var') ~= 1 || isempty(dateaxis_opt)
         dateaxis_opt = 1;  
      end

      %validate axis limits
      if exist('axlims','var') ~= 1
         axlims = [];  %default to automatic axis limits
      elseif length(axlims) ~= 4 && length(axlims) ~= 2
         axlims = [];  %invalid format - use default
      else
         axlims = axlims(:)';  %force row vector
      end

      %validate scale
      if exist('scale','var') ~= 1 || isempty(scale)
         scale = 'linear';  %default to linear y-axis scaling
      elseif ~ischar(scale)
         scale = 'linear';
      end

      %initialize lines, markers, colors to defaults if omitted
      if exist('styles','var') ~= 1
         styles = [];
      elseif ischar(styles)
         styles = cellstr(styles);
      elseif ~iscell(styles)
         styles = [];
      end
      if exist('markers','var') ~= 1
         markers = [];
      elseif ~iscell(markers)
         markers = [];
      end
      if exist('colors','var') ~= 1
         colors = [];
      elseif ~iscell(colors)
         colors = [];
      end

      if exist('fillmarkers','var') ~= 1
         fillmarkers = 1;
      end
      if length(fillmarkers) < num_ycols
         fillmarkers = repmat(fillmarkers(1),num_ycols,1);
      end

      if exist('markersize','var') ~= 1
         markersize = 5;
      end
      if length(markersize) < num_ycols
         markersize = repmat(markersize(1),num_ycols,1);
      end

      %generate marker array
      if isempty(markers)
         markers = repmat(markers0,ceil(num_ycols./12),1);
      elseif length(markers) < num_ycols
         markers = repmat(markers,1,ceil(num_ycols./length(markers)));
      else
         markers = markers(1:num_ycols);
      end

      %generate linestyle array
      if isempty(styles)
         styles = repmat({'-'},num_ycols,1);
      elseif length(styles) < num_ycols
         styles = repmat(styles,ceil(num_ycols./length(styles)),1);
      else
         styles = styles(1:num_ycols);
      end

      %generate color array if omitted
      if isempty(colors)  %pad color selections to match columns
         colors = repmat(colors0(:,1),ceil(num_ycols./6),1);
      end
      
      %trim/copy color array to match ycols to prevent errors with fill array loop
      if length(colors) < num_ycols
         colors = repmat(colors,ceil(num_ycols./length(colors)),1);
      else
         colors = colors(1:num_ycols);
      end

      %generate fill array
      fills = ones(length(colors),3);
      for n = 1:length(colors)
         if fillmarkers(n) == 1
            Iclr = find(strcmp(colors0(:,1),colors{n}));
            if ~isempty(Iclr)
               fills(n,1:3) = colors0{Iclr(1),2};
            end
         end
      end

      %proceed if column selections valid
      if ~isempty(xcol) && ~isempty(ycols)

         flag_nodata = 0;

         %check for empty data columns, omit from plot
         if strcmp(s.datatype{xcol},'s')
            Ivalid = find(~cellfun('isempty',s.values{xcol}));
         else
            Ivalid = find(~isnan(s.values{xcol}));
         end
         if isempty(Ivalid)
            flag_nodata = 1;
         else  %check ycols
            for n = 1:num_ycols
               if strcmp(s.datatype{ycols(n)},'s')
                  Ivalid = find(~cellfun('isempty',s.values{ycols(n)}));
               else
                  Ivalid = find(~isnan(s.values{ycols(n)}));
               end
               if isempty(Ivalid)
                  ycols(n) = NaN;
               end
            end
            if sum(~isnan(ycols)) == 0
               flag_nodata = 1;
            end
         end

      else
         flag_nodata = 1;
      end

      if flag_nodata == 0

         %extract values arrays
         vals = s.values;
         
         %init x labels
         xlbls = [];

         %process xcol values
         if strcmp(s.datatype{xcol},'s') ~= 1
            xvals = vals{xcol};  %numeric - simple assignment
         else  %deal with string x columns
            if strcmp(s.variabletype{xcol},'datetime') == 1  %try converting strings to dates
               xvals = datestr2num(vals{xcol},s.units{xcol});
            else  %encode strings as integers, store label array
               str = s.values{xcol};
               xvals = zeros(length(str),1);
               tkns = unique(str);
               for n = 1:length(tkns)
                  Ival = strcmp(str,tkns{n});
                  xvals(Ival) = n;
               end
               xlbls = tkns;
            end
         end

         %check for valid columns to plot
         if ~isempty(xvals) && sum(~strcmp(s.datatype(no_nan(ycols)),'s')) > 0

            %build column name list for legend
            colnames = cell(length(s.name),1);
            for n = 1:length(s.name)
               colnames{n} = [s.name{n},' (',s.units{n},')'];
            end

            %generate figure and plot window titles
            titlestr = s.title;
            if length(titlestr) > 70
               figtitle = wordwrap(titlestr,75,0);
               if size(figtitle,1) > 3
                  figtitle = figtitle(1:3,1);
                  figtitle{3,1} = [figtitle{3,1},'...'];
               end
               figtitle = char(figtitle);
               figtitle = strjust(figtitle,'center');  %center 3-line plot title
               titlestr = [titlestr(1:70),'...'];  %trim title string for figure window
            else
               figtitle = s.title;
            end

            qc_data = struct('s',s, ...
               'x',xcol, ...
               'y',ycols, ...
               'Igroups',[], ...
               'groupnames',[], ...
               'rotate',rotateaxis, ...
               'scalefactor',[]);

            res = get(0,'ScreenSize');
            if num_ycols > 1
               wid = 900;
            else
               wid = 750;
            end

            %init plot figure
            h_fig = figure('Visible',visible, ...
               'Position',[max(0,round((res(3)-wid)/2)) max(50,round((res(4)-650)/2)) wid 650], ...
               'Color',[1 1 1], ...
               'PaperPositionMode','auto', ...
               'InvertHardcopy','off', ...
               'Name',['Plot of ',titlestr], ...
               'NumberTitle','off', ...
               'Tag','GCE_Toolbox_Plot');

            h_GCE = plotmenu('GCETools',h_fig);  %generate standard menu items

            %add viual QC tool menu entry
            uimenu('Parent',h_GCE, ...
               'Separator','on', ...
               'Label','Visual QC Tool Window', ...
               'Callback','ui_visualqc(''init'')', ...
               'Tag','mnuVisualQC');

            %init scaling factor array
            scalefact = ones(1,num_ycols);

            %recalculate y values, column names if autoscaling enabled
            if strcmp(scale,'auto')
               scale = 'linear';  %reset axis scaling for plot
               if num_ycols > 1
                  maxvals = zeros(1,num_ycols);
                  for n = 1:num_ycols  %determine max
                     if ~isnan(ycols(n)) && ~strcmp(s.datatype{ycols(n)},'s')
                        tmp = vals{ycols(n)};
                        testmax = max(tmp(~isnan(tmp)));
                        if ~isnan(testmax)
                           maxvals(n) = testmax;
                        end
                     end
                  end
                  maxval = max(maxvals);
                  for n = 1:length(maxvals)
                     if maxvals(n) > 0
                        factor = floor(log10(maxval./maxvals(n)));
                        if factor > 0  %scale
                           vals{ycols(n)} = vals{ycols(n)} .* (10^factor);
                           colnames{ycols(n)} = [colnames{ycols(n)},' (x',num2str(10^factor),')'];
                           scalefact(n) = 10^factor;
                        end
                     end
                  end
               end
            end

            %add scale factor array to cached qc_data
            qc_data.scalefactor = scalefact;

            set(h_fig,'UserData',qc_data,'Pointer','watch')
            drawnow
            
            %init array of plot handles for legend
            h_allplots = zeros(num_ycols,1);

            %build plots
            for n = 1:num_ycols

               if ~isnan(ycols(n)) && ~strcmp(s.datatype{ycols(n)},'s')

                  %create appropriate value index
                  if deblank == 1
                     Ivals = find(~isnan(vals{ycols(n)}));
                     if isempty(Ivals)  %check for all missing data, restore full index to prevent botched legend
                        Ivals = (1:length(vals{ycols(n)}));
                     end
                  else
                     Ivals = (1:length(vals{ycols(n)}));
                  end

                  %check for flags
                  Iflags = [];
                  if flags > 0
                     flagvals = s.flags{ycols(n)};
                     if size(flagvals,1) > 0
                        flagvals = flagvals(Ivals,:);
                        Iflags = find((flagvals(:,1)~=' '));
                     end
                  end
                  
                  %get x and y data based on rotation setting
                  if rotateaxis == 1
                     xdata = vals{ycols(n)};
                     ydata = xvals;
                  else
                     xdata = xvals;
                     ydata = vals{ycols(n)};
                  end
                  
                  %generate plots and flags
                  h = plot(xdata(Ivals),ydata(Ivals),[colors{n},markers{n},styles{n}]);
                  h_allplots(n) = h;
                  
                  %add tag to data series
                  set(h,'Tag',s.name{ycols(n)})
                  if ~isempty(Iflags)
                     if flags == 1
                        h_fl = text(xdata(Ivals(Iflags)),ydata(Ivals(Iflags)),flagvals(Iflags,:));
                     else  %flags == 2
                        hold on;
                        h_fl = plot(xdata(Ivals(Iflags)),ydata(Ivals(Iflags)),['r',markers{n}]);
                     end
                  end
                  
                  %set fill and size options for data plot
                  if sum(fills(n,:)) < 3
                     set(h,'Clipping','on','MarkerFaceColor',fills(n,:),'MarkerSize',markersize(n))
                  else
                     set(h,'Clipping','on','MarkerSize',markersize(n))
                  end
                  
                  %set properties of flag characters or symbols
                  if ~isempty(Iflags)
                     if flags == 1
                        set(h_fl, ...
                           'fontname','Times', ...
                           'fontsize',9, ...
                           'horizontalalignment','center', ...
                           'verticalalignment','bottom', ...
                           'color',[.8 0 0], ...
                           'clipping','on', ...
                           'tag',['Flags_',s.name{ycols(n)}])
                     else
                        set(h_fl, ...
                           'Clipping','on', ...
                           'MarkerFacecolor',[1 0 0], ...
                           'MarkerSize',markersize(n), ...
                           'Tag',['Flags_',s.name{ycols(n)}])  %add tag to flag series
                     end
                  end

                  %hold axis position
                  hold on

               end

            end

            %set axis limits based on maximum data extent
            hold off   %reset plot scale
            axis auto  %rescale axis
            ax = axis;  %get axis limits
            if rotateaxis == 0
               axis([floor(min(xvals(~isnan(xvals)))) ceil(max(xvals(~isnan(xvals)))) ax(3:4)])
            end

            %create plot title
            h_ax = gca;
            axpos = get(h_ax,'Position');
            if mlversion >= 7
               axwid = .8;
            else
               axwid = .86;
            end
            if size(figtitle,1) > 1
               axht = max(0.65,axpos(4)-(0.02 .* size(figtitle,1)));
            else
               axht = axpos(4);
            end
            if num_ycols > 1  %adjust for legend offset
               set(h_ax,'Position',[.1 axpos(2) axwid+0.03 axht])
            else
               set(h_ax,'Position',[.1 axpos(2) axwid axht])
            end

            title(figtitle, ...
               'FontName','Helvetica', ...
               'FontSize',14, ...
               'FontWeight','bold', ...
               'Interpreter','none', ...
               'ButtondownFcn','textedit');

            %define x label
            if ~strcmp(s.units{xcol},'none')
               xlblstr = [s.name{xcol},' (',s.units{xcol},')'];
            else
               xlblstr = s.name{xcol};
            end

            %define y label, checking for single variable plot first
            if sum(~isnan(ycols)) == 1
               ycol = no_nan(ycols);  %get index of single valud y col
               if ~strcmp(s.units{ycol},'none')
                  ylblstr = [s.name{ycol},' (',s.units{ycol},')'];
               else
                  ylblstr = s.name{ycol};
               end
            else
               ylblstr = 'Value';
            end

            %set default grid, color options
            set(h_ax,'YGrid','on','Color','none')

            %format plot
            if rotateaxis == 1

               ylabel(xlblstr, ...
                  'FontSize',14, ...
                  'Fontweight','bold', ...
                  'Interpreter','none', ...
                  'ButtonDownFcn','textedit');

               xlabel(ylblstr, ...
                  'FontSize',14, ...
                  'Fontweight','bold', ...
                  'Interpreter','none', ...
                  'ButtonDownFcn','textedit');

               axpos = get(h_ax,'Position');
               set(h_ax, ...
                  'XAxisLocation','top', ...
                  'Position',[axpos(1),axpos(2)-.05,axpos(3:4)], ...
                  'FontSize',10, ...
                  'XScale',scale, ...
                  'XGrid','on', ...
                  'YDir','reverse')

               if ~isempty(axlims)
                  if length(axlims) == 4
                     axis(axlims(3:4),axlims(1:2));  %reverse X/Y, apply manual limits
                  else
                     axis([axlims get(h_ax,'YLim')]);
                  end
               end

               %deal with date labeling for numerical xcols containing serial dates
               if dateaxis_opt == 1
                  if strcmp(s.variabletype{xcol},'datetime') && ~strcmp(s.datatype{xcol},'s')
                     try
                        xtick = get(h_ax,'YTick');
                        if xtick > 693962 && xtick < 767376  %datenums for 1900-2100
                           dstr = datestr(xtick,2);
                        else
                           dstr = '';
                        end
                     catch
                        dstr = '';
                     end
                     if ~isempty(dstr)  %replace tick labels
                        %add date labels and establish auto function for rescaling dates after zoom
                        set(h_ax,'YTickLabel',dstr, ...
                           'ButtonDownFcn','dateaxis')
                        h_dateaxis = findobj(h_fig,'tag','popDateAxis');
                        set(h_dateaxis,'Value',2)
                        dateaxis
                     end
                  end
               end

               %apply other axis labels previously assigned
               if ~isempty(xlbls)  %set manual xlabels for encoded strings
                  set(h_ax, ...
                     'YLim',[1,length(xlbls)], ...
                     'YTick',(1:length(xlbls)), ...
                     'YTickLabels',char(xlbls'))
               end

            else  %standard y vs x plot

               xlabel(xlblstr, ...
                  'FontSize',14, ...
                  'Fontweight','bold', ...
                  'Interpreter','none', ...
                  'ButtonDownFcn','textedit');

               ylabel(ylblstr, ...
                  'FontSize',14, ...
                  'Fontweight','bold', ...
                  'Interpreter','none', ...
                  'ButtonDownFcn','textedit');

               set(h_ax, ...
                  'FontSize',10, ...
                  'YScale',scale)

               if ~isempty(axlims)
                  if length(axlims) == 4
                     axis(axlims);
                  else
                     axis([get(h_ax,'XLim'),axlims]);
                  end
               end

               %deal with date labeling for numerical xcols containing serial dates
               if dateaxis_opt == 1
                  if strcmp(s.variabletype{xcol},'datetime')
                     try
                        xtick = get(h_ax,'XTick');
                        if xtick > 693962 && xtick < 767376  %datenums for 1900-2100
                           dstr = datestr(xtick,2);
                        else
                           dstr = '';
                        end
                     catch
                        dstr = '';
                     end
                     if ~isempty(dstr)  %replace tick labels
                        %add date labels and establish auto function for rescaling dates after zoom
                        set(h_ax,'XTickLabel',dstr, ...
                           'ButtonDownFcn','dateaxis')
                        h_dateaxis = findobj(h_fig,'tag','popDateAxis');
                        set(h_dateaxis,'Value',2)
                        dateaxis
                     end
                  end
               end

               if ~isempty(xlbls)  %set manual xlabels for encoded strings
                  set(h_ax, ...
                     'XLim',[1,length(xlbls)], ...
                     'XTick',(1:length(xlbls)), ...
                     'XTickLabel',char(xlbls'))
               end

            end

            set(h_fig,'Pointer','arrow')

            %generate legend if multi-y
            if sum(~isnan(ycols)) > 1
               Iplots = find(~isnan(ycols));
               h_ax_cache = gca;
               if mlversion < 7
                  hl = legend(h_allplots(Iplots),colnames{ycols(Iplots)},-1);
               else
                  hl = legend(h_allplots(Iplots),colnames{ycols(Iplots)});
               end
               %clear border to prevent text overruns, disable TeX interpreter
               if mlversion < 7
                  set(hl,'Color',[1 1 1],'XColor',[1 1 1],'YColor',[1 1 1]);
                  ht = findobj(hl,'Type','Text');
                  set(ht,'Interpreter','none','FontSize',8)  %use non-TeX interpreter for text to avoid underscore problems
               else  %set option for main legend handle
                  set(hl,'Color',[1 1 1]);
                  set(hl,'Interpreter','none','FontSize',8)
                  if mlversion < 8.4
                     axes(hl)
                     set(hl,'Location','none')  %set location to none to avoid plot refresh problems
                  end
               end
               axes(h_ax_cache)
            end

            plotbuttons  %display plot zooming buttons

         end

      else
         msg = 'no valid data to plot';
      end

   else
      msg = 'invalid data structure';
   end

else
   msg = 'insufficient arguments for function';
end