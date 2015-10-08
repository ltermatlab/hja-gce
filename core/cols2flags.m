function [s2,msg] = cols2flags(s,flagcols,datacols,overwrite,deleteopt,prefix)
%Converts values in specified text columns of a GCE Data Structure to QA/QC flags for the corresponding data columns
%
%syntax: [s2,msg] = cols2flags(s,flagcols,datacols,overwrite,delete,prefix)
%
%inputs:
%  s = GCE Data Structure to modify
%  flagcols = array of column numbers or names containing flag information to process
%    (if omitted, all text columns starting with 'Flag_' {case insensitive} will be selected)
%  datacols = array of column numbers or names containing data columns to update
%    (if omitted, columns matching the flag columns will be selected, otherwise
%    must correspond to 'flagcols')
%  overwrite = option to overwrite existing flag information
%    0 = no/default (new flags will be merged with existing flags)
%    1 = yes
%  deleteopt = option to delete original flag column after conversion
%    0 = no
%    1 = yes/default
%  prefix = prefix denoting flag columns for identification of corresponding value column
%    (string, default = 'Flag_')
%
%outputs:
%  s2 = updated data structure (or unmodified structure if no candidate columns were found)
%  msg = text of any error messages
%
%notes:
%  1) if any text values are converted to flags, the Q/C criteria for the corresponding
%     data columns will be locked by adding a 'manual' token to prevent over-writing
%     of flags when Q/C criteria are evaluated
%  2) if overwrite = 1 and the text column is empty, all flags in the corresponding
%     data column will be cleared and the Q/C criteria locked
%  3) if overwrite = 0 and the text column is empty, no changes will be made to existing
%     flags or Q/C criteria
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
%last modified: 18-Nov-2014

%init output
s2 = [];
msg = '';

