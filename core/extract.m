function [vals,flags,cols_returned,msg] = extract(data,cols,maxrows)
%Extracts columns from a GCE-LTER data structure and returns standard numeric or cell arrays of strings
%
%syntax:  [vals,flags,cols_returned,msg] = extract(data,cols,maxrows)
%
%inputs:
%  data = source data structure
%  cols = an array of column names or position indices (note: invalid selections will be omitted)
%  maxrows = the maximum number of data rows to return
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
%   statement: vals = extract(s,{'NESDIS_ID','Temp_Air','Precipitation'}) -- where NESDIS_ID is text
%     returns: vals =
%            {640x1 cell}    [640x1 double]    [640x1 double]
%
%   statement: vals = extract(s,{'Temp_Air','Precipitation'}) -- where Temp_Air and Precipitation are numeric
%      returns: vals =
%            16.9778         0
%            17.0000         0
%            17.0111         0
%            17.2389         0
%            ...             ...
%
%  2) Column selections can be repeated and listed in any order to duplicate and re-order data columns
%     in the 'values' array (e.g. values = extract(data,[1,3,5,5,5,2]))
%
%  3) Empty flag arrays will be expanded to match the length of the value arrays
%
%
%(c)2002-2012 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 25-Jul-2012

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
      if exist('maxrows','var') ~= 1
         maxrows = 0;  %default to all rows
      end
      
      %validate column selections
      if ~isnumeric(cols)
         cols_returned = name2col(data,cols); %resolve by name (only returns valid columns)
      else
         badcols = setdiff(cols,(1:length(data.values)));  %check for invalid columns
         if ~isempty(badcols)
            for n = 1:length(badcols)
               %set all invalid column references to NaN, preserving original order and duplication
               cols(cols==badcols(n)) = NaN;
            end
            cols_returned = cols(~isnan(cols));  %remove bad columns
         else
            cols_returned = cols;
         end
      end
      
      %check for valid column selection
      if ~isempty(cols_returned)
         
         %extract arrays
         if length(cols_returned) == 1
            vals = data.values{cols_returned};  %extract single column
         else
            %use copycols to extract multiple columns with no metadata option
            vals = copycols(data,cols_returned,'N');
         end
         
         %determine number of rows
         if iscell(vals)
            rows = length(vals{1});  %get number of rows from first data column
         else
            rows = size(vals,1);
         end
         
         %extract flags
         flags = data.flags(cols_returned);
         
         %expand empty flag arrays to match value arrays
         Inull = find(cellfun('isempty',flags));
         if ~isempty(Inull)
            [flags(Inull)] = cellstr(repmat('',rows,1));
         end
         
         %check for single column extraction
         if length(cols_returned) == 1
            flags = char(flags);
         end
         
         %limit rows returned if maxrows specified and < rows
         if ~isempty(vals) && maxrows > 0 && maxrows < rows
            
            %calculate number of columns
            numcols = length(cols_returned);

            %filter based on array type, size
            if ~iscell(vals) %numeric array
               vals = vals(1:maxrows,:);  %limit dimensions using row/col indices
            else  %cell array
               if numcols == 1
                  %limit rows in single column
                  vals = vals(1:maxrows);
               else
                  %loop through columns limiting rows
                  for n = 1:numcols
                     vals{n} = vals{n}(1:maxrows);
                  end
               end
            end
            
            %filter flag records
            if numcols == 1
               flags = flags(1:maxrows,:);  %character array
            else
               for n = 1:numcols
                  flags{n} = flags{n}(1:maxrows,:);
               end
            end
            
         end
         
      else
         msg = 'invalid column selections';
      end
      
   end
   
end