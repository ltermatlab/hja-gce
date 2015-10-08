function [s,msg] = imp_nerr_cdmo(fn,pn,template,titlestr,deletetemp)
%Imports CSV files downloaded from the National Estuarine Research Reserve CDMO web site
%(http://cdmo.baruch.sc.edu/)
%
%Note that this parser assumes the following file structure (2010 CDMO format):
%  3 header rows (legend note, units, column names)
%  footer starting with "******Legend******"
%  numeric flag codes after each variable denoted by <#>
%  NaN or empty field for missing values
%  trailing comma potentially present after column titles, data rows
%
%syntax:  [s,msg] = imp_nerr_cdmo(fn,pn,template,title,deletetemp)
%
%inputs:
%  fn = file name to import (default = prompted)
%  pn = pathname for fn (default = pwd)
%  template = metadata template (default = 'NERR_CDMO_Website')
%  title = data set title (default = 'Monitoring data downloaded from the NERR CDMO web site')
%  deletetemp = option to delete temporary file on successful parsing (0 = no, 1 = yes/default)
%
%outputs:
%  s = GCE Data Structure
%  msg = text of any error messages
%
%(c)2009-2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 01-Jun-2015

%initialize outputs:
s = [];
msg = '';

%define parameters
curpath = pwd;
if exist('template','var') ~= 1
   template = 'NERR_CDMO_Website';
end
if exist('titlestr','var') ~= 1
   if strcmp(template,'NERR_CDMO_Website')
      titlestr = 'Monitoring data downloaded from the NERR CDMO web site';  %set default title unless provided as input
   else
      titlestr = '';  %use template title
   end
end

%validate path
if exist('pn','var') ~= 1
   pn = curpath;
elseif ~isdir(pn)
   pn = curpath;
else
   pn = clean_path(pn);
end

%prompt for file if omitted or invalid
if exist('fn','var') ~= 1
   cd(pn)
   [fn,pn] = uigetfile('*.txt;*.csv;*.asc;*.ans;*.dat','Select a text file to import');
   cd(curpath)
elseif exist([pn,filesep,fn],'file') ~= 2
   [fn,pn] = uigetfile(fn,'Locate the text file to import');
end
drawnow

%pass filename, pathname, and static parameters to custom ASCII import filter
if fn ~= 0
   
   %set default delete option if omitted
   if exist('deletetemp','var') ~= 1
      deletetemp = 1;
   end
   
   %generate intermediate file with modified header, legend removed, angle brackets removed from flags
   [tmp,fn_base,fn_ext] = fileparts(fn);
   fn_clean = [fn_base,'_clean',fn_ext];
   fid = fopen([pn,filesep,fn],'r');
   fid2 = fopen([pn,filesep,fn_clean],'w');
   
   %read header lines, first data row
   ln = fgetl(fid); %burn first line
   colunits = fgetl(fid); %grab units
   coltitles = fgetl(fid); %grab column titles
   
   %clean up units, column titles
   colunits = strrep(strrep(colunits,'Flag Code See Legend','none'),'See Legend','none');
   coltitles = regexprep(coltitles,'[ "]','');
   coltitles = strrep(coltitles,'F_Record','Record');
   if strcmp(coltitles(end),',')
      coltitles = coltitles(1:end-1);  %strip terminal comma if present
   end
   
   %init attribute metadata lookup array
   flds = {'Station_Code','s','nominal','none'; ...
      'isSWMP','s','code','none'; ...
      'DateTimeStamp','s','datetime','none'; ...
      'Historical','d','code','discrete'; ...
      'ProvisionalPlus','d','code','discrete'; ...
      'Record','d','ordinal','discrete'};
   
   %generate datatype string (date/time string, historical flag, provisional flag, value/flag pairs)
   numfields = length(strfind(coltitles,',')) + 1;
   
   %init attribute metadata arrays
   ar_cols = splitstr(coltitles,',');
   ar_units = splitstr(colunits,',');
   dtypes = repmat({''},1,numfields);
   vtypes = dtypes;
   ntypes = dtypes;
   
   %assign attribute metadata
   for n = 1:length(ar_cols)
      Isel = find(strcmpi(ar_cols{n},flds(:,1)));
      if ~isempty(Isel)  %fixed column
         dtypes{n} = flds{Isel(1),2};
         vtypes{n} = flds{Isel(1),3};
         ntypes{n} = flds{Isel(1),4};
         ar_units{n} = 'none';  %clear CDMO units for fixed fields
      elseif strncmpi(ar_cols{n},'F_',2)  %flag column
         dtypes{n} = 'd';
         vtypes{n} = 'code';
         ntypes{n} = 'discrete';
      else  %data column
         dtypes{n} = 'f';
         vtypes{n} = 'data';
         ntypes{n} = 'continuous';
      end
   end   
   
   %write new header for imp_ascii function
   fprintf(fid2,'%s\r\n',coltitles);
   
   ln = fgetl(fid); %get next line
   while ischar(ln)
      if strncmp(ln,'***',3)
         break
      elseif ~isempty(ln)
         ln = regexprep(ln,' (\(|\[)\w*(\)|\])','');  %remove text qualifiers after bracketed flags
         ln = regexprep(ln,'(<|>|\(|\)|\[|\])+','');  %remove brackets from flags
         ln = regexprep(ln,',(NAN)?,',',NaN,');  %use NaN for empty values (replacing NAN)
         ln = regexprep(ln,'\s*,\s*',',');  %trim spaces around delimiters
         ln = regexprep(ln,',\D{3},',',NaN,');  %replace NAN or any residual 3-letter flags with NaN
         if strcmp(ln(end),',')
            ln = ln(1:end-1);  %strip last comma if present
         end
         fprintf(fid2,'%s\r\n',ln);  %write line
      end
      ln = fgetl(fid); %read next line
   end
   
   %close file handles
   fclose(fid);
   fclose(fid2);
   
   %import the data file
   fstr = ['%',strrep(cell2commas(dtypes,3),',',' %')];
   [s,msg] = imp_ascii(fn_clean,pn,'',template,fstr,coltitles,1,'',',');
   
   if ~isempty(s)
      
      %add units if no specific template defined
      if strcmp(template,'NERR_CDMO_Website') && ~isempty(ar_units) && length(ar_units) == length(ar_cols)
         for n = 1:length(ar_cols)
            s = update_attributes(s,n,'units',ar_units{n});
         end
      end
      
      %delete temp file
      if deletetemp == 1
         try
            delete([pn,filesep,fn_clean])
         catch
            msg = ['an error occurred deleting the temporary file ',pn,filesep,fn_clean];
         end
      end
      
      %update the title
      if ~isempty(titlestr)
         s = newtitle(s,titlestr);
      end
      
      %map NERR flags to GCE flags
      s = cols2flags_mapped(s,'NERR_CDMO');
      
      %generate serial date and date part columns from string date/time stamp (d/m/yy h:m)
      dts_pos = name2col(s,'DateTimeStamp');
      if ~isempty(dts_pos)
         
         dts = extract(s,'DateTimeStamp');  %extract date/time
         dt = ones(length(dts),1) .* NaN;   %init serial data array
         
         %loop through strings, parse date/time components
         for n = 1:length(dts)
            try
               ar = sscanf(dts{n},'%d/%d/%d %d:%d');  %try parsing date/time components
               if ar(3) < 70
                  ar(3) = 2000 + ar(3);  %use 2000 as base year
               elseif ar(3) < 100
                  ar(3) = 1900 + ar(3);  %use 1900 as base year if 2 digit year >70
               end
               dt(n) = datenum(ar(3),ar(1),ar(2),ar(4),ar(5),0);  %generate serial date
            catch
               dt = NaN;
            end
         end
         
         %check for valid calculated dates, add columns
         if sum(~isnan(dt)) > 0
            
            %delete original date/time stamp
            s = deletecols(s,dts_pos);
            
            %add calculated serial date
            s = addcol(s, ...
               dt, ...
               'Date', ...
               'serial day (base 1/1/0000)', ...
               'Date of measurement', ...
               'f', ...
               'datetime', ...
               'continuous', ...
               6, ...
               '', ...
               dts_pos);  
            
            %generate date part columns
            s = add_datepartcols(s);  
            
            %add study dates to metadata
            s = add_studydates(s);  
            
         end
         
      end
      
   end
   
end