function [s2,msg] = split_dataseries(s,splitcol,joincols,valcols,maxseries)
%Splits a compound data series based on values in a specified column and serially joins subsets to form a standard table
%containing the specified data columns repeated for each unique split column value
%
%syntax: [s2,msg] = split_dataseries(s,splitcol,joincols,valcols)
%
%inputs:
%  s = data structure to split
%  splitcol = name or index of column to use for splitting the data series (string or integer datatype)
%     (note: if splitcol is numeric, records with NaN values will be excluded from the results!)
%  joincols = name or indices of columns to use to join the split series
%  valcols = name or indices of value columns to include as data columns (repeated for each series, 
%    with series value pre-pended to column names to create names of final columns)
%  maxseries = maximum number of series to split (default = [] for all)
%
%outputs:
%  s2 = modified structure
%  msg = text of any error message
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
%last modified: 26-Feb-2012

s2 = [];
msg = '';

if nargin >= 4
   
   if exist('maxseries','var') ~= 1
      maxseries = [];
   end
   
   if gce_valid(s,'data')
      
      %look up column indices for text column names or force row vector orientation if numeric
      if ~isnumeric(splitcol)
         splitcol = name2col(s,splitcol);
      else
         splitcol = splitcol(:)';
      end
      
      if ~isnumeric(joincols)
         joincols = name2col(s,joincols);
      else
         joincols = joincols(:)';
      end
      
      if ~isnumeric(valcols)
         valcols = name2col(s,valcols);
      else
         valcols = valcols(:)';
      end

      %validate column selections
      if length(splitcol) == 1 && ~isempty(joincols) && ~isempty(valcols)
         
         %look up datatype of split column
         dtype = get_type(s,'datatype',splitcol);
         
         if inlist(dtype,{'s','d'}) == 1
            
            %extract, process split column values
            splitdata = extract(s,splitcol);         
            if iscell(splitdata)
               groups = unique(splitdata);
            else
               groups = unique(splitdata(~isnan(splitdata)));
            end
            
            %validate values in split column
            if length(groups) > 1 && length(groups) < length(splitdata)
               
               %put groups in original occurrence order instead of alphabetical based on first occurrence lookup
               grouporder = zeros(length(groups),1);  %init position array
               if iscell(groups)
                  for n = 1:length(groups)
                     grouporder(n) = min(find(strcmp(splitdata,groups{n})));  %look up string group
                  end
               else
                  for n = 1:length(groups)
                     grouporder(n) = min(find(splitdata == groups(n)));  %look up integer group
                  end
               end
               [tmp,Isort] = sort(grouporder);  %get sort index
               groups = groups(Isort);  %apply sort to group array
               
               %apply series limiter if specified, otherwise default to all series
               if isempty(maxseries)
                  maxseries = length(groups);
               else
                  maxseries = max([maxseries,length(groups)]);
               end
               
               %generate record split query criteria
               crit = repmat({''},maxseries,1);
               prefix = crit;
               if iscell(groups)
                  for n = 1:maxseries
                     crit{n} = ['strcmp(col',int2str(splitcol),',''',groups{n},''')'];
                     prefix{n} = [groups{n},'_'];
                  end
               else
                  for n = 1:maxseries
                     crit{n} = ['col',int2str(splitcol),'=',num2str(groups(n))];
                     prefix{n} = [s.name{splitcol},'_',num2str(groups(n)),'_'];
                  end
               end
               
               %init output structure using first group values
               [s2,rows] = querydata(s,crit{1});

               %clear metadata
               s2.metadata = [];
               
               if rows > 0
                  
                  %init output structure from first query, remove unneeded columns, add column prefix
                  s2 = copycols(s2,[joincols,valcols]);
                  
                  %generate new column index of join cols
                  joincols0 = (1:length(joincols));  
                  
                  %generate new column index of value cols
                  valcols0 = (length(joincols)+1:length(joincols)+length(valcols));
                  for n = 1:length(valcols0)
                     s2.name{valcols0(n)} = [prefix{1},s2.name{valcols0(n)}];  %rename val cols to apply prefix
                  end
                  
                  %loop through remaining queries, join to output
                  for n = 2:maxseries
                     
                     %run query to return records for group value
                     [s_tmp,rows] = querydata(s,crit{n});  

                     if rows > 0
                        
                        %clear metadata for joining
                        s_tmp.metadata = []; 

                        %perform join without metadata merging
                        [s2,msg0] = joindata(s2,s_tmp,joincols0,joincols,'full',valcols0,valcols, ...
                            '',prefix{n},'','key',1,'none');
                         
                        if ~isempty(s2)
                           startcol = length(joincols0) + length(valcols0) + 1;  %determine starting column for new valcols
                           valcols0 = [valcols0,startcol:startcol+length(valcols)-1];  %add new valcols to array
                        else
                           s2 = [];
                           msg = ['errors occurred joining the split structure columns: ',msg0];
                           break
                        end
                        
                     else
                        
                        s2 = [];
                        msg = 'errors occurred splitting the structure on the specified column';
                        break
                        
                     end
                     
                  end
                  
                  if ~isempty(s2)
                     
                     %restore metadata and data file list from original structure
                     s2.metadata = s.metadata;
                     s2.datafile = s.datafile;
                     
                     %update title, edit date, processing history
                     if length(valcols) > 1
                        titlestr = ['Data columns ',cell2commas(s.name(valcols),1),' extracted from ',s.title,', split by values in column ',s.name{splitcol}];
                     else
                        titlestr = ['Data column ',s.name{valcols},' extracted from ',s.title,', split by values in column ',s.name{splitcol}];
                     end
                     if length(joincols) > 1
                        titlestr = [titlestr,' and joined on columns ',cell2commas(s.name(joincols),1)];
                     else
                        titlestr = [titlestr,' and joined on column ',s.name{joincols}];
                     end
                     s2 = newtitle(s2,titlestr);
                     s2.editdate = datestr(now);
                     s2.history = [s.history ; ...
                           {datestr(now)},{['split the data structure based on values in column ',s.name{splitcol}, ...
                                 ', joining each data series on column(s) ',cell2commas(s.name(joincols),1), ...
                                 ' and returning column(s) ',cell2commas(s.name(valcols)),' for each unique value of ', ...
                                 s.name{splitcol},' to create a tabular data set (''split_dataseries'')']}];
                  end
                  
               else
                  msg = 'errors occurred splitting the structure on the specified column';
               end
               
            else
               if length(groups) == 1
                  msg = 'split column must contain multiple unique values';
               else
                  msg = 'no repeated values in split column';
               end
            end
            
         else
            msg = 'unsupported split column datatype';
         end
         
      else
         msg = 'column selections are invalid';
      end
      
   else
      msg = 'invalid data structure';
   end
   
else
   msg = 'insufficient arguments for function';
end