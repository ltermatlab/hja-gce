function [s2,msg,expression] = add_calcexpr(s,expr,colname,colunits,coldesc,pos,repscalar,colcrit,vartype,overwrite)
%Evaluates a text expression as a MATLAB statement and adds the resultant values to a GCE Data Structure
%
%syntax:  [s2,msg,expression] = add_calcexpr(s,expr,colname,colunits,coldesc,pos,repscalar,colcrit,vartype,overwrite)
%
%inputs:
%  s = data structure (struct - required)
%  expr = valid MATLAB expression (string - required)
%  colname = name to assign the calculated column (string - optional; default = 'NewColumn')
%  colunits = units for calculated column (string - optional; default = 'none')
%  coldesc = description of calculated column (string - optional; default = '')
%  pos = position to assign to calculated column in the structure (integer - optional; 
%     default = last column, 0 for before first column)
%  repscalar = option to replicate scalar values to the required column length (integer - optional)
%     0 = no (scalar results will return an error for multi-row data sets)
%     1 = yes (default)
%  colcrit = Q/C criteria for calculated column (string - optional; default = '' for none)
%  vartype = variable type to assign:
%     'data' = measured data value
%     'calculation' = calculated data value (default)
%     'nominal' = nominal or categorical value
%     'ordinal' = order/positional value
%     'logical' = boolean/true-false value
%     'datetime' = date or time value
%     'coord' = geographic coordinate value
%     'code' = coded value
%     'text' = free text
%  overwrite = option to overwrite any existing columns of the same name (integer - optional)
%     0 = no (default)
%     1 = yes
%     
%outputs:
%  s2 = modified data structure
%  msg = text of any error message
%  expression = actual MATLAB expression evaluated (for debugging or documentation purposes)
%
%
%notes:
%  1) column references in 'expr' will be replaced with column data arrays
%  2) if the expression evaluation fails, vector versions of multiplication, division and exponentiation
%     operators will be tried automatically (i.e. .*, ./ and /^, resp.)
%
%
%(c)2002-2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 11-Mar-2015

%init output
s2 = [];
msg = '';

