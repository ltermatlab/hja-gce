function msg = poly2thalweg_bnd(fn_poly)
%Updates Thalweg boundary data in 'thalweg_bnd.mat' by parsing polygons from a polygon manager (.ply) file
%
%syntax: msg = poly2thalweg_bnd(transect,fn_poly)
%
%input:
%   fn_poly = polygon manager (.ply) file to import (default = 'thalweg_bnd.ply')
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
   fn_poly = 'thalweg_bnd.ply';
end

if exist(fn_poly,'file') == 2
   
   if exist('thalweg_bnd.mat','file') == 2
      
      %load polygon file
      try
         v = load(fn_poly,'-mat');
      catch
         v = struct('null','');
      end
      
      %check for recnognized polygon data structure
      if isfield(v,'polydata')
         
         %load Thalweg boundary data
         try
            v_bnd = load('thalweg_bnd.mat','-mat');
         catch
            v_bnd = struct('null','');
         end
         
         %extract polygon arrays
         polydata = v.polydata;         
         names = polydata.list';
         bounds = polydata.data';

         %get transect names == variable names in boundaries file
         transects = fieldnames(v_bnd);
         matches = transects;
         
         %match transect names, updated Thalweg bounds
         for n = 1:length(transects)
            transect = transects{n};
            Imatch = find(strncmpi(transect,names,length(transect)));
            if length(Imatch) == 1
               v_bnd.(transect) = bounds{Imatch,:};
            else
               matches{n} = '';  %clear transect match entry
            end
         end
         
         %check for any valid matches
         matches = matches(~cellfun('isempty',matches));
         
         %save updates or generate error message
         if ~isempty(matches)
            fn = which('thalweg_bnd.mat');
            save(fn,'-struct','v_bnd')
            msg = ['successfully updated Thalweg boundaries for transects ',cell2commas(matches,1)];
         else
            msg = 'failed to match any transects in ''thalweg_bnd.mat''';
         end         
         
      else
         msg = 'unsupported polygon file structure';
      end
      
   else
      msg = 'the Thalweg boundaries file ''thalweg_bnd.mat'' was not found in the search path';
   end
   
else
   msg = 'a valid polygon file is required';
end
