function [s2,msg] = normalize_cols(s,cols,repcols,cat_name,val_name,unitsopt,datatype)
%Normalizes a data set by merging multiple columns to form combined parameter name and parameter value columns
%with records in other specified columns repeated for each group of parameters (i.e. converts a dataset with 
%repeating groups to a normalized database table)
%
%Note that the original column names will be replicated and used as parameter names
%in the resultant data set
%
%syntax: [s2,msg] = normalize_cols(s,cols,repcols,cat_name,val_name,unitsopt,datatype)
%
%input:
%  s = data structure to modify (required)
%  cols = array of column names or numbers to normalize (required)
%     (note that datatype, numbertype and units of specified columns must all match unless
%     unitsopt and datatype arguments dictate otherwise)
%  repcols = array of column names or numbers to replicate for each record of cols
%     (optional; [] = none, all columns not specified by cols if omitted)
%  cat_name = name for the combined category column (optional; default = 'Column_Names')
%  val_name = name for the combined value column (optional; default = 'Column_Values')
%  unitsopt = option for units matching:
%     'match' = only merge columns with matching data type and units (default)
%     'ignore' = ignore differences in units and variable types and include a units column
%         named [val_name,'_Units']
%  datatype = data type for values columns (converted using convert_datatype.m as necessary):
%     '' = datatype of source columns (must all match)
%     'f' = cast all columns to floating point with precision based on the maximum preciion for cols
%     'e' = cast all columns to exponential with precision based on the maximum precision for cols
%     's' = cast all columns to string with precision = 0
%     'round' = cast all columns to integer by rounding values with precision = 0
%     'fix' = cast all columns to integer by truncating values with precision = 0
%     'ceil' = cast all columns to integer by rounding up values with precision = 0
%     'floor' = cast all columns to integer by rounding down values with precision = 0
%
%output:
%  s2 = updated structure
%  msg = text of any error message
%
%notes:
%  - when string columns are converted to a numeric datatype, non-numeric strings values will
%    be converted to NaN, and datetime and coordinate columns will be converted to numeric
%    serial dates and decimal degrees, resp. (see 'convert_datatype.m')
%  - when numeric columns are converted to string, the specified precision of each column
%    will be used for formatting
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
%last modified: 08-Aug-2014

%init output
s2 = [];
msg = '';

