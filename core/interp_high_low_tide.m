function [s2,msg] = interp_high_low_tide(s,cols,method,col_date,col_depth,timestep,polyorder,windowsize)
%Generates interpolated high and low tide values of selected columns in a GCE data structure
%based on analysis of depth or pressure data using the 'tide_high_low' function
%(note that non-numeric and numeric columns with variable types other than 'data' or 'calculation'
%will not be interpolated - the closest observation to the tide time will be returned)
%
%syntax: [s2,msg] = interp_high_low_tide(s,cols,method,col_date,col_depth,timestep,polyorder,windowsize)
%
%input:
%  s = data structure to evaluate
%  cols = data columns to interpolate (default = all data/calculation columns)
%  method = interpolation method for 'interp1'
%    'nearest'  - nearest neighbor interpolation
%    'linear'   - linear interpolation
%    'spline'   - piecewise cubic spline interpolation
%    'pchip'    - shape-preserving piecewise cubic interpolation (default)
%    'cubic'    - same as 'pchip'
%    'v5cubic'  - the cubic interpolation from MATLAB 5, which does not
%                 extrapolate and uses 'spline' if X is not equally spaced
%  col_date = name or index of serial date column (default = automatically determined from date/time columns)
%  col_depth = name or index of depth or pressure column (default = 'Depth' or 'Pressure')
%  timestep = time step interval for interpolation (minutes, default = 5)
%  polyorder = polynomial order for fitting high and low tide peaks (default = 3)
%  windowsize = number of measured data points around the tide high/low peak to use for interpolation
%     (default = 10)
%
%output:
%  s2 = modified structure containing interpolated data
%  msg = text of any error message
%
%(c)2010 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 15-Oct-2010

s2 = [];
msg = '';

if nargin >= 1 && gce_valid('s','data') == 1
   
   if exist('method','var') ~= 1
      method = 'pchip';
   end
   
   if exist('timestep','var') ~= 1
      timestep = 5;
   end
   
   if exist('polyorder','var') ~= 1
      polyorder = 3;
   end
   
   if exist('windowsize','var') ~= 1
      windowsize = 10;
   end
   
   if exist('col_date','var') ~= 1
      [dt,msg0,s,col_date] = get_studydates(s);
   else
      [dt,msg0] = get_studydates(s,col_date);      
   end
   
   if ~isempty(dt)
      
      if exist('col_depth','var') ~= 1
         col_depth = name2col(s,'Depth',0,'f');
         if isempty(col_depth)
            col_depth = name2col(s,'Pressure',0,'f');
         end
      end

      dep = extract(s,col_dep);  %extract depth
      
      if ~isempty(dep)
         
         if exist('cols','var') ~= 1
            cols = listdatacols(s);  %look up all data/calc columns
         end
         cols = setdiff(cols,[col_date,col_depth]);  %remove date, depth columns from cols list
         
         if ~isempty(cols)
            
            %generate high/low tide times
            [t_high,t_low,a_high,a_low] = tide_high_low(dt,dep,timestep,polyorder);
            
            if ~isempty(t_high) && ~isempty(t_low)
               
               %combine tide time and amplitude arrays and sort by time
               t_peak = [t_high ; t_low];
               amp_peak = [a_high ; a_low];
               [t_peak,Isort] = sort(t_peak);
               amp_peak = amp_peak(Isort);
               
               %instantiate new structure, copying top-level metadata
               s2 = newstruct('data');
               s2.title = s.title;
               s2.metadata = s.metadata;
               s2.datafile = s2.datafile;

               %add date and depth/pressure column for tidal peaks
               s2 = addcol(s2,t_peak,s.name{col_date},s.units{col_date},s.description{col_date}, ...
                  s.datatype{col_date},s.variabletype{col_date},s.numbertype{col_date},s.precision(col_date), ...
                  s.criteria{col_date});
               s2 = addcol(s2,amp_peak,s.name{col_depth},s.units{col_depth},s.description{col_depth}, ...
                  s.datatype{col_depth},s.variabletype{col_depth},s.numbertype{col_depth},s.precision(col_depth), ...
                  s.criteria{col_depth});
               
               %calculate number of points before/after peak to use
               num_pre = ceil(windowsize/2);
               num_post = num_pre;
               
               %loop through data columns and perform interpolation
               for c = 1:length(cols)
                  
                  
               end
               
            else
               msg = 'high and low tides could not be determined from the depth or pressure values';
            end
            
         else
            msg = 'no valid data or calculation columns were specified';
         end           
         
      else
         msg = 'invalid depth or pressure column';
      end      
      
   else
      msg = 'invalid serial date column (or serial date column could not be determined)';
   end
   
else
   if nargin == 0
      msg = 'insufficient arguments for function';
   else
      msg = 'invalid data structure';
   end
end