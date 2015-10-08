function [msg,h_fig] = plotgroups(s,xcol,ycol,groupcols,maxgps,colors,markers,styles,fillmarkers,markersize,rotateaxis,scale,flags,visible)
%Creates multiple line/scatter plots for values in two columns of a GCE Data Structure,
%with one line plotted for each distinct value in a series of one or more grouping columns
%
%syntax:  [msg,h_fig] = plotgroups(s,xcol,ycol,groupcols,maxgps,colors,markers,styles,fillmarkers,markersize,rotateaxis,scale,flags,visible)
%
%inputs:
%  s = data structure
%  xcol = column number or name to use for x-axis values (if string, must be valid MATLAB datetime format)
%  ycol = column number or name to use for y-axis values (must be numeric)
%  groupcols = column numbers or names to use for grouping data to plot as individual lines (string or numeric)
%  maxgps = maximum number of groups to display (default = 10);
%  colors = cell array of colors to cycle through for multiple line plots
%  markers = cell array of markers to cycle through for multiple line plots
%  styles = cell array of line styles to cycle through for multiple line plots
%  fillmarkers = option to fill marker symbols with the specified color
%    0 = no/default
%    1 = yes
%  markersize = fontsize for symbols (default = 5)
%  rotateaxis = option to rotate plot axis so X values are on the ordinate, and Y values
%    are along the abscissa: 0 = do not rotate (default); 1 = rotate
%  scale = y-axis scaling option: 'linear' (default) or 'log'
%  flags = option to plot QC flag characters above respective data points
%    0 = no
%    1 = yes - plotted as characters (default)
%    2 = yes - plotted as red symbols on top of data values
%  visible = plot display option
%    'on' = display plot on the console (default)
%    'off' = do not display (e.g. for batch plotting during data harvesting)
%
%output:
%  msg = text of any error messages
%  h_fig = handle of figure generated
%
%
%(c)2002-2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 01-Jun-2015

msg = '';
h_fig = [];

