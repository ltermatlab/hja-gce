function [lcl,ucl] = conf_limits(mn,sd,n,pct)
%Calculates lower and upper confidence limits for an array of means and standard deviations
%
%syntax: [lcl,ucl] = conf_limits(mn,sd,n,pct)
%
%inputs:
%  mn = mean of values
%  sd = sample standard deviation of values (length must match mn)
%  n = number of values (length must match mn)
%  pct  = percent confidence interval to calculate (scalar, default = 95, 0 > pct < 100)
%
%outputs:
%  lcl = lower confidence limit
%  ucl = upper confidence limit
%
%
%(c)2006 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 26-Feb-2006

lcl = [];
ucl = [];

if nargin >= 3

   if length(mn) == length(sd) && length(mn) == length(n)
      
      if exist('pct','var') ~= 1
         pct = 95;
      end
      
      if pct > 0 && pct < 100
         
         %convert percent to alpha
         a = (100-pct)./100;
         
         %calc one-sided t-value
         tval = t_value_onetail(a./2,n-1);
         
         if ~isempty(tval)
            
            %calculate critical value
            try
               critval = tval .* (sd./sqrt(n));
            catch
               critval = [];
            end
            
            if ~isempty(critval)
               lcl = mn - critval;
               ucl = mn + critval;
            end
            
         end
         
      end
      
   end
   
end