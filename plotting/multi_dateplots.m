function [fn_array,msg] = multi_dateplots(s,ycols,fn_base,pn,datecol,daterange,datetickfmt,labels,colors,markers,linestyles,fillmarkers,markersize,figsize,fmt)
%Generates individual plot files for selected columns in a GCE Data Structure
%
%syntax: [fn_array,msg] = multi_dateplots(s,ycols,fn_base,pn,datecol,daterange,datetickfmt,labels,colors,markers,linestyles,fillmarkers,markersize,figsize,fmt)
%
%inputs:
%   s = data structure containing variables to plot, or filename of a data structure (struct or char; required)
%   ycols = array of column names or indices to plot (cell or integer array; required)
%   fn_base = base filename for plot files (string; required)
%   pn = path name for saving plots (string; required)
%   datecol = name or index of string or numeric date column (string or integer; required)
%   daterange = 1 or 2-element cell or numeric array indicating starting and ending date to plot 
%     (cell or numeric array; optional; default = [] for automatic based on date range in data set)
%   datetickfmt = date tick format - see help datestr (string or integer; optional; default = auto')
%   labels = array of labels to use as plot titles (cell array; optional; default = column names)
%   colors = string or cell array of Matlab color values for each column - see 'help plot' (default = 'b')
%   markers = string or cell array of Matlab marker styles - see 'help plot' (default = 'o')
%   linestyles = string or cell array of Matlab line styles - see 'help plot' (default = '-')
%   fillmarkers = option to fill marker symbols with the specified color
%      0 = no
%      1 = yes/default
%      (or array of 0,1 matching ycols)
%   markersize = fontsize for marker symbols (default = 5)
%   figsize = 2-element array of figure width and height in pixels (numeric array; optional;
%     default = [800 600])
%   fmt = file format option:
%     'png' = Portable Networks Graphics (PNG) image - default
%     'jpg' = JPEG image
%
%outputs:
%  fn_array  = cell array of plot filenames
%
%notes:
%  1) if daterange only includes one date string or datenum it will be used as the starting date
%     and ending date will be determined automatically, e.g. daterange = now-7 will always
%     plot the last 7 days of data in the file
%
%
%(c)2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 20-May-2013

%init output
fn_array = [];
msg = '';

