function msg = exp_matlab(s,fn,pn,filetype,metastyle,flagopt,flagcols,varname)
%Exports the contents of a GCE Data Structure as a standard MATLAB data file containing data and metadata as variables
%
%syntax:  msg = exp_matlab(s,fn,pn,filetype,metastyle,flagopt,flagcols,varname)
%
%inputs:
%  s = data structure
%  fn = filename
%  pn = pathname
%  filetype = file type to export:
%     'mat' = numerical matrix, with string columns encoded as integers
%           and documented in the metadata
%     'vars' = columns as individual named variables (numerical arrays or
%           cell arrays of strings)
%     'struct' = standard MATLAB struct with column names as field names and rows as
%           structure dimension (i.e. nx1 struct, where n = number of rows)
%  metastyle = metadata style to use for formatting documentation stored in the
%     variable 'metadata' (default = 'GCE', '' = no metadata)
%  flagopt = option to convert flags to data columns/arrays
%     'E' = encode flags as integer columns and document codes in metadata (default)
%     'S' = encode flags as cell arrays of string columns (filetype = vars only)
%     'N' = do not convert flags
%  flagcols = option specifying which flag arrays to instantiate if flagopt = 'E' or 'S'
%     'mult' = create a flag column/array for every column containing any flagged values (default)
%     'alldata' = create a flag column/array for every column assigned variable type
%        'data' or 'calculation', regardless of whether flags are assigned or not
%     'mult+data' = same as 'alldata', except flags are included for non-data, non-calculation 
%        columns with flags assigned
%     'all' create a flag column/array for every column regardless of flag assignments
%  varname = variable name to use for filetype 'mat' or 'struct' (default = 'data')
%
%output:
%  msg = text of any error messages
%
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
%last modified: 02-Sep-2014

msg = '';

