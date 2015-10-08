function Iflag = flag_well_pumping(vals,windowsize,threshold)
%Returns an index indicating records collected during and following well pumping events based on negative spikes in pressure
%
%syntax: Iflag = flag_well_pumping(vals,windowsize,threshold)
%
%inputs:
%  vals = array of depth or pressure values to evaluate
%  windowsize = 2-element array indicating the number of preceding and following records to flag
%     to allow for the effects of pumping to damp out (default = [1 6], i.e. 15 min before and 
%     180 min after for 15 min data)
%  threshold = threshold for identifying spike values, as fraction of the maximum point-to-point
%     devation (default = 0.5 for 50% of maximum deviation)
%
%outputs:
%  Iflag = logical index of values measured during the soaking period
%
%(c)2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 09-Sep-2013

Iflag = [];

if nargin >= 1 && isnumeric(vals)
   
   %validate windowsize
   if exist('windowsize','var') ~= 1 || isempty(windowsize)
      windowsize = [1 6];  %set default
   elseif length(windowsize) < 2
      windowsize = [windowsize(1) windowsize(1)];  %replicate scalar value
   end
   
   %validate threshold
   if exist('threshold','var') ~= 1 || isempty(threshold)
      threshold = 0.5;  %default to 50% max spike
   end
   
   %get point-to-point difference
   del = abs(diff(vals));
   
   %calculate maximum difference
   maxdel = max(del);
   
   %get index of spikes >25% maximum
   Idel = find(del >= maxdel*threshold);
   
   %init flag index
   Iflag = zeros(length(vals),1);
   
   %set flag index for preceding records
   for n = windowsize(1):-1:1
      idx = Idel - n + 1;   %get position index with offset
      idx = idx(idx>0);     %remove negatives (preceding first record)
      if ~isempty(idx)
         Iflag(idx) = 1;
      end
   end
   
   %set flag index for spike record and following records
   maxrec = length(vals);
   for n = 0:windowsize(2)
      idx = Idel + n;
      idx = idx(idx<=maxrec);
      if ~isempty(idx)
         Iflag(idx) = 1;
      end
   end
   
   %convert Iflag to logical array
   Iflag = Iflag == 1;
   
end