function [s2,msg] = add_transect_dist(s,loncol,latcol,transect,accuracy,disttol)
%Adds trandsect and distance columns to a GCE Data Structure by matching GPS coordinates to transect coordinates
%based on Thalweg lines registered in 'thalweg_ref.mat'
%
%syntax: [s2,msg] = add_transect_dist(s,loncol,latcol,transect,accuracy,disttol)
%
%inputs:
%  s = data structure to modify
%  loncol = name or number of column containing longitudes in decimal degrees ([] = automatically determined)
%  latcol = name or number of column containing latitutdes in decimal degrees ([] = automatically determined)
%  transect = name of a specific transect in 'thalweg_ref.mat' to constrain the matches ('' = any)
%  accuracy = analysis accuracy (sets size of comparison matrix for matching coordinates)
%     1 = low (fastest/default)
%     2 = medium
%     3 = high (slowest)
%  disttol = tolerance in km for maximum distance from reference transect to include in the output
%     (default = 2.5)
%
%outputs:
%  s2 = modified structure
%  msg = text of any error messages
%
%
%(c)2002-2012 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 20-Aug-2012

%init output
s2 = [];
msg = '';

%check for required argument and required function mfile
if nargin >= 1 && (exist('gps2riverdist','file') == 2 || exist('gps2riverdist','file') == 6)
   
   %check for valid data structure
   if gce_valid(s,'data')
      
      %validate longitude column
      if exist('loncol','var') ~= 1
         loncol = [];
      elseif ischar(loncol)
         loncol = name2col(s,loncol);
      elseif ~isempty(loncol) && (loncol <= 0 || loncol > length(s.name))
         loncol = [];
      end
      
      %look up loncol if omitted based on attribute descriptors
      if isempty(loncol)
         loncol = find(strncmpi(s.name,'lon',3) & strcmp(s.variabletype,'coord') & strncmpi(s.units,'deg',3) & ~strcmp(s.datatype,'s'));
         if ~isempty(loncol)
            loncol = loncol(1);
         end
      end
      
      %validate latitude column
      if exist('latcol','var') ~= 1
         latcol = [];
      elseif ischar(latcol)
         latcol = name2col(s,latcol);
      elseif ~isempty(latcol) && (latcol <= 0 || latcol > length(s.name))
         latcol = [];
      end
      
      %look up latcol if omitted based on attribute descriptors
      if isempty(latcol)
         latcol = find(strncmpi(s.name,'lat',3) & strcmp(s.variabletype,'coord') & strncmpi(s.units,'deg',3) & ~strcmp(s.datatype,'s'));
         if ~isempty(latcol)
            latcol = latcol(1);
         end
      end
      
      %set default transect (auto) if omitted
      if exist('transect','var') ~= 1
         transect = '';
      end
      
      %set default accuracy if omitted (medium)
      if exist('accuracy','var') ~= 1
         accuracy = 2;
      end
      
      %set default tolerance if omitted (2.5km)
      if exist('disttol','var') ~= 1
         disttol = 2.5;
      end
      
      %check for loncol and latcol
      if ~isempty(loncol) && ~isempty(latcol)
         
         %extract lon/lat arrays
         lon = extract(s,loncol);
         lat = extract(s,latcol);
         
         %get index of non-NaN coordinates
         Ivalid = find(~isnan(lon) & ~isnan(lat));
         
         if ~isempty(Ivalid)
            
            %call external function to calculate distances
            [distance,river] = gps2riverdist(lon(Ivalid),lat(Ivalid),transect,accuracy,disttol);
            
            if ~isempty(distance) && ~isempty(river)
               
               %check for any valid matched distances
               if ~isempty(find(~isnan(distance)))
                  
                  %calculate starting position for new columns
                  colpos = max(loncol,latcol) + 1;
                  
                  %init full arrays for updating data set
                  river_all = repmat({'NaN'},length(lon),1);
                  dist_all = ones(length(lon),1) .* NaN;
                  
                  %add calculations for valid coordinates to master arrays
                  river_all(Ivalid) = river;
                  dist_all(Ivalid) = distance;
                  
                  %add Transect
                  s2 = addcol(s,river_all,'Transect','none','Transect name based on Thalweg line geographic lookup', ...
                     's','nominal','none',0,'',colpos);
                  
                  %add Transect_Distance
                  s2 = addcol(s2,dist_all,'Transect_Distance','km','Transect distance based on Thalweg line geographic lookup', ...
                     'f','calculation','continuous',2,'',colpos+1);
                  
                  %confirm structure validity
                  if gce_valid(s2,'data')
                     
                     %generate history entry
                     if isempty(transect)
                        transect_string = 'for any transect';
                     else
                        transect_string = ['for the ',transect,' transect'];
                     end
                     s2.history = [s.history ; ...
                           {datestr(now)},{['added columns Transect and Transect_Distance at position ',int2str(colpos), ...
                                 ' based on matching geographic coordinates in columns ', ...
                                 s.name{loncol},' and ',s.name{latcol},' to the closest Thalweg line coordinates ',transect_string, ...
                                 ' in ''thalweg_ref.mat'' within a tolerance of ',num2str(disttol),' km (''add_river_dist'')']}];
                     
                  else
                     msg = 'errors occurred adding the transect and distanct columns to the structure';
                  end
                  
               else
                  msg = 'transect distances could not be determined for these coordinates';
               end
               
            else
               msg = 'no valid coordinates in latitude and longitude columns';
            end
            
         else
            msg = 'transect distances could not be determined for these coordinates';
         end
         
      else
         msg = 'latitude and/or longitude columns are invalid or could not be determined';
      end
      
   else
      msg = 'invalid data structure';
   end
   
else
   
   if nargin > 0
      msg = 'required function ''gps2riverdist'' is not present';
   else
      msg = 'insufficient arguments for function';
   end
   
end