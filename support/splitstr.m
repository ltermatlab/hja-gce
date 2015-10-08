function ar = splitstr(str,delim,clearopt,trimopt)
%Splits a character array into elements based on positions of a specified delimiter,
%and returns the results as a cell array of strings with any blank elements removed
%
%syntax:  ar = splitstr(str,delim,clearopt,trimopt)
%
%inputs:
%  str = string to split
%  delim = delimiter character
%  clearopt = option to clear empty rows (0 = no, 1 = yes/default)
%  trimopt = option to trim leading blanks from rows (0 = no, 1 = yes/default)
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

ar = [];

if nargin >= 2
   
   if exist('trimopt','var') ~= 1
      trimopt = 1;
   elseif trimopt ~= 0
      trimopt = 1;
   end
   
   if exist('clearopt','var') ~= 1
      clearopt = 1;
   elseif clearopt ~= 0
      clearopt = 1;
   end
   
   if length(delim) == 1
      
      if iscell(str)
         str = char(str);
      end
      
      if size(str,1) > 1  %concatenate multiline character arrays
         str = [repmat(delim,size(str,1),1),str];  %add leading delimiters
         str = str';       %transpose string prior to concatenation
         str = str(:)';    %concatenate rows
         str = str(2:end); %strip leading delimiter
      end
      
      I_del = strfind(str,delim);
      
      if ~isempty(I_del)
         
         ar = repmat({''},length(I_del)+1,1);  %initialize output cell array
         len = length(str);
         nsegs = length(I_del);
         
         if trimopt == 1  %trim leading blanks
            
            %grab first segment unless delim at position 1
            if I_del(1) > 1
               ar{1} = trimstr(str(1,1:I_del(1)-1));
            end
            
            %process remaining segment
            for n = 2:nsegs
               if I_del(n)-I_del(n-1) > 1  %check for zero-length strings
                  ar{n} = trimstr(str(1,I_del(n-1)+1:I_del(n)-1));
               end
            end
            
            %append any characters after last delimiter
            if I_del(end) < len
               ar{end} = trimstr(str(1,I_del(end)+1:end));
            end
            
         else
            
            %grab first segment unless delim at position 1
            if I_del(1) > 1
               ar{1} = deblank(str(1,1:I_del(1)-1));
            end
            
            %process remaining segment
            for n = 2:nsegs
               if I_del(n)-I_del(n-1) > 1  %check for zero-length strings
                  ar{n} = deblank(str(1,I_del(n-1)+1:I_del(n)-1));
               end
            end
            
            %append any characters after last delimiter
            if I_del(end) < len
               ar{end} = deblank(str(1,I_del(end)+1:end));
            end
            
         end
         
         if clearopt == 1  %omit empty cells
            
            I2 = find(~cellfun('isempty',ar));  %get index of non-empty cells
            if ~isempty(I2)
               ar = ar(I2);
            else
               ar = [];
            end
            
         end
         
      else  %no delimiter found - return entire string
         
         if ~isempty(str)
            if trimopt == 1
               str = deblank(str);
               if ~isempty(str)
                  str = fliplr(deblank(fliplr(str)));
               end
            end
         end
         ar = {str};
         
      end
      
   end
   
end