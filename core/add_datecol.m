function [s2,msg] = add_datecol(s,fmt,cols,pos)
%Generates a column of formatted date values from date component columns or an existing date column in a GCE Data Structure
%
%syntax: [s2,msg] = add_datecol(s,format,cols,pos)
%
%inputs:
%  s = GCE Data Structure
%  format = date format option:
%     [] = numeric serial day for MATLAB (base 1/1/0000 = 1) (default)
%     -1 = numeric serial day for spreadsheets (base 1/1/1900 = 0)
%     0 = text in DD-MMM-YYYY hh:mm:ss format
%     1 = text in DD-MMM-YYYY format
%     2 = text in MM/DD/YY format
%     3 = text in YYYYMMDD format (i.e. ClimDB format)
%     23 = text in MM/DD/YYYY format
%     24 = text in DD/MM/YYYY format
%     26 = text in YYYY/MM/DD format
%     29 = text in YYYY-MM-DD format (i.e. ISO 8601 date)
%     30 = text in YYYYMMDDTHHMMSS format (i.e. ISO 8601 datetime)
%     31 = text in YYYY-MM-DD hh:mm:ss format
%  cols = column names or indices containing date or date components for conversion:
%     [] = automatic (default); performs a case-insensitive search for non-text datetime columns
%        with the above names, and if no date part columns are found but a column 'Date' is present
%        it will be converted to the  requested format
%     array of columns = numeric date component columns containing Year, Month, Day, Hour, Minute, Second
%        in sequence. Missing columns are replaced with zeros except for Day, which is replaced with ones
%        for proper year + month calculation.
%     scalar column = text or numeric serial date column to convert to the specified format
%  pos = column position (default = before first date part column)
%
%outputs:
%  s2 = resultant data structure with added 'Date' column
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
%last modified: 15-Jul-2013

%init output
s2 = [];
msg = '';

