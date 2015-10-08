function [s,msg,s_raw] = imp_ncdc_ghcnd(fn,pn,template,datestart,dateend,silent,deleteopt)
%Imports climate data from a NCDC Global Historic Climate Network daily summary file to create a GCE Data Structure
%
%syntax: [s,msg,s_raw] = imp_ncdc_ghcnd(fn,pn,template,datestart,dateend,silent,deleteopt)
%
%input:
%  fn = name of the data file to import
%  pn = path of the data file to import (default = pwd)
%  template = metadata template to use (default = 'NCDC_GHCND')
%  datestart = beginning year and month to return (YYYYMM, default = [] for earliest available)
%  dateend = ending year and month to return (YYYYMM, default = [] for latest available)
%  silent = option to suppress progress bar status updates if GUI mode (0 = no/default, 1 = yes)
%  deleteopt = option to delete the temporary tabular file (0 = no, 1 = yes/default)
%
%output:
%  s = GCE data structure
%  msg = text of any error messages
%  s_raw = initial GCE data structure prior to denormalization and application of attribute metadata
%
%notes:
%  1) Parameter definitions in 'ncdc_ghcnd_parameters.mat' are used to translate integers
%     into standard numeric fields and to apply parameter-specific metadata to attributes
%  2) A monotonic time series data set will be generated for the full period of record
%  3) Only quality control information in the QFlags columns will be preserved as QA/QC flags
%  4) The normalized raw table (s_raw) only contains records for non-null (non-NaN) observations
%
%
%(c)2011-2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 27-Jun-2013

%initialize output
s = [];
s_raw = [];

