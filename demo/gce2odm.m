function [s_odm,msg,s2] = gce2odm(s,sitecode,datecol,utc_offset,missingflag,qc_level,s_varmap,s_flagmap)
%Converts a GCE Data Structure to an ODM-compatible data table
%
%syntax: [s_odm,msg,s2] = gce2odm(s,sitecode,datecol,utc_offset,missingflag,qc_level,s_varmap,s_flagmap)
%
%input:
%   s = GCE Data Structure to convert (struct; required)
%   sitecode = site code to use for matching variables (string; required)
%   datecol = name or index of column containing string or numeric dates (string or integer; default = 'Date')
%   utc_offset = UTC Offset of datecol (number; default = 0 for none)
%   missingflag = qualifier flag to assign for missing values (string; default = 'M')
%   qc_level = quality control level to assign (integer; default = 0)
%   s_varmap = GCE Data Structure or name of a .mat file containing a lookup table
%     of ODM ids for sites and variables (struct or string; default = 'odm_channel_mapping.mat')
%   s_flagmap = GCE Data Structure or name of a .mat file containing a lookup table
%     of ODM ids for qualifier flags (struct or string; default = 'odm_qualifiers.mat')
%
%output:
%  s_odm = refactored GCE Data Structure containing variables combined into a
%     DataValue column plus ODM identifiers and date columns
%  msg = text of any error message
%  s2 = refactored GCE Data Structure with original Channel name, flag codes and other
%     intermediate lookup values not supported by ODM
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
%last modified: 06-Aug-2013

s_odm = [];
s2 = [];

