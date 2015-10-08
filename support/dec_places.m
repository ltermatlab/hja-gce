function prec = dec_places(num,maxprec)
%Determines the maximum number of used decimal places in a floating-point array
%up to the specified maximum precision
%
%syntax: prec = dec_places(num,maxprec)
%
%inputs:
%  num = floating-point number to evaluate
%  maxprec = maximum precision to report (default = 12)
%
%outputs:
%  prec = precision
%
%(c)2002-2011 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project-2006 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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

prec = [];

if nargin >= 1

   if exist('maxprec','var') ~= 1
      maxprec = 12;
   end

   if isnumeric(num)

      prec = 0;  %init precision

      for n = 1:length(num)

         x = abs(num(n));   %remove negative sign
         dec = x - fix(x);  %get decimal portion

         if dec ~= 0

            %generate as formatted string to analyze decimal places
            str = fliplr(sprintf(['%0.',int2str(maxprec),'f'],dec));

            %check for last zero in string - break out of loop if maxprec criteria hit
            if ~strcmp(str(1),'0')
               prec = maxprec;
               break
            else
               I = strfind(str,'0');
               Inonzero = find(I-[1:length(I)]);
               if ~isempty(Inonzero)
                  if Inonzero(1) <= maxprec
                     prec = max(prec,maxprec-Inonzero(1)+1);  %update precision if new value > existing
                  else
                     prec = maxprec;
                     break
                  end
               else
                  prec = maxprec;
                  break
               end
            end

         else
            prec = max(prec,0);
         end

      end

   end

end