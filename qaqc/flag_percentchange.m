function Iflag = flag_percentchange(vals,lowlimit,highlimit,framesize,iterations)
%Returns an index of values above or below the mean of preceeding values by the specified percentages
%(forward-only evaluation, with optional recursive analysis to prevent inappropriate flagging of values
%adjacent to outliers)
%
%syntax: Iflag = flag_percentchange(vals,lowlimit,highlimit,framesize,iterations)
%
%inputs:
%  vals = array of values
%  lowlimit = low limit criteria in percent (mean - lowlimit/100) (default = 25)
%  highlimit = high limit criteria in percent (mean + highlimit/100) (default = 25)
%  framesize = number of preceeding values to use for mean calculation (default = 1)
%  iterations = number of flag-check iterations to perform to minimize inappropriate flagging
%    of in-bounds values following out-of-bounds values (default = 1, max = 10; each iteration removes the
%    first flagged value in each repetitively flagged group and re-analyzes the remaining values)
%
%outputs:
%  Iflag = logical index of values outside of the range: mean-lowlimit/100 < value > mean+highlimit/100
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
%last modified: 08-Aug-2013

Iflag = [];

if nargin >= 1
   
   if isnumeric(vals) && ~isempty(vals)
      
      [r,c] = size(vals);
      
      if r == 1 || c == 1
         
         %validate inputs, apply defaults
         if exist('lowlimit','var') ~= 1 || isempty(lowlimit)
            lowlimit = 0.25;
         else
            lowlimit = lowlimit ./ 100;
         end
         
         if exist('highlimit','var') ~= 1 || isempty(highlimit)
            highlimit = 0.25;
         else
            highlimit = highlimit ./ 100;
         end
         
         if exist('framesize','var') ~= 1 || isempty(framesize)
            framesize = 1;
         end
         
         if exist('iterations','var') ~= 1 || isempty(iterations)
            iterations = 1;
         elseif iterations < 1
            iterations = 0;
         elseif iterations > 10
            iterations = 10;
         end
         
         %prep val array
         vals = vals(:);
         len = length(vals);
         
         %initialize indices
         Iall = (1:len)';
         Ibefore = ones(len,framesize) .* NaN;
         
         %generate appropriate logical indices for selection sizes
         for n = 1:framesize
            Ibefore(n+1:len,n) = Iall(1:len-n,1);
            Inan = find(isnan(Ibefore(:,n)));
            if ~isempty(Inan)
               Ibefore(Inan,n) = Iall(Inan);
            end
         end
         
         %populate comparison matrices
         valsbefore = vals(Ibefore);
         if framesize > 1
            mnbefore = mean(valsbefore')';
         else
            mnbefore = valsbefore;
         end
         
         %individually handle means/stds with NaN elements (replace NaNs with value being compared)
         Inan = find(isnan(mnbefore));
         if ~isempty(Inan)
            for n = 1:length(Inan)
               if ~isnan(vals(Inan(n)))
                  vb = valsbefore(Inan(n),:);
                  vb_nonan = vb(~isnan(vb));
                  if ~isempty(vb_nonan)
                     mnbefore(Inan(n)) = mean(vb_nonan);
                  end
               end
            end
         end
         
         %build  index of values violating low limit
         if lowlimit > 0
            Ilow = vals < (mnbefore - mnbefore .* lowlimit);
         else
            Ilow = zeros(len,1);
         end
         
         %build  index of values violating high limit
         if highlimit > 0
            Ihigh = vals > (mnbefore + mnbefore .* highlimit);
         else
            Ihigh = zeros(len,1);
         end
         
         %build logical output matrix
         Iflag = (Ilow == 1 | Ihigh == 1);
         
         %recursively analyze groups of flags, removing the leading flagged value and re-evaluating the remainder
         %in order to unflag inappropriately flagged values following out-of-range values
         if iterations > 0
            Igaps = find(diff(Iflag)==1) + 1;  %get starting index of each flag group based on 0-to-1 transition
            if ~isempty(Igaps)
               vals(Igaps) = NaN;
               Iflag2 = flag_percentchange(vals,lowlimit,highlimit,framesize+1,iterations-1);
               Iunflag = Iflag==1 & Iflag2==0;
               Iflag(Iunflag) = 0;  %clear flags not identified in next iteration
               Iflag(Igaps) = 1;  %reset flags on gaps
            end
         end
         
      end
      
   end
   
end