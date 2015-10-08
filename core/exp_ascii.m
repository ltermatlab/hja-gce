function msg = exp_ascii(s,fmt,fn,pn,rpttitle,hdropt,flagopt,metastyle,ldr,rnums,misschar,del,groupcol,appendopt,terminator,extensionopt)
%Exports the contents of a GCE Data Structure or GCE Stats Structure as a delimited text file
%
%syntax:  msg = exp_ascii(s,fmt,fn,pn,rpttitle,hdropt,flagopt,metastyle,leader,rownumbers,missingchar,delim,groupcol,appendopt,terminator,extensionopt)
%
%input:
%   s = data or stat structure
%   fmt = one of the following format specifications:
%      'tab' - tab-delimitted ASCII text
%      'comma' - commas-delimitted ASCII text
%      'csv' - comma-separated value format (with quoted header lines)
%      'space' - space-delimited format 
%      'del' - delimited ASCII text using user-specified delimiter
%   fn = filename (overwrites if data structure, appends if stat structure)
%   pn = pathname (if omitted, the current directory will be used)
%   rpttitle is the title to use for the output file (data structure title used if omitted)
%   hdropt = header option:
%      'F' for full {default}
%      'B' for brief
%      'T' for column titles only
%      'N' for none
%      'SF' for full header plus independent doc file '-meta.txt'
%      'SB' for brief header plut independent doc file '-meta.txt'
%      'ST' for column titles only plus independent doc file '-meta.txt'
%      'SN' for no header plus independent doc file '-meta.txt'
%   flagopt = flag option:
%      'I' for inline
%      'C' for flag column
%      'M' for multiple text flag columns after the corresponding data column (if flags defined)
%      'MD' same as 'M', except text flags are displayed for all data/calculation columns
%      'MD+' same as 'MD', except text flags are also displayed for non-data, non-calculation columns if assigned
%      'MC' same as 'M', except text flags are displayed for all columns
%      'MA' for multiple text flag columns appended after the data columns
%      'MAD' same as 'MA', except text flags are displayed for all data/calculation columns
%      'MAD+' same as 'MD', except text flags are also displayed for non-data, non-calculation columns if assigned
%      'MAC' same as 'MA', except text flags are displayed for all columns
%      'E' for multiple encoded flag columns after the corresponding data column (if flags defined)
%      'ED' same as 'E', except encoded flags are displayed for all data/calculation columns
%      'ED+' same as 'ED', except encoded flags are also displayed for non-data, non-calculation columns if assigned
%      'EC' same as 'E', except encoded flags are displayed for all columns
%      'EA' for multiple encoded flag columns appended after the data columns
%      'EAD' same as 'EA', except encoded flags are displayed for all data/calculation columns
%      'EAD+' same as 'EAD', except encoded flags are displayed non-data, non-calculation columns if assigned
%      'EAC' same as 'EA', except encoded flags are displayed for all columns
%      'N' to suppress flags (default)
%      'R' to remove (null) flagged values
%      'D' for delete rows with any flagged values)
%   metastyle = named metadata style to use for generating formatted metadata (default = 'GCE')
%   leader = character or string to pre-pend to each header row (default = '')
%   rownumbers = option to include a column of rownumbers before data columns
%      'N' = no (default)
%      'Y' = yes
%   missingchar = string to substitute for missing values (default = 'NaN')
%   delim = delimitter to use for the 'del' format (default = '  ')
%   groupcol = option to append a column for group value (stat structure only)
%      'N' = no
%      'Y' = yes (default)
%   appendopt = option to append exported text to the specified file if it already exists
%      'N' = no (default)
%      'Y' = yes
%      'T' = yes with tight spacing (no intervening blank rows)
%   terminator = line terminator character (default = '\r\n' for carriage return and line feed; 
%      specify '\n' for linefeed or '\r' for carriage return alone
%   extensionopt = extension format option
%      'lower' = lower case extension (default)
%      'upper' = upper case extension
%
%output:
%   msg = the text of any errors that occurred
%
%
%(c)2002-2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project-2005 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 16-Jan-2015

%init output
msg = '';
error = 0;
docname = '';

%check for required arguments
if nargin >= 3

   %validate  structure and determine type
   [val,stype] = gce_valid(s);

   if val == 1

      %filter delimited text options, update delimiter token
      fmt = lower(fmt);
      
      if strcmp(fmt,'tab')
         fmt = 'del';
         del = '\t';
      elseif strcmp(fmt,'comma')
         fmt = 'del';
         del = ',';
      elseif strcmp(fmt,'csv')
         del = ',';
      elseif strcmp(fmt,'space')
         fmt = 'del';
         del = '  ';
      elseif exist('del','var') ~= 1
         del = '  ';
      else  %replace special symbols with supported variants
         del = strrep(del,'''','''''');
         del = strrep(del,'%','%%');
         del = strrep(del,'\','\\');
      end

      %supply defaults for omitted arguments
      
      %default for including group value column for grouped stats
      if exist('groupcol','var') ~= 1
         groupcol = 'Y';
      else
         groupcol = upper(groupcol);
      end

      %default to overwriting existing file
      if exist('appendopt','var') ~= 1
         appendopt = 'N';
      end

      %default to NaN as missing character
      if exist('misschar','var') ~= 1
         misschar = 'NaN';
      elseif isempty(misschar)
         misschar = '';  %force empty character array if empty
      end

      %default to not displaying row numbers
      if exist('rnums','var') ~= 1
         rnums = 'N';
      else
         rnums = upper(rnums);
         if ~strcmp(rnums,'Y')
            rnums = 'N';
         end
      end

      %default to no leading characters for header
      if exist('ldr','var') ~= 1
         ldr = '';
      end

      %default to automatic metadata style selection
      if exist('metastyle','var') ~= 1
         metastyle = '';
      end
      
      %default to windows line terminator if not specified or unsupported option
      if exist('terminator','var') ~= 1
         terminator = '\r\n';
      elseif ~strcmp(terminator,'\r') && ~strcmp(terminator,'\n')
         terminator = '\r\n';
      end

      %determine default noflags option based on structure type and presence of flagged values
      if strcmp(stype,'data')
         if sum(~cellfun('isempty',s.flags)) == 0
            noflags = 1;
         else
            noflags = 0;
         end
      else
         noflags = 1;
      end
      
      %default to lower case extension
      if exist('extensionopt','var') ~= 1 || isempty(extensionopt)
         extensionopt = 'lower';
      end

      %default to no flag option, otherwise pre-process flag encoding and revise option accordingly
      if exist('flagopt','var') ~= 1
         flagopt = 'N';
      else  %pre-process flag options
         flagopt = upper(flagopt);
         switch flagopt
         case 'D'  %null all flagged values
            s = cullflags(s);
         case 'R'  %delete all rows with flagged values
            s = nullflags(s);
         case 'C'  %combined flag column
            s = flags2cols(s,'single',0,0,1,0);
         case 'M'  %multiple text flag cols next to data cols (only if defined)
            s = flags2cols(s,'mult',0,0,1,0);
         case 'MD' %multiple text flag cols next to data (all data/calc)
            s = flags2cols(s,'alldata',0,0,1,0);
         case 'MD+' %multiple text flag cols next to data (all data/calc plus any others assigned)
            s = flags2cols(s,'mult+data',0,0,1,0);
         case 'MC' %multiple text flag cols next to data (all data/calc)
            s = flags2cols(s,'all',0,0,1,0);
         case 'MA' %multiple text flag cols appended at end (only if defined)
            s = flags2cols(s,'mult',0,0,0,0);
            if noflags == 1; flagopt = 'N'; end  %disable flag display
         case 'MAD' %multiple text flag cols appended at end (all data/calc)
            s = flags2cols(s,'alldata',0,0,0,0);
         case 'MAD+' %multiple text flag cols appended at end (all data/calc plus any others assigned)
            s = flags2cols(s,'mult+data',0,0,0,0);
         case 'MAC' %multiple text flag cols appended at end (all data/calc)
            s = flags2cols(s,'all',0,0,0,0);
         case 'E' %multiple encoded flag cols next to data (only if defined)
            s = flags2cols(s,'mult',0,0,1,1);
            if noflags == 1; flagopt = 'N'; end  %disable flag display
         case 'ED' %multiple encoded flag cols next to data (all data/calc)
            s = flags2cols(s,'alldata',0,0,1,1);
         case 'ED+' %multiple encoded flag cols next to data (all data/calc plus any others assigned)
            s = flags2cols(s,'mult+data',0,0,1,1);
         case 'EC' %multiple encoded flag cols next to data (all data/calc)
            s = flags2cols(s,'all',0,0,1,1);
         case 'EA' %multiple encoded flag cols appended at end (only if defined)
            s = flags2cols(s,'mult',0,0,0,1);
            if noflags == 1; flagopt = 'N'; end  %disable flag display
         case 'EAD' %multiple encoded flag cols appended at end (all data/calc)
            s = flags2cols(s,'alldata',0,0,0,1);
         case 'EAD+' %multiple encoded flag cols appended at end (all data/calc plus any others assigned)
            s = flags2cols(s,'mult+data',0,0,0,1);
         case 'EAC' %multiple encoded flag cols appended at end (all data/calc)
            s = flags2cols(s,'all',0,0,0,1);
         case 'I' %inline flags
            %no action required
         otherwise  %unsupported option - ignore flags
            flagopt = 'N';
         end
         if ~strcmp(flagopt,'I')
            flagopt = 'N';  %convert non-inline flags to none because already processed
         end
      end

      %parse and validate header options
      if exist('hdropt','var') ~= 1
         hdropt = '';
      end
      if isempty(hdropt)
         hdropt = 'F';
      else
         hdropt = upper(hdropt);
         if strcmp(hdropt,'D')
            hdropt = 'SF';  %catch obsolete option
         end
         if strcmp(hdropt(1),'S') || strcmpi(metastyle,'xml')
            [tmp,basefn] = fileparts(fn);
            if strcmpi(metastyle,'xml')
               docname = [basefn,'.xml'];
               if strcmp(hdropt,'SF') || strcmp(hdropt,'F')
                  hdropt = 'B';  %override full header for xml metadata
               end
            else
               if strcmpi(extensionopt,'upper')
                  docname = [basefn,'-META.TXT'];
               else
                  docname = [basefn,'-meta.txt'];
               end
            end
            if length(hdropt) > 1
               hdropt = hdropt(2:end);
            end
         end
         if ~strcmp(hdropt,'B') && ~strcmp(hdropt,'N') && ~strcmp(hdropt,'T')
            hdropt = 'F';  %apply default if unsupported option
         end
      end

      %generate appropriate header description for metadata entry
      switch hdropt
         case 'B'
            headerdesc = '5 lines of ASCII text';
         case 'T'
            headerdesc = '1 line of ASCII text';
         case 'N'
            headerdesc = 'no header';
         otherwise
            if strcmp(fmt,'csv')
               headerdesc = 'variable length ASCII text prepended to the data table';
            else
               headerdesc = 'variable length ASCII text prepended to the data table, with lines enclosed in quotes and trailing commas';
            end
      end

      %validate path
      if exist('pn','var') ~= 1
         pn = pwd;
      elseif ~isdir(pn)
         pn = pwd;
      end

      %use data set title if not specified, otherwise sync new title to data set
      if exist('rpttitle','var') ~= 1
         rpttitle = s.title;
      elseif isempty(rpttitle)
         rpttitle = s.title;
      else
         s = addmeta(s,[{'Dataset'},{'Title'},{rpttitle}],1);  %use report title in lieu of dataset title
      end

      %add derived rownumber column if necessary
      if strcmp(rnums,'Y') && strcmp(stype,'data')
         s2 = addcol(s, ...
            (1:length(s.values{1}))', ...
            'Record', ...
            'none', ...
            'Data record number', ...
            'd', ...
            'ordinal', ...
            'discrete', ...
            0, ...
            '', ...
            0);
         if ~isempty(s2)
            s2.history = s.history;  %nullify update history for added column
            s = s2;  %replace structure
         end
      end

      %check for metadata header
      if ~strcmp(hdropt,'F') && isempty(docname)  %skip metadata update, formatting

         metastr = '';

      else  %update metadata, generate string

         newmeta = [{'Data'},{'MissingValues'},{misschar}];

         %update metadata to include file format, filename, header description
         if ~strcmp(fmt,'csv')
            if ~isempty(ldr)
               newmeta = [newmeta; ...
                     {'Data'},{'FileName'},{fn}; ...
                     {'Data'},{'Header'},{[headerdesc,' preceded by "',ldr,'"']}; ...
                     {'Data'},{'FileFormat'},{'ASCII text'}];
            else
               newmeta = [newmeta; ...
                     {'Data'},{'FileName'},{fn}; ...
                     {'Data'},{'Header'},{headerdesc}; ...
                     {'Data'},{'FileFormat'},{'ASCII text'}];
            end
         else  %csv
            newmeta = [newmeta; ...
                  {'Data'},{'FileName'},{fn}; ...
                  {'Data'},{'Header'},{headerdesc}; ...
                  {'Data'},{'FileFormat'},{'ASCII text (comma-separated value format)'}];
         end

         %update metadata to include delimiters, data types
         if ~strcmp(fmt,'fix')
            switch del
            case '\t'
               newmeta = [newmeta; ...
                     {'Data'},{'Delimiters'},{'single tab'}; ...
                     {'Data'},{'DataTypes'},{'variable width tab-delimited columns'}];
            case ','
               newmeta = [newmeta; ...
                     {'Data'},{'Delimiters'},{'single comma'}; ...
                     {'Data'},{'DataTypes'},{'variable width comma-delimited columns'}];
            case ' '
               newmeta = [newmeta; ...
                     {'Data'},{'Delimiters'},{'single space'}; ...
                     {'Data'},{'DataTypes'},{'variable width space-delimited columns'}];
            otherwise  %custom delimiter
               newmeta = [newmeta ; ...
                     {'Data'},{'Delimiters'},{['"',del,'"']}; ...
                     {'Data'},{'DataTypes'},{'variable width delimited columns'}];
            end
         else
            newmeta = [newmeta ; ...
                  {'Data'},{'Delimiters'},{'variable spaces (fixed width columns)'}; ...
                  {'Data'},{'DataTypes'},{'fixed-width columns'}];
         end

         %update metadata
         s = addmeta(s,newmeta,0,'exp_ascii');

         %generate formatted metadata
         if isempty(docname)
            metastr = listmeta(s,metastyle);  %character array only
         else
            metastr = listmeta(s,metastyle,docname,pn,'char',[],terminator);  %write to file
         end

      end

      %check for delimited text format
      if strcmp(fmt,'del') || strcmp(fmt,'csv')

         if strcmp(stype,'data')

            %init runtime loop variables
            numcol = length(s.name);
            numrows = length(s.values{1});
            assignstr = '';
            nullstr = repmat(' ',numrows,1);
            flagstr = nullstr;  %build blank flag array

            titlestr = repmat({''},1,numcol);
            unitstr = titlestr;
            varstr = titlestr;
            datastr = '';
            printstr = '';

            %define quote string
            if strcmp(fmt,'csv')
               quotestr = '"';
            else
               quotestr = '';
            end

            %build header strings and data format string
            for n = 1:numcol

               %generate string version of column number
               colstr = int2str(n);

               %fill flag matrix column
               ffstr = '';
               fpstr = '';
               if ~strcmp(flagopt,'N');
                  flags = s.flags{n};
                  if ~isempty(flags)
                     if strcmp(flagopt,'I')  %generate format string, printstr
                        ffstr = '%s';
                        fpstr = [',deblank(char(fl' colstr '(n,:)))'];
                        eval(['fl',colstr,'=flags;'])  %create flag variable
                     else  %add flags to cumulative character array of flags
                        I = find(flags(:,1)~=' ');
                        if ~isempty(I)
                           len = length(I);
                           str = [repmat([s.name{n} '='],len,1) ...
                                 flags(I,:) repmat(';',len,1)];
                           str2 = repmat(nullstr,1,size(str,2));
                           str2(I,:) = str;
                           flagstr = [flagstr str2];
                        end
                     end
                  end
               end

               %add name, units, variable type of current column to header arrays
               titlestr{n} = s.name{n};
               unitstr{n} = s.units{n};
               varstr{n} = s.variabletype{n};

               %get attributes of current column for decision-making
               cprec = s.precision(n);
               ctype = s.datatype{n};
               vtype = s.variabletype{n};

               %add comma separator if necessary
               if n > 1
                  printstr = [printstr,','];
               end

               %add column data to overall data format string
               if ~strcmp(flagopt,'I')
                  if strcmp(ctype,'s') %string
                     assignstr = [assignstr 'c' colstr '=s.values{' colstr '};'];
                     if ~strcmp(vtype,'datetime')
                        %non-datetime string - use quotes if defined
                        datastr = [datastr quotestr '%s' quotestr del];
                     else
                        %datetime string - ignore quotes if defined
                        datastr = [datastr '%s' del];
                     end
                     printstr = [printstr 'c' colstr '{n}'];
                  else  %numerical
                     assignstr = [assignstr 'c' colstr '=s.values{' colstr '};'];
                     if strcmp(ctype,'f') || strcmp(ctype,'e')  %floating point or exponential
                        datastr = [datastr '%0.' int2str(cprec) ctype del];
                        printstr = [printstr 'c' colstr '(n,1)'];
                     else  %integer
                        datastr = [datastr '%d' del];
                        printstr = [printstr 'round(c' colstr '(n,1))'];  %force rounding to avoid fprintf cast from d to e
                     end
                  end
               else  %inline flags
                  if strcmp(ctype,'s')  %string
                     assignstr = [assignstr 'c' colstr '=s.values{' colstr '};'];
                     if ~strcmp(vtype,'datetime')
                        %non-datetime string - use quotes
                        datastr = [datastr quotestr '%s' ffstr quotestr del];
                     else
                        %datetime string - ignore quotes
                        datastr = [datastr '%s' ffstr del];
                     end
                     printstr = [printstr 'c' colstr '{n}' fpstr];
                  else  %numerical
                     assignstr = [assignstr 'c' colstr '=s.values{' colstr '};'];
                     if strcmp(ctype,'f') || strcmp(ctype,'e')  %floating point or exp
                        datastr = [datastr '%0.' int2str(cprec) ctype ffstr del];
	                     printstr = [printstr 'c' colstr '(n,1)' fpstr];
                     else  %integer
                        datastr = [datastr '%d' ffstr del];
	                     printstr = [printstr 'round(c' colstr '(n,1))' fpstr];
                     end
                  end
               end

            end

            datastr = [datastr(1,1:length(datastr)-length(del)) terminator];

            %perform variable assignments for value columns
            error = 0;
            try
               eval(assignstr)
            catch
               error = 1;
            end

            %write file
            if error == 0
               try
                  if exist([pn,filesep,fn],'file') == 2 && ~strcmp(appendopt,'N')
                     fid = fopen([pn,filesep,fn],'a');  %append to existing file
                     if ~strcmp(appendopt,'T')
                        fprintf(fid,[terminator terminator]);  %add empty lines prior to writing new header
                     end
                  else
                     fid = fopen([pn,filesep,fn],'w');  %open file for write, overwriting any existing file
                  end
               catch
                  error = 1;
               end
            end

            try

               if error == 0

                  if ~strcmp(hdropt,'N') && ~strcmp(hdropt,'T')

                     if ~strcmp(fmt,'csv')  %standard delimited file

                        if strcmp(hdropt,'B')

                           if ~isempty(rpttitle)
                              fprintf(fid,[ldr ['Data set title:  %s' terminator] ldr terminator],rpttitle);
                           end

                        else  %full header

                           fprintf(fid,[ldr 'File automatically generated: %s' terminator],datestr(now));
                           fprintf(fid,[ldr terminator]);

                           %print metadata
                           for n = 1:size(metastr,1)
                              fprintf(fid,[ldr '%s' terminator],deblank(metastr(n,:)));
                           end

                           %print spacer rows
                           fprintf(fid,[ldr terminator ldr terminator]);

                        end

                     else  %csv file - wrap header lines containing commas in quotes

                        trailer = repmat(',',1,length(s.name)-1);  %generate trailing commas for header

                        if strcmp(hdropt,'B')  %brief header - title only

                           if ~isempty(rpttitle)
                              str = strrep(rpttitle,'"','""');  %escape double quotes
                              fprintf(fid,['"Data set title: %s"%s' terminator ',%s' terminator],str,trailer,trailer);
                           end

                        else  %full header - metadata

                           fprintf(fid,['"File automatically generated: %s"%s' terminator],datestr(now),trailer);
                           fprintf(fid,[',%s' terminator],trailer);

                           %print metadata
                           for n = 1:size(metastr,1)
                              str = strrep(deblank(metastr(n,:)),'"','""');
                              fprintf(fid,['"%s"%s' terminator],str,trailer);
                           end

                           fprintf(fid,[',%s' terminator ',%s' terminator],trailer,trailer);

                        end

                     end

                  end

                  %generate header if specified
                  if ~strcmp(hdropt,'N')

                     %check for csv format
                     if strcmp(fmt,'csv')

                        %wrap title, units, variables in quotes, escaping and double quotes if present
                        titlestr = sub_quotecheck(titlestr);
                        unitstr = sub_quotecheck(unitstr);
                        varstr = sub_quotecheck(varstr);

                        %print column titles
                        fprintf(fid,'%s,',titlestr{1:length(titlestr)-1});
                        fprintf(fid,['%s' terminator],titlestr{end});

                        %print units, variabletypes unless title only option specified
                        if ~strcmp(hdropt,'T')
                           fprintf(fid,'%s,',unitstr{1:length(titlestr)-1});
                           fprintf(fid,['%s' terminator],unitstr{end});
                           fprintf(fid,'%s,',varstr{1:length(titlestr)-1});
                           fprintf(fid,['%s' terminator],varstr{end});
                        end

                     else  %other delimited formats

                        %print column titles
                        fprintf(fid,ldr);  %print leader text
                        fprintf(fid,['%s' del],titlestr{1:length(titlestr)-1});
                        fprintf(fid,['%s' terminator],titlestr{end});

                        %print units, variabletypes unless title only option specified
                        if ~strcmp(hdropt,'T')
                           fprintf(fid,ldr);  %print column titles
                           fprintf(fid,['%s' del],unitstr{1:length(unitstr)-1});
                           fprintf(fid,['%s' terminator],unitstr{end});
                           fprintf(fid,ldr);
                           fprintf(fid,['%s' del],varstr{1:length(varstr)-1});
                           fprintf(fid,['%s' terminator],varstr{end});
                        end

                     end

                  end

                  if strcmp(misschar,'NaN')  %print NaNs

                     %try to use vectorized fprintf if all-numeric, no flags, no NaN subst
                     err = 0;

                     if strcmp(flagopt,'N') && sum(strcmp(s.datatype,'s')) == 0

                        %initialize output matrix
                        mat = [];

                        %build row-wise matrix
                        for n = 1:length(s.values)
                           try
                              if strcmp(s.datatype{n},'d')
                                 mat = [mat ; round(s.values{n})'];
                              else
                                 mat = [mat ; s.values{n}'];
                              end
                           catch  %problem - abort
                              err = 1;
                              break
                           end
                        end

                        method = 'fast';

                     else

                        method = 'slow';

                     end

                     if err == 0 && strcmp(method,'fast')

                        fprintf(fid,datastr,mat);

                     else  %use loop method

                        eval(['for n = 1:numrows; str = sprintf(datastr,', ...
                              printstr,'); fprintf(fid,''%s'',str); end'])

                     end

                  else  %replace NaNs

                     if strcmp(fmt,'csv') && ~isempty(misschar)
                        misschar = ['"' misschar '"'];
                     end
                     eval([' for n = 1:numrows; str = strrep(sprintf(datastr,', ...
                           printstr,'),''NaN'',misschar); fprintf(fid,''%s'',str); end'])

                  end

                  fclose(fid);

               else  %bad fid

                  msg = 'Errors occurred opening the file (possible path problem)';

               end

            catch  %bad write

               msg = 'Errors occurred writing to the file (possible sharing violation)';

            end

         else  %export stat structure

            numcol = length(s.name);
            numrows = size(s.min,1);

            namestr = [];
            unitstr = [];

           if strcmp(fmt,'csv')
              quotestr = '"';
           else
              quotestr = '';
           end

            %initialize format string vars
            f_name = [quotestr 'Column:' quotestr del];
            f_units = [quotestr 'Units:' quotestr del];
            f_cnt = [quotestr '%s' quotestr del];
            f_stat = [quotestr '%s' quotestr del];
            f_stat2 = [quotestr '%s' quotestr del];
            f_se = [quotestr '%s' quotestr del];
            p_obs = '';
            p_miss = '';
            p_val = '';
            p_flag = '';
            p_min = '';
            p_max = '';
            p_med = '';
            p_sum = '';
            p_mean = '';
            p_sd = '';
            p_se = '';

            for n = 1:numcol

               colstr = int2str(n);
               dtype = lower(s.datatype{n});

               precval = s.precision(n);
               if strcmp(dtype,'f') || strcmp(dtype,'e')
                  precstr = int2str(precval);
                  precstr1 = int2str(precval+1);
                  precstr2 = int2str(precval+2);
               else
                  precstr = '0';
                  precstr1 = '0';
                  precstr2 = '0';
               end

               %build format strings
               f_name = [f_name '%s' del];
               f_units = [f_units '%s' del];
               f_cnt = [f_cnt '%d' del];
               if strcmp(dtype,'e')
                  f_stat = [f_stat '%0.' precstr 'e' del];
                  f_stat2 = [f_stat2 '%0.' precstr 'e' del];
                  f_se = [f_se '%0.' precstr 'e' del];
               else
                  f_stat = [f_stat '%0.' precstr 'f' del];
                  f_stat2 = [f_stat2 '%0.' precstr1 'f' del];
                  f_se = [f_se '%0.' precstr2 'f' del];
               end

               namestr = [namestr,s.name(n)];
               unitstr = [unitstr,s.units(n)];

               if n > 1

                  %build assignment strings
                  a_obs = [a_obs 'obs' colstr '=s.observations(:,' colstr ');'];
                  a_miss = [a_miss 'miss' colstr '=s.missing(:,' colstr ');'];
                  a_val = [a_val 'val' colstr '=s.valid(:,' colstr ');'];
                  a_flag = [a_flag 'flag' colstr '=s.flagged(:,' colstr ');'];
                  a_min = [a_min 'min' colstr '=s.min(:,' colstr ');'];
                  a_max = [a_max 'max' colstr '=s.max(:,' colstr ');'];
                  a_med = [a_med 'med' colstr '=s.median(:,' colstr ');'];
                  a_sum = [a_sum 'sum' colstr '=s.total(:,' colstr ');'];
                  a_mean = [a_mean 'mean' colstr '=s.mean(:,' colstr ');'];
                  a_sd = [a_sd 'sd' colstr '=s.stddev(:,' colstr ');'];
                  a_se = [a_se 'se' colstr '=s.se(:,' colstr ');'];

                  %build print strings
                  p_obs = [p_obs ',obs' colstr '(n)'];
                  p_miss = [p_miss ',miss' colstr '(n)'];
                  p_val = [p_val ',val' colstr '(n)'];
                  p_flag = [p_flag ',flag' colstr '(n)'];
                  p_min = [p_min ',min' colstr '(n)'];
                  p_max = [p_max ',max' colstr '(n)'];
                  p_med = [p_med ',med' colstr '(n)'];
                  p_sum = [p_sum ',sum' colstr '(n)'];
                  p_mean = [p_mean ',mean' colstr '(n)'];
                  p_sd = [p_sd ',sd' colstr '(n)'];
                  p_se = [p_se ',se' colstr '(n)'];

               else  %first arguments

                  %build assignment strings
                  a_obs = ['obs' colstr '=s.observations(:,' colstr ');'];
                  a_miss = ['miss' colstr '=s.missing(:,' colstr ');'];
                  a_val = ['val' colstr '=s.valid(:,' colstr ');'];
                  a_flag = ['flag' colstr '=s.flagged(:,' colstr ');'];
                  a_min = ['min' colstr '=s.min(:,' colstr ');'];
                  a_max = ['max' colstr '=s.max(:,' colstr ');'];
                  a_med = ['med' colstr '=s.median(:,' colstr ');'];
                  a_sum = ['sum' colstr '=s.total(:,' colstr ');'];
                  a_mean = ['mean' colstr '=s.mean(:,' colstr ');'];
                  a_sd = ['sd' colstr '=s.stddev(:,' colstr ');'];
                  a_se = ['se' colstr '=s.se(:,' colstr ');'];

                  %build print strings
                  p_obs = [p_obs 'obs' colstr '(n)'];
                  p_miss = [p_miss 'miss' colstr '(n)'];
                  p_val = [p_val 'val' colstr '(n)'];
                  p_flag = [p_flag 'flag' colstr '(n)'];
                  p_min = [p_min 'min' colstr '(n)'];
                  p_max = [p_max 'max' colstr '(n)'];
                  p_med = [p_med 'med' colstr '(n)'];
                  p_sum = [p_sum 'sum' colstr '(n)'];
                  p_mean = [p_mean 'mean' colstr '(n)'];
                  p_sd = [p_sd 'sd' colstr '(n)'];
                  p_se = [p_se 'se' colstr '(n)'];

               end

            end

            if ~isempty(s.group{1}) && strcmp(groupcol,'Y')  %append group column

               %get group info
               if strcmp(s.group{3},'s')
                  gpstyle = [quotestr '%s' quotestr];
                  gstr = ',char(s.groupvalue{n})';
               else
                  gpstyle = ['%0.' int2str(s.group{4}) s.group{3}];
                  gstr = ',s.groupvalue(n)';
               end

               f_name = [f_name quotestr 'Group' quotestr terminator];
               f_units = [f_units quotestr 'Value' quotestr terminator];
               f_cnt = [f_cnt gpstyle terminator];
               f_stat = [f_stat gpstyle terminator];
               f_stat2 = [f_stat2 gpstyle terminator];
               f_se = [f_se gpstyle terminator];
               p_obs = [p_obs gstr];
               p_miss = [p_miss gstr];
               p_val = [p_val gstr];
               p_flag = [p_flag gstr];
               p_min = [p_min gstr];
               p_max = [p_max gstr];
               p_med = [p_med gstr];
               p_sum = [p_sum gstr];
               p_mean = [p_mean gstr];
               p_sd = [p_sd gstr];
               p_se = [p_se gstr];

            else  %trim terminal delimiters, add carriage return

               f_name = [f_name(1,1:length(f_name)-length(del)) terminator];
               f_units = [f_units(1,1:length(f_units)-length(del)) terminator];
               f_cnt = [f_cnt(1,1:length(f_cnt)-length(del)) terminator];
               f_stat = [f_stat(1,1:length(f_stat)-length(del)) terminator];
               f_stat2 = [f_stat2(1,1:length(f_stat2)-length(del)) terminator];
               f_se = [f_se(1,1:length(f_se)-length(del)) terminator];

            end

            eval(a_obs);
            eval(a_miss);
            eval(a_val);
            eval(a_flag);
            eval(a_min);
            eval(a_max);
            eval(a_med);
            eval(a_sum);
            eval(a_mean);
            eval(a_sd);
            eval(a_se);

            %write file
            try
               if exist([pn,filesep,fn],'file') == 2
                  fid = fopen([pn,filesep,fn],'a');
                  fprintf(fid,[terminator terminator]);
               else
                  fid = fopen([pn,filesep,fn],'w');
               end
            catch
               error = 1;
            end

            try

               if error == 0

                  if ~strcmp(fmt,'csv')  %standard delimited file

                     if ~strcmp(hdropt,'N')

                        if ~strcmp(hdropt,'T')

                           if strcmp(hdropt,'B')  %report title only

                              if ~isempty(rpttitle)
                                 fprintf(fid,[ldr '%s' terminator ldr terminator],rpttitle);
                              end

                           else  %generate full metadata header

                              fprintf(fid,[ldr 'Statistical report automatically generated: %s' terminator],datestr(now));

                              %print metadata
                              fprintf(fid,[ldr terminator]);
                              for n = 1:size(metastr,1)
                                 fprintf(fid,[ldr '%s' terminator],deblank(metastr(n,:)));
                              end

                              fprintf(fid,[ldr terminator ldr 'Analysis date: %s' terminator],s.analysisdate);

                           end

                           fprintf(fid,[ldr 'Flagged values: %s' terminator],s.flagoption);

                           if ~cellfun('isempty',s.group)
                              if strcmp(groupcol,'N')
                                 fprintf(fid,[ldr 'Grouped by column: ' s.group{1} ' (' s.group{2} ')' terminator]);
                              else
                                 fprintf(fid, [ldr 'Grouped by column: ' s.group{1} ' (' s.group{2} ...
                                       ') - group values appended as last column' terminator]);
                              end
                           end

                           fprintf(fid,[ldr terminator]);

                        end

                        fprintf(fid,f_name,namestr{:});

                        if ~strcmp(hdropt,'T')
                           fprintf(fid,f_units,unitstr{:});
                        end

                     end

                  else  %csv

                     if ~isempty(s.group{1}) && strcmp(groupcol,'Y')
                        trailer = repmat(',',1,length(s.name)+1);
                     else
                        trailer = repmat(',',1,length(s.name));
                     end

                     if ~strcmp(hdropt,'N')

                        if ~strcmp(hdropt,'T')

                           if strcmp(hdropt,'B')  %title only

                              if ~isempty(rpttitle)
                                 fprintf(fid,['"%s"%s' terminator ',%s' terminator],rpttitle,trailer,trailer);
                              end

                           else  %generate full metadata header

                              fprintf(fid,['"Statistical report automatically generated: %s"%s' terminator],datestr(now),trailer);

                              %print metadata
                              fprintf(fid,',%s',trailer);
                              for n = 1:size(metastr,1)
                                 str = strrep(deblank(metastr(n,:)),'"','""');
                                 fprintf(fid,['"%s"%s' terminator],str,trailer);
                              end

                              fprintf(fid,[',%s' terminator '"Analysis date: %s"%s' terminator],trailer,s.analysisdate,trailer);

                           end

                           fprintf(fid,['"Flagged values: %s"%s' terminator],s.flagoption,trailer);

                           if ~cellfun('isempty',s.group)
                              if strcmp(groupcol,'N')
                                 fprintf(fid,['"Grouped by column: ' s.group{1} ' (' s.group{2} ')"%s' terminator],trailer);
                              else
                                 fprintf(fid, ['"Grouped by column: ' s.group{1} ' (' s.group{2} ...
                                       ') - group values appended as last column"%s' terminator],trailer);
                              end
                           end

                        end

                        namestr = sub_quotecheck(namestr);
                        unitstr = sub_quotecheck(unitstr);

                        fprintf(fid,f_name,namestr{:});

                        if ~strcmp(hdropt,'T')
                           fprintf(fid,f_units,unitstr{:});
                        end

                     end

                  end

                  if strcmp(misschar,'NaN')
                     
                     %define script to generate table using eval
                     evalstr = ['n = 1; fprintf(fid,f_cnt,''Total Obs:'',' p_obs ');' ...
                     	'for n = 2:numrows; fprintf(fid,f_cnt,'''',' p_obs '); end;' ...
                        'n = 1; fprintf(fid,f_cnt,''Missing:'',' p_miss ');' ...
                     	'for n = 2:numrows; fprintf(fid,f_cnt,'''',' p_miss '); end;' ...
                        'n = 1; fprintf(fid,f_cnt,''Valid:'',' p_val ');' ...
                     	'for n = 2:numrows; fprintf(fid,f_cnt,'''',' p_val '); end;' ...
                     	'n = 1; fprintf(fid,f_cnt,''Flagged:'',' p_flag ');' ...
                     	'for n = 2:numrows; fprintf(fid,f_cnt,'''',' p_flag '); end;' ...
                     	'n = 1; fprintf(fid,f_stat,''Min:'',' p_min ');' ...
                     	'for n = 2:numrows; fprintf(fid,f_stat,'''',' p_min '); end;' ...
                     	'n = 1; fprintf(fid,f_stat,''Max:'',' p_max ');' ...
                     	'for n = 2:numrows; fprintf(fid,f_stat,'''',' p_max '); end;' ...
                     	'n = 1; fprintf(fid,f_stat,''Sum:'',' p_sum ');' ...
                        'for n = 2:numrows; fprintf(fid,f_stat,'''',' p_sum '); end;' ...
                     	'n = 1; fprintf(fid,f_stat,''Median:'',' p_med ');' ...
                     	'for n = 2:numrows; fprintf(fid,f_stat,'''',' p_med '); end;' ...
                     	'n = 1; fprintf(fid,f_stat2,''Mean:'',' p_mean ');' ...
                     	'for n = 2:numrows; fprintf(fid,f_stat2,'''',' p_mean '); end;' ...
                     	'n = 1; fprintf(fid,f_stat2,''StdDev:'',' p_sd ');' ...
                        'for n = 2:numrows; fprintf(fid,f_stat2,'''',' p_sd '); end;' ...
                        'n = 1; fprintf(fid,f_se,''SE:'',' p_se ');' ...
                     	'for n = 2:numrows; fprintf(fid,f_se,'''',' p_se '); end;'];

                     try
                        eval(evalstr)
                     catch
                        msg = 'Errors generating statistics table';
                     end

                  else  %replace missing chars

                     if strcmp(fmt,'csv') && ~isempty(misschar)
                        misschar = ['"' misschar '"'];
                     end

                     %define script to generate table using eval
                     evalstr = ['n = 1; str = strrep(sprintf(f_cnt,''Total Obs:'',' p_obs '),''NaN'',misschar); fprintf(fid,''%s'',str);' ...
                        'for n = 2:numrows; str = strrep(sprintf(f_cnt,'''',' p_obs '),''NaN'',misschar); fprintf(fid,''%s'',str); end;' ...
                        'n = 1; str = strrep(sprintf(f_cnt,''Missing:'',' p_miss '),''NaN'',misschar); fprintf(fid,''%s'',str);' ...
                        'for n = 2:numrows; str = strrep(sprintf(f_cnt,'''',' p_miss '),''NaN'',misschar); fprintf(fid,''%s'',str); end;' ...
                        'n = 1; str = strrep(sprintf(f_cnt,''Valid:'',' p_val '),''NaN'',misschar); fprintf(fid,''%s'',str);' ...
                        'for n = 2:numrows; str = strrep(sprintf(f_cnt,'''',' p_val '),''NaN'',misschar); fprintf(fid,''%s'',str); end;' ...
                        'n = 1; str = strrep(sprintf(f_cnt,''Flagged:'',' p_flag '),''NaN'',misschar); fprintf(fid,''%s'',str);' ...
                        'for n = 2:numrows; str = strrep(sprintf(f_cnt,'''',' p_flag '),''NaN'',misschar); fprintf(fid,''%s'',str); end;' ...
                        'n = 1; str = strrep(sprintf(f_stat,''Min:'',' p_min '),''NaN'',misschar); fprintf(fid,''%s'',str);' ...
                        'for n = 2:numrows; str = strrep(sprintf(f_stat,'''',' p_min '),''NaN'',misschar); fprintf(fid,''%s'',str); end;' ...
                        'n = 1; str = strrep(sprintf(f_stat,''Max:'',' p_max '),''NaN'',misschar); fprintf(fid,''%s'',str);' ...
                        'for n = 2:numrows; str = strrep(sprintf(f_stat,'''',' p_max '),''NaN'',misschar); fprintf(fid,''%s'',str); end;' ...
                        'n = 1; n = 1; str = strrep(sprintf(f_stat,''Median:'',' p_med '),''NaN'',misschar); fprintf(fid,''%s'',str);' ...
                        'for n = 2:numrows; str = strrep(sprintf(f_stat,'''',' p_med '),''NaN'',misschar); fprintf(fid,''%s'',str); end;' ...
                        'n = 1; str = strrep(sprintf(f_stat,''Sum:'',' p_sum '),''NaN'',misschar); fprintf(fid,''%s'',str);' ...
                        'for n = 2:numrows; str = strrep(sprintf(f_stat,'''',' p_sum '),''NaN'',misschar); fprintf(fid,''%s'',str); end;' ...
                        'n = 1; str = strrep(sprintf(f_stat2,''Mean:'',' p_mean '),''NaN'',misschar); fprintf(fid,''%s'',str);' ...
                        'for n = 2:numrows; str = strrep(sprintf(f_stat2,'''',' p_mean '),''NaN'',misschar); fprintf(fid,''%s'',str); end;' ...
                        'n = 1; str = strrep(sprintf(f_stat2,''StdDev:'',' p_sd '),''NaN'',misschar); fprintf(fid,''%s'',str);' ...
                        'for n = 2:numrows; str = strrep(sprintf(f_stat2,'''',' p_sd '),''NaN'',misschar); fprintf(fid,''%s'',str); end;' ...
                        'n = 1; str = strrep(sprintf(f_se,''SE:'',' p_se '),''NaN'',misschar); fprintf(fid,''%s'',str);' ...
                        'for n = 2:numrows; str = strrep(sprintf(f_se,'''',' p_se '),''NaN'',misschar); fprintf(fid,''%s'',str); end;'];
                     
                     try
                        eval(evalstr)
                     catch
                        msg = 'Errors generating statistics table';
                     end

                  end

                  fclose(fid);

               else  %bad fid

                  msg = 'Errors occurred opening the file (possible Matlab path problem)';

               end

            catch  %file locked

               msg = 'Errors occurred writing to the file (possible sharing violation)';

            end

         end

      elseif strcmp(fmt,'fix')

         if strcmp(stype,'data')

            %initialize variables
            numcol = length(s.name);
            numrows = length(s.values{1});
            if ~strcmp(hdropt,'N')
               hdrrows = 3;
            else
               hdrrows = 0;
            end

            %initialize print variables
            if ~strcmp(hdropt,'N')
               c0 = char([' Name:';'Units:';' Type:'],int2str((1:numrows)'));
               datastr = '%s  ';
               printstr = 'c0(n,:),';
            else
               datastr = '';
               c0 = '';
               printstr = '';
            end

            for n = 1:numcol

               colstr = int2str(n);

               %build header print strings
               nstr = char(s.name{n});
               if ~strcmp(hdropt,'N')
                  ustr = char(s.units{n});
                  vstr = char(s.variabletype{n});
                  eval(['h' colstr '=centerstr(nstr,centerstr(ustr,vstr));'])
               else
                  eval(['h' colstr '='''';'])
               end

               %get header values
               cprec = s.precision(n);
               ctype = char(s.datatype{n});

               %build assignment strings (convert numbers to formatted text)
               if ~strcmp(flagopt,'I')
                  if strcmp(ctype,'s')  %string
                     eval(['c' colstr '=centerstr(h' colstr ',char(s.values{' colstr '}));']);
                  else  %numerical
                     if strcmp(ctype,'f')  %floating point
                        maxval = max(abs(s.values{n}));
                        if maxval > 0
                           dig = ceil(log10(maxval)) + cprec + 2;
                        else
                           dig = cprec + 2;
                        end
                        eval(['c' colstr '=centerstr(h' colstr ',num2str(s.values{' colstr '},''%' ...
                              int2str(dig) '.' int2str(cprec) 'f''));']);
                     else  %integer
                        eval(['c' colstr '=centerstr(h' colstr ',int2str(s.values{' colstr '}));']);
                     end
                  end
               else  %include inline flags
                  flags = s.flags{n};
                  if isempty(flags)
                     flags = char(repmat(cellstr(' '),numrows,1));
                  end
                  if strcmp(ctype,'s')  %string
                     eval(['c' colstr '=centerstr(h' colstr ',[char(s.values{' colstr '}) flags]);']);
                  else  %numerical
                     if strcmp(ctype,'f')  %floating point
                        maxval = max(abs(s.values{n}));
                        if maxval > 0
                           dig = ceil(log10(maxval)) + cprec + 2;
                        else
                           dig = cprec + 2;
                        end
                        eval(['c' colstr '=centerstr(h' colstr ',[num2str(s.values{' colstr '},''%' ...
                              int2str(dig) '.' int2str(cprec) 'f'') flags]);']);
                     else  %integer
                        eval(['c' colstr '=centerstr(h' colstr ',[int2str(s.values{' colstr '}) flags]);']);
                     end
                  end
               end

               %build data format string and print argument string
               datastr = [datastr '%s  '];
               if n > 1
                  printstr = [printstr ',c' colstr '(n,:)'];
               else
                  printstr = [printstr 'c' colstr '(n,:)'];
               end

            end

            datastr = [datastr terminator];

            %write file
            try
               if exist([pn,filesep,fn],'file') == 2 && ~strcmp(appendopt,'N')
                  fid = fopen([pn,filesep,fn],'a');
                  if ~strcmp(appendopt,'T')
                     fprintf(fid,[terminator terminator]);
                  end
               else
                  fid = fopen([pn,filesep,fn],'w');
               end
            catch
               error = 1;
            end

            if error == 0

               try

                  if ~strcmp(hdropt,'N')  %print header

                     if ~isempty(rpttitle)
                        fprintf(fid,['Data set title:  %s' terminator terminator],rpttitle);
                     end

                     if strcmp(hdropt,'F')  %generate full header rows

                        fprintf(fid,[h_line1 '  %s' terminator],datestr(now));

                        %print metadata
                        if sum(~cellfun('isempty',s.metadata)) > 0
                           fprintf(fid,['  %s' terminator],deblank(metastr(1,:)));
                           for n = 2:size(metastr,1)
                              metaline = deblank(metastr(n,:));
                              if ~isempty(metaline)
                                 fprintf(fid,[blanks(9) '  %s' terminator],metaline);
                              end
                           end
                        end

                        fprintf(fid,[terminator h_line2 '  %s' terminator],char(s.version));

                        fprintf(fid,[terminator h_line3 '  %s (%d rows)' terminator], ...
                           char(s.datafile{1,1}),s.datafile{1,2});
                        for n = 2:size(s.datafile,1)
                           fprintf(fid,[blanks(length(h_line3)) '  %s (%d rows)' terminator], ...
                              char(s.datafile{n,1}),s.datafile{n,2});
                        end

                        fprintf(fid,[terminator h_line4 '  %s' terminator],s.createdate);

                        editstr = s.editdate;
                        if isempty(editstr)
                           editstr = '(not edited)';
                        end
                        fprintf(fid,[h_line5 '  %s' terminator],editstr);

                        str_hist = s.history;
                        if ~isempty(str_hist)
                           fprintf(fid,[terminator '%s  %s - %s' terminator],'Processing history:',str_hist{1,1},str_hist{1,2});
                           for n = 2:size(str_hist,1)
                              fprintf(fid,[blanks(21) '%s - %s' terminator],str_hist{n,1},str_hist{n,2});
                           end
                           fprintf(fid,terminator);
                        end

                     end

                  end

                  %print data rows using format string
                  eval(['for n = 1:size(c1,1); str = sprintf(''',datastr, ...
                        ''',',printstr,'); fprintf(fid,''%s'',str); end'])

                  fprintf(fid,[terminator terminator]);  %add extra returns in case appended to

                  fclose(fid);

               catch  %file locked
                  msg = 'Errors occurred writing to the file (possible sharing violation)';
               end

            else  %bad fid
               msg = 'Errors occurred opening the file (possible sharing violation)';
            end

         end

      end

   else
      msg = 'invalid GCE data or stat structure';
   end

else
   msg = 'insufficient arguments for function';
end


%subfunction to wrap cells in double quotes
function carray2 = sub_quotecheck(carray)
carray2 = carray;
if iscell(carray)
   for n = 1:length(carray)
      str = strrep(carray{n},'"','""');
      carray2{n} = ['"',str,'"'];
   end
end
