function msg = clean_endnote(fn,fn2,pn)
%Cleans up author lists and keywords with hard returns and missing identifiers in an Endnote Export file
%
%syntax: clean_endnote(fn,fn2,pn)
%
%inputs:
%  fn = filename of EndNote export file
%  fn2 = filename for cleaned output file
%  pn = pathname of EndNote export file and cleaned output file
%
%outputs:
%  msg = status message
%
%notes:
%  1) single-line author lists in the format: last,init.init, init.init last, ... will be standardized
%  2) keywords separated by hard returns will be combined into a comma-delimited list
%
%(c)2010-2014 Wade M. Sheldon
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
%Wade M. Sheldon
%Dept. of Marine Sciences
%University of Georgia
%Athens, GA 30602-3636
%email: sheldon@uga.edu
%
%last modified: 13-Aug-2014

if nargin == 3
   
   %clean path the remove any terminal path delimiters
   pn = clean_path(pn);
   
   %open file handles
   try
      fid = fopen([pn,filesep,fn],'r');
   catch
      fid = [];
   end
   
   if ~isempty(fid)
      try
         fid2 = fopen([pn,filesep,fn2],'wt');
      catch
         fid2 = [];
      end
   else
      fid2 = [];
   end
   
   %check for valid handles
   if ~isempty(fid) && ~isempty(fid2)
      
      %init field buffer
      lastfield = '';
      
      %read first line
      str = fgetl(fid);
      
      %perform author and editor list cleanup
      while ischar(str)
         
         %remove terminal whitespace
         str = trimstr(str);
         
         %check for empty string
         if ~isempty(str)
            
            %check for valid field
            if strncmp(str,'%',1) && length(str) >= 2
               
               %buffer field
               lastfield = str(1:2);
               
               if strncmp([str,'   '],'%A ',3) || strncmp([str,'   '],'%E ',3)
                  
                  if strncmp([str,'   '],'%A ',3)
                     fld = '%A ';
                  else
                     fld = '%E ';
                  end
                  
                  str2 = strrep(strrep(strrep(strrep(str,' and ',', '),', Jr',' Jr'),', II',' II'),', IV',' IV');
                  
                  ar = splitstr(str2,',');
                  len = length(ar);
                  
                  if len >= 2

                     %init output string with leading field code
                     str = [ar{1},', ',ar{2}];

                     %check for all authors on 1 comma-delimited line
                     if len > 3 && fix(len/2)*2 == len
                        for n = 3:2:len
                           str = [str,char(13),fld,ar{n},', ',ar{n+1}];
                        end
                     else
                        for n = 3:len
                           ar2 = splitstr(ar{n},' ');
                           if length(ar2) == 2
                              str = [str,char(13),fld,ar2{2},', ',ar2{1}];
                           else
                              str = [str,char(13),fld,ar{n}];
                           end
                        end
                     end
                  end
                  
               end
               
               %define output
               fstr = '\r\n%s';
                  
            else  %no field tag - add to output 

               %define output format
               fstr = '%s';

               if strcmp(lastfield,'%K')
                  str = [', ',str]; %comma delimiter for keywords
               else
                  str = [' ',str];  %space delimiter for other fields
               end
               
            end
            
         else  %empty row
            
            %define output
            fstr = '\r\n';
            
         end
         
         %write out string buffer with appropriate format string
         fprintf(fid2,fstr,str);
         
         %get next line
         str = fgetl(fid);
         
      end
      
      %add terminal return
      fprintf(fid2,'\r\n');
      
      %close files
      fclose(fid2);     
      fclose(fid);
      
      msg = ['successfully cleaned ',fn];
      
   else
      msg = 'an error occurred opening files';
   end
   
else
   msg = 'insufficient arguments for function';
end