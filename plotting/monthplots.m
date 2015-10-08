function msg = monthplots(s,parms,flags,pn,colors,markers,styles,fillmarkers,markersize,yaxlims)
%Generates monthly date plots for a multiple parameters in a GCE data structure,
%and saves the figures as a series of .png files
%
%syntax: msg = monthplots(s,parms,nullflags,pn,colors,markers,linestyles,fillmarkers,markersize,yaxlims)
%
%inputs:
%  s = data structure (file dialog will appear if omitted or empty)
%  parms = parameter to plot (parameter list will appear if omitted or empty)
%  nullflags = option to null flagged values (1 = yes, 0 = no/default)
%  pn = pathname to save plots (default = pwd)
%  colors = cell array of color codes (default = plotdata defaults)
%  markers = cell array of marker codes (default = plotdata defaults)
%  linestyles = cell array of linestyle codes (default = plotdata defaults)
%  fillmarkers = option to fill markers with corresponding color (0 = no/default, 1 = yes)
%  markersize = marker fontsize (default = 6)
%  yaxlims = y-axis range to use (default = auto)
%
%outputs:
%  msg = text of any error message
%
%(c)2002-2006 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 09-Dec-2005

msg = '';
curpath = pwd;

if exist('s','var') ~= 1
   s = [];
end

if isempty(s)

   [fn,pn] = uigetfile('*.mat;*.MAT','Select a Sonde file to plot');

   if fn ~= 0
      cd(pn)
      v = load(fn);
      if isstruct(v)
         if isfield(v,'data')
            s = v.data;
            if gce_valid(s,'data') ~= 1
               s = [];
            end
         end
      end
      cd(curpath)
   end

end

if ~isempty(s)

   if exist('yaxlims','var') ~= 1
       yaxlims = [];
   end

   if exist('fillmarkers','var') ~= 1
      fillmarkers = 0;
   end

   if exist('markersize','var') ~= 1
      markersize = 6;
   end

   if exist('styles','var') ~= 1
      styles = [{'-'};{':'};{'--'};{'-.'}];
   end

   if exist('markers') ~=1
      markers = [];
   end

   if exist('colors','var') ~= 1
      colors = [];
   end

   if exist('pn','var') ~= 1
      pn = pwd;
   end

   if exist('flags','var') ~= 1
      flags = 0;
   end

   if exist('parms','var') ~= 1
      parms = '';
   end

   if isempty(parms)
      ar = [s.name',repmat({' ('},length(s.name),1),s.units',repmat({')'},length(s.name),1)];
      ycol = listdialog( ...
         'liststring',concatcellcols(ar), ...
         'name','Choose Parameters', ...
         'promptstring','Choose parameters to plot', ...
         'selectionmode','multiple', ...
         'listsize',[0 0 250 350]);
   else
      ycol = name2col(s,parms);
   end

   if ~isempty(ycol)

      datecol = name2col(s,'Date');

      if ~isempty(datecol)

         datevals = extract(s,datecol);

         if iscell(datevals);
            datevals = datenum(char(datevals));
         end

         Idate = find(~isnan(datevals));
         mindate = floor(min(datevals(Idate)));
         minmonth = datenum(['01-',datestr(mindate,3),'-',datestr(mindate,10)]);
         maxdate = ceil(max(datevals(Idate)));
         maxmonth = datenum(['01-',datestr(maxdate+32,3),'-',datestr(maxdate,10)]);

         if flags == 1
            s = nullflags(s);
         end

         months = [{'January'}, ...
               {'February'}, ...
               {'March'}, ...
               {'April'}, ...
               {'May'}, ...
               {'June'}, ...
               {'July'}, ...
               {'August'}, ...
               {'September'}, ...
               {'October'}, ...
               {'November'}, ...
               {'December'}];

         ticklbls = repmat({''},31,1);
         ticklbls{1} = '1';
         ticklbls{7} = '7';
         ticklbls{14} = '14';
         ticklbls{21} = '21';
         ticklbls{28} = '28';
         ticklbls = char(ticklbls);

         plotdata(s,datecol,ycol,colors,markers,styles,fillmarkers,markersize,'auto',0,1,1,1,1,yaxlims);
         plotbuttons hide
         ax = axis;

         %autogenerate base filename
         fn = '';
         for n = 1:length(ycol)
            parm = lower(s.name{ycol(n)});
            if length(ycol) > 3
               parm = parm(1:min(5,length(parm)));
            end
            fn = [fn,parm,'_'];
         end

         cd(pn)

         while minmonth < maxmonth  %print interval plots

            fname = [fn,lower(datestr(minmonth,12))];

	         if ~strcmp(datestr(minmonth,5),'12')
   	         nextmonth = datenum(['01-',datestr(minmonth+32,3),'-',datestr(minmonth,10)]);
      	   else  %wrap year
         	   nextmonth = datenum(['01-Jan-',datestr(minmonth+32,10)]);
	         end

            ax = axis;
            axis([minmonth nextmonth-1 ax(3:4)])

            set(get(gca,'XLabel'),'String',[months{str2num(datestr(minmonth,5))},' ',datestr(minmonth,10)])
            set(gca,'XTick',[minmonth:minmonth+(nextmonth-minmonth)])
            set(gca,'XTickLabel',ticklbls)

            if flags == 0
               clipplottext  %manage flag label visibility
            end

            eval(['print -dpng -r96 -noui ',fname])

            minmonth = nextmonth;

         end

         close(gcf)
         cd(curpath)

      else

         msg = 'this function requires a GCE structure containing ''Site'' and ''Date'' columns';

      end

   else

      msg = 'no valid data to plot - cancelled';

   end

else

   msg = 'this function requires a valid GCE data structure';

end
