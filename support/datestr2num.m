function dt = datestr2num(str,fmt)
%Efficiently converts a cell array of date strings to MATLAB serial dates checking for empty strings and duplicates
%
%syntax:  dt = datestr2num(str,fmt)
%
%input:
%  str = cell array of date strings
%  fmt = date format, e.g. 'yyyy-mm-dd HH:MM:SS' (default = '' for any)
%
%output:
%  dt = array of MATLAB serial dates for each entry in str
%
%notes:
%  1) fmt strings will be matched to formats supported by datestr() case-insensitively
%     after removal of time zone suffix strings (e.g. ' (EST)' or ' - GMT')
%  2) when fmt matches a datestr() option, conversion speed will typically be 10x faster
%  3) if fmt does not match the actual data format, auto-detection by datenum() will be
%     used as a fall-back and conversions will be much slower
%
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
%last modified: 08-Mar-2013

%init output
dt = [];

%check for required argument
if nargin >= 1 && iscell(str)
   
   %set default format if omitted
   if exist('fmt','var') ~= 1
      fmt = '';
   end
   
   %init format lookup list
   unit_lookup = {0,'dd-mmm-yyyy HH:MM:SS'; ...
      1,'dd-mmm-yyyy'; ...
      2,'mm/dd/yy'; ...
      3,'mmm'; ...
      4,'m'; ...
      5,'mm'; ...
      6,'mm/dd'; ...
      7,'dd'; ...
      8,'ddd'; ...
      9,'d'; ...
      10,'yyyy'; ...
      11,'yy'; ...
      12,'mmmyy'; ...
      13,'HH:MM:SS'; ...
      14,'HH:MM:SS PM'; ...
      15,'HH:MM'; ...
      16,'HH:MM PM'; ...
      17,'QQ-YY'; ...
      18,'QQ'; ...
      19,'dd/mm'; ...
      20,'dd/mm/yy'; ...
      21,'mmm.dd,yyyy HH:MM:SS'; ...
      22,'mmm.dd,yyyy'; ...
      23,'mm/dd/yyyy'; ...
      24,'dd/mm/yyyy'; ...
      25,'yy/mm/dd'; ...
      26,'yyyy/mm/dd'; ...
      27,'QQ-YYYY'; ...
      28,'mmmyyyy'; ...
      29,'yyyy-mm-dd'; ...
      30,'yyyymmddTHHMMSS'; ...
      31,'yyyy-mm-dd HH:MM:SS'};
   
   %init array of NaN
   dt = ones(length(str),1) .* NaN;
   
   %get indices of non-empty, unique dates
   Ivalid = find(~cellfun('isempty',str));
   
   %check for any non-empty strings to convert
   if ~isempty(Ivalid)
      
      %remove time zone string from fmt
      Itz = regexpi(fmt,'\s+(\(|- )\w{2}(T|C)');
      if ~isempty(Itz)
         fmt = fmt(1:Itz(1)-1);
      end
      
      %check for recognized date units
      Idunits = find(strcmpi(fmt,unit_lookup(:,2)));
      if ~isempty(Idunits)
         convertstr = unit_lookup{Idunits(1),2};
      else
         convertstr = '';
      end
      
      %get only unique dates for efficiency
      [dstr,Iunique,Iorig] = unique(str(Ivalid));

      %init date number array
      numrows = length(dstr);
      dnum = ones(numrows,1) .* NaN;
      
      %group values to reduce memory and boost speed
      gpsize = 10000;
      numgps = ceil(numrows/gpsize);
      for cnt = 1:numgps
         Istart = gpsize .* (cnt-1) + 1;  %start index
         Iend = min(Istart+gpsize-1,numrows);  %end index
         if ~isempty(convertstr)
            try
               %try using date conversion string based on units
               tempvals = datenum(char(dstr(Istart:Iend)),convertstr);
            catch
               try
                  %fall back to auto
                  tempvals = datenum(char(dstr(Istart:Iend)));
               catch
                  tempvals = [];
               end
            end
         else
            try
               %use auto format detection
               tempvals = datenum(char(dstr(Istart:Iend)));
            catch
               tempvals = [];
            end
         end
         if ~isempty(tempvals) && isnumeric(tempvals)
            %update output array with converted values
            dnum(Istart:Iend) = tempvals;
         end
      end
      
      %add calculated dates to output array, resolving unique value index
      if ~isempty(dnum)
         dt(Ivalid) = dnum(Iorig);
      end
      
   end
   
end