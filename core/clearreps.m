function s2 = clearreps(s,cols)
%Replaces repeated values in the selected columns of a GCE-LTER data structure
%with NaN, allowing values in sorting or aggregating columns to be cleared
%during export.
%
%syntax:  s2 = clearreps(s,cols)
%
%WARNING: This function is only intended for creating temporary structures -
%this operation irrevocably removes data from the selected columns, which will
%render the data set invalid if future sorting or aggregating is done.
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
%last modified: 4-Feb-2001

s2 = [];

if nargin == 2

   if gce_valid(s,'data')

      data = s.values;
      flags = s.flags;

      if iscell(cols) | isstr(cols)
         cols = name2col(s,cols);
      end

      for n = 1:length(cols)

         x = data{n};
         f = flags{n};
         len = length(x);

         I = find([0 ; x(1:len-1)==x(2:len)]);

         if ~isempty(I)  %apply index to clear values, flags
            x(I) = NaN;
            data{n} = x;
            if ~isempty(f)
               f(I,:) = repmat(' ',length(I),size(f,2));
               flags{n} = f;
            end
         end

      end

      %build string of column numbers for history entry
      colstr = int2str(cols(1));
      for n = 2:length(cols)
         colstr = [colstr ', ' int2str(cols(n))];
      end

      s2 = s;
      curdate = datestr(now);

      s2.values = data;
      s2.flags = flags;
      s2.editdata = curdate;
      s2.history = [s.history ; ...
            {curdate},{['cleared repeated values in columns ',colstr,' (clearreps)']}];

   end

end
