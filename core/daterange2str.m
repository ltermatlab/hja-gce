function str = daterange2str(dt,I_dt,fmt,datesep)
%Generates textual descriptions of ranges of serial dates based on a selection index
%(called by add_anomalies to generate date ranges for missing/flagged values)
%
%syntax: str = daterange2str(dt,I_dt,format,datesep)
%
%inputs:
%  dt = sorted array of MATLAB serial dates (see 'datenum')
%  I_dt = logical index of dates to describe
%  format = date format to use (default = 23 for 'mm/dd/yyyy'; see 'datestr' for options)
%  datesep = character used to separate date range limits (default = '-', e.g. 1/1/2004-1/5/2004)
%
%outputs:
%  str = character array containing the textual description of the date range(s)
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
%last modified: 05-Apr-2004

str = '';

if nargin >= 2

   if exist('I_dt','var') ~= 1
      I_dt = [1:length(dt)]';
   else
      I_dt = I_dt(:);
   end

   if exist('fmt','var') ~= 1
      fmt = '';
   end

   mlver = version;
   if isempty(fmt)
      if ~strcmp(mlver(1),'5')
         fmt = 23;
      else
         fmt = 2;
      end
   else  %test format option, default to 24 if invalid
      try
         datestr(now,fmt);
      catch
	      if ~strcmp(mlver(1),'5')
   	      fmt = 23;
      	else
         	fmt = 2;
	      end
      end
   end

   if exist('datesep','var') ~= 1
      datesep = '-';
   end

   if ~isempty(I_dt) & ~isempty(dt)

      %calculate skips in the index, returning an array containing the start of each new segment
      Iskips = [0 ; find(diff(I_dt)>1)] + 1;

      if length(Iskips) > 1  %check for multiple ranges

         laststr = '';  %init last string buffer

         %loop through pairs of skip indices
         for n = 1:length(Iskips)-1
            if Iskips(n+1)-Iskips(n) > 1  %check for range
               str1 = datestr(dt(I_dt(Iskips(n))),fmt);
               str2 = datestr(dt(I_dt(Iskips(n+1)-1)),fmt);
               if ~strcmp(str1,str2)  %check for differences in formatted date strings
                  str = [str,', ',str1,datesep,str2];
               elseif ~strcmp(str2,laststr)  %check that formatted string doesn't duplicate end of prior range
                  str = [str,', ',str2];
               end
               laststr = str2;  %update buffer
            else  %single date/time
               str1 = datestr(dt(I_dt(Iskips(n))),fmt);
               if ~strcmp(str1,laststr)  %check for non-duplication
                  str = [str,', ',str1];
               end
               laststr = str1;
            end
         end

         %handle last segment
         if Iskips(end) < I_dt(end)  %check for terminal date
            str1 = datestr(dt(I_dt(Iskips(end))),fmt);
            str2 = datestr(dt(I_dt(end)),fmt);
            if ~strcmp(str1,str2)  %check for differences in formatted date strings
               str = [str,', ',str1,datesep,str2];
            elseif ~strcmp(str2,laststr)  %check that doesn't duplicate end of prior range
               str = [str,', ',str1];
            end
            laststr = str2;
         else
            str1 = datestr(dt(I_dt(Iskips(end))),fmt);
            if ~strcmp(str1,laststr)  %check that doesn't duplicate end of prior range
               str = [str,', ',str1];
            end
            laststr = str1;
         end

      else  %no skips - use entire index for range

         str1 = datestr(dt(I_dt(1)),fmt);
         str2 = datestr(dt(I_dt(end)),fmt);
         if ~strcmp(str1,str2)
            str = [', ',str1,datesep,str2];
         else
            str = [', ',str1];
         end

      end

      if ~isempty(str)
         str = str(3:end);  %remove leading comma, space
      end

   end

end