function [s2,msg] = flags2cols_selected(s,flags,cols,encode,emptycols,prefix)
%Converts selected Q/C flag information in specified columns of a GCE Data Structure to coded string columns
%and documents the code values in the metadata
%
%syntax: [s2,msg] = flags2cols_selected(s,flags,cols,encode,emptycols,prefix)
%
%inputs:
%  s = the data structure to modify
%  flags = Q/C flags to convert (character array of flag codes; default = '' for any)
%  cols = array of column names or index numbers to convert (default = [] for all)
%  encode = option to encode the first flag instance per data value as an integer code:
%     0 = do not encode (default)
%     1 = encode flags (with 0 = no flag)
%  emptycols = option to include empty columns when no matching flags are assigned:
%     0 = omit empty columns (default)
%     1 = include empty columns
%  prefix = prefix to add to column name to denote flag column (string, default = 'Flag_')
%
%output:
%  s2 = the resultant structure
%  msg = text of any error messages
%
%
%(c)2011-2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 15-May-2013

s2 = [];
msg = '';

if nargin >= 1
   
   %default to all flags
   if exist('flags','var') ~= 1
      flags = '';
   end
   
   %default to all columns
   if exist('cols','var') ~= 1
      cols = [];
   end
   
   %default to not encoding flags as integers
   if exist('encode','var') ~= 1
      encode = 0;
   elseif ~isnumeric(encode) || encode ~= 1
      encode = 0;
   end
   
   %default to not including columns with no flags assigned
   if exist('emptycols','var') ~= 1
      emptycols = 0;
   elseif emptycols ~= 1
      emptycols = 0;
   end
   
   %assign default prefix
   if exist('prefix','var') ~= 1 || ~ischar(prefix) || isempty(prefix)
      prefix = 'Flag_';
   end
      
   if gce_valid(s,'data')
      
      %validate column selections
      if isempty(cols)
         cols = 1:length(s.values);
      elseif ~isnumeric(cols)
         cols = name2col(s,cols);
      else
         cols = intersect(cols,(1:length(s.values)));
      end
      
      if ~isempty(cols)
         
         s2 = s;  %init output structure
         numrows = length(s.values{1});  %get number of data rows
         col_offset = 0;     %init position offset for adding flag columns
         valuecodes = [];  %init array of value codes
         
         %look up and parse flag codes
         flagcodes = lookupmeta(s,'Data','Codes');
         flagdefs = [];  %init array of flag definitions
         flagnums = [];  %init array of integers for encoded flags
         if ~isempty(flagcodes)
            if ~isempty(strfind(flagcodes,'|'))
               flagdefs = splitstr(flagcodes,'|');
            else
               flagdefs = splitstr(flagcodes,',');
            end
            flagnums = (1:length(flagdefs))';  %generate flag index numbers in definition order
         end
         
         for cnt = 1:length(cols)
            
            col = cols(cnt);  %get colum index
            allflags = [];  %init array of matched flags
            flagarray = s.flags{col};  %get flag array
            wid = size(flagarray,2);  %calculate flag array width
            
            %get index of matching flags
            if isempty(flagarray)
               Iflag = [];
               flagarray2 = [];
            else
               Iflag = zeros(numrows,wid);
               if isempty(flags)
                  flagarray2 = flagarray;  %copy flagarray unmodified to include any assigned flag
                  for n = 1:wid
                     Imatch = flagarray(:,n) ~= ' ';  %get index of any assigned flag
                     Ivalid = find(Imatch);
                     if ~isempty(Ivalid)
                        Iflag(Ivalid,n) = 1;  %update match index
                        newflags = unique(flagarray(Ivalid,n));
                        allflags = [allflags ; cellstr(newflags)];
                     end
                  end
               else
                  flagarray2 = repmat(' ',size(flagarray,1),wid);
                  for n = 1:wid
                     for m = 1:length(flags)
                        Imatch = flagarray(:,n) == flags(m); %get index of flags matching specified character
                        Ivalid = find(Imatch);
                        if ~isempty(Ivalid)
                           Iflag(Ivalid,n) = 1;  %update match index
                           flagarray2(Ivalid,n) = flags(m);
                           newflags = unique(flagarray(Ivalid,n));
                           allflags = [allflags ; cellstr(newflags)];
                        end
                     end
                  end
               end
               Iflag = find(sum(Iflag,2));
               allflags = unique(allflags);
            end

            %compress flags, convert to cell array
            flagarray2 = sub_compressflags(flagarray2,Iflag);
                          
            if emptycols == 1 || (~isempty(flagarray2) && ~isempty(Iflag))
               
               if ~isempty(flagarray2) && ~isempty(Iflag)
                  
                  if encode == 1
                     
                     %init array of encoded flags
                     flagdata = zeros(numrows,1);
                     
                     %generate integer code for first unmatched flag
                     if isempty(flagnums)
                        newflag = 1;
                     else
                        newflag = max(flagnums) + 1;
                     end
                     
                     %loop through matched flags resolving integer codes and updating definitions
                     newflags = allflags;  %create replica matched flag array for updating
                     for n = 1:length(allflags)
                        flagchar = allflags{n};
                        Imatchflag = find(flagarray2(:,1) == flagchar);
                        if ~isempty(Imatchflag)
                           Imatch = find(strncmp(flagdefs,flagchar,1));
                           if ~isempty(Imatch)
                              val = Imatch(1);
                              str = flagdefs{Imatch(1)};
                              flagdefs = [flagdefs ; {[int2str(val),str(2:end)]}];   %add definition for new code
                           else
                              val = newflag;  %use next newflag code
                              newflag = newflag + 1;  %update newflag counter
                              flagdefs = [flagdefs ; {[int2str(val),' = undefined code ',flagchar]}];  %add definition
                           end
                           newflags{n} = int2str(val);  %add code to new matched flag list
                           flagdata(Imatchflag) = val;  %add code to derived data column
                        end
                     end
                     allflags = newflags;  %replace original flag matches
                     
                  else
                     
                     %convert character array of matched flags to cell array
                     flagdata = cellstr(flagarray2);
                     
                  end
                  
               else  %include empty column
                  
                  if encode == 1
                     flagdata = zeros(numrows,1);
                  else
                     flagdata = repmat({''},numrows,1);
                  end
                  
               end
               
               %generate flag column name
               colname = [prefix,s.name{col}];
               
               %generate column description including flag codes
               coldesc = ['QA/QC flags for ',s.description{col},' (flagging criteria, where "x" is ',s.name{col},': ', ...
                  strrep(strrep(strrep(s.criteria{col},'col_',''),';',', '),'''','"'),')'];
               
               %increment column offset
               col_offset = col_offset + 1;
               
               %add column to data structure
               if encode == 1
                  s2 = addcol(s2,flagdata,colname,'none',coldesc,'d','code','none',0,'',col+col_offset);
               else
                  s2 = addcol(s2,flagdata,colname,'none',coldesc,'s','code','none',0,'',col+col_offset);
               end
               
               %generate code definition for new column
               if encode == 1
                  str = [colname,': 0 = no flag assigned, '];
               else
                  str = [colname,': "" = no flag assigned, '];
               end
              
               %add definitions for other matched flags
               for n = 1:length(allflags)
                  flag = allflags{n};
                  Imatch = find(strncmp(flagdefs,[flag,' ='],length(flag)+2));
                  if ~isempty(Imatch)
                     if encode == 1
                        str = [str,flagdefs{Imatch(end)},', '];  %if encoded, use last definition based on appending new codes
                     else
                        str = [str,flagdefs{Imatch(1)},', '];  %if not encoded, use first matching definition
                     end
                  else
                     str = [str,allflags{n},' = undefined code ',flag];
                  end
               end
               
               %append new codes to existing value code array, removing terminal comma and space
               valuecodes = [valuecodes ; {str(1:length(str)-2)}];
               
            else
               cols(cnt) = NaN;  %clear column index
            end
               
         end
         
         cols = cols(~isnan(cols));  %remove NaNs to generate list of updated columns
         
         if ~isempty(cols)
            
            if length(cols) > 1
               histstr = ['flags for columns ',cell2commas(s.name(cols),1)];
            else
               histstr = ['flags for column ',s.name{cols}];
            end
            
            if ~isempty(valuecodes) %update code list in documentation
               
               %get value codes from metadata
               oldcodes = lookupmeta(s,'Data','ValueCodes');
               if ~isempty(oldcodes)
                  ar = splitstr(oldcodes,'|');
                  if length(ar) == 1
                     if strncmp('no',ar{1},2) == 1  %check for 'none' or 'not specified'
                        ar = [];
                     end
                  end
               else
                  ar = [];
               end
               valuecodes = [ar ; valuecodes];
               
               %add history entry
               s2.history = [s.history; {datestr(now)} {[histstr,cell2commas(s.name(cols),1), ...
                     ' converted to data columns, flag codes updated in metadata (''flags2cols'')']}];
          
               %add value codes
               s2 = addmeta(s2,[{'Data'},{'ValueCodes'},{cell2pipes(valuecodes)}],1);
               
            else
               s2.history = [str_hist; {datestr(now)} {[histstr,cell2commas(s.name(Iflag),1),' converted to data columns (''flags2cols'')']}];
            end
            
         else
            s2 = s;  %revert to original structure
            msg = 'no flags were present in any of the specified columns';
         end            
         
      else
         msg = 'invalid column selection';
      end
      
   else
      msg = 'invalid GCE data structure';
   end
   
else
   msg = 'insufficient arguments for function';
end


function flagarray2 = sub_compressflags(flagarray,I_fl)
  
wid = size(flagarray,2);

if ~isempty(I_fl)  %check for non-empty rows

   flagarray2 = repmat(' ',size(flagarray,1),wid);  %init compressed flag array
   
   %compress flags by aligning characters to the left in the character array
   for n = 1:length(I_fl)
      ptr = I_fl(n);  %set row index pointer
      Itmp = find(flagarray(ptr,:) ~= ' ');  %get index of non-blank flags
      flagarray2(ptr,1:length(Itmp)) = flagarray(ptr,Itmp);  %assign non-blank flags to leftmost cols of flagarray2
   end
   
   %trim blank columns, starting from right and breaking when hit assigned flags
   c = 1:wid;  %init index of valid columns to keep
   for m = wid:-1:1
      Ivalid2 = find(flagarray2(:,m)~=' ');  %check for assigned flags
      if isempty(Ivalid2)
         c(m) = NaN;  %flag column for deletion
      else
         break
      end
   end
   c = c(~isnan(c));  %remove columns flagged for deletion
   
   %store trimmed char array of flags in cell array
   if isempty(c)      
      flagarray2 = [];  %no flags after coalesce
   else
      flagarray2 = flagarray2(:,c);
   end
   
else  %no flags assigned
   flagarray2 = [];
end