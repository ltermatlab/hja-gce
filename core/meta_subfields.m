function meta2 = meta_subfields(meta)
%Adds supported sub-fields to a GCE Data Toolbox metadata array for improved parsing by meta2struct()
%
%syntax: meta2 = meta_subfields(meta)
%
%input:
%  meta = nx3 cell array of strings containing metadata categories, fields and empty values
%
%output:
%  meta2 = nx3 cell array of strings with supported subfield headings added to the values field
%
%(c)2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 08-Sep-2014

%init output
meta2 = [];

%validate metadata
if exist('meta','var') == 1 && iscell(meta) && size(meta,2) == 3
   
   %init output metadata array
   meta2 = meta;
   
   %list of personnel fields
   fields = {'Dataset','Investigator' ; ...
      'Project','Leaders' ; ...
      'Status','Contact'};
   
   %list of supported subfields
   subfields = {'Name:' ; ...
      'Position:' ; ...
      'Organization:'; ...
      'Address:' ; ...
      'City:'; ...
      'State:'; ...
      'Postal Code:'; ...
      'Phone:' ; ...
      'Email:' ; ...
      'UserID:'};
   
   %generate value string from subfields with linefeed token
   str_subfields = concatcellcols(concatcellcols([repmat({'|'},size(subfields,1),1),subfields(:,1)],'')','');
   
   for n = 1:size(fields,1)
      
      %look up matching fields in meta
      Imatch = find(strcmp(fields{n,1},meta(:,1)) & strcmp(fields{n,2},meta(:,2)));
      
      %add value string to matched fields
      if ~isempty(Imatch)
         meta2(Imatch,3) = str_subfields;
      end
      
   end   
   
end
