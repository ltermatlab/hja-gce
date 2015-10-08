function status = cell2textfile(ar,fn,digits)
%Exports contents of a cell array of scalar character or numeric values to a text file
%
%syntax: status = cell2textfile(ar,fn,digits)
%
%input:
%  ar = cell array
%  fn = fully-qualified filename for the text file (.csv for CSV format,
%     any other extension for tab-delimited text)
%  digits = maximum digits of precision for numeric values (default = automatic)
%
%output:
%  status = status message
%
%(c)2011 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 25-Jan-2011

if nargin >= 2 && iscell(ar)
   
   %supply default for digits
   if exist('digits','var') ~= 1
      digits = [];
   end
   
   %determine file extension
   [pn,fn_base,fn_ext] = fileparts(fn);
   if strcmp(fn_ext,'.csv')
      delim = ',';
      charwrap = '"';
   else
      delim = '\t';
      charwrap = '';
   end
   
   %check for non-scalar arrays in cells
   Ibad = find(cellfun('ndims',ar) ~= 2);
   
   if isempty(Ibad)
      
      %open file handle
      try
         fid = fopen(fn,'w');
      catch
         fid = [];
      end
      
      if ~isempty(fid)
         
         %look up number of columns
         numcols = size(ar,2);
         
         %loop over first 2 dimensions of the array
         for row = 1:size(ar,1)
            
            for col = 1:numcols
               
               val = ar{row,col};  %extract cell value
               
               if isnumeric(val)
                  if isempty(digits)
                     str = num2str(val);  %convert numeric to string
                  else
                     str = num2str(val,digits);
                  end
               elseif ischar(val)
                  str = [charwrap,val,charwrap];
               elseif iscell(val)
                  str = char(val);  %convert cell to string
               else
                  str = '';
               end
               
               fprintf(fid,'%s',str);  %write out value
               
               %add delimiter or end line
               if col < numcols
                  fprintf(fid,delim);
               else
                  fprintf(fid,'\r\n');
               end
               
            end
         end
         
         fclose(fid);  %close file
         
      else
         status = 'error opening file';
      end
      
   else
      status = 'unsupported cell array configuration';
   end
   
else
   status = 'insufficent arguments';
end