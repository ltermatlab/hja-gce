function [s2,msg] = addmeta(s,newmeta,silent,fncname,appendopt)
%Appends or updates metadata fields in a GCE-LTER data structure or metadata array
%
%syntax:  [s2,msg] = addmeta(s,newmeta,silent,fncname,appendopt)
%
%inputs:
%  s = data structure containing metadata to update or nx3 cell array of strings (metadata array)
%  newmeta = nx3 cell array of new metadata to add/update
%  silent = option to add metadata without a history entry
%    0 = no (default)
%    1 = yes
%  fncname = toolbox function name string to reference in the processing history entry
%    (default = 'addmeta')
%  appendopt = option to append metadata content in matching fields instead of overwriting
%    0 = no (default)
%    1 = yes
%
%outputs:
%  s2 = updated data structure (or metadata array)
%  msg = text of any error messages
%
%notes:
%  1) if newmeta is empty or invalid, the original structure will be returned with a warning
%     in msg
%
%
%(c)2002-2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 05-Jun-2013

s2 = [];
msg = '';

%check for required arguments
if nargin >= 2

   %check for omitted arguments, supply defaults
   if exist('application','var') ~= 1
      fncname = 'addmeta';
   end

   if exist('silent','var') ~= 1
      silent = 0;
   end
   
   if exist('appendopt','var') ~= 1
      appendopt = 0;
   end

   %check for valid metadata to merge
   if iscell(newmeta) && size(newmeta,2) == 3

      %check for cell array or data/stat structure, get metadata array
      if iscell(s) && size(s,2) == 3
         meta = s;
         s = [];
      elseif gce_valid(s)
         meta = s.metadata;
      else
         meta = [];  %unsupported format
      end

      %check for existing metadata to update
      if ~isempty(meta)
         
         %use original metadata as a template
         meta2 = meta;
         
         %process each row of new metadata
         for n = 1:size(newmeta,1)
            
            %extract metadata categories, fields
            metacat = meta2(:,1);
            metafd = meta2(:,2);
            
            %get index of metadata rows with matching categories & fields
            Imatch = find(strcmpi(metacat,newmeta{n,1}) & strcmpi(metafd,newmeta{n,2}));
            
            %check for field match to existing metadata
            if ~isempty(Imatch)
               
               %get old and new field values
               oldval = meta2{Imatch(1),3};
               newval = newmeta{n,3};
               
               %check for append option
               if appendopt == 1 && ~isempty(oldval)
                  if strncmp(oldval,'|',1) ~= 1
                     oldval = ['|',oldval];  %prepend pipe separator unless exists
                  end
                  if strncmp(newval,'|',1) == 1
                     newval = newval(2:end);  %remove leading separator if exists
                  end
                  newval = [oldval,'|',newval];
               end
               
               %update field value
               meta2(Imatch(1),3) = {newval};
               
            else  %add unmatched metadata rows
               meta2 = [meta2 ; newmeta(n,:)];
            end
            
         end
         
      else  %no existing metadata; incorporate new metadata wholesale        
         meta2 = newmeta;         
      end

      %update status field if it exists
      Imatch = find(strcmpi('Status',meta2(:,1)) & strcmpi('MetadataUpdate',meta2(:,2)));
      if ~isempty(Imatch)
         meta2(Imatch(1),3) = {datestr(now,1)};
      end
      
      %update metadata in data/stat structure
      if ~isempty(s)
         
         %copy original structure
         s2 = s;
         curdate = datestr(now);
         
         %update output structure
         s2.metadata = meta2;
         s2.editdate = curdate;
         
         %update history unless silent update
         if silent == 0
            oldval = ['updated ',int2str(size(newmeta,1)),' metadata fields in the ', ...
               cell2commas(unique(newmeta(:,1))),' sections (''',fncname,''')'];
            s2.history = [s2.history ; {curdate},{oldval}];
         end
         
      else
         %return metadata array only
         s2 = meta2;
      end

   else
      s2 = s;
      msg = 'invalid metadata format - no metadata added to data structure';
   end

else
   msg = 'insufficient inputs for function';
end
