function [s2,msg] = concat_cols(s,cols,separator,deleteoption,colname,vartype,criteria,units,description)
%Concatenates text columns in a GCE data structure to create a single text column
%
%syntax: [s2,msg] = concat_cols(s,cols,separator,deleteoption,colname,vartype,criteria,units,description)
%
%inputs:
%  s = data structure to modify
%  cols = array of column numbers or names to concatenate (numeric columns will be converted
%     to strings using the 'num2str' function automatically)
%  separator = separator string to use between column values (default = '')
%  deleteoption = option to delete the original columns after concatenation
%     0 = no (default)
%     1 = yes
%  colname = column name to assign to the combined column (default = '' for concatenated list of column names)
%  vartype = variable type to assign to the combined column (default = 'text')
%  criteria = QA/QC flag criteria to assign to the combined column (default = '')
%  units = variable units to assign to the combined column (default = units of first column)
%  description = variable description to assign to the combined column (default = ['Combined values from columns ',...)
%
%output:
%  s2 = updated structure
%  msg = text of any error message
%
%(c)2002-2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 03-Jun-2013

s2 = [];
msg = '';

if nargin >= 2

   if gce_valid(s,'data')
      
      %supply defaults for omitted arguments
      if exist('separator','var') ~= 1
         separator = '';
      end
      
      if exist('colname','var') ~= 1
         colname = '';
      end
      
      if exist('deleteoption','var') ~= 1
         deleteoption = 0;
      elseif deleteoption ~= 1
         deleteoption = 0;
      end
      
      if exist('vartype','var') ~= 1
         vartype = 'text';
      end
      
      if exist('criteria','var') ~= 1
         criteria = '';
      end
      
      %look up column indices by name
      if ~isnumeric(cols)
         cols = name2col(s,cols);
      end
      
      %validate column selections
      Ivalid = cols >= 1 & cols <= length(s.name);
      cols = cols(Ivalid);
      
      if ~isempty(cols)
         
         %set default units if omitted
         if exist('units','var') ~= 1
            units = s.units{cols(1)};
         end
         
         %set default description if omitted
         if exist('description','var') ~= 1
            description = '';
         end
         
         %init runtime variables
         allcols = [];
         err = 0;
      
         %add columns to master array, converting numeric columns to strings
         for n = 1:length(cols)
            col = cols(n);
            if strcmp(s.datatype{col},'s')
               c = extract(s,col);
            else
               s_tmp = convert_datatype(s,col,'s');  %call external function to convert column data type
               if ~isempty(s_tmp) && strcmp(s_tmp.datatype{col},'s')
                  c = extract(s_tmp,col);
               else
                  c = [];
               end
            end
            if iscell(c) && ~isempty(c)
               allcols = [allcols,c];
            else
               err = 1;
               msg = ['an error occurred adding column ',s.name{col}];
            end
         end      
         
         if err == 0 && size(allcols,2) > 0
         
            %perform concatenation
            allcols = concatcellcols(allcols,separator);
            
            %generate automatic column name, description
            if isempty(colname)
               colname = char(concatcellcols(s.name(cols),'_'));
            end
            
            %generate column description
            if isempty(description)
               description = ['Combined values from columns ',cell2commas(s.name(cols),1)];
            end
            
            %add combined column
            s2 = addcol(s,allcols,colname,units,description,'s',vartype,'none',0,criteria,max(cols)+1);
            
            %generate history entry, skipping generic column addition step
            if isempty(separator)
               sepstr = '';
            else
               sepstr = [', separating values by ''',separator,''','];
            end
            s2.history = [s.history; ...
                  {datestr(now),['concatentated values from columns ',cell2commas(s.name(cols),1),sepstr, ...
                        ' to generate text column ',colname,' (''concat_cols'')']}];
            
            %delete original columns if specified
            if deleteoption == 1
               s2 = deletecols(s2,cols);
            end
            
         end
         
      else
         msg = 'invalid column selection';
      end
      
   else
      msg = 'invalid data structure';
   end
   
else
   msg = 'insufficient arguments for function';
end