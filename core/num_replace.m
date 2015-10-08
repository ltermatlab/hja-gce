function [s2,msg] = num_replace(s,cols,oldval,newval,logopt,flag)
%Search and replace numeric values in specified columns of a GCE Data Structure with a new value
%
%syntax: [s2,msg] = num_replace(s,cols,oldval,newval,logopt,flag)
%
%inputs:
%  s = data structure to update - required
%  cols = array of column names or numbers to update (text columns will be ignored) - required
%  oldval = scalar number or text expression containing criteria to match - required
%     (e.g. 10 or 'Air_Temp < 0 & Precip > 0')
%  newval = scalar number to substitute for matched values - required
%  logopt = maximum number of value changes to log to the processing history field
%     (0 = none, default = 100, inf = all)
%  flag = Q/C flag to assign for revised values (default = '' for none)
%
%outputs:
%  s2 = modified structure
%  msg = text of any error messages
%
%(c)2011-2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 17-Apr-2013

s2 = [];
msg = '';

%check for required input
if nargin >= 4 && ~isempty(oldval) && isnumeric(newval) && length(newval) == 1
   
   if gce_valid(s,'data') == 1
      
      %supply default log option if omitted
      if exist('logopt','var') ~= 1
         logopt = 100;
      end
      
      %assign default flag option
      if exist('flag','var') ~= 1
         flag = '';
      end
      
      %get column index if names specified
      if ~isnumeric(cols)
         cols = name2col(s,cols);
      end
      
      if ~isempty(cols)
         
         %get index of non-text column selections
         Inonstring = find(~strcmp(s.datatype(cols),'s'));
         
         if ~isempty(Inonstring)
            
            cols = cols(Inonstring);  %remove any text columns from column selection
            
            s2 = s;  %copy structure to output
            
            %init history entry
            if ischar(oldval)
               str_hist = ['replaced values matching ''',oldval,''' in column(s) ',cell2commas(s2.name(cols),1), ...
                  ' with ',num2str(newval),' (''num_replace'')'];
            else
               str_hist = ['replaced values of ',num2str(oldval),' in column(s) ',cell2commas(s2.name(cols),1), ...
                  ' with ',num2str(newval),' (''num_replace'')'];
            end
            s2.history = [s.history ; {datestr(now)},{str_hist}];
            
            updates = 0;  %init change counter
            
            %loop through columns performing and logging substitution
            for n = 1:length(cols)
               
               col = cols(n);  %get column index
               
               vals = extract(s2,col);  %get column values
               
               if ischar(oldval)
                  %run querydata to get index for text criteria
                  [s_tmp,numrows,qry,msg0,Imatch] = querydata(s2,oldval);  %#ok<ASGLU>
               elseif isnan(oldval)
                  Imatch = find(isnan(vals));  %get index of NaN values
               else
                  Imatch = find(vals == oldval);  %get index of matching numeric values
               end
               
               %check for matches
               if ~isempty(Imatch)
                  updates = updates + 1;  %increment counter
                  vals(Imatch) = newval;  %replace matched values
                  [s2,msg0] = update_data(s2,col,vals,logopt);  %update dataset columns and log changes
                  if isempty(s2)
                     msg = ['an error occurred updating values for column ',int2str(col),': ',msg0];
                     break
                  elseif ~isempty(flag)
                     s2 = addflags(s2,col,Imatch,flag);  %add q/c flags for updated values
                  end
               end
               
            end
            
            %check for any changes, reverse changes to history if none
            if updates == 0
               s2 = s;  %revert changes to history if no matches found
               msg = 'no matching values were found';
            end
            
         else
            msg = 'invalid column selection (only numeric columns are supported)';
         end
         
      else
         msg = 'invalid column selection';
      end
      
   else
      msg = 'invalid gce data structure';
   end
   
else
   if nargin < 4
      msg = 'insufficient arguments for function';
   else
      msg = 'invalid original or replacement value specified';
   end
end