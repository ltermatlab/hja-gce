function Iflag = flag_nsigma(vals,lowlimit,highlimit,framesize,iterations)
%Returns an index of values above or below the mean of preceeding values by the specified number of standard deviations
%(forward-only evaluation, with optional recursive analysis to prevent inappropriate flagging of values
%adjacent to outliers)
%
%syntax: Iflag = flag_nsigma(vals,lowlimit,highlimit,framesize,iterations)
%
%inputs:
%  vals = array of values
%  lowlimit = low limit criteria (mean - lowlimit*std) (default = 3)
%  highlimit = high limit criteria (mean + highlimit*std) (default = 3)
%  framesize = number of preceeding values to use for mean calculation (default = 5, minimum = 3)
%  iterations = number of flag-check iterations to perform to minimize inappropriate flagging
%    of in-bounds values following out-of-bounds values (default = 1, max = 10; each iteration removes the
%    first flagged value in each repetitively flagged group and re-analyzes the remaining values)
%
%outputs:
%  Iflag = logical index of values outside of the range: mean-std*lowlimit < value > mean+std*highlimit
%
%
%(c)2002-2006 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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

%initialize output
Iflag = [];

%check for required input
if nargin >= 1
   
   %validate input
   if isnumeric(vals) && ~isempty(vals)
      
      %check for vector
      [r,c] = size(vals);
      
      if r == 1 || c == 1
         
         %validate input, apply defaults for omitted arguments
         if exist('lowlimit','var') ~= 1 || isempty(lowlimit)
            lowlimit = 3;
         end
         
         if exist('highlimit','var') ~= 1 || isempty(highlimit)
            highlimit = 3;
         end
         
         if exist('framesize','var') ~= 1 || isempty(framesize)
            framesize = 5;
         elseif framesize < 3
            framesize = 3;
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
         Iafter = ones(len,framesize) .* NaN;
         Ibefore = Iafter;
         
         %generate appropriate logical indices for selection sizes
         for n = 1:framesize
            
            Iafter(1:len-n,n) = Iall(n+1:len,1);
            Inan = find(isnan(Iafter(:,n)));
            if ~isempty(Inan)
               Iafter(Inan,n) = Iall(Inan);
            end
            
            Ibefore(n+1:len,n) = Iall(1:len-n,1);
            Inan = find(isnan(Ibefore(:,n)));
            if ~isempty(Inan)
               Ibefore(Inan,n) = Iall(Inan);
            end
            
         end
         
         %populate comparison matrices
         valsbefore = vals(Ibefore);
         
         %get mean for each column
         mnbefore = mean(valsbefore,2);
         
         %get sample standard deviation for each column
         stdbefore = std(valsbefore,0,2);
         
         %individually handle means/stds with NaN elements (replace NaNs with value being compared)
         Inan = find(isnan(mnbefore));
         if ~isempty(Inan)
            for n = 1:length(Inan)
               if ~isnan(vals(Inan(n)))
                  vb = valsbefore(Inan(n),:);
                  mnbefore(Inan(n)) = mean(vb(~isnan(vb)));
                  stdbefore(Inan(n)) = std(vb(~isnan(vb)));
               end
            end
         end
         
         %build index of values violating low limit
         if lowlimit > 0
            Ilow = vals < (mnbefore - stdbefore .* lowlimit);
         else
            Ilow = zeros(len,1);
         end
         
         %build index of values violating high limit
         if highlimit > 0
            Ihigh = vals > (mnbefore + stdbefore .* highlimit);
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
               Iflag2 = flag_nsigma(vals,lowlimit,highlimit,framesize+1,iterations-1);
               Iunflag = (Iflag==1 & Iflag2==0);
               Iflag(Iunflag) = 0;  %clear flags not identified in next iteration
               Iflag(Igaps) = 1;  %reset flags on gaps
            end
         end
         
      end

   end
   
end