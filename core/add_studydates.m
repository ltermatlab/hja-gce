function [s2,msg] = add_studydates(s,datecol)
%Adds study date metadata descriptors to a GCE Data Structure, based on the range of date values in
%the specified date/time column.
%
%syntax: [s2,msg] = add_studydates(s,datecol)
%
%inputs:
%  s = data structure to modify
%  datecol = name or index of a datetime column (Matlab serial date (base 0),
%    spreadsheet serial date (base 1900), or text compatible with the 'datenum' function)
%
%outputs:
%  s2 = modified structure
%  msg = text of any error message
%
%(c)2002-2010 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 11-Nov-2010

s2 = [];
msg = '';

if nargin >= 1

   if exist('datecol','var') ~= 1
      datecol = [];
   end

   [d,msg] = get_studydates(s,datecol);  %call external function to validate columns, determine retrieve dates
   if ~isempty(d)
      d = d(~isnan(d));  %remove any NaNs before performing calcs
   end

   if ~isempty(d)  %check for valid non-NaN data

      meta = [];

      dstart = datestr(min(d),1);
      dstart0 = lookupmeta(s,'Study','BeginDate');
      if ~strcmp(dstart,dstart0)
         meta = [meta ; {'Study','BeginDate',dstart}];
      end

      dend = datestr(max(d),1);
      dend0 = lookupmeta(s,'Study','EndDate');
      if ~strcmp(dend,dend0)
         meta = [meta ; {'Study','EndDate',dend}];
      end

      if ~isempty(meta)
         [s2,msg] = addmeta(s,meta,1);
         if ~isempty(s2)
            s2.editdate = datestr(now);
            s2.history = [s2.history ; {datestr(now)}, ...
                  {'automatically assigned study date metadata descriptors based on the range of date values in date/time columns (add_studydates)'}];
         end
      else
         s2 = s;  %no change - don't need to update
      end

   else
      s2 = s;  %return unmodified structure
      msg = 'appropriate date/time data values could not be identified in the structure - metadata not updated';
   end

else
   msg = 'insufficient arguments for function';
end