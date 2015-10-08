function [s2,msg] = add_datepartcols(s,datecol,timecol,dateparts,position)
%Adds numerical date part columns to a GCE Data Structure, based on a single serial date column
%(base 1900 or base 0000). Note that any existing columns named 'Year', 'Month', 'Day', 'Hour',
%'Minute', 'Second' will be replaced.
%
%syntax: [s2,msg] = add_datepartcols(s,datecol,timecol,dateparts,position)
%
%inputs:
%  s = GCE Data Structure (struct; required)
%  datecol = name or number of serial date column (string or integer; optional; default is first column
%     starting with 'Date' (case insensitive) and datatype 'f' or 's' and variabletype 'datetime')
%  timecol = name or number of time column (string or integer; optional; default is [] if datecol is 
%     numeric, otherwise first column starting with 'Time' and datatype 'd' or 's' and variabletype 'datetime')
%  dateparts = optional list of dateparts to include (cell array of strings or numerical array; optional; default = all):
%    'year' or 'yr' or 1 = year
%    'month' or 'mo' or 2 = month
%    'day' or 'dy' or 3 = day
%    'hour' or 'hr' or 4 = hour
%    'minute' or 'mi' or 5 = minute
%    'second' or 'sc' or 6 = second
%  position = optional position for insertion of the columns (0 = beginning,
%    >0 insert after column 'position', after date/time columns if omitted)
%
%outputs:
%  s2 = output structure with inserted columns;
%  msg = text of any error message
%
%notes:
%  1) string dateparts are not case-sensitive (e.g. Year or year or YR)
%  2) timecol argument will be ignored if datecol contains a numeric serial date
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
%last modified: 03-Apr-2015

%init output
s2 = [];
msg = '';

