function [s2,msg] = nullflags(s,flagchars,cols,metaopt,clearflags,newflag,logsize)
%Converts values in a GCE Data Structure assigned specified flags to NaN/empty
%
%syntax:  [s2,msg] = nullflags(s,flagchars,cols,metaopt,clearflags,newflag,logsize)
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
%  clearflags = option to clear flag assignments for nulled values
%    0 = no
%    1 = yes (default)
%  newflag = new flag character to assign for any nulled values, overwriting other flags if present
%    '' = none - retain existing flag(s) (default)
%    character scalar = character to assign (e.g. 'R'; ignored if clearflags == 1)
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
%  3) if clearflags = 1 then newflag will be ignored
%  4) if clearflags = 0 then flags for affected columns will be locked to prevent over-writing
%  5) if cols is specified and no columns are matched, the original structure will
%     be returned with a warning in msg
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

%check for required arguments
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
      
      if exist('clearflags','var') ~= 1 || ~isnumeric(clearflags) || clearflags ~= 0
         clearflags = 1;
      end
      
      if exist('newflag','var') ~= 1 || ~ischar(newflag)
         newflag = '';
      elseif length(newflag) > 1
         newflag = newflag(1);  %restrict to single character
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

      %check for valid column selections
      if ~isempty(cols)
         
         %assign input structure to output and init change log
         s2 = s;
         log = [];
         
         %check for any assigned flags before proceding (i.e. non-empty flags field for column)
         Iflags = find(~cellfun('isempty',s2.flags(cols)));
         
         if ~isempty(Iflags)
            
            %loop through specified columns with assigned flags
            for n = 1:length(Iflags)

               col = cols(Iflags(n));  %set column pointer
               
               f = s2.flags{col};  %get flag column
               
               if ~isempty(f)
                  
                  if isempty(flagchars)  %any flags
                     
                     I_fl = find(f(:,1)~=' ');
                     if clearflags == 1
                        s2.flags{col} = '';  %clear flags
                     end
                     
                  else  %specific flags
                     
                     I_fl = zeros(size(f,1),1);
                     I_resid = zeros(1,size(f,2));
                     flagcols = size(f,2);
                     
                     %analyze each column of flag chars for matches
                     for m = 1:flagcols
                        for o = 1:length(flagchars)
                           I1 = (f(:,m)==flagchars(o));
                           I2 = find(I1);
                           if ~isempty(I2)
                              I_fl = I_fl + I1;
                              if clearflags == 1
                                 %clear all flags for matching records
                                 f(I2,1:flagcols) = repmat(' ',length(I2),flagcols);
                              elseif ~isempty(newflag)
                                 %replace existing flags with newflag
                                 f(I2,1:flagcols) = [repmat(newflag,length(I2),1) repmat(' ',length(I2),flagcols-1)];
                              end
                           end
                        end
                     end
                     
                     %check for residual flags if flags cleared
                     for m = 1:flagcols
                        if ~isempty(find(f(:,m)~=' '))
                           I_resid(m) = 1;
                        end
                     end
                     
                     %update flag columns
                     I_fl = find(I_fl);
                     I_resid = find(I_resid);
                     if isempty(I_resid)
                        s2.flags{col} = '';
                     elseif length(I_resid) < size(f,2)
                        s2.flags{col} = f(:,I_resid);
                     else
                        s2.flags{col} = f;
                     end
                     
                  end

                  %check for matched flags to null
                  if ~isempty(I_fl)

                     %lock flags for column if not cleared
                     if clearflags == 0
                        crit = s2.criteria{col};
                        if isempty(strfind(crit,'manual'))
                           if isempty(crit)
                              crit = 'manual';
                           else
                              crit = [crit,';manual'];
                           end
                           s2.criteria{col} = crit;  %update criteria to lock flags
                        end
                     end
                     
                     %get column data
                     colvals = s2.values{col};

                     %nullify values
                     coltype = s2.datatype{col};  %get column data type
                     if strcmp(coltype,'s')
                        colvals(I_fl) = {''};
                     else
                        colvals(I_fl) = NaN;
                     end

                     %update value matrix
                     s2.values{col} = colvals;

                     %log changes in processing history
                     if length(I_fl) > logsize
                        log = [log ; {[int2str(length(I_fl)),' records in ',s2.name{col}]}];
                     else
                        log = [log ; {[s2.name{col},' record(s) ',cell2commas(strrep(cellstr(int2str(I_fl)),' ',''),1)]}];
                     end

                  end

               end

            end

            %check for value substitutions and build log entries
            if ~isempty(log)

               %generate column listing
               if length(cols) == length(s2.name)
                  colstr = 'all columns';
               else
                  colstr = ['column(s) ',cell2commas(s2.name(cols),1)];
               end

               %build history based on clearflags and flag character options
               if clearflags == 1
                  if isempty(flagchars)
                     flagstr = ['converted values in ',colstr,' assigned any QA/QC flag to NaN/empty: ',cell2commas(log)];
                  else
                     flagdefs = get_flagdefs(s2,flagchars);
                     flagstr = ['converted values in ',colstr,' assigned QA/QC flag(s) ',flagdefs,' to NaN/empty: ',cell2commas(log)];
                  end
               else
                  %check for flag replacment option
                  if isempty(newflag)
                     if isempty(flagchars)
                        flagstr = ['converted values in ',colstr,' assigned any QA/QC flag to NaN/empty, retaining and locking existing flags: ', ...
                           cell2commas(log)];
                     else
                        flagdefs = get_flagdefs(s2,flagchars);
                        flagstr = ['converted values in ',colstr,' assigned QA/QC flag(s) ',flagdefs, ...
                           ' to NaN/empty, retaining and locking existing flags: ',cell2commas(log)];
                     end
                  else  %replaced
                     if isempty(flagchars)
                        flagstr = ['converted values in ',colstr,' assigned any QA/QC flag to NaN/empty, locking and replacing existing flags with ''', ...
                           newflag,''': ',cell2commas(log)];
                     else
                        flagdefs = get_flagdefs(s2,flagchars);
                        flagstr = ['converted values in ',colstr,' assigned QA/QC flag(s) ',flagdefs, ...
                           ' to NaN/empty, locking and replacing existing flags with ''',newflag,''': ',cell2commas(log)];
                     end
                  end
               end

               %add operation to anomaly section of metadata if specified
               if metaopt == 1
                  meta = lookupmeta(s2,'Data','Anomalies');
                  meta = strrep(meta,'none noted','');
                  if ~isempty(meta)
                     metastr = [meta,' ',upper(flagstr(1)),flagstr(2:end),'.'];
                  else
                     metastr = [upper(flagstr(1)),flagstr(2:end),'.'];
                  end
                  s2 = addmeta(s2,{'Data','Anomalies',metastr});
               end

               %update editdate, history
               curdate = datestr(now);
               s2.editdate = curdate;
               s2.history = [s.history ; {curdate} {[flagstr,' (''nullflags'')']}];

            else
               msg = 'no values met the specified criteria (operation cancelled)';
            end

         else
            msg = 'no flags are assigned in the selected columns (operation cancelled)';
         end

      else  %no valid columns
         %return original structure and warning message
         s2 = s;  
         msg = 'invalid column selection';
      end

   else
      msg = 'not a valid data structure';
   end

else
   msg = 'insufficient arguments for function';
end
