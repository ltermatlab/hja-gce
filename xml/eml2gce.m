function [s_array,msg] = eml2gce(s_raw,fn,pn)
%Converts EML-described data retrieved using 'fetch_eml_data' to an array of GCE Data Structures
%optionally saving the structures to disk as variables named according to the EML entityName values
%
%syntax: [s_array,msg] = eml2gce(s_raw,fn,pn)
%
%input:
%  s_raw = parsed EML data structures from 'fetch_eml_data'
%  fn = filename for saving the converted structures to disk (default = '' for none)
%  pn = pathname for saving the converted structures to disk (default = [gce_homepath,filesep,'userdata'])
%
%output:
%  s_array = cell array of GCE Data Structures for each parsed data table
%  msg = text of any error message
%
%
%(c)2012-2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 21-Oct-2014

%init output variables
s_array = [];
msg = '';

%check for url input
if nargin >= 1
   
   %validate filename
   if exist('fn','var') ~= 1
      fn = '';
   end
   
   %validate path
   if exist('pn','var') ~= 1
      pn = [gce_homepath,filesep,'userdata'];
   elseif isempty(pn) || ~isdir(pn)
      pn = [gce_homepath,filesep,'userdata'];
   end
      
   %check for valid structure from 'fetch_eml_data'
   if isstruct(s_raw) && isfield(s_raw,'packageid')
      
      %init output array for gce structures
      s_array = cell(length(s_raw),1);
      num_structs = length(s_raw);
      
      %loop through data set info
      for n = 1:num_structs
         
         %get number of columns
         numcols = length(s_raw(n).names);
         
         %init data structure
         s = newstruct('data');
         
         %append entity name to title for compound data sets
         if num_structs == 1
            s = newtitle(s,s_raw(n).title);
         else
            s = newtitle(s,[s_raw(n).title,': ',s_raw(n).entity]);
         end
         
         %add attribute descriptors
         s.name = s_raw(n).names';
         s.units = s_raw(n).units';
         s.description = s_raw(n).definitions';
         s.flags = repmat({''},1,numcols);
         s.precision = zeros(1,numcols);
         
         %get codes and generate code metadata
         colnames = s_raw(n).names;
         codes = s_raw(n).codes;
         Ivalid = find(~cellfun('isempty',codes));
         if ~isempty(Ivalid)
            codelist = cell2pipes(concatcellcols([colnames(Ivalid),codes(Ivalid)],': '));
         else
            codelist = '';
         end
         
         %format contributor list
         contrib = s_raw(n).creator;
         if iscell(contrib)
            contrib = cell2pipes(trimstr(contrib));
         else
            contrib = strrep(contrib,';','|');
         end
         
         %format location and coordinate metadata
         coords = s_raw(n).geography;
         str_sites = '';
         str_coords = '';
         
         if ~isempty(coords) && size(coords,2) == 2            

            %loop through site descriptions
            for int_coord = 1:size(coords,1)
               
               %format site description
               sitedesc = coords{int_coord,1};
               if ~isempty(sitedesc)
                  sitedesc = strrep(sitedesc,' -- ',' - ');
               end
               str_sites = [str_sites, ...
                  '|Site ',int2str(int_coord),' -- ',sitedesc];
               
               %format coordinates
               coord = coords{int_coord,2};  %get coordinate array
               str_coords = [str_coords, ...
                  '|Site ',int2str(int_coord),' -- ', ...
                  '|  NW: ',num2str(coord(1,1),8),', ',num2str(coord(1,2),8), ...
                  '|  NE: ',num2str(coord(2,1),8),', ',num2str(coord(2,2),8), ...
                  '|  SE: ',num2str(coord(3,1),8),', ',num2str(coord(3,2),8), ...
                  '|  SW: ',num2str(coord(4,1),8),', ',num2str(coord(4,2),8)];
            end
         end
         
         %format taxa
         taxa = s_raw(n).taxa;
         if ~isempty(taxa)
            taxa = cell2commas(strrep(taxa,',',';'));
         else
            taxa = '';
         end
         
         %format study dates
         studydates = s_raw(n).dates;
         if iscell(studydates) && size(studydates,1) >= 2
            Istart = find(strncmp('BeginDate: ',studydates,11));
            Iend = find(strncmp('EndDate: ',studydates,9));
            if ~isempty(Istart) && ~isempty(Iend)
               begindate = studydates{Istart(1)}(12:end);
               enddate = studydates{Iend(end)}(10:end);
            end
         else
            begindate = '';
            enddate = '';
         end

         %format methods and instrumentation
         allmethods = s_raw(n).methods;
         
         if ~isempty(allmethods)
            
            %get inverse = index of all non-instrument methods lines
            Imethods = find(strncmp('method:',allmethods,7));
            num_methods = length(Imethods);
            
            %init methods and instruments arrays
            ar_methods = cell(1,num_methods);
            ar_instruments = cell(1,num_methods);
            
            for int_method = 1:num_methods
               
               %init indices
               Imethod = Imethods(int_method);  %get method index
               Iinstr = [];  %init index of corresponding instruments
               
               %check for instruments after method line prior to next method
               if int_method < num_methods
                  Inext = Imethods(int_method + 1);
                  if Inext > Imethod + 1
                     Iinstr = (Imethod+1:Inext-1);  %get index of corresponding instruments
                  end
               else
                  if Imethod + 1 < length(allmethods)
                     Iinstr = (Imethod+1:length(allmethods));
                  end
               end
               
               %generate method label
               methodlbl = ['Method ',int2str(int_method),': '];
               
               %add methods to methods array
               ar_methods{int_method} = [methodlbl,allmethods{Imethod}(9:end)];
               
               %add instruments
               ar_instruments{int_method} = methodlbl;
               if ~isempty(Iinstr)
                  for int_instr = 1:length(Iinstr)
                     instrument = allmethods{Iinstr(int_instr)};
                     instrument = trimstr(strrep(instrument,' instrument:',''));
                     ar_instruments{int_method} = [ar_instruments{int_method},'|  ',instrument]; 
                  end
               else
                  ar_instruments{int_method} = [ar_instruments{int_method},'none'];
               end
                              
            end           
            
            %generate methods and instruments character arrays
            methods = cell2pipes(trimstr(ar_methods));
            instruments = cell2pipes(trimstr(ar_instruments));
         
         else
            methods = '';
            instruments = '';
         end
         
         %add sampling description
         sampling = s_raw(n).sampling;
         if ~isempty(sampling)
            sampling = strrep(cell2pipes(trimstr(sampling)),'|','');
         else
            sampling = '';  %force empty character array
         end
         
         %parse project name and funding
         project = s_raw(n).project;
         [Istart,Iend] = regexp(project,'\(funding:.*)');
         if ~isempty(Istart)
            funding = project(Istart+10:Iend-1);
            project = project(1:Istart-2);
         else
            funding = '';
         end
         
         %format usage rights
         rights = s_raw(n).rights;
         if size(rights,1) > 1
            %convert multi-line text array to string
            rights = cell2pipes(rights);
         else
            rights = char(rights);
         end
         
         %format contact info
         contacts = s_raw(n).contact;
         if size(contacts,1) > 1
            %convert cell array to pipe-delimited string
            contacts = cell2pipes(trimstr(contacts));
         else
            contacts = char(contacts);
         end
         
         %init metadata array
         meta = {'Dataset','Accession',s_raw(n).packageid ; ...
            'Dataset','Investigator',contrib; ...
            'Dataset','Abstract',s_raw(n).abstract; ...
            'Dataset','Keywords',s_raw(n).keywords; ...
            'Project','Name',project; ...
            'Project','Funding',funding; ...
            'Site','Location',str_sites; ...
            'Site','Coordinates',str_coords; ...
            'Study','Sampling',sampling; ...
            'Study','BeginDate',begindate; ...
            'Study','EndDate',enddate; ...
            'Study','Methods',methods; ...
            'Study','Instrumentation',instruments; ...
            'Study','Species',taxa; ...
            'Status','Contact',contacts; ...
            'Status','Restrictions',rights; ...
            'Data','ValueCodes',codelist};
         
         %examine each data column to determine types and convert uint32 to double
         dtype = repmat({'u'},1,numcols);
         vtype = repmat({'unspecified'},1,numcols);
         ntype = vtype;
         vals = repmat({'NaN'},1,numcols);
         crit = repmat({''},1,numcols);
         
         if ~isempty(s_raw(n).data)
            
            %add parsed data file info
            s.datafile = {s_raw(n).filename,length(s_raw(n).data{1})};
            
            %loop through columns, determiing data type, variable type and numeric type
            for cnt = 1:length(s_raw(n).data)
               
               %get data array for column
               data = s_raw(n).data{cnt};
               dtypes = s_raw(n).datatypes{cnt};
               scale = s_raw(n).scales{cnt};
               bounds = s_raw(n).bounds{cnt};
               unit = s_raw(n).units{cnt};
               
               %check data type
               if iscell(data)
               
                  %assign string data type
                  dtype{cnt} = 's';
                  colname = s.name{cnt};
                  
                  %check for codes or standard date/time column name
                  if ~isempty(codes{cnt})
                     vtype{cnt} = 'code';  %check for coded column based on code list
                  elseif strcmp(scale,'datetime') || ~isempty(strfind(lower(colname),'date')) || ...
                        sum(inlist(colname,{'date','time','year','month','day','hour','minute','second'},'insensitive'))
                     vtype{cnt} = 'datetime';  %check for date/time column
                  elseif strcmp(dtypes,'boolean')
                     vtype{cnt} = 'logical';  %check for boolean data type (which maps to string)
                  else
                     vtype{cnt} = 'nominal';  %default to categorical/nominal
                  end
                  ntype{cnt} = 'none';
                  
                  %update values array
                  vals{cnt} = data;
               
               else  %numeric array
                  
                  %get column class and name
                  coltype = class(data);
                  colname = colnames{cnt};
                  
                  %set data type based on class
                  if strcmp(coltype,'double')
                     dtype{cnt} = 'f';
                     ntype{cnt} = 'continuous';
                  else
                     data = double(data);  %force conversion of uint32 to double
                     dtype{cnt} = 'd';
                     ntype{cnt} = 'discrete';
                  end
                  
                  %check for codes or other recognized column patterns and assign variable type automatically
                  if ~isempty(codes{cnt})
                     vtype{cnt} = 'code';  %assign code type based on code definition presence
                  elseif strcmp(scale,'datetime') || ~isempty(strfind(lower(colname),'date')) || ...
                        max(inlist(colname,{'date','time','year','month','day','hour','minute','second'},'insensitive')) > 0
                     vtype{cnt} = 'datetime';  %assign datetime based on scale or column name pattern
                  elseif strcmp(scale,'ordinal')
                     vtype{cnt} = 'ordinal';  %assign ordinal based on scale
                  elseif max(inlist(colname,{'longitude','latitude','lon','lat'},'insensitive')) > 0
                     vtype{cnt} = 'coord';  %assing coord based on column name pattern
                  elseif strcmp(scale,'interval') || strncmpi(unit,'degree',6) || ~isempty(strfind(unit,'°'))
                     ntype{cnt} = 'angular';  %override number scale for interval data with degree/degrees unit
                     vtype{cnt} = 'data';  %assign data type to interval scale values other than lat/lon
                  elseif max(inlist(colname,{'site','zone','plot','location','station'},'insensitive')) > 0
                     vtype{cnt} = 'nominal';  %assign nominal based on common categorical column names
                  else
                     vtype{cnt} = 'data';  %assign data if no other patterns matched
                  end
                  
                  %check for bounds
                  if length(bounds) > 1
                     
                     ar = splitstr(bounds,';'); %split bounds into array
                     newcrit = '';
                     
                     %loop through bounds
                     for bnd = 1:length(ar)
                        
                        %get string from array
                        str = ar{bnd};
                        
                        %convert value bounds into q/c criteria
                        if strncmp(str,'value <= ',9)
                           newcrit = [newcrit,';x>',str(10:end),'=''I'''];
                        elseif strncmp(str,'value < ',8)
                           newcrit = [newcrit,';x>=',str(9:end),'=''I'''];
                        elseif strncmp(str,'value >= ',9)
                           newcrit = [newcrit,';x<',str(10:end),'=''I'''];
                        elseif strncmp(str,'value > ',8)
                           newcrit = [newcrit,';x<=',str(9:end),'=''I'''];
                        end
                        
                     end
                     
                     %strip leading semicolon
                     if length(newcrit) > 1
                        crit{cnt} = newcrit(2:end);  
                     end
                     
                  end   
                  
                  %update values array
                  vals{cnt} = data;
                  
               end
               
            end
                  
         end
         
         %update remaining structure fields
         s.datatype = dtype;
         s.variabletype = vtype;
         s.numbertype = ntype;
         s.criteria = crit;
         s.values = vals;

         %validate structure before continuing
         val = gce_valid(s,'data');

         if val == 1
            
            %add accession, packageid and contributor to metadata
            s = addmeta(s,meta);
            
            %assign numeric type and precision automatically, not converting any numbers to exponential
            s = assign_numtype(s,0);
            
            %evaluate QA/QC criteria
            s = dataflag(s);
            
            %add structure to output cell array
            s_array{n} = s;
            
            %save to file if specified
            if ~isempty(fn)
               
               %get entity name for use as variable name
               varname = ['entity_',int2str(n)];
               
               %init temp structure for save command
               s_tmp = struct(varname,s);
               
               %create new file or append if n > 1
               if n == 1
                  try
                     save([pn,filesep,fn],'-struct','s_tmp')
                  catch  %old matlat - use eval
                     eval([varname,' = s; save([pn,filesep,fn],''',varname,''')'])
                  end                
               else
                  try
                     save([pn,filesep,fn],'-append','-struct','s_tmp')
                  catch  %old matlab - use eval
                     eval([varname,' = s; save([pn,filesep,fn],''',varname,''',''-append'')'])
                  end
               end
            end
            
         else
            
            %invalid data
            s_array{n} = [];
            msg = 'no data were retrieved for the data table or a file parsing error occurred';
            
         end
         
      end
      
   end
   
else
   msg = 'url is required';
end
