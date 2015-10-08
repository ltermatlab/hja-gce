function ar = list_pasta_packages(scope,baseurl)
%Lists package identifiers and latest revisions for data packages in the LTER data portal
%
%syntax: ar = list_pasta_packages(scope,baseurl)
%
%input:
%  scope = site scope (e.g. 'knb-lter-gce')
%  baseurl = PASTA base url (string; default = 'http://pasta.lternet.edu/package/eml/')
%
%output:
%  ar = 2-column numeric array of packageIds and revisions
%
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
%last modified: 01-Apr-2013

ar = [];

if nargin >= 1 && ~isempty(scope)
   
   %validate url
   if exist('baseurl','var') ~= 1
      baseurl = 'http://pasta.lternet.edu/package/eml/';
   elseif ~strcmp(baseurl(end),'/')
      baseurl = [baseurl,'/'];
   end
   
   %perform initial query
   url = [baseurl,scope];   
   str = urlread(url);
   
   if ~isempty(str)
      
      %parse integers from string into cell array
      c = textscan(str,'%d');
      
      if ~isempty(c)
         
         %extract array of integer ids
         ids = c{1};
         
         %get number of packages
         num = length(ids);
         
         %init output arrays
         ar = [ids zeros(num,1)];
         
         %loop through packages looking up latest revisions
         for cnt = 1:num
            
            %generate url for package
            url2 = [url,'/',int2str(ids(cnt))];
            
            %read url
            str = urlread(url2);

            %parse revisions
            c = textscan(str,'%d');
            
            %add latest revision to output array
            if ~isempty(c)
               revs = c{1};
               ar(cnt,2) = max(revs);
            end
            
         end
         
      end
      
   end
      
end