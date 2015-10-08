function [s2,msg] = cols2flags_mapped(s,flagset_name,flagcols,datacols,overwrite,deleteopt)
%Converts data set columns to QA/QC flags after mapping multi-character flags to single character equivalents
%based on mappings defined in the data structure 'flag_mapping.mat'
%
%syntax: [s2,msg] = cols2flags_mapped(s,flagset_name,flagcols,datacols,overwrite,delete)
%
%input:
%  s = data structure to modify
%  flagset_name = name of a flag mapping set in the data structure 'flag_mapping.mat' (matched to "Flag_Set" variable)
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
%
%output:
%  s2 = updated data structure (or unmodified structure if no candidate columns were found)
%  msg = text of any error messages
%
%usage notes:
%  1) any unmapped flags will be ignored, so the information will be lost if deleteopt = 1
%  2) if flagset_name is empty a GUI select list will be displayed for choosing a flag set
%
%(c)2009-2011 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%  email: sheldon@uga.edu
%
%last modified: 24-May-2011

s2 = [];
msg = '';

if nargin >= 1
   
   if gce_valid(s,'data')
      
      %default to an empty flag set for selection from a GUI list
      if exist('flagset_name','var') ~= 1 || isempty(flagset_name)
         flagset_name = '';
      end
      
      flagset = [];  %init flag set array
      
      %look up map table by name from 'flag_mapping.mat'
      if exist('flag_mapping.mat','file') == 2
         
         %load data structure
         try
            v = load('flag_mapping.mat','-mat');
         catch
            v = struct('null','');
         end
         
         if isfield(v,'data') && gce_valid(v.data,'data') == 1
            
            %invoke list selection GUI if flag_set empty
            if isempty(flagset_name)
               allsets = extract(v.data,'Flag_Set');  %extract flag_set names
               alldesc = extract(v.data,'Flag_Set_Label');  %extract flag_set labels for select list
               [flagsets,Iunique] = unique(allsets);  %get unique flagsets and index for retrieving label
               Iselect = listdialog('name','Flag Mapping', ...
                  'liststring',concatcellcols([flagsets,alldesc(Iunique)],' - '), ...
                  'promptstring','Select a Flag Mapping Set to Apply', ...
                  'selectionmode','single', ...
                  'listsize',[0 0 500 300]);
               if ~isempty(Iselect)
                  flagset_name = flagsets{Iselect};
               end
            end
            
            if ~isempty(flagset_name)
               
               flagset_data = querydata(v.data,['strcmpi(''',flagset_name,''',Flag_Set)']);
               if ~isempty(flagset_data)
                  try
                     flagset = [extract(flagset_data,'Original_Flag'), ...
                        extract(flagset_data,'GCE_Flag'), ...
                        extract(flagset_data,'GCE_Definition')];
                  catch
                     flagset = [];
                  end
               end
            
            end
            
         end
         
      end
      
      if iscell(flagset) && size(flagset,2) >= 2
         
         %validate other input arguments, assign defaults if omitted
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
         end
         
         %look up flagcols with corresponding data cols if not specified
         if isempty(flagcols)
            
            flagcols = [];
            
            %get index of string columns with 'flag_' prefix, case insensitive
            Iflags = find(strncmpi(s.name,'flag_',5) & strcmp(s.datatype,'s') | strcmp(s.datatype,'d'));
            
            for n = 1:length(Iflags)
               flagname = s.name{Iflags(n)};  %get flag column name
               if length(flagname) > 5
                  varname = flagname(6:end);  %parse base variablename
                  Idata = find(strcmp(s.name,varname));  %look up corresponding data column
                  if length(Idata) > 1  %if > 1 match, check if preceeding column has same base name
                     if n > 1
                        Idata2 = find(Idata == (Iflags(n)-1));
                        if length(Idata2) == 1
                           Idata = Idata(Idata2);  %use only match to preceding column
                        end
                     end
                  end
                  if length(Idata) == 1  %add to convert list
                     flagcols = [flagcols,Iflags(n)];
                     datacols = [datacols,Idata];
                  end
               end
            end
            
         end
         
         %check for matching flag and data cols
         if ~isempty(flagcols) && ~isempty(datacols) && length(flagcols)==length(datacols)
            
            %check for non-string flag cols - convert to string
            Istr = find(strcmp(s.datatype(flagcols),'s'));
            if length(Istr) < length(flagcols)
               Inonstr = setdiff(flagcols,Istr);
               [s,msg2,badcols] = convert_datatype(s,Inonstr,'s');
               if ~isempty(badcols)
                  flagcols = setdiff(flagcols,badcols);
                  msg = ['column(s) ',cell2commas(s.name(badcols),1),' could not be converted to text'];
               end
            end
            
            %add processing history entry
            str = ['mapped QA/QC flags in columns ',cell2commas(s.name(flagcols),1), ...
               ' to flags specified in the mapping table ''',flagset_name,''' in the file ''flag_mapping.mat''', ...
               ' (''cols2flags_mapped'')'];
            s.history = [s.history ; {datestr(now),str}];
            
            %perform flag mapping
            if ~isempty(s)
              
               %perform flag substitutions, update column values
               for n = 1:length(flagcols)
                  col = flagcols(n);
                  vals = extract(s,col);
                  newvals = repmat({''},length(vals),1);
                  for m = 1:size(flagset,1)
                     testval = flagset{m,1};
                     Imatch = find(strncmp(vals,testval,length(testval)));
                     if ~isempty(Imatch)
                        newvals(Imatch) = flagset(m,2);
                     end
                  end
                  s = update_data(s,col,newvals,0);
               end
               
               if ~isempty(s)
                  
                  %generate flag definitions, if provided, and add to flag codes
                  if size(flagset,2) >= 3
                     str = lookupmeta(s,'Data','Codes');
                     if ~isempty(str)
                        [flagcodes,flagdefs] = splitcodes(str);
                     else
                        flagcodes = [];
                        flagdefs = [];
                     end
                     flagcodes = [flagcodes ; flagset(:,2)];
                     flagdefs = [flagdefs ; flagset(:,3)];
                     [flagcodes,Iflagdefs] = unique(flagcodes);
                     flagdefs = flagdefs(Iflagdefs);
                     str = cell2commas(concatcellcols([flagcodes(:),flagdefs(:)],' = '));
                     if ~isempty(str)
                        s = addmeta(s,{'Data','Codes',str},0,'cols2flags_mapped');
                     end
                  end

                  %pass structure and options to cols2flags
                  [s2,msg] = cols2flags(s,flagcols,datacols,overwrite,deleteopt);
                  
                  %generate flag definition array for checking, augmenting with new flags
                  if ~isempty(s2) && size(flagset,2) >= 3
                     
                     flagdefstr = lookupmeta(s2,'Data','Codes');
                     flagdefs = [];
                     if ~isempty(flagdefstr)
                        flagdefarray = splitstr(flagdefstr,',');
                        for n = 1:length(flagdefarray)
                           def = splitstr(flagdefarray{n},'=');
                           if length(def) == 2
                              Imatch = find(strcmp(flagset(:,2),def{1}));
                              if length(Imatch) == 1
                                 flagdefarray{n} = [def{1},' = ',flagset{Imatch,3}];
                              end
                           end
                        end
                        flagdefstr = concatcellcols(flagdefarray(:)',', ');
                        s2 = addmeta(s2,{'Data','Codes',char(flagdefstr)},0,'cols2flags_multi');
                     end
                     
                  end
                  
               else
                  msg = 'an error occurred substituting flag characters';
               end
               
            end
            
         else
            s2 = s;  %assign original structure to output
            msg = 'column selections are invalid or no candidate columns could be determined';
         end
         
      else
         msg = 'no valid QA/QC flag mapping set was specified';
      end
      
   else
      msg = 'invalid data structure';
   end
   
else
   msg = 'insufficient arguments for function';
end