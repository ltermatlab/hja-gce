function [s2,msg] = copyrows(s,rowindex,metadata)
%Copies data from one or more rows in a GCE-LTER data structure to form a new data structure or array
%(can also be used to duplicate, reorder, or remove rows, e.g. if structure s contains 100 rows,
%'copyrows(s,[1:50,100:-1:51])' will produce a new structure with rows 51-100 in reverse order).
%
%syntax:  [s2,msg] = copyrows(s,rows,metadata)
%
%input:
%   s = original data structure
%   rowindex = array of rows to copy (can only include valid rows, although duplicates 
%       are allowed to produce multiple copies of existing records)
%   metadata = option to return a complete data structure with metadata or just extract value arrays
%      'Y' = yes (default)
%      'N' = no (i.e. only return a data matrix containing the specified columns - see extract.m)
%
%output:
%   s2 = the resultant data structure ('metadata' = 'Y') or array of data
%      values ('metadata' = 'N') (note: if any requested fields are type 's' then
%      's2' will be a cell array, otherwise a numerical array will be returned)
%   msg = text of any error messages
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
%last modified: 21-Mar-2013

%initialize output
s2 = [];
msg = '';

%check for required arguments
if nargin >= 2
   
   %validate data structure
   if gce_valid(s,'data')
      
      %use default metadata option if omitted
      if exist('metadata','var') ~= 1
         metadata = '';
      end
      if isempty(metadata)
         metadata = 'Y';
      elseif strcmpi(metadata,'N') ~= 1
         metadata = 'Y';
      end
      
      %get value array from structure
      vals = s.values;
      nrows = length(vals{1});
      
      %remove invalid record indices, update total
      Ivalid = find(rowindex >= 1 & rowindex <= nrows);
      if ~isempty(Ivalid)
         rowindex = rowindex(Ivalid);
      else
         rowindex = [];
      end
      
      %check for valid row index
      if ~isempty(rowindex)
         
         %get flags array
         flags = s.flags;
         cancel = 0;
         
         try
            
            %loop through columns
            for n = 1:length(vals)
            
               %get value and flag arrays
               valarray = vals{n};
               flagarray = flags{n};
               
               %apply index to vals
               vals{n} = valarray(rowindex);
               
               %apply index to flags
               if ~isempty(flagarray)
                  flags{n} = flagarray(rowindex,:);
                  if isempty(find(flagarray(rowindex,:)~=' '))  %check for no remaining flags after subselect
                     flags{n} = '';  %clear flags
                  end
               end
               
            end
            
         catch
            cancel = 1;
         end
         
         %check for runtime error
         if cancel == 0
            
            %copy structure
            s2 = s;

            %check for metadata option
            if strcmpi(metadata,'Y')
               
               %generate history entry
               ninc = length(rowindex);
               if length(rowindex) < length(s.values{1})
                  str = ['extracted ',int2str(ninc),' of ',int2str(nrows),' rows from the structure '];
               else
                  str = 'reordered rows in the structure based on a user-supplied index';
               end
               
               %finalize structure
               curdate = datestr(now);
               s2.history = [s.history ; {curdate} {[str,' (''copyrows'')']}];
               s2.editdate = curdate;
               s2.values = vals;
               s2.flags = flags;
               
            else               
               s2 = extract(s2,(1:length(s2.name)));               
            end
            
         else
            msg = 'errors occurred deleting the specified rows and corresponding flags';
         end
         
      else
         msg = 'invalid row selection';
      end
      
   else
      msg = 'invalid data structure';
   end
   
else
   msg = 'insufficient arguments for function';
end