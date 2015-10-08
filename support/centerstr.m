function str3 = centerstr(str1,str2)
%Centers two character arrays with respect to eachother
%
%syntax: str3 = centerstr(str1,str2)
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
%last modified: 09-Sep-2004

if nargin == 2
   
   if ~isempty(str1)
      
      w1 = size(str1,2);
      w2 = size(str2,2);
      
      if w2 == 0  %check for empty second string
         str3 = str1;      
      else
         if w1 < w2
            lpad = fix((w2-w1)./2);
            str1 = [repmat(blanks(size(str1,1))',1,lpad) str1];
         elseif w1 > w2
            lpad = fix((w1-w2)./2);
            str2 = [repmat(blanks(size(str2,1))',1,lpad) str2];
         end
         str3 = str2mat(str1,str2);
      end
      
   else  %don't prepend empty string
      str3 = str2;
   end
   
end