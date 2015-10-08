function index = search_index(pn,index,option,subdir,flagcols,fn_index)
%Generates a search index for 'search_data' by inspecting all MATLAB files in the specified directories
%
%syntax: index = search_index(pn,index,option,subdir,flagcols,fn_index)
%
%inputs:
%  pn = pathnames to evaluate (default = pwd)
%  index = existing index structure to modify (variable 'index' in fn_index if omitted)
%  option = optional index management command
%    'rebuild' = generate a new index and overwrite any existing index file of the same name
%    'refresh' (default) = refresh existing index by removing missing files and adding/updating
%       index information for new or updated files (matched by path, filename, variablename)
%    'minimal' = generate a minimal index containing paths, files, variables, titles
%  subdir = option to recurse subdirectories below pn
%  flagcols = option to instantiate flag columns before indexing:
%    '' = do not instantiate
%    'auto' = 'M' for data sets with text columns, otherwise 'E' (default)
%    'M' for multiple text flag columns after the corresponding data column (if flags defined)
%    'MD' same as 'M', except text flags are displayed for all data/calculation columns
%    'MD+' same as 'MD', except text flags are also displayed for non-data, non-calculation columns if assigned
%    'MC' same as 'M', except text flags are displayed for all columns
%    'MA' for multiple text flag columns appended after the data columns
%    'MAD' same as 'MA', except text flags are displayed for all data/calculation columns
%    'MAD+' same as 'MD', except text flags are also displayed for non-data, non-calculation columns if assigned
%    'MAC' same as 'MA', except text flags are displayed for all columns
%    'E' for multiple encoded flag columns after the corresponding data column (if flags defined)
%    'ED' same as 'E', except encoded flags are displayed for all data/calculation columns
%    'ED+' same as 'ED', except encoded flags are also displayed for non-data, non-calculation columns if assigned
%    'EC' same as 'E', except encoded flags are displayed for all columns
%    'EA' for multiple encoded flag columns appended after the data columns
%    'EAD' same as 'EA', except encoded flags are displayed for all data/calculation columns
%    'EAD+' same as 'EAD', except encoded flags are displayed non-data, non-calculation columns if assigned
%    'EAC' same as 'EA', except encoded flags are displayed for all columns
%  fn_index = filename for saving the index to disk in the GCE Toolbox directory
%    (index not saved as a file if omitted)
%
%outputs:
%  index = search index structure, containing the fields:
%    'path' = directory path for structure file
%    'filename' = name of structure file
%    'filedate' = date file was lasted modified
%    'varname' = MATLAB variable name in the file
%    'author' = author list
%    'taxa' = array of taxonomic names
%    'keywords' = array of keywords
%    'columns' = array of column names
%    'units' = array of column units
%    'variabletypes' = array of column variabletypes
%    'descriptions' = array of column descriptions
%    'records' = number of records (i.e. data rows)
%    'date_public' = public release date
%    'date_start' = starting date of observations (MATLAB serial date number)
%    'date_end' = ending date of observations (MATLAB serial date number)
%    'sites' = array of GCE study sites and/or transects covered by the observations
%    'wboundlon' = west bounding longitude (decimal degrees, -180 to 180)
%    'eboundlon' = east bounding longitude (decimal degrees, -180 to 180)
%    'sboundlat' = south bounding latitude (decimal degrees, -90 to 90)
%    'nboundlat' = north bounding latitude (decimal degrees, -90 to 90)
%    [metadata fields] = various metadata text fields defined in 'search_data.mat'
%
%(c)2002-2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 25-Mar-2015

curpath = pwd;

%validate input, supply defaults for omitted parameters
if exist('index','var') ~= 1
   index = [];
end

if exist('pn','var') ~= 1
   pn = {curpath};
elseif ischar(pn)
   pn = {pn};
end
pn = unique(pn);  %remove redundant path entries to avoid search duplicates

if exist('fn_index','var') ~= 1
   fn_index = '';
