function [s2,rows_returned,qry_final,msg,I_inc] = querydata(s,qry)
%Queries values in a GCE Data Structure to return a new data structure containing only rows meeting the criteria
%
%syntax:  [s2,rows,qry_final,msg,I_inc] = querydata(s,query)
%
%inputs:
%  s = GCE-LTER data structure to query (struct; required)
%  qry = a query statement consisting of one or more row selection criteria strings, either
%    combined using parentheses and boolean operations (&,| or AND,OR) or as separate statements
%    concatenated using semicolons (implies AND/&). Data columns can be referenced by name or
%    using the col[#] alias, such as col2 or col10 (string; required)
%      examples:
%        col1>13;col2<20
%        salinity > 30 and temperature >= 20 and temperature <= 30
%        year == 2000 (equivalents: year is 2000, year = 2000)
%        strcmp(Type,'ctd') <-- MATLAB string comparison function syntax (strcmp,strncmp,strmatch,etc)
%
%outputs:
%  s2 = resultant data structure
%  rows_returned = number of rows returned
%  qry_final = final query string after any string or column name substitutions
%  msg = text of any error messages
%  I_inc = index of matched rows in the original structure
%
%(c)2002-2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 15-Jan-2015

%init output
s2 = [];
rows_returned = 0;

%check for required arguments
if nargin == 2
   
   %check non-empty query (note: structure validation done by query_index)
   if isstruct(s) && ischar(qry) && ~isempty(qry)
      
      %get number of original data rows
      numrows = num_records(s);
      
      %call function to clean up and execute query
      [I_inc,msg,qry_final] = query_index(s,qry);
      
      %check for any matches
      if ~isempty(I_inc)
         
         %calculate num rows returned for output
         rows_returned = length(I_inc);
         
         %apply selection index to values, flags
         s2 = copyrows(s,I_inc,'Y');
         
         %update processing history, omitting call to copyrows
         curdate = datestr(now);
         s2.editdate = curdate;
         s2.history = [s.history ; {curdate} ...
            {['query ''',qry,''' run, returned ', ...
            int2str(rows_returned),' of ',int2str(numrows),' data rows (''querydata'')']}];
         
         %update study dates to reflect subsetting if any datetime variables present
         if sum(strcmp(s2.variabletype,'datetime')) > 0
            s_temp = add_studydates(s2);
            if ~isempty(s_temp)
               s2 = s_temp;  %operation succeeded - substitute temp structure for output
            else
               msg = 'query succeeded but study data metadata could not be updated';
            end
         end
         
      end
      
   else
      msg = 'invalid data structure or query string';
   end
   
else
   msg = 'insufficient arguments';
end