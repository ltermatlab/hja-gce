function [s2,msg] = add_itis_tsn(s,col,searchtype,tsn_name,tsn_pos,decode)
%Looks up ITIS taxonomic serial numbers for a column of taxonomic names or codes in a GCE Data Structure
%by querying the Integrate Taxonomic Information System at http://www.itis.gov/ using 'fetch_itis.m'
%
%syntax: [s2,msg] = add_itis_tsn(s,col,searchtype,tsn_name,tsn_pos,decode)
%
%input:
%  s = data structure to update
%  col = name or index number of a data column containing taxonomic names to look up
%  searchtype = search type option
%    'scientific' = search on scientific name (default)
%    'common' = search on common name
%  tsn_name = name for the TSN column (default = [colname,'_TSN'])
%  tsn_pos = position for the TSN column (default = immediately following col)
%  decode = option to decode values in col prior to looking up the TSN
%    0 = no  (default when the variabletype of col is not 'code')
%    1 = yes (default when the variabletype of col is 'code' or col is numeric)
%
%output:
%  s2 = updated structure
%  msg = text of any error message
%
%usage notes:
%  1) only columns with variable type of 'code' or 'nominal' are supported
%  2) common terms for undistinguished species within a genus (e.g. spp, spp., sp., species)
%     will be removed prior to searching ITIS, so TSN entries will match the corresponding genus
%  3) TSN values will be added as strings with variable type 'nominal'
%
%(c)2012 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 08-Feb-2012

%init output
s2 = [];

%check for required arguments
if nargin >= 2
   
   %check for valid data structure
   if gce_valid(s,'data')
      
      if ~isnumeric(col)
         col = name2col(s,col);
      else
         col = intersect(col,(1:length(s.name)));
      end
      
      if length(col) == 1
         
         %get column characteristics
         vtype = get_type(s,'variabletype',col);
         dtype = get_type(s,'datatype',col);
         
         %check for code or nominal variable type
         if strcmp(vtype,'code') || strcmp(vtype,'nominal')
            
            %validate searchtype or supply default
            if exist('searchtype','var') ~= 1
               searchtype = '';
            end
            if isempty(searchtype) || ~strcmp(searchtype,'common')
               searchtype = 'scientific';
            end
            
            %validate tsn_name or supply default
            if exist('tsn_name','var') ~= 1
               tsn_name = '';
            end
            if isempty(tsn_name)
               tsn_name = [s.name{col},'_TSN'];
            end
            
            %validate tsn_pos or supply default
            if exist('tsn_pos','var') ~= 1
               tsn_pos = [];
            end
            if isempty(tsn_pos)
               tsn_pos = col + 1;
            end
            
            %specify auto decode option if omitted
            if exist('decode','var') ~= 1
               decode = [];
            end
            
            %set missing decode option based on variabletype and datatype
            if isempty(decode)
               if strcmp(vtype,'code') || ~strcmp(dtype,'s')
                  decode = 1;
               else
                  decode = 0;
               end
            end
            
            %extract query names (decoding if necessary)
            decodeflag = 0;
            if decode == 0
               if strcmp(dtype,'s')
                  names = extract(s,col);
               else
                  s_tmp = convert_datatype(s,col,'s','fix');
                  names = extract(s_tmp,col);
               end
            else
               s_tmp = decodecols(s,col,'',{'tsn_query'});
               decodeflag = 1;
               names = extract(s_tmp,'tsn_query');
            end
            
            %check for successful name extraction
            if ~isempty(names) && iscell(names)
               
               %check for gui mode
               h = findobj('Tag','dlgDSEditor');
               if ~isempty(h)
                  guimode = 1;
               else
                  guimode = 0;
               end
               
               %get unique names and index of original positions
               [namelist,Inames,Iorig] = unique(names);
               
               %remove species suffix (e.g. spp, sp., species) using regex
               namelist = regexprep(namelist,'( sp+\.*$| species$)+','','ignorecase');
               
               %init tsn array
               tsn = repmat({''},length(names),1);
               
               %init progress bar if in guimode
               if guimode == 1
                  ui_progressbar('init',length(namelist)+1,'ITIS Query Status');
               end
               
               %perform lookups
               for n = 1:length(namelist)
                  
                  %update progress bar
                  if guimode == 1
                     ui_progressbar('update',n,['Searching for ',namelist{n},' ...']);
                  end
                  
                  %perform query with parsetaxa = 0 option to only return TSN field
                  taxa = fetch_itis(searchtype,namelist{n},0);
                  
                  %extract and validate TSN
                  if ~isempty(taxa) && isstruct(taxa) && isfield(taxa,'TSN')
                     tsn_match = taxa.TSN;
                     if ~isempty(tsn_match)
                        Imatch = Iorig == n;  %get index of all original column entries
                        tsn(Imatch) = cellstr(int2str(taxa.TSN));  %convert to string and update master TSN array
                     end
                  end
                  
               end
               
               %update progress bar
               if guimode == 1
                  ui_progressbar('update',n+1,'Adding column ...')
               end
               
               %generate history entry for ITIS lookup
               strhist = ['looked up ITIS TSN entries for ',searchtype,' names in column ', ...
                  s.name{col}];
               if decodeflag == 1
                  strhist = [strhist,', after decoding values based on code definitions in the metadata'];
               end
               strhist = [strhist,' (''add_itis_tsn'')'];
               
               %init output structure, add history entry
               s2 = s;
               curdate = datestr(now);
               s2.editdate = curdate;
               s2.history = [s.history ; {curdate} {strhist}];
               
               %check for prior TSN column and delete
               oldcol = name2col(s2,tsn_name);
               if ~isempty(oldcol)
                  s2 = deletecols(s2,oldcol);
               end
               
               %add TSN column to data set
               [s2,msg] = addcol(s2,tsn,tsn_name,'none', ...
                  ['Taxonomic serial numbers for entries in column ',s.name{col}, ...
                  ' obtained from the Integrated Taxonomic Information System database (http://www.itis.gov/)'], ...
                  's','nominal','none',0,'',tsn_pos);
               
               %close progress bar
               if guimode == 1
                  ui_progressbar('close')
               end
               
            else
               msg = 'failed to extract taxonomic names from the specified column';
            end
            
         else
            msg = 'invalid column type - only columns with variable type of code or nominal are supported';
         end
         
      else
         msg = 'invalid column selection';
      end
      
   else
      msg = 'invalid data structure';
   end
   
else
   msg = 'insufficient arguments for function (s and col are required)';
end