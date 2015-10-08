function [msg,filelist,badfiles] = batch_exp_ascii(pn_source,pn_dest,filespec,fmt,header,clearflags,flaglist,flagopt,metastyle,leader,rownumbers,missingchar,delim,terminator,datecol,dateformat,silent)
%Exports a batch of files containing GCE Data Structures to delimimited text format
%
%syntax:  [msg,filelist,badfiles] = batch_exp_ascii(pn_source,pn_dest,filespec,fmt,hdropt,clearflags,flaglist,flagopt,metastyle,ldr,rnums,misschar,delim,groupcol,appendopt,terminator,datecol,dateformat,silent)
%
%input:
%   pn_source = pathname containing the files to export (required)
%   pn_dest = pathname for saving the exported text files (required)
%   filespec = file specification for selecting files to export (e.g. '*.mat', required)
%   fmt = text file format (required):
%      'tab' - tab-delimimitted ASCII text
%      'comma' - commas-delimimitted ASCII text
%      'csv' - comma-separated value format (with quoted header lines)
%      'delim' - delimimited ASCII text using user-specified delimimiter
%   header = header option:
%      'F' for full {default}
%      'B' for brief
%      'T' for column titles only
%      'N' for none
%      'SF' for full header plus independent doc file '-meta.txt'
%      'SB' for brief header plut independent doc file '-meta.txt'
%      'ST' for column titles only plus independent doc file '-meta.txt'
%      'SN' for no header plus independent doc file '-meta.txt'
%   clearflags = option for removing flagged values:
%      '' = retain all flagged values (default)
%      'nullall' = convert values assigned any flag to NaN/empty
%      'cullall' = delimete rows containing any flagged values
%      'null' = null values assigned flags specified in 'flaglist'
%      'cull' = delimete rows containing values assigned flags specified in 'flaglist'
%   flaglist = list of flags to remove based on 'clearflags' setting (default = '')
%   flagopt = flag display option:
%      'I' for inline
%      'C' for flag column
%      'M' for multiple text flag columns after the corresponding data column (if flags defined)
%      'MD' same as 'M', except text flags are displayed for all data/calculation columns
%      'MD+' same as 'MD', except text flags are also displayed for non-data, non-calculation columns if assigned
%      'MC' same as 'M', except text flags are displayed for all columns
%      'MA' for multiple text flag columns appended after the data columns
%      'MAD' same as 'MA', except text flags are displayed for all data/calculation columns
%      'MAD+' same as 'MD', except text flags are also displayed for non-data, non-calculation columns if assigned
%      'MAC' same as 'MA', except text flags are displayed for all columns
%      'E' for multiple encoded flag columns after the corresponding data column (if flags defined)
%      'ED' same as 'E', except encoded flags are displayed for all data/calculation columns
%      'ED+' same as 'ED', except encoded flags are also displayed for non-data, non-calculation columns if assigned
%      'EC' same as 'E', except encoded flags are displayed for all columns
%      'EA' for multiple encoded flag columns appended after the data columns
%      'EAD' same as 'EA', except encoded flags are displayed for all data/calculation columns
%      'EAD+' same as 'EAD', except encoded flags are displayed non-data, non-calculation columns if assigned
%      'EAC' same as 'EA', except encoded flags are displayed for all columns
%      'N' to suppress flags (default)
%      'R' to remove (null) flagged values
%      'D' for delete rows with any flagged values)
%   metastyle = named metadata style for full headers (default = 'GCE')
%   leader = character or string to preceed each header row (default = '')
%   rownumbers = option to include a column of rownumbers ('y' or 'no' - default)
%   missingchar = is the string to substitute for missing values (default = 'NaN')
%   delim = delimimitter to use for the 'delim' format (default = determined from fmt)
%   terminator = line terminator character (default = '\r\n' for carriage return and line feed;
%      specify '\n' for linefeed or '\r' for carriage return alone
%   datecol = name or index number of a string or floating-point date column to use for date conversions
%      (default = [] for automatic selection of 'Date' column or first string or floating-point datetime column)
%   dateformat = format option for date conversions (see datestr.m for options) ([] for no conversion)
%   silent = option to suppress console or progress bar status updates (0 = no/default, 1 = yes)
%
%output:
%   msg = the text of any errors that occurred
%   filelist = list of files successfully exported
%   badfiles = list of files that were not exported due to errors
%
%
%(c)2012-2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project-2005 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 10-Sep-2014

%init output
filelist = [];
badfiles = [];

%check for required input
if nargin >= 4 && isdir(pn_source) && isdir(pn_dest) && ~isempty(filespec) && ~isempty(fmt)
   
   %clean terminal file separators from paths
   pn_source = clean_path(pn_source);
   pn_dest = clean_path(pn_dest);   

   %set default delimeter if omitted
   if exist('delim','var') ~= 1
      delim = '  ';
   end

   %filter format options, update delimimiter token to match as necessary
   fmt = lower(fmt);
   ext = '.txt';
   if strcmp(fmt,'tab')
      delim = '\t';  %clear delimiter for tabs
   elseif strcmp(fmt,'comma')
      delim = ',';
   elseif strcmp(fmt,'csv')
      delim = ',';
      ext = '.csv';
   else  %escape field token charcters used as delimiters
      delim = strrep(delim,'''','''''');
      delim = strrep(delim,'%','%%');
      delim = strrep(delim,'\','\\');
   end
   
   %default to NaN as missing character
   if exist('missingchar','var') ~= 1
      missingchar = 'NaN';
   elseif isempty('missingchar')
      missingchar = '';  %force empty character array
   end
   
   %default to not displaying row numbers
   if exist('rownumbers','var') ~= 1
      rownumbers = 'N';
   else
      if ~strcmpi(rownumbers,'Y')
         rownumbers = 'N';
      else
         rownumbers = 'Y';  %force upper case
      end
   end
   
   %default to no leading characters for header
   if exist('leader','var') ~= 1
      leader = '';
   end
   
   %default to brief header
   if exist('header','var') ~= 1
      header = 'B';
   else
      header = upper(header);
   end
   
   %default to not clearing flags
   if exist('clearflags','var') ~= 1
      clearflags = '';
   end
   
   %default to no flag specification
   if exist('flaglist','var') ~= 1
      flaglist = '';
   end
   
   %default to not display flags
   if exist('flagopt','var') ~= 1
      flagopt = 'N';
   else
      flagopt = upper(flagopt);
   end
   
   %default to no leader
   if exist('leader','var') ~= 1
      leader = '';
   end
   
   %default to automatic metadata style selection
   if exist('metastyle','var') ~= 1
      metastyle = '';
   end
   
   %default to NaN missing character
   if exist('missingchar','var') ~= 1
      missingchar = 'NaN';
   end
   
   %set default terminator based on system type
   if exist('terminator','var') ~= 1
      if ispc
         terminator = '\r\n';
      else
         terminator = '\n';
      end
   elseif ~strcmp(terminator,'\r') && ~strcmp(terminator,'\n')
      terminator = '\r\n';
   end
   
   %set default datecol to auto if omitted
   if exist('datecol','var') ~= 1
      datecol = [];
   end
   
   %set default dateformat to empty for no conversion if omitted
   if exist('dateformat','var') ~= 1
      dateformat = [];
   end
   
   %
   %default to displaying status updated
   if exist('silent','var') ~= 1
      silent = 0;
   end
   
   %get list of matching files to process
   d = dir([pn_source,filesep,filespec]);
   
   %check for matched files
   if ~isempty(d)
      
      %init guimode flag
      guimode = 0;
      
      %if not in silent mode, check for editor window instance and set guimode flag to 1
      if silent == 0
         
         %check for open editor or export dialog instance
         if length(findobj) > 1
            h_editor = findobj('Tag','dlgDSEditor');
            h_export = findobj('Tag','dlgExport');
         else
            h_editor = [];
            h_export = [];
         end
         
         %set guimode option based on editor instance and invoke GUI progress bar
         if ~isempty(h_editor) || ~isempty(h_export)
            guimode = 1;
            ui_progressbar('init',length(d),'Batch Text Export')
         end
         
      end
      
      %init status report arrasy
      msgarray = repmat({''},length(d),1);
      filelist = msgarray;
      badfiles = msgarray;
      
      for n = 1:length(d)
         
         %get filename from directory list
         fn = d(n).name;
         
         %update progress bar or console display
         if guimode == 1
            ui_progressbar('update',n,['Processing ',fn])
         elseif silent == 0
            clc
            disp(['processing ',int2str(length(d)),' files in ',pn_source])
            disp(' ')
            drawnow
         end
         
         %load variables
         try
            vars = load([pn_source,filesep,fn],'-mat');
         catch
            vars = [];
         end
         
         %check for successful load
         if ~isempty(vars)
            
            %get variable names from load structure
            varnames = fieldnames(vars);
            
            %init export flag and exp_ascii msg
            exportflag = 0;
            msg0 = '';
            
            %loop through variable checking for data structures            
            for var = 1:length(varnames)
               
               %extract variable
               varname = varnames{var};
               s = vars.(varname);
               
               %check for valid structure
               if isstruct(s) && gce_valid(s,'data')
                  
                  %get base filename from original file
                  [pn_dest,fn_base] = fileparts([pn_dest,filesep,fn]);
                  
                  %generate output filename, appending variablename unless standard 'data' variable
                  if strcmp(varname,'data')
                     fn_dest = [fn_base,ext];
                  else
                     fn_dest = [fn_base,'_',varname,ext];
                  end                  
                  
                  %pre-process nulled or culled flagged values/rows, update flag option
                  if strcmp(clearflags,'nullall')
                     %null flags, logging deletions to the metadata and retaining flags
                     s = nullflags(s,'',[],1,0);
                     flagopt = 'N';
                  elseif strcmp(clearflags,'cullall')
                     %cull flags, logging deletions
                     s = cullflags(s,'',[],1);
                     flagopt = 'N';
                  elseif strcmp(clearflags,'nullcust') && ~isempty(flaglist)
                     %null specified flags, logging deletions and retaining flags
                     s = nullflags(s,flaglist,[],1,0);
                  elseif strcmp(clearflags,'cullcust') && ~isempty(flaglist)
                     %cull specified flags, logging deletions
                     s = cullflags(s,flaglist,[],1);
                  end
                  
                  %apply date format conversion if specified, trapping errors and reverting to original structure on failure
                  if ~isempty(dateformat)
                     
                     %look up date column
                     if isempty(datecol)
                        dtype = get_type(s,'datatype');
                        vtype = get_type(s,'variabletype');
                        Idt = find(strcmp('datetime',vtype) & (strcmp('f',dtype) | strcmp('s',dtype)));
                        if ~isempty(Idt)
                           if length(Idt) == 1
                              datecol = Idt;
                           else
                              Idt2 = find(strncmpi('date',s.name(Idt),4));
                              if ~isempty(Idt2)
                                 datecol = Idt(Idt2(1));
                              else
                                 datecol = Idt(1);
                              end
                           end
                        end
                     end
                     
                     %check for matched date column
                     if ~isempty(datecol)
                        s_tmp = convert_date_format(s,datecol,dateformat);
                        if ~isempty(s_tmp)
                           s = s_tmp;
                        end
                     end
                     
                  end
                  
                  %export
                  msg0 = exp_ascii(s,fmt,fn_dest,pn_dest,'',header,flagopt,metastyle, ...
                     leader,rownumbers,missingchar,delim,[],'N',terminator);
                  
                  %set successful export flag
                  exportflag = 1;
               
               end
               
            end
            
            if exportflag == 1 && isempty(msg0)
               
               %generate success message and add file to filelist
               if length(varnames) == 1
                  msgarray{n} = ['successfully exported ',pn_source,filesep,fn,' as ',pn_dest,filesep,fn_dest];                              
               else
                  msgarray{n} = ['successfully exported ',int2str(length(varnames)),' variables in ',pn_source,filesep,fn, ...
                     ' as ',pn_dest,filesep,fn_base,'_[variable]',ext];                              
               end
               filelist{n} = [pn_source,filesep,fn];
            
            else  %no successful exports               

               %add file to badfiles
               badfiles{n} = [pn_source,filesep,fn];
               
               %generate context-appropriate error message
               if isempty(msg0)
                  msgarray{n} = ['no valid GCE Data Structures were found in ',pn_source,filesep,fn,' - export cancelled'];
               else
                  msgarray{n} = ['an error occurred exporting ',pn_source,filesep,fn,' - ',msg0];
               end
               
            end
            
         else
         
            %generate error message and add file to badfiles
            msgarray{n} = ['errors occurred loading ',pn_source,filesep,fn,' - export cancelled'];
            badfiles{n} = [pn_source,filesep,fn];
         
         end
         
         %display status on console if not in guimode or silent
         if guimode == 0 && silent == 0
            disp(msgarray{n})
         end
         
      end
      
      %close progressbar
      if guimode == 1
         ui_progressbar('close')
      end
      
      %generate character array message
      msg = char(['Exported files in ',pn_source],' ',char(msgarray));
      
      %remove empty rows in filelist, badfiles
      filelist = filelist(~cellfun('isempty',filelist));
      badfiles = badfiles(~cellfun('isempty',badfiles));
      
   else  %no files
      
      %generate error message
      msg = ['no files matching the pattern ''',pn_source,filesep,filespec,''' were found'];
      
   end   
   
else  %bad input
   
   %generate appropriate error message
   if nargin < 4
      msg = 'insufficient arguments for function';
   else
      if ~isdir(pn_source)
         msg = 'invalid source path';
      elseif ~isdir(pn_source)
         msg = 'invalid destination path';
      elseif isempty(filespec)
         msg = 'invalid file specification';
      else
         msg = 'invalid file format option';
      end
   end
   
end