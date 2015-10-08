function [msg,filenames,dateranges,thumbs] = dateplots(interval,fn,pn,fmt,res,thumbnails,h)
%Generates individual date plots at the specified interval from a standard date plot and saves
%each plot as a bitmap or vector image file
%
%syntax: [msg,filenames,dateranges,thumbs] = dateplots(interval,fn,pn,format,resolution,thumbnailss,h)
%
%inputs:
%  invertal = date interval per plot:
%    'native' = native interval (export plot and thumbnail without scaling)
%    'day' = hourly plots for 1 day
%    'week' = daily plots for 1 week
%    'month' = daily plots for 1 month
%    'year' = monthly plots for 1 year
%    'decade' = yearly plots for 1 decade
%  fn = base filename for plots (_yyyy.png will be appended)
%  pn = pathname for saved plots (default = pwd)
%  format = file format:
%    'png' = Portable Network Graphics bitmap (default)
%    'jpeg<nn>' = JPEG bitmap with quality level <nn>, e.g. 'jpeg90'
%    'tiff' = Tagged Image File Format bitmap
%    'epsc2' = Encapsulated PostScript level 2 color (vector)
%     ... (see help for MATLAB print command)
%  resolution = 1 or 2 element array specifying bitmap resolution for the primary and thumbnail
%    image in dpi, resp. (default = [96 32])
%  thumbnails = option to use specified recolution to generate thumbnails in PNG format and also
%    generate a second image at full resolution in the specified format (for use on web pages)
%    0 = no (default)
%    1 = yes
%  h = handle of date plot figure (x axis must be serial date numbers; default = gcf)
%
%outputs:
%  msg = text of any error message
%  filenames = array of filenames generated
%  dateranges = array of date ranges corresponding to filenames
%  thumbs = array of thumbnail filenames generated
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
%last modified: 13-Apr-2015

curpath = pwd;
msg = '';
filenames = [];
dateranges = [];
thumbs = [];

