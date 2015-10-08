function date_out = datecnv(dateval,opt)
%Converts numerical dates between various software conventions
%
%syntax:  date_out = datecnv(dateval,opt)
%
%inputs:
%  dateval = vector of numerical dates to be converted
%  opt = conversion option str:
%    'xl2mat' = MS Excel format (1/1/1900 = 1) to Matlab format
%             (1/1/0000 = 1) (Default)
%    'mat2xl' = Matlab format to Excel format
%
%outputs:
%  dateout = matching vector of converted dates
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
%last modified: 07-Nov-2000

if exist('dateval','var') ~= 1
   dateval = 0;
elseif isempty(dateval)
   dateval = NaN;
end

if exist('opt','var') ~= 1
   opt = 'xl2mat';
end

offset = ones(length(dateval),1) .* (datenum('1-Jan-1900')-2);

switch opt

case 'xl2mat'  %convert MS Excel dates to Matlab dates

   date_out = dateval(:) + offset;

case 'mat2xl'  %convert Matlab dates to MS Excel dates

   date_out = dateval(:) - offset;

otherwise

   date_out = [];

end

