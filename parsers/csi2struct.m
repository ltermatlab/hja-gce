function [msg,fn2] = csi2struct(fn,pn,template,pn2,missingval,year,timezone,year_name,yearday_name,time_name)
%Parses mixed data arrays from a Campbell Scientific Instruments array-based datalogger file
%and generates GCE data structures by matching arrays to an array metadata template file.
%Data structures are named according to the array ID (e.g array_150), and the data structures
%and raw data are all saved as a single MATLAB binary file named according to the input file.
%
%Note: raw data are stored in a custom structure named 'rawdata' containing fields for the
%filename, pathname, date processed, and raw data for each array, pre-pended with a calculated
%serial date column).
%
%syntax: msg = csi2struct(fn,pn,template,pn2,missingval,year,timezone,year_name,yearday_name,time_name)
%
%inputs:
%  fn = filename of CSI datalogger file to parse (prompted if omitted)
%  pn = pathname of the file (default = pwd)
%  template = filename of a metadata template file ('choose' = prompted, default = 'csi2struct.mat')
%  pn2 = alternate pathname for output structures (pn if omitted)
%    (note: GCE Data Structure files will be named [fn]_[nnn].mat, where [nnn] is the array number)
%  missingval = missing value flag recorded by the data logger (default = '-99999')
%  year = year in which data was collected (for conversion of year day to serial day;
%    derived from file date or filename if omitted from the arrays)
%  timezone = time zone of time observations (default = '' for unspecified)
%  year_name = name of the Year column (default = case-insensitive search for a column name 'Year'
%    or column with units 'yyyy')
%  yearday_name = name of the YearDay or JulianDay column for determining day of year (default = 
%    case-insensitive search for a column name starting with 'julian' or 'yearday' or having units 
%    starting with 'day')
%  time_name = name of the Time column for determmining time of day (default = case-insensitive search
%     for a column name starting with 'time' or having units 'hhmm')
%
%output:
%  msg = text indicating the status of the processing
%  fn2 = fully-qualified filename of output file
%
%note:
%  1) if the arrays do not contain a Year column and the collection dates span years,
%     specify the *end* year; year values will be decremented for prior years based on
%     roll-over of year day values
%
%(c)2002-2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 15-Jul-2013

%init output
msg = '';
fn2 = '';

%validate path
if exist('pn','var') ~= 1
   pn = pwd;
elseif ~isdir(pn)
   pn = pwd;
else
   pn = clean_path(pn);  %strip terminal file separator
end

%validate input file
filespec = '*.dat;*.txt;*.asc';
if exist('fn','var') ~= 1
   fn = '';
elseif exist([pn,filesep,fn],'file') ~= 2
   filespec = fn;
   fn = '';
end

%prompt for file if invalid, omitted
if isempty(fn)
   curpath = pwd;
   cd(pn)
   [fn,pn] = uigetfile(filespec,'Select a Campbell datalogger file to process');
   cd(curpath)
   drawnow
   if fn == 0
      fn = '';
   end
end

%set default pn2 if omitted
if exist('pn2','var') ~= 1
   pn2 = pn;
elseif ~isdir(pn2)
   pn2 = pn;
end

