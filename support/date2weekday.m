function wd = date2weekday(dt,firstday)
%Calculates numerical week day for any date, based on a specified first day of the week
%
%syntax: wd = date2weekday(dt)
%
%inputs:
%  dt = numerical MATLAB date (base Jan 1 0000) or date string recognized by 'datenum'
%     (default = current date/time if omitted)
%  firstday = first day of the week (default = 'Sun')
%
%outputs:
%  wd = numerical day of the week (1-7), with 1 based on firstday option
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
%last modified: 19-Feb-2009

wd = [];

%set default date if omitted, or calculate numeric date from string date
if nargin == 0
   dt = now;
elseif ~isnumeric(dt)
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

if exist('firstday','var') ~= 1
   firstday = 'Sun';
end

if ~isempty(dt)

   %init output array
   wd = repmat(NaN,length(dt),1);
   
   %generate string day number
   dstr = datestr(dt,8);
   
   %init array of week days
   daystr = {'Sun','Mon','Tue','Wed','Thu','Fri','Sat'};
   
   %look up index of first day
   Ifirstday = find(strcmpi(daystr,firstday));
   
   %generate numeric indices of weekdays based on first day
   if isempty(Ifirstday)
      Ifirstday = 1;  %default to Sun if not matched
   end
   if Ifirstday == 1
      daylist = 1:7;
   elseif Ifirstday < 7
      daylist = [Ifirstday:7,1:Ifirstday-1];
   else
      daylist = [7,1:6];
   end
   
   %loop through weekdays, substituting numeric day for string based on character array position matches
   for n = 1:length(daylist)
      str = daystr{daylist(n)};
      Imatch = find(dstr(:,1)==str(1) & dstr(:,2)==str(2) & dstr(:,3)==str(3));
      if ~isempty(Imatch)
         wd(Imatch) = n;
      end
   end
   
end