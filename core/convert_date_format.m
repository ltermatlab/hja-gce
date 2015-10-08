function [s2,msg] = convert_date_format(s,cols,fmt)
%Converts the format of specified date/time columns in a GCE Data Structure to a new format
%
%syntax: [s2,msg] = convert_date_format(s,cols,fmt)
%
%inputs:
%  s = GCE Data Structure
%  cols = array of column names or index numbers to convert ('datetime' columns of type 'f' or 's')
%  fmt = date format option:
%     [] = numeric serial day for MATLAB (base 1/1/0000 = 1)
%     -1 = numeric serial day for spreadsheets (base 1/1/1900 = 0)
%     0 = 'dd-mmm-yyyy HH:MM:SS'
%     1 = 'dd-mmm-yyyy'
%     2 = 'mm/dd/yy'
%     3 = 'mmm'
%     4 = 'm'
%     5 = 'mm'
%     6 = 'mm/dd'
%     7 = 'dd'
%     8 = 'ddd'
%     9 = 'd'
%     10 = 'yyyy'
%     11 = 'yy'
%     12 = 'mmmyy'
%     13 = 'HH:MM:SS'
%     14 = 'HH:MM:SS PM'
%     15 = 'HH:MM'
%     16 = 'HH:MM PM'
%     17 = 'QQ-YY'
%     18 = 'QQ'
%     19 = 'dd/mm'
%     20 = 'dd/mm/yy'
%     21 = 'mmm.dd,yyyy HH:MM:SS'
%     22 = 'mmm.dd,yyyy'
%     23 = 'mm/dd/yyyy'
%     24 = 'dd/mm/yyyy'
%     25 = 'yy/mm/dd'
%     26 = 'yyyy/mm/dd'
%     27 = 'QQ-YYYY'
%     28 = 'mmmyyyy'
%     29 = 'yyyy-mm-dd'
%     30 = 'yyyymmddTHHMMSS'
%     31 = 'yyyy-mm-dd HH:MM:SS'
%     custom string = custom format combining date part symbols and punctuation
%       (allowed symbols: yyyy,yy,mmmm,mmm,mm,m,dddd,ddd,dd,d,HH,MM,SS,FFF,PM - see datestr)
%
%outputs:
%  s2 = revised data structure
%  msg = text of any error message
%
%notes:
%  1) for floating-point serial dates in cols, if the maximum value is <1e5 then
%     spreadsheet base 1900 dates are assumed and dateconv(dt,'xl2mat') is called
%     to convert the dates to MATLAB datenum format (base 0000)
%
%(c)2013-2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 01-Apr-2015

%init output
s2 = [];
msg = '';

