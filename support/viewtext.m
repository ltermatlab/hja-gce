function viewtext(str,wrap,indent,titlestr)
%Displays the contents of a character array or cell array of strings in a GUI text viewer using 'ui_viewtext'
%
%Note: use 'textfile2cell' and specify a filename and path to view contents of a text file, e.g.
% viewtext(textfile2cell('myfile.txt','c:\mypath'),80,0)
%
%syntax: viewtext(str,wrap,indent,titlestr)
%
%inputs:
%  str = text to display (character array or cell array of strings, tabs converted to spaces automatically)
%  wrap = wordwrap margin in characters (default = 0)
%  indext = leading indent for wrapped lines (default = 0)
%  titlestr = title for the dialog (default = 'Text Viewer')
%
%outputs:
%  none
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
%last modified: 08-Dec-2010

if nargin >= 1
   if exist('wrap','var') ~= 1
      wrap = 0;
   end
   if exist('indent','var') ~= 1
      indent = 0;
   end
   if exist('titlestr','var') ~= 1
      titlestr = 'Text Viewer';
   end
   try
      if ischar(str)
          str = cellstr(str);  %convert to cell array if padded character array
      end
      str = strrep(str,char(9),'   ');  %replace tabs with spaces
      ui_viewtext(str,wrap,indent,titlestr)
   catch
      disp('an error occurred initializing the text viewer');
   end
end