function [s2,msg] = compactcols(s,cols)
%Deletes columns in a data structure in which all values are null/empty
%
%syntax: [s2,msg] = compactcols(s,cols)
%
%inputs:
%  s = data structure to modify
%  cols = array of column names, numbers to evaluate ([] = all)
%
%outputs:
%  s2 = modified structure (= s if no null columns present)
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
%last modified: 19-Jan-2006

s2 = [];
msg = '';

if nargin >= 1
   
   if gce_valid(s,'data')
      
      %validate column selections, apply defaults if omitted
      if exist('cols','var') ~= 1
         cols = [];
      end      
      if isempty(cols)
         cols = [1:length(s.name)];
      elseif ~isnumeric(cols)
         cols = name2col(s,cols);
      end
      
      if ~isempty(cols)
         
         s2 = s;
         Inull = [];
         
         %evaluate data columns
         for n = 1:length(cols)
            vals = s.values{n};
            if iscell(vals)
               if length(find(cellfun('isempty',vals))) == length(vals)
                  Inull = [Inull,cols(n)];
               end
            else
               if length(find(isnan(vals))) == length(vals)
                  Inull = [Inull,cols(n)];
               end
            end
         end
         
         %apply index if empty columns founds
         if ~isempty(Inull)
            str_hist = s.history; %buffer processing history
            [s2,msg] = deletecols(s,Inull);
            if ~isempty(s2)
               if length(s2.name) < length(s.name)
                  if length(Inull) > 1
                     colstr = concatcellcols([repmat({''''},length(Inull),1), ...
                           s.name(Inull)',repmat({''''},length(Inull),1)],'');
                     str = ['deleted empty columns ',cell2commas(colstr,1),' (compactcols)'];
                  else
                     str = ['deleted empty column ''',s.name{Inull},''' (compactcols)'];
                  end
                  s2.history = [str_hist ; {datestr(now)},{str}];
               end
            end
         else
            msg = 'no empty columns were identified';
         end
         
      else
         msg = 'invalid column selection';
      end
      
   else
      msg = 'invalid data structure';
   end
   
else
   msg = 'insufficient arguments';   
end