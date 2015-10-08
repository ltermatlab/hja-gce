function [s2,msg] = readheader(fn,pn,s)
%Parses documentation and attribute descriptor metadata using 'imp_ascii.m' to update a GCE Data Structure
%
%syntax:  [s2,msg] = readheader(fn,pn,s)
%
%inputs:
%   fn = filename of a tab, comma or space-delimitted ASCII file with optional header rows formatted as follows:
%     [category_field]:[value string] - metadata category/fieldname pair and corresponding value
%        (e.g. Dataset_Title:Annual survey of ...). Field names cannot contain spaces, and cannot match
%        the reserved fields listed below. Any number of metadata rows can be included in the header.
%     name:[column names] - delimited list of column names (no spaces within names)
%     datatype:[column data type] - delimited list of data type characters {'f' for floating-point
%        number, 'd' or 'i' for signed decimal/integer, 's' for string/character, 'e' for exponential)
%     units:[column units] - delimited list of column units (use ~ as a placeholder for spaces)
%     description:[column descriptions] - delimited list of column descriptions (use comma or tab
%        delimiters to preserve word spaces and prevent parsing errors - optional
%     variabletype:[column variable type] - delimited list of variable types ('data' for measured
%        data values, 'calculation' for calculated values, 'code' for coded values, etc.)
%     numbertype:[column numerical type] - delimited list of numerical types ('continuous' for ratio
%        values, 'discrete' for discontinuous values, 'angular' for angular values)
%     precision:[column output precisions] - delimited list of integers to be used to
%        format the number of decimal places when values are exported
%     criteria:[column flagging criteria] - delimited list of Q/C flagging criteria.  Criteria
%        are strings containing an indexing criterion (using 'x' to reference column values) and
%        single-character flag value, formatted as follows:
%           x<0='L'  or  x>=100='H' or x==3='N' or x~=0='V' for numerical columns
%           strcmp(x,'test')='N' for string columns
%        Multiple flag statements can be used for each column by separation criteria with ';'
%        (e.g. x<0='L';x>10='H'), and flagging characters will be appended if values match
%        multiple criteria.
%   pn = pathname (default is current directory)
%   s = structure to update (if omitted, a structure with only the header and metadata fields will be returned
%
%outputs:
%   s2 = updated data structure, or a minimal metadata structure (if s = [])
%   msg = text of any error message
%
%
%(c)2002-2012 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 22-Feb-2012

%initialize outputs
s2 = [];
msg = '';

%initialize variables
filemask  = '*.txt';

%set constants
curpath = pwd;
curdate = datestr(now);

%validate path
if exist('pn','var') ~= 1
   pn = curpath;
elseif isstruct(pn)  %catch missing pathname argument
   if exist('s','var') ~= 1
      s = pn;
   end
   pn = curpath;
elseif ~isdir(pn)
   pn = curpath;
else
   pn = clean_path(pn);
end

%initialize empty structure for output
if exist('s','var') ~= 1
   s = newstruct('data');
   s.title = ['New metadata imported ',curdate];
end

%validate filename
if exist('fn','var') ~= 1
   fn = '';
elseif exist([pn,filesep,fn],'file') ~= 2  %check for existence of file
   filemask = fn;
   fn = '';
end

%prompt for file
if isempty(fn)
   cd(pn)
   [fn,pn] = uigetfile(filemask,'Select a metadata file to read');
   cd(curpath)
end

%check for cancel
if fn ~= 0

   %parse the header
   [hdrs,hddrows,msg] = parseheader(fn,pn);

   %check for valid output
   if isstruct(hdrs) && hddrows > 0

      %init output structure
      s2 = s;

      %update structure metadata
      s2.title = hdrs.titlestr;
      s2.metadata = hdrs.metadata;
      s2.editdate = curdate;
      s2.history = [s.history ; {curdate},{'imported new header fields and metadata (''readheader'')'}];
      s2.name = hdrs.coltitles;
      s2.units = hdrs.units;
      s2.description = hdrs.desc;
      s2.datatype = hdrs.datatypes;
      s2.variabletype = hdrs.vartypes;
      s2.numbertype = hdrs.numtypes;
      s2.precision = hdrs.prec;
      s2.criteria = hdrs.flagcrit;

      %validate updated structure
      if gce_valid(s2,'data')
         
         %apply flagging criteria if data arrays present
         if ~isempty(s2.values{1})
            [s2,msg] = dataflag(s2);
         end
         
      else
         
         s2 = [];
         msg = 'metadata is not compatible with the existing data arrays';
         
      end

   else
      
      msg = 'unsupported or invalid file format';
      
   end

end