%check for valid data structure input
if nargin >= 1 && gce_valid(s,'data')
   
   %supply defaults for omitted arguments
   if exist('position','var') ~= 1
      position = [];
   elseif position < 0
      position = 0;
   end
   
   if exist('timecol','var') ~= 1
      timecol = [];
   elseif ~isnumeric(timecol)
      timecol = name2col(s,timecol);
   end
   
   %force column lookup if datecol omitted
   if exist('datecol','var') ~= 1
      datecol = [];
   elseif ~isnumeric(datecol)
      datecol = name2col(s,datecol);
   end
   
   %look up date field if not specified, excluding 'yearday' column if present
   if isempty(datecol)
      
      %get date column index
      Icol = find(strcmp('f',get_type(s,'datatype')) & strcmp('datetime',get_type(s,'variabletype')) & ...
         ~strcmpi('yearday',s.name));
      
      if length(Icol) >= 1
         
         %check for multiple matches
         if length(Icol) == 1
            datecol = Icol;  %use only matched column
         else
            Icol2 = find(strncmpi(s.name(Icol),'date',4));  %search for column name starting with 'date'
            if length(Icol2) >= 1
               datecol = Icol(Icol2(1));  %use first matched column starting with 'date'
            else
               datecol = Icol(1);  %use first original match
            end
         end
         
      else   %no floating point date
         
         %look for string date column         
         Icol = find(strcmp('s',get_type(s,'datatype')) & strcmp('datetime',get_type(s,'variabletype')));
         
         %check for multiple matches
         if length(Icol) >= 1
            if length(Icol) == 1
               datecol = Icol;
            else
               Icol2 = find(strncmpi('date',s.name,4));  %get index of columns starting with 'date'
               if length(Icol2) >= 1
                  datecol = Icol(Icol2(1));  %use first match starting with 'date'
               else
                  datecol = Icol(1);  %use first match regardless of name
               end
            end
         end
      end
   end

   %check for matched date column
   if ~isempty(datecol)

      %look up variable type and data type of date column
      vtype = get_type(s,'variabletype',datecol);
      dtype = get_type(s,'datatype',datecol);
      
      %confirm specified or matched column is datetime column in either floating-point or string format
      if strcmp('datetime',vtype) && (strcmp('f',dtype) || strcmp('s',dtype))
         
         %check for date strings
         if strcmp('s',dtype)
            
            dstr = extract(s,datecol);  %extract string dates
            
            d = ones(length(dstr),1) .* NaN;  %init array of numeric dates
            
            %check for time column by name and type if not specified
            if isempty(timecol)
               Icol = find(strcmpi('time',s.name) & strcmp('datetime',get_type(s,'variabletype')));
               if length(Icol) == 1
                  timecol = Icol(1);
               end
            end
            
            %calculate numeric time if timecol present
            if ~isempty(timecol)
               
               %extract time values
               t = extract(s,timecol);
               
               %check for string time column, convert to numeric
               if ~strcmp('s',get_type(s,'datatype',timecol))
                  
                  %convert integer time to decimal days
                  if max(t) <= 2400
                     %assume 0000 to 2400 format                   
                     th = fix(t./100)./24;  %convert hours to fractional day
                     tm = (t-fix(t./100).*100)./60./24;  %conver minutes to fractional day
                     t = th + tm;
                  elseif max(t) <= 240000  
                     %assume 000000 to 240000 format
                     th = fix(t./10000)./24;  %convert hours to fractional day
                     tms = (t-fix(t./10000).*10000);  %calculate just minute/seconds part of number
                     tm = fix(tms./100)./60./24;  %convert minutes to fractional day
                     ts = (tms - fix(tms./100).*100)./60./60./24;  %convert seconds to fractional day
                     t = th + tm + ts;
                  else
                     %unsupported format
                     t = zeros(length(str),1);
                  end
                  
                  %convert string date to numeric and then add time
                  try
                     dnew = datenum(dstr);
                  catch
                     try
                        dnew = datenum_iso(dstr);  %try iso format variant
                     catch
                        dnew = [];
                     end
                  end
                  
                  if ~isempty(dnew) && length(dnew) == length(t)
                     d = dnew + t;
                  end
                  
               else  %string date and time columns
                  
                  %concatenate date and time strings with space separator
                  dt = concatcellcols([dstr,t],' ');
                  
                  %convert string date/time to numeric
                  try
                     dnew = datenum(dt);
                  catch
                     try
                        dnew = datenum_iso(dt);  %try iso format variant
                     catch
                        dnew = [];
                     end
                  end
                  
                  %check for successful conversion
                  if ~isempty(dnew)
                     d = dnew;
                  end
                  
               end
               
            else  %date column only
            
               %convert string date to numeric
               try
                  dnew = datenum(dstr);
               catch
                  try
                     dnew = datenum_iso(dstr);  %try iso date string formats
                  catch
                     dnew = [];
                  end
               end
               
               %check for successful conversion
               if ~isempty(dnew)
                  d = dnew;
               end
               
            end
            
         else
            
            %extract floating-point dates
            d = extract(s,datecol);
            
         end
         
         %check for successful extraction/calculation of numeric serial date
         if ~isempty(d)
            
            %get index of valid dates
            Ivalid = find(~isnan(d));
            
            %check for valid dates to process
            if ~isempty(Ivalid)
               
               %check for time zone in units
               timezones = {'GMT','EST','EDT','CST','CDT','MST','MDT','PST','PDT'};
               hourstr = 'Hours';
               for n = 1:length(timezones)
                  if ~isempty(strfind(s.units{datecol},timezones{n})) || ...
                        ~isempty(strfind(s.description{datecol},timezones{n}))
                     hourstr = [hourstr,' - ',timezones{n}];    %#ok<AGROW>
                     break
                  end
               end
               
               %initialize cell arrays of attribute metadata for columns
               allcols = [{'yr'}, ...
                  {'mo'}, ...
                  {'dy'}, ...
                  {'hr'}, ...
                  {'mi'}, ...
                  {'sc'}];
               allnames = [{'Year'}, ...
                  {'Month'}, ...
                  {'Day'}, ...
                  {'Hour'}, ...
                  {'Minute'}, ...
                  {'Second'}];
               allunits = [{'YYYY'}, ...
                  {'MM'}, ...
                  {'DD'}, ...
                  {'hr'}, ...
                  {'min'}, ...
                  {'sec'}];
               alldesc = [{'Calendar year'}, ...
                  {'Calendar month'}, ...
                  {'Calendar day'}, ...
                  {hourstr}, ...
                  {'Minutes'}, ...
                  {'Seconds'}];
               
               %check for existing date part columns, store positions
               Ioldcols = [];
               for n = 1:length(allnames)
                  I_existing = find(strcmp(s.name,allnames{n}));
                  if ~isempty(I_existing)
                     if I_existing(1) ~= datecol
                        if ~isempty(timecol)
                           if I_existing(1) ~= timecol
                              Ioldcols = [Ioldcols,I_existing];
                           end
                        else
                           Ioldcols = [Ioldcols,I_existing];
                        end
                     end
                  end
               end

               %init processing history entry
               histstr = '';

               %delete existing date part columns, update datecol/timecol
               if ~isempty(Ioldcols)
                  
                  %update processing history entry and output message
                  histstr = ['deleted existing datetime columns ',cell2commas(s.name(Ioldcols),1),'; updated '];
                  msg = ['Existing date component columns ',cell2commas(s.name(Ioldcols),1),' were updated'];
                  
                  %delete old columns
                  s_tmp = deletecols(s,Ioldcols);
                  
                  %check for successful deletion
                  if ~isempty(s_tmp)
                  
                     %copy temp structure to output but omitting history entry for deletion
                     str_hist = s.history;  %buffer history
                     s = s_tmp;
                     s.history = str_hist;  %restore history
                     clear s_tmp;
                     
                     %adjust datecol index if necessary
                     if datecol > min(Ioldcols)
                        I_before = find(Ioldcols < datecol);
                        if ~isempty(I_before)
                           datecol = datecol - length(I_before);
                        end
                     end
                     
                     %adjust timecol index if necessary
                     if ~isempty(timecol)
                        if timecol > min(Ioldcols)
                           I_before = find(Ioldcols < timecol);
                           if ~isempty(I_before)
                              timecol = timecol - length(I_before);
                           end
                        end
                     end
                     
                  end
                  
               end
               
               %init attribute metadata descriptor arrays
               alldatatypes = [repmat({'d'},1,5),{'f'}];
               allvartypes = repmat({'datetime'},1,6);
               allnumtypes = [repmat({'discrete'},1,5),{'continuous'}];
               allprec = [0,0,0,0,0,2];
               allcrit = [{''}, ...
                  {'x<1=''I'';x>12=''I'''}, ...
                  {'x<1=''I'';x>31=''I'''}, ...
                  {'x<0=''I'';x>24=''I'''}, ...
                  {'x<0=''I'';x>60=''I'''}, ...
                  {'x<0=''I'';x>60=''I'''}];
               
               %check for automatic date parts option
               if exist('dateparts','var') ~= 1
                  dateparts = [];
               end
               if isempty(dateparts)
                  autodateparts = 1;
               else
                  autodateparts = 0;
               end
               
               if isempty(dateparts)  %use defaults
                  dateparts = allcols(1:6);
               elseif ~iscell(dateparts)  %assume index
                  dateparts = allcols(dateparts);
               end
               
               if log10(d(Ivalid(1))) < 5  %check for base 1900 dates, convert to MATLAB dates
                  d(Ivalid) = datecnv(d(Ivalid),'xl2mat');
               end
               
               %calculate date vectors from serial date
               if autodateparts == 1 || (sum(strcmpi(dateparts,'sc')) == 0 && sum(strcmpi(dateparts,'second')) == 0)
                  inc = 1.1574e-005;  %add 1 second for minute rounding if seconds not explicitly requested
                  [yr,mo,dy,hr,mi,sc] = datevec(d(Ivalid)+inc);
                  sc = sc - 1;  %subtract extra second
                  sc(sc<0) = 0;  %zero any negative seconds resulting from subtraction
               else
                  [yr,mo,dy,hr,mi,sc] = datevec(d(Ivalid));
               end
               
               %initialize cell array for vec cols
               cols = cell(1,6);
               
               %check missing date values
               if length(Ivalid) == length(d)
                  
                  cols{1} = yr;
                  cols{2} = mo;
                  cols{3} = dy;
                  cols{4} = hr;
                  cols{5} = mi;
                  cols{6} = sc;
                  
               else  %deal with NaNs
                  
                  %init arrays of NaN
                  yr2 = ones(length(d),1) .* NaN;
                  mo2 = yr2;
                  dy2 = yr2;
                  hr2 = yr2;
                  mi2 = yr2;
                  sc2 = yr2;
                  
                  %populate master date component arrays with calculated values
                  yr2(Ivalid) = yr;
                  mo2(Ivalid) = mo;
                  dy2(Ivalid) = dy;
                  hr2(Ivalid) = hr;
                  mi2(Ivalid) = mi;
                  sc2(Ivalid) = sc;
                  
                  %add to cell array
                  cols{1} = yr2;
                  cols{2} = mo2;
                  cols{3} = dy2;
                  cols{4} = hr2;
                  cols{5} = mi2;
                  cols{6} = sc2;
                  
               end
               
               %determine cols requested (non-zero columns if automatic)
               selcols = zeros(1,6);
               for n = 1:6
                  if sum(strcmpi(allcols{n},dateparts)) > 0 || sum(strcmpi(allnames{n},dateparts)) > 0
                     if autodateparts == 0
                        selcols(n) = 1;
                     elseif sum(floor(cols{n})) > 0  %check for non-zero elements, truncating to eliminate trivial floating-point math digits
                        selcols(n) = 1;
                     end
                  end
               end
               I_sel = find(selcols);  %get list of date part columns to include
               
               %copy existing structure to output
               s2 = s;
               
               %add cols after timecol or datecol if not specified
               if isempty(position)
                  if ~isempty(timecol)
                     position = timecol;
                  else
                     position = datecol;
                  end
               end
               
               %cache formatted date/time
               curdate = datestr(now);
               
               %add columns to data structure
               if position > 0
                  if position < length(s2.name)  %embed
                     s2.name = [s.name(1:position),allnames(I_sel),s.name(position+1:end)];
                     s2.units = [s.units(1:position),allunits(I_sel),s.units(position+1:end)];
                     s2.description = [s.description(1:position),alldesc(I_sel),s.description(position+1:end)];
                     s2.datatype = [s.datatype(1:position),alldatatypes(I_sel),s.datatype(position+1:end)];
                     s2.variabletype = [s.variabletype(1:position),allvartypes(I_sel),s.variabletype(position+1:end)];
                     s2.numbertype = [s.numbertype(1:position),allnumtypes(I_sel),s.numbertype(position+1:end)];
                     s2.precision = [s.precision(1:position),allprec(I_sel),s.precision(position+1:end)];
                     s2.criteria = [s.criteria(1:position),allcrit(I_sel),s.criteria(position+1:end)];
                     s2.values = [s.values(1:position),cols(I_sel),s.values(position+1:end)];
                     s2.flags = [s.flags(1:position),repmat({''},1,length(I_sel)),s.flags(position+1:end)];
                     s2.history = [s.history ; ...
                        {curdate},{[histstr,cell2commas(allnames(I_sel),1),' datetime columns added after column ', ...
                        s.name{position},' (''add_datepartcols'')']}];
                  else  %append columns
                     s2.name = [s.name,allnames(I_sel)];
                     s2.units = [s.units,allunits(I_sel)];
                     s2.description = [s.description,alldesc(I_sel)];
                     s2.datatype = [s.datatype,alldatatypes(I_sel)];
                     s2.variabletype = [s.variabletype,allvartypes(I_sel)];
                     s2.numbertype = [s.numbertype,allnumtypes(I_sel)];
                     s2.precision = [s.precision,allprec(I_sel)];
                     s2.criteria = [s.criteria,allcrit(I_sel)];
                     s2.values = [s.values,cols(I_sel)];
                     s2.flags = [s.flags,repmat({''},1,length(I_sel))];
                     s2.history = [s.history ; ...
                        {curdate},{[histstr,cell2commas(allnames(I_sel),1),' datetime columns added after column ', ...
                        s.name{end},' (''add_datepartcols'')']}];
                  end
               else  %prepend columns
                  s2.name = [allnames(I_sel),s.name];
                  s2.units = [allunits(I_sel),s.units];
                  s2.description = [alldesc(I_sel),s.description];
                  s2.datatype = [alldatatypes(I_sel),s.datatype];
                  s2.variabletype = [allvartypes(I_sel),s.variabletype];
                  s2.numbertype = [allnumtypes(I_sel),s.numbertype];
                  s2.precision = [allprec(I_sel),s.precision];
                  s2.values = [cols(I_sel),s.values];
                  s2.flags = [repmat({''},1,length(I_sel)),s.flags];
                  s2.criteria = [allcrit(I_sel),s.criteria];
                  s2.history = [s.history ; ...
                     {curdate},{[histstr,cell2commas(allnames(I_sel),1),' datetime columns added before column ',s.name{1},' (''add_datepartcols'')']}];
               end
               
               s2.editdate = curdate;
               
            else
               msg = 'date column is invalid or format is not supported by MATLAB';
            end
            
         else
            msg = 'no valid date values in the indicated column';
         end
         
      else
         msg = 'date column is invalid or format is not supported by MATLAB';
      end
      
   else
      msg = 'date column is invalid or format is not supported by MATLAB';
   end
   
else
   msg = 'a valid GCE Data Structure argument is required';
end
