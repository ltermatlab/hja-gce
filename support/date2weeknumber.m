function [week,year] = date2weeknumber(dt,standard)
%Calculates week numbers for an array of serial dates according to various calendar standards
%
%syntax: [week,year] = date2weeknumber(dt,standard)
%
%input:
%  dt = array of MATLAB serial dates (from datenum)
%  standard = week number standard
%    'simple' = simple week numbering (week 1 begins on January 1, week 2 begins on January 8)
%    'US' = US standard week numbering (week 1 is first calendar week, subsequent weeks start on Sunday - default)
%    'ISO' = ISO 8601 week numbering (week 1 is first calendar week containing a Thursday, subsequent weeks start on Monday)
%
%output:
%  week = array of week numbers
%  year = corresponding array of years (same as calendar year for 'simple' and 'US', adjusted year for 'ISO')
%
%(c)2009 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 17-Jun-2009

week = [];
year = [];

if nargin >= 1
   
   %try to convert text dates to numeric
   if ~isnumeric(dt)
      try
         dt = datenum(dt);
      catch
         try
            dt = datenum_iso(dt);
         catch
            dt = [];
         end
      end
   end
   
   %check for valid numeric date array
   if ~isempty(dt)
      
      %set default standard if omitted, else convert to upper case
      if exist('standard','var') ~= 1
         standard = 'US';
      else
         standard = upper(standard);
      end
      
      %calculate weeks, years based on standard
      switch standard
         
         case 'US'
            
            [year,mo,dy] = datevec(dt);
            
            week = 1 + floor((dt-(datenum(year,1,2) - date2weekday(datenum(year,1,1))))/7);
            
         case 'ISO'
            
            [year,mo,dy] = datevec(dt + 4 - date2weekday(dt+6));

            week = 1 + floor((dt - datenum(year,1,5) + date2weekday(datenum(year,1,3)))/7);
            
         case 'SIMPLE'
            
            [year,mo,dy] = datevec(dt);
            
            week = floor((dt-datenum(year,1,1))/7) + 1;
            
      end
      
   end
   
end