%check for required input
if nargin >= 2 && ischar(sitecode) && gce_valid(s,'data')
   
   %supply default datecol if omitted
   if exist('datecol','var') ~= 1
      datecol = 'Date';
   end
   
   %look up date column index
   if ~isnumeric(datecol)
      datecol = name2col(s,datecol,'insensitive');
   end
   
   %validate utc_offset and supply default if omitted
   if exist('utc_offset','var') ~= 1 || isempty(utc_offset) || ~isnumeric(utc_offset)
      utc_offset = 0;
   end
   
   %validate missingflag
   if exist('missingflag','var') ~= 1
      missingflag = '';
   end
   if isempty(missingflag) || ~ischar(missingflag)
      missingflag = 'M';
   end
   
   %validate q/c level
   if exist('qc_level','var') ~= 1
      qc_level = [];
   end
   if isempty(qc_level) || ~isnumeric(qc_level)
      qc_level = 0;
   else
      qc_level = ceil(qc_level);  %convert qc_level to next highest integer
   end
   
   %check for s_varmap
   if exist('s_varmap','var') ~= 1
      s_varmap = 'odm_channel_mapping.mat';
   end
   
   %try to load s_varmap from a file
   if ischar(s_varmap) && exist(s_varmap,'file') == 2
      try
         vars = load(s_varmap,'-mat');
      catch e
         vars = struct('null','');
         msg0 = ['error loading variable mapping file (',e.message,')'];
      end
      if isfield(vars,'data')
         s_varmap = vars.data;
      else
         s_varmap = [];
      end
   else
      s_varmap = [];
   end
   
   %check for s_flagmap
   if exist('s_flagmap','var') ~= 1
      s_flagmap = 'odm_qualifiers.mat';
   end
   
   %try to load s_flagmap from a file unless s_varmap is invalid
   if ~isempty(s_varmap) && ischar(s_flagmap) && exist(s_flagmap,'file') == 2
      try
         vars = load(s_flagmap,'-mat');
      catch e
         vars = struct('null','');
         msg0 = ['error loading flag mapping file (',e.message,')'];
      end
      if isfield(vars,'data')
         s_flagmap = vars.data;
      else
         s_flagmap = [];
      end
   else
      s_flagmap = [];
   end
   
   %check for valid s_varmap and s_flagmap
   if ~isempty(s_varmap) && ~isempty(s_flagmap) && gce_valid(s_varmap) && gce_valid(s_flagmap)
      
      %get numeric serial date from datecol
      dt = get_studydates(s,datecol);
      dt_str = cellstr(datestr(dt,31));
      
      %calculate date in utc time
      if utc_offset ~= 0
         dt_utc = dt - utc_offset/24;
         dt_str_utc = cellstr(datestr(dt_utc,31));
      else
         dt_str_utc = dt_str;
      end
      
      %add LocalDateTime, DateTimeUTC and UTCOffset columns
      s2 = addcol(s,dt_str,'LocalDateTime','yyyy-mm-dd HH:MM:SS','Date of observation in local time', ...
         's','datetime','none',0,'',datecol+1);
      
      s2 = addcol(s2,utc_offset,'UTCOffset','hours','Local time offset from UTC', ...
         'f','data','continuous',0,'',datecol+2);
      
      s2 = addcol(s2,dt_str_utc,'DateTimeUTC','yyyy-mm-dd HH:MM:SS','Date of observation in UTC time', ...
         's','datetime','none',0,'',datecol+3);

      %filter variable mapping dataset based on SiteCode
      s_varmap = querydata(s_varmap,['strcmpi(''',sitecode,''',SiteCode)']);
      
      if ~isempty(s_varmap)

         %check data type of NoDataValue - set to 'f' if 'd' to avoid issues with coalesce_cols.m post-join
         dtype_ndv = get_type(s_varmap,'datatype','NoDataValue');
         if ~strcmp(dtype_ndv,'f')
            s_varmap = convert_datatype(s_varmap,'NoDataValue','f');
         end
         
         %refactor data set to include Date, Channel and DataValue columns
         channels = setdiff((1:length(s2.name)),(datecol:datecol+3));
         [s2,msg] = normalize_cols(s2, ...
            channels, ...              %index of channel columns (all except for Date)
            (datecol:datecol+3), ...   %column to replicate (Date columns)
            'Channel', ...             %name of combined variable name column
            'DataValue', ...           %name for combined data value column
            'ignore', ...              %option to ignore unit differences
            'f' ...                    %option to cast as data as floating-point
            );
         
         %remove units
         s2 = deletecols(s2,'DataValue_Units');
         
         %join to variable map data set
         [s2,msg0] = joindata(s2, ...   %left structure to join
            s_varmap, ...   %right structure to join (lookup)
            'Channel', ...  %left structure key column
            'Channel', ...  %right structure key column
            'lookup', ...   %join type
            [], ...         %left output columns (all non-key)
            [], ...         %right output column (all non-key)
            '', ...         %prefix for left structure columns
            '', ...         %prefix for right structure columns
            '', ...         %filename for left structure
            'no', ...       %do not remove dupes
            0, ...          %do not require matching units
            'none' ...      %do not merge metadata
            );
         
         %check for variable mapping error
         if isempty(s2)     
            
            %no data - return error
            msg = ['an error occurred mapping variables (',msg0,')'];   
            
         else
            
            %delete numeric serial date column
            s2 = deletecols(s2,s.name{datecol});
      
            %replace missing values with NoDataValue, assign missingflag
            s2 = coalesce_cols(s2,'DataValue','NoDataValue',0,missingflag,0);
            
            %delete NoDataValue
            s2 = deletecols(s2,'NoDataValue');  %just remove NoDataValue
            
            %instantiate flags
            s2 = flags2cols(s2, ...
               'DataValue', ...   %column to generate flags for
               0, ...   %option to retain GCE flag criteria and flags for reference
               0, ...   %option to not flag missing values as 'M'
               1, ...   %option to add flag column right after data column
               0, ...   %option to not encode flags as integers
               'Flag_', ...  %flag column prefix
               1 ...    %option to only use first flag to ensure only 1 character per column
               );
            
            %check for no flags - add empty Flag_DataValue and NaN
            flagcol = name2col(s2,'Flag_DataValue');
            if isempty(flagcol)
               pos = name2col(s2,'DataValue');  %get position of DataValue column
               flagvals = repmat({''},num_records(s2),1);  %init empty array of flags
               s2 = addcol(s2,flagvals,'Flag_DataValue','', ...
                  'QA/QC flags for DataValue','s','code','none',0,'',pos+1);
            end
            
            %update variable type of QualifierCode column in s_flagmap to match Flag_Value
            s_flagmap = update_attributes(s_flagmap,'QualifierCode','variabletype','code');
            
            %join to ODM qualifiers
            [s2,msg0] = joindata(s2, ...   %left structure to join
               s_flagmap, ...   %right structure to join (lookup)
               'Flag_DataValue', ...  %left structure key column
               'QualifierCode', ...  %right structure key column
               'lookup', ...   %join type
               [], ...         %left output columns (all non-key)
               [], ...         %right output column (all non-key)
               '', ...         %prefix for left structure columns
               '', ...         %prefix for right structure columns
               '', ...         %filename for left structure
               'no', ...       %do not remove dupes
               0, ...          %do not require matching units
               'none' ...      %do not merge metadatafin
               );
            
            %check for qualifer join errors
            if ~isempty(s2)
               
               %reposition Flag_DataValue to after DataValue
               pos = name2col(s2,'DataValue');
               s2 = copycols(s2,[2:pos,1,pos+1:length(s2.name)]);
               
               %add remaining ODM fields using fixed values (revise as necessary for ODM instance)
               numrows = num_records(s2);
               s2 = addcol(s2,repmat({'nc'},numrows,1),'CensorCode','','Censor code', ...
                  's','code','none',0,'');
               s2 = addcol(s2,ones(numrows,1),'SourceID','','Source identifier', ...
                  'd','code','discrete',0,'');
               s2 = addcol(s2,repmat(qc_level,numrows,1),'QualityControlLevelID','','Quality control level', ...
                  'd','nominal','discrete',0,'');
               
               %generate s_odm subset for database insert
               s_odm = copycols(s2,{'DataValue', ...
                  'LocalDateTime', ...
                  'UTCOffset', ...
                  'DateTimeUTC', ...
                  'SiteID', ...
                  'VariableID', ...
                  'OffsetValue', ...
                  'CensorCode', ...
                  'QualifierID', ...
                  'MethodID', ...
                  'SourceID', ...
                  'QualityControlLevelID'});
               
               %add appropriate title
               s_odm = newtitle(s_odm, ...
                  ['ODM DataValues Export Table for Site ',sitecode,' (generated ',datestr(now),')']);
               
            else
               msg = ['an error occurred mapping flags (',msg0,')'];               
            end
            
         end
         
      else
         msg = 'no entries in variable mapping data set for the specified sitecode';
      end
      
   else
      if exist('msg0','var') && ~isempty(msg0)
         msg = msg0;
      else
         msg = 'invalid variable and/or qualifer mapping data sets specified';
      end
   end
   
else
   
   %report specific error
   if nargin < 2
      msg = 'insufficient arguments for function - data structure and sitecode are required';
   elseif ~ischar(sitecode)
      msg = 'invalid site code';
   else
      msg = 'invalid data structure';
   end
   
end