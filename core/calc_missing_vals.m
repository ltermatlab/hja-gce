function [s2,msg] = calc_missing_vals(s,cols,expr,logopt,flag,flagdef)
%Fills in missing values in one or more columns of a GCE Data Structure using a calculated expression
%
%syntax:  [s2,msg] = calc_missing_vals(s,cols,expr,logopt,flag,flagdef)
%
%inputs:
%  s = data structure to modify
%  cols = array of column numbers or names to update
%  expr = valid MATLAB expression for calculating fill values (column values will substituted for
%     column names, e.g. '(Max_Temp+Min_Temp)./2' to calculate Mean_Temp values from Max_Temp and 
%     Min_Temp column values)
%  logopt = maximum number of value changes to log per column to the processing history field
%     (0 = none, default = 100, inf = all)
%  flag = Q/C flag to assign to interpolated values (default = 'E', '' for no flagging)
%  flagdef = Q/C flag definition to add if flag is not listed in the metadata
%     (default = 'data value estimated by computation')
%
%outputs:
%  s2 = modified data structure
%  msg = text of any error message
%  expression = actual MATLAB expression evaluated (for debugging or documentation purposes)
%
%
%usage notes:
%  1. 'expr' must evaluate to a numeric or text array compatible with the column data type
%  2. scalar numeric values or character arrays will be replicated to match the length of
%     missing values in each column (see 'add_calcexpr.m')
%  3. if no values are filled (e.g. no missing values exist or 'expr' does not return valid data)
%     then the original structure will be return unmodified with a warning in 'msg'
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
%last modified: 15-Nov-2012

%init output
s2 = [];
msg = '';

%check for required arguments
if nargin >= 3
   
   %validate data structure
   if gce_valid(s,'data')
      
      %validate log option
      if exist('logopt','var') ~= 1
         logopt = 100;
      elseif isempty(logopt) || ~isnumeric(logopt)
         logopt = 100;
      end
      
      %validate flag argument or assign default
      if exist('flag','var') ~= 1
         flag = 'E';
      elseif ~ischar(flag)
         flag = 'E';
      elseif length(flag) > 1
         flag = flag(1);
      end
      
      %validate falgdef argument and assign default if omitted
      if exist('flagdef','var') ~= 1
         flagdef = 'data value estimated by computation';
      end
      
      %validate column selection
      if ~isnumeric(cols)
         cols = name2col(s,cols);  %perform name to number translation
      else
         cols = intersect(cols,(1:length(s.name)));  %remove invalid column selections
      end
      
      %check for valid column selection and non-empty expression
      if ~isempty(cols) && ~isempty(expr)
         
         %check for scalar constant first
         newvals = str2double(expr);
         
         %call add_calcexpr function if str2double returns NaN
         if isnan(newvals)
            s_tmp = add_calcexpr(s,expr,'Calc_Missing_Vals_Data','','',1,1,'');
            if ~isempty(s_tmp)
               newvals = extract(s_tmp,'Calc_Missing_Vals_Data');
            else
               newvals = [];
            end
         end
         
         %check for valid return data from expression
         if ~isempty(newvals)
            
            %init output structure
            s2 = s;
            
            %add history entry to capture expression and column list
            s2.editdate = datestr(now);
            s2.history = [s2.history ; {datestr(now), ...
               ['replaced missing values in column(s) ',cell2commas(s.name(cols)), ...
               ' with values calculated from the MATLAB expression ''',expr,''' (''calc_missing_vals'')']}];
            
            %add flag definition if doesn't exist
            if ~isempty(flag) && ~isempty(flagdef)
               
               %get existing flag code list
               meta = lookupmeta(s2,'Data','Codes');
               
               %check for existing entry, add if missing
               if isempty(strfind(meta,[flag,' = ']))
                  if isempty(meta)
                     meta = [flag,' = ',flagdef];
                  else
                     meta = [meta,', ',flag,' = ',flagdef];
                  end
                  s2 = addmeta(s2,{'Data','Codes',meta},0,'calc_missing_vals');
               end
               
            end
                        
            %init indices of skipped and bad columns
            skippedcols = zeros(length(cols),1);
            badcols = skippedcols;
            
            %loop through columns replacing missing values
            for n = 1:length(cols)
               
               col = cols(n);  %get column index
               
               vals = extract(s,col);  %get column values
               
               %check for compatible data types
               if (isnumeric(vals) && isnumeric(newvals)) || (iscell(vals) && iscell(newvals))

                  Imissing = find(isnan(vals));  %get index of missing numeric valies
                  
                  if ~isempty(Imissing)
                     
                     if length(newvals) == 1
                        vals(Imissing) = newvals;  %update all missing with scalar newval
                     elseif length(newvals) == length(vals)
                        vals(Imissing) = newvals(Imissing);  %update missing vals with corresponding newvals
                     else
                        vals = [];  %record mismatch
                        skippedcols(n) = 1;  %flag as skipped column
                     end
                     
                     %lock qa/qc flags then update data column values, specifying logging option and flag
                     if ~isempty(vals)
                        s2 = flag_locks(s2,'lock',col);  %lock flags
                        s2 = update_data(s2,col,vals,logopt,flag);  %update values
                     end
                     
                  else
                     skippedcols(n) = 1;
                  end
                  
               else                  
                  badcols(n) = 1;  %flag column as bad due to incompatible data types                  
               end
               
            end
            
            %check for bad/skipped columns and generate error message
            goodcols = find(skippedcols == 0 & badcols == 0);
            
            %check for bad/skipped columns, generate error message
            if isempty(goodcols)
               
               s2 = s;  %revert structure to original
               msg = ['Failed to fill any missing values in column(s) ',cell2commas(s.name(cols),1),' - update skipped'];
               
            elseif length(goodcols) < length(cols)
               
               %init error message
               msg = ['Failed to fill in missing values in ',int2str(length(cols)-length(goodcols)),' column(s): '];
               
               %add list of bad cols
               Ibad = find(badcols);
               if ~isempty(Ibad)
                  msg = [msg,' errors occurred updating column(s) ',cell2commas(s.name(cols(Ibad)),1),', '];
               end
               
               %add list of skipped cols
               Iskipped = find(skippedcols);
               if ~isempty(Iskipped)
                  msg = [msg,' no missing values were replaced in column(s) ',cell2commas(s.name(cols(Iskipped)),1),', '];
               end
               
               %remove terminal semicolon
               msg = msg(1:end-2);
               
            end
            
         else
            msg = 'The expression could not be evaluated - check for syntax errors';
         end
         
      else  %bad column selection or expression
         
         if isempty(cols)
            msg = 'Tnvalid column selection';
         else
            msg = 'Tnvalid expression';
         end         
         
      end
      
   else
      msg = 'Tnvalid data structure';
   end
   
else
   msg = 'Insufficient arguments for function';
end