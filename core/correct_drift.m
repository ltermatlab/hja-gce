function [s2,msg] = correct_drift(s,cols,method,offset,daterange,datecol,flagchar,logopt)
%Corrects sensor drift by applying a constant, linearly-varying or custom weighted offset for a range of dates
%
%syntax: [s2,msg] = correct_drift(s,cols,method,offset,daterange,datecol,flagchar,logopt)
%
%input:
%   s = data structure to update (note: must contain time-series data with valid date/time columns)
%   cols = names or indices of columns to correct
%   method = correction method:
%      'constant' = constant correction applied to all matching records
%      'linear' = linearly-varying correction between 0 at start time to offset at end time
%      'custom' = custom weighted corrections to apply when 'offset' contains an array of values
%         (note: the 'offset' array will be scaled using shape-preserving piecewise cubic interpolation 
%         across the entire 'daterange' period to match the temporal frequency of the data, so the 
%         first element of 'offset' will apply to the beginning date and last element to the ending date)
%   offset = value offset to apply:
%      numeric scalar = constant offset or end-point of linearly-varying offset too apply to all date ranges
%      numeric array = constant offsets or end-points of linearly-varying offsets for each date
%        range, or the custom-weighted offsets to scale and apply to all date ranges
%   daterange = 2-column array of starting and ending dates (numeric array of serial dates
%      or cell array of date strings in a format supported by datenum; default = entire date range)
%   datecol = date column ([] for automatic)
%   flagchar = flag to assign to corrected values (default: 'C = data value corrected for sensor drift')
%   logopt = number of value corrections to log in the metadata (default = 50)
%
%output:
%   s2 = revised data structure
%   msg = text of any error message
%
%usage notes:
%   1) offsets are added to measured values, so use negative numbers to subtract an offset
%   2) if 'offsets' contains an array with fewer elements than the number of rows in 'daterange'
%      the last element of offsets to be replicated to produce a matching array
%   3) only one array of offsets is supported for method = 'custom', so the function should be
%      called separately for each date range to apply separate custom-weighted offsets
%   4) the definition '[flagchar] = corrected value' will be registered in the metadata if flagchar is
%      not already defined
%
%
%(c)2011-2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 03-Jul-2014

%init output
s2 = [];
msg = '';

