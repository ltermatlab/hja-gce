function [s,msg] = imp_campbell_toa5(fn,pn,template,serial_date,timezone,workflow)
%Imports data from a Campbell Scientific Instruments TOA5 ASCII file to create a GCE Data Structure
%
%syntax: [s,msg] = imp_campbell_toa5(fn,pn,template,serial_date,timezone,workflow)
%
%inputs:
%  fn = name of file to import (default = prompted)
%  pn = pathname of file (default = pwd)
%  template = metadata template to apply (default = '' for none)
%  serial_date = option to calculate a MATLAB serial date column from TIMESTAMP
%     0 = no
%     1 = yes/default
%  timezone = time zone setting of logger (default = '' for unspecified)
%  workflow = name of a GCE Data Toolbox workflow function to call for post-processing the data
%     (default = '' for none)
%
%outputs:
%  s = data structure
%  msg = text of any error or status message
%
%
%notes:
%  1) if no template is specified, a default title and abstract will be generated
%     based on TOA5 header information and variables
%  2) if 'workflow' is specified, it must correspond to a MATLAB function in the path
%     that accepts a GCE Data Structure as input and returns a GCE Data Structure and text
%     error message as output arguments (e.g. [s2,msg] = myfund(s))
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
%last modified: 14-Jun-2014

%init output
s = [];
msg = '';

%validate path
if exist('pn','var') ~= 1
   pn = '';
end
if ~isdir(pn)
   pn = pwd;
else
   pn = clean_path(pn);  %strip terminal file separator if present
end

%validate input file
filespec = '*.dat;*.txt';
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

