function msg = stop_harvesters(name)
%Stops all or specified harvest timers and deletes the timer object(s) from memory
%
%syntax: msg = stop_harvesters(name)
%
%inputs:
%   name = harvester name to stop (string or cell array, optional; default = '' for any)
%
%outputs
%   msg = status of the timer instantiations
%
%
%(c)2012-2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 22-Jul-2013

%default to all timers if name not specified
if nargin == 0
   name = '';
elseif ischar(name)
   name = cellstr(name);  %convert string name to cell array for looping
end

%check for any running timers
t = timerfind;

if ~isempty(t)
   
   %check for all timer option
   if isempty(name)
      
      stop(t);  
      delete(t);
      msg = ['All ',int2str(length(t)),' running harvest timers were stopped and deleted from memory'];
         
   else   
   
      %init cell array for messages
      c = cell(length(name),1);
      
      %loop through names
      for n = 1:length(name)
         t = timerfind('Name',name{n});
         if ~isempty(t)
            stop(t);
            delete(t);
            c{n} = ['Stopped harvester ''',name{n},''' and deleted it from memory'];
         else
            c{n} = ['Harvester ''',name{n},''' is not running'];
         end
      end
      
      %convert message to character array
      msg = char(c);
      
   end   
   
else
   msg = 'No matching timer objects were found';
end