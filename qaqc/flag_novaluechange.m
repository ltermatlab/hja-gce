function Iflag = flag_novaluechange(vals,lowlimit,highlimit,framesize,iterations)
%Returns an index of values that do not differ from the mean of preceeding values by the specified limits
%(forward-only evaluation, with optional recursive analysis to prevent inappropriate flagging of values
%adjacent to outliers)
%
%syntax: Iflag = flag_novaluechange(vals,lowlimit,highlimit,framesize,iterations)
%
%inputs:
%  vals = array of values
%  lowlimit = low limit change criteria (default = 0)
%  highlimit = high limit change criteria (default = 0)
%  framesize = number of preceeding values to use for mean calculation (default = 1)
%  iterations = number of flag-check iterations to perform to minimize inappropriate flagging
%    of in-bounds values following out-of-bounds values (default = 1, max = 10; each iteration removes the
%    first flagged value in each repetitively flagged group and re-analyzes the remaining values)
%
%outputs:
%  Iflag = logical index of values outside of the range: mean-lowlimit < value > mean+highlimit
%
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
%last modified: 24-Apr-2013

Iflag = [];

if nargin >= 1
   
   if isnumeric(vals) && ~isempty(vals)
      
      [r,c] = size(vals);
      
      if r == 1 || c == 1
         
         %validate inputs, apply defaults
         if exist('lowlimit','var') ~= 1
            lowlimit = [];
         end
         if isempty(lowlimit)
            lowlimit = 0;  %set to zero to prevent default override
         end
         
         if exist('highlimit','var') ~= 1
            highlimit = [];
         end
         if isempty(highlimit)
            highlimit = 0;  %set to zero to prevent default override
         end
         
         if exist('framesize','var') ~= 1
            framesize = 1;
         end
         
         if exist('iterations','var') ~= 1
            iterations = 1;
         elseif iterations < 1
            iterations = 0;
         elseif iterations > 10
            iterations = 10;
         end
         
         %call flag_valuechange to get index of values that *do* change by the specified thresholds
         Iflag0 = flag_valuechange(vals,lowlimit,highlimit,framesize,iterations);
         
         %invert index to create index of values that *do not* change by the specified thresholds
         Iflag = ~Iflag0;
         
      end
      
   end
   
end