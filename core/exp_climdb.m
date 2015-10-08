function [msg,status,s_mod] = exp_climdb(s,site,station,fn,pn,append,pct_missing)
%Exports climate and/or hydrographic monitoring data in LTER ClimDB harvester format.
%Data will be resampled to daily intervals if necessary, and column names and units
%will be converted to ClimDB equivalents based on the lookup table stored in the data
%structure 'exp_climdb.mat'. Note that values assigned quality control flag 'I' (invalid)
%will automatically be removed from the data (converted to missing)
%
%syntax: [msg,status,s_mod] = exp_climdb(s,site,station,fn,pn,append,pct_missing)
%
%inputs:
%  s = data structure to export
%  site = ClimDB site code
%  station = ClimDB station code
%  fn = filename to export (default = [site]_lter.txt)
%  pn = pathname for export file (default = pwd)
%  append = option to append or overwrite existing file
%    0 = overwrite existing file
%    1 = append to existing file (default)
%  pct_missing = q/c flag criteria to use for maximum percent missing values for flagging derived
%    statistics when resampling data to daily intervals (default = 20; NaN for no missing value criteria)
%
%outputs:
%  msg = status message
%  status = status flag (0 = failure, 1 = success)
%  s_mod = modified structure used for export file generation
%
%
%(c)2002-2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project-2006 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 03-Mar-2014

s_mod = [];
msg = '';
status = 0;

