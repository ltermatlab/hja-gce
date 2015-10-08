function [s2,msg] = coalesce_cols(s,col1,col2,checkunits,flag,deletecol)
%Coalesces values in two or more compatible data columns by filling in null/NaN records
%from the first column with non-null/non-NaN records from the subsequent columns. This function
%can be used to consolidate data in duplicate or equivalent data columns resulting
%from merge or join operations (e.g. data offsets resulting from merging data sets
%with differences in column name spelling).
%
%syntax: [s2,msg] = coalesce_cols(s,col1,col2,checkunits,flag,deletecol)
%
%inputs:
%  s = data column to modify
%  col1 = name or index of first data column
%  col2 = names or indices of other columns to coalesce with col1
%  checkunits = option to check units for compatibility (case-insensitive text comparison)
%     0 = no
%     1 = yes/default
%  flag = flag to assign to copied values (default = '' for none)
%  deletecol = option to delete second column after coalescing
%     0 = no
%     1 = yes/default
%
%outputs:
%  s2 = modified data structure
%  msg = text of any error message
%
%(c)2002-2010 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%  email: sheldon@uga.edu
%
%last modified: 07-Jul-2010

s2 = [];
msg = '';

if nargin >= 3
   
   if gce_valid(s,'data')
      
      %validate input
      if ~isnumeric(col1)
         col1 = name2col(s,col1);
      end
      
      if ~isnumeric(col2)
         col2 = name2col(s,col2);
      end
      
      if exist('checkunits','var') ~= 1
         checkunits = 1;
      end
      
      if exist('flag','var') ~= 1
         flag = '';
      elseif ~ischar(flag) || length(flag) ~= 1
         flag = '';
      end
      
      if exist('deletecol','var') ~= 1
         deletecol = 1;
      end
      
      %check for valid column selections
      if length(col1) == 1 && ~isempty(col2)
         
         %check for col1 in col2 array
         Ivalid = col2 ~= col1;
         col2 = col2(Ivalid);
         
         if ~isempty(col2)
            
            %init valid col2 list
            col2_valid = col2;
            
            %copy structure to output
            s2 = s;
    
            %cache variabletypes
            vtype = s2.variabletype;
            vtype = strrep(vtype,'calculation','data');  %convert calc type to data so matches
            
            %loop through columns to coalesce
            for n = 1:length(col2)
               
               %get index of source column
               col = col2(n);
               
               %perform unit check if specified
               if checkunits == 1
                  unit_match = strcmpi(deblank(s2.units{col1}),deblank(s2.units{col}));
               else
                  unit_match = 1;
               end
               
               %check column compatibility
               if strcmp(s2.datatype{col1},s2.datatype{col}) && strcmp(vtype{col1},vtype{col}) && ...
                     strcmp(s2.numbertype{col1},s2.numbertype{col}) && unit_match == 1
                  
                  %extract values from structure
                  vals1 = extract(s2,col1);
                  vals2 = extract(s2,col);
                  
                  %evaluate offsets in data, generate index of vals from column 2 to copy to column 1
                  if isnumeric(vals1)
                     I1 = isnan(vals1);
                     I2 = ~isnan(vals2);
                  else  %text data
                     I1 = cellfun('isempty',vals1);
                     I2 = ~cellfun('isempty',vals2);
                  end
                  
                  %get index of values to copy to fill in NaN/null
                  Icopy = find(I1 & I2);
                  
                  %copy updates to column 1 (if necessary)
                  if ~isempty(Icopy)
                  
                     %update processing history before update
                     s2.history = [s2.history ; ...
                        {datestr(now)},{['replaced ',int2str(length(Icopy)),' NaN/empty values in column ', ...
                        s2.name{col1},' with values from column ',s2.name{col},' (''coalesce_cols'')']}];
                     
                     %assign flags for copied values if specified and lock flags
                     if ~isempty(flag)
                        s2 = addflags(s2,col1,Icopy,flag);
                     end
                     
                     %update value array
                     vals1(Icopy) = vals2(Icopy);

                     %update data, logging differences
                     s2 = update_data(s2,col1,vals1);
                 
                  end                  
                  
               else  %bad column selection
                  
                  col2_valid(n) = NaN;  %clear column from valid list                  
                  msg = 'data columns are not compatible (check data type and units)';                  
                  
               end
            
            end
            
            %delete secondary columns if specified
            col2_valid = col2_valid(~isnan(col2_valid));
            if ~isempty(col2_valid) && deletecol == 1       
               s2 = deletecols(s2,col2_valid);
            end            
            
         else
            msg = 'no unique source columns were specified';
         end
         
      else
         msg = 'invalid column selections';
      end
      
   else
      msg = 'invalid data structure';
   end
   
else
   msg = 'insufficient arguments';
end