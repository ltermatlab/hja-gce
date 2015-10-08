function [s2,msg] = add_yeardaycol(s,roundopt,datecol,timecol,position)
%Adds a numerical year day column to a GCE Data Structure, based on serial date or formatted date and time columns
%(serial date will automatically be calculated based on existing date/time columns if omitted). Note that any 
%existing column named 'YearDay' will be replaced.
%
%syntax: [s2,msg] = add_yeardaycol(s,roundopt,datecol,timecol,position)
%
%inputs:
%  s = GCE Data Structure
%  roundopt = rounding option for year day values
%    '' = no rounding (default)
%    'round' = round to nearest integer
%    'fix' = fix/trucate
%    'floor' = round down towards minus inf
%    'ceil' = round up towards inf
%  datecol = name or number of serial date column (datatype 'f' or 's',
%     variabletype 'datetime')
%  timecol = name or number of time column (datatype 'd' or 's', variabletype
%     'datetime', ignored if datecol is not a string)
%  position = optional position for insertion of the columns (0 = beginning,
%    after date/time columns if omitted)
%
%outputs:
%  s2 = output structure with inserted columns;
%  msg = text of any error message
%
%
%(c)2002-2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 15-Oct-2013

s2 = [];
msg = '';

%check for required input
if nargin >= 1
   
   %validate optional arguments
   if exist('roundopt','var') ~= 1
      roundopt = '';
   end
   
   if exist('position','var') ~= 1
      position = [];
   elseif position < 0
      position = 0;
   end
   
   %validate data structure
   if gce_valid(s,'data')
      
      %check for omitted time column
      if exist('timecol','var') ~= 1
         timecol = [];
      elseif ischar(timecol)
         timecol = name2col(s,timecol);
      end
      
      %force column lookup if datecol omitted
      if exist('datecol','var') ~= 1
         datecol = [];
      elseif ischar(datecol)
         datecol = name2col(s,datecol);
      end
      
      %look up date field if not specified
      if isempty(datecol)
         
         %get index of floating-point datetime columns
         Icol = find(strcmp(s.datatype,'f') & strcmp(s.variabletype,'datetime'));
         
         %use first floating-point date col if found
         if length(Icol) >= 1
            if length(Icol) == 1
               datecol = Icol(1);
            else  %multiple floating-point datetime fields - look for first col starting with "date"
               Icol2 = find(strncmpi(s.name(Icol),'date',4));
               if length(Icol2) >= 1
                  datecol = Icol(Icol2(1));                  
               end
            end
         else   %no floating point date - look for string cols
            Icol = find(strcmp(s.datatype,'s') & strcmp(s.variabletype,'datetime'));
            if length(Icol) >= 1
               datecol = Icol(1);
            elseif length(Icol) > 1
               Icol2 = find(strncmpi(s.name(Icol),'date',4));
               if length(Icol2) >= 1
                  datecol = Icol(Icol2(1));
               end
            end
         end
      end
      
      d = [];  %init serial date
      
      %check for matched date column
      if ~isempty(datecol)
         
         %check for float or string dates
         if strcmp(s.variabletype{datecol},'datetime') && (strcmp(s.datatype{datecol},'f') || strcmp(s.datatype{datecol},'s'))
            
            %extract numeric date or handle string date and time cols
            if strcmp(s.datatype{datecol},'s')
               dstr = extract(s,datecol);
               d = repmat(NaN,length(dstr),1);
               tstr = [];
               if isempty(timecol)
                  Icol = find(strncmpi(s.name,'time',4) & strcmp(s.variabletype,'datetime'));
                  if length(Icol) >= 1
                     timecol = Icol(1);
                  end
               end
               if ~isempty(timecol)
                  t = extract(s,timecol);
                  if ~strcmp(s.datatype{timecol},'s')  %string date and numeric time
                     if max(t) < 2400
                        th = fix(t./100)./24;
                        tm = (t-fix(t./100).*100)./60./24;
                        t = th + tm;
                     else
                        t = zeros(length(str),1);
                     end
                     try
                        dnew = datenum(dstr);  %generate numeric dates
                     catch
                        try
                           dnew = datenum_iso(dstr);  %try iso variant if errors
                        catch
                           dnew = [];
                        end
                     end
                     if isnumeric(dnew) && ~isempty(dnew)
                        d = dnew + t;
                     end
                  else  %string date and time cols - concatenate to from date/time string
                     dstr = concatcellcols([dstr,t],' ');
                     try
                        dnew = datenum(dstr);
                     catch
                        try
                           dnew = datenum_iso(dstr);
                        catch
                           dnew = [];
                        end
                     end
                     if isnumeric(dnew) && ~isempty(dnew)
                        d = dnew;
                     end
                  end
               else  %string date col only
                  try
                     dnew = datenum(dstr);
                  catch
                     try
                        dnew = datenum_iso(dstr);
                     catch
                        dnew = [];
                     end
                  end
                  if isnumeric(dnew) && ~isempty(dnew)
                     d = dnew;
                  end
               end
            else  %numeric date
               d = extract(s,datecol);
            end
            
         end
         
      else  %try to calculate numeric days from date component columns, identified by name and datatype
         
         %get indices of date/time component columns
         ycol = find(strncmpi(s.name,'year',4) & strcmp(s.variabletype,'datetime') & ~strcmp(s.datatype,'s'));
         mcol = find(strncmpi(s.name,'month',5) & strcmp(s.variabletype,'datetime') & ~strcmp(s.datatype,'s'));
         dcol = find(strncmpi(s.name,'day',3) & strcmp(s.variabletype,'datetime') & ~strcmp(s.datatype,'s'));
         hcol = find(strncmpi(s.name,'hour',4) & strcmp(s.variabletype,'datetime') & ~strcmp(s.datatype,'s'));
         mincol = find(strncmpi(s.name,'minute',6) & strcmp(s.variabletype,'datetime') & ~strcmp(s.datatype,'s'));
         seccol = find(strncmpi(s.name,'second',6) & strcmp(s.variabletype,'datetime') & ~strcmp(s.datatype,'s'));
         
         %check for minimum columns, extract and combine to produce date
         if ~isempty(mcol) && ~isempty(dcol)
            mvals = extract(s,mcol(1));
            dvals = extract(s,dcol(1));
            numrows = size(mvals,1);
            if ~isempty(ycol)
               yvals = extract(s,ycol(1));
            else
               yvals = repmat(str2double(datestr(now,10)),numrows,1);
            end
            if ~isempty(hcol)
               hvals = extract(s,hcol(1));
            else
               hvals = zeros(numrows,1);
            end
            if ~isempty(mincol)
               minvals = extract(s,mincol(1));
            else
               minvals = zeros(length(numrows),1);
            end
            if ~isempty(seccol)
               secvals = extract(s,seccol(1));
            else
               secvals = zeros(length(numrows),1);
            end
            try
               d = datenum(yvals,mvals,dvals,hvals,minvals,secvals);  %calculate serial date
            catch
               d = [];
            end
            datecol = max([ycol,mcol,dcol,hcol,mincol,seccol]);  %get position of last column for positioning of YearDay
         end
         
      end
      
      %check for parsed dates
      if ~isempty(d)
         
         I = find(~isnan(d));  %get index of valid dates
         
         if ~isempty(I)  %check for valid dates to convert
            
            if log10(d(I(1))) < 5  %check for base 1900 dates
               d(I) = datecnv(d(I),'xl2mat');
            end
            
            yeardays = date2yearday(d,roundopt);  %calculate year day
            
            if ~isempty(yeardays)
               
               %determine position for new YearDay column after date/time columns used
               if isempty(position)
                  if ~isempty(timecol)
                     position = timecol + 1;
                  else
                     position = datecol + 1;
                  end
               end
               
               %delete existing YearDay column
               Iyearday = name2col(s,'YearDay');
               if ~isempty(Iyearday)
                  s = deletecols(s,Iyearday);
               end
               
               %define attribute metadata for YearDay
               dtype = 'd';
               ntype = 'discrete';
               prec = 0;
               
               %check for floating-point data if no rounding
               if isempty(roundopt)
                  Idec = find(yeardays-fix(yeardays));
                  if ~isempty(Idec)
                     dtype = 'f';
                     ntype = 'continuous';
                     prec = 3;
                  end
               end
               
               %add YearDay column
               [s2,msg] = addcol(s,yeardays, ...
                  'YearDay', ...
                  'day', ...
                  'Numerical year day (day number within the current year)', ...
                  dtype, ...
                  'datetime', ...
                  ntype, ...
                  prec, ...
                  'x<1=''I'';x>366=''I''', ...
                  position);
               
               if isempty(s2)
                  msg = ['an error occurred adding the YearDay column: ',msg];
               end
               
            else               
               msg = 'an error occurred calculating the year days from the specified date/time column';               
            end
            
         else            
            msg = 'date values are missing or invalid';            
         end
         
      else         
         msg = 'date column is invalid or could not be identified';         
      end
      
   else      
      msg = 'invalid GCE Data Structure';      
   end
   
else   
   msg = 'insufficient input arguments for function';   
end