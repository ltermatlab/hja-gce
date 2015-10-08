function [s,msg] = imp_csi_array(fn,pn,array,template)
%Imports an array from a Campbell Scientific Instruments array-based data logger file
%calling 'csi2struct.m' to process the ASCII data file if a .mat file is not specified
%
%syntax: [s,msg] = imp_csi_array(fn,pn,array,template)
%
%input:
%  fn = filename to load or parse (default = prompted)
%  pn = pathname for fn (default = pwd)
%  array = array name to import (default = prompted)
%  template = template metadata file for parsing ASCII data (default = prompted)
%
%output:
%  s = data structure generated for the specified array
%  msg = text of any error message
%
%
%(c)2011-2012 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 08-Jun-2012

%init output
s = [];
msg = '';

%validate path, supply default if omitted
if exist('pn','var') ~= 1
   pn = '';
end
if ~isdir(pn)
   pn = pwd;
else
   pn = clean_path(pn);
end

%validate file
if exist('fn','var') ~= 1
   fn = '';
   filespec = '*.mat;*.dat;*.txt;*.asc';
elseif exist([pn,filesep,fn],'file') ~= 2
   filespec = fn;
   fn = '';
end

%set default array if omitted
if exist('array','var') ~= 1
   array = '';
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
      catch
         v = [];
      end
      
      if isstruct(v)
         
         %get array of valid data structure names
         vars = fieldnames(v);  %get all variable names
         varlist = vars;  %init variable label for dialog
         for n = 1:length(vars)
            if gce_valid(v.(vars{n}),'data') ~= 1
               vars{n} = '';  %null entry for non data structure
            else               
               numrecs = num_records(v.(vars{n}));
               numcols = length(v.(vars{n}).name);
               titlestr = v.(vars{n}).title;
               varlist{n} = [vars{n},' (',int2str(numcols),' cols, ',int2str(numrecs),' rows): ',titlestr];
            end
         end
         
         %filter out invalid variables
         Ivalid = find(~cellfun('isempty',vars));
         vars = vars(Ivalid);
         
         if ~isempty(vars)
            
            varlist = varlist(Ivalid);  %apply filter to variable labels
            
            %check for array specification or use a GUI list dialog
            if ~isempty(array)
               Isel = find(strcmp(vars,array));
            else
               Isel = listdialog('name','Array List', ...
                  'promptstring','Select a CSI data logger array to import', ...
                  'liststring',varlist, ...
                  'selectionmode','single', ...
                  'listsize',[0 0 700 400]);                  
            end
            
            if ~isempty(Isel)
               s = v.(vars{Isel});
            elseif ~isempty(array)
               msg = ['array ',array,' was not found in ''',fn2,''''];
            end
            
         else
            msg = ['no valid data structures were found in ''',fn2,''''];
         end
         
      else
         msg = ['Processed file ''',fn2,''' is not a valid MATLAB data file'];
      end
      
   else
      msg = ['An error occurred loading the processed file ''',fn2,''''];
   end
   
end