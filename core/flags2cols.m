function [s2,msg] = flags2cols(s,flagcols,clearopt,missing,pos,encode,prefix,firstflag)
%Converts Q/C flags in a GCE Data Structure to coded string or integer columns in the data set
%
%syntax: [s2,msg] = flags2cols(s,flagcols,clearopt,missing,pos,encode,prefix,firstflag)
%
%inputs:
%  s = the data structure to modify
%  flagcols = flag column arrangement option:
%     array of column names or index numbers = create flag columns for the specified data columns
%     'mult' = create a separate flag column for each column with flagged values (default)
%     'alldata' = create a flag column following every column assigned variable type
%        'data' or 'calculation' regardless of whether flags are assigned
%     'mult+data' = same as alldata, except any flags assigned in non-data, non-calc columns
%        will also be instantiated as coded columns
%     'all' = create a flag column following every column regardless of whether flags are assigned
%     'single' = create a single compound flag column named [prefix]AllColumns (e.g. Flag_AllColumns)
%        with entries for any column with flags assigned separted by ampersands
%        (e.g. Salinity=Q&Temperature=IQ&...)
%  clearopt = flag clearing option:
%     0 = retain flag criteria and flag values (default)
%     1 = delete existing flags and flag criteria
%  missing = missing value option:
%     0 = do not add additional criteria to flag missing values (default)
%     1 = flag missing values as 'M' and include in flag column(s)
%  pos = position of flag columns
%     0 = append all flag columns after the data columns
%     1 = add each flag column after the corresponding data column (default)
%  encode = encode flags as integers and update the flag codes in the documentation
%     0 = do not encode flags (default)
%     1 = encode flags as unique integers (0 = no flag) and document codes in the metadata
%  prefix = prefix to add to column name to denote flag column (string, default = 'Flag_')
%  firstflag = option to only convert the first-assigned flag (automatic if 'encode' is 1)
%     0 = no (default)
%     1 = yes
%
%output:
%  s2 = the resultant structure
%  msg = text of any error messages
%
%notes:
%   1) encode is set to 0 automatically if 'flagcols' = single
%   2) existing columns named [prefix][column] (e.g. Flag_Salinity, ...) will be deleted
%      to support updating static flag columns; specify a distinct prefix if this
%      column deletion is not desired
%   3) if flagcols = 'alldata', flags for non-data, non-calculation columns will not be displayed
%      (use 'mult+data' to ensure all assigned flags are represented)
%
%(c)2002-2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 18-Nov-2014

%initialize output
s2 = [];
msg = '';

