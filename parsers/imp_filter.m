function [data,msg] = imp_filter(fn,pn,fstr,colnames,headerlines,missingchar,template,titlestr)
%Imports data from a delimited ASCII file using a specified format string and list of
%column names to create a GCE Data Structure. Optionally replaces one or more missing
%value codes with 'NaN' and applies a named metadata template to assign column descriptors
%and import general metadatal.
%
%syntax: [data,msg] = imp_filter(fn,pn,formatstr,colnames,headerlines,missingchar,template,title)
%
%inputs:
%  fn = name of file to parse
%  pn = path name of 'fn'
%  formatstr = character array containing the formatted input string to use to
%     parse the data (see 'textread' or 'fscanf') (default = '' {auto})
%  colnames = cell array or comma-delimited character array of column names
%     to assign to the parsed data (default = '' {auto})
%  headerlines = number of header lines to skip (default = 0)
%  missingchar = character array containing a comma-separated list of missing character tokens
%     to replace with NaN (e.g. 'MM,-999', default = ''; note that regex character patterns
%     are also supported)
%  template = predefined metadata template present in 'imp_templates.mat' to apply (default = '')
%  title = title for the data set (overrides title in template; default = '')
%
%outputs:
%  data = GCE data structure
%  msg = text of any error message
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
%last modified: 06-Apr-2012

data = [];

