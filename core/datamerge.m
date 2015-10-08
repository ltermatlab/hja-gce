function [s,msg] = datamerge(s1,s2,order,addcols,units,fixflags,calcflags)
%Merges (concatenates) two GCE Data Structures to create a combined structure
%
%Note: column matching is based on a case-insensitive comparison of column names,
%column data types, and (optionally) column units (differences in other descriptors
%are ignored -- contents from top data structure are used for the derived structure)
%
%syntax:  [s,msg] = datamerge(s1,s2,order,addcols,units,fixflags,calcflags)
%
%inputs:
%   s1 = first data structure
%   s2 = second data structure
%   order = merge order:
%     0 = ascending structure creation date order (default)
%     1 = data1 at top
%     2 = data2 at top
%   addcols = option to add columns to accomodate mismatched fields:
%     0 = do not add columns - all columns must match
%     1 = add columns to accomodate mismatches
%   units = option to perform a case-insensitive comparison of unit strings
%     when identifying matching columns:
%     0 = no units comparison
%     1 = compare units (default)
%   fixflags = option to fix flags prior to merging data sets by adding 'manual'
%     to each Q/C criteria string to prevent inappropriate automatic reflagging
%     0 = do not fix (default)
%     1 = fix
%   calcflags = option to recalculate flags after merging data
%     0 = no  (default if fixflags = 1)
%     1 = yes (default if fixflags = 0, ignored if fixflags = 1)
%
%outputs:
%   s = merged data structure
%   msg = string containing any error messages
%
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

%initialize variables
s = [];
msg = '';
cancel = 0;

