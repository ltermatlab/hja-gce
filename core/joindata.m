function [s,msg] = joindata(s0,s1,key0,key1,jointype,cols0,cols1,prefix0,prefix1,s1fname,cleardupesopt,matchunits,metamerge)
%Joins two data structures together by finding matching data rows in one or more common (key) columns
%and returns a structure containing the key columns and the specified columns in both original structures
%
%syntax: [s,msg] = joindata(s0,s1,key0,key1,jointype,cols0,cols1,prefix0,prefix1,s1fname,cleardupes,matchunits,metamerge)
%
%inputs:
%  s0 = first structure
%  s1 = second structure
%  key0 = array of key column names or numbers for the first structure
%  key1 = array of key column names or numbers for the second structure
%  jointype = type of join to perform:
%    'inner' = inner join - only return records with matching keys
%    'left' = left outer join - return all records from s0 and matching records from s1
%    'right' = right outer join - return all records from s1 and matching records from s0
%    'full' = full outer join - return all records from s0 and s1
%    'lookup' = list lookup, where key columns in s0 are matched to keys in s1
%       to look up values (e.g. code definitions, site metadata fields) from a 
%       reference data set; similar to a 'left' join, except that duplicate
%       values can be present in s0 key columns.
%  cols0 = array of output column names or numbers for the first structure
%    (default = all non-key columns if omitted)
%  cols1 = array of output column names or numbers for the second structure
%    (default = all non-key columns)
%  prefix0 = optional prefix to prepend to column names of first structure (default = '')
%  prefix1 = optional prefix to prepend to column names of second structure (default = '')
%  s1fname = optional string containing the filename of the second structure to display
%    in the processing history entry
%  cleardupes = option to remove duplicate records from data structures prior to joining
%    'no' = do not remove duplicates
%    'yes' = remove records in which all key and data columns are identical (default)
%    'key' = remove records in which key columns are identical (forces join, but can result
%       in data loss!)
%  matchunits = option to require matching units for all key column matches
%     0 = no
%     1 = yes (default)
%  metamerge = metadata sections to merge
%     'all' = all sections (default)
%     'none' = no metadata sections (except data column metadata)
%     'pick' = option to select metadata sections from a list
%     1 or 2 column cell array = sections or sections/fields to merge
%
%outputs:
%  s = joined structure
%  msg = text of any error message
%
%notes:
%  1) The combination of values in key columns must be unique for each structure (unless jointype = 'lookup')
%  2) The datatypes of corresponding key columns must match, as well as the units unless matchunits = 0
%  3) For join types other than 'inner', values in unmatched records will be padded with NaNs
%     or empty strings based on the column data type
%  4) For join type 'lookup', cleardupes will be set to 'no' to allow for duplicates unless cleardupes = 'key'
%
%(c)2002-2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 28-May-2013

s = [];
msg = '';