if nargin >= 3

   if gce_valid(s,'data') && exist('exp_climdb.mat','file') == 2

      %validate path
      if exist('pn','var') ~= 1 || ~isdir(pn)
         pn = pwd;
      end

      %convert numeric station id to string
      if isnumeric(station)
         station = num2str(station);
      end

      %set default filename if omitted
      if exist('fn','var') ~= 1
         fn = '';
      end
      
      %generate standard filename
      if isempty(fn)
         fn = [lower(site),'_lter.txt'];  
      end

      %default to append mode
      if exist('append','var') ~= 1
         append = 1;  
      elseif append ~= 0
         append = 1;
      end

      %default to 20% missing threshold
      if exist('pct_missing','var') ~= 1
         pct_missing = 20;
      elseif ~isnumeric(pct_missing)
         pct_missing = NaN;
      end

      %remove redundant columns to avoid fatal ClimDB harvest errors
      numcols = length(s.name);
      [tmp,Iunique] = unique(s.name);

      %perform dupe check
      while length(Iunique) < numcols

         %get indices of dupe columns
         Iunique = sort(Iunique);  %sort unique index
         Idupes = setdiff((1:length(s.name)),Iunique);  %get index of dupe columns by difference from Iunique
         dupe1 = Idupes(1);  %grab first dupe column
         dupe2 = setdiff(find(strcmp(s.name,s.name{dupe1})),dupe1);  %get index of first dupe column after dupe1
         dupe2 = dupe2(1);  %restrict to first item if >1 dupe

         %ensure relative column order correct for consolidation
         col1 = min([dupe1,dupe2]);
         col2 = max([dupe1,dupe2]);

         %perform consolidation, fall back to deletion of col2 if fails
         s_tmp = coalesce_cols(s,col1,col2);
         if ~isempty(s_tmp)
            if length(s_tmp.name) < length(s.name)  %check for messed up delete, infinite loop condition
               s = s_tmp;
            else
               s = deletecols(s,col2);  %consolidation failed, fall back to delete
            end
         else
            s = deletecols(s,col2);  %consolidation failed, fall back to delete
         end

         %generate new dupe index for next iteration
         [tmp,Iunique] = unique(s.name);
         numcols = length(s.name);

      end

      %load attribute mapping data set
      try
         v = load('exp_climdb.mat','-mat');
      catch e
         v = struct('null','');
         msg = ['ClimDB attribute mapping data set ''exp_climdb.mat'' is missing or invalid (',e.message,')'];
      end

      if isfield(v,'data')

         %get date values to determine increment
         dt = get_studydates(s);
         mindateinc = 1;

         %check for daily or greater date increment, resample if < 1
         if ~isempty(dt)
            
            if isnumeric(dt)
            
               %get record-record differences of sorted dates, removing NaNs
               dateinc = diff(sort(dt(~isnan(dt))));
               dateinc = dateinc(dateinc > 0);  %ignore duplicates
               
               if ~isempty(dateinc)
                  
                  %get minimum increment
                  mindateinc = min(dateinc);
                  
                  %check for < daily
                  if mindateinc < 1
                     
                     %generate Q/C rules for aggregated data columns
                     if ~isnan(pct_missing)
                        qc_crit = {'missing',num2str(pct_missing),'percent','Q';'flagged','0','count','Q'};
                     else
                        qc_crit = {'flagged','0','count','Q'};
                     end
                     
                     %check for Year, Month Day
                     if sum(strcmp(s.name,'Year')) > 0 && sum(strcmp(s.name,'Month')) > 0 && sum(strcmp(s.name,'Day')) > 0
                        s = aggr_stats(s,{'Year','Month','Day'},listdatacols(s),0,'I',qc_crit);
                     else
                        s = add_datepartcols(s);  %try to generate Year, Month, Day
                        if ~isempty(s)
                           s = aggr_stats(s,{'Year','Month','Day'},listdatacols(s),0,'I',qc_crit);
                        end
                     end
                     
                  end
                  
               end
               
            end
            
         end

         %check missing datetime array or invalid data set after aggregation
         if ~isempty(s) && ~isempty(dt)

            %clear Date column, if present, so it can be regenerated in Climdb format
            s2 = deletecols(s,'Date');
            if ~isempty(s2)
               s = s2;
            end

            %generate ClimDB date column from Year, Month, Day if present
            if sum(strcmp(s.name,'Year')) > 0 && sum(strcmp(s.name,'Month')) > 0 && sum(strcmp(s.name,'Day')) > 0
            
               %generate date column in yyyymmdd format
               s = add_datecol(s,3,{'Year','Month','Day'},0);  
               
            else  %use dt array from get_studydates
               
               %add dt array as Date column
               s = addcol(s,dt,'Date','serial day (base 1/1/0000)','Date of measurement','f','datetime','continuous',7,'',0);
               s = convert_date_format(s,'Date','yyyymmdd');
               
            end

            %check for successful date addition
            if ~isempty(s)

               err = 0;

               %get lists of Climdb column name equivalents and corresponding units for autoconversion
               colnames = extract(v.data,'ColumnName');
               climdbnames = extract(v.data,'ClimdbName');
               climdbunits = extract(v.data,'ClimdbUnits');

               %init column array with date column
               cols = name2col(s,'Date');

               %get list of all data/calculation columns
               datacols = listdatacols(s);

               %check for candidate Climdb columns
               for n = 1:length(datacols)
                  
                  %look up column
                  Imatch = find(strcmp(s.name{datacols(n)},colnames) | strcmp(s.name{datacols(n)},climdbnames));
                  
                  %check for match
                  if ~isempty(Imatch)
                     
                     %use first matched column
                     Imatch = Imatch(1);  
                     
                     %add to cols list
                     cols = [cols,datacols(n)];
                     
                     %rename column to match ClimDB name
                     s.name{datacols(n)} = climdbnames{Imatch};
                     
                     %perform unit conversion if necessary
                     if ~strcmpi(s.units{datacols(n)},climdbunits{Imatch})
                        s2 = unit_convert(s,datacols(n),climdbunits{Imatch});
                        if ~isempty(s2)
                           s = s2;
                        else
                           err = 1;
                        end
                     end
                     
                  end
                  
               end

               if length(cols) > 1 && err == 0

                  %preserve flags based on column dependencies by setting criteria to manual
                  for n = 1:length(cols)
                     if ~isempty(s.flags{cols(n)})
                        s.criteria{cols(n)} = [s.criteria{cols(n)},';manual'];
                     end
                  end

                  %clear values assigned flag I
                  s = nullflags(s,'I');

                  %use column index to subset structure
                  s = copycols(s,cols);

                  %check columns assigned flags for unsupported flag codes
                  Iflags = find(~cellfun('isempty',s.flags));
                  if ~isempty(Iflags)
                     for n = 1:length(Iflags)
                        flags = s.flags{Iflags(n)};
                        I = find(flags(:,1)~=' ');
                        if isempty(I)
                           s.flags{Iflags(n)} = '';
                        else
                           allflags = cellstr(upper(flags(:,1)));  %convert flags to upper case cell array
                           flaglist = unique(allflags(I));  %get list of assigned flags
                           for m = 1:length(flaglist)
                              if length(find(strcmp({'E','G','T','Q','M'},flaglist{m}))) ~= 1  %check against list
                                 allflags = strrep(allflags,flaglist{m},'');  %remove unsupported flags
                              end
                           end
                           s.flags{Iflags(n)} = char(allflags);  %update flag array
                        end
                     end
                  end

                  %generate flags for each data column
                  s = flags2cols(s,'alldata',0,1,1,0);

                  %add station column
                  s = addcol(s, ...
                     station, ...
                     'Station', ...
                     'none', ...
                     'Monitoring station', ...
                     's', ...
                     'nominal', ...
                     'none', ...
                     0, ...
                     '', ...
                     0);

                  %add site column
                  s = addcol(s, ...
                     site, ...
                     'LTER_Site', ...
                     'none', ...
                     'Monitoring station', ...
                     's', ...
                     'nominal', ...
                     'none', ...
                     0, ...
                     '', ...
                     0);

                  if gce_valid(s,'data')
                     s_mod = s;  %assign output
                     status = 1;
                     if append == 1
                        appendopt = 'T';
                     else
                        appendopt = 'N';
                     end
                     exp_ascii(s,'comma',fn,pn,'','T','N','','!','no','',',','N',appendopt);
                     if mindateinc >= 1
                        msg = ['Successfully exported data in Climdb format to file ''',fn,''''];
                     else
                        msg = ['Successfully resampled data to daily intervals and exported in Climdb format to file ''', ...
                              fn,''''];
                     end
                  else
                     msg = 'Errors occurred preparing data in Climdb format - export cancelled';
                  end

               else

                  if length(cols) == 1
                     msg = 'No columns compatable with ClimDB were present in the structure - export cancelled';
                  else
                     msg = 'Errors occurred performing required unit converstions - export cancelled';
                  end

               end

            else
               msg = 'Could not generate ClimDB data format - export cancelled';
            end

         else
            msg = 'Could not determine date/time interval or resample to daily interval data - export cancelled';
         end

      end

   else

      if exist('exp_climdb.mat','file') ~= 2
         msg = 'Required file ''exp_climdb.mat'' could not be located - export cancelled';
      else
         msg = 'invalid data structure';
      end

   end

else
   msg = 'insufficient arguments for function';
end