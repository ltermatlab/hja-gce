function ad = angleavg(d,units,zerotol)
%Calculates an average for angular data using a unit vector approach based on the formula:
%   ad = atan2(mean(sin(d)),mean(cos(d)))
%
%syntax:  ad = angleavg(d,units,zerotol)
%
%inputs:
%   d = vector of directional angles
%   units = angular units (first 3 characters matched):
%      'deg' = degrees (default)
%      'rad' = radians
%      'grad' = grads
%   zerotol = zero tolerance for floating-point math (default = 1e-6)
%
%outputs:
%   ad = average direction
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
%last modified: 05-Jul-2002

ad = [];

if nargin >= 1

   if exist('zerotol','var') ~= 1
      zerotol = 1e-6;
   end

   if exist('units','var') ~= 1
      units = 'deg';
   elseif ~ischar(units)
      units = 'deg';
   else
      units = [units,'   '];  %pad string to avoid array addressing errors if < 3 chars
   end

   units = units(1:3);

   %convert units to radians
   switch units
   case 'deg'  %degrees
      d = d(:) .* pi/180;
   case 'gra'  %grads
      d = d(:) .* pi/200;
   case 'rad'  %radians
      d = d(:) %no conversion
   otherwise  %unsupported
      d = [];
   end

   if ~isempty(d)

      %compute vector component average
      ad = atan2(mean(sin(d)),mean(cos(d)));

      %convert result to native units
      switch units
      case 'deg'
         ad = ad .* 180/pi;
         if ad < 0
            ad = ad + 360;
         end
      case 'grad'
         ad = ad .* 200/pi;
         if ad < 0
            ad = ad + 400;
         end
      end

      %apply zero tolerance threshhold
      if abs(ad) < zerotol
         ad = 0;
      end

   else

      ad = NaN;  %unsupported option - return NaN

   end

end

