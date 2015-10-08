function [s2,msg] = fill_meta_tokens(s,sections)
%Replaces tokens in metadata templates with text from the corresponding metadata fields
%(e.g. [Study_BeginDate] in Dataset_Title replaced with contents of Study_BeginDate metadata field)
%
%syntax: [s2,msg] = fill_meta_tokens(s,sections)
%
%inputs:
%  s = GCE data structure to modify
%  sections = nx2 array of metadata sections to evaluate (default = {'Dataset','Title';'Dataset','Abstract'})
%
%output:
%  s2 = updated GCE data structure
%  msg = text of any error message
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
%last modified: 07-Sep-2011

s2 = [];
msg = '';

if nargin >= 1

   if gce_valid(s,'data')

      if exist('sections','var') ~= 1
         sections = [];
      end

      if isempty(sections)
         sections = {'Dataset','Title';'Dataset','Abstract'};
      end

      if size(sections,2) == 2

         s2 = s;

         for n = 1:size(sections,1)

            str0 = lookupmeta(s,sections{n,1},sections{n,2});
            str = str0;
            flds = [];

            if ~isempty(str)

               I_start = strfind(str,'[');
               if ~isempty(I_start)
                  I_end = strfind(str,']');
                  if length(I_end) == length(I_start)
                     for m = 1:length(I_start)
                        tkn = str(I_start(m)+1:I_end(m)-1);
                        if length(strfind(tkn,'_')) == 1
                           flds = [flds ; {tkn}];
                        end
                     end
                  end
               end

               if ~isempty(flds)
                  for m = 1:length(flds)
                     tkn = ['[',flds{m},']'];
                     metaflds = splitstr(flds{m},'_');
                     str2 = lookupmeta(s,metaflds{1},metaflds{2});
                     str = strrep(str,tkn,str2);
                  end
               end

               if strcmp(str0,str) ~= 1
                  s2 = addmeta(s2,[sections(n,1:2),{str}]);
                  if strcmp(sections{n,1},'Dataset') & strcmp(sections{n,2},'Title')
                     s2.title = str;  %update dataset title if metadata title updated
                  end
               end

            end

         end

      else
         msg = 'invalid metadata section array';
      end

   else
      msg = 'invalid data structure';
   end

else
   msg = 'insufficient arguments for function';
end