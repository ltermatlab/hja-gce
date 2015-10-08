function [s2,msg,interp_errors] = interp_missing_stepwise(s,xcol,ycols,stepcol,method,maxpts,logopt)
%Performs interpolation to fill in missing values, proceeding step-wise for each unique value in a stepping column
%
%syntax: [s2,msg] = interp_missing(s,xcol,ycols,method,maxpts,logopt)
%
%inputs:
%  s = data structure to update
%  xcol = x column to use for the interpolation (should not contain missing values)
%  ycols = y column(s) to interpolate
%  stepcol = column to use for stepping through the interpolations - a separate interpolation
%    of 'ycols' as a function of 'xcol' will be perform for each unique value in 'stepcol'
%  method = interpolation method
%     'nearest' = nearest neighbor
%     'linear' = linear interpolation (default)
%     'spline' = piecewise cubic spline
%     'pchip' = piecewise cubic Hermite interpolate (MATLAB R13+)
%     'cubic' = cubic interpolation
%  maxpts = maximum consecutive points to interpolate (0 or inf = no limit, default = 5)
%  logopt = maximum number of value changes to log (0 = none, default = 50, inf = all)
%  flag = Q/C flag to assign to interpolated values (string; optional; default = 'E', '' for no flagging)
%  flagdef = Q/C flag definition to add if flag is not listed in the metadata
%     (string; optional; default = 'data value estimated by interpolation')
%
%outputs:
%  s2 = updated structure
%  msg = text of any error messages
%
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

