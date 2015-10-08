function [refs,Ibad,Iunmatched,unmatched] = parse_endnote(fn,pn,generic_type)
%Parses bibliographic information from an EndNote export file to create a structure
%containing all supported EndNote fields. Also normalizes author, editor and keyword delimiters
%to support parsing names and keywords for uploading to the GCE Bibliographic Database.
%
%syntax: [refs,Ibad,Iunmatched,unmatched] = parse_endnote(fn,pn)
%
%inputs:
%  fn = filename of EndNote export file
%  pn = pathname of EndNote export file
%  generic_type = reference type to substitute for 'Generic'
%     default = 'Conference Paper';
%
%outputs:
%  refs = reference structure containing all recognized EndNote fields present in the file
%  Ibad = index of records with author and/or editor fields containing non-standard formatting
%  Iunmatched = index of records containing unmatched fields
%
%
%(c)2010-2015 Wade M. Sheldon
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
%Wade M. Sheldon
%Dept. of Marine Sciences
%University of Georgia
%Athens, GA 30602-3636
%email: sheldon@uga.edu
%
%last modified: 12-Mar-2015

%init output
refs = [];
Ibad = [];
Iunmatched = [];
unmatched = [];

%assign defaults for omitted arguments
if exist('pn','var') ~= 1
   pn = '';
end

if exist('fn','var') ~= 1
   fn = '';
end

if exist('generic_type','var') ~= 1
   generic_type = 'Conference Paper';
end

curpath = pwd;  %cache current directory
if exist(pn,'dir') ~= 7
   pn = curpath;
elseif strcmp(pn(end),filesep)
   pn = pn(1:end-1); %strip terminal path separator
end

%prompt for file if omitted, invalid
if exist([pn,filesep,fn],'file') ~= 2
   cd(pn)  %change to working directory
   [fn,pn] = uigetfile('*.txt','Select an EndNote export file to upload');
   cd(curpath)  %revert to original directory
   drawnow
   if fn == 0
      fn = '';
   end
end

