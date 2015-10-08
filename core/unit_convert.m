function [s2,msg] = unit_convert(s,col,newunits,expr,newcol,newcolname)
%Performs unit conversions on a column in a GCE Data Structure using the specified multiplier or expression.
%If no multiplier or expression is supplied, a standard conversion will be performed by matching original
%and new units in the file 'ui_unitconv.mat' (if present). Conversion expressions are documented in the
%'Data'|'Calculations' section of the metadata.
%
%syntax: [s2,msg] = unit_convert(s,col,newunits,expr,newcol)
%
%inputs:
%  s = original structure
%  col = column name or number to convert
%  newunits = new units for column
%  expr = multiplier or expression (note: expression must be a string containing
%    a valid MATLAB equation using x as a value placeholder, e.g. x*1.8+32)
%  newcol = option to add converted data as a new column
%    0 = no (replace data - default)
%    1 = yes
%  newcolname = name for new column (default = newunits appended to original column name,
%     ignored unless newcol = 1)
%
%outputs:
%  s2 = modified structure
%  msg = text of any error message
%
%notes:
%  1) if multiple columns are specified and newunits = 'metric' or 'english' then
%     batch english-to-metric or metric-to-english unit conversions are performed, resp.)
%  2) if newunits matches the current units using a case-sensitive comparison,
%     the unmodified structure will be returned with a warning message
%
%(c)2002-2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 07-Mar-2014

s2 = [];
msg = '';

