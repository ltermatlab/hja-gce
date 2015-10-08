function [s,msg] = imp_datastruct(fn,pn)
%Retrieves a GCE Data Structure from a MATLAB binary file
%
%syntax: s = imp_datastruct(fn,pn)
%
%inputs:
%  fn = filename
%  pn = pathname
%
%output:
%  s = data structure
%  msg = text of any error message
%
%usage notes:
%  1. if only one valid GCE Data Structure is present it will be returned automatically
%  2. if multiple data structures are present, a list dialog will be presented to choose the structure to load
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
%last modified: 08-Oct-2011

s = [];
msg = '';
curpath = pwd;

%validate path
if exist('pn','var') ~= 1
   pn = '';
end
if isempty(pn)
   pn = curpath;
elseif exist(pn,'dir') ~= 7
   pn = curpath;
elseif strcmp(pn(end),filesep)
   pn = pn(1:end-1);
end

if exist('fn','var') ~= 1
   fn = '';
   filemask = '*.mat;*.MAT';
elseif exist([pn,filesep,fn],'file') ~= 2
   filemask = fn;
   fn = '';
end

%prompt for file
if isempty(fn)
   cd(pn)
   [fn,pn] = uigetfile(filemask,'Select a GCE Data Structure file to load');
   cd(curpath)
   drawnow
   if fn == 0
      fn = '';
   end
end

if ~isempty(fn)
   
   %load variables into a structure
   try
      vars = load([pn,filesep,fn],'-mat');
   catch
      vars = [];
      msg = 'invalid MATLAB file';
   end
   
   if isstruct(vars)

      %get variable names
      vnames = fieldnames(vars);
      
      %check for valid data structures
      Ivars = zeros(length(vnames),1);
      for n = 1:length(vnames)
         if gce_valid(vars.(vnames{n}),'data')
            Ivars(n) = 1;
         end
      end
      
      %generate logical index of valid structures
      Ivars = find(Ivars);
      
      %get variable selection
      if isempty(Ivars)
         Isel = [];
      elseif length(Ivars) > 1
         Isel = listdialog('liststring',vnames, ...
            'selectionmode','single', ...
            'promptstring','Select a variable to load', ...
            'name','Select Variable');
      else
         Isel = 1;
      end
      
      %extract selected structure
      if ~isempty(Isel)
         s = vars.(vnames{Isel});
      else
         msg = ['''',fn,''' does not contain any valid GCE Data Structures'];
      end
      
   else
      msg = ['''',fn,''' is not a valid MATLAB data file'];
   end
   
end