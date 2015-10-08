function [s2,msg,badcols] = decodecols(s,cols,suffix,colnames)
%Converts coded columns in a GCE Data Structure to text columns based on code definitions in the metadata
%and adds a decoded column to the data set
%
%syntax: [s2,msg,badcols] = decodecols(s,cols,suffix,colnames)
%
%input:
%  s = data structure to update
%  cols = array of column names or index numbers to decode (default = all coded columns)
%  suffix = suffix to append to decoded column names (default = '_Decoded')
%  colnames = array of new column names to use for decoded columns, overriding suffix setting
%     (cell array of strings matching the length of cols)
%
%output:
%  s2 = updated data structure
%  msg = text of any error message
%  badcols = array of column numbers that could not be decoded
%
%(c)2011 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 01-Jun-2011

s2 = [];
msg = '';
badcols = [];

if nargin >= 1  && gce_valid(s,'data')
   
   %check for omitted column selected
   if exist('cols','var') ~= 1
      cols = [];
   end
   
   %validate column selection, supplying index of coded columns if empty
   if isempty(cols)
      cols = name2col(s,s.name,'','','code');  %get index of all coded columns if omitted
   elseif isnumeric(cols)
      cols = intersect((1:length(s.name)),cols);  %limit to valid columns
   else  %look up text column names
      cols = name2col(s,cols);
   end
   
   %validate suffix
   if exist('suffix','var') ~= 1
      suffix = '_Decoded';
   end
   if ~ischar(suffix)
      %catch old syntax without suffix
      if iscell(suffix) && length(suffix) == length(cols) && exist('colnames','var') ~= 1
         colnames = suffix;
         suffix = '';
      else
         suffix = '_Decoded';
      end
   end
   
   %check for missing colnames input or mismatched array sizes
   if exist('colnames','var') ~= 1
      colnames = [];
   elseif length(colnames) ~= length(cols)
      colnames = [];
      msg = [msg ; {'mismatched number of column names - values ignored'}];
   end
   
   %restrict column selections to 'code' variable type, remove colnames for non-coded columns
   if ~isempty(cols)
      vartype = get_type(s,'variabletype',cols);  %look up variable type
      Iskipped = find(~strcmp(vartype,'code'));  %get index of non-coded columns
      Ivalid = find(strcmp(vartype,'code'));  %get index of code columns
      if ~isempty(colnames)
         colnames = colnames(Ivalid);  %limit column names to valid columns
      end
      if ~isempty(Iskipped)
         badcols = cols(Iskipped);
         msg = [msg ; {['columns ',cell2commas(s.name(badcols),1), ...
            ' are not valid coded columns and were skipped']}];  %add warning to output message
      end
      cols = cols(Ivalid); %apply restriction to column index
   end
   
   if ~isempty(cols)
      
      %generate colnames if not specified
      if isempty(colnames)
         colnames = concatcellcols([s.name(cols)',repmat({suffix},length(cols),1)],'')';
      end
      
      %look up and parse code lists
      all_codes = lookupmeta(s,'Data','ValueCodes');
      ar_codes = splitstr(all_codes,'|');
      
      if ~isempty(ar_codes)
         
         s2 = s;  %copy input structure to output
         
         %add history entry for decode cols
         if length(cols) > 1
            str_hist = ['decoded values in columns ',cell2commas(s.name(cols),1), ...
               ' based on code values in the metadata, and added columns ',cell2commas(colnames,1), ...
               ' as categorical text columns (''decodecols'')'];
         else
            str_hist = ['decoded values in column ',char(s.name(cols)), ...
               ' based on code values in the metadata, and added column ',char(colnames), ...
               ' as a categorical text column (''decodecols'')'];
         end
         s2.history = [s2.history ; {datestr(now)},{str_hist}];
         s2.editdate = datestr(now);
         
         %init array of bad columns
         badcols = zeros(length(cols),1);  
         
         %loop through columns and decode, adding new categorical text columns
         for n = 1:length(cols)
            col = cols(n);
            colname = s.name{col};
            Imatch = find(strncmp(ar_codes,[colname,':'],length(colname)+1));
            if length(Imatch) == 1
               codelist = ar_codes{Imatch}(length(colname)+2:end);
               [codes,defs] = splitcodes(codelist);
               if ~isempty(codes)
                  vals0 = extract(s,col);
                  if ~iscell(vals0)
                     try
                        %convert numeric codes to string, trimming leading/trailing blanks
                        s_tmp = convert_datatype(s,col,'s','fix');
                        vals0 = trimstr(extract(s_tmp,col));
                     catch
                        vals0 = [];
                     end
                  end
                  if ~isempty(vals0)
                     vals = repmat({''},length(vals0),1);
                     for m = 1:length(codes)
                        Icode = find(strcmp(vals0,codes{m}));
                        if ~isempty(Icode)
                           vals(Icode) = defs(m);
                        end
                     end
                     Ivalid = find(~cellfun('isempty',vals));
                     if ~isempty(Ivalid)
                        pos = name2col(s2,colname);  %get column position in output structure
                        s2 = addcol(s2,vals,colnames{n},s.units{col},s.description{col}, ...
                           's','nominal','none',0,'',pos(1)+1);
                     else
                        badcols(n) = 1;
                        msg = [msg ; {['no matching codes were found in column ''',colname,'''']}];
                     end
                  else
                     badcols(n) = 1;
                     msg = [msg ; {['values in column ''',colname,''' could not be converted to strings']}];
                  end
               else
                  badcols(n) = 1;
                  msg = [msg ; {['codes for column ''',colname,''' could not be parsed']}];
               end
            else
               badcols(n) = 1;
               msg = [msg ; {['codes for column ''',colname,''' were not found in the metadata']}];
            end
         end
         
         if iscell(msg)
            msg = cell2commas(msg);
         end
         
      else
         msg = 'no value codes are present in the metadata';
      end
      
   else
      msg = 'invalid column selection - only columns with variabletype = ''code'' are supported';
   end
   
else
   if nargin == 0
      msg = 'insufficient arguments for function';
   else
      msg = 'invalid GCE Data Structure';
   end
end
