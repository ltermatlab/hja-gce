function [vals,flags,cols_returned,msg] = extract_rows(data,cols,rowindex)
%Extracts selected rows from columns in a GCE-LTER data structure as numeric or cell arrays of strings
%
%syntax:  [vals,flags,cols_returned,msg] = extract_rows(data,cols,rowindex)
%
%inputs:
%  data = source data structure
%  cols = an array of column names or position indices (note: invalid selections will be omitted)
%  rowindex = array of rows to extract (can only include valid rows, although duplicates 
%        are allowed to produce multiple copies of specific records)
%
%outputs:
%  vals = a numeric array or cell array of strings containing values from cols
%  flags = character array (1 column) or cell array of strings (> 1 column) containing Q/C flags for values in cols
%  cols_returned = array of column indices returned (reflecting removal of invalid selections in 'cols')
%  msg = text of any error messages
%
%Usage notes:
%
%  1) If multiple data columns are specified in 'cols' and one or more columns are string type
%     (i.e. text), a cell array will be returned containing each individual array in its own cell;
%     otherwise, a numeric matrix will be returned with each data set column as a matrix column.
%
%  For example:
%
%   statement: vals = extract_rows(s,{'NESDIS_ID','Temp_Air','Precipitation'},(1:10)) -- where NESDIS_ID is text
%     returns: 
%         vals =
%            {10x1 cell}    [10x1 double]    [10x1 double]
%
%   statement: vals = extract_rows(s,{'Temp_Air','Precipitation'},(7:10)) -- where Temp_Air and Precipitation 
%      are numeric returns: 
%         vals =
%            16.9778         0
%            17.0000         0
%            17.0111         0
%            17.2389         0
%
%  2) Column selections can be repeated and listed in any order to duplicate and re-order data columns
%     in the 'values' array (e.g. values = extract(data,[1,3,5,5,5,2]))
%
%  3) Empty flag arrays will be expanded to match the length of the value arrays
%
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
%last modified: 21-Mar-2013

%init output
vals = [];
cols_returned = [];
msg = '';
flags = [];

%check for required arguments
if nargin >= 2
   
   %check for valid data structure
   if gce_valid(data,'data')
      
      %set default for missing maxrows argument
      if exist('rowindex','var') ~= 1
         rowindex = [];  %default to all rows
      end
      
      %apply row index
      if ~isempty(rowindex)
         [data,msg] = copyrows(data,rowindex,'Y');
      end
      
      if ~isempty(data)
         
         %extract data
         [vals,flags,cols_returned,msg] = extract(data,cols,0);
         
      end
      
   end
   
end