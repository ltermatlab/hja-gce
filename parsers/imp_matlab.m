function [s,msg] = imp_matlab(fn,pn,varlist,template)
%Reads selected variables in a MATLAB binary file or the base worskspace to form a GCE Data Structure.
%
%syntax: [s,msg] = imp_matlab(source,pn,varlist,template)
%
%input:
%  source = filename to import or 'workspace' to specify base workspace (default = prompted)
%  pn = pathname for source (default = pwd or none for source = 'workspace')
%  varlist = array of variable names to import (default = selected from a list dialog)
%  template = metadata template to apply (default = '' for none)
%
%output:
%  s = GCE data structure
%  msg = text of any error messages
%
%usage notes:
%  1. cell, numeric and character arrays and matrices are supported, and basic data descriptor
%     metadata are determined automatically by value inspection
%  2. cell arrays must only contain scalar character or numeric elements
%     (numeric values will be converted to strings automatically, which may
%     result in a change in precision)
%  3. padded character arrays will be converted to a 1-column cell array of strings
%  4. row-oriented numeric and cell arrays will be converted to column-major orientation
%  5. numeric and cell matrices will be split into multiple data set columns, with "_col[n]"
%     appended to the common column name
%
%
%(c)2002-2012 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 04-Oct-2012

s = [];
msg = '';
curpath = pwd;

%validate path
if exist('pn','var') ~= 1
   pn = '';
end
if isempty(pn)
   pn = curpath;
elseif ~isdir(pn)
   pn = curpath;
elseif strcmp(pn(end),filesep)
   pn = pn(1:end-1);  %strip terminal file separator
end

%validate file, prompt if omitted, invalid
if exist('fn','var') ~= 1
   fn = '';
end

%check for workspace option
if ~strcmpi(fn,'workspace')
   filemask = '';
   if isempty(fn)
      filemask = '*.mat';
   elseif exist([pn,filesep,fn],'file') ~= 2
      filemask = fn;
      fn = '';
   end
   if isempty(fn)
      cd(pn)
      [fn,pn] = uigetfile(filemask,'Select a MATLAB data file to import');
      cd(curpath)
      drawnow
      if fn == 0
         fn = '';
      end
   end
end

