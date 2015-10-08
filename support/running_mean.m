function [mn,sd,num] = running_mean(vals,points,ignore_nan,direction)
%Calculates the running mean and other statistics of an array over the specified number of points
%in either direction to smooth a data series for analysis or comparison
%
%syntax: [mn,sd,num] = running_mean(vals,points,ignore_nan,direction)
%
%inputs:
%  vals = value array
%  points = number of points to average over
%  ignore_nan = option to ignore NaN values when computing means
%     0 = do not ignore (return NaN if any value in points is NaN) - default
%     1 = ignore NaNs when computing mean
%  direction = direction option:
%     'back' = backward-looking running mean of value and points-1 preceding values (default)
%     'forward' = forward-looking running mean of value and points-1 following values
%
%outputs:
%  mn = array of running means matching the dimensions of the input array ([] on error)
%  sd = array of standard deviations for mn
%  num = array of numbers of points used for mn and sd calculation
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

%init output
mn = [];
sd = [];
num = [];

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
            
            %pre-pend NaN to offset values for calculating mean of preceding values
            if strcmpi(direction,'forward')               
               vals2 = vals;
               numvals2 = numvals;
            else  %backward
               vals2 = [ones(1,points-1).*NaN , vals];  %offset values to force backward mean calc
               numvals2 = length(vals2);  %recalculate numvals
            end
            
            %add value array to composite array, incrementally offset
            for n = 1:points
               temp = vals2(n:numvals2);
               ar(n,1:length(temp)) = temp;
            end
            
            %truncate excess columns from backward comparison
            ar = ar(:,1:numvals);
            
            %calculate running mean
            mn = mean(ar,1);
            sd = std(ar,1);

            %init num and adjust for tails
            num = repmat(points,1,numvals);
            if strcmpi(direction,'forward')
               num(end:-1:end-points+1) = (1:points);
            else
               num(1:points) = (1:points);
            end

            %calculate stats based on NaN option
            if ignore_nan == 1
               
               %loop through NaN means, recalculating without NaN values
               Inan = find(isnan(mn));
               for n = 1:length(Inan)
                  idx = Inan(n);              %get index of affect rows
                  temp = ar(:,idx);           %extract values
                  temp = temp(~isnan(temp));  %remove NaNs
                  if ~isempty(temp)
                     mn(idx) = mean(temp,1);  %recalculate mean
                     sd(idx) = std(temp,1);   %recalculate sd
                     num(idx) = length(temp); %recalculate num
                  end
               end
               
            else
            
               %re-calculate mean of tail portion with incomplete values
               for n = 1:points
                  temp = ar(:,n);
                  temp = temp(~isnan(temp));
                  if ~isempty(temp)
                     mn(n) = mean(temp,1);  %recalculate mean
                     sd(n) = std(temp,1);   %recalculate sd
                     num(n) = length(temp); %recalculate num
                  end
               end
                           
            end
            
            %match array orientation with original value array
            if c == 1
               %force column orientation
               mn = mn';
               sd = sd';
               num = num';
            end
            
         end
         
      elseif points == 1  %catch window size = 1, return original array and stats
         mn = vals;   
         sd = 0;
         num = 1;
      end
      
   end
   
end