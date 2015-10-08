function Imatch = contains(vals,pattern,caseopt)
%Returns a logical index of strings in an array that contain the specified substring
%
%syntax: Imatch = contains(vals,pattern,caseopt)
%
%inputs:
%  vals = cell array of string values or delimited character array to test (valid delimiters are
%    semicolons, commas, or spaces)
%  pattern = character array containing the substring to match
%  caseopt = check case option
%    'sensitive' = use case-sensitive matches (default)
%    'insensitive' = use non-case sensitive matches
%
%outputs:
%  Imatch = logical index of values *not* in the specified list
%
%
%(c)2008-2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 17-Dec-2014

Imatch = [];

if nargin >= 2 && ischar(pattern) && ~isempty(pattern)
   
   %set case check flag
   if exist('caseopt','var') ~= 1
      checkcase = 1;
   elseif strcmpi(caseopt,'insensitive')
      checkcase = 0;
   else
      checkcase = 1;
   end
   
   %evaluate delimited string, convert to cell array
   if ischar(vals)
      if ~isempty(strfind(vals,';'))
         vals = splitstr(vals,';');
      elseif ~isempty(strfind(vals,','))
         vals = splitstr(vals,',');
      else
         vals = splitstr(vals,' ');
      end
   end
   
   %check for valid array to check
   if iscell(vals)
      
      %convert pattern to lower case if not case sensitive
      if checkcase == 0
         pattern = lower(pattern);
      end
      
      %init match index
      Imatch0 = zeros(length(vals),1);
      
      %loop through values
      for n = 1:length(vals)
         
         %extract string to check
         str = vals{n};

         %validate string
         if ischar(str)
            
            %convert to lower case if insensitive match
            if checkcase == 0
               str = lower(str);
            end
            
            %perform match
            if ~isempty(strfind(str,pattern))
               Imatch0(n) = 1;
            end
            
         end
         
      end
      
      %convert Imatch integer array to logical array
      Imatch = Imatch0 == 1;
      
   end
   
end