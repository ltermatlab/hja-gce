function [s2,msg] = interp_missing_diurnal(s,xcol,ycols,datecol,method,maxpts,logopt,flag,flagdef)
%Performs 1D interpolation to fill in missing values in time-series data based on time of day
%using a specified method and flags the interpolated values.
%
%syntax: [s2,msg] = interp_missing_diurnal(s,xcol,ycols,datecol,method,maxpts,logopt,flag,flagdef)
%
%inputs:
%  s = data structure to update (struct; required)
%  xcol = x column to use for the interpolation (string or integer; required)
%  ycols = y column(s) to interpolate (cell array of strings or integer array; required)
%  datecol = serial date or date string column to use for matching records to time of day
%     (string or integer; optional; default = first datetime column beginning with 'date')
%  method = interpolation method (string; optional)
%     'nearest' = nearest neighbor
%     'linear' = linear interpolation (default)
%     'spline' = piecewise cubic spline
%     'pchip' = piecewise cubic Hermite interpolate (MATLAB R13+)
%     'cubic' = cubic interpolation
%  maxpts = maximum consecutive points to interpolate (integer; optional; 0 or inf = no limit, default = 10)
%  logopt = maximum number of value changes to log (integer; optional; 0 = none, default = 50, inf = all)
%  flag = Q/C flag to assign to interpolated values (string; optional; default = 'E', '' for no flagging)
%  flagdef = Q/C flag definition to add if flag is not listed in the metadata
%     (string; optional; default = 'data value estimated by interpolation')
%
%outputs:
%  s2 = updated structure
%  msg = text of any error messages
%
%notes:
%  1) xcol should not contain missing values for best results
%  2) the data set will be sorted by column 'xcol' automatically
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
%last modified: 14-Jan-2015

s2 = [];
msg = '';