%load file unless operation cancelled from file dialog
if ~isempty(fn)
   
   %init empty variable list if omitted
   if exist('varlist','var') ~= 1
      varlist = [];
   end
   
   %set default template option if omitted
   if exist('template','var') ~= 1
      template = '';
   end
   
   if strcmpi(fn,'workspace')
      ws = evalin('base','whos');  %get list of variables in workspace
      if ~isempty(ws)
         Ivalid = find(~strcmp({ws.class},'struct'));  %get index of non-structure arrays
      else
         Ivalid = [];
      end
      if ~isempty(Ivalid)
         ws = ws(Ivalid);  %remove unsupported variables
         vars = [];
         for n = 1:length(ws)
            varname = ws(n).name;  %get variable name from structure
            newdata = evalin('base',varname,'[]');  %get values
            if ~isempty(newdata)
               vars.(varname) = newdata;  %assign to vars structure
            end
         end
      else
         vars = [];
      end
   else %load file
      vars = [];
      try
         vars = load([pn,filesep,fn],'-mat');  %load variables into structure
      catch
         msg = 'Invalid MATLAB data file';
      end
   end
   
   if isstruct(vars)  %check for valid file
      
      %get array of variable names in file
      varnames = fieldnames(vars);
      
      %check for variable list input, build select list if not specified
      if isempty(varlist)
         
         %generate variable description strings for selection listbox
         vardesc = varnames;
         for n = 1:length(varnames)
            varclass = class(vars.(varnames{n}));
            [var_r,var_c] = size(vars.(varnames{n}));
            if var_r > 1
               r_str = [int2str(var_r),' rows'];
            else
               r_str = [int2str(var_r),' row'];
            end
            if var_c > 1
               c_str = [int2str(var_c),' cols'];
            else
               c_str = [int2str(var_c),' col'];
            end
            vardesc{n} = [varnames{n},'  (',varclass,' array, ',r_str,' x ',c_str,')'];
         end
         
         %check for a single valid variable - import automatically
         if length(varnames) == 1
            
            if ~isstruct(vars.(varnames{1}))
               Isel = 1;
            else
               Isel = [];
               msg = 'no compatible numeric or cell array variables were found in the file';
            end
            
         else  %use selection list
            
            %init selection indices
            Iall = [];
            Isel = [];
            
            %build index of non-structure variables
            for n = 1:length(varnames)
               if ~isstruct(vars.(varnames{n}))
                  Iall = [Iall,n];
               end
            end
            
            %build list dialog
            if ~isempty(Iall)
               
               %remove unsupported variable names, descriptions, init list dialog
               varnames = varnames(Iall);
               vardesc = vardesc(Iall);
               res = get(0,'screensize');
               Isel = listdialog('liststring',vardesc, ...
                  'selectionmode','multiple', ...
                  'name','Select one or more variables to import', ...
                  'listsize',[max(0,0.5.*(res(3)-400)) max(50,0.5.*(res(4)-300)) 400 300]);
               drawnow
               
               if isempty(Isel)
                  msg = 'no variables were selected';
               end
               
            else
               msg = 'no compatible numeric or cell array variables were found in the file';
            end
            
         end
         
      else  %use user-provided list of variables, if provided
         
         %match variables by name
         Isel = zeros(length(varnames),1);
         for n = 1:length(varlist)
            Imatch = find(strcmp(varnames,varlist{n}));
            if ~isempty(Imatch)
               Isel(Imatch) = 1;
            end
         end
         
         %compress index
         Isel = find(Isel);
         
      end
      
      %check for selected variables
      if ~isempty(Isel)
         
         %count number of variables to import
         numvars = length(Isel);
         
         %init runtime vars
         values = [];
         colnames = [];
         numrows = [];
         badvars = [];
         
         %process selected variables
         for n = 1:numvars
            
            %extract variable
            data = vars.(varnames{Isel(n)});
            
            if isstruct(data)  %check for structures
               data = [];
               badvars = [badvars ; {[varnames{Isel(n)},' - structure variables are not supported']}];
            elseif iscell(data)  %test cell arrays for non-scalar elements
               numels = cellfun('size',data,1);  %check number of array elements
               charclass = cellfun('isclass',data,'char');  %check char class of elements
               numclass = cellfun('isclass',data,'double');  %check for numeric class of elements
               if ~isempty(find(numels > 1)) || ~isempty(find(charclass == 0 & numclass == 0))
                  data = [];  %multi-dimensional or mixed-type cell array - skip
                  badvars = [badvars ; {[varnames{Isel(n)},' - unsupported cell array content']}];
               elseif size(data,1) == 1 && size(data,2) > 1
                  data = data(:);  %convert row orientation to column
               end
            elseif isempty(data)
               badvars = [badvars ; {[varnames{Isel(n)},' - variable is empty']}];
            elseif size(data,1) == 1 && size(data,2) > 1 && ~ischar(data)  
               data = data(:); %convert row vectors to col vectors (unless single character array)
            end
            
            if ~isempty(data)  %continue if OK
               if isempty(numrows)  %check for empty row check value
                  numrows = size(data,1);
               end
               if size(data,1) == numrows  %add data columns to array
                  if size(data,2) == 1 || ischar(data)  %single numeric/cell column or character array
                     if ischar(data)
                        data = cellstr(data);
                     end
                     values = [values , {data}];
                     colnames = [colnames , {varnames{Isel(n)}}];
                  else  %loop through multiple columns, appending column index
                     for m = 1:size(data,2)
                        values = [values , {data(:,m)}];
                        colnames = [colnames , {[varnames{Isel(n)},'_col',int2str(m)]}];
                     end
                  end
               else
                  badvars = [badvars ; {[varnames{Isel(n)},' - invalid number of data rows']}];
               end
            end
            
         end
         
         %build structure if data successfully imported
         if ~isempty(values)
            
            numcols = length(values);
            
            %init default arrays of column descriptors
            dtype = repmat({'u'},1,numcols);
            units = repmat({''},1,numcols);
            desc = repmat({''},1,numcols);
            vtype = repmat({'data'},1,numcols);
            ntype = units;
            prec = zeros(1,numcols);
            crit = repmat({''},1,numcols);
            flags = crit;
            
            %evaluate data, assign descriptors by value inspection
            for n = 1:length(values)
               
               vals = values{n};
               
               if iscell(vals)  %assume cell arrays = strings
                  
                  %convert numeric elements in the cell array to strings
                  Inumeric = find(cellfun('isclass',vals,'double'));
                  if ~isempty(Inumeric)
                     for cnt = 1:length(Inumeric)
                        pos = Inumeric(cnt);
                        try
                           vals{pos} = num2str(vals{pos});
                        catch
                           vals{pos} = '';
                        end
                     end
                     values{n} = vals;  %update column values
                  end
                  
                  dtype{n} = 's';
                  vtype{n} = 'text';
                  ntype{n} = 'none';
                  
               else  %determine initial numerical attributes
                  
                  Ivalid = find((abs(vals)>0)+(~isnan(vals)) == 2);  %get index of nonzero, non-NaN vals
                  
                  if ~isempty(Ivalid)
                     
                     if sum(vals(Ivalid) - fix(vals(Ivalid))) == 0  %check for integers
                        
                        dtype{n} = 'd';
                        ntype{n} = 'discrete';
                        prec(n) = 0;
                        
                     else
                        
                        ntype{n} = 'continuous';
                        
                        %determine precision based on order of magnitude
                        try
                           om = ceil(log10(max(abs(vals(Ivalid)))));
                           if 10.^om >= 1e6
                              dtype{n} = 'e';
                              prec(n) = 3;
                           else
                              dtype{n} = 'f';
                              prec(n) = max(0,5-om);  %default to >= 5 significant digits
                           end
                        catch
                           dtype{n} = 'f';
                           prec(n) = 0;
                        end
                        
                     end
                     
                  else  %all values empty/zero
                     
                     dtype{n} = 'd';
                     ntype{n} = 'discrete';
                     prec(n) = 0;
                     
                  end
                  
               end
               
            end
            
            %instantiate and populate structure
            s = newstruct('data');  %create empty data structure
            curdate = now;
            
            titlestr = ['Data imported from ''',fn,''' on ',datestr(curdate,1)];
            s.title = titlestr;
            s.metadata = [{'Dataset'},{'Title'},{titlestr}];
            s.datafile = [{fn},{length(values{1})}];
            s.createdate = datestr(curdate);
            s.history = [s.history; ...
               {datestr(curdate)},{'data imported from MATLAB data file, data descriptors assigned automatically (''imp_matlab'')'}];
            s.name = colnames;
            s.units = units;
            s.description = desc;
            s.datatype = dtype;
            s.variabletype = vtype;
            s.numbertype = ntype;
            s.precision = prec;
            s.values = values;
            s.criteria = crit;
            s.flags = flags;
            
            %validate structure
            [valid,stype,errmsg] = gce_valid(s,'data');
            
            if valid == 1  %check data structure validity
               
               %apply template if defined
               if ~isempty(template)
                  [s,msg] = apply_template(s,template);
               else
                  s = dataflag(s);  %evaluate q/c criteria only
               end
               
               %check for bad variables, generate warning
               if ~isempty(badvars)
                  badvar_msg = char([{'Note: the following variables were not imported for the reasons listed:'}; ...
                     {''}; badvars]);
                  if isempty(msg)
                     msg = badvar_msg;
                  else
                     msg = char([{msg};{''};{badvar_msg}]);
                  end
               end               
               
            else
               s = [];
               msg = 'GCE data structure could not be created';
               if ~isempty(errmsg)
                  msg = [msg,' (error: ',errmsg];
               end
            end
            
         else
            msg = 'None of the selected variables are compatible with the GCE Data Structure specification';
         end
         
      else
         if isempty(msg)
            msg = 'No variables were selected - import cancelled';
         end
      end
      
   else
      if strcmpi(fn,'workspace')
         msg = 'No compatible variables were found in the base MATLAB workspace';
      else
         msg = ['''',fn,''' is not a valid MATLAB binary file - import cancelled'];
      end
   end
   
end