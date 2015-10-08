function [s2,msg] = copycols(s,cols,metadata,skip_validation)
%Copies data from one or more columns in a GCE Data Structure to form a new data structure or array
%
%syntax:  [s2,msg] = copycols(s,cols,return_meta,skip_validation)
%
%inputs:
%   s = original data structure
%   cols = array of column names or numbers to copy (invalid column selections will be removed,
%      but duplicates are allowed to produce multiple copies of columns)
%   return_meta = option to return a data structure with all metadata fields as output
%      'Y' = yes (default)
%      'N' = no (i.e. only return a data matrix containing the specified columns)
%   skip_validation = option to skip validation check, for example when re-ordering attribute metadata only
%      'Y' = yes
%      'N' = no (default)
%
%outputs:
%   s2 = the resultant data structure ('metadata' = 'Y') or array of data
%      values ('metadata' = 'N') (note: if any requested fields are type 's' then
%      's2' will be a cell array, otherwise a numerical array will be returned)
%   msg = text of error messages
%
%notes:
%  1) copycols() can also be used to duplicate, reorder, or remove columns (e.g. if s contains 4 columns, 
%    'copycols(s,[4:-1:2 4]) will produce a new 4-column structure containing columns 4,3,2,4 
%    with corresponding header entries).
%  2) unmatched column names or indices will be ignored
%
%
%(c)2002-2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 22-Aug-2014

%initialize outputs
s2 = [];
msg = '';

if nargin >= 2
   
   %set default for missing arguments
   if exist('skip_validation','var') ~= 1
      skip_validation = 'N';
   end
   
   if gce_valid(s,'data') || strcmpi(skip_validation,'Y') == 1
      
      %use default metadata option if omitted
      if exist('metadata','var') ~= 1
         metadata = '';
      end
      if isempty(metadata)
         metadata = 'Y';
      elseif strcmpi(metadata,'N') ~= 1
         metadata = 'Y';
      end
      
      %get column array from names, skipping any columns not present
      if ~isnumeric(cols)
         cols = name2col(s,cols);
      else
         Iunmatched = setdiff(cols,(1:length(s.name)));
         for n = 1:length(Iunmatched)
            %remove invalid columns but retain dupes, ordering
            cols = cols(cols~=Iunmatched(n));
         end
      end
      
      %check for valid columns
      if ~isempty(cols)
         
         %check for metadata option
         if strcmp(metadata,'Y')
            
            %get current date
            curdate = datestr(now);
            
            %init output structure
            s2 = s;
            
            %apply column index to select output columns
            s2.name = s.name(cols);
            s2.units = s.units(cols);
            s2.description = s.description(cols);
            s2.datatype = s.datatype(cols);
            s2.variabletype = s.variabletype(cols);
            s2.numbertype = s.numbertype(cols);
            s2.precision = s.precision(cols);
            s2.criteria = s.criteria(cols);
            s2.values = s.values(cols);
            s2.flags = s.flags(cols);
            
            %update processing history
            s2.editdate = curdate;
            s2.history = [s.history ; ...
                  {curdate} {['copied/reordered columns ',cell2commas(s.name(cols),1),' (''copycols'')']}];
            
         else  %data matrix only
            
            %extract arrays
            s2 = s.values(cols);
            
            %get index of text columns
            Istr = strcmp(s.datatype(cols),'s');
            if sum(Istr) == 0  
               %all numerical - convert to standard numeric array
               s2 = cat(2,s2{:});
            end
            
         end
         
      else
         msg = 'invalid column selection';
      end
      
   else
      msg = 'invalid data structure';
   end
   
else
   msg = 'insufficient arguments';
end
