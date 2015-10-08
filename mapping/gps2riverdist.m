function [distance,river] = gps2riverdist(lon,lat,river,accuracy,disttol)
%Computes transect distances along Thalweg lines from geographic coordinates 
%using reference transects from 'thalweg_ref.mat'
%
%syntax: [distance,river] = gps2riverdist(lon,lat,river,accuracy,disttol)
%
%input:
%  lon = geographic longitude in decimal degrees
%  lat = geographic latitude in decimal degrees
%  river = river Thalweg line to use ('' = auto-determine using 'gps2river')
%  accuracy = analysis accuracy (sets size of 'trandist' comparison matrix)
%     1 = low (fastest)
%     2 = medium (default)
%     3 = high (slowest)
%  disttol = tolerance in km for maximum distance from reference transect to include in the output
%     (default = 2.5)
%
%output:
%  distance = array of transect distances in km
%  river = cell array of river names
%
%(c)2004-2012 Wade M. Sheldon
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
%Athens, GA 30602
%email: sheldon@uga.edu
%
%last modified: 18-Apr-2012

%init output
distance = [];

if nargin >= 2 && exist('thalweg_ref.mat','file') == 2
   
   %set default accurracy to medium if omitted
   if exist('accuracy','var') ~= 1
      accuracy = 2;
   end
   
   %set default tolerance to 2.5km if omitted
   if exist('disttol','var') ~= 1
      disttol = 2.5;
   end
   
   %set default river selection (auto) if omitted
   if exist('river','var') ~= 1
      river = '';
   end
   
   %validate river, convert to cell array if needed
   if ~isempty(river)
      if ischar(river)
         river = repmat({river},length(lon),1);
      elseif iscell(river)
         if length(river) < length(lon)
            river = repmat(river(1),length(lon),1);  %if insufficient river entries, replicate first entry
         end
      else  %unsupported format
         river = '';
      end
   end
   
   %load reference data set
   try
      v = load('thalweg_ref.mat','-mat');
   catch
      v = [];
   end
   
   if ~isempty(v)
      
      if length(lon) == length(lat)
         
         %force column orientation for lat/lon arrays
         lon = lon(:);  
         lat = lat(:);  
         
         %look up rivers from lat/lon if auto
         if isempty(river)
            river = gps2river(lon,lat);  %run function to perform gross river lookups if not defined
         end

         %init distance array
         distance = ones(length(lon),1) .* NaN;  
         
         if iscell(river)
            
            %get index of matched coords
            Ivalid = find(~cellfun('isempty',river));
            
            if ~isempty(Ivalid)
               
               %get list of unique matched rivers
               rivers = unique(river(Ivalid));
               
               %loop through rivers, processing coordinates in batches
               for n = 1:length(rivers)
                  
                  %check for thalweg data for matched river
                  if isfield(v,rivers{n})
                     
                     ref = v.(rivers{n});  %load respective reference transect from 'thalweg_ref'
                     
                     Iriv = find(strcmp(river,rivers{n}));  %get index of coords in river
                     
                     gps = [lon(Iriv),lat(Iriv)];  %create gps array
                     
                     dist = trandist(gps,ref,accuracy,disttol);  %calculate transect distances with specified accuracy
                     
                     %add distance to master output array
                     if ~isempty(dist)
                        distance(Iriv) = dist;
                     end
                     
                  end
                  
               end
               
            end
            
         end
         
      end
      
   end
   
else
   river = [];   
end