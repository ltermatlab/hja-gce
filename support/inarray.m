function Imatch = inarray(vals,valuearray,tolerance)
%Matches values in an array to elements in a specified list of values and returns a logical index
%
%syntax: Imatch = inarray(vals,valuearray,tolerance)
%
%inputs:
%  vals = numeric array of values to check
%  valuearray = array of allowed values
%  tolerance = tolerance for numeric comparisons (default = eps)
%
%outputs:
%  Imatch = logical index of values in the specified list
%
%
%(c)2010 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 12-Nov-2010

Imatch = [];

if nargin >= 2
   
   if isnumeric(vals) && isnumeric(valuearray) && ~isempty(vals) && ~isempty(valuearray)
      
      %remove duplicates from valuearray
      valuearray = unique(valuearray);
      
      %supply default tolerance if omitted
      if exist('tolerance','var') ~= 1 || ~isnumeric(tolerance)
         tolerance = eps;
      end
      
      %init match index
      Imatch = zeros(length(vals),1);
      
      %loop through value index updating flags
      for n = 1:length(valuearray)
         testval = valuearray(n);  %get test value
         Irem = find(Imatch == 0);  %get index of unflagged values
         if ~isempty(Irem)
            Igood = find(vals(Irem) >= testval-tolerance & vals(Irem) <= testval+tolerance);
            if ~isempty(Igood)
               Imatch(Irem(Igood)) = 1;
            end
         else
            break  %all values matched - break out of loop
         end
      end
      
      %convert to logical array
      Imatch = Imatch == 1;
      
   end

end