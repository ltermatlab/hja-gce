function ar2 = concatcellcols(ar,spacer)
%Concatenates individual cells on each row in a cell array of strings to form a single column array
%
%syntax: ar2 = concatcellcols(ar,spacer)
%
%inputs:
%  ar = cell array of strings
%  spacer = optional spacer to insert between columns (default = '')
%
%output:
%  ar2 = concatenated array
%
%(c)2004-2011 by Wade Sheldon
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
%last modified: 22-Sep-2011

ar2 = [];

%validate spacer argument
if exist('spacer','var') ~= 1
   spacer = '';
end

if nargin >= 1

   if iscell(ar)

      %get array dimensions
      numrows = size(ar,1);
      numcols = size(ar,2);

      if numcols > 1

         ar2 = cell(numrows,1);

         if ~isempty(spacer)
            spc = repmat({spacer},1,numcols);
            for n = 1:numrows
               tmp = [ar(n,:) ; spc];
               tmp = [tmp{:}];
               ar2{n} = tmp(1:end-length(spacer));
            end
         else
            for n = 1:numrows
               tmp = ar(n,:)';
               ar2{n} = [tmp{:}];
            end
         end

      else  %no need to concat

         ar2 = ar;

      end

   end

end
