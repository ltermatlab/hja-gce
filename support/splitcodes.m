function [codenames,codevalues] = splitcodes(str,delim)
%Parses a delimited string containing code name, code value pairs and returns matching name and value arrays
%(e.g. code1 = value1, code2 = value2, ...)
%
%syntax: [codenames,codevalues] = splitcodes(str,delim)
%
%input:
%  str = string to parse
%  delim = delimiter character (default = ',')
%
%output:
%  codename = array of code names
%  codevalues = matching array of code values
%
%
%(c)2002-2006 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 19-Oct-2004

codenames = [];
codevalues = [];

if nargin >= 1
   
   if exist('delim','var') ~= 1
      delim = ',';
   end
   
   ar = splitstr(str,delim);
   
   if ~isempty(ar)
      for n = 1:length(ar)
         ar2 = splitstr(ar{n},'=');
         if length(ar2) == 2
            codenames = [codenames ; ar2(1)];
            codevalues = [codevalues ; ar2(2)];
         end
      end
   end
   
end