function numrows = split_csi(arrays,fn,pn)
%Splits Campbell Scientific datalogger files into separate files for each
%of the specified storage arrays. Split files are named according to the input
%filename, with '_xxx' appended to the name and the same extension.
%
%syntax: numrows = split_csi(arrays,fn,pn)
%
%inputs:
%  arrays = list of arrays to save (cell array of strings or numeric array)
%  fn = name of file to split (will be prompted if omitted or empty)
%  pn = file path
%
%outputs:
%  numrows = number of data rows processed for each array
%
%
%(c)2002-2011 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 07-Sep-2011

%init output
numrows = [];

if nargin >= 1

   %validate arrays argument
   if ~iscell(arrays)
      if isnumeric(arrays)
         arrays = strrep(cellstr(int2str(arrays(:))),' ','');
      elseif ischar(arrays)
         arrays = cellstr(arrays);
      else  %unsupported format
         arrays = [];
      end
   end

   %get working directory
   curpath = pwd;

   %validate path argument
   if exist('pn','var') ~= 1
      pn = curpath;
   elseif ~isdir(pn)
      pn = curpath;
   else
      pn = clean_path(pn);
   end

   %check for missing file argument
   if exist('fn','var') ~= 1
      fn = '';
   end

   %prompt for file if note specified or missing
   if isempty(fn) || exist([pn,filesep,fn],'file') ~= 2
      cd(pn)
      if isempty(fn)
         filespec = '*.dat;*.txt;*.asc';
      else
         filespec = fn;
      end
      [fn,pn] = uigetfile(filespec,'Select a Campbell datalogger file to process');
      drawnow
      if fn == 0
         fn = '';
      end
      cd(curpath)
   end

   %check for valid file, arrays
   if ~isempty(fn) && ~isempty(arrays)

      %init numrows to store length of each array
      numrows = zeros(length(arrays),1);

      %parse base filename
      [tmp,base,ext] = fileparts(fn);

      %open output file handles, put handles in an array
      fidout = zeros(length(arrays),1);
      for n = 1:length(arrays)
         fidout(n) = fopen([pn,filesep,base,'_',arrays{n},ext],'w');
      end

      %open input file and read first line
      fid = fopen([pn,filesep,fn],'r');
      ln = deblank(fgetl(fid));

      %loop through file until eof (ln == -1)
      while ischar(ln)

         %remove leading/trailing spaces
         ln = deblank(ln);

         if ~isempty(ln)

            ln = strrep(ln,char(13),'');  %strip carriage returns

            %check for valid array id (no leading comma)
            if ~strcmp(ln(1),',')
               Icomma = strfind(ln,',');  %get index of commas
               if length(Icomma) >=3  %check for incomplete lines
                  lbl = ln(1:Icomma(1)-1);  %get array label
                  Iarray = find(strcmp(arrays,lbl));  %check to see if array is specified for output
                  if length(Iarray) == 1
                     numrows(Iarray) = numrows(Iarray) + 1;
                     fprintf(fidout(Iarray),'%s\r',ln);  %write line to appropriate file
                  end
               end
            end

         end

         %read next line
         ln = fgetl(fid);

      end

      %close all open file handles
      fclose(fid);
      for n = 1:length(fidout)
         fclose(fidout(n));
      end

   end

end