if nargin >= 4  %check for sufficient args

   if gce_valid(s,'data')

      %initialize lists of standard markers and colors
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

      styles0 = [ ...
         {'-'}; ...
         {':'}; ...
         {'-.'}; ...
         {'--'}];

      colors0 = [ ...
         {'b'},{[0 0 1]}; ...
         {'g'},{[0 1 0]}; ...
         {'k'},{[0 0 0]}; ...
         {'r'},{[1 0 0]}; ...
         {'c'},{[0 1 1]}; ...
         {'m'},{[1 0 1]}; ...
         {'y'},{[1 1 0]}];

      if exist('flags','var') ~= 1 || isempty(flags)  %default to displaying flags
         flags = 1;
      end

      if exist('scale','var') ~= 1 || isempty(scale)
         scale = 'linear';  %default to linear axis scaling
      end

      if exist('rotateaxis','var') ~= 1 || isempty(rotateaxis)
         rotateaxis = 0;  %default to standard y vs x orientation
      end

      %initialize lines, markers, colors to empty if omitted
      if exist('styles','var') ~= 1
         styles = [];
      elseif ischar(styles)
         styles = cellstr(styles);
      end
      if exist('markers','var') ~= 1
         markers = [];
      elseif ischar(markers)
         markers = cellstr(markers);
      end
      if exist('colors','var') ~= 1
         colors = [];
      elseif ischar(colors)
         colors = cellstr(colors);
      end
      if exist('fillmarkers','var') ~= 1
         fillmarkers = 0;
      end
      if exist('markersize','var') ~= 1
         markersize = 5;
      end

      if exist('maxgps','var') ~= 1
         maxgps = 10;  %default to <=10 lines
      elseif maxgps == 0
         maxgps = inf;  %no limit
      end

      %set default visibility if omitted
      if exist('visible','var') ~= 1 || isempty(visible) || ~ischar(visible) || ~strcmpi(visible,'off')
          visible = 'on';
      end

      %perform name-to-column substitutions
      if ~isnumeric(xcol)
         xcol = name2col(s,xcol);
      end
      if ~isnumeric(ycol)
         ycol = name2col(s,ycol);
      end
      if ~isnumeric(groupcols)
         groupcols = name2col(s,groupcols);
      end

      %validate column selections
      if ~isempty(xcol) && ~isempty(ycol) && ~isempty(groupcols)
         xcol = xcol(1);
         ycol = ycol(1);
         if xcol ~= ycol
            if ~(strcmp(s.datatype{xcol},'s') && ~strcmp(s.variabletype{xcol},'datetime')) && ~strcmp(s.datatype{ycol},'s')
               s = sortdata(s,groupcols,1);
               if isempty(s)
                  msg = 'invalid grouping column(s)';
               end
            else
               msg = 'invalid column selections - text columns are not supported';
               s = [];
            end
         else
            msg = 'X and Y columns must be distinct';
            s = [];
         end
      else
         msg = 'invalid column selections';
         s = [];
      end
      
      if ~isempty(s)  %check for valid selections/sort

         %produce all-numerical comparison matrix
         numcols = length(groupcols);
         numrows = length(s.values{1});
         compmat = ones(numrows,numcols);
         types = s.datatype;
         for n = 1:numcols
            x = s.values{groupcols(n)};
            if strcmp(types{groupcols(n)},'s')  %substitute unique integers for strings
               Igp = [find([0;strcmp(x(1:length(x)-1),x(2:length(x)))]==0) ; numrows+1];
               for m = 1:length(Igp)-1
                  compmat(Igp(m):Igp(m+1)-1,n) = m;
               end
            else
               compmat(:,n) = x;
            end
         end

         %calculate master grouping index by comparing row-to-row diffs and padding array
         if numcols == 1
            I_breaks = [1 ; find([0 ; (abs(compmat(1:numrows-1,:)-compmat(2:numrows,:))')']) ; ...
               numrows+1];
         else
            I_breaks = [1 ; find([0 ; sum(abs(compmat(1:numrows-1,:)-compmat(2:numrows,:))')']) ; ...
               numrows+1];
         end

         %calculate number of lines to generate
         numlines = length(I_breaks) - 1;
         if numlines > maxgps
            numlines = maxgps;
            I_breaks = I_breaks(1:maxgps+1);
         end

         %generate array of markers
         if isempty(markers)  %use defaults if omitted, blank
            markers = repmat(markers0,ceil(numlines./12),1);
         elseif strcmp(markers(1),'none')  %check for none
            markers = repmat({''},numlines,1);
         elseif length(markers) < numlines  %replicate insufficient markers
            markers = repmat(markers,1,ceil(numlines./length(markers)));
         end

         %generate array of line styles
         if isempty(styles)
            styles = repmat(styles0,ceil(numlines./4),1);
         elseif strcmp(styles{1},'none')
            styles = repmat({''},numlines,1);
         elseif length(styles) < numlines
            styles = repmat(styles,ceil(numlines./length(styles)),1);
         end

         %generate array of colors
         if isempty(colors)  %pad color selections to match columns
            colors = repmat(colors0(:,1),ceil(numlines./6),1);
         elseif length(colors) < numlines
            colors = repmat(colors(:)',1,ceil(numlines./length(colors)));
         end

         %generate fill array
         fills = ones(length(colors),3);
         if fillmarkers == 1
            for n = 1:length(colors)
               Iclr = find(strcmp(colors0(:,1),colors{n}));
               if ~isempty(Iclr)
                  fills(n,1:3) = colors0{Iclr(1),2};
               end
            end
            %colors = repmat({'k'},1,length(colors));  %override edgecolor
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

         %proceed to generate plots if valid data in structure columns
         if ~isempty(find(~isnan(s.values{ycol}))) && ...
               ((~strcmp(s.datatype{xcol},'s') && ~isempty(find(~isnan(s.values{xcol})))) || ...
               (strcmp(s.datatype{xcol},'s') && ~isempty(find(~cellfun('isempty',s.values{xcol})))))

            legendstr = cell(numlines,1);

            res = get(0,'ScreenSize');

            h_fig = figure('Visible',visible, ...
               'Name',['Plot of ',titlestr], ...
               'Position',[max(0,round((res(3)-850)/2)) max(50,round((res(4)-600)/2)) 850 600], ...
               'Color',[1 1 1], ...
               'PaperPositionMode','auto', ...
               'InvertHardcopy','off', ...
               'NumberTitle','off', ...
               'UserData',[]);

            h_GCE = plotmenu('GCETools',h_fig);  %generate standard menu items

            uimenu('Parent',h_GCE, ...
               'Separator','on', ...
               'Label','Visual QC Tool Window', ...
               'Callback','ui_visualqc(''init'')', ...
               'Tag','mnuVisualQC');

            set(gcf,'pointer','watch')
            drawnow

            groupnames = [];

            if strcmp(s.datatype{xcol},'s') && strcmp(s.variabletype{xcol},'datetime')
               convertdate = 1;
            else
               convertdate = 0;
            end
            
            %generate lines
            for n = 1:numlines

               I = I_breaks(n):min(numrows,I_breaks(n+1)-1);  %generate index for group
               xdata = s.values{xcol}(I);  %grab x column data
               if convertdate == 1
                  try
                     xdata = datestr2num(xdata,s.units{xcol});
                  catch
                     xdata = [];
                  end
               end
               ydata = s.values{ycol}(I);  %grab y column data

               %plot if not empty
               if ~isempty(xdata) && ~isempty(ydata)

                  [xdata,Isort] = sort(xdata);
                  ydata = ydata(Isort);

                  I_flags = [];
                  if flags == 1 && ~isempty(s.flags{ycol})
                     flagvals = s.flags{ycol}(I,:);
                     if size(flagvals,1) > 0
                        flagvals = flagvals(Isort);
                        I_flags = find(flagvals(:,1)~=' ');
                     end
                  end

                  if rotateaxis == 1
                     h = plot(ydata,xdata,[colors{n},markers{n},styles{n}]);
                     if ~isempty(I_flags)
                        if flags == 1  %character flags
                           h_fl = text(ydata(I_flags),xdata(I_flags),flagvals(I_flags,:));
                        else  %symbol flags
                           hold on;
                           h_fl = plot(ydata(I_flags),xdata(I_flags),['r',markers{n}]);
                        end
                     end
                  else
                     h = plot(xdata,ydata,[colors{n},markers{n},styles{n}]);
                     if ~isempty(I_flags)
                        if flags == 1
                           h_fl = text(xdata(I_flags),ydata(I_flags),flagvals(I_flags,:));
                        else
                           hold on;
                           h_fl = plot(xdata(I_flags),ydata(I_flags),['r',markers{n}]);
                        end
                     end
                  end
                  
                  if sum(fills(n,:)) < 3
                     set(h,'Clipping','on','MarkerFaceColor',fills(n,:),'MarkerSize',markersize)
                  else
                     set(h,'Clipping','on','MarkerSize',markersize)
                  end

                  hold on

                  %set properties of flag characters or symbols
                  if ~isempty(I_flags)
                     if flags == 1
                        set(h_fl, ...
                           'fontname','Times', ...
                           'fontsize',9, ...
                           'horizontalalignment','center', ...
                           'verticalalignment','bottom', ...
                           'color',[.8 0 0], ...
                           'clipping','on', ...
                           'tag',['flags_',int2str(n)])
                     else
                        set(h_fl, ...
                           'Clipping','on', ...
                           'MarkerFacecolor',[1 0 0], ...
                           'MarkerSize',markersize(n), ...
                           'Tag',['flags_',int2str(n)])
                     end
                  end
                  
                  str = '';
                  for m = 1:length(groupcols)
                     if strcmp(s.datatype{groupcols(m)},'s')
                        groupname = [s.name{groupcols(m)},' = ',s.values{groupcols(m)}{I(1)}];
                     else
                        groupname = [s.name{groupcols(m)},' = ',num2str(s.values{groupcols(m)}(I(1)))];
                     end
                     str = [str,groupname,', '];
                     groupnames = [groupnames ; {groupname}];
                  end

                  legendstr{n} = str(1:end-2);

               end

            end

            uih = struct( ...
               's',s, ...
               'x',xcol, ...
               'y',ycol, ...
               'Igroups',[I_breaks], ...
               'groupnames',{groupnames}, ...
               'rotate',rotateaxis, ...
               'scalefactor',[]);

            set(h_fig,'UserData',uih)

            hold off
            axis auto  %autoscale axis

            %create plot title
            axpos = get(gca,'Position');
            axwid = .88;

            if size(figtitle,1) > 1
               set(gca,'Position',[.08 axpos(2) axwid max(.65,axpos(4)-(0.02 .* size(figtitle,1)))])
            else
               set(gca,'Position',[.08 axpos(2) axwid axpos(4)])
            end

            title(figtitle, ...
               'FontName','Helvetica', ...
               'FontSize',14, ...
               'FontWeight','bold', ...
               'Interpreter','none', ...
               'ButtondownFcn','textedit');

            if ~strcmp(s.units{xcol},'none')
               xlblstr = [s.name{xcol},' (',s.units{xcol},')'];
            else
               xlblstr = s.name{xcol};
            end

            if ~strcmp(s.units{ycol},'none')
               ylblstr = [s.name{ycol},' (',s.units{ycol},')'];
            else
               ylblstr = s.name{ycol};
            end

            %set default grid, background color
            set(gca,'YGrid','on','Color','none')

            %create axis labels, legend, set scaling options
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

               axpos = get(gca,'Position');
               set(gca, ...
                  'XAxisLocation','top', ...
                  'Position',[axpos(1),axpos(2)-.05,axpos(3:4)], ...
                  'YDir','reverse')

               if strcmp(scale,'log')
                  set(gca,'XScale','log','XGrid','on')
               end

               %display date ticks if appropriate
               if strcmp(s.variabletype{xcol},'datetime') && ~strcmp(s.datatype{xcol},'s')
                  try
                     xtick = get(gca,'YTick');
                     if min(xtick) > 693962 && max(xtick) < 767376  %datenums for 1900-2100
                        dstr = datestr(xtick,2);
                     else
                        dstr = '';
                     end
                  catch
                     dstr = '';
                  end
                  if ~isempty(dstr)  %replace tick labels
                     %add date labels and establish auto function for rescaling dates after zoom
                     set(gca,'YTickLabel',dstr, ...
                        'ButtonDownFcn','dateaxis')
                     h_dateaxis = findobj(gcf,'tag','popDateAxis');
                     set(h_dateaxis,'Value',2)
                     dateaxis
                  end
               end

               if mlversion < 7
                  hl = legend(legendstr,-1);
               else
                  hl = legend(legendstr,'Location','NorthEastOutside');
               end

            else  %standard y vs x plot

               ylabel(ylblstr, ...
                  'FontSize',14, ...
                  'Fontweight','bold', ...
                  'Interpreter','none', ...
                  'ButtonDownFcn','textedit');

               xlabel(xlblstr, ...
                  'FontSize',14, ...
                  'Fontweight','bold', ...
                  'Interpreter','none', ...
                  'ButtonDownFcn','textedit');

               if strcmp(scale,'log')
                  set(gca,'YScale','log')
               end

               %display date ticks if appropriate
               if strcmp(s.variabletype{xcol},'datetime')
                  try
                     xtick = get(gca,'XTick');
                     if min(xtick) > 693962 && max(xtick) < 767376  %datenums for 1900-2100
                        dstr = datestr(xtick,2);
                     else
                        dstr = '';
                     end
                  catch
                     dstr = '';
                  end
                  if ~isempty(dstr)  %replace tick labels
                     %add date labels and establish auto function for rescaling dates after zoom
                     set(gca,'XTickLabel',dstr, ...
                        'ButtonDownFcn','dateaxis')
                     h_dateaxis = findobj(gcf,'tag','popDateAxis');
                     set(h_dateaxis,'Value',2)
                     dateaxis
                  end
               end

               if mlversion < 7
                  hl = legend(legendstr,-1);
               else
                  hl = legend(legendstr,'Location','NorthEastOutside');
               end

            end

            %format legend
            if mlversion < 7
               set(hl,'Color',[1 1 1],'XColor',[1 1 1],'YColor',[1 1 1]);  %clear border to prevent text overruns
               ht = findobj(hl,'Type','Text');
               set(ht,'Interpreter','none','FontSize',8)  %use non-TeX interpreter for text to avoid underscore problems
            else
               set(hl,'Color',[1 1 1]);
               set(hl,'Interpreter','none','FontSize',8)
               if mlversion < 8.4
                  set(hl,'Location','none')  %set location to none to avoid plot refresh problems
               end
            end

            set(gcf,'pointer','arrow')

            plotbuttons  %add axis zooming toolbar

         else
            msg = 'no valid data to plot';
         end

      end

   end

end