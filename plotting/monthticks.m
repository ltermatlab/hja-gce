function monthticks(fmt,months,h_ax)
%Sets X-axis limits and ticks to even month intervals in a specified date label format for a time-series plot
%
%syntax: monthticks(fmt,months,h_ax)
%
%input:
%  fmt = numeric date string format for 'datestr' function:
%     1 = dd-mmm-yyyy (default)
%     2 = mm/dd/yy
%     12 = mmmyy
%     20 = dd/mm/yy
%     28 = mmmyyyy
%     29 = yyyy-mm-dd
%     (see datestr help for more options)
%  months = numeric array of months to include ticks for (default = auto)
%  h_ax = axis object to update (default = gca)
%
%output:
%  none
%
%note: x-axis range will be set to include the first day of the first month and first day 
%    of the following month based on the starting axis limits
%
%
%(c)2011 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 13-Sep-2011

%supply defaults for omitted arguments
if exist('fmt','var') ~= 1
   fmt = 1;
elseif ~isnumeric(fmt) || fmt > 31
   fmt = 1;
end

%get current axis handle unless no figures open (to avoid opening a blank one when calling gca)
if exist('h_ax','var') ~= 1
   if length(findobj) > 1
      h_ax = gca;
   else
      h_ax = [];
   end
end

if ~isempty(h_ax)
   
   %get current x axis limits
   xlim = get(h_ax,'XLim');
   
   %parse start and end dates
   [yr1,mn1] = datevec(xlim(1));
   [yr2,mn2,dy2] = datevec(xlim(2));
   
   %set default months if omitted
   if exist('months','var') ~= 1
      if diff(xlim) <= 365
          months = (1:12);  %all months for <=1 year date span
      elseif yr2-yr1 > 8
          months = 1;  %january only for decadal plots
      elseif yr2-yr1 > 4
          months = [1 7];  %january and june for long-term plots
      elseif yr2-yr1 > 2
          months = [1 4 7 10];  %quarterly for medium-term plots
      else  
          months = [1 3 5 7 9 11];  %every other month for multi-year plots   
      end
   end
   
   %kick mid-month end date to next month
   if dy2 > 1
      if mn2 < 12
         mn2 = mn2 + 1;
      else
         yr2 = yr2 + 1;
         mn2 = 1;
      end
   elseif yr2 > yr1 && mn2 == 1
      %catch 1 day roll-over to next year
      yr2 = yr2 - 1;
      mn2 = 12;
   end    
   
   %generate matching arrays of months, years
   if yr1 == yr2
      mos = (mn1:mn2)';
      yrs = repmat(yr1,length(mos),1);
   elseif yr2-yr1 > 1
      mos = [mn1:12,repmat((1:12),1,yr2-yr1-1),1:mn2]';
      yrs = ones(length(mos),1);
      numyrs = yr2 - yr1 + 1;
      for n = 1:numyrs
         yr = yr1 + n - 1;
         if n == 1  %first year
            Istart = 1;
            Iend = 12 - mn1 + 1;
         elseif n == numyrs  %last year
            Istart = length(mos) - mn2 + 1;
            Iend = length(mos);
         else  %intermediate year
            %get indices for current year (offset by number of months in first year
            Istart = 12.*(n-2) + 12-mn1+2;
            Iend = Istart + 11; 
         end
         yrs(Istart:Iend) = yr;
      end
   else
      mos = [mn1:12,1:mn2]';
      yrs = [repmat(yr1,1,12-mn1+1),repmat(yr2,1,mn2-1+1)]';
   end

   %generate date ticks, tick labels for all months
   xtick = datenum(yrs,mos,ones(length(mos),1));
   xlabel = cellstr(datestr(xtick,fmt));
   
   %limit tick labels to specified months
   Imatch = inarray(mos,months);
   xlabel(~Imatch) = {''};
   
   %set axis limit to even month increment and set ticks, labels
   set(gca, ...
      'XLim',[xtick(1) xtick(end)], ...
      'XTick',xtick, ...
      'XTickLabel',char(xlabel))
   
end
