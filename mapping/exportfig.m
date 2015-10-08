function exportfig(option)
%Exports the current figure in the specified format with uicontrol printing suppressed, prompting for filename and path
%
%syntax: exportfig(option)
%
%input:
%  option = print format option:
%    'psbw' = B&W Postscript
%    'psc' = Color Postscript
%    'epsbw1' = B&W Encapsulated Postscript Level 1
%    'epsc1' = Color Encapsulated Postscript Level 1
%    'epsbw2' = B&W Encapsulated Postscript Level 2
%    'epsc2' = Color Encapsulated Postscript Level 2
%    'pngsuper' = 600dpi PNG
%    'pnghigh' = 300dpi PNG
%    'pngmed' = 150dpi PNG
%    'pnglow' = 96dpi PNG
%    'jpegsuper' = 600dpi JPEG
%    'jpeghigh' = 300dpi JPEG
%    'jpegmed' = 150dpi JPEG
%    'jpeglow' = 96dpi JPEG
%    'tiffsc' = 600dpi TIFF (compressed)
%    'tiffsnc' = 600dpi TIFF (no compression)
%    'tiffhc' = 300dpi TIFF (compressed)
%    'tiffhnc' = 300dpi TIFF (no compression)
%    'tiffmc' = 150dpi TIFF (compressed)
%    'tiffmnc' = 150dpi TIFF (no compression)
%    'tifflc' = 96dpi TIFF (compressed)
%    'tifflnc' = 96dpi TIFF (no compression)
%
%
%(c)2005 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 06-May-2005

curpath = pwd;
lastpath = curpath;

%get cached path
h_save = findobj(gcf,'Tag','mnuSave');
if isempty(h_save)
   h_save = findobj(gcf,'Tag','mnuExport');  %check for alternative tag
end
if ~isempty(h_save)
   lastpath = get(h_save,'UserData');
   if exist(lastpath) ~= 7
      lastpath = curpath;
      set(h_save,'UserData',curpath)  %reset path cache if invalid
   end
end

h = gcf;
mode_buf = get(h,'paperpositionmode');
set(h,'paperpositionmode','auto')

switch option
   
case 'psbw',
   opt = ' -dps2 -loose -noui';
   spec = '*.ps';
   
case 'psc',
   opt = ' -dpsc2 -loose -noui';
   spec = '*.ps';
   
case 'epsbw2',
   opt = ' -deps2 -tiff -loose -noui';
   spec = '*.eps';
   
case 'epsc2',
   opt = ' -depsc2 -tiff -loose -noui';
   spec = '*.eps';
   
case 'epsbw1',
   opt = ' -deps -tiff -loose -noui';
   spec = '*.eps';
   
case 'epsc1',
   opt = ' -depsc -tiff -loose -noui';
   spec = '*.eps';
   
case 'epsc2',
   opt = ' -dps -tiff -loose -noui';
   spec = '*.ps';
   
case 'pngsuper'
   opt = ' -dpng -r600 -noui';
   spec = '*.png';
   
case 'pnghigh'
   opt = ' -dpng -r300 -noui';
   spec = '*.png';
   
case 'pngmed'
   opt = ' -dpng -r150 -noui';
   spec = '*.png';
   
case 'pnglow'
   opt = ' -dpng -r96 -noui';
   spec = '*.png';
   
case 'jpegsuper'
   opt = ' -djpeg90 -r600 -noui';
   spec = '*.jpg;*.jpeg';
   
case 'jpeghigh',
   opt = ' -djpeg90 -r300 -noui';
   spec = '*.jpg;*.jpeg';
   
case 'jpegmed',
   opt = ' -djpeg90 -r150 -noui';
   spec = '*.jpg;*.jpeg';
   
case 'jpeglow',
   opt = ' -djpeg90 -r96 -noui';
   spec = '*.jpg;*.jpeg';
   
case 'tiffsc'
   opt = ' -dtiff -r600 -noui';
   spec = '*.tif;*.tiff';
   
case 'tiffsnc'
   opt = ' -dtiffnocompression -r600 -noui';
   spec = '*.tif;*.tiff';
   
case 'tiffhc',
   opt = ' -dtiff -r300 -noui';
   spec = '*.tif;*.tiff';
   
case 'tiffhnc',
   opt = ' -dtiffnocompression -r300 -noui';
   spec = '*.tif;*.tiff';
   
case 'tiffmc',
   opt = ' -dtiff -r150 -noui';
   spec = '*.tif;*.tiff';
   
case 'tiffmnc',
   opt = ' -dtiffnocompression -r150 -noui';
   spec = '*.tif;*.tiff';
   
case 'tifflc'
   opt = ' -dtiff -r96 -noui';
   spec = '*.tif;*.tiff';
   
case 'tifflnc'
   opt = ' -dtiffnocompression -r96 -noui';
   spec = '*.tif;*.tiff';
   
otherwise
   opt = '';
   spec = '*.fig';
   
end

cd(lastpath)
[filename,pathname] = uiputfile(spec,'Choose a name and directory for the output file');
drawnow

if filename ~= 0
   
   figure(h)
   
   cd(pathname)   
   if ~isempty(opt)
      eval(['print ''',filename,'''',opt]);
   else
      hgsave(gcf,filename);
   end
   
   if ~isempty(h_save)
      set(h_save,'UserData',pathname)  %cache save path
   end
   
end

set(gcf,'paperpositionmode',mode_buf)
cd(curpath)
