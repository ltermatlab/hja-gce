function ar2 = null2emptystr(ar)
%Replaces empty cells in a cell array with empty strings
%
%syntax:  ar2 = null2emptystr(ar)
%
%input:
%  ar = cell array of strings
%
%output:
%  ar2 = updated cell array
%
%(c)2005 Wade M. Sheldon
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
%Wade M. Sheldon
%Dept. of Marine Sciences
%University of Georgia
%Athens, GA 30602-3636
%email: sheldon@uga.edu
%
%last modified: 05-Apr-2005

ar2 = [];

if nargin == 1

   if iscell(ar)

      ar2 = ar;

      Inull = find(cellfun('isempty',ar));
      if ~isempty(Inull)
         [ar2{Inull}] = deal('');
      end

   end

end