function [s2,msg] = minvalue2zero(s,cols,minvalue,metadata,flag)
%Converts values in specified columns of a GCE Data Structure below a minimum threshold to zero
%
%syntax: [s2,msg] = minvalue2zero(s,cols,minvalue,metadata,flag)
%
%inputs:
%  s = data structure to modify (required)
%  cols = list of column names or numbers (required)
%  minvalue = minimum value (required)
%  metadata = metadata update option
%    0 = do not log changes to the metadata or structure history
%    1 = log changes (default)
%  flag = Q/C flag to assign for revised values (default = '' for none)
%
%outputs:
%  s2 = modified structure
%  msg = text of any error messages
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
%last modified: 17-Apr-2013

s2 = [];
msg = '';

if nargin >= 3 && isnumeric(minvalue)

   %assign defaults for omitted arguments
   if exist('metadata','var') ~= 1
      metadata = 1;
   end
   
   if exist('flag','var') ~= 1
      flag = '';
   end

   if gce_valid(s,'data')

      if ~isnumeric(cols)
         cols = name2col(s,cols);
      end

      if ~isempty(cols)

         Inonstring = find(~strcmp(s.datatype(cols),'s'));  %get index of non-text column selections

         if ~isempty(Inonstring)
            
            s2 = s;  %copy structure to output
            
            %add provisional history entry
            s2.history = [s2.history ; ...
               {datestr(now)},{['converted values below ',num2str(minvalue),' in column(s) ', ...
               cell2commas(s2.name(cols),1),' to zero (''minvalue2zero'')']}];
            
            cols = cols(Inonstring);  %remove any text columns from column selection
            
            %init history buffers, counter
            anomstr = '';
            updates = 0;
            
            %loop through columns performing and logging substitution
            for n = 1:length(cols)
               
               col = cols(n);  %get column index
               vals = extract(s2,col);  %get column values
               Ilow = find(vals < minvalue);  %get index of values below the minimum
               
               if ~isempty(Ilow)
                  
                  updates = updates + 1;  %inc update total
                  vals(Ilow) = 0;  %zero values
                  
                  s2 = update_data(s2,col,vals);  %apply updates and log changes
                  
                  %add flag if specified
                  if ~isempty(flag)
                     s2 = addflags(s2,col,Ilow,flag);
                  end
                  
               end
               
            end
            
            %check for any changes
            if updates > 0
               
               s2.editdate = datestr(now);  %update revision date

               %update metadata if specified
               if metadata == 1
                  %add history entry to original history field to omit redundant dataflag entries
                  anom = lookupmeta(s2,'Data','Anomalies');
                  if isempty(anom) || strcmpi(anom,'none noted') || strcmpi(anom,'none')
                     anom = anomstr(2:end);
                  else
                     anom = [anom,anomstr];
                  end
                  s2 = addmeta(s2,{'Data','Anomalies',anom},0,'minvalue2zero');
               end
               
            else
               s2 = s;  %revert structure to remove provisional history entry               
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
   msg = 'insufficient arguments for function';
end