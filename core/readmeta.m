function [s2,msg] = readmeta(fn,pn,s)
%Reads a text file containing delimited metadata fields ([category_field]:[value])
%for updating the metadata field in a GCE-LTER data structure.  See 'readdata.m'.
%
%syntax:  [s2,msg] = readmeta(fn,pn,s)
%
%inputs:
%   'fn' is the name of the text file
%   'pn' is the pathname (default is current directory)
%   's' is a structure to update (if omitted, a structure with only
%      the header and metadata fields will be returned
%
%outputs:
%   's2' is an updated data structure, or a minimal metadata structure
%
%
%(c)2002-2010 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 13-Oct-2010

%initialize outputs
s2 = [];
msg = '';

%initialize variables
filemask  = '*.txt';
cancel = 0;

%set constants
curpath = pwd;
curdate = datestr(now);

if exist('pn','var') ~= 1
   pn = curpath;
elseif isstruct(pn)  %catch missing pathname
   if exist('s','var') ~= 1
      s = pn;
   end
   pn = curpath;
end

if exist('s','var') ~= 1  %initialize empty structure for output
   s = newstruct('data');
   s.title = ['New metadata imported ',curdate];
end

if exist('fn','var') ~= 1
   fn = '';
elseif exist(fn,'file') ~= 2  %check for existence of file
   filemask = fn;
   fn = '';
end

%prompt for file
if isempty(fn)
   cd(pn)
   [fn,pn] = uigetfile(filemask,'Select a metadata file to read');
   cd(curpath)
end

if fn ~= 0  %check for cancel

   [hdrs,hdrrows,msg] = parseheader(fn,pn);

   if isstruct(hdrs)

      metadata = hdrs.metadata;
      titlestr = hdrs.titlestr;

      if ~isempty(metadata)

         s2 = s;

         if ~isempty(titlestr)
            s2.title = titlestr;
         end

         s2.metadata = cellstr(metadata);
         s2.editdate = curdate;
         s2.history = [s2.history ; {curdate} {'updated metadata (''readmeta'')'}];

      end

   else
      msg = 'invalid file format';
   end

end