%check for required arguments and validate input
if nargin >= 5 && ~isempty(ycols) && ~isempty(fn_base) && ~isempty(pn) && ~isempty(datecol)
   
   %validate path
   if isdir(pn)
      
      if ischar(s)
         if exist(s,'file') == 2
            try
               vars = load(s,'-mat');
            catch e
               vars = struct('null','');
               msg = ['an error occurred loading the file (',e.message,')'];
            end
            if isfield(vars,'data')
               s = vars.data;
            elseif isempty(msg)
               msg = 'the file does not include a valid GCE Data Structure';
            end
         else
            msg = [s,' was not found in the MATLAB search path'];
         end
      end
      
      if gce_valid(s,'data')
         
         %set defaults for omitted plot options
         if exist('colors','var') ~= 1 || isempty(colors)
            colors = 'b';
         end
         if ischar(colors)
            %replicate scalar color
            colors = repmat({colors},length(ycols),1);
         elseif length(colors) < length(ycols)
            %pad colors to match length of y columns
            colors = [colors(:)' repmat(colors(end),1,length(ycols)-length(colors))];
         end
         
         if exist('markers','var') ~= 1 || isempty(markers)
            markers = 'o';
         end
         if ischar(markers)
            %replicate scalar marker
            markers = repmat({markers},length(ycols),1);
         elseif length(markers) < length(ycols)
            %pad markers to match length of ycols
            markers = [markers(:)' repmat(markers(end),1,length(ycols)-length(markers))];
         end
         
         if exist('linestyles','var') ~= 1 || isempty(linestyles)
            linestyles = '-';
         end
         if ischar(linestyles)
            %replicate scalar style
            linestyles = repmat({linestyles},length(ycols),1);
         elseif length(linestyles) < length(ycols)
            %pad style to match length of ycols
            linestyles = [linestyles(:)' repmat(linestyles(end),1,length(ycols)-length(linestyles))];
         end
         
         %set default fill option
         if exist('fillmarkers','var') ~= 1 || isempty(fillmarkers)
            fillmarkers = 1;
         end
         
         %set default marker size option
         if exist('markersize','var') ~= 1 || isempty(markersize)
            markersize = 5;
         end
         
         %validate column indices
         if ~isnumeric(ycols)
            %look up column indices returning NaN for any invalid columns
            ycols = name2col(s,ycols,0,'','',1);
         else
            %replace any invalid column indices with NaN
            ycols(~inarray(ycols,(1:length(s.name)))) = NaN;
         end
         
         %set cols to empty if no valid columns
         if sum(~isnan(ycols)) == 0
            ycols = [];
         end
         
         %check for valid columns, generate date array for plotting
         if ~isempty(ycols)
            
            %check for datecol
            if exist('datecol','var') ~= 1
               datecol = [];
            elseif ~isnumeric(datecol)
               datecol = name2col(s,datecol);
            end
            
            %get dates
            dt = get_studydates(s,datecol);
            
         else
            dt = [];
         end
         
         %check for valid columns and dates
         if ~isempty(ycols) && ~isempty(dt)
            
            %validate labels
            if exist('labels','var') ~= 1 || length(labels) ~= length(ycols)
               labels = s.name(ycols(~isnan(ycols)));
            else
               %remove labels for unmatched columns
               labels = labels(~isnan(ycols));
            end
            
            %remove plot options for invalid columns
            if ~isempty(colors)
               colors = colors(~isnan(ycols));
            end
            if ~isempty(markers)
               markers = markers(~isnan(ycols));
            end
            if ~isempty(linestyles)
               linestyles = linestyles(~isnan(ycols));
            end
            
            %remove invalid columns
            ycols = ycols(~isnan(ycols));
            
            %generate default min/max
            dt_min_default = floor(min(no_nan(dt)));
            dt_max_default = ceil(max(no_nan(dt)));
            dt_min = NaN;
            dt_max = NaN;
            
            %validate daterange
            if exist('daterange','var') ~= 1
               daterange = [];
            elseif ischar(daterange)
               daterange = cellstr(daterange);  %convert string start date to cell array
            end
            
            %assign dt_min
            if length(daterange) >= 1
               if isnumeric(daterange)
                  dt_min = daterange(1);
               else
                  dt_min = datenum(daterange{1});
               end
            end
            
            %assign dt_max
            if length(daterange) >= 2
               if isnumeric(daterange)
                  dt_max = daterange(2);
               else
                  dt_max = datenum(daterange{2});
               end
            end
            
            %check for missing/invalid min/max
            if isnan(dt_min)
               dt_min = dt_min_default;
            end
            if isnan(dt_max)
               dt_max = dt_max_default;
            end
            
            %set default datetick format if omitted
            if exist('datetickfmt','var') ~= 1 || isempty(datetickfmt)
               datetickfmt = 'dd-mmm-yyyy';
            end
            
            %subset data by date
            Idates = find(dt>=dt_min & dt<=dt_max);
            
            %check for valid data in range
            if ~isempty(Idates)
               
               %subset data and date array
               s = copyrows(s,Idates,'Y');
               
               %set default figsize if omitted
               if exist('figsize','var') ~= 1 || ~isnumeric(figsize) || length(figsize) < 2
                  figsize = [800 650];
               end
               
               %set default format if omitted
               if exist('fmt','var') ~= 1 || ~strcmp(fmt,'jpg')
                  fmt = 'png';
               end
               
               %init output filename array
               fn_array = repmat({''},length(ycols),1);
               
               %generate plots
               for n = 1:length(ycols)
                  
                  %get column data and metadata
                  y = extract(s,ycols(n));
                  
                  if isnumeric(y)
                     
                     %get y limits
                     y_min = floor(min(no_nan(y)));                     
                     y_max = ceil(max(no_nan(y)));
                     if y_min == y_max
                        y_max = y_min + 1;
                     end
                     
                     %get units and variable name
                     units = s.units{ycols(n)};
                     varname = strrep(s.name{ycols(n)},' ','_');
                     
                     %generate plot
                     [msg,h_fig] = plotdata(s, ...
                        datecol, ...     %date as X
                        ycols(n), ...    %column as Y
                        colors{n}, ...   %color
                        markers{n}, ...  %marker
                        linestyles{n}, ...   %line style
                        fillmarkers, ... %marker fill
                        markersize, ...  %marker size
                        'linear', ...    %scale
                        0, ...           %rotate option
                        1, ...           %x-sort option
                        1, ...           %date axis option
                        1, ...           %flag display option
                        0, ...           %deblank option
                        [dt_min dt_max y_min y_max] ... %axis limits
                        );
                     
                     if isempty(msg)
                        
                        %set figure size
                        pos = get(h_fig,'Position');
                        set(h_fig,'Position',[pos(1) pos(2) figsize(1) figsize(2)])
                        
                        %update axis labels and title
                        h_ax = gca;
                        set(get(h_ax,'Title'),'String',labels{n})
                        set(get(h_ax,'XLabel'),'String','Date')
                        set(get(h_ax,'YLabel'),'String',units)
                        
                        %update date tick format
                        datetick(h_ax,'x',datetickfmt,'keeplimits','keepticks');
                        
                        %generate filename
                        fn = [pn,filesep,fn_base,'_',varname,'.',fmt];
                        fn_array{n} = fn;
                        
                        %save file
                        if strcmp(fmt,'jpg')
                           print(fn,'-djpeg90','-r96','-noui');
                        else
                           print(fn,'-dpng','-r96','-noui');
                        end
                        
                        %close figure
                        delete(h_fig)
                        
                     end
                     
                  end
                  
               end
               
            else
               msg = 'no valid data in the specified range to plot';
            end
            
         else
            if isempty(ycols)
               msg = 'invalid column selection';
            else
               msg = 'date column is invalid or could not be identified';
            end
         end
         
      else
         %check for file loading error message - if none, report validation error
         if isempty(msg)
            msg = 'invalid data structure';
         end
      end
      
   else
      msg = 'invalid output path';
   end
   
end
