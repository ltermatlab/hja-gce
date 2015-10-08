function [tbl,msg] = gceds2table(s,flagopt,flagcols)
%Converts data, qualifier flags and metadata from a GCE Data Structure to a MATLAB table object
%
%syntax:  [tbl,msg] = gceds2table(s,flagopt,flagcols)
%
%inputs:
%  s = data structure
%  flagopt = option to convert flags to data columns/arrays
%     'S' = instantiate flags as cell arrays of string columns  (default)
%     'E' = instantiate flags as integer columns and document codes in metadata
%     'N' = do not instantiate flag columns (ignore)
%  flagcols = option specifying which flag arrays to instantiate if flagopt = 'E' or 'S'
%     'mult' = create a flag column/array for every column containing any flagged values (default)
%     'alldata' = create a flag column/array for every column assigned variable type
%        'data' or 'calculation', regardless of whether flags are assigned or not
%     'all' create a flag column/array for every column regardless of flag assignments
%
%output:
%  tbl = MATLAB table object
%  msg = text of any error messages
%
%notes:
%   1) this funtion requires MATLAB R2013a or later with the function struct2table()
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
%last modified: 08-Nov-2013

tbl = [];
msg = '';

if nargin >= 1 && exist('struct2table','file') == 2 && gce_valid(s,'data')
   
   %validate flagopt option
   if exist('flagopt','var') ~= 1 || isempty(flagopt)
      flagopt = 'S';
   end
   
   %validate flagcols option
   if exist('flagcols','var') ~= 1 || isempty(flagcols)
      flagcols = 'all';
   elseif ~strcmpi(flagcols,'alldata') && ~strcmpi(flagcols,'mult')
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
      
      %convert flat structure to table with names derived from fields
      tbl = struct2table(s2);
      
      %add dataset title
      tbl.Properties.Description = s.title;
      
      %add variable units
      tbl.Properties.VariableUnits = s.units;
      
      %add variable descriptions
      tbl.Properties.VariableDescriptions = s.description;
      
      %add formatted doc metadata as userdata
      tbl.Properties.UserData = listmeta(s,'FLED');
      
   catch e
      
      %catch runtime error
      tbl = [];
      msg = ['an error occurred creating the table (',e.message,')'];
      
   end
   
else  %bad input
   
   if nargin == 0
      msg = 'data structure is required';
   elseif exist('struct2table','file') ~= 2
      msg = 'this function requires the ''struct2table'' function in MATLAB R2013b or higher';
   else
      msg = 'invalid data structure';
   end
   
end
