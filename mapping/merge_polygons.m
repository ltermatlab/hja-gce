function [polydata,msg] = merge_polygons(opt,sortnames,fn1,pn1,fn2,pn2,fn_out,pn_out)
%Merges polygons stored in GCE Maptools .ply files to form a new compbined database
%
%syntax: [polydata,msg] = merge_polygons(opt,sortnames,fn1,pn1,fn2,pn2,fn_out,pn_out)
%
%inputs:
%  opt = merge option:
%    'all' = retain all entries in both databases (sorted)
%    'unique' = retain only unique entries from either database (based on name and date) - default
%  sortnames = option to sort polygon names (0 = no/default, 1 = yes)
%  fn1 = filename of first .ply file (prompted if omitted)
%  pn1 = pathname of first .ply file (pwd if omitted, blank)
%  fn2 = filename of second .ply file (prompted if omitted)
%  pn2 = pathname of second .ply file (pwd if omitted, blank)
%  fn_new = filename for merged .ply file (prompted if omitted)
%  pn_new = pathname for merged .ply file (pwd if omitted)
%
%outputs:
%  polydata = structure containing polygon data for 'poly_mgr'
%  msg = text of any error message
%
%(c)2004 Wade M. Sheldon
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
%Dept. of Marine Sciences
%University of Georgia
%Athens, GA 30602
%email: sheldon@uga.edu
%
%last modified: 30-Jun-2004

polydata = [];
msg = '';
curpath = pwd;

%validate input, set defaults
if exist('opt') ~= 1
   opt = 'all';
elseif ~strcmp(opt,'unique')
   opt = 'all';
end

if exist('sortnames') ~= 1
   sortnames = 0;
end

if exist('pn1') ~= 1
   pn1 = curpath;
elseif exist(pn1) ~= 7
   pn1 = curpath;
end

if exist('fn1') ~= 1
   fn1 = '';
   filespec1 = '*.ply';
elseif exist([pn1,filesep,fn2]) ~= 2
   filespec1 = fn1;
   fn1 = '';
end

if exist('pn2') ~= 1
   pn2 = curpath;
elseif exist(pn2) ~= 7
   pn2 = curpath;
end

if exist('fn2') ~= 1
   fn2 = '';
   filespec2 = '*.ply';
elseif exist([pn2,filesep,fn2]) ~= 2
   filespec2 = fn2;
   fn2 = '';
end

if exist('pn_out') ~= 1
   pn_out = curpath;
elseif exist(pn2) ~= 7
   pn_out = curpath;
end

if exist('fn_out') ~= 1
   fn_out = '';
end

%prompt for first file if omitted/invalid
if isempty(fn1)
   cd(pn1)
   [fn1,pn1] = uigetfile(filespec1,'Select an initial polygon database file to load');
   if fn1 == 0
      fn1 = '';
   end
   cd(curpath)
end

%prompt for second file if omitted/invalid
if isempty(fn2)
   cd(pn2)
   [fn2,pn2] = uigetfile(filespec2,'Select a polygon database file to merge');
   if fn2 == 0
      fn2 = '';
   end
   cd(curpath)
end

if ~isempty(fn1) & ~isempty(fn2)

   %load files, retrieve structures
   cd(pn1)
   vars1 = load(fn1,'-mat');
   cd(pn2)
   vars2 = load(fn2,'-mat');
   cd(curpath)
   
   if isfield(vars1,'polydata')
      polydata1 = vars1.polydata;
   else
      polydata1 = [];
   end
   
   if isfield(vars2,'polydata')
      polydata2 = vars2.polydata;
   else
      polydata2 = [];
   end
   
   if ~isempty(polydata1) & ~isempty(polydata2)

      %retrieve/standardize polygon list
      list1 = polydata1.list;
      list2 = polydata2.list;
      if ~iscell(list1)
         list1 = cellstr(list1);
      end
      if ~iscell(list2)
         list2 = cellstr(list2);
      end
      
      %retrieve/standardize polygon data
      data1 = polydata1.data;
      data2 = polydata2.data;
      if ~iscell(data1)
         data1 = {[data1]};
      end
      if ~iscell(data2)
         data2 = {[data2]};
      end

      %retrieve/standardize polygon centers
      center1 = polydata1.center;
      center2 = polydata2.center;
      if ~iscell(center1)
         center1 = {[center1]};
      end
      if ~iscell(center2)
         center2 = {[center2]};
      end
      
      %perform merge
      if strcmp(opt,'all')
         newlist = [list1 , list2];
         newdata = [data1 , data2];
         newcenter = [center1 , center2];     
      else
         [tmp,Inew] = setdiff(list2,list1);
         if ~isempty(Inew)
            newlist = [list1 , list2(Inew)];
            newdata = [data1 , data2(Inew)];
            newcenter = [center1 , center2(Inew)];
         else
            newlist = list1;
            newdata = data1;
            newcenter = center1;
            msg = ['no unique polygons found in ''',fn2,''' -- merge skipped'];
         end
      end
      
      polydata = polydata1;

      if sortnames == 1
         [newlist,Isort] = sort(newlist);  %sort final list
      else
         Isort = [1:length(newlist)];
      end
      
      %create new database based on polydata1
      polydata.list = newlist;
      polydata.data = newdata(Isort);
      polydata.center = newcenter(Isort);
      
      %save file if specified
      if ~isempty(fn_out)
         cd(pn_out)
         save(fn_out,'polydata')
         cd(curpath)
      end
      
   else
      
      msg = 'one or both polygon files are invalid';
      
   end
   
end