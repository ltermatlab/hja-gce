function x2 = roundsig(x,sigdig,method)
%Rounds numbers to the indicated significant digits using the method specified
%
%syntax: x2 = roundsig(x,sigdig,method)
%
%input:
%  x = numerical value, array or matrix to round
%  sigdig = number of significant digits
%  method = function to use to set precision:
%    'round' (default)
%    'ceil'
%    'floor'
%    'fix'
%
%output:
%  x2 = modified value, array or matrix
%
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
%last modified: 29-Mar-2013

x2 = [];

%check for required arguments
if nargin >= 2

   %check for positive integer
   if sigdig > 0 && fix(sigdig) == sigdig

      if exist('method','var') ~= 1
         method = 'round';
      end

      switch method
      case 'ceil'
         fnc = 'ceil';
      case 'floor'
         fnc = 'floor';
      case 'fix'
         fnc = 'fix';
      otherwise
         fnc = 'round';
      end

      try

         Izero = find(x==0);  %get index of elements == 0
         x(Izero) = NaN;  %replace with NaNs to avoid log errors

         %perform rounding/truncation using base10 log approach
         x2 = feval(fnc,x .* 10.^(sigdig - ceil(log10(abs(x))))) ./ 10.^(sigdig - ceil(log10(abs(x))));

         x2(Izero) = 0;  %restore zeros

      catch

         x2 = [];
         warning('Errors occurred rounding the data - operation cancelled')

      end

   else
      warning('Significant digits must be a positive integer');
   end

else
   warning('Insufficient inputs for function (type ''help roundsig'' for details)');
end
