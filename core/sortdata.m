function [sdata,msg] = sortdata(data,cols,dirs,caseopt)
%Performs multi-column, bidirectional sorting on rows in a GCE Data Structure
%
%syntax:  [sdata,msg] = sortdata(data,cols,dirs,caseopt)
%
%inputs:
%  data = data structure to sort
%  cols = array of column numbers or column names to sort by
%  dirs = array of sort directions corresponding to 'cols' (scalar values will be replicated)
%     1 = ascending (default)
%     -1 = descending
%  caseopt = case-sensitive sort option for string columns
%     1 = case-sensitive (default)
%     0 = case-insensitive 
%
%outputs:
%  sdata = sorted data structure
%  msg = text of any error messages
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
%last modified: 21-Apr-2013

sdata = [];
msg = '';
cancel = 0;

if nargin >= 2

   %set default caseopt if omitted
   if exist('caseopt','var') ~= 1
      caseopt = 1;
   elseif caseopt ~= 0
      caseopt = 1;
   end

   %look up column indices from column names
   if ~isnumeric(cols)
      cols = name2col(data,cols);
   end

   %validate and replicate direction array if necessary
   if isempty(cols)
      cancel = 1;
      msg = 'invalid column selection';
   elseif exist('dirs','var') ~= 1
      dirs = ones(1,length(cols));  %default to ascending
   elseif length(dirs) == 1
      dirs = ones(1,length(cols)) .* dirs;  %replicate scalar direction
   elseif length(dirs) < length(cols)
      cancel = 1;
      msg = 'invalid array of sort directions';
   end

   %generate sort order lookup index before altering dirs
   sortindex = dirs;
   sortindex(sortindex == -1) = 2;

   if cancel == 0

      numcols = length(cols);

      %propagate descending sort orders through subsequent elements of dirs array
      %to prevent inadvertent reversals in cumulative sort index
      for n = 1:numcols-1
         dirs(n+1:numcols) = dirs(n+1:numcols) .* dirs(n);
      end

      %read cell array of values
      vals = data.values;

      %initialize master sort index unsorted index
      I_all = (1:length(vals{1}))';

      %process sort indices in reverse order
      for n = numcols:-1:1

         %read sort column
         x = vals{cols(n)};

         %create sort index after applying master index to data
         if ~iscell(x)
            [tmp,I] = sort(x(I_all));
         else  %convert cell array of strings to character matrix before sort
            if caseopt == 0
               x = char(lower(x));
            else
               x = char(x);
            end
            [tmp,I] = sortrows(x(I_all,:));
         end

         %check for descending sort - reverse index
         if dirs(n) == -1
            I = flipud(I);
         end

         %sort master index using new index
         I_all = I_all(I);

      end

      %apply master index to all data columns and flag columns
      flags = data.flags;
      for n = 1:length(vals)

         x = vals{n};
         vals(n) = {x(I_all)};

         f = flags{n};
         if ~isempty(f)
            flags(n) = {f(I_all,:)};
         end

      end

      %generate list of sorted columns and orders for history entry
      orderstr = [{'(ascending)'},{'(descending)'}];
      sortcols = [data.name{cols(1)},orderstr{sortindex(1)}];
      for n = 2:length(cols)
         sortcols = [sortcols,', ',[data.name{cols(n)},orderstr{sortindex(n)}]];
      end

      %update processing history
      curdate = datestr(now);
      sdata = data;  %copy input data to output structure
      sdata.editdate = curdate;
      if length(cols) > 1
         sdata.history = [data.history ; {curdate} {['sorted by columns ' sortcols ' (''sortdata'')']}];
      else
         sdata.history = [data.history ; {curdate} {['sorted by column ' sortcols ' (''sortdata'')']}];
      end
      
      sdata.values = vals;  %update data values
      sdata.flags = flags;  %update flags

   end

else
   msg = 'insufficient input arguments';
end


