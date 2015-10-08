function msg = dateplot2template(fn_template,pn_template,cols,plotwidth,thumbnails,interval,fn_plots,fn_html,pn,h_fig,pagetitle,nav,fmt)
%Generates an HTML page and image files, with optional hyperlinked thumbnails, to represent
%time series data plots for a specified interval on a web page based on a specified HTML template
%
%Note: the HTML template must include the comment tag <!--gcetools_insert--> for insertion
%of the plot index table and hyperlinks, and CSS styles can be assigned for the following page
%elements to modify their appearances:
%  h1 (plot title)
%  hr.plots (separator line below title)
%  p.note (thumbnail image note)
%  table.plots (overall plot index table)
%  td.plottitle (plot label table cells)
%  td.plot (plot table cells)
%
%syntax: msg = dateplot2template(fn_template,pn_template,cols,plotwidth,thumbnails,interval,fn_plots,fn_html,pn,h_fig,pagetitle,nav,fmt)
%
%inputs:
%  fn_template = filename of the HTML template to use (required)
%  pn_template = pathname for fn_template (default = pwd)
%  cols = number of colums per page (default = 1)
%  plotwidth = width of primary image or thumbnail image and primary image in pixels
%    (default = [300,figure width])
%  thumbnails = option to use images on HTML page as thumbnails which are hyperlinked
%      to full-size 96dpi images (i.e. generates 2 images per time interval):
%    0 = no (default)
%    1 = yes
%  interval = date interval for plots (see 'dateplots')
%    'day' = 1 plot/day
%    'week' = 1 plot/week
%    'month' = 1 plot/month (default)
%    'year' = 1 plot/year
%    'decade' = 1 plot/10 years
%  fn_plots = base filename for plots (default = 'dateplot')
%  fn_html = name for html file (default = 'index.htm')
%  pn = pathname for HTML file and images (default = pwd)
%  h_fig = figure to plot (default = gcf)
%  pagetitle = string to use as the page title (default = figure title)
%  nav = breadcrumb navigation text (default = '')
%  fmt = image format (default = png) -- see 'dateplots'
%
%outputs:
%  msg = text of any error message
%
%(c)2002-2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 16-May-2013

msg = '';
curpath = pwd;

