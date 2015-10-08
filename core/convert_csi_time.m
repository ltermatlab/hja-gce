function [s2,msg] = convert_csi_time(s,cols,fmt)
%Converts Campbell Scientific max/min times in hhmm integer or h:m string format to a standard time format
%
%syntax: [s2,msg] = convert_csi_time(s,cols,fmt)
%
%input:
%  s = data structure to convert (struct; required)
%  cols = column names or numbers to convert (string, cell-array or integer; required)
%  fmt = output format
%    'hhmm' = integer column in hhmm format
%    'hh:mm' = string column in standard hh:mm format
%    'hh:mm PM' = string column in hh:mm format with AM/PM
%    'hh:mm:ss' = string column in hh:mm:ss format (default)
%    'hh:mm:ss PM' = string column in hh:mm:ss format with AM/PM
%
%output:
%  s2 = updated structure
%  msg = text of any error message
%
%
%notes:
%  1) original time column(s) must be integer or string format
%  2) if no times are successfully converted the original structure will be returned
%     with an error message
%
%(c)2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 27-Oct-2014

%init output
s2 = [];
msg = '';

%check for required input
if nargin >= 2 && ~isempty(cols) && gce_valid(s,'data') == 1
   
   %validate time format
   if exist('fmt','var') ~= 1 || isempty(fmt)
      fmt = 'hh:mm:ss';
   else
      if ~inlist({fmt},{'hhmm','hh:mm','hh:mm PM','hh:mm:ss PM'},'insensitive')
         fmt = 'hh:mm:ss';
      end
   end
   
   %init output
   s2 = s;
   
   %check for text column
   if ~isnumeric(cols)
      cols = name2col(s,cols);
   end
   
   %init message array
   msgarray = cell(length(cols),1);
     
   %loop through cols
   for n = 1:length(cols)
      
      %get column index
      col = cols(n);
      
      dtype = get_type(s,'datatype',col);
      
      %extract time strings
      t_vals = extract(s,col);
      
      %convert to time integers
      if strcmp(dtype,'s')
         t_int = csi_time2integer(t_vals);
      elseif strcmp(dtype,'d')
         t_int = t_vals;
      else  %unsupported
         t_int = ones(length(t_vals),1) .* NaN;
      end
      
      %check for any converted values, update column
      if sum(~isnan(t_int)) > 0
         
         %check for integer/string time
         if strcmpi(fmt,'hhmm')
         
            %delete original column
            s2 = deletecols(s2,col);
            
            %add converted data
            s2 = addcol(s2,t_int, ...
               s.name{col}, ...
               'hhmm', ...
               s.description{col}, ...
               'd', ...
               'ordinal', ...
               'discrete', ...
               0, ...
               'x<0=''I'';x>2400=''I''', ...
               col);
            
         else
            
            %calculate string time
            vals = csi_integer2time(t_int,fmt);
            
            if ~isempty(vals)
                           
               %delete original column
               s2 = deletecols(s2,col);
            
               %add converted data
               s2 = addcol(s2,vals, ...
                  s.name{col}, ...
                  fmt, ...
                  s.description{col}, ...
                  's', ...
                  'datetime', ...
                  'none', ...
                  0, ...
                  '', ...
                  col);
               
            else
               
               %generate error message
               msgarray{n} = ['No valid times were found and converted in column ',s.name{col}];
               
            end
            
         end
         
      else
         
         %generate error message
         msgarray{n} = ['No valid times were found and converted in column ',s.name{col}];
         
      end      
      
   end
   
   %get index of converion failures
   Igood = cellfun('isempty',msgarray);
   
   %check for any valid conversions
   if sum(Igood) > 0
   
      %generate history entry
      str_hist = ['converted Campbell Scientific Instruments logger times in column(s) ', ...
         cell2commas(s.name(cols(Igood))),' to ',fmt,' format (''convert_csi_time'')'];
      
      %update edit date
      s2.editdate = datestr(now);
      
      %update processing history
      s2.history = [s.history ; ...
         {datestr(now),str_hist}];
      
      %generate message for any failed conversions
      if Igood < length(cols)
         msg = cell2commas(msgarray(~Igood));
      end
   
   else
   
      %return unmodified structure and error
      s2 = s;
      msg = 'No valid times were found and converted in the selected column(s)';
   
   end
      
else
   
   %generate input error message
   if nargin < 2
      msg = 'insufficient arguments (data structure and column names/numbers required)';
   elseif isempty(cols)
      msg = 'columns to convert not specified';
   else
      msg = 'invalid data structure';
   end
   
end