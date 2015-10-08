function [s,msg] = parse_climdb_data(fn,pn,template,savetemp)
%Parses tab-delimited data retrieved from the LTER ClimDB/HydroDB web application to create a data structure
%
%syntax: [s,msg] = parse_climdb_data(fn,pn,template,savetemp)
%
%input:
%  fn = name of file to parse
%  pn = path of file to parse
%  template = metadata template to apply after parsing data (default = 'LTER_ClimDB')
%  savetemp = option to retain the temporary parsed data file after successfully importing the data
%    0 = no (default)
%    1 = yes
%
%output:
%  s = data structure containing parsed data set
%  msg = text of any error message
%
%
%(c)2002-2011 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 07-Sep-2011

%init output
s = [];
msg = '';

%apply defaults for omitted parameters
if exist('template','var') ~= 1
   template = 'LTER_climDB';
end

if exist('savetemp','var') ~= 1
   savetemp = 0;
end

%validate path, use current working directory if omitted, invalid
if exist('pn','var') ~= 1
   pn = '';
end
if isempty(pn)
   pn = fileparts(which('parse_climdb_data'));  %default to toolbox directory
elseif exist(pn,'dir') ~= 7
   pn = fileparts(which('parse_climdb_data'));  %default to toolbox directory
elseif strcmp(pn(end),filesep)
   pn = pn(1:end-1);  %strip terminal file separator
end

%validate filename or prompt if blank, not found
if exist('fn','var') ~= 1
   fn = '';
   filemask = '*.txt';
elseif exist([pn,filesep,fn],'file') ~= 2
   filemask = fn;
   fn = '';
end

%prompt for file
if isempty(fn)
   curpath = pwd;
   cd(pn)
   [fn,pn] = uigetfile(filemask,'Select a ClimDB/HydroDB tab-delimited file to parse');
   cd(curpath)
   if fn == 0
      fn = '';  %check for cancel
   end
end

