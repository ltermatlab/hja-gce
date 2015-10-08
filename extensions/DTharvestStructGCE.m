function options = DTharvestStructGCE(fn,period,time_offset,template,title,server,source)
%Generates an options structure for use with DTharvest.m containing a workflow to generate a GCE Data Structure
%
%syntax: options = DTharvestStructGCE(fn,period,time_offset,template,title,server,source)
%
%input:
%   fn = fully-qualified filename to use for saving raw channel data and GCE Data Structures 
%     (string; optional; default = '')
%   period = data collection frequency in hours (number; optional; default = 1)
%   time_offset = time offset from server in hours (number; optional; default = 0)
%   template = metadata template to assign (string; default = '')
%   title = data set title to assign (string; default = '')
%   server = Data Turbine server to document in data structure metadata (string; default = '')
%   source = Data Turbine source to document in the data structure metadata (string; default = '')
%
%output:
%   options = structure containing harvest timer configuration options - see DTharvest.m (struct; optional):
%      'Period' = data collection frequency in hours (number)
%      'StartTime' = time of day to start harvests; used in conjunction with Period to determine
%         exact start time of the first harvest, e.g. 
%         Period = 1 and StartTime = 09:45 will start hourly harvests at 09:45 or the next interval
%         Period = 24 and StartTime = 05:00 will start daily harvests at 05:00 or the next interval
%         (string; hh:mm; default = '' to start harvests without any delay)
%      'TimeOffset' = offset from server time for converting start times and harvested data time 
%         stamps to local time (numeric; default = 0 for no offset)
%      'FileRaw' = fully qualified filename for saving or appending raw Data Turbine channel data
%         (i.e. DTstruct file) (string; '' to disable saving raw data)
%      'VariableRaw' = variable name for saving the raw channel data (string; default = 'dts_raw')
%      'FileAligned' = fully qualified filename for saving aligned channel structures 
%         (string; '' to disable saving aligned structures)
%      'VariableAligned' = variable name for saving the aligned channel structure (string, default = 'dts_aligned')
%      'Workflow' = MATLAB code to evaluate following a successful data harvest to perform workflow actions
%         (string; default = code to append a GCE Data Structure as 'data' in 'FileAligned')
%      'LogOption' = options for logging a summary of operations:
%         'file' = save a log of operations to a variable 'log' in the 'FileRaw' file (default)
%         'email' = email a log of operations the the address specified in 'Email' (see 'sendmail' help for setup)
%         'file,email' = save a log to both disk and email
%         '' = do not log operations
%      'Email' = email address to use if 'LogOption' includes an 'email' option
%      'Console' = option to display status messages on the computer console:
%         'all' = display all harvest status messages (default)
%         'error' = only display error messages
%         '' = do not display console messages
%      'LastDate' = date of last data retrieved (MATLAB serial data or date string; use [] to request 
%         all available data on the first harvest)
%      'Log' = harvest operations log (automatically assigned by DTharvest.m)
%
%notes:
%  1) thie function requires Data Turbine and DTMatlabTK from the Open Source Data Turbine web site
%     (http://www.dataturbine.org/)
%  2) inputs fn, period and time_offset are provided for convenience when instantiating an options
%     structure for DTharvest.m; if they are not used then corresponding fields should be filled 
%     in manually before calling DTharvest.m, along with other options
%  3) date/time patterns within square brackets can be included in FileRaw, FileAligned and FileGCE
%     to automate date-based file management (e.g. 'met_[yyyymmdd].mat', where yyyymmdd is converted
%     to the current date when the harvest is run)
%  4) Workflow code can contain tokens for FileRaw, VariableRaw, FileAligned and VariableAligned e.g.
%     'vars = load(''[FileAligned]''); data = vars.[VariableAligned]; plot(data.Date,data.Channel1,'bd');'
%  5) Workflow code can also reference the variables 's_latest' and 's_raw' containing aligned and raw
%     channel structures from DTlatest.m, resp.
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
%last modified: 08-May-2013

%set default filename if omitted
if exist('fn','var') ~= 1
   fn = '';
end

%set default period if omitted
if exist('period','var') ~= 1
   period = 1;
end

%set default time_offset if omitted
if exist('time_offset','var') ~= 1
   time_offset = 0;
end

%set default template if omitted
if exist('template','var') ~= 1
   template = '';
end

%set default server and source if omitted
if exist('server','var') ~= 1
   server = '';
end
if exist('source','var') ~= 1
   source = '';
end

if exist('DTharvestStruct','file') == 2
   
   %call DTharvestStruct to get the base option structure
   options = DTharvestStruct(fn,period,time_offset);
   
   %generate workflow statement for generating and saving a GCE data structure
   workflow = ['data = DTchan2gce(s_aligned,''',template,''',''',title,''',''',server,''',''',source,''');', ...
      'append_data(data,''[FileAligned]'',''data'',''append'',''new_date'',0,1);'];
   
   %update options structure
   options.Workflow = workflow;
   
else
   options = [];
end