%check for cancel
if ~isempty(fn)
   
   %generate stop word list for automatic keywording
   if exist('keyword_cull_list.txt','file') == 2      
      try
         fid_cull = fopen('keyword_cull_list.txt','r');
         cull_list = textscan(fid_cull,'%s');
         cull_list = cull_list{:};
      catch
         cull_list = {'after'; ...
            'al'; ...
            'along'; ...
            'among'; ...
            'an'; ...
            'and'; ...
            'are'; ...
            'as'; ...
            'at'; ...
            'before'; ...
            'between'; ...
            'both'; ...
            'by'; ...
            'close'; ...
            'de'; ...
            'des'; ...
            'due'; ...
            'during'; ...
            'ed'; ...
            'eds'; ...
            'effect'; ...
            'eight'; ...
            'et'; ...
            'five'; ...
            'for'; ...
            'four'; ...
            'from'; ...
            'II'; ...
            'III'; ...
            'in'; ...
            'inside'; ...
            'into'; ...
            'is'; ...
            'it'; ...
            'its'; ...
            'IV'; ...
            'IX'; ...
            'IXX'; ...
            'more'; ...
            'much'; ...
            'nine'; ...
            'of'; ...
            'off'; ...
            'on'; ...
            'one'; ...
            'outside'; ...
            'seven'; ...
            'six'; ...
            'spp'; ...
            'st'; ...
            'ten'; ...
            'than'; ...
            'that'; ...
            'the'; ...
            'their'; ...
            'those'; ...
            'three'; ...
            'through'; ...
            'to'; ...
            'two'; ...
            'un'; ...
            'use'; ...
            'using'; ...
            'VI'; ...
            'VII'; ...
            'VIII'; ...
            'vs'; ...
            'with'; ...
            'within'; ...
            'would'; ...
            'XI'; ...
            'XII'; ...
            'XIII'; ...
            'XXI'; ...
            'XXII'; ...
            'XXIII'; ...
            'XXIV'; ...
            '%'; ...
            '-'};
      end      
   else
      cull_list = '';
   end

   %init structure for parsed citation info
   fieldmap = {'A','Author'; ...
         'B','SecondaryTitle'; ...
         'C','PlacePublished'; ...
         'D','Year'; ...
         'E','Editor'; ...
         'F','Label'; ...
         'I','Publisher'; ...
         'J','Journal'; ...
         'K','Keywords'; ...
         'L','CallNumber'; ...
         'M','Accession'; ...
         'N','Number'; ...
         'P','Pages'; ...
         'R','DOI'; ...
         'S','TertiaryTitle'; ...
         'T','Title'; ...
         'U','URL'; ...
         'V','Volume'; ...
         'X','Abstract'; ...
         'Y','TertiaryAuthor'; ...
         'Z','Notes'; ...
         '0','ReferenceType'; ...
         '6','NumberOfVolumes'; ...
         '7','Edition'; ...
         '8','Date'; ...
         '9','TypeOfWork'; ...
         '?','SubsidiaryAuthor'; ...
         '@','ISBN'; ...
         '!','ShortTitle'; ...
         '&','Section'; ...
         '(','OriginalPublication'; ...
         ')','ReprintEdition'; ...
         '*','ReviewedItem'; ...
         '+','AuthorAddress'; ...
         '1','LegalNote'; ...
         '2','YearPublished'; ...
         '4','Reviewer'; ...
         '<','ResearchNotes'; ...
         'O','AlternateJournal'; ...
         'G','Language'; ...
         '>','InternalLink'};

   %init empty structure to hold parsed refs
   numrefs = 1000;
   refs = cell2struct(repmat({''},size(fieldmap,1),numrefs),fieldmap(:,2));

   %init runtime vars
   eof = 0;
   nullflag = 0;
   cnt = 1;

   %open file
   fid = fopen([pn,filesep,fn],'r');

   %parse lines
   while eof == 0

      ln = fgetl(fid);  %read next line from file

      if ~ischar(ln)  %check for eof

         eof = 1;  %set eof flag

      elseif isempty(ln)  %check for spacer line (record delimiter)

         nullflag = 1;

      elseif strncmp(ln,'%',1)  %check for field token

         tkn = ln(2);
         str = ln(4:end);
         Ifld = find(strcmp(fieldmap(:,1),tkn));  %look up field token

         if ~isempty(Ifld)

            fld = fieldmap{Ifld,2};  %look up field name

            if strcmp(tkn,'0')  %check for reference type

               %close out prior record
               if cnt > 0
                  if nullflag == 1
                     kw_flag = 0;
                     if isfield(refs,'Keywords')
                        if isempty(refs(cnt).Keywords)
                           kw_flag = 1;
                        end
                     else
                        kw_flag = 1;
                     end
                     if kw_flag == 1 && isfield(refs,'Title')
                        kw = sub_keywords(refs(cnt).Title,cull_list);
                        if ~isempty(kw)
                           refs(cnt).Keywords = kw;
                        end
                     end
                     nullflag = 0;  %clear spacer row flag
                  end                  
               end
               
               %increment record counter
               cnt = cnt + 1;
   
               %check for need to redimension refs
               if cnt > numrefs
                  numrefs = numrefs + 1000;
                  flds = fieldnames(refs);
                  refs = [refs ; cell2struct(repmat({''},length(flds),1000),flds)];  %#ok<AGROW>
               end
               
               %perform generic substitution if defined
               if ~isempty(generic_type)
                  if strcmp(str,'Generic')
                     str = generic_type;
                  end
               end

            elseif strcmp(tkn,'A') || strcmp(tkn,'E') %check for author/editor

               %check for questionable formatting, set flag
               if ~isempty(strfind(str,' and ')) || isempty(strfind(str,','))
                  Ibad = [Ibad ; cnt];
               end

               str = strrep(strrep(str,'  ',' '),'. ','.');  %remove excess whitespace
               str = strrep(str,' and ','; ');  %delimit multiple entries per field
               try
                  oldstr = refs(cnt).(fld);
               catch
                  oldstr = '';
               end
               if ~isempty(oldstr)
                  str = [oldstr,'; ',str];  %append to delimited list
               end
               
            elseif strcmp(tkn,'D')  %convert non-numeric text in year field to missing

               yearnum = str2double(str);

               if ~isnan(yearnum)
                  refs(cnt).YearNumber = fix(yearnum);
               end

            elseif strcmp(tkn,'K')  %check keyword delimiter

               %convert compound UGAMI keyword styles to comma-separated
               str = strrep(str,'  see:',',');
               str = strrep(str,';',',');

               %check for space-delimited string or single string length > 50
               if isempty(strfind(str,',')) || length(str) > 50
                  str = strrep(str,' ',', ');
                  if length(splitstr(str,',')) == 1
                     str = str(1:min(length(str),50));  %trim single string
                  end
               end
               
            elseif strcmp(tkn,'T')
               
               clc; disp(['record ',int2str(cnt),'; ',str]); drawnow

            end

            refs(cnt).(fld) = str;  %add to ref structure

         else
            Iunmatched = [Iunmatched ; cnt];  %add field index to array of unmatched
            unmatched = [unmatched ; {tkn}];
         end

      end

   end

   fclose(fid);

   %remove empty records
   refs = refs(1:cnt);
   
   %check last record for missing keywords
   kw_flag = 0;
   if isfield(refs,'Keywords')
      if isempty(refs(cnt).Keywords)
         kw_flag = 1;
      end
   else
      kw_flag = 1;
   end
   if kw_flag == 1 && isfield(refs,'Title')
      kw = sub_keywords(refs(cnt).Title,cull_list);
      if ~isempty(kw)
         refs(cnt).Keywords = kw;
      end
   end

   if isfield(refs,'YearNumber')
      Inodate = find(cellfun('isempty',{refs.YearNumber}));
      if ~isempty(Inodate)
         [refs(Inodate).YearNumber] = deal(NaN);
      end
   end

end

%remove redundant index values and sort
if ~isempty(Ibad)
   Ibad = unique(Ibad);
end

if ~isempty(Iunmatched)
   Iunmatched = unique(Iunmatched);
   unmatched = unique(unmatched);
end


%function for automatic keywording based on titles
function keywords = sub_keywords(titlestr,cull_list)

keywords = '';

if ischar(titlestr)

   str = regexprep(titlestr,'[,.;:?!"/()]*',' ');  %remove punctuation
   str = strrep(str,'--',' ');  %remove double dashes but retain hyphenated words

   wordlist = unique(splitstr(str,' '));

   if ~isempty(cull_list)      

      for n = 1:length(wordlist)
         w = wordlist{n};
         if length(w) > 1
            if sum(strcmpi(cull_list,w)) > 0
               wordlist{n} = '';
            end
            if length(find(strcmpi(wordlist,w))) > 1
               wordlist{n} = '';
            end
         else
            wordlist{n} = '';
         end
      end

      wordlist = wordlist(~cellfun('isempty',wordlist));
      if ~isempty(wordlist)
         keywords = cell2commas(wordlist);
      end

   end
   
end