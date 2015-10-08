function [s2,msg] = addcol(s,newdata,colname,units,description,datatype,variabletype,numbertype,precision,criteria,pos,overwrite)
%Adds a column array as a new calculated column to a GCE-LTER data structure
%
%syntax:  [s2,msg] = addcol(s,newdata,name,units,description,datatype,variabletype,numbertype,precision,criteria,pos,overwrite)
%
%inputs:
%   s = original data structure (struct; required)
%   newdata = an array of calculated values (numeric or cell array; required)
%   colname = the name of the new column (integer or string; required)
%   units = the units string for the new column (string; required)
%   description = the description for the new column (string; optional - default = name)
%   datatype = the data type of the new column (string; optional)
%      'f' = floating-point
%      'e' = exponential
%      'd' = integer
%      's' = string
%   variabletype = the variable type of the new column (string; optional - default = 'calculation')
%      'data' = measured data value or observation
%      'calculation' = calculated data value
%      'nominal' = categorical value or label
%      'ordinal' = order or positional value
%      'logical' = boolean/true-false value
%      'datetime' = date and/or time value
%      'coord' = geographic coordinate
%      'code' = coded value
%      'text' = free text
%   numbertype = the numerical type of the new column (string; optional)
%      'continuous' = continuously variable (ratio scale)
%      'discrete' = whole number
%      'angular' = angular or vector variable (interval scale)
%      'none' = non-numeric
%   precision = the number of decimal places to use for text output
%      (optional - default calculated for 6 significant digits)
%   criteria = the flagging criteria for the new column (optional - default = '')
%   pos = the column position (1 = beginning, [] = last)
%   overwrite = option to overwrite any existing columns of the same name (integer - optional)
%     0 = no (default)
%     1 = yes
%
%outputs:
%   s2 = the updated data structure
%   msg = the text of any error messages
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
%last modified: 18-Mar-2015

%initialize outputs
s2 = [];
msg = '';

