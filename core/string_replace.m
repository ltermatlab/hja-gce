function [s2,msg] = string_replace(s,cols,oldstring,newstring,matchtype,caseopt,flag,logopt)
%Performs string replacement on one or more text columns in a GCE Data Structure
%(note that partial string searches use regular expression matching, so regex
%patterns expressions can be used)
%
%syntax: [s2,msg] = string_replace(s,cols,oldstring,newstring,matchtype,caseopt,flag,logopt)
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
%  flag = Q/C flag to assign for revised values (default = '' for none)
%  logopt = number of value replacements to log (default = 50)
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
      
      %assign default flag option
      if exist('flag','var') ~= 1
         flag = '';
      end
      
      %assign default logging option
      if exist('logopt','var') ~= 1
         logopt = 50;
      end
      
      %get index of column names
      if ~isnumeric(cols)
         cols = name2col(s,cols);
      end
      
      if ~isempty(cols)
         
         %get index of string columns
         Istr = find(strcmp(s.datatype(cols),'s'));
         
         %init index of bad columns with any non-string cols
         Ibad = setdiff(cols,cols(Istr));
         badcols = zeros(1,length(cols));
         badcols(Ibad) = 1;
         
         %check for valid columns to process
         if ~isempty(Istr)
            
            s2 = s;  %init output
            
            %add provisional history entry prior to substitutions
            s2.history = [s2.history ; ...
               {datestr(now)},{['replaced values of ''',oldstring,''' in column(s) ',cell2commas(s2.name(cols),1), ...
               ' with ''',newstring,''', performing a ',matchtype,' case-',caseopt,' match (''string_replace'')']}];

            updates = 0;  %init change counter
            
            for n = 1:length(Istr)
               
               col = cols(Istr(n));  %get column index
               vals = extract(s,col);  %extract string data column
               newvals = [];  %init new values
               Imatch = [];  %init match index

               if strcmp(matchtype,'full')
                  if matchcase == 1
                     Imatch = strcmp(vals,oldstring);
                  else
                     Imatch = strcmpi(vals,oldstring);
                  end
                  Imatch = find(Imatch);
                  if ~isempty(Imatch)
                     newvals = vals;
                     newvals(Imatch) = {newstring};
                  end
               else  %partial match using regex
                  if isempty(flag)
                     try
                        if matchcase == 1
                           newvals = regexprep(vals,oldstring,newstring);
                        else
                           newvals = regexprep(vals,oldstring,newstring,'ignorecase');
                        end
                        %force empty string to prevent buggy regex implementation in MATLAB 6.5
                        newvals(cellfun('isempty',newvals)) = {''};
                     catch
                        badcols(cols(Istr(n))) = 1;  %add column to bad column list
                     end
                  else
                     %get match index first for flag assignment before replacing text
                     try
                        if matchcase == 1
                           Imatch0 = regexp(vals,oldstring);
                           Imatch = find(~cellfun('isempty',Imatch0));
                           if ~isempty(Imatch)
                              newvals = regexprep(vals,oldstring,newstring);
                           end
                        else
                           Imatch0 = regexpi(vals,oldstring);
                           Imatch = find(~cellfun('isempty',Imatch0));
                           if ~isempty(Imatch)
                              newvals = regexprep(vals,oldstring,newstring,'ignorecase');
                           end
                        end
                     catch
                        badcols(cols(Istr(n))) = 1;  %add column to bad column list
                     end
                  end
               end
               
               %check for substitutions, apply updates
               if ~isempty(newvals) && length(newvals) == length(vals)
                  updates = updates + 1;  %increment updates counter
                  [s2,msg0] = update_data(s2,col,newvals,logopt);  %apply updates and log changes
                  if isempty(s2)
                     msg = ['an error occurred updating values for column ',int2str(col),': ',msg0];
                     break
                  elseif ~isempty(flag) && ~isempty(Imatch)
                     s2 = addflags(s2,col,Imatch,flag);  %flag updated strings if specified
                  end
               end
               
            end
                        
            %check for updates and errors
            if ~isempty(s2)
               
               if updates == 0
                  s2 = s;  %revert changes to history entry
               end
               
               Ibadcols = find(badcols);  %get index of any bad columns
               if ~isempty(Ibadcols)
                  msg = ['errors occurred performing string replacements for column(s) ',cell2commas(s2.name(Ibadcols),1)];
               end
               
            end
            
         else
            msg = 'this function requires string type columns';
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