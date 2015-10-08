function [s,msg,lastdate] = DTsource2gce(server,source,startdate,time_offset,template,maxdays)
%Imports data channels from a Data Turbine source to create a GCE Data Structure
%(see https://gce-svn.marsci.uga.edu/trac/GCE_Toolbox/wiki/DataModel)
%
%syntax: [s,msg,lastdate] = DTsource2gce(server,source,startdate,time_offset,template,maxdays)
%
%inputs:
%   server = DataTurbine server IP address (string; required)
%   source = DataTurbine source (string; required)
%   startdate = starting date for data retrieval (string date or numeric MATLAB serial date;
%      optional; default = [] for earliest date available in DataTurbine)
%   time_offset = time offset from server in hours for both startdate and 'Date' field in s 
%      (numeric; optional; default = 0 for no offset)
%   template = metadata template to apply (string; optional; default = '' for none)
%   maxdays = maximum days of data to retrieve from Data Turbine in a single request - 
%      if maxdays is > 0 then data arrays will be retrieved in chunks and concatenated to limit
%      load on the server or network link (number; optional; default = [] or 0 for unlimited)
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
%         DTMatlabTK library (e.g. DTget, DTstruct)
%         rbnb.jar registered in the permanent or runtime Java path (e.g. javaaddpath(which('rbnb.jar'))
%         GCE Data Toolbox library (https://gce-svn.marsci.uga.edu/trac/GCE_Toolbox)
%   2) only numeric and text channels are supported; numeric channels will be converted into
%      double-precision numeric arrays
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
%last modified: 15-Apr-2013

%init output
s = [];
lastdate = [];

%validate input
if nargin >= 2 && ~isempty(server) && ~isempty(source)
   
   %check for DTMatlabTK and GCE Data Toolbox dependencies
   if exist('DTstruct','file') == 2 && exist('DTget','file') == 2 && exist('imp_struct','file') == 2
      
      %supply default start date if omitted
      if exist('startdate','var') ~= 1
         startdate = [];
      end
      
      %set default time_offset if omitted
      if exist('time_offset','var') ~= 1 || isempty(time_offset) || ~isnumeric(time_offset)
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
      
      %call DTlatest to get the requested data as time-aligned MATLAB arrays in a structure
      [data,msg,lastdate] = DTlatest(server,source,startdate,time_offset,maxdays,'*');
      
      %check for return data
      if ~isempty(data)
         
         %define title and time zone if no template specified
         if isempty(template)
            
            %generate title
            titlestr = ['Data imported from Data Turbine source ''',source,''' on server ',server];
            
            %add time offset
            if time_offset ~= 0
               titlestr = [titlestr,' (offset by ',num2str(time_offset),' hours)'];
            end
            
         else
            
            %use defaults
            titlestr = '';
            
         end
         
         %convert channel structure to GCE data structure and apply template if defined
         [s,msg] = DTchan2gce(data,template,titlestr,server,source);
         
      end
      
   else
      msg = 'required functions in the DTMatlabTK library or GCE Data Toolbox were not found in the MATLAB path';
   end
   
else
   msg = 'missing input: a valid server and source are required';
end