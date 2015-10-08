function [s2,msg,dupe_flag,dt_add] = fill_date_gaps(s,datecol,remove_dupes,repl_nondata)
%Fills in missing date/time records in a time-series data set to create uniform time intervals
%(deprecated - use pad_date_gaps.m instead)
%
%syntax: [s2,msg,dupe_flag,dt_add] = fill_date_gaps(s,datecol,remove_dupes,repl_nondata)
%
%inputs:
%  s = data structure to modify
%  datecol = serial date column (automatically determined if omitted or empty)
%  remove_dupes = option to remove records with duplicated date/time columns,
%    retaining only the first occurance (0 = no/default, 1 = yes)
%    (WARNING - remove_dupes == 1 can seriously compromise non-time-series data sets)
%  repl_nondata = option to replicate values in non-data/non-datetime columns (i.e.
%    variabletype not 'data', 'calculation' or 'datetime') when the values on either
%    side of a date/time gap are identical to avoid NaN/null entries in categorical
%    or geographical fields used for summarizing data (0 = no, 1 = yes/default)
%
%outputs:
%  s2 = modified data structure
%  msg = text of any error or status message
%  dupe_flag = flag indicating whether duplicate values were present preventing
%    gap filling (used by 'ui_editor' to prompt for remove_dupes == 1 option)
%  dt_add = array of MATLAB serial dates added to pad data gaps
%
%notes:
%  1) this function is deprecated and included for backward-compatibility - use
%     pad_date_gaps.m instead
%
%(c)2002-2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 18-Mar-2015

%initialize output
s2 = [];
dupe_flag = 0;

%check for required data structure
if nargin >= 1
   
   %apply defaults for omitted parameters
   if exist('datecol','var') ~= 1
      datecol = [];  %automatic date column lookup
   end
   
   if exist('remove_dupes','var') ~= 1
      remove_dupes = 0;  %do not remove duplicates - throw an error
   end
   
   if exist('repl_nondata','var') ~= 1
      repl_nondata = 1;  %replicate non-data values that are the same before/after gaps
   end
   
   [s2,msg,dupe_flag,dt_add] = pad_date_gaps(s,datecol,remove_dupes,repl_nondata);  %call preferred function   
   
else
   msg = 'Insufficient arguments for function';
end