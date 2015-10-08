function [s2,msg,badcols] = codes2dataset(s,cols,metafields)
%Generates a code definition data structure for coded columns in a GCE Data Structure
%
%syntax: [s2,msg,badcols] = codes2dataset(s,cols,metaopt)
%
%input:
%  s = data set containing code columns
%  cols = array of column names or index numbers to include (default = all columns with variable type of 'code')
%  metaopt = array of metadata categories and fields to retain
%     [] = auto/default (all fields in Dataset, Project, Study, Status and Supplement, omitting Site and Data fields)
%     'prompt' = option to select fields using a GUI dialog
%     nx2 cell array = array of metadata sections and fields to retain
%
%output:
%  s2 = code definition data structure
%  msg = text of any error message
%  badcols = array of columns that could not be decoded
%
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
%last modified: 09-Feb-2012

%init output
s2 = [];
msg = '';
badcols = [];

%check for valid data set argument
if nargin >= 1 && gce_valid(s,'data')
   
   %validate column selections
   if exist('cols','var') ~= 1
      cols = [];
   end
   if isempty(cols)
      coltypes = get_type(s,'variabletype');
      cols = find(strcmp(coltypes,'code'));
   elseif ~isnumeric(cols)
      cols = name2col(s,cols);
   else
      cols = intersect(cols,(1:length(s.name)));
   end
   
   %check for valid columns
   if ~isempty(cols)
      
      %init badcols
      Ibadcols = zeros(length(cols),1);
      
      %validate metadata field selection, using defaults or prompting as necessary
      if exist('metafields','var') ~= 1
         metafields = [];
      elseif ischar(metafields) && strcmpi(metafields,'prompt')
         metafields = [];
         if ~isempty(s.metadata)
            Ivalid = find(~cellfun('isempty',s.metadata(:,3)));
            if ~isempty(Ivalid)
               metastr = concatcellcols([concatcellcols(s.metadata(Ivalid,1:2),'_'),s.metadata(Ivalid,3)],':   ');
               Isel = listdialog('liststring',metastr, ...
                  'selectionmode','multiple', ...
                  'promptstring','Select metadata content to import', ...
                  'name','Import Metadata', ...
                  'listsize',[0 0 640 500]);
               if ~isempty(Isel)
                  metafields = s.metadata(Ivalid(Isel),1:2);
               end
            end
         end
      elseif ~iscell(metafields) && size(metafields,2) ~= 2
         metafields = [];
      end
      
      %get metadata array from source structure
      meta = s.metadata;
      
      %use default metadata fields if not specified or invalid
      if isempty(metafields)
         Iflds = inlist(meta(:,1),{'Dataset','Project','Study','Status','Supplement'});
         metafields = meta(Iflds,1:2);
      end
      
      %subset metadata
      newmeta = [metafields repmat({''},size(metafields,1),1)];
      for n = 1:size(metafields,1)
         Imatch = find(strcmpi(metafields{n,1},meta(:,1)) & strcmpi(metafields{n,2},meta(:,2)));
         if ~isempty(Imatch)
            newmeta{n,3} = meta{Imatch(1),3};
         end
      end
      Ivalid = find(~cellfun('isempty',newmeta(:,3)));
      if ~isempty(Ivalid)
         newmeta = newmeta(Ivalid,:);
      end
      
      %init output structure
      s2 = newstruct('data');
      
      %copy specified metadata content from source structure
      s2 = addmeta(s2,newmeta,1);
      
      %add prefix to original data set title
      s2 = newtitle(s2,['Coded value definition table for ',s.title]);
      
      %init arrays for derived columns
      colnames = [];
      codenames = [];
      codedefs = [];
      
      %loop through columns, decoding columns and extracting unique codes, defs
      for n = 1:length(cols)
         
         col = cols(n);  %get column index
         colname = s.name{col};   %get column name for lookups
         
         s_tmp = cleardupes(s,col);   %remove duplicate codes to speed up decoding
         s_tmp = decodecols(s_tmp,col,'_decoded');  %decode column

         %check for valid codes to include
         if ~isempty(s_tmp)
            
            %check for non-string codes, convert
            dtype = char(get_type(s_tmp,'datatype',col));  %get data type of code column
            if ~strcmp(dtype,'s')
               s_tmp = convert_datatype(s_tmp,col,'s','fix');  %convert numeric code to string
            end
            
            %get codes and defs from summary structure
            codes = extract(s_tmp,col);
            defs = extract(s_tmp,[colname,'_decoded']);
            
            %get index of non-empty codes
            Ivalid = find(~cellfun('isempty',codes));
            
            if ~isempty(Ivalid)
               
               codes = codes(Ivalid);  %remove empty codes
               defs = defs(Ivalid);  %remove defs for empty codes
         
               %add new codes and defs to data arrays
               if ~isempty(codes) && ~isempty(defs)
                  colnames = [colnames ; repmat({colname},length(codes),1)];
                  codenames = [codenames ; codes];
                  codedefs = [codedefs ; defs];
               else
                  Ibadcols(n) = 1;
               end
               
            else
               Ibadcols(n) = 1;
            end
            
         else
            Ibadcols(n) = 1;
         end
         
      end
      
      %add columns to new data set
      s2 = addcol(s2,colnames,'Column','none','Data set column name','s','nominal','none',0,'');
      s2 = addcol(s2,codenames,'Code','none','Value code','s','nominal','none',0,'');
      s2 = addcol(s2,codedefs,'Definition','none','Value code definition','s','nominal','none',0,'');
      
      %generate badcols array
      badcols = s.name(cols(find(Ibadcols)));
      
      %check for errors
      if isempty(s2)
         msg = 'An error occurred extracting the codes for the specified columns';
      elseif ~isempty(badcols)
         msg = ['Note: no valid codes were present in column(s): ',cell2commas(badcols,1)];
      end
      
   else
      msg = 'invalid column selection';
   end
   
else
   msg = 'invalid data structure';
end
