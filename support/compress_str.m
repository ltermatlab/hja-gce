function str2 = compress_str(str)
%Removes all blanks from a character array or cell array of strings
%
%syntax: str2 = compress_str(str)
%
%input:
%  str = text to compress
%
%output:
%  str2 = modified text array (or empty array on error)
%
%
%(c)2007 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 11-May-2007

str2 = '';

if nargin == 1
   
   %call external function to remove leading and trailing blanks first
   str = trimstr(str);
   
   if ~isempty(str)
      
      if ischar(str)
         
         %init output with same dimensions as trimmed string
         str2 = repmat(' ',size(str,1),size(str,2));
         
         %init width
         wid = 0;
         
         %loop through rows, adding compressed strings
         for n = 1:size(str,1)
            tmp = strrep(str(n,:),' ','');
            len = length(tmp);
            if len > 0
               str2(n,1:len) = tmp;
               wid = max(wid,len);
            end
         end
         
         %remove unused columns
         str2 = str2(:,1:wid);
         
      else
         
         str2 = str;
         
         for n = 1:size(str,1)
            str2{n} = strrep(str{n},' ','');
         end         
         
      end
      
   end
   
end