function msg = start_harvesters(harvesters)
%Creates timer objects based on information stored in 'harvest_timers.mat'
%to harvest remote data sources and create GCE Data Structures.
%
%syntax: msg = start_harvesters(harvesters)
%
%input:
%   harvesters = GCE Data Structure structure containing timer configuration details (if omitted
%      the data in 'harvest_timers.mat' will be used)
%
%output:
%   msg = status of the timer instantiations
%
%notes:
%   1) any running harvesters of the same name will be stopped to prevent conflicts
%
%(c)2006-2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 21-Jul-2013

%init output
msg = '';

%check for harvesters argument, otherwise load default file from disk
if nargin == 0
   harvesters = [];
   if exist('harvest_timers.mat','file') == 2
      try
         v = load('harvest_timers.mat');
      catch
         v = struct('null','');
      end
      if isfield(v,'data')
         harvesters = v.data;  %check for data structure format
      elseif isfield(v,'harvesters')  
         harvesters = v.harvesters;  %check for deprecated format
      end
   end
end

if ~isempty(harvesters)
   
   %check for harvesters in data structure format
   if gce_valid(harvesters,'data') ~= 1
      harvesters = harvesters2struct(harvesters);  %call sub-function to convert from legacy format
   end
   
   if ~isempty(harvesters)
      
      %extract timer property arrays from data structure
      names = extract(harvesters,'Name');
      execmodes = extract(harvesters,'ExecutionMode');
      periods = extract(harvesters,'Period');
      timerfcns = extract(harvesters,'TimerFcn');
      startdays = extract(harvesters,'StartDay');
      starttimes = extract(harvesters,'StartTime');
      
      %init message array
      msgarray = cell(length(harvesters),1);
      
      %loop through timers
      for n = 1:length(names)
         
         %get array values for current timer
         name = names{n};
         execmode = execmodes{n};
         period = fix(periods(n) * 60);  %convert minutes to seconds
         starttime = starttimes{n};
         startday = startdays(n);
         timerfcn = timerfcns{n};
         
         %check for timer of same name already running and stop/delete
         t = timerfind('Name',name);
         if ~isempty(t)
            stop(t);
            delete(t);
         end
         
         %check for disabled harvester based on period = 0
         if period > 0
            
            %init timer object
            t = timer('Name',name, ...
               'ExecutionMode',execmode, ...
               'Period',period, ...
               'BusyMode','queue', ...
               'ErrorFcn',['disp([''Error executing ''''',name,''''':'']); disp(''''); disp(lasterr)'], ...
               'TimerFcn',['try; msg = ',timerfcn,'; add_harvest_log(''',name,''',msg); disp(msg); catch; ', ...
                  'msg = [''error executing ''''',strrep(timerfcn,'''',''''''),''''' at '',datestr(now)]; ', ...
                  'add_harvest_log(''',name,''',msg); disp(msg); end'], ...
               'Tag',['timer_',name]);            

            %get current date, current hour and current day
            dt = now;
            dvec = datevec(dt);
            hr = dvec(4);
            dy = fix(dt);
            
            %start timer based on starting day
            if startday == 0  %no start day delay
               
               dt_next = dy + datenum(['1/0/0000 ',starttime]);  %calculate initial starting date
               
               %check for past/future date and adjust start if necessary
               if dt < dt_next  %before start time
                  dstr = [datestr(dy,1),' ',starttime];  %convert to string
               else  %after start time, kick to period after current time
                  while dt > dt_next
                     dt_next = dt_next + (period ./ 86400);  %increment by Period converted to fractional days
                  end
                  dstr = datestr(dt_next,0);  %convert adjusted date to string
               end
               
            else  %specified start day
               
               daynum = date2weekday(dt);
               
               if startday > daynum  %check for < 1 week
                  dy_offset = (startday - daynum);
               elseif startday == daynum
                  hr_start = (datenum(['1/1/2000 ',starttime]) - datenum('1/1/2000')) * 24;
                  if hr < hr_start
                     dy_offset = 0;  %future time
                  else
                     dy_offset = 7;  %past specified day - kick to following week
                  end
               else
                  dy_offset = (startday - daynum) + 7;
               end
               
               dstr = [datestr(dy+dy_offset,1),' ',starttime];  %generate date string for startup
               
            end
            
            if ~isempty(dstr)
               
               %start harvester and generate status message
               try
                  startat(t,dstr);
                  msg0 = ['Successfully started harvest timer ''',name,'''; next harvest set for ',dstr];
               catch me
                  msg0 = ['WARNING! An error occurred initializing harvester ''',name,''': ',me.message];
               end
               
            else
               msg0 = ['WARNING! An error occurred initializing harvester ''',name,''''];
            end
            
         else
            msg0 = ['WARNING! Harvester ''',name,''' was not initialized (Period = 0)'];
         end
         
         msgarray{n} = msg0;
         
      end
            
      %convert message array to character array for output
      msg = char(msgarray(~cellfun('isempty',msgarray)));
      
   else
      msg = 'unrecognized harvest timer data format';
   end
   
else
   msg = 'the harvest timer data file ''harvest_timers.mat'' was not found in the search path';
end
return


function data = harvesters2struct(harvesters)
%Converts a GCE harvest timer structure into a GCE Data Structure for editing
%
%syntax: data = harvesters2struct(harvesters)
%
%input:
%  harvesters = structure with fields:
%     'Name' = name of timer
%     'ExecutionMode' = timer execution mode
%     'Period' = execution period in seconds
%     'TimerFcn' = statement to evaluate
%     'StartTime' = timer start time (hh:mm:ss)
%     'StartDay' = timer start day of week (0 = auto, 1 = Sunday, ...)
%
%output:
%  data = GCE Data Structure with columns matching harvesters fields
%
%
%notes:
%  1) harvesters.Period will be converted from seconds to minutes
%
%
%(c)2011-2012 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 26-Jul-2012

%init output
data = [];

if nargin == 1 && isstruct(harvesters)
   
   %init data structure
   data = newstruct;
   data = newtitle(data,'Harvest Timers');
   
   try
      
      %convert legacy period in seconds to minutes for start_harvesters.m
      period = [harvesters.Period]' ./ 60;
      
      %add columns to data structure
      data = addcol(data,{harvesters.Name}','Name','','Harvest timer name','s','nominal','none',0,'');
      data = addcol(data,{harvesters.ExecutionMode}','ExecutionMode','', ...
         'Harvest timer execution mode (singleShot, fixedSpacing, fixedDelay, fixedRate)','s','nominal','none',0, ...
         'flag_notinlist(x,''singleShot,fixedSpacing,fixedDelay,fixedRate'')=''I''');
      data = addcol(data,period,'Period','minutes', ...
         'Harvest timer execution period','f','interval','none',0,'x<0=''I'';x<1=''Q''');
      data = addcol(data,{harvesters.TimerFcn}','TimerFcn','', ...
         'Harvest timer statement to evaluate (function call)','s','nominal','none',0,'');
      data = addcol(data,{harvesters.StartTime}','StartTime','hh:mm:ss','Harvest timer start time (hh:mm:ss)','s','datetime','none',0,'');
      data = addcol(data,[harvesters.StartDay]','StartDay','d', ...
         'Harvest timer start day of the week (0 = auto, 1 = Sunday, 2 = Monday, 3 = Tuesday, 4 = Wednesday, 5 = Thursday, 6 = Friday, 7 = Saturday', ...
         'd','ordinal','none',0,'flag_notinarray(x,[0,1,2,3,4,5,6,7])=''I''');
      
   catch
      data = [];
   end
   
end