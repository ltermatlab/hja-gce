function copylines(h1,h2)
%Copies Matlab line objects from the current axis of one figure to another
%
%syntax: copylines(h1,h2)
%
%input:
%  h1 = handle of source figure
%  h2 = handle of destination figure
%
%
%(c)2004 by Wade Sheldon
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
%Department of Marine Sciences
%University of Georgia
%Athens, Georgia  30602-3636
%sheldon@uga.edu
%
%last modified: 31-May-2002

if nargin == 2

   figure(h1)

   h = findobj(gca,'type','line');

   if ~isempty(h)

      lines = cell(length(h),1);

      for n = 1:length(h)
         s = get(h(n));
         lines{n} = s;
      end

      figure(h2)

      for n = 1:length(lines)
         s = lines{n};
         if ~strcmp(s.Tag,'distbar')
            s = rmfield(s,'Parent');
            s = rmfield(s,'Children');
            s = rmfield(s,'Type');
            line(s);
         end
      end

   end

end

