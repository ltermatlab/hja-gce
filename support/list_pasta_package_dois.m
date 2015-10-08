function s = list_pasta_package_dois(scopes,identifiers, revisions,baseurl)
%Lists DOIs for specified data packages in the LTER data portal
%
%syntax: s = list_pasta_package_dois(scopes,identifiers, revisions,baseurl)
%
%input:
%  scopes = site scopes (cell array of strings or character array; required)
%  identifiers = array of data set identifiers (integer; required)
%  revisions = array of data set revisions for each identifier (integer; required)
%  baseurl = PASTA base url (string; optional; default = 'http://pasta.lternet.edu/package/')
%
%output:
%  s = struct containing fields:
%     'scope' = site scope
%     'identifier' = data package identifer
%     'revision' = data package revision
%     'doi' = data package doi (empty string if package not found)
%
%(c)2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 02-Oct-2013

s = [];

if nargin >= 3 && ~isempty(scopes) && ~isempty(identifiers) && ~isempty(revisions)
   
   %validate identifiers and revisions arrays
   if isnumeric(identifiers) && isnumeric(revisions) && length(identifiers) == length(revisions)
      
      %convert scope string to cell array
      if ischar(scopes)
         scopes = cellstr(scopes);
      end
      
      %replicate scope array to match identifiers
      if iscell(scopes) && length(scopes) == 1
         scopes = repmat(scopes,length(identifiers),1);
      end
      
      %check for matching scope and identifiers
      if iscell(scopes) && length(scopes) == length(identifiers)
         
         %validate url
         if exist('baseurl','var') ~= 1
            baseurl = 'http://pasta.lternet.edu/package/';
         elseif ~strcmp(baseurl(end),'/')
            baseurl = [baseurl,'/'];
         end

         %init identifiers
         dois = repmat({''},length(identifiers),1);
         
         %init struct
         s = cell2struct([scopes,num2cell(identifiers),num2cell(revisions),dois], ...
            {'scope','identifier','revision','doi'},2);
         
         %loop through packages looking up dois
         for n = 1:length(s)
            
            url = [baseurl,'doi/eml/',s(n).scope,'/',int2str(s(n).identifier),'/',int2str(s(n).revision)];
            
            html = urlread(url);
            
            if strncmpi(html,'doi',3)
               s(n).doi = html;
            end
            
         end
         
      end
      
   end
   
end