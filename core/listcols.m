function [lst,msg] = listcols(data,listformat)
%Lists names and units of all columns in a GCE-LTER data or stat structure
%in various output formats
%
%syntax:  [lst,msg] = listcols(data,format)
%
%inputs:
%  data = data structure
%  format = integer specifying output format option
%    1 = character array of column numbers, names, units, data types (default)
%    2 = structure of names, with fieldnames as: col1, col2, etc.
%    3 = character array of names only
%    4 = cell array of names and units concatenated (excluding blank and "none" units)
%    5 = 2-column cell array of names, units
%
%outputs:
%  lst = output array
%  msg = text of any error messages
%
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
%  sheldon@uga.edu
%
%last modified: 18-Nov-2010

%initialize output
lst = '';
msg = '';

if nargin >= 1
   
   %validate format option
   if exist('listformat','var') ~= 1
      listformat = 1;  %set default format if omitted
   elseif ~isnumeric(listformat)
      listformat = 1;
   else
      listformat = fix(listformat);
   end
   
   if gce_valid(data)
      
      names = data.name;
      units = data.units;
      dtype = data.datatype;
      dtype = strrep(dtype,'s','string');
      dtype = strrep(dtype,'f','floating-point');
      dtype = strrep(dtype,'e','exponential');
      dtype = strrep(dtype,'d','integer');
      dtype = strrep(dtype,'u','unspecified');
      
      if sum(~cellfun('isempty',names)) > 0
         
         len = length(names);
         nums = int2str((1:len)');
         
         switch listformat            
            case 1  %character array of nums, names, units, type
               str_temp = concatcellcols([names',repmat({' ('},len,1),units',repmat({')  -- '},len,1),dtype']);
               str_temp = strrep(str_temp,' (none)','');
               str_temp = strrep(str_temp,' ()','');
               lst = [nums,repmat(':  ',len,1),char(str_temp)];
            case 2  %structure of names
               fd = strrep(cellstr([repmat('col',len,1) nums]),' ','')';
               lst = cell2struct(names,fd,2);
            case 3  %char array of names only
               lst = char(names');
            case 4  %cell array of names, units
               numcols = length(names);
               str_pre = repmat({' ('},numcols,1);  %init opening parentheses string
               str_post = repmat({')'},numcols,1);  %init closing parentheses string
               units = strrep(units,'none','');  %strip out units of 'none'
               Inull = find(cellfun('isempty',units));  %get index of empty units
               if ~isempty(Inull)
                  str_pre(Inull) = {''};
                  str_post(Inull) = {''};
               end
               lst = concatcellcols([names',str_pre,units',str_post]);
            case 5 %2-column cell array of names, units
               lst = [names(:),units(:)];
            otherwise
               msg = 'invalid format option';
         end
         
      else
         msg = 'no column name information in the data structure';
      end
      
   else
      msg = 'invalid GCE-LTER data structure';
   end
   
else
   msg = 'insufficient arguments for function';
end
