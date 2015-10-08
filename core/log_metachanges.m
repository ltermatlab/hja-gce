function editstr = log_metachanges(s0,s,fmt)
%Documents changes to attribute metadata fields in a GCE Data Structure after application of a template
%
%syntax: editstr = log_metachanges(s0,s,fmt)
%
%input:
%  s0 = original GCE Data Structure
%  s = updated GCE Data Structure
%  fmt = format option
%    'char' = character array with changes delimited by semicolons (default)
%    'cell' = cell array of changes by field
%
%output:
%  editstr = character or cell array describing attribute metadata changes
%
%(c)2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 20-Mar-2013

%initialize edit history string
editstr = '';

%check for data structure
if isstruct(s0) && isstruct(s)
   
   %default to character array output
   if exist('fmt','var') ~= 1
      fmt = 'char';
   end
   
   %check for text attribute metadata changes
   flds = {'name','units','datatype','variabletype','numbertype','criteria','precision'};
   fldnames = {'Name','Units','Data Type','Variable Type','Numeric Type','Q/C Criteria','Precision'};
   for n = 1:length(flds)
      fld = flds{n};
      try
         str = sub_fieldchanges(s0.(fld),s.(fld),s.name,fldnames{n});
      catch
         str = '';
      end
      if ~isempty(str)
         editstr = [editstr,str];
      end
   end
   
   %check for description changes, log changes without detail
   try
      Ied = find(~strcmp(s0.description,s.description));
   catch
      Ied = [];
   end
   if ~isempty(Ied)
      if length(Ied) > 1
         editstr = [editstr,'Descriptions of columns ',cell2commas(s.name(Ied),1),' edited; '];
      else
         editstr = [editstr,'Description of column ',s.name{Ied},' edited; '];
      end
   end
   
   %format output
   if ~isempty(editstr)
      if strcmp(fmt,'cell')
         editstr = splitstr(editstr,'|');  %convert to cell array
      else
         editstr = strrep(editstr(1:end-1),'|',';');  %convert pipe delimiter to semi-colons
      end
   end
   
   
end

return


function editstr = sub_fieldchanges(meta_ar,meta_ar2,colnames,fldname)
%Check for attribute metadata changes, update and generate history entry
%
%input:
%  meta_ar = array of original structure attribute descriptors
%  meta_ar2 = array of revised attribute descriptors
%  fldname = field name string to use for describing metadata updates in history
%
%output:
%  meta_ar = updated metadata array
%  editstr = history entry (character array)

%init str_update
editstr = '';

%get index of field changes
if iscell(meta_ar)
   Ied = find(~strcmp(meta_ar,meta_ar2));
else
   Ied = find(meta_ar~=meta_ar2);
end

%check for any changes
if ~isempty(Ied)
   
   %init cell array for edit entries
   str_temp = repmat({''},1,length(Ied));
   
   %loop through changes
   if strcmpi(fldname,'name')
      for n = 1:length(Ied)
         str_temp{n} = ['Name of column ',meta_ar{Ied(n)},' changed to ',meta_ar2{Ied(n)},'; '];
      end
   elseif iscell(meta_ar)
      for n = 1:length(Ied)
         str_temp{n} = [fldname,' of column ',colnames{Ied(n)},' changed from ''', ...
            meta_ar{Ied(n)},''' to ''',meta_ar2{Ied(n)},'''; '];
      end
   else
      for n = 1:length(Ied)
         str_temp{n} = [fldname,' of column ',colnames{Ied(n)},' changed from ', ...
            num2str(meta_ar(Ied(n))),' to ',num2str(meta_ar2(Ied(n))),'; '];
      end
   end
      
   %convert cell to character array
   editstr = [str_temp{:},'|'];
   
end