if nargin >= 2
   
   if exist('h','var') ~= 1
      h = gcf;
   else
      figure(h)
   end
   
   if exist('fmt','var') ~= 1
      fmt = 'png';
      ext = '.png';
      if mlversion < 8.4
         renderer = '-zbuffer';
      else
         renderer = '-opengl';
      end
   elseif strncmp(fmt,'jpeg',4)
      ext = '.jpg';
      if mlversion < 8.4
         renderer = '-zbuffer';
      else
         renderer = '-opengl';
      end
   elseif strncmp(fmt,'tiff',4)
      ext = '.tif';
      if mlversion < 8.4
         renderer = '-zbuffer';
      else
         renderer = '-opengl';
      end
   elseif strncmp(fmt,'eps',3)
      ext = '.eps';
      renderer = '-painters';
   elseif strncmp(fmt,'ps',2)
      ext = '.ps';
      renderer = '-painters';
   elseif strncmp(fmt,'ill',3)
      ext = 'ai';
      renderer = '-painters';
   else
      ext = ['.',fmt];
      renderer = '-painters';
   end
   
   %define renderer for PNG thumbnails
   if mlversion < 8.4
      thumb_renderer = '-zbuffer';
   else
      thumb_renderer = '-opengl';
   end

   if exist('res','var') ~= 1
      res = [96 32];
   elseif length(res) < 2
      res = [res 32];
   end
   
   if exist('thumbnails','var') ~= 1
      thumbnails = 0;
   end
   
   if exist('pn','var') ~= 1
      pn = curpath;
   elseif exist(pn,'dir') ~= 7
      pn = '';
   elseif strcmp(pn(end),filesep)
      pn = pn(1:end-1);
   end
   
   if ~isempty(pn)
      
      %get handles of data axes
      h_ax = findobj(h,'type','axes');
      
      %exclude legend for legacy MATLAB versions
      if mlversion < 8.4
         for n = 1:length(h_ax)
            if strcmp(get(h_ax(n),'tag'),'legend')
               h_ax(n) = NaN;  %flag legend axes for omission
            end
         end
         h_ax = h_ax(~isnan(h_ax));
      end
      
      if ~isempty(h_ax)
         
         %cache initial x-axis info
         numax = length(h_ax);
         xlbls = repmat({''},1,numax);
         xlims = cell(1,numax);
         xticks = xlims;
         xtickmodes = xlims;
         for n = 1:numax
            xlims{n} = get(h_ax(n),'XLim');
            xticks{n} = get(h_ax(n),'XTick');
            xtickmodes{n} = get(h_ax(n),'XTickMode');
            xlbl = get(get(h_ax(n),'XLabel'),'String');
            if ~isempty(xlbl)
               xlbls{n} = xlbl;
            end
         end
         
         axes(h_ax(1))
         ax0 = axis;
         
         if ax0(1) > 657438 && ax0(2) <= 767375  %check for reasonable date range (1800-2100)
            
            datevals = ax0(1:2);
            mindate = floor(min(datevals));
            maxdate = ceil(max(datevals));
            
            switch interval
               
               case 'decade'
                  
                  vec = datevec(mindate);
                  minyear = floor(vec(1)/10)*10;
                  
                  vec = datevec(maxdate);
                  maxyear = ceil(vec(1)/10)*10;
                  
                  while minyear < maxyear  %print interval plots
                     
                     fname = [fn,'_',int2str(minyear),'-',int2str(minyear+10),ext];
                     filenames = [filenames ; {fname}];
                     dateranges = [dateranges ; {[int2str(minyear),'-',int2str(minyear+10)]}];
                     if thumbnails == 1
                        thumbname = strrep(fname,ext,['_small',ext]);
                        thumbs = [thumbs ; {thumbname}];
                     end
                     
                     xtick = [];
                     xticklbl = [];
                     for n = 1:11
                        xtick = [xtick datenum(minyear+(n-1),1,1)];
                        xticklbl = [xticklbl ; {int2str(minyear+(n-1))}];
                     end
                     
                     for n = 1:numax
                        axes(h_ax(n))
                        ax = axis;
                        axis([xtick(1) xtick(11) ax(3:4)])
                        set(gca,'XTick',xtick)
                        xlbl = get(get(h_ax(n),'XLabel'),'String');
                        if ~isempty(xlbl)
                           set(get(h_ax(n),'XLabel'),'String','Date')
                        end
                        if ~isempty(get(gca,'XTickLabel'))
                           set(gca,'XTickLabel',char(xticklbl))
                        end
                     end
                     
                     clipplottext  %manage flag label visibility
                     refresh(gcf)
                     drawnow
                     
                     try
                        if thumbnails == 1
                           if mlversion < 8.4
                              print([pn,filesep,thumbname],thumb_renderer,'-dpng',['-r',int2str(res(2))],'-noui')
                           else
                              print([pn,filesep,thumbname],thumb_renderer,'-dpng',['-r',int2str(res(2))],'-noui')
                           end
                        end
                        print([pn,filesep,fname],renderer,['-d',fmt],['-r',int2str(res(1))],'-noui')
                     catch
                        msg = 'invalid print options';
                        break
                     end
                     
                     minyear = minyear + 10;
                     
                  end
                  
               case 'year'
                  
                  vec = datevec(mindate);
                  minyear = vec(1);
                  
                  vec = datevec(maxdate);
                  maxyear = vec(1);
                  
                  while minyear <= maxyear  %print interval plots
                     
                     fname = [fn,'_',int2str(minyear),ext];
                     filenames = [filenames ; {fname}];
                     dateranges = [dateranges ; {int2str(minyear)}];
                     if thumbnails == 1
                        thumbname = strrep(fname,ext,['_small',ext]);
                        thumbs = [thumbs ; {thumbname}];
                     end
                     
                     xtick = [];
                     xticklbl = [];
                     for n = 1:13
                        xtick = [xtick datenum(minyear,n,1)];
                        xticklbl = [xticklbl ; {datestr(datenum(minyear,n,1),12)}];
                     end
                     
                     for n = 1:length(h_ax)
                        axes(h_ax(n))
                        ax = axis;
                        axis([xtick(1) xtick(13) ax(3:4)])
                        xlbl = get(get(gca,'XLabel'),'String');
                        if ~isempty(xlbl)
                           set(get(gca,'XLabel'),'String','Date')
                        end
                        set(gca,'XTick',xtick)
                        if ~isempty(get(gca,'XTickLabel'))
                           set(gca,'XTickLabel',char(xticklbl))
                        end
                     end
                     
                     clipplottext  %manage flag label visibility
                     refresh(gcf)
                     drawnow
                     
                     try
                        if thumbnails == 1
                           if mlversion < 8.4
                              print([pn,filesep,thumbname],thumb_renderer,'-dpng',['-r',int2str(res(2))],'-noui')
                           else
                              print([pn,filesep,thumbname],thumb_renderer,'-dpng',['-r',int2str(res(2))],'-noui')
                           end
                        end
                        print([pn,filesep,fname],renderer,['-d',fmt],['-r',int2str(res(1))],'-noui')
                     catch
                        msg = 'invalid print options';
                        break
                     end
                     
                     minyear = minyear + 1;
                     
                  end
                  
               case 'week'
                  
                  weekdays = {'Sun','Mon','Tue','Wed','Thu','Fri','Sat'};
                  
                  wd = find(strcmp(weekdays,datestr(mindate,8)));
                  mindate = floor(mindate) - (wd - 1);  %round down to previous sunday
                  
                  while mindate < maxdate  %print interval plots
                     
                     rng = [datestr(mindate,26),'-',datestr(mindate+6,26)];
                     rngstr = [datestr(mindate,1),' to ',datestr(mindate+6,1)];
                     fname = [fn,'_',strrep(rng,'/',''),ext];
                     filenames = [filenames ; {fname}];
                     dateranges = [dateranges ; {rngstr}];
                     if thumbnails == 1
                        thumbname = strrep(fname,ext,['_small',ext]);
                        thumbs = [thumbs ; {thumbname}];
                     end
                     
                     xtick = [];
                     xticklbl = [];
                     weekdays = [weekdays,{'Sun'}];
                     for n = 1:8
                        xtick = [xtick mindate+(n-1)];
                        xticklbl = [xticklbl ; {weekdays{n}}];
                     end
                     
                     for n = 1:length(h_ax)
                        axes(h_ax(n))
                        ax = axis;
                        axis([xtick(1) xtick(end) ax(3:4)])
                        xlbl = get(get(gca,'XLabel'),'String');
                        if ~isempty(xlbl)
                           set(get(gca,'XLabel'),'String',['Day (',rngstr,')'])
                        end
                        set(gca,'XTick',xtick)
                        if ~isempty(get(gca,'XTickLabel'))
                           set(gca,'XTickLabel',char(xticklbl))
                        end
                     end
                     
                     clipplottext  %manage flag label visibility
                     refresh(gcf)
                     drawnow
                     
                     try
                        if thumbnails == 1
                           if mlversion < 8.4
                              print([pn,filesep,thumbname],thumb_renderer,'-dpng',['-r',int2str(res(2))],'-noui')
                           else
                              print([pn,filesep,thumbname],thumb_renderer,'-dpng',['-r',int2str(res(2))],'-noui')
                           end
                        end
                        print([pn,filesep,fname],renderer,['-d',fmt],['-r',int2str(res(1))],'-noui')
                     catch
                        msg = 'invalid print options';
                        break
                     end
                     
                     mindate = mindate + 7;
                     
                  end
                  
               case 'day'
                  
                  while mindate < maxdate  %print interval plots
                     
                     fname = [fn,'_',datestr(mindate,1),ext];
                     filenames = [filenames ; {fname}];
                     dateranges = [dateranges ; {datestr(mindate,1)}];
                     if thumbnails == 1
                        thumbname = strrep(fname,ext,['_small',ext]);
                        thumbs = [thumbs ; {thumbname}];
                     end
                     
                     xtick = (mindate:2/24:mindate+1);
                     xticklbl = datestr(xtick,15);
                     
                     for n = 1:length(h_ax)
                        axes(h_ax(n))
                        ax = axis;
                        axis([xtick(1) xtick(end) ax(3:4)])
                        xlbl = get(get(gca,'XLabel'),'String');
                        if ~isempty(xlbl)
                           set(get(gca,'XLabel'),'String',['Time (',datestr(mindate,1),')'])
                        end
                        set(gca,'XTick',xtick)
                        if ~isempty(get(gca,'XTickLabel'))
                           set(gca,'XTickLabel',char(xticklbl))
                        end
                     end
                     
                     clipplottext  %manage flag label visibility
                     refresh(gcf)
                     drawnow
                     
                     try
                        if thumbnails == 1
                           if mlversion < 8.4
                              print([pn,filesep,thumbname],thumb_renderer,'-dpng',['-r',int2str(res(2))],'-noui')
                           else
                              print([pn,filesep,thumbname],thumb_renderer,'-dpng',['-r',int2str(res(2))],'-noui')
                           end
                        end
                        print([pn,filesep,fname],renderer,['-d',fmt],['-r',int2str(res(1))],'-noui')
                     catch
                        msg = 'invalid print options';
                        break
                     end
                     
                     mindate = mindate + 1;
                     
                  end
                  
               case 'month'
                  
                  %build array of months
                  vec = datevec(mindate);
                  minmonth = datenum(vec(1),vec(2),1);
                  
                  vec = datevec(maxdate);
                  maxmonth = datenum(vec(1),vec(2)+1,1) - 1;
                  
                  months = {'January', ...
                        'February', ...
                        'March', ...
                        'April', ...
                        'May', ...
                        'June', ...
                        'July', ...
                        'August', ...
                        'September', ...
                        'October', ...
                        'November', ...
                        'December'};
                  
                  %generate ticks
                  ticklbls = repmat({''},31,1);
                  ticklbls{1} = '1';
                  ticklbls{7} = '7';
                  ticklbls{14} = '14';
                  ticklbls{21} = '21';
                  ticklbls{28} = '28';
                  ticklbls = char(ticklbls);
                  
                  %print interval plots
                  while minmonth < maxmonth
                     
                     %generate filenames
                     fname = [fn,'_',lower(datestr(minmonth,12)),ext];
                     filenames = [filenames ; {fname}];
                     dateranges = [dateranges ; {[months{str2double(datestr(minmonth,5))},' ',datestr(minmonth,10)]}];
                     if thumbnails == 1
                        thumbname = strrep(fname,ext,['_small',ext]);
                        thumbs = [thumbs ; {thumbname}];
                     end
                     
                     vec = datevec(minmonth);
                     nextmonth = datenum(vec(1),vec(2)+1,1);
                     
                     %scale plot
                     for n = 1:length(h_ax)
                        axes(h_ax(n))
                        ax = axis;
                        axis([minmonth nextmonth-1 ax(3:4)])
                        xlbl = get(get(gca,'XLabel'),'String');
                        if ~isempty(xlbl)
                           set(get(gca,'XLabel'),'String',['Day (',months{str2double(datestr(minmonth,5))},' ',datestr(minmonth,10),')'])
                        end
                        set(gca,'XTick',(minmonth:minmonth+(nextmonth-minmonth)))
                        if ~isempty(get(gca,'XTickLabel'))
                           set(gca,'XTickLabel',ticklbls)
                        end
                     end
                     
                     clipplottext  %manage flag label visibility
                     refresh(gcf)
                     drawnow
                     
                     %generate files
                     try
                        if thumbnails == 1
                           if mlversion < 8.4
                              print([pn,filesep,thumbname],thumb_renderer,'-dpng',['-r',int2str(res(2))],'-noui')
                           else
                              print([pn,filesep,thumbname],thumb_renderer,'-dpng',['-r',int2str(res(2))],'-noui')
                           end
                        end
                        print([pn,filesep,fname],renderer,['-d',fmt],['-r',int2str(res(1))],'-noui')
                     catch
                        msg = 'invalid print options';
                        break
                     end
                     
                     minmonth = nextmonth;
                     
                  end
                  
               otherwise  %native resolution
                  
                  %get date range from x-axis limits
                  xlim = get(gca,'xlim');
                  mindate = xlim(1);
                  maxdate = xlim(2);
                  
                  %generate filenames and date range string
                  rng = [datestr(mindate,26),'-',datestr(maxdate,26)];
                  rngstr = [datestr(mindate,1),' to ',datestr(maxdate,1)];
                  fname = [fn,'_',strrep(rng,'/',''),ext];
                  filenames = {fname};
                  dateranges = {rngstr};
                  if thumbnails == 1
                     thumbname = strrep(fname,ext,['_small',ext]);
                     thumbs = {thumbname};
                  end
                     
                  %generate plot files
                  try
                     if thumbnails == 1
                        if mlversion < 8.4
                           print([pn,filesep,thumbname],thumb_renderer,'-dpng',['-r',int2str(res(2))],'-noui')
                        else
                           print([pn,filesep,thumbname],thumb_renderer,'-dpng',['-r',int2str(res(2))],'-noui')
                        end
                     end
                     print([pn,filesep,fname],renderer,['-d',fmt],['-r',int2str(res(1))],'-noui')
                  catch
                     msg = 'invalid print options';
                  end
                  
            end
            
            %reset axis labels, limits
            if ~strcmp(interval,'native')
               for n = 1:numax
                  set(get(h_ax(n),'XLabel'),'String',xlbls{n})
                  set(h_ax(n),'XLim',xlims{n},'XTick',xticks{n},'XTickMode',xtickmodes{n})
               end
               dateaxis
               clipplottext
               drawnow
            end
                        
         else
            msg = 'x dimension of plot must be a serial date in the range 1/1/1800 to 12/31/2100';
         end
         
      else
         msg = 'no valid data plots on specified figure';
      end
      
   else
      msg = 'output path is invalid';
   end
   
else
   msg = 'insufficient arguments for function';
end