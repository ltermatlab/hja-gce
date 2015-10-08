function Iflag = flag_daterange(datetime,daterange,dateformat)
%Returns an index of date/time values that are within a specified time of day for time-based QA/QC flagging
%
%syntax: Iflag = flag_daterange(datetime,daterange,dateformat)
%
%inputs:
%  datetime = array of date/time values, either a numeric array of MATLAB serial dates from datenum()
%    or cell array of date strings compatible with datenum (numeric or cell array of strings; required)
%  daterange = cell array containing pairs of starting and ending dates to index (cell array of strings; required;
%    e.g. {'2/10/2013 01:30:00','2/11/2013 15:20:00','3/1/2013 00:00:00','3/3/2013 21:00:00'}
%  dateformat = date/time format string to use for converting string dates to datenums for improved performance
%    (string; optional; default = '' for automatic; see datestr() help for supported date/time tokens)
%
%outputs:
%  Iflag = logical index of values collected during the specified time range
%
%notes:
%  1) if dateformat is specified, all values of datetime and daterange must be in the same format
%
%
%(c)2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 24-Oct-2013

Iflag = [];

%check for required arguments
if nargin >= 2 && ~isempty(datetime) && iscell(daterange) && mod(size(daterange,2),2) == 0
   
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
      
      %init flag array
      flags = zeros(length(dt),1);
      
      %calculate number of time pairs
      num_times = size(daterange,2)/2;
      
      %loop through pairs of start/end time
      for n = 1:num_times
         
         %get position indices of start/end times
         Itstart = 2 * (n-1) + 1;
         Itend = Itstart + 1;
         
         %parse time range into date vectors
         try
            if ~isempty(dateformat)               
               dt_start = datenum(daterange{Itstart},dateformat);
               dt_end = datenum(daterange{Itend},dateformat);
            else
               dt_start = datenum(daterange{Itstart});
               dt_end = datenum(daterange{Itend});
            end
         catch
            dt_start = [];
            dt_end = [];
         end
         
         %check for successful parsing
         if ~isempty(dt_start) && ~isempty(dt_end)
            
            %generate index of times within range
            Imatch = dt >= dt_start & dt <= dt_end;
            
            %update flags array
            flags(Imatch) = 1;
            
         end
      
      end
      
      %generate output logical index
      Iflag = flags == 1;
      
   end   
   
end