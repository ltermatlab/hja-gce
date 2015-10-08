function [msg,h_fig] = plotwind(s,col_date,col_speed,col_dir,maxspeed,daterange,deblank,showflags,linespec_speed,linespec_dir,markersize_speed,visible)
%Generates a standard 2-axis wind plot from a GCE Data Structure, with wind speed
%plotted on the top axis and wind direction plotted on the bottom axis.
%
%syntax: [msg,h_fig] = plotwind(s,col_date,col_speed,col_dir,maxspeed,daterange,deblank,showflags,linespec_speed,linespec_dir,markersize_speed,visible)
%
%inputs:
%  s = data structure
%  col_date = name or number of date column (numerical serial date or date string)
%  col_speed = wind speed column name or number
%  col_dir = wind direction column name or number (must have units of deg or degrees and
%    numbertype of angular)
%  maxspeed = maximum windspeed to plot (used for y-axis scaling) (default = []/automatic)
%  daterange = 2 element numerical or cell array defining the range of dates to plot (default = all)
%  deblank = option to remove NaNs (nulls) prior to plotting to force line plotting
%    0 = do not remove
%    1 = remove (default)
%  showflags = option to plot QA/QC flags above data points
%    0 = do no plot
%    1 = plot (default)
%  linespec_speed = line type for wind speed (default = 'kd:')
%  linespec_dir = line type for wind direction (default = 'b-')
%  markersize_speed = marker size for speed (default = 4)
%  visible = plot display option
%    'on' = display plot on the console (default)
%    'off' = do not display (e.g. for batch plotting during data harvesting)
%
%outputs:
%  msg = text of any error messages
%  h_fig = handle of figure generated
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
%last modified: 08-Jul-2014

msg = '';
h_fig = [];