elseif ~isempty(fn_index)  %strip off leading path, force .mat extension
   [fn_path,fn_base,fn_ext] = fileparts(fn_index);
   if ~strcmpi(fn_ext,'.mat')
      fn_ext = '.mat';
   end
   fn_index = [fn_base,fn_ext];
end

if exist('option','var') ~= 1
   option = 'refresh';
elseif ~strcmp(option,'rebuild') && ~strcmp(option,'minimal')
   option = 'refresh';
end

if strcmp(option,'minimal')
   fullindex = 0;
else
   fullindex = 1;  %set full index flag
end

if exist('subdir','var') ~= 1
   subdir = 1;  %set subdirectory recursion flag
end

if exist('flagcols','var') ~= 1
   flagcols = 'auto';
end

%try to load index from user-specified file if file already exists
if isempty(index) && ~isempty(fn_index)
   if exist(fn_index,'file') == 2
      vars = load(fn_index,'-mat');
      if isfield(vars,'index')
         index = vars.index;
      end
   end
end

%validate existing cache entries in specified directories, remove any invalid or out of date file entries
%retaining any entries from non-indexed directories
if strcmp(option,'refresh') && ~isempty(index)
   Ival = ones(length(index),1);
   for n = 1:length(pn)
      Ipn = find(strcmp({index.path},pn{n}));
      for m = 1:length(Ipn)
         rec = Ipn(m);
         pn_test = index(rec).path;
         if ~strncmp(pn_test,'http',4) && ~strncmp(pn_test,'ftp',3)
            d = dir([pn_test,filesep,index(rec).filename]);
            if length(d) ~= 1
               Ival(rec) = 0;  %remove missing files from index
            elseif ~strcmp(d.date,index(rec).filedate)
               Ival(rec) = 0;  %remove outdated files from index
            end
         end
      end
   end
   Ival = find(Ival);
   if isempty(Ival)
      index = [];
   else
      index = index(Ival);
   end
end

%init metadata text field array for index creation/populating
s_metafields = [];
if exist('search_data.mat','file') == 2
   try
      v = load('search_data.mat');
   catch
      v = struct('null','');
   end
   if isfield(v,'metafields')
      s_metafields = v.metafields;  %overwrite defaults with stored values
   end
end
if isempty(s_metafields)
   %array of metadata text fields to index: field, description, search_type, index_type, metadata_sections
   metafields = {'Title','Title Text','contains','minimal',{'Dataset','Title'}; ...
         'Abstract','Abstract Text','contains','full',{'Dataset','Abstract'}; ...
         'Methods','Methods Text','contains','full',{'Study','Methods'}; ...
         'Study','Study Text','contains','full',{'Study','Description';'Study','Sampling'}; ...
         'CoreArea','Core Area','contains','full',{'Dataset','LTERCore';'Dataset','Themes'}; ...
         'Accession','Accession','starts','minimal',{'Dataset','Accession'}};
else  %convert from structure form to array
   metafields = [{s_metafields.Field}',{s_metafields.Label}',{s_metafields.SearchType}', ...
         {s_metafields.IndexType}',{s_metafields.MetaFields}'];
end
if fullindex == 0  %remove full-index only fields
   Iminimal = find(strcmp(metafields(:,4),'minimal'));
   if ~isempty(Iminimal)
      metafields = metafields(Iminimal,:);
   else
      metafields = [];
   end
end

%init index if empty, otherwise cache info for duplicate checking
if strcmp(option,'rebuild') || isempty(index)
   index = struct('path','', ...
      'filename','', ...
      'filedate','', ...
      'varname','', ...
      'author','', ...
      'taxa',[], ...
      'keywords',[], ...
      'columns',[], ...
      'units',[], ...
      'datatypes',[],...
      'variabletypes',[], ...
      'descriptions',[], ...
      'records',[], ...
      'date_public',[], ...
      'date_start',[], ...
      'date_end',[], ...
      'sites',[], ...
      'wboundlon',[], ...
      'eboundlon',[], ...
      'sboundlat',[], ...
      'nboundlat',[]);
   for n = 1:size(metafields,1)
      index.(lower(metafields{n,1})) = '';
   end
   idx = 0;
   oldpn = '';
   oldfn = '';
