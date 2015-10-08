function meta2 = meta2struct(meta)
%Converts an n x 3 cell array containing GCE-LTER metadata into a nested structure
%with fields named according to metadata category and field names.  Value fields
%containing pipes will be split into character arrays during conversion.
%
%syntax: meta2 = meta2struct(meta)
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
%last modified: 26-May-2015

meta2 = [];

if nargin == 1

   if isstruct(meta)
      if isfield(meta,'metadata')
         meta = meta.metadata;
      else
         meta = '';
      end
   end

   if iscell(meta) && size(meta,2) == 3

      %rename Data/Names to Columns
      Iname = find(strcmp(meta(:,1),'Data') & strcmp(meta(:,2),'Names'));
      if ~isempty(Iname)
         Inewpos = max(find(strcmp(meta(:,1),'Data')));
         meta(Iname,2) = {'Columns'};
         Ibegin = setdiff((1:Inewpos)',Iname);
         Iend = (Inewpos+1:size(meta,1))';
         Ifinal  = [Ibegin ; Iname ; Iend];
         meta = meta(Ifinal,:);
      end

      meta(:,1) = deblank(meta(:,1));
      meta(:,2) = deblank(meta(:,2));

     %add numbered method leaders prior to splitting fields if absent
     fields = [{'Study'} , {'Methods'} ; ...
            {'Study'} , {'Instrumentation'} ; ...
            {'Study'} , {'Taxonomy'} ; ...
            {'Study'} , {'Permits'}];
      for n = 1:size(fields,1)
         I = find(strcmp(meta(:,1),fields{n,1}) & strcmp(meta(:,2),fields{n,2}));
         if length(I) == 1
            str = meta{I,3};
            if ~isempty(str)
               Istart = regexpi(str,'method \d+:');
               if isempty(Istart)
                  if strcmp(fields{n,2},'Methods') == 1
                     ar = splitstr(str,'|');
                     str_tmp = cell(1,length(ar));
                     for m = 1:length(ar)
                        str_tmp{m} = ['|Method ',int2str(m),': ',ar{m}];
                     end
                     meta{I,3} = char(concatcellcols(str_tmp,''));
                  else
                     str = trimstr(strrep(str,'|','; '));
                     if strncmp(str,'; ',2)
                        str = str(2:end);
                     end
                     meta{I,3} = ['|Method 1: ',str];
                  end
               end
            end
         end
      end

      %nest instrumentation, taxonomy, permits under methods based on method label
      Imethods = find(strcmp('Study',meta(:,1)) & strcmp('Methods',meta(:,2)));

      %parse instrumentation into lookup array
      Imatch = find(strcmp('Study',meta(:,1)) & strcmp('Instrumentation',meta(:,2)));
      if ~isempty(Imatch)        
         ar_instr = subfun_split_methods(meta{Imatch,3});
      else
         ar_instr = [];
      end

      %parse taxonomy into lookup array
      Itaxa = find(strcmp('Study',meta(:,1)) & strcmp('Taxonomy',meta(:,2)));
      if ~isempty(Itaxa)        
         ar_taxa = subfun_split_methods(meta{Itaxa,3});
      else
         ar_taxa = [];
      end
      
      %parse permits into lookup array
      Ipermits = find(strcmp('Study',meta(:,1)) & strcmp('Permits',meta(:,2)));
      if ~isempty(Ipermits)        
         ar_permits = subfun_split_methods(meta{Ipermits,3});
      else
         ar_permits = [];
      end
      
      %init substructure for methods steps
      s_methods = struct('Description','','Instrumentation','','Taxonomy','','Permits','');
      s_methodstep = struct('Method','');
      
      %parse methods
      if ~isempty(Imethods)
         
         %get method string
         str_methods = meta{Imethods(1),3};
         
         %get indices of method labels
         [Istart,Iend] = regexpi(str_methods,'method \d:');
         
         %get number of sections
         numsections = length(Istart);
         
         %loop through sections
         for n = 1:numsections
            
            %get method lable
            method_lbl = str_methods(Istart(n):Iend(n));
            
            %get method text
            if n < numsections
               method_text = str_methods(Iend(n)+1:Istart(n+1)-1);
            else
               method_text = str_methods(Iend(n)+1:end);
            end
            
            %clean up pipes and compress whitespace
            method_text = regexprep(strrep(method_text,'|',','),'\s*',' ');
            
            %init method entry
            s_methods.Description = cell2commas(splitstr(method_text,','),0);
            s_methods.Instrumentation = '';
            s_methods.Taxonomy = '';
            s_methods.Permits = '';
            
            %add instruments
            if ~isempty(ar_instr)
               Imatch = find(strcmpi(method_lbl,ar_instr(:,1)));
               if ~isempty(Imatch)
                  s_methods.Instrumentation = ar_instr{Imatch(1),2};
               end
            end
            
            %add taxonomy
            if ~isempty(ar_taxa)
               Imatch = find(strcmpi(method_lbl,ar_taxa(:,1)));
               if ~isempty(Imatch)
                  s_methods.Taxonomy = ar_taxa{Imatch(1),2};
               end
            end
            
            %add permits
            if ~isempty(ar_permits)
               Imatch = find(strcmpi(method_lbl,ar_permits(:,1)));
               if ~isempty(Imatch)
                  s_methods.Permits = ar_permits{Imatch(1),2};
               end
            end
            
            s_methodstep(n,1).Method = s_methods;
            
         end
         
      end
      
      %remove other numerical leaders prior to splitting fields
      fields = [{'Study'} , {'Personnel'} ; ...
            {'Study'} , {'Affiliations'}];

      for n = 1:size(fields,1)
         I = find(strcmp(meta(:,1),fields{n,1}) & strcmp(meta(:,2),fields{n,2}));
         if length(I) == 1
            str = meta{I,3};
            id = 1;
            while id ~= 0
               idstr = [int2str(id),': '];
               I2 = strfind(str,idstr);
               if ~isempty(I2)
                  str = strrep(str,idstr,'');
                  id = id + 1;
               else
                  id = 0;
               end
            end
            meta{I,3} = str;
         end
      end

      %remove study leaders prior to splitting fields
      fields = [{'Study'} , {'Description'} ; ...
            {'Study'} , {'Plots'} ; ...
            {'Study'} , {'BeginDate'} ; ...
            {'Study'} , {'EndDate'} ; ...
         	{'Study'} , {'Sampling'} ];
      for n = 1:size(fields,1)
         I = find(strcmp(meta(:,1),fields{n,1}) & strcmp(meta(:,2),fields{n,2}));
         if length(I) == 1
            str = meta{I,3};
            id = 1;
            while id ~= 0
               idstr = ['Study ',int2str(id),': '];
               I2 = strfind(str,idstr);
               if ~isempty(I2)
                  str = strrep(str,idstr,'');
                  id = id + 1;
               else
                  id = 0;
               end
            end
            meta{I,3} = str;
         end
      end

      %remove sitecode from site strings
      I = find(strcmp(meta(:,1),'Site') & strcmp(meta(:,2),'Location'));
      I2 = find(strcmp(meta(:,1),'Site') & ~(strcmp(meta(:,2),'Climatology') | strcmp(meta(:,2),'Location')));
      if length(I) == 1
         ar = splitstr(meta{I,3},'|');
         ar2 = meta(I2,3);
         for n = 1:length(ar)
            Istr = strfind(ar{n},' --');
            if ~isempty(Istr)
	            str = [ar{n}(1:Istr(1)-1),' -- '];
               ar2 = strrep(ar2,str,'');
            end
         end
         meta(I2,3) = ar2;
      end

      %remove unsupported and unneeded fields (i.e. generated by listmeta as attribute descriptors)
      flds = [ {'Data'} , {'Descriptions'} ; ...
               {'Data'} , {'Units'} ; ...
               {'Data'} , {'DataTypes'} ; ...
               {'Data'} , {'ColumnTypes'} ; ...
               {'Data'} , {'Columntype'} ; ...
               {'Data'} , {'FlagCriteria'} ; ...
               {'Data'} , {'VariableTypes'} ; ...
               {'Data'} , {'Precisions'} ; ...
               {'Data'} , {'ValueRange'} ; ...
               {'Data'} , {'Fields'} ; ...
               {'Data'} , {'AllAttributes'} ; ...
               {'Data'} , {'ValueCodes'} ; ...
               {'Study'} , {'Instrumentation'} ; ...
               {'Study'} , {'Taxonomy'} ; ...
               {'Study'} , {'Permits'} ];
      Irem = [];
      for n = 1:size(flds,1)
         Imatch = find(strcmp(meta(:,1),flds{n,1}) & strcmp(meta(:,2),flds{n,2}));
         if ~isempty(Imatch)
            Irem = [Irem ; Imatch];
         end
      end
      Ikeep = setdiff((1:size(meta,1))',Irem);
      meta = meta(Ikeep,:);

      %convert fields with pipes to char arrays
      vals = subfun_splitpipes(meta(:,3));
      
      %split comma-delimited fields into arrays
      splitfields = {'Dataset','Keywords';'Study','Species'};
      for n = 1:size(splitfields,1)
         I = find(strcmp(meta(:,1),splitfields{n,1}) & strcmp(meta(:,2),splitfields{n,2}));
         if ~isempty(I)
            tmp = char(splitstr(meta{I(1),3},','));
            vals(I) = {tmp};
         end
      end
      
      %store pre-parsed methods/instruments tree
      I = find(strcmp(meta(:,1),'Study') & strcmp(meta(:,2),'Methods'));
      if ~isempty(I)
         vals{I} = s_methodstep;      
      end
      
      %nest fields with repeating elemements as substructures with the specified name
      nestfields = [{'Dataset'} , {'Keywords'} , {'Keyword'} , {'nodupe'} ; ...
            {'Study'} , {'Taxonomy'} , {'Key'} , {'nodupe'} ; ...
            {'Study'} , {'Species'} , {'Taxa'} , {'nodupe'} ; ...
            {'Study'} , {'Permits'} , {'Permit'} , {'nodupe'}];
      for n = 1:size(nestfields,1)
         I = find(strcmp(meta(:,1),nestfields{n,1}) & strcmp(meta(:,2),nestfields{n,2}));
         if length(I) == 1
            if ~isempty(vals{I})
               if strcmp(nestfields{n,4},'nodupe')
                  c = unique(cellstr(vals{I}));
               else
                  c = cellstr(vals{I});
               end
               Ivalid = find(~strcmpi('none',c) & ~strcmpi('not applicable',c) & ~strcmpi('not specified',c));
               if ~isempty(Ivalid)
                  vals{I} = struct(nestfields{n,3},c(Ivalid));
               else
                  vals{I} = [];
               end
            end
         end
      end
      
      %nest study elements
      fields = [{'Study'} , {'Description'} , {'Design'}; ...
            {'Study'} , {'Plots'} , {'Plots'}; ...
            {'Study'} , {'BeginDate'} , {'BeginDate'}; ...
            {'Study'} , {'EndDate'} ,{'EndDate'}; ...
            {'Study'} , {'Sampling'} , {'Sampling'}];
      I = find(strcmp(meta(:,1),fields{1,1}) & strcmp(meta(:,2),fields{1,2}));
      if length(I) == 1
         ar1 = splitstr(vals{I},'|');
         ar = ar1;
         for n = 2:size(fields,1)
            I2 = find(strcmp(meta(:,1),fields{n,1}) & strcmp(meta(:,2),fields{n,2}));
            if length(I2) == 1
               ar2 = splitstr(vals{I2},'|');
               if length(ar2) < length(ar1)
                  ar2 = [ar2 ; repmat({'unspecified'},length(ar1)-length(ar2),1)];
               end
            else
               ar2 = repmat({'unspecified'},length(ar1),1);
            end
            ar = [ar , ar2];
  	         Iall = (1:size(meta,1));
     	      Iall = Iall(Iall~=I2);
        	   meta = meta(Iall,:);
            vals = vals(Iall);
         end
         s = struct('StudyElement',cell2struct(ar,fields(:,3),2)');
         I = find(strcmp(meta(:,1),fields{1,1}) & strcmp(meta(:,2),fields{1,2}));
         vals{I} = s;
         meta{I,3} = s;
      end

      %nest study personnel
      I = find(strcmp(meta(:,1),'Study') & strcmp(meta(:,2),'Personnel'));
      I2 = find(strcmp(meta(:,1),'Study') & strcmp(meta(:,2),'Affiliations'));
      if length(I) == 1
         pers = cellstr(vals{I});
         if ~cellfun('isempty',pers)
            if length(I2) == 1
               affil = cellstr(vals{I2});
               if size(affil,1) < size(pers,1)
                  affil = [affil ; repmat({'unspecified'},size(pers,1)-size(affil,1),1)];
               end
               %remove affiliation field
               Iall = (1:size(meta,1));
               Iall = Iall(Iall~=I2);
               meta = meta(Iall,:);
               vals = vals(Iall);
            else
               affil = repmat({'unspecified'},size(pers,1),1);
            end
            s = struct('Person','');
            for n = 1:size(pers,1)
               s(n).Person = struct('Name',pers{n},'Organization',affil{n});
            end
            vals{I} = s';
         end
      end
      
      %nest locations
      I = find(strcmp(meta(:,1),'Site') & strcmp(meta(:,2),'Location'));
      
      if length(I) == 1
         
         %define structure fields
         fields = [{'LocationName'}; ...
               {'Coordinates'}; ...
               {'Physiography'}; ...
               {'Landform'}; ...
               {'Hydrography'}; ...
               {'Topography'}; ...
               {'Geology'}; ...
               {'Vegetation'}; ...
               {'History'}];
            
         ar1 = splitstr(meta{I,3},'|');

         %parse coordinates, add BoundingBox or Point child structure for each site/location
         I2 = find(strcmp(meta(:,1),'Site') & strcmp(meta(:,2),'Coordinates'));
         if length(I2) == 1
            str = meta{I2,3};
            if ~isempty(strfind(str,'NW'))
               str = regexprep(str,'\|\s+','|');  %remove padding spaces after breaks
               str = strrep(strrep(strrep(strrep(str,'|NW:','NW:'),'|NE:',' NE:'),'|SW:',' SW:'),'|SE:',' SE:');  %remove breaks between polygon vertices
            end
            ar2 = splitstr(str,'|');  %split coordinates on remaining pipes
            if length(ar2) == length(ar1)
               for n = 1:length(ar2)
                  str = ar2{n};
                  if ~isempty(strfind(str,'NW:'))
		               s2 = struct('NorthWest','','NorthEast','','SouthEast','','SouthWest','');
	                  str = strrep(str,'NW: ','|');
   	               str = strrep(str,'NE: ','|');
      	            str = strrep(str,'SE: ','|');
         	         str = strrep(str,'SW: ','|');
                     ar_tmp = splitstr(str,'|');
                     if length(ar_tmp) == 4  %no site name format
                        s2.NorthWest = subfun_formatcoords(ar_tmp{1});
                        s2.NorthEast = subfun_formatcoords(ar_tmp{2});
                        s2.SouthEast = subfun_formatcoords(ar_tmp{3});
                        s2.SouthWest = subfun_formatcoords(ar_tmp{4});
                     elseif length(ar_tmp) == 5  %site name format
                        s2.NorthWest = subfun_formatcoords(ar_tmp{2});
                        s2.NorthEast = subfun_formatcoords(ar_tmp{3});
                        s2.SouthEast = subfun_formatcoords(ar_tmp{4});
                        s2.SouthWest = subfun_formatcoords(ar_tmp{5});
                     end
                     s2 = struct('BoundingBox',s2);
                  else  %point location
                     s2 = struct('Point',subfun_formatcoords(str));
                  end
                  ar2{n} = s2; %replace string with nested structure
               end
            else
               ar2 = repmat({''},length(ar1),1);
            end
            %remove metadata field
            Iall = (1:size(meta,1));
            Iall = Iall(Iall~=I2);
            meta = meta(Iall,:);
            vals = vals(Iall);
         else  %no coords
            ar2 = repmat({''},length(ar1),1);
         end

         %add coordinates array to location name array
         ar = [ar1 , ar2];
         
         %parse remaining location fields
         for n = 3:length(fields)
            fld = fields{n};
	         I2 = find(strcmp(meta(:,1),'Site') & strcmp(meta(:,2),fld));
            if length(I2) == 1
               str = meta{I2,3};
               if strcmp(fld,'History')
                  %collapse sub-elements within site history entries before splitting on pipes
                  str = strrep(str,'|   ',' ');  
               end
               ar2 = splitstr(str,'|');
               if length(ar2) < length(ar1)
                  ar2 = [ar2 ; repmat({''},length(ar1)-length(ar2),1)];
               end
               %remove metadata field
               Iall = (1:size(meta,1));
               Iall = Iall(Iall~=I2);
               meta = meta(Iall,:);
               vals = vals(Iall);
            else  %missing field
               ar2 = repmat({''},length(ar1),1);
            end
            ar = [ar , ar2(1:length(ar1))];
         end
         s = cell2struct(ar,fields,2);
         I = find(strcmp(meta(:,1),'Site') & strcmp(meta(:,2),'Location'));
         meta{I,3} = s;
         vals{I} = s';

      end

      %nest investigator, project leaders, parsing named subfields if present
      fields = {'Dataset','Investigator' ; 'Project','Leaders' ; 'Status','Contact'};
      subfields = {'Name', 'name:' ; ...
         'Position', 'position:' ; ...
         'Address', 'address:' ; ...
         'Organization' , 'organization:'; ...
         'City' , 'city:'; ...
         'State' , 'state:'; ...
         'PostalCode' , 'postal code:'; ...
         'Phone' , 'phone:' ; ...
         'ElectronicMail' , 'email:' ; ...
         'UserID','userid:'};
      
      for cnt = 1:size(fields,1)
         s2 = [];  %init sub-structure
         I = find(strcmp(meta(:,1),fields{cnt,1}) & strcmp(meta(:,2),fields{cnt,2}));
         if length(I) == 1
            s = struct('ContactInformation','');  %init main structure
            ar = subfun_concatsubfields(vals{I});  %clean up contact info, combining wrapped lines
            if ~isempty(ar)
               Ifirsttag = 1;
               for cnt2 = 1:size(subfields,1)
                  Imatch = find(strncmpi(ar{1},subfields{cnt2,2},length(subfields{cnt2,2})));
                  if ~isempty(Imatch)
                     Ifirsttag = cnt2;
                     break
                  end
               end
               Igroups = find(strncmpi(ar,subfields{Ifirsttag,2},length(subfields{Ifirsttag,2})));  %get starting indices of first subfield to identify groups
               if ~isempty(Igroups)
                  if length(Igroups) == 1
                     Istart = 1;
                     Iend = length(ar);
                  else
                     Istart = 1;
                     Iend = Igroups(2)-1;
                     for n = 2:length(Igroups)
                        Istart = [Istart,Igroups(n)];
                        if n < length(Igroups)
                           Iend = [Iend,Igroups(n+1)-1];
                        else
                           Iend = [Iend,length(ar)];
                        end
                     end
                  end
                  for gps = 1:length(Istart)
                     ar2 = ar(Istart(gps):Iend(gps));
                     for n = 1:size(subfields,1)
                        Imatch = find(strncmpi(ar2,subfields{n,2},length(subfields{n,2})));
                        for m = 1:length(Imatch)
                           str = ar2{Imatch(m)};
                           s2(gps).(subfields{n,1}) = trimstr(str(length(subfields{n,2})+1:end));
                        end
                     end
                  end
               else   %no first subfield tags - put all contact info in single element
                  s2 = struct('Name',{char(ar)});
               end
            else
               s2 = [];
            end
            if ~isempty(s2)
               s.ContactInformation = s2;
               vals{I} = s';
               meta{I,3} = s';
            end
         end
      end

      %nest processing history
      I = find(strcmp(meta(:,1),'Data') & strcmp(meta(:,2),'ProcessHistory'));
      if length(I) == 1
         ar = cellstr(vals{I});
         ar2 = [];
         for n = 2:length(ar)
            str = ar{n};
            Icolon = strfind(str,':');
            if ~isempty(Icolon)
	            try
                  d = datenum(str(1:Icolon(1)-1));
               catch
                  d = [];
               end
               if ~isempty(d)
                  ar2 = ar(n:end);
                  break
               end
            end
         end
         if ~isempty(ar2)
	         s = cell2struct(ar2,{'ProcessStep'},2);
   	      vals{I} = s;
            meta{I,3} = s;
         end
      end

      %get array of unique categories
      fn = unique(meta(:,1));

      %sort category names according to first occurrence in the metadata
      pos = zeros(length(fn),1);
      for n = 1:length(fn)
         I = find(strcmp(meta(:,1),fn{n}));
         pos(n) = I(1);
      end
      [pos,Isort] = sort(pos);
      fn = fn(Isort);  %desort fn list to match matadata order

      %init empty structure based on category names
      meta2 = cell2struct(repmat({''},length(fn),1),fn,1);

      %loop through fieldnames, create substructures containing field values
      for n = 1:length(fn)
         I = find(strcmp(meta(:,1),fn{n}));
         v = cell2struct(vals(I),meta(I,2),1);
         meta2.(fn{n}) = v;
      end

   end

end


%define subfunction for splitting strings with pipes
function vals = subfun_splitpipes(vals)

for n = 1:length(vals)

   val = vals{n};

   if ischar(val) && ~isempty(strfind(vals{n},'|'))

      %init vars
      rem = vals{n};
      str = '';
      tmp = [];

      %split on pipes
      while ~isempty(rem)
         [str,rem] = strtok(rem,'|');
         str = fliplr(deblank(fliplr(str)));
         if ~isempty(str)
            tmp = [tmp ; {str}];
            str = '';
         end
      end

      %process last string
      str = fliplr(deblank(fliplr(str)));
      if ~isempty(str)
         tmp = [tmp ; {str}];
      end

      %store split vals as character array
      vals{n} = char(tmp);

   end

end


%define subfunction for formatting coordinates as lon,lat in decimal degrees
function coordstr = subfun_formatcoords(str)

coordstr = '';

if ~isempty(str)
   
   %split coordinate pairs on comma
   ar = splitstr(str,',');
   
   %validate coordinate pair
   if length(ar) == 2
      
      %generate decimal degrees from formatted coordinate
      c1 = coordstr2ddeg(ar{1});
      c2 = coordstr2ddeg(ar{2});

      %check for lon/lat based on sign and magnitude
      if c1 < 0 || c1 > 90
         lon = c1;
         lat = c2;
      elseif c2 < 0 || c2 > 90
         lon = c2;
         lat = c1;
      else  %assume lat,lon if neither coordinate negative or >90
         lat = c1;
         lon = c2;
      end
      
      %format coordinates
      coordstr = sprintf('%0.6f,%0.6f',lon,lat);
      
   end
end
return

%define function for formatting contact information by concatenating wrapped lines
function ar2 = subfun_concatsubfields(str)

ar2 = [];

%check for empty input
if ~isempty(str)
   
   %dimension output array
   ar2 = cell(size(str,1),1);
   
   %init first row and row pointer
   ar2{1} = trimstr(str(1,:));
   ptr = 1;
   
   %loop through remaining rows, checking for labels and colons
   for n = 2:size(str,1)
      
      %compress string and 
      str0 = trimstr(str(n,:));
      pos = strfind(str0,':');
      
      %check for subfield label
      if ~isempty(pos) && pos(1) <= 20
         ptr = ptr + 1;
         ar2{ptr} = str0;
      else
         ar2{ptr} = [ar2{ptr},', ',str0];
      end
   end
   
   %remove empty rows
   ar2 = ar2(~cellfun('isempty',ar2));

end


%define subfunction to split metadata with method labels into a 2-column array for nesting under method description
function ar = subfun_split_methods(str)

%get indices of method labels
[Istart,Iend] = regexpi(str,'method \d:');

%get number of sections
numsections = length(Istart);
ar = cell(numsections,2);

%loop through sections
for n = 1:numsections
   
   %get method lable
   method_lbl = str(Istart(n):Iend(n));
   
   %get method text
   if n < numsections
      instr_text = str(Iend(n)+1:Istart(n+1)-1);
   else
      instr_text = str(Iend(n)+1:end);
   end
   
   %clean up pipes and compress whitespace
   instr_text = regexprep(strrep(instr_text,'|',','),'\s*',' ');
   
   %add to match array
   ar{n,1} = method_lbl;
   ar{n,2} = cell2commas(splitstr(instr_text,','),0);
   
end
