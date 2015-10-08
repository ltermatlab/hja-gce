function [s2,msg] = update_attributes(s,col,attrib_names,attrib_values)
%Updates attribute metadata for a column in a GCE Data Structure
%
%syntax: [s2,msg] = update_attributes(s,col,attrib_names,attrib_values)
%
%input:
%  s = data structure to update
%  col = names or index number of a data structure column to update
%  attrib_names = cell array of attributes to update ('name','units','description','datatype',
%     'variabletype','numbertype','precision','criteria')
%  attrib_values = cell array of attribute values to apply
%
%output:
%  s2 = updated data structure
%  msg = text of any error message
%
%
%(c)2012 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 21-Feb-2012

%init output
s2 = [];
msg = '';

%check for required input
if nargin == 4
   
   if gce_valid(s,'data')
      
      %validate column selections
      if ~isnumeric(col)
         col = name2col(s,col);
      else
         col = intersect(col,(1:length(s.name)));
      end
      
      %convert scalar attribute names to cell
      if ischar(attrib_names)
         attrib_names = cellstr(attrib_names);
      end
      
      %convert scalar attribute values
      if ~iscell(attrib_values)
         attrib_values = cellstr(attrib_values);
      elseif isnumeric(attrib_values)
         attrib_values = num2cell(attrib_values);
      end
      
      %check for valid column and matching array dimensions
      if length(col) == 1 && length(attrib_names) == length(attrib_values)
         
         %validate attribute names
         bad_attribs = ~inlist(attrib_names,{'name','units','description','datatype', ...
               'variabletype','numbertype','precision','criteria'});
         
         if sum(bad_attribs) == 0
            
            %copy input structure to output
            s2 = s;
            
            %init history string
            str_hist = repmat({''},length(attrib_names),1);
            
            %init bad value array
            badvals = zeros(length(attrib_names),1);
            
            for att = 1:length(attrib_names)
               
               %get attribute name and value to apply
               att_name = attrib_names{att};
               att_val = attrib_values{att};
               
               %check for character value unless attribute is precision
               if ischar(att_val) || strcmp(att_name,'precision')
                  
                  switch att_name
                     case 'name'
                        s2.name{col} = att_val;
                     case 'units'
                        s2.units{col} = att_val;
                     case 'description'
                        s2.description{col} = att_val;
                     case 'datatype'
                        if inlist(att_val,{'f','d','e','s'})
                           s2.datatype{col} = att_val;
                        else
                           badvals(att) = 1;
                        end
                     case 'variabletype'
                        if inlist(att_val,{'data','calculation','nominal','ordinal','logical','datetime', ...
                              'coord','code','text'})
                           s2.variabletype{col} = att_val;
                        else
                           badvals(att) = 1;
                        end
                     case 'numbertype'
                        if inlist(att_val,{'continuous','discrete','angular','none'})
                           s2.variabletype{col} = att_val;
                        else
                           badvals(att) = 1;
                        end
                     case 'precision'
                        if att_val >= 0
                           newprec = fix(att_val);  %force integer precision
                           if newprec > 0 && inlist(s.datatype{col},{'s','d'})
                              %check for nonzero precision for string or integer columns
                              badvals(att) = 1;
                           else
                              s2.precision(col) = newprec;
                           end
                        else
                           badvals(att) = 1;
                        end
                     case 'criteria'
                        s2.criteria = att_val;
                     otherwise
                        badvals(att) = 1;
                  end
                  
                  %generate history entry
                  if badvals(att) == 0
                     if ischar(att_val)
                        if strcmp(att_name,'name')
                           str_hist{att} = ['; updated name of column ',s.name{col},' to ',att_val];
                        else                           
                           str_hist{att} = ['; updated ',att_name,' for column ',s.name{col},' from ', ...
                              s.(att_name){col},' to ',att_val];
                        end
                     else
                        str_hist{att} = ['; updated ',att_name,' from ',int2str(s.(att_name)(col)), ...
                           ' to ',int2str(att_val)];
                     end
                  end
                  
               else
                  badvals(att) = 1;
               end
               
            end
            
            %validate updated structure
            if sum(badvals) < length(attrib_names)
               
               [val,stype,msg0] = gce_valid(s2,'data');
               
               if val == 0 || ~strcmp(stype,'data')
                  
                  %clear output and report validation errors
                  s2 = [];
                  msg = ['the updated structure is not valid: ',msg0];
                  
               else
                  
                  %reformat history entry
                  str_hist = char(concatcellcols(str_hist(:)',''));
                  if length(str_hist) > 3
                     str_hist = str_hist(3:end);
                  end
                  str_hist = ['updated attribute metadata descriptors (''update_attributes''): ',str_hist];
                  
                  %update structure history
                  curdate = datestr(now);
                  s2.editdate = curdate;
                  s2.history = [s2.history ; {curdate} {str_hist}];
                  
                  %generate bad attributes error message
                  if sum(badvals) > 0                     
                     Ibad = find(badvals);
                     if length(Ibad) == 1
                        msg = ['invalid attribute value for ',attrib_names{Ibad}];
                     else
                        msg = ['invalid attribute values for ',cell2commas(attrib_names(Ibad,1))];
                     end                     
                  end
                  
               end
               
            else
               
               %clear structure if all updates failed
               s2 = [];
               msg = 'no valid updates could be performed';
               
            end               
            
         else
            
            %generate bad attribute error message
            Ibad = find(bad_attribs);
            if length(Ibad) > 1
               badlist = cell2commas(attrib_names(Ibad),1);
               msg = [badlist,' are not valid data structure attributes'];
            else
               msg = [attrib_names{Ibad},' is not a valid data structure attribute'];
            end
            
         end
         
      else
         
         if length(col) ~= 1
            msg = 'invalid column selection';
         else
            msg = 'attribe name and values must match';
         end
         
      end
      
   else
      msg = 'invalid data structure';
   end
   
else
   msg = 'insufficient input for function';
end