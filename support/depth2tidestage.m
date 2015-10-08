function [stage,tidebin,t_high,t_low,a_high,a_low] = depth2tidestage(dt,depth,timestep,polyorder)
%Determines tide stage and sequential tide bin from a time series of depth or pressure data using tide_high_low()
%
%syntax: [stage,tidebin,t_high,t_low,a_high,a_low] = depth2tidestage(dt,depth,timestep,polyorder)
%
%input:
%  dt = serial date array from MATLAB datenum (numeric array; required)
%  depth = measured depth or pressure values for each value of dt (numeric array; required)
%  stagetol = hours before and after tide peak to consider low and high tide stage
%     (number; optional; default = 2)
%  timestep = time step interval for interpolation (minutes, default = 5)
%  polyorder = polynomial order for fitting high and low tide peaks (default = 3)
%
%output:
%  stage = cell array of strings containing text tide stage code:
%    Low = low tide
%    EarlyFlood = early flood tide
%    MidFlood = mid flood tide
%    LateFlood = late flood tide
%    High = high tide
%    EarlyEbb = early ebb tide
%    MidEbb = mid ebb tide
%    LateEbb = late ebb tide
%  tidebin = integer array containing numeric tide stage code:
%    1 = Low
%    2 = EarlyFlood
%    3 = MidFlood
%    4 = LateFlood
%    5 = High
%    6 = EarlyEbb
%    7 = MidEbb
%    8 = LateEbb
%  t_high = array of estimated high tide times
%  t_low = array of estimated low tide times
%  a_high = array of estimated high tide amplitudes
%  a_low = array of estimated low tide amplitudes
%
%(c)2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 20-Feb-2015

stage = [];
tidebin = [];
t_high = [];
t_low = [];
a_high = [];
a_low = [];

%check for required input
if nargin >= 2 && length(dt) == length(depth)
   
   %use default time step if omitted
   if exist('timestep','var') ~= 1 || isempty(timestep)
      timestep = 5;
   end
   
   %use default polynomial order if omitted
   if exist('polyorder','var') ~= 1 || isempty(polyorder)
      polyorder = 3;
   end
   
   %call tide_high_low to generate tide times
   [t_high,t_low,a_high,a_low] = tide_high_low(dt,depth,timestep,polyorder);
   
   if ~isempty(t_high) && ~isempty(t_low)
      
      %pre-pend record for times before first peak (based on subtracting first high/low time difference)
      tidediff = abs(t_low(1)-t_high(1));
      if t_low(1) < t_high(1)
         %add preceding high tide flag
         firstrec = [t_low(1)-tidediff,1];
      else
         %add preceding low tide flag
         firstrec = [t_high(1)-tidediff,0];
      end
      
      %append record for times past last peak
      tidediff = abs(t_low(end)-t_high(end));
      if t_low(end) > t_high(end)
         lastrec = [t_low(end)+tidediff,1];
      else
         lastrec = [t_high(end)+tidediff,0];
      end
      
      %build combined time array, sorted on date
      peaktides = [firstrec ; t_low , zeros(length(t_low),1) ; t_high , ones(length(t_high),1) ; lastrec];
      [~,Isort] = sort(peaktides(:,1));
      peaktides = peaktides(Isort,:);
      
      %dimension output arrays
      stage = repmat({''},length(dt),1);
      tidebin = zeros(length(dt),1);
      
      %loop through peaks assigning stage and bin
      for n = 1:size(peaktides,1)-1
         
         %get time and stage flag
         t1 = peaktides(n,1);
         t2 = peaktides(n+1,1);
         stageflag = peaktides(n,2);
         
         %get indices for times around peak
         tdiffs = linspace(t1,t2,9);
         Ipeak1 = dt > t1 & dt <= tdiffs(2);
         Imid1 = dt > tdiffs(2) & dt <= tdiffs(4);
         Imid2 = dt > tdiffs(4) & dt <= tdiffs(6);
         Imid3 = dt > tdiffs(6) & dt <= tdiffs(8);
         Ipeak2 = dt > tdiffs(8) & dt <= t2;
         
         %find and populate records
         if stageflag == 0
            stage(Ipeak1) = {'Low'};
            stage(Imid1) = {'EarlyFlood'};
            stage(Imid2) = {'MidFlood'};
            stage(Imid3) = {'LateFlood'};
            stage(Ipeak2) = {'High'};
            tidebin(Ipeak1) = 1;
            tidebin(Imid1) = 2;
            tidebin(Imid2) = 3;
            tidebin(Imid3) = 4;
            tidebin(Ipeak2) = 5;
         else
            stage(Ipeak1) = {'High'};
            stage(Imid1) = {'EarlyEbb'};
            stage(Imid2) = {'MidEbb'};
            stage(Imid3) = {'LateEbb'};
            stage(Ipeak2) = {'Low'};
            tidebin(Ipeak1) = 5;
            tidebin(Imid1) = 6;
            tidebin(Imid2) = 7;
            tidebin(Imid3) = 8;
            tidebin(Ipeak2) = 1;
         end
         
      end
               
   end

end