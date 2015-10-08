function Imatch = inlist(vals,valuelist,caseopt)
%Matches strings in an array to elements in a specified list and returns a logical index
%
%Lists can be cell arrays of strings, delimited character arrays, attributes in GCE Data Structures,
%or named variables in a MATLAB file
%
%syntax: Imatch = inlist(vals,valuelist,caseopt)
%
%inputs:
%  vals = cell array of string values or delimited character array to test (valid delimiters are
%    semicolons, commas, or spaces)
%  valuelist = list of dis-allowed values, either:
%    1) character array delimited with commas, semi-colons or spaces
%    2) cell array of strings
%    3) GCE data structure containing a value list column (i.e. filename|variable|column,
%       e.g. 'plant_list.mat|data|Plant_Species')
%    4) standard MATLAB file containing a value list cell array (i.e. filename|variable)
%    (note: external files must be in the search path or fully-qualified pathnames must be used)
%  caseopt = check case option
%    'sensitive' = use case-sensitive matches (default)
%    'insensitive' = use non-case sensitive matches
%
%outputs:
%  Imatch = logical index of values in the specified list
%
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
%  sheldon@uga.edu
%
%last modified: 07-Sep-2011

Imatch = [];

if nargin >= 2

   %set case check flag
   if exist('caseopt','var') ~= 1
      checkcase = 1;
   elseif strcmpi(caseopt,'insensitive')
      checkcase = 0;
   else
      checkcase = 1;
   end

   %evaluate delimited string, convert to cell array
   if ischar(vals)
      if ~isempty(strfind(vals,';'))
         vals = splitstr(vals,';');
      elseif ~isempty(strfind(vals,','))
         vals = splitstr(vals,',');
      else
         vals = splitstr(vals,' ');
      end
   end

   if iscell(vals)

      %generate comparison cell array if delimited list, filename specified
      if ischar(valuelist)
         if ~isempty(strfind(valuelist,'|'))  %check for external file syntax
            parms = splitstr(valuelist,'|');  %split filename, variable name, column name
            if length(parms) >= 2
               fn = parms{1};
               if length(parms) == 3  %data structure format
                  var = parms{2};
                  col = parms{3};
               else  %standard file format
                  var = parms{2};
                  col = [];
               end
               valuelist = [];
               if exist(fn,'file') == 2
                  try
                     vars = load(fn,'-mat');
                     if isfield(vars,var)
                        data = getfield(vars,var);
                        if isempty(col)
                           valuelist = data;  %standard file - use variable
                        else
                           valuelist = extract(data,col);  %data structure - extract column
                        end
                        if ~iscell(valuelist)  %validate format
                           valuelist = [];
                        end
                     end
                  end
               end
            end
         else  %try to split delimited array
            if ~isempty(strfind(valuelist,';'))
               valuelist = splitstr(valuelist,';');
            elseif ~isempty(strfind(valuelist,','))
               valuelist = splitstr(valuelist,',');
            else
               valuelist = splitstr(valuelist,' ');
            end
         end
      end

      if ~isempty(valuelist)

         valuelist = unique(valuelist);  %remove dupes

         %init matrix of zeros, with test values as rows, list values as columns
         Imatch = zeros(length(vals),length(valuelist));

         %test for shortest dimension for looping
         if length(vals) > length(valuelist)
            if checkcase == 1
               for n = 1:length(valuelist)
                  Itmp = strcmp(vals,valuelist{n});
                  Imatch(:,n) = Itmp(:);  %update column with string match results
               end
            else  %ignore case
               for n = 1:length(valuelist)
                  Itmp = strcmpi(vals,valuelist{n});
                  Imatch(:,n) = Itmp(:);  %update column with string match results
               end
            end
         else
            if checkcase == 1
               for m = 1:length(vals)
                  Itmp = strcmp(valuelist,vals{m});
                  Imatch(m,:) = Itmp(:)';  %update row with string match results
               end
            else  %ignore case
               for m = 1:length(vals)
                  Itmp = strcmpi(valuelist,vals{m});
                  Imatch(m,:) = Itmp(:)';  %update row with string match results
               end
            end
         end

         %generate logical array for matching strings
         if size(Imatch,2) > 1
            Isum = sum(Imatch')';  %sum matches across rows (requires double inversion)
            Imatch = Isum == 1;
         else
            Imatch = Imatch == 1;
         end

      end

   end

end