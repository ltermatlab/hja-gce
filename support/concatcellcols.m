function ar2 = concatcellcols(ar,spacer,skipempty)
%Concatenates individual cells on each row in a cell array of strings to form a single column array
%
%syntax: ar2 = concatcellcols(ar,spacer,skipempty)
%
%inputs:
%  ar = cell array of strings
%  spacer = optional spacer to insert between columns (default = '')
%  skipempty = option to omit empty cells when concatenating:
%     0 = no (default)
%     1 = yes
%
%output:
%  ar2 = concatenated array
%
%(c)2004-2012 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 24-Nov-2014

ar2 = [];

if nargin >= 1 && iscell(ar)
   
   %validate spacer argument
   if exist('spacer','var') ~= 1
      spacer = '';
   end
   
   %validate skipempty
   if exist('skipempty','var') ~= 1 || isempty(skipempty)
      skipempty = 0;
   end
   
   %remove empty cells if specified
   if skipempty == 1
      ar = ar(~cellfun('isempty',ar));
   end
   
   %get array dimensions
   numrows = size(ar,1);
   numcols = size(ar,2);
   
   %check for columns to concatenate
   if numcols > 1
      
      %init output array
      ar2 = cell(numrows,1);
      
      %concatenate
      if ~isempty(spacer)
         
         %generate spacer array
         spc = repmat({spacer},1,numcols);
         
         %loop through cells and perform concatenation
         for n = 1:numrows
            tmp = [ar(n,:) ; spc];
            tmp = [tmp{:}];
            ar2{n} = tmp(1:end-length(spacer));
         end
         
      else  %no spacer
         
         %loop through cells and perform concatenation
         for n = 1:numrows
            tmp = ar(n,:)';
            ar2{n} = [tmp{:}];
         end
         
      end
      
   else  %no need to concat      
      ar2 = ar;      
   end
   
end
