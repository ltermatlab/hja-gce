function tablerows = htmltable2cell(html,emptycells,urls,base_url)
%Parses table structures from HTML text to return a cell array of contents
%
%syntax: tablerows = htmltable2cell(html,emptycells,urls,base_url)
%
%input:
%   html = html text from 'urlread' or an nx1 cell array of strings
%   emptycells = option to include empty cells (0 = no/default, 1 = yes)
%   urls = option to retain hyperlinks as labels plus URLs in parentheses
%      (0 = no/default, 1 = yes)
%   base_url = base url for expanding relative hyperlinks (default = '' for none)
%
%output:
%   tablerows = cell array of parsed table rows
%
%
%(c)2012 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 29-Aug-2012

%init output
tablerows = [];

%check for required input
if nargin >= 1 && (ischar(html) || iscell(html))
   
   %set default emptycells option
   if exist('emptycells','var') ~= 1
      emptycells = 0;
   end
   
   %set default urls option
   if exist('urls','var') ~= 1
      urls = 0;
   end
   
   %set default baseurl option
   if exist('base_url','var') ~= 1
      base_url = '';
   end
   
   %parse html into an array, splitting elements on line feeds
   if ischar(html)
      ar = splitstr(html,char(10),1,1);
   else
      ar = html;  %use pre-parsed html array
   end
   
   %validate parsed array
   if ~isempty(ar) && size(ar,1) > 1 && size(ar,2) == 1
      
      %strip out explicit html styling elements and replace escaped characters
      ar = strrep(ar,'&nbsp;',' ');  %replace non-breaking space character references
      ar = strrep(ar,'&ndash;','-');  %replace dash character references
      ar = regexprep(ar,'<br\/?>',', ','ignorecase');  %remove line breaks, replace with comma
      ar = regexprep(ar,'<\/?[bi]{1}>','','ignorecase');   %remove bold or italic tags
      ar = regexprep(ar,'<\/?font[^>]*>','','ignorecase');   %remove legacy font tags
      
      %handle anchor tags
      if urls == 0
         
         %remove anchor tags entirely
         ar = regexprep(ar,'<\/?a{1}[^>]*>','','ignorecase');
         
      else
         
         %convert relative to absolute links if base url specified
         if ~isempty(base_url)
            ar = regexprep(ar,'(<\s*a\s+[^>]*href\s*=\s*[\"''])(?!http)([^\"''>]+)([\"''>]+)', ...
               ['<a href="',base_url,'/$2$3'],'ignorecase');
            ar = regexprep(ar,['href="',base_url,'\/\/'],['href="',base_url,'\/']);  %remove double slash
         end
         
         %convert anchor tags to urls in parentheses after labels
         ar = regexprep(ar,'<a href="([^"]*)"([^>]*)>([^<]*)</a>','$3 ($1)','ignorecase');
         
      end
      
      %convert to character array
      str = [ar{:}];
      
      %get index of opening table row
      Ioprow = strfind(str,'<tr');
      Iclrow = [Ioprow(2:end)-1,length(str)];  %set default row close index to text between row start tags
      
      if ~isempty(Ioprow)
         
         %init array for table rows
         tablerows = cell(length(Ioprow),1);
         
         %loop through rows
         for n = 1:length(Ioprow);
            
            %get content position indices
            Istart = Ioprow(n) + 3;
            Iendrow = strfind(str(Istart:Iclrow(n)),'</tr>');
            if ~isempty(Iendrow)
               Iend = Istart + Iendrow + 3;
            else
               Iend = Iclrow(n) - 1;  %use remainder of string up to next row start tag
            end
            
            %extract content from master string
            seg = str(Istart:Iend);
            Iopcell = strfind(seg,'<td');
            Iclcell = strfind(seg,'</td>');
            
            %extract cell contents, add to array
            if ~isempty(Iopcell) && length(Iopcell) == length(Iclcell)
               tblcells = cell(1,length(Iopcell));
               for m = 1:length(Iopcell);
                  Istartc = Iopcell(m);
                  Iendc = Iclcell(m)+4;
                  if Iendc > Istartc
                     seg2 = seg(Istartc:Iendc);  %get entire table cell including tags
                     fld = regexprep(seg2,'<[^>]+[>]{1}','');  %strip all html tags from string
                     tblcells{m} = trimstr(fld);
                  end
               end
               if emptycells == 0
                  tblcells = tblcells(~cellfun('isempty',tblcells));
               end
               tablerows{n} = tblcells;
            end
            
         end
         
         %remove empty cells from array
         tablerows = tablerows(~cellfun('isempty',tablerows));
         
      end
      
   end
   
end
