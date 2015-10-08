function str = csi_integer2time(val,fmt)
%Converts Campbell Scientific Instruments min/max times in hhmm integer format to hh:mm string format
%
%syntax: str = csi_time2integer(val,fmt)
%
%inputs:
%  val = numeric array of times in hhmm integer format
%  fmt = time format:
%    'hh:mm'
%    'hh:mm:ss' - default
%    'hh:mm PM'
%    'hh:mm:ss PM'
%    
%outputs:
%  str = character array with times in hh:mm format
%
%(c)2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 27-Oct-2014

%init output
str = '';

%validate input
if nargin >= 1 && ~isempty(val) && isnumeric(val)
   
   %validate time format
   if exist('fmt','var') ~= 1 || isempty(fmt)
      fmt = 'hh:mm:ss';
   else
      if ~inlist({fmt},{'hh:mm','hh:mm PM','hh:mm:ss PM'},'insensitive')
         fmt = 'hh:mm:ss';
      end
   end
   fmt = upper(fmt);
   
   %calculate hours
   h = fix(val./100);
   
   %calculate minutes
   m = val - h.*100;

   %generate array of zeros for other date/time components
   tmp = zeros(length(h),1);

   %calculate numeric date
   dt = datenum(tmp,tmp,tmp,h,m,tmp);
   
   %generate hh:mm
   str = datestr(dt,fmt);

end