if nargin >= 4
   
   %validate inputs
   if gce_valid(s,'data')
      
      if ~isempty(newdata)
         
         %check for non-vector data
         if size(newdata,2) > 1  %check for vector data
            if ischar(newdata)
               newdata = cellstr(newdata);
            elseif size(newdata,1) == 1
               newdata = newdata(:);  %force column vector
            else
               newdata = [];
               msg = '''newdata'' must be a vector - column addition cancelled';
            end
         end
         
         if iscell(newdata)
            if ~isempty(newdata) && ischar(newdata{1})
               len = length(newdata);
            else
               len = 0;
               newdata = [];
               msg = 'empty, numeric or mixed-type cell arrays are not supported';
            end
         elseif isnumeric(newdata)
            len = size(newdata(:),1);
         elseif ischar(newdata)
            newdata = cellstr(newdata);  %convert character array to cell array
            len = length(newdata);
            datatype = 's';
         else
            newdata = [];
            ln = 0;
            msg = 'unsupported array type';
         end
         
         if length(s.name) > 1
            if len == 1  %automatically replicate scalars
               newdata = repmat(newdata,length(s.values{1}),1);
            elseif len ~= length(s.values{1})
               newdata = [];
               msg = 'operation cancelled - ''newdata'' and ''s'' have different numbers of rows';
            end
         end
         
         if ~isempty(newdata)  %proceed if required inputs passed validation
            
            %catch cell array input of names
            if iscell(colname)
               colname = char(colname{1});
            end
            
            %fill in optional arguments
            if exist('description','var') ~= 1 || ~ischar(description)
               description = colname;
            end
            
            %validate position
            if exist('pos','var') ~= 1
               pos = [];
            end         
            if isempty(pos)
               pos = length(s.name)+1;  %add as last column
            else
               pos = pos - 0.1;  %add fractional position to account for offset
            end
            
            %validate precision
            if exist('precision','var') ~= 1
               if iscell(newdata)
                  precision = 0;  %string data
               else
                  vals = newdata(~isnan(newdata));
                  if ~isempty(vals)
                     integertest = max(abs(fix(vals)-vals));  %check for all integers
                     if integertest == 0
                        precision = 0;  %all integers
                     else
                        dig = fix(log10(max(abs(vals))))+1;  %get significant digits
                        sigdig = dig - 6;  %get precision to get 6 significant digits
                        if sigdig > 0
                           precision = 0;  %max number >1e6, set 0 decimal places
                        else
                           precision = abs(sigdig);  %set decimal places to get 6 significant digits
                        end
                     end
                  else
                     precision = 0;  %set precision of 0 for all NaN column
                  end
               end
            end
            
            %validate datatype
            if exist('datatype','var') ~= 1 || ~inlist(datatype,{'s','d','f','e'})
               if iscell(newdata)
                  datatype = 's';  %set cell arrays to string
               elseif precision == 0
                  datatype = 'd';  %set integer type if no decimals places
               else
                  datatype = 'f';
               end
            end
            
            %validate variabletype
            if exist('variabletype','var') ~= 1 || ~ischar(variabletype)
               variabletype = 'calculation';
            end
            
            %validate numbertype
            if exist('numbertype','var') ~= 1 || sum(inlist(numbertype,{'continuous','discrete','angular','none'})) == 0
               if strcmp(datatype,'f')
                  numbertype = 'continuous';
               elseif strcmp(datatype,'d')
                  numbertype = 'discrete';
               else
                  numbertype = 'none';
               end
            end
            
            %validate criteria
            if exist('criteria','var') ~= 1 || ~ischar(criteria)
               criteria = '';
            else
               criteria = deblank(criteria);
            end

            %validate overwrite
            if exist('overwrite','var') ~= 1 || ~isnumeric(overwrite) || overwrite ~= 1
               overwrite = 0;
            end
            
            %copy input structure
            s2 = s;
            
            %check for overwrite and rename column(s) to be deleted
            if overwrite == 1
               pos_old = strcmp(s2.name,colname);
               s2.name(pos_old) = {'TO-BE-DELETED'};
            end

            %update structure fields
            curdate = datestr(now);
            s2.name = [s2.name,{colname}];
            s2.units = [s2.units,{units}];
            s2.description = [s2.description,{description}];
            s2.datatype = [s2.datatype,{datatype}];
            s2.variabletype = [s2.variabletype,{variabletype}];
            s2.numbertype = [s2.numbertype,{numbertype}];
            s2.precision = [s2.precision,precision];
            s2.criteria = [s2.criteria,{criteria}];
            s2.values = [s2.values,{newdata}];
            s2.flags = [s2.flags,{''}];  %add empty flag array - will be updated by dataflag if criteria supplied
            s2.editdate = curdate;         
            
            %apply column ordering
            [tmp,Isort] = sort([1:length(s.name),pos]);
            finalpos = find(tmp==pos);
            s2 = copycols(s2,Isort);

            %check for overwrite and rename column(s) to be deleted
            msg2 = '';
            if overwrite == 1
               pos_old = find(strcmp(s2.name,'TO-BE-DELETED'));
               [s2,msg2] = deletecols(s2,pos_old,1);
            end
            
            if ~isempty(s2)
               
               %update history (ignoring sort step)
               s2.history = [s.history ; ...
                     {datestr(now)},{['added column ''',char(colname),''' at position ',int2str(finalpos(1)),' (''addcol'')']} ];
               s2.editdate = datestr(now);
               
               %update qc flags if criteria supplied for new data
               if ~isempty(criteria)
                  [s2,msg] = dataflag(s2,finalpos);
               end
               
            else
               if isempty(msg2)
                  msg = 'an error occurred adding the column';
               else
                  msg = ['an error occurred removing the original calculated column (',msg2,')'];
               end
            end
            
         end
         
      else
         msg = 'invalid data array';
      end
      
   else
      msg = 'invalid data structure';
   end
   
else   
   msg = 'insufficient arguments for function';   
end