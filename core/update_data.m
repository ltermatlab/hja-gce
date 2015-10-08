function [s2,msg,Idiffs] = update_data(s,col,newdata,logopt,flag,flagdef,fnc)
%Updates values in a GCE Data Structure column, optionally logging all value changes
%to the processing history field
%
%syntax: [s2,msg,Idiffs] = update_data(s,col,newdata,logopt,flag,flagdef,fnc)
%
%inputs:
%  s = structure to modify (struct; required)
%  col = column number or name to update (integer or string; required)
%  newdata = new data values (numerical or cell array matching the length and type of the original data; required)
%  logopt = maximum number of value changes to log to the processing history field
%    (integer; optional; default = 100, 0 = none, inf = all)
%  flag = flag to assign for revised data values (string; optional; default = '' for no flag)
%  flagdef = definition of flag if not already registered in the metadata (string; optional;
%    default = 'revised value' or '' if flag = '')
%  fnc = function name to log in the processing history (string; optional; default = 'update_data')
%
%outputs:
%  s2 = updated structure
%  msg = text of any error messages
%  Idiffs = index of rows with revised values
%
%notes:
%  1) see 'update_values.m' to update just selected rows of a data column
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
%last modified: 19-Feb-2015

s2 = [];
msg = '';
Idiffs = [];

%check for required arguments
if nargin >= 3 && gce_valid(s,'data')
   
   %validate logopt arg, supply default if omitted
   if exist('logopt','var') ~= 1
      logopt = 100;
   elseif ~isnumeric(logopt)
      logopt = 0;
   else
      logopt = fix(logopt);
   end
   
   %set default flag if omitted
   if exist('flag','var') ~= 1
      flag = '';
   elseif ~ischar(flag)
      flag = '';
   elseif length(flag) > 1
      flag = flag(1);
   end
   
   %set default fnc if omitted
   if exist('fnc','var') ~= 1 || ~ischar(fnc) || isempty(fnc)
      fnc = 'update_data';
   end
   
   %set default flagdef if omitted
   if isempty(flag)
      flagdef = '';  %force empty definition if no flag assigned
   elseif exist('flagdef','var') ~= 1 || isempty(flagdef)
      flagdef = 'revised value';
   end
   
   %look up column index if necessary
   if ~isnumeric(col)
      col = name2col(s,col);
   end
   
   if ~isempty(col)
      
      dtype = s.datatype{col};  %extract data type
      olddata = extract(s,col);  %extract original data value array
      
      %init runtime vars
      val = 0;
      
      if (size(newdata,1) == size(olddata,1)) && size(newdata,2) == 1
         
         %validate new data, check for differences by datatype
         switch dtype
            case 's'  %string
               if iscell(newdata)
                  val = 1;
                  Idiffs = find(~strcmp(olddata,newdata));
               else
                  msg = 'data could not be updated due to a type mismatch error (string data expected)';
               end
            case 'd'  %integer
               if isnumeric(newdata)
                  newdata2 = newdata(~isnan(newdata));
                  if isempty(newdata2)
                     val = 1;
                  elseif isempty(find(newdata2 ~= fix(newdata2)))   %#ok<EFIND>
                     val = 1;
                  end
                  if val == 1
                     Idiffs = subfun_nansafediff(newdata,olddata);
                  end
               end
               if val == 0
                  msg = 'data could not be updated due to a type mismatch error (integer data expected)';
               end
            case 'f'  %floating-point
               if isnumeric(newdata)
                  val = 1;
                  Idiffs = subfun_nansafediff(newdata,olddata);
               else
                  msg = 'data could not be updated due to a type mismatch error (floating-point data expected)';
               end
            case 'e'  %exponential
               if isnumeric(newdata)
                  val = 1;
                  Idiffs = subfun_nansafediff(newdata,olddata);
               else
                  msg = 'data could not be updated due to a type mismatch error (exponential data expected)';
               end
         end
         
         %check validation flag before proceeding
         if val == 1
            
            %init output structure
            s2 = s;
            
            %check for differences, update values and history
            if ~isempty(Idiffs)
               
               %update data array in structure with new values
               s2.values{col} = newdata;

               %generate flag assignment string for history
               if ~isempty(flag)
                  flagstr = ['and flagged as ''',flag,''' '];
               else
                  flagstr = ' ';
               end

               %generate processing history entry text
               colname = s.name{col};
               numdiffs = length(Idiffs);
               if numdiffs > 1
                  updatelog = [int2str(numdiffs),' values in ''',colname, ...
                     ''' were updated with new values',flagstr,'(''',fnc,''')'];
               else
                  updatelog = ['1 value in ''',colname,''' was updated with a new value ', ...
                     flagstr,'(''',fnc,''')'];
               end

               %generate individual value change entries for processing history based on logopt setting
               if numdiffs <= logopt
                  str = repmat({'',','},numdiffs,1);
                  if strcmp(dtype,'s')
                     for n = 1:numdiffs
                        str{n,1} = [' changed record ',int2str(Idiffs(n)),' from ''',olddata{Idiffs(n)}, ...
                           ''' to ''',newdata{Idiffs(n)},''''];
                     end
                  else
                     if strcmp(dtype,'d')
                        fstr = '%0d';
                     else
                        fstr = ['%0.',int2str(s.precision(col)),dtype];
                     end
                     for n = 1:numdiffs
                        str{n,1} = [' changed record ',int2str(Idiffs(n)),' from ',sprintf(fstr,olddata(Idiffs(n))), ...
                           ' to ',sprintf(fstr,newdata(Idiffs(n)))];
                     end
                  end
                  str{end,2} = '';
                  str = str';
                  updatelog = [updatelog,':',[str{:}]];
               end
               
               %update processing history
               s2.history = [s2.history ; {datestr(now)},{updatelog}];
               
               %evaluate automatic q/c flag rules or add manual flags
               if ~isempty(flag)                  
                  %add manual flags for revised values
                  s2 = addflags(s2,col,Idiffs,flag,flagdef);                  
               else
                  %update automatic flags
                  s2 = dataflag(s2,col);
               end
               
               %update edit date field
               s2.editdate = datestr(now);
               
            else  %no differences
               msg = 'structure was not modified - no differences were found between old and new values';
            end
            
         end
         
      else
         msg = 'data could not be updated due to array size mismatch';
      end
      
   else
      msg = 'invalid column selection';
   end
   
else
   if nargin < 3
      msg = 'insuffience arguments for function';
   else
      msg = 'invalid data structure';
   end
end


function Idiffs = subfun_nansafediff(data1,data2)
%returns index of differences between two matching numeric arrays, accounting for NaNs in same position (NaN-safe)

%get index of records with NaN in both arrays
Inan = (isnan(data1) + isnan(data2)) == 2;

%get index of array differences
Idiffs = data1 ~= data2;

%reset match index with matching NaNs
Idiffs(Inan) = 0;

%generate logical index
Idiffs = find(Idiffs);