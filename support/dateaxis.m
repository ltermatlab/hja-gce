function dateaxis
%Refreshes date ticks on the x-axis of the current plot
%
%syntax: dateaxis
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
%last modified: 14-Apr-2015

xtick = get(gca,'xtick');

%get handles of data axes
h_ax = findobj(gcf,'type','axes');

%remove legend axes from legacy MATLAB versions
if mlversion < 8.4
   for n = 1:length(h_ax)
      if strcmp(get(h_ax(n),'tag'),'legend') || isempty(get(h_ax(n),'XTickLabel'))
         h_ax(n) = NaN;  %flag legend axes for omission
      end
   end
   h_ax = h_ax(~isnan(h_ax));
end

try

   h_gca = gca;

   for n = 1:length(h_ax)

      axes(h_ax(n))  %set focus

      if min(xtick) >= 657438 && max(xtick) <= 767376  %check for 1/1/1800-1/1/2101

         h = findobj(gcf,'tag','popDateAxis');
         if ~isempty(h)
            val = get(h,'value');
            ud = get(h,'userdata');
            fmt = ud{val};
         else
            fmt = -1;  %auto
         end

         if fmt == -1  %auto ticks
            int = max(diff(xtick)); %get maximum interval
            if int >= 365
               fmt = 10;  %yyyy
            elseif int >= 30
               fmt = 12;  %mmmyy
            elseif int >= 1
               fmt = 2;   %mm/dd/yy
            else
               fmt = 15;  %HH:MM
            end
         end

         if length(fmt) > 1  %multi-element formats
            str = datestr(xtick,fmt(1));
            num = length(xtick);
            for m = 2:length(fmt)
               str = [str,repmat(' ',num,1),datestr(xtick,fmt(m))];  %append additional strings
            end
            set(gca,'xticklabel',str)
         elseif fmt > 0  %single formats
            set(gca,'xticklabel',datestr(xtick,fmt))
         else  %no date format
            set(gca,'xticklabelmode','auto')
         end

      else
         set(gca,'xticklabelmode','auto')
      end

      axes(h_gca)  %reset current axes

   end

catch
   set(gca,'xticklabelmode','auto')
end