%check for required input
if nargin >= 2
   
   %validate data structure
   if gce_valid(s,'data')
      
      %use defaults for omitted parameters
      if exist('cat_name','var') ~= 1
         cat_name = 'Column_Names';
      end
      
      if exist('val_name','var') ~= 1
         val_name = 'Column_Values';
      end
      
      %validate units option
      if exist('unitsopt','var') ~= 1
         unitsopt = 'match';
      elseif ~strcmp(unitsopt,'ignore') && ~strcmp(unitsopt,'include')
         unitsopt = 'match';
      end
      
      %validate datatype option
      if exist('datatype','var') ~= 1
         datatype = '';
      end
      if ~isempty(datatype) && max(~inlist(datatype,{'','f','s','e','round','fix','ceil','floor'})) == 1
         datatype = '';
      end
      
      %look up indices of column names
      if ~isnumeric(cols)
         cols = name2col(s,cols);
      else
         %remove invalid column selections, preserving order
         [tmp,Iskip] = setdiff(cols(:)',(1:length(s.name)));
         if ~isempty(Iskip)
            cols(Iskip) = NaN;
            cols = cols(~isnan(cols));
         end
      end
      
      %look up indices of columns to replicate
      if exist('repcols','var') ~= 1
         if ~isempty(cols)
            %default to all other cols if omitted
            repcols = setdiff([1:length(s.name)],cols(:)');
         else
            repcols = [];
         end
      elseif ~isempty(repcols)
         if ~isnumeric(repcols)
            repcols = name2col(s,repcols);
         else
            %remove invalid column selections, preserving order
            [tmp,Iskip] = setdiff(repcols,(1:length(s.name)));
            if ~isempty(Iskip)
               repcols(Iskip) = NaN;
               repcols = repcols(~isnan(repcols));
            end
         end
         %remove repcols already included in cols, preserving order
         [tmp,Idupe] = intersect(repcols,cols);
         if ~isempty(Idupe)
            repcols(Idupe) = NaN;
            repcols = repcols(~isnan(repcols)); 
         end
      end
      
      %check for valid columns
      if length(cols) > 1
         
         %init units buffer for unitsopt = 'include' 
         units_all = s.units;
         
         %check for datatypes and units standardization options
         if ~isempty(datatype) || ~strcmp(unitsopt,'match')
            
            %clear units if unitsopt ~= match
            if ~strcmp(unitsopt,'match')
               s.units(cols) = repmat({''},1,length(cols));
               s.variabletype(cols) = repmat({'data'},1,length(cols));
            end
            
            %standardize column data types
            if ~isempty(datatype)
               
               %set options for convert_datatype.m and post-conversion attribute metadata
               switch datatype
                  case 'f'
                     newdtype = 'f';
                     integeropt = 'round';
                     newvartype = 'data';
                     newnumtype = 'continuous';
                     newprec = max(s.precision(cols));
                  case 's'
                     newdtype = 's';
                     integeropt = 'round';
                     newvartype = 'nominal';
                     newnumtype = 'none';
                     newprec = 0;
                  case 'e'
                     newdtype = 'e';
                     newvartype = 'data';
                     integeropt = 'round';
                     newnumtype = 'continuous';
                     newprec = max(s.precision(cols));
                  case 'round'
                     newdtype = 'd';
                     newvartype = 'data';
                     integeropt = 'round';
                     newnumtype = 'discrete';
                     newprec = 0;
                  case 'fix'
                     newdtype = 'd';
                     newvartype = 'data';
                     integeropt = 'fix';
                     newnumtype = 'discrete';
                     newprec = 0;
                  case 'ceil'
                     newdtype = 'd';
                     newvartype = 'data';
                     integeropt = 'ceil';
                     newnumtype = 'discrete';
                     newprec = 0;
                  case 'floor'
                     newdtype = 'd';
                     newvartype = 'data';
                     integeropt = 'floor';
                     newnumtype = 'discrete';
                     newprec = 0;
                  otherwise
                     newdtype = '';
                     newvartype = 'data';
                     integeropt = '';                     
                     newnumtype = '';
                     newprec = 0;
               end
               
               %perform conversions and set attributes
               if ~isempty(newdtype)              
                  s = convert_datatype(s,cols,newdtype,integeropt);
                  s.numbertype(cols) = repmat({newnumtype},1,length(cols));
                  s.precision(cols) = repmat(newprec,1,length(cols));
                  s.variabletype(cols) = repmat({newvartype},1,length(cols));
               end
               
            end
            
         end

         %generate check indices for matching datatype, variabletype, numbertype, units
         num_dtype = length(unique(s.datatype(cols)));
         num_vtype = length(unique(s.variabletype(cols)));
         num_ntype = length(unique(s.numbertype(cols)));
         num_units = length(unique(s.units(cols)));
         
         if num_dtype == 1 && num_vtype == 1 && num_ntype == 1 && num_units == 1
            
            %look up column descriptors from first listed column
            dtype = s.datatype{cols(1)};
            vtype = s.variabletype{cols(1)};
            ntype = s.numbertype{cols(1)};
            units = s.units{cols(1)};
            prec = s.precision(cols(1));
            
            %add category field
            s2 = addcol(s,' ',cat_name,'none', ...
               ['Categorical values from normalization of data columns ',cell2commas(s.name(cols),1)], ...
               's','nominal','',0,'','');
            
            %add value field based on data type
            if strcmp(dtype,'s')
               tempvals = ' ';
            else
               tempvals = NaN;
            end            
            s2 = addcol(s2,tempvals,val_name,units, ...
               ['Combined values from normalization of data columns ',cell2commas(s.name(cols),1)], ...
               dtype,vtype,ntype,prec,'manual','');
            
            %add units field for unitsopt = 'include'
            s2 = addcol(s2,' ',[val_name,'_Units'],'', ...
               ['Combined units from normalization of data columns ',cell2commas(s.name(cols),1)], ...
               's','nominal','',0,'','');
            
            if ~isempty(s2)
               
               %copy replication columns plus new normalized columns to create new structure
               Icopy = [repcols(:)',length(s2.name)-2:length(s2.name)];
               s2 = copycols(s2,Icopy);

               %update column indices for category, value columns after extraction
               Iunitcol = length(s2.name);
               Ivalcol = Iunitcol-1;
               Icatcol = Iunitcol-2;
               
               %determine number of records for array dimensioning
               numrecs = num_records(s2);  %number of records for original data arrays
               totrecs = numrecs .* length(cols);  %calculated total for final data arrays
               
               %init category, value, units and flag arrays based on first specified column
               vals_cats = repmat({''},totrecs,1);
               if strcmp(s.datatype{cols(1)},'s')
                  vals_vals = vals_cats;
               else
                  vals_vals = repmat(NaN,totrecs,1);
               end
               vals_units = vals_cats;
               vals_flags = repmat(' ',totrecs,1);
               
               %loop through remaining columns and append to arrays, replicating other records as necessary
               for n = 1:length(cols)
                  
                  %get starting and ending indices for output arrays
                  Istart = numrecs * (n-1) + 1;
                  Iend = numrecs * n;
                  
                  %add categories, units to cumulative arrays
                  vals_cats(Istart:Iend) = repmat(s.name(cols(n)),numrecs,1);
                  vals_units(Istart:Iend) = repmat(units_all(cols(n)),numrecs,1);

                  %add values, flags
                  [vals_newvals,vals_newflags] = extract(s,cols(n));
                  vals_vals(Istart:Iend) = vals_newvals;

                  %get flag array dimensions for comparison
                  flagsize1 = size(vals_flags,2);
                  flagsize2 = size(vals_newflags,2);

                  %resize flag character arrays to match, then add new flags to master flag array
                  if flagsize2 == 0
                     vals_newflags = repmat(' ',numrecs,flagsize1);  %expand empty new flags
                  elseif flagsize2 > flagsize1
                     vals_flags = [vals_flags,repmat(' ',totrecs,flagsize2-flagsize1)];
                  end
                  vals_flags(Istart:Iend,1:flagsize2) = vals_newflags(:,1:flagsize2);
                  
                  %calculate indices for records to copy for replicated columns
                  Iorig = (1:num_records(s2))';  %index for all existing records in output strcture
                  Icopy = (1:numrecs)';  %index for original records to copy
                  
                  %copy records in replication columns, skipping first iteration since records already exist
                  if n > 1
                     s2 = copyrows(s2,[Iorig;Icopy],'Y');
                  end
                  
               end

               %update normalized category, value columns with cumulative arrays
               s2 = update_data(s2,Icatcol,vals_cats,0);
               s2 = update_data(s2,Ivalcol,vals_vals,0);
               
               %check for cumulative flags - add to data column
               if size(vals_flags,2) > 1 || sum(vals_flags(:,1) ~= ' ') > 0
                  s2 = addflags(s2,Ivalcol,[],vals_flags);
               end
               
               %update or delete units column based on option, generating appoproiate history entry string
               if strcmp(unitsopt,'ignore')
                  s2 = update_data(s2,Iunitcol,vals_units,0);
                  str_hist = ['created normalized data set by combining values in columns ',cell2commas(s.name(cols),1), ...
                        ' to generate categorical column ',cat_name,', value column ',val_name,' and units column ',val_name,'_Units'];
               else
                  s2 = deletecols(s2,Iunitcol);
                  str_hist = ['created normalized data set by combining values in columns ',cell2commas(s.name(cols),1), ...
                        ' to generate categorical column ',cat_name,' and value column ',val_name];
               end
               
               %check for no flags in combined value column and remove manual token and empty flag array
               Iflags = find(vals_flags ~= ' ');
               
               if isempty(Iflags)
                  Ivalcol = name2col(s2,val_name);
                  s2.flags(Ivalcol) = {''};
                  s2.criteria(Ivalcol) = {''};
               end
               
               %add data type conversion to history entry
               if ~isempty(datatype)
                  switch datatype
                     case 'f'
                        datatype_string = 'floating point';
                     case 'e'
                        datatype_string = 'exponential';
                     case 's'
                        datatype_string = 'string';
                     otherwise
                        datatype_string = ['integer (',datatype,')'];                        
                  end
                  str_hist = [str_hist,', converting values in ',val_name,' to ',datatype_string,' data type'];
               end
               
               %complete history string
               if ~isempty(repcols)
                  str_hist = [str_hist,', replicating values in column(s) ',cell2commas(s.name(repcols),1), ...
                     ' for each distinct ',cat_name];
               end
               str_hist = [str_hist,' (''normalize_cols'')'];               
               
               %update edit date, processing history
               curdate = datestr(now);
               s2.editdate = curdate;
               s2.history = [s.history ; {curdate},{str_hist}];
               
            else
               msg = 'an error occurred normalizing the data set with the specified options';
            end
            
         else  %mismatched columns
            
            %generate appropriate error message based on mismatches
            if num_dtype ~= 1
               msg = [msg,', mismatched data types'];
            end
            
            if num_vtype ~= 1
               msg = [msg,', mismatched variable types'];
            end
            
            if num_ntype ~= 1
               msg = [msg,', mismatched numerical types'];
            end
            
            if num_units ~= 1
               msg = [msg,', mismatched units'];
            end
            
            msg = ['invalid column selection - ',msg(3:end)];
            
         end
         
      else
         msg = 'invalid column selection';   
      end
      
   else
      msg = 'invalid data structure';
   end
   
else
   msg = 'insufficient arguments';
end