%check for required data structure argument
if nargin == 3 && gce_valid(s,'data')
   
   %look up default column names if no columns specified
   if exist('cols','var') ~= 1
      cols = [];
   elseif ~isnumeric(cols)
      cols = name2col(s,cols);
   else
      cols = intersect((1:length(s.name)),cols);  %remove invalid columns
   end
   
   if ~isempty(cols)
      
      %init array of updated column flags
      numcols = length(cols);
      
      %init output
      s2 = s;
      badcols = zeros(numcols,1);
      msg_all = repmat({''},numcols,1);
      
      %init format lookup list for generating units
      unit_lookup = {0,'dd-mmm-yyyy HH:MM:SS'; ...
         1,'dd-mmm-yyyy'; ...
         2,'mm/dd/yy'; ...
         3,'mmm'; ...
         4,'m'; ...
         5,'mm'; ...
         6,'mm/dd'; ...
         7,'dd'; ...
         8,'ddd'; ...
         9,'d'; ...
         10,'yyyy'; ...
         11,'yy'; ...
         12,'mmmyy'; ...
         13,'HH:MM:SS'; ...
         14,'HH:MM:SS PM'; ...
         15,'HH:MM'; ...
         16,'HH:MM PM'; ...
         17,'QQ-YY'; ...
         18,'QQ'; ...
         19,'dd/mm'; ...
         20,'dd/mm/yy'; ...
         21,'mmm.dd,yyyy HH:MM:SS'; ...
         22,'mmm.dd,yyyy'; ...
         23,'mm/dd/yyyy'; ...
         24,'dd/mm/yyyy'; ...
         25,'yy/mm/dd'; ...
         26,'yyyy/mm/dd'; ...
         27,'QQ-YYYY'; ...
         28,'mmmyyyy'; ...
         29,'yyyy-mm-dd'; ...
         30,'yyyymmddTHHMMSS'; ...
         31,'yyyy-mm-dd HH:MM:SS'};
      
      for n = 1:numcols
         
         %validate column data type, variable type
         col = cols(n);
         dtype = get_type(s,'datatype',col);
         vtype = get_type(s,'variabletype',col);
         unitstr = s.units{col};
         descstr = s.description{col};
         
         if strcmp(vtype,'datetime')
            
            %get column values
            vals = extract(s,col);
            
            %get numeric serial date
            if strcmp(dtype,'s')
               
               %call external function to convert dates
               dt = datestr2num(vals,unitstr);
               
            elseif strcmp(dtype,'f')
               
               %use numeric values as is
               dt = vals;
               if max(no_nan(dt)) < 1e5
                  dt = datecnv(dt,'xl2mat');  %assume spreadsheet date (base 1900) if <1e5
               end
               
            else
               dt = [];  %unsupported for d, e
            end
            
            %try to apply format
            if isempty(fmt)
               dt_new = dt;
               dtype_new = 'f';
               ntype_new = 'continuous';
               prec_new = 7;
            elseif isnumeric(fmt) && fmt == -1
               dt_new = datecnv(dt,'mat2xl');  %generate spreadhsheet serial date
               dtype_new = 'f';
               ntype_new = 'continuous';
               prec_new = 7;
            else  %datestr format
               dtype_new = 's';
               ntype_new = 'none';
               prec_new = 0;
               Ivalid = find(~isnan(dt));
               dt_new = repmat({''},length(dt),1);
               if ~isempty(Ivalid)
                  try
                     dstr = cellstr(datestr(dt(Ivalid),fmt));                     
                  catch
                     dstr = [];
                  end
                  if ~isempty(dstr)
                     dt_new(Ivalid) = dstr;
                  end
               end
            end
            
            %check for successful formatting
            if ~isempty(dt_new)
               
               %generate new units
               units = '';
               fmt_new = '';
               if isempty(fmt)
                  units = 'MATLAB serial day (base 1/1/0000)';
                  fmt_new = 'MATLAB serial date';
               elseif isnumeric(fmt)
                  if fmt < 0
                     units = 'spreadsheet serial day (base 1/1/1900)';
                     fmt_new = 'spreadsheet serial date';
                  else
                     Iunits = find(fmt == [unit_lookup{:,1}]);
                     if ~isempty(Iunits)
                        units = unit_lookup{Iunits(1),2};
                        fmt_new = units;
                     end
                  end
               else  %string
                  units = fmt;
                  fmt_new = fmt;
               end
               
               %update descstr if default from add_datecol.m is used
               if strcmpi('Fractional serial day (based on 1 = January 1, 0000)',descstr)
                  descstr = 'Calendar date and time of observation';
               end
               
               %check column units and descriptions for timezone references
               if ~isempty(descstr) || ~isempty(unitstr)
                  str = [unitstr,' ',descstr];  %form composite string for time zone searching
                  timezones = {'UTC','GMT','EST','EDT','CST','CDT','MST','MDT','PST','PDT'};
                  for cnt = 1:length(timezones)
                     if ~isempty(strfind(str,timezones{cnt}))
                        units = [units,' - ',timezones{cnt}];     %#ok<AGROW>
                        break
                     end
                  end
               end
               
               %delete existing column
               s2 = deletecols(s2,col);
               
               %add converted column
               s2 = addcol(s2,dt_new,s.name{col},units,descstr,dtype_new,'datetime',ntype_new,prec_new,'',col);               
               
            else
               badcols(n) = 1;
               msg_all{n} = ['errors occurred converting dates in column ',s.name{col}];
            end
            
         else
            badcols(n) = 1;
            msg_all{n} = ['unsupported variable type in column ',s.name{col}];
         end
         
      end
      
      %generate goodcols array, compress badcols and msg_all
      goodcols = badcols == 0;
      msg_all = msg_all(~cellfun('isempty',msg_all));

      if sum(goodcols) > 0
         
         %update structure
         s2.editdate = datestr(now);
         s2.history = [s.history ; ...
            {datestr(now),['converted dates in column(s) ',cell2commas(s.name(cols)),' to format ',fmt_new]}];
         
         if sum(badcols) > 0
            msg = cell2commas(msg_all);
         end
         
      else
         
         %return empty structure and error message
         s2 = [];
         msg = cell2commas(msg_all);
         
      end      
      
   else
      msg = 'invalid column selection';      
   end   
   
else
   msg = 'invalid data structure';
end
