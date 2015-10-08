function [t_high,t_low,a_high,a_low] = tide_high_low(dt,depth,timestep,polyorder)
%Returns interpolated times and amplitudes of high and low tides based on a time-series of depth measurements
%(note that if an error occurs with the selected polyorder, a 2nd-order fit will be attempted)
%
%syntax: [t_high,t_low,a_high,a_low] = tide_high_low(dt,depth,timestep,polyorder)
%
%input:
%  dt = serial date array (from MATLAB datenum)
%  depth = measured depth values for each value of dt
%  timestep = time step interval for interpolation (minutes, default = 5)
%  polyorder = polynomial order for fitting high and low tide peaks (default = 3)
%
%output:
%  t_high = array of estimated high tide times
%  t_low = array of estimated low tide times
%  a_high = array of estimated high tide amplitudes
%  a_low = array of estimated low tide amplitudes
%
%(c)2009-2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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

%init output
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
   
   %generate time interval in days
   t_int = timestep / (24 * 60);
   
   %remove NaN date records
   Ivalid = find(~isnan(dt));
   dt = dt(Ivalid);
   depth = depth(Ivalid);

   %get unique dates and sort arrays by date
   [dt2,Iunique] = unique(dt);
   depth2 = depth(Iunique);

   Ivalid2 = find(~isnan(depth2));
   if length(Ivalid2) < length(Ivalid)
      depth2 = interp1(dt2(Ivalid2),depth2(Ivalid2),dt2,'spline');
   end
   
   %calculate mid amplitude of depth series using median (to reduce impact of outliers/skewness)
   d_mid =  median(depth2);
   
   %get indices of high and low sections (half amplitude range)
   I_high = find(depth2 >= d_mid);
   I_low = find(depth2 < d_mid);
   
   %get indices of high tide segments
   I_breakend = [find(diff(I_high)>1) ; length(I_high)];
   I_breakstart = [1 ; I_breakend(1:end-1)+1];
   num_high = length(I_breakstart);
   
   %init high tide arrays
   t_high = NaN .* ones(num_high,1);
   a_high = t_high;
   
   %disable polyfit warnings
   warning('off','MATLAB:polyfit:PolyNotUnique')

   %interpolate and compute time and amplitude at high peak
   for n = 1:num_high
      
      %get index of points in peak section
      Isel = I_high(I_breakstart(n)):I_high(I_breakend(n));  
      
      %fit to polynomial, centering and scaling
      [coeff,~,mu] = polyfit(dt2(Isel),depth2(Isel),polyorder);  
      
      %generate high res dt for interpolation
      dt_int = (dt2(Isel(1)):t_int:dt2(Isel(end)))';  
      
      %generate high res depth for interpolation from polyfit stats
      dep_int = polyval(coeff,dt_int,[],mu);  
      
      %get amplitude of peak from interpolation
      [max_int,Ipeak] = max(dep_int);  
      
      %get time of peak from interpolation
      t_high(n) = dt_int(Ipeak);  
      
      %calculate corresponding amplitude
      a_high(n) = max([max_int,max(depth2(Isel))]);
      
   end
   
   %reenable polyfit warnings
   warning('on','MATLAB:polyfit:PolyNotUnique')

   %get indices of low tide segments
   I_breakend = [find(diff(I_low)>1) ; length(I_low)];
   I_breakstart = [1 ; I_breakend(1:end-1)+1];
   num_low = length(I_breakstart);

   %init low tide arrays
   t_low = NaN .* ones(num_low,1);
   a_low = t_low;

   %interpolate and compute time and amplitude at low peak
   for n = 1:num_low
      
      %get index of points in peak section
      Isel = I_low(I_breakstart(n)):I_low(I_breakend(n));
      x = dt2(Isel);
      y = depth2(Isel);
      
      %check for sufficient points
      if length(x) > polyorder
         
         %fit to polynomial, centering and scaling
         try
            [coeff,~,mu] = polyfit(x,y,polyorder);
         catch
            [coeff,~,mu] = polyfit(x,y,2);  %fall back to 2nd order polynomial, centering and scaling
         end
         
         %generate high res dt for interpolation
         dt_int = (dt2(Isel(1)):t_int:dt2(Isel(end)))';
         
         %generate high res depth for interpolation from polyfit stats
         dep_int = polyval(coeff,dt_int,[],mu);  
         
         %get amplitude of peak from interpolation
         [min_int,Ipeak] = min(dep_int);
         
         %get time of peak from interpolation
         t_low(n) = dt_int(Ipeak);  
         
         %calculate correpsonding amplitude at t_low
         a_low(n) = min([min_int,min(depth2(Isel))]);
         
      end
      
   end
   
   %remove uncomputed high tide values
   Ivalid = ~isnan(t_high);
   t_high = t_high(Ivalid);
   a_high = a_high(Ivalid);
   
   %remove uncomputed low tide values
   Ivalid = ~isnan(t_low);
   t_low = t_low(Ivalid);
   a_low = a_low(Ivalid);
   
end
