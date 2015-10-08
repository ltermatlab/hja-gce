function ar = splitstr_multi(str,delim,clearopt,trimopt)
%Splits strings in a cell array into sub-arrays based on a delimiter character
%and returns a uniform multi-column array (requires splitstr.m)
%
%syntax:  ar = splitstr_multi(str,delim,clearopt,trimopt)
%
%inputs:
%  str = string to split
%  delim = delimiter character
%  clearopt = option to clear empty rows (0 = no/default, 1 = yes)
%  trimopt = option to trim leading and trailing blanks from split strings (0 = no, 1 = yes/default)
%
%output:
%  ar = cell array
%
%notes:
%  1) the function 'splitstr.m' is required
%  2) the number of columns will be based on the maximum number of terms in any string
%  3) strings that contain fewer terms will be padded with empty strings
%
%(c)2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 05-Feb-2013

%init output
ar = [];

%check for valid input
if nargin >= 2 && iscell(str) && ischar(delim) && length(delim) == 1
   
   %set default clearopt if omitted
   if exist('clearopt','var') ~= 1 || ~isnumeric(clearopt)
      clearopt = 0;
   end
   
   %set default trimopt if omitted
   if exist('trimopt','var') ~= 1 || ~isnumeric(trimopt)
      trimopt = 1;
   end
   
   %force column orientation
   str = str(:);
   
   %determine number of elements based on splitting first string
   str0 = str{1};
   if ischar(str0)
      ar_split = splitstr(str0,delim,0,trimopt);
   else
      ar_split = [];
   end
   
   if ~isempty(ar_split)
      
      %init output array with dimensions based on input array size and number of elements in first string
      numrows = length(str);
      numcols = length(ar_split);
      newcol = repmat({''},numrows,1);
      ar = repmat(newcol,1,numcols);
      
      %loop through remaining rows
      for n = 1:numrows
         
         %split string
         str0 = str{n};
         if ischar(str0)
            ar_split = splitstr(str0,delim,0,trimopt);
         else
            ar_split = [];
         end
         
         %validate and populate output array
         if ~isempty(ar_split)
            
            %check split array size
            numcols0 = length(ar_split);
            
            %check for array size mismatches
            if numcols0 < numcols
               
               %padd elements to match output
               ar_new = [ar_split ; repmat({''},numcols-numcols0,1)];
               
            else
               
               %use split array as is
               ar_new = ar_split;

               %increase output array size to match number of elements and adjust numcols
               if numcols0 > numcols                 
                  ar = [ar,repmat(newcol,1,numcols0-numcols)];
                  numcols = numcols0;                  
               end
               
            end
            
            %add to output
            ar(n,1:numcols) = ar_new(1:numcols);
            
         end

      end
      
      %clear empty rows
      if clearopt == 1
         
         %get index of empty cells
         Inull = cellfun('isempty',ar);
         
         %generate clear index
         Iclear = sum(Inull,2) == numcols;
         
         %remove empty rows
         ar = ar(~Iclear);
         
      end
            
   end
   
end