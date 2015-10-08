function str2 = wordwrap(str1,wrap,indent,fmt)
%Wraps lines of text at word breaks with optional indentation
%
%syntax:  str2 = wordwrap(str,col,indent,fmt)
%
%inputs:
%  str = character array or cell array of strings to wrap
%  col = column to wrap text at (default = 80, minimum = 30)
%  indent = number of spaces to preceed each wrapped line (default = 0)
%  fmt = output format:
%    'cell' = cell array (default)
%    'char' = character array
%
%outputs:
%  str2 = character or cell array containing word-wrapped text
%
%
%(c)2002-2011 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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

str2 = [];
tmp = [];

if nargin >= 1

   if exist('fmt','var') ~= 1
      fmt = 'cell';
   end

   if exist('indent','var') ~= 1
      indent = 0;
   end

   if exist('col','var') ~= 1
      col = 80;
   elseif col < 30
      col = 30;
   end

   if isstr(str1)
      str1 = cellstr(str1);
   end

   for n = 1:length(str1);

      str = str1{n};
      len = length(str);

      if len <= wrap

         tmp = [tmp ; {str}];

      else  %wrap overlength line

         %initialize line counter
         linenum = 0;

         %get left margin
         lmarg = length(str) - length(deblank(fliplr(str)));

         %check for minimum left margin + 10 wrap margin
         if wrap < (lmarg + 10)
            error = 1;
            break
         end

         while ~isempty(str)

            linenum = linenum + 1;

            %apply indent if linenum > 1
            if linenum > 1
               pad = lmarg + indent;
            else
               pad = 0;
            end
            str = [blanks(pad) , str ];

            newlen = length(str);

            if newlen > wrap

               %get index of spaces, skipping pad
               Isp = strfind(str(1,pad+1:newlen),' ');

               %calculate right margin
               if ~isempty(Isp)
                  Isp = Isp + pad;  %shift index to account for pad
                  rmarg = min(newlen,min([max(Isp(find(Isp <= wrap))),wrap]));
               else
                  rmarg = min(newlen,wrap);
               end

               %append first line to array
               tmp = [tmp ; {deblank(str(1,1:rmarg))}];

               %trim string
               if newlen > rmarg
                  str = str(1,rmarg+1:newlen);
               else
                  str = '';
               end

            else

               tmp = [tmp ; {str}];
               str = '';

            end

         end

      end

   end

   if strcmp(fmt,'char')
      str2 = char(tmp);
   else
      str2 = tmp;
   end

end
