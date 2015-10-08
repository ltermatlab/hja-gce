function [s2,msg] = deleterows(s,rows,logopt)
%Deletes data from one or more rows in a GCE-LTER data structure to form a new data structure or array.
%
%syntax:  [s2,msg] = deleterows(s,rows,logoption)
%
%inputs:
%   s = original data structure
%   rows = array of rows numbers to delete
%   logoption = maximum number of row deletions to individually log to the structure history
%      (0 for none, inf for all, default = 100)
%
%outputs:
%   s2 = updated data structure
%   msg = text of any error messages
%
%
%(c)2002-2006 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 21-Aug-2006

%initialize outputs
s2 = [];
msg = '';

if nargin >= 2
   
   if exist('logopt','var') ~= 1
      logopt = 100;
   elseif ~isnumeric(logopt)
      logopt = 100;
   elseif logopt <= 0
      logopt = 0;
   end
   
   if gce_valid(s,'data')
      
      if isnumeric(rows)
         
         numrows = length(s.values{1});
         
         Ivalid = find(rows > 0 & rows <= numrows);
         
         if ~isempty(Ivalid)
            
            rows = unique(rows(Ivalid));      
            rows_retain = setdiff([1:numrows]',rows(:));
            
            if ~isempty(rows_retain)
               
               str_hist = s.history;  %buffer history
               [s2,msg] = copyrows(s,rows_retain,'Y');  %use copyrows function on residual rows to perform delete
               
               if ~isempty(s2)
                  
                  %report deletions in processing history
                  if length(rows) > 1
                     str = ['deleted ',int2str(length(rows)),' records from the data set (''deleterows'')'];
                  else
                     str = ['deleted 1 record from the data set (''deleterows'')'];
                  end
                  
                  if length(rows) <= logopt
                     str = [str,'; records: ',cell2commas(strrep(cellstr(int2str(rows(:))),' ',''))];
                  end
                  
                  s2.history = [str_hist ; {datestr(now)},{str}];
                  s2.editdate = datestr(now);
                  
               end
               
            end
            
         else
            msg = 'invalid row selection';
         end
         
      else
         msg = 'invalid row selection';
      end
      
   else
      msg = 'invalid data structure';   
   end
   
else
   msg = 'insufficient arguments';
end