%check for required arguments
if nargin >= 3

   %check for valid data structure
   if gce_valid(s,'data')

      %supply defaults for omitted parameters
      if exist('linespec_speed','var') ~= 1
         linespec_speed = 'kd:';
      end

      if exist('linespec_dir','var') ~= 1
         linespec_dir = 'b-';
      end

      if exist('maxspeed','var') ~= 1
         maxspeed = [];
      end
      
      if exist('markersize_speed','var') ~= 1
         markersize_speed = 4;
      end

      %set default visibility if omitted
      if exist('visible','var') ~= 1 || isempty(visible) || ~ischar(visible) || ~strcmpi(visible,'off')
          visible = 'on';
      end

      %calculate date range
      mindate = [];
      maxdate = [];
      if exist('daterange','var') == 1
         if iscell(daterange)
            if length(daterange) >= 2
               mindate = datenum(daterange{1});
               maxdate = datenum(daterange{2});
            elseif length(daterange) == 1
               maxdate = datenum(daterange{1});
            end
         elseif isnumeric(daterange)
            if length(daterange) >= 2
               mindate = daterange(1);
               maxdate = daterange(2);
            elseif length(daterange) == 1
               maxdate = daterange(1);
            end
         elseif ischar(daterange)
            maxdate = datenum(daterange);
         end
      end

      if exist('deblank','var') ~= 1
         deblank = 1;
      end

      if exist('showflags','var') ~= 1
         showflags = 1;
      end

      if ~isnumeric(col_date)
         col_date = name2col(s,col_date);
      end

      if ~isnumeric(col_speed)
         col_speed = name2col(s,col_speed);
      end

      if ~isnumeric(col_dir)
         col_dir = name2col(s,col_dir);
      end

      %check for matched columns
      if ~isempty(col_date) && ~isempty(col_speed) && ~isempty(col_dir)

         %validate and extract date column
         d = extract(s,col_date);
         if strcmp(s.datatype{col_date},'s')
            try
               d = datenum(d);
            catch    %#ok<CTCH>
               d = [];
            end
         end

         %validate and extract speed column
         if strcmp(s.datatype{col_speed},'f')
            spd = extract(s,col_speed);
            if deblank == 1
               Ispd = find(~isnan(spd));
            else
               Ispd = [1:length(spd)]';
            end
         else
            spd = [];
         end

         %validate and extract direction column
         if strcmp(s.datatype{col_dir},'f') && strcmp(s.numbertype{col_dir},'angular') && ...
               strncmpi(s.units{col_dir},'deg',3)
            dir = extract(s,col_dir);
            if deblank == 1
               Idir = find(~isnan(dir));
            else
               Idir = (1:length(dir))';
            end
         else
            dir = [];
         end

         %check for valid date, speed and direction arrays
         if ~isempty(d) && ~isempty(spd) && ~isempty(dir)

            %get screen metrics
            res = get(0,'ScreenSize');

            %create plot figure
            h_fig = figure('Visible',visible, ...
               'Name','Wind Data Plot', ...
               'Numbertitle','off', ...
               'Toolbar','none', ...
               'Color',[1 1 1], ...
               'Position',[max(10,(res(3)-800).*0.5) max(30,(res(4)-600).*0.5) 800 650], ...
               'InvertHardcopy','off', ...
               'PaperPositionMode','auto', ...
               'Tag','WindPlot');

            %generate standard menu items
            plotmenu('GCETools',h_fig);

            %geneate axis labels
            spd_lbl = [s.name{col_speed},' (',s.units{col_speed},')'];
            dir_lbl = [s.name{col_dir},' (',s.units{col_dir},')'];
            date_lbl = [s.name{col_date},' (',s.units{col_date},')'];

            %wrap long figure titles
            if length(s.title) > 75
               figtitle = strjust(char(wordwrap(s.title,75,0)),'center');
            else
               figtitle = s.title;
            end

            %round min/max dates
            if isempty(mindate)
               mindate = floor(min(d(~isnan(d))));
            end
            if isempty(maxdate)
               maxdate = ceil(max(d(~isnan(d))));
            end
            xlim = [mindate,maxdate];

            %add speed axis
            h_speedax = axes('Position',[.05 .5 .83 .38], ...
               'Color',[1 1 1], ...
               'Tag','axisSpeed', ...
               'UserData','auto');

            h_spd = plot(d(Ispd),spd(Ispd),linespec_speed);
            set(h_spd,'MarkerSize',markersize_speed)

            if showflags == 1 && ~isempty(s.flags{col_speed})
               flagvals = s.flags{col_speed};
               Iflags = find(flagvals(Ispd,1)~=' ');
               if ~isempty(Iflags)
                  h_fl = text(d(Ispd(Iflags)),spd(Ispd(Iflags)),flagvals(Ispd(Iflags),:));
                  set(h_fl, ...
                     'fontname','Times', ...
                     'fontsize',9, ...
                     'horizontalalignment','center', ...
                     'verticalalignment','bottom', ...
                     'color',[.8 0 0], ...
                     'clipping','on', ...
                     'tag','flags')
               end
            end

            minspeed = 0;
            if isempty(maxspeed)
               maxspeed = ceil(max(spd(~isnan(spd))));
            elseif length(maxspeed) == 2
               minspeed = maxspeed(1);
               maxspeed = maxspeed(2);
            else
               maxspeed = maxspeed(1);
            end

            set(h_speedax, ...
               'XLim',xlim, ...
               'XTickLabel','', ...
               'YAxisLocation','right', ...
               'YGrid','on', ...
               'YLim',[minspeed maxspeed]);

            title(figtitle, ...
               'FontName','Helvetica', ...
               'FontSize',14, ...
               'FontWeight','bold', ...
               'Interpreter','none', ...
               'ButtondownFcn','textedit');

            ylabel(spd_lbl, ...
               'FontSize',14, ...
               'Fontweight','bold', ...
               'Interpreter','none', ...
               'ButtonDownFcn','textedit');

            h_dirax = axes('Position',[.05 .1 .83 .38], ...
               'Color',[1 1 1], ...
               'Tag','axisDirection', ...
               'UserData','auto');

            plot(d(Idir),dir(Idir),linespec_dir);

            %check for showflags option, generate flag labels
            if showflags == 1 && ~isempty(s.flags{col_dir})
               flagvals = s.flags{col_dir};
               Iflags = find(flagvals(Idir,1)~=' ');
               if ~isempty(Iflags)
                  h_fl = text(d(Idir(Iflags)),dir(Idir(Iflags)),flagvals(Iflags,:));
                  set(h_fl, ...
                     'fontname','Times', ...
                     'fontsize',9, ...
                     'horizontalalignment','center', ...
                     'verticalalignment','bottom', ...
                     'color',[.8 0 0], ...
                     'clipping','on', ...
                     'tag','flags')
               end
            end

            set(h_dirax, ...
               'XLim',xlim, ...
               'YAxisLocation','right', ...
               'YLim',[0 360], ...
               'YTick',[0 90 180 270 360], ...
               'YTickLabel',char('0°(N)','90°(E)','180°(S)','270°(W)','360°(N)'), ...
               'YGrid','on');

            ylabel(dir_lbl, ...
               'FontSize',14, ...
               'Fontweight','bold', ...
               'Interpreter','none', ...
               'ButtonDownFcn','textedit');

            xlabel(date_lbl, ...
               'FontSize',14, ...
               'Fontweight','bold', ...
               'Interpreter','none', ...
               'ButtonDownFcn','textedit');

            %add date axis and plot button bar
            dateaxis
            plotbuttons

         end

      else
         msg = 'invalid column selections';
      end

   else
      msg = 'invalid data structure';
   end

else
   msg = 'insufficient arguments for function';
end