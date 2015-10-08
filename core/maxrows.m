function data2 = maxrows(data,maxrow)
%Returns a maximum of 'maxrownum' rows from a GCE-LTER data structure 'data'
%
%syntax:  data2 = maxrows(data,maxrownum)
%
%input:
%  data = data structure to subset
%  maxrow = maximum number of rows to return
%
%output:
%  data2 = subset data structure
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
%last modified: 29-Jan-2001

data2 = [];

if nargin == 2

   if isstruct(data)

      if isfield(data,'values')

         vals = data.values;
         flags = data.flags;
         len = length(vals{1});

         for n = 1:length(data.values)
            v = vals{n};
            f = flags{n};
            vals{n} = v(1:min(len,maxrow));
            if ~isempty(f)
               flags{n} = f(1:min(len,maxrow),:);
            end
         end

         curdate = datestr(now);
         data2 = data;
         data2.editdate = curdate;
         data2.history = [data.history ; {curdate} {[int2str(maxrow) ' top rows extracted (''maxrows'')']}];
         data2.values = vals;
         data2.flags = flags;

      end

   end

end