%check for required arguments
if nargin >= 1
   
   %default to not encoding flags
   if exist('encode','var') ~= 1
      encode = 0;
   elseif ischar(encode)
      encode = 0;
   end
   
   %default to displaying all flags unless encoding option specified
   if encode == 1
      firstflag = 1;
   elseif exist('firstflag','var') ~= 1
      firstflag = 0;
   elseif firstflag ~= 1
      firstflag = 0;
   end
   
   %default to adding flags adjacent to data columns
   if exist('pos','var') ~= 1
      pos = 1;
   elseif ischar(pos)
      pos = 1;
   end
   
   %default to not adding flags for missing values
   if exist('missing','var') ~= 1
      missing = 0;
   end
   
   %default to not clearing criteria
   if exist('clearopt','var') ~= 1
      clearopt = 0;
   elseif ischar(clearopt)
      clearopt = 0;
   end
   
   %default to multiple flags
   if exist('flagcols','var') ~= 1
      flagcols = 'mult';
   elseif ischar(flagcols)
      if ~inlist(flagcols,{'single','mult','all','alldata','mult+data'})
         flagcols = 'mult';
      elseif strcmp(flagcols,'single')
         encode = 0;  %override encoding setting for single compound flag col
      end
   end
   
   %assign default prefix
   if exist('prefix','var') ~= 1 || ~ischar(prefix) || isempty(prefix)
      prefix = 'Flag_';
   end
   
   %check for valid data structure
   if gce_valid(s,'data')
      
      %generate array of columns to instantiate flags for based on flagopt and dataset contents
      if ischar(flagcols)
         switch flagcols
            case 'all'  %all columns
               cols = 1:length(s.name);
            case 'alldata'  %all data/calculation columns
               vtype = get_type(s,'variabletype');
               cols = find(inlist(vtype,{'data','calculation'}))';
            case 'mult+data'  %all columns with flags assigned plus all data/calculation columns
               vtype = get_type(s,'variabletype');
               cols = unique([find(~cellfun('isempty',s.flags)) , find(inlist(vtype,{'data','calculation'}))']);
            otherwise  %multiple or single options - only columns with flags
               cols = find(~cellfun('isempty',s.flags));
         end
      else
         if isnumeric(flagcols)
            cols = intersect(flagcols,(1:length(s.name)));  %validate array of column numbers
         else
            cols = name2col(s,flagcols);  %look up column names
         end
         flagcols = 'specifed';  %reset flagcols option for string tests
      end
      
      %check for columns to process
      if ~isempty(cols)
         
         %delete prior flag columns for specified data columns if present
         colnames = s.name(cols);  %buffer original column names for re-generating cols after deletion
         oldflagcols = concatcellcols([repmat({prefix},length(cols)+1,1),[s.name(cols),{'AllColumns'}]'])';
         s = deletecols(s,oldflagcols);
         
         %regenerate column list based on revised data structure
         cols = name2col(s,colnames);
         numcols = length(cols);
         
         if ~isempty(s) && numcols > 0
            
            %get number of data rows
            numrows = length(s.values{1});
            
            %init output structure
            s2 = s;
            
            %check for multiple flag column option
            if ~strcmp(flagcols,'single')
               
               %init runtime vars
               newcols = cell(1,numcols);
               newnames = newcols;
               newdesc = newcols;
               newunits = repmat({'none'},1,numcols);
               newvartype = repmat({'code'},1,numcols);
               
               %look up and parse flag codes to build definition array
               flagcodes = lookupmeta(s,'Data','Codes');
               if ~isempty(flagcodes)
                  if ~isempty(strfind(flagcodes,'|'))
                     flagarray = splitstr(flagcodes,'|');
                  else
                     flagarray = splitstr(flagcodes,',');
                  end
               else
                  %supply GCE default flags if not defined
                  flagarray = {'Q = questionable value' ; ...
                     'I = invalid value' ; ...
                     'E = estimated value'};
               end
               if missing == 1
                  flagarray = [flagarray ; {'M = missing value'}];
               end
               
               %init arrays of attribute descriptors, flag values
               if encode == 0
                  newdatatype = repmat({'s'},1,numcols);
                  newnumtype = repmat({'none'},1,numcols);
                  dummycol = repmat({''},numrows,1);
               else
                  newdatatype = repmat({'d'},1,numcols);
                  newnumtype = repmat({'discrete'},1,numcols);
                  dummycol = zeros(numrows,1);
               end
               newprec = zeros(1,numcols);
               newcrit = repmat({''},1,numcols);
               flaglist = repmat({''},numcols,1);
               
               %init loop vars
               newpos = [];
               str = '';
               
               %loop through columns, build attribute metadata descriptors for flag values
               for n = 1:numcols
                  
                  col = cols(n);  %get structure column pointer
                  newpos = [newpos,col+.5];  %add position marker for pos = 1
                  flags = s.flags{col}; %get assigned flags
                  newnames{n} = [prefix,s.name{col}];  %generate flag column name
                  
                  %generate missing flags if necessary
                  if missing == 1
                     
                     %get column values
                     vals = s.values{col};
                     
                     %get index of missing values
                     if isnumeric(vals)
                        Imissing = isnan(vals);
                     else
                        Imissing = cellfun('isempty',vals);
                     end
                     
                     %update flags
                     if ~isempty(Imissing)
                        
                        %generate array of missing value flags
                        newflags = repmat(' ',numrows,1);
                        newflags(Imissing,1) = 'M';
                        
                        %update column flags
                        if isempty(flags)
                           flags = newflags;
                        else
                           %add column of M flags and compress spaces
                           flags = char(trimstr(cellstr([flags,newflags])));
                        end
                        
                     end          
                     
                  end
                  
                  %generate column description including flag criteria
                  if missing == 0
                     newdesc{n} = ['QA/QC flags for ',s.description{col}, ...
                        ' (flagging criteria, where "x" is ',s.name{col},': ',strrep(strrep(strrep(s.criteria{col},'col_',''),';',', '),'''','"'),')'];
                  elseif strcmp(s.datatype{col},'s')
                     newdesc{n} = ['QA/QC flags for ',s.description{col}, ...
                        ' (flagging criteria, where "x" is ',s.name{col},': ',strrep(strrep(strrep(s.criteria{col},'col_',''),';',', '),'''','"'), ...
                        ', cellfun("isempty",x)="M")'];
                  else
                     newdesc{n} = ['QA/QC flags for ',s.description{col}, ...
                        ' (flagging criteria, where "x" is ',s.name{col},': ',strrep(strrep(strrep(s.criteria{col},'col_',''),';',', '),'''','"'), ...
                        ', isnan(x)="M")'];
                  end
                  
                  %generate flag column value array
                  if isempty(flags)
                     
                     %add dummy column for no flags
                     newcols{n} = dummycol;
                     
                     %add no flag definition
                     if encode == 1
                        %generate dummy definition with leader for encoded flags,
                        %because all unflagged values will be assigned 0
                        str = ', 0 = no flag';
                     else
                        str = '';
                     end
                     
                  elseif encode == 1
                     
                     %assign dummy 0 flag definition with leader
                     str = ', 0 = no flag';
                     
                     %encode flags as unique integers, using flag definition array to ensure cross-column consistency
                     if ~isempty(flags)
                        [flagnums,newlist,flagstr] = sub_encodeflags(flags,flagarray);
                     else
                        flagnums = [];  %no flags assigned
                     end
                     
                     %update flag code definitions with output from subfunction
                     if ~isempty(flagnums)
                        newcols{n} = flagnums;
                        if ~isempty(flagarray)
                           str = [str,', ',flagstr];
                        else
                           for m = 1:length(newlist)
                              str = [str,', ',newlist{m},' = unspecified'];
                           end
                        end
                     else
                        newcols{n} = dummycol;
                     end
                     
                  else  %instantiate text flags
                     
                     %convert flags to cell array
                     if isempty(flags)
                        newcols{n} = repmat({''},numrows,1);
                     elseif firstflag == 1
                        newcols{n} = cellstr(flags(:,1));
                     else
                        newcols{n} = cellstr(flags);
                     end
                     
                     %get index of non-empty flag rows
                     Ivalid = find(~cellfun('isempty',newcols{n}));
                     
                     if ~isempty(Ivalid)
                        
                        %get unique list of flags assigned
                        newlist = unique(newcols{n}(Ivalid));
                        
                        %form unique list of individual flags if >1 assigned
                        if firstflag == 0
                           newlist = unique(cellstr([newlist{:}]'));
                        end
                        
                        %check for undefined flags, add unspecified definition
                        str = '';  

                        if ~isempty(flagarray)                           
                           flagarraychar = char(flagarray);
                           flagarraycomp = cellstr(flagarraychar(:,1));                           
                           for m = 1:length(newlist)
                              Iflagitem = find(strcmp(flagarraycomp,newlist{m}));
                              if isempty(Iflagitem)
                                 tmp = [newlist{m},' = unspecified'];
                                 flagarray = [flagarray ; {tmp}];
                                 flagarraycomp = [flagarraycomp ; newlist(m)];
                                 str = [str,', ',newlist{m},' = unspecified'];
                              else
                                 flagnum = cols(1);
                                 str = [str,', ',flagarray{Iflagitem(1)}];
                              end
                           end                           
                        else                           
                           for m = 1:length(newlist)
                              str = [str,', ',newlist{m},' = unspecified'];
                           end
                        end
                        
                     end
                     
                  end
                  
                  %add updated info to flag definitions
                  if ~isempty(str)
                     flaglist{n} = [prefix,s.name{col},': ',str(3:end)];
                  end
                  
               end

               %append flag columns to structure
               s2.name = [s.name,newnames];
               s2.units = [s.units,newunits];
               s2.description = [s.description,newdesc];
               s2.datatype = [s.datatype,newdatatype];
               s2.variabletype = [s.variabletype,newvartype];
               s2.numbertype = [s.numbertype,newnumtype];
               s2.precision = [s.precision,newprec];
               s2.criteria = [s.criteria,newcrit];
               s2.flags = [s.flags,repmat({''},1,numcols)];
               s2.values = [s.values,newcols];
               
               %buffer history
               str_hist = s.history;
               
               %clear original flags, criteria if specified
               if clearopt == 1
                  tmp = repmat({''},1,length(cols));
                  s2.flags(cols) = tmp;
                  s2.criteria(cols) = tmp;
               end
               
               %reorder columns to put flags after values if pos == 1
               if pos == 1
                  allcols = (1:length(s.name));
                  if ~strcmp(flagcols,'all')
                     [tmp,Isort] = sort([allcols,newpos]);
                  else
                     [tmp,Isort] = sort([allcols,allcols+0.5]);
                  end                  
                  s2 = copycols(s2,Isort);  %apply re-ordering
               end
               
               %update history (skipping reordering step)               
               if length(cols) > 1
                  histstr = 'flags for columns ';
               else
                  histstr = 'flags for column ';
               end
               
               %update code list in metadata
               if ~isempty(flaglist)
                  
                  %parse and amend flag definitions
                  valcodes = lookupmeta(s,'Data','ValueCodes');
                  if ~isempty(valcodes)
                     ar = splitstr(valcodes,'|');
                     if length(ar) == 1
                        if strncmp('no',ar{1},2) == 1  %check for 'none' or 'not specified'
                           ar = [];
                        end
                     end
                  else
                     ar = [];
                  end
                  ar = [ar ; flaglist];
                  
                  %update dataset metadata
                  s2 = addmeta(s2,[{'Data'},{'ValueCodes'},{cell2pipes(ar,0,'',0,1)}],1);
                  
                  %generate history entry
                  if encode == 1
                     s2.history = [str_hist; {datestr(now)} {[histstr,cell2commas(s.name(cols),1), ...
                        ' converted to encoded data columns, flag codes updated in metadata (''flags2cols'')']}];
                  else
                     s2.history = [str_hist; {datestr(now)} {[histstr,cell2commas(s.name(cols),1), ...
                        ' converted to data columns, flag codes updated in metadata (''flags2cols'')']}];
                  end
                  
               else
                  
                  %no new flags - just update history
                  s2.history = [str_hist; ...
                     {datestr(now)} {[histstr,cell2commas(s.name(cols),1),' converted to data columns (''flags2cols'')']}];
                  
               end
               
            else  %create single flag column
               
               %init flag column
               flagvals = repmat({''},numrows,1);
               
               %add attribute metadata for combined flag column
               s2.name = [s.name,{[prefix,'AllColumns']}];
               s2.units = [s.units,{'none'}];
               s2.description = [s.description,{'QA/QC flags'}];
               s2.datatype = [s.datatype,{'s'}];
               s2.variabletype = [s.variabletype,{'text'}];
               s2.numbertype = [s.numbertype,{'none'}];
               s2.precision = [s.precision,0];
               s2.criteria = [s.criteria,{''}];
               s2.flags = [s.flags,{''}];
               
               %loop through columns with flags assigned
               for n = 1:numcols
                  
                  %get column index
                  col = cols(n);
                  
                  %get column name, flags
                  colname = s.name{col};
                  flags = s.flags{col};
                  
                  if ~isempty(flags)
                     
                     %get index of non-empty flags
                     Ivalid = find(flags(:,1)~=' ');
                     
                     %append flag assignments to combined column
                     for m = 1:length(Ivalid)
                        
                        %get existing combined flag string
                        str = flagvals{Ivalid(m)};
                        
                        %append new flag assignment
                        if isempty(str)
                           newstr = [colname,'=',deblank(flags(Ivalid(m),:))];
                        else
                           newstr = [str,'&',colname,'=',deblank(flags(Ivalid(m),:))];
                        end
                        
                        %update combined string
                        flagvals{Ivalid(m)} = newstr;
                        
                     end
                     
                  end
                  
               end
               
               %add value array containing combined flags
               s2.values = [s.values,{flagvals}];
               
               %update processing history
               s2.history = [s.history; {datestr(now)}, ...
                  {'all data column flags converted to a composite string column ''Flags_AllColumns'' (''flags2column'')'}];
               
               %clear flags, criteria if specified
               if ~isempty(s2) && clearopt == 1
                  tmp = repmat({''},1,length(cols));
                  s2.flags(cols) = tmp;
                  s2.criteria(cols) = tmp;
               end
               
            end
            
         end
         
      else  %no flag columns to process
         
         %return original structure
         s2 = s;
         
         %generate appropriate error message
         if ischar(flagcols) && strcmp(flagcols,'alldata') || strcmp(flagcols,'specified')
            msg = 'invalid column selection';
         else
            msg = 'no flags were assigned in any of the specified data columns';
         end
         
      end
      
   else
      msg = 'invalid GCE data structure';
   end
   
else
   msg = 'insufficient arguments for function';
end


%subfunction to encode flags
function [flagvals,flaglist,flagstr] = sub_encodeflags(flags,flagarray)

%init output
flagvals = [];
flaglist = '';
flagstr = '';

%get index of non-empty flags
Ivalid = find(flags(:,1)~=' ');

if ~isempty(Ivalid)
   
   %generate comparison arrays
   usedflags = cellstr(flags(Ivalid,1));
   flaglist = unique(usedflags);
   flagvals = zeros(size(flags,1),1);
   flagarraychar = char(flagarray);
   flagarraycomp = cellstr(flagarraychar(:,1));
   flagstr = '';
   
   %generate encoded integer flags and flag code definitions for each unique set of original flags
   for n = 1:length(flaglist)
      Iflag = find(strcmp(flagarraycomp,flaglist{n}));
      if isempty(Iflag)
         tmp = [flaglist{n},' = unspecified'];
         flagarray = [flagarray ; {tmp}];
         flagarraycomp = [flagarraycomp ; {flaglist{n}}];
         flagnum = length(flagarray);
         flagstr = [flagstr,', ',int2str(flagnum),' = unspecified'];
      else
         flagnum = Iflag(1);
         flagstr = [flagstr,', ',int2str(flagnum),' = ',deblank(strrep(flagarraychar(Iflag(1),:),'= ','(')),')'];
      end
      Iused = strcmp(flaglist{n},usedflags);
      flagvals(Ivalid(Iused)) = flagnum;
   end
   
   %remove leading equal sign and spaces from flag definition string
   if ~isempty(flagstr)
      flagstr = flagstr(3:end);
   end
   
end