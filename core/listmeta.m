function [metastr,s_xml] = listmeta(s,style,fn,pn,opt,wrap,terminator)
%Generates formatted metadata from values stored in a GCE Data or Stat structure
%
%syntax:  [meta,s_xml] = listmeta(s,style,fn,pn,opt,wrap)
%
%inputs:
%  s = data structure
%  style = named metadata style present in 'metastyles.mat' or 'xml' for XML metadata
%  fn = filename for saving metadata to disk (optional)
%  pn = pathname (optional - pwd if omitted)
%  opt = output option
%    'char' = character array (default)
%    'cell' = cell array
%  wrap = column to use for word wrap (style default if omitted; min = 40 if nonzero)
%  terminator = line terminator character (default = '\r\n' for carriage return and line feed; 
%     specify '\n' for linefeed or '\r' for carriage return alone
%
%output:
%  meta = character or cell array of metadata
%  s_xml = XML structure ([] if style ~= xml)
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
%last modified: 15-Jul-2014

%init runtime variables
metastr = '';
error = 0;
metastruct = [];
meta = [];
s_xml = [];

%check for required input, metadata styles file in local path
if nargin >= 1 && exist('metastyles.mat','file') == 2

   %validate input and apply defaults for omitted parameters
   if exist('wrap','var') ~= 1
      wrap = [];
   elseif ischar(wrap)
      wrap = [];
   elseif wrap < 40
      wrap = 40;  %set at minimum 40 to prevent wrap problem with indents
   end

   if exist('opt','var') ~= 1
      opt = 'char';
   elseif ~strcmp(opt,'cell')
      opt = 'char';
   end

   if exist('pn','var') ~= 1
      pn = '';
   end
   if isempty(pn)
      pn = pwd;
   elseif exist(pn,'dir') ~= 7
      pn = pwd;  %invalid directory - use default
   elseif strcmp(pn(end),filesep)
      pn = pn(1:end-1);  %strip terminal file separator
   end

   %apply default GCE style if omitted
   if exist('style','var') ~= 1
      style = 'GCE';
   elseif isempty(style)
      style = 'GCE';
   elseif strcmpi(style,'xml')
      style = 'xml';  %force case to ease comparison
   end

   %default to windows line terminator if not specified or unsupported option
   if exist('terminator','var') ~= 1
      terminator = '\r\n';
   elseif ~strcmp(terminator,'\r') && ~strcmp(terminator,'\n')
      terminator = '\r\n';
   end
   
   if exist('fn','var') ~= 1
      fn = '';
   end

   prefix = '';

   if gce_valid(s)

      if ~strcmp(style,'xml')  %check for plain text style

         %load style info file
         try
            vars = load('metastyles.mat','-mat');
         catch
            vars = struct('null','');
         end

         if isfield(vars,'styles')

            styles = vars.styles;
            Istyle = find(strcmpi({styles.name},style));

            if ~isempty(Istyle)
               metastyle = styles(Istyle(1));
               prefix = metastyle.columnprefix;
            else
               metastr = 'Invalid metadata style specified';
               error = 1;
            end

         else
            metastr = 'Metadata style templates could not be loaded';
            error = 1;
         end

      end

   else
      error = 1;
   end

   if error == 0  %no errors - update column metadata and proceed

      if strcmp(style,'xml')
         s = updatecols(s,prefix,1);
      else
         s = updatecols(s,prefix,0);
      end

      if ~isempty(s)
         meta = s.metadata;
      end

      if ~isempty(meta)
         if ~strcmp(style,'xml')
            %build structure to hold metadata fields, with fieldnames = Category_Field
            try
               metastruct = cell2struct(meta(:,3),concatcellcols(meta(:,1:2),'_'),1);
            catch  %clean up metadata array by removing trailing blanks from categories/fields, concatenating redundant fields
               meta = sub_cleanupmetadata(meta);
               metastruct = cell2struct(meta(:,3),concatcellcols(meta(:,1:2),'_'),1);
            end
         end
      else
         metastr = 'Invalid metadata format in data/stat structure';
         error = 1;
      end

   end

   if error == 0  %no errors - proceed with style application

      if strcmp(style,'xml')

         %remove auxiliary fields prior to generic xml output
         killfields = [{'Data'},{'AllAttributes'} ; ...
               {'Data'},{'ColumnTypes'}];
         for n = 1:size(killfields,1)
            I = (strcmp(meta(:,1),killfields{n,1}) & strcmp(meta(:,2),killfields{n,2}));
            Iatt = find(I);
            if ~isempty(Iatt)
               meta = meta(~I,:);
            end
         end

         s_xml = meta2struct(meta);

         metastr = struct2xml(s_xml,'Metadata',1,80,3,0);

         if ~isempty(metastr) && ~isempty(fn)
            xml2file(metastr,'',0,fn,pn);
         end

      else  %format ASCII metadata

         %init runtime vars
         newmeta = [];
         nowrapflag = [];

         %get style info, attribute label lists, eval strings, levels from style
         label_list = metastyle.label;
         eval_list = metastyle.evalstr;
         level_list = metastyle.level;
         indent = metastyle.indent;
         if isempty(wrap)
            wrap = metastyle.wrapcolumn;  %use style default if not overwritten by input
         end
         nowrap = metastyle.nowrap;
         newlinechar = metastyle.newlinechar;
         if strcmp(deblank(newlinechar),'|')
            newlinechar = '';  %clear default newlinechar option so chars not replaced during string handling
         end

         %loop through style rows, performing metadata lookups and generating output strings
         for n = 1:length(label_list)

            %get style row info
            val = '';
            evalstr = eval_list{n};
            level = level_list(n);
            label = label_list{n};

            %check for something to do
            if ~isempty(evalstr)
               metafields = sub_parsefields(evalstr);  %get array of metadata fields in evalstr
               if ~isempty(metafields)
                  %replace metadata field placeholders with metadata contents
                  for m = 1:length(metafields)
                     metafield = metafields{m};
                     if isfield(metastruct,metafield)
                        newstr = metastruct.(metafield);
                     else
                        newstr = '';
                     end
                     if length(evalstr) ~= length(metafield)  %check for string expression
                        evalstr = strrep(evalstr,metafield,newstr);
                     else  %metadata field alone
                        evalstr = newstr;
                     end
                  end
               end
               val = evalstr;
            end
            
            %check for multi-line character arrays - convert to string
            if size(val,1) > 1
               val = char(concatcellcols(cellstr(val)',' '));
            end

            %generate leader if necessary
            rem = [blanks(level .* indent) , label];

            %perform newlinechar substitutions
            if isempty(newlinechar)
               rem = [rem , ' ' , val];
            elseif ~isempty(deblank(val))
               rem = [rem , ' ' , strrep(val,'|',newlinechar)];
            end

            Ibreak = strfind(rem,'|');
            if isempty(Ibreak)
               tmp = {rem};
            else
               numbreaks = length(Ibreak);
               tmp = cell(numbreaks+1,1);
               ldr = blanks((level+1) .* indent);
               for cnt = 1:numbreaks + 1
                  if cnt == 1
                     Istart = 1;
                     Iend = Ibreak(cnt)-1;
                  elseif cnt <= numbreaks
                     Istart = Ibreak(cnt-1)+1;
                     Iend = Ibreak(cnt)-1;
                  else  %last interval
                     Istart = Ibreak(end)+1;
                     Iend = length(rem);
                  end
                  str = rem(Istart:Iend);
                  if ~isempty(str) && cnt > 1
                     str = [ldr,str];
                  end
                  tmp{cnt} = str;
               end
               tmp = tmp(~cellfun('isempty',tmp));
            end

            %add to cumulative metadata array
            newmeta = [newmeta ; tmp];
            nowrapflag = [nowrapflag ; repmat(nowrap(n),size(tmp,1),1)];

         end

         %word wrap field contents if specified
         if wrap > 0

            tmp = [];
            error = 0;

            for n = 1:length(newmeta);

               str = newmeta{n};
               len = length(str);

               if len <= wrap || nowrapflag(n) == 1

                  tmp = [tmp ; {str}];

               else  %wrap overlength line

                  %initialize line counter
                  linenum = 0;

                  %get left margin
                  lmarg = length(str) - length(deblank(fliplr(str)));

                  %check for minimum left margin + 10 wrap margin
                  if wrap < (lmarg + 10)
                     tmp = [tmp ; {str}];
                     break
                  end

                  tmp2 = [];  %init temp array 2 for wrapped text

                  while ~isempty(str)

                     linenum = linenum + 1;

                     %apply indent if linenum > 1
                     if linenum > 1
                        pad = lmarg + indent;
                     else
                        pad = 0;
                     end
                     str = [blanks(pad) , str ];

                     newlen = length(str);

                     if newlen > wrap

                        %get index of spaces, skipping pad
                        Isp = strfind(str(1,pad+1:newlen),' ');

                        %calculate right margin
                        if ~isempty(Isp)
                           Isp = Isp + pad;  %shift index to account for pad
                           rmarg = min(newlen,min([max(Isp(Isp <= wrap)),wrap]));
                        else
                           rmarg = min(newlen,wrap);
                        end

                        %append first line to array
                        tmp2 = [tmp2 ; {str(1,1:rmarg)}];

                        %trim string
                        if newlen > rmarg
                           str = str(1,rmarg+1:newlen);
                        else
                           str = '';
                        end

                     else
                        tmp2 = [tmp2 ; {str}];
                        str = '';
                     end

                  end

                  tmp = [tmp ; tmp2];  %add wrapped array to master array

               end

            end

            newmeta = tmp;

         end

         if error == 0

            %write to file if specified
            if ~isempty(fn)
               fid = fopen([pn,filesep,fn],'w');
               for n = 1:size(newmeta,1)
                  fprintf(fid,['%s',terminator],newmeta{n});
               end
               fclose(fid);
            end

            %generate character array from cell if specified
            if strcmp(opt,'char')
               metastr = char(newmeta);
            else
               metastr = newmeta;  %just assign to output
            end

         end

      end

   else
      metastr = 'Metadata could not be parsed using the specified style';
   end

end

return

%
%define subfunctions called by listmeta
%

function s2 = updatecols(s,columnprefix,xml)
%Creates an nx3 cell array of metadata describing the column
%attributes of a GCE Data or Stat Structure
%last modified: 22-Feb-2001

s2 = [];
metadata = [];

if isstruct(s)

   %fill in missing description field
   if isfield(s,'name') && ~isfield(s,'description')
      s.description = s.name;
   end

   [val,type] = gce_valid(s);  %validate data structure, get type

   if val == 1 && ~isempty(s.name)

      %format attribute metadata, adding descriptive text for codes
      colname = s.name';
      coldesc = s.description';
      colunits = s.units';
      dtype = s.datatype';
      coltype = repmat({'numerical'},length(dtype),1);
      coltype(strcmp(dtype,'s')) = {'text'};
      dtype(strcmp(dtype,'f')) = {'floating-point'};
      dtype(strcmp(dtype,'e')) = {'exponential'};
      dtype(strcmp(dtype,'d')) = {'integer'};
      dtype(strcmp(dtype,'s')) = {'string'};
      dtype(strcmp(dtype,'u')) = {'unspecified'};
      vtype = s.variabletype';
      vtype(strcmp(vtype,'coord')) = {'geographic coordinate'};
      vtype(strcmp(vtype,'code')) = {'coded value'};
      vtype(strcmp(vtype,'text')) = {'free text'};
      vtype(strcmp(vtype,'calc')) = {'calculation'};
      ntype = s.numbertype';
      colprec = cellstr(int2str(s.precision'));
      colcrit = strrep(s.criteria,'''','"');
      colcrit = strrep(colcrit,'manual','manually-assigned flags');
      Iemptycrit = find(cellfun('isempty',colcrit));
      if ~isempty(Iemptycrit); colcrit(Iemptycrit) = {'none'}; end

      %generate attribute property table for generating allcols field
      numcol = length(colname);
      colstr = int2str([1:numcol]');

      %get value codes, calcs from general metadata
      codelist = lookupmeta(s,'Data','ValueCodes');
      valuecodes = repmat({''},length(s.name),1);
      if ~isempty(codelist)
         ar = splitstr(codelist,'|');
         for n = 1:length(ar)
            ar2 = splitstr(ar{n},':');
            if length(ar2) == 2
               fld = ar2{1};
               codes = ar2{2};
               Icol = find(strcmpi(s.name,fld));
               if ~isempty(Icol) && ~isempty(codes)
                  %only use first column match to avoid index errors if duplicate column names present
                  valuecodes{Icol(1)} = codes;
               end
            end
         end
      end

      if xml == 0
         allcols = [{'|'}, ...
               {'Name'}, ...
               {'Units'}, ...
               {'Data type'}, ...
               {'Variable type'}, ...
               {'Number type'}, ...
               {'Precision'}, ...
               {'QC Criteria'}];
      else
         allcols = [{'|'}, ...
               {'Name'}, ...
               {'Units'}, ...
               {'Description'}, ...
               {'DataType'}, ...
               {'VariableType'}, ...
               {'NumberType'}, ...
               {'Precision'}, ...
               {'QC_Criteria'}, ...
               {'ValueCodes'}];
      end

      namestr = '|';
      descstr = '|';
      unitstr = '|';
      dtypestr = '|';
      coltypestr = '|';
      vtypestr = '|';
      precstr = '|';
      critstr = '|';
      rngstr = '|';
      codestr = '|';

      %format attribute info by structure type
      if strcmpi(type,'data')

         vals = s.values;
         if ~isempty(vals)
            numrows = length(vals{1});
         else
            numrows = 0;
         end

         if numrows == 1
            sizestr = '1 record';
         else
            sizestr = [int2str(numrows) ' records'];
         end

         %loop through attributes, adding characteristics to field strings
         for n = 1:numcol

            if xml == 0
               spc1 = ['|' , columnprefix , colstr(n,:) , '. '];
            else
               spc1 = '|';
            end

            namestr = [namestr , spc1 , colname{n}];
            descstr = [descstr , spc1 , coldesc{n}];
            unitstr = [unitstr , spc1 , colunits{n}];
            dtypestr = [dtypestr , spc1 , dtype{n}];
            coltypestr = [coltypestr , spc1 , coltype{n}];
            vtypestr = [vtypestr , spc1 , [vtype{n},' (',ntype{n},')']];
            precstr = [precstr , spc1 , colprec{n}];
            codestr = [codestr , spc1 , valuecodes{n}];

            crit = colcrit{n};
            if length(crit) >= 2
               if strcmp(', ',crit(end-1:end))
                  crit = crit(1:end-2);
               end
            end
            critstr = [critstr , spc1 , crit];

            if xml == 0
               allcols = [allcols ; {spc1} , ...
                     {colname{n}}, ...
                     {colunits{n}}, ...
                     {dtype{n}}, ...
                     {vtype{n}}, ...
                     {ntype{n}}, ...
                     {colprec{n}}, ...
                     {crit}];
            else
               allcols = [allcols ; {spc1} , ...
                     {colname{n}}, ...
                     {colunits{n}}, ...
                     {coldesc{n}}, ...
                     {dtype{n}}, ...
                     {vtype{n}}, ...
                     {ntype{n}}, ...
                     {colprec{n}}, ...
                     {crit}, ...
                     {valuecodes{n}}];
            end

            if ~isempty(vals)
               if ~strcmp(s.datatype{n},'s')
                  x = vals{n};
                  x = x(~isnan(x));
                  if ~isempty(x)
                     rngstr = [rngstr , spc1 , [num2str(min(x)) ' to ' num2str(max(x))]];
                  else
                     rngstr = [rngstr, spc1, '(none)'];
                  end
               else
                  rngstr = [rngstr , spc1 , '(none)'];
               end
            end

         end

      else  %stat structure

         numrows = size(s.min,1);
         if numrows > 1
            sizestr = [int2str(numrows) , ' records'];
         else
            sizestr = [int2str(numrows) , ' record'];
         end

         for n = 1:numcol

            if xml == 0
               spc1 = ['|' , colstr(n,:) , '. '];
            else
               spc1 = '|';
            end

            namestr = [namestr , spc1 , colname{n}];
            descstr = [descstr , spc1 , coldesc{n}];
            unitstr = [unitstr , spc1 , colunits{n}];
            dtypestr = [dtypestr , spc1 , dtype{n}];
            coltypestr = [coltypestr , spc1 , coltype{n}];
            vtypestr = [vtypestr , spc1 , [vtype{n},' (',ntype{n},')']];
            precstr = [precstr , spc1 , colprec{n}];

            crit = colcrit{n};
            if length(crit) >= 2
               if strcmp(', ',crit(end-1:end))
                  crit = crit(1:end-2);
               end
            end
            critstr = [critstr , spc1 , crit];

            allcols = [allcols ; {spc1} , ...
                  {colname{n}}, ...
                  {colunits{n}}, ...
                  {dtype{n}}, ...
                  {vtype{n}}, ...
                  {ntype{n}}, ...
                  {colprec{n}}, ...
                  {crit}];

            if ~strcmp(s.datatype{n},'s')
               rngstr = [rngstr , spc1 , [num2str(s.min(n)) ' to ' num2str(s.max(n))]];
            else
               rngstr = [rngstr , spc1, '(none)'];
            end

         end

      end

      if xml == 0
         %concatenate allcols string array
         allstr = [char(allcols(:,1)),char(allcols(:,2))];
         padstr = repmat('   ',numcol+1,1);
         for n = 3:size(allcols,2)
            allstr = [allstr padstr char(allcols(:,n))];
         end
         allstr = allstr';
      else
         s_tmp = struct('Column',[]);
         for n = 2:size(allcols,1)
            for m = 2:size(allcols,2)
               fld = strrep(allcols{1,m},' ','');
               s_tmp(n-1).Column.(fld) = allcols{n,m};
            end
         end
         allstr = s_tmp';
      end

      %add source data file info
      datafilestr = '';
      if isfield(s,'datafile')
         datafiles = s.datafile;
         if size(datafiles,1) == 1
            datafilestr = ['Original data file processed: ', datafiles{1,1} , ' (' , int2str(datafiles{1,2}) , ' records)'];
         else
            datafilestr = 'Original data files processed: ';
            for n = 1:size(datafiles,1)
               datafilestr = [datafilestr , '|   ', datafiles{n,1} , ' (' , int2str(datafiles{n,2}) , ' records)'];
            end
         end
         datafilestr = [datafilestr , '|'];
      end

      %update processing history, format processing history string using external function
      s.history = [s.history ; ...
            {datestr(now)} {'updated 15 metadata fields in the Status, Data sections to reflect attribute metadata (''updatecols'')'}; ...
            {datestr(now)} {'parsed and formatted metadata (''listmeta'')'}];
      history = listhist(s,1);
      histstr = 'Data processing history:|';
      for n = 1:size(history,1)
         histstr = [histstr , '|   ' , deblank(history(n,:))];
      end

      %get edit history
      editstr = 'not updated';
      if isfield(s,'editdate')
         editstr = s.editdate;
         if ~isempty(editstr)
            editstr = datestr(datenum(editstr),1);
         else
            editstr = 'not updated';
         end
      end

      %look up lookbox version from doc file
      str_toolbox = 'GCE Data Toolbox for MATLAB';
      fn_info = which('gce_datatools.mat');
      if ~isempty(fn_info)
         try
            vars = load(fn_info,'-mat');
         catch
            vars = struct('null','');
         end
         if isfield(vars,'toolboxversion')
            str_toolbox = ['GCE Data ',vars.toolboxversion];
         end
      end

      %generate metadata update array to reflect physical file characteristics and attribute descriptor formatting
      if xml == 0
         metadata = [{'Status'} , {'DataUpdate'} , {editstr} ; ...
               {'Data'} , {'Fields'} , {int2str(numcol)} ; ...
               {'Data'} , {'Size'} , {sizestr} ; ...
               {'Data'} , {'Names'}, {namestr} ; ...
               {'Data'} , {'Descriptions'} , {descstr} ; ...
               {'Data'} , {'Units'} , {unitstr} ; ...
               {'Data'} , {'DataTypes'} , {dtypestr} ; ...
               {'Data'} , {'ColumnTypes'} , {coltypestr} ; ...
               {'Data'} , {'VariableTypes'} , {vtypestr} ; ...
               {'Data'} , {'Precisions'} , {precstr} ; ...
               {'Data'} , {'AllAttributes'} , {allstr(:)'} ; ...
               {'Data'} , {'FlagCriteria'} , {critstr} ; ...
               {'Data'} , {'ValueRange'} , {rngstr} ; ...
               {'Data'} , {'ProcessHistory'} , {['|Software version: ',str_toolbox,'|Data structure version: ',s.version,'|',datafilestr,histstr]}];
      else
         metadata = [{'Status'} , {'DataUpdate'} , {editstr} ; ...
               {'Data'} , {'Fields'} , {int2str(numcol)} ; ...
               {'Data'} , {'Size'} , {sizestr} ; ...
               {'Data'} , {'Names'} , {allstr} ; ...
               {'Data'} , {'Descriptions'} , {''} ; ...
               {'Data'} , {'Units'} , {''} ; ...
               {'Data'} , {'DataTypes'} , {''} ; ...
               {'Data'} , {'ColumnTypes'} , {''} ; ...
               {'Data'} , {'VariableTypes'} , {''} ; ...
               {'Data'} , {'Precisions'} , {''} ; ...
               {'Data'} , {'AllAttributes'} , {''} ; ...
               {'Data'} , {'FlagCriteria'} , {''} ; ...
               {'Data'} , {'ValueRange'} , {rngstr} ; ...
               {'Data'} , {'ProcessHistory'} , {['|Software version: ',str_toolbox,'|Data structure version: ',s.version,'|',datafilestr,histstr]}];
      end

      s2 = addmeta(s,metadata,0,'listmeta');  %update metadata fields

   end

end
return

function metafields = sub_parsefields(str)
%parses metadata fields in a text expression based on the Category_Field naming convention

metafields = [];

if ~isempty(str)

   valchars = [48:57,65:90,97:122];  %define array of valid ASCII characters

   len = length(str);

   Ius = strfind(str,'_');

   if ~isempty(Ius);

      for m = 1:length(Ius)

         Istart = Ius(m)-1;
         while Istart > 0
            c = str(Istart);
            if ~isempty(find(double(c)==valchars))
               Istart = Istart - 1;
            else
               break
            end
         end
         Istart = Istart + 1;

         Iend = Ius(m)+1;
         while Iend <= len
            c = str(Iend);
            if ~isempty(find(double(c)==valchars))
               Iend = Iend + 1;
            else
               break
            end
         end
         Iend = Iend - 1;

         newfld = str(Istart:Iend);
         metafields = [metafields ; {newfld}];

      end

   end
end
return

function meta2 = sub_cleanupmetadata(meta)
%cleans up metadata by removing trailing blanks from field names and concatenating
%multiple fields of the same name to prevent structure field naming problems

meta(:,1) = deblank(meta(:,1));
meta(:,2) = deblank(meta(:,2));
teststr = concatcellcols([meta(:,1),meta(:,2)],'_');
flds = unique(teststr);

if length(flds) ~= size(meta,1)  %check for something to do

   Ikeep = ones(size(flds,1),1);  %init master index for records to keep
   for n = 1:length(flds)
      Imatch = find(strcmp(teststr,flds{n}));
      if length(Imatch) > 1
         str = meta{Imatch(1),3};
         for m = 2:length(Imatch)
            str2 = meta{Imatch(m),3};
            if ~isempty(str2)
               str = [str,'|',str2];  %concatenate
            end
            Ikeep(Imatch(m)) = 0;  %remove record from master index to clear contents
         end
         meta{Imatch(1),3} = str;  %store concatenated results
      end
   end

   meta = meta(Ikeep,:);  %apply master index

end

meta2 = meta;
return