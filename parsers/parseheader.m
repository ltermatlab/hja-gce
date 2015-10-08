function [hdrs,hdrrows,msg] = parseheader(fn,pn,titlestr,metaonly)
%Parses documentation and attribute descriptor metadata from a specifically-formatted text file header
%for importing the metadata and parsing the data file using 'imp_ascii.m'.
%
%syntax: [hdrs,hdrrows,msg] = parseheader(fn,pn,titlestr,metaonly)
%
%inputs:
%  fn = name of a tab, comma or space-delimitted ASCII file, optionally including a structured
%    metadata header as described in note 1 (string; required)
%  pn = path for filename (string; optional; default = pwd)
%  titlestr = title string (string; optional; default = use metadata 'Dateset_Title' value)
%  metaonly = option to only return parsed metadata and not complete header information (integer; optional):
%    0 = no (default)
%    1 = yes
%
%outputs:
%   hdrs = structure containing header information
%   hddrows = number of header rows parsed
%   msg = text of any error messages returned
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
%last modified: 18-Dec-2014

%initialize outputs
hdrs = [];
hdrrows = 0;
msg = '';

%check for required file argument
if nargin >= 1
   
   %validate metaonly argument
   if exist('metaonly','var') ~= 1 || isempty(metaonly)
      metaonly = 0;
   elseif metaonly ~= 1
      metaonly = 0;
   end
   
   %check for omitted titlestr
   if exist('titlestr','var') ~= 1
      titlestr = '';
   end
   
   %validate path, assign default if omitted/invalid
   curpath = pwd;  %get current directory
   if exist('pn','var') ~= 1
      pn = curpath;
   elseif ~isdir(pn)
      pn = curpath;
   else
      pn = clean_path(pn);
   end
   
   %verify file exists at path
   if exist([pn,filesep,fn],'file') == 2
      
      %define column delimiters (tab, space)
      del = [char(9),char(32),','];
      
      %initialize header variables
      hdr = [];
      numcols = 0;
      coltitles = [];
      units = [];
      desc = [];
      prec = [];
      datatypes = [];
      vartypes = [];
      numtypes = [];
      flagcrit = [];
      metadata = [];
      
      %read file
      try
         fid = fopen([pn,filesep,fn],'r');  %open file
         str = fgetl(fid);  %get first line
      catch
         str = -1;  %set EOF flag on error
      end
      
      while ischar(str)  %check for EOF

         %init loop variables
         fd1 = '';
         fd2 = '';
         val = '';
         
         %check for category name, field name, field value format (token_token:value)
         [Istart,Iend] = regexp(str,'^\w+_\w+:');
         
         if ~isempty(Istart) && ~isempty(Iend)

            %split category_field and value
            fd = str(Istart:Iend-1);
            [fd1,rem] = strtok(fd,'_');  %parse category
            fd2 = rem(2:end);  %parse field            
            val = trimstr(str(Iend+1:end));
                        
         else
            
            %check for attribute metadata field, value array format (token:value,value,...)
            [Istart,Iend] = regexp(str,'^\w+:');
            
            if ~isempty(Istart) && ~isempty(Iend)              
               fd1 = str(Istart:Iend-1);
               val = trimstr(str(Iend+1:end));               
            end
            
         end
         
         %check for parsed values
         if ~isempty(fd1)
            
            %increment header count
            hdrrows = hdrrows + 1;
            
            %add to header array unless value field is empty
            if ~isempty(val)
               hdr = [hdr ; {fd1} {fd2} {val}];
            end
            
            %get next line
            str = fgetl(fid);            

         else
            str = -1;  %found date row or unsupported header format
         end
         
      end
      
      %close file
      fclose(fid);

      %check for parsed header and/or column titles
      if ~isempty(hdr)
         
         %parse headers
         for n = 1:size(hdr,1)
            
            fd1 = hdr{n,1};  %get category
            fd2 = hdr{n,2};  %get field name
            val = strrep(hdr{n,3},char(13),'');  %get field value, stripping any carriage returns
            
            if ~isempty(fd2)  %metadata row
               
               val = strrep(val,char(9),''); %strip residual tabs from Excel template
               metadata = [metadata ; {fd1} {fd2} {val}];  %add to metadata array
               
               %use metadata title for structure field if omitted
               if strcmpi(fd1,'dataset') && strcmpi(fd2,'title')
                  titlestr = val;
               end
               
            else   %column descriptions
               
               switch lower(fd1)  %process according to field names
                  
                  case 'name'  %parse column names
                     
                     %check delimiters, convert to cell array
                     if ~isempty(strfind(val,char(9))) || ~isempty(strfind(val,','))
                        coltitles = sub_str2cell(val,[char(9),',']);  %try tab, comma first to preserve spaces
                     else
                        coltitles = sub_str2cell(val,' ;');  %try space, semicolon next
                     end
                     
                     %get number of columns from column names
                     numcols = length(coltitles);
                     
                  case 'units'  %parse column units
                     
                     %check delimiters, convert to cell array
                     if ~isempty(strfind(val,char(9))) || ~isempty(strfind(val,','))
                        units = sub_str2cell(val,[char(9),',']);  %try tab, comma first to preserve spaces
                     else
                        units = sub_str2cell(val,' ;');  %try space, semicolon next
                     end
                     
                     %replace optional underscore spacers with true spaces
                     if ~isempty(units)
                        units = strrep(units,'_',' ');
                     end
                     
                  case 'description'  %parse column descriptions
                     
                     %check delimiters, convert to cell array
                     if ~isempty(strfind(val,char(9)))  %check for tab delim first to protect commas
                        desc = sub_str2cell(val,char(9));
                     elseif ~isempty(strfind(val,';'))  %check for semicolons next
                        desc = sub_str2cell(val,';');
                     else
                        desc = sub_str2cell(val,',');  %try comma last
                     end
                     
                  case 'precision'  %parse column precision
                     
                     precstr = sub_str2cell(val,del);  %get cell array of precision strings
                     prec = str2double(precstr')';  %convert to numeric array
                     
                  case 'datatype'  %parse data types
                     
                     datatypes = sub_str2cell(lower(val),del);
                     if ~isempty(datatypes)
                        datatypes = strrep(lower(datatypes),'i','d');  %replace nonstandard integer identifiers
                     end
                     
                  case 'variabletype'  %parse variable types
                     
                     vartypes = sub_str2cell(lower(val),del);
                     
                  case 'numbertype'  %parse number types
                     
                     numtypes = sub_str2cell(lower(val),del);
                     
                  case 'criteria'  %parse flag criteria
                     
                     %convert strings to cell array, but preserve commas and spaces in strings
                     flagcrit = sub_str2cell(val,char(9));
                     
                     if ~isempty(flagcrit)
                        
                        %clean up empty criteria placeholders, nonstandard syntax
                        flagcrit = strrep(flagcrit,'NaN','');
                        flagcrit = strrep(flagcrit,'none','');
                        flagcrit = strrep(flagcrit,'<>','~=');
                        flagcrit = strrep(flagcrit,';;',';');
                        
                        %strip trailing semicolon
                        for cnt = 1:length(flagcrit)
                           str_temp = flagcrit{cnt};
                           if ~isempty(str_temp)
                              if strcmp(str_temp(end),';')
                                 flagcrit{cnt} = str_temp(1:end-1);
                              end
                           end
                        end
                        
                     end
                     
               end
               
            end
            
         end
         
         %check for missing content and supply defaults
         if metaonly == 1
            
            hdrs = struct('metadata','');
            
            if ~isempty(metadata)
               hdrs.metadata = cellstr(metadata);
            else
               hdrs.metadata = [{'Dataset'},{'Title'},{titlestr}];
            end
            
         elseif ~isempty(coltitles)
            
            %check for missing datatypes, default to 'u'
            if isempty(datatypes)
               datatypes = repmat({'u'},1,numcols);
            end
            
            %check for missing units, default to ''
            if isempty(units)
               units = repmat({''},1,numcols);
            end
            
            %check for missing variabletypes, default to 'data'
            if isempty(vartypes)
               vartypes = repmat({'data'},1,numcols);
            end
            
            %check for missing numbertypes, default to 'unspecified'
            if isempty(numtypes)
               numtypes = repmat({'unspecified'},1,numcols);
            end
            
            %check for missing precisions, default to 0 (and auto-assignment)
            if isempty(prec)
               prec = zeros(1,numcols);
            end
            
            %check for missing q/c criteria, default to ''
            if isempty(flagcrit)
               flagcrit = repmat({''},1,numcols);
            else
               flagcrit = strrep(flagcrit,'NaN','');
            end
            
            %check for missing descriptions, default to repeating column names
            if isempty(desc)
               desc = coltitles;  %use column titles as descriptions if missing
            end
            
            %init array of matched columns for generating hddrows
            matchcols = {'units','precision','criteria','datatype','variabletype','numbertype','description'};
            matches = [(length(units)==numcols), ...
               (length(prec)==numcols), ...
               (length(flagcrit)==numcols), ...
               (length(datatypes)==numcols), ...
               (length(vartypes)==numcols), ...
               (length(numtypes)==numcols), ...
               (length(desc)==numcols)];
            
            %check for complete header values, generate output structure
            if length(find(matches)) == 7
               
               %init structure
               hdrs = struct('coltitles',[], ...
                  'units',[], ...
                  'desc',[], ...
                  'prec',[], ...
                  'datatypes',[], ...
                  'vartypes',[], ...
                  'numtypes',[], ...
                  'flagcrit',[], ...
                  'metadata',[], ...
                  'titlestr',[]);
               
               %add metadata array, or default to title-only metadata
               if ~isempty(metadata)
                  hdrs.metadata = sub_combine_meta_fields(metadata);
               else
                  hdrs.metadata = [{'Dataset'},{'Title'},{titlestr}];
               end
               
               %populate hdrs structure with parsed content
               hdrs.titlestr = titlestr;
               hdrs.coltitles = coltitles;
               hdrs.units = units;
               hdrs.desc = desc;
               hdrs.prec = [prec];
               hdrs.datatypes = datatypes;
               hdrs.vartypes = vartypes;
               hdrs.numtypes = numtypes;
               hdrs.flagcrit = flagcrit;
               
            else
               
               %get index of bad sections
               Ibadsection = matches==0;
               
               msg = ['values in the following header sections do not match the number of column name fields: ', ...
                  cell2commas(matchcols(Ibadsection),1)];
               
            end
            
         else
            msg = 'one or more header rows are invalid';
         end
         
      else
         msg = 'unrecognized file header format';
      end
      
   end
   
end

return


%%%%%%%%%%%%%%%%%%%%%%%
% Define subfunctions %
%%%%%%%%%%%%%%%%%%%%%%%

function result = sub_str2cell(str,del)
%function for splitting a delimitted string into a cell array
%
%input:
%  str = sring to split
%  del = delimeter
%
%output:
%  result = cell array containing delimiter-split string

result = [];

%split string based on delimiter
[tok,str] = strtok(str,del);
while ~isempty(tok)
   result = [result,{tok}];
   [tok,str] = strtok(str,del);
end

%strip tilde space placeholder
result = strrep(result,'~',' ');

%replace single space cells with empty strings
Iempty = strcmp(result,' ');
result(Iempty) = {''};

return

function meta2 = sub_combine_meta_fields(meta)
%function for combining metadata content in redundant categories and fields

teststr = cellstr([char(meta(:,1)),char(meta(:,2))]);
flds = unique(teststr);

for n = 1:length(flds)
   I = find(strcmpi(teststr,flds{n}));
   if length(I) > 1
      str = ['|',meta{I(1),3}];
      for m = 2:length(I)
         str = [str,'|',meta{I(m),3}];  %concatenate
         meta(I(m),1:3) = [{''},{''},{''}];  %clear contents
      end
      meta{I(1),3} = str;  %store concatenated results
   end
end

I = ~cellfun('isempty',meta(:,1));
meta2 = meta(I,:);

return