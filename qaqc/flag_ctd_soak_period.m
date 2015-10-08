function Iflag = flag_ctd_soak_period(vals,windowsize,maxdepth)
%Returns an index indicating records collected during the pre-deployment soaking period of a CTD cast
%(note: assumes no missing values in vals)
%
%syntax: Iflag = flag_ctd_soak_period(vals,windowsize,maxdepth)
%
%inputs:
%  vals = array of depth or pressure values to evaluate
%  windowsize = running mean window size for smoothing data prior to identification of 
%    soak-to-cast transition (default = 12)
%  maxdepth = maximum depth to flag as part of the soaking period to prevent excessive
%    flag assignment if transition not detected (default = 2)
%
%outputs:
%  Iflag = logical index of values measured during the soaking period
%
%(c)2002-2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 31-Jul-2013

Iflag = [];

if nargin >= 1

   if exist('windowsize','var') ~= 1
      windowsize = 12;
   end
   
   if exist('maxdepth','var') ~= 1
      maxdepth = 2;
   end
   
   %force column orientation
   vals = vals(:);
   
   %get ending index of top 1/2 of depth/pressure values
   midpt = mean([max(vals),min(vals)]);  %calculate unweighted mean based on min/max
   Imid = min(find(vals>midpt));  
   
   %calculate n-point running mean (working upwards) to smooth out bumps
   mn = running_mean(flipud(vals(1:Imid)),windowsize,1,'forward');
   
   %get differential of depth/pressure
   d = diff(mn);
   
   %calculate index postion of last soak period record
   Idiff = (Imid-1:-1:1);
   Itop = Idiff(min(find(d>=0)));
   
   %generate flag index to return
   flags = zeros(length(vals),1);  %init array
   flags(1:Itop) = 1;  %assign 1 to values during soak

   %reset flags for values > maxdepth if defined
   if maxdepth > 0
      overdepth = vals(1:Itop) > maxdepth;
      Ioverdepth = max(find(overdepth == 0));  %get index of max position where depth <= maxdepth
      if ~isempty(Ioverdepth)
         flags(Ioverdepth:Itop) = 0;
      end
   end
   
   Iflag = flags == 1;  %convert to logical array
   
end

