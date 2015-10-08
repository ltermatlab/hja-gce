function Iflag = flag_inarray(vals,valuearray,tolerance)
%Returns an index of numeric values that are present in a specified array
%for performing quality control analysis of coded numeric values
%
%syntax: Iflag = flag_inarray(vals,valuearray,tolerance)
%
%inputs:
%  vals = numeric array of values to check
%  valuearray = array of allowed values
%  tolerance = tolerance for numeric comparisons (default = eps)
%
%outputs:
%  Iflag = logical index of values *in* the specified list
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
%last modified: 11-Nov-2010

Iflag = [];

if nargin >= 2
   
   if isnumeric(vals) && isnumeric(valuearray) && ~isempty(vals) && ~isempty(valuearray)
      
      %supply default tolerance if omitted
      if exist('tolerance','var') ~= 1 || ~isnumeric(tolerance)
         tolerance = eps;
      end
      
      %get index of values in array
      Iflag = inarray(vals,valuearray,tolerance);
            
   end
   
end