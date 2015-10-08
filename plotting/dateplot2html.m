function msg = dateplot2html(cols,plotwidth,thumbnails,interval,fn_plots,fn_html,pn,pagetitle,nav_html,h_fig,fmt)
%Generates an HTML page and image files, with optional hyperlinked thumbnails, to represent
%time series data plots for a specified interval on a web page
%
%syntax: msg = dateplot2html(cols,plotwidth,thumbnails,interval,fn_plots,fn_html,pn,pagetitle,nav_html,h_fig,fmt)
%
%inputs:
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
%  pagetitle = title string for HTML page and header (default = plot title)
%  nav_html = HTML to include at the top right of the page for navigation (default = '')
%  h_fig = figure to plot (default = gcf)
%  fmt = image format (default = png) -- see 'dateplots'
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
%last modified: 18-Jun-2005

msg = '';
curpath = pwd;

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

if exist('pagetitle','var') ~= 1
   pagetitle = '';
end

if exist('fmt','var') ~= 1
   fmt = 'png';
end

if isempty(pagetitle)
   h_ax = findobj(gcf,'Type','axes');
   for n = 1:length(h_ax)
      pagetitle = get(get(h_ax(n),'title'),'string');
      if size(pagetitle,1) > 1
         pagetitle = char(concatcellcols(trimstr(cellstr(pagetitle)'),' '));
         break
      end
   end
end

if exist('nav_html','var') ~= 1
   nav_html = '';
else
   if size(nav_html,1) > 1  %concatentate multi-line character arrays to avoid matrix errors
      nav_html = concatcellcols(cellstr(nav_html)',' ');
      nav_html = nav_html{:};
   end
   nav_html = ['<p class="nav">',nav_html,'</p>'];
end

if thumbnails == 1
   note_html = '<p class="note">(click on thumbnail image to view larger plot)&nbsp;&nbsp;</p>';
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

      figtable = {'<table border="0" cellpadding="0" cellspacing="10" width="100%">'};
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
      figtable = [figtable ; {'</table>'}];

      html = [{'<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">'}; ...
            {'<html>'}; ...
            {'<head>'}; ...
            {['  <title>',pagetitle,'</title>']}; ...
            {'  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">'}; ...
            {'  <style type="text/css">'}; ...
            {'  <!--'}; ...
            {'  h1  { font-family: ''Times New Roman'', Times, serif; font-size: 18pt; text-align: center; margin-left: 0.5in; margin-right: 0.5in; margin-bottom: 2px;}'}; ...
            {'  p.nav  { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 10pt; font-weight: bold; text-align: left; }'}; ...
            {'  p.note  { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 8pt; font-weight: bold; font-style: italic; color: green; text-align: right; margin-top: 1px; margin-bottom: 4px; }'}; ...
            {'  td.plottitle  { font-family: ''Times New Roman'', Times, serif; font-size: 14pt; text-align: left; background-color: #EFEFEF; }'}; ...
            {'  td.plot  { text-align: center; }'}; ...
            {'  -->'}; ...
            {'  </style>'}; ...
            {'</head>'}; ...
            {''}; ...
            {'<body bgcolor="#FFFFFF" text="#000000" link="#0000FF" vlink="#800080" alink="#FF0000">'}; ...
            {nav_html}; ...
            {['<h1>',pagetitle,'</h1>']}; ...
            {'<hr width="100%">'}; ...
            {note_html}; ...
            {'<br>'}; ...
            {''}; ...
            figtable ; ...
            {''}; ...
            {'<br>'}; ...
            {['<p><hr>&nbsp;&nbsp;<em>page generated ',datestr(now),'</em></p>']}; ...
            {''}; ...
            {'</body>'}; ...
            {'</html>'}];

      cd(pn)
      fid = fopen(fn_html,'w');
      fprintf(fid,'%s\r',html{:});
      fclose(fid);
      cd(curpath)

   end

end