function msg = merge_dateplots(prefix_array,caption_array,fn_html,pn,fn_template,pn_template,pagetitle,plot_ext)
%Generates an HTML table of date plot thumbnails based on multiple sets of existing plots in a specified directory
%
%syntax: msg = merge_dateplots(prefix_array,caption_array,fn_html,pn,fn_template,pn_template,pagetitle,plot_ext)
%
%input:
%  prefix_array = cell array of plot prefix strings to include (matching date ranges for each plot type
%    will be combined on the same table row for comparisons - 1 table row will be generated per matched prefix)
%  caption_array = array of captions to display for each entry in 'prefix_array'
%  fn_html = name of HTML file to generate
%  pn = pathname for plot files to analyze and final HTML file
%  fn_template = filename of HTML template to use (must include <!-gcetools_insert-> comment tag)
%  pn_template = pathname for template (default = pn)
%  pagetitle = string to use as the page title (default = '')
%  plot_ext = file extension used for thumbnail plots (default = 'png')
%
%output:
%  msg = status message
%
%
%(c)2002-2011 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 07-Sep-2011

if nargin >= 5

   if isdir(pn)

      pn = clean_path(pn);  %remove terminal file separator from path
      
      if exist('pn_template','var') ~= 1
         pn_template = pn;
      elseif ~isdir(pn_template)
         pn_template = pn;
      end
      
      if exist([pn_template,filesep,fn_template],'file') == 2
         
         %validate, format prefix_array
         if ischar(prefix_array)
            prefix_array = cellstr(prefix_array);
         end
         
         %validate, format plotcaptions
         if isempty(caption_array)
            caption_array = repmat({''},1,length(prefix_array));
         elseif ischar(caption_array)
            caption_array = cellstr(caption_array);
         end
         
         %pad caption_array if too few
         if length(caption_array) < length(prefix_array)
            caption_array = [caption_array,repmat({''},1,length(prefix_array)-length(caption_array))];
         end
         
         %validate plot title string, add markup
         if exist('pagetitle','var') ~= 1
            pagetitle = '';
         else
            pagetitle = ['<h2 class="plots">',pagetitle,'</h2>'];
         end
         
         %supply default plot extension if omitted
         if exist('plot_ext','var') ~= 1
            plot_ext = 'png';
         end
         
         %get directory listing for thumbnail plots matching spec
         d = dir([pn,filesep,'*_small.',plot_ext]);
         
         if ~isempty(d)
            
            allfiles = {d.name}';
            meta = struct('prefix','','filename','','start',[],'end',[],'interval','');
            rownum = 0;
            
            %iterate through files, parsing dates and filling in metadata
            for n = 1:length(prefix_array)
               interval = '';
               dnum1 = [];
               dnum2 = [];
               prefix = prefix_array{n};
               Irows = strncmp(prefix,allfiles,length(prefix));
               if ~isempty(Irows)
                  files = allfiles(Irows);
                  date_str = strrep(strrep(strrep(files,prefix,''),['_small.',plot_ext],''),'_','');
                  for m = 1:length(files)
                     d = date_str{m};
                     if length(d) == 4  %year format
                        dnum1 = datenum(['01/01/',d]);
                        dnum2 = dnum1;
                        interval = 'year';
                     elseif length(d) == 5  %month/year format
                        dnum1 = datenum(['01-',d(1:3),'-',d(4:5)]);
                        dnum2 = dnum1;
                        interval = 'month';
                     elseif length(d) == 11  %day format
                        dnum1 = datenum(d);
                        dnum2 = dnum1;
                        interval = 'day';
                     elseif ~isempty(strfind(d,'-'))  %date range format
                        [d1,rem] = strtok(d,'-');
                        d2 = strtok(rem,'-');
                        if length(d1) == 8  %weekly format
                           dnum1 = datenum([d1(5:6),'/',d1(7:8),'/',d1(1:4)]);
                           dnum2 = datenum([d2(5:6),'/',d2(7:8),'/',d2(1:4)]);
                           interval = 'week';
                        elseif length(d) == 4  %decade format
                           dnum1 = datenum(['01/01/',d1]);
                           dnum2 = datenum(['01/01/',d2]);
                           interval = 'decade';
                        end
                     end
                     rownum = rownum + 1;
                     meta(rownum).prefix = prefix;
                     meta(rownum).filename = files{m};
                     meta(rownum).start = dnum1;
                     meta(rownum).end = dnum2;
                     meta(rownum).interval = interval;
                  end
               end
            end
            
            if ~isempty(meta)
               
               %check for consistent interval
               interval = unique({meta.interval});
               
               if length(interval) == 1 && ~cellfun('isempty',interval)
                  
                  interval = char(interval);
                  
                  %get sorted list of unique start dates
                  startdates = unique([meta.start]);
                  
                  %get list of prefixes in order specified, omitting any not matched
                  matched_prefixes = unique({meta.prefix});
                  prefixes = [];
                  plotcaptions = [];
                  for n = 1:length(prefix_array)
                     if ~isempty(strcmp(matched_prefixes,prefix_array{n}))
                        prefixes = [prefixes ; prefix_array(n)];
                        plotcaptions = [plotcaptions ; caption_array(n)];
                     end
                  end
                  
                  %calculate table size
                  numrows = length(startdates);
                  cols = length(prefixes);

                  %calculate table cell widths
                  cellwidths = fix(repmat(100./cols,1,cols).*10)./10;
                  if sum(cellwidths) ~= 100
                     cellwidths(end) = 100-sum(cellwidths(1:end-1));
                  end
                  
                  %init html
                  figtable = [{pagetitle}; ...
                        {'<p class="note">(click on thumbnail image to view larger plot)&nbsp;&nbsp;</p><br>'}; ...                        
                        {'<div align="center">'}; ...
                        {'<table cellpadding="0" cellspacing="10" class="plots">'}];
                  
                  
                  %generate table
                  for n = 1:numrows
                     
                     Irows = find([meta.start]==startdates(n));
                     
                     switch interval
                        case 'decade'
                           caption = ['Plots for ',datestr(startdates(n),10),' to ',datestr(meta(Irows(1)).end,10)];
                        case 'year'
                           caption = ['Plots for ',datestr(startdates(n),10)];                           
                        case 'month'
                           caption = ['Plots for ',date2monthyear(startdates(n))];
                        case 'week'
                           caption = ['Plots for ',datestr(startdates(n),1),' to ',datestr(meta(Irows(1)).end,1)];
                        otherwise %day
                           caption = ['Plots for ',datestr(startdates(n),1)];
                     end
                     
                     %open row
                     figtable = [figtable ; {'  <tr>'}]; 
                     
                     %generate row header
                     figtable = [figtable ; ...
                           {['    <td colspan="',int2str(cols),'" width="100%" class="plottitle">&nbsp;',caption,'</td>']}; ...
                           {'  </tr>'} ; ...
                           {'  <tr>'}];
                     
                     %generate plot cells
                     for m = 1:cols
                        Irow = strcmp(prefixes{m},{meta(Irows).prefix});
                        if ~isempty(Irow)
                           fn = meta(Irows(Irow)).filename;
                           widstr = sprintf('%0.1f%%',cellwidths(m));
                           figtable = [figtable ; ...
                                 {['    <td width="',widstr,'" class="plot">']}; ...
                                 {['      <p class="plot-caption">',plotcaptions{m},'</p>']}; ...
                                 {['      <a href="',strrep(fn,'_small',''),'"><img src="',fn,'" border="0" alt="',fn,'"></a>']}; ...
                                 {'    </td>'}];
                        else  %no matching plot for interval
                           figtable = [figtable ; {['    <td width="',widstr,'">&nbsp;</td>']}];
                        end
                     end

                     %close last row
                     figtable = [figtable ; {'  </tr>'}];
                     
                  end
                  
                  %close table
                  figtable = [figtable ; ...
                        {'</table>'}; ...
                        {'</div>'}; ...
                        {'<br>'}; ...
                        {'<hr align="left" width="25%" class="plots">'}; ...
                        {['<p>&nbsp;&nbsp;<em>page generated ',datestr(now),'</em></p>']}];
                  
                  %open file handles
                  fid0 = fopen([pn_template,filesep,fn_template],'r');
                  fid = fopen([pn,filesep,fn_html],'w');
                  
                  %read template file, checking for insert tag, write to output file
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
                                 fprintf(fid,ln(1:Istr(1)-1));
                              end
                              fprintf(fid,'\r');
                              fprintf(fid,'%s\r',figtable{:});
                              fprintf(fid,ln(min([length(ln),Istr(1)+22]):end));
                              flag_done = 1;
                           else
                              fprintf(fid,ln);
                           end
                        else
                           fprintf(fid,ln);
                        end
                     else
                        flag_eof = 1;
                     end
                  end
                  
                  fclose(fid);
                  fclose(fid0);
                  
                  msg = ['successfully generated web page as ''',pn,filesep,fn_html,''''];
                  
               else
                  msg = 'multiple plot intervals are not supported by this function - operation cancelled';
               end               
               
            else
               msg = 'plot filenames could not be parsed - operation cancelled';
            end
            
         else
            msg = ['no thumbnail plots with the extension ''',plot_ext,''' were found in the specified directory'];
         end
         
      else
         msg = 'invalid HTML template file (not found)';
      end
      
   else
      msg = 'invalid plot pathname specified';
   end
   
else
   msg = 'insufficient arguments for function';
end