if nargin >= 1

   %assign defaults for omitted parameters
   if exist('flagopt','var') ~= 1
      flagopt = 'E';
   end

   if exist('flagcols','var') ~= 1
      flagcols = 'mult';
   elseif ~inlist(flagcols,{'alldata','all','mult+data'})
      flagcols = 'mult';
   end

   if exist('metastyle','var') ~= 1
      metastyle = 'GCE'; %use default GCE metadata style
   end

   if exist('filetype','var') ~= 1
      filetype = 'vars';
   else
      filetype = lower(filetype);
   end
   
   if exist('varname','var') ~= 1
      varname = 'data';
   end

   %validate input structure
   if gce_valid(s,'data')

      %cache working directory
      curpath = pwd;
      
      %validate path
      if exist('pn','var') ~= 1
         pn = '';
      end
      if isempty(pn)
         pn = curpath;
      elseif ~isdir(pn)
         pn = curpath;
      else
         pn = clean_path(pn);  %strip terminal file separator
      end

      %check for omitted filename, prompt
      if exist('fn','var') ~= 1
         fn = '';
      end
      if isempty(fn)
         cd(pn)
         [fn,pn] = uiputfile('*.mat;*.MAT','Select a directory and filename for the MATLAB file');
         pn = clean_path(pn);  %remove terminal file separator
         cd(curpath)
         drawnow
      end

      %check for cancel on file prompt
      if ischar(fn)

         %instantiate flags as data columns
         if strcmpi(flagopt,'E') || strcmpi(flagopt,'S')
            if strcmpi(flagopt,'S') && ~strcmp(filetype,'mat')   %check for variables or struct type file & string flag option
               s = flags2cols(s,flagcols,0,0,1,0);  %add flag columns for all data/calculation columns as cell arrays
            else
               s = flags2cols(s,flagcols,0,0,1,1);  %add flag columns for all data/calculation columns as encoded integers
            end
         end

         %generate export file
         switch filetype

            case 'mat'  %single data matrix

               %get index of string columns
               Istr = find(strcmp(s.datatype,'s'));
               if ~isempty(Istr)
                  s = encodestrings(s);  %encode string columns as integers
               end

               %update metadata if requested in output
               if ~isempty(metastyle) && ~isempty(s.metadata)

                  %update physical file attribute metadata
                  newmeta = [{'Data'},{'MissingValues'},{'NaN'}; ...
                        {'Data'},{'FileName'},{fn}; ...
                        {'Data'},{'Header'},{'Variable length ASCII text stored in the Matlab variable ''metadata'''}; ...
                        {'Data'},{'FileFormat'},{'Matlab 5.x binary file'}; ...
                        {'Data'},{'Delimiters'},{'not applicable'}; ...
                        {'Data'},{'DataTypes'},{'Matlab numerical matrix'}];

                  s = addmeta(s,newmeta,1);

                  %update processing history
                  s.history = [s.history; ...
                        {datestr(now)},{'exported data columns and column flags as Matlab variables (''exp_matlab'')'}];

                  metadata = listmeta(s,metastyle);

               else
                  metadata = '';
               end

               %generate simple matrix using copycols option
               data = copycols(s,(1:length(s.name)),'N');
               
               %init output struct
               output = struct('data',[]);
               output.(varname) = data;

               %generate column, unit, description arrays
               output.columns = s.name';
               output.units = s.units';
               output.descriptions = s.description';
               output.metadata = metadata;                    %#ok<STRNU>

               %save file
               if ~isempty(metadata)             
                  save([pn,filesep,fn],'-struct','output',varname,'metadata','columns','units','descriptions');
               else
                  save([pn,filesep,fn],'-struct','output',varname,'columns','units','descriptions');
               end

            case 'vars'  %individual arrays

               %update metadata if requested in output
               if ~isempty(metastyle)

                  %update physical file descriptor metadata
                  newmeta = [{'Data'},{'MissingValues'},{'NaN'}; ...
                        {'Data'},{'FileName'},{fn}; ...
                        {'Data'},{'Header'},{'Variable length ASCII text stored in the Matlab variable ''metadata'''}; ...
                        {'Data'},{'FileFormat'},{'Matlab 5.x binary file'}; ...
                        {'Data'},{'Delimiters'},{'not applicable'}; ...
                        {'Data'},{'DataTypes'},{[int2str(length(s.name)),' Matlab variables']}];
                  s = addmeta(s,newmeta,1);

                  %update processing history
                  s.history = [s.history; ...
                        {datestr(now)},{'exported data columns and column flags as Matlab variables (''exp_matlab'')'}];

                  %generate formatted metadata array
                  metadata = listmeta(s,metastyle);

               else
                  metadata = '';
               end
              
               %init output struct for save function
               if ~isempty(metadata)
                  output = struct('metadata','');
                  output.metadata = metadata;
               else                  
                  output = struct(s.name{1},'');
               end
               
               %extract data columns as struct fields, trapping errors due to invalid variable names
               for n = 1:length(s.name)
                  vname = trimstr(s.name{n});  %get variable name
                  if ~isnan(str2double(vname(1)))  %check for numeric variable names
                     vname = ['col_',vname];
                  end
                  try
                     output.(vname) = extract(s,n);
                  catch e
                     msg = ['an error occurred exporting column ''',s.name{n},''' (',e.message,')'];
                     break
                  end
               end
               
               %save variables
               if isempty(msg)
                  save([pn,filesep,fn],'-struct','output')
               end

            case 'struct'  %standard structure
               
               if ~isempty(metastyle)
                  
                  %update physical file descriptor metadata
                  newmeta = [{'Data'},{'MissingValues'},{'NaN'}; ...
                     {'Data'},{'FileName'},{fn}; ...
                     {'Data'},{'Header'},{'Variable length ASCII text stored in the Matlab structure field ''metadata'''}; ...
                     {'Data'},{'FileFormat'},{'Matlab 5.x binary file'}; ...
                     {'Data'},{'Delimiters'},{'not applicable'}; ...
                     {'Data'},{'DataTypes'},{[int2str(length(s.name)),' Matlab variables']}];
                  s = addmeta(s,newmeta,1);
                  
                  %update processing history
                  s.history = [s.history; ...
                     {datestr(now)},{'exported data columns and column flags as a standard MATLAB struct variable (''exp_matlab'')'}];
                  
                  %generate formatted metadata array
                  metadata = listmeta(s,metastyle);
                  
               else
                  metadata = '';
               end

               try
                  
                  %get number of cols and rows
                  numcols = length(s.name);
                  numrows = num_records(s);
                  
                  %init struct
                  data = cell2struct(cell(numrows,numcols),s.name,2);
                  
                  %populate multi-dimensional struct
                  for c = 1:numcols
                     colname = s.name{c};
                     vals = extract(s,c);
                     if iscell(vals)
                        for r = 1:numrows
                           data(r,1).(colname) = vals{r};
                        end
                     else
                        for r = 1:numrows
                           data(r,1).(colname) = vals(r);
                        end
                     end
                  end
                  
               catch e
                  data = [];
                  msg = ['an error occurred creating the struct variable (',e.message,')'];
               end               
               
               if ~isempty(data)
                  
                  %generate output struct for save function
                  output = struct(varname,'');
                  output.(varname) = data;
                  
                  %add metadata field if relevant
                  if ~isempty(metadata)
                     output.metadata = metadata;                       %#ok<STRNU>
                  end
                  
                  try
                     %save struct to disk
                     save([pn,filesep,fn],'-struct','output')
                  catch e
                     msg = ['an error occurred saving the file (',e.message,')'];
                  end
               end
               
            otherwise
               msg = 'unsupported filetype option';

         end
         
         %update editor path cache
         if isempty(msg)
            syncpath(pn,'save');
         end

      elseif fn ~= 0  %bad path
         msg = 'invalid pathname';
      end

   else
      msg = 'invalid GCE Data Structure';
   end

else
   msg = 'insufficient arguments';
end