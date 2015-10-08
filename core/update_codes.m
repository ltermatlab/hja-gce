function newmeta = update_codes(meta,colname,codenames,codevals,option)
%Updates value codes defined in the metadata for a column in a GCE Data Structure
%
%syntax: newmeta = update_codes(meta,colname,codenames,codevals,option)
%
%input:
%  meta = metadata array (3-column cell array of categories, field names and field values)
%  colname = column name
%  codenames = cell array of code names
%  codevals = cell array of code values matching codenames
%  output = output option:
%     'fragment' = updated content of Data/ValueCodes only
%     'metadata' = updated metadata array (default)
%
%output:
%  newmeta = updated Data/ValueCodes metadata content
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
%last modified: 12-Oct-2011

newmeta = [];

if nargin >= 4 && iscell(meta) && size(meta,2) == 3
   
   if ~isempty(colname) && ischar(colname)
      
      if iscell(codenames) && iscell(codevals) && length(codenames) == length(codevals)
         
         %set default output option if omitted
         if exist('option','var') ~= 1
            option = 'metadata';
         elseif strcmp(option,'fragment') ~= 1
            option = 'metadata';
         end
         
         %format code definitions for inclusion in metadata (Data/ValueCodes)
         try
            newcodes = [colname,': ',cell2commas(concatcellcols([codenames,codevals],' = ')')];
         catch
            newcodes = [];
         end
         
         if ~isempty(newcodes)
            
            %look up existing code list
            oldcodes = lookupmeta(meta,'Data','ValueCodes');
            
            %generate updated metadata array
            if isempty(oldcodes)
               
               newmeta = ['|',newcodes];  %add sole entry
            
            elseif isempty(strfind(oldcodes,[colname,':']))
            
               newmeta = [oldcodes,'|',newcodes];  %append codes to prior entries
            
            else  %update prior entries
               
               %split code assignments for multiple columns
               if ~isempty(strfind(oldcodes,';'))
                  delim = ';';
               else
                  delim = '|';
               end
               
               %parse code lists for multiple columns
               ar = splitstr(oldcodes,delim);
               
               %get index of specified column
               Imatch = find(strncmp(ar,[colname,':'],length(colname)+1));
               
               %generate new metadata array
               if ~isempty(Imatch)
                  ar(Imatch) = {newcodes};
                  newmeta = ['|',char(concatcellcols(ar','|'))];  %generate updated master code list
               else
                  newmeta = [oldcodes,'|',newcodes];  %parsing failed - just append codes to prior entries
               end
               
            end
            
            %incorporate updated code lists in metadata array if specified
            if strcmp(option,'metadata')
               newmeta = addmeta(meta,{'Data','ValueCodes',newmeta},0,'update_codes');
            end
            
         end
         
      end
      
   end
   
end