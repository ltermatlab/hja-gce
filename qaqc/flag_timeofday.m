function Iflag = flag_timeofday(datetime,timerange,dateformat)
%Returns an index of date/time values that are within a specified time of day for time-based QA/QC flagging
%
%syntax: Iflag = flag_timeofday(datetime,timerange,dateformat)
%
%inputs:
%  datetime = array of date/time values, either a numeric array of MATLAB serial dates from datenum()
%    or cell array of date strings compatible with datenum (numeric or cell array of strings; required)
%  timerange = cell array containing pairs of starting and ending times to index (cell array of strings; required;
%    e.g. {'10:30','11:00','16:00','16:30'}
%  dateformat = datetime format string to use for converting string dates to datenums
%    (string; optional; default = '' for automatic; see datestr() help for supported options)
%
%outputs:
%  Iflag = logical index of values collected during the specified time range
%
%notes:
%  1) time ranges are inclusive, so values in the range time_min >= time <= time_max will be selected
%  2) if dateformat is specified, all values of datetime must be in the same format
%
%(c)2013-2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 25-Feb-2015

Iflag = [];

%check for required arguments
if nargin >= 2 && ~isempty(datetime) && iscell(timerange) && mod(size(timerange,2),2) == 0
   
   %check for omitted dateformat, default to auto
   if exist('dateformat','var') ~= 1
      dateformat = '';
   end
   
   %check for text dates - call datenum
   if ~isnumeric(datetime)
      try
         if iscell(datetime)
            datetime = char(datetime);
         end
         if ~isempty(dateformat)
            dt = datenum(datetime,dateformat);
         else
            dt = datenum(datetime);
         end
      catch
         %fail silently
         dt = [];
      end
   else
      dt = datetime;
   end
   
   if ~isempty(dt)
      
      %parse dates into date vector
      dvec = datevec(dt);
      
      %init flag array
      flags = zeros(length(dt),1);
      
      %calculate number of time pairs
      num_times = size(timerange,2)/2;
      
      %loop through pairs of start/end time
      for n = 1:num_times
         
         %get position indices of start/end times
         Itstart = 2 * (n-1) + 1;
         Itend = Itstart + 1;
         
         %parse time range into date vectors
         tvec_start = datevec(timerange{Itstart});
         tvec_end = datevec(timerange{Itend});
         
         %check for successful parsing
         if ~isempty(dvec) && ~isempty(tvec_start) && ~isempty(tvec_end)
            
            %calculate fractional hour for datetime
            t_dt = dvec(:,4) + dvec(:,5)./60 + dvec(:,6)./3600;
            
            %calculate fractional hours for time range
            t_start = tvec_start(4) + tvec_start(5)./60 + tvec_start(6)./3600;
            t_end = tvec_end(4) + tvec_end(5)./60 + tvec_end(6)./3600;
            
            %generate index of times within range
            Imatch = t_dt >= t_start & t_dt <= t_end;
            
            %update flags array
            flags(Imatch) = 1;
            
         end
      
      end
      
      %generate output logical index
      Iflag = flags == 1;
      
   end   
   
end