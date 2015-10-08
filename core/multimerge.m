function [s,msg,fn_bad] = multimerge(filelist,structnames,mergetype,fixflags,metamerge,addfilename,flagopt,flagchars)
%Merges (concatenates) multiple GCE Data Structures specified by filename and structure name
%
%syntax: [s,msg] = multimerge(filelist,structnames,mergetype,fixflags,metamerge,addfilename,flagopt,flagchars)
%
%inputs:
%  filelist = cell array containing a list of filenames (fully-qualified or relative)
%  structnames = matching cell array of data structure names (default = array of 'data')
%  mergetype = type of merge to perform:
%    'order' = merge in order specified (default)
%    'date' = merge by study date (from data set or metadata)
%    'datetrim' = merge time series, deleting overlapping records from earlier structures
%    'datetrim2' = merge time series, deleting overlapping records from newer structures
%  fixflags = option to fix flags prior to merging data sets by adding 'manual'
%     to each Q/C criteria string to prevent inappropriate automatic reflagging
%     0 = do not fix (default)
%     1 = fix
%  metamerge = metadata sections to merge
%     'all' = all sections (default)
%     'none' = no metadata sections (except data column metadata)
%     'pick' = option to select metadata sections from a list
%     1 or 2 column cell array = sections or sections/fields to merge
%  addfilename = option to add a filename column to each merged data set
%     0 = no/default
%     1 = yes
%  flagopt = option to remove flagged values or records containing flagged values prior to
%        merging data sets
%     '' = do not remove (default)
%     'null' = use 'nullflags' function to NaN flagged values
%     'cull' = use 'cullflags' function to remove rows containing any flagged values
%  flagchars = flag characters to null/cull
%     '' = any flags
%     character array = list of specific flags to null (e.g. 'I' or 'IQ')
%
%outputs:
%  s = merged data structure
%  msg = text of any errors
%  fn_bad = cell array of files and could not be merged due to validation or merge errors
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
%last modified: 09-Oct-2010

s = [];
msg = '';
fn_bad = [];

