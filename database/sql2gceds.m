function [s,msg,coltypes,vals] = sql2gceds(conn,qry,template,autoclose,maxrows,debugfile)
%Executes an SQL query on the specified data source and returns the results as a GCE Data Structure
%
%syntax: [s,msg,coltypes,values] = sql2gceds(conn,qry,template,autoclose,maxrows,debugfile)
%
%input:
%   conn = database connection object or name of connection script (required)
%   qry = SQL statement (required)
%   template = metadata template to apply (default = '' for none)
%   autoclose = option to automatically close the database connection after running the query
%      to support use in automated workflows when 'conn' is a database connection function 
%      (0 = no, 1 = yes/default)
%   maxrows = maximum number of rows to return (default = 0 for all)
%   debugfile = option to save a debug file 'sql2gceds_debug.mat' for troubleshooting data type
%      mapping issues (0 = no/default, 1 = yes)
%
%output:
%   s = data structure
%   msg = message indicating success or failure (with error text)
%   coltypes = JDBC column types (for debugging)
%   values = cell array of values from the resultset
%
%
%(c)2002-2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 20-Jun-2013

%init output
s = [];
msg = '';
coltypes = [];
vals = [];

if nargin >= 2

   %validate template
   if exist('template','var') ~= 1
      template = '';
   end
   
   %validate maxrows
   if exist('maxrows','var') ~= 1
      maxrows = 0;
   end

   %set default autoclose option if omitted
   if exist('autoclose','var') ~= 1
      autoclose = 1;
   end
   
   %set default debug option if omitted
   if exist('debugfile','var') ~= 1
      debugfile = 0;
   end
   
   %init runtime vars
   data = [];
   meta = [];
   
   %check for connection error
   if isempty(conn.Message)
      
      %get database system name from connection object
      db = conn.Instance;
      
      %execute query
      curs = exec(conn,qry);
      
      %check for query error
      if isempty(curs.Message)
         
         %fetch records into array
         try
            curs = fetch(curs,maxrows);      
            data = curs.Data;
            meta = attr(curs);         
            close(curs)
         catch
            msg = 'Query returned no data';
         end
         
      else         
         msg = ['Query execution error: ',curs.Message];         
      end
      
   else      
      msg = ['Database connection error: ',conn.Message];      
   end
   
   %close the database connection
   if autoclose == 1
      try
         close(conn);
      catch
         %do nothing
      end
   end
   
   %evaluate resultset data
   if ~isempty(data)
      
      %init lookup matrix for JDBC column types based on MATLAB version to accomodate database
      %toolbox changes
      %  column 1: JDBC type
      %  column 2: GCE data type
      %  column 3: GCE variable type
      %  column 4: GCE numeric type
      %  column 5: data extraction/conversion expression (where datacol = extracted column; raw data returned if empty)
      
      if mlversion >= 7  %use MATLAB 7+ syntax
         
         lookup = {'bit','d','logical','discrete','double(datacol)'; ...
               'boolean','d','logical','discrete','str2num(char(strrep(strrep(datacol,''true'',''1''),''false'',''0'')))'; ...
               'numeric','f','data','continuous',''; ...
               'decimal','f','data','continuous',''; ...
               'real','f','data','continous',''; ...
               'double','f','data','continuous',''; ...
               'float','f','data','continuous',''; ...
               'integer','d','data','discrete',''; ...
               'int','d','data','discrete',''; ...
               'int identity','d','ordinal','discrete',''; ...
               'bigint','d','data','discrete',''; ...
               'smallint','d','data','discrete',''; ...
               'tinyint','d','data','discrete',''; ...
               'date','s','datetime','none',''; ...
               'datetime','f','datetime','continuous',''; ...
               'datetime2','f','datetime','continuous',''; ...
               'time','s','datetime','none',''; ...
               'timestamp','s','datetime','none',''; ...
               'char','s','nominal','none',''; ...
               'varchar','s','nominal','none',''};       
            
      else  %use MATLAB 6 syntax
         
         lookup = {'bit','d','logical','discrete','str2num(char(strrep(strrep(datacol,''true'',''1''),''false'',''0'')))'; ...
               'boolean','d','logical','discrete','str2num(char(strrep(strrep(datacol,''true'',''1''),''false'',''0'')))'; ...
               'numeric','f','data','continuous',''; ...
               'decimal','f','data','continuous',''; ...
               'real','f','data','continous',''; ...
               'double','f','data','continuous',''; ...
               'float','f','data','continuous',''; ...
               'integer','d','data','discrete',''; ...
               'int','d','data','discrete',''; ...
               'int identity','d','ordinal','discrete',''; ...
               'bigint','d','data','discrete',''; ...
               'smallint','d','data','discrete',''; ...
               'tinyint','d','data','discrete',''; ...
               'date','s','datetime','none',''; ...
               'datetime','f','datetime','continuous',''; ...
               'datetime2','f','datetime','continuous',''; ...
               'time','s','datetime','none',''; ...
               'timestamp','s','datetime','none',''; ...
               'char','s','nominal','none',''; ...
               'varchar','s','nominal','none',''};       
                        
      end
      
      %get info from JDBC metadata
      if isstruct(data)
         %use fieldnames from struct to reflect any removal of whitespace
         colnames = fieldnames(data)';
      else
         colnames = {meta.fieldName};
      end
      coltypes = {meta.typeName};  %get field types

      %check for valid data return
      if isstruct(data) || (iscell(data) && size(data,2) == length(colnames))
         
         %get column count for validation
         ncols = length(coltypes);

         %init value array
         vals = cell(1,ncols);

         %init attribute metadata arrays
         datatypes = repmat({''},1,ncols);
         vartypes = datatypes;
         numtypes = datatypes;
         prec = zeros(1,ncols);
         crit = datatypes;
         flags = datatypes;
         units = repmat({''},1,ncols);
         
         %loop through columns,looking up attribute metadata and processing instructions
         for n = 1:ncols
            
            %look up info for field type
            Imatch = find(strcmp(lookup(:,1),coltypes{n}));  
            
            %check for matched column type
            if ~isempty(Imatch) 
                              
               Imatch = Imatch(1);  %use first match
               datatypes{n} = lookup{Imatch,2};  %get datatype
               vartypes{n} = lookup{Imatch,3};  %get variable type
               numtypes{n} = lookup{Imatch,4};  %get numeric type

               %extract data columns from cell array or structure
               if iscell(data)
                  if ischar(data{1,n})
                     datacol = strrep(data(:,n),'null','');  %string - just get native cell array and strip nulls
                  else
                     datacol = [data{:,n}]';  %numeric - extract cell contents to form column array
                  end
               else                  
                  datacol = data.(colnames{n});
                  if iscell(datacol)
                     if ~ischar(datacol{1})
                        datacol = [datacol{:}]';  %convert numeric values in cell arrays to numeric arrays
                     else
                        datacol = strrep(datacol,'null','');  %strip nulls from strings
                     end
                  end
               end
               
               %evaluate data conversion expression if non-empty
               expr = lookup{Imatch,5};
               if ~isempty(expr)
                  try
                     eval(['vals_temp=',expr,';'])
                  catch
                     vals_temp = datacol;  %use native data
                  end
               else
                  vals_temp = datacol;  %use native data
               end
               
               %add array to vals, forcing column orientation
               vals{n} = vals_temp(:);  
               
               %evaluate floating point values, calculate precision
               if strcmp(lookup(Imatch,2),'f')
                  
                  coldata = vals{n};
                  dig = [];
                  
                  %check for cell array
                  if iscell(coldata)
                     
                     %check for special case of string datetime column with 'f' data type
                     if strncmpi(coltypes{n},'datetime',8)
                        
                        %convert dates to numeric serial dates, catching nulls and converting to NaN
                        tmp = ones(length(coldata),1).*NaN;
                        Ivalid = find(~cellfun('isempty',coldata));
                        
                        %convert non-empty dates to serial dates
                        if ~isempty(Ivalid)
                           [dstr,Iunique,Iorig] = unique(coldata(Ivalid));  %get only unique dates for efficiency
                           try
                              dnum = datenum(dstr);
                           catch
                              dnum = [];
                           end
                           if ~isempty(dnum)
                              tmp(Ivalid) = dnum(Iorig);  %add converted dates, reconciling valid and unique indices
                           end
                        end
                        
                        %update column data arraay
                        coldata = tmp;
                        
                     else  %other cell array
                        
                        %check for numeric data - extract from cell array
                        tmp = coldata;
                        if ~isempty(tmp) && isnumeric(tmp{1})
                           try
                             tmp = [tmp{:}]';
                           catch
                              tmp = [];
                           end
                        else
                           tmp = [];
                        end
                        
                        %check for successful extraction or override metadata to string
                        if ~isempty(tmp)
                           coldata = tmp;
                        else   %revert attribute metadata to string
                           datatypes{n} = 's';
                           numtypes{n} = 'none';
                           dig = 0;
                        end
                        
                     end
                     
                  end
                  
                  %update value array if changed
                  vals{n} = coldata;
                  
                  %calculate 5 significant digits for non-datetime, numeric floating point value arrays
                  if isempty(dig)
                     
                     %calculate maximum value, checking for 0 before using log10
                     try
                        maxval = max(abs(vals{n}));
                     catch
                        maxval = 0;
                     end
                     if ~isnan(maxval) && maxval > 0
                        dig = max(0,5 - ceil(log10(maxval)));
                     else
                        dig = 0;
                     end
                     
                  end                  
                  
               else  %string or integer                  
                  dig = 0;  %use 0 precision                  
               end
               
               prec(n) = dig; %store pecision    
               
            else  %use defaults for unmatched column type
               
               datatypes{n} = 'u';
               vartypes{n} = 'data';
               numtypes{n} = 'unspecified';
               val_tmp = data(:,n);
               vals{n} = val_tmp(:);              
               prec(n) = 0;
               
            end

         end
         
         %populate data structure fields
         s = newstruct('data');
         s.title = ['Data returned from an SQL statement executed on the data source ''',db,''''];
         s.datafile = {[db,' query: ',qry],[length(vals{1})]};
         s.createdate = datestr(now);
         s.name = colnames;
         s.units = units;
         s.description = colnames;
         s.datatype = datatypes;
         s.variabletype = vartypes;
         s.numbertype = numtypes;
         s.precision = prec;
         s.values = vals;
         s.criteria = crit;
         s.flags = flags;
         s.history = [s.history; ...
            {datestr(now),['imported result set from SQL query on data source ''',db,''' (''sql2struct'')']}];
         
         %validate structure
         [val,stype,msg0] = gce_valid(s,'data');

         %finalize structure
         if val ~= 1

            %save debug file if not valid
            if debugfile == 1
               debug = struct('colnames',[],'coltypes',[],'data',[],'s',[]);
               debug.colnames = colnames;
               debug.coltypes = coltypes;
               debug.data = data;
               debug.s = s;
               save('sql2gceds_debug.mat','debug')
            end
         
            %clear output structure and generate error message
            s = [];
            msg = ['Structure could not be created: ',msg0];
         
         else
            
            %apply metadata template
            if ~isempty(template)
               [s_tmp,msg_template] = apply_template(s,template);
               if ~isempty(s_tmp)
                  s = s_tmp;
               end
            else
               msg_template = '';
            end
            
            %automatically assign unmatched numeric types after template application
            Icols = find(strcmp('u',s.datatype)); %get index of columns with unspecified data types
            if ~isempty(Icols)
               [s,msg_numtype] = assign_numtype(s,0,Icols); %assign numeric type and precision based on value inspection
            else
               msg_numtype = '';
            end
            
            %combine error messages from template and assign_numtype
            if ~isempty(msg_template) || ~isempty(msg_numtype)
               msg = msg_template;
               if ~isempty(msg_numtype)
                  if ~isempty(msg)
                     msg = [msg,'; ',msg_numtype];
                  else
                     msg = msg_numtype;
                  end
               end
            end               
            
         end
         
      else  %no data     
         
         msg = 'Query returned no data';         
         
         %save debug file
            if debugfile == 1
               debug = struct('colnames',[],'coltypes',[],'data',[],'s',[]);
               debug.colnames = colnames;
               debug.coltypes = coltypes;
               debug.data = data;
               save('sql2gceds_debug.mat','debug')
            end
         
      end
      
   else      
      msg = 'Query returned no data';      
   end
   
end
