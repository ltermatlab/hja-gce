function [s,msg] = sql2struct(conn,qry,maxrows)
%Executes an SQL statement on the specified data source and returns a multidimensional structure with field names
%derived from resultset fields, and one dimension per row
%
%syntax: [s,msg] = sql2struct(conn,qry,maxrows)
%
%inputs:
%   conn = database connection object (see 'database' function in Database toolbox)
%   qry = SQL SELECT statement
%   maxrows = maximum number of rows to return (omitted or 0 = all)
%
%outputs:
%   s = data structure
%   msg = message indicating success or failure (with error text)
%
%
%(c)2007-2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 03-Sep-2014

%init outputs
s = [];
msg = '';

if nargin >= 2
   
   %init runtimes
   data = [];
   meta = [];
   
   %set default option for maxrows
   if exist('maxrows','var') ~= 1
      maxrows = 0;
   end
   
   %check for database object
   if isobject(conn)
      
      %check for JDBC error message
      if isempty(conn.Message)
         
         %execute query
         curs = exec(conn,qry);
         
         %check for error message
         if isempty(curs.Message)
            
            %grab data
            try
               curs = fetch(curs,maxrows);
               data = curs.Data;
               meta = attr(curs);
               close(curs);
            catch e
               data = [];
               meta = [];
               msg = ['A MATLAB error occurred (',e.message,')'];
            end
            
         else
            msg = ['Query execution error: ',curs.Message];
         end
         
      else
         msg = ['Database connection error: ',conn.Message];
      end
      
   else
      msg = 'Invalid database connection object';
   end
   
   %if data retrieved grab fieldnames from JDBC metadata
   if ~isempty(data)
      
      %check for struct or cell array based on setdbpref options
      if isstruct(data)
         
         %get structure field names
         flds = fieldnames(data);
         
         %init cell array for parsing individual arrays into separate structure dimensions
         ar = cell(length(data.(flds{1})),length(flds));
         
         %add struct field contents to cell array
         for num = 1:length(flds)
            vals = data.(flds{num});
            if isnumeric(vals)
               vals = num2cell(vals);
            end
            ar(:,num) = vals;
         end
         
         %convert cell array into a multi-dimensional struct for parity with cell array return
         s = cell2struct(ar,flds,2);
         
      else  %cell array data
         
         %grab fieldnames into cell array
         colnames = {meta.fieldName};
         
         %determine number of data columns
         numcols = size(data,2);
         
         %check for correspondence of query columns, resultset array
         if numcols == length(colnames)
            
            %convert resultset columns into a structure with fields named according to query attributes
            if numcols > 1 || ~strcmpi(data(1),'No Data')
               try
                  s = cell2struct(data,colnames,2);
               catch e
                  s = [];
                  msg = ['Error creating structure from resultset - check for unsupported field names (',e.message,')'];
               end
            end
            
         end
         
      end
      
   end
   
   %check for null results and no error message
   if isempty(s) && isempty(msg)
      msg = 'Query returned no data';
   end
   
end