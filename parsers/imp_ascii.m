function [data,msg] = imp_ascii(fn,pn,titlestr,template,fstr,colnames,headerlines,missingchars,delimiter)
%Parses data from a delimitted text file to create a GCE Data Structure
%
%syntax:  [data,msg] = imp_ascii(fn,pn,title,template,fstr,colnames,headerlines,missingchars,delimiter)
%
%inputs:
%  fn = name of a tab, comma or space-delimitted ASCII file, optionally including a structured
%    metadata header as described in note 1 (string; optional)
%  pn = path for filename (string; optional; default = pwd or prompted if fn = '')
%  titlestr = data set title ('Dataset_Title' metadata field or title in template will be used if blank)
%  template = predefined metadata template or template structure to apply (string or struct; optional)
%  fstr = user-defined format string to use for the 'textscan' or 'textread' function (string; optional;
%     determined automatically from metadata template, file header or data inspection if omitted)
%  colnames = cell array or comma-delimited string of column names (cell or string; optional; 
%     determined from header parsing or template if omitted)
%  headerlines = number of header rows to skip over (integer; optional; default = [] for auto)
%  missingchars = comma-separated list of missing character tokens in numeric fields to replace 
%     with NaN (string; optional; default = ''; e.g. 'MM,-999')
%  delimiter = field delimiter character (string; optional)
%    '' = auto (default)
%    ',' = comma
%    '\t' = tab
%    ' ' = spaces
%
%outputs:
%  data = GCE data structure
%  msg = text of any error messages that occurred
%
%notes:
%  1) Metadata header format description:
%     [category_field]:[value string] - metadata category/fieldname pair and corresponding value
%       (e.g. Dataset_Title:Annual survey of ...). Field names cannot contain spaces, and cannot match
%       the reserved fields listed below. Any number of metadata rows can be included in the header.
%     name:[column names] - delimited list of column names (no spaces within names)
%     datatype:[column data type] - delimited list of data type characters {'f' for floating-point
%       number, 'd' or 'i' for signed decimal/integer, 's' for string/character, 'e' for exponential)
%     units:[column units] - delimited list of column units (use ~ as a placeholder for spaces)
%     description:[column descriptions] - delimited list of column descriptions (use comma or tab
%       delimiters to preserve word spaces and prevent parsing errors - optional
%     variabletype:[column variable type] - delimited list of variable types ('data' for measured
%       data values, 'calculation' for calculated values, 'code' for coded values, etc.)
%     numbertype:[column numerical type] - delimited list of numerical types ('continuous' for ratio
%       values, 'discrete' for discontinuous values, 'angular' for angular values)
%     precision:[column output precisions] - delimited list of integers to be used to
%       format the number of decimal places when values are exported
%     criteria:[column flagging criteria] - delimited list of Q/C flagging criteria.  Criteria
%       are strings containing an indexing criterion (using 'x' to reference column values) and
%       single-character flag value, formatted as follows:
%          x<0='L'  or  x>=100='H' or x==3='N' or x~=0='V' for numerical columns
%          strcmp(x,'test')='N' for string columns
%       Multiple flag statements can be used for each column by separation criteria with ';'
%       (e.g. x<0='L';x>10='H'), and flagging characters will be appended if values match
%       multiple criteria.
%  2) If 'fn' and 'pn' are both omitted or 'fn' is invalid, a file dialog will be
%     used to select the data file
%  3) 'imp_filter.m' is called automatically for numeric missing value codes or regex patterns
%     or if any missingchars are defined for MATLAB 6.5 or earlier versions
%  4) Values of 'NaN' and '~' in string columns will be replaced with '' and ' ', resp.
%  5) Integer columns will be imported as double-precision floating point values (type double)
%     and truncated to support use of NaN to indicate missing values in GCE Data Structures
%  6) Formats based on mixed delimiters are not supported (e.g. commas and spaces)
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
%last modified: 29-Apr-2015

%initialize output
data = [];
msg = '';

%initialize variables
filemask = '*.txt;*.csv,*.asc;*.prn;*.dat';
curpath = pwd;

%evaluate inputs, set defaults for omitted arguments
if exist('fstr','var') ~= 1
   fstr = '';
end

%check for template
if exist('template','var') ~= 1
   template = '';
   orig_template = '';
else
   orig_template = template;  %buffer original template
end

%check for title
if exist('titlestr','var') ~= 1
   titlestr = '';
end

%check for missing characters array
if exist('missingchars','var') ~= 1
   missingchars = [];
end

%check for explicit number of headerlines
if exist('headerlines','var') ~= 1
   headerlines = [];
end

%check for explicit delimiter
if exist('delimiter','var') ~= 1
   delimiter = '';
end

%check for column names
if exist('colnames','var') ~= 1
   colnames = [];
elseif ischar(colnames) && ~isempty(strfind(colnames,','))
   colnames = splitstr(colnames,',')';