if nargin >= 1

   if exist('pn_template','var') ~= 1
      pn_template = curpath;
   elseif exist(pn_template,'dir') ~= 7
      pn_template = curpath;
   end

   if exist([pn_template,filesep,fn_template],'file') ~= 2
      fn_template = '';
   end

   if ~isempty(fn_template)

      if exist('h_fig','var') ~= 1
         h_fig = gcf;
      end

      %get figure handle, size in pixels
      figunits = get(h_fig,'Units');
      set(h_fig,'Units','pixels')
      figsize = get(h_fig,'Position');
      set(h_fig,'Units',figunits)

      if exist('cols','var') ~= 1
         cols = 1;
      end

      if exist('plotwidth','var') ~= 1
         plotwidth = [300,figsize(3)];
      elseif length(plotwidth) < 2
         plotwidth = [plotwidth,figsize(3)];
      end

      if exist('thumbnails','var') ~= 1
         thumbnails = 0;
      end

      if exist('nav','var') ~= 1
         nav = '';
      end

      if exist('fmt','var') ~= 1
         fmt = 'png';
      end

      if exist('pagetitle','var') ~= 1
         h_ax = findobj(gcf,'Type','axes');
         for n = 1:length(h_ax)
            pagetitle = get(get(h_ax(n),'title'),'string');
            if size(pagetitle,1) > 1
               pagetitle = char(concatcellcols(trimstr(cellstr(pagetitle)'),' '));
               break
            end
         end
      end
      if ~isempty(pagetitle)
         if size(pagetitle,1) > 1
            strtemp = [cellstr(pagetitle)' ; repmat({' '},1,size(pagetitle,1))];
            pagetitle = deblank([strtemp{:}]);
         end
         pagetitle = ['<h2>',pagetitle,'</h2>'];
      end

      if thumbnails == 1
         note_html = '<br><p class="note"">(click on thumbnail image to view larger plot)&nbsp;&nbsp;</p><br>';
      else
         note_html = '';
      end

      if exist('interval','var') ~= 1
         interval = 'month';
      end

      if exist('pn','var') ~= 1
         pn = curpath;
      elseif exist(pn,'dir') ~= 7
         pn = curpath;
      elseif strcmp(pn(end),filesep)
         pn = pn(1:end-1);
      end

      if exist('fn_plots','var') ~= 1
         fn_plots = 'dateplot';
      end

      if exist('fn_html','var') ~= 1
         fn_html = 'index.htm';
      end

      if fn_plots ~= 0

         thumb_res = round((plotwidth(1)./figsize(3)) .* (figsize(3)./900) .* 96);
         image_res = round((plotwidth(2)./figsize(3)) .* 96);
         if thumbnails == 0
            [msg,filenames,dateranges] = dateplots(interval,fn_plots,pn,fmt,image_res,0,h_fig);
         else
            [msg,filenames,dateranges,thumbfiles] = dateplots(interval,fn_plots,pn,fmt,[image_res,thumb_res],1,h_fig);
         end

         if ~isempty(filenames)

            numrows = ceil(length(filenames)./cols);
            numplots = length(filenames);
            cellwidths = fix(repmat(100./cols,1,cols).*10)./10;
            if sum(cellwidths) ~= 100
               cellwidths(end) = 100-sum(cellwidths(1:end-1));
            end

            figtable = [{nav}; ...
                  {pagetitle}; ...
                  {note_html}; ...
                  {'<div align="center">'}; ...
                  {'<table cellpadding="0" cellspacing="10" class="plots">'}];

            for n = 1:numrows
               figtable = [figtable ; {'  <tr>'}];
               for m = 1:cols
                  widstr = sprintf('%0.1f%%',cellwidths(m));
                  ctr = cols .* (n-1) + m;
                  if ctr <= numplots
                     figtable = [figtable ; {['    <td width="',widstr,'" class="plottitle">&nbsp;Plot for ',dateranges{ctr},'</td>']}];
                  else
                     figtable = [figtable ; {['    <td width="',widstr,'">&nbsp;</td>']}];
                  end
               end
               figtable = [figtable ; {'  </tr>'} ; {'  <tr>'}];
               for m = 1:cols
                  widstr = sprintf('%0.1f%%',cellwidths(m));
                  ctr = cols .* (n-1) + m;
                  if ctr <= numplots
                     if thumbnails ==  0
                        figtable = [figtable ; ...
                              {['    <td width="',widstr,'" class="plot">']}; ...
                              {['      <img src="',filenames{ctr},'" border="0" alt="',filenames{ctr},'">']}; ...
                              {'    </td>'}];
                     else
                        figtable = [figtable ; ...
                              {['    <td width="',widstr,'" class="plot">']}; ...
                              {['      <a href="',filenames{ctr},'"><img src="',thumbfiles{ctr},'" border="0" alt="',filenames{ctr},'"></a>']}; ...
                              {'    </td>'}];
                     end
                  else
                     figtable = [figtable ; {['    <td width="',widstr,'">&nbsp;</td>']}];
                  end
               end
               figtable = [figtable ; {'  </tr>'}];
            end
            figtable = [figtable ; ...
                  {'</table>'}; ...
                  {'</div>'}; ...
                  {'<br>'}; ...
                  {'<hr align="left" width="25%">'}; ...
                  {['<p>&nbsp;&nbsp;<em>page generated ',datestr(now),'</em></p>']}];

            fid0 = fopen([pn_template,filesep,fn_template],'r');
            fid = fopen([pn,filesep,fn_html],'w');

            flag_eof = 0;
            flag_done = 0;
            while flag_eof == 0
               ln = fgets(fid0);
               if ln ~= -1
                  ln = strrep(ln,'%','%%');
                  if flag_done == 0
                     Istr = strfind(ln,'<!--gcetools_insert-->');
                     if ~isempty(Istr)
                        if Istr(1) > 1
                           fprintf(fid,'%s',ln(1:Istr(1)-1));
                        end
                        fprintf(fid,'\r');
                        fprintf(fid,'%s\r',figtable{:});
                        fprintf(fid,'%s',ln(min([length(ln),Istr(1)+22]):end));
                        flag_done = 1;
                     else
                        fprintf(fid,'%s',ln);
                     end
                  else
                     fprintf(fid,'%s',ln);
                  end
               else
                  flag_eof = 1;
               end
            end

            fclose(fid);
            fclose(fid0);

         end

      end

   else
      msg = 'invalid HTML template file (file not found)';
   end

else
   msg = 'insufficient arguments - ''fn_template'' is required';
end