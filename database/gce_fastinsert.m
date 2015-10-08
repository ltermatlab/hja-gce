function msg = gce_fastinsert(s,conn,tablename,cols,fieldnames,maxrows)
%Executes the MATLAB Database Toolbox 'fastinsert' function for selected columns of a GCE Data Structure
%
%syntax:  msg = gce_fastinsert(s,conn,tablename,cols,fieldnames,maxrows)
%
%input:
%  s = GCE Data Structure containing columns to insert into the database
%  conn = MATLAB database toolbox connection structure (see 'help database')
%  tablename = database table name (character array)
%  cols = array of structure column names or indices to insert ([] = all/default)
%  fieldnames = cell array of database field names ([] = use structure column names/default)
%  maxrows = maximum number of rows to insert at once (integer; 0 = unlimited/default)
%
%output:
%  msg = status or error message
%
%notes:
%  1) the Database Toolbox 'fastinsert' function is required
%  2) data column arrays will be inserted as formatted - use GCE Data Toolbox data format
%     and date conversion utilities before calling gce_fastinsert if conversions are required
%  3) if maxrows > 0, fastinsert.m will be called repeatedly until all records are inserted,
%     but will break on errors
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
%last modified: 10-May-2013

msg = '';

%check for required input
if nargin >= 3 && ~isempty(conn) && ~isempty(tablename) && gce_valid(s,'data')
   
   %check for Database Toolbox fastinsert function
   if exist('database/fastinsert','file') == 2
      
      %set default maxrows
      if exist('maxrows','var') ~= 1 || maxrows < 0
         maxrows = 0;
      end
      
      %set default column selection if omitted
      if exist('cols','var') ~= 1
         cols = [];
      end
      
      %validate column selection
      if isempty(cols)
         cols = s.name';  %use all columns if omitted
      elseif isnumeric(cols)
         try
            cols = s.name(cols);  %get column names
         catch
            cols = [];  %column index error
         end
      else
         if ischar(cols)
            cols = cellstr(cols);  %convert character array to cell
         end
         if length(intersect(cols,s.name)) < length(cols)
            cols = [];  %mismatched column present
         end
      end
      
      %check for valid columns
      if ~isempty(cols)
         
         %supply default fieldnames if omitted
         if exist('fieldnames','var') ~= 1
            fieldnames = [];
         end
         
         %validate fieldnames
         if isempty(fieldnames)
            fieldnames = cols;
         elseif ischar(fieldnames)
            fieldnames = cellstr(fieldnames);
         end
         
         %check for matching cols, fieldnames
         if length(cols) == length(fieldnames)
            
            %get total number of records
            numrows = num_records(s);
            
            %check for unlimited option
            if maxrows == 0 || maxrows > numrows
               maxrows = numrows;
            end               

            %calculate number of passes
            numpasses = ceil(numrows./maxrows);
            
            for n = 1:numpasses
               
               %calculate starting and ending row indices
               Istart = maxrows * (n-1) + 1;
               if n < numpasses
                  Iend = maxrows * n;
               else
                  Iend = numrows;  %use actual number for last interval
               end
               
               %subset data structure
               s_temp = copyrows(s,(Istart:Iend),'Y');

               %generate cell array from data structure
               data = gceds2cell(s_temp,cols);
               
               %perform insert, trapping errors
               try
                  fastinsert(conn,tablename,fieldnames,data);
               catch e
                  msg = ['an error occurred inserting records ', ...
                     int2str(Istart),' to ',int2str(Iend),': ',e.message];
                  break
               end
               
            end
            
         else
            msg = 'mismatch between number of columns and database fields';
         end
         
      else
         msg = 'invalid column selection';
      end
      
   else
      msg = 'the function database/fastinsert is not available in MATLAB';
   end
   
else
   if nargin < 3
      msg = 'insufficient arguments for function';
   else
      msg = 'invalid database connection, tablename or data structure';
   end
end