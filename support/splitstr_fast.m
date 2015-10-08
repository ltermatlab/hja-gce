function ar = splitstr_fast(str,delim)
%Speed-optimized version of the 'splitstr' function for deblanked, single-line character arrays
%
%syntax: ar = splitstr_fast(str,delim)
%
%inputs:
%  str = string to split
%  delim = delimiter character
%
%output:
%  ar = cell array
%
%
%(c)2002-2011 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 07-Sep-2011

ar = [];  %init output

%get index of delimiters
I_del = strfind(str,delim);

%check for presence of delimiters
if ~isempty(I_del)

   ar = repmat({''},length(I_del)+1,1);  %initialize output cell array
   len = length(str);  %get string length
   nsegs = length(I_del);  %count number of segments
   n = 1;

   %grab first segment unless delim at position 1
   if I_del(1) > 1
      ar{1} = str(1,1:I_del(1)-1);
   end

   %process remaining segment
   for n = 2:nsegs
      if I_del(n)-I_del(n-1) > 1  %check for zero-length strings
         ar{n} = str(1,I_del(n-1)+1:I_del(n)-1);
      end
   end

   %append any characters after last delimiter
   if I_del(end) < len
      ar{end} = str(1,I_del(end)+1:end);
   end

else  %no delimiter found - return entire string
   ar = {str};
end