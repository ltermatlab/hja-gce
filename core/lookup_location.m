function location = lookup_location(loc,reffile)
%Returns details for a specific geographic location registered in 'geo_locations.mat'
%
%syntax: location = lookup_location(loc,reffile)
%
%inputs:
%  loc = location name to look up
%  reffile = name or fully-qualified pathname of the reference database file to use (default = 'geo_locations.mat')
%    (note: file must contain a MATLAB structure named 'locations' with text field 'Location')
%
%outputs:
%  location = structure containing all fields in reffile:locations matching the specified location name
%
%
%(c)2012 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 02-Feb-2012

%init output
location = [];

if nargin >= 1
   
   %supply default reference file if omitted
   if exist('reffile','var') ~= 1
      reffile = 'geo_locations.mat';
   end
   
   %validate location string and reffile
   if ischar(loc) && exist(reffile,'file') == 2
      
      try
         v = load(reffile,'-mat');
      catch
         v = struct('null','');
      end
      
      %check for valid locations database
      if isfield(v,'locations')
         
         locations = v.locations;
         
         %validate locations structure
         if isstruct(locations) && isfield(locations,'Location')
            
            idx = find(strcmp(loc,{locations.Location}'));
            
            if length(idx) >= 1               
               location = locations(idx);
            end
            
         end
         
      end
         
   end
   
end
