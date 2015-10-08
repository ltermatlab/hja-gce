function [data,msg] = parse_usgs(fn,pn,titlestr,template,timezone,flag_provisional,clear_provisional)
%Parses tab-delimited real-time or daily data obtained from the USGS National Water Information System
%web site to create a GCE Data Structure. If no template is specified a generic template containing
%column descriptors for common hydrographic and meteorological parameters will be used.
%A provisional data flag column will also be included to indicate the presence of provisional
%values in each data record.
%
%syntax: [data,msg] = parse_usgs(fn,pn,titlestr,template,timezone,flag_provisional,clear_provisional)
%
%inputs:
%  fn = file name to parse (will be prompted if empty)
%  pn = path name for file (default = current directory)
%  titlestr = string to use as a structure title (default = generic title based on date)
%  template = name of metadata template to use (default = 'USGS_generic')
%  timezone = time zone for local time (default = '') - overridden if provided by USGS
%  flag_provisional = option to flag all data values as provisional (e.g. real-time data)
%     0 = no/default (based on presence of "P" flags in record)
%     1 = yes
%  clear_provisional = option to clear provisional ("P") flags after generating a single 'Provisional'
%     boolean column indicating the presence of provisional values in the record (specify 0 to retain
%     individual P value qualifiers)
%     0 = no
%     1 = yes/default
%
%outputs:
%  data = data structure
%  msg = text of any error message
%
%(c)2002-2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 04-May-2015

%init output
data = [];
msg = '';
curpath = pwd;

%validate input, provide defaults for omitted parameters
if exist('clear_provisional','var') ~= 1
   clear_provisional = 1;
elseif clear_provisional ~= 0
   clear_provisional = 1;
end

if exist('flag_provisional','var') ~= 1
   flag_provisional = 0;
elseif flag_provisional ~= 1
   flag_provisional = 0;
end

if exist('timezone','var') ~= 1
   timezone = '';
end

if exist('titlestr','var') ~= 1
   titlestr = '';
end

if exist('template','var') ~= 1
   template = 'USGS_Generic';
end

%validate path
if exist('pn','var') ~= 1
   pn = '';
end
if ~isdir(pn)
   pn = curpath;
else
   pn = clean_path(pn);  %strip terminal path separator
end

%validate file
if exist('fn','var') ~= 1
   fn = '';
   filespec = '*.txt;*.asc;*.dat;*.ans';
else
   if exist([pn,filesep,fn],'file') ~= 2
      filespec = fn;
      fn = '';
   end
end

if isempty(fn)
   cd(pn)
   [fn,pn] = uigetfile(filespec,'Select a file containing tab-delimited USGS data');
   if fn == 0
      fn = '';  %check for cancel
   end
   cd(curpath)
   drawnow
end

