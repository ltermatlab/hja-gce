function d = yearday2date(yearday,year,offset)
%Converts Julian Day/Year Day to a MATLAB serial date
%
%syntax: d = yearday2date(yearday,year,offset)
%
%inputs:
%  yearday = Julian Day (number or numeric array; required; year day in fractional days)
%  year = calendar year (number or numeric array; optional; default = current year)
%  offset = Julian Day offset for 01-Jan, in days (number; optional; default = 1 so yearday = 0
%     equates to midnight 01-Jan of the specified year)
%
%outputs:
%  d = serial MATLAB date
%
%notes:
%  1) if yearday is an array, year must be a matching size array or scalar number
%     that will be replicated for all values in yearday
%
%(c)2002-2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 17-Sep-2014

%init output
d = [];

if nargin >= 1 && isnumeric(yearday)
   
   %check for offset
   if exist('offset','var') ~= 1 || isempty(offset) || ~isnumeric(offset)
      offset = 1;
   end

   %force column arrangement of yearday
   yearday = yearday(:);
   
   %check for missing year, use current
   if exist('year','var') ~= 1
      dvec = datevec(now);
      year = dvec(1);
   end

   if isnumeric(year)
      
      %check for single year, replicate to match yearday
      if length(year) == 1 && length(yearday) > 1
         year = repmat(year,length(yearday),1);
      end
      
      %check for array size match
      if length(year) == length(yearday)
         
         %generate serial date
         d = datenum(year,0,yearday+offset);
         
      end
      
   end

end
