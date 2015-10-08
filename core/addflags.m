function [s2,msg] = addflags(s,Icols,Irows,flag,flagdef)
%Adds manual qualifier flags to all or selected records in one or more columns of a GCE Data Structure
%
%syntax: [s2,msg] = addflags(s,cols,rows,flag,flagdef)
%
%input:
%   s = data structure to update (struct, required)
%   Icols = array of column names or numeric indicies to update (numeric or cell array of strings, required)
%   Irows = array of row numbers to update (numeric array, required, [] = all)
%   flag = flag character or array of flags matching Irows to assign (character or cell array, required) 
%   flagdef = flag definition to document in the metadata if flag not already defined (string, optional)
%
%output:
%  s2 = updated structure
%  msg = text of any error message
%
%(c)2010-2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 08-Apr-2015

%init output
s2 = [];
msg = '';

%check for required input
if nargin >= 4 && ~isempty(flag)
   
   %check for omitted flagdef
   if exist('flagdef','var') ~= 1 || isempty(flagdef)
      flagdef = 'undefined';
   end
   
   %check for cell array of flags, convert to character array
   if iscell(flag)
      try
         flag = char(flag);
      catch
         flag = '';
      end
   end
   
   %check for valid data structure and flag array
   if gce_valid(s,'data') && ~isempty(flag)
      
      %look up column indices if non-numeric
      if ~isnumeric(Icols)
         Icols = name2col(s,Icols);
      end
      
      %validate row index
      numrows = num_records(s);
      if isempty(Irows)
         %default to all rows if omitted
         Irows = (1:numrows)';
      else
         %remove invalid or duplicate row selections
         Irows = unique(Irows(Irows >= 1 & Irows <= numrows));
      end
      
      %check for valid columns rows
      if ~isempty(Icols) && ~isempty(Irows) && ~isempty(flag) && (size(flag,1) == 1 || size(flag,1) == length(Irows))
         
         %assign original structure as output
         s2 = s;
         
         %add flag definition if not already assigned
         s2 = add_flagdef(s2,flag,flagdef);
         
         %init flag array to add
         if size(flag,1) == 1
            %expand flag array to match Irows
            flags_add = repmat(flag,length(Irows),1);
         else
            flags_add = flag;
         end
            
         %loop through columns and update flags
         for n = 1:length(Icols)
            
            %extract column index and flags
            col = Icols(n);
            flags = s2.flags{col};

            %generate new flag array
            if isempty(flags)
               
               %no existing flags - create empty flag array
               flagsize2 = size(flags_add,2);
               flags = repmat(' ',numrows,flagsize2);
               
               %update empty flag array with new flags
               flags(Irows,1:flagsize2) = flags_add;
               
            else  %existing flags - replace rows with specified flag               
               
               %get flag array widths to check compatibility
               flagsize1 = size(flags,2);
               flagsize2 = size(flags_add,2);
               
               %pad flag arrays as necessary
               if flagsize2 < flagsize1
                  %pad new flags to match existing
                  flags_add = [flags_add , repmat(' ',size(flags_add,1),flagsize1-flagsize2)]; 
               elseif flagsize2 > flagsize1
                  %padd existing flags to match new
                  flags = [flags , repmat(' ',size(flags,1),flagsize2-flagsize1)];
               end
               
               %update flag array with new flags
               flags(Irows,1:flagsize2) = flags_add(:,1:flagsize2);
               
            end
            
            %update stored flags
            s2.flags{col} = flags;
            
         end

         %generate history entry
         if size(flag,1) == 1
            str_hist = ['manually added ''',flag,''' flags to ',int2str(length(Irows)),' records in column(s) ', ...
               cell2commas(s2.name(Icols),1),' (''addflags'')'];
         else
            str_hist = ['manually added an array of custom flags to ',int2str(length(Irows)),' records in column(s) ', ...
               cell2commas(s2.name(Icols),1),' (''addflags'')'];
         end
         
         %update processing history         
         s2.history = [s2.history ; {datestr(now),str_hist}];
         s2.editdate = datestr(now);

         %lock flags
         s2 = flag_locks(s2,'lock',Icols);
         
      else  %bad cols or rows
         
         if isempty(Icols)
            msg = 'invalid column selection';
         elseif isempty(Irows)
            msg = 'invalid row selection';
         else
            msg = 'flag array size does not match row selection';
         end
         
      end
      
   else
      msg = 'invalid data structure';
   end
   
else
   msg = 'insufficient arguments for function';
end