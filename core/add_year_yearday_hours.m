function [s2,msg] = add_year_yearday_hours(s,datecol,position)
%Adds Year, YearDay and Hours columns to a GCE Data Structure, calculated from existing date/time columns
%
%syntax: [s2,msg] = add_year_yearday_hours(s,datecol,position)
%
%inputs:
%  s = GCE Data Structure
%  datecol = name or number of serial date column (datatype 'f' or 's',
%     variabletype 'datetime')
%  position = optional position for insertion of the columns (0 = beginning,
%    after date/time columns if omitted)
%
%outputs:
%  s2 = output structure with inserted columns;
%  msg = text of any error message
%
%notes:
%  1) any existing Year, YearDay or Hours columns will be overwritten
%  2) serial dates are calculated using 'get_studydates' from existing date/time columns
%     if datecol is omitted
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
%last modified: 06-Mar-2013

%init output
s2 = [];
msg = '';

if nargin >= 1 && gce_valid(s,'data')
   
   %check for omitted datecol
   if exist('datecol','var') ~= 1
      datecol = [];
   elseif ~isnumeric(datecol)
      datecol = name2col(s,datecol);
   end
   
   %check for omitted position
   if exist('position','var') ~= 1
      position = [];
   end
   
   %call external function to return serial dates for records, including matched datecol column index
   [d,msg0,s_temp,datecol] = get_studydates(s,datecol);   
   
   if ~isempty(d)
      
      %get index of valid dates
      Ivalid = find(~isnan(d));
      
      %check for valid dates to convert
      if ~isempty(Ivalid)
         
         %check for base 1900 dates
         if log10(d(Ivalid(1))) < 5
            d(Ivalid) = datecnv(d(Ivalid),'xl2mat');
         end
         
         %calculate date components
         try
            [yr,mo,dy,hr,mn,sc] = datevec(d);
            hr = hr + mn./60 + sc./360;  %convert hour, minute, seconds to decimal hours
         catch
            yr = [];
            hr = [];
         end
         
         %calculate year day
         if ~isempty(yr)
            yeardays = date2yearday(d,'fix');
         end
         
         if ~isempty(yr) && ~isempty(hr) && ~isempty(yeardays)
            
            %check for existing Year, YearDay and Hours column and delete
            yearcol = name2col(s,'Year');  %cache position of Year column if present
            s2 = deletecols(s,{'Year','YearDay','Hours'});
            
            %set default position if omitted
            if isempty(position)
               if ~isempty(datecol)
                  position = datecol + 1;
               elseif ~isempty(yearcol)
                  position = yearcol;  %use existing Year column position
               elseif ~isempty(datecol)
                  position = datecol + 1;  %use provided date column for position
               else
                  dcol = name2col(s,'Date');
                  if ~isempty(dcol)
                     position = dcol + 1;  %check for date column
                  else
                     position = 1;  %default to first column
                  end
               end
            end
                        
            %add columns in reverse order            
            s2 = addcol(s2,hr, ...
               'Hours', ...
               'hours', ...
               'Time of day in fractional hours', ...
               'f', ...
               'datetime', ...
               'continuous', ...
               4, ...
               'x<0=''I'';x>24=''I''', ...
               position);
            
            s2 = addcol(s2,yeardays, ...
               'YearDay', ...
               'day', ...
               'Numerical year day (day number within the current year)', ...
               'd', ...
               'datetime', ...
               'discrete', ...
               0, ...
               'x<1=''I'';x>366=''I''', ...
               position);
            
            s2 = addcol(s2,yr, ...
               'Year', ...
               'YYYY', ...
               'Calendar year', ...
               'd', ...
               'datetime', ...
               'discrete', ...
               0, ...
               '', ...
               position);
            
            %update history entry
            if ~isempty(s2)
               
               %generate history entry
               if ~isempty(yearcol)
                  histstr = 'updated Year, YearDay and Hours columns calculated from date/time information in the data structure (''add_year_yearday_hours'')';
               else
                  histstr = 'added calculated Year, YearDay and Hours columns based on date/time information in the data structure (''add_year_yearday_hours'')';
               end
               
               %add entry to original history to replace addcol entries with a more specific entry
               s2.history = [s.history ; {datestr(now),histstr}];
               
            else
               msg = 'an error occurred adding the Year, YearDay and Hours columns';
            end
            
         else
            msg = 'an error occurred calculating Year, YearDay and Hours columns from existing date/time columns';
         end
         
      else
         msg = 'no valid date/time values are present in the structure';
      end
      
   else
      msg = 'date column is invalid or could not be identified';
   end
   
else
   
   if nargin == 0
      msg = 'insufficient input arguments for function';
   else
      msg = 'invalid GCE Data Structure';
   end
   
end