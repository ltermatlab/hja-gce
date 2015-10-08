function [s,msg] = fetch_climdb_data(site,station,parms,username,userorg,userpurpose,date_min,date_max,template,silent,savetemp,pn,base_url)
%Fetches data for a specified site and station from the ClimDB/HydroDB web site (requires networking features in MATLAB 6.5/R13 or higher)
%
%syntax: [s,msg] = fetch_climdb_data(site,station,parms,username,userorg,userpurpose,date_min,date_max,template,silent,savetemp,pn,base_url)
%
%input:
%  site = site code (e.g. 'GCE')
%  station = station code (e.g. 'DOCTORTOWN')
%  parms = cell array containing list of parameters to fetch ([] = all)
%  username = user name (for logging access)
%  userorg = user organization (for logging access)
%  userpurpose = user's purpose in downloading (for logging access)
%  date_min = minimum date (YYYY-MM-DD, default = '2000-01-01')
%  date_max = maximum date (YYYY-MM-DD, default = today)
%  template = metadata template to apply after importing data (default = 'LTER_ClimDB')
%  silent = option to suppress status messages (0 = no, 1 = yes/default)
%  savetemp = option to retain raw and parsed ClimDB data files after importing
%     (0 = no/default, 1 = yes/files saved to toolbox directory as 'climdb_[YYYYMMDDTHHMMSS]_raw.txt'
%     and 'climdb_[YYYYMMDDTHHMMSS]_parsed.txt')
%  pn = path for temporary files (default = [toolbox directory]/search_webcache)
%  base_url = base url of the Climdb web application (default = 'http://climhy.lternet.edu/')
%
%output:
%  s = data structure
%  msg = text of any error message
%
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
%last modified: 27-Jun-2013

%init output
s = [];
msg = '';

