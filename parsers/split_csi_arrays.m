function [msg,filelist,badarrays] = split_csi_arrays(fn,pn,pn2,template)
%Splits processed arrays from a Campbell Scientific Instruments array-based data logger file
%to create separate .mat files with filenames based on the original filename with array name suffix
%
%syntax: [msg,filelist,badfiles] = split_csi_arrays(fn,pn,pn2,template)
%
%input:
%  fn = filename to load or parse (default = prompted)
%  pn = pathname for fn (default = pwd)
%  pn2 = pathname for saving split files (default = pn)
%  template = template metadata file for parsing ASCII data (default = prompted)
%
%output:
%  msg = status message
%  filelist = list of filenames successfully saved
%  badarrays = list of arrays that were not saved
%
%notes:
%  1) 'csi2struct.m' will be called to process the ASCII data file if a .mat file is not specified
%
%
%(c)2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 06-Aug-2013

%init output
msg = '';
filelist = [];
badarrays = [];

%validate path, supply default if omitted
if exist('pn','var') ~= 1
   pn = '';
end
if ~isdir(pn)
   pn = pwd;
else
   pn = clean_path(pn);
end

%validate output path, supply default if omitted/invalid
if exist('pn2','var') ~= 1
   pn2 = pn;
elseif ~isdir(pn2)
   pn2 = pn;
end

%validate file
if exist('fn','var') ~= 1
   fn = '';
   filespec = '*.mat;*.dat;*.txt;*.asc';
elseif exist([pn,filesep,fn],'file') ~= 2
   filespec = fn;
   fn = '';
end

%set default template if omitted
if exist('template','var') ~= 1
   template = 'choose';
end

%prompt for file if omitted/invalid
if isempty(fn)
   curpath = pwd;
   cd(pn)
   [fn,pn] = uigetfile(filespec,'Select a Campbell Scientific data logger file to import');
   cd(curpath)
   if fn == 0
      fn = '';
   end
end

%check for cancel
if ~isempty(fn)
   
   %parse file extension
   [tmp,fn_base,fn_ext] = fileparts(fn);
   
   %call csi2struct to parse logger file unless .mat file
   if ~strcmpi(fn_ext,'.mat')
      [msg2,fn2] = csi2struct(fn,pn,template);
      if isempty(fn2)
         msg = msg2;  %use csi2struct message as return message if not file generated
      end
   else
      fn2 = [pn,filesep,fn];  %generate fully-qualified filename
   end
   
   %load processed file to get array list
   if exist(fn2,'file') == 2
      
      try
         v = load(fn2,'-mat');
      catch e
         v = [];
         msg = ['error loading file ''',fn2,''' (',e.message,')'];
      end
      
      if isstruct(v)
         
         %get array of valid data structure names
         vars = fieldnames(v);  %get all variable names
         for n = 1:length(vars)
            if gce_valid(v.(vars{n}),'data') ~= 1
               vars{n} = '';  %null entry for non data structure
            end
         end
         
         %filter out invalid variables
         Ivalid = find(~cellfun('isempty',vars));
         vars = vars(Ivalid);
         
         if ~isempty(vars)
            
            %init file save list for output message
            filelist = cell(length(Ivalid),1);
            badarrays = filelist;
            
            %loop through variables
            for n = 1:length(Ivalid)
               data = v.(vars{n});                                                        %#ok<NASGU>
               fn_out = [pn2,filesep,fn_base,'_',vars{n},'.mat'];
               try
                  save(fn_out,'data')
                  filelist{n} = fn_out;
               catch
                  badarrays{n} = vars{n};
               end
            end
            
            %format output
            Ivalid = ~cellfun('isempty',filelist);
            
            %compress filelist
            filelist = filelist(Ivalid);
            if isempty(filelist)
               filelist = [];
            end
            
            %compress badarrays
            badarrays = badarrays(~Ivalid);            
            if isempty(badarrays)
               badarrays = [];
            end
            
            %generate output message
            msg = ['successfully split ',int2str(length(filelist)),' files, failed to split ',int2str(length(badarrays)),' files'];            
            
         else
            msg = ['no valid data structures were found in ''',fn2,''''];
         end
         
      else
         if isempty(msg)
            msg = ['Processed file ''',fn2,''' is not a valid MATLAB data file'];
         end
      end
      
   else
      msg = ['An error occurred loading the processed file ''',fn2,''''];
   end
   
end