if ~isempty(fn)

   %set default template
   if exist('template','var') ~= 1
      template = '';
   end
   if isempty(template)
      template = 'csi2struct.mat';
   elseif strcmp(template,'choose')
      template = '';  %reset to empty to force prompted selection
   end

   %validate missingval
   if exist('missingval','var') ~= 1
      missingval = '';
   elseif isnumeric(missingval)
      missingval = num2str(missingval);
   end
   if isempty(missingval)
      missingval = '-99999';
   end

   %validate year
   if exist('year','var') ~= 1
      year = [];
   elseif ~isnumeric(year)
      if ischar(year)
         year = str2double(year);  %try to convert string year to integer
         if isnan(year)
            year = [];
         else
            year = fix(year);
         end
      else
         year = [];
      end
   end

   %set default time zone if omitted, otherwise validate and format for appending to date units
   if exist('timezone','var') ~= 1
      timezone = '';
   elseif ischar(timezone) && length(timezone) == 3
      timezone = [' - ',upper(timezone)];
   end
   
   %default to year from filename prefix or file date if missing, invalid
   if isempty(year)
      if length(fn) >= 4
         year = str2double(fn(1:4));  %try to parse year from filename (first 4 chars)
         if ~isnan(year)
            if year < 1950 || year > 2050
               year = [];
            end
         else
            year = [];  %convert back to empty array
         end
      end
      if isempty(year)
         fileinfo = dir([pn,filesep,fn]);  %get file info
         dvec = datevec(datenum(fileinfo.date));  %parse file date
         year = dvec(1);  %get year from file date vector
      end
   end

   %init runtime arrays
   arraymeta = [];
   metadata = [];
   v = struct('null','');
   mlv = mlversion;  %get matlab version for regex syntax

   %load metadata template
   if exist(template,'file') == 2
      try
         v = load(template,'-mat');
      catch
      end
   elseif exist([pn,filesep,template],'file') == 2
      try
         v = load([pn,filesep,template],'-mat');
      catch
      end
   else  %prompt for template
      curpath = pwd;
      if isdir([gce_homepath,filesep,'userdata'])
         cd([gce_homepath,filesep,'userdata'])
      else
         cd(pn)
      end
      [fn_meta,pn_meta] = uigetfile('csi2struct.mat;*.mat','Please select a metadata template file to apply');
      cd(curpath)
      drawnow
      if fn_meta ~= 0
         try
            v = load([pn_meta,filesep,fn_meta],'-mat');
         catch
         end
      end
   end

   %load metadata
   if isfield(v,'data')
      arraymeta = v.data;
      metadata = arraymeta.metadata;
   end

   %check for successful metadata template loading
   if ~isempty(arraymeta) && gce_valid(arraymeta,'data') == 1

      %init runtime vars
      rawdata = struct('file',fn, ...
         'path',pn, ...
         'date',datestr(now));
      lbls = [];
      vals = [];
      tmplbls = cell(500,1);
      tmpvals = cell(500,1);
      ctr = 0;

      %read file, read first line
      fid = fopen([pn,filesep,fn],'r');
      ln = deblank(fgetl(fid));

      %loop through rows parsing array labels
      while ischar(ln)

         ln = deblank(ln);  %remove trailing spaces

         if ~isempty(ln)

            %strip carriage returns
            ln = strrep(ln,char(13),'');

            %check for data line
            if ~strcmp(ln(1),',')

               %replace missing value code (flanked by commas or at beginning or end of line) with NaN
               %note: uses pattern tokens to ensure correct before/after characters used around NaN
               if mlv >= 7
                  ln = regexprep(ln,['(,|\s|)',missingval,'(,|\s|)'],'$1NaN$2');
               else
                  ln = regexprep(ln,['(,|\s|)',missingval,'(,|\s|)'],'$1NaN$2','tokenize');  %specify tokenize option for ML 6.5
               end

               %get index of commas
               Icomma = strfind(ln,',');

               %check for valid data row with array, timestamp, data values
               if length(Icomma) >= 3

                  %increment buffer counter
                  ctr = ctr + 1;

                  %check to see if need to clear buffer
                  if ctr > 500
                     lbls = [lbls ; tmplbls];
                     vals = [vals ; tmpvals];
                     tmplbls = cell(500,1);
                     tmpvals = cell(500,1);
                     ctr = 1;
                  end

                  %get array label
                  lbl = ln(1:Icomma(1)-1);

                  if length(lbl) <= 5
                     tmplbls{ctr} = lbl;  %grab first token as array id
                     tmpvals{ctr} = ln(Icomma(1)+1:end);  %grab remainder of row
                  end

               end

            end

         end

         ln = fgetl(fid);  %read next line

      end

      fclose(fid);  %close file

      %add remaining temp buffers to label and value arrays
      lbls = [lbls ; tmplbls(1:ctr)];
      vals = [vals ; tmpvals(1:ctr)];

      %get base filename for output
      [tmp,basefn] = fileparts(fn);
      fn2 = [pn2,filesep,basefn,'.mat'];

      %init variable list with raw data array
      varlist = 'save(fn2,''rawdata''';  %init eval script

      %generate list of array lables
      if ~cellfun('isempty',lbls)
         lbl_list = unique(lbls);
      else
         lbl_list = [];
      end
      
      %process each array
      for n = 1:length(lbl_list)

         Ilbl = find(strcmp(lbls,lbl_list{n}));  %get index of matching rows

         %generate output array
         ar = vals(Ilbl);  %get array of values for the matched array
         ar2 = [ar , repmat({','},length(Ilbl),1)]';
         ar2 = [ar2{:}];  %concatenate data to form continuous comma-delim string for parsing

         Icomma = strfind(ar{1},',');
         parms = length(Icomma) + 1;

         %count leading decimal fields of first, middle and last records for format string assignment
         decimals = zeros(3,1);
         recs = [1,ceil(length(ar)./2),length(ar)];
         for m = 1:length(recs);
            teststr = splitstr(ar{recs(m)},',');
            for cnt = 1:length(teststr)
               if isempty(strfind(teststr{cnt},'.'))
                  decimals(m) = decimals(m) + 1;
               else
                  break
               end
            end
         end
         numints = min(decimals);  %use minimum estimate

         %generate format string, parse data into output array
         fstr = [repmat('%d,',1,numints),repmat('%f,',1,parms-numints)];
         mat = sscanf(ar2,fstr,[parms,inf])';

         %store array in rawdata structure
         rawdata.(['array_',lbl_list{n}]) = mat;

         %look up attribute metadata in csi2struct.mat
         meta = querydata(arraymeta,['ArrayID=',lbl_list{n},' & Column>1']);

         if ~isempty(meta) && ~isempty(mat)

            if length(meta.values{1}) == size(mat,2)

               %sort by column, extract info columns
               meta = sortdata(meta,'Column',1);
               colnames = extract(meta,'Name')';
               vartypes = extract(meta,'VariableType')';
               units = extract(meta,'Units')';
               arraynames = extract(meta,'ArrayName');
               if ~isempty(arraynames)
                  arrayname = arraynames{1};
               else
                  arrayname = '';
               end

               %look up datetime columns for date calculation based on metadata
               dtcols = find(strcmp(vartypes,'datetime'));
               Iyearcol = [];
               Iyeardaycol = [];
               Itimecol = [];
               yearcol = [];
               yeardaycol = [];
               timecol = [];
               
               %set default year column name if omitted
               if exist('year_name','var') ~= 1
                  year_name = '';
               end
               
               %set default year day column if omitted
               if exist('yearday_name','var') ~= 1
                  yearday_name = '';
               end

               %set default time column if omitted
               if exist('time_name','var') ~= 1
                  time_name = '';
               end
               
               %look up year
               if ~isempty(year_name)
                  %look up specified column
                  Iyearcol = find(strcmpi(colnames,year_name));
               end
               if isempty(Iyearcol)
                  %search for column
                  Iyearcol = find(strcmpi(colnames(dtcols),'Year') | strcmpi(units(dtcols),'yyyy'));
               end
               if ~isempty(Iyearcol)
                  yearcol = dtcols(Iyearcol(1));
               end
               
               %look up yearday
               if ~isempty(yearday_name)
                  %look up specified column
                  Iyeardaycol = find(strcmpi(colnames,yearday_name));
               end
               if isempty(Iyeardaycol)
                  %search for column
                  Iyeardaycol = find(strcmpi(colnames(dtcols),'yearday') | strncmpi(colnames(dtcols),'jul',3) | strncmpi(units(dtcols),'day',3));
               end
               if ~isempty(Iyeardaycol)
                  yeardaycol = dtcols(Iyeardaycol(1));
               end
               
               %look up time
               if ~isempty(time_name)
                  %look up specified column
                  Itimecol = find(strcmpi(colnames,time_name));
               end
               if isempty(Itimecol)
                  %search for column
                  Itimecol = find(strncmpi(colnames(dtcols),'time',4) | strncmpi(colnames(dtcols),'hour',4) | strncmpi(units(dtcols),'hr',2) | strcmpi(units(dtcols),'hhmm'));
               end
               if ~isempty(Itimecol)
                  timecol = dtcols(Itimecol(1));
               end
               
               %check for both yearday and time columns
               if length(yeardaycol) == 1 && length(timecol) == 1
               
                  %use yearday for day
                  dy = mat(:,yeardaycol);
                  
                  %check for year column in array
                  if ~isempty(yearcol)  
                     
                     %use year column from data if available
                     yr = mat(:,yearcol);
                     
                  else  %use specified/estimated year
                  
                     %init matching year array
                     yr = repmat(year,size(mat,1),1);
                     
                     %check for yearday rollover and adjust years prior to transition
                     daydiff = diff(dy);
                     Idiff = find(daydiff<0);
                     
                     %loop through breaks, adjust years by index
                     for cnt = 1:length(Idiff)
                        if cnt == 1
                           Istart = 1;
                           Iend = Idiff(1);
                        else
                           Istart = Idiff(cnt-1) + 1;
                           Iend = Idiff(cnt);
                        end
                        offset = (length(Idiff)-cnt+1);  %calculate offset
                        yr(Istart:Iend) = yr(Istart:Iend) - offset;  %decrement year for relevant segment
                     end
                     
                  end
                  
                  %add calculated serial date (optionally converted to GMT) to each array
                  padzeros = zeros(size(mat,1),1);
                  mo = padzeros;  %use zeros for month
                  hr = fix(mat(:,timecol)./100);  %calc decimal hours
                  mi = mat(:,timecol)-fix(mat(:,timecol)./100).*100;  %calc minutes
                  sc = padzeros;  %use zeros for seconds
                  d = datenum(yr,mo,dy,hr,mi,sc);  %calc serial date
                  mat = [d,mat];
                  
               else
                  mat = [ones(size(mat,1),1).*NaN,mat];  %prepend array of NaN in place of date column
               end

               %create GCE Data Structure
               data = newstruct('data');
               if ~isempty(arrayname)
                  titlestr = ['Data from CSI datalogger array ',arrayname,' (array ',lbl_list{n},') parsed from ''', ...
                        fn,''' on ',datestr(now,1)];
               else
                  titlestr = ['Data from CSI datalogger array ',lbl_list{n},' parsed from ''', ...
                        fn,''' on ',datestr(now,1)];
               end
               
               %populate structure fields
               data.title = titlestr;
               data.datafile = [{fn},{size(mat,1)}];
               data.name = [{'Date'} , colnames];
               data.units = [{['serial day (base 1/1/0000)',timezone]} , extract(meta,'Units')'];
               data.description = [{'Fractional serial day (based on 1 = January 1, 0000)'} , extract(meta,'Description')'];
               data.datatype = [{'f'} , extract(meta,'DataType')'];
               data.variabletype = [{'datetime'} , vartypes];
               data.numbertype = [{'continuous'}, extract(meta,'NumberType')'];
               data.precision = [6 , extract(meta,'Precision')'];
               data.criteria = [{''} , extract(meta,'Criteria')'];
               data.metadata = metadata;
               data.history = [data.history ; {datestr(now)}, ...
                     {['parsed data from Campbell Scientific Instruments datalogger output file and ', ...
                           'assigned metadata descriptors based on array ID and column position (''csi2struct'')']}];
               data.values = num2cell(mat,1);
               data.flags = repmat({''},1,length(data.name));

               %validate structure
               [val,stype,msg0] = gce_valid(data,'data');

               if val == 1 && strcmp(stype,'data')
                  data_temp = add_studydates(data);
                  if ~isempty(data_temp)
                     data = data_temp;
                  end
                  data = dataflag(data);
                  if ~isempty(data)
                     eval(['array_',lbl_list{n},'=data;'])
                     varlist = [varlist,',''array_',lbl_list{n},''''];
                  else
                     msg0 = 'An error occurred updating Q/C flags';
                     data = [];
                  end
               else
                  data = [];
               end

               %generate output message
               if ~isempty(data)
                  msg = char(msg,['  successfully generated GCE Data Structure for data in array ',lbl_list{n}]);
               else
                  msg = char(msg,['  error: metadata for array ',lbl_list{n}, ...
                        ' was missing or invalid (GCE Data Structure not saved) - ',msg0]);
               end

            end

         end

      end

      varlist = [varlist,');'];  %finalize data storage script
      try
         eval(varlist)
         msg = char(['Arrays successfully parsed from ',fn,' and saved as ',basefn,'.mat'],msg);
      catch
         msg = 'A MATLAB error occurred save the parsed data structures';
      end

   else
      msg = ['CSI array metadata stored in ''',template,''' was invalid or the template was not found'];
   end

end