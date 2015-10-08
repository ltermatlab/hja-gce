function [s,msg] = imp_castaway_ctd(fn,pn,template,castfile)
%Parses and concatenates cast records from an OSIL Castaway CTD instrument
%
%syntax: [s,msg] = imp_castaway_ctd(fn,pn,template,castfile)
%
%input:
%   fn = filename to import (string; optional; prompted if omitted)
%   pn = pathname containing the files to process (string; optional; default = pwd)
%   template = metadata template to apply (string; optional; default = 'OSIL_Castaway')
%   castfile = option to include the cast file as a data column (integer; optional; 0 = no, 1 = yes/default)
%
%output:
%   s = data structure containing cast data for all matched files
%   msg = text of any error message
%
%(c)2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 01-May-2015

%init output
s = [];
msg = '';

%validate input, apply defaults for omitted arguments
if exist('pn','var') ~= 1 || isempty(pn)
   pn = pwd;
elseif ~isdir(pn)
   pn = pwd;
else
   pn = clean_path(pn);
end

%validate or prompt for file
if exist('fn','var') ~= 1 || isempty(fn)
   curpath = pwd;
   cd(pn)
   [fn,pn] = uigetfile('*.csv','Select a Castaway CTD file to Import');
   drawnow
   cd(curpath)
   if ~ischar(fn)
      fn = [];
   end
end

