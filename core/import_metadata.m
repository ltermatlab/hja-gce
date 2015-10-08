function newmeta = import_metadata(meta,meta_source,fields,importmode)
%Imports metadata fields from one GCE Data Toolbox metadata array to update another metadata array
%
%syntax: newmeta = import_metadata(meta,meta_source,fields,importmode)
%
%input:
%   meta = metadata array to update (nx3 cell array of strings)
%   meta_source = metadata array to import content from (nx3 cell array of strings)
%   fields = field selection option:
%      'all' = all fields
%      'selected' = fields selected from a GUI list dialog (default)
%   importmode = metadata import mode
%      'overwrite' = overwrite all corresponding fields in meta with content from meta_source (default)
%      'overlay' = overlay content, only filling in empty fields in meta with content from meta_source
%
%output:
%   newmeta = revised metadata array (nx3 cell array of strings)
%
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
%last modified: 13-Oct-2011

newmeta = [];

%validate input
if nargin >= 2 && iscell(meta) && iscell(meta_source) && size(meta,2) == 3 && size(meta_source,2) == 3
   
   %apply default values for omitted arguments
   if exist('fields','var') ~= 1
      fields = 'selected';
   elseif strcmpi(fields,'all') ~= 1
      fields = 'selected';
   end
   
   if exist('importmode','var') ~= 1
      importmode = 'overwrite';
   elseif strcmpi(importmode,'overlay') ~= 1
      importmode = 'overwrite';
   end
   
   %check for selective metadata import, cull meta_source based on user field selections
   if strcmpi(fields,'selected')
      Imetasection = [];
      Ivalid = find(~cellfun('isempty',meta_source(:,3)));
      if ~isempty(Ivalid)
         metastr = concatcellcols([concatcellcols(meta_source(Ivalid,1:2),'_'),meta_source(Ivalid,3)],':   ');
         Isel = listdialog('liststring',metastr, ...
            'selectionmode','multiple', ...
            'promptstring','Select metadata content to import', ...
            'name','Import Metadata', ...
            'listsize',[0 0 640 500]);
         if ~isempty(Isel)
            Imetasection = Ivalid(Isel);
         end
      end
      meta_source = meta_source(Imetasection,:);  %apply selections
   end
   
   %check for empty newmeta again to catch cancels on user selections
   if ~isempty(meta_source)
      
      %clear trailing blanks from metadata categories/fields to prevent miscomparisons
      meta_source(:,1) = deblank(meta_source(:,1));
      meta_source(:,2) = deblank(meta_source(:,2));
      
      %overlay or overwrite metadata content
      if isempty(meta) || (strcmpi(fields,'all') && strcmpi(importmode,'overwrite'))
         
         newmeta = meta_source;  %original metadata empty or overwrite option - use source content alone
         
      else  %overlay content or overwrite selected sections
         
         %clear trailing blanks from metadata categories/fields to prevent miscomparisons
         if ~isempty(meta)
            meta(:,1) = deblank(meta(:,1));
            meta(:,2) = deblank(meta(:,2));
         end
         
         %init array for matched fields
         matches = zeros(size(meta_source,1),1);
         
         %set overwrite flag
         if strcmpi(importmode,'overwrite')
            flag_overwrite = 1;
         else
            flag_overwrite = 0;
         end
         
         %loop through metadata performing category/field matches
         for n = 1:size(meta,1)
            Imatch = find(strcmp(meta{n,1},meta_source(:,1)) & strcmp(meta{n,2},meta_source(:,2)));
            if ~isempty(Imatch)
               matches(Imatch) = 1;  %add matched fields to pointer array
               if flag_overwrite == 1
                  str = meta_source{Imatch(1),3};  %unconditionally replace contents
                  for m = 2:length(Imatch)  %concatenate multiple matches if present
                     str = [str,'|',meta_source{Imatch(m),3}];
                     meta_source(Imatch(m),:) = [{''},{''},{''}];  %clear duplicated content
                  end
               else  %overlay
                  str = deblank(meta{n,3});
                  if isempty(str)  %check for existing info
                     str = meta_source{Imatch(1),3};  %use contents of new metadata
                     for m = 2:length(Imatch)  %concatenate multiple matches
                        str = [str,'|',meta_source{Imatch(m),3}];
                        meta_source(Imatch(m),:) = [{''},{''},{''}];  %clear duplicates
                     end
                  end
               end
               meta{n,3} = str;  %update contents of metadata array
            end
         end
         
         %get index of matched fields in meta_source
         Imatches = find(matches);
         
         %append unmatched fields in new metadata to existing metadata
         if ~isempty(Imatches)
            Iall = (1:size(meta_source,1))';
            Iunused = setdiff(Iall,Imatches);
            meta = [meta ; meta_source(Iunused,:)];
         elseif ~isempty(meta)  %no fields matched - append all non-empty fields
            Ivalid = find(~cellfun('isempty',meta_source(:,3)));
            if ~isempty(Ivalid)
               meta = [meta ; meta_source(Ivalid,:)];
            end
         end
         
         %copy revised metadata to output
         newmeta = meta;
         
      end
      
   else  %no content to import
      
      %copy original metadata to output
      newmeta = meta;
      
   end
   
end