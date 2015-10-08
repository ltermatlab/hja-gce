function filelist = recurse_files(pn,filemask,filemask_exclude,filelist)
%Recursively builds a list of all files in a directory and subdirectories matching a filename pattern
%optionally excluding files with names that match a second string pattern
%
%syntax: filelist = recurse_files(pn,filemask,filemask_exclude)
%
%inputs:
%  pn = starting pathname (default = pwd)
%  filemask = cell or character array of filemasks to match (default = '*.mat')
%  filemask_exclude = cell or character array of filemasks to exclude from the results (default = '')
%     (note: do not include wildcard characters or string comparisons will fail)
%
%outputs:
%  filelist = cell array of pathnames, filenames and file dates matching 'filemask'
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

%init filelist for first iteration
if exist('filelist','var') ~= 1
   filelist = [];
end

%set default path if omitted
if exist('pn','var') ~= 1
   pn = '';
end
if isempty(pn)
   pn = pwd;
elseif strcmp(pn(end),filesep)
   pn = pn(1:end-1);  %strip terminal file separator from path
end

if exist(pn,'dir') == 7

   %set default exclude filter if omitted
   if exist('filemask_exclude','var') ~= 1
      filemask_exclude = [];
   else
      if ischar(filemask_exclude)
         filemask_exclude = cellstr(filemask_exclude);  %convert char to cell array
      end
   end

   %set default filemask if omitted
   if exist('filemask','var') ~= 1
      if ispc
         filemask = {'*.mat'};  %set Windows default
      else
         filemask  = {'*.mat','*.MAT'};  %set case-sensitive Unix default
      end
   elseif ischar(filemask)  %convert char to cell array
      filemask = cellstr(filemask);
   end

   %init filelist if not provided
   if exist('filelist','var') ~= 1
      filelist = [];
   end

   %init temporary array
   templist = [];

   %loop through each filemask, add matching paths, files, file dates, applying exclusion filters
   for n = 1:length(filemask)

      %get directory structure for current level
      d = dir([pn,filesep,filemask{n}]);

      if ~isempty(d)

         %get array of file names
         fn = {d.name}';

         %init filename index, excluding directory names and aliases (i.e. '.' and '..')
         Ivalid = ~strncmp(fn,'.',1) & ~strncmp(fn,'..',2) & [d.isdir]' == 0;

         %evaluate exclusions
         if ~isempty(filemask_exclude)  %evalulate all exclusion filters
            for m = 1:length(filemask_exclude)
               pad = blanks(length(filemask_exclude{m}));  %add padding to filename to prevent reverse string matches
               for cnt = 1:length(fn)
                  if ~isempty(strfind([fn{cnt},pad],filemask_exclude{m}))
                     Ivalid(cnt) = 0;  %string found = zero index record
                  end
               end
            end
         end

         %apply index to remove excluded files
         Ivalid = find(Ivalid);
         if ~isempty(Ivalid)
            templist = [templist ; repmat({pn},length(Ivalid),1),fn(Ivalid),{d(Ivalid).date}'];  %add matches to list
         end

      end

   end

   %remove duplicate entries from temp array
   if length(filemask) > 1 & ~isempty(templist)
      [tmp,Iunique] = unique(templist(:,2));  %get index of unique filenames
      if ~isempty(Iunique)
         templist = templist(Iunique,:);
      else
         templist = [];
      end
   end

   %add new entries to cumulative array
   filelist = [filelist ; templist];

   %call function recursively to process any subdirectories
   d = dir(pn);
   Isub = find([d.isdir]==1 & ~strncmp({d.name},'.',1) & ~strncmp({d.name},'..',2));  %exclude '.' and '..' aliases
   for n = 1:length(Isub)
      filelist = recurse_files([pn,filesep,d(Isub(n)).name],filemask,filemask_exclude,filelist);  %call function recursively
   end

end