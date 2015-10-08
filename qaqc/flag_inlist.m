function Iflag = flag_inlist(vals,valuelist,caseopt)
%Returns an index of string values that are present in a specified list array or file-based list
%for performing quality control analysis of coded values or other textual data columns
%
%syntax: Iflag = flag_inlist(vals,valuelist,caseopt)
%
%inputs:
%  vals = cell array of string values or delimited character array to test (valid delimiters are
%    semicolons, commas, or spaces)
%  valuelist = list of dis-allowed values, either:
%    1) character array delimited with commas, semi-colons or spaces
%    2) cell array of strings
%    3) GCE data structure containing a value list column (i.e. filename|variable|column, 
%       e.g. 'plant_list.mat|data|Plant_Species')
%    4) standard MATLAB file containing a value list cell array (i.e. filename|variable)
%    (note: external files must be in the search path or fully-qualified pathnames must be used)
%  caseopt = check case option
%    'sensitive' = use case-sensitive matches (default)
%    'insensitive' = use non-case sensitive matches
%
%outputs:
%  Iflag = logical index of values *not* in the specified list
%
%
%(c)2008 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 23-Jul-2008

Iflag = [];

if nargin >= 2
   
   %set case check flag
   if exist('caseopt','var') ~= 1
      caseopt = 'sensitive';
   end
   
   Iflag = inlist(vals,valuelist,caseopt);
      
end