if nargin >= 1

   if gce_valid(s,'data')

      %supply defaults for omitted arguments
      if exist('overwrite','var') ~= 1
         overwrite = 0;
      elseif overwrite ~= 1
         overwrite = 0;
      end
      
      if exist('deleteopt','var') ~= 1
         deleteopt = 1;
      elseif deleteopt ~= 0
         deleteopt = 1;
      end

      if exist('flagcols','var') ~= 1
         flagcols = [];
	   elseif ~isnumeric(flagcols)
   	   flagcols = name2col(s,flagcols);
      end

      if exist('datacols','var') ~= 1
         datacols = [];
      elseif ~isnumeric(datacols)
         datacols = name2col(s,datacols);
      end
      
      if exist('prefix','var') ~= 1
         prefix = 'Flag_';
      end

      %check for user-specified flag column array
      if ~isempty(flagcols)

         if isempty(datacols)
            datacols = [];
            for n = 1:length(flagcols)
               vname = s.name{flagcols(n)};
               if strncmpi(vname,prefix,length(prefix))
                  vname2 = vname(length(prefix)+1:end);
                  Idatacol = name2col(s,vname2);
                  if ~isempty(Idatacol)
                     datacols = [datacols,Idatacol];
                  else
                     flagcols(n) = NaN;  %remove unmatched flag column
                  end
               end
            end
         end
         
         %clear unmatched flag columns
         flagcols = flagcols(~isnan(flagcols));

      else  %parse column names to determine flag/data columns

         flagcols = [];
         datacols = [];

         %get index of string columsn with flag column prefix (case insensitive)
         Iflags = find(strncmpi(s.name,prefix,length(prefix)) & strcmp(s.datatype,'s'));
         
         for n = 1:length(Iflags)
            
            %get flag column name
            flagname = s.name{Iflags(n)};
            
            %eliminate columns without a variable name following the flag prefix
            if length(flagname) > length(prefix)
               
               %parse base variable name
               varname = flagname(length(prefix)+1:end);
               
               %look up corresponding data column
               Idata = find(strcmp(s.name,varname));
               
               %if > 1 match, check if preceeding column has same base name
               if length(Idata) > 1
                  if n > 1
                     Idata2 = find(Idata == (Iflags(n)-1));
                     if length(Idata2) == 1
                        Idata = Idata(Idata2);  %use only match to preceding column
                     end
                  end
               end
               
               %add column to convert list
               if length(Idata) == 1  
                  flagcols = [flagcols,Iflags(n)];
                  datacols = [datacols,Idata];
               end
               
            end
         end

      end
      
      %check for flag column and data column matches
      if ~isempty(flagcols) && ~isempty(datacols) && length(flagcols)==length(datacols)

         %copy structure to output
         s2 = s;

         %generate flag definition array for checking, augmenting with new flags
         flagdefstr = lookupmeta(s,'Data','Codes');
         flagdefs = [{''},{'unspecified'}];
         if ~isempty(flagdefstr)
            flagdefarray = splitstr(flagdefstr,',');
            for n = 1:length(flagdefarray)
               def = splitstr(flagdefarray{n},'=');
               if length(def) == 2
                  flagdefs = [flagdefs ; {strrep(def{1},'''','')},{def{2}}];
               end
            end
         end

         %loop through flag columns to generate flag arrays
         for n = 1:length(flagcols)

            %extract new flag values
            flags = extract(s,flagcols(n));
            
            %get index of non-empty cells
            Ivalid = find(~cellfun('isempty',flags));

            %check for non-empty flags or overwrite mode
            if ~isempty(Ivalid) || overwrite == 1
               
               %check for non-empty flags - generate newflag array
               if ~isempty(Ivalid)
                  
                  %get list of unique flags
                  flaglist = setdiff(unique(flags(Ivalid)),{''});
                  
                  %add undefined flags to definition list
                  for m = 1:length(flaglist)
                     flag = strrep(flaglist{m},' ','');
                     if ~isempty(flag)
                        if isempty(find(strcmp(flagdefs(:,1),flag(1))))
                           flagdefs = [flagdefs ; {flag(1)},{'unspecified'}];
                        end
                     end
                  end
                  
                  %convert flags to padded character array after trimming leading, trailing blanks
                  flagstr = trimstr(char(flags));
                  
                  %check for flags to convert
                  oldflags = s.flags{datacols(n)};
                  if isempty(oldflags) || overwrite == 1
                     newflags = flagstr;  %just use new flags if overwrite mode or no prior flags
                  else
                     %append new flags to existing flag array and compress to eliminate leading blanks
                     newflags = compress_str([oldflags,flagstr]);
                  end
                  
               else  %no flags and overwrite == 1 - clear all flags                 
                  
                  newflags = '';
                  
               end

               %update structure flag array
               s2.flags{datacols(n)} = newflags;

               %add manual flag token to prevent flag recalculation
               crit = deblank(s2.criteria{datacols(n)});
               if isempty(crit)
                  crit = 'manual';
               elseif isempty(strfind(crit,'manual'))
                  crit = strrep([crit,';manual'],';;',';');
               end
               s2.criteria{datacols(n)} = crit;
               
            end

         end

         %add flag code definitions to metadata
         flagdefstr = '';
         for n = 2:size(flagdefs,1)
            flagdefstr = [flagdefstr,', ',flagdefs{n,1},' = ',flagdefs{n,2}];
         end
         if ~isempty(flagdefstr)
            s2 = addmeta(s2,[{'Data'},{'Codes'},{flagdefstr(2:end)}]);
         end

         %remove old flag columns
         deleteopt_history = '';
         if deleteopt == 1
            s2 = deletecols(s2,flagcols);
            deleteopt_history =  ' and deleted flag source columns';            
         end
         
         %update processing history
         if ~isempty(s2)
	         s2.history = [s.history ; {datestr(now)},{['converted text codes in flag column(s) ', ...
   	               cell2commas(s.name(flagcols),1),' to QA/QC flags for data column(s) ', ...
      	            cell2commas(s.name(datacols),1),deleteopt_history,' (''cols2flags'')']}];
	      else
            msg = 'an error occurred converting the columns to QA/QC flags - operation cancelled';
         end

      else
         s2 = s;  %assign original structure to output
         msg = 'column selections are invalid or no candidate columns could be determined';
      end

   else
      msg = 'this function requires a valid GCE Data Structure';
   end

else
   msg = 'insufficient arguments for function';
end