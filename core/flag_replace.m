function [s2,msg] = flag_replace(s,cols,oldstring,newstring,matchtype,caseopt)
%Performs string replacement for flags of one or more columns in a GCE Data Structure
%(note that partial string searches use regular expression matching, so regex
%patterns expressions can be used)
%
%syntax: [s2,msg] = flag_replace(s,cols,oldstring,newstring,matchtype,caseopt)
%
%input:
%  s = data structure to modify
%  cols = name or indices of columns to modify
%  oldstring = string, substring, or regex pattern to match
%  newstring = string to substitute for oldstring
%  matchtype = string match option:
%    'full' = match only complete strings in target columns
%    'partial' = match partial strings (default)
%  caseopt = case sensitive option
%    'sensitive' = case-sensivie match (default)
%    'insensitive' = case-insensitive match
%
%output:
%  s2 = updated structure
%  msg = text of any error message
%
%
%(c)2010-2011 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 19-Oct-2011

s2 = [];
msg = '';

if nargin >= 4 && gce_valid(s,'data')
   
   if ~isempty(oldstring)
      
      %supply defaults for omitted arguments and validate
      if exist('matchtype','var') ~= 1
         matchtype = 'partial';
      elseif ~strcmpi(matchtype,'full')
         matchtype = 'partial';
      end
      
      if exist('caseopt','var') ~= 1
         caseopt = 'sensitive';
      elseif ~strcmpi(caseopt,'insensitive')
         caseopt = 'sensitive';
      end
      
      %set matchcase flag
      if strcmpi(caseopt,'insensitive')
         matchcase = 0;
      else
         matchcase = 1;
      end
      
      %get index of column names
      if ~isnumeric(cols)
         cols = name2col(s,cols);
      end
      
      if ~isempty(cols)
         
         %get index of columns with flag assignments
         Iflag = find(~cellfun('isempty',s.flags(cols)));
         
         %init index of bad columns with any non-string cols
         Ibad = setdiff(cols,cols(Iflag));
         badcols = zeros(1,length(cols));
         badcols(Ibad) = 1;
         
         %check for valid columns to process
         if ~isempty(Iflag)
            
            s2 = s;  %init output
            
            %add provisional history entry prior to substitutions
            s2.history = [s2.history ; ...
               {datestr(now)},{['replaced ''',oldstring,''' flags in column(s) ',cell2commas(s2.name(cols),1), ...
               ' with ''',newstring,''' flags, performing a ',matchtype,' case-',caseopt,' match (''string_replace'')']}];

            updates = 0;  %init change counter
            
            for n = 1:length(Iflag)
               
               col = cols(Iflag(n));  %get column index
               flags = cellstr(s.flags{col});  %extract string data column
               newflags = [];  %init new values

               if strcmp(matchtype,'full')
                  if matchcase == 1
                     Imatch = strcmp(flags,oldstring);
                  else
                     Imatch = strcmpi(flags,oldstring);
                  end
                  Imatch = find(Imatch);
                  if ~isempty(Imatch)
                     newflags = flags;
                     newflags(Imatch) = {newstring};
                  end
               else  %partial match using regex
                  try
                     if matchcase == 1
                        newflags = regexprep(flags,oldstring,newstring);
                     else
                        newflags = regexprep(flags,oldstring,newstring,'ignorecase');
                     end
                     %force empty string to prevent buggy regex implementation in MATLAB 6.5
                     newflags(cellfun('isempty',newflags)) = {''};
                  catch
                     badcols(cols(Iflag(n))) = 1;  %add column to bad column list
                  end
               end
               
               %check for substitutions, apply updates
               if ~isempty(newflags) && length(newflags) == length(flags)
                  updates = updates + 1;  %increment updates counter
                  try
                     s2.flags{col} = char(newflags);  %apply updates and log changes
                     s2 = flag_locks(s2,'lock',col);  %lock flags to prevent automatic re-evaluation
                  catch
                     s2 = [];
                     msg0 = 'invalid flag array';
                  end
                  if isempty(s2)
                     msg = ['an error occurred updating flags for column ',int2str(col),': ',msg0];
                     break
                  end
               end
               
            end
                        
            %check for updates and errors
            if ~isempty(s2)
               
               if updates == 0
                  
                  %revert changes to history entry if no replacements made
                  s2 = s;
                  
               elseif length(newstring) == 1
                  
                  %check for corresponding flag definition in metadata and add if not found
                  flagcodes = lookupmeta(s2,'Data','Codes');
                  newcodes = '';
                  flag = newstring;
                  
                  if isempty(flagcodes)
                     newcodes = [flag,' = undefined'];
                  else
                     ar = splitstr(flagcodes,',');
                     Iflag = find(strncmp([flag,' ='],ar,length(flag)+2));
                     if isempty(Iflag)
                        newcodes = [flagcodes,', ',flag,' = undefined'];
                     end
                  end
                  if ~isempty(newcodes)
                     %add new code definition to metadata
                     s2 = addmeta(s2,{'Data','Codes',newcodes},0,'update_data');
                  end                  
               end
                              
            end
            
         end
         
      else
         msg = 'invalid column selections';
      end
      
   else
      msg = 'oldstring cannot be blank';   
   end
   
else
   if nargin < 4
      msg = 'insufficient arguments for function';
   else
      msg = 'invalid data structure';
   end
end