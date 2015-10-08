function [s2,msg] = add_history(s,str,fcn)
%Adds an entry to the data structure processing history
%
%syntax: [s2,msg] = add_history(s,str,fcn)
%
%input:
%  s = data structure to modify
%  str = string to add to the processing history
%  fcn = function name to reference in the processing history (default = '')
%
%output:
%  s2 = updated structure
%  msg = text of any error message
%
%
%(c)2009 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 16-Dec-2009

%init output
s2 = [];
msg = '';

if nargin >= 2
   
   if gce_valid(s,'data')
      
      s2 = s;  %copy input structure
      
      curdate = datestr(now);  %cache formatted date
      
      s2.editdate = curdate;  %update edit date field
      
      %append function name to string
      if exist('fcn','var') == 1
         str = [str,' (''',fcn,''')'];
      end
      
      %update processing history
      s2.history = [s2.history ; {curdate},{str}];
      
   end
   
else
   msg = 'insufficient arguments';
end