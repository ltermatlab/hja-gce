function [s2,msg] = interp_parms_by_salinity(s,salinity_array,col_date,col_salinity,parms,tol_value,tol_percent,method)
%Generates a derived data set containing interpolated variable measurements for a target salinity
%or conductivity in a moored sonde data set. Note that variables will not be interpolated where
%the target salinity/conductivity cannot be determined within both a value and percentage tolerance.
%
%syntax: [s2,msg] = interp_parms_by_salinity(s,salinity_array,col_date,col_salinity,parms,tol_value,tol_percent,method)
%
%input:
%  s = mooring data set to analyze
%  salinity_array = array of target salinity or conductivity values, in units of col_salinity column
%  col_date = column name or index containing a MATLAB serial date (default = '' for automatic)
%  col_salinity = column name or index containing salinity or conductivity data values 
%     (default = 'Salinity')
%  parms = array of column names or indices of parameters to interpolate 
%     (default = all data/calc columns other than salinity)
%  tol_value = maximum difference between target and interpolated salinity/conductivity in units of 
%     col_salinity column (default = 0.25)
%  tol_percent = maximum difference between target and interpolated salinity/conductivity in percent
%     (default = 5)
%  method = interpolation method to use (see 'interp1', default = 'pchip')
%
%output:
%  s2 = derived data set
%  msg = text of any error message
%
%(c)2009-2010 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 28-May-2010

%init output
s2 = [];
msg = '';

