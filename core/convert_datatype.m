function [s2,msg,badcols] = convert_datatype(s,cols,newdtype,integeropt)
%Converts specified columns in a GCE Data Structure to a new data type, transforming values as necessary
%
%syntax: [s2,msg,badcols] = convert_datatype(s,cols,newdtype,integeropt)
%
%inputs:
%  s = data structure to modify
%  cols = array of column names or numbers to modify
%  newdtype = target data type (note that transformation will be skipped if original datatype = newdtype)
%    'f' = floating-point
%    'e' = exponential
%    'd' = integer
%    's' = string
%  integeropt = option for handling conversions to integer type (ignored if newdtype not 'd')
%    'round' = round to nearest integer (default)
%    'fix' = round towards zero (truncate decimal places)
%    'ceil' = round up to nearest integer
%    'floor' = round down to nearest integer
%
%outputs:
%  s2 = modified structure
%  msg = text of any error message
%  badcols = array of column numbers that could not be converted
%
%usage notes:
%  - conversions from numeric to string or string to numeric will lock flags and clear QA/QC criteria
%  - conversions from string to numeric for columns with variable types of 'datetime' or 'coord' will be
%      evaluated  using appropriate content filters to generate MATLAB serial dates or decimal degrees, resp.,
%      and column units will be updated accordingly
%  - conversions from numeric to string for columns with variable type 'datetime' and datatype 'f'
%      will be converted from numeric serial date to formatted date (DD-MMM-YYYY or DD-MMM-YYYY HH:MM:SS)
%  - original structure will be returned if no conversions are necessary
%  - an empty matrix will be returned if all conversions fail or a conversion error occurs
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
%last modified: 21-May-2013

s2 = [];
msg = '';

