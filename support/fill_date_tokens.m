function str2 = fill_date_tokens(str)
%Replaces date/time field tokens in square brackets with current date/time information
%
%syntax: str2 = fill_date_tokens(str)
%
%input:
%  str = original string, potentially containing date/time tokens in square brackets
%
%output:
%  str2 = updated string
%
%notes:
%  1) date/time tokens must be enclosed in square brackets, e.g. 'loggerfile_[yyyymmdd].mat' 
%  2) see 'datestr' help for supported tokens (e.g. yyyy = year, mm = numeric month,
%     mmm = 3-letter month, dd = day, HH = hour, MM = minute)
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
%last modified: 07-Apr-2013

%init output
str2 = '';

if nargin == 1 && ~isempty(str)
   
   %get start/end indices of date/time patterns in str
   [Idstart,Idend] = regexp(str,'\[[-a-zA-Z]+\]');
   num_pat = length(Idstart);
   
   %check for date/time pattern matches
   if num_pat == 0
      
      %no matches - return original string
      str2 = str;
      
   else
      
      %add text before first token
      if Idstart(1) > 1
         str2 = str(1:Idstart(1)-1);
      end
      
      %loop through patterns filling in date/time tokens
      for cnt = 1:num_pat
         
         %extract pattern, resolve and append to output
         dpattern = str(Idstart(cnt)+1:Idend(cnt)-1);
         
         %resolve date/time component
         try
            dstr = datestr(now,dpattern);
         catch
            dstr = dpattern;  %fall back to original string if not valid datestring
         end
         
         %add to output
         str2 = [str2,dstr];
         
         %add intervening or terminal text
         if cnt < num_pat
            %add intervening text between patterns
            str2 = [str2,str(Idend(cnt)+1:Idstart(cnt+1)-1)];
         elseif Idend(end) < length(str)
            %add terminal text
            str2 = [str2,str(Idend(end)+1:end)];
         end
         
      end
      
   end

end