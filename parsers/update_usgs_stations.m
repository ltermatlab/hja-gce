function [s,msg] = update_usgs_stations(datatypes)
%Updates the USGS station list by querying the NWIS site inventory
%
%syntax: [s,msg] = update_usgs_stations(datatypes)
%
%input:
%  datatypes = cell array or comma-separated list of data type codes to query
%     'rt' = real-time and recent daily (default)
%     'peak' = peak streamflow
%     'discharge' = daily discharge
%     'qw' = water quality
%     'gw' = groundwater
%     'any' = any type
%
%output:
%  s = USGS station list data set
%  msg = status message
%
%(c)2010-2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 02-Jun-2013

%check for omitted datatypes, default to real-time
if exist('datatypes','var') ~= 1 || isempty(datatypes)
   datatypes = 'rt';
end

%call function to fetch inventory data
[s,msg] = fetch_usgs_inventory('',datatypes);

if ~isempty(s)
   fn = which('usgs_stations.mat');
   if ~isempty(fn)
      pn = fileparts(fn);
   else
      pn = [gce_homepath,filesep,'settings'];
      if ~isdir(pn)
         pn = fileparts(which('update_usgs_stations'));
      end
   end
   data = s;
   save([pn,filesep,'usgs_stations.mat'],'data')
   msg = 'successfully updated USGS stations in ''usgs_stations.mat''';
end