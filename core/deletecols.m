function [s2,msg] = deletecols(s,cols,silent)
%Deletes specified columns from a GCE Data Structure, ignoring any unmatched column names or indices
%
%syntax: [s2,msg] = deletecols(s,cols,silent)
%
%inputs:
%  s = data structure to modify (struct; required)
%  cols = array of column names or numbers to delete (integer, string or cell array; required)
%  silent = option to omit history entry about column deletion (integer; optional)
%     0 = no (default)
%     1 = yes
%
%outputs:
%  s2 = modified data structure
%  msg = text of any error message
%
%notes: 
%  1) if all specified columns are invalid the original structure will be returned unmodified
%     with a warning message (i.e. function can be safely called without testing for the presence 
%     of a named column)
%  2) if all columns are deleted an empty array will be returned with a warning message
%
%(c)2002-2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 11-Mar-2015

s2 = [];
msg = '';

%check for required input
if nargin >= 2

   %check for valid data structure
   if gce_valid(s,'data')
      
      %validate silent option
      if exist('silent','var') ~= 1 || ~isnumeric(silent) || silent ~= 1
         silent = 0;
      end

      %validate column selections
      if ~isnumeric(cols)
         cols = name2col(s,cols);
      else
         %remove out of range columns
         cols = cols(cols > 0 & cols <= length(s.name));
      end

      %check for any columns to delete
      if ~isempty(cols)

         %invert column list to get column indices to keep
         Icols = setdiff((1:length(s.name)),cols);

         %check for residual columns
         if ~isempty(Icols)

            %copy residual columns and metadata, skipping validation
            s2 = copycols(s,Icols,'Y','Y');

            if ~isempty(s2)
               
               %format date for history
               curdate = datestr(now);

               if silent == 0
                  
                  %update history
                  if length(cols) > 1
                     str = 'deleted columns ';
                  else
                     str = 'deleted column ';
                  end
                  s2.history = [s.history ; {curdate} , ...
                     {[str,cell2commas(s.name(cols),1),' from the structure (''deletecols'')']}];
                  
               end
               
               %update edit date
               s2.editdate = curdate;

            else
               msg = 'all columns deleted';
            end

         else
            msg = 'all columns deleted';
         end

      else
         s2 = s;  %pass original structure back
         msg = 'no matching columns were found';
      end

   else
      msg = 'invalid GCE Data Structure';
   end

else
   msg = 'insufficient arguments for function';
end