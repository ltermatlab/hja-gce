function help_flagfnc
%Opens a GUI dialog containing help text for all QA/QC flagging functions named 'flag_*'
%
%syntax: help_flagfnc
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
%last modified: 16-Nov-2005

str_intro = { ...
      '================================================================================================='; ...
      '                           GCE Data Toolbox Flag Function Reference'; ...
      '================================================================================================='; ...
      ' '; ...
      '     Function-based flag criteria should be written as:'; ...
      ' '; ...
      '        fnc(x,arg1,arg2,...)=''F'', where:'; ...
      '            fnc = function name'; ...
      '            x = data column placeholder (values will be sent to function)'; ...
      '            arg1,arg2,... = additional function arguments'; ...
      '            F = flag character to assign to values flagged based on the function'; ...
      ' '; ...
      '     Note that values in any data column can also be referenced as ''col_[name]'''; ...
      ' '; ...
      '     Examples:'; ...
      ' '; ...
      '        flag_nsigma(x,3,3,5,1)=''Q'''; ...
      ' '; ...
      '        flag_o2saturation(col_O2_Concentration,col_Temp_Water,col_Salinity,100,20,''mg/L'')=''I'''; ...
      ' '; ...
      '================================================================================================='; ...
      ' '};
str_help = [];
str_view = [];

pn = fileparts(which('help_flagfnc'));

d = dir([pn,filesep,'flag_*.*']);

for n = 1:length(d)
   fn = d(n).name;
   [tmp,fn_base] = fileparts(fn);
   try
      str = ['Function: ',fn_base,char(10),char(10),help(fn)];
   catch
      str = '';
   end
   if ~isempty(str)
      str_help = [str_help ; {str}];
   end
end

str_sep = [{repmat('=',1,80)};{''}];

if ~isempty(str_help)
   str_view = [str_intro ; splitstr(str_help{1},char(10),0,0)];
   for n = 2:length(str_help)
      str_view = [str_view ; str_sep ; splitstr(str_help{n},char(10),0,0)];
   end
   ui_viewtext(str_view,0,0,'Flag Function Reference');
end