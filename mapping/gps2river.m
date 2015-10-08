function river = gps2river(lon,lat)
%Matches geographic coordinates to rivers based on bounding polygons in 'thalweg_bnd.mat'
%
%syntax:  river = gps2river(lon,lat)
%
%input:
%  lon = longitude in decimal degrees
%  lat = latitude in decimal degrees
%
%output:
%  river = cell array of river names
%
%
%(c)2000-2012 Wade M. Sheldon
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
%Dept. of Marine Sciences
%University of Georgia
%Athes, GA 30602
%
%last modified: 18-Apr-2012

river = '';

if nargin == 2 && exist('thalweg_bnd.mat','file') == 2
   
   if length(lon) == length(lat)
      
      %format array of coordinates
      coords = [lon(:),lat(:)];
      
      %load boundary polygon data
      try
         v = load('thalweg_bnd.mat','-mat');  
      catch
         v = [];
      end
      
      if isstruct(v)
         
         %get array of river names (variable names in file)
         rivnames = fieldnames(v);
         
         %initialize indices
         I_all = ones(size(coords,1),1);
         I_match = zeros(size(coords,1),1);
         I_null = find(I_all-I_match);      
         river = repmat({''},size(coords,1),1);
         
         %loop through rivers
         for n = 1:length(rivnames)
            
            riv_bnds = v.(rivnames{n});  %extract river boundaries
            
            if isnumeric(riv_bnds) && size(riv_bnds,2) == 2
               
               %get index of locations inside
               I_inside = find(insidepoly(coords(I_null,1),coords(I_null,2),riv_bnds(:,1),riv_bnds(:,2)));
               
               %check for matches
               if ~isempty(I_inside)
                  
                  I_riv = I_null(I_inside);  %get main index positions
                  
                  I_match(I_riv) = 1;  %set match index
                  
                  [river(I_riv)] = deal(rivnames(n));  %update river names
                  
                  I_null = find(I_all-I_match);  %update null index for next matches
                  
                  %check for residual unmatched coordinates, break if all matched
                  if isempty(I_null)
                     break
                  end
                  
               end
               
            end
            
         end
         
      end
      
   end
   
end