if nargin >= 4
   
   %default to cleardupesopt = yes if not specified
   if exist('cleardupesopt','var') ~= 1
      cleardupesopt = 'yes';
   elseif ~ischar(cleardupesopt)
      cleardupesopt = 'yes';
   else
      cleardupesopt = lower(cleardupesopt);
      if ~strcmp(cleardupesopt,'no') && ~strcmp(cleardupesopt,'key')
         cleardupesopt = 'yes';
      end
   end
   
   %default to requiring matching units
   if exist('matchunits','var') ~= 1
      matchunits = 1;
   elseif matchunits ~= 0
      matchunits = 1;
   end
   
   %default to merging all metadata
   if exist('metamerge','var') ~= 1
      metamerge = 'all';
   end
   
   %default to empy s1 filename
   if exist('s1fname','var') ~= 1
      s1fname = '';
   end
   
   %default to inner join
   if exist('jointype','var') ~= 1
      jointype = 'inner';
   elseif ~ischar(jointype)
      jointype = 'inner';
   else
      jointype = lower(jointype);
   end
   
   %default to empty prefix for columns from s0
   if exist('prefix0','var') ~= 1
      prefix0 = '';
   end
   
   %default to empty prefix for columns from s1
   if exist('prefix1','var') ~= 1
      prefix1 = '';
   end
   
   %check for valid data structures
   if gce_valid(s0,'data') && gce_valid(s1,'data')
      
      %validate s0 key column selections
      if ~isnumeric(key0)
         Icols = name2col(s0,key0);  %look up column index by name
         if length(Icols) == 1 && ischar(key0) || length(Icols) == length(key0)
            key0 = Icols;  %use column index
         else
            key0 = [];  %unmatched column - clear index
         end
      else
         Icols = intersect(key0,(1:length(s0.name)));  %check for invalid column index
         if length(Icols) ~= length(key0)
            key0 = [];   %unmatched column - clear index
         end
      end
      
      %validate s1 key column selections
      if ~isnumeric(key1)
         Icols = name2col(s1,key1);  %look up column index by name
         if length(Icols) == 1 && ischar(key1) || length(Icols) == length(key1)
            key1 = Icols;  %use column index
         else
            key1 = [];  %unmatched column - clear index
         end
      else
         Icols = intersect(key1,(1:length(s1.name)));  %check for invalid column index
         if length(Icols) ~= length(key1)
            key1 = [];  %unmatched column - clear index
         end
      end
      
      %check for non-empty, same-length keys
      if ~isempty(key0) && ~isempty(key1) && length(key0) == length(key1)

         %get datatype, variabletype, units for s0, s1
         dtype0 = s0.datatype(key0);
         dtype1 = s1.datatype(key1);
         vtype0 = s0.variabletype(key0);
         vtype1 = s1.variabletype(key1);
         units0 = lower(s0.units(key0));
         units1 = lower(s1.units(key1));
         
         %check keys for same datatypes, variabletype, units
         if strcmp([dtype0{:}],[dtype1{:}]) && strcmp([vtype0{:}],[vtype1{:}]) && (matchunits == 0 || strcmp([units0{:}],[units1{:}]))
            
            %default to all non-key columns of s0 if output columns not specified
            if exist('cols0','var') ~= 1
               cols0 = [];
            elseif ~isnumeric(cols0)
               cols0 = name2col(s0,cols0);
            end
            if isempty(cols0)  %select all non-key columns by default
               cols0 = setdiff((1:length(s0.name)),key0);
            end
            
            %default to all non-key columns of s1 if output columns not specified
            if exist('cols1','var') ~= 1
               cols1 = [];
            elseif ~isnumeric(cols1)
               cols1 = name2col(s1,cols1);
            end
            if isempty(cols1)
               cols1 = setdiff((1:length(s1.name)),key1);
            end
            
            %check for valid output columns, non-empty structures
            if ~isempty(cols0) && ~isempty(cols1) && ~isempty(s0.values{1}) && ~isempty(s1.values{1})
               
               %clear dupes (and sort by key cols) or just sort structures prior to comparison
               if strcmp(cleardupesopt,'key')
                  s0 = cleardupes(s0,key0);
                  s1 = cleardupes(s1,key1);
               else
                  s0 = sortdata(s0,key0,1,1);  %sort data using case-sensitive option
                  s1 = sortdata(s1,key1,1,1);  %sort data using case-sensitive option
                  if strcmp(cleardupesopt,'yes')
                     if ~strcmp(jointype,'lookup')
                        %override cleardupes for left data set in lookup join
                        s0 = cleardupes(s0,[key0,cols0],'simple');
                     end
                     s1 = cleardupes(s1,[key1,cols1],'simple');
                  end
               end
               
               %get value array sizes
               numrows0 = length(s0.values{1});
               numrows1 = length(s1.values{1});
               
               %extract value arrays from key columns
               vals0 = s0.values(key0);
               vals1 = s1.values(key1);
               
               %get index of string columns
               stringcols = find(strcmp(dtype0,'s'));
               
               %encode string key columns as unique integers
               if ~isempty(stringcols)
                  
                  for n = 1:length(stringcols)
                     
                     %get index of globally-unique values for use as numeric substitutions
                     [allstr,Iunique,Iall] = unique([vals0{stringcols(n)};vals1{stringcols(n)}]);
                     
                     %update value arrays with integers from combined match index
                     vals0{stringcols(n)} = Iall(1:numrows0);  %use index values for original vals0 array positions
                     vals1{stringcols(n)} = Iall(numrows0+1:end);  %use index values for original vals1 array positions

                  end
                  
               end
               
               %count number of key columns
               numkeys = length(key0);
               
               %build numerical comparison matrices
               comp0 = zeros(length(s0.values{1}),numkeys);
               comp1 = zeros(length(s1.values{1}),numkeys);
               
               %populate comparison matrices
               for n = 1:numkeys
                  comp0(:,n) = vals0{n};
                  comp1(:,n) = vals1{n};
               end
               
               %run check for unique key columns
               if numkeys <= 2
                  uniq0 = size(unique(comp0,'rows'),1) == numrows0;
                  uniq1 = size(unique(comp1,'rows'),1) == numrows1;
               else  %check for excess key cols, adjust comparison matrix
                  for n = 1:numkeys
                     uniq0 = size(unique(comp0(:,1:n),'rows'),1) == numrows0;
                     uniq1 = size(unique(comp1(:,1:n),'rows'),1) == numrows1;
                     if uniq0 == 1 && uniq1 == 1
                        %numkeys = n;
                        comp0 = comp0(:,1:n);
                        comp1 = comp1(:,1:n);
                        break
                     end
                  end
               end
               
               %check for dupes in keys (ignoring dupes in s0 if jointype = 'lookup')
               if (strcmpi(jointype,'lookup') || uniq0 == 1) && uniq1 == 1
                  
                  %init row counter, indices
                  cnt = 0;
                  I0 = ones(numrows0+numrows1,1) .* NaN;
                  I1 = I0;
                  
                  %init row counters and multiplier array
                  pos0 = 1;
                  pos1 = 1;
                  mult = 10 .^ (size(comp0,2)-1:-1:0);
                  
                  %generate join index based on join type
                  switch jointype
                     
                     %inner join - match both
                     case 'inner'
                     
                        while pos0 <= numrows0 && pos1 <= numrows1
                           diffs = sum(comp0(pos0,:)~=comp1(pos1,:));  %check for key dupes
                           if diffs == 0
                              cnt = cnt + 1;
                              I0(cnt) = pos0;
                              I1(cnt) = pos1;
                              pos0 = pos0 + 1;
                              pos1 = pos1 + 1;
                           else
                              lt = sum((comp0(pos0,:)<comp1(pos1,:)).*mult);
                              gt = sum((comp0(pos0,:)>comp1(pos1,:)).*mult);
                              if lt < gt
                                 pos1 = pos1 + 1;
                              else
                                 pos0 = pos0 + 1;
                              end
                           end
                        end
                     
                     %left join - retain all s0 rows
                     case 'left'
                     
                        while pos0 <= numrows0
                           if pos1 > numrows1  %past end of right structure
                              cnt = cnt + 1;
                              rem = (pos0:numrows0)';
                              I0(cnt:cnt+length(rem)-1) = rem;
                              cnt = cnt + length(rem) - 1;
                              pos0 = numrows0 + 1;
                           else
                              diffs = sum(comp0(pos0,:)~=comp1(pos1,:));
                              if diffs == 0
                                 cnt = cnt + 1;
                                 I0(cnt) = pos0;
                                 I1(cnt) = pos1;
                                 pos0 = pos0 + 1;
                                 pos1 = pos1 + 1;
                              else
                                 lt = sum((comp0(pos0,:)<comp1(pos1,:)).*mult);
                                 gt = sum((comp0(pos0,:)>comp1(pos1,:)).*mult);
                                 if lt < gt
                                    pos1 = pos1 + 1;
                                 else
                                    cnt = cnt + 1;
                                    I0(cnt) = pos0;
                                    pos0 = pos0 + 1;
                                 end
                              end
                           end
                        end
                        
                     %right join - retain all s1 rows
                     case 'right'
                        
                        while pos1 <= numrows1
                           if pos0 > numrows0  %past end of left structure
                              cnt = cnt + 1;
                              rem = (pos1:numrows1)';  %add all remaining rows
                              I1(cnt:cnt+length(rem)-1) = rem;
                              cnt = cnt + length(rem) - 1;
                              pos1 = numrows1 + 1;
                           else
                              diffs = sum(comp0(pos0,:)~=comp1(pos1,:));
                              if diffs == 0
                                 cnt = cnt + 1;
                                 I0(cnt) = pos0;
                                 I1(cnt) = pos1;
                                 pos0 = pos0 + 1;
                                 pos1 = pos1 + 1;
                              else
                                 lt = sum((comp0(pos0,:)<comp1(pos1,:)).*mult);
                                 gt = sum((comp0(pos0,:)>comp1(pos1,:)).*mult);
                                 if lt < gt
                                    cnt = cnt + 1;
                                    I1(cnt) = pos1;
                                    pos1 = pos1 + 1;
                                 else
                                    pos0 = pos0 + 1;
                                 end
                              end
                           end
                        end
                     
                     %lookup - retain all s0 rows, fill in matching s1 rows and replicate
                     case 'lookup'

                        while pos0 <= numrows0
                           if pos1 > numrows1  %past end of right structure
                              cnt = cnt + 1;
                              rem = (pos0:numrows0)';  %build remainder array
                              I0(cnt:cnt+length(rem)-1) = rem;  %add remaining s0 rows to output index
                              cnt = cnt + length(rem) - 1;  %update final count to include skipped rows
                              break
                           else
                              diffs = sum(comp0(pos0,:)~=comp1(pos1,:));  %check for differences
                              if diffs == 0  %match
                                 cnt = cnt + 1;
                                 I0(cnt) = pos0;
                                 I1(cnt) = pos1;
                                 pos0 = pos0 + 1;  %increment s0 row count but *not* s1 to allow dupes
                              else
                                 %check where next differences are
                                 lt = sum((comp0(pos0,:)<comp1(pos1,:)).*mult);
                                 gt = sum((comp0(pos0,:)>comp1(pos1,:)).*mult);
                                 if lt < gt
                                    %difference in s1 - increment counter
                                    pos1 = pos1 + 1;
                                 else
                                    %differences in s0 - increment counter
                                    cnt = cnt + 1;
                                    I0(cnt) = pos0;
                                    pos0 = pos0 + 1;
                                 end
                              end
                           end
                        end
                        
                     %full join - retain all rows
                     otherwise
                     
                        while pos0 <= numrows0 || pos1 <= numrows1
                           cnt = cnt + 1;
                           if pos0 > numrows0  %past end of left structure
                              rem = (pos1:numrows1)';
                              I1(cnt:cnt+length(rem)-1) = rem;
                              cnt = cnt + length(rem) - 1;
                              pos1 = numrows1 + 1;
                           elseif pos1 > numrows1  %past end of right structure
                              rem = (pos0:numrows0)';
                              I0(cnt:cnt+length(rem)-1) = rem;
                              cnt = cnt + length(rem) - 1;
                              pos0 = numrows0 + 1;
                           else
                              comp0(pos0,:);
                              comp1(pos1,:);
                              diffs = sum(comp0(pos0,:)~=comp1(pos1,:));
                              if diffs == 0
                                 I0(cnt) = pos0;
                                 I1(cnt) = pos1;
                                 pos0 = pos0 + 1;
                                 pos1 = pos1 + 1;
                              else
                                 lt = sum((comp0(pos0,:)<comp1(pos1,:)).*mult);
                                 gt = sum((comp0(pos0,:)>comp1(pos1,:)).*mult);
                                 if lt < gt
                                    I1(cnt) = pos1;
                                    pos1 = pos1 + 1;
                                 else
                                    I0(cnt) = pos0;
                                    pos0 = pos0 + 1;
                                 end
                              end
                           end
                           
                        end
                  end
                  
                  %truncate indices to remove unmatched rows
                  I0 = I0(1:cnt);
                  I1 = I1(1:cnt);
                  
                  len0 = length(I0);
                  len1 = length(I1);
                  
                  %check for index errors
                  if len0 == len1
                     
                     if (~isempty(I0) && ~isempty(I1)) || strcmp(jointype,'full')
                        
                        %buffer history
                        str_hist = s0.history;
                        
                        %build output structure
                        s = newstruct;
                        s.metadata = s0.metadata;
                        if ~isempty(prefix0) || ~isempty(prefix1)  %add prefix strings
                           s.name = [s0.name(key0), ...
                              concatcellcols([repmat({prefix0},length(cols0),1),s0.name(cols0)'])', ...
                              concatcellcols([repmat({prefix1},length(cols1),1),s1.name(cols1)'])'];
                        else
                           s.name = [s0.name(key0),s0.name(cols0),s1.name(cols1)];
                        end
                        s.units = [s0.units(key0),s0.units(cols0),s1.units(cols1)];
                        s.description = [s0.description(key0),s0.description(cols0),s1.description(cols1)];
                        s.datatype = [s0.datatype(key0),s0.datatype(cols0),s1.datatype(cols1)];
                        s.variabletype = [s0.variabletype(key0),s0.variabletype(cols0),s1.variabletype(cols1)];
                        s.numbertype = [s0.numbertype(key0),s0.numbertype(cols0),s1.numbertype(cols1)];
                        s.precision = [s0.precision(key0),s0.precision(cols0),s1.precision(cols1)];
                        s.criteria = [s0.criteria(key0),s0.criteria(cols0),s1.criteria(cols1)];
                        s.values = cell(1,length(s.name));
                        s.datafile = [s0.datafile ; s1.datafile];
                        
                        %build indices of unmatched rows if necessary
                        if ~strcmp(jointype,'inner')
                           I0valid = find(~isnan(I0));
                           I1valid = find(~isnan(I1));
                           I0rem = find(isnan(I0));
                           I1rem = find(isnan(I1));
                        else
                           I0valid = [1:length(I0)]';
                           I1valid = [1:length(I1)]';
                           I0rem = [];
                           I1rem = [];
                        end
                        
                        %initialize values, flags arrays
                        vals = cell(1,numkeys+length(cols0)+length(cols1));
                        flags = vals;
                        
                        %fill key cols, output columns from s0
                        for n = 1:numkeys+length(cols0)
                           
                           if n <= numkeys
                              col = key0(n);
                           else
                              col = cols0(n-numkeys);
                           end
                           
                           if ~strcmp(s0.datatype{col},'s')
                              v = repmat(NaN,len0,1);
                           else
                              v = repmat({''},len0,1);
                           end
                           
                           I = I0(I0valid);
                           v(I0valid) = s0.values{col}(I);
                           
                           if ~isempty(s0.flags{col})
                              wid = size(s0.flags{col},2);
                              f = repmat(' ',len0,wid);
                              f(I0valid,1:wid) = s0.flags{col}(I,1:wid);
                           else
                              f = '';
                           end
                           
                           %populate missing key fields with values from s1
                           if n <= numkeys && ~strcmp(jointype,'inner')
                              if ~isempty(I0rem)  %add missing values, flags from s0
                                 I = I1(I0rem);
                                 v(I0rem) = s1.values{key1(n)}(I);
                                 f1 = s1.flags{key1(n)};
                                 if ~(isempty(f) && isempty(f1))  %mesh flags
                                    if ~isempty(f) && isempty(f1)  %pad flags for s1
                                       f(I0rem,1:size(f,2)) = repmat(' ',length(I0rem),size(f,2));
                                    elseif isempty(f) && ~isempty(f1)
                                       wid = size(f1,2);
                                       f = repmat(' ',len0,wid);
                                       f(I0rem,1:wid) = f1(I,1:wid);
                                    else  %flags for both, mesh widths
                                       wid0 = size(f,2);
                                       wid1 = size(f1,2);
                                       if wid0 > wid1
                                          f1 = [f1,repmat(' ',size(f1,1),wid0-wid1)];
                                       elseif wid0 < wid1
                                          f = [f,repmat(' ',size(f,1),wid1-wid0)];
                                       end
                                       wid = max(wid0,wid1);
                                       f(I0rem,1:wid) = f1(I,1:wid);
                                    end
                                 end
                              end
                           end
                           
                           vals{n} = v;
                           flags{n} = f;
                           
                        end
                        
                        %fill output columns from s1
                        for n = 1:length(cols1)
                           
                           col = cols1(n);
                           
                           if ~strcmp(s1.datatype{col},'s')
                              v = repmat(NaN,len0,1);
                           else
                              v = repmat({''},len0,1);
                           end
                           
                           I = I1(I1valid);
                           v(I1valid) = s1.values{col}(I);
                           
                           if ~isempty(s1.flags{col})
                              wid = size(s1.flags{col},2);
                              f = repmat(' ',len1,wid);
                              f(I1valid,1:wid) = s1.flags{col}(I,1:wid);
                           else
                              f = '';
                           end
                           
                           vals{numkeys+length(cols0)+n} = v;
                           flags{numkeys+length(cols0)+n} = f;
                           
                        end
                        
                        %append key columns, output columns
                        s.values = vals;
                        s.flags = flags;
                        
                        if gce_valid(s,'data')
                           
                           %resort structure if right,full join
                           if ~strcmp(jointype,'inner')
                              s = sortdata(s,(1:numkeys),1,1);
                           end
                           
                           %merge metadata unless 'none' specified for metamerge
                           if iscell(metamerge) || ~strcmp(metamerge,'none')
                              newmeta = mergemeta(s0,s1,metamerge);
                           else
                              newmeta = s0.metadata;  %no metadata merge - just use first structure
                           end
                           
                           %redefine title based on original data filenames, clear accession
                           %titlestr = ['Combined data from files ',cell2commas(s.datafile(:,1),1)];
                           titlestr = ['Joined data from ',s0.title,' and ',s1.title];
                           if ~isempty(newmeta)
                              I = find(strcmp(newmeta(:,1),'Dataset') & strcmp(newmeta(:,2),'Title'));
                              if isempty(I)
                                 newmeta = [newmeta ; {'Dataset'},{'Title'},{titlestr}];
                              else
                                 newmeta{I(1),3} = titlestr;
                              end
                           else
                              newmeta = [{'Dataset'},{'Title'},{titlestr}];
                           end
                           s.title = titlestr;  %update structure title
                           
                           %clear accession field in metadata, if present
                           I = find(strcmp(newmeta(:,1),'Dataset') & strcmp(newmeta(:,2),'Accession'));
                           if isempty(I)
                              newmeta = [newmeta ; {'Dataset'},{'Accession'},{'N/A'}];
                           else
                              newmeta{I(1),3} = 'N/A';
                           end
                           
                           %update metadata
                           s = addmeta(s,newmeta,1);
                           
                           %generate history entry
                           if length(key0) == 1
                              colstr = ' column ';
                           else
                              colstr = ' columns ';
                           end
                           
                           switch jointype
                              case 'left'
                                 joinstr = ['performed a left join of',colstr];
                              case 'right'
                                 joinstr = ['performed a right outer join of',colstr];
                              case 'full'
                                 joinstr = ['performed a full outer join of',colstr];
                              case 'lookup'
                                 joinstr = ['performed a lookup join of',colstr];
                              otherwise
                                 joinstr = ['performed an inner join of',colstr];
                           end
                           
                           if ~isempty(prefix0)
                              prefix0str = [' renamed by adding the prefix ''',prefix0,''''];
                           else
                              prefix0str = '';
                           end
                           
                           if ~isempty(prefix1)
                              prefix1str = [' renamed by adding the prefix ''',prefix1,''''];
                           else
                              prefix1str = '';
                           end
                           
                           if ~isempty(s1fname)
                              fnstr = [' from ',s1fname];
                           else
                              fnstr =  ' from a second structure';
                           end
                           
                           %perform history update
                           s.history = [str_hist ; ...
                              {datestr(now)},{[joinstr,cell2commas(s0.name(key0),1), ...
                              ' on',colstr,cell2commas(s1.name(key1),1),fnstr,', returning column(s) ', ...
                              cell2commas(s0.name(cols0),1),' from the first structure',prefix0str,' and column(s) ', ...
                              cell2commas(s1.name(cols1),1),' from the second structure',prefix1str,' (', ...
                              int2str(length(s.values{1})),' rows) (''joindata'')']}];
                           
                           %update edit date
                           s.editdate = datestr(now);
                           
                           %issue non-overlap warning message for full outer join
                           if isempty(I0) && isempty(I1)
                              msg = 'no intersecting rows in key fields so data columns do not overlap';
                           end
                           
                        else
                           s = [];
                           msg = 'errors occurred applying the join indices to create a new structure';
                        end
                        
                     else
                        s = [];
                        msg = 'no intersecting rows in key fields so data columns do not overlap';
                     end
                     
                  else
                     s = [];
                     msg = 'errors occurred creating the join index';
                  end
                  
               else
                  if uniq0 == 1
                     msg = 'key columns of second structure are not unique';
                  elseif uniq1 == 1
                     msg = 'key columns of first structure are not unique';
                  else
                     msg = 'key columns of neither structure are unique';
                  end
               end
               
            else
               if isempty(cols0) || isempty(cols1)
                  msg = 'output columns not specified for one or both structures';
               else
                  msg = 'one or both structures contain no data rows';
               end
            end
            
         else
            msg = 'key column data types, variable types, or units are mismatched';
         end
         
      else
         msg = 'invalid or unmatched key columns';
      end
      
   else
      msg = 'one or both data structures are invalid';
   end
   
else
   msg = 'insufficient arguments for function';
end
