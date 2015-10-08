function [s2,msg] = split_cols(s,col,delimiter,deleteoption,vartype,units,description,criteria)
%Splits a text column in a GCE data structure on a delimiter character to create multiple columns
%
%syntax: [s2,msg] = split_cols(s,col,delimiter,deleteoption,vartype,units,description,criteria)
%
%inputs:
%  s = data structure to modify
%  col = index number or name of text column to split (integer or string, required)
%  delimiter = delimiter character to use for splitting column values (1-character string, required)
%  deleteoption = option to delete the original columns after concatenation
%     0 = no (default)
%     1 = yes
%  colname = column name to assign to the combined column (default = '' for concatenated list of column names)
%  vartype = variable type to assign to the split columns (default = '' for col variable type)
%  units = variable units to assign to the split columns (default = '')
%  description = description to assign to the split columns (default = 'Split values from column [column]')
%  criteria = QA/QC flag criteria to assign to the combined column (default = '')
%
%output:
%  s2 = updated structure
%  msg = text of any error message
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
%last modified: 05-Feb-2013

%init output
s2 = [];
msg = '';

%check for required input
if nargin >= 3

   if gce_valid(s,'data')
      
      %set default delete option if omitted
      if exist('deleteoption','var') ~= 1
         deleteoption = 0;
      elseif deleteoption ~= 1
         deleteoption = 0;
      end
      
      %set default criteria if omitted
      if exist('criteria','var') ~= 1
         criteria = '';
      end
      
      %set default units if omitted
      if exist('units','var') ~= 1
         units = '';
      end
      
      %look up column index by name
      if ~isnumeric(col)
         col = name2col(s,col);
      end
      
      %validate column selection
      if length(col) == 1 && strcmp(get_type(s,'datatype',col),'s')
         
         %set default variable type if omitted
         if exist('vartype','var') ~= 1
            vartype = s.variabletype{col};
         end
         
         %set default description if omitted
         if exist('description','var') ~= 1
            description = ['Split values from column ',s.name{col}];
         end
         
         %split column
         str = extract(s,col);
         ar = splitstr_multi(str,delimiter,0,1);
         
         %validate split results
         if ~isempty(ar) && size(ar,1) == length(str) && size(ar,2) > 1
            
            %get original column title 
            colname = s.name{col};
            
            %delete original column if specified
            if deleteoption == 1
               s2 = deletecols(s,col);
               newcol = col;
            else
               s2 = s;
               newcol = col+1;
            end
            
            %add split columns
            for n = 1:size(ar,2)
               data = ar(:,n);
               s2 = addcol(s2,data,[colname,'_',int2str(n)],units,description,'s',vartype,'none',0,criteria,newcol+n-1);
            end            
            
         else
            msg = 'the text column could not be split based on the specified delimiter';
         end
         
      else
         msg = 'invalid column selection - col must be a single text column';
      end
      
   else
      msg = 'invalid data structure';
   end
   
else
   msg = 'insufficient arguments for function';
end