function newmeta = mergemeta(s1,s2,mergetype)
%Merges metadata from two GCE Data structures following a data merge or join operation
%
%syntax: newmeta = mergemeta(s1,s2)
%
%inputs:
%  s1 = first data structure
%  s2 = second data structure
%  mergetype = type of metadata merge to perform
%     'all' = all sections (default)
%     'pick' = option to select metadata sections from a list
%     1 or 2 column cell array = sections or sections/fields to merge
%
%output:
%  newmeta = meshed metadata array (nx3 cell array)
%
%(c)2002-2011 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 07-Sep-2011

newmeta = [];

if nargin >= 2

   if gce_valid(s1,'data') && gce_valid(s2,'data')

      if ~isempty(s1.metadata) && ~isempty(s2.metadata)

         %set default merge type if omitted or invalid
         if exist('mergetype','var') ~= 1
            mergetype = 'all';
         elseif ischar(mergetype) && ~strcmpi(mergetype,'pick')
            mergetype = 'all';
         elseif iscell(mergetype) && size(mergetype,2) < 2
            mergetype = 'all';
         end

         %select metadata fields in second structure to merge unless 'all' selected or no metadata
         if ~isempty(s2.metadata) && (iscell(mergetype) || strcmp(mergetype,'pick'))

            %extract metadata array
            meta2 = s2.metadata;

            %generate field list if not specified
            if ~iscell(mergetype)
               metastr = concatcellcols(meta2(:,1:2),'_');
               Isel = listdialog('liststring',metastr, ...
                  'selectionmode','multiple', ...
                  'promptstring','Select metadata sections to merge', ...
                  'name','Import Metadata', ...
                  'listsize',[0 0 280 500]);
               if ~isempty(Isel)
                  fields = meta2(Isel,1:2);
               else
                  fields = [];  %no fields selected
               end
            end

            %remove unselected fields from metadata array
            for n = 1:size(meta2,1)
               Imatch = find(strcmp(fields(:,1),meta2{n,1}) & strcmp(fields(:,2),meta2{n,2}));
               if isempty(Imatch)
                  meta2{n,3} = '';  %clear field
               end
            end

            %update structure
            s2.metadata = meta2;

         end

         %build array of general metadata categories, fields (i.e. excluding most Data sections)
         Imeta = [find(strcmp('Dataset',s1.metadata(:,1)))];
         Imeta = [Imeta ; find(strcmp('Project',s1.metadata(:,1)))];
         Imeta = [Imeta ; find(strcmp('Site',s1.metadata(:,1)))];
         Imeta = [Imeta ; find(strcmp('Study',s1.metadata(:,1)))];
         Imeta = [Imeta ; find(strcmp('Supplement',s1.metadata(:,1)))];
         Imeta = [Imeta ; find(strcmp('Status',s1.metadata(:,1)))];

         %generate array, add anomalies/calc fields from Data section
         fieldlist = [s1.metadata(Imeta,1:2); ...
               {'Data','Anomalies'}; ...
               {'Data','Calculations'}];  %add anomalies, calculations to list but leave off other Data fields

         %call subfunction to perform field-by-field comparisons, concatenate contents that differ
         newmeta = sub_concatmeta(s1.metadata,s2.metadata,fieldlist);

         if ~isempty(newmeta)  %check for no metadata or no differences

            %update metadata update date
            Imeta = find(strcmp(newmeta(:,1),'Status') & strcmp(newmeta(:,2),'MetadataUpdate'));
            if isempty(Imeta)  %cat/field not found - add
               newmeta = [newmeta ; {'Status'},{'MetadataUpdate'},{datestr(now,1)}];
            else
               newmeta{Imeta(1),3} = datestr(now,1);
            end

            %mesh study periods (earliest begin date, latest end date)
            start1 = lookupmeta(s1,'Study','BeginDate');
            end1 = lookupmeta(s1,'Study','EndDate');
            start2 = lookupmeta(s2,'Study','BeginDate');
            end2 = lookupmeta(s2,'Study','EndDate');
            if ~isempty(start1) && ~isempty(start2)
               try
                  mindate = min(datenum(start1),datenum(start2));
                  Imeta = find(strcmp(newmeta(:,1),'Study') & strcmp(newmeta(:,2),'BeginDate'));
                  if isempty(Imeta)
                     newmeta = [newmeta ; {'Study'},{'BeginDate'},{datestr(mindate,1)}];
                  else
                     newmeta{Imeta(1),3} = datestr(mindate,1);
                  end
               end
            end
            if ~isempty(end1) && ~isempty(end2)
               try
                  maxdate = max(datenum(end1),datenum(end2));
                  Imeta = find(strcmp(newmeta(:,1),'Study') & strcmp(newmeta(:,2),'EndDate'));
                  if isempty(Imeta)
                     newmeta = [newmeta ; {'Study'},{'EndDate'},{datestr(maxdate,1)}];
                  else
                     newmeta{Imeta(1),3} = datestr(maxdate,1);
                  end
               end
            end

            %mesh release dates (max public release, max project release)
            projectdate1 = lookupmeta(s1,'Status','ProjectRelease');
            publicdate1 = lookupmeta(s1,'Status','PublicRelease');
            projectdate2 = lookupmeta(s2,'Status','ProjectRelease');
            publicdate2 = lookupmeta(s2,'Status','PublicRelease');
            if ~isempty(projectdate1) && ~isempty(projectdate2)
               try
                  maxdate = max(datenum(projectdate1),datenum(projectdate2));
                  Imeta = find(strcmp(newmeta(:,1),'Status') & strcmp(newmeta(:,2),'ProjectRelease'));
                  if isempty(Imeta)
                     newmeta = [newmeta ; {'Status'},{'ProjectRelease'},{datestr(maxdate,1)}];
                  else
                     newmeta{Imeta(1),3} = datestr(maxdate,1);
                  end
               end
            end
            if ~isempty(publicdate1) && ~isempty(publicdate2)
               try
                  maxdate = max(datenum(publicdate1),datenum(publicdate2));
                  Imeta = find(strcmp(newmeta(:,1),'Status') & strcmp(newmeta(:,2),'PublicRelease'));
                  if isempty(Imeta)
                     newmeta = [newmeta ; {'Status'},{'PublicRelease'},{datestr(maxdate,1)}];
                  else
                     newmeta{Imeta(1),3} = datestr(maxdate,1);
                  end
               end
            end

            %merge value codes using dedicated subfunction
            newcodes = sub_mergecodes(lookupmeta(s1,'Data','ValueCodes'),lookupmeta(s2,'Data','ValueCodes'));
            if ~isempty(newcodes)
               Imeta = find(strcmp(newmeta(:,1),'Data') & strcmp(newmeta(:,2),'ValueCodes'));
               if isempty(Imeta)
                  newmeta = [newmeta ; {'Data'},{'ValueCodes'},{newcodes}];  %cat/field not found - add
               else
                  newmeta{Imeta(1),3} = newcodes;
               end
            end

            %merge flag codes
            flagcodes1 = deblank(lookupmeta(s1,'Data','Codes'));
            flagcodes2 = deblank(lookupmeta(s2,'Data','Codes'));
            flagcodes = '';

            if strcmp(flagcodes1,flagcodes2) == 1
               flagcodes = flagcodes1;
            elseif ~isempty(flagcodes1) && ~isempty(flagcodes2) %check for >= 1 empty fields (rely on standard concat if one/both empty)
               flagcodes1 = strrep(flagcodes1,'|',',');
               flagcodes2 = strrep(flagcodes2,'|',',');
               allflagcodes = splitstr([flagcodes1,',',flagcodes2],',');
               unique_flagcodes = allflagcodes(1);
               for n = 2:length(allflagcodes)
                  if isempty(find(strcmp(unique_flagcodes,allflagcodes{n})))
                     unique_flagcodes = [unique_flagcodes ; allflagcodes(n)];
                  end
               end
               flagcodes = cell2commas(unique_flagcodes,0);  %convert cell array to comma-sep list
            end

            if ~isempty(flagcodes)
               Imeta = find(strcmp(newmeta(:,1),'Data') & strcmp(newmeta(:,2),'Codes'));
               if isempty(Imeta)
                  newmeta = [newmeta ; {'Data'},{'Codes'},{flagcodes}];  %cat/field not found - add
               else
                  newmeta{Imeta(1),3} = flagcodes;
               end
            end

            %merge keywords
            keywords1 = deblank(lookupmeta(s1,'Dataset','Keywords'));
            keywords2 = deblank(lookupmeta(s2,'Dataset','Keywords'));
            keywords = '';  %init composite keywords

            if strcmp(keywords1,keywords2) == 1  %check for equivalence
               keywords = keywords1;
            elseif ~isempty(keywords1) && ~isempty(keywords2) %check for empty fields (rely on standard concat if one/both empty)
               keywords1 = strrep(keywords1,'|',',');
               keywords2 = strrep(keywords2,'|',',');
               try
                  allkeywords = unique([splitstr(keywords1,',') ; splitstr(keywords2,',')]);
                  keywords = cell2commas(allkeywords);
               catch
                  keywords = [keywords1,', ',keywords2];
               end
            end

            if ~isempty(keywords)
               Imeta = find(strcmp(newmeta(:,1),'Dataset') & strcmp(newmeta(:,2),'Keywords'));
               if isempty(Imeta)
                  newmeta = [newmeta ; {'Dataset','Keywords',keywords}];
               else
                  newmeta{Imeta(1),3} = keywords;
               end
            end

         else  %empty metadata array(s)

            if isempty(s1.metadata)
               newmeta = s2.metadata;  %no metadata for first structure - use second structure (returns either s2.metadata or empty array)
            else
               newmeta = s1.metadata;
            end

         end

      end

      %clear accession field if present, otherwise add it
      if ~isempty(newmeta)
         Imeta = find(strcmp(newmeta(:,1),'Dataset') & strcmp(newmeta(:,2),'Accession'));
         if isempty(Imeta)
            newmeta = [newmeta ; {'Dataset'},{'Accession'},{''}];
         else
            newmeta{Imeta(1),3} = '';
         end
      else
         newmeta = [{'Dataset'},{'Accession'},{''}];
      end

   end

