function new_index = index2httpindex(index,pn,url,gce_sendfile,accession,pubdate)
%Replaces specified file paths in a search index structure with urls for indexing web-hosted data sets
%
%syntax: new_index = index2httpindex(index,pn,url,gce_sendfile,accession,pubdate)
%
%inputs:
%  index = search index structure to modify (see 'search_index')
%  pn = array of physical file paths to replace
%  url = array of base urls to substitute for pn strings (must match pn)
%  gce_sendfile = option to prepend GCE send_file.asp script parameters to filenames
%    0 = no (default)
%    1 = yes
%  accession = option to parse accession from filename
%    0 = no (default)
%    1 = yes
%  pubdate = public release date cut-off (default = now, NaN = any)
%
%outputs:
%  new_index = modified search index
%
%
%(c)2004-2011 by Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 08-Sep-2011

new_index = [];

if nargin >= 3

   %supply defaults for omitted arguments
   if exist('pubdate') ~= 1
      pubdate = now;
   end

   if exist('gce_sendfile') ~= 1
      gce_sendfile = 0;
   end

   %validate index
   if isstruct(index)
      if ~isfield(index,'path')
         index = [];
      end
   else
      index = [];
   end

   if ischar(pn)
      pn = cellstr(pn);
   end

   if ischar(url)
      url = cellstr(url);
   end

   %check for valid index & matched pn/url
   if length(pn) == length(url) & ~isempty(index)

      %remove non-public data sets from index if date specified
      if ~isnan(pubdate)
         Ipublic = find([index.date_public]' <= pubdate);
         if ~isempty(Ipublic)
            index = index(Ipublic);
         else
            index = [];
         end
      end

      if ~isempty(index)

         %init path, filename arrays
         pn_all = {index.path}';
         fn_all = {index.filename}';
         acc_all = {index.accession}';
         pn_new = pn_all;
         fn_new = fn_all;
         Imatches = [];

         for n = 1:length(pn)

            old_pn = pn{n};
            len = length(old_pn);

            Imatch = find(strncmp(old_pn,pn_all,length(old_pn)));
            if ~isempty(Imatch)
               Imatches = [Imatches ; Imatch];  %add to match index
               for m = 1:length(Imatch)
                  Irec = Imatch(m);
                  pn_new{Irec} = [url{n},strrep(pn_all{Irec}(len+1:end),'\','/')];
                  if gce_sendfile == 1
                     for cnt = 1:length(Irec)
                        fn = fn_all{Irec(cnt)};
                        if accession == 1
                           acc = strtok(fn,'_');
                        else
                           acc = acc_all{Irec(cnt)};
                        end
                        fn_new{Irec(cnt)} = ['send_file.asp?name=[username]&email=[useremail]&affiliation=[useraffiliation]&notify=[usernotify]&accession=', ...
                              acc,'&filename=',fn];
                     end
                  end
               end
            end
         end

         %apply match index to filter out non-matched entries
         new_index = index(Imatches);
         pn_new = pn_new(Imatches);
         fn_new = fn_new(Imatches);

         %update path, filename contents
         [new_index.path] = deal(pn_new{:});
         [new_index.filename] = deal(fn_new{:});

         %check for accession duplicates, remove entries for older file versions
         [tmp,Isort] = sortrows({new_index.filename}');
         new_index = new_index(Isort);

         if accession == 1

            [tmp,Isort] = sortrows({new_index.accession}');
            new_index = new_index(Isort);

            all_acc = {new_index.accession}';
            all_fn = {new_index.filename}';
            Ilatest = ones(length(new_index),1);  %init index of latest files

            for n = 2:length(Isort)
               if strcmp(all_acc(n),all_acc(n-1))
                  [tmp,Isort] = sortrows(all_fn(n-1:n));
                  if Isort(2) == 2
                     Ilatest(n-1) = 0;
                  else
                     Ilatest(n) = 0;
                  end
               end
            end

            new_index = new_index(find(Ilatest));

         end

      end

   end

end