%check for required file argument and presence of parameter database file
if nargin >= 1 && exist('ncdc_ghcnd_parameters.mat','file') == 2
   
   %validate path
   if exist('pn','var') ~= 1
      pn = pwd;
   else
      pn = clean_path(pn);
   end
   
   %validate filename location
   if exist([pn,filesep,fn],'file') == 2
      
      %supply default template if omitted
      if exist('template','var') ~= 1
         template = 'NCDC_GHCND';
      end
      
      %supply default silent option if omitted
      if exist('silent','var') ~= 1 || isempty(silent)
         silent = 0;
      end
   
      %supply default start date or validate
      if exist('datestart','var') ~= 1
         datestart = [];
      end
      if ischar(datestart) && length(datestart) == 6
         datestart = str2double(datestart);  %convert string to integer value
      elseif isempty(datestart)
         datestart = 0;  %set 0 to include all dates
      end
      
      %supply default end date or validate
      if exist('dateend','var') ~= 1
         dateend = [];
      end
      if ischar(dateend) && length(dateend) == 6
         dateend = str2double(dateend);  %convert string to integer value
      elseif isempty(dateend)
         dvec = datevec(now);
         dateend = dvec(1).*100 + dvec(2);  %convert current date to yyyymm integer
      end
      
      %supply default delete option if omitted
      if exist('deleteopt','var') ~= 1
         deleteopt = 1;
      end
      
      %check for parameters file
      try
         v = load('ncdc_ghcnd_parameters.mat','-mat');
         parmlist = v.data;
         if gce_valid(parmlist,'data') ~= 1
            parmlist = [];
         end
      catch
         parmlist = [];
      end
      
      %check for successful parameter list load
      if ~isempty(parmlist)
         
         %check for GUI mode based on presence of an open data editor window
         guimode = 0;
         if length(findobj) > 1
            h = findobj('Tag','dlgDSEditor');
            if ~isempty(h)
               guimode = 1;
            end
         end
         
         %init progress bar if in gui mode
         if silent == 0 && guimode == 1
            ui_progressbar('init',4,'Import NCDC GHCND File');
            ui_progressbar('update',1,'Normalizing GHCN-D file format ...');
         end
         
         %call parsing subroutine to convert GHCND report into a skinny, tabular data set
         [s_raw,msg] = parse_ncdc_ghcnd(fn,pn,datestart,dateend,deleteopt);
         
         %update progress bar
         if silent == 0 && guimode == 1
            ui_progressbar('update',2,'Reformatting and applying metadata ...');
         end
         
         %check for valid raw table structure
         if ~isempty(s_raw)
            
            %get flag definitions from parameter data set metadata
            flagmeta = lookupmeta(parmlist,'Data','Codes');
            
            %get station id from parsed file
            station = unique(extract(s_raw,'Station'));
            
            %check for unsupported multi-station file format
            if length(station) == 1
               
               %get value and QFlag arrays
               allvals = extract(s_raw,'Value');
               allflags = extract(s_raw,'QFlag');
               
               %get numeric serial dates
               dt_str = extract(s_raw,'Date');
               if mlversion >= 8
                  %use format-specific datenum
                  dt = datenum(dt_str,'mm/dd/yyyy');
               else
                  %use generic datenum
                  dt = datenum(dt_str);
               end
               
               %get date range
               dt_min = min(no_nan(dt));
               dt_max = max(no_nan(dt));
               
               %generate complete date range and formatted string version
               dt_full = (dt_min:dt_max)';
               
               %get list of all unique parameter codes
               parms_all = extract(s_raw,'Parameter');
               parms = unique(parms_all);
               
               %init primary output structure with title and Q/C flag definitions
               s = newstruct('data');
               s.datafile = s_raw.datafile;  %copy file import info from raw structure
               s = newtitle(s,['Data imported from NCDC GHCN station ',char(station),' on ',datestr(now,1)]);
               s = addmeta(s,{'Data','Codes',flagmeta},1);
               
               %add station and date columns to output structure
               s = addcol(s,dt_full,'Date','serial day (base 1/1/0000)','Date of observation', ...
                  'f','datetime','continuous',0,'',1);
               s = addcol(s,repmat(station,length(dt_full),1),'Station','none', ...
                  'Global Historic Climate Network station identifier','s','nominal','none',0,'',0);

               %loop through parameters, looking up metadata and adding padded data columns and Qflags
               for n = 1:length(parms)
                  
                  %filter parameters data set based on current parameter (1 record result)
                  parm = parms{n};
                  meta = querydata(parmlist,['strcmp(''',parm,''',Variable)']);
                  
                  %get attribute metadata values
                  if ~isempty(meta)
                     desc = char(extract(meta,'Description'));
                     dtype = char(extract(meta,'DataType'));
                     vtype = char(extract(meta,'VariableType'));
                     ntype = char(extract(meta,'NumberType'));
                     units = char(extract(meta,'Units_Original'));
                     newunits = char(extract(meta,'Units'));
                     mult = extract(meta,'Multiplier');
                     crit = char(extract(meta,'Criteria'));
                     prec = extract(meta,'Precision');
                     codes = char(extract(meta,'Codes'));
                  else
                     desc = '';
                     dtype = 'd';
                     vtype = 'data';
                     ntype = 'discrete';
                     units = '';
                     newunits = '';
                     mult = 1;
                     crit = '';
                     prec = 0;
                     codes = '';
                  end
                  
                  %get index of records for parameter
                  Iparm = find(strcmp(parm,parms_all));
                  
                  %get values and QFlags
                  vals = allvals(Iparm);
                  flags = allflags(Iparm);
                  
                  %check for missing dates for parameter
                  dt_parm = dt(Iparm);
                  baddates = setdiff(dt_full,dt_parm);
                  numdates = length(baddates);
                  
                  %pad records if any missing dates
                  if ~isempty(numdates)
                  
                     %append missing dates to date array and pad value/flag arrays with nulls
                     dt_parm = [dt_parm ; baddates];
                     vals = [vals ; repmat(NaN,numdates,1)];
                     flags = [flags ; repmat({''},numdates,1)];
                     
                     %sort dates, apply sort index to values, flags
                     [dt_parm,Isort] = sort(dt_parm);
                     vals = vals(Isort);
                     flags = flags(Isort);
                     
                  end
                  
                  %add value and flag arrays to structure
                  s = addcol(s,vals,parm,units,desc,dtype,vtype,ntype,prec,crit);
                  s = addcol(s,flags,['Flag_',parm],'none',['Quality control flags for ',parm], ...
                     's','code','none',0,'');
                  
                  %check for unit conversion
                  if mult ~= 1
                     s = unit_convert(s,parm,newunits,mult);
                  end
                  
                  %check for code definitions, add to metadata
                  if ~isempty(codes)
                     oldcodes = lookupmeta(s,'Data','ValueCodes');
                     [codenames,codevals] = splitcodes(codes);
                     codemeta = update_codes({'Data','ValueCodes',oldcodes},parm,codenames,codevals);
                     if ~isempty(codemeta)
                        s = addmeta(s,codemeta,0,'imp_ncdc_ghcnd');
                     end
                  end
                  
                  if isempty(s)
                     msg = ['An error occurred refactoring the data set at parameter ''',parm,''''];
                     break
                  end
                  
               end

               %finalize output structure
               if ~isempty(s)
                  
                  if silent == 0 && guimode == 1
                     ui_progressbar('update',3,'Finalizing data structure ...');
                  end

                  %check for mean air temp, calculate from TMAX and TMIN if not present
                  tmean = name2col(s,'TMEAN');
                  if isempty(tmean)
                     tmax = name2col(s,'TMAX');
                     tmin = name2col(s,'TMIN');
                     if ~isempty(tmax) && ~isempty(tmin)
                        s = add_calcexpr(s,'(TMAX+TMIN)./2','TMEAN',s.units{tmax}, ...
                           'Daily mean air temperature calculated from daily maximum and minimum temperature', ...
                           min(tmax,tmin)+1,0,s.criteria{tmax});
                     end
                  end
                  
                  %apply metadata template
                  if ~isempty(template)
                     s = apply_template(s,template);
                  end
                  
                  %check for generic template and add content from ncdc_ghcnd_stations.mat
                  if isempty(template) || strcmp('NCDC_GHCND',template)                     
                     s_tmp = add_ncdc_metadata(s,char(station));
                     if ~isempty(s_tmp)
                        s = s_tmp;
                     end
                  end
                  
                  %convert Qflags to Q/C flag arrays
                  s = cols2flags(s); 
                  
                  %add date/part columns
                  s = add_datepartcols(s,'Date');

                  %add study date metadata
                  s = add_studydates(s,'Date');

                  %convert precip to cm if present
                  col_prcp = name2col(s,'Daily_Total_Precipitation');
                  if ~isempty(col_prcp)
                     s = unit_convert(s,col_prcp,'cm');
                  end
                  
               end
               
            else
               msg = 'Multi-station NCDC data files are not supported';
            end
            
         end
         
         if silent == 0 && guimode == 1
            ui_progressbar('close')
         end
         
      else
         msg = 'The NCDC GHCND parameter metadata file ''ncdc_ghcnd_parameters.mat'' is invalid';
      end
      
   else
      msg = 'Invalid filename or path';
   end
   
else
   if nargin == 0
      msg = 'A valid filename is required';
   else
      msg = 'The NCDC GHCND parameter metadata file ''ncdc_ghcnd_parameters.mat'' is not present in the MATLAB path';
   end
end

return

function [s,msg] = parse_ncdc_ghcnd(fn,pn,datestart,dateend,deleteopt)
%Converts a NCDC GHCND report file into tabular form and returns a GCE Data Structure
%
%Note that the data structure returned will contain a highly normalized ("skinny") data set with
%columns for Station, Date, Parameter, Value, MFlag, QFlag and SFlag, that only contains
%non-empty (non-NaN) values.
%
%syntax: [s,msg] = parse_ncdc_ghcnd(fn,pn,deleteopt)
%
%input:
%  fn = name of the data file to parse
%  pn = path of the data file to parse (default = pwd)
%  datestart = beginning year and month to return (YYYYMM integer)
%  dateend = ending year and month to return (YYYYMM integer)
%  deleteopt = option to delete the temporary tabular file (0 = no, 1 = yes/default)
%
%output:
%  s = resultant data structure
%  msg = text of any error messages
%
%
%(c)2011 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 30-Nov-2011

s = [];

if nargin == 5
   
   %parse base filename from input file to generate output file
   [tmp,fn_base,fn_ext] = fileparts(fn);
   fn2 = [fn_base,'_table',fn_ext];
   
   %open input and output file handles
   fid = fopen([pn,filesep,fn],'r');
   fid2 = fopen([pn,filesep,fn2],'w');
   
   %generate header for automated parsing with imp_ascii.m
   fprintf(fid2,'name:Station\tDate\tParameter\tValue\tMFlag\tQFlag\tSFlag\r');
   fprintf(fid2,'units:none\tMM/DD/YYYY\tnone\tnone\tnone\tnone\tnone\r');
   fprintf(fid2,'datatype:s\ts\ts\td\ts\ts\ts\r');
   fprintf(fid2,'variabletype:nominal\tdatetime\tnominal\tdata\tcode\tcode\tcode\r');
   fprintf(fid2,'numbertype:none\tnone\tnone\tdiscrete\tnone\tnone\tnone\r');
   fprintf(fid2,'precision:0\t0\t0\t0\t0\t0\t0\r');
   
   %read first line of input file
   ln = fgetl(fid);
   
   %loop through input file, checking for EOF (ln = -1)
   while ischar(ln)
      
      len = length(ln);
      
      %check for valid record length
      if len >= 266
         
         %parse fixed fields for record
         station = ln(1:11);
         yr = ln(12:15);
         mn = ln(16:17);
         parm = ln(18:21);
         
         %calculate yyyymm integer for date range check
         daterec = str2double([yr,mn]);
         
         %check for in-range date, then parse days to generate records
         if daterec >= datestart && daterec <= dateend
            
            %loop through 31 daily values
            for n = 1:31
               
               %calculate positional offset for string parsing
               offset = 22 + 8 .* (n-1);
               
               %get measurement value, check for missing value
               val = ln(offset:offset+4);
               if strcmp(val,'-9999')
                  val = NaN;
               else
                  try
                     %convert string to numeric value
                     val = str2double(val);
                  catch
                     val = NaN;
                  end
               end
               
               if ~isnan(val)
                  
                  %generate date string (mm/dd/yyyy) from year, month, day strings
                  dt = [mn,'/',sprintf('%02d',n),'/',yr];
                  
                  %initialize flags with tildes
                  mflag = '~';
                  qflag = '~';
                  sflag = '~';
                  
                  %check for value flag codes to parse, replacing spaces with tildes to ensure proper import
                  if n < 31 || len >= offset + 7
                     mflag = strrep(ln(offset+5),' ','~');
                     qflag = strrep(ln(offset+6),' ','~');
                     sflag = strrep(ln(offset+7),' ','~');
                  end
                  
                  %write record for day, including station, date, parameter, parameter value and flags
                  fprintf(fid2,'%s\t%s\t%s\t%d\t%s\t%s\t%s\r',station,dt,parm,val,mflag,qflag,sflag);
                  
               end
               
            end
            
         end
         
      end
      
      %read next line
      ln = fgetl(fid);
      
   end
   
   %close file handles
   fclose(fid);
   fclose(fid2);
   
   %import the tabular output file
   [s,msg] = imp_ascii(fn2,pn);
   
   %delete the tabular output file on success if specified
   if ~isempty(s) && deleteopt == 1 && exist([pn,filesep,fn2],'file') == 2
      try
         delete([pn,filesep,fn2])
      catch e
         msg = ['an error occurred deleting the temporary file ',pn,filesep,fn2,' (',e.message,')'];
      end
   end
   
else
   msg = 'insufficient arguments for ''parse_ncdc_ghcnd'' subfunction';
end

return