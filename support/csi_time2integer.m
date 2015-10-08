function val = csi_time2integer(str)
%Converts Campbell Scientific Instruments min/max times in h:m format to hhmm integer format
%
%syntax: val = csi_time2integer(str)
%
%inputs:
%  str = cell array of time strings
%
%outputs:
%  val = numeric array of integer times
%
%(c)2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 24-Oct-2014

%init output
val = [];

%validate input
if nargin == 1 && ~isempty(str)
   
   %convert character array to cell
   if ischar(str)
      str = cellstr(str);
   end
   
   %validate array
   if iscell(str)
      
      %init val array
      val = ones(length(str),1) .* NaN;
      
      for n = 1:length(str)

         %split hour, minute
         ar = textscan(str{n},'%d:%d');
         
         %validate split fields
         if length(ar) == 2
            
            %convert to hhmm
            val(n) = ar{1}*100 + ar{2};
            
         end
         
      end
      
   end
   
end