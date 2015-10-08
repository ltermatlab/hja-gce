function str2 = clean_str(str)
%Converts a single or multi-line character array to a string with all insignificant whitespace removed
%
%syntax:  str2 = clean_str(str)
%
%input:
%  str = multi-line character array
%
%output:
%  str2 = single-row character array
%
%(c)2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 03-Jun-2013

str2 = '';

%check for required input
if nargin == 1 && ischar(str)
   
   %check for multi-line array
   if size(str,1) > 1
      
      %convert to trimmed cell array and concatenate
      c = concatcellcols(cellstr(str)',' ');
      
      %convert to string, removing insignificant whitespace
      str2 = char(regexprep(c,'\s*',' '));
      
   else
      
      %single-line array - just remove insignificant whitespace
      str2 = regexprep(str,'\s*',' ');
      
   end
   
end
   
   