if nargin >= 2

   if gce_valid(s1,'data') == 1 && gce_valid(s2,'data') == 1  %check for valid structures

      %apply defaults for omitted arguments
      if exist('fixflags','var') ~= 1
         fixflags = 0;
      end

      if exist('calcflags','var') ~= 1
         if fixflags == 0
            calcflags = 1;
         else
            calcflags = 0;
         end
      end

      if exist('units','var') ~= 1
         units = 1;
      end

      if exist('addcols','var') ~= 1
         addcols = 0;
      end

      if exist('order','var') ~= 1
         order = 0;
      end

      %determine structure creation date order if automatic
      if order == 0
         datediff = datenum(s2.createdate) - datenum(s1.createdate);
         if datediff >= 0  %s2 same or newer
            order = 1;
         else
            order = 2;
         end
      end

      %lock flags if requested
      if fixflags == 1
         s1 = flag_locks(s1,'lock',[]);
         s2 = flag_locks(s2,'lock',[]);
      end

      %perform column matching determination
      matchcols = 0;
      if length(s1.name) == length(s2.name)
         %sort by column names to allow straight comparison
         [colnames1,I1] = sort(lower(s1.name));
         [colnames2,I2] = sort(lower(s2.name));
         dtypes1 = s1.datatype(I1);
         dtypes2 = s2.datatype(I2);
         if sum(~strcmp(colnames1,colnames2)) > 0 || sum(~strcmp(dtypes1,dtypes2)) > 0  %columns don't match
            matchcols = 1;
         elseif units == 1  %check units
            if sum(~strcmpi(s1.units(I1),s2.units(I2))) > 0
               matchcols = 1;
            end
         end
      else  %different lengths - force match
         matchcols = 1;
      end

      if matchcols == 1  %perform column matching

         if addcols == 1

            numcols1 = length(s1.name);
            numcols2 = length(s2.name);

            %append datatypes to column names to ensure dual match
            colnames1 = cell(1,numcols1);
            colnames2 = cell(1,numcols2);
            if units == 0
               for n = 1:numcols1
                  colnames1{n} = [lower(s1.name{n}),'_',s1.datatype{n}];
               end
               for n = 1:numcols2
                  colnames2{n} = [lower(s2.name{n}),'_',s2.datatype{n}];
               end
            else  %add unit strings to enable unit matching
               for n = 1:numcols1
                  colnames1{n} = [lower(s1.name{n}),'_',s1.datatype{n},'_',lower(s1.units{n})];
               end
               for n = 1:numcols2
                  colnames2{n} = [lower(s2.name{n}),'_',s2.datatype{n},'_',lower(s2.units{n})];
               end
            end

            %form comparison matrix
            Imatches = zeros(numcols1,numcols2);
            for n = 1:numcols1
               Imatch = strcmp(colnames1{n},colnames2);
               Imatches(n,:) = Imatch;
            end

            %get indices of missing columns by row/col inverted sums
            Iadd1 = find(~sum(Imatches'));
            Iadd2 = find(~sum(Imatches));

            if length(Iadd1) ~= numcols1 && length(Iadd2) ~= numcols2

               %add mismatched columns from s2 to s1
               if ~isempty(Iadd2)
                  s1.name = [s1.name,s2.name(Iadd2)];
                  s1.units = [s1.units,s2.units(Iadd2)];
                  s1.description = [s1.description,s2.description(Iadd2)];
                  s1.datatype = [s1.datatype,s2.datatype(Iadd2)];
                  s1.variabletype = [s1.variabletype,s2.variabletype(Iadd2)];
                  s1.numbertype = [s1.numbertype,s2.numbertype(Iadd2)];
                  s1.precision = [s1.precision,s2.precision(Iadd2)];
                  s1.criteria = [s1.criteria,s2.criteria(Iadd2)];
                  v = cell(1,length(Iadd2));
                  f = v;
                  numrows = length(s1.values{1});
                  for n = 1:length(Iadd2)
                     if ~strcmp(s2.datatype{Iadd2(n)},'s')
                        v{n} = repmat(NaN,numrows,1);
                     else
                        v{n} = repmat({''},numrows,1);
                     end
                     if isempty(s2.flags{Iadd2(n)})
                        f{n} = '';
                     else
                        f{n} = repmat(' ',numrows,1);
                     end
                  end
                  s1.values = [s1.values,v];
                  s1.flags = [s1.flags,f];
               end

               %add mismatched columns from s1 to s2
               if ~isempty(Iadd1)
                  s2.name = [s2.name,s1.name(Iadd1)];
                  s2.units = [s2.units,s1.units(Iadd1)];
                  s2.description = [s2.description,s1.description(Iadd1)];
                  s2.datatype = [s2.datatype,s1.datatype(Iadd1)];
                  s2.variabletype = [s2.variabletype,s1.variabletype(Iadd1)];
                  s2.numbertype = [s2.numbertype,s1.numbertype(Iadd1)];
                  s2.precision = [s2.precision,s1.precision(Iadd1)];
                  s2.criteria = [s2.criteria,s1.criteria(Iadd1)];
                  v = cell(1,length(Iadd1));
                  f = v;
                  numrows = length(s2.values{1});
                  for n = 1:length(Iadd1)
                     if ~strcmp(s1.datatype{Iadd1(n)},'s')
                        v{n} = repmat(NaN,numrows,1);
                     else
                        v{n} = repmat({''},numrows,1);
                     end
                     if isempty(s1.flags{Iadd1(n)})
                        f{n} = '';
                     else
                        f{n} = repmat(' ',numrows,1);
                     end
                  end
                  s2.values = [s2.values,v];
                  s2.flags = [s2.flags,f];
               end

               Icols = [];
               for n = 1:length(s1.name)
                  if units == 0
                     Imatch = find(strcmpi(s1.name{n},s2.name)+strcmp(s1.datatype{n},s2.datatype)==2);
                     Icols = [Icols,Imatch(1)];
                  else
                     Imatch = find(strcmpi(s1.name{n},s2.name)+strcmp(s1.datatype{n},s2.datatype)+strcmpi(s1.units{n},s2.units)==3);
                     Icols = [Icols,Imatch(1)];
                  end
               end

               if length(Icols) == length(s2.name)
                  s2 = copycols(s2,Icols);  %reorder s2 columns to match s1 after matching
               else
                  s2 = [];
               end

               if isempty(s2)
                  cancel = 1;
                  msg = 'merge failed - structures could not be matched';
               else
                  if gce_valid(s1,'data') == 0 || gce_valid(s2,'data') == 0
                     cancel = 1;
                     msg = 'errors occurred synchronizing columns';
                  end
               end

            else

               cancel = 1;
               msg = 'merge failed - no overlapping columns';

            end

         else  %addcols off - throw error

            cancel = 1;
            msg = 'merge failed - different number of columns (addcols option required)';

         end

      end

      if cancel == 0  %perform merge

         %create order placeholders for eval statements
         if order == 1
            s_top = s1;
            s_bot = s2;
            orderstr = 'bottom';
         else
            s_top = s2;
            s_bot = s1;
            orderstr = 'top';
         end

         %force same column order in case not set during matching
         if matchcols == 0
            s_bot = copycols(s_bot,s_top.name,'Y');
            if length(s_bot.name) ~= length(s_top.name)
               s_bot = [];
            end
         end

         if ~isempty(s_bot) && ~isempty(s_top)

            %initialize output structure = s_top
            s = s_top;

            curdate = datestr(now);
            s.editdate = curdate;  %update editdate
            s.history = [s.history ; {curdate} ...
                  {[int2str(length(s2.values{1})) ' rows added at the ' orderstr ' of the data set (''datamerge'')']}];

            %append datafiles, function versions
            s.datafile = [s_top.datafile ; s_bot.datafile];

            %append value array and flag arrays column by column
            vals = cell(1,length(s.name));
            flags = cell(1,length(s.name));
            for n = 1:length(s_top.name)
               vals{n} = [s_top.values{n} ; s_bot.values{n}];
               fl_top = s_top.flags{n};
               fl_bot = s_bot.flags{n};
               if isempty(fl_top) && isempty(fl_bot)
                  flags{n} = '';
               else
                  if isempty(fl_top)
                     fl_top = repmat(' ',length(s_top.values{1}),1);
                  end
                  if isempty(fl_bot)
                     fl_bot = repmat(' ',length(s_bot.values{1}),1);
                  end
                  flags{n} = char(fl_top,fl_bot);
               end
               %check for any manual flags, add manual token to criteria string if not already present to preserve
               manual = length(strfind([s_top.criteria{n},s_bot.criteria{n}],'manual'));
               if manual > 0 && isempty(strfind(s.criteria{n},'manual'))
                  if ~isempty(s_top.criteria{n})
                     s.criteria{n} = [s.criteria{n},';manual'];
                  else
                     s.criteria{n} = 'manual';
                  end
               end
            end
            s.values = vals;
            s.flags = flags;

            newmeta = mergemeta(s1,s2);  %merge metadata

            %redefine title based on original data filenames, clear accession
            titlestr = ['Merged data from ',s1.title,' and ',s2.title];
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

            %clear accession
            I = find(strcmp(newmeta(:,1),'Dataset') & strcmp(newmeta(:,2),'Accession'));
            if isempty(I)
               newmeta = [newmeta ; {'Dataset'},{'Accession'},{''}];
            else
               newmeta{I(1),3} = '';
            end

            if ~isempty(newmeta)
               s = addmeta(s,newmeta);  %update metadata to include new accession
            end

            if fixflags == 0 || calcflags == 1
               s = dataflag(s);  %update flags to reflect merged criteria unless flags locked
            end

            %update study date metadata after successful merge, falling back to original structure on failure
            s_tmp = add_studydates(s);
            if ~isempty(s_tmp)
               s = s_tmp;
            end

         else
            msg = 'errors occurred matching or re-ordering the columns';
         end

      end

   else
      msg = 'one or both data structures are invalid';
   end

end