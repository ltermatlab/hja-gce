function str2 = trimstr(str)
%Trims leading and trailing blanks from a single string or cell array of strings
%
%syntax: str2 = trimstr(str)
%
%input:
%  str = string to trim
%
%output
%  str2 = modifed string
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
%last modified: 28-May-2013

str2 = '';

if nargin == 1
   
   if exist('strtrim','builtin') == 5
      
      %use built-in MATLAB function if available
      str2 = strtrim(str);
      
   else  %else deblank
      
      if ischar(str)
         
         %clear leading and trailing blanks
         str2 = fliplr(deblank(fliplr(deblank(str))));
         
      elseif iscell(str)
         
         %loop through
         for n = 1:length(str)
            tmp = fliplr(deblank(fliplr(deblank(str{n}))));
            str{n} = tmp;
         end
         
         str2 = str;
         
      end
      
   end
   
end