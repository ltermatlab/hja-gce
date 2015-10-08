function [s2,msg] = trim_textcols(s,cols,logopt,flag)
%Trims leading and trailing blanks from all or specified text columns in a GCE Data Structure
%
%syntax: [s2,msg] = trim_textcols(s,cols,logopt,flag)
%
%input:
%  s = data structure to modify (struct; required)
%  cols = array of column names or index numbers to trim (cell or integer array; optional; 
%     default = all string columns)
%  logopt =  maximum number of value changes to log to the processing history field
%     (integer; optional; 0 = none, default = 100, inf = all)
%  flag = flag to assign for revised data values (string; optional; default = '' for no flag)
%  flagdef = definition of flag (string; optional; default = '')
%
%output:
%  s2 = modifed string
%  msg = text of any error message
%
%notes:
%  1) numeric columns included in cols will be ignored
%  2) the original structure will be returned unmodified if no substitutions are made
%
%
%(c)2013-2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 19-Feb-2015

s2 = [];
msg = '';

if nargin >= 1 && gce_valid(s,'data')
   
   %get column datatypes
   dtype = get_type(s,'datatype');
   Istr = find(strcmp('s',dtype));
   
   %validate column selection
   if exist('cols','var') ~= 1 || isempty(cols)
      cols = Istr;
   elseif ~isnumeric(cols)
      cols = name2col(s,cols);
   else
      cols = cols(cols>0 & cols<length(s.name));
   end
   
   %remove numeric columns from cols
   cols = intersect(cols,Istr);

   %copy unmodified input structure to output
   s2 = s;

   if ~isempty(cols)
      
      %validate logopt
      if exist('logopt','var') ~= 1
         logopt = 100;
      elseif ~isnumeric(logopt)
         logopt = 100;
      end
      
      %validate flag option
      if exist('flag','var') ~= 1
         flag = '';
      elseif ~ischar(flag)
         flag = '';
      end
      
      %validate flag def option
      if exist('flagdef','var') ~= 1 || isempty(flag)
         flagdef = '';
      end
      
      %loop through columns trimming strings
      for n = 1:length(cols)
         str = extract(s2,cols(n));
         str2 = strtrim(str);
         s2 = update_data(s2,cols(n),str2,logopt,flag,flagdef,'trim_textcols');
      end
      
   else
      msg = 'invalid column selection or no string columns found';
   end
   
end