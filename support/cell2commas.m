function str = cell2commas(c,opt)
%Concatenates elements in a cell array of strings to form a single comma-separated character array.
%Note that multidimensional arrays will be concatenated by column and then row, and that empty cells will
%be omitted.
%
%syntax: str = cell2commas(c,opt)
%
%inputs:
%  c = cell array
%  opt = format option
%    0 = only commas (default)
%    1 = separate last two items in list with 'and'
%    2 = separate last two items in list with 'or'
%    3 = only commas with no whitespace
%
%output:
%  str = concatenated string
%
%
%(c)2002-2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 13-Aug-2014

%init output
str = '';

%validate input
if exist('c','var') ~= 1
   c = '';
end

if exist('opt','var') ~= 1 || ~isnumeric(opt) || opt > 3
   opt = 0;
end

if iscell(c)
   
   %force row vector orientation
   c = c(:)';  
   I = ~cellfun('isempty',c);
   c = c(I);
   
   %get array length
   len = length(c);
   
   %check for singular array
   if len == 1
      
      str = c{1};
      
   elseif len > 1
      
      %generate string based on option
      switch opt
         
         case 0  %comma and space
            
            c = [c ; repmat({', '},1,length(c)-1),{''}];
            str = [c{:}];
            
         case 1  % 'and' terminal separator
            
            if len == 2
               str = [c{1},' and ',c{2}];
            else
               c = [c ; repmat({', '},1,length(c)-2),{' and '},{''}];
               str = [c{:}];
            end
            
         case 2   % 'or' terminal separator
            
            if len == 2
               str = [c{1},' or ',c{2}];
            else
               c = [c ; repmat({', '},1,length(c)-2),{' or '},{''}];
               str = [c{:}];
            end
            
         case 3    %no whitespace
            
            c = [c ; repmat({','},1,length(c)-1),{''}];
            str = [c{:}];
            
      end
      
   end
   
end