if ~isempty(fn)

   %get base filename of input file
   [tmp,fn_base] = fileparts(fn);

   %init temp file name
   fn2 = [fn_base,'_parsed.txt'];

   %open file handles
   fid1 = fopen([pn,filesep,fn],'r');
   fid2 = fopen([pn,filesep,fn2],'w');

   %get header line
   str = fgetl(fid1);

   %replace date column name with year, month, day for parsing
   tab = char(9);
   str = strrep(str,['Date',tab],['Year',tab,'Month',tab,'Day',tab]);

   %split header on tabs
   ar = splitstr(str,tab);
   numcols = length(ar);

   %init attribute metadata arrays
   colnames = repmat({''},1,numcols);
   units = colnames;
   desc = colnames;
   datatype = colnames;
   vartype = colnames;
   numtype = colnames;
   prec = zeros(1,numcols);
   fstr = '';

   %loop through header row, parse parameters, units, flags and assign descriptors
   for n = 1:numcols
      switch ar{n}
         case 'Site'
            colnames{n} = 'Site';
            units{n} = 'none';
            desc{n} = 'Site~name';
            datatype{n}= 's';
            vartype{n} = 'nominal';
            numtype{n} = 'none';
            fstr_tkn = '%s\t';
         case 'Station'
            colnames{n} = 'Station';
            units{n} = 'none';
            desc{n} = 'Station~name';
            datatype{n} = 's';
            vartype{n} = 'nominal';
            numtype{n} = 'none';
            fstr_tkn = '%s\t';
         case 'Year'
            colnames{n} = 'Year';
            units{n} = 'YYYY';
            desc{n} = 'Calendar year of observation';
            datatype{n} = 'd';
            vartype{n} = 'datetime';
            numtype{n} = 'discrete';
            fstr_tkn = '%d';
         case 'Month'
            colnames{n} = 'Month';
            units{n} = 'MM';
            desc{n} = 'Calendar month of observation';
            datatype{n} = 'd';
            vartype{n} = 'datetime';
            numtype{n} = 'discrete';
            fstr_tkn = '-%d';
         case 'Day'
            colnames{n} = 'Day';
            units{n} = 'DD';
            desc{n} = 'Calendar day of observation';
            datatype{n} = 'd';
            vartype{n} = 'datetime';
            numtype{n} = 'discrete';
            fstr_tkn = '-%d\t';
         case 'Flag'  %flag column - append preceding column name for reconciling flags to columns
            colnames{n} = ['Flag~',colnames{n-1}];
            units{n} = 'none';
            desc{n} = ['QA/QC~flags~for~',colnames{n-1}];
            datatype{n} = 's';
            vartype{n} = 'code';
            numtype{n} = 'none';
            fstr_tkn = '%s\t';
         otherwise  %data column - rely on import template 'LTER_ClimDB' to provide metadata
            colnames{n} = strrep(ar{n},' ','~');  %replace spaces with tilde to prevent parsing errors
            units{n} = '~';
            desc{n} = '~';
            datatype{n} = 'f';
            vartype{n} = 'data';
            numtype{n} = 'u';
            prec(n) = 2;
            fstr_tkn = '%f\t';
      end
      fstr = [fstr,fstr_tkn];
   end
   fstr = fstr(1:end-2);  %trim terminal tab token

   %generate first header rows with tokens for 'imp_ascii' function
   fprintf(fid2,'name:%s',colnames{1});
   fprintf(fid2,'\t%s',colnames{2:end});
   fprintf(fid2,'\r');

   fprintf(fid2,'units:%s',units{1});
   fprintf(fid2,'\t%s',units{2:end});
   fprintf(fid2,'\r');

   fprintf(fid2,'description:%s',desc{1});
   fprintf(fid2,'\t%s',desc{2:end});
   fprintf(fid2,'\r');

   fprintf(fid2,'datatype:%s',datatype{1});
   fprintf(fid2,'\t%s',datatype{2:end});
   fprintf(fid2,'\r');

   fprintf(fid2,'variabletype:%s',vartype{1});
   fprintf(fid2,'\t%s',vartype{2:end});
   fprintf(fid2,'\r');

   fprintf(fid2,'numbertype:%s',numtype{1});
   fprintf(fid2,'\t%s',numtype{2:end});
   fprintf(fid2,'\r');

   fprintf(fid2,'precision:%d',prec(1));
   fprintf(fid2,'\t%d',prec(2:end));
   fprintf(fid2,'\r');

   %generate placeholder title string for metadata
   titlestr = ['Data imported from ClimDB/HydroDB on ',datestr(now,1)];
   fprintf(fid2,['Dataset_Title:',titlestr,'\r']);

   %loop through data rows, clearing 'G' flags and filling in missing values with NaN
   str = fgetl(fid1);
   while ischar(str)
      str = strrep(str,' ','');  %clear blanks
      str = strrep(str,[tab,'G'],[tab,'~']);  %replace any 'G' flags with empty flags
      if ~isempty(strfind(str,[tab,tab]))  %check for missing values (tab-tab), replace with NaN/~
         ar = splitstr_fast(str,tab);  %split string into cell array on tabs
         str = [ar{1},tab,ar{2},tab,ar{3}];  %init revised fixed site, station, date fields
         for n = 4:2:length(ar)-1  %loop through pairs of cols, adding NaN's and missing flags as necessary
            if isempty(ar{n})
               str = [str,tab,'NaN',tab,'~'];  %missing value - add NaN and discard M flag if present
            elseif isempty(ar{n+1})
               str = [str,tab,ar{n},tab,'~'];  %value with missing flag - add null flag
            else
               str = [str,tab,ar{n},tab,ar{n+1}];  %both val and flag valid - add to string unchanged
            end
         end
      elseif str(end) == tab
         str = [str,'~'];  %add terminal empty flag if not present
      end
      fprintf(fid2,'%s\r',str);
      str = fgetl(fid1);
   end

   %close files
   fclose(fid1);
   fclose(fid2);

   %parse formatted import file
   [s,msg] = imp_ascii(fn2,pn,titlestr,template,fstr);

   %clean up dataset to remove null columns, flags
   if ~isempty(s)

      %delete temp file if specified
      if savetemp == 0
         try
            delete([pn,filesep,fn2])
         catch
         end
      end

      %remove empty columns, including flag columns
      s = compactcols(s);

      %convert Climdb flags to GCE flags
      s2 = cols2flags(s);

      %perform other flag post-processing if flag conversion successful, otherwise revert to original structure
      if ~isempty(s2)
         s = s2;
         Iflag = find(strncmp(s.name,'Flag_',5));  %get index of residual flag columns from nulls
         if ~isempty(Iflag)
            histstr = s.history;  %buffer history to avoid delete logging
            s = deletecols(s,Iflag);  %delete extra flag columns
            s.history = histstr;  %restore history
         end
      else
         s2 = [];
      end

      %add MATLAB serial date column, update study data metadata
      s = add_datecol(s);
      s = add_studydates(s);

      %generate data set title with site, station, date range
      titlestr = 'Data retrieved from ClimDB';

      %look up site, station from data set
      sites = extract(s,'Site');
      stations = extract(s,'Station');
      if ~isempty(sites) & ~isempty(stations)
         site = sites{1};
         station = stations{1};
         titlestr = [titlestr,' for ',site,' station ',station];
      end

      %look up studydates
      begindate = lookupmeta(s,'Study','BeginDate');
      enddate = lookupmeta(s,'Study','EndDate');
      if ~isempty(begindate) & ~isempty(enddate)
         titlestr = [titlestr,' from ',begindate,' to ',enddate];
      end

      %update title
      s = newtitle(s,titlestr,0);

   else
      fclose('all');  %try to close open file handles on import error to avoid orphaned files
   end

end