function msg = list_harvesters
%Lists active MATLAB timer objects created by start_harvesters.m
%
%syntax: msg = list_harvesters
%
%inputs:
%   none
%
%outputs
%   msg = character array listing the names and status of all timer objects
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
%last modified: 03-Jul-2013

%get handles of all timer objects
h = timerfindall;
num = length(h);

%check for any timers
if num > 0
   
   %init states
   states = repmat({''},num,1);
   
   %loop through timers getting status info
   for n = 1:num
      
      %get timer handle from array
      t = h(n);

      %get timer metadata
      t_name = get(t,'Name');
      t_period = get(t,'Period');
      t_running = get(t,'Running');
      t_tasks = get(t,'TasksExecuted');
      states{n} = [t_name,': running = ',t_running, ...
         ', period = ',num2str(t_period),' sec', ...
         ', tasks = ',int2str(t_tasks)];
      
      %get index of valid Data Turbine timers
      Ivalid = find(~cellfun('isempty',states));
      
      %generate output message
      if ~isempty(Ivalid)
         msg = char(states(Ivalid));
      else
         msg = 'no Data Turbine harvest timers were found';
      end
      
   end
   
else
   msg = 'no harvest timers were found in memory';
end