if nargin >= 4

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
         xcol = name2col(s,xcol);  %look up column index from name
      end

      if ~isnumeric(stepcol)
         stepcol = name2col(s,stepcol); %look up column index from name
      end

      %check for single xcol & single stepcol
      if length(xcol) == 1 && length(stepcol) == 1

         if ~isnumeric(ycols)
            ycols = name2col(s,ycols);  %look up column index from names
         end

         %document and remove string, integer columns from ycols
         ycols_bad = intersect(ycols,find(strcmp(s.datatype,'s') | strcmp(s.datatype,'d')));
         ycols = setdiff(ycols,ycols_bad);

         if ~isempty(ycols) && ~strcmp(s.datatype{xcol},'s')

            s2 = s;  %init output structure

            if exist('method','var') ~= 1
               method = 'linear';
            end

            if exist('maxpts','var') ~= 1
               maxpts = 5;
            end

            if exist('logopt','var') ~= 1
               logopt = 50;
            end

            stepdata = extract(s,stepcol);  %extract step values

            stepgroups = unique(stepdata);  %get array of unique step values
            numgps = length(stepgroups);

            if numgps < length(stepdata)

               Irecords = cell(1,numgps);
               if iscell(stepgroups)
                  for n = 1:numgps
                     Isel = find(strcmp(stepdata,stepgroups{n}));  %get index of matching records
                     if length(Isel) > 2
                        Irecords{n} = Isel;  %add to index collection unless < 3 records
                     end
                  end
               else  %numeric step column
                  for n = 1:numgps
                     Isel = find(stepdata == stepgroups(n));  %get index of matching records
                     if length(Isel) > 2
                        Irecords{n} = Isel;  %add to index collection unless < 3 records
                     end
                  end
               end

               %remove empty ranges
               Irecords = Irecords(find(~cellfun('isempty',Irecords)));
               numgps2 = length(Irecords);  %recalc groups

               if ~isempty(Irecords)

                  %extract x data
                  xdata = s.values{xcol};

                  %extract y data, flags
                  ydata = s.values(ycols);
                  yflags = s.flags(ycols);

                  %init modified ydata
                  ydata2 = ydata;

                  %init modified flags, instantiating any empty flag columns
                  yflags2 = yflags;
                  Inull = find(cellfun('isempty',yflags2));  %get index of empty flag arrays
                  if ~isempty(Inull)
                     yflags2(Inull) = repmat({repmat(' ',length(xdata),1)},1,length(Inull));  %instantiate empty flags
                  end

                  %init modification flag array, interpolated point counter array
                  dirtyflag = zeros(1,length(ycols));

                  %init error index
                  interp_errors = [];

                  for n = 1:numgps2

                     Isel = Irecords{n};  %get relevant record index

                     x = xdata(Isel);  %get relevant x data

                     %check for sufficient x data for interpolation
                     if length(find(~isnan(x))) > 2

                        for m = 1:length(ycols)

                           y = ydata{m}(Isel);       %get y values for range
                           Ival = find(~isnan(y));   %get index of valid values
                           Inan = find(isnan(y));    %get index of missing values
                           Ifirst = min(Ival);       %get start of valid data region (to avoid extrapolation)
                           Ilast = max(Ival);        %get end of valid data region (to avoid extrapolation)

                           if ~isempty(Inan)

                              %perform interpolation using specified method
                              try
                                 y_int = feval('interp1',x(Ival),y(Ival),x(Ifirst:Ilast),method);
                                 y2 = y;
                                 y2(Ifirst:Ilast) = y_int;
                              catch
                                 y2 = [];
                                 interp_errors = [interp_errors ; {ycols(m)} , {Isel}];  %add index counters to error index
                              end

                              if ~isempty(y2)

                                 Ival2 = find(~isnan(y2(Inan)));  %get index of successfully interpolated values

                                 %check for interpolation regions > maxpts
                                 if ~isempty(Ival2) && maxpts > 0 && maxpts < inf
                                    Ibreaks = find(diff(Inan(Ival2))>1);
                                    if ~isempty(Ibreaks);
                                       Istart = [1 ; Ibreaks(1:end-1)+1];
                                       Iend = Ibreaks;
                                       Ibad = find((Iend-Istart)+1 > maxpts);
                                       if ~isempty(Ibad)
                                          for cnt = 1:length(Ibad)
                                             y2(Inan(Ival2(Istart(Ibad(cnt)):Iend(Ibad(cnt))))) = NaN;  %restore NaN
                                          end
                                          Ival2 = find(~isnan(y2(Inan)));  %regenerate index of successfully interpolated values
                                       end
                                    end
                                 end

                                 %update master arrays with new values and flags
                                 if ~isempty(Ival2)

                                    dirtyflag(m) = 1;  %set dirty flag for y column

                                    ydata2{m}(Isel) = y2;  %update master data array (both original + interp data

                                    yflags2{m}(Isel(Inan(Ival2))) = flag;  %update master flag array (interp only)

                                 end

                              end

                           end

                        end

                     end

                  end

                  if sum(dirtyflag) > 0

                     %add flag code to metadata if necessary
                     if ~isempty(flagdef)
                        s2 = add_flagdef(s2,flag,flagdef);
                     end

                     %init maxpts string for history
                     if maxpts > 0 && maxpts < inf
                        str_maxpts = [', excluding data gaps with more than ',int2str(maxpts),' consecutive missing values'];
                     else
                        str_maxpts = '';
                     end

                     %get index of updated ycols
                     Ivalid = find(dirtyflag);

                     %loop through modified cols, updating processing history, data and flags
                     for n = 1:length(Ivalid)

                        col = ycols(Ivalid(n));  %get y column index

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
                        str = ['filled in missing values in column ',s2.name{col}, ...
                              ' with estimated values based on interpolation of ',s2.name{col},' as a function of ', ...
                              s2.name{xcol},' using the MATLAB ',num2str(mlversion),' function ''interp1'' with the ''', ...
                              method,''' (',methodstr,') method option, performed step-wise for each unique value in column ', ...
                              s2.name{stepcol},' using the ''',method,''' method',str_maxpts,' (''interp_missing_stepwise'')'];
                        s2.history = [s2.history ; {datestr(now)},{str}];

                        %perform data update
                        [s2,msg2] = update_data(s2,ycols(Ivalid(n)),ydata2{Ivalid(n)},logopt);

                        %perform flag update, nulling output and breaking on errors
                        if ~isempty(s2)
                           s2.flags{col} = yflags2{Ivalid(n)};
                           crit = s2.criteria{col};
                           if isempty(crit)
                              crit = 'manual';
                           elseif isempty(strfind(crit,'manual'))
                              crit = [crit,';manual'];
                           end
                           s2.criteria{col} = crit;
                        else
                           s2 = [];
                           msg = ['an error occurred while updating the data structure: ',msg2];
                           break
                        end
                     end

                  else
                     msg = 'no interpolations were performed';
                  end

               else
                  msg = 'no step column groups contained > 2 records - interpolation skipped';
               end

            else
               msg = 'invalid step column - no repeated values for interpolation';
            end

         else
            msg = 'invalid y column selections';
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