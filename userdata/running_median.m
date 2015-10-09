function mn = running_median(vals,points,ignore_nan,direction)
%Calculates the running median of a value array over the specified number of preceding or following points
%
%syntax: mn = running_median(vals,points,ignore_nan,direction)
%
%inputs:
%  vals = value array
%  points = number of points to average over
%  ignore_nan = option to ignore NaN values when computing means
%     0 = do not ignore (return NaN if any value in points is NaN) - default
%     1 = ignore NaNs when computing median
%  direction = direction option:
%     'back' = backward-looking running median of value and points-1 preceding values (default)
%     'forward' = forward-looking running median of value and points-1 following values
%
%outputs:
%  mn = matching array of running median (or [] on error)
%
%notes:
%  1) the number of averaged points at the beginning of the array is < points and
%     missing values at the beginning of the array (N < points) will be ignored regardless 
%     of ignore_nan setting
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

mn = [];

if nargin >= 2
   
   %check for ignore_nan option
   if exist('ignore_nan','var') ~= 1
      ignore_nan = 0;
   end
   
   %check for direction option
   if exist('direction','var') ~= 1 || ~strcmpi(direction,'forward')
      direction = 'back';
   end
   
   %check for numeric input
   if isnumeric(vals) && isnumeric(points)
      
      if points > 1
         
         points = floor(points); %force integer
         [r,c] = size(vals);  %get array dimensions
         
         if length(vals) > points && (r == 1 || c == 1)
            
            %force row array
            vals = vals(:)';
            
            %init composite array
            numvals = length(vals);
            ar = ones(points,numvals) .* NaN;
            
            %pre-pend NaN to offset values for calculating median of preceding values
            if strcmpi(direction,'forward')               
               vals2 = vals;
               numvals2 = numvals;
            else  %backward
               vals2 = [ones(1,points-1).*NaN , vals];  %offset values to force backward median calc
               numvals2 = length(vals2);  %recalculate numvals
            end
            
            %add value array to composite array, incrementally offset
            for n = 1:points
               temp = vals2(n:numvals2);
               ar(n,1:length(temp)) = temp;
            end
            
            %truncate excess columns from backward comparison
            ar = ar(:,1:numvals);
            
            %calculate running median
            mn = median(ar);
               
            if ignore_nan == 1
               
               %loop through NaN means, recalculating without NaN values
               Inan = find(isnan(mn));
               for n = 1:length(Inan)
                  temp = ar(:,Inan(n));
                  temp = temp(~isnan(temp));
                  if ~isempty(temp)
                     mn(Inan(n)) = median(temp,1);
                  end
               end
               
            else
            
               %re-calculate median of tail portion with incomplete values
               for n = 1:points
                  temp = ar(:,n);
                  temp = temp(~isnan(temp));
                  if ~isempty(temp)
                     mn(n) = median(temp,1);
                  end
               end
            
            end
            
            %match array orientation with original value array
            if c == 1
               mn = mn';  %force column orientation
            end
            
         end
         
      elseif points == 1  %catch window size = 1, return original array
         mn = vals;         
      end
      
   end
   
end