elseif iscell(colnames)
   colnames = colnames(:)';  %convert to row array
end

%validate import path
if exist('pn','var') ~= 1
   pn = '';
end
if isempty(pn)
   pn = curpath;
elseif ~isdir(pn)
   pn = curpath;
else
   pn = clean_path(pn);  %strip terminal file separator if present
end

%validate filename
if exist('fn','var') ~= 1
   fn = '';
end
if ~isempty(fn)
   if exist([pn,filesep,fn],'file') ~= 2  %check for existence of file
      filemask = fn;
      fn = '';
   end
end

%prompt for file if omitted, not found
if isempty(fn)
   cd(pn)
   [fn,pn] = uigetfile(filemask,'Select an ASCII data file to import');
   cd(curpath)
   drawnow
   if ~ischar(fn)
      fn = '';  %check for cancel
   end
end

%check for valid file after uigetfile call (end if cancel)
if ~isempty(fn)
   
   %determine matlab version for feature checking
   ver = mlversion;
   
   %check missingchars for numeric values or regex patterns/metacharacters
   if ~isempty(missingchars)
      Iregex = regexp(missingchars,'[0-9\()*+?]');
   else
      Iregex = '';
   end

   %call 'imp_filter.m' recursively if numeric/regex missingchars argument or MATLAB 6.5 or earlier plus missingchars
   if ~isempty(Iregex) || (ver < 7 && ~isempty(missingchars))
      
      [data,msg] = imp_filter(fn,pn,fstr,colnames,headerlines,missingchars,template,titlestr);
      
   else

      %check for fstr, headerlines and colnames all specified before parsing header
      if ~isempty(fstr) && ~isempty(headerlines)
         
         %check for empty colnames, supply defaults
         if isempty(colnames)
            numcols = length(strfind(fstr,'%'));
            nums = (1:numcols)';            
            colnames = strrep(cellstr([repmat('Column',numcols,1),int2str(nums)])',' ','');
         end
         
         %define header rows based on headerlines input
         hdrrows = headerlines;
         hdr_msg = '';
         
         %determine number of columns for array dimensioning
         numcols = length(colnames);
         nullstr = repmat({''},1,numcols);
         
         %determine data type by parsing format string
         dtypes = splitstr(regexprep(fstr,'[^%fedunscq ]','','ignorecase'),'%');  %strip unsupported codes
         dtypes = strrep(dtypes,'n','f');  %convert n token to f as datatype
         dtypes = strrep(dtypes,'u','d');  %convert u token to d as datatype
         dtypes = regexprep(dtypes,'(c|q)','s');  %convert c and q tokens to s as datatype
         
         %assign variable and numeric types
         vtypes = repmat({'data'},1,numcols);
         ntypes = repmat({'unspecified'},1,numcols);  %set unspecified for numtype to force evaluation
         
         %get index of string data types for variable type and number type assignment
         Istr = find(strcmp(dtypes,'s'));
         if ~isempty(Istr)
            vtypes(Istr) = {'nominal'};
            ntypes(Istr) = {'none'};
         end
         
         %get index of integer data types for number type assignment
         Iint = find(strcmp(dtypes,'d'));
         if ~isempty(Iint)
            ntypes(Iint) = {'discrete'};
         end
         
         %define hdrs structure based on input
         hdrs.metadata = {'Dataset','Title',titlestr};
         hdrs.titlestr = titlestr;
         hdrs.coltitles = colnames(:)';
         hdrs.units = nullstr;
         hdrs.desc = colnames(:)';
         hdrs.datatypes = dtypes(:)';
         hdrs.vartypes = vtypes;
         hdrs.numtypes = ntypes;
         hdrs.prec = zeros(1,numcols);
         hdrs.flagcrit = nullstr;
         
      else  %missing info - parse header
         
         %call external function to parse header to fill in missing info
         [hdrs,hdrrows,hdr_msg] = parseheader(fn,pn,titlestr);

      end     

      %check for valid header info, parse data or use template if header missing or data types undefined
      if isempty(hdrs) || sum(strcmpi('u',hdrs.datatypes)) > 0
         
         if isempty(template) || isempty(hdrs)
            
            %call routine for parsing beginning of file to determine column data types
            if isstruct(hdrs)
               
               %cache parsed doc metadata
               meta_cache = hdrs.metadata;
               
               if isempty(hdrs.coltitles)
                  %try parsing file without column titles
                  [hdrs,hdrrows,delim] = subfun_parseascii(fn,pn,titlestr,'');
               else
                  %use column titles
                  [hdrs,hdrrows,delim] = subfun_parseascii(fn,pn,hdrs.titlestr,hdrs.coltitles,hdrs.units,hdrrows);
               end
               
               %restore metadata
               hdrs.metadata = meta_cache;
               
            else
               
               %no header - determine format and column titles automatically, using specified headerlines and colnames
               [hdrs,hdrrows,delim] = subfun_parseascii(fn,pn,titlestr,colnames,'',headerlines);

            end
            
            if isempty(delimiter)
               delimiter = delim;
            end

         else
            
            %use metadata template to determine data types
            meta = meta_template(template,hdrs.coltitles);
            
            %populate hdrs struct with information from matched template variables
            if ~isempty(meta)
               hdrs.metadata = meta.metadata;
               Imatch = find(~strcmpi(meta.datatype,'u'));
               hdrs.coltitles(Imatch) = meta.name(Imatch);
               hdrs.units(Imatch) = meta.units(Imatch);
               hdrs.desc(Imatch) = meta.description(Imatch);
               hdrs.datatypes(Imatch) = meta.datatype(Imatch);
               hdrs.vartypes(Imatch) = meta.variabletype(Imatch);
               hdrs.numtypes(Imatch) = meta.numbertype(Imatch);
               hdrs.prec(Imatch) = meta.precision(Imatch);
               hdrs.flagcrit(Imatch) = meta.criteria(Imatch);
               hdrs.metadata(Imatch) = meta.metadata(Imatch);
               template = '';  %clear template to avoid double application
               Inomatch = find(strcmpi(hdrs.datatypes,'u'));  %get index of any unmatched columns
               if ~isempty(Inomatch)
                  %try parsing to determine datatype
                  [hdrs2,hdrrows] = subfun_parseascii(fn,pn,hdrs.titlestr,hdrs.coltitles);
                  if ~isempty(hdrs2)
                     hdrs.datatypes(Inomatch) = hdrs2.datatypes(Inomatch);
                  end
               end
            end
            
         end
         
      end
      
      %check for parsed header info
      if isstruct(hdrs)

         %check for provided headerlines and override hdrrows
         if ~isempty(headerlines)
            hdrrows = headerlines;
         end
         
         %override auto-determined data descriptors using template if specified
         if ~isempty(template)
            
            %look up metadata for columnt titles
            meta = meta_template(template,hdrs.coltitles);

            if ~isempty(meta)
               
               %get documentation metadata
               hdrs.metadata = meta.metadata;
               
               %get index of matched columns based on valid datatype, apply metadata
               Imatch = find(~strcmpi(meta.datatype,'u'));
               hdrs.coltitles(Imatch) = meta.name(Imatch);
               hdrs.units(Imatch) = meta.units(Imatch);
               hdrs.desc(Imatch) = meta.description(Imatch);
               hdrs.vartypes(Imatch) = meta.variabletype(Imatch);
               hdrs.numtypes(Imatch) = meta.numbertype(Imatch);
               hdrs.prec(Imatch) = meta.precision(Imatch);
               hdrs.flagcrit(Imatch) = meta.criteria(Imatch);
               
            end
            
         end
         
         %init runtime vars
         numcols = length(hdrs.coltitles);
         types = hdrs.datatypes;
         
         %split up filename for extension check
         [pn_tmp,fn_base,fn_ext] = fileparts(fn);
         
         %generate format string from datatypes if omitted         
         if isempty(fstr)
            numcols = length(types);
            fstr = char([repmat({' '},1,numcols) ; repmat({'%'},1,numcols) ; types])';
            fstr = fstr(2:end);
            fstr = strrep(fstr,'e','f');  %change exponential format to float in format string
            if strcmpi(fn_ext,'.csv')
               fstr = strrep(fstr,'%s','%q');  %change string token to quoted string token for csv files
            end
         end

         %call textscan or textread based on MATLAB version to parse column value arrays
         if ver < 7
            [values,msg,debug] = subfun_textread(fn,pn,fstr,numcols,hdrrows,delimiter);
         else
            [values,msg,debug] = subfun_textscan(fn,pn,fstr,hdrrows,missingchars,delimiter);
         end
         
         %check for successful parsing, otherwise rely on msg from subfunctions for error reporting
         if ~isempty(values)
            
            %calculate number of rows from first column length
            numrows = length(values{1});
            
            %exert validation rules
            Imatch = find(strcmpi(types,'s'));  %set string column parameters
            if ~isempty(Imatch)
               hdrs.numtypes(Imatch) = repmat({'none'},1,length(Imatch));
               hdrs.prec(Imatch) = zeros(1,length(Imatch));
               %perform automatic substitutions
               for n = 1:length(Imatch)                  
                  values{Imatch(n)} = strrep(values{Imatch(n)},'NaN','');
                  values{Imatch(n)} = strrep(values{Imatch(n)},'~',' ');
               end
            end
            
            Imatch = find(strcmpi(types,'d'));  %set integer column parameters
            if ~isempty(Imatch)
               hdrs.numtypes(Imatch) = repmat({'discrete'},1,length(Imatch));
               hdrs.prec(Imatch) = zeros(1,length(Imatch));
            end
            
            Imatch = find(hdrs.prec < 0);
            if ~isempty(Imatch)
               hdrs.prec(Imatch) = zeros(1,length(Imatch));
            end
            
            %look up title in metadata
            metadata = hdrs.metadata;
            if ~isempty(metadata)
               if isempty(hdrs.titlestr)  %attempt to sync title from metadata
                  hdrs.titlestr = lookupmeta(metadata,'Dataset','Title');
               else
                  Ititle = find(strcmpi(metadata(:,1),'Dataset') & strcmpi(metadata(:,2),'Title'));
                  if ~isempty(Ititle)
                     metadata{Ititle(1),3} = hdrs.titlestr;  %sync data set title to metadata to override template
                  end
               end
            end
            
            %format current date
            curdate = datestr(now);
            
            %instantiate and populate new data structure with matched template descriptors
            data = newstruct('data');
            data.title = hdrs.titlestr;
            data.datafile = [{fn},{numrows}];
            data.createdate = curdate;
            data.name = hdrs.coltitles;
            data.units = hdrs.units;
            data.description = hdrs.desc;
            data.datatype = types;
            data.variabletype = hdrs.vartypes;
            data.numbertype = hdrs.numtypes;
            data.precision = hdrs.prec;
            data.criteria = hdrs.flagcrit;
            data.values = values;  %add parsed data arrays
            data.flags = repmat({''},1,numcols);  %init empty flag arrays
            
            %validate data structure
            if gce_valid(data) == 1 && ~isempty(data.values)

               %add metadata content to default FLED
               if ~isempty(metadata)
                  data = addmeta(data,metadata,1,'',0);
               end

               %update history as appropriate
               data.history = [data.history ; ...
                  {curdate},{[int2str(numrows),' rows imported from ASCII data file ''',fn,''' (''imp_ascii'')']}];
               if hdrrows > 1
                  data.history = [data.history ; ...
                     {curdate},{[int2str(hdrrows),' metadata fields in file header parsed (''parse_header'')']}];
               end
               
               if ~isempty(orig_template)
                  if ischar(template)
                     data.history = [data.history ; ...
                        {curdate},{['data descriptor metadata updated based on the template ''',orig_template,''' (''meta_template'')']}];
                  else
                     data.history = [data.history ; ...
                        {curdate},{'data descriptor metadata updated based on a user-specified template (''meta_template'')'}];
                  end
               elseif ~isempty(find(strcmpi(hdrs.numtypes,'unspecified')))
                  Iunspec = find(strcmpi(data.numbertype,'unspecified'));
                  data = assign_numtype(data,0,Iunspec);  %assign automatic metadata for unassigned number types
               end
               
               data.history = [data.history ; ...
                  {datestr(now)},{'data structure validated (''gce_valid'')'}];
               
               %auto-generate data types for numeric fields if no template specified and not specified in header
               if isempty(orig_template)
                  Inumeric = find(strcmpi(data.datatype,'f') & strcmpi(data.units,'unspecified'));
                  if ~isempty(Inumeric)
                     data = assign_numtype(data,0,Inumeric);
                  end
               end
               
               %apply flagging criteria if necessary
               if sum(~cellfun('isempty',data.criteria)) > 0
                  [data,msg] = dataflag(data);
                  if ~isempty(data)
                     data.editdate = [];  %reset edit data after running external flag function
                  end
               end
               
               %generate study dates if possible
               if ~isempty(find(strcmpi(data.variabletype,'datetime')))
                  data2 = add_studydates(data);
                  if ~isempty(data2)
                     data = data2;
                  end
               end
               
               %fill tokens in template fields if defined
               if ~isempty(template)
                  data2 = fill_meta_tokens(data);
                  if ~isempty(data2)
                     data = data2;
                  end
               end
               
            else
               
               %assign debug structure to base workspace for troubleshooting purposes
               if ~isempty(debug)
                  assignin('base','imp_ascii_debug',debug);   %send debug structure to base workspace
               end
               assignin('base','imp_ascii_debug_data',data)
               
               %clear data variable, generate error message
               data = [];
               if gce_valid(data,'data') ~= 1
                  msg = 'the imported data failed validation - check for mismatched data types in template';
               else
                  msg = 'no data were imported from the file';
               end
               
            end
            
         end
         
      else
         
         if isempty(hdr_msg)
            msg = 'the file could not parsed -- check for redundant delimiters, mixed numeric and string columns, or unsupported missing value codes';
         else
            msg = ['the file could not parsed -- ',hdr_msg];
         end
         
      end
      
   end
   
end

return


function [values,msg,debug] = subfun_textscan(fn,pn,fstr,hdrrows,missingchars,delimiter)
%subfunction to parse data using textscan for MATLAB 7+
%
%input:
%  fn = filename
%  pn = pathname
%  fstr = format string for textscan
%  hdrrows = number of header rows to skip
%  missingchars = comma-delimited list of missing value characters in numeric fields
%  delimiter = field delimiter character(s)
%
%output:
%  values = cell array of parsed data arrays
%  msg = text of any error message
%  debug = debug information for troubleshooting on error

%init output
values = [];
msg = '';
debug = [];

%split missingchars into array
if ~isempty(missingchars) && ~isempty(strfind(missingchars,','))
   missingchars = splitstr(missingchars,',');
end

%get array of field tokens and index of integer fields
ar = splitstr(fstr,'%');
intcols = ~cellfun('isempty',regexpi(ar,'(d|u|e)'));

%check for integer fields, replace with %n
if sum(intcols) > 0
   fstr2 = regexprep(fstr,'%(\d*)(d|u|e)','%$1n','ignorecase');
else
   fstr2 = fstr;
end

%check for empty hdrrows
if isempty(hdrrows)
   hdrrows = 0;
end

%open file for parsing
try
   fid = fopen([pn,filesep,fn],'r');
catch
   fid = [];
end

%check for file opening errors
if ~isempty(fid)
   
   %check for no delimiters - init array of delimiters to try
   if isempty(delimiter)
      delims = {'\t' ',\t' ',' ' '};  %try comma and/or tab, then tab, then comma, then space
   else
      delims = {delimiter};  %convert specified delimiter to cell array for extraction within loop
   end

   %loop through delimiters
   for n = 1:length(delims)
      
      %get delimiter character from array
      delimiter = delims{n};

      try
         %check for space delimiter first
         if strcmp(delimiter,' ')
            %turn off whitespace option and enable multiple delims as one for space delimited
            if isempty(missingchars)
               values = textscan(fid,fstr2,'Headerlines',hdrrows,'ReturnOnError',0,'Whitespace','', ...
                  'Delimiter',delimiter,'MultipleDelimsAsOne',1);
            else
               values = textscan(fid,fstr2,'Headerlines',hdrrows,'ReturnOnError',0,'Whitespace','', ...
                  'Delimiter',delimiter,'MultipleDelimsAsOne',1,'TreatAsEmpty',missingchars);
            end
         else  %tab/comma
            if isempty(missingchars)
               values = textscan(fid,fstr2,'Headerlines',hdrrows, ...
                  'Whitespace',' \b','ReturnOnError',0,'Delimiter',delimiter);
            else
               values = textscan(fid,fstr2,'Headerlines',hdrrows, ...
                  'Whitespace',' \b','ReturnOnError',0,'Delimiter',delimiter,'TreatAsEmpty',missingchars);
            end
         end
      catch
         values = [];
         msg = ['An error occurred parsing the file: ',lasterr];
      end
      
      if ~isempty(values)
         break;  %stop on success
      end
      
   end
   
   %close file handle
   fclose(fid);

   %check for integer columns parsed as floating-poing and truncate to enforce format
   if ~isempty(values) && sum(intcols) > 0 && length(values) == length(intcols)
      
      %get index of columns
      Iint = find(intcols);
      
      %loop through columns
      for n = 1:length(Iint)
         col = Iint(n);  %get column pointer
         vals = values{col};  %get column values
         try
            newvals = fix(vals);  %truncate
         catch
            newvals = [];
         end
         if ~isempty(newvals)
            values{col} = newvals;  %update values if sucessfully truncated
         else
            values = [];
            msg = ['An error occurred truncating values in integer column ',int2str(col)];
            break
         end
      end
      
   end
   
else
   msg = 'an error occurred opening the file for parsing';
end

return


function [values,msg,debug] = subfun_textread(fn,pn,fstr,numcols,hdrrows,delimiter)
%subfunction to parse data using textread for MATLAB 6.5 and earlier
%
%input:
%  fn = filename
%  pn = pathname
%  fstr = format string for textread
%  numcols = number of data columns
%  hdrrows = number of header lines to skip over
%  delimiter = field delimiter ('' = attempt to parse with '\t', ',', ',\t' or ' ')
%
%output:
%  values = cell array of parsed data arrays
%  msg = text of any error message
%  debug = debug structure for troubleshooting on error

%init output
values = [];
msg = '';

%generate variable list
varnames = char(concatcellcols(cellstr([repmat('c',numcols,1),int2str((1:numcols)')])',','));
varnames = ['[',strrep(varnames,' ',''),']'];

%split up filename for extension check
[pn_tmp,fn_base,fn_ext] = fileparts(fn);

%generate parser evaluation string based on context
if strcmpi(fn_ext,'.csv')  %csv - switch to quoted character input and comma delimiter
   
   %check for MATLAB 5
   if mlversion < 6
      evalstr0 = [varnames,' = textread(''',pn,filesep,fn,''',fstr,-1,''headerlines'',', ...
         int2str(hdrrows),',''whitespace'',''\b\r\n'',''delimiter'','','');'];   %comma only
   else
      evalstr0 = [varnames,' = textread(''',pn,filesep,fn,''',fstr,-1,''headerlines'',', ...
         int2str(hdrrows),',''whitespace'',''\b\r\n'',''delimiter'','','',''emptyvalue'',NaN);'];   %comma + emptyvalue
   end
   
   %clear other eval strings
   evalstr1 = '';
   evalstr2 = '';
   evalstr3 = '';
   evalstr4 = '';
   
elseif ~isempty(delimiter)  %specific delimiter
   
   %check for MATLAB 5
   if mlversion < 6
      evalstr0 = [varnames,' = textread(''',pn,filesep,fn,''',fstr,-1,''headerlines'',', ...
         int2str(hdrrows),',''whitespace'',''\b\r\n'',''delimiter'',''',delimiter,''');'];  %user-specified dilimiter
   else
      evalstr0 = [varnames,' = textread(''',pn,filesep,fn,''',fstr,-1,''headerlines'',', ...
         int2str(hdrrows),',''whitespace'',''\b\r\n'',''delimiter'',''',delimiter,''',''emptyvalue'',NaN);'];  %delim + emptyvalue
   end
   
   %clear other eval strings
   evalstr1 = '';
   evalstr2 = '';
   evalstr3 = '';
   evalstr4 = '';
   
else  %all other types - try progressive set of delimiters
   
   %define tiered set of import statements to evaluate
   if mlversion < 6  %use MATLAB 5 textread syntax
      evalstr0 = [varnames,' = textread(''',pn,filesep,fn,''',fstr,-1,''headerlines'',', ...
         int2str(hdrrows),',''whitespace'',''\t\b\r\n'',''delimiter'','''');'];  %tab only
      evalstr1 = [varnames,' = textread(''',pn,filesep,fn,''',fstr,-1,''headerlines'',', ...
         int2str(hdrrows),',''whitespace'',''\b\r\n'',''delimiter'','','');'];  %comma only
      evalstr2 = [varnames,' = textread(''',pn,filesep,fn,''',fstr,-1,''headerlines'',', ...
         int2str(hdrrows),',''whitespace'',''\t\b\r\n'',''delimiter'','','');'];  %tab & comma only
      evalstr3 = [varnames,' = textread(''',pn,filesep,fn,''',fstr,-1,''headerlines'',', ...
         int2str(hdrrows),',''whitespace'','' \t\b\r\n'',''delimiter'','','');'];  %tab & comma & whitespace
      evalstr4 = [varnames,' = textread(''',pn,filesep,fn,''',fstr,-1,''headerlines'',', ...
         int2str(hdrrows),',''whitespace'','' '',''delimiter'','''');'];  %fixed width, no delimiter
   else  %use MATLAB 6+ textread syntax
      evalstr0 = [varnames,' = textread(''',pn,filesep,fn,''',fstr,-1,''headerlines'',', ...
         int2str(hdrrows),',''whitespace'',''\b\r\n'',''delimiter'',''\t'',''emptyvalue'',NaN);'];  %tab only
      evalstr1 = [varnames,' = textread(''',pn,filesep,fn,''',fstr,-1,''headerlines'',', ...
         int2str(hdrrows),',''whitespace'',''\b\r\n'',''delimiter'','','',''emptyvalue'',NaN);'];   %comma only
      evalstr2 = [varnames,' = textread(''',pn,filesep,fn,''',fstr,-1,''headerlines'',', ...
         int2str(hdrrows),',''whitespace'',''\b\r\n'',''delimiter'',''\t,'',''emptyvalue'',NaN);'];  %tab & comma only
      evalstr3 = [varnames,' = textread(''',pn,filesep,fn,''',fstr,-1,''headerlines'',', ...
         int2str(hdrrows),',''whitespace'',''\b\r\n'',''delimiter'',''\t, '',''emptyvalue'',NaN);'];  %tab & comma & ws
      evalstr4 = [varnames,' = textread(''',pn,filesep,fn,''',fstr,-1,''headerlines'',', ...
         int2str(hdrrows),',''whitespace'','' '',''delimiter'','''',''emptyvalue'',NaN);'];  %fixed width, no delimiter
   end
   
end

%init debugging structure to dump to the base workspace on errors
debug = struct('fstr',fstr, ...
   'evalstr','', ...
   'evalstr0',evalstr0, ...
   'evalstr1',evalstr1, ...
   'evalstr2',evalstr2, ...
   'evalstr3',evalstr3, ...
   'evalstr4',evalstr4);

%execute eval strings sequentially to parse data until success or all fail
error = 0;
try
   eval(evalstr0)
catch
   error = 1;
end

%try alternate eval strings unless CSV file or explicit delimiter
if error == 1 && ~strcmpi(fn_ext,'.csv') && isempty(delimiter)
   
   %try eval string 1
   error = 0;
   try
      eval(evalstr1)
   catch
      error = 1;
   end
   
   if error == 1 %try 2nd eval string
      
      error = 0;
      try
         eval(evalstr2)
      catch
         error = 1;
      end
      
      if error == 1  %try 3rd eval string
         
         error = 0;
         try
            eval(evalstr3)
         catch
            error = 1;
         end
         
         if error == 1  %try 4th eval string
            
            error = 0;
            try
               eval(evalstr4)
            catch
               error = 1;
            end
            
            if error == 0
               debug.evalstr = evalstr4;
            end
            
         else
            debug.evalstr = evalstr3;
         end
         
      else
         debug.evalstr = evalstr2;
      end
      
   else
      debug.evalstr = evalstr1;
   end
   
else
   debug.evalstr = evalstr0;
end

%check for success
if error == 0
   
   %build output parameter list string
   assignstr = 'values = [';
   for n = 1:numcols
      str = ['{c',int2str(n),'}'];
      if n > 1
         assignstr = [assignstr,',',str];
      else
         assignstr = [assignstr,str];
      end
   end
   assignstr = [assignstr,'];'];

   %evaluate variable assignment statement, trapping errors
   try
      eval(assignstr)
   catch
      msg = 'an error occurred generating an array of parsed column values';
   end
   
end

return


function [hdrs,hdrrows,delimiter] = subfun_parseascii(fn,pn,titlestr,colnames,units,hdrrows)
%subfunction to parse first few rows of an ascii file to determine column titles, datatypes
%
%input:
%  fn = filename
%  pn = pathname
%  titlestr = title string
%  colnames = cell array of column names
%  units = cell array of column units
%  hdrrows = number of header lines to skip over
%
%output:
%  hdrs = structure of header information
%  hdrrows = number of header rows
%  delimiter = record delimiter

%init output
hdrs = [];
delimiter = '';

%set default colnames if omitted
if isempty(colnames)
   colnames = [];   
end

%set default hdrrows if omitted
if exist('hdrrows','var') ~= 1 || isempty(hdrrows)
   hdrrows = 0;
end

%supply defaults for omitted arguments
if exist('units','var') ~= 1
   units = '';
end

%init runtime vars
dtypearray = cell(5,1);
ntypearray = dtypearray;
precarray = dtypearray;
numcols = zeros(5,1);

%open file for reading
try
   fid = fopen([pn,filesep,fn],'r');
catch
   fid = [];
end

%check for valid file handle
if ~isempty(fid)
   
   %init colnames test array
   colnames_test = [];
   
   %burn header rows if defined
   if hdrrows > 0
      
      %read through header
      for n = 1:hdrrows
         rem = fgetl(fid);
      end
      
      %check for no column names, try to parse from last header row
      if isempty(colnames) && ~isempty(rem)
         rem = strrep(rem,char(9),',');  %convert tabs to commas
         colnames_test = splitstr(rem,',')';            
      end
      
   end
   
   %read first data row
   rem = fgetl(fid);
   
   %check first row for delimiter
   if strfind(rem,char(9))
      delimiter = '\t';
   elseif strfind(rem,',')
      delimiter = ',';
   else
      delimiter = ' ';
   end
   
   %init first-line header flag
   headerflag = 0;
      
   for n = 1:5  %inspect first 5 data rows after header

      %init loop arrays
      coltype = [];
      numtype = [];
      prec = [];
      
      %replace tabs with comma to simplify field parsing, stripping terminal delimiter
      rem = strrep(rem,char(9),',');
      if strcmp(',',rem(end))
         rem = rem(1:end-1);
      end
      
      %loop through fields
      while ~isempty(rem)
         
         %split fields on comma
         [tkn,rem] = strtok(rem,',');
         tkn = trimstr(tkn); %remove leading/trailing blanks
         
         if ~isempty(tkn)

            %check column type
            if strcmpi(tkn,'NaN') || ~isnan(str2double(tkn))  %check for numeric field or NaN
               if ~isempty(strfind(upper(tkn),'E+')) || ~isempty(strfind(upper(tkn),'E-'))  %check for exponential syntax
                  coltype = [coltype,{'e'}];
                  numtype = [numtype,{'continuous'}];
                  prec = [prec,3];
               else  %use generic floating-point, catch integer during post-eval
                  coltype = [coltype,{'f'}];
                  numtype = [numtype,{'continuous'}];
                  Idot = strfind(tkn,'.');
                  if isempty(Idot)
                     prec = [prec,0];
                  else
                     prec = [prec,max(0,length(tkn)-Idot(1))];
                  end
               end
            else  %assign string type
               coltype = [coltype,{'s'}];
               numtype = [numtype,{'none'}];
               prec = [prec,0];
               if hdrrows == 0 && n == 1  %if no header and line 1, assume text fields = column names
                  colnames = [colnames,{tkn}];
                  headerflag = 1;  %set header flag for first row column titles
               end
            end
            
         elseif n > 1
            
            lastcoltype = dtypearray{n-1};
            
            if isempty(coltype)
               coltype = [lastcoltype{1}];
            else
               if length(coltype) < length(lastcoltype)
                  coltype = [coltype,lastcoltype(length(coltype)+1)];
               else
                  coltype = [coltype,{'u'}];
               end
            end
            
            numtype = [numtype,{'unspecified'}];
            prec = [prec,0];
            
         end
         
      end

      %check for 1st line header flag
      if headerflag == 1
         hdrrows = 1;
      end

      %store row metadata in cell arrays to avoid column mismatch errors
      dtypearray{n} = coltype;
      ntypearray{n} = numtype;
      precarray{n} = prec;
      
      %calculate number of columns for data row
      numcols(n) = length(coltype);
      
      %read next line
      rem = fgetl(fid);
      
      %break, truncate meta arrays if EOF
      if ~ischar(rem)
         dtypearray = dtypearray(1:n);
         ntypearray = ntypearray(1:n);
         precarray = precarray(1:n);
         numcols = numcols(1:n);
         break
      end
      
   end
   
   %close file handle
   fclose(fid);

   if size(dtypearray,1) > 2
      
      %clear invalid column names from individual string fields on line 1 - force automatic generation
      if length(colnames) ~= numcols(1)
         if length(colnames_test) == numcols(1)
            colnames = colnames_test;  %use test column names from last header row, if found and match data
         else
            colnames = [];
         end
      else
         %remove leading/trailing quotes from column titles
         try
            if mlversion >= 7
               %use new regex syntax
               colnames = regexprep(colnames,'("|'')(.)*("|'')','$2');
            else
               %use old regex syntax
               colnames = regexprep(colnames,'("|'')(.)*("|'')','$2','tokenize');
               colnames = colnames(:)';  %force row orientation
            end
         catch
            %use loop and string handling if regex fails
            for cnt = 1:length(colnames)
               str = colnames{cnt};
               if strcmp(str(1),'"') || strcmp(str(1),'''')
                  str = str(2:end);
               end
               if strcmp(str(end),'"') || strcmp(str(end),'''')
                  str = str(1:end-1);
               end
               colnames{cnt} = str;
            end
         end
      end
      
      badcolnum = sum(numcols(2:end)~=numcols(1));  %check for diffs in # columns
      
      if badcolnum == 0
         
         %generate cell array of first row data types for header check
         coltype1 = dtypearray{1};
         coltype2 = dtypearray{2};
         
         %check for first row all strings but not second row - assume column headers in first row
         if sum(strcmpi('s',coltype1)) == numcols(1) && sum(strcmpi('s',coltype2)) ~= numcols(2)
            
            %set header rows if not already defined
            if hdrrows == 0
               hdrrows = 1;
            end
            
            %update comparison arrays
            dtypearray = dtypearray(2:end);  %remove first row from comparison
            coltype1 = dtypearray{1};  %refigure column type array
            
         end
            
         if isempty(colnames)
            
            %autogenerate column headings
            colnames = strrep(cellstr([repmat('Column',numcols(1),1),int2str((1:numcols(1))')])',' ','');
            
         end
         
         %init datatype comparison matrix
         badtypes = zeros(size(dtypearray,1),numcols(1));
         
         %loop through data type arrays for each column checking for matches
         for n = 1:size(dtypearray,1)
            coltype = dtypearray{n};
            for m = 2:numcols(1)
               if ~strcmpi(coltype{m},coltype1{m})
                  badtypes(n,m) = 1;
               end
            end
         end
         
         %calc total number of datatype mismatches
         baddatatypes = sum(sum(badtypes));
         
         %build header struct, attempt to import if no mismatches
         if baddatatypes == 0
            
            %determine max precision for each column based on decimal placement
            try
               precs = max(cat(1,precarray{:}));
               if length(precs) < numcols(1)
                  precs = zeros(1,numcols(1));
               end
            catch
               precs = zeros(1,numcols(1));
            end
            
            %determine number type based on first data row
            try
               ntypes = ntypearray{1+hdrrows};
            catch
               ntypes = repmat({'unspecified'},1,numcols(1));
            end
            
            %generate hdrs structure with parsed file info
            if isempty(titlestr)
               titlestr = ['Data imported from the text file ''',fn,''''];
            end
            hdrs.titlestr = titlestr;
            hdrs.metadata = [{'Dataset'},{'Title'},{titlestr}; ...
               {'Dataset'},{'Abstract'},{['Data imported by parsing the ASCII text file ''',fn, ...
               ''' and automatically assigning numerical descriptors based on value inspection.']}];
            hdrs.coltitles = colnames;
            hdrs.datatypes = coltype1;
            if ~isempty(units) && length(units) == length(colnames)
               hdrs.units = units;
            else
               hdrs.units = repmat({'unspecified'},1,numcols(1));
            end
            hdrs.desc = repmat({''},1,numcols(1));
            hdrs.vartypes = repmat({'data'},1,numcols(1));
            hdrs.numtypes = ntypes;
            hdrs.prec = precs;
            hdrs.flagcrit = repmat({''},1,numcols(1));
            
         end
         
      end
      
   end
   
end

return