if nargin >= 3
   
   if gce_valid(s,'data')
      
      %assign defaults for omitted arguments
      if exist('flag','var') ~= 1
         flag = 'E';
      elseif ~ischar(flag)
         flag = 'E';
      elseif length(flag) > 1
         flag = flag(1);
      end
      
      if exist('flagdef','var') ~= 1
         flagdef = 'data value estimated by interpolation';
      end
      
      if ~isnumeric(xcol)
         xcol = name2col(s,xcol);  %perform name to number translation
      end
      
      if length(xcol) == 1
         
         if ~isnumeric(ycols)
            ycols = name2col(s,ycols);  %perform name to number translation
         end
         
         %document and remove string, integer columns from ycols
         ycols_skipped = intersect(ycols,find(strcmp(s.datatype,'s') | strcmp(s.datatype,'d')));
         ycols = setdiff(ycols,ycols_skipped);
         
         %init bad interpolation and error arrays
         ycols_bad = zeros(length(ycols),1);
         ycols_error = ycols_bad;
         
         %check for valid ycols and numeric xcol
         if ~isempty(ycols) && ~strcmp(s.datatype{xcol},'s')
            
            interp_flag = 0;  %init flag for interpolated values
            
            s2 = sortdata(s,xcol,1,1);  %init output structure with sorted structure
            
            %validate datecol, default to auto if omitted
            if exist('datecol','var') ~= 1
               datecol = [];
            end
            if ~isempty(datecol) && ~isnumeric(datecol)
               datecol = name2col(s,datecol);
            end
            
            %call function to retrieve array of numeric serial dates from datecol
            if ~isempty(datecol)
               dt = get_studydates(s,datecol);
               try
                  %get date part vector
                  dvec = datevec(dt);
               catch
                  dvec = [];
               end
            else
               dvec = [];
            end
            
            %check for valid dates
            if ~isempty(dvec)
               
               %supply defaults for other missing arguments
               if exist('method','var') ~= 1
                  method = 'linear';
               end
               
               if exist('maxpts','var') ~= 1
                  maxpts = 10;
               end
               
               if exist('logopt','var') ~= 1
                  logopt = 50;
               end
               
               %extract x values
               x = extract(s,xcol);
                              
               for n = 1:length(ycols)
                  
                  y = extract(s,ycols(n));  %get y values for column
                  Ival = find(~isnan(y));   %get index of valid values
                  Inan = find(isnan(y));    %get index of missing values
                  
                  if ~isempty(Inan)
                     
                     %init y2
                     y2 = y;

                     %perform interpolation for each value using other data at same times using specified method
                     for nval = 1:length(Inan)
                        idx = Inan(nval);
                        Imatch = find(dvec(Ival,4)==dvec(idx,4) & dvec(Ival,5)==dvec(idx,5) & dvec(Ival,6)==dvec(idx,6));
                        if ~isempty(Imatch)
                           try
                              y_int = feval('interp1',x(Ival(Imatch)),y(Ival(Imatch)),x(idx),method);
                              y2(idx) = y_int;  %update y2 with interpolated values
                           catch
                              y2 = [];
                              ycols_error(n) = 1;
                              break
                           end
                        end
                     end
                     
                     if ~isempty(y2)
                        
                        %get index of successfully interpolated values
                        Ival2 = find(~isnan(y2(Inan)));
                        
                        %check for excessively large gaps, restore NaNs if > maxpts option
                        if ~isempty(Ival2) && maxpts > 0 && maxpts < inf
                           
                           Irepeat = find(diff(Inan(Ival2))==1);  %get indices of contiguous runs of interpolations based on index diff
                           
                           if ~isempty(Irepeat)
                              
                              Ibreaks = find(diff(Irepeat)>1);   %get indices of breaks in interp value sequences
                              
                              %check for breaks
                              if ~isempty(Ibreaks)
                                 
                                 %generate starting indices, adding first segment pointer
                                 Istart = [Irepeat(1) ; Irepeat(Ibreaks+1)];
                                 
                                 %generate ending indices, adding terminal segment pointer
                                 Iend = [Irepeat(Ibreaks)+1 ; Irepeat(end)+1];
                                 
                                 %generate index of blocks > maxpts in size
                                 Ibad = find((Iend-Istart)+1 > maxpts);
                                 
                                 %loop through bad segments, resetting values to NaN
                                 if ~isempty(Ibad)
                                    for m = 1:length(Ibad)
                                       y2(Inan(Ival2(Istart(Ibad(m)):Iend(Ibad(m))))) = NaN;
                                    end
                                 end
                                 
                              elseif length(Irepeat) >= maxpts  %one contiguous block of repeats > maxpts
                                 
                                 y2 = y;  %reset y2 to replace NaNs
                                 
                              end
                              
                              Ival2 = find(~isnan(y2(Inan)));  %regenerate index of successfully interpolated values
                              
                           end
                           
                        end
                        
                        %check for interpolated values
                        if ~isempty(Ival2)
                           
                           %set flags if specified
                           if ~isempty(flag)
                              
                              %lock q/c flags
                              crit = s2.criteria{ycols(n)};
                              if isempty(crit)
                                 crit = 'manual';
                              elseif isempty(strfind(crit,'manual'))
                                 crit = [crit,';manual'];
                              end
                              s2.criteria{ycols(n)} = crit;  %update flag criteria before updating data to lock flags
                              
                              %set specified flag on interpolated values
                              flags = s2.flags{ycols(n)};
                              if isempty(flags)
                                 flags = repmat(' ',length(s2.values{1}),1);  %instantiate flags
                              end
                              flags(Inan(Ival2),1) = flag;
                              s2.flags{ycols(n)} = flags;
                              
                              %add flag definition if specified and not already listed
                              if ~isempty(flagdef)
                                 s2 = add_flagdef(s2,flag,flagdef);
                              end
                              
                           end
                           
                           %look up method names for history string
                           switch method
                              case 'linear'
                                 methodstr = 'linear interpolation';
                              case 'nearest'
                                 methodstr = 'nearest neighbor interpolation';
                              case 'spline'
                                 methodstr = 'piecewise cubic spline interpolation';
                              case 'pchip'
                                 methodstr = 'piecewise cubic Hermite interpolation';
                              case 'cubic'
                                 if mlversion > 6
                                    methodstr = 'piecewise cubic Hermite interpolation';
                                 else
                                    methodstr = 'cubic interpolation or cubic spline for non-equally-spaced data';
                                 end
                              case 'v5cubic'
                                 methodstr = 'cubic interpolation or cubic spline for non-equally-spaced data';
                              otherwise
                                 methodstr = 'unknown method';
                           end
                           
                           %add history entry for interpolation
                           if maxpts > 0 && maxpts < inf
                              str_maxpts = [', excluding data gaps with more than ',int2str(maxpts),' consecutive missing values'];
                           else
                              str_maxpts = '';
                           end
                           if length(Ival2) > 1
                              str = ['replaced ',int2str(length(Ival2)),' missing values'];
                              str2 = ' with estimated values ';
                           else
                              str = 'replaced 1 missing value';
                              str2 = ' with an estimated value ';
                           end
                           if ~isempty(flag)
                              str_flags = [', and flagging the estimated values as ''',flag,''''];
                           else
                              str_flags = '';
                           end
                           str = [str,' in column ',s2.name{ycols(n)},str2, ...
                              'based on 1D interpolation of ',s2.name{ycols(n)},' as a function of ', ...
                              s2.name{xcol},' using the MATLAB ',num2str(mlversion),' function ''interp1'' with the ''', ...
                              method,''' (',methodstr,') method option',str_maxpts,str_flags,' (''interp_missing'')'];
                           s2.history = [s2.history ; {datestr(now)},{str}];
                           
                           %perform data update, logging data changes
                           s2 = update_data(s2,ycols(n),y2,logopt);
                           
                           interp_flag = 1;  %update interpolation flag
                           
                        else
                           ycols_bad(n) = 1;   %add to bad column list
                        end
                        
                     end
                  end
               end
               
               %generate error message if any bad columns or errors
               Ibadcols = find(ycols_bad);
               Ierrors = find(ycols_error);
               if ~isempty(Ibadcols) || ~isempty(Ierrors) || ~isempty(ycols_skipped)
                  if length(Ibadcols) == length(ycols)  %check for complete failure
                     s2 = s;  %restore original structure
                     msg = 'failed to interpolate data in any specified column';
                  else
                     if ~isempty(Ibadcols)
                        if length(Ibadcols) < length(ycols)
                           if length(ycols_bad) == 1
                              msg = ['failed to interpolate data in column ',s2.name{ycols(Ibadcols)}];
                           else
                              msg = ['failed to interpolate data in columns ',cell2commas(s2.name(ycols(Ibadcols)),1)];
                           end
                        end
                     end
                  end
                  if ~isempty(Ierrors)
                     if ~isempty(msg)
                        msg = [msg,', '];
                     end
                     if length(Ibadcols) > 1
                        msg = [msg,'errors occurred interpolating data in columns ',cell2commas(s2.name(ycols(Ierrors)),1)];
                     else
                        msg = [msg,'errors occurred interpolating data in column ',s2.name{ycols(Ierrors)}];
                     end
                  end
                  if ~isempty(ycols_skipped)
                     if ~isempty(msg)
                        msg = [msg,', '];
                     end
                     if length(ycols_skipped) > 1
                        msg = [msg,'interpolation was not attempated for columns ',cell2commas(s2.name(ycols_skipped),1), ...
                           ' because column data types are not supported'];
                     else
                        msg = [msg,'interpolation was not attempated for column ',s2.name{ycols_skipped}, ...
                           ' because the column data type is not supported'];
                     end
                  end
               end
               
               %check for no values interpolated - restore original structure
               if interp_flag == 0
                  s2 = s;
                  msg = 'no missing values were interpolated in the specified columns';
               end
               
            else
               msg = 'date column was invalid or could not be determined';
            end
            
         else
            if isempty(ycols)
               msg = 'invalid y column selections';
            else
               msg = 'invalid x column selection - string data cannot be used for interpolation';
            end
         end
         
      else
         msg = 'invalid x column selection';
      end
      
   else
      msg = 'invalid data structure';
   end
   
else
   msg = 'insufficient arguments for function';
end