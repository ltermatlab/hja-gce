function [I_inc,msg,qry] = query_index(s,qry)
%Returns an index of rows in a GCE Data Structure matching a query statement
%
%syntax: [I_inc,msg,qry] = query_index(s,qry)
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
%  I_inc = index of matched rows in the original structure
%  msg = text of any error messages
%  qry = final query string after any substitutions
%
%(c)2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
I_inc = [];
msg = '';

%check for required arguments
if nargin == 2
   
   %check for valid data structure and non-empty query
   if gce_valid(s,'data') && ischar(qry) && ~isempty(qry)
      
      %replace delimiters with ampersands
      qry = strrep(qry,';',' & ');
      
      %initialize variables
      err = 0;
      
      %get list of column names in reverse length order for column name substitution
      colnames = s.name;
      [~,Isort] = sort(cellfun('length',colnames));  %get sorted array of colname lengths
      Isort = fliplr(Isort);  %flip sort index for longest names first
      
      %replace column names with array references to prevent problems if column names match reserved terms
      for n = 1:length(Isort)
         
         %get column name and position index as strings
         colstr = int2str(Isort(n));
         colname = colnames{Isort(n)};
            
         %replace column placeholder in query with structure data array reference
         qry = strrep(qry,['col',colstr],['s.values{',colstr,'}']);
         
         %check for existance of column name in query
         if strfind(qry,colname)
            
            %check for string comparison function references
            if ~isempty(strfind(qry,'strcmp')) || ~isempty(strfind(qry,'strncmp')) || ~isempty(strfind(qry,'strmatch'))
               escapeflag = 1;  %set flag for escaping string search terms that partially column names
            else
               escapeflag = 0;
            end
            
            %escape col name in text criteria wrapped in quotes (at beginning or end of string)
            if escapeflag == 1
               qry = strrep(qry,[colname,''''],'----');
               qry = strrep(qry,['''',colname],'====');
            end
            
            %replace column name in query with structure data array reference
            qry = strrep(qry,colname,['s.values{',colstr,'}']);
            
            %unescape column name in text criteria
            if escapeflag == 1
               %restore col name in text criteria
               qry = strrep(qry,'----',[colname,'''']);
               qry = strrep(qry,'====',['''',colname]);
            end
            
         end
         
      end
      
      %evaluate query
      try
         eval(['I_inc = find(',qry,');'])
      catch e
         err = 1;
      end
      
      %check for query failure - try operator substitution
      if err == 1
         
         %perform natural language syntax subsitutions
         qry = strrep(qry,'~=','<>');  %protect '~=' from '=' substitution
         qry = strrep(strrep(qry,'=','=='),'====','==');  %2-stage conversion for '='
         qry = strrep(qry,'<>','~=');  %convert/revert to '~='
         qry = strrep(qry,'<==','<='); %fix munged <=
         qry = strrep(qry,'>==','>='); %fix munged >=
         qry = strrep(qry,' and ',' & ');
         qry = strrep(qry,' AND ',' & ');
         qry = strrep(qry,' or ',' | ');
         qry = strrep(qry,' OR ',' | ');
         qry = strrep(qry,' is over ',' > ');
         qry = strrep(qry,' IS OVER ',' > ');
         qry = strrep(qry,' is under ',' < ');
         qry = strrep(qry,' IS UNDER ',' < ');
         qry = strrep(qry,' is not over ',' <= ');
         qry = strrep(qry,' IS NOT OVER ',' <= ');
         qry = strrep(qry,' is not under ',' >= ');
         qry = strrep(qry,' IS NOT UNDER ',' >= ');
         qry = strrep(qry,' is greater than ',' > ');
         qry = strrep(qry,' IS GREATER THAN ',' > ');
         qry = strrep(qry,' is less than ',' < ');
         qry = strrep(qry,' IS LESS THAN ',' < ');
         qry = strrep(qry,' is not greater than ',' <= ');
         qry = strrep(qry,' IS NOT GREATER THAN ',' <= ');
         qry = strrep(qry,' is not less than ',' >= ');
         qry = strrep(qry,' IS NOT LESS THAN ',' >= ');
         qry = strrep(qry,' is not ',' ~= ');
         qry = strrep(qry,' IS NOT ',' ~= ');
         qry = strrep(qry,' is ',' == ');
         qry = strrep(qry,' IS ',' == ');
         qry = strrep(qry,' equals ',' == ');
         qry = strrep(qry,' EQUALS ',' == ');
         qry = strrep(qry,' not ',' ~ ');
         qry = strrep(qry,' NOT ',' ~ ');
         qry = strrep(qry,'~ ','~');  %remove whitespace around tildes from 'not' substitutions
         qry = strrep(qry,'l==t','list');  %undo corruption of 'list'
         qry = strrep(qry,'L==T','LIST');
         
         %re-evaluate query
         try
            eval(['I_inc = find(',qry,');'])
         catch e
            err = 1;
         end
         
      end
      
      %check for any matches
      if isempty(I_inc)
         if err == 1
            msg = ['an error occurred excuting the query (',e.message,')'];
         else
            msg = 'query returned no rows';
         end
      end
      
   else
      if ischar(qry) && ~isempty(qry)
         msg = 'invalid query string';
      else
         msg = 'invalid data structure';
      end
   end
   
else
   msg = 'insufficient arguments';
end