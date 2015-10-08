function ui_editcodes(s,col,h_cb,cb)
%GUI dialog for editing value codes for a specified column in a GCE Data Structure
%
%syntax: ui_editcodes(s,col,h_cb,cb)
%
%input:
%  s = data structure to modify
%  col = name or index of string or integer column to define codes for in the structure metadata
%  h_cb = object handle for storing the code list data set (GCE data structure with columns
%     Code and Definition)
%  cb = callback statement to execute after editing is complete
%
%output:
%  none
%
%(c)2007-2012 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 29-Nov-2012

if nargin == 4

   if gce_valid(s,'data')

      if ~isnumeric(col)
         col = name2col(s,col);
      end

      %check for single column selection
      if length(col) == 1

         dtype = get_type(s,'datatype',col);

         %check for string or integer datatype
         if strcmp(dtype,'s') || strcmp(dtype,'d')

            %init codename, codevals arrays
            codenames = [];
            codevals = [];

            %get old codes from the metadata
            oldcodes = lookupmeta(s,'Data','ValueCodes');

            %parse old codes for specified column
            if ~isempty(oldcodes)

               %split code assignments for multiple columns
               if ~isempty(strfind(oldcodes,'|'))
                  delim = '|';
               else
                  delim = ';';
               end
               ar = splitstr(oldcodes,delim);

               %parse codes for specified column
               if ~isempty(ar)
                  
                  %get column name
                  colname = s.name{col};
                  
                  %check for template mode (variable==name)
                  Ieq = strfind(colname,'==');
                  if ~isempty(Ieq)
                     colname = trimstr(colname(Ieq+2:end));  %strip off template variable
                  end
                  
                  %look up cell starting with column name and colon
                  Icol = find(strncmp(ar,[colname,':'],length(colname)+1));
                  if ~isempty(Icol)
                     [tmp,rem] = strtok(ar{Icol},':');
                     if length(rem) > 2
                        oldcodes = trimstr(rem(2:end));
                        [codenames,codevals] = splitcodes(oldcodes);  %parse code names, values into arrays
                        codenames = strrep(codenames,'""','');  %remove empty double quotes from flags2cols
                     else
                        oldcodes = '';
                     end
                  else
                     oldcodes = '';
                  end
                  
               end
               
            end

            %extact column values
            allvals = unique(extract(s,col));

            %check for integer column, convert to cell array of strings
            if ~iscell(allvals)
               allvals = cellstr(int2str(allvals));
               allvals = strrep(allvals,' ','');
            end
            
            %remove empty cells
            Ivalid = ~cellfun('isempty',allvals);
            if ~isempty(Ivalid)
               allvals = allvals(Ivalid);
            else
               allvals = [];
            end
            
            %update code list arrays with unique column values          
            if ~isempty(allvals)
               if isempty(codenames)
                  codenames = allvals;
                  codevals = repmat({'unspecified'},length(codenames),1);
               else  %add undocumented codes to prior list
                  [tmp,Inew] = setdiff(allvals,codenames);
                  if ~isempty(Inew)
                     codenames = [codenames ; allvals(Inew)];
                     codevals = [codevals ; repmat({'unspecified'},length(Inew),1)];
                  end
               end   
            end
            
            %generate a data structure for editing the code definitions
            s_tmp = newstruct('data');
            s_tmp = addcol(s_tmp,codenames,s.name{col},'','','s','code','none',0,'',1);
            s_tmp = addcol(s_tmp,codevals,'Definition','','','s','text','none',0,'strcmp(x,''unspecified'')=''I''',[]);

            %open the data structure for editing, passing along the callback info to return the data
            %to the calling dialog
            ui_datagrid('init',s_tmp,h_cb,cb,200,'left')
            set(gcf,'name','Value Code Definitions')

         else
            disp('unsupported column data type')
         end

      else
         disp('invalid column selection')
      end

   else
      disp('invalid data structure')
   end

else
   disp('insufficient arguments')
end