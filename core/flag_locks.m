function [s2,msg] = flag_locks(s,lock_option,cols)
%Locks or unlocks Q/C flag criteria for specified columns in a GCE-LTER data structure
%
%syntax: [s2,msg] = flag_locks(s,lock_option,cols)
%
%inputs:
%  s = data structure to update
%  lock_option = lock option:
%    'lock' = lock Q/C criteria (add 'manual' token)
%    'unlock' = unlock Q/C criteria (remove 'manual' token, recalculate flags)
%  cols = arrays of column numbers or names (default = [] for all columns)
%
%outputs:
%  s2 = updated structure
%  msg = text of any error message
%
%
%(c)2008 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%Wade M. Sheldon
%School of Marine Programs
%University of Georgia
%Athens, GA 30602 USA
%email: sheldon@uga.edu
%
%last modified: 22-Oct-2008

s2 = [];
msg = '';

if nargin >= 2
   
   if gce_valid(s,'data') == 1
      
      %update all columns if cols omitted
      if exist('cols','var') ~= 1
         cols = [];
      end
      
      %validate column list
      if isempty(cols)
         cols = [1:length(s.name)];  %choose all
      elseif ~isnumeric(cols)
         cols = name2col(s,cols);  %resolve column names
      else
         cols = intersect(cols,[1:length(s.name)]);  %remove invalid columns from numeric array
      end
      
      if ~isempty(cols)

         %check for supported flag operation
         if inlist(lock_option,{'lock','unlock'},'insensitive')
            
            s2 = s;  %init output structure
            dirtycols = [];  %init modified columns array
            str_hist = '';  %init history update
            
            %lock/unlock flags and set dirty flag for modified columns
            if strcmpi(lock_option,'lock')
               
               for n = 1:length(cols)
                  crit = s2.criteria{cols(n)};  %extract Q/C criteria
                  if isempty(crit)
                     crit = 'manual';
                     dirtycols = [dirtycols,cols(n)];
                  elseif isempty(strfind(crit,'manual'))
                     crit = [crit,';manual'];
                     dirtycols = [dirtycols,cols(n)];
                  end
                  s2.criteria{cols(n)} = crit;  %update Q/C criteria
               end

               if ~isempty(dirtycols)
                  if length(dirtycols) > 1
                     str_hist = ['locked Q/C flag criteria for columns ',cell2commas(s.name(dirtycols),1), ...
                           ' to prevent automatic evaluation (''flag_locks'')'];
                  else
                     str_hist = ['locked Q/C flag criteria for column ',cell2commas(s.name(dirtycols),1), ...
                           ' to prevent automatic evaluation (''flag_locks'')'];
                  end
               end
               
            else %unlock
               
               for n = 1:length(cols)
                  crit = s2.criteria{cols(n)};  %extract Q/C criteria
                  if ~isempty(crit) && ~isempty(strfind(crit,'manual'))
                     dirtycols = [dirtycols,cols(n)];
                     crit = strrep(strrep(crit,'manual',''),';;',';');  %remove manual token and redundant separators
                     if ~isempty(crit) && strcmp(crit(end),';')
                        crit = crit(1:end-1);  %strip terminal criteria separator
                     end
                  end
                  s2.criteria{cols(n)} = crit;
               end

               if ~isempty(dirtycols)
                  if length(dirtycols) > 1
                     str_hist = ['unlocked Q/C flag criteria for columns ',cell2commas(s.name(dirtycols),1), ...
                           ' to restore automatic evaluation (''flag_locks'')'];
                  else
                     str_hist = ['unlocked Q/C flag criteria for column ',cell2commas(s.name(dirtycols),1), ...
                           ' to restore automatic evaluation (''flag_locks'')'];
                  end
               end
               
            end

            %update processing history and recalc flags if necessary
            if ~isempty(dirtycols)
               s2.history = [s2.history ; {datestr(now),str_hist}];
               if strcmp(lock_option,'unlock')
                  s2 = dataflag(s2,dirtycols);  %regenerate flags for unlocked columns               
               end
            end               

         else
            msg = 'unsupported lock operation';
         end
         
      else
         msg = 'column selections are invalid';
      end
            
   else
      msg = 'invalid data structure';
   end
   
else
   msg = 'insufficient inputs for function';   
end