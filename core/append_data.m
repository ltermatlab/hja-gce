function [s2,msg] = append_data(s,fn,varname,mergetype,titleopt,fixflags,saveopt)
%Appends a GCE Data Structure to an existing data structure on disk using a specified merge type
%
%syntax: [s2,msg] = append_data(s,fn,varname,mergetype,titleopt,fixflags,saveopt)
%
%input:
%  s = data structure to append
%  fn = relative or fully-qualified filename of data file containing structure to append new data to
%  varname = MATLAB variable name of target structure (default = 'data')
%  mergetype = type of merge to perform:
%    'date_append' = time series merge, deleting overlapping records from new data (default)
%    'date_overwrite' = time series merge, deleting overlapping records from existing data
%    'append' = append all new data to existing data without trimming overlap
%  titleopt = title handling option for combined dataset
%    'original' = retain title of original structure (or s if fn:varname not present)
%    'new' = use title of new structure
%    'new_date' = use title of new structure and call 'add_title_dates' to update date range (default)
%    str = custom string to use as a title
%  fixflags = option to lock flags to prevent automatic recalculation
%    0 = no (default)
%    1 = yes
%  saveopt = option to save combined data as variable 'varname' in 'fn'
%    0 = no
%    1 = yes (default)
%
%output:
%  s2 = combined data structure
%  msg = text of any error message
%
%notes:
%  1) if fn does not exist, s will be returned as s2 without modification
%  2) if fn or fn:varname does not exist and saveopt == 1, s will be saved as fn:varname
%  3) date and time component tokens can be included in fn within square brackets to
%     automatically manage data file creation (e.g. 'marshlanding_[yyyymmdd].mat' will be
%     converted to 'marshlanding_20130401.mat' at runtime); see 'datestr' help for supported tokens
%     (e.g. yyyy = year, mm = numeric month, mmm = 3-letter month, dd = day, HH = hour, MM = minute)
%  4) if mergetype is 'date_append' or 'date_overwrite' and the date range of 's' fully overlaps with
%     the existing data, s2 will be the unmodifed structure from fn:varname, a warning message will be 
%     returned, and s2 will not be re-saved to fn regardless of 'saveopt' setting
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
%last modified: 02-Apr-2013

s2 = [];
msg = '';

%check for required argument
if nargin >= 2 && gce_valid(s,'data')
   
   %replace date/time tokens in filename
   fn = fill_date_tokens(fn);
   
   %set default varname if omitted
   if exist('varname','var') ~= 1
      varname = 'data';
   end
   
   %validate mergetype, supply default if omitted/invalid
   if exist('mergetype','var') ~= 1
      mergetype = 'date_append';
   end
   
   %set default titleopt if omitted
   if exist('titleopt','var') ~= 1 || isempty(titleopt)
      titleopt = 'new_date';
   elseif strcmpi(titleopt,'new_date') || strcmpi(titleopt,'original') || strcmpi(titleopt,'new')
      titleopt = lower(titleopt);
   end
   
   %set default fixflags if omitted
   if exist('fixflags','var') ~= 1
      fixflags = 0;
   end
   
   %set default saveopt if omitted
   if exist('saveopt','var') ~= 1
      saveopt = 1;
   end
   
   %assign calcflags option based on fixflags
   if fixflags == 1
      calcflags = 0;
   else
      calcflags = 1;
   end
   
   %load existing data if present
   s0 = [];
   
   if exist(fn,'file') == 2
      
      %try loading variables from file
      try
         vars = load(fn,'-mat');
      catch
         vars = struct('null','var');
      end
      
      %check for specified variable, extract if present and a valid GCE data structure
      if isfield(vars,varname) && gce_valid(vars.(varname),'data')
         s0 = vars.(varname);
      end
      
   end
   
   %merge with existing data
   if isempty(s0)
      
      %no prior data - return new structure as is
      s2 = s;
      
   else
      
      %perform specified merge
      switch mergetype
         case 'append'
            [s2,msg] = datamerge(s0,s,1,1,1,fixflags,calcflags);
         case 'date_overwrite'
            [s2,msg] = merge_by_date(s0,s,[],[],fixflags,calcflags,'older');
         otherwise  %date_append
            [s2,msg] = merge_by_date(s0,s,[],[],fixflags,calcflags,'newer');
      end
      
      %check for overlapping dates or failed merge - return original structure from fn:varname
      if isempty(s2)
         s2 = s0;
      end
      
   end
   
   %update title
   switch titleopt
      
      case 'new_date'
         s2 = newtitle(s2,s.title,0);  %use new data set title
         s2 = add_title_dates(s2);     %add/update dates
      case 'new'
         if ~isempty(s0)
            s2 = newtitle(s2,s.title);    %use new title
         end
      case 'original'
         if ~isempty(s0)
            s2 = newtitle(s2,s0.title);   %retain original title
         end
      otherwise
         s2 = newtitle(s2,titleopt);    %custom string
         
   end
   
   %save if specified
   if ~isempty(s2)
      
      if saveopt == 1
         
         %create struct with varname field for saving
         output.(varname) = s2;
         
         try
            if exist(fn,'file') == 2
               save(fn,'-struct','output','-append')
            else
               save(fn,'-struct','output')
            end
         catch
            msg = 'an error occurred saving the output file';
         end
         
      end
      
   else
      msg = 'an error occurred updating the data set title';
   end
   
else  %bad input
   
   if margin < 2
      msg = 'insufficient arguments for function';
   else
      msg = 'invalid data structure';
   end
   
end

