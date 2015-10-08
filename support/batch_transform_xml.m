function msg = batch_transform_xml(pn,filespec,xsl,extension)
%Performs batch XSL tranformation of xml documents in a directory
%
%syntax: msg = batch_transform_xml(pn,filespec,xsl,extension)
%
%input:
%  pn = pathname
%  filespec = file specifier
%  xsl = XSL filename or URL
%  extension = filename extension for transformed files (e.g. 'htm')
%
%output:
%  msg = status message (multi-line character array)
%
%
%(c)2010 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 14-Oct-2010

if nargin == 4
   
   if isdir(pn)
      
      pn = clean_path(pn);  %remove terminal file separator
      
      d = dir([pn,filesep,filespec]);  %get directory listing of files
      
      if ~isempty(d)
         
         msg = repmat({''},length(d),1);  %init message array
         
         %loop through files applying transform
         for n = 1:length(d)
            fn = d(n).name;  %get filename
            [pn_temp,fn_base] = fileparts(fn);  %base base filename
            fn_out = [fn_base,'.',extension];  %generate output filename
            try
               xslt([pn,filesep,fn],xsl,[pn,filesep,fn_out]);  %run transform
               msg{n} = ['successfully transformed ',fn];
            catch
               msg{n} = ['errors occurred transforming ',fn];
            end               
         end
         
         msg = char(msg);  %convert message to character array
         
      else
         msg = 'no files matched';
      end
      
   else
      msg = 'invalid directory';
   end
   
else
   msg = 'insufficient arguments for function';
end