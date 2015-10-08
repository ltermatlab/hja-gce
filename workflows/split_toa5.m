function [msg,filelist] = split_toa5(fn,pn,interval,pn2,fn_base)
%Splits a Campbell Scientific Instruments TOA5 file into daily or hourly files
%
%syntax: [msg,filelist] = split_toa5(fn,pn,interval,basefn,pn2,fn_base)
%
%input:
%  fn = name or specifier of file(s) to split (e.g. '*.dat'; default = prompted)
%  pn = pathname for fn  (default = pwd)
%  interval = file interval:
%    'day' = split into daily files with '_[yyyy-mm-dd]' appended to the base filename
%    'hour' = split into hourly files with '_[yyyymmdd_hh]00' appended to the base filename
%  pn2 = pathname to save split files (default = pn)
%  fn_base = filename base to use for the output file with date appended (default = base name of fn)
%
%output:
%  msg = status message
%
%(c)2012-2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 25-Mar-2013

%init output
msg = '';
filelist = [];

%validate path
if exist('pn','var') ~= 1
   pn = '';
elseif ~isdir(pn)
   pn = '';
else
   pn = clean_path(pn);
end

if isempty(pn)
   pn = pwd;
end

%check for omitted file
if exist('fn','var') ~= 1
   fn = '';
end

%validate filename or filemask
if isempty(fn)
   filespec = '*.txt;*.dat';
else
   d = dir([pn,filesep,fn]);  %get directory list for filename/filespec
   if isempty(d)
      filespec = fn;
      fn = '';
   else
      files = {d.name}';  %generate cell array of filenames
   end
end

%prompt for file if missing, invalid
if isempty(fn)
   curpath = pwd;
   cd(pn)
   [fn,pn] = uigetfile(filespec,'Select a CSI TOA5 file to split');
   cd(curpath)
   drawnow
   if ~ischar(fn)
      files = '';
   else
      files = {fn};  %convert to cell array
   end
end

%check for cancel
if ~isempty(files)
   
   %supply default interval if omitted
   if exist('interval','var') ~= 1
      interval = '';
   end
   if isempty(interval) || ~strcmp(interval,'hour')
      interval = 'daily';
   end
   
   %validate output path
   if exist('pn2','var') ~= 1 || ~isdir(pn2)
      pn2 = pn;
   end
   
   %validate fn_base
   if exist('fn_base','var') ~= 1
      fn_base = '';
   end
   
   %get number of files
   numfiles = length(files);
   
   %init message array
   msgarray = repmat({''},numfiles,1);
   
   for f = 1:numfiles
      
      %get filename
      fn = files{f};
      
      %init header array
      hdr = cell(4,1);
      
      %open input file
      try
         fid = fopen([pn,filesep,fn],'r');
      catch
         fid = [];
      end
      
      %check for file open errors
      if ~isempty(fid)
         
         %init filelist
         filelist = [];
         
         %read 4-line header
         for n = 1:4
            ln = fgets(fid);
            hdr{n} = ln;
         end
         
         %init last date, write file handle
         lastdate = '';
         fid2 = '';
         
         %set character limit for timestamp checking
         if strcmp(interval,'hour')
            numchars = 14;
         else
            numchars = 11;
         end

         %parse filename components
         [~,fn2_base,fn2_ext] = fileparts(fn);
         if ~isempty(fn_base)
            fn2_base = fn_base;  %override base filename if fn_base defined
         end

         %split file
         while ischar(ln)
            
            ln = fgets(fid);  %read line
            
            if length(ln) >= numchars
               
               %get date or date + hh
               newdate = ln(2:numchars);
               
               %check for new date, start new output file
               if ~strcmp(newdate,lastdate)
                  
                  %update cached date
                  lastdate = newdate;
                  
                  %close prior daily file
                  if ~isempty(fid2)
                     fclose(fid2);
                  end

                  %generate filename suffix based on interval
                  if numchars == 11
                     suffix = newdate;
                  else  %hour - add hh00
                     suffix = [newdate(1:10),'_',newdate([12 13]),'00'];
                  end
                  
                  %generate fully qualified output filename and display status
                  pn2fn2 = [pn2,filesep,fn2_base,'_',suffix,fn2_ext];                 
                  disp(['generating file ',pn2fn2]); drawnow
                  filelist = [filelist ; {pn2fn2}];  %add filename to list
                  
                  %check for new file - write header
                  if exist(pn2fn2,'file') ~= 2
                     fid2 = fopen(pn2fn2,'w');  %open output file with date suffix
                     for n = 1:4
                        fprintf(fid2,'%s',hdr{n});
                     end
                  else
                     fid2 = fopen(pn2fn2,'a');  %append output to existing file
                  end
                  
               end
               
               %write line
               fprintf(fid2,'%s',ln);
               
            end
            
         end
         
         %close file handles
         if ~isempty(fid2)
            fclose(fid2);
         end
         fclose(fid);
         
         %generate status message
         if strcmp(interval,'hour')
            msgarray{f} = ['split ',pn,filesep,fn,' into ',num2str(length(filelist)),' hourly files in ',pn2];
         else
            msgarray{f} = ['split ',pn,filesep,fn,' into ',num2str(length(filelist)),' daily files in ',pn2];
         end
         
      end
      
   end
   
   %format output message
   msg = char(msgarray);
   
else
   msg = 'No files were selected';
end