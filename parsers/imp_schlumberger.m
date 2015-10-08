function [s,msg] = imp_schlumberger(fn,pn,template,workflow)
%Import filter for GCE Schlumberger CTD-Diver or Cera-Diver groundwater data logger files
%
%syntax:  [s,msg] = imp_schlumberger(fn,pn,template,workflow)
%
%inputs:
%  fn = file name to import (default = prompted)
%  pn = pathname for fn (default = pwd)
%  template = metadata template (default = '' for automatic selection of 'GCE_CTD_Diver' or
%     'GCE_Cera_Diver' based on header information)
%  workflow = name of a GCE Data Toolbox workflow function to call for post-processing the data
%     (default = '' for none)
%
%outputs:
%  s = GCE Data Structure
%  msg = text of any error messages
%
%(c)2011-2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 24-Nov-2014

%initialize outputs:
s = [];

%validate template
if exist('template','var') ~= 1
   template = '';
end

%validate workflow
if exist('workflow','var') ~= 1
   workflow = '';
end

%define header strings for automatic template matching
str_cera_diver = 'Cera-Diver';
str_ctd_diver = 'CTD-Diver';
str_baro_diver = 'Mini-Diver';

%define corresonding metadata templates
template_ctd_diver = 'GCE_CTD_Diver';
template_cera_diver = 'GCE_Cera_Diver';
template_baro_diver = 'GCE_Baro_Diver';

%validate path
if exist('pn','var') ~= 1
   pn = curpath;
elseif ~isdir(pn)
   pn = curpath;
elseif strcmp(pn(end),filesep)
   pn = pn(1:end-1);  %strip terminal file separator
end

%prompt for file if omitted or invalid
if exist('fn','var') ~= 1
   cd(pn)
   [fn,pn] = uigetfile('*.csv','Select a Schlumberger logger file to import');
   cd(curpath)
elseif exist([pn,filesep,fn],'file') ~= 2
   [fn,pn] = uigetfile(fn,'Locate the text file to import');
end
drawnow

%pass filename, pathname, and static parameters to custom ASCII import filter
if fn ~= 0

   %init runtime vars
   col_names = '';  %init column names string
   hdr = [];

   %init file marker strings
   data_start = '[Data]';
   len_data_start = length(data_start);
   data_end = 'END OF DATA FILE';
   len_data_end = length(data_end);

   %generate temp file name
   [tmp,fn_base,fn_ext] = fileparts(fn);
   fn_temp = [fn_base,'_filtered',fn_ext];

   %open data file, read first line
   fid = fopen([pn,filesep,fn],'r');
   str = fgetl(fid);

   %parse header
   while ischar(str)
      if strncmpi(str,data_start,len_data_start)
         fgetl(fid);  %burn spacer row after data tag
         col_names = fgetl(fid);  %get column heading row
         break
      else
         if ~isempty(str) && ~strncmpi(str,'==',2)
            hdr = [hdr ; {scrub_ctd_diver_log(str)}];  %cache header for metadata parsing
         end
      end
      str = fgetl(fid);
   end

   %get first data line
   str = fgetl(fid);

   %split date/time heading into separate components for faster parsing (checking for hh:mm or
   %hh:mm:ss format in first data row)
   if length(strfind(str,':')) == 1
      col_names = regexprep(col_names,'Date/time,','Month,Day,Year,Hour,Minute,','ignorecase');
   else
      col_names = regexprep(col_names,'Date/time,','Year,Month,Day,Hour,Minute,Second,','ignorecase');
   end

   %write filtered file, starting with column titles
   fid2 = fopen([pn,filesep,fn_temp],'w');
   fprintf(fid2,'Name:%s\r',col_names);
   while ischar(str)
      if ~strncmpi(str,data_end,len_data_end)
         fprintf(fid2,'%s\r',str);
      else
         break
      end
      str = fgetl(fid);
   end

   %close files
   fclose(fid);
   fclose(fid2);

   %check for successfully parsed header
   if ~isempty(hdr) && ~isempty(col_names)

      %assign template based on instrumentation string if not specified
      if isempty(template)
         Iinstr = find(strncmpi(hdr,'Instrument type',15));  %get index of instrument line in header
         if ~isempty(Iinstr)
            ar = splitstr(hdr{Iinstr(1)},'=');  %split string based on equal signs
            if length(ar) >= 2
               instrument = ar{2};  %grab second string as instrument and match to defined strings
               if strcmpi(instrument,str_cera_diver)
                  template = template_cera_diver;
                  titlestr = 'Groundwater well pressure and temperature measurements';
               elseif strcmpi(instrument,str_ctd_diver)
                  template = template_ctd_diver;
                  titlestr = 'Groundwater well pressure, temperature and conductivity measurements';
               elseif strcmpi(instrument,str_baro_diver)
                  template = template_baro_diver;
                  titlestr = 'Groundwater well atmospheric pressure and temperature measurements';
               end
            end
         end
      else
         titlestr = '';
      end

      %define format string based on number of column headings, presence of Seconds column
      ar_colnames = splitstr(col_names,',');
      if isempty(strfind(col_names,',Second,'))
         num_data_cols = length(ar_colnames) - 5;
         fstr = ['%d/%d/%d %d:%d',repmat(' %f',1,num_data_cols)];
      else
         num_data_cols = length(ar_colnames) - 6;
         fstr = ['%d/%d/%d %d:%d:%d',repmat(' %f',1,num_data_cols)];
      end

      %parse temp file
      [s,msg] = imp_ascii(fn_temp,pn,'',template,fstr);
      

      if ~isempty(s)

         %delete temp file
         try
            delete([pn,filesep,fn_temp]);
            msg0 = '';
         catch
            msg0 = ['An error occurred deleting the temporary import file ''',fn_temp,''''];
         end

         %add header to metadata
         s = addmeta(s,{'Supplement','UserNotes',cell2pipes(hdr)},0,'imp_schlumberger_sonde');

         %fill metadata tokens for date fields
         s = fill_meta_tokens(s);

         %add date columns
         s_tmp = add_datecol(s);
         if ~isempty(s_tmp)
            s = s_tmp;
            msg1 = '';
         else
            msg1 = 'An error occurred adding a serial date column';
         end

         %add well metadata
         [s,msg2] = add_well_metadata(s,fn,'',titlestr);
         
         %concatenate messages, skipping any empty ones
         ar_msg = {msg0,msg1,msg2};
         msg = char(concatcellcols(ar_msg,';',1));
         
         %call post-processing workflow if defined
         if ~isempty(s) && ~isempty(workflow)
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

      end

   else
      msg = 'Unrecognized file format - failed to parse column headings';
   end

else
   msg = 'Import cancelled';
end

function str2 = scrub_ctd_diver_log(str)
%cleans up extra whitespace and formatting in CTD-Diver headers

str2 = regexprep(str,'^\s+','');  %strip leading spaces
str2 = regexprep(str2,'\s*',' ');  %normalize multiple spaces
str2 = strrep(str2,'=','= ');     %add space after equals
str2 = regexprep(str2,'\s*:',':');  %remove space before colons