if nargin >= 1

   %valid file list array
   if iscell(filelist) && size(filelist,1) > 1
      
      numfiles = size(filelist,1);
      
      %set default flagchars option if omitted
      if exist('flagchars','var') ~= 1
         flagchars = '';
      end
      
      %set default flagopt if omitted
      if exist('flagopt','var') ~= 1
         flagfunction = '';
      else
         switch flagopt
            case 'null'
               flagfunction = 'nullflags';
            case 'cull'
               flagfunction = 'cullflags';
            otherwise
               flagfunction = '';
         end
      end
      
      %set default array of structure names if omitted or replicate scalar name
      if exist('structnames','var') ~= 1  
         structnames = [];
      end
      if isempty(structnames)
         structnames = repmat({'data'},numfiles,1);
      elseif ischar(structnames)
         structnames = repmat({structnames},numfiles,1);  %replicate scalar name
      end
      
      %validate structure name array
      if length(structnames) == numfiles
         
         %set defaults for omitted inputs
         if exist('addfilename','var') ~= 1
            addfilename = 0;
         end
         
         calcdates = 0;
         if exist('mergetype','var') ~= 1
            mergetype = 'order';
         elseif ~strcmp(mergetype,'order')
            calcdates = 1;
         end
         
         if exist('fixflags','var') ~= 1
            fixflags = 0;
         end
         
         if exist('metamerge','var') ~= 1
            metamerge = 'all';
         end
         
         %init runtime vars
         s_all = cell(numfiles,1);
         s_startdates = repmat(NaN,numfiles,1);
         fn_good = [];
         fn_bad = [];
         fn_base_all = [];
         
         for n = 1:length(filelist)
            
            fn = filelist{n};

            if exist(fn,'file') == 2
            
               try
                  vars = load(fn,'-MAT');
               catch
                  vars = struct('null','');
               end
               
               if isfield(vars,structnames{n})
                  
                  data = vars.(structnames{n});
                  
                  if gce_valid(data,'data')
                     
                     [tmp,fn_base] = fileparts(fn);
                     data = addmeta(data,{'Dataset','Accession',fn_base},1);

                     %add filename column at beginning of data set if specified
                     if addfilename == 1
                        data2 = addcol(data,fn_base, ...
                           'DataSetName', ...
                           'none', ...
                           'Names of the original data sets merged to create the composite data set', ...
                           's', ...
                           'nominal', ...
                           'none', ...
                           0, ...
                           '', ...
                           0);                        
                        if ~isempty(data2)
                           data = data2;
                        end
                     end

                     s_all{n} = data;
                     
                     fn_good = [fn_good ; {fn}];
                     [tmp,fn_base] = fileparts(fn);
                     fn_base_all = [fn_base_all,{fn_base}];
                     
                     if calcdates == 1
                        dt = get_studydates(data);
                        startdate = [];
                        if ~isempty(dt)
                           startdate = min(dt(~isnan(dt)));
                        else
                           dt_str = lookupmeta(data,'Study','BeginDate');
                           if ~isempty(dt_str)
                              startdate = datenum(dt_str);
                           end
                        end
                        if ~isempty(startdate)
                           s_startdates(n) = startdate;
                        end
                     end
                     
                  else
                     fn_bad = [fn_bad ; {fn}];
                  end
               else
                  fn_bad = [fn_bad ; {fn}];
               end
            else
               fn_bad = [fn_bad ; {fn}];
            end
         end
         
         Ivalid = find(~cellfun('isempty',s_all));
         if ~isempty(Ivalid)
            s_all = s_all(Ivalid);
            s_startdates = s_startdates(Ivalid);
         else
            s_all = [];
            s_startdates = [];
         end
         
         if calcdates == 1
            s_startdates(isnan(s_startdates)) = now;  %set missing date vals to today's date to append at end
            [tmp,Iorder] = sort(s_startdates);
            s_all = s_all(Iorder);  %apply ordering to cached data structures
         end
         
         %perform merge if two or more valid structures
         if length(s_all) >= 2
            
            %init output with first structure
            s = s_all{1};      

            %check for option to pick metadata sections from a list
            if ~iscell(metamerge)
               if strcmp(metamerge,'pick')
                  if ~isempty(s.metadata)
                     metastr = concatcellcols(s.metadata(:,1:2),'_');
                     Isel = listdialog('liststring',metastr, ...
                        'selectionmode','multiple', ...
                        'promptstring','Select metadata sections to merge', ...
                        'name','Import Metadata', ...
                        'listsize',[0 0 280 500]);
                     if ~isempty(Isel)
                        if length(Isel) < size(s.metadata,1)
                           metamerge = s.metadata(Isel,1:2);
                        else
                           metamerge = 'all';
                        end
                     else
                        metamerge = 'none';
                     end
                  end                             
               end
            end
            
            %perform concatenations
            for n = 2:length(s_all)
            
               s2 = s_all{n};
               
               %process metadata selections
               if iscell(metamerge)
               
                  %build index of matching fields to retain
                  meta = s2.metadata;
                  metarows = size(metamerge,1);
                  Ikeep = zeros(size(meta,1),1);
                  
                  if size(metamerge,2) == 2
                     for m = 1:metarows
                        Imatch = find(strcmp(meta(:,1),metamerge{m,1}) & strcmp(meta(:,2),metamerge{m,2}));
                        if ~isempty(Imatch)
                           Ikeep(Imatch) = 1;
                        end
                     end
                  else
                     for m = 1:metarows
                        Imatch = find(strcmp(meta(:,1),metamerge{m,1}));
                        if ~isempty(Imatch)
                           Ikeep(Imatch) = 1;
                        end
                     end
                  end
                  
                  Iclear = find(~Ikeep);  %create index of fields to clear by inversion
                  meta(Iclear,3) = repmat({''},length(Iclear),1);  %clear unselected fields
                  s2.metadata = meta;
                  
               elseif strcmp(metamerge,'none')
                  
                  %buffer title
                  titlestr = lookupmeta(s2,'Dataset','Title');
                  meta = s2.metadata;
                  Ititle = find(strcmp(meta(:,1),'Dataset') & strcmp(meta(:,2),'Title'));
                  meta(:,3) = repmat({''},size(meta,1),1);  %clear all value fields
                  if ~isempty(Ititle)  
                     meta{Ititle(1),3} = titlestr;  %restore title field
                  end
                  s2.metadata = meta;
                  
               end
               
               %perform selected merge
               if strcmp(mergetype,'datetrim')
                  [s_tmp,msg2] = merge_by_date(s,s2,[],[],fixflags,0,'older');
               elseif strcmp(mergetype,'datetrim2')
                  [s_tmp,msg2] = merge_by_date(s,s2,[],[],fixflags,0,'newer');
               else  %order or date
                  [s_tmp,msg2] = datamerge(s,s2,1,1,1,fixflags,0);
               end
               
               %validate merged data structure
               if ~isempty(s_tmp)
                  s = s_tmp;
                  s_tmp = [];
               else
                  fn_bad = [fn_bad ; fn_good(n)];  %add fn to list of bad files
               end
               
            end
            
            %perform post-merge flag removal, Q/C flag updating
            if ~isempty(s)
               s = newtitle(s,['Merged data from ',cell2commas(fn_base_all,1)]);
               if ~isempty(flagfunction) %perform requested flag removal (and update Q/C flags)
                  try
                     s_tmp = feval(flagfunction,s,flagchars);
                  catch
                     s_tmp = [];
                  end
                  if ~isempty(s_tmp)
                     s = s_tmp;
                  else
                     s = dataflag(s);  %just update Q/C flags
                  end
               else
                  s = dataflag(s);  %just update Q/C flags
               end
            end
            
            %generate error message if necessary
            if ~isempty(fn_bad)
               if strncmp(mergetype,'datetrim',8)
                  msg2 = ' (e.g. completely overlapping dates or no overlapping columns)';
               else
                  msg2 = ' (e.g. no overlapping columns)';
               end
               if length(fn_bad) > 1
                  msg = [int2str(length(fn_bad)),' files were invalid or could not be merged',msg2];
               else
                  msg = ['1 file was invalid or could not be merged',msg2];
               end
            end
                           
         else
            
            if isempty(s_all)
               msg = 'no valid data structures to merge - cancelled';
            else
               msg = 'two or more valid data structures required for merge';
            end
            
         end
         
      else
         msg = 'invalid structure name array';
      end
      
   else
      msg = 'invalid file list array';
   end
   
end