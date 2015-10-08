function listbox2file(h_listbox,fn,pn)
%Saves the string contents of a listbox uicontrol as an ASCII text file
%
%syntax: listbox2file(h_listbox,fn,pn)
%
%inputs:
%  h_listbox = uicontrol handle of the listbox (default = first listbox
%    on current figure)
%  fn = filename for text file (prompted if omitted)
%  pn = path name for text file (default = pwd if fn specified, otherwise prompted)
%
%outputs:
%  none
%
%
%(c)2002-2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 08-Oct-2013

if exist('h_listbox','var') ~= 1
   if length(findobj) > 1
      h_listbox = findobj(gcf,'Type','uicontrol','Style','listbox');
      if ~isempty(h_listbox)
         h_listbox = h_listbox(1);
      end
   else
      h_listbox = [];
   end
end

if ~isempty(h_listbox)
   
   %cache current directory
   curpath = pwd;

   %get listbox contents
   str = get(h_listbox,'String');
   
   if ~isempty(str)
      
      %set path
      if exist('pn','var') ~= 1 || ~isdir(pn)
         pn = curpath;
      end
      
      if exist('fn','var') ~= 1
         fn = '';
      end
      
      %prompt for file
      if isempty(fn)
         cd(pn)
         [fn,pn] = uiputfile('*.txt','Select a name and location for the text file');
         cd(curpath)
         drawnow
         if fn == 0
            fn = '';
         end
      end
      
      %write file unless cancelled
      if ~isempty(fn)
         
         %add appropriate file separator to path if not present
         if strcmp(pn(end),filesep) ~= 1
            pn = [pn,filesep];
         end
         
         %determine approprite line terminator
         if ispc
            fstr = '%s\r\n';
         else
            fstr = '%s\n';
         end
         
         %generate file
         try
            
            %open file
            fid = fopen([pn,fn],'w');
            
            %convert cell array of strings to character array
            if iscell(str)
               str = char(str);
            end
            
            %loop through lines
            for n = 1:size(str,1)
               fprintf(fid,fstr,str(n,:));
            end
            
            %close file
            fclose(fid);
            
         catch e
            
            %report error
            messagebox('init', ...
               ['An error occurred writing the file (',e.message,')'], ...
               '', ...
               'Error', ...
               [.9 .9 .9]);
            
         end
         
      end
      
   end
   
end