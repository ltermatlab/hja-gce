function [s2,msg] = cullflags(s,flagchars,cols,metaopt,logsize)
%Deletes all records from a GCE Data Structure containing any values assigned specified flags
%
%syntax:  [s2,msg] = cullflags(s,flagchars,cols,metaopt,logsize)
%
%inputs:
%  s = structure to modify
%  flagchars = flag characters to match
%    '' = any (default)
%    character array = array of specific flag characters to match (e.g. 'I' or 'IQ')
%  cols = list of columns to evaluate
%    [] = all columns
%    numeric or cell array = array of specific column index numbers or names (e.g. {'Salinity','Temperature'})
%  metaopt = option to log deletions to the Data|Anomalies field of the structure metadata
%    0 = no (default)
%    1 = yes
%  logsize = number of individual value changes to log in the processing history metadata
%    0 = none (summarize changes per column)
%    n = log n individual changes and summarize if > n values affected (default = 100)
%    inf = log all individual changes
%
%output:
%  s2 = modified structure
%  msg = text of any error message
%
%usage notes:
%  1) if no values are affected, the unmodified structure will be returned without error
%  2) if multiple flag characters are specified, each will be matched independently
%  3) if cols is specified and no columns are matched, the original structure will
%     be returned with a warning in msg
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
%last modified: 12-Sep-2014

%init output
s2 = [];
msg = '';

%check for required argument
if nargin >= 1

   if gce_valid(s,'data')

      %supply defaults for missing arguments
      if exist('metaopt','var') ~= 1 || metaopt ~= 1
         metaopt = 0;
      end

      if exist('flagchars','var') ~= 1
         flagchars = '';
      elseif iscell(flagchars)
         flagchars = concatcellcols(flagchars(:)','');  %convert cell array of flags to character array
      elseif ~ischar(flagchars)
         flagchars = '';
      end
            
      if exist('logsize','var') ~= 1 || ~isnumeric(logsize)
         logsize = 100;
      elseif logsize < 0
         logsize = 0;
      end
      
      %validate column selections
      if exist('cols','var') ~= 1
         cols = [];
      end
      if isempty(cols)
         cols = (1:length(s.name));  %default to all
      elseif ~isnumeric(cols)
         cols = name2col(s,cols);  %look up column names
      else
         cols = intersect(cols(:),(1:length(s.name)));  %remove any invalid column selections
      end

      %check for valid column selection
      if ~isempty(cols)

         %init output structure
         s2 = s;

         %build default index (no rows removed)
         Imaster = zeros(length(s2.values{1}),1);

         %loop through columns
         for n = 1:length(cols)

            f = s2.flags{cols(n)};  %get flag column

            if ~isempty(f)

               if isempty(flagchars)  %any flags
                  
                  I_fl = find(f(:,1)~=' ');  %get index of non-empty flag arrays based on charcter in first column
                  s2.flags{cols(n)} = '';  %clear flags for column
                  
               else  %specific flags
                  
                  %init runtime variables
                  I_fl = zeros(size(f,1),1);     %index of matched falgs
                  I_resid = zeros(1,size(f,2));  %index of residual flags
                  flagcols = size(f,2);          %number of flag columns
                  
                  %analyze each column of flag chars for matches
                  for m = 1:flagcols
                     for o = 1:length(flagchars)
                        I1 = (f(:,m)==flagchars(o));  %index of matched flags
                        I2 = find(I1);                %pointers for matched flags
                        if ~isempty(I2)
                           I_fl = I_fl + I1;          %add match index to master index
                           f(I2,1:flagcols) = repmat(' ',length(I2),flagcols);  %clear all flags for matched records
                        end
                     end
                  end
                  
                  %check for residual flags
                  for m = 1:flagcols
                     if ~isempty(find(f(:,m)~=' '))
                        I_resid(m) = 1;
                     end                        
                  end
                  
                  %update flag columns
                  I_fl = find(I_fl);         %get final index of matched flags
                  I_resid = find(I_resid);   %get final index of residual flags
                  if isempty(I_resid)
                     s2.flags{cols(n)} = '';   %no residual flag - clear all
                  elseif length(I_resid) < size(f,2)
                     s2.flags{cols(n)} = f(:,I_resid);  %existing flags array wider than residual flags array - update slice
                  else
                     s2.flags{cols(n)} = f;  %residual flags array matches existing array - replace
                  end
                  
               end
               
               %update master flag match index
               if ~isempty(I_fl)
                  Imaster(I_fl) = 1;
               end

            end

         end

         %init master indices for flagged
         I_flagged = find(Imaster);

         %check for matched flags
         if ~isempty(I_flagged)

            %delete rows using external function (note that log option is irrelevant)
            s2 = deleterows(s2,I_flagged');  

            if ~isempty(s2)

               %generate column descriptions for metadata
               if length(cols) == length(s2.name)
                  colstr = 'any column';
               else
                  colstr = ['column(s) ',cell2commas(s2.name(cols),2)];
               end

               %generate flag charcter list for metadata
               if isempty(flagchars)
                  flagstr = 'any QA/QC flag';
               else
                  flagdefs = get_flagdefs(s2,flagchars);
                  flagstr = ['QA/QC flag(s) ',flagdefs];
               end

               %get formatted date
               curdate = datestr(now);

               %generate processing history, metadata strings
               if length(I_flagged) > logsize
                  metastr = ['deleted ',int2str(length(I_flagged)),' rows with values in ', ...
                        colstr,' assigned ',flagstr,'.'];
               else
                  metastr = ['deleted the following rows with values in ', ...
                        colstr,' assigned ',flagstr,': ', ...
                        cell2commas(strrep(cellstr(int2str(I_flagged)),' ',''),1),'.'];
               end
               histstr = [metastr,' (''cullflags'')'];

               %update anomalies metadata if specified
               if metaopt == 1
                  meta = lookupmeta(s,'Data','Anomalies');
                  meta = strrep(meta,'none noted','');
                  if ~isempty(meta)
                     metastr = [meta,' ',metastr];
                  end
                  s2 = addmeta(s2,{'Data','Anomalies',[upper(metastr(1)),metastr(2:end)]},1);
               end

               %update edit date, add history entry
               s2.editdate = curdate;
               s2.history = [s.history ; {curdate} {histstr}];
               
            else
               msg = 'all data rows were removed';
            end

         else
            msg = 'no values matched the specified criteria (0 rows deleted)';
         end

      else   %no cols
         %return original structure and a warning
         s2 = s;
         msg = 'invalid column selection';
      end

   else
      msg = 'invalid data structure';
   end

else
   msg = 'insufficient arguments for function';
end
