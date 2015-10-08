function msg = monthplotsfig(fn,pn,h)
%Generates individual monthly date plots from a standard date plot and saves each plot as a .png file
%
%syntax: msg = monthplotsfig(fn,pn,h)
%
%inputs:
%  fn = base filename for plots (_mmmyy.png will be appended)
%  pn = pathname for saved plots (default = pwd)
%  h = handle of date plot figure (x axis must be serial date numbers; default = gcf)
%
%outputs:
%  msg = text of any error message
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

curpath = pwd;
msg = '';

if nargin >= 1

    if exist('h','var') ~= 1
        h = gcf;
    else
        figure(h)
    end

    if exist('pn','var') ~= 1
        pn = curpath;
    end

    %get handles of data axes
    h_ax = findobj(gcf,'type','axes');

    %exclude legend axes for legacy MATLAB versions
    if mlversion < 8.4
       for n = 1:length(h_ax)
           if strcmp(get(h_ax(n),'tag'),'legend')
               h_ax(n) = NaN;  %flag legend axes for omission
           end
       end
       h_ax = h_ax(~isnan(h_ax));
    end

    axes(h_ax(1))

    ax0 = axis;

    if ax0(1) > 693962

        datevals = ax0(1:2);

        mindate = floor(min(datevals));
        minmonth = datenum(['01-',datestr(mindate,3),'-',datestr(mindate,10)]);
        maxdate = ceil(max(datevals));
        maxmonth = datenum(['01-',datestr(maxdate+32,3),'-',datestr(maxdate+32,10)]);

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

        cd(pn)

        while minmonth < maxmonth  %print interval plots

            fname = [fn,'_',lower(datestr(minmonth,12)),'.png'];

            if ~strcmp(datestr(minmonth,5),'12')
                nextmonth = datenum(['01-',datestr(minmonth+32,3),'-',datestr(minmonth,10)]);
            else  %wrap year
                nextmonth = datenum(['01-Jan-',datestr(minmonth+32,10)]);
            end

            for n = 1:length(h_ax)
                axes(h_ax(n))
                ax = axis;
                axis([minmonth nextmonth-1 ax(3:4)])
                xlbl = get(get(gca,'XLabel'),'String');
                if ~isempty(xlbl)
                    set(get(gca,'XLabel'),'String',[months{str2num(datestr(minmonth,5))},' ',datestr(minmonth,10)])
                end
                set(gca,'XTick',[minmonth:minmonth+(nextmonth-minmonth)])
                if ~isempty(get(gca,'XTickLabel'))
                    set(gca,'XTickLabel',ticklbls)
                end
            end

            clipplottext  %manage flag label visibility
            refresh(gcf)
            drawnow

            if mlversion < 8.4
               print(fname,'-zbuffer','-dpng','-r96','-noui')
            else
               print(fname,'-opengl','-dpng','-r96','-noui')
            end

            minmonth = nextmonth;

        end

        cd(curpath)

        set(h_ax,'xtickmode','auto','xticklabelmode','auto','xlim',ax0(1:2))
        dateaxis
        clipplottext  %reset flag label visibility

        drawnow

    else

        msg = 'x dimension of plot must be serial date';

    end

else

    msg = 'base filename is required';

end
