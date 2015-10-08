function [dt,msg] = datenum_iso(str,format)
%Generates MATLAB serial dates from ISO date strings in the form 'yyyy-mm-dd HH:MM:SS' or 'yyyymmddTHHMMSS'
%
%syntax: [dt,msg] = datenum_iso(str,format)
%
%input:
%  str = character array or cell array of strings to evaluate
%  format = integer date format style (from 'datestr' function)
%     29 = 'yyyy-mm-dd'
%     30 = 'yyyymmddTHHMMSS' 
%     31 = 'yyyy-mm-dd HH:MM:SS'
%     [] = determined automatically
%
%output:
%  dt = numeric array of MATLAB serial days, where 1 corresponds to 1-Jan-0000
%  msg = error message text (empty character array if no error encountered)
%
%
%(c)2002-2009 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 19-Feb-2009

%init output
dt = [];
msg = '';

if nargin >= 1
   
   if ~isempty(str) && ~isnumeric(str)
      
      %convert scalar character array to string
      if ischar(str)
         str = cellstr(str);
      end
      
      %default to auto format if omitted
      if exist('format','var') ~= 1
         format = [];
      end
      
      %determine format based on delimieters in first date string
      if isempty(format)
         if ~isempty(strfind(str{1},'T'))
            format = 30;
         elseif ~isempty(strfind(str{1},' '))
            format = 29;
         else
            format = 31;
         end         
      end
      
      %determine format string, parameters based on format
      switch format
         case 29
            fstr = '%4u-%2u-%2u';
            parms = 3;
         case 30
            fstr = '%4u%2u%2uT%2u%2u%2u';
            parms = 6;
         case 31
            fstr = '%4u-%2u-%2u %2u:%2u:%2u';
            parms = 6;
         otherwise
            fstr = '';
            parms = 0;            
      end
      
      if parms > 0
      
         %determin array length
         num = length(str);

         %init output
         dt = repmat(NaN,num,1);
         
         baddates = 0;
         
         %evaluate dates
         if parms == 6
            for n = 1:num
               try
                  [yy,mn,dd,hh,mm,ss] = strread(str{n},fstr);
                  dt(n) = datenum(yy,mn,dd,hh,mm,ss);
               catch
                  dt(n) = NaN;
                  baddates = baddates + 1;
               end
            end
         else
            for n = 1:num
               try
                  [yy,mn,hh] = strread(str{n},fstr);
                  dt(n) = datenum(yy,mn,dd);
               catch
                  dt(n) = NaN;
                  baddates = baddates + 1;
               end
            end
         end
         
         if baddates > 0
            msg = [int2str(baddates),' date values could not be parsed'];
         end
         
      else
         msg = 'invalid format specification';
      end
      
   else
      msg = 'invalid date array';
   end
   
else
   msg = 'insufficient arguments';   
end