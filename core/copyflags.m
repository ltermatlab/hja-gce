function [s2,msg] = copyflags(s,flagcols,datacols,opt)
%Copies composite flags from one or more columns and adds to or replaces the existing flag arrays
%of one or more other columns (used to propagate flags to dependent/calculated columns).
%
%syntax: [s2,msg] = copyflags(s,flagcols,datacols,opt)
%
%inputs:
%  s = data structure to modify
%  flagcols = array of column numbers or names containing flags to apply
%    (if length > 1, a composite flag array will be created and populated
%     in array order)
%  datacols = array of column numbers or names in which to apply the flags
%  opt = update option:
%    'replace' = replace all existing flags with new flag array
%    'add' = add flag array to existing flags (overwriting only flags for
%       rows in common) (default)
%
%outputs:
%  s2 = modified structure (or original structure if no flags assigned in 'flagcols')
%  msg = text of any error message
%
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
%last modified: 24-Feb-2015

s2 = [];
msg = '';

if nargin >= 3
   
   if gce_valid(s,'data')
      
      %set default option if omitted/invalid
      if exist('opt','var') ~= 1
         opt = 'add';
      elseif ~strcmp(opt,'replace')
         opt = 'add';
      end
      
      %look up string flag column names
      if ~isnumeric(flagcols)
         flagcols = name2col(s,flagcols);
      end
      
      %look up string data column names
      if ~isnumeric(datacols)
         datacols = name2col(s,datacols);
      end
      
      %check for valid flag and data columns
      if ~isempty(flagcols) && ~isempty(datacols)
         
         %check for non-overlapping column selections
         if isempty(intersect(flagcols,datacols))
            
            %copy structure to output
            s2 = s;
            
            %get index of columns with flags assigned
            Iflags = find(~cellfun('isempty',s2.flags(flagcols)));
            
            %check for flags to copy
            if ~isempty(Iflags)
               
               %initialize allflags array using first set of flags
               allflags = s2.flags{flagcols(Iflags(1))};  
               
               %remove extra flag columns
               allflags = allflags(:,1); 
               
               %loop through remaining flag columns
               for n = 2:length(Iflags)
                  flags = s2.flags{flagcols(Iflags(n))};
                  flags = flags(:,1);
                  Inoflags = find(allflags(:,1)==' ');
                  Inewflags = find(flags(Inoflags,1)~=' ');
                  if ~isempty(Inoflags) && ~isempty(Inewflags)  %apply nested index to add new flags to empty slots
                     allflags(Inoflags(Inewflags),1) = flags(Inoflags(Inewflags),1);
                  end
               end
               
               %build index of non-empty composite flags
               Iallflags = find(allflags(:,1)~=' ');  
               
               %check for any flags to update
               if ~isempty(Iallflags)
                  
                  %update flag assignments on target
                  if strcmp(opt,'replace')
                     for n = 1:length(datacols)
                        s2.flags{datacols(n)} = allflags;
                     end
                  else
                     for n = 1:length(datacols)
                        flags = s2.flags{datacols(n)};
                        if isempty(flags)
                           s2.flags{datacols(n)} = allflags;
                        else
                           flags(Iallflags,1) = allflags(Iallflags,1);
                           for m = 2:size(flags,2)
                              flags(Iallflags,m) = repmat(' ',length(Iallflags),1);
                           end
                           s2.flags{datacols(n)} = flags;
                        end
                     end
                  end
                  
                  %set criteria to manual
                  for n = 1:length(datacols)
                     if isempty(strfind(s2.criteria{datacols(n)},'manual'))
                        if isempty(s2.criteria{datacols(n)})
                           s2.criteria{datacols(n)} = 'manual';
                        else
                           s2.criteria{datacols(n)} = strrep([s2.criteria{datacols(n)},';manual'],';;',';');
                        end
                     end
                  end
                  
                  %update processing history and edit date
                  curdate = datestr(now);
                  
                  s2.editdate = curdate;
                  if strcmp(opt,'add')
                     str = ['copied QA/QC flags from column(s) ',cell2commas(s.name(flagcols),1), ...
                        ' to column(s) ',cell2commas(s.name(datacols),1), ...
                        ', merging copied flags with any existing flags, and set QA/QC criteria ', ...
                        'for destination column(s) to ''manual'' (''copyflags'')'];
                  else
                     str = ['copied QA/QC flags for column(s) ',cell2commas(s.name(datacols),1), ...
                        ' to column(s) ',cell2commas(s.name(flagcols),1), ...
                        ', overwriting any existing flags, and set QA/QC criteria for destination ', ...
                        'column(s) to ''manual'' (''copyflags'')'];
                  end
                  s2.history = [s2.history ; {curdate},{str}];
                  
               end
               
            end
            
         else
            msg = 'flag column and data column arrays cannot overlap';
         end
         
      end
      
   else      
      msg = 'not a valid GCE Data Structure';
   end
   
else
   msg = 'insufficient arguments for function';
end
