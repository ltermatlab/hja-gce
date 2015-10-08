function dist = trandist(gps,ref,accuracy,disttol)
%Function for computing upriver distance of coordinates 'gps' relative to reference track 'ref'.
%Assembles matrix of nearby reference coordinates and locates the closest point by minimum direct 
%distance calculation.
%
%syntax:  dist = trandist(gps,ref,accuracy,disttol)
%
%input:
% 'gps' = 2-column array of lon/lat pairs in decimal degrees
% 'ref' = 3-column array of lon/lat pairs and distance
% 'accuracy' = analysis accuracy (sets size of 'trandist' comparison matrix)
%    1 = low (fastest)
%    2 = medium
%    3 = high (slowest)
% 'disttol' = tolerance in km for maximum distance from reference transect to include in the output
%    (default = 2.5)
%
%output:
%  'dist' = 1 column vector of distances in km (note: coordinates > 'disttol' away from
%    'ref' (or 0.1km from termini) return distance values NaN).
%
%
%(c)2004 Wade M. Sheldon
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
%School of Marine Programs
%University of Georgia
%Athens, GA 30602
%email: sheldon@uga.edu
%
%last modified: 04-May-2006

dist = [];

if nargin >= 2
   
   if exist('accuracy') ~= 1              %set default 'fast' if argument not used
      accuracy = 1;
   end
   
   if exist('disttol') ~= 1         %set default minimum distance tolerance to 2.5km
      disttol = 2.5;
   end  
   
   if accuracy == 1                   %set selection size lower limit for iterative mode
      minpts = 80;
   elseif accuracy == 2
      minpts = 160;
   else
      minpts = 320;
   end
   maxpts = minpts * 1.5;            %set selection size upper limit for iterative mode
   
   dist = ones(size(gps,1),1) .* NaN;   %initialize output variable
   
   lastmatch = [0 0 0];
   
   %calculate bounding box limits for validation (bounds + .5km)
   e_bound = max(ref(:,1)) + .0052;
   w_bound = min(ref(:,1)) - .0052;
   s_bound = min(ref(:,2)) - .0045;
   n_bound = max(ref(:,2)) + .0045;
   
   refsize = size(ref,1);
   
   for n = 1:size(gps,1)              %outer loop to pass each pair of values in 'gps'
      
      ln_test = .0012 * (minpts/20);   %reset initial longitude selection criteria (iter. mode)
      lat_test = .001 * (minpts/20);   %reset initial latitude selection criteria (iter. mode)
      newmax = maxpts;                 %reset point selection upper limit (iter. mode)
      index = 0;                       %initialize recycled variables (iter. mode)
      termflag = 0;
      
      %check for inbound points
      if gps(n,1) <= e_bound & gps(n,1) >= w_bound & gps(n,2) >= s_bound & gps(n,2) <= n_bound
         
         if n == 1 | accuracy > 2    %if first coordinate or max accuracy, use iterative selection
            
            iterative = 1;
            
         elseif lastmatch(1) ~= 0    %test for valid previous match
            
            lastmatchdist = gpsdistk(gps(n,1:2),gps(n-1,1:2));
            
            if lastmatchdist <= 0.2    %use points around last match for selection if <0.2km away
               
               iterative = 0;
               
               lastmatchpos = find(ref(:,3)==lastmatch(:,3));
               firstpos = lastmatchpos-minpts./2;
               
               if firstpos <= 1
                  firstpos = 1;
                  termflag = 1;  %selection contains 1st coord in ref - set terminal check flag
               end
               
               lastpos = lastmatchpos+minpts./2;
               
               if lastpos >= refsize
                  lastpos = refsize;
                  termflag = 2;  %selection contains last coord in ref - set terminal check flag
               end
               
               gpsnear = ref(firstpos:lastpos,:);    %form selection array of nearby points in ref
               numref = size(gpsnear,1);
               gpstest = ones(numref,1)*gps(n,1:2);  %form matching test matrix for test coord
               
            else
               
               iterative = 1;  %revert to iterative mode if too far from last coordinate
               
            end
            
         else
            
            iterative = 1;   %revert to iterative if last match not valid
            
         end
         
         if iterative == 1   %choose nearby points in ref iteratively
            
            loops = 1;
            kicks = 0;
            
            while length(index) < minpts | length(index) > newmax
               
               index = find(ref(:,1)>=(gps(n,1)-ln_test) & ref(:,1)<=(gps(n,1)+ln_test)...
                  & ref(:,2)<=(gps(n,2)+lat_test) & ref(:,2)>=(gps(n,2)-lat_test));
               
               if length(index) > newmax           %excess points - reduce boundaries
                  
                  ln_test = ln_test * (minpts./length(index));
                  lat_test = lat_test * (minpts./length(index));
                  loops = loops + 1;
                  
               elseif length(index) < minpts        %too few points - increase boundaries
                  
                  if loops < 5 
                     
                     ln_test = ln_test * 1.1;
                     lat_test = lat_test * 1.1;
                     loops = loops + 1;
                     
                  else  %adjust boundaries unevenly to avoid stable oscillation/infinite loop
                     
                     kicks = kicks + 1;
                     loops = 0;
                     
                     if kicks <= 2
                        
                        ln_test = ln_test*(1+0.05*rand);  
                        lat_test = lat_test*(1+0.05*rand);
                        
                     else   %if 2 adjustments fail to resolve problem, increase selection limits
                        
                        newmax = newmax*2;
                        ln_test = ln_test*(3+0.05*rand);
                        lat_test = lat_test*(3+0.05*rand);
                        
                     end
                     
                  end
                  
               end
               
            end
            
            numref = length(index);
            
            gpsnear = ref(index,:);
            
            gpstest = ones(numref,1)*gps(n,1:2);
            
            if index(1) == 1
               termflag = 1;  %selection contains 1st coord in ref - set terminal coord flag
            elseif index(numref) == refsize
               termflag = 2;  %selection contains last coord in ref - set terminal coord flag
            end
            
         end
         
         %compute distances relative to 'gps'
         
         d = gpsdistk(gpstest,gpsnear(:,1:2));
         
         [mindist,pos] = min(d);       %get index value for minimum distance (closest)
         
         if mindist < 2.5              %test for excessive distance
            
            if mindist < disttol       %test using final distance criterion
               
               if (termflag == 1 & pos == 1) | (termflag == 2 & pos == numref)
                  if mindist <= .1       %only keep distance if close to terminus to avoid overruns
                     dist(n,1) = gpsnear(pos,3);  %return corresponding distance of closest point
                  end
               else  %not terminal point
                  dist(n,1) = gpsnear(pos,3);
               end
               
            end
            
            lastmatch = gpsnear(pos,:);  %buffer matching coordinate
            
         else    %don't return distance -- too far from transect
            
            lastmatch = [0 0 0];  %clear matching coordinate
            
         end
         
      end
      
   end
   
end