%check for required arguments
if nargin >= 5

   %check for MATLAB http functions
   if exist('urlread','file') == 2

      %force upper case station name for HTML parsing
      station = upper(station);

      %set defaults for omitted arguments
      if exist('parms','var') ~= 1
         parms = [];
      elseif ischar(parms)
         parms = cellstr(lower(parms));  %convert single parm to cell array
      else
         parms = lower(parms);
      end

      if exist('date_min','var') ~= 1 || isempty(date_min)
         date_min = '2000-01-01';
      end

      if exist('date_max','var') ~= 1 || isempty(date_max)
         date_max = datestr(now,29);  %use today's date for date_max if omitted
      end

      if exist('template','var') ~= 1
         template = 'LTER_ClimDB';  %use generic template
      end

      %validate temp directory, set to blank for default if missing, invalid
      if exist('pn','var') ~= 1
         pn = '';
      elseif ~isdir(pn)
         pn = '';
      elseif strcmp(pn(end),filesep)
         pn = pn(1:end-1);  %strip terminal file separator from path
      end

      if exist('silent','var') ~= 1
         silent = 1;  %default to interactive status display
      end

      if exist('savetemp','var') ~= 1
         savetemp = 0;  %default to delete temp files on successful fetch
      end

      %test for GUI mode, set flag for progress bar status instead of console status
      guimode = 0;
      stepnum = 0;
      if silent == 0 && length(findobj) > 1
         if strcmp(get(gcf,'Tag'),'dlgFetchClimDB')  %check for ui_fetch_climdb dialog instance
            guimode = 1;  %set mode flag
            ui_progressbar('init',7,'Retrieving data from ClimDB')  %init progress bar GUI
         end
      end

      %validate or set default base url for climdb web app
      if exist('base_url','var') ~= 1
         base_url = '';
      end
      if isempty(base_url)
         base_url = 'http://climhy.lternet.edu/';
      elseif ~strcmp(base_url(end),'/')
         base_url = [base_url,'/'];  %append terminal slash if omitted
      end
      url = [base_url,'plot.pl'];  %add script to url

      %format initial http post data array
      postdata = {'submit','submit', ...
            'page','1', ...
            'site',site, ...
            'name',username, ...
            'org',userorg, ...
            'purpose',userpurpose, ...
            'style','./images/expe1011.css'};

      if silent == 0
         if guimode == 1
            stepnum = stepnum + 1;
            ui_progressbar('update',stepnum,'Requesting parameter list...')
         else
            disp([datestr(now),': info request posted to ClimDB']); drawnow
         end
      end

      %send initial post, retrieve as html string
      [html,status] = urlread(url,'POST',postdata);

      if status == 1

         if silent == 0
            if guimode == 1
               stepnum = stepnum + 1;
               ui_progressbar('update',stepnum,'Generating data request...')
            else
               disp([datestr(now),': retrieved parameter list from ClimDB']); drawnow
            end
         end

         %get indices of all select lists
         pos_sel = regexp(html,'<SELECT');  %get start of all select lists
         pos_endsel = regexp(html,'</SELECT>');  %get ending positions of all select lists

         if ~isempty(pos_sel)

            %parse select list text and names
            lists = cell(length(pos_sel),2);
            for n = 1:length(pos_sel)
               str = html(pos_sel(n):pos_endsel(n)+8);  %extract select list html
               lists{n,1} = str;
               Iname_start = strfind(str,'NAME=');  %grab name attribute
               if ~isempty(Iname_start)
                  str = str(Iname_start+6:end);
                  Iname_end = strfind(str,'''');
                  if ~isempty(Iname_end)
                     lists{n,2} = str(1:Iname_end(1)-1);  %extract list name
                  end
               end
            end

            %parse relevant variable list for station from page 2 html
            station_label = '';
            tkn_station = ['OPTION VALUE=',site,station];
            for n = 1:length(lists)
               Istation = strfind(lists{n,1},tkn_station);
               if ~isempty(Istation)
                  station_label = lists{n,2};
                  break
               end
            end

            %check for parsed station_label to confirm expected output obtained
            if ~isempty(station_label)

               %generate corresponding variable label using string substitution, look up select list
               var_label = strrep(station_label,'station','variable');
               Ilist = find(strcmp(lists(:,2),var_label));

               if length(Ilist) == 1

                  %parse variables, format as comma-delimited list
                  ar_vars = splitstr(lists{Ilist,1},char(10));
                  ar_vars = strrep(ar_vars(2:end-1),'<OPTION VALUE=','');  %strip option leader
                  totalvars = length(ar_vars);
                  vars = cell(totalvars,2);
                  varcnt = 0;
                  for n = 1:totalvars
                     [str,rem] = strtok(ar_vars{n},'>');  %grab option value
                     keepvar = 1;  %init keep flag for parameter match
                     if ~isempty(parms)  %check to see if var in specified parm list
                        [tmp,rem] = strtok(rem,'-');  %get variable abbreviation leader & discard
                        varname = trimstr(strtok(rem(min(3,length(rem)):end),'<'));  %clean up parm name
                        if isempty(find(strcmpi(parms,varname)))
                           keepvar = 0;  %parm not matched - clear keep flag
                        end
                     end
                     if keepvar == 1
                        vars{n,1} = [str,int2str(varcnt)];  %add fields to parm array
                        vars{n,2} = str;
                        varcnt = varcnt + 1;
                     end
                  end

                  %compact parm list to remove empty cells
                  Ivalid = find(~cellfun('isempty',vars(:,1)));
                  if ~isempty(Ivalid)
                     vars = vars(Ivalid,:);
                     vars = vars';  %transpose for linear concatenation by column (to maintain pairing)
                  else
                     vars = [];
                  end

                  if ~isempty(vars)

                     %generate sitelist, station list from parsed html
                     numvars = size(vars,2);  %get number of requested parameters
                     numlist = strrep(cellstr(int2str([0:numvars-1]')),' ','');  %generate array of numerical suffix strings
                     sitelist = [concatcellcols([repmat({'site'},numvars,1),numlist],'')';repmat({site},1,numvars)]; %generate site list
                     stationlist = [concatcellcols([repmat({'station'},numvars,1),numlist],'')';repmat({station},1,numvars)];  %generate station list

                     %generate http parameter array for data request
                     postdata = [{'submit','submit', ...
                              'count',int2str(numvars), ...
                              'page','3', ...
                              'method','tab', ...
                              'agg_period','daily', ...
                              'begin',date_min, ...
                              'end',date_max}, ...
                           sitelist(:)', ...
                           stationlist(:)', ...
                           vars(:)'];

                     if silent == 0
                        if guimode == 1
                           stepnum = stepnum + 1;
                           ui_progressbar('update',stepnum,'Requesting station data...')
                        else
                           disp([datestr(now),': submitting data request']); drawnow
                        end
                     end

                     %set or create default temp directory if necessary
                     if isempty(pn)
                        pn = gce_homepath;  %get toolbox directory
                        pn_test = [pn,filesep,'search_webcache'];  %check for search_webcache subdirectory
                        if ~isdir(pn_test)
                           status = mkdir(pn,'search_webcache');  %try to create web cache directory
                           if status == 1
                              pn = pn_test;  %use search_webcache
                           end
                        else
                           pn = pn_test;  %use search_webcache
                        end
                     end

                     %init temp file name
                     fn = ['climdb_',lower(site),'_',lower(station),'_', ...
                           strrep(date_min,'-',''),'_',strrep(date_max,'-',''), ...
                           '_',datestr(now,30),'_raw.txt'];
                     fqfn = [pn,filesep,fn];  %form fully-qualified filename

                     %send data request, write output to file
                     [fqfn,status] = urlwrite(url,fqfn,'POST',postdata);

                     if silent == 0
                        if guimode == 1
                           stepnum = stepnum + 1;
                           ui_progressbar('update',stepnum,'Parsing station data...')
                        else
                           disp([datestr(now),': retrieved data from ClimDB']); drawnow
                        end
                     end

                     %parse data file, convert to data structure import format
                     if ~isempty(fqfn) && status == 1

                        %call external parsing function
                        [s,msg2] = parse_climdb_data(fn,pn,template,savetemp);

                        if ~isempty(s)

                           if silent == 0
                              if guimode == 1
                                 stepnum = stepnum + 1;
                                 ui_progressbar('update',stepnum,'Finalizing structure')
                              else
                                 disp([datestr(now),': data structure finalized']); drawnow
                              end
                           end

                           %clean up temp file
                           if savetemp == 0 & exist(fqfn,'file') == 2
                              if silent == 0
                                 if guimode == 1
                                    stepnum = stepnum + 1;
                                    ui_progressbar('update',stepnum,'Cleaning up temp files...')
                                 else
                                    disp([datestr(now),': deleted temporary files']); drawnow
                                 end
                              end
                              try
                                 delete(fqfn)  %try to delete file, catch errors
                              catch
                              end
                           end

                        else

                           msg = 'An error occurred parsing the retrieved data set';
                           if ~isempty(msg2)
                              msg = [msg,': ',msg2];
                           end

                           if silent == 0

                              if guimode == 1
                                 stepnum = stepnum + 1;
                                 ui_progressbar('update',stepnum,'Data import failed...')
                              else
                                 disp([datestr(now),': failed to parse data file']); drawnow
                              end

                           end

                        end

                     else  %no data

                        %delete empty urlwrite file if exists
                        if exist(fqfn,'file') == 2
                           try
                              fclose('all');
                              delete(fqfn);
                           catch
                           end
                        end

                        msg = 'failed to retrieve data from Climdb';

                        if guimode == 1
                           stepnum = stepnum + 1;
                           ui_progressbar('update',stepnum,'Cancelling import...')
                        else
                           disp([datestr(now),': failed to retrieve data']); drawnow
                        end

                     end

                  else
                     msg = 'none of the requested parameters are available for the specified station';
                  end

               else
                  msg = 'variable list for specified station could not be identified in web output';
               end

            else
               msg = 'unrecognized response received from ClimDB server';
            end

         else
            msg = 'failed to parse variable list for specified site and station';
         end

      else
         msg = 'could not retrieve data from ClimDB';
      end

      if guimode == 1
         ui_progressbar('close')  %close down progress bar figure
      end

   else
      msg = 'the function ''urlwrite'' in MATLAB 6.5/R13 or higher is required';
   end

else
   msg = 'insufficient arguments for function';
end