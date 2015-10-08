function cols = name2col(s,colnames,caseopt,datatype,variabletype,unmatched)
%Returns an array of column index numbers matching the specified list of column names in a GCE-LTER data structure
%
%Notes:
%  1) if more than one column matches the name, only the index of the first instance will be returned
%  2) if multiple names are specified and some are unmatched the return index will not correspond
%     with the name array unless 'unmatched' is set to 1 (i.e. to return NaN for the unmatched names in order)
%
%syntax:  cols = name2col(s,colnames,caseopt,datatype,variabletype,unmatched)
%
%inputs:
%  s = data structure to query
%  colname = array of column names
%  caseopt = case sensitivity option
%    0 = case insensitive (default)
%    1 = case sensitive
%  datatype = datatype option
%    '' = any datatype (default)
%    'f' = floating-point
%    'e' = exponential
%    's' = string
%    'd' = integer
%  variabletype = variable type option
%    '' = any datatype (default)
%    string = specific variable type (e.g. data, calculation, nominal, ordinal, code, datetime, coord, logical, text)
%  unmatched = unmatched variable option
%    0 = do not return NaN for unmatched columns (default for legacy support)
%    1 = return NaN for all unmatched columns
%
%(c)2002-2008 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 08-Jan-2008

cols = [];

if nargin >= 2

   %set defaults for omitted arguments
   if exist('caseopt','var') ~= 1
      caseopt = 0;
   elseif ~isnumeric(caseopt)
      caseopt = 0;
   end

   if exist('datatype','var') ~= 1
      datatype = '';
   end
   
   if exist('variabletype','var') ~= 1
      variabletype = '';
   end
   
   if exist('unmatched','var') ~= 1
      unmatched = 0;
   end
   
   %catch single name - convert to cell array
   if isstr(colnames)
      colnames = cellstr(colnames);
   end

   if gce_valid(s,'data') & iscell(colnames)

      %get column names
      names = s.name;

      %apply case sensitivity option
      if caseopt == 0
         names = lower(names);
         colnames = lower(colnames);
      end
      
      %init datatype, variabletype lookup indices
      I_dt = ones(1,length(names));
      I_vt = I_dt;
      
      %check for specific datatype
      if ~isempty(datatype)
         I_dt = strcmp(s.datatype,datatype);
      end
      
      %check for specific variabletype
      if ~isempty(variabletype)
         I_vt = strcmp(s.variabletype,variabletype);
      end
      
      %apply specific datatype, variabletype filters
      Icols = find(I_dt & I_vt);

      %perform name lookups
      for n = 1:length(colnames)
         Imatch = find(strcmp(names(Icols),colnames{n}));
         if ~isempty(Imatch)
            cols = [cols,Icols(Imatch(1))];  %return first match
         elseif unmatched == 1
            cols = [cols,NaN];  %add NaN for unmatched parameter
         end
      end

   end
   
end