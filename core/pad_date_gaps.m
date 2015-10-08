function [s2,msg,dupe_flag,dt_add] = pad_date_gaps(s,datecol,remove_dupes,repl_nondata,min_interval,flag,textfill)
%Fills in missing date/time records in a time-series data set to create uniform time intervals
%
%syntax: [s2,msg,dupe_flag,dt_add] = pad_date_gaps(s,datecol,remove_dupes,repl_nondata,min_interval,flag,textfill)
%
%inputs:
%  s = data structure to modify (struct; required)
%  datecol = name or index of serial date column (string or integer; optional; determined 
%    automatically by get_studydates() if omitted or empty)
%  remove_dupes = option to remove records with duplicated date/time columns,
%    retaining only the first occurance (integer; optional; 0 = no/default, 1 = yes)
%    (WARNING - remove_dupes == 1 can seriously compromise non-time-series data sets)
%  repl_nondata = option to replicate values in non-data/non-datetime columns (i.e.
%    variabletype not 'data', 'calculation' or 'datetime') when the values on either
%    side of a date/time gap are identical to avoid NaN/null entries in categorical
%    or geographical fields used for summarizing data (integer; optional; 0 = no, 1 = yes/default)
%  min_interval = minimum time interval (in minutes) for padding to avoid excessive record
%    insertion for irregular time series (number in minutes; optional; default = 1)
%  flag = flag to assign for inserted data values (character; optional; default = '' for none)
%  textfill = string to use for filling in missing values in text columns (character array; 
%     optional; default = '')
%
%outputs:
%  s2 = modified data structure
%  msg = text of any error or status message
%  dupe_flag = flag indicating whether duplicate values were present preventing
%    gap filling (used by 'ui_editor' to prompt for remove_dupes == 1 option)
%  dt_add = array of MATLAB serial dates added to pad data gaps
%
%notes:
%  1) a serial date column will be auto-generated from date component columns if not present
%  2) if remove_dupes = 1, only the first instance of a record for a date/time will be retained
%  3) for time series data sampled at <= 1Hz, use the default min_interval = 1 minute to
%     avoid over-filling records based on changes in seconds or floating-point serial date 
%     differences between records
%  4) if repl_nondata = 1, text columns will be filled using the pre-gap string if it matches
%     the post-gap value even if textfill is specified
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
%last modified: 15-Apr-2015

%initialize output
s2 = [];
msg = '';
dupe_flag = 0;
dt_add = [];

