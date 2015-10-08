function [s2,msg] = insertrows(s,values,cols,pos)
%Inserts rows of new data into specified columns of an existing GCE Data Structure,
%padding corresponding rows in omitted columns with missing values (NaN/empty)
%
%syntax: [s2,msg] = insertrows(s,values,cols,pos)
%
%inputs:
%  s = data structure to modify
%  values = new data rows to add (conventional cell array or cell array arranged as in 'values'
%    field in the GCE Data Structure specification)
%  cols = column assignments for 'values' (default = all if length(values) = length(s.values),
%    required if length(values) < length(s.values))
%  pos = starting row position (0 = top, default = length(s.values{1})+1)
%
%outputs:
%  s2 = modified structure
%  msg = text of any error message
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
%last modified: 24-Nov-2003

s2 = [];
msg = '';

if nargin >= 2

   if gce_valid(s,'data')

      if exist('cols','var') ~= 1
         cols = [1:length(s.name)];
      elseif ~isnumeric(cols)
         cols = name2col(s,cols);
      end

      if exist('pos','var') ~= 1
         pos = length(s.values{1}) + 1;
      end

      if iscell(values)

         if size(values,1) > 1  %convert standard cell array to single row composite array
            tmp = values;
            values = cell(1,size(tmp,2));
            for n = 1:length(values)
               if isnumeric(tmp{1,n})  %check for numeric array, convert to double
                  values{n} = [tmp{:,n}]';
               else
                  values{n} = tmp(:,n);  %leave as cell array of strings
               end
            end
         end

         if (length(values) == length(cols)) & (length(cols) == length(unique(cols)))

            badcol = 0;
            numrows0 = length(s.values{1});
            numrows = size(values{1},1);

            for n = 1:length(s.name)
               vals = s.values{n};
               I = find(cols == n);
               if length(I) == 1
                  newvals = values{I};
                  if ischar(newvals)
                     newvals = cellstr(newvals);
                  end
                  if strcmp(class(vals),class(newvals)) & size(newvals,1) == numrows & size(newvals,2) == 1
                     if strcmp(s.datatype{n},'d')
                        newvals = round(newvals);  %round integers
                     end
                     s.values{n} = [vals ; newvals];
                  else
                     badcol = 1;
                     break
                  end
               else  %no match -- pad with missing values
                  if isnumeric(vals)
                     pad = repmat(NaN,numrows,1);
                  else
                     pad = repmat({''},numrows,1);
                  end
                  s.values{n} = [vals ; pad];
               end
            end

            if gce_valid(s,'data') == 0
               badcol = 1;
            end

            if badcol == 0
               s2 = s;
               if pos == 0 %top
                  Isort = [numrows0+1:numrows0+numrows,1:numrows0]';
               elseif pos < numrows0  %middle
                  Isort = [1:pos-1,numrows0+1:numrows0+numrows,pos:numrows0]';
               else
                  Isort = [];
               end
               if ~isempty(Isort)
                  s2 = copyrows(s2,Isort);
               end
               s2.editdate = datestr(now);
               s2.history = [s.history ; ...
                     {datestr(now)},{['inserted ',int2str(numrows),' new records for column(s) ', ...
                           cell2commas(s.name(cols),1),' starting at position ',int2str(pos),' (''insertrows'')']}];
               s2 = dataflag(s2);  %update Q/C flags
            else
               msg = 'data are not compatible with the specified columns';
            end

         else

            msg = 'invalid column selections or mismatched column list and data array';

         end

      else

         msg = 'invalid values array format';

      end


   else

      msg = 'invalid data structure';

   end

else

   msg = 'insufficient arguments for function';

end