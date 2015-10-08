function [msg,filelist,badfiles] = batch_import(filtname,filemask,pn1,pn2,arg1,arg2,arg3,arg4,arg5,arg6,silent)
%Batch processes raw data files in a directory using a specified GCE Data Toolbox import filter function
%
%syntax: [msg,filelist,badfiles] = batch_import(filtname,filemask,pn1,pn2,arg1,arg2,arg3,arg4,arg5,arg6,silent)
%
%input:
%  filtname = name of the import filter (M-file that accepts filename and pathname
%     arguments and returns a single data structure and message string - required)
%  filemask = filemask to use to identify candidate import files (e.g. '*.txt', '*.txt;*.asc' - required)
%  pn1 = pathname containing the raw files (default = current directory)
%  pn2 = pathname for saving data structures (default = pn1)
%  arg1 = optional runtime argument to pass to import filter after filename and pathname parameters
%  arg2 = second optional runtime argument to pass to import filter after filename and pathname parameters
%  arg3 = third optional runtime argument to pass to import filter after filename and pathname parameters
%  arg4 = fourth optional runtime argument to pass to import filter after filename and pathname parameters
%  arg5 = fifth optional runtime argument to pass to import filter after filename and pathname parameters
%  arg6 = sixth optional runtime argument to pass to import filter after filename and pathname parameters
%  silent = option for suppressing command line status messages (1 = suppress,
%     0 = display/default)
%
%output:
%  msg = status message
%  filelist = cell array of successfully processed files
%  badfiles = cell array of original files that could not be processed
%
%notes:
%  1. processed files are named based on the input file with a .mat extension (e.g. mydata.txt -> mydata.mat)
%  2. if the input file is a MATLAB file with .mat extension, then '_proc.mat' will be used to prevent overwriting
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
%last modified: 01-Mar-2013

%init output
filelist = [];
badfiles = [];

