function [s2,msg] = gceds2struct(s,dim,flagopt,flagcols)
%Converts columns of a GCE Data Structure to a standard structure variable with fields named based on columns
%
%syntax:  [s2,msg] = gceds2struct(s,dim,flagopt,flagcols)
%
%inputs:
%  s = data structure
%  dim = structure dimension option:
%     'scalar' = scalar structure with each field containing an array (default)
%     'mult' = multidimensional structure with each field containing a scalar value (1 dimension per data row)
%  flagopt = option to convert flags to data columns/arrays
%     'S' = instantiate flags as cell arrays of string columns  (default)
%     'E' = instantiate flags as integer columns and document codes in metadata
%     'N' = do not instantiate flag columns (ignore)
%  flagcols = option specifying which flag arrays to instantiate if flagopt = 'E' or 'S'
%     'mult' = create a flag column/array for every column containing any flagged values (default)
%     'alldata' = create a flag column/array for every column assigned variable type
%        'data' or 'calculation', regardless of whether flags are assigned or not
%     'mult+data' = combination of 'mult' and 'alldata', creating flag columns/arrays for
%        every 'data' or 'calculation' column plus any other columns with flags assigned
%     'all' create a flag column/array for every column regardless of flag assignments
%
%output:
%  s2 = standard struct with fields named according to column names
%  msg = text of any error messages
%
%
%(c)2013-2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 06-Sep-2014

msg = '';

if nargin >= 1 && gce_valid(s,'data')
   
   %validate fmt option
   if exist('dim','var') ~= 1 || ~strcmpi(dim,'mult')
      dim = 'scalar';
   end
   
   %validate flagopt option
   if exist('flagopt','var') ~= 1 || isempty(flagopt)
      flagopt = 'S';
   end
   
   %validate flagcols option
   if exist('flagcols','var') ~= 1 || isempty(flagcols)
      flagcols = 'all';
   elseif ~inlist(flagcols,{'mult','alldata','mult+data'})
      flagcols = 'all';
   end
   
   %instantiate flags as data columns
   if strcmpi(flagopt,'E') || strcmpi(flagopt,'S')
      if strcmpi(flagopt,'S')
         s = flags2cols(s,flagcols,0,0,1,0);  %add flag columns for all data/calculation columns as cell arrays
      else
         s = flags2cols(s,flagcols,0,0,1,1);  %add flag columns for all data/calculation columns as encoded integers
      end
   end
   
   %get number of cols and rows
   numcols = length(s.name);
   numrows = num_records(s);
   
   %init struct
   try
      
      if strcmp(dim,'mult')
         
         s2 = cell2struct(cell(numrows,numcols),s.name,2);
         
         %populate multi-dimensional struct
         for c = 1:numcols
            colname = s.name{c};
            vals = extract(s,c);
            if iscell(vals)
               for r = 1:numrows
                  s2(r,1).(colname) = vals{r};
               end
            else
               for r = 1:numrows
                  s2(r,1).(colname) = vals(r);
               end
            end
         end
         
      else  %scalar
         
         %scalar struct of arrays
         s2 = cell2struct(s.values,s.name,2);
         
      end
      
   catch e
      
      %catch runtime error
      s2 = [];
      msg = ['an error occurred creating the structure (',e.message,')'];
      
   end
   
else  %bad input
   
   if nargin == 0
      msg = 'data structure is required';
   else
      msg = 'invalid data structure';
   end
   
end
