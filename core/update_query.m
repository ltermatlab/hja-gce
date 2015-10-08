function [s2,msg,I_match] = update_query(s,col,newval,qry,logopt,flag,flagdef)
%Updates values in a GCE Data Structure column for rows matching specified query criteria
%
%syntax: [s2,msg,I_inc] = update_query(s,col,newval,qry,logopt,flag,flagdef)
%
%inputs:
%  s = structure to modify (struct; required)
%  col = column number or name to update (integer or string; required)
%  newval = new value to substitute for all matched rows (scalar number or string matching col datatype; required)
%  qry = a query statement consisting of one or more row selection criteria strings, either
%    combined using parentheses and boolean operations (&,| or AND,OR) or as separate statements
%    concatenated using semicolons (implies AND/&). Data columns can be referenced by name or
%    using the col[#] alias, such as col2 or col10 (string; required)
%      examples:
%        col1>13;col2<20
%        salinity > 30 and temperature >= 20 and temperature <= 30
%        year == 2000 (equivalents: year is 2000, year = 2000)
%        strcmpi(Type,'ctd') <-- MATLAB string comparison function syntax (strcmp,strncmp,strmatch,etc)
%  logopt = maximum number of value changes to log to the processing history field
%    (0 = none, default = 100, inf = all)
%  flag = flag to assign for revised data values (default = '' for no flag)
%  flagdef = definition of flag if not already registered in the metadata (string; optional;
%    default = 'revised value' or '' if flag = '')
%
%outputs:
%  s2 = updated structure
%  msg = text of any error messages
%  I_match = index of rows matched by the query
%
%notes:
%  1) if the specified qry does not return any rows or querydata() returns an error
%     the unmodified structure will be returned with a warning message
%
%  
%(c)2014-2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
I_match = [];

if nargin >= 4 && gce_valid(s,'data') && ischar(qry) && ~isempty(qry)

   %lookup column names or validate column selection
   if ~isnumeric(col)
      col = name2col(s,col);
   else
      col = intersect(col,(1:length(s.name)));
   end
   
   %check for matched column
   if ~isempty(col) && length(col) == 1
      
      %validate newval and convert to cell array if string
      dtype = get_type(s,'datatype',col);      
      if strcmp(dtype,'s')
         if ischar(newval)
            newval = {newval};  %convert string to cell array
         elseif iscell(newval)
            if length(newval) > 1
               newval = [];  %invalid array length
            end
         else
            newval = [];  %unsupported format
         end
      elseif ~isnumeric(newval) || length(newval) > 1
         newval = [];  %unsupported format
      end
      
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
      
      %set default flagdef if omitted
      if isempty(flag)
         flagdef = '';  %force empty definition if no flag assigned
      elseif exist('flagdef','var') ~= 1 || isempty(flagdef)
         flagdef = 'revised value';
      end
   
      %check for matching array types
      if ~isempty(newval)
         
         %run query
         [I_match,msg0] = query_index(s,qry);
         
         %check for matching data and row arrays
         if ~isempty(I_match)
            
            %replicate newval to match query return rows
            numrows = length(I_match);
            newvals = repmat(newval,numrows,1);
            
            %check for successful update, apply to data structure
            [s2,msg] = update_values(s,col,newvals,I_match,logopt,flag,flagdef);
            
            %generate string formatted newval
            if iscell(newval)
               newval_str = char(newval);
            else
               newval_str = num2str(newval);
            end
            
            %generate flag assignment string for history
            if ~isempty(flag)
               flagstr = [' and flagged any revised values as ''',flag,''''];
            else
               flagstr = '';
            end
            
            %generate processing history entry, skipping generic update_values step
            str_hist = ['updated values in ',int2str(numrows),' row(s) of column ',s2.name{col}, ...
               ' to ',newval_str,flagstr,', based on the query ''',qry,''' (''update_query'')'];            
            s2.history = [s.history ; {datestr(now)} {str_hist}];
            
         else
            s2 = s;
            msg = ['no records matched the specified query - no update performed (',msg0,')'];
         end
         
      else
         msg = 'mismatch between new data and column data type or unsupported array size';
      end

   else
      msg = 'invalid column selection';
   end
   
else  %bad input
   
   if nargin < 4
      msg = 'insufficient arguments for function';
   elseif ~ischar(qry) || isempty(qry)
      msg = 'invalid query';
   else
      msg = 'invalid data structure';
   end
   
end