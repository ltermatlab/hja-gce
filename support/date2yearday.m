function [yrday,yr] = date2yearday(d,roundopt)
%Calculates year day from a vector of MATLAB serial dates or cell array of valid date strings 
%(as generated by the 'datestr' function)
%
%syntax: [yearday,year] = date2yearday(d,roundopt)
%
%inputs:
%  d = dates to convert
%  roundopt = rounding option
%    '' = no rounding (default)
%    'round' = round to nearest integer
%    'fix' = fix/trucate
%    'floor' = round down towards minus inf
%    'ceil' = round up towards inf
%
%outputs:
%  yearday = year day (fractional days since January 1 00:00 of the same year)
%  year = calendar year
%
%(c)2002-2009 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 08-Jun-2009

yrday = [];
yr = [];

if nargin >= 1
   
   if exist('roundopt','var') ~= 1
      roundopt = '';  %default to no rounding
   end
   
   if ~isnumeric(d)
      try
         if iscell(d)
            d = char(d);  %convert to character array
         end
         d = datenum(d); %try to convert non-numeric input to serial dates
      catch
         d = [];
      end
   end
   
   if ~isempty(d) & isnumeric(d)
      
      d = d(:);  %force column orientation
      
      %calculate year day
      dvec = datevec(d);
      yr = dvec(:,1);
      daymo_vec = zeros(length(yr),1);
      yrday = d - datenum(yr,daymo_vec,daymo_vec);
      
      %handle rounding
      if ~isempty(roundopt)
         switch roundopt
            case 'round'
               yrday = round(yrday);
            case 'fix'
               yrday = fix(yrday);
            case 'floor'
               yrday = floor(yrday);
            case 'ceil'
               yrday = ceil(yrday);
         end
      end
      
   end
   
end