else  %extract arrays of existing paths, files, variables for dupe check
   if ~isfield(index,'descriptions')
      for n = 1:length(index)
         index(n).descriptions = index(n).columns;  %add column name array as descriptions if not present
      end
   end
   if ~isfield(index,'datatypes')
      for n = 1:length(index)
         index(n).datatypes = repmat({'unspecified'},length(index(n).columns),1);  %add unmatched data type
      end
   end
   idx = length(index);
   oldpn = {index.path}';
   oldfn = {index.filename}';
end

%search through all directories
for n = 1:length(pn)

   pn_temp = clean_path(pn{n});

   if isdir(pn_temp)  %check for valid directory

      fn_all = [];

      if subdir == 0
         d = dir([pn_temp,filesep,'*.mat']);
         if ~ispc  %include files with upper case extensions on unix/mac systems with case-sensitive filenames
            d2 = dir([pn_temp,filesep,'*.MAT']);
            d = [d ; d2];
         end
         if ~isempty(d)
            fn = {d.name}';
            fn_date = {d.date}';
            %form full pathname,filename to match recurse_files
            fn_all = concatcellcols([repmat({pn_temp},length(fn),1),fn],filesep);
         end
      else  %recurse subdirectories to build file list
         if ~ispc
            filemask = {'*.mat','*.MAT'};  %include files with upper case extensions on unix/mac systems with case-sensitive filenames
         else
            filemask = {'*.mat'};
         end
         filelst = recurse_files(pn_temp,filemask);
         if ~isempty(filelst)
            fn_all = concatcellcols(filelst(:,1:2),filesep);
            fn_date = filelst(:,3);
         end
      end

      %check for no files condition
      if ~isempty(fn_all)

         %evaluate all .mat files
         for m = 1:length(fn_all)

            if fix(m/50)*50 == m; drawnow; end  %issue drawnow every 50 files to minimize screen lockups

            dupe = 0;  %init duplicate check flag

            fn = fn_all{m};

            %parse path, filename from full file
            [pn_base,fn_base,fn_ext] = fileparts(fn);
            fn_base = [fn_base,fn_ext];

            %check for existing match if option = 'refresh'
            %(note: file modification already evaluated by file date, so indexing skipped prior to variable test)
            if ~isempty(oldpn)
               if ~isempty(find(strcmp(oldpn,pn_base) & strcmp(oldfn,fn_base)))
                  dupe = 1;  %already indexed
               end
            end

            %index variable if not already indexed
            if dupe == 0

               try
                  vars = load(fn,'-mat');
               catch
                  vars = [];
               end

               if isstruct(vars)

                  flds = fieldnames(vars);

                  for v = 1:length(flds)

                     varname = flds{v};

                     data = vars.(varname);

                     if gce_valid(data,'data')  %check if valid GCE Data Structure

                        idx = idx + 1;  %increment index record counter

                        %instantiate flag columns
                        if ~isempty(flagcols)
                           if strcmp(flagcols,'auto')
                              if isempty(find(strcmp(data.datatype,'s')))
                                 flagcols = 'E';
                              else
                                 flagcols = 'M';
                              end
                           end
                           switch flagcols
                              case 'E'
                                 data = flags2cols(data,'mult',0,0,1,1);
                              case 'ED'
                                 data = flags2cols(data,'alldata',0,0,1,1);
                              case 'ED+'
                                 data = flags2cols(data,'mult+data',0,0,1,1);
                              case 'EC'
                                 data = flags2cols(data,'all',0,0,1,1);
                              case 'EA'
                                 data = flags2cols(data,'mult',0,0,0,1);
                              case 'EAD'
                                 data = flags2cols(data,'alldata',0,0,0,1);
                              case 'EAD+'
                                 data = flags2cols(data,'mult+data',0,0,0,1);
                              case 'EAC'
                                 data = flags2cols(data,'all',0,0,0,1);
                              case 'M'
                                 data = flags2cols(data,'mult',0,0,1,0);
                              case 'MD'
                                 data = flags2cols(data,'alldata',0,0,1,0);
                              case 'MD+'
                                 data = flags2cols(data,'mult+data',0,0,1,0);
                              case 'MC'
                                 data = flags2cols(data,'all',0,0,1,0);
                              case 'MA'
                                 data = flags2cols(data,'mult',0,0,0,0);
                              case 'MAD'
                                 data = flags2cols(data,'alldata',0,0,0,0);
                              case 'MAD+'
                                 data = flags2cols(data,'mult+data',0,0,0,0);
                              case 'MAC'
                                 data = flags2cols(data,'all',0,0,0,0);
                           end
                        end

                        %determine study dates
                        if fullindex == 1
                           date_start = NaN;
                           date_end = NaN;
                           dt = get_studydates(data);  %call external function to retrieve dates
                           if iscell(dt)
                              try
                                 dt = datenum(char(dt));
                              catch
                                 dt = [];
                              end
                           end
                           if ~isempty(dt)
                              dt = dt(~isnan(dt));  %remove any NaNs before performing calcs
                              if ~isempty(dt)
                                 date_start = min(dt);
                                 date_end = max(dt);
                              end
                           else  %try to look up dates in metadata
                              try
                                 date_start = datenum(lookupmeta(data,'Study','BeginDate'));
                                 if isempty(date_start); date_start = NaN; end
                              catch
                                 date_start = NaN;
                              end
                              try
                                 date_end = datenum(lookupmeta(data,'Study','EndDate'));
                                 if isempty(date_end); date_end = NaN; end
                              catch
                                 date_end = NaN;
                              end
                           end
                        else
                           date_start = NaN;
                           date_end = NaN;
                        end

                        %call subfunction to lookup study site info from lat/lon or site columns
                        if fullindex == 1
                           [sitelist,wboundlon,eboundlon,sboundlat,nboundlat] = sub_lookupsites(data);
                        else
                           sitelist = [];
                           wboundlon = NaN;
                           eboundlon = NaN;
                           sboundlat = NaN;
                           nboundlat = NaN;
                        end

                        %retrieve taxonomic info from value codes section of metadata
                        taxa = [];
                        if fullindex == 1
                           codes = lookupmeta(data,'Data','ValueCodes');
                           ar_codes = splitstr(codes,'|');
                           if ~isempty(ar_codes)
                              for n_codes = 1:length(ar_codes)
                                 [var,rem] = strtok(ar_codes{n_codes},':');
                                 if ~isempty(strfind(lower(var),'species'))  %look for any attribute name containing "species"
                                    [codenames,codevalues] = splitcodes(rem(3:end),',');
                                    if ~isempty(codevalues)
                                       taxa = [taxa ; codevalues];  %append to list of taxonomic names
                                    end
                                 end
                              end
                           end
                        end

                        %retrieve author name from metadata
                        author = '';
                        if fullindex == 1
                           authorstr = lookupmeta(data,'Dataset','Investigator');
                           if ~isempty(authorstr)
                              author = strtok(authorstr,'|');  %grab author as first line
                              if strncmpi(author,'name: ',6)
                                 if length(author) > 6
                                    author = author(7:end);
                                 else
                                    author = '';
                                 end
                              end
                           end
                        end

                        %parse public release data from metadata
                        date_public = NaN;
                        if fullindex == 1
                           date_publicstr = lookupmeta(data,'Status','PublicRelease');
                           if ~isempty(date_publicstr)
                              try
                                 date_public = datenum(date_publicstr);
                              catch
                                 date_public = NaN;
                              end
                           end
                        end

                        %retrieve keywords from metadata
                        keywords = [];
                        if fullindex == 1
                           str = lookupmeta(data,'Dataset','Keywords');
                           if ~isempty(str)
                              keywords = splitstr(str,',');
                           end
                        end

                        %grab column names, units, datatypes, variabletypes, descriptions
                        columns = [];
                        units = [];
                        datatypes = [];
                        variabletypes = [];
                        descriptions = [];
                        if fullindex == 1
                           columns = data.name';
                           units = data.units';
                           datatypes = strrep(strrep(strrep(strrep(data.datatype','e','exponential'),'d','integer'),'f','floating-point'),'s','string');
                           variabletypes = data.variabletype';
                           descriptions = data.description';
                        end

                        %determine records
                        records = NaN;
                        if fullindex == 1
                           if ~isempty(data.values)
                              records = length(data.values{1});
                           end
                        end

                        %perform general metadata field lookups based on info in metafields array
                        for cnt = 1:size(metafields,1)
                           metafield = lower(metafields{cnt,1});
                           lookupfields = metafields{cnt,5};
                           metastr = '';
                           for cnt2 = 1:size(lookupfields,1)
                              str = lookupmeta(data,lookupfields{cnt2,1},lookupfields{cnt2,2});
                              if ~isempty(str)
                                 metastr = [metastr,' ',str];
                              end
                           end
                           if length(metastr) > 1
                              metastr = metastr(2:end);  %trim leading blank
                           else
                              metastr = '';
                           end
                           index(idx).(metafield) = metastr;
                        end

                        %populate static index fields
                        index(idx).path = pn_base;
                        index(idx).filename = fn_base;
                        index(idx).filedate = fn_date{m};
                        index(idx).varname = varname;
                        index(idx).author = author;
                        index(idx).taxa = taxa;
                        index(idx).keywords = keywords;
                        index(idx).columns = columns;
                        index(idx).units = units;
                        index(idx).datatypes = datatypes;
                        index(idx).variabletypes = variabletypes;
                        index(idx).descriptions = descriptions;
                        index(idx).records = records;
                        index(idx).date_public = date_public;
                        index(idx).date_start = date_start;
                        index(idx).date_end = date_end;
                        index(idx).sites = sitelist;
                        index(idx).wboundlon = wboundlon;
                        index(idx).eboundlon = eboundlon;
                        index(idx).sboundlat = sboundlat;
                        index(idx).nboundlat = nboundlat;

                     end
                  end
               end
            end
         end
      end
   end
end

if ~isempty(index(1).filename)
   if ~isempty(fn_index)
      pn_tools = fileparts(which('search_datasets'));  %get working path for GCE toolbox
      save([pn_tools,filesep,fn_index],'index')  %save index
   end
else  %remove dummy entries and return empty structure
   index = [];
end


%--------------
%sub-functions
%--------------

%subfunction for looking up GCE site codes based on lat/lon/utm or numeric/string codes
function [sitelist,wboundlon,eboundlon,sboundlat,nboundlat] = sub_lookupsites(data)

sitelist = [];
wboundlon = NaN;
eboundlon = NaN;
sboundlat = NaN;
nboundlat = NaN;

%try geographic lookups first to get all relevant polygons in the database
[lon,lat] = lookup_coords(data);

if ~isempty(lon) && ~isempty(lat)

   Ivalid = find(~isnan(lon(:)) & ~isnan(lat(:)));

   if ~isempty(lon) && ~isempty(lat)
      sitelist = unique(match_sites(lon(Ivalid),lat(Ivalid),'all','unique'));
      wboundlon = min(lon);
      eboundlon = max(lon);
      sboundlat = min(lat);
      nboundlat = max(lat);
   end

else  %look up based on site and/or transect columns

   %load geographic database tables for lookups
   polygons = [];
   locations = [];
   if exist('geo_polygons.mat','file') == 2
      v = load('geo_polygons.mat');
      if isfield(v,'polygons')
         polygons = v.polygons;
      end
   end
   if exist('geo_locations.mat','file') == 2
      v = load('geo_locations.mat');
      if isfield(v,'locations')
         locations = v.locations;
      end
   end

   %look for site column
   sitecol = find(strcmpi(data.name,'site'));
   if ~isempty(sitecol)
      sites = unique(extract(data,sitecol));
      if ~isempty(sites)
         if isnumeric(sites)
            if ~isempty(polygons)  %try to lookup sitecodes
               for n = 1:length(sites)
                  Imatch = find([polygons.SiteNumber] == sites(n));
                  if ~isempty(Imatch)
                     sitelist = [sitelist ; {polygons(Imatch(1)).SiteCode}];
                  end
               end
               sitelist = unique(sitelist);
            else  %convert numeric site codes to string site codes (e.g. 1 to GCE1)
               sitestr = strjust(num2str(int2str(sites)),'left');
               sitelist = cellstr([repmat('GCE',size(sitestr,1),1),sitestr]);
            end
         else
            sitelist = sites;
         end
      end
   end

   %look for transect column
   transectcol = find(strcmpi(data.name,'transect'));
   if ~isempty(transectcol)
      transects = extract(data,transectcol);
      if iscell(transects)
         transects = unique(transects);
         sitelist = [sitelist ; transects];
      end
   end

   %clean up matched site list
   if ~isempty(sitelist)
      Ivalid = find(~cellfun('isempty',sitelist));
      if ~isempty(Ivalid)
         sitelist = sitelist(Ivalid);  %remove empty matches
      else
         sitelist = [];
      end
   else  %try to parse sites from metadata
      metastr = lookupmeta(data,'Site','Location');
      if ~isempty(metastr)
         arsites = splitstr(metastr,'|');
         if ~isempty(arsites)
            for n = 1:length(arsites)
               site = strtok(arsites{n},' ');
               if ~isempty(site)
                  sitelist = [sitelist ; {site}];
               end
            end
         end
      end
   end

   %try to look up bounding polygons from GCE geographic database tables
   if ~isempty(sitelist) && ~isempty(polygons)
      wboundlon = inf;
      eboundlon = -inf;
      sboundlat = inf;
      nboundlat = -inf;
      for n = 1:length(sitelist)
         Imatch = find(strcmp({polygons.SiteCode},sitelist{n}));
         if ~isempty(Imatch)  %grab bounding polygons from site database
            wboundlon = min(wboundlon,polygons(Imatch(1)).WBoundLon);
            eboundlon = max(eboundlon,polygons(Imatch(1)).EBoundLon);
            sboundlat = min(sboundlat,polygons(Imatch(1)).SBoundLat);
            nboundlat = max(nboundlat,polygons(Imatch(1)).NBoundLat);
         elseif ~isempty(locations)  %try to lookup point locations
            Imatch = find(strcmpi({locations.Location},sitelist{n}));
            if ~isempty(Imatch)
               Imatch = Imatch(1);
               wboundlon = locations(Imatch).Longitude;
               eboundlon = wboundlon;
               sboundlat = locations(Imatch).Latitude;
               nboundlat = sboundlat;
            end
         end
      end
      if wboundlon == inf; wboundlon = NaN; end
      if eboundlon == -inf; eboundlon = NaN; end
      if sboundlat == inf; sboundlat = NaN; end
      if nboundlat == -inf; nboundlat = NaN; end
   end

   %try to parse geographic coordinates from metadata strings if all lookups fail
   if isnan(wboundlon) || isnan(eboundlon) || isnan(nboundlat) || isnan(sboundlat)
      str = lookupmeta(data,'Site','Coordinates');  %get coordinate string from metadata
      if ~isempty(str)
         wboundlon = inf;
         eboundlon = -inf;
         sboundlat = inf;
         nboundlat = -inf;
         str = strrep(strrep(strrep(strrep(str,'NW: ',''),'SW: ',''),'NE: ',''),'SE: ',''); %remove geo corner labels
         ar = splitstr(str,'|');  %split compound coordinates on pipes
         for n = 1:length(ar)
            str = ar{n};
            Idash = strfind(str,'-');  %check for site labels based on dash separator
            if ~isempty(Idash)
               if max(Idash) < length(str)
                  str = str(max(Idash)+1:end);  %strip all leading text based on last dash
               else
                  str = '';
               end
            end
            if ~isempty(str)
               %check for West, North, East, South labels for resolving coordinate hemispheres
               if ~isempty(strfind(str,'W')) || ~isempty(strfind(str,'N')) || ~isempty(strfind(str,'E')) || ~isempty(strfind(str,'S'))
                  str = strrep(strrep(strrep(str,'°',' '),'''',' '),'"',' ');  %strip degree, min, sec symbols
                  ar2 = splitstr(str,',');  %split on commas
                  if length(ar2) ~= 2
                     ar2 = splitstr(str,'/');  %try splitting by slash
                     if length(ar2) ~= 1
                        ar2 = splitstr(str,';');  %try splitting by semicolon
                     end
                  end
                  if length(ar2) == 2  %check for 2 coordinate strings
                     lonstr = '';
                     latstr = '';
                     lonmult = 1;  %init longitude hemisphere sign multiplier
                     latmult = 1;  %init latitude hemisphere sign multiplier
                     for m = 1:2
                        cstr = ar2{m};
                        if ~isempty(strfind(cstr,' W'))  %W longitude
                           lonmult = -1;
                           lonstr = strrep(cstr,' W','');
                        elseif ~isempty(strfind(cstr,' N')) %N latitude
                           latstr = strrep(cstr,' N','');
                        elseif ~isempty(strfind(cstr,' E'))  %E longitude
                           lonstr = strrep(cstr,' E','');
                        elseif ~isempty(strfind(cstr,' S'))  %S latitude
                           latmult = -1;
                           latstr = strrep(cstr,' S','');
                        end
                     end
                     if ~isempty(lonstr) && ~isempty(latstr)
                        %calculate longitude in decimal degrees
                        lon = 0;  %init numeric lon
                        cnt = 0;  %init term counter
                        while ~isempty(lonstr)
                           [str,lonstr] = strtok(lonstr,' ');
                           cnt = cnt + 1;
                           if cnt <= 3  %check for excess components/unrecognized format
                              lon = lon + abs((str2double(str) ./ 60^(cnt-1)));  %add next component converted to dec. degrees
                           else
                              lon = 0;
                              break
                           end
                        end
                        %calculate latitude in decimal degrees
                        lat = 0;  %init numeric lat
                        cnt = 0;
                        while ~isempty(latstr)
                           [str,latstr] = strtok(latstr,' ');
                           cnt = cnt + 1;
                           if cnt <= 3  %check for excess components/unrecognized format
                              lat = lat + abs((str2double(str) ./ 60^(cnt-1))); %add next component converted to dec. degrees
                           else
                              lat = 0;
                              break
                           end
                        end
                        if lon > 0 && lat > 0  %check for valid coordinate pair
                           %apply hemisphere signs
                           lon = lon .* lonmult;
                           lat = lat .* latmult;
                           wboundlon = min(wboundlon,lon);
                           eboundlon = max(eboundlon,lon);
                           sboundlat = min(sboundlat,lat);
                           nboundlat = max(nboundlat,lat);
                        end
                     end
                  end
               end
            end
         end
         if wboundlon == inf; wboundlon = NaN; end
         if eboundlon == -inf; eboundlon = NaN; end
         if sboundlat == inf; sboundlat = NaN; end
         if nboundlat == -inf; nboundlat = NaN; end
      end
   end

end