%check for required data structure argument
if nargin >= 1 && gce_valid(s,'data')
   
   %validate column position or assign default
   if exist('pos','var') ~= 1
      pos = name2col(s,'Date');  %check for existing Date column
      if isempty(pos)
         pos = -1;  %flag for automatic calculation
      end
   elseif pos > length(s.name)
      pos = length(s.name) + 1;
   end
   
   %look up default column names if no columns specified
   if exist('cols','var') ~= 1
      cols = [];
   elseif ~isnumeric(cols)
      cols = name2col(s,cols);
   else
      cols = intersect((1:length(s.name)),cols);
   end
   
   %default to MATLAB serial date
   if exist('fmt','var') ~= 1
      fmt = [];
   end
   
   %look up default date component column names if no columns specified
   if isempty(cols)
      
      %get column names as array
      colnames = s.name;
      
      %init match array
      mat = {'year','month','day','hour','minute','second'};
      cols = zeros(1,6);
      
      %loop through match array
      for n = 1:6
         Imatch = find(strcmpi(colnames,mat{n}) & strcmp(s.variabletype,'datetime') & ~strcmp(s.datatype,'s'));
         if isempty(Imatch)  %check for columns starting with the label string to catch variants
            Imatch = find(strncmpi(colnames,mat{n},length(mat{n})) & strcmp(s.variabletype,'datetime') & ~strcmp(s.datatype,'s'));
         end
         if ~isempty(Imatch)
            cols(n) = Imatch(1);  %use first matched column
         end
      end
            
      %check for required year match
      if cols(1) == 0
         
         cols = [];
         
      else
         
         %check for year day if month, day missing
         if cols(2) == 0 && cols(3) == 0
            Imatch = find(strcmpi(colnames,'yearday') & strcmp(s.variabletype,'datetime') & ~strcmp(s.datatype,'s'));
            if ~isempty(Imatch)
               cols(3) = Imatch(1);
            else
               Imatch = find(strcmpi(colnames,'julianday') & strcmp(s.variabletype,'datetime') & ~strcmp(s.datatype,'s'));
               if ~isempty(Imatch)
                  cols(3) = Imatch(1);
               end
            end
         end
         
      end
      
   end
   
   %initialize cache of description strings for time zone check
   descstr = '';
   d = [];
   
   %check for valid columns after lookup (unless a single date column is specified)
   if ~isempty(cols) && length(cols) > 1
      
      %add date col before first datepart col if not specified
      if pos < 0
         pos = min(cols(cols>0));
      end
      
      %pad vector if < 6 component columns specified
      if length(cols) < 6
         cols = [cols(:)',zeros(1,6-length(cols))];  %pad vector to 6 cols
      end
      
      %get size of data table
      dlen = length(s.values{1});
      
      %initialize input matrix, setting day to 1 if omitted for proper year + month handling
      vals = [zeros(dlen,2),ones(dlen,1),zeros(dlen,3)];
      
      %loop through columns adding date elements to matrix
      for n = 1:6
         
         if cols(n) > 0
         
            %extract column values, add to matrix
            v = extract(s,cols(n));
            if ~isempty(v)
               vals(:,n) = v;
            end
            
            %append description to master description string for time zone check
            descstr = [descstr,' ',s.description{cols(n)}];
            
         end
      end
      
      try
         d = datenum(vals(:,1),vals(:,2),vals(:,3),vals(:,4),vals(:,5),vals(:,6));
      catch
         d = [];
      end
      
   else  %check for text or numeric serial date column to convert
      
      if isempty(cols)
         %look for column by name and variable type
         Idt = find(strncmpi(s.name,'date',4) & strcmp(s.variabletype,'datetime'));
      else
         Idt = cols;
      end
      
      if ~isempty(Idt)
         
         %check if multiple matches, use first floating point if present
         if length(Idt) > 1
            Idt2 = find(strcmp(s.datatype(Idt),'f'));  %check for floating=point date column first
            if ~isempty(Idt2)
               pos = Idt(Idt2(1));  %use first floating-point column
            else
               pos = Idt(1);  %use first non floating-point column
            end
         else
            pos = Idt;
         end
         
         %get column from data set
         d = extract(s,pos);
         
         %check for date string, convert to numeric
         if iscell(d)
            try
               d = datenum(d);
            catch
               try
                  d = datenum_iso(d);
               catch
                  d = [];
               end
            end
         end
         if ~isempty(d)
            descstr = s.description{pos};
         end
      end
      
   end
   
   %check for serial date calculation
   if ~isempty(d)
      
      %delete existing date column, caching date units if found for conversion documentation
      datecol = name2col(s,'Date');
      if ~isempty(datecol)
         dunits0 = s.units{datecol};
         if datecol < pos
            pos = pos-1;  %shift position to reflect column removal
         end
         s = deletecols(s,datecol);  %delete existing date column
      else
         dunits0 = '';
      end
      
      %check column descriptions for timezone references
      units = '';
      if ~isempty(descstr)
         timezones = {'GMT','EST','EDT','CST','CDT','MST','MDT','PST','PDT'};
         for n = 1:length(timezones)
            if ~isempty(strfind(descstr,timezones{n}))
               units = [' - ',timezones{n}];
               break
            end
         end
      end
      
      %generate formatted dates, add to structure based on format
      if isempty(fmt)  %matlab default
         
         dunits = 'MATLAB serial day (base 1/1/0000)';
         
         %add native matlab serial date
         s2 = addcol(s, ...
            d, ...
            'Date', ...
            ['serial day (base 1/1/0000)',units], ...
            'Fractional MATLAB serial day (based on 1 = January 1, 0000)', ...
            'f', ...
            'datetime', ...
            'continuous', ...
            6, ...
            '', ...
            pos);
         
      elseif fmt == -1  %spreadsheet
         
         dunits = 'spreadsheet serial day (base 1/1/1900)';
         
         dnum = datecnv(d,'mat2xl');  %generate spreadhsheet serial date
         
         %add column
         s2 = addcol(s, ...
            dnum, ...
            'Date', ...
            ['serial day (base 1/1/1900)',units], ...
            'Fractional serial day (based on 0 = January 1, 1900)', ...
            'f', ...
            'datetime', ...
            'continuous', ...
            6, ...
            '', ...
            pos);
         
      elseif fmt == 3  %climdb
         
         dunits = 'YYYYMMDD (ClimDB)';
         
         [yr,mo,dy] = datevec(d);  %split date into YMD vectors
         
         dnum = yr.*10000 + mo.*100 + dy;  %generate integer data number
         
         %add column
         if ~isempty(dnum)
            s2 = addcol(s, ...
               dnum, ...
               'Date', ...
               'YYYYMMDD', ...
               'Calendar date', ...
               'd', ...
               'datetime', ...
               'discrete', ...
               0, ...
               '', ...
               pos);
         end
         
      else  %other matlab datestr option
      
         %generate date unit strings based on format option
         switch fmt
            case 0
               dunits = 'DD-MMM-YYYY hh:mm:ss';
            case 1
               dunits = 'DD-MMM-YYYY';
            case 2
               dunits = 'MM/DD/YY';
            case 23
               dunits = 'MM/DD/YYYY';
            case 24
               dunits = 'DD/MM/YYYY';
            case 26
               dunits = 'YYYY/MM/DD';
            case 29
               dunits = 'YYYY-MM-DD';
            case 30
               dunits = 'YYYYMMDDThhmmss';
            case 31
               dunits = 'YYYY-MM-DD hh:mm:ss';
            otherwise
               dunits = '';
         end
         
         %check for a matched format
         if ~isempty(dunits)
            
            %perform conversion
            dunits = [dunits,units];
            try
               dstr = cellstr(datestr(d,fmt));
            catch
               dstr = '';
            end
            
            %check for success
            if ~isempty(dstr)
               s2 = addcol(s, ...
                  dstr, ...
                  'Date', ...
                  dunits, ...
                  'Calendar date', ...
                  's', ...
                  'datetime', ...
                  'none', ...
                  0, ...
                  '', ...
                  pos);
            else
               s2 = [];
            end
            
         else
            s2 = [];
         end
         
      end
      
      %generate processing history entry
      if ~isempty(s2)
         if ~isempty(cols)
            cols = cols(cols~=0);  %remove unused zero columns
            histstr = ['calculated calendar date in ',dunits,' format from individual date component columns ',cell2commas(s.name(cols),1), ...
               ', added ''Date'' column at position ',int2str(pos)];
         else
            histstr = ['converted column ',s2.name{pos},' from ',dunits0,' format to ',dunits,' format'];
         end
         s2.history = [s.history ; ...
            {datestr(now),[histstr,' (''add_datecol'')']}];
         s2.editdate = datestr(now);
      else
         msg = 'date values could not be calculated from the specified columns using the selected format';
      end
      
   else
      msg = 'required date fields are missing or could not be determined';
   end
   
else
   msg = 'a valid GCE Data Structure is required';
end
