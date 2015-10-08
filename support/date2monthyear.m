function str = date2monthyear(dt)
%Converts a MATLAB serial date to Month-Year format (e.g. January 2004)
%
%syntax: str = date2monthyear(d)
%
%input:
%  d = MATLAB serial date
%
%output:
%  str = character array of month year
%
%
%(c)2002-2006 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 14-Sep-2004

str = '';
mo = datestr(dt,3);
yr = datestr(dt,10);

switch(mo)
   case 'Jan'
      str = 'January';
   case 'Feb'
      str = 'February';
   case 'Mar'
      str = 'March';
   case 'Apr'
      str = 'April';
   case 'May'
      str = 'May';
   case 'Jun'
      str = 'June';
   case 'Jul'
      str = 'July';
   case 'Aug'
      str = 'August';
   case 'Sep'
      str = 'September';
   case 'Oct'
      str = 'October';
   case 'Nov'
      str = 'November';
   case 'Dec'
      str = 'December';
   otherwise
      str = '';
end

str = [str,' ',yr];
