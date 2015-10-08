function str = textfile2str(fn,pn,emptylines,trim)
%Reads the specified text file, and returns a string (i.e. 1-row character array)
%
%**WARNING**
%This function is only intended for ASCII files - opening a non-ASCII file
%will produce unpredictable results and may take a long time to complete
%
%syntax:  str = textfile2cell(fn,pn,emptylines,trim)
%
%inputs:
%  fn = filename
%  pn = pathname
%  emptylines = option to omit empty lines (0 = no/default, 1 = yes)
%  trim = option to trim leading and trailing blanks (0 = no/default, 1 = yes)
%
%output:
%  str = 1-row cell array containing file contents (including line terminators)
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
%last modified: 21-May-2013

%init output
str = '';
curpath = pwd;

%validate path, supply default if omitted
if exist('pn','var') ~= 1 || isempty(pn) || ~isdir(pn)
   pn = curpath;
else
   pn = clean_path(pn);
end

%check for omitted file
if exist('fn','var') ~= 1
   fn = '';
end

%set default trim option
if exist('trim','var') ~= 1
   trim = 0;
end

%set default emptylines option
if exist('emptylines','var') ~= 1
   emptylines = 0;
end

%check for fully qualified filename
if exist(fn,'file') == 2
   fqfn = fn;
elseif exist([pn,filesep,fn],'file') == 2
   fqfn = [pn,filesep,fn];
else
   if ~isempty(fn)
      filespec = fn;
   else
      filespec = '*.txt;*.asc;*.prn';
   end
   cd(pn)
   [fn,pn] = uigetfile(filespec,'Select a text file to read');
   drawnow
   cd(curpath)
   if ischar(fn)
      fqfn = [pn,filesep,fn];
   else
      fqfn = '';
   end
end

%check for cancel
if ~isempty(fqfn)
   
   try
      fid = fopen(fqfn,'r');
   catch e
      fid = [];
   end
   
   if ~isempty(fid)
      
      %init temp variables and counters
      ar = [];
      ar_tmp = cell(1,1000);
      cnt = 0;
      
      %read first line
      ln = fgets(fid);
      
      while ischar(ln)
         
         if ~isempty(deblank(ln)) || emptylines == 1
            
            %increment counter
            cnt = cnt + 1;
            
            %check for trim option - remove leading whitespace
            if trim == 1
               ln = trimstr(ln);
            end
            
            %check for end of intermediate cell array - redimension
            if cnt > size(ar_tmp,2)
               ar = [ar ar_tmp];       %add pending rows to array
               ar_tmp = cell(1,1000);  %re-init temp array
               cnt = 1;                %reset counter
            end
            
            %store string
            ar_tmp{cnt} = ln;
            
         end
         
         %get next line
         ln = fgets(fid);
         
      end
      
      %close file
      fclose(fid);
      
      %add remainder of temp array to output
      ar = [ar ar_tmp(1:cnt)];
      
      %convert cell array to string
      str = char([ar{:}]);

   end
   
end



