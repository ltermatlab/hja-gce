function msg = endnote2fastlane(pn,fn_endnote,fn_parsed)
%Parses an Endnote export file to produce a tab-delimited file for entering pubs into Fastlane
%
%syntax: msg = endnote2fastlane(pn,fn_endnote,fn_parsed)
%
%input:
%  pn = pathname for files (default = pwd)
%  fn_endnote = filename of the EndNote export file  (default = 'GCE_Publications_Endnote.txt')
%  fn_parsed = filename for the delimited parsed file  (default = '_parsed' appended fo fn_endnote)
%
%output:
%  msg = status message
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
%last modified: 21-Sep-2010

msg = '';

if exist('pn','var') ~= 1
   pn = pwd;
end

if exist('fn_endnote','var') ~= 1
   fn_endnote = 'GCE_Publications_Endnote.txt';
end

if exist('fn_parsed','var') ~= 1
   [tmp,fn_base,fn_ext] = fileparts(fn_endnote);
   fn_parsed = [fn_base,'_parsed',fn_ext];
end

if exist([pn,filesep,fn_endnote],'file') ~= 2
   curpath = pwd;
   filespec = fn_endnote;
   fn_endnote = '';
   cd(pn)
   [fn_endnote,pn] = uigetfile(filespec,'Select an EndNote file to parse');
   cd(curpath)
   drawnow
   if fn_endnote == 0
      fn_endnote = '';
   end
end

if ~isempty(fn_endnote)
   
   ar = textfile2cell(fn_endnote,pn,0,0,0,1);
   numrows = size(ar,1);

   %open output file and write header line
   fid = fopen([pn,filesep,fn_parsed],'w');
   fprintf(fid,'RefType\tAuthors\tTitle\tEditors\tJournal/Book\tPublisher\tYear\tVolume\tPages\tDOI\tStatus\tID\r\n');
   
   Icite = find(strncmpi(ar,'%0',2));
   numcites = length(Icite);
   
   for n = 1:numcites      
      
      Istart = Icite(n);
      if n < numcites
         Iend = Icite(n+1)-1;
      else
         Iend = numrows;
      end      
      ar2 = ar(Istart:Iend);

      %init runtime vars
      titlestr = '';
      coll = '';
      pub = '';
      yr = '';
      vol = '';
      pg = '';
      doi = '';
      status = '';
      
      %parse fields
      reftype = ar2{1}; reftype = strrep(reftype(4:end),'Generic','Conference Paper');
      Iid = find(strncmp(ar2,'%M',2)); idstr = ar2{Iid(1)}(4:end);
      Iauth = find(strncmp(ar2,'%A',2)); auth = combine_names(ar2(Iauth));
      Ied = find(strncmp(ar2,'%E',2)); eds = combine_names(ar2(Ied));
      Ititle = find(strncmp(ar2,'%T',2)); if ~isempty(Ititle); titlestr = ar2{Ititle(1)}(4:end); end
      Icollection = find(strncmp(ar2,'%B',2)); if ~isempty(Icollection); coll = ar2{Icollection(1)}(4:end); end
      Ipublisher = find(strncmp(ar2,'%I',2)); if ~isempty(Ipublisher); pub = ar2{Ipublisher(1)}(4:end); end
      Iyr = find(strncmp(ar2,'%D',2));  if ~isempty(Iyr); yr = ar2{Iyr(1)}(4:end); end
      Ivol = find(strncmp(ar2,'%V',2)); if ~isempty(Ivol); vol = ar2{Ivol(1)}(4:end); end
      Ipg = find(strncmp(ar2,'%P',2)); if ~isempty(Ipg); pg = ar2{Ipg(1)}(4:end); end
      Idoi = find(strncmp(ar2,'%R',2)); if ~isempty(Idoi); doi = ar2{Idoi(1)}(4:end); end
      Istatus = find(strncmp(ar2,'%Z',2));  if ~isempty(Istatus); status = ar2{Istatus(1)}(4:end); end
      
      %write delimited line to file
      fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\r\n',reftype,auth,titlestr,eds,coll, ...
         pub,yr,vol,pg,doi,status,idstr);
         
   end
   
   fclose(fid);   
   
   msg = 'successfully parsed file';
   
else
   msg = 'invalid input file';
end

return

function str = combine_names(ar)
   str = '';
   for n = 1:length(ar)
      str_tmp = ar{n};
      if length(str_tmp) > 3
         ar_tmp = splitstr(str_tmp(4:end),',');
         if length(ar_tmp) >= 2
            lastname = ar_tmp{1};
            firstname = '';
            fn = ar_tmp{2};
            ar_fn = splitstr(fn,' ');
            for m = 1:length(ar_fn)
               fn_tmp = ar_fn{m};
               firstname = [firstname,fn_tmp(1),'.'];  %just use first initials
            end
            if length(ar_tmp) >= 3
               suffix = [', ',ar_tmp{3},'; '];  %add leading comma, space and terminal semicolon
            else
               suffix = '; ';  %no suffix - just add semicolon
            end            
            str = [str,lastname,', ',firstname,suffix];  %append name to list
         end
      end
   end
   if ~isempty(str)
      str = str(1:length(str)-2);  %remove terminal semicolon
   end
return