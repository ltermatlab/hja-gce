function [s2,msg] = add_title_dates(s,format,separator)
%Adds or updates a formatted date range to the title of a GCE Data Structure based the dates of observations
%
%syntax: [s2,msg] = add_title_dates(s,format,separator)
%
%input:
%  s = data structure to update
%  format = datestr format option to use (integer; default = 1 for 'dd-mmm-yyyy')
%  separator = date separator string (string; default = ' to ')
%
%output:
%  s2 = revised data structure
%  msg = text of any error message
%
%notes:
%  1) this function used 'get_studydates.m' to retrieve date/time information, which requires
%     recognized date or date component columns be present
%  2) if date range cannot be determined, the unmodified data structure will be
%     returned with a warning message
%  3) existing date range information in the title will be updated
%
%
%(c)2012 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 19-Oct-2012

%init output
s2 = [];
msg = '';

%check for required input
if nargin >= 1 && gce_valid(s,'data')
   
   %validate date format option
   if exist('format','var') ~= 1 || isempty(format) || ~isnumeric(format)
      format = 1;
   end
   
   %validate separator option
   if exist('separator','var') ~= 1 || ~ischar(separator)
      separator = ' to ';
   end
   
   %get array of serial dates for data records
   dt = get_studydates(s);
   
   %init min/max dates
   dt_min = [];
   dt_max = [];
   
   %get min/max dates
   if ~isempty(dt)
      dt_min = min(dt(~isnan(dt)));
      dt_max = max(dt(~isnan(dt)));
   end
   
   %check for valid date range
   if ~isempty(dt_min) && ~isempty(dt_max)
      
      %get current title string
      str = s.title;

      %remove any prior date range based on pattern matches to common datestr formats and separators
      patterns = { ...
         '\d{2}-\D{3}-\d{4} \d{2}:\d{2}:\d{2}' ; ...
         '\d{2}-\D{3}-\d{4}' ; ...
         '\d{2}/\d{2}/\d{2}' ; ...
         '\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}' ; ...
         '\d{4}-\d{2}-\d{2}' ...
         };
      try
         str2 = str;  %buffer original string
         for n = 1:length(patterns)
            pattern = patterns{n};  %get pattern from array
            str2 = regexprep(str2,[' (from|for|during) ',pattern,'( to | through | - |-)',pattern],'');
         end
      catch
         str2 = str;
      end

      %append dt to title
      dt_string = [str2,' from ',datestr(dt_min,format),separator,datestr(dt_max,format)];

      %generate updated structure with new title
      s2 = newtitle(s,dt_string);
                  
   else
      s2 = s;
      msg = 'date range could not be determined for the data set';
   end
      
else
   if nargin == 0
      msg = 'insufficient input (data structure is required)';
   else
      msg = 'invalid GCE Data Structure';
   end
end