end


%define subfunction for merging value codes
function mergestr = sub_mergecodes(str1,str2)

if strcmp(deblank(str1),deblank(str2)) == 1  %check for string duplication first

   mergestr = str1;

else  %perform merge

   if ~isempty(str1)
      if ~strcmp(str1(1,1),'|')
         str1 = ['|',str1];
      end
      str = [strrep(str1,',','|'),'|',strrep(str2,',','|')];
   else
      str = str2;
   end

   nvars = length(strfind(str,':'));

   if nvars > 0

      str = strrep(strrep(str,':',':|'),'||','|');  %force single line break after column label delimiter for parsing
      codes = repmat({''},nvars,2);  %init code array
      ar = splitstr(str,'|');  %split codes based on pipes
      nrows = length(ar);

      if nrows > 0
         tmp = ar{1};
         if ~isempty(strfind(tmp,':'))
            codes{1,1} = strtok(tmp,':');
            count = 1;
            codelist = '';
            for n = 2:nrows
               tmp = ar{n};
               if ~isempty(strfind(tmp,':'))
                  codes{count,2} = codelist;
                  codelist = '';
                  count = count + 1;
                  codes{count,1} = strtok(tmp,':');
               elseif ~isempty(codelist)
                  codelist = [codelist,', ',tmp];
               else
                  codelist = tmp;
               end
            end
            if ~isempty(codelist)
               codes{count,2} = codelist;
            end
         end
      end

      Ival = find(~cellfun('isempty',codes(:,1)));
      if ~isempty(Ival)
         mincodes = unique(codes(Ival,1));
      else
         mincodes = [];
      end
      nvars2 = length(mincodes);

      if nvars2 < nvars

         codes2 = [mincodes,repmat({''},nvars2,1)];
         for n = 1:nvars2
            Imeta = strcmp(codes2{n,1},codes(:,1));
            if length(Imeta) == 1
               codes2{n,2} = codes{Imeta,2};
            elseif length(Imeta) > 1
               ar2 = cell2commas(unique(splitstr(cell2commas(codes(Imeta,2)),',')));
               codes2{n,2} = ar2;
            end
         end

         codes = codes2;
         nvars = nvars2;

      end

      %convert parsed, merged code list back to pipe and comma-delimited list
      codes = concatcellcols(codes,': ');  %concatenate labels, code list
      if size(codes,1) > 1
         codes = concatcellcols(codes','|');  %concatenate multiple codes
      end

      %pre-pend pipe and convert to character array
      mergestr = ['|',char(codes)];

   else
      mergestr = str;  %return full concatenated string - no recognizable variables
   end

end


%define subfunction to concatenate metadata fields that differ in contents
function meta = sub_concatmeta(meta1,meta2,fields)

meta = [];

label1 = lookupmeta(meta1,'Dataset','Accession');
label1 = strrep(strrep(strrep(strrep(label1,'N/A',''),'none',''),'None',''),'not assigned','');
if ~isempty(label1)
   label1 = [label1,': '];
end

label2 = lookupmeta(meta2,'Dataset','Accession');
label2 = strrep(strrep(strrep(strrep(label2,'N/A',''),'none',''),'None',''),'not assigned','');
if ~isempty(label2)
   label2 = [label2,': '];
end

for n = 1:size(fields,1)

   str1 = lookupmeta(meta1,fields{n,1},fields{n,2});
   str2 = lookupmeta(meta2,fields{n,1},fields{n,2});

   if strcmp(str1,str2) ~= 1  %check for duplication, omit from output array if match

      if ~isempty(str1) && ~isempty(str2)
         if ~strcmp(str1(1,1),'|')  %add leading carriage return for indenting
            str1 = ['|',label1,str1];
         end
         meta = [meta ; fields(n,1:2),{[str1,'|',label2,str2]}];
      elseif ~isempty(str1)
         meta = [meta ; fields(n,1:2),{str1}];
      else
         meta = [meta ; fields(n,1:2),{str2}];
      end

   end

end