if nargin >= 3

   %look up column index from name
   if ~isnumeric(col)
      col = name2col(s,col);
   end

   %check for valid column and units
   if ~isempty(newunits) && ~isempty(col)

      %validate newcol input
      if exist('newcol','var') ~= 1 || newcol ~= 1
         newcol = 0;
      end
      
      %validate newcolname input
      if exist('newcolname','var') ~= 1 || newcol == 0
         newcolname = '';
      end

      if length(col) == 1  %single conversion

         %check for unit difference and numeric column
         if ~strcmp(s.units{col},newunits) && ~strcmp(s.datatype{col},'s')

            %set default expression to auto
            if exist('expr','var') ~= 1
               expr = '';
            end

            %init runtime variables
            eq = '';
            mult = [];
            fstr = '';

            %check for supplied multiplier/equation
            if isempty(expr)

               %check for unit conversion dictionary file in path
               if exist('ui_unitconv.mat','file') == 2

                  %load dictionary
                  try
                     vars = load('ui_unitconv.mat','-mat');
                  catch
                     vars = struct('null','');
                  end

                  if isfield(vars,'conversions')

                     %get conversions table variable from file
                     conversions = vars.conversions;

                     %check for valid structure fields
                     if isfield(conversions,'units1') && isfield(conversions,'units2') && ...
                           isfield(conversions,'multiplier') && isfield(conversions,'equation')

                        %perform case-sensitive match first, then case-insensitive if no match
                        I1 = find(strcmp({conversions.units1}',s.units{col}));
                        if isempty(I1)
                           I1 = find(strcmpi({conversions.units1}',s.units{col}));
                        end

                        %match newunits if match for oldunits
                        if ~isempty(I1)
                           I2 = find(strcmp({conversions.units2}',newunits));
                           if isempty(I2)
                              I2 = find(strcmpi({conversions.units2}',newunits));
                           end
                        else
                           I2 = [];
                        end

                        %check for valid combination of units
                        I = intersect(I1,I2);

                        %get multiplier or equation for first match
                        if length(I) >= 1
                           I = I(1);  %force first match if multiples
                           mult = conversions(I).multiplier;
                           if ~isempty(mult)
                              eq = '';
                              fstr = conversions(I).formatstring;
                           else
                              eq = conversions(I).equation;
                           end
                        end

                     end

                  end
               end

            elseif ischar(expr)

               if isempty(strfind(expr,'x'))  %catch string multipliers
                  mult = str2double(expr);
                  if isnan(mult)
                     mult = [];
                  end
                  eq = '';
               else
                  mult = [];
                  eq = expr;
               end

            else
               mult = expr;
               eq = '';
            end

            %check for valid multiplier or equation
            if ~isempty(mult) || ~isempty(eq)

               try  %perform conversions

                  %init runtime vars
                  x = s.values{col};
                  error = 0;
                  y = [];

                  %calculate converted column values
                  if ~isempty(mult)
                     y = x .* mult;
                  else
                     try
                        eval(['y=',eq,';'])
                     catch
                        error=1;
                     end
                  end

                  %update numeric comparison criteria
                  crit = s.criteria{col};
                  if ~isempty(crit)
                     [crit,numconv] = convert_crit_units(crit,mult,eq);
                     critstr = [' and ',int2str(numconv),' QA/QC flag criteria parameters'];
                  else
                     critstr = '';
                  end

                  if error == 0 && size(y,2) == 1 && size(y,1) == size(x,1)

                     %get column name, units and calculation metadata from original structure
                     colname = s.name{col};
                     oldunits = s.units{col};
                     calcs = lookupmeta(s,'Data','Calculations');

                     %check for newcol option
                     if newcol ~= 1

                        %just update value array, units metadata and Q/C criteria
                        newcolname = colname;
                        s.values{col} = y;
                        s.units{col} = newunits;
                        s.criteria{col} = crit;
                        s.history = [s.history ; ...
                              {datestr(now)},{['converted units of ''',colname,''' column',critstr,' from ',oldunits,' to ',newunits,' (''unit_convert'')']}];

                     else
                        
                        %generate newcolname if empty
                        if isempty(newcolname)
                           
                           %remove invalid characters from unit string, first performing common substitutions
                           unitstr = strrep(strrep(strrep(strrep(newunits,' ','_'),char(176),''),char(181),'u'),'*','x');
                           unitstr_clean = '';
                           for n = 1:length(unitstr)
                              testchar = unitstr(n);
                              if ~isempty(find(testchar == '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz'))
                                 unitstr_clean = [unitstr_clean,testchar];
                              end
                           end
                           
                           %generate new column name from original plus cleaned up units
                           newcolname = [colname,'_',unitstr_clean];
                           
                        end

                        %add converted column to data structure, copying attribute metadata
                        [s2,msg2] = addcol(s,y, ...
                           newcolname, ...
                           newunits, ...
                           s.description{col}, ...
                           s.datatype{col}, ...
                           s.variabletype{col}, ...
                           s.numbertype{col}, ...
                           s.precision(col), ...
                           crit, ...
                           col+1);

                        %check for column insert errors, generate history entry
                        if ~isempty(s2)
                           s2.history = [s.history ; ...
                              {datestr(now)},{['converted units of ''',colname,''' column',critstr, ...
                                    ' from ',oldunits,' to ',newunits,' and added to structure as new column ', ...
                                    newcolname,' (''unit_convert'')']}];
                           s = s2;
                        else
                           s = [];
                           msg = ['errors occurred adding the converted data as a new column (',msg2,')'];
                        end

                     end

                     if ~isempty(mult)
                        if ~isempty(fstr)
                           newcalcs = ['|',newcolname,': ',newcolname,'(',newunits,') = ',colname,'(',oldunits,') * ',sprintf(fstr,mult)];
                        else
                           newcalcs = ['|',newcolname,': ',newcolname,'(',newunits,') = ',colname,'(',oldunits,') * ',num2str(mult)];
                        end
                     else
                        newcalcs = ['|',newcolname,': ',newcolname,'(',newunits,') = ',strrep(eq,'x',[colname,'(',oldunits,')'])];
                     end

                     %check for old calc string > 1 line or if 1 line not starting with 'none' or 'not')
                     if ~isempty(calcs)
                        if size(calcs,1) > 1 || (isempty(find(strncmp('none',calcs,4))) && isempty(find(strncmp('not',calcs,3))))
                           newcalcs = [calcs,newcalcs];
                        end
                     end

                     %add calcuation metadata, generate output structure
                     s2 = addmeta(s,[{'Data'},{'Calculations'},{newcalcs}],1);
                     
                     %recalculate q/c flags, checking for cross-references in other columns
                     allcrit = s2.criteria;
                     pat = ['col_',s2.name{col}];
                     try
                        %get index of all references to column in q/c rules using cell-array version of strfind
                        Imatch = strfind(allcrit,pat); 
                     catch
                        try
                           %use loop version if strfind doesn't support cell arrays (older MATLAB)
                           Imatch = cell(1,length(allcrit));
                           for cnt = 1:length(allcrit);
                              Imatch{cnt} = strfind(allcrit{cnt},pat);
                           end
                        catch
                           Imatch = cell(1,length(allcrit));  %return empty cell array on error
                        end
                     end
                     cols = unique([col,find(~cellfun('isempty',Imatch))]);  %get list of columns containing references plus updated column
                     s2 = dataflag(s2,cols);  %update flags

                  end

               catch
                  s2 = [];  %clear output parm
                  msg = 'errors occurred applying unit conversions';
               end

            else
               msg = 'conversion equation could not be determined';
            end

	      else

      	   if strcmp(s.datatype{col},'s')
   	         msg = 'unit conversions cannot be applied to string columns';
         	else  %no unit change
               s2 = s;
            	msg = 'column is already in the specified units (no change made)';
    	      end

         end

      else  %batch conversion

         if exist('ui_unitconv.mat','file') == 2

            %load conversions database (data structure)
            try
               vars = load('ui_unitconv.mat','-mat');
            catch
               vars = struct('null','');
            end

            if isfield(vars,'englishmetric')

               %get englishmetric variable for ui_unitconv.mat file
               englishmetric = vars.englishmetric;

               %assign relevant list to runtime variables
               if strcmp(newunits,'english')
                  unit_comp = extract(englishmetric,'Metric');
                  unit_conv = extract(englishmetric,'English');
               else
                  unit_comp = extract(englishmetric,'English');
                  unit_conv = extract(englishmetric,'Metric');
               end

               %init runtime arrays of columns converted and errors
               cols = [];
               errors = [];

               %loop through structure columns checking for units to convert
               for n = 1:length(s.units)
                  Imatch = find(strcmp(s.units{n},unit_comp));  %get index of matching units in master list
                  if length(Imatch) >= 1
                     Imatch = Imatch(1);  %force first match
                     data = unit_convert(s,n,unit_conv{Imatch});  %call function recursively in single unit mode
                     if ~isempty(data)
                        cols = [cols,n];
                        s = data;
                     else
                        errors = [errors,n];
                     end
                  end
               end

               %check for successful conversion (or none)
               if isempty(cols)
                  msg = 'no unit conversions were applied';
               else
                  s2 = s;  %assign revised structure to output
                  if ~isempty(errors)
                     if length(errors) == 1
                        msg = ['errors occurred applying unit conversion to column ',s.name{errors}];
                     else
                        msg = ['errors occurred applying unit conversions to columns ',cell2commas(s.name(errors),1)];
                     end
                  end
               end

            else
               msg = 'unit conversions file ''ui_unitconv.mat'' is invalid or corrupted';
            end

         else
            msg = 'unit conversions file ''ui_unitconv.mat'' could not be located';
         end

      end

   else

      if isempty(newunits)
         msg = 'new units were not specified';
      else
         msg = 'invalid data structure column';
      end

   end

else
   msg = 'insufficient inputs for functions';
end


%subfunction to convert QA/QC criteria
function  [crit2,numconv] = convert_crit_units(crit,mult,eq)

crit2 = '';
numconv = 0;

if ~isempty(crit) && (~isempty(mult) || ~isempty(eq))  %check for something to do

   ar = splitstr(crit,';');  %break up multiple criteria
   charlist = '0123456789Ee+-.';  %define numerical characters

   for n = 1:length(ar);

      %init runtime vars
      str = ar{n};
      revnumstr = '';
      Imatch = strfind(str,'=''');  %get index of character assignment token

      %check for valid expr, excluding external col refs
      if ~isempty(Imatch) && isempty(strfind(str,'col_'))  
         
         %add numeric characters to number string in reverse order working back from flag assignment
         for m = Imatch(1)-1:-1:1
            if ~isempty(strfind(charlist,str(m)))
               revnumstr = [revnumstr,str(m)];
            else
               break
            end
         end
         
         if ~isempty(revnumstr)
            num = str2double(fliplr(revnumstr));
            if ~isempty(mult)
               newnum = num .* mult;
            else
               newnum = [];
               err = 0;
               try
                  %assign number to x variable and evaluate expression
                  eval(['x=num; newnum=',eq,';'])
               catch
                  err = 1;
               end
               if err == 1
                  newnum = [];
               end
            end
            if ~isempty(newnum)
               str = strrep(str,fliplr(revnumstr),num2str(newnum));
               ar{n} = str;
               numconv = numconv + 1;
            end
         end
         
      end
      
   end

   ar = [ar' ; repmat({';'},1,length(ar))];
   crit2 = [ar{:}];
   crit2 = crit2(1:end-1);

end