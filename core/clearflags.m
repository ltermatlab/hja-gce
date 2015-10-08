function [s2,msg] = clearflags(s,flagchars,cols,lockopt,metaopt)
%Clears specified flags from a GCE Data Structure for display or export purposes
%
%syntax:  [s2,msg] = clearflags(s,flagchars,cols,lockopt,metaopt)
%
%inputs:
%  s = structure to modify
%  flags = flags to replace
%  cols = array of column names or numbers to process (default = all)
%  lockopt = options to lock or unlock flag criteria for affected columns after clearing flags
%    0 = no change  (note that flags will not be unlocked if already locked by another operation)
%    1 = lock flags (default)
%    2 = unlock flags to restore automatic calculation
%  metaopt = option to log cleared flags to the Data|Anomalies field of the structure metadata
%    0 = no
%    1 = yes (default)
%
%output:
%  s2 = modified structure
%  msg = text of any error message
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
%last modified: 25-May-2011

s2 = [];
msg = '';

if nargin >= 2

   if gce_valid(s,'data') == 1 && ischar(flagchars)

      %apply defaults for omitted/invalid options
      if exist('lockopt','var') ~= 1
         lockopt = 1;
      elseif lockopt ~= 0 && lockopt ~= 2
         lockopt = 1;
      end
      
      if exist('metaopt','var') ~= 1
         metaopt = 1;
      elseif metaopt ~= 0
         metaopt = 1;
      end

      %validate column selections
      if exist('cols','var') ~= 1
         cols = [];
      end
      if isempty(cols)
         cols = (1:length(s.name));  %default to all
      elseif ~isnumeric(cols)
         cols = name2col(s,cols);  %look up column names
      end

      if ~isempty(cols)

         s2 = s;  %assign input structure to output
         log = [];

         %check for any assigned flags
         Iflags = find(~cellfun('isempty',s2.flags(cols)));
         
         if ~isempty(Iflags)

            for n = 1:length(Iflags)  %loop through columns with assigned flags

               col = cols(Iflags(n));  %resolve column pointer
               
               f = s2.flags{col};  %get flags

               if ~isempty(f)
                  
                  I_fl = zeros(size(f,1),1);  %init flag character index 
                  flagcols = size(f,2);  %look up width of flag array
                  I_resid = zeros(1,flagcols);  %init index of residual flags
                  
                  %analyze each column of flag chars for matches
                  for m = 1:flagcols
                     for o = 1:length(flagchars)
                        I1 = (f(:,m)==flagchars(o));
                        I2 = find(I1);
                        if ~isempty(I2)
                           I_fl = I_fl + I1;
                           f(I2,1:flagcols) = repmat(' ',length(I2),flagcols);  %clear all flags for matching records
                        end
                     end
                  end
                  
                  %get index of records with cleared flags
                  I_fl = find(I_fl);
                  
                  %check for cleared flags, perform clean up and logging
                  if ~isempty(I_fl)
                     
                     %check for residual flags
                     for m = 1:flagcols
                        if ~isempty(find(f(:,m)~=' '))
                           I_resid(m) = 1;
                        end                        
                     end
                     
                     %compress residual flags if necessary                  
                     I_resid = find(I_resid);
                     if isempty(I_resid)
                        s2.flags{col} = '';
                     elseif length(I_resid) < size(f,2)
                        s2.flags{col} = f(:,I_resid);
                     else
                        s2.flags{col} = f;
                     end
                     
                     %lock/unlock flags if specified
                     if lockopt ~= 0
                        crit = s2.criteria{col};
                        if lockopt == 1
                           if isempty(strfind(crit,'manual'))
                              if isempty(crit)
                                 crit = 'manual';
                              else
                                 crit = [crit,';manual'];  %append
                              end
                           end
                        else
                           if ~isempty(strfind(crit,'manual'))
                              crit = strrep(strrep(crit,'manual',''),';;',';');  %remove manual token and redundant semicolons
                              if ~isempty(crit)
                                 if strcmp(crit(end),';')
                                    crit = crit(1:end-1);  %remove terminal semicolon
                                 end
                              end
                           end
                        end
                        s2.criteria{col} = crit;
                     end
                     
                     %log flag clearing
                     if length(I_fl) > 100
                        log = [log ; {[int2str(length(I_fl)),' records in ',s2.name{col}]}];
                     else
                        log = [log ; {[s2.name{col},' record(s) ',cell2commas(strrep(cellstr(int2str(I_fl)),' ',''),1)]}];
                     end

                  end

               end

            end

            %update processing history, metadata if operations performed
            if ~isempty(log)

               %generate context-appropriate entries for history
               if length(cols) == length(s2.name)
                  colstr = 'all columns';
               else
                  colstr = ['column(s) ',cell2commas(s2.name(cols),1)];
               end
               
               if lockopt == 1
                  lockstr = ' and locked flags to prevent automatic recalculation';
               else
                  if lockopt == 2
                     lockstr = ' and unlocked flags to restore automatic recalculation';
                  else
                     lockstr = '';
                  end
               end

               flagdefs = get_flagdefs(s2,flagchars);
               str_update = ['cleared assignments of QA/QC flag(s) ',flagdefs,' for ',colstr,lockstr,': ',cell2commas(log)];

               if metaopt == 1
                  meta = lookupmeta(s2,'Data','Anomalies');
                  meta = strrep(meta,'none noted','');
                  if ~isempty(meta)
                     metastr = [meta,' ',upper(str_update(1)),str_update(2:end),'.'];
                  else
                     metastr = [upper(str_update(1)),str_update(2:end),'.'];
                  end
                  s2 = addmeta(s2,{'Data','Anomalies',metastr});
               end

               curdate = datestr(now);

               %update editdate, history
               s2.editdate = curdate;
               s2.history = [s.history ; {curdate} {[str_update,' (''clearflags'')']}];
               
               if lockopt ~= 1
                  s2 = dataflag(s2,cols);  %refresh flags if not locked
               end


            end

         end

      else
         msg = 'invalid column specification';
      end

   else
      if ~ischar(flagchars)
         msg = 'invalid flag character array';
      else
         msg = 'not a valid data structure';
      end
   end

else
   msg = 'insufficient arguments for function';
end