if ~isempty(fn)

   %generate filename for modified import file
   [tmp,basefn] = fileparts(fn);
   tempfn = [basefn,'_mod.txt'];

   %init runtime variables
   coltitles = [];
   colformats = [];
   datatypes = [];
   coldesc = [];
   stationlbl = '';
   html = 0;
   provisional_flags = [];
   timezoneflag = 0;
   mlv = mlversion;  %get matlab version for handling syntax variances

   %init pattern of inline flags to remove from numeric columns
   inlineflags = '(Ssn|Ice|Pr|Rat|Nd|Eqp|Fld|Dry|Dis|--|***)';


   %open input file, read first line
   fid = fopen([pn,filesep,fn],'r');
   ln = fgetl(fid);

   %read file until hit column titles or EOF
   while ischar(ln)

      if ~isempty(ln)

         if ~isempty(strfind(lower(ln),'html '))  %check for html tag (error page)

            html = 1;
            break

         elseif ~strncmp(ln,'#',1)  %check for non-header line

            %check for column title line
            if strncmpi(ln,'agency_cd',9)

               str_titles = ln;  %store column header line
               ln = fgetl(fid);  %get next header line
               str_formats = ln; %column format line
               ln = fgetl(fid);  %skip to first data line

               %split column labels, substituting date for datetime for consistency
               coltitles = splitstr(str_titles,char(9));
               coltitles = strrep(coltitles,'datetime','date');

               %replace time zone code to prevent identification as qa/qc flag
               coltitles = strrep(coltitles,'tz_cd','timezone');

               %remove leading DD strings from storet codes, and add Flag_ prefix for flag cols
               for cnt = 4:length(coltitles)
                  ar = splitstr(coltitles{cnt},'_');
                  if length(ar) > 1
                     if strcmp(ar{end},'cd')  %flag
                        coltitles{cnt} = ['Flag_',char(concatcellcols(ar(2:end-1)','_'))];
                     else
                        coltitles(cnt) = concatcellcols(ar(2:end)','_');
                     end
                  end
               end

               %split formats and replace USGS field tokens with MATLAB tokens
               colformats = splitstr(str_formats,char(9));
               colformats = regexprep(colformats,'\d*','');  %strip field sizes
               colformats = strrep(colformats,'d','s');  %convert date to string
               colformats = strrep(colformats,'n','f');  %convert numeric to float

               %generate datatypes for parsing
               datatypes = concatcellcols([repmat({'%'},length(colformats),1),colformats(:)],'')';

               %prepend descriptions for agency, station, date timezone to descriptions
               if ~isempty(find(strcmp(coltitles,'timezone')))
                  coldesc = [{'Agency code';'Station ID';'Date';'Local time zone'} ; coldesc];
                  timezoneflag = 1;
               else
                  coldesc = [{'Agency code';'Station ID';'Date'} ; coldesc];
               end

            end

            break  %break out of loop once header finished

         %check for station id line, grab station info
         elseif strncmpi(ln,'# Data for ',11) || strncmpi(ln,'# Sites in ',11)

            ln = fgetl(fid);  %skip to next line

            if isempty(strfind(ln,'USGS'))
               ln = fgetl(fid);  %burn spacer line
            end

            Istrstart = strfind(ln,'USGS');
            if ~isempty(Istrstart)
               ln2 = [ln,'   '];  %pad line to avoid index errors
               ln2 = deblank(ln2(Istrstart(1)+5:end));
               [str,rem] = strtok(ln2,' ');
               if length(rem) > 1
                  str = [str,' (',rem(2:end),')'];
               end
               stationlbl = ['USGS Station ',str];
            end

         %check for variable list section
         elseif strncmpi(ln,'# Data provided for',19)

            coldesc = [];  %init column description array

            %get heading line, check for statistics column
            ln = fgetl(fid);
            if ~isempty(strfind(ln,'statistic'))
               startcol = 5;
            else
               startcol = 4;
            end

            %parse descriptions
            ln = deblank(fgetl(fid));
            while length(ln) > 1
               ar = splitstr(ln,' ');
               if length(ar) >= startcol
                  str = char(concatcellcols(ar(startcol:end)',' ')');
                  coldesc = [coldesc ;  {str} ; {['QA/QC flags for ',str]}];
               else
                  coldesc = [coldesc ; {'unspecified'} ; {'QA/QC flags'}];
               end
               ln = deblank(fgetl(fid));
            end

         end

      end

      %read next line
      ln = fgetl(fid);

   end

   %continue parsing file lines after header processed

   if html == 1

      %html error page detected - close file
      fclose(fid);
      msg = 'file does not contain tab-delimited data (HTML found)';

   else

      status = 0;  %init status flag

      %check for matched titles and formats
      if ~isempty(coltitles) && ~isempty(colformats) && length(coltitles) == length(colformats)

         numcols = length(coltitles);
         fstr = char(concatcellcols(datatypes,' '));  %generate format string from datatype array

         %open temp file, write column headers
         fid2 = fopen([pn,filesep,tempfn],'w');
         fprintf(fid2,'name:');
         fprintf(fid2,'%s\r',char(concatcellcols(coltitles',char(9))));
         fprintf(fid2,'datatype:');
         fprintf(fid2,'%s\r',char(concatcellcols(colformats',char(9))));

         %add descriptions if match column titles
         if ~isempty(coldesc) && length(coldesc) == length(coltitles)
            fprintf(fid2,'description:');
            fprintf(fid2,'%s\r',char(concatcellcols(coldesc',char(9))));
         end

         %init record counter and provisional flag array
         rec_num = 0;
         provisional_flags = zeros(10000,1);

         %loop through records until EOF
         while ischar(ln)

            if ~isempty(ln)

               %increment record counter, check flag array dimensions
               rec_num = rec_num + 1;
               if rec_num > length(provisional_flags)
                  provisional_flags = [provisional_flags ; zeros(10000,1)];  %add more elements to flag array
               end

               %handle Accepted/Provisional flags
               ln = strrep(ln,'A','~');  %clear accepted flags and colon separators
               if flag_provisional == 1 || ~isempty(strfind(ln,'P'))
                  provisional_flags(rec_num) = 1;  %set provisional flag for record if any P flags present
                  if clear_provisional == 1
                     ln = strrep(ln,'P','~');  %clear provisional flags
                  end
               end
               ln = strrep(ln,'~e','e');  %clear empty flag preceeding 'e' flag from removed 'A','P'

               %clean up blanks, embedded commas, unsupported missing value codes to prevent parsing errors
               ln = strrep(ln,',','');  %remove thousands separator comma
               ln = strrep(ln,char(13),'');  %strip hard returns
               if timezoneflag == 1
                   %replace spaces before non-numeric fields (e.g. time zone) with a tab for parsing
                   if mlv >= 7
                       ln = regexprep(ln,' +(\D)+',[char(9),'$1']);
                   else
                       ln = regexprep(ln,' +(\D)+',[char(9),'$1'],'tokenize'); %add tokenize option for ML 6.5
                   end
               end
               ln = regexprep(ln,inlineflags,'NaN');  %replace inline value status codes with NaN

               %insert NaN for missing values
               Inull = strfind(ln,[char(9),char(9)]);  %get index of nulls based on double tab
               if ~isempty(Inull)
                  ln2 = ln(1:Inull(1));
                  for n = 1:length(Inull)-1
                     ln2 = [ln2,'NaN',ln(Inull(n)+1:Inull(n+1))];
                  end
                  ln2 = [ln2,'NaN',ln(Inull(end)+1:end)];
                  ln = ln2;
               end

               %fix terminal missing value
               if ln(end) == char(9)
                  ln = [ln,'NaN'];  %add terminal missing value
               elseif length(strfind(ln,char(9))) < (numcols-1)
                  ln = [ln,char(9),'NaN'];  %add terminal missing value
               end

               %write line to temp file
               if ~isempty(ln)
                  fprintf(fid2,'%s\r',ln);
               end

            end

            ln = fgetl(fid);  %get next line

         end

         fclose(fid2);  %close temp file

         provisional_flags = provisional_flags(1:rec_num);  %truncate provisional flag array to match data records

         status = 1;

      end

      fclose(fid);  %close raw data file

      if status == 1  %check for recognized header info and converted file flag

         %generate data set title if not provided
         if isempty(titlestr)
            if ~isempty(stationlbl)
               titlestr = ['Data from ',stationlbl];
            else
               titlestr = 'Data from the USGS web site';
            end
         end

         %parse the modified file to create a data structure
         [data,msg2] = imp_ascii(tempfn,pn,titlestr,template,fstr);

         if ~isempty(data)

            %try to delete temp file
            try
               delete([pn,filesep,tempfn])
            catch
               %no action
            end
            
            %catch any unmatched columns in template, call assign_numtype()
            numtype = get_type(data,'numbertype');
            dtype = get_type(data,'datatype');
            Iunmatched = (strcmp('u',dtype) | strcmp('unspecified',numtype));
            if sum(Iunmatched) > 0
               data = assign_numtype(data,0,find(Iunmatched));
            end

            str_hist = data.history;  %buffer history to prevent date manipulation/copycols entries

            %convert string date/time to serial date
            datecol = name2col(data,'Date');
            dt = get_studydates(data,datecol);

            %generate formatted min/max dates
            if ~isempty(dt)
               dt_col = name2col(data,'Date');
               data = deletecols(data,dt_col);
               data = addcol(data,dt,'Date','serial day (base 1/1/0000)', ...
                  'Fractional serial day (based on 1 = January 1, 0000)','f','datetime','continuous',8,'',dt_col);
               mindate = min(dt(~isnan(dt)));
               maxdate = max(dt(~isnan(dt)));
               str_mindate = datestr(mindate,1);
               str_maxdate = datestr(maxdate,1);
            else
               mindate = [];
               maxdate = [];
               str_mindate = '';
               str_maxdate = '';
            end

            %check for time zone column - extract values and delete column
            tz = extract(data,'TimeZone');
            tz_str = timezone;  %init time zone string with optional input
            if ~isempty(tz)
               data = deletecols(data,'TimeZone');
               if iscell(tz)
                  tz_str = tz{1};
               end
            end

            %add time zone to date units for unit conversions
            if ~isempty(datecol) && ~isempty(tz_str)
               %add timezone to date units
               units = data.units{datecol(1)};
               data.units{datecol(1)} = [units,' - ',upper(trimstr(tz_str))];
            end

            %generate and update metadata
            data.history = str_hist;  %replace history with buffer
            data.editdate = '';  %clear editdate
            if ~isempty(str_mindate)
               titlestr = [data.title,' from ',str_mindate,' to ',str_maxdate];
               data.title = titlestr;
            else
               titlestr = data.title;
            end

            data = addmeta(data, ...
               {'Dataset','Title',titlestr; ...
                  'Study','BeginDate',str_mindate; ...
                  'Study','EndDate',str_maxdate; ...
                  'Status','ProjectRelease',str_maxdate; ...
                  'Status','PublicRelease',str_maxdate});

            %perform specific unit conversions, trapping any missing column errors
            if ~isempty(name2col(data,'Precipitation'))
               s2 = unit_convert(data,'Precipitation','mm');
               if ~isempty(s2); data = s2; end
            end
            if ~isempty(name2col(data,'Daily_Total_Precipitation'))
               s2 = unit_convert(data,'Daily_Total_Precipitation','mm');
               if ~isempty(s2); data = s2; end
            end

            %perform general metric unit conversions
            s2 = unit_convert(data,(1:length(data.name)),'metric');
            if ~isempty(s2); data = s2; end

            %generate date part columns *after* unit conversions
            if isstruct(data)
               [data,msg] = add_datepartcols(data);
            else
               data = [];
            end

            %add provisional data flag column to structure
            if ~isempty(data) && ~isempty(provisional_flags)
               data2 = addcol(data,provisional_flags,'Provisional','none','Values flagged as provisional in the USGS database', ...
                  'd','logical','discrete',0,'x<0=''I'';x>1=''I''',3);
               if ~isempty(data2)
                  %add code definition to metadata
                  codelist = lookupmeta(data,'Data','ValueCodes');
                  data = addmeta(data2,{'Data','ValueCodes',[codelist,'|Provisional: 0 = no (accepted value), 1 = yes']});
               end
            end

            %check for flag columns, convert to flag arrays after removing colon separators
            flagcols = find(strncmpi(data.name,'flag_',5));
            if ~isempty(flagcols)
               data2 = string_replace(data,flagcols,':','','partial','insensitive','');
               [data2,msg2] = cols2flags(data2);  %convert USGS flag columns to QA/QC flags
               if ~isempty(data2)  %return modified structure with new flags
                  data = data2;
                  msg = msg2;
               end
            end

            %look up station id from data set
            stationid = extract(data,'StationID');
            if ~isempty(stationid)
               stationid = stationid{1};
            end

            %add station/site metadata from USGS header if generic template used
            if ~isempty(stationid) && strcmp(template,'USGS_Generic') && exist('usgs_stations.mat','file') == 2

               %generate data parameter list for abstract
               Iparms = find(strcmp(data.variabletype,'data') | strcmp(data.variabletype,'calculation'));
               if ~isempty(Iparms)
                  parmlist = [' Parameters retrieved included ',cell2commas(data.name(Iparms),1),'.'];
               else
                  parmlist = '';
               end

               %generate abstract text
               abstract = 'Data were downloaded from the USGS National Water Information System database (http://waterdata.usgs.gov/nwis)';
               if ~isempty(stationlbl)
                  abstract = [abstract,' for ',stationlbl];
               end
               abstract = [abstract,', covering the period ',datestr(mindate,1),' to ',datestr(maxdate,1),'.',parmlist, ...
                     ' The USGS data file was then parsed, transformed and quality-checked using the GCE Data Toolbox for MATLAB ', ...
                     '(http://gce-lter.marsci.uga.edu/public/im/tools/data_toolbox.htm) to create a documented tabular ', ...
                     'data set with parameters in metric units. The USGS investigates the occurrence, quantity, quality, ', ...
                     'distribution, and movement of surface and underground waters and disseminates the data to the public, ', ...
                     'State and local governments, public and private utilities, and other Federal agencies involved with ', ...
                     'managing our water resources.'];

               %init metadata array for updating
               newmeta = {'Dataset','Abstract',abstract};

               %load USGS station descriptor reference data set
               try
                  vars = load('usgs_stations.mat','-mat');
               catch
                  vars = struct('null','');
               end

               if isfield(vars,'data')

                  %search for matching record in 'usgs_stations' data set
                  usgsinfo = querydata(vars.data,['strcmp(Station,''',stationid,''')']);

                  %extract info fields from reference data set to populate metadata
                  if ~isempty(usgsinfo)
                     desc = extract(usgsinfo,'Description',1);
                     if ~isempty(desc)
                        newmeta = [newmeta ; {'Site','Location',[stationid,' -- ',char(desc)]}];
                     end
                     alt = extract(usgsinfo,'Altitude',1);
                     if ~isnan(alt)
                        newmeta = [newmeta ; {'Study','Instrumentation', ...
                                 ['Monitoring station ',stationid,' is installed at an altitude of ',num2str(alt),' meters']}];
                     end
                     drain = extract(usgsinfo,'Drainage',1);
                     if ~isempty(drain)
                        newmeta = [newmeta ; {'Study','Description', ...
                                 ['Measurements from monitoring station ',stationid,' represent a drainage area of ', ...
                                 num2str(drain),' hectares']}];
                     end
                     lon = extract(usgsinfo,'Longitude',1);
                     lat = extract(usgsinfo,'Latitude',1);
                     if ~isnan(lon) && ~isnan(lat)
                        coords = sub_format_coords(lon,lat);
                        if ~isempty(coords)
                           newmeta = [newmeta ; {'Site','Coordinates',[stationid,' -- ',coords]}];
                        end
                     end
                  end

               end

               %add auto-generated metadata
               data = addmeta(data,newmeta,0,'fetch_usgs');

            end

         else

            if ~isempty(msg2)
               msg = ['Errors occurred converting the parsed file to a data structure (imp_ascii error: ', ...
                     msg2,')'];
            end

         end

      else
         msg = 'Unrecognized file format returned from USGS';
      end

   end

end

return

%subfunction for formatting geographic coordinates

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
