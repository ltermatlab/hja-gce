function [s2,msg] = convert_num2str(s,col,vartype)
%Converts values in a numeric data column of a GCE Data Structure to string values using 'int2str'
%
%syntax: [s2,msg] = convert_int2str(s,col,vartype)
%
%inputs:
%  s = data structure to modify
%  col = name or index of column to modify
%  vartype = variable type to assign to the modified column (default = [] for no change)
%
%outputs:
%  s2 = modified structure
%  msg = text of any error message
%
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
%last modified: 03-Aug-2006

s2 = [];
msg = '';

if nargin >= 2
   
   %default to no vartype change if omitted
   if exist('vartype','var') ~= 1
      vartype = [];
   end
   
   %look up column name
   if ~isnumeric(col)
      col = name2col(s,col);
   end
   
   if length(col) == 1
      
      %validate and lookup data type for column
      dtype = get_type(s,'datatype',col);
      
      if ~strcmp(dtype,'s')
         
         data0 = extract(s,col);  %extract data values
         
         %init runtime vars for processing conversions in groups to minimize memory overhead
         numrows = length(data0);  %get number of records
         gpsize = 1000;  %init group size for conversions
         numgps = ceil(numrows./gpsize);  %calculate number of iterations
         
         if numrows > 0
            
            data2 = [];  %init converted data array
            
            try
               
               if strcmp(dtype,'d')
                  
                  %loop through records, converting values and appending to data2
                  for n = 1:numgps
                     Istart = gpsize .* (n-1) + 1;  %calc starting row index
                     if n < numgps
                        Iend = gpsize .* n;  %calc ending row index (non-terminal groups)
                     else
                        Iend = numrows;  %calc ending row index (terminal group)
                     end
                     tmp = cellstr(int2str(data0(Istart:Iend)));
                     if ~isempty(tmp)
                        data2 = [data2 ; tmp];
                     else
                        data2 = [];
                        break
                     end
                  end
                  
               else
                  
                  prec = s.precision(col);  %look up precision
                  fstr = ['%0.',int2str(prec),dtype];  %generate format string
                  
                  %loop through records, converting values and appending to data2
                  for n = 1:numgps
                     Istart = gpsize .* (n-1) + 1;  %calc starting row index
                     if n < numgps
                        Iend = gpsize .* n;  %calc ending row index (non-terminal groups)
                     else
                        Iend = numrows;  %calc ending row index (terminal group)
                     end
                     tmp = cellstr(num2str(data0(Istart:Iend),fstr));
                     if ~isempty(tmp)
                        data2 = [data2 ; tmp];
                     else
                        data2 = [];
                        break
                     end
                  end
                  
               end
               
               %clear NaNs
               if ~isempty(find(isnan(data0)))
                  data2 = strrep(data2,'NaN','');
               end
               
            catch
               data2 = [];
            end
            
            if ~isempty(data2)
               
               %buffer column attributes
               colname = s.name{col};
               desc = s.description{col};
               if isempty(vartype)
                  vartype = s.variabletype{col};
               end
               
               %delete existing data column
               s2 = deletecols(s,col);
               
               %add revised data column
               s2 = addcol(s2,data2,colname,'none',desc,'s',vartype,'none',0,'',col);
               
               if ~isempty(s2)
                  
                  %generate data type string for history
                  switch dtype
                     case 'd'
                        dtypestr = 'integer';
                     case 'f'
                        dtypestr = 'floating-point';
                     case 'e'
                        dtypestr = 'exponential';
                     otherwise
                        dtypestr = 'unspecified';
                  end
                  
                  %update processing history, omitting column deletion, addition steps by appending to original array
                  s2.history = [s.history ; ...
                        {datestr(now)},{['converted the data type of column ',s.name{col},' from ',dtypestr, ...
                              ' to string (''convert_num2str'')']}];
                  
               else
                  msg = 'errors occurred updating the structure';
               end
               
            else
               msg = 'errors occurred converting the data values to strings';
            end
            
         else
            msg = 'data structure is empty';
         end
         
      else
         msg = 'invalid column data type';
      end
      
   else
      msg = 'invalid column selection';
   end
   
else
   msg = 'insufficient arguments for function';
end