if ~isempty(fn)
   
   %check for template input, assign default if omitted
   if exist('template','var') ~= 1
      template = '';
   end
   
   %check for serial_date option
   if exist('serial_date','var') ~= 1
      serial_date = 1;
   elseif serial_date ~= 0
      serial_date = 1;
   end

   %check for time zone
   if exist('timezone','var') ~= 1
      timezone = '';
   end
   
   %check for workflow
   if exist('workflow','var') ~= 1
      workflow = '';
   end
   
   %open file and read header lines
   try
      fid = fopen([pn,filesep,fn],'r');
   catch
      fid = [];
   end
   
   if ~isempty(fid)
      
      datarows = cell(10,1);
      
      %read 4 header lines and up to 10 data lines for parsing
      try
         ln1 = fgetl(fid);
         ln2 = fgetl(fid);
         ln3 = fgetl(fid);
         ln4 = fgetl(fid);
         for n = 1:10
            ln = fgetl(fid);
            if ischar(ln)
               datarows{n} = ln;
            else
               break;
            end
         end
      catch
         ln1 = '';
         ln2 = '';
         ln3 = '';
         ln4 = '';
      end
      
      fclose(fid); %close file
      
      %check for valid content
      if ~isempty(ln1) && ~isempty(ln2) && ~isempty(ln3) && ~isempty(ln4) && sum(~cellfun('isempty',datarows)) >= 1
         
         %parse header info and first data row for validation
         info = splitstr(strrep(ln1,'"',''),',');  %split out info fields from first line
         flds = splitstr(strrep(ln2,'"',''),',',0); %split field labels
         units = splitstr(strrep(ln3,'"',''),',',0); %split unit strings         
         meas = splitstr(strrep(ln4,'"',''),',',0); %split measurement type labels
         row1 = splitstr(datarows{1},',',0);  %split first data row for field number comparison
         
         %replace units for timestamp field
         units = strrep(units,'TS','YYYY-MM-DD hh:mm:ss');
         
         %check for valid TOA5 format
         if strcmpi('TOA5',info(1)) && length(flds) == length(units) && length(flds) == length(meas) && length(flds) == length(row1)
            
            %evaluate up to 10 data rows checking for quoted text fields for format string generation
            textflds = zeros(10,length(row1));  %init text field flag array
            for n = 1:length(datarows)
               ln = datarows{n};
               if ~isempty(ln)
                  ln = regexprep(ln,'("NAN"|"INF"|"-INF")+','0');  %replace quoted NaN, Inf, -Inf with zero for type testing
                  ar = splitstr(ln,',');
                  if length(ar) == length(flds)
                     Itextflds = strncmp(ar,'"',1);
                     textflds(n,Itextflds) = 1;
                  end
               elseif n > 1
                  textflds(n,:) = textflds(n-1,:);  %copy prior row if past end of data rows
               end
            end
            
            ar_fstr = repmat({'%f'},1,length(flds));  %init format string
            Itextfields = (sum(textflds) >= 1);  %get index of text fields from evaluation array
            ar_fstr(Itextfields) = {'%q'};  %substitute quoted text token for text fields
            
            %check for serial date option, parse components from TIMESTAMP if present
            if serial_date == 1
               Its = find(strcmpi(flds,'TIMESTAMP'));
               if length(Its) == 1
                  %substitute date component labels, units, measurement types, field tokens for TIMESTAMP values
                  flds = [flds(1:Its-1)',{'Year%%temp','Month%%temp','Day%%temp','Hour%%temp','Minute%%temp','Second%%temp'},flds(Its+1:end)'];
                  units = [units(1:Its-1)',{'YYYY','MM','DD','hh','mm','ss'},units(Its+1:end)'];
                  meas = [meas(1:Its-1)',{'""','""','""','""','""','""'},meas(Its+1:end)'];
                  ar_fstr{Its} = '"%d-%d-%d %d:%d:%f"';
               end
            end
            
            %generate format string
            fstr = char(concatcellcols(ar_fstr,' ')); 
            
            %generate the default title if no template is specified            
            if isempty(template)
               titlestr = ['Data imported from Campbell Scientific Instruments TOA5 file ',fn,' at ',datestr(now)];
            else
               titlestr = '';
            end
            
            %import the file, substituting NaN for quoted missing and infinite values
            if mlversion >= 7
               [s,msg] = imp_ascii(fn,pn,titlestr,'',fstr,flds,4,'"NAN","INF","-INF"',',');
            else %older matlab version - use legacy imp_filter
               [s,msg] = imp_filter(fn,pn,fstr,flds,4,'"NAN","INF","-INF"','',titlestr);
            end
            
            %generate MATLAB serial date column, delete date part columns if specified
            if ~isempty(s) && serial_date == 1
               s = add_datecol(s,[],{'Year%%temp','Month%%temp','Day%%temp','Hour%%temp','Minute%%temp','Second%%temp'});
               datecol = name2col(s,'Date');
               if ~isempty(datecol) && length(timezone) == 3
                  dunits = s.units{datecol};
                  s = update_attributes(s,'Date',{'units'},{[dunits,' - ',timezone]});
               end
               s = deletecols(s,{'Year%%temp','Month%%temp','Day%%temp','Hour%%temp','Minute%%temp','Second%%temp'});
               s = add_studydates(s,'Date');  %add study date metadata
            end
            
            %apply template, or add units and generated descriptions for columns if no template found
            if ~isempty(s)
               
               if ~isempty(template)
                  
                  %apply specified template
                  [s,msg] = apply_template(s,template);
                  
               else
                  
                  %add column info from TOA5 header
                  cols = s.name;
                  if length(cols) == length(flds)
                     col_units = s.units;
                     col_desc = s.description;
                     for n = 1:length(cols)
                        col_units{n} = units{n};
                        switch meas{n}
                           case 'Avg'
                              desc = 'Averaged measurement of ';
                           case 'Smp'
                              desc = 'Instantaneous measurement of ';
                           case 'WVec'
                              desc = 'Vector product of ';
                           case 'Tot'
                              desc = 'Totaled measurement of';
                           otherwise
                              desc = 'Measurement of ';
                        end
                        col_desc{n} = [desc,cols{n}];
                     end
                     s.units = col_units;
                     s.description = col_desc;
                     s.history = [s.history ; {datestr(now)}, ...
                        {'updated column units and descriptions based on information parsed from the CSI TAO5 header (''imp_campbell_toa5'')'}];
                     s.editdate = datestr(now);
                  end
                  
                  %add additional info parsed from header
                  if length(info) == 8
                     
                     %get general info from header
                     station = info{2};
                     logger = info{3};
                     sn = info{4};
                     firmware = info{5};
                     program = strrep(info{6},'CPU:','');
                     tablename = info{8};
                     
                     %check for study date metadata, format for inclusion in abstract
                     begindate = lookupmeta(s,'Study','BeginDate');
                     enddate = lookupmeta(s,'Study','EndDate');
                     if ~isempty(begindate) && ~isempty(enddate)
                        daterange = ['from ',begindate,' to ',enddate,' '];
                     else
                        daterange = '';
                     end
                     
                     %generate abstract text
                     abstract = ['Imported data from a Campbell Scientifics Instruments model ',logger, ...
                        ' data logger operated at station ',station,' on ',datestr(now,1),'. A total of ', ...
                        int2str(num_records(s)),' records were parsed from the ''',tablename,''' table ', ...
                        'generated by the ''',program,''' program. Observations were recorded ',daterange,'for ', ...
                        int2str(length(s.name)),' variables, including: ',cell2commas(s.name,1),'.'];
                     
                     %geneate instrument metadata
                     instrument = ['Electronic data logger (make: Campbell Scientific Instruments, model: ',logger, ...
                        ', serial number: ',sn,', firmware: ',firmware,')'];
                     
                     %generate metadata array
                     newmeta = {'Dataset','Abstract',abstract; ...
                        'Study','Instrumentation',instrument};
                     
                     %incorporate metadata
                     s = addmeta(s,newmeta,0,'imp_campbell_toa5');                     
                     
                  end
                  
               end
               
            end
            
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
            
         else
            msg = 'file could not be parsed - unrecognized header structure';
         end
         
      else
         msg = 'file could not be parsed - unrecognized file format or empty data table';
      end
      
   else
      msg = ['an error occurred opening the file ',pn,filesep,fn];
   end
   
end