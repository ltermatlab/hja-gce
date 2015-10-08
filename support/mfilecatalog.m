function mfilecatalog(filespec,pn1,fn,pn2)
%Generates a catalog of mfiles in the specified directory as an ASCII file.
%
%syntax: mfilecatalog(filespec,pn1,fn,pn2)
%
%inputs:
%  filespec = file specification string (default = '*.m')
%  pn1 = pathname containing mfiles to catalog (default = pwd)
%  fn = filename used to save catalog (default = mfiles.txt)
%  pn2 = pathname used to save catalog (deault = pn1)
%
%outputs:
%  none
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
%last modified: 04-Jun-2002

curpath = pwd;

if exist('filespec','var') ~= 1
   filespec = '*.m';
end

if exist('pn1') == 1
   cd(pn1);
else
   pn1 = curpath;
end

if exist('fn','var') ~= 1
   fn = 'mfiles.txt';
elseif isempty(fn)
   fn = 'mfiles.txt';
end

if exist('pn2','var') ~= 1
   pn2 = pn1;
end

d = dir(filespec);

if ~isempty(d)

   [fnames,I] = sort({d.name}');
   d = d(I);

   cd(pn2)
   fid = fopen(fn,'w');

   for n = 1:length(d)

      h = help(fnames{n});
      str = strrep(h,[char(10),' '],[char(13),char(9)]);  %replace newline with return, tab

      fprintf(fid,'%s\tdate: %s\r\t\r\t%s\r\r',strtok(d(n).name,'.'),strtok(d(n).date,' '),str(2:end));

   end

   fclose(fid);

end