%check for required input
if nargin >= 2

   %get current path for path validation
   curpath = pwd;

   %validate input path
   if exist('pn1','var') ~= 1
      pn1 = curpath;
   elseif ~isdir(pn1)
      pn1 = curpath;
   else
      pn1 = clean_path(pn1);  %strip terminal file separator
   end

   %validate output path
   if exist('pn2','var') ~= 1
      pn2 = pn1;
   elseif ~isdir(pn2)
      pn2 = pn1; %default 
   else
      pn2 = clean_path(pn2);  %strip terminal file separator
   end
   
   %validate optional function arguments 1 to 3
   if exist('arg1','var') ~= 1
      arg1 = [];
   end
   
   if exist('arg2','var') ~= 1
      arg2 = [];
   end
   
   if exist('arg3','var') ~= 1
      arg3 = [];
   end

   if exist('arg4','var') ~= 1
      arg4 = [];
   end

   if exist('arg5','var') ~= 1
      arg5 = [];
   end

   if exist('arg6','var') ~= 1
      arg6 = [];
   end

   if exist('silent','var') ~= 1
      silent = 0;
   end

   %get structure of filenames in target directory
   d = [];
   filemask = splitstr(filemask,';');  %split multiple delimiters
   for n = 1:length(filemask)
      d_tmp = dir([pn1,filesep,filemask{n}]);  %get directory listing for each filemash
      if ~isempty(d_tmp)
         d = [d ; d_tmp];  %add listing to master directory structure
      end
   end

   %check for matched files
   if ~isempty(d)
      
      %init error message array, filelist array, badfiles array
      msgarray = repmat({''},length(d),1);
      filelist = msgarray;
      badfiles = msgarray;

      %init GUI update mode
      guimode = 0;
      
      %init progress bar or display status on console unless silent mode specified
      if silent == 0
         h_editor = findobj('Tag','dlgDSEditor');  %check for an open editor GUI form
         h_batch_import = findobj('Tag','dlgBatchImport');  %check for ui_batch_import form
         if ~isempty(h_editor) || ~isempty(h_batch_import)
            guimode = 1;  %set guimode flag
            ui_progressbar('init',length(d),'Batch Import');
         else  %console updates
            clc
            disp(['*** processing ',int2str(length(d)),' files ***'])
            disp(' ');
            drawnow
         end
      end

      %loop through file list
      for n = 1:length(d)

         %get filename from directory listing
         fn = d(n).name;
         
         %update progressbar
         if guimode == 1
            ui_progressbar('update',n,['Processing ',fn]);
         end

         %try evaluating function with specified arguments
         try
            if ~isempty(arg6)
               [data,msg2] = feval(filtname,fn,pn1,arg1,arg2,arg3,arg4,arg5,arg6);
            elseif ~isempty(arg5)
               [data,msg2] = feval(filtname,fn,pn1,arg1,arg2,arg3,arg4,arg5);
            elseif ~isempty(arg4)
               [data,msg2] = feval(filtname,fn,pn1,arg1,arg2,arg3,arg4);
            elseif ~isempty(arg3)
               [data,msg2] = feval(filtname,fn,pn1,arg1,arg2,arg3);
            elseif ~isempty(arg2)
               [data,msg2] = feval(filtname,fn,pn1,arg1,arg2);
            elseif ~isempty(arg1)
               [data,msg2] = feval(filtname,fn,pn1,arg1);
            else
               [data,msg2] = feval(filtname,fn,pn1);
            end
         catch
            data = [];
            msg2 = 'invalid import filter or unhandled runtime error';
         end

         %check for return data
         if ~isempty(data)
            
            %parse input filename for generating output filename
            [tmp,basename,ext] = fileparts(fn);
               
            %check for data structure return
            if gce_valid(data,'data')

               %check for input .mat file, revise basename to prevent overwriting input file
               if ~strcmp(ext,'.mat')
                  fn2 = [basename,'.mat'];
               else
                  fn2 = [basename,'_proc.mat'];  %append '_proc' to base filename to avoid overwrite
               end
               
               %save output to destination
               try
                  save([pn2,filesep,fn2],'data')
                  msg_status = ['processed ''',fn,''', saved as: ',fullfile(pn2,fn2)];
                  msgarray{n} = msg_status;  %add status message
                  filelist{n} = [pn2,filesep,fn2];  %add processed file
               catch
                  msg_status = ['an error occurred saving file ''',fn2,''''];
                  msgarray{n} = msg_status;  %add status message
                  badfiles{n} = [pn1,filesep,fn];  %add source to bad files array
               end
               
            else  %non-structure output - assume .mat file written by filter (e.g. csi2struct.m)
               
               if ischar(data)
                  msg_status = ['processed ''',fn,''''];
                  msgarray{n} = msg_status;  %add status message
                  filelist{n} = [pn2,filesep,fn];  %add processed file
               end
               
            end

            %display status on the console
            if silent == 0 && guimode == 0
               disp(msg_status)
               drawnow
            end

         else
            
            %add to bad files array
            badfiles{n} = [pn1,filesep,fn];

            %add error message to msgarray
            msgarray{n} = ['** errors processing ''',fn,''' ** (',msg2,')'];

            %display error on console
            if silent == 0 && guimode == 0
               disp(['***ERROR processing ''',fn,''' *** (skipped)'])
               drawnow
            end

         end

      end

      %convert msgarray to character array, prepending title and spacer row
      msg = char(['Finished processing files in ',pn1,':'],' ',char(msgarray));
      
      %remove empty cells from filelist and badfiles
      filelist = filelist(~cellfun('isempty',filelist));
      badfiles = badfiles(~cellfun('isempty',badfiles));

      %display final status message
      if silent == 0
         if guimode == 1
            ui_progressbar('close')
            ui_viewtext(msg,0,0,'Batch Process Report',[850 600]) %open listbox-based text viewer
         else
            disp(' '); disp(' ');
         end
      end

   else
      msg = ['no matching files were found in the directory ',pn1];
   end

else
   msg = 'insufficient arguments for function';
end