%check for required arguments
if nargin >= 2 && gce_valid(s,'data')
   
   %check for non-empty expression
   if ~isempty(expr) && ischar(expr)

      %supply defaults for optional arguments
      if exist('colcrit','var') ~= 1
         colcrit = '';  %no q/c criteria
      end

      if exist('repscalar','var') ~= 1
         repscalar = 1;  %yes to replicate scalars
      end

      if exist('pos','var') ~= 1
         pos = length(s.name)+1;  %default to last position
      end

      if exist('colname','var') ~= 1
         colname = 'NewColumn';  %default column name
      end

      if exist('colunits','var') ~= 1
         colunits = 'none';  %default units
      end

      if exist('coldesc','var') ~= 1
         coldesc = '';  %default description
      end
      
      %validate variable type
      if exist('vartype','var') ~= 1
         vartype = 'calculation';
      elseif ~inlist(vartype,{'data','calculation','nominal','ordinal','logical','datetime','coord','code','text'})
         vartype = 'calculation';
      end

      %validate overwrite
      if exist('overwrite','var') ~= 1 || ~isnumeric(overwrite) || overwrite ~= 1
         overwrite = 0;
      end
      
      %call subroutine to evaluate expression and return data array and updated expression string
      [data,expression] = subfun_evalexpr(s,expr);

      %check for return data
      if ~isempty(data)

         %check data format
         if ischar(data)
            data = cellstr(data);
         elseif iscell(data)
            if ~ischar(data{1})
               data = [];
               msg = 'non-string cell arrays are not supported';
            end
         end

         %force column orientation and replicate scalars if necessary
         if ~isempty(data)
            data = data(:);  %force column orientation
            if size(data,1) ~= length(s.values{1}) || size(data,2) > 1
               if repscalar == 1 && size(data,1) == 1
                  data = repmat(data,length(s.values{1}),1);
               else
                  data = [];
                  msg = 'invalid number of rows returned by expression';
               end
            end
         end

         if ~isempty(data)
            
            %assign data type, numeric type, precision based on data type and scale
            if iscell(data)
               
               %string
               dtype = 's';
               ntype = 'none';
               prec = 0;
               
            else  %numeric
               
               %check for integer/float
               if sum(data~=floor(data)) == 0  %check for no decimal point
                  
                  %integer
                  dtype = 'd';
                  ntype = 'discrete';
                  prec = 0;
                  
               else  %float
                  
                  %check scale for float/exponential format
                  maxval = max(abs(data(~isnan(data))));
                  
                  if maxval > 0
                     om = ceil(log10(maxval));  %calculate order of magnitude
                     if om > 5  %use scientific notation for large numbers
                        dtype = 'e';
                        ntype = 'continuous';
                        prec = 3;  %default to 4 significant digits
                     else  %use floating point
                        dtype = 'f';
                        ntype = 'continuous';
                        prec = max(0,5-om);  %default to 5 significant digits
                     end
                  else
                     dtype = 'd';
                     ntype = 'discrete';
                     prec = 0;  %all zeros or can't determine om - use integer defaults
                  end
                  
               end
               
            end

            %buffer history before column addition
            str_hist = s.history;
            
            %add calculated column
            [s2,msg] = addcol(s, ...
               data, ...
               colname, ...
               colunits, ...
               coldesc, ...
               dtype, ...
               vartype, ...
               ntype, ...
               prec, ...
               colcrit, ...
               pos, ...
               overwrite);

            %finalize structure
            if ~isempty(s2)
               
               %update edit date
               s2.editdate = datestr(now);
               
               %update processing history
               s2.history = [str_hist ; ...
                     {datestr(now)},{['calculated column ',colname,' generated by the expression ''',expr,''' (add_calcexpr)']}];
               
               %add calculation
               calcmeta = lookupmeta(s2,'Data','Calculations');
               s2 = addmeta(s2,{'Data','Calculations',[calcmeta,'|',colname,': ',colname,' = ',expr]});
               
            else
               msg = ['calculated column could not be added to the data structure (error: ',msg,')'];
            end

         end

      else
         msg = 'expression could not be evaluated - check syntax';
      end

   else
      msg = 'invalid expression string';
   end

else

   if nargin < 2
      msg = 'too few arguments for function';
   else
      msg = 'invalid data structure';
   end

end


function [data,e] = subfun_evalexpr(s,e)
%Subfunction for evaluating a MATLAB expression using arrays from a GCE Data Structure
%
%input:
%  s = data structure to evaluate
%  e = expression to evaluate
%
%output:
%  data = data array
%  e = updated expression

%init output
data = [];
err = 0;

%replace column name references with data pointers using regular expression matching
colnames = s.name;
e = [' ',e,' '];  %add terminal spaces for regex matching to support name boundary checks
for n = 1:length(colnames)
   [Istart,Iend] = regexp(e,['[^a-zA-Z_]',colnames{n},'[^a-zA-Z0-9_]']);  %get arrays of starting/ending indices
   if ~isempty(Istart)
      e2 = e(1:Istart(1)-1);  %init with leading text before first match
      for m = 1:length(Istart)
         if m > 1
            e2 = [e2,e(Iend(m-1)+1:Istart(m)-1)];  %add intervening text between multiple matches
         end
         %replace matched column name with value array pointer, preserving bounding chars
         e2 = [e2,e(Istart(m)),'s.values{',int2str(n),'}',e(Iend(m))];  
      end
      e2 = [e2,e(Iend(end)+1:end)];  %add trailing text after last match
      e = e2;  %update expression with re-processed string
   end
end

w = warning;  %cache warning state
warning('off')

%evaluate expression
try
   eval(['data = ',e,';'])
catch
   data = [];
   err = 1;
end

%try math substitutions if eval fails to return results
if isempty(data) || err == 1
   e = strrep(e,'*','.*');
   e = strrep(e,'/','./');
   e = strrep(e,'^','.^');
   try
      eval(['data = ',e,';'])
   catch
      data = [];
   end
end

warning(w);  %restore warning state

if ~isempty(data)
    if islogical(data)
        data = double(data);  %convert logical/boolean values to integers
    end
end
