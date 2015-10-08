function h_fig = loadmap(fn,pn)
%Loads a MATLAB map figure, centers it onscreen, and updates the title and axes labels
%
%syntax: h_fig = loadmap(fn,pn)
%
%input:
%  fn = filename of .fig map file (prompted if omitted)
%  pn = pathname for fn (path of loadmap function)
%
%output:
%  h_fig = figure handle
%
%
%(c)2005 Wade Sheldon
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
%Department of Marine Sciences
%University of Georgia
%Athens, Georgia  30602-3636
%sheldon@uga.edu
%
%last modified: 12-Apr-2005

h_fig = [];

if exist('pn') ~= 1
   pn = '';
end

if isempty(pn)
   pn = fileparts(which('loadmap'));
elseif strcmp(pn(end),filesep)
   pn = pn(1:end-1);  %strip terminal path separator
end

if exist('fn') ~= 1
   fn = '';
end

if isempty(fn)
   [fn,pn] = uigetfile('*.fig;*.dat','Select a MATLAB map figure or Coastline Extractor file to open');
   drawnow
   if fn == 0
      fn = '';
   end
end

if ~isempty(fn)
   [tmp,fn_base,ext] = fileparts(fn);
   ext = lower(ext);
   try
      if strcmp(ext,'.fig')  %try figure
         open([pn,filesep,fn]);
         h_fig = gcf;
      elseif strcmp(ext,'.dat')  %try coastline extractor
         data = load([pn,filesep,fn],'-ascii');
         if size(data,2) == 2
            plotmap(data);
            h_fig = gcf;
         end
      else
         h_fig = [];
      end
      if ~isempty(h_fig)
         center_fig;              %center the figure on screen, resizing if necessary
         r12_axistitles;         %update title, axis labels if MATLAB R12 or later
         mapbuttons('replace'); %update plot buttons if old figure
         mapmenu('replace');     %update plot menus if old figure
      end
   catch
      h_fig = [];
   end
   if isempty(h_fig)
      messagebox('init',['''',fn,''' could not be opened as a map'],'','Error',[.9 .9 .9])
   end
end