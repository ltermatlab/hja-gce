function [s2,msg] = update_values(s,col,newdata,rows,logopt,flag,flagdef)
%Updates selected values in a GCE Data Structure column based on a row index
%
%syntax: [s2,msg] = update_values(s,col,newdata,rows,logopt,flag,flagdef)
%
%inputs:
%  s = structure to modify (struct; required)
%  col = column number or name to update (integer or string; required)
%  newdata = new data values (numeric or cell array compatible with the column data type; required)
%  rows = index of rows to update matching the length of newdata (integer array; required)
%  logopt = maximum number of value changes to log to the processing history field
%    (integer; optional; default = 100, 0 = none, inf = all)
%  flag = flag to assign for revised data values (string; optional; default = '' for no flag)
%  flagdef = definition of flag if not already registered in the metadata (string; optional;
%    default = 'revised value' or '' if flag = '')
%
%outputs:
%  s2 = updated structure
%  msg = text of any error messages
%
%notes:
%  1) if newdata is a character array, it will be converted to a cell array of strings automatically
%
%  
%(c)2013-2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
%
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
%last modified: 15-Jan-2015

s2 = [];

if nargin >= 4 && gce_valid(s,'data')
   
   %check for character array newdata
   if ischar(newdata)
      try
         newdata = trimstr(cellstr(newdata));
      catch
         newdata = [];
      end
   end
   
   %force column orientation
   newdata = newdata(:);
   
   %check for matching data and row arrays
   if isnumeric(rows) && length(newdata) == length(rows)
      
      %lookup column names or validate column selection
      if ~isnumeric(col)
         col = name2col(s,col);
      else
         col = intersect(col,(1:length(s.name)));
      end
      
      %check for matched column
      if ~isempty(col)
         
         %supply default logopt if omitted
         if exist('logopt','var') ~= 1
            logopt = 100;
         end
         
         %set default flag if omitted
         if exist('flag','var') ~= 1
            flag = '';
         elseif ~ischar(flag)
            flag = '';
         elseif length(flag) > 1
            flag = flag(1);
         end
         
         %set default flag_def if omitted
         if isempty(flag)
            flagdef = '';  %force empty definition if no flag assigned
         elseif exist('flagdef','var') ~= 1 || isempty(flagdef)
            flagdef = 'revised value';
         end
         
         %get column data
         vals = extract(s,col);
         
         %check for matching array types
         if (isnumeric(newdata) && isnumeric(vals)) || (iscell(newdata) && iscell(vals))
         
            %perform update
            try
               vals(rows) = newdata;
            catch
               vals = [];
            end
            
            %check for successful update, apply to data structure
            if ~isempty(vals)
               [s2,msg] = update_data(s,col,vals,logopt,flag,flagdef);
            else
               msg = 'an error occurred applying the updates - check newdata format';
            end
            
         else
            msg = 'mismatch between new data and column data type';
         end
         
      else
         msg = 'invalid column selection';
      end
      
   else
      msg = 'mismatch between size of data array and row index';
   end   
   
else
   if nargin < 4
      msg = 'insufficient arguments for function';
   else
      msg = 'invalid data structure';
   end
end