function Iflag = flag_total(vals,highlimit,framesize,iterations)
%Returns an index of values that exceed a limit when totalled with a specified number of preceding values
%(forward-only evaluation, with optional recursive analysis to prevent inappropriate flagging of values
%adjacent to outliers)
%
%syntax: Iflag = flag_total(vals,highlimit,framesize,iterations)
%
%inputs:
%  vals = array of values
%  highlimit = maximum totalled value over the specified framesize (sum(yi,...,yi-famesize)>highlimit = 1)
%  framesize = number of preceeding values to use for mean calculation (default = 1)
%  iterations = number of flag-check iterations to perform to minimize inappropriate flagging
%    of in-bounds values following out-of-bounds values (default = 0, max = 10; each iteration removes the
%    first flagged value in each repetitively flagged group and re-analyzes the remaining values)
%
%outputs:
%  Iflag = logical index of values outside of the range: mean-lowlimit < value > mean+highlimit
%
%
%(c)2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project-2005 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 31-Jan-2013

%initialize output
Iflag = [];

%check for required arguments
if nargin >= 2
   
   %check for non-empty numeric array of values to compare
   if isnumeric(vals) && ~isempty(vals)
      
      %check for row or column vector of values
      [r,c] = size(vals);
      
      if r == 1 || c == 1
         
         %use default framesize if omitted
         if exist('framesize','var') ~= 1
            framesize = 1;
         end
         
         %use default iterations if omitted
         if exist('iterations','var') ~= 1
            iterations = 0;
         elseif iterations < 1
            iterations = 0;
         elseif iterations > 10
            iterations = 10;
         end
         
         %prep val array
         vals = [0 ; vals(:)];  %force column orientation and pre-pend a zero value for comparisons < framesize
         len = length(vals);  %get length of value array
         
         %initialize indices
         Iall = (1:len)';
         Ibefore = repmat(NaN,len,framesize);
         
         %generate appropriate logical indices for selection sizes
         for n = 1:framesize
            Ibefore(n+1:len,n) = Iall(1:len-n,1);
            Inan = find(isnan(Ibefore(:,n)));
            if ~isempty(Inan)
               Ibefore(Inan,n) = 1;  %reference first dummy 0 value for all indices before framesize
            end
         end
         
         %populate comparison matrices
         valsbefore = vals(Ibefore);
         if framesize > 1
            tot_before = sum(valsbefore,2);  %total across rows
         else
            tot_before = valsbefore;  %framesize = 1 so compare against prior 1 value itself
         end
         
         %individually handle vals with NaN elements (ignore NaNs - effectively treating NaN as zero)
         Inan = find(isnan(tot_before));
         if ~isempty(Inan)
            for n = 1:length(Inan)
               if ~isnan(vals(Inan(n)))
                  vb = valsbefore(Inan(n),:);
                  vb_nonan = vb(~isnan(vb));
                  if ~isempty(vb_nonan)
                     tot_before(Inan(n)) = sum(vb_nonan);
                  end
               end
            end
         end
         
         %build index of non-zero values violating high limit
         Ihigh = vals > 0 & (vals + tot_before) > highlimit;
         Ihigh = Ihigh(2:end);  %remove first dummy value
         
         %build output matrix
         Iflag = (Ihigh == 1);
         
         %recursively analyze groups of flags, removing the leading flagged value and re-evaluating the remainder
         %in order to unflag inappropriately flagged values following out-of-range values
         if iterations > 0
            Igaps = find(diff(Iflag)==1) + 1;  %get starting index of each flag group based on 0-to-1 transition
            if ~isempty(Igaps)
               vals(Igaps) = NaN;  %clear first flagged value in each group
               Iflag2 = flag_total(vals,highlimit,framesize+1,iterations-1);  %recurseively call function
               Iunflag = (Iflag==1 & Iflag2==0);  %get index of unflagged values
               Iflag(Iunflag) = 0;  %clear flags not identified for next iteration
               Iflag(Igaps) = 1;  %reset flags on gaps
            end
         end
         
      end
      
   end
   
end