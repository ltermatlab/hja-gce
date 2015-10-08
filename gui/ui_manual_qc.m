function ui_manual_qc(op,s,cols,h,cb,colwid)
%Opens a GCE Data Structure in a data grid to allow data values and Q/C flags to be viewed and edited
%
%syntax: ui_manual_qc(op,s,cols,h,cb,colwid)
%
%inputs:
%  op = operation to perform ('init' to open the dialog)
%  s = GCE Data Structure to display/edit
%  cols = array of column names or numbers to instantiate flags for editing ([] = all)
%  h = handle of figure or object to use to store a 2-element cell array containing
%    the edited data structure and an integer flag indicating whether any changes were
%    made (flag = 1) or not (flag = 0)
%  cb = function callback to execute after applying edits (note: the edited structure
%    can be returned via callback by referencing the variable 's')
%  colwid = width of grid columns in pixels (default = 100)
%
%output:
%  none
%
%notes:
%  1) if changes are made to any flags, the Q/C criteria will automatically be locked
%     to prevent reversion when Q/C rules are evaluated
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
%last modified: 12-Feb-2013

switch op
   
   case 'init'  %initialized editing grid
      
      %validate input
      if nargin >= 4 && gce_valid(s,'data') && ~isempty(h) && ~isempty(cb)
         
         %set default column width if omitted
         if exist('colwidth','var') ~= 1
            colwid = 100;
         end
         
         %instantiate flags as columns with MFlag_ prefix to avoid conflicts with existing
         if isempty(cols)
            flagcols = 'all';
         else
            flagcols = cols;
         end
         s2 = flags2cols(s,flagcols,0,0,1,0,'MFlag_',0);
         
         %check for success
         if ~isempty(s2)
            
            %init structure for caching data for call to ui_datagrid
            cache = struct('s',s,'h',h,'cb',cb);

            %open structure in data grid
            ui_datagrid('init',s2,h,'ui_manual_qc(''eval'',cache)',colwid,'auto',cache);            
            
         else
            messagebox('init','An error occurred instantiating flags - operation cancelled','','Error',[0.9 0.9 0.9]);
         end
         
      end      
      
   case 'eval'  %evaluate return data
      
      if exist('s','var') == 1
         
         %get cached info from call to ui_datagrid
         cache = s;         
         s = cache.s;
         h = cache.h;
         cb = cache.cb;
         
         %init runtime variables
         data = [];
         h_dlg = [];
         
         %get return data from ui_datagrid and clear cache in figure uicontrol
         if ~isempty(h)
            h_dlg = parent_figure(h);
            if ~isempty(h_dlg)
               figure(h_dlg)
               data = get(h,'userdata');
               set(h,'userdata',[])
            end
         end
         
         %validate return data
         if iscell(data) && length(data) >= 3
            s2 = data{1};
            dirty = data{2};
            log = data{3};
         end
         
         %check for changes
         if dirty == 1
            
            %get names of edited data columns and temporary flag columns
            colchanges = intersect(unique(log(:,1)),s2.name);            
            if ~isempty(colchanges)
               Iflag = strncmp('MFlag_',colchanges,6);
               flagchanges = colchanges(Iflag);
            else
               flagchanges = [];               
            end
            
            %apply flag updates
            if ~isempty(flagchanges)
               s2 = cols2flags(s2,flagchanges,[],1,1,'MFlag_');
            end
            
            %delete unedited manual flag columns
            flagcols = find(strncmp('MFlag_',s2.name,6));
            s2 = deletecols(s2,flagcols);
            
            %restore processing history from original structure to suppress documenting ui_datagrid and cols2flags steps
            %and add entry for manual flag edits
            s2.history = [s.history ; ...
               {datestr(now),['manually edited QA/QC flags for column(s) ',cell2commas(strrep(flagchanges,'MFlag_',''),1), ...
                     ' and reset criteria to prevent automatic recalculation (''ui_manual_qc'')']}];
            s2.editdate = datestr(now);
            
            %remove log entries for temporary flag edits
            log = log(~strncmp('MFlag_',log(:,1),6),:);
            
            %generate log entries for data edits
            if ~isempty(log)            
               
               %init history string
               str = [];
               
               %generate entries
               for n = 1:size(log,1)
                  if strcmp(log{n,1},'delete')
                     if length(log{n,2}) < logopt
                        str = [str ; {['deleted record(s) ',cell2commas(strrep(cellstr(int2str(log{n,2})),' ',''),1)]}];
                     else
                        str = [str ; {['deleted ',int2str(length(log{n,2})),' record(s)']}];
                     end
                  elseif strcmp(log{n,1},'copy')
                     if length(log{n,2}) < logopt
                        str = [str ; {['copied record(s) ',cell2commas(strrep(cellstr(int2str(log{n,2})),' ',''),1), ...
                           ' to position ',int2str(log{n,3})]}];
                     else
                        str = [str ; {['copied ',int2str(length(log{n,2})),' records(s) to position ',int2str(log{n,3})]}];
                     end
                  elseif strcmp(log{n,1},'insert')
                     str = [str ; {['inserted blank record at position ',int2str(log{n,2})]}];
                  else
                     str = [str ; {['changed ''',log{n,1},''' row ',int2str(log{n,2}),' from ',log{n,3},' to ',log{n,4}]}];
                  end
               end
               
               %update history
               s2.history = [s2.history ; ...
                  {datestr(now)},{['edited structure data (''ui_datagrid''): ',cell2commas(str)]}];
                              
            end
            
            %return data to calling dialog
            if ~isempty(h_dlg) && ~isempty(h) && ~isempty(cb)
               
               figure(h_dlg)
               set(h,'UserData',s2)
               try
                  eval(cb)
               catch
                  messagebox('init','An error occurred returning the edited data structure to the original window','','Warning',[0.95 0.95 0.95])
               end
               
            else
               
               ui_editor('init',s2)
               messagebox('init','An error occurred returning the edited data structure to the original window','','Warning',[0.95 0.95 0.95])
            
            end
            
         end
         
      end
      
end