if nargin >= 2 && gce_valid(s,'data') && isnumeric(salinity_array)
   
   %validate input, set defaults for omitted arguments
   if exist('method','var') ~= 1
      method = '';
   end
   if isempty(method)
      method = 'pchip';
   end

   if exist('tol_value','var') ~= 1
      tol_value = .25;
   end
   
   if exist('tol_percent','var') ~= 1
      tol_percent = 5;
   end
   
   if exist('col_date','var') ~= 1
      col_date = [];  %default to automatic date column identification
   end

   %validate or look up salinity column
   if exist('col_salinity','var') ~= 1
      col_salinity = [];
   end
   if isempty(col_salinity)
      col_salinity = name2col(s,'salinity',0,'f');
   elseif ~isnumeric(col_salinity)
      col_salinity = name2col(s,col_salinity);
   end

   %validate or look up parameter columns
   if exist('parms','var') ~= 1
      parms = [];
   end
   if isempty(parms)  %look up all data/calc columns, excluding salinity column
      types = get_type(s,'variabletype');
      parms = find(strcmp(types,'data') | strcmp(types,'calc'));
      if ~isempty(parms)
         parms = setdiff(parms,col_salinity);
      end
   elseif ~isnumeric(parms)
      parms = name2col(s,parms);  %look up column indices from names
   end

   %validate parameter array, remove non-floating point columns and salinity column
   parms = intersect((1:length(s.name)),parms);
   dtypes = get_type(s,'datatype');
   Ifloat = strcmp(dtypes,'f') | strcmp(dtypes,'e');
   Ifloatparms = Ifloat(parms) == 1;
   parms = setdiff(parms(Ifloatparms),col_salinity);

   if ~isempty(col_salinity) && ~isempty(parms)

      %get serial dates from data set (automatically determining date column if omitted)
      dt_orig = get_studydates(s,col_date);

      %get sort index and index of valid dates
      if ~isempty(dt_orig)
         [dt,Isort] = sort(dt_orig);
         Ivalid = find(~isnan(dt));
      else
         Ivalid = [];
      end

      if ~isempty(Ivalid)

         %remove records with NaN dates, sort remaining records by date value
         dt = dt(Ivalid);
         Isort = Isort(Ivalid);
         s = copyrows(s,Isort);

         if ~isempty(dt)

            sal = extract(s,col_salinity); %get measured salinity/conductivity/conductance values

            if isnumeric(sal)

               %instantiate output structure, copying metadata and lineage fields
               s2 = newstruct('data');
               s2.metadata = s.metadata;
               s2.history = s.history;
               s2.datafile = s.datafile;
               s2 = newtitle(s2,[cell2commas(s.name(parms),1),' interpolated to match reference values of ',s.name{col_salinity},' from ',s.title]);

               %instantiate output array
               data = [];

               %extract parm data arrays
               parm_data = extract(s,parms);

               %set target interval for time step in fractional days (default = 2/60/24 = 2 minutes)
               interval = 0.00138888888889;
               
               %check for measured data interval > target interval, interpolate if necessary
               if mean(diff(dt)) > interval  
                  try
                     dt2 = [min(dt):interval:max(dt)]';
                     sal2 = interp1(dt,sal,dt2,'spline');
                  catch
                     dt2 = [];
                     sal2 = [];
                  end
                  if isempty(dt2) || isempty(sal2)
                     dt2 = dt;
                     sal2 = sal;
                  end
               end
               
               %iterate through target salinity values
               for cnt = 1:length(salinity_array)

                  %get target salinity from array
                  salinity = salinity_array(cnt);  

                  %calculate salinity bracket limits for locating regions near target (+/-20%, min 0.2)
                  bracket = max(0.1,salinity * 0.1);
                  ulim = salinity + bracket;
                  llim = max(0,salinity - bracket);

                  %get index of regions of salinity within brackets
                  Isal = find(sal2 >= llim & sal2 <= ulim);

                  if ~isempty(Isal)

                     %get indices of brackets matching salinity lookup
                     Ibreaks = find(diff(Isal)>1);
                     Iend = [Isal(Ibreaks);Isal(end)];
                     Istart = [1;Isal(Ibreaks+1)];

                     %init array of interpolated dates and closest matched interpolated salinity
                     interp_data = repmat(NaN,length(Istart),length(parms)+3);

                     %calc number of rows
                     numrows = length(sal);

                     for n = 1:length(Istart)

                        %get arrays of dates, salinities within each bracket
                        Isel = Istart(n):Iend(n);
                        if length(Isel) < 3
                           Isel = max(1,Istart(n)-2):min(Iend(n)+2,numrows);  %pad out selection if < 6 elements
                        end
                        dt0 = dt2(Isel);
                        sal0 = sal2(Isel);

                        %generate date intervals for interpolation (10 sec resolution)
                        interval = 1/24/60/6;
                        dt_interp = min(dt0):interval:max(dt0);

                        %perform interpolation, falling back to spline on errors
                        try
                           sal_interp = interp1(dt0,sal0,dt_interp,method);
                        catch
                           try
                              sal_interp = interp1(dt0,sal0,dt_interp,'spline');
                           catch
                              sal_interp = [];
                           end
                        end

                        if ~isempty(sal_interp)
                           
                           [tmp,Iclosest] = min(abs(sal_interp - salinity));
                           sal_closest = sal_interp(Iclosest);
                           dt_closest = dt_interp(Iclosest);
                           sal_offset = abs(sal_closest-salinity);
                           pct_offset = sal_offset/salinity;
                           interp_data(n,1) = dt_closest;
                           interp_data(n,2) = salinity;
                           interp_data(n,3) = sal_closest;
                           
                           %check for interpolated salinity within tolerance
                           if sal_offset <= tol_value && pct_offset <= (tol_percent/100)
                              
                              %look up closest match from interpolated value array
                              [tmp,Iparmstart] = max(find(dt_orig <= dt_closest));
                              Iparmend = Iparmstart + 1;
                              if Iparmstart > 5
                                 Iparmstart = Iparmstart - 5;
                              else
                                 Iparmstart = 1;
                              end
                              if Iparmend < length(dt_orig) - 6;
                                 Iparmend = Iparmend + 5;
                              else
                                 Iparmend = length(dt_orig);
                              end
                              
                              %loop through output variables performing interpolations to match salinity
                              for m = 1:length(parms)
                                 parm0 = parm_data(Iparmstart:Iparmend,m);  %get parameter values for interpolation interval
                                 try
                                    parm_interp = interp1(dt_orig(Iparmstart:Iparmend),parm0,dt_closest,method);
                                 catch
                                    try
                                       parm_interp = interp1(dt_orig(Iparmstart:Iparmend),parm0,dt_closest,'spline');
                                    catch
                                       parm_interp = NaN;
                                    end
                                 end
                                 interp_data(n,m+3) = parm_interp;
                              end
                           
                           end
                           
                        end

                     end

                     data = [data ; interp_data];  %append to output data array

                  end

               end

               %add interpolated data to output structure
               s2 = addcol(s2,data(:,1),'Date','serial day (base 1/1/000)','Fractional serial date (based on 1 = January 1, 0000)', ...
                  'f','datetime','continuous',6,'',1);
               s2 = addcol(s2,data(:,2),[s.name{col_salinity},'_Ref'],s.units{col_salinity},['Reference value of ',s.description{col_salinity}],'f','calculation','continuous',2,'x<0=''I''');
               s2 = addcol(s2,data(:,3),[s.name{col_salinity},'_Interp'],s.units{col_salinity},['Interpolated value closest to target reference value of ',s.description{col_salinity}], ...
                  'f','calculation','continuous',2,'x<0=''I''');

               %loop through output variable columns, adding to end of data structure sequentially
               for n = 1:length(parms)
                  col = parms(n);
                  s2 = addcol(s2,data(:,3+n),[s.name{col},'_Interp'],s.units{col},['Interpolated ',s.description{col}], ...
                     s.datatype{col},'calc','continuous',s.precision(col),s.criteria{col});
               end

               %check validity of structure
               if gce_valid(s2,'data') ~= 1
                  s2 = [];
                  msg = 'an error occurred generating the output structure';
               end

            else
               msg = 'invalid salinity column format';
            end

         else
            msg = 'no valid date information was present in the data set';
         end

      else
         msg = 'no valid date information could be retrieved (or date column could not be determined)';
      end

   else
      msg = 'invalid salinity or parameter column selections';
   end

else  %bad input
   if nargin == 0
      msg = 'data structure is required';
   else
      msg = 'invalid data structure';
   end
end