%check for required arguments and valid data structure
if nargin >= 4 && gce_valid(s,'data') == 1
   
   %check for valid offset
   if isnumeric(offset)
      
      %force column array of offsets
      offset = offset(:)';
      
      %look up column names or validate numeric indices
      if ~isnumeric(cols)
         cols = name2col(s,cols);
      else
         cols = intersect(cols,(1:length(s.name)));
      end
      
      %check for matched columns
      if ~isempty(cols)
         
         %validate method argument
         if ~inlist(method,{'constant','linear','custom'},'insensitive')
            method = 'constant';  %catch unsupported method
         elseif strcmpi(method,'custom') && length(offset) == 1
            method = 'constant';  %override method for scalar offset
         end
         
         %check for datecol input
         if exist('datecol','var') ~= 1
            datecol = [];
         elseif ~isnumeric(datecol)
            datecol = name2col(s,datecol);
         end
         
         %check for flagchar input
         if exist('flagchar','var') ~= 1
            flagchar = 'C';
         elseif ~ischar(flagchar)
            flagchar = 'C';
         end
         
         %check for logoption input
         if exist('logopt','var') ~= 1
            logopt = 50;
         end
         
         %check for daterange input
         if exist('daterange','var') ~= 1
            daterange = [];
         else
            numdates = size(daterange,1);
            if numdates > 1
               if length(offset) == 1
                  %replicate scalar offset to match number of date ranges
                  offset = repmat(offset,numdates,1);
               elseif length(offset) < numdates && ~strcmpi(method,'custom')
                  %copy last element to match number of date ranges for constant and linear methods
                  offset = [offset(:) ; repmat(offset(end),numdates-length(offset),1)];
               end
            end
         end
         
         %extract study dates array from structure
         dt = get_studydates(s,datecol);
         
         if ~isempty(dt)
            
            %calculate min/max study date
            mindate = min(no_nan(dt));
            maxdate = max(no_nan(dt));
            
            %validate date range
            if isempty(daterange)
               daterange = [mindate maxdate];  %default to full period of record
            elseif size(daterange,2) == 2
               if iscell(daterange)
                  %convert string dates to numeric serial dates
                  daterange0 = daterange;
                  daterange = zeros(size(daterange0));
                  for n = 1:size(daterange0,1)
                     try
                        daterange(n,1) = datenum(daterange0{n,1});
                        daterange(n,2) = datenum(daterange0{n,2});
                     catch
                        break
                     end
                  end
                  if ~isempty(find(daterange==0))
                     daterange = [];  %check for date format errors, clear daterange
                  end
               end
            else
               daterange = [];
            end
            
            %check for valid numeric date range array
            if ~isempty(daterange)
               
               %sort study dates and return index for sorting data structure to match
               [dt,Isort] = sort(dt);
               
               %init output structure by sorting input structure
               s2 = copyrows(s,Isort,'Y');
               
               %generate appropriate history for date sorting, overriding entry by copyrows
               s2.history = [s.history ; ...
                  {datestr(now),'sorted rows by measurement date prior to applying drift corrections (''correct_drift'')'}];
                              
               %init status flags for updated values and runtime errors
               updateflag = 0;
               errflag = 0;
               
               %loop through date range pairs
               for n = 1:size(daterange,1)
                  
                  %get start and end date scalars
                  datestart = daterange(n,1);
                  dateend = daterange(n,2);
                  
                  %validate date range relative to study dates
                  if dateend >= datestart && datestart < maxdate && dateend > mindate
                     
                     %get index of values within date range
                     Iinrange = find(dt >= datestart & dt <= dateend);
                     
                     if ~isempty(Iinrange)
                        
                        %init history entry for date range
                        if length(cols) == 1
                           str_hist = ['corrected values in column ',s.name{cols}];
                        else
                           str_hist = ['corrected values in columns ',cell2commas(s.name(cols),1)];
                        end
                        str_hist = [str_hist,' for sensor drift over the date range ',datestr(datestart),' to ',datestr(dateend), ...
                           ' by applying a '];
                        
                        %apply correction based on method and document details in processing history
                        if strcmpi(method,'constant')
                           c = repmat(offset(n),length(Iinrange),1);  %generate constant correction offset array
                           str_hist = [str_hist,'constant correction of ',num2str(offset(n)),' (''correct_drift'')'];
                        else
                           dt_inrange = dt(Iinrange);  %get array of in-range dates
                           if strcmpi(method,'custom')
                              %interpolate weights to match date range
                              dt0 = linspace(datestart,dateend,length(offset));  %get even date increments for correction elements
                              try
                                 c = interp1(dt0,offset,dt_inrange,'pchip');  %interpolate to match corrections to measurement dates
                                 str_hist = [str_hist,'custom weighted correction varying from ',num2str(min(offset)), ...
                                    ' to ',num2str(max(offset)),' (''correct_drift'')'];
                              catch
                                 c = [];
                              end
                           else  %linear
                              w = (dt_inrange - datestart)./(dateend - datestart);  %calculate linear weighting
                              c = repmat(offset(n),length(Iinrange),1) .* w;  %apply weighting
                              str_hist = [str_hist,'linearly-weighted correction varying from 0 to ', ...
                                 num2str(offset(n)),' (''correct_drift'')'];
                           end
                        end
                        s2.history = [s2.history ; {datestr(now),str_hist}];  %update history
                        
                        %check for correction array
                        if ~isempty(c)
                           
                           %loop through column selections, applying offset
                           for cnt = 1:length(cols)
                           
                              col = cols(cnt);  %get column pointer
                              vals = extract(s2,col);  %extract value array

                              %check for numeric array
                              if ~isempty(vals) && ~iscell(vals)
                                 updateflag = 1;  %set updated value flag
                                 vals(Iinrange) = vals(Iinrange) + c;  %apply offset to matched values
                                 [s2,msg0] = update_data(s2,col,vals,logopt);  %incorporate and log changes
                                 if ~isempty(s2)
                                    if ~isempty(flagchar)
                                       [s2,msg0] = addflags(s2,col,Iinrange,flagchar);  %add flags for revised values
                                       if isempty(s2)
                                          msg = ['An error occurred adding the flags: ',msg0];
                                          break
                                       end
                                    end
                                 else
                                    msg = ['An error occurred applying the offset: ',msg0];
                                    break
                                 end
                              end
                              
                           end
                           
                        else
                           
                           %set flags and break on error
                           updateflag = 0;
                           errflag = 1;
                           break
                           
                        end
                        
                     end
                     
                  end
                  
               end
               
               %check for any data revision
               if updateflag == 1
                  
                  %check for flag definition and add if not found
                  if ~isempty(flagchar)
                     flagcodes = lookupmeta(s2,'Data','Codes');
                     newcodes = '';
                     if isempty(flagcodes)
                        newcodes = [flagchar,' = data value corrected for sensor drift'];
                     else
                        ar = splitstr(flagcodes,',');
                        Iflag = find(strncmp([flagchar,' ='],ar,length(flagchar)+2));
                        if isempty(Iflag)
                           newcodes = [flagcodes,', ',flagchar,' = data value corrected for sensor drift'];
                        end
                     end
                     if ~isempty(newcodes)
                        %add new code definition to metadata
                        s2 = addmeta(s2,{'Data','Codes',newcodes},0,'correct_drift');
                     end
                  end
                  
               else  %no updates
                  
                  %check for runtime errors
                  if errflag == 0
                     s2 = s;  %revert history changes
                     msg = 'no matching records found within specified date ranges - no corrections applied';
                  else
                     s2 = [];
                     msg = 'an error occurred applying the corrections - check for duplicate of missing date/time values';
                  end
                  
               end
               
            else
               msg = 'invalid date range array';
            end
            
         else
            msg = 'study dates could not be determined - operation cancelled';
         end
         
      else
         msg = 'invalid column selection';
      end
      
   else
      msg = 'invalid offset';
   end
   
else
   if nargin < 3
      msg = 'insufficient arguments for this function';
   else
      msg = 'invalid data structure';
   end
end

