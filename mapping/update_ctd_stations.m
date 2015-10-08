function msg = update_ctd_stations(fn_thalweg)
%Updates CTD stations in 'ctd_stations.mat' based on Thalweg reference transects
%
%syntax: msg = update_ctd_stations(fn_thalweg)
%
%input:
%   fn_thalweg = Thalweg reference transect file to import (default = 'thalweg_ref.ply')
%
%output:
%   msg = status message
%
%notes:
%   1) transects will be matched based on polygon names (ignoring type and date information)
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
%last modified: 19-Apr-2012

if nargin == 0
   fn_thalweg = 'thalweg_ref.mat';
end

if exist(fn_thalweg,'file') == 2
   
   if exist('ctd_stations.mat','file') == 2
      
      %load ctd station structure
      try
         v_ctd = load('ctd_stations.mat','-mat');
      catch
         v_ctd = struct('null','');
      end
      
      if isfield(v_ctd,'transects')
         
         %get transects structure
         transects = v_ctd.transects;
         
         %get river names to match to Thalweg variables, removing spaces
         rivers = strrep({transects.river}',' ','');
         
         %load polygon file
         try
            v_ref = load(fn_thalweg,'-mat');
         catch
            v_ref = struct('null','');
         end
         
         %get transect names from variables in Thalweg file
         flds = fieldnames(v_ref);
         matches = flds;  %init matches
         
         %match transects and update CTD data
         for n = 1:length(flds)
            Imatch = find(strcmpi(flds{n},rivers));
            if length(Imatch) == 1
               coords = v_ref.(flds{n});  %get coordinates from Thalweg variable
               defaults = transects(Imatch).default;  %get default stations
               transects(Imatch).transect = v_ref.(flds{n});  %update transect coordinates
               transects(Imatch).default = [defaults(1) fix(coords(end,3)./2).*2 defaults(3)];  %update max station for defaults
            else
               matches{n} = '';  %clear match
            end
         end
         
         %check for any valid matches
         matches = matches(~cellfun('isempty',matches));
         
         %save updates or generate error message
         if ~isempty(matches)
            fn = which('ctd_stations.mat');
            save(fn,'transects')
            msg = ['successfully updated CTD stations for transects ',cell2commas(matches,1)];
         else
            msg = 'failed to match any transects';
         end         
         
      else
         msg = 'unrecognized CTD station format in ''ctd_stations.mat''';
      end
      
   else
      msg = '''ctd_stations.mat'' was not found in the MATLAB search path';
   end
   
else
   msg = 'invalid or missing Thalweg reference transect file';   
end