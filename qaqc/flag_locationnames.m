function Iflag = flag_locationnames(locations,caseopt,emptyopt)
%Returns an index of location code values that are not present in the geographic database 'geo_locations.mat'
%
%syntax: Iflag = flag_locationnames(locations,caseopt,emptyopt)
%
%inputs:
%  locations = cell array of site codes
%  caseopt = check case option
%    'sensitive' = use case-sensitive matches (default)
%    'insensitive' = use non-case sensitive matches
%  emptyopt = empty value option
%    'flag' = flag empty/missing values as unmatched
%    'noflag' = do not flag empty values (default)
%
%outputs:
%  Iflag = logical index of values *not* in the specified list
%
%
%(c)2011 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 24-Aug-2011

Iflag = [];

if nargin >= 1 && iscell(locations) && ~isempty(locations)
   
   %supply defaults for omitted arguments
   if exist('caseopt','var') ~= 1
      caseopt = 'sensitive';
   elseif ~strcmp(caseopt,'insensitive')
      caseopt = 'sensitive';
   end
   
   if exist('emptyopt','var') ~= 1
      emptyopt = 'noflag';
   elseif ~strcmp(emptyopt,'flag')
      emptyopt = 'noflag';
   end
   
   %check for polygons database
   if exist('geo_locations.mat','file') == 2
      
      %load database
      try
         vars = load('geo_locations.mat');
      catch
         vars = struct('null','');
      end
      
      if isfield(vars,'locations')
         
         %extract master list of site codes from polygon database
         all_locs = {vars.locations.Location}';
         
         %call flag function to match locations with specified options
         Iflag = flag_notinlist(locations,all_locs,caseopt,emptyopt);
         
      end
      
   end
   
end