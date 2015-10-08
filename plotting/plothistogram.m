function msg = plothistogram(s,col,bins,flagopt)
%Plots a frequency histogram for the indicated column in a GCE Data Structure
%
%syntax:  plothist(s,columns,bins,flagopt)
%
%inputs:
%  s = data structure
%  columns = name or number of a column in s
%  bins = number of bins (default = 10)
%  flagopt = option to include or exclude flagged values
%    e = exclude (default)
%    i = include
%
%output:
%  msg = text of any error messages
%
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
%last modified: 15-Mar-2002

msg = '';

if nargin >= 2

   if exist('flagopt','var') ~= 1
      flagopt = 'e';
   elseif ~isstr(flagopt)
      flagopt = 'e';
   elseif ~strcmp(lower(flagopt),'i')
      flagopt = 'e';
   end

   if exist('bins','var') ~= 1
      bins = 10;
   end

   [val,stype] = gce_valid(s);

   if val == 1 & strcmp(stype,'data')

      if isstr(col)
         col = name2col(s);
      end

      col = col(1);

      if ~strcmp(s.datatype(col),'s')
         tkns = '';
         if strcmp(flagopt,'e')  %null flagged values
            s = nullflags(s);
         end
         data = s.values{col(1)};
         data = data(~isnan(data));
      else  %encode strings
         str = s.values{col};
         tkns = unique(str);
         bins = length(tkns);
         data = zeros(length(str),1);
         for m = 1:length(tkns)
            Ival = find(strcmp(str,tkns{m}));
            data(Ival) = m;
         end
      end

      res = get(0,'ScreenSize');
      figure('Position',[max(0,round((res(3)-800)/2)) max(50,round((res(4)-580)/2)) 800 550], ...
         'Color',[1 1 1], ...
         'PaperPositionMode','auto', ...
         'Name',['Histogram for ',s.name{col}], ...
         'NumberTitle','off');
      drawnow

      try
         if ~isempty(tkns)
	         hist(data,[1:bins]);
            set(gca,'XTickLabel',char(tkns))
         else
            hist(data,bins);
         end
         title(['Frequency Histogram for ',s.name{col}],'fontname','Arial','fontsize',18,'fontweight','bold','interpreter','none');
         xlabel([s.name{col},' (',s.units{col},')'],'fontname','Arial','fontsize',14,'fontweight','bold','interpreter','none');
         ylabel('Frequency','fontname','Arial','fontsize',14,'fontweight','bold','interpreter','none');
         drawnow
      catch
         close
         drawnow
         msg = 'errors occurred plotting the histogram';
      end

   else

      msg = 'not a valid GCE Data Structure';

   end

else

   msg = 'insufficient arguments for function';

end