if nargin >= 2
   
   %remove terminal file separator from path
   pn = clean_path(pn);
   
   %validate missing character selections
   if exist('missingchar','var') ~= 1
      missingchar = '';
   elseif isempty(missingchar)
      missingchar = '';  %catch empty array or string
   elseif ~iscell(missingchar)
      if isnumeric(missingchar)
         missingchar = {num2str(missingchar)};
      elseif ischar(missingchar)
         if ~isempty(strfind(missingchar,','))
            missingchar = splitstr(missingchar,',');
         else
            missingchar = cellstr(missingchar);
         end
      else  %unsupported class
         missingchar = '';
      end
   end
   
   %generate regex pattern from missing characters
   if ~isempty(missingchar)
      if length(missingchar) > 1
         missingchar = concatcellcols(missingchar','|');  %add pipe separator if array of missing value strings
      end
      missingchar = ['(\s|\,)?(',char(missingchar(:)'),')(,\s|\,)?'];  %note: requires padding space at the end of the line to match last field
   end

   if exist('template','var') ~= 1
      template = '';
   end
   
   if exist('titlestr','var') ~= 1
      titlestr = '';
   end
   
   if exist('headerlines','var') ~= 1
      headerlines = 0;
   elseif ~isnumeric(headerlines)
      headerlines = 0;
   end
   
   if exist('colnames','var') ~= 1
      colnames = [];
   elseif iscell(colnames)
      colnames = strrep(colnames,' ','_');
      colnames = char(concatcellcols(colnames(:)',','));
   end
   
   if exist('fstr','var') ~= 1
      fstr = '';
   end
   
   %generate default column names if no header and no column names provided
   if isempty(colnames) && headerlines == 0 && ~isempty(fstr)
      parms = length(strfind(fstr,'%'));
      colnames = strrep(cell2commas(concatcellcols([repmat({'column'},parms,1),cellstr(int2str((1:parms)'))])'),' ','');
   end
   
   dtypes = '';
   vtypes = '';
   ntypes = '';
   prec = '';
   
   %parse format string to generate column datatype string for new header
   if ~isempty(fstr)
      I = strfind(fstr,'%');
      if ~isempty(I)
         tmp = splitstr(fstr(I(1):end),'%');
         for n = 1:length(tmp)
            str = tmp{n};
            dtkn = '';
            for m = 1:length(str)
               if isnan(str2double(str(m))) && ~strcmp(str(m),'.')
                  dtkn = str(m);
                  break
               end
            end
            dtkn = strrep(dtkn,'q','s');  %replace quoted string token type with s for metadata
            dtypes = [dtypes,',',dtkn];
            vtypes = [vtypes,',data'];
            ntypes = [ntypes,',unspecified'];
            prec = [prec,',0'];
         end
         dtypes = dtypes(2:end);
         vtypes = vtypes(2:end);
         ntypes = ntypes(2:end);
         prec = prec(2:end);
      else
         msg = 'invalid format string';
         return
      end
   end
   
   if isdir(pn)
      
      if exist([pn,filesep,fn],'file') == 2
         
         [tmp,basefn,ext] = fileparts(fn);
         fn2 = [basefn,'_filtered',ext];
         
         try
            
            %open file handles
            fid = fopen([pn,filesep,fn],'r');
            fid2 = fopen([pn,filesep,fn2],'w');
            
            for n = 1:headerlines
               ln = fgetl(fid);
               if n == headerlines && isempty(colnames)
                  colnames = ln;
               end
            end
            
            %write new header
            if ~isempty(fstr)
               fprintf(fid2,'name:%s\r',colnames);
               fprintf(fid2,'datatype:%s\r',dtypes);
               fprintf(fid2,'variabletype:%s\r',vtypes);
               fprintf(fid2,'numbertype:%s\r',ntypes);
               fprintf(fid2,'precision:%s\r',prec);
            elseif ~isempty(colnames)
               fprintf(fid2,'%s\r',colnames);
            end
            
            %init runtime vars for file reading
            eof = 0;  %end of file flag
            buffsize = 10;  %number of rows to buffer for string substitution
            buff0 = repmat({''},buffsize,1);  %starting string buffer array
            buff = buff0;  %working string buffer array
            cnt = 0;  %buffer cell counter
            status = 1;  %status flag for error checking
            
            %loop through file reading lines
            while eof == 0
               ln = fgetl(fid);
               cnt = cnt + 1;
               if ~ischar(ln)
                  eof = 1;  %set eof flag
               else
                  %check for full buffer
                  if cnt > buffsize
                     %write file buffer and reset
                     status = sub_write_file(fid2,buff,missingchar,'$1NaN$3',0);
                     if status == 0
                        break;
                     else
                        buff = buff0;
                        cnt = 1;
                     end
                  end
                  buff{cnt} = [ln,char(13)];  %add line and carriage return to buffer
               end
            end
            
            %write remainder of buffer unless error
            if status == 1
               status = sub_write_file(fid2,buff,missingchar,'$1NaN$3',1);
            end
            
            fclose(fid2);
            fclose(fid);
            
            if status == 1
               [data,msg] = imp_ascii(fn2,pn,titlestr,template,fstr);
            else
               msg = 'an error occurred generating the filtered import file';
            end
            
         catch
            fclose all;
            msg = 'errors occurred opening the file or creating temporary files';
         end
         
         %delete temp file if data successfully parsed
         try
            if ~isempty(data) && exist([pn,filesep,fn2],'file') == 2
               delete([pn,filesep,fn2])
            end
         catch
            msg = ['errors occurred deleting temporary file ''',fn2,''''];
         end
         
      else
         msg = ['''',fn,''' not found in the specified directory'];
      end
      
   else
      msg = ['''',pn,''' is not a valid directory'];
   end
   
else
   msg = 'insufficient arguments for function';
end

return


function status = sub_write_file(fid,buffer,missingchar,subst,lastchunk)
%subfunction that performs missing character substitution and writes out buffered lines to the specified file handle
%
%input:
%  fid = file identifier
%  buffer = buffer to write
%  missingchar = missing value code regex pattern
%  subst = value to substitute for matched missing value code(s)
%  lastchunk = flag indicating whether the last chunk of data are being written
%     for performing a terminal empty value check to avoid parsing errors (0 = no, 1 = yes)
%
%output:
%  status = integer status flag (1 = ok, 0 = error)

%init status flag
status = 1;

%concatenate strings into 1xn character array
str = [buffer{:}];

%perform missing value substitution using regex
if ~isempty(missingchar)
   mlv = mlversion;
   try
      if mlv >= 7
         str = regexprep([' ',str,' '],missingchar,subst);
      else
         str = regexprep([' ',str,' '],missingchar,subst,'tokenize');  %specify tokenize option for MATLAB 6.x
      end
      str = str(2:end-1);  %remove flanking spaces
   catch
      status = 0;
   end
end

%write string to file
if status == 1 && ~isempty(str)
   
   %check for last chunk with terminal newline and/or carriage return
   if lastchunk == 1 && length(str) > 2 && (strcmp(str(end),char(10)) || strcmp(str(end),char(13)))
      
      %check for 2 line terminator characters (e.g. CRLF)
      if (strcmp(str(end-1),char(10)) || strcmp(str(end-1),char(13)))
         numterm = 2;
      else
         numterm = 1;
      end
      
      %if using MATLAB 6.5 or earlier, check for terminal tab or comma before line terminator, 
      %add NaN before line terminator(s) to prevent parsing issue with textread function omitting last value from array
      if mlversion < 7 && (strcmp(str(end-numterm),char(9)) || strcmp(str(end-numterm),','))
         str = [str(1:end-numterm),'NaN',str(end-numterm+1:end)];
      end
      
   end
   
   %write file, catching errors
   try
      fprintf(fid,'%s',str);
   catch
      status = 0;
   end
   
end

return