%check for valid file
if exist([pn,filesep,fn],'file') == 2
   
   if exist('template','var') ~= 1
      template = 'OSIL_Castaway';
   end
   
   if exist('castfile','var') ~= 1
      castfile = 1;
   end
   
   %init array of metadata fields, column names, column units, and eval functions to perform
   metaflds = { ...
      'Device','Device','none','s','nominal',0,0; ...
      'File name','CastFile','none','s','nominal',0,castfile; ...
      'Cast time (UTC)','Date_UTC','serial day (base 1/1/0000) - GMT','f','datetime',7,1; ...
      'Cast time (local)','Date_Local','serial day (base 1/1/0000)','f','datetime',7,1; ...
      'Sample type','SampleType','none','s','code',0,0; ...
      'Start latitude','Latitude','degrees','f','coord',6,1; ...
      'Start longitude','Longitude','degrees','f','coord',6,1; ...
      'Start altitute','Altitude','cm','f','data',2,0; ...
      'Start GPS horizontal error(Meter)','GPS_Error_Horizontal','m','f','data',2,1; ...
      'Start GPS vertical error(Meter)','GPS_Error_Vertical','m','f','data',2,1; ...
      'Start GPS number of satellites','GPS_Satellites','count','d','data',0,1; ...
      'Cast duration (Seconds)','Cast_Duration','sec','f','data',2,0; ...
      'Samples per second','SamplingRate','Hz','d','data',0,0; ...
      'Conductivity calibration date','Calibration_Conductivity','serial day (base 1/1/0000)','f','datetime',7,0; ...
      'Temperature calibration date','Calibration_Temperature','serial day (base 1/1/0000)','f','datetime',7,0; ...
      'Pressure calibration date','Calibration_Pressure','serial day (base 1/1/0000)','f','datetime',7,0; ...
      };
   
   %convert metadata field info to struct and add column for parsed value
   s_meta = cell2struct([metaflds,cell(size(metaflds,1),1)], ...
      {'column','name','units','datatype','variabletype','precision','datacolumn','value'},2);
   
   %init header variables
   hdr = cell(100,1);
   coltitles = [];
   hdr_rows = 0;
   
   %read header
   try
      fid = fopen([pn,filesep,fn],'r');
      str = '';
      while ischar(str)
         str = fgetl(fid);
         if strncmp(str,'% ',2)
            hdr_rows = hdr_rows + 1;
            hdr{hdr_rows} = str(3:end);
         else
            hdr_rows = hdr_rows + 1;
            coltitles = splitstr(str,',',0,1);  %grab column titles
            break
         end
      end
      fclose(fid);
   catch
      msg = 'error parsing file';
   end
      
   %check for successful parsing
   if hdr_rows > 0
      
      %remove empty rows from header
      hdr = hdr(~cellfun('isempty',hdr),:);
      
      %set starting title
      titlestr = ['YSI (OSIL) Castaway CTD Profile Data Imported on ',datestr(now,1)];
      
      %parse data
      [s,msg] = imp_ascii(fn,pn,titlestr,template,'',coltitles,hdr_rows,'',',');
      
      if ~isempty(s)
         
         %init added column index
         col = 0;
         
         %parse header info, add columns to data structure if indicated
         for n = 1:length(s_meta)
            
            %get field info
            dtype = s_meta(n).datatype;
            vtype = s_meta(n).variabletype;
            prec = s_meta(n).precision;
            datacol = s_meta(n).datacolumn;
            
            %check for header field based on column title
            fldname = s_meta(n).column;
            fldsize = length(s_meta(n).column);
            Imatch = find(strncmpi(fldname,hdr,fldsize));
            
            %check for match
            if ~isempty(Imatch)
               
               %get value string
               str = hdr{Imatch(1)};
               
               %check for empty value field
               if length(str) >= fldsize+2
                  str = str(fldsize+2:end);
                  switch dtype
                     case 'f'
                        %check for date/time
                        if strcmp(vtype,'datetime')
                           val = datenum(str);
                        else
                           val = str2double(str);
                        end
                     case 'd'
                        val = str2double(str);
                        val = fix(val);
                     otherwise %s
                        val = str;
                  end
                  s_meta(n).value = val;
               end
               
            elseif ~strcmp(dtype,'s')
               s_meta(n).value = NaN;  %use NaN for numeric field types
            end
            
            %add data column
            if datacol == 1
               
               %increment counter
               col = col + 1;
               
               %determine numeric type
               switch dtype
                  case 'f'
                     numtype = 'continuous';
                  case 'd'
                     numtype = 'discrete';
                  otherwise
                     numtype = 'none';
               end
               
               %add column
               [s,msg] = addcol(s, ...
                  val, ...
                  s_meta(n).name, ...
                  s_meta(n).units, ...
                  s_meta(n).column, ...
                  dtype, ...
                  vtype, ...
                  numtype, ...
                  prec, ...
                  '', ...
                  col);
               
               if isempty(s)
                  msg = ['error adding header column ',s_meta(n).name,' (',msg,')'];  %#ok<AGROW>
                  break
               end
               
            end
            
         end
         
         %add date metadata
         s = add_studydates(s,'Date_UTC');
         
         %get start/end dates
         dt = get_studydates(s,'Date_UTC');
         
         %generate title with date/time
         titlestr = ['YSI (OSIL) Castaway CTD Profile Collected at ',datestr(min(no_nan(dt)),'yyyy-mm-dd HH:MM:SS')];
         s = newtitle(s,titlestr,0);
         
         %generate header field structure with field names
         s_meta2 = cell2struct({s_meta.value},{s_meta.name},2);
         
         %generate abstract text
         date_start = lookupmeta(s,'Study','BeginDate');
         abstract = ['Vertical profiles of conductivity, temperature and pressure were measured on ',date_start, ...
            ' using a manually-deployed YSI (OSIL) Castaway CTD with a sampling rate of ',num2str(s_meta2.SamplingRate), ...
            ' Hz. Location information was recorded by the on-board GPS receiver at 10m accurracy. ', ...
            'Salinity, depth, density and sound speed were calculated from the measured parameters using the ', ...
            'embedded instrument firmware.'];                                                        

         %generate methods text
         methods = ['|Method 1: CTD Profiling - The YSI (OSIL) Castaway instrument was attached to a fishing rod or shipboard davit, ', ...
            'turned on, and lowered into the water by hand until hitting bottom. Measurements of temperature, pressure, ', ...
            'conductivity and sound velocity were recordsed at a sampling rate of ',num2str(s_meta2.SamplingRate), ...
            ' Hz.|Method 2: Data Acquisition and Processing - Cast files were downloaded to a computer via Bluetooth radio', ...
            'and exported as text files in comma-separated value format. Derived variables depth, salinity, specific conductance ', ...
            'and density were computed from pressure, temperature and conductivity by the embedded firmware. ', ...
            'The CSV text files were then imported into the GCE Data Toolbox for MATLAB for quality control, ', ...
            'documentation and integration into profile data sets'];
         
         %generate instrumentation text
         instr = ['|Method 1:', ...
            '|  Temperature Sensor', ...
            '|     Manufacturer: YSI (OSIL) (Model: Castaway, Serial Number: ',s_meta2.Device, ...
            '|     Parameter: Water Temperature (Accuracy: 0.05°C, Range: -5°C to 45°C, Resolution: 0.01°C)', ...
            '|     Calibration: ',datestr(s_meta2.Calibration_Temperature,1), ...
            '|  Conductivity Sensor', ...
            '|     Manufacturer: YSI (OSIL) (Model: Castaway, Serial Number: ',s_meta2.Device, ...
            '|     Parameter: Water Conductivity (Accuracy: 0.25% +/- 5 uS/cm, Range: 0-100,000 uS/cm, Resolution: 1 uS/cm)', ...
            '|     Calibration: ',datestr(s_meta2.Calibration_Conductivity,1), ...
            '|  Pressure Sensor', ...
            '|     Manufacturer: YSI (OSIL) (Model: Castaway, Serial Number: ',s_meta2.Device, ...
            '|     Parameter: Water Pressure (Accuracy: 0.25% of full scale, Range: 0-100 dbar, Resolution: 0.01 dbar)', ...
            '|     Calibration: ',datestr(s_meta2.Calibration_Pressure,1), ...
            '|  Salinity (derived)', ...
            '|     Manufacturer: YSI (OSIL) (Model: Castaway, Serial Number: ',s_meta2.Device, ...
            '|     Parameter: Salinity (Accuracy: 0.1 (PSS-78), Range: 0-42 (PSS-78), Resolution: 0.01 (PSS-78))', ...
            '|  Sound Speed (derived)', ...
            '|     Manufacturer: YSI (OSIL) (Model: Castaway, Serial Number: ',s_meta2.Device, ...
            '|     Parameter: Sound Speed (Accuracy: 0.15 m/s, Range: 1400-1730 m/s, Resolution: 0.01 m/s)', ...
            '|  Global Positioning System Receiver', ...
            '|     Manufacturer: YSI (OSIL) (Model: Castaway, Serial Number: ',s_meta2.Device, ...
            '|     Parameter: Latitude (Accuracy: 10m)', ...
            '|     Parameter: Longitude (Accuracy: 10m)', ...
            '|Method 2: none'];
         
         %add methods
         s = addmeta(s,{'Dataset','Abstract',abstract; 'Study','Methods',methods;'Study','Instrumentation',instr},0,'imp_castaway_ctd');
                  
         %look up locations from GPS
         s = add_locations(s,0.5,0.25,'ctd',1,'Longitude','Latitude','Station');
         
         %add site
         s = add_studysites(s,'transect','Transect','Longitude','Latitude');
         
         %add location metadata
         s = add_sitemetadata(s);
         
      end
      
   end   
      
else
   msg = 'invalid import file';
end

