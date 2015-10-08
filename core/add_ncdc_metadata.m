function [s2,msg] = add_ncdc_metadata(s,stationid)
%Adds metadata to a NOAA NCDC data set based on station information in ''ncdc_ghcnd_stations.mat''
%
%syntax: [s2,msg] = add_ncdc_metadata(s,stationid)
%
%input:
%  s = NCDC data structure to update
%  stationid = GHCN station ID (default = value in first row of Station column)
%
%output:
%  s2 = updated data structure
%  msg = status message
%
%(c)2010-2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 29-May-2013

%init output
s2 = s;
msg = '';

if nargin >= 1 && gce_valid(s,'data') == 1
   
   %lookup stationid if not specified
   if exist('stationid','var') ~= 1
      stationid = '';
   end
   if isempty(stationid)
      stationid = extract(s,'Station',1);
      if ~isempty(stationid)
         stationid = char(stationid);
      end
   end
   
   %check for valid stationid and ncdc_stations.mat
   if ~isempty(stationid) && exist('ncdc_ghcnd_stations.mat','file') == 2
      
      %load station info file
      try
         v = load('ncdc_ghcnd_stations.mat','-mat');
      catch
         v = struct('null','');
      end
      
      %extract info for station
      if isfield(v,'data')
         
         %look up coop id
         [data,rows] = querydata(v.data,['strcmpi(''',stationid,''',StationID)']);
         
         %check for single valid match
         if ~isempty(data) && rows == 1
            
            %extract fields
            state = char(extract(data,'State'));
            station = char(extract(data,'StationName'));
            country = char(extract(data,'Country'));
            lat = extract(data,'Latitude');
            lon = extract(data,'Longitude');
            el = extract(data,'Elevation');
            
            %generate location
            if isempty(state)
               loc = country;
            else
               loc = [state,', ',country];
            end
            
            %look up range of dates, format
            dt = get_studydates(s);
            mindate = datestr(min(dt(~isnan(dt))),1);
            maxdate = datestr(max(dt(~isnan(dt))),1);
            
            %format lat/lon
            if ~isnan(lat) && ~isnan(lon)
               latlon = sub_format_coords(lon,lat);
            else
               latlon = '';
            end
            
            %generate study description based on presence of elevation info
            if ~isnan(el)
               elevation = [' at an elevation of ',num2str(el),'m'];
            else
               elevation = '';
            end
            
            studydesc = ['Climate variables were measured at ',station,' in ',loc, ...
               ' (stationid ',stationid,')',elevation, ...
               ' according to Global Historic Climate Network guidelines (http://www.ncdc.noaa.gov/oa/climate/ghcn-daily/)', ...
               ' and reported as daily-interval summary statistics.'];
            
            %generate title string
            titlestr = ['Daily climate data from ',station,' in ',loc,' (stationid ',stationid,') for ',mindate,' to ',maxdate];
            abs = ['Global Historical Climatology Network daily climate data were downloaded from the NOAA National Climatic Data Center (http://www.ncdc.noaa.gov/oa/climate/ghcn-daily/) on ', ...
               s.createdate,' for ',station,' in ',loc,' (stationid ',stationid,'). Data were retrieved for the date range ', ...
               mindate,' to ',maxdate,' and parsed using the GCE Data Toolbox for MATLAB, and documented based on GHCN-D metadata ', ...
               '(http://www1.ncdc.noaa.gov/pub/data/ghcn/daily/readme.txt).'];
            
            %generate other metadata
            newmeta = {'Dataset','Abstract',abs; ...
               'Site','Location',[stationid,' -- ',station,' in ',loc]; ...
               'Site','Coordinates',[stationid,' -- ',latlon]; ...
               'Study','Description',studydesc; ...
               'Status','ProjectRelease',datestr(now,1); ...
               'Status','PublicRelease',datestr(now,1)};
            
            %update title, metadata
            s2 = newtitle(s,titlestr);
            s2 = addmeta(s2,newmeta,0,'add_ncdc_metadata');
            
         else
            msg = 'could not match station id in ''ncdc_ghcnd_stations.mat''';
         end
         
      end
      
   else
      if isempty(stationid)
         msg = 'station ID could not be determined';
      else
         msg = 'metadata not added - database file ''ncdc_ghcnd_stations.mat'' was not found';
      end
   end
   
else
   if nargin == 0
      msg = 'insufficient input for function';
   else
      msg = 'invalid data structure';
   end
end
return

function str = sub_format_coords(lon,lat)
%generates formatted DMS coordinates based on lon/lat in decimal degrees

if lon < 0
   hem1 = 'W';
else
   hem1 = 'E';
end
if lat < 0
   hem2 = 'S';
else
   hem2 = 'N';
end

try
   str = sprintf(['%02d %02d %0.2f ',hem2,', %03d %02d %0.2f ',hem1],ddeg2dms(abs(lat)),ddeg2dms(abs(lon)));
catch
   str = '';
end
return