function [s2,msg,flagerrors] = dataflag(s,cols,manual_flags)
%Evaluates Q/C criteria or assigns user-specified flags to generate or update Q/C flag arrays
%for all or specified data columns
%
%syntax:  [s2,msg,flagerrors] = dataflag(s,cols,manual_flags)
%
%inputs:
%  s = data structure to evaluate
%  cols = names or indices of columns to evaluate (default = []/all)
%  manual_flags = array of flags to manually assign (default = [])
%     (note that flags must be a character array the same length as s value arrays)
%
%outputs:
%  s2 = flagged data structure
%  msg = text of any error message
%  flagerrors = array of column numbers for which errors occurred evaluating flags
%     (same information reported by column name in 'msg')
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
%last modified: 10-Feb-2012

%initialize output parameters
msg = '';
s2 = [];
flagerrors = [];

if nargin >= 1
   
   if gce_valid(s,'data')
      
      %validate cols input
      if exist('cols','var') ~= 1
         cols = (1:length(s.name));  %default to all columns
      elseif ~isnumeric(cols)
         cols = name2col(s,cols);  %look up column indices for names
      end
      
      %check for valid columns to process
      if ~isempty(cols)
         
         %extract flag criteria, enumerate columns, rows
         crit = s.criteria;
         numcol = length(s.name);
         numrows = length(s.values{1});
         f0 = repmat(' ',numrows,1);  %init dummy flag array
         
         %validate manual flag arrays
         if exist('manual_flags','var') ~= 1
            manual_flags = [];
         elseif ~ischar(manual_flags)
            manual_flags = [];
         elseif size(manual_flags,1) ~= numrows
            manual_flags = [];
         end
         
         %lock flags if manual flags specified
         if ~isempty(manual_flags)
            s = flag_locks(s,'lock',cols);
         end
         
         %set GUI mode for progress bar updates for large data sets
         guimode = 0;
         if numrows > 30000
            if ~isempty(findobj('Tag','dlgDSEditor'))
               guimode = 1;
               ui_progressbar('init',length(cols)+1,'Evaluating Q/C Criteria ...');
            end
         end
         
         %initialize flag variables
         flags = s.flags;  %init with existing flags
         
         %generate column reference substitution matrix (for resolving column refs to dataset column pointers)
         colname_subs = [concatcellcols([repmat({'col'},numcol,1),s.name'],'_'), ...
            concatcellcols([repmat({'s.values{'},numcol,1),strrep(cellstr(int2str((1:numcol)')),' ',''),repmat({'}'},numcol,1)],'')];
         len = cellfun('length',colname_subs(:,1));  %get column name lengths
         [tmp,Isort] = sort(len);  %sort length array, get index
         colname_subs = colname_subs(flipud(Isort),:);  %sort match matrix in reverse length order to prevent substring matches
         
         %evaluate criteria for specified columns
         for cnt = 1:length(cols)
            
            col = cols(cnt);  %set column pointer
            critstr = crit{col};  %extract q/c criteria for column
            
            if guimode == 1; ui_progressbar('update',cnt,['Evaluating Q/C criteria (column ',int2str(col),')']); end
            
            if isempty(strfind(critstr,'manual')) || ~isempty(manual_flags)  %check for manual token (locked flags)
               
               if isempty(critstr)  %check for null criteria
                  
                  %apply manual flags or clear flags if none specified
                  if ~isempty(manual_flags)
                     flags(col) = {manual_flags};
                  else
                     flags(col) = {''};  %null criteria - clear any residual flags
                  end
                  
               else  %evaluate criteria
                  
                  %check for security issues with rules
                  if isempty(manual_flags)
                     %perform security checks for system calls - abort rule evaluation for column if any found
                     critstr2 = lower(strrep(critstr,' ',''));  %strip blanks, convert to lower case for string search
                     securitycheck = 1;  %init flag
                     if ~isempty(strfind(critstr2,'system(')) || ~isempty(strfind(critstr2,'dos(')) || ...
                           ~isempty(strfind(critstr2,'unix(')) || ~isempty(strfind(critstr2,'!'))
                        securitycheck = 0;  %system call found - flag as invalid
                     end
                  else
                     securitycheck = 1;
                  end
                  
                  if securitycheck == 0
                     
                     flagerrors = [flagerrors,col];  %do not revise flags, add column to flag error array
                     
                  else  %proceed with flag evaluation
                     
                     if isempty(manual_flags)
                        
                        %substitute column placeholders in criteria strings with value array references
                        if ~isempty(strfind(critstr,'col_'))
                           for m = 1:size(colname_subs,1)
                              critstr = strrep(critstr,colname_subs{m,1},colname_subs{m,2});  %substitute array ref
                           end
                           crit{col} = critstr;  %update cached criteria for column
                        end
                        
                        x = s.values{col};   %assign column values to 'x' for alias references
                        
                        %parse criteria into array (omitting any empty criteria and terminal whitespace)
                        allcrit = splitstr(crit{col},';',1,1);
                        
                        %init empty flag array
                        f_all2 = repmat(f0,1,length(allcrit));  %init empty final flag array
                        f_all = f_all2;
                        
                        %evaluate criteria and generate flags
                        for n = 1:length(allcrit)
                           
                           %set loop runtime variables
                           flagcrit = allcrit{n};  %get criteria expression from array
                           Ieq = find(flagcrit == '=');  %get index of equal signs
                           len = length(Ieq);  %get number of equal signs in expression
                           f = f0;  %initialize character array for flags
                           
                           if len > 0  %check for valid assignment format
                              
                              %reformat flag criteria as f(condition)='flag'
                              evalstr = ['f(',flagcrit(1,1:max(Ieq(len)-1,1)),')',flagcrit(1,Ieq(len):length(flagcrit)),';'];
                              
                              %evaluate expression to assign flags, trapping errors and adding to error array
                              try
                                 eval(evalstr)
                              catch
                                 f = [];
                                 flagerrors = [flagerrors,col];
                              end
                              
                              %add flags to cumulative character array
                              if ~isempty(f)
                                 f_all(:,n) = f;
                              end
                              
                           end
                           
                        end
                        
                     else  %add manual flags
                        
                        f_all = flags{col};  %get existing flag array
                        
                        %append manual flags if other flags present, otherwise just use manual flags
                        if isempty(f_all)
                           f_all = manual_flags;
                        else
                           f_all = [f_all,manual_flags];
                        end
                        
                        f_all2 = repmat(f0,1,size(f_all,2));  %init master flag array
                        
                     end
                     
                     wid = size(f_all,2); %get width of flag character array
                     
                     %get index of non-empty rows
                     Ivalid = zeros(numrows,wid);
                     for m = 1:wid
                        Ivalid(:,m) = f_all(:,m)~=' ';  %add index of non-empty flags to master index
                     end
                     
                     %create logical index of non-empty rows from Ivalid
                     if wid > 1
                        I_fl = find(sum(Ivalid')>0)';
                     else
                        I_fl = find(Ivalid>0);
                     end
                     
                     if ~isempty(I_fl)  %check for non-empty rows
                        
                        %compress flags by aligning characters to the left in the character array
                        for n = 1:length(I_fl)
                           ptr = I_fl(n);  %set row index pointer
                           Itmp = find(Ivalid(ptr,:));  %get index of non-blank flags
                           f_all2(ptr,1:length(Itmp)) = f_all(ptr,Itmp);  %assign non-blank flags to leftmost cols of f_all2
                        end
                        
                        %trim blank columns, starting from right and breaking when hit assigned flags
                        c = 1:wid;  %init index of valid columns to keep
                        for m = wid:-1:1
                           Ivalid2 = find(f_all2(:,m)~=' ');  %check for assigned flags
                           if isempty(Ivalid2)
                              c(m) = NaN;  %mark column for deletion
                           else
                              break
                           end
                        end
                        c = c(~isnan(c));  %remove columns marked for deletion
                        
                        %store trimmed char array of flags in cell array
                        if ~isempty(c)
                           flags(col) = {f_all2(:,c)};  %add non-empty flag columns from master flag array to data structure
                        else
                           flags(col) = {''};  %no flags after coalesce
                        end
                        
                     else  %no flags assigned
                        flags(col) = {''};
                     end
                     
                  end
                  
               end
               
            end
            
         end
         
         if guimode == 1; ui_progressbar('close'); end
         
         %format flag errors as message string
         if ~isempty(flagerrors)
            flagerrors = unique(flagerrors);  %remove duplicate error messages for multiple bad rules in 1 col
            msg = ['Errors occurred evaluating flag criteria for column(s): ', ...
               cell2commas(s.name(flagerrors),1)];
         end
         
         %generate output structure
         s2 = s;  %init output
         s2.flags = flags;  %update flag arrays
         
         %update edit date, processing history
         curdate = datestr(now);
         s2.editdate = curdate;
         if length(cols) == length(s.name)
            if isempty(manual_flags)
               hist_str = 'Q/C flagging criteria applied, ''flags'' field updated (''dataflag'')';
            else
               hist_str = 'User-specified flags assigned to all columns, ''flags'' field updated (''dataflag'')';
            end
         else
            if isempty(manual_flags)
               hist_str = ['Q/C flagging criteria applied for column(s) ',cell2commas(s2.name(cols),1), ...
                  ', ''flags'' field updated (''dataflag'')'];
            else
               hist_str = ['User-specified flags assigned for column(s) ',cell2commas(s2.name(cols),1), ...
                  ', ''flags'' field updated (''dataflag'')'];
            end
         end
         s2.history = [s.history ; {curdate},{hist_str}];
         
      else
         msg = 'invalid column selections';
      end
      
   else
      msg = 'invalid data structure';
   end
   
else
   msg = 'insufficient arguments for function';
end