function ar = gceds2cell(s,cols)
%Converts a GCE Data Structure to a standard MATLAB cell array
%
%syntax: ar = gceds2cell(s,cols)
%
%input:
%  s = GCE Data Structure to convert
%  cols = array of column names or numbers to extract
%
%output:
%  ar = cell array output
%
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
%last modified: 08-Mar-2013

%init output
ar = [];

%check for required input
if nargin >= 1 && gce_valid(s,'data')
   
   %set default column selection if omitted
   if exist('cols','var') ~= 1
      cols = [];
   end
   
   %validate column selections
   if isempty(cols)
      cols = (1:length(s.name));
   elseif ~isnumeric(cols)
      cols = name2col(s,cols);
   else
      cols = cols(cols >= 1 & cols <= length(s.name));  %remove invalid column selections
   end
   
   if ~isempty(cols)
      
      %get number of rows
      numrecords = length(s.values{1});
      
      if numrecords > 0
      
         %init array
         ar = cell(numrecords,length(cols));
         
         %loop through columns
         for cnt = 1:length(cols)
            
            %extract column data
            vals = extract(s,cols(cnt));
            
            %check for numeric column - convert to cell
            if ~iscell(vals)
               vals = num2cell(vals);
            end
            
            %copy values to output array
            ar(:,cnt) = vals(:);
            
         end
         
      end
      
   end
   
end

