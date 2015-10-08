function str = textfile2cell(fn,pn,emptylines,wrap,indent,trim)
%Reads the specified text file, and returns a cell array of strings with lines optionally word-wrapped
%
%**WARNING**
%This function is only intended for ASCII files - opening a non-ASCII file
%will produce unpredictable results and may take a long time to complete
%
%syntax:  str = textfile2cell(fn,pn,emptylines,wrap,indent,trim)
%
%inputs:
%  fn = filename
%  pn = pathname
%  emptylines = option to retain empty lines (0 = no, 1 = yes/default)
%  wrap = word-wrap margin (default = 0, min = 30)
%  indent = number of characters to indent wrapped lines (default = 0)
%  trim = option to trim leading and trailing blanks (0 = no/default, 1 = yes)
%
%output:
%  str = cell array of strings
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

%validate wrap option
if exist('wrap','var') ~= 1
   wrap = 0;
elseif ischar(wrap)
   wrap = 0;
elseif wrap > 0 && wrap < 30
   wrap = 30;
end

%validate indent option
if exist('indent','var') ~= 1
   indent = 0;
elseif ischar(indent)
   indent = 0;
elseif indent < 0
   indent = 0;
end

%check for empty filename - prompt
if exist([pn,filesep,fn],'file') ~= 2
   if ~isempty(fn)
      filespec = fn;
   else
      filespec = '*.txt;*.asc;*.prn';
   end
   cd(pn)
   [fn,pn] = uigetfile(filespec,'Select a text file to read');
   drawnow
   cd(curpath)
end

%check for cancel
if ischar(fn) && ~isempty(fn)
   
   %open file
   try
      fid = fopen([pn,filesep,fn],'r');
   catch
      fid = [];
   end
   
   if ~isempty(fid)
      
      %init runtime variables
      str = [];
      tmp = cell(1000,1);
      cnt = 0;
      
      ln = fgetl(fid);
      
      while ischar(ln)
         
         %remove trailing whitespace
         ln = deblank(ln);
         
         %check for empty line
         if ~isempty(ln) || emptylines == 1
            
            %increment temp array row counter
            cnt = cnt + 1;
            
            %check for trim option
            if trim == 1
               ln = trimstr(ln);
            end
            
            %check for exhausted temp buffer
            if cnt > size(tmp,1)
               str = [str ; tmp];   %add pending entries to output
               tmp = cell(1000,1);  %re-init temp array
               cnt = 1;             %restart counter
            end
            
            %add line to temp array
            tmp{cnt} = ln;
            
         end
         
         %read next line
         ln = fgetl(fid);
         
      end
      
      %close file
      fclose(fid);
      
      %add remaining lines to output
      str = [str ; tmp(1:cnt)];
      
      %check for wrap option
      if wrap > 0
         str = wordwrap(str,wrap,indent);
      end
      
   end
   
end



