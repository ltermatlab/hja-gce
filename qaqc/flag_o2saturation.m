function Iflag = flag_o2saturation(o2_conc,temp,sal,maxsat,minsat,units)
%Returns an index of dissolved oxygen concentration values that are above or below specified saturation limits
%at the respective temperature and salinity values based on the function 'o2_saturation'
%
%syntax: Iflag = flag_o2saturation(o2_conc,temp,sal,maxsat,minsat,units)
%
%inputs:
%  o2_conc = oxygen concentration in units specified by 'units' (default mg/L)
%  temp = water temperature in °C
%  sal = salinity in PSU
%  maxsat = maximum saturation limit in % (sat > maxsat return 1, sat <= maxsat return 0)
%    (default = 100 if omitted)
%  minsat = minimum saturation limit in % (sat < minsat return 1, sat >= minsat return 0)
%    (default = 0 if omitted)
%  units = units of o2_conc
%    'mg/L' (default)
%    'ppm'
%    'ml/L'
%
%outputs:
%  Iflag = logical index of values outside of the range: mean-lowlimit/100 < value > mean+highlimit/100
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
%last modified: 16-Nov-2005

Iflag = [];

if nargin >= 3

   if exist('maxsat','var') ~= 1
      maxsat = 100;
   end

   if exist('minsat','var') ~= 1
      minsat = 0;
   end

   if exist('units','var') ~= 1
       units = 'mg/L';
   end

   if length(maxsat) == 1

      sat = o2_saturation(o2_conc,temp,sal,units);

      if ~isempty(sat)

         Ibad = (sat < minsat) + (sat > maxsat);  %create composite index of sat<minsat & sat>maxsat

         Iflag = Ibad > 0;  %build logical index

      end

   end

end