if nargin >= 3
   
   if gce_valid(s,'data')
      
      %set default integeropt if omitted, blank
      if exist('integeropt','var') ~= 1
         integeropt = '';
      end
      if isempty(integeropt)
         integeropt = 'round';
      end
      
      %check for valid datatype, integeropt
      if inlist(newdtype,{'f','e','d','s'},1) == 1 && inlist(integeropt,{'round','fix','floor','ceil'},1) == 1
         
         %validate column selections
         if ~isnumeric(cols)
            cols = name2col(s,cols); %look up column indices from names
            cols = unique(cols);     %ensure no duplicates
         else
            cols = unique(cols);  %ensure no duplicates
            if length(intersect(cols,(1:length(s.name)))) < length(cols)  %check for invalid columns
               cols = [];
            end
         end
         
         if ~isempty(cols)
            
            %init output structure
            s2 = s;
            
            %init bad column array
            badcols = [];
            
            %init datatype lookup list for metadata
            dtypelist = {'f','floating-point'; ...
                  'e','exponential'; ...
                  'd','integer'; ...
                  's','string'};
            
            %loop through column list and perform conversions
            for n = 1:length(cols)

               %get column pointer
               col = cols(n);

               %look up current attributes for column
               dtype = s2.datatype{col};
               numtype = s2.numbertype{col};
               vartype = s2.variabletype{col};
               prec = s2.precision(col);
               crit = s2.criteria{col};
               units = s2.units{col};
               
               %check for existing qc flags - set to manual if need to clear criteria
               if ~isempty(s2.flags{col})
                  flags = 1;
               else
                  flags = 0;
               end
               flaghist = '';
               
               %init value arrays, updated precision, criteria and units
               colname = s2.name{col};
               vals = s2.values{col};
               newvals = [];
               newprec = 0;
               newnumtype = numtype;
               newcrit = crit;
               newunits = units;
               
               %check for datatype difference
               if ~strcmp(dtype,newdtype)
               
                  %init transform string
                  str_transform = '';
                  
                  %handle transformations
                  if strcmp(newdtype,'s')  %convert to string
                     
                     newprec = 0;
                     newnumtype = 'none';
                     
                     %update q/c criteria, generate history string
                     if flags == 1
                        newcrit = 'manual';  %lock flags to preserve existing
                        flaghist = ', clearing existing Q/C criteria and locking flags to prevent recalculation';
                     else
                        newcrit = '';  %clear Q/C criteria
                        flaghist = ', clearing existing Q/C criteria';
                     end
                     
                     %check for special cases of numerical serial date based on variable type and name string
                     if strcmp(vartype,'datetime') && strcmp(dtype,'f') && (~isempty(strfind(lower(colname),'date')) || ~isempty(strfind(lower(colname),'time')))
                        
                        dmin = min(vals(~isnan(vals)));
                        
                        if dmin < 100000  
                           vals = datecnv(vals,'xls2mat');
                           str_transform = 'datecnv(x,''xls2mat'')';
                        else
                           str_transform = 'x';
                        end

                        %check for time zone appended to units
                        [Itzstart,Itzend] = regexp(units,' - [A-Z][MDS]T');
                        if ~isempty(Itzstart)
                           tz = units(Itzstart:Itzend);
                        else
                           tz = '';
                        end

                        %determine datestr format based on resolution
                        valdiffs = (fix(vals .* 10000) ./ 10000) - fix(vals);  %check for decimals, ignoring <.0001 precision
                        if max(valdiffs) > 0
                           dateformat = 0;
                           newunits = ['DD-MMM-YYYY HH:MM:SS',tz];
                        else
                           dateformat = 1;
                           newunits = ['DD-MMM-YYYY',tz];
                        end
                        
                        %format dates
                        Ivalid = find(~isnan(vals));  %get index of non-NaN values
                        
                        if ~isempty(Ivalid)
                        
                           try
                              tmpvals = datestr(vals(Ivalid),dateformat);
                              if ischar(tmpvals)
                                 newvals = repmat({''},length(vals),1);  %generate empty cell array of strings
                                 newvals(Ivalid) = cellstr(tmpvals);  %add converted date strings to output array by original position
                              else
                                 newvals = [];  %return empty array on failed string conversion
                              end
                           catch
                              newvals = [];  %return empty array on errors
                           end
                        
                           %generate foramt string
                           str_transform = ['cellstr(datestr(',str_transform,',',int2str(dateformat),'))'];
                           
                        end

                     else  %general case
                        
                        %generate appropriate format string for conversion
                        fstr = '';
                        switch dtype
                           case 'f'
                              fstr = ['%0.',int2str(prec),'f'];
                           case 'e'
                              fstr = ['%0.',int2str(prec),'e'];
                           case 'd'
                              fstr = '%0d';
                        end
                        
                        %perform conversion
                        if ~isempty(fstr)                        
                           numrows = length(vals);
                           gps = ceil(numrows./100);  %calculate number of groups of 100 for looping to minimize memory use
                           nullstr = repmat({''},100,1);  %generate empty array for blocks that can't be converted
                           newvals = repmat({''},numrows,1);  %init empty cell array
                           try
                              for cnt = 1:gps
                                 Istart = 100.*(cnt-1) + 1;  %calc starting index
                                 Iend = min(Istart+99,numrows);  %calc ending index
                                 valstr = num2str(vals(Istart:Iend),fstr);  %perform string conversion
                                 if isempty(valstr)
                                    tempvals = nullstr;  %add empty strings
                                 else
                                    %convert to cell, clear NaNs and leading blanks
                                    tempvals = strrep(strrep(cellstr(valstr),'NaN',''),' ','');
                                 end
                                 newvals(Istart:Iend) = tempvals;  %add to cumulative cell array
                              end
                           catch
                              newvals = [];  %return empty array on errors
                           end
                        end
                        
                        %generate transform string
                        if ~isempty(newvals)
                           str_transform = ['strrep(cellstr(num2str(x,',fstr,')),''NaN'','''')'];
                        end
                        
                     end
                     
                  else  %convert to/between numeric formats
                     
                     %check for string-to-numeric conversion
                     if strcmp(dtype,'s')
                        
                        %update q/c criteria, generate history string
                        if flags == 1
                           newcrit = 'manual';  %lock flags to preserve existing
                           flaghist = ', clearing existing Q/C criteria and locking flags to prevent recalculation';
                        else
                           newcrit = '';  %clear Q/C criteria
                           flaghist = ', clearing existing Q/C criteria';
                        end
                        
                        %check for special cases of date/time, coordinate columns and use special filters
                        switch vartype
                           
                           case 'datetime'
                              
                              try
                                 
                                 %perform serial date conversion using datestr2num
                                 newvals = datestr2num(vals,units);
                                 
                                 %look for unsupported date/time format returning NaN
                                 if isempty(find(~isnan(newvals)))
                                    newvals = [];  
                                 end
                                 
                                 %check for time zone appended to units, buffer for adding to newunits
                                 [Itzstart,Itzend] = regexpi(units,'\s+(\(|- )\w{2}(T|C)');
                                 if ~isempty(Itzstart)
                                    tz = units(Itzstart:Itzend);
                                 else
                                    tz = '';
                                 end
                                 
                                 %generate transform string, new units
                                 if ~isempty(newvals)
                                    str_transform = ['x=datestr2num(x,''',units,''')'];
                                    newunits = ['serial day (base 1/1/0000)',tz];
                                 end                                    
                                 
                              catch
                                 newvals = [];
                              end
                              
                           case 'coord'
                              
                              newvals = coordstr2ddeg(vals);  %send to external conversion function
                              
                              %check for unsupported format or all NaN results (returned as empty matrix)
                              if ~isempty(newvals)                         
                                 newunits = 'degrees';
                                 newnumtype = 'angular';
                                 str_transform = 'coordstr2ddeg(x)';
                              end                              
                              
                           otherwise  %general string-to-num conversion
                              
                              try
                                 newvals = str2double(vals);  %convert from string to double first
                                 if ~isempty(find(~isnan(newvals)))
                                    str_transform = 'str2double(x)';  %generate initial transform string
                                 else
                                    newvals = [];  %all NaN - clear output
                                    str_transform = '';
                                 end
                              catch
                                 newvals = [];  %error occurred - clear output
                                 str_transform = '';
                              end
                              
                        end
                        
                        %post-process numbers, determine precision
                        if ~isempty(newvals)
                           
                           %convert from double to integer if necessary
                           switch newdtype
                              case 'd'
                                 newprec = 0;
                                 newnumtype = 'discrete';
                                 switch integeropt
                                    case 'fix'
                                       newvals = fix(newvals);
                                    case 'floor'
                                       newvals = floor(newvals);
                                    case 'ceil'
                                       newvals = ceil(newvals);
                                    otherwise  %default to round
                                       newvals = round(newvals);
                                 end
                                 str_transform = [integeropt,'(',str_transform,')'];
                              case 'f'
                                 newnumtype = 'continuous';
                                 newprec = dec_places(newvals,6);  %use external function to determine decimal places (<=12)
                              case 'e'
                                 newnumtype = 'continuous';
                                 newprec = dec_places(newvals,3);  %use external function to determine decimal places (<=3)
                           end
                           
                        end
                        
                     else  %numeric interconversion
                        
                        newvals = vals;  %start with no conversion
                        
                        %apply integer conversions, determine precision
                        switch newdtype
                           case 'd'
                              newprec = 0;
                              newnumtype = 'discrete';
                              switch integeropt
                                 case 'fix'
                                    newvals = fix(newvals);
                                 case 'floor'
                                    newvals = floor(newvals);
                                 case 'ceil'
                                    newvals = ceil(newvals);
                                 otherwise  %default to round
                                    newvals = round(newvals);
                              end
                              str_transform = [integeropt,'(x)'];
                           case 'f'
                              newnumtype = 'continuous';
                              newprec = dec_places(newvals,6);  %use external function to determine decimal places (<=12)
                           case 'e'
                              newnumtype = 'continuous';
                              newprec = dec_places(newvals,3);  %use external function to determine decimal places (<=3)
                        end                        
                        
                     end                     
                     
                  end
                  
                  if ~isempty(newvals)
                     
                     %update datatype, precision, value array
                     s2.units{col} = newunits;
                     s2.datatype{col} = newdtype;
                     s2.numbertype{col} = newnumtype;
                     s2.precision(col) = newprec;
                     s2.values{col} = newvals;
                     s2.criteria{col} = newcrit;
                  
                     %look up dtype label
                     I_dtype = find(strcmp(dtypelist(:,1),dtype));
                     if ~isempty(I_dtype)
                        str_dtype = dtypelist{I_dtype,2};
                     else
                        str_dtype = 'unknown';
                     end
                     
                     %look up newdtype label
                     I_newdtype = find(strcmp(dtypelist(:,1),newdtype));
                     if ~isempty(I_newdtype)
                        str_newdtype = dtypelist{I_newdtype,2};
                     else
                        str_newdtype = 'unknown';
                     end
                     
                     %update processing history
                     dt = datestr(now);
                     s2.editdate = dt;
                     if ~isempty(str_transform)
                        histstr = ['converted data type of column ',s2.name{col},' from ',str_dtype,' to ',str_newdtype, ...
                           ' using the MATLAB expression "',str_transform, ...
                           '", and updated numerical type to ',newnumtype,' and precision to ',int2str(newprec),flaghist, ...
                           ' (''convert_datatype'')'];
                     else
                        histstr = ['converted data type of column ',s2.name{col},' from ',str_dtype,' to ',str_newdtype, ...
                           ', and updated numerical type to ',newnumtype,' and precision to ',int2str(newprec),flaghist, ...
                           ' (''convert_datatype'')'];
                     end
                     s2.history = [s2.history ; {dt},{histstr}];
                        
                  else
                     badcols = [badcols,col];  %add to bad column array
                  end      
                  
               end
               
            end            
            
            %return empty structure, error message if no conversions successful
            if length(badcols) == length(cols)
               s2 = [];
               msg = 'the specified column(s) could not be converted to the selected data type';
            elseif gce_valid(s2,'data') ~= 1
               s2 = [];
               msg = 'the modified structure failed validation';
            else
               s2 = dataflag(s2,setdiff(cols,badcols));
            end
            
         else  %bad col input
            msg = 'invalid column selection';
         end
         
      else  %bad parameter input
         if inlist(newdtype,{'f','e','d','s'},1) ~= 1
            msg = 'invalid target datatype';
         else
            msg = 'invalid integer conversion option';
         end
      end
      
   else  %bad data structure
      msg = 'invalid data structure';
   end
   
else
   msg = 'insufficient arguments for function';
end