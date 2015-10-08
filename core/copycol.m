function [s2,msg] = copycol(s,col,colname)
%Copies and renames a single column in a GCE Data Structure
%
%syntax:  [s2,msg] = copycol(s,col,colname)
%
%inputs:
%   s = original data structure
%   col = name or index of column to copy
%   colname = name to assign to copied column (default = '[colname]_copy')
%
%outputs:
%   s2 = updated data structure
%   msg = text of error messages
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
%last modified: 21-Aug-2013

%initialize outputs
s2 = [];

if nargin >= 2 && ~isempty(col)
   
   if gce_valid(s,'data')
      
      %validate col
      if ~isnumeric(col)
         col = name2col(s,col);
      elseif length(col) ~= 1 || isempty(intersect(col,(1:length(s.name))))
         col = [];
      end
      
      %check for valid column
      if length(col) == 1
         
         %check for empty colname, supply default
         if exist('colname','var') ~= 1
            colname = '';
         end         
         if isempty(colname)
            colname = [s(col).name,'_copy'];
         end
         
         %get total number of columns
         numcols = length(s.name);
         
         %generate cols array, duplicating index
         if col > 1
            if col < numcols
               cols = [1:col,col,col+1:numcols];
            else  %last
               cols = [1:numcols,numcols];
            end
         else  %first
            cols = [1,1,2:numcols];
         end
         
         %create output structure with duplicated column
         [s2,msg] = copycols(s, ...
            cols, ...  %array of columns to copy, duplicating Date
            'Y', ...   %retain metadata
            'Y' ...    %skip validation
            );
         
         %rename column
         s2 = rename_column(s2,col+1,colname);
         
      else
         msg = 'invalid column selection';
      end
      
   else
      msg = 'invalid data structure';
   end
   
else
   msg = 'insufficient arguments';
end
