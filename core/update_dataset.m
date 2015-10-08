function [s2,msg] = update_dataset(s,s_update,deleteopt,logopt,matchunits)
%Updates data column values and adds new columns from a second GCE Data Structure and logs all changes in the metadata
%
%syntax: [s2,msg] = update_dataset(s,s_update,deleteopt,logopt,matchunits)
%
%inputs:
%  s = structure to modify
%  s_update = structure containing new and updated data arrays
%  deleteopt = option to delete columns in s that are not present in s_update
%    0 = no
%    1 = yes (default)
%  logopt = maximum number of value changes to log to the processing history field
%    (0 = none, default = 100, inf = all)
%  matchunits = option to require matching units in update columns (in addition to name, data type and variable type)
%    0 = no (default)
%    1 = yes
%
%outputs:
%  s2 = updated structure
%  msg = text of any error messages
%
%notes:
%  1) the number of records in each dataset must match
%  2) new columns in s_update that are not present in s will be added to the output structure
%
%
%(c)2002-2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 23-Dec-2014

s2 = [];
msg = '';

%check for minimum required arguments
if nargin >= 2
   
   %set default deleteopt if omitted
   if exist('deleteopt','var') ~= 1 || isempty(deleteopt) || deleteopt ~= 1
      deleteopt = 0;
   end
   
   %set default logopt if omitted
   if exist('logopt','var') ~= 1 || isempty(logopt)
      logopt = 100;
   end

   %set default matchunits if omitted
   if exist('matchunits','var') ~= 1 || isempty(matchunits) || matchunits ~= 0
      matchunits = 1;
   end
   
   %validate data structures
   val1 = gce_valid(s,'data');
   val2 = gce_valid(s_update,'data');
   
   if val1 == 1 && val2 == 1
      
      %get number of records
      len1 = num_records(s);
      len2 = num_records(s_update);
      
      %verify same size table
      if len1 == len2

         %init output and error counter
         s2 = s;
         err = 0;
         
         %get intersection of column names
         [tmp,Iupdatecols,Isourcecols] = intersect(s_update.name,s2.name);
         
         %loop through matching columns checking for updates
         for n = 1:length(Isourcecols)
            
            %get column indices
            s_col = Isourcecols(n);
            u_col = Iupdatecols(n);
            
            %compare attributes
            if strcmp(s2.datatype{s_col},s_update.datatype{u_col}) && ...
                  strcmp(s2.variabletype{s_col},s_update.variabletype{u_col}) && ...
                  (matchunits == 0 || strcmpi(s2.units{s_col},s_update.units{u_col}))
               
               %extract values for comparison
               newvals = extract(s_update,u_col);
               
               %call update_data, which will ignore unchanged values
               [s2,msg0] = update_data(s2,s_col,newvals,logopt);
               if isempty(s2)
                  err = 1;
                  msg = ['an error occurred updating the values in column ',s2.name{s_col},' (',msg0,')'];
                  break
               end
               
            else
               err = 1;
               msg = ['mismatched attribute metadata in column ',s2.name{s_col}];
               break
            end
            
         end
         
         if err == 0
            
            %add new columns from s_update to the end of s
            [tmp,Iadd] = setdiff(s_update.name,s2.name);
            
            for n = 1:length(Iadd)
               
               %get column index
               col = Iadd(n);
               
               %extract values
               newvals = extract(s_update,col);
               
               %add values and attributes
               s2 = addcol(s2,newvals, ...
                  s_update.name{col}, ...
                  s_update.units{col}, ...
                  s_update.description{col}, ...
                  s_update.datatype{col}, ...
                  s_update.variabletype{col}, ...
                  s_update.numbertype{col}, ...
                  s_update.precision(col), ...
                  s_update.criteria{col}, ...
                  []);
            end
            
            %remove unmatched columns in s if specified
            if deleteopt == 1
               
               %get column index
               [tmp,Idel] = setdiff(s.name,s_update.name);
               
               %delete columns
               if ~isempty(Idel)
                  s2 = deletecols(s2,Idel);
               end
               
            end
            
         end

      else
         msg = 'mismatched number of records in data structures';
      end
      
   else
      if val1 == 0
         msg = 'source data structure is invalid';
      else
         msg = 'update data structure is invalid';
      end
   end
   
else
   msg = 'insufficient arguments';
end