%check for required data structure
if nargin >= 1
   
   %validate data structure
   if gce_valid(s,'data')
      
      if ~isempty(s.values) && length(s.values{1}) > 1
         
         %set default datecol if omitted
         if exist('datecol','var') ~= 1
            datecol = [];  %automatic date column lookup
         elseif ischar(datecol)
            datecol = name2col(s,datecol);  %convert column name to index number
         end
         
         %set default remove_dupes option if omitted
         if exist('remove_dupes','var') ~= 1
            remove_dupes = 0;  %do not remove duplicates - throw an error
         end
         
         %set default repl_nondata option if omitted
         if exist('repl_nondata','var') ~= 1
            repl_nondata = 1;  %replicate non-data values that are the same before/after gaps
         end
         
         %set default min_interval if omitted
         if exist('min_interval','var') ~= 1
            min_interval = 1;
         end
         
         %set default flag if omitted
         if exist('flag','var') ~= 1 || isempty(flag) || ~ischar(flag)
            flag = ' ';
         elseif length(flag) > 1
            flag = flag(1);
         end
         
         %set default textfill if omitted
         if exist('textfill','var') ~= 1 || ~ischar(textfill)
            textfill = '';
         end
         
         %calculate minimum interval in days
         dt_interval = min_interval / 1440;
         
         %validate or determine serial date column
         if isempty(datecol)
            datecol = find(strcmp(s.variabletype,'datetime') & strcmp(s.datatype,'f'));
            if length(datecol) > 1  %multiple matches - check column names
               Idate = find(strncmpi(s.name(datecol),'date',4));  %check for column name starting with 'date'
               if ~isempty(Idate)
                  datecol = datecol(Idate(1));
               else
                  datecol = datecol(1);  %just use first match
               end
            end
         elseif ~strcmp(s.variabletype{datecol},'datetime') || ~strcmp(s.datatype{datecol},'f')
            datecol = [];
         end
         
         %try to calculate serial date column if not identified
         if isempty(datecol)
            s_tmp = add_datecol(s);
            if ~isempty(s_tmp)
               s = s_tmp;
               datecol = find(strcmp(s.variabletype,'datetime') & strcmp(s.datatype,'f'));
            end
         end
         
         %check for matched date column
         if ~isempty(datecol)
            
            %extract serial date values
            s2 = s;  %copy input structure to output structure
            dt = extract(s2,datecol);
            dt = sort(dt);
            
            %check for gaps by difference of sorted dates
            datediffs = diff(dt);
            mindiff = min(datediffs);
            maxdiff = max(datediffs);

            %check for duplicates based on min_interval, try to resolve by removing duplicate records in datetime columns
            %excluding Date (e.g. YMD)
            if mindiff < dt_interval && remove_dupes == 1
               Idt = setdiff(find(strcmp(s2.variabletype,'datetime')),datecol);  %get index of other datetime columns
               if ~isempty(Idt)
                  s_tmp = cleardupes(s2,Idt);
                  if ~isempty(s_tmp)  %repeat gap check
                     s2 = s_tmp;
                     dt = extract(s2,datecol);
                     dt = sort(dt);
                     datediffs = diff(dt);
                     mindiff = min(datediffs);
                     maxdiff = max(datediffs);
                  end
               end
            end

            %check for non-duplicate dates with > min_interval datediff intervals
            if mindiff >= dt_interval && maxdiff-mindiff >= dt_interval

               %round mindiff to avoid spurious floating-point decimal issues when generating intervening times
               if min_interval >= 1                  
                  mindiff = floor(mindiff*1440000)./1440000;  %truncate minutes to 3 decimal places
               else
                  mindiff = floor(mindiff*86400000)./86400000;  %truncate seconds to 3 decimal places
               end               
               
               %look up array length for bounds check
               lastrow = length(dt);
               
               %get index of gaps
               Igap = find(datediffs >= mindiff);
               
               %generate index of gap start/end
               gapidx = cell(length(Igap),3);

               %create array of dates to fill gaps
               for n = 1:length(Igap)
                  Igapstart = Igap(n);
                  Igapend = min(lastrow,Igap(n)+1);
                  gapstart = dt(Igapstart);  %get pre-gap value
                  gapend = dt(Igapend);  %get post-gap value
                  gapdata = (gapstart+mindiff:mindiff:gapend-mindiff)';  %create date series to fill gap
                  if ~isempty(gapdata)
                     gapidx{n,1} = Igapstart;
                     gapidx{n,2} = Igapend;
                     gapidx{n,3} = gapdata;
                  end
               end
               Ivalid = ~cellfun('isempty',gapidx(:,1));
               gapidx = gapidx(Ivalid,:);
               
               %generate gap data array, record insertion indices
               dt_add = cat(1,gapidx{:,3});  %concat individual arrays
               dt_addrecords = [cat(1,gapidx{:,1}),cat(1,gapidx{:,2}),cellfun('length',gapidx(:,3))];
               
               if ~isempty(dt_add)
                  
                  %get index of non-data/non-datetime columns
                  if repl_nondata == 1
                     vtypes = get_type(s2,'variabletype');
                     repl_cols = find(~strcmp(vtypes,'data') & ...
                        ~strcmp(vtypes,'calculation') & ...
                        ~strcmp(vtypes,'datetime'));
                  else
                     repl_cols = [];
                  end
                  
                  %determine total length of insert
                  numrows = length(dt_add);
                  numorig = lastrow;
                  
                  %generate dummy empty value and flag arrays
                  emptycell = repmat({textfill},numrows,1);
                  emptynum = ones(numrows,1).*NaN;
                  emptyflags = repmat(' ',numorig,1); %empty flags for original data rows            
                  newflags = repmat(flag,numrows,1);  %flags for inserted data rows
                  
                  %update data columns, flag columns
                  for n = 1:length(s2.name)
                     
                     %extract values, flags, Q/C rules
                     vals = s2.values{n};
                     flags = s2.flags{n};
                     crit = s2.criteria{n};
                     
                     %check for data/calc column
                     if isempty(find(n == repl_cols))
                        
                        if iscell(vals)  %string column
                           vals = [vals ; emptycell];
                        elseif n ~= datecol  %non-date numeric column
                           vals = [vals ; emptynum];
                        else  %date column
                           vals = [vals ; dt_add];
                        end
                        
                     else  %check for duplicate pre/post-gap values in non-data columns, replicate
                        
                        if iscell(vals)  %string column
                           
                           newvals = emptycell;  %init empty cell array of strings
                           rowptr = 1;  %init row pointer for array addressing
                           
                           %loop through gaps
                           for m = 1:size(dt_addrecords,1)
                              Istart = dt_addrecords(m,1);
                              Iend = dt_addrecords(m,2);
                              numrecs = dt_addrecords(m,3);
                              if strcmp(vals{Istart},vals{Iend})  %check for pre/post match
                                 newvals(rowptr:rowptr+numrecs-1) = vals(Istart);
                              end
                              rowptr = rowptr + numrecs;  %increment row pointer
                           end
                           vals = [vals ; newvals];
                           
                        elseif n ~= datecol  %numeric column
                           
                           newvals = emptynum;  %init empty data array
                           rowptr = 1;  %init row pointer for array addressing
                           
                           %loop through gaps
                           for m = 1:size(dt_addrecords,1)
                              Istart = dt_addrecords(m,1);
                              Iend = dt_addrecords(m,2);
                              numrecs = dt_addrecords(m,3);
                              if vals(Istart) == vals(Iend)  %check for pre/post match
                                 newvals(rowptr:rowptr+numrecs-1) = vals(Istart);
                              end
                              rowptr = rowptr + numrecs;  %increment row pointer
                           end
                           
                           vals = [vals ; newvals];
                           
                        else  %date column
                           vals = [vals ; dt_add];
                        end
                        
                     end
                     
                     %check for existing flags
                     if ~isempty(flags)
                        flags = [flags ; repmat(newflags,1,size(flags,2))];
                     elseif flag ~= ' '
                        flags = [emptyflags ; newflags];
                        if isempty(crit)
                           crit = 'manual';
                        elseif isempty(strfind(crit,'manual'))
                           crit = strrep([crit,';manual'],';;',';');
                        end
                     end
                     
                     %update structure
                     s2.values{n} = vals;
                     s2.flags{n} = flags;
                     s2.criteria{n} = crit;
                     
                  end
                  
                  %update processing history
                  str_rows = int2str(numrows);
                  if numrows > 1
                     str_rows = [str_rows,' new records'];
                  else
                     str_rows = [str_rows,' new record'];
                  end
                  if flag ~= ' '
                     str_flags = [' and assigned flag ''',flag,''' to inserted records'];
                  else
                     str_flags = '';
                  end
                  if isempty(repl_cols)
                     s2.history = [s2.history ; {datestr(now)}, ...
                        {['inserted ',str_rows,' containing date/time values and NaN/null data values to fill in date/time interval gaps in the data series', ...
                        str_flags,' (''pad_date_gaps'')']}];
                  else  %include list of non-data columns with values replicated
                     s2.history = [s2.history ; {datestr(now)}, ...
                        {['inserted ',str_rows,' with date/time values and NaN/null data values (replicating common values in the non-data columns ', ...
                        cell2commas(s2.name(repl_cols),1),') to fill in date/time interval gaps in the data series', ...
                        str_flags,' (''pad_date_gaps'')']}];
                  end
                  
                  %sort by date column
                  s2 = sortdata(s2,datecol);
                  if ~isempty(s2)
                     %re-generate date part columns if already present in the data set
                     dateparts = [];
                     dtcols = {'year','month','day','hour','minute','second'};
                     for n = 1:length(dtcols)
                        if ~isempty(find(strcmpi(s2.name,dtcols{n})))
                           dateparts = [dateparts,n];
                        end
                     end
                     if ~isempty(dateparts)
                        s2 = add_datepartcols(s2,datecol,[],dateparts);
                     end
                     msg = ['Added ',int2str(numrows),' null records to fill in date/time interval gaps'];
                  else  %empty output struct - report validation error
                     msg = 'An error occurred filling in date/time gaps - modified structure failed validation';
                  end
                  
               else
                  msg = ['No date/time gaps > ',num2str(min_interval),' min were present in the data set'];
               end
               
            else  %report null results but return original structure
               s2 = s;
               if mindiff == 0
                  msg = 'Invalid time series data set (duplicate date values or redundant date/time columns found)';
                  dupe_flag = 1;
               else
                  msg = ['No date/time gaps > ',num2str(min_interval),' min were present in the data set'];
               end
            end
            
         else
            msg = 'Date column was invalid or could not be determined';
         end
         
      else
         %empty values or single-row data set so nothing to do - return original structure
         s2 = s;
      end
      
   else
      msg = 'Invalid data structure';
   end
   
else
   msg = 'Insufficient arguments for function';
end