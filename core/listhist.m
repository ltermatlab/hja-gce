function str_hist = listhist(data,fmt,wrap,indent)
%Lists the contents of the history field from a GCE-LTER Data Structure
%as a formatted character array, using the date format specified (default = 0)
%
%syntax:  str = listhist(data,dateformat,wrap,indent)
%
%inputs:
%  data = data structure
%  fmt = date format (see 'datestr')
%  wrap = word wrap margin
%    0 = no wrap/default
%    >40 = margin
%  indent = characters to indent after word wrap (default = 0)
%
%outputs:
%  str = character or cell array
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

str_hist = '';

if nargin >= 1

   if exist('indent','var') ~= 1
      indent = 5;
   end

   if exist('wrap','var') ~= 1
      wrap = 0;
   elseif wrap < 40
      wrap = 0;
   end

   if exist('fmt','var') ~= 1
      fmt = 0;
   elseif fmt < 0 | fmt > 18
      fmt = 0;
   end

   if isstruct(data)

      if isfield(data,'history')

         history = data.history;

         if fmt ~= 0
            str_hist = concatcellcols([cellstr(datestr(datenum(char(history(:,1))),fmt)),history(:,2)],': ');
         else
            str_hist = concatcellcols(history,': ');
         end

         if wrap > 0

            tmp = [];

            for n = 1:length(str_hist);

               str = str_hist{n};
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
                        tmp = [tmp ; {str(1,1:rmarg)}];

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

            str_hist = tmp;

         end

         str_hist = char(str_hist);

      end

   end

end
