function [s,msg] = fetch_usgs_stats(stations,labels,pn,maxyears)
%Fetches long-term discharge statistics for a list of USGS gauging stations
%for use in setting HydroDB Q/C limits
%
%syntax: [s,msg] = fetch_usgs_stats(stations,labels,pn,maxyears)
%
%input:
%  stations = array of station ids (cell array of strings)
%  labels = array of station labels (cell array of strings)
%  pn = pathname for harvest information (default = pwd)
%  maxyears = maximum years (default = 100)
%
%(c)2008-2010 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 14-Sep-2010

s = [];
msg = '';

if nargin >= 2
   if exist('pn','var') ~= 1
      pn = pwd;
   elseif ~isdir(pn)
      pn = pwd;
   end
   if exist('maxyears','var') ~= 1
      maxyears = 100;
   end
   if iscell(stations) && iscell(labels)
      
      if length(stations) == length(labels)
         
         stations = stations(:);  %force column orientation
         labels = labels(:);  %force column orientation
         days = ceil(maxyears .* 365.25);  %calculate number of days to request
         
         %init storage arrays
         len = length(stations);
         min_date = repmat({''},len,1);
         max_date = min_date;
         min_discharge = repmat(NaN,len,1);
         max_discharge = min_discharge;
         mean_discharge = min_discharge;
         sd_discharge = min_discharge;
         
         %loop through stations, requesting archival or provision data
         for n = 1:len             
            [s_tmp,msg] = fetch_usgs(stations{n},'daily',days,'USGS_Generic',pn);  %try long-term archive
            if ~isempty(s_tmp)
               Idschg = name2col(s_tmp,'Daily_Mean_Discharge');  %get column index (& check for Daily_Mean_Discharge parm)
               if ~isempty(Idschg)
                  s_tmp = unit_convert(s_tmp,'Daily_Mean_Discharge','L/s');  %convert to HydroDB units
                  Idschg = Idschg(1);  %force first matching parm
                  discharge = extract(s_tmp,Idschg);  %get discharge
                  discharge = discharge(~isnan(discharge));  %remove nans
                  dt = extract(s_tmp,'Date');  %get datenum
                  dt = dt(~isnan(dt));  %remove nans
                  min_date{n} = datestr(min(dt),1);  %generate min date string
                  max_date{n} = datestr(max(dt),1);  %generate max date string
                  units = s_tmp.units{Idschg};  %lookup units
                  prec = s_tmp.precision(Idschg);  %lookup prec
                  min_discharge(n) = min(discharge);  %calc min
                  max_discharge(n) = max(discharge);  %calc max
                  mean_discharge(n) = mean(discharge);  %calc mean
                  sd_discharge(n) = std(discharge);  %calc sd
               end
            end
         end
         
         %build output structure
         s = newstruct;
         s = addcol(s,stations,'Station','none','USGS station identifier','s','nominal','none',0);
         s = addcol(s,labels,'HydroDB','none','HydroDB station identifier','s','nominal','none',0);
         s = addcol(s,min_date,'Min_Date','DD-MMM-YYYY', ...
            'Earliest date for which finalized or provisional data are available in the USGS database','s','datetime','none',0);
         s = addcol(s,max_date,'Max_Date','DD-MMM-YYYY', ...
            'Latest date for which finalized or provisional data are available in the USGS database','s','datetime','none',0);
         s = addcol(s,min_discharge,'Min_Discharge',units,'Minimum recorded daily mean discharge','f','calculation','continuous',prec,'x<0=''I''');
         s = addcol(s,mean_discharge,'Mean_Discharge',units,'Mean recorded daily mean discharge','f','calculation','continuous',prec+1,'x<0=''I''');
         s = addcol(s,max_discharge,'Max_Discharge',units,'Maximum recorded daily mean discharge','f','calculation','continuous',prec,'x<0=''I''');
         s = addcol(s,sd_discharge,'SD_Discharge',units,'Standard deviation of recorded daily mean discharge','f','calculation','continuous',prec+2,'x<0=''I''');

         s = dataflag(s);  %update flags
         
         if isempty(s)
            msg = 'an error occurred generating the output structure';
         end
         
      else
         msg = 'station and label arrays must match';
      end
   else
      msg = 'stations and label smust be cell arrays of strings';
   end
else
   msg = 'insufficient arguments for function';   
end