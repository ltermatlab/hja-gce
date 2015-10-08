function [s2,msg] = trim_metadata(s,maxchars)
%Trims excess characters from metadata fields in a GCE Data Structure
%
%syntax:  [s2,msg] = trim_metadata(s,maxchars)
%
%input:
%  s = data structure to revise
%  maxchars = maximum number of characters to retain in metadata fields (default = 20000; 
%     0 to clear all fields)
%
%output:
%  s2 = updated data structure
%  msg = text of any error message
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
%last modified: 03-Oct-2014

%init output
s2 = [];
msg = '';

if nargin >= 1
   
   %perform basic structure validation
   if isstruct(s) && isfield(s,'metadata') && size(s.metadata,2) == 3

      %init output structure
      s2 = s;
      
      %get metadata array
      meta = s.metadata;
      
      %check for missing/invalid maxchars and use default
      if exist('maxchars','var') ~= 1 || isempty(maxchars) || ~isnumeric(maxchars)
         maxchars = 20000;
      elseif maxchars > 0
         %force integer
         maxchars = fix(maxchars);
      else
         maxchars = 0;
      end
         
      %get index of excessively long fields
      Ilong = find(cellfun('length',meta(:,3)) > maxchars);
      
      %check for matching fields, trim
      if ~isempty(Ilong)

         %loop through fields to trim
         for cnt = 1:length(Ilong)
            
            %get original string
            str = meta{Ilong(cnt),3};
            
            %get index of space characters
            Ispc = strfind(str,' ');
            
            %check for last space before hitting maxchars
            if ~isempty(Ispc) && maxchars > 20
               trimsize = Ispc(max(find(Ispc <= maxchars)));                             %#ok<MXFND>
               if isempty(trimsize) || trimsize < (maxchars-20)
                  trimsize = maxchars;
               end
            else
               trimsize = maxchars;
            end
            
            %trim string based on last space or maxchars
            newstr = str(1:trimsize);
            
            %update metadata
            meta(Ilong(cnt),3) = {newstr};
            
         end
      
         %update metadata with trimmed fields
         s2.metadata = meta;
         
         %generate history entry, including field names for 10 or fewer trimmed fields
         if length(Ilong) > 10
            flds = [int2str(length(Ilong)),' metadata fields'];
         else
            flds = cell2commas(concatcellcols(meta(Ilong,1:2),'/'),1);
         end
         str_hist = ['trimmed text entries in metadata fields(s) ',flds, ...
            ' to a maximum of ',int2str(maxchars),' characters (''trim_metadata'')'];
            
         %add update date and processing history entry
         s2.editdate = datestr(now);
         s2.history = [s2.history ; ...
            {datestr(now),str_hist}];
         
      end
      
   else
      msg = 'invalid GCE Data Structure';
   end
   
else
   msg = 'insufficient input arguments';
end
