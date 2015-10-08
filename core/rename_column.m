function [s2,msg] = rename_column(s,col,col_name,col_desc,silent)
%Updates the name of a column in a GCE Data Structure, propagating the change
%to any dependent Q/C flagging expressions.
%
%syntax: [s2,msg] = rename_column(s,column,column_name,column_description,silent)
%
%intput:
%  s = structure to update
%  column = name or number of column to update
%  column_name = new column name
%  column_description = new column description (default = original description)
%  silent = option to perform the change without updating the data structure
%      processing history
%    0 = no (default)
%    1 = yes
%
%output:
%  s2 = updated structure (or original structure if specified column not present)
%  msg = text of any error message
%
%
%(c)2002-2006 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 25-Jan-2007

s2 = [];
msg = '';

if nargin >= 3
   
   s2 = s;  %assign original structure to output to support blind scripting failover

   col_name = trimstr(col_name);
   
   if exist('silent','var') ~= 1
      silent = 0;
   end
   
   if ~isnumeric(col)
      col = name2col(s,col);
   end

   if gce_valid(s,'data') && ~isempty(col) && ~isempty(col_name)

      if exist('col_desc','var') ~= 1
         col_desc = '';
      end
      if isempty(col_desc)
         col_desc = s.description{col(1)};
      end
      
      col_orig = s.name{col(1)};
      
      %update all columns matching the name or index number
      [s2.name(col)] = deal({col_name});
      [s2.description(col)] = deal({col_desc});
      
      for n = 1:length(s2.criteria)
         crit = s2.criteria{n};
         if ~isempty(crit)
            crit = strrep(crit,col_orig,col_name);
            s2.criteria{n} = crit;
         end
      end
      
      if silent == 0
         s2.history = [s.history ; {datestr(now)}, ...
               {['renamed column ''',col_orig,''' to ''',col_name, ...
                     ''' and propagated the change to any dependent Q/C flag criteria (''rename_column'')']}];
      end

   else
      
      if isempty(col)
         msg = 'invalid column name';
      elseif isempty(col_name)
         msg = 'new column name cannot be an empty string';
      else
         msg = 'invalid data structure';
      end
      
   end
   
else
   msg = 'insufficient arguments';
end