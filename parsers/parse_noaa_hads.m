function [s,msg] = parse_noaa_hads(fn,pn,template,trim_partial,max_trim)
%Parses data arrays from a NOAA HADS NESDIS file to generate a GCE Data Structure
%
%syntax: [s,msg] = parse_noaa_hads(fn,pn,template,trim_partial,max_trim)
%
%input:
%  fn = name of file to parse
%  pn = pathname of file to parse (default = pwd)
%  template = metadata template to apply (default = '')
%  trim_partial = option to trim incomplete beginning and ending records to prevent data merge issues
%     0 = no
%     1 = yes (default)
%  max_trim = maximum number of leading and trailing partial records to trim (default = [] = number of data
%     and calculation columns - 1; ignored if trim_partial = 0)
%
%output:
%  s = data structure
%  msg = text of any error message
%
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
%last modified: 17-Jan-2013

s = [];
msg = '';

if nargin >= 1
   
   %set default pathname if omitted
   if exist('pn','var') ~= 1
      pn = pwd;
   elseif strcmp(pn(end),filesep)
      pn = pn(1:end-1);  %strip terminal file separator
   end
   
   %set default template if omitted
   if exist('template','var') ~= 1
      template = '';
   end
   
   %set default trim_partial option if omitted
   if exist('trim_partial','var') ~= 1
      trim_partial = 1;
   elseif trim_partial ~= 0
      trim_partial = 1;
   end
   
   %set default max_trim option if omitted
   if exist('max_trim','var') ~= 1
      max_trim = [];
   end
   
   if exist([pn,filesep,fn],'file') == 2
      
      %parse file using imp_ascii with no header option
      [s,msg] = imp_ascii(fn,pn,'','NOAA_HADS','%s %s %s %d-%d-%d %d:%d %f %s', ...
         {'NESDIS_ID','NWSLID','Parameter','Year','Month','Day','Hour','Minute','Value','Flag_Value'},0,'','|');

      %check for failure - try import again skipping first potentially incomplete row
      if isempty(s)
         [s,msg] = imp_ascii(fn,pn,'','NOAA_HADS','%s %s %s %d-%d-%d %d:%d %f %s', ...
            {'NESDIS_ID','NWSLID','Parameter','Year','Month','Day','Hour','Minute','Value','Flag_Value'},1,'','|');
      end
      
      %check for valid HADS array parsing
      if gce_valid(s,'data')
         
         %add serial date column for self-joins
         s = add_datecol(s);
         
         %convert value flags to Q/C flag arrays prior to splitting if any assigned
         flag = extract(s,'Flag_Value');
         Iflags = find(~cellfun('isempty',flag));
         if ~isempty(Iflags)
            s = cols2flags(s,'Flag_Value','Value',0);
         end

         %check for multiple parameters and split series accordingly
         parms = unique(extract(s,'Parameter'));        
         if length(parms) > 1
            %split data set based on values of 'Parameter', forming table by serial self-joins on 'Date','StationID','Sensor'
            s2 = split_dataseries(s,'Parameter',{'Date','NESDIS_ID','NWSLID'},{'Value'});
         elseif length(parms) == 1
            %delete Parameter column and rename Value to include parameter ID
            s2 = deletecols(s,'Parameter');
            s2 = rename_column(s2,'Value',[char(parms),'_Value']);
         else
            s2 = [];  %no valid parameters
         end
         
         %check for failed split
         if ~isempty(s2)
            s = s2;  %copy temp structure to output
         else  %try removing dupes before split
            cols = find(strcmp(s.variabletype,'data') ~= 1 & strcmp(s.variabletype,'calculation') ~= 1);  %get index of non-data cols
            s = cleardupes(s,cols);  %clear dupes based on identical non-data cols
            s = split_dataseries(s,'Parameter',{'Date','NESDIS_ID','NWSLID'},{'Value'});  %try splitting series again
         end
         
         if ~isempty(s)
            
            %finalize structure column order
            s = copycols(s,[2,3,1,4:length(s.name)]);  %re-order columns to put StationID, Sensor first
            
            %regenerate date part columns
            s = add_datepartcols(s,'Date');
            
            %apply template if specified
            if ~isempty(template)
               
               %apply specified metadata template, matching attributes
               s2 = apply_template(s,template,'all');
               
               if ~isempty(s2)
                  
                  %update output variable
                  s = s2;
                  
                  %re-generate serial date column to apply any time zone info from metadata template
                  if ~isempty(name2col(s,'Date'))
                     s = deletecols(s,'Date');
                  end
                  s = add_datecol(s);
                  
               else
                  msg = 'errors occurred applying the specified metadata template';
               end
               
            end
            
            %add study dates
            s = add_studydates(s,'Date');
            mindate = lookupmeta(s,'Study','BeginDate');
            maxdate = lookupmeta(s,'Study','EndDate');
            
            %generate title string, update title
            titlestr = 'Data Retrieved from the NOAA Hydro-meteorological Automated Data System (HADS)';
            if ~isempty(mindate) && ~isempty(maxdate)
               titlestr = [titlestr,' for ',mindate,' to ',maxdate];
            end
            s = newtitle(s,titlestr,0);
            
            %trim first and/or last records if incomplete
            if trim_partial == 1
               
               %look up number of records
               numrecs = length(s.values{1});
               
               %set 25% minimum values threshhold to prevent sparse columns from biasing trim calcs
               minvals = ceil(numrecs * 0.25);
               
               if numrecs > 0
                  
                  %get index of data and calc columns
                  Idata = listdatacols(s);
                  
                  if ~isempty(Idata)
                     
                     %set default max_trim if omitted
                     if isempty(max_trim)
                        max_trim = length(Idata) - 1;
                     end
                     
                     %init delete flags
                     Ivalid_top = ones(length(Idata),1);
                     Ivalid_bot = ones(length(Idata),1) .* numrecs;
                     
                     %loop through cols checking for valid data ranges
                     for n = 1:length(Idata)
                        
                        data = extract(s,Idata(n));  %extract data array
                        if iscell(data)
                           Ival = find(~cellfun('isempty',data));  %get index of non-empty string records
                        else
                           Ival = find(~isnan(data));  %get index of non-NaN numeric records
                        end
                        
                        %update results array with top/bottom pointers
                        if ~isempty(Ival) && length(Ival) > minvals
                           Ivalid_top(n) = min(Ival);
                           Ivalid_bot(n) = max(Ival);
                        else
                           %no data or sparse column - exclude metrics from trim calc
                           Ivalid_top(n) = 1;
                           Ivalid_bot(n) = numrecs;
                        end
                        
                     end
                     
                     %calculate first complete data record based on maximum of first valid record for all data cols
                     cleartop = max(Ivalid_top);
                     if cleartop > max_trim
                        cleartop = max_trim;
                     end
                     
                     %calculate last complete data record based on minimum of last valid record for all data cols
                     clearbot = min(Ivalid_bot);
                     if clearbot < (numrecs - max_trim + 1)
                        clearbot = numrecs - max_trim + 1;
                     end
                     
                     %generate index of records to delete based on cleartop, clearbot
                     delrows = [];
                     if cleartop > 1
                        delrows = (1:cleartop);
                     end
                     if clearbot < numrecs
                        delrows = [delrows,clearbot:numrecs];
                     end
                     
                     %perfrom row deletions
                     if ~isempty(delrows)
                        s = deleterows(s,delrows);
                     end
                     
                  end
                  
               end
               
            end
            
         else
            msg = ['errors occurred splitting the data arrays - check temporary file ''',pn,filesep,fn,''''];
         end
         
      else
         msg = ['arrays could not be parsed from raw data - check temporary file ''',pn,filesep,fn,''''];
      end
      
   else
      msg = 'invalid filename';
   end
   
else
   msg = 'insufficient arguments for function';
end