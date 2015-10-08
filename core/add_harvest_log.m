function msg = add_harvest_log(harvester,entry,logfile)
%Logs results of a harvest operation initiated by start_harvesters to a GCE Data Structure
%
%syntax: msg = add_harvest_log(harvester,entry,logfile)
%
%inputs:
%   harvester = name of the harvester ('Name' field in harvest_timers.mat)
%   entry = log entry to record (string)
%   logfile = fully-qualified filename of the log file (default = 'harvest_logs.mat' in /settings)
%
%outputs
%   msg = status of the timer instantiations
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
%last modified: 05-Sep-2013

if nargin >= 2
   
   %validate logfile
   if exist('logfile','var') ~= 1 || isempty(logfile)
      logfile = which('harvest_logs.mat');
   end
   
   %check for valid log file
   data = [];
   if ~isempty(logfile) && exist(logfile,'file') == 2
      try
         v = load(logfile,'-mat');
      catch e
         v = struct('null','');
         logfile = '';
         msg = ['log file ''',logfile,''' is invalid (',e.message,')'];
      end
      if isfield(v,'data')
         data = v.data;
      end
   else
      logfile = '';  %clear logfile if invalid
   end
   
   %set default logfile name if omitted/invalid 
   if isempty(logfile)
      logfile = [gce_homepath,filesep,'settings',filesep,'harvest_logs.mat'];
   end
   
   %add log entry to structure
   if ~isempty(data) && gce_valid(data,'data')
      
      %compress muilti-line character arrays or cell arrays of strings into single string
      if iscell(entry) || size(entry,1) > 1
         entry = cellstr(entry);
         entry = char(concatcellcols(entry(:)','; '));  
      end      
      
      %replace carriage returns and line feeds with semi-colons and compress whitespace
      entry = regexprep(entry,'[\r\n]*','; ');
      entry = regexprep(entry,'\s*',' ');
      
      %insert new row at end of structure
      data = insertrows(data,{datestr(now,0),harvester,entry},{'Date','Harvester','Entry'});
      
      msg = ['successfully saved log entry to ',logfile];   
      
   else  %create new log structure
      
      %init log
      data = newstruct('data');      
      data = newtitle(data,'Data Harvest Logs');
      
      %add date column
      data = addcol(data,{datestr(now,0)}, ...
         'Date', ...
         'yyyy-mm-dd HH:MM:SS', ...
         'Date of log entry', ...
         's', ...
         'datetime', ...
         'none', ...
         0, ...
         '', ...
         1);
      
      %add harvester name
      data = addcol(data, ...
         harvester, ...
         'Harvester', ...
         '', ...
         'Name of the data harvester', ...
         's', ...
         'nominal', ...
         'none', ...
         0, ...
         '', ...
         2);
      
      %add harvester name
      data = addcol(data, ...
         entry, ...
         'Entry', ...
         '', ...
         'Log entry', ...
         's', ...
         'freetext', ...
         'none', ...
         0, ...
         '', ...
         3);
      
      msg = ['successfully created log file ',logfile,' and added entry'];   

   end
         
   %save log file
   if ~isempty(data)
      try
         save(logfile,'data')
      catch e
         msg = ['an error occurred saving the log file ''',logfile,''' (',e.message,')'];
      end   
   else
      msg = 'an error occurred appending the log entry - log file not updated';
   end
   
else
   msg = 'harvester name and log entry are required';
end