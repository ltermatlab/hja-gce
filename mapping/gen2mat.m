function map = gen2mat(filename,pathname)
%Reads .GEN files created by Arcview's UNGENERATE command into a MATLAB array
%
%syntax: map = gen2mat(filename,pathname)
%
%(c)2002,2003,2004 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 08-Sep-2004

map = [];
curpath = pwd;

if exist('pathname') == 1
   cd(pathname)
else
   pathname = curpath;
end

if exist('filename') ~= 1
   [filename,pathname] = uigetfile('*.gen','Select map file to import');
elseif exist(filename) ~= 2
   [filename,pathname] = uigetfile(filename,['Locate the GEN file ''' filename '''']);
end

if filename ~= 0

   map = [NaN NaN];
   data = [NaN NaN];
   blockcnt = 0;

   cd(pathname)

   fid = fopen(filename,'r');

   fgetl(fid);  %burn 1st line

   eof = 0;

   while eof == 0

      block = fscanf(fid,'%f %f',[2 inf]);

      if ~isempty(block)

         data = [data ; block' ; NaN NaN];

         if size(data,1) >= 500
            map = [map ; data];
            data = [NaN NaN];
         end

         blockcnt = blockcnt + 1;

         if blockcnt == fix(blockcnt/100)*100
            clc; disp([num2str(blockcnt) ' data segments processed ...'])
         end

         fgetl(fid); fgetl(fid);   %burn intervening lines

      else

         eof = 1;

      end

   end

   fclose(fid);

   map = [map(2:size(map,1),1:2) ; data(1:size(data,1)-1,1:2)];

end

cd(curpath)
