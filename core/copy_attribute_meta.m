function [s2,msg] = copy_attribute_meta(s1,s2,cols_s1,cols_s2,metafields)
%Copies attribute metadata between specified columns in two data structures
%
%syntax: [s2,msg] = copy_attribute_meta(s1,s2,cols_s1,cols_s2,metafields)
%
%inputs:
%  s1 = source structure
%  s2 = destination structure
%  cols_s1 = source column names or indices in s1
%  cols_s2 = destination column names or indices in s2 (default = cols_s1)
%  metafields = cell array of metadata fields to copy (default = 
%    {'name','units','description','datatype','variabletype','numbertype','precision','criteria'})
%
%output:
%  s2 = updated destination structure
%  msg = text of any error message
%
%(c)2010 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 15-Oct-2010

msg = '';

if nargin >= 3
   
   if gce_valid(s1,'data') == 1 && gce_valid(s2,'data') == 1
      
      if exist('cols_s2','var') ~= 1
         cols_s2 = cols_s1;
      end
      
      if ~isnumeric(cols_s1)
         cols_s1 = name2col(s1,cols_s1);
      else
         cols_s1 = intersect((1:length(s1.name)),cols_s1);
      end
      
      if ~isnumeric(cols_s2)
         cols_s2 = name2col(s2,cols_s2);
      else
         cols_s2 = intersect((1:length(s2.name)),cols_s2);
      end
      
      if ~isempty(cols_s1) && ~isempty(cols_s2) && length(cols_s1) == length(cols_s2)
         
         %assign default metadata fields if omitted/invalid
         if exist('metafields','var') ~= 1
            metafields = [];
         end
         if isempty(metafields) || ~iscell(metafields)
            metafields = {'name','units','description','datatype','variabletype', ...
               'numbertype','precision','criteria'};
         end
         
         %init change message array
         changelog = repmat({''},length(cols_s1),length(metafields));
         
         %copy metadata
         for n = 1:length(cols_s1)
            for m = 1:length(metafields)          
               fld = metafields{m};
               colname = s2.name{cols_s2(n)};
               copyflag = 0;
               val1 = s1.(metafields{m})(cols_s1(n));
               val2 = s2.(metafields{m})(cols_s2(n));
               if iscell(val1)
                  if ~strcmp(char(val1),char(val2))
                     copyflag = 1;
                     changelog{n,m} = ['changed ',fld,' of ',colname,' from ''',char(val2),''' to ''',char(val1),''''];
                  end
               else
                  if val1 ~= val2
                     copyflag = 1;
                     changelog{n,m} = ['changed ',fld,' of ',colname,' from ',num2str(val2),' to ',num2str(val1)];
                  end
               end
               if copyflag == 1
                  s2.(fld)(cols_s2(n)) = s1.(fld)(cols_s1(n));
               end
            end
         end
         
         %convert changelog into column array
         changelog = changelog';
         changelog = [changelog(:)]';
         
         %check for changes
         Ichange = find(~cellfun('isempty',changelog));
         
         if ~isempty(Ichange)
            
            %generate history string
            s2.editdate = datestr(now);
            s2.history = [s2.history ; {datestr(now)}, ...
               {['copied attribute metadata from another data structure (''copy_attribute_meta''); ', ...
               char(concatcellcols(changelog(Ichange),', '))]}];
         
            %validate updated structure
            [val,stype,msg0] = gce_valid(s2,'data');

            %clear structure and generate error message if invalid
            if val ~= 1
               s2 = [];
               msg = ['updated structure is invalid (',msg0,')'];
            end
         
         else
            msg = 'no differences were found in metadata content';
         end
         
      else
         msg = 'invalid column selections';
      end
      
   else
      msg = 'one or both data structures are invalid';
   end   
   
else
   msg = 'insufficient arguments for function';
end