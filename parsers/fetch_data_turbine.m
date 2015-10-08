function [s,msg] = fetch_data_turbine(server,source,startdate,time_offset,template,maxdays,workflow)
%Retrieves channel data from a Data Turbine source to create a GCE Data Structure
%
%syntax: [s,msg] = fetch_data_turbine(server,source,startdate,time_offset,template,maxdays,workflow)
%
%inputs:
%   server = DataTurbine server IP address (string; required)
%   source = DataTurbine source (string; required)
%   startdate = starting date for data retrieval (string date or numeric MATLAB serial date;
%      optional; default = [] for earliest date available in DataTurbine)
%   time_offset = time offset from the server in hours for both startdate and 'Date' field in s 
%      (numeric; optional; default = 0 for no offset)
%   template = metadata template to apply (string; optional; default = '' for none)
%   maxdays = maximum days of data to retrieve from Data Turbine in a single request -
%      if maxdays is > 0 then data arrays will be retrieved in chunks and concatenated to limit
%      load on the server or network link (number; optional; default = [] or 0 for unlimited)
%  workflow = name of a GCE Data Toolbox workflow function to call for post-processing the data
%     (default = '' for none)
%
%output:
%  s = GCE data structure containing a Date column and columns for each Data Turbine data channel
%      available at server/source
%  msg = text of any error messages
%  lastdate = MATLAB numeric serial date for the last data record returned (for use in sequential
%      data retrieval scenarios)
%
%notes:
%   1) function dependencies (must be present in the working directory or MATLAB path):
%         DTsource2gce.m
%         DTMatlabTK library (e.g. DTget, DTstruct)
%         rbnb.jar registered in the permanent or runtime Java path (e.g. javaaddpath(which('rbnb.jar'))
%   2) only numeric and text channels are supported; numeric channels will be converted into
%      double-precision numeric arrays
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
%last modified: 15-Oct-2013

s = [];

%check for required aruments
if nargin >= 2
   
   %check for workflow
   if exist('workflow','var') ~= 1
      workflow = '';
   end
   
   %check for function dependencies
   if exist('DTsource2gce.m','file') == 2 && exist('DTget.m','file') == 2
      
      %check for Data Turbine in the Java class path, try to add if not present
      dt_check = check_data_turbine;
      
      %confirm rbnb.jar is loaded
      if dt_check == 1
         
         %supply default start date if omitted
         if exist('startdate','var') ~= 1
            startdate = [];
         end
         
         %set default time_offset if omitted
         if exist('time_offset','var') ~= 1
            time_offset = 0;
         end
         
         %set default template if omitted
         if exist('template','var') ~= 1
            template = '';
         end
         
         %check for maxdays option
         if exist('maxdays','var') ~= 1 || isempty(maxdays)
            maxdays = 0;
         end
         
         %call DTsource2gce
         [s,msg] = DTsource2gce(server,source,startdate,time_offset,template,maxdays);
         
         %call post-processing workflow if defined
         if ~isempty(workflow)
            if exist(workflow,'file') == 2
               try
                  [s,msg] = feval(workflow,s);
               catch e
                  msg = ['an error occurred calling ''',workflow,''' (',e.message,')'];
               end
            else
               s = [];
               msg = ['workflow function ''',workflow,''' is not present in the MATLAB path'];
            end
         end
            
      else
         msg = 'the Data Turbine Java archive (rbnb.jar) is not present in the Java classpath';
      end
      
   else
      msg = 'required DTMatlabTK functions (DTsource2gce.m, DTget.m) are not present in the MATLAB path';
   end   
   
else
   msg = 'insufficient arguments - server and source are required';
end

return



function status = check_data_turbine()
%checks for Data Turbine (rbnb.jar) in the Java class path and attemps to add it if not found
%
%input:
%  none
%
%output:
%  status = Data Turbine status flag (0 = not present, 1 = present)

%init output
status = 0;

%get Java classpath
jcp = javaclasspath;

%search for 'rbnb.jar'
Irbnb = strfind(jcp,'rbnb.jar');

%check for match
dt_check = length(find(~cellfun('isempty',Irbnb)));

if dt_check > 0
   status = 1;
elseif exist('rbnb.jar','file') == 2
   try
      javaaddpath(which('rbnb.jar'))
      status = 1;
   catch    %#ok<CTCH>
      status = 0;
   end
end

return