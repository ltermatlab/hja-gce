function [data,colnames,sitenum,botdep,hdr] = parse_37sm(fn,pn,calc_depth,lat,fn2,pn2)
%Parses a processed data file (.asc) from a Seabird Electronics 37-SM Microcat
%and returns a standard data matrix and header array.
%
%syntax: [data,colnames,site,bottomdep,hdr] = parse_37sm(fn,pn,calc_depth,lat,fn2,pn2)
%
%inputs:
%  fn = name of file to parse  (obtained from prompted input if omitted)
%  pn = directory containing file to parse  (default = current directory)
%  calc_depth = option to calculate total depth if bottom depth information is present in 'parse_37sm.mat'
%    0 = no (default)
%    1 = yes
%  lat = latitude in decimal degrees (looked up based on site number derived
%        from filename or obtained by prompted input if omitted)
%  fn2 = name of an optional output file  (no output file if omitted or empty)
%  pn2 = directory for output file (same as pn if omitted)
%
%outputs:
%  data = n x 11-12 matrix of sonde data, containing columns
%     year (yyyy)
%     month (mm)
%     day (d)
%     minute (min)
%     second (sec)
%     temperature (°C)
%     conductivity (S/m)
%     pressure (dbar)
%     depth (m)
%     [totaldepth (m)]
%     salinity (PSU)
%     sigma_t
%  colnames = cell array of column names (for metadata lookup)
%  site = GCE site number determined from filename (for metadata lookup)
%  bottomdep = depth from substrate to pressure sensor (for documenting in metadata)
%  hdr = SBE header lines as a cell array of strings
%
%Note: this code is based on the function (mccnv.m) developed by the authors listed below:
%
%Susan Elston, Skidaway Institute of Oceanography, Savannah, Georgia, USA
%Julie Amft, Skidaway Institutde of Ocanography, Savannah, Georgia, USA
%
%Two autonomous m-files are also included in this file as subfunctions for convenience
%(see included help text for attribution and versioning information)
%  salsig2 -- by V. Holliday (as modified by Julie Amft)
%  sw_dpth -- by Phil Morgan <morgan@ml.csiro.au>
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
%last modified: 14-Apr-2015

data = [];
hdr = [];
sitenum = [];
colnames = [];
botdep = NaN;
curpath = pwd;

%validate input, prompt for missing filenames, etc.
if exist('calc_depth','var') ~= 1
   calc_depth = 0;
elseif ~isnumeric(calc_depth)
   calc_depth = 0;
end

%validate paths
if exist('pn','var') ~= 1
   pn = '';
end
if ~isdir(pn)
   pn = curpath;
elseif strcmp(pn(end),filesep)
   pn = pn(1:end-1);  %strip terminal separator
end

if exist('pn2','var') ~= 1
   pn2 = '';
end
if ~isdir(pn2)
   pn2 = pn;
elseif strcmp(pn2(end),filesep)
   pn2 = pn2(1:end-1);
end

%validate filenames
if exist('fn','var') ~= 1
   fn = '';
end

if exist('fn2','var') ~= 1
   fn2 = '';
end

%prompt for input file if missing/invalid
filemask = '*.asc;*.cnv';
if exist([pn,filesep,fn],'file') ~= 2
   if ~isempty(fn)
      filemask = fn;  %use invalid filename as mask for prompt
   end
   cd(pn)
   [fn,pn] = uigetfile(filemask,'Select a data file to parse');
   cd(curpath)
   drawnow
   if fn == 0
      fn = '';
   end
end

if ~isempty(fn)

   %init runtime parameters
   if exist('lat','var') ~= 1
      lat = [];
   end

   depths = [];

   if isempty(lat)

      if exist('parse_37sm.mat','file') == 2  %try to look up lat by site number in filename

         try
            sonde_info = load('parse_37sm.mat');  %load sonde location data
         catch
            sonde_info = struct('null','');
         end

         if isfield(sonde_info,'sondes')

            sondes = sonde_info.sondes;
            depths = sonde_info.depths;

            %get site number from filename
            if strcmpi(fn(1),'c')  %check for cal file
               sitenum = str2double(fn(2:3));
            else
               sitenum = str2double(fn(1:2));
            end

            %look up site record, get site name and latitude
            if ~isempty(sitenum)
               Isel = find([sondes.site]==sitenum);  %look for matching site number
               if ~isempty(Isel)
                  lat = sondes(Isel(1)).latitude;  %use latiutude for first matching site
               else
                  sitenum = [];
                  lat = [];
               end
            end

         end

      end

      if isempty(lat)  %prompt for latitude entry if couldn't look up

         %check for valid file, then prompt for lat input
         try
            fid = fopen([pn,filesep,fn],'r');
            str = fgetl(fid);
            fclose(fid);
            if ~isempty(find(strncmp('* Sea-Bird',str,10)))
               if isempty(findobj)  %check for GUI mode
   		         disp(' '); disp(' ')
         		   lat = input('Input the Latitude (in decimal format) of mooring:','s');
                  lat = str2double(lat);
               else
                  lat = 31.4;  %use central lat of GCE domain
               end
            else
               lat = [];  %invalid file
            end
         catch
            lat = [];  %errors reading file
         end

      end

   end

   %check for latitude parameter
   if ~isempty(lat)

      rowcnt = 0;

      %parse header, calculate # of header rows
      fid = fopen([pn,filesep,fn],'r');
      ln = fgets(fid);
      while ischar(ln)
         rowcnt = rowcnt + 1;
         if strncmpi(deblank(ln),'*END*',5)
            rowcnt = rowcnt + 3;
            ln = fgets(fid);
            break
         else
            hdr = [hdr ; {deblank(ln)}];
            ln = fgetl(fid);
         end
      end
      fclose(fid);

      %parse arrays using various alternative raw data format filters

      %try string date format
      err = 0;
      try
         [temp90,condS_m,press,da,mo_str,yr,hr,mn,sc] = textread([pn,filesep,fn],'%f, %f, %f, %d %s %d, %d:%d:%d', ...
            'headerlines',rowcnt);
         mo = sub_monthstring2num(mo_str);   %convert string month to numeric
      catch
         err = 1;
      end

      %try numerical date format
      if err == 1
         try
            [temp90,condS_m,press,mo,da,yr,hr,mn,sc] = textread([pn,filesep,fn],'%f, %f, %f, %d-%d-%d, %d:%d:%d', ...
               'headerlines',rowcnt);
            err = 0;
         catch
            err = 1;
         end
      end

      %try format with numerical data, no pressure
      if err == 1
         try
            [temp90,condS_m,mo,da,yr,hr,mn,sc] = textread([pn,filesep,fn],'%f, %f, %d-%d-%d, %d:%d:%d', ...
               'headerlines',rowcnt);
            press = zeros(length(temp90),1);  %use zero for pressure for bucket operation
            err = 0;
         catch
            err = 1;
         end
      end

      %try format with string date, no pressure
      if err == 1
         try
            [temp90,condS_m,da,mo_str,yr,hr,mn,sc] = textread([pn,filesep,fn],'%f, %f, %d %s %d, %d:%d:%d', ...
               'headerlines',rowcnt);
            press = zeros(length(temp90),1);  %use zero for pressure for bucket operation
            mo = sub_monthstring2num(mo_str);
            err = 0;
         catch
            err = 1;
         end
      end

      %try format with string date, pressure
      if err == 1
         try
            [temp90,condS_m,press,da,mo_str,yr,hr,mn,sc] = textread([pn,filesep,fn],'%f %f %f %d %s %d %d:%d:%d', ...
               'headerlines',rowcnt);
            mo = sub_monthstring2num(mo_str);
            err = 0;
         catch
            err = 1;
         end
      end

      %try space-delimited format with julian date and flag column
      if err == 1

         try
            [temp90,condS_m,press,juliandate,flag] = textread([pn,filesep,fn],' %f %f %f %f %f', ...
               'headerlines',rowcnt-3,'delimiter',' ');
            err = 0;  %reset error flag if successful file parsing
         catch
            err = 1;
         end

         %check for valid parsed arrays, calculate start date from header string
         if err == 0

            %check for start_time string in header
            Istart = find(strncmpi(hdr,'# start_time =',14));
            if ~isempty(Istart)
               str_start = hdr{Istart(1)}(15:end);  %extract date
               try
                  dt_start = datenum(str_start);
               catch
                  dt_start = [];
               end
               if ~isempty(dt_start)
                  dvec = datevec(dt_start);  %parse date components
                  yr = dvec(1);
               else
                  yr = NaN;
               end
            else
               yr = NaN;
            end

            %if no start date in header, use current year but check for prior year year day
            if isnan(yr)
               juliandate_now = date2yearday(now);
               dvec = datevec(now);
               yr = dvec(1);
               if max(juliandate) > juliandate_now
                  yr = yr - 1;  %use prior year if ending year day > current
               end
            end

            dt = yearday2date(juliandate,yr,0);  %convert julian date to matlab date with 0 offset
            [yr,mo,da,hr,mn,sc] = datevec(dt);  %parse date/time components from date vector

         end

      end

      %check for valid return data
      if err == 0

         %calculate intermediate terms for salsig2 function
         cond = condS_m * 10;          %calculate conductivity in mmho/cm
         depth = sw_dpth(press,lat);   %calculate depth from pressure (UNESCO algorithm)
         temp68 = temp90 * 1.00024;    %calculate temp68 for salinity calculation

         %calculate salinity, sigmat from depth, temp, cond using UNESCO algorithm
         [mcsal,mcsigmat] = salsig2(depth,temp68,cond);
         sal = real(mcsal);          %salsig makes complex #s if dep & cond are negative
         sigmat = real(mcsigmat);    %salsig makes complex #s if dep & cond are negative

         %check for deployment depths structure
         if exist('depths','var') == 1 && ~isempty(sitenum)

            botdep = NaN;
            maxdate = max(datenum(yr,mo,da,hr,mn,zeros(length(mn),1)));
            if ~isempty(maxdate)
               s = querydata(depths,['Deployment=',int2str(sitenum),' & Date<=',num2str(maxdate)]);
               if ~isempty(s)
                  dep = extract(s,'DepthToBottom');
                  botdep = dep(end);
               end
            end

            % order columns of output file:
            if calc_depth == 1

               data = [yr mo da hr mn sc temp90 condS_m press depth depth+botdep sal sigmat];

               colnames = [{'Year'}, ...
                     {'Month'}, ...
                     {'Day'}, ...
                     {'Hour'}, ...
                     {'Minute'}, ...
                     {'Second'}, ...
                     {'Temperature'}, ...
                     {'Conductivity'}, ...
                     {'Pressure'}, ...
                     {'Depth'}, ...
                     {'TotalDepth'}, ...
                     {'Salinity'}, ...
                     {'Sigma_t'}];

               % SAVE OUT FILE (*.out):
               if ~isempty(fn2)
                  fid2 = fopen([pn2,filesep,fn2],'w');
                  fprintf(fid2,'%04d %02d %02d %02d %02d %02d %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f\n',data');
                  fclose(fid2);
               end

            else

               data = [yr mo da hr mn sc temp90 condS_m press depth sal sigmat];

               colnames = [{'Year'}, ...
                     {'Month'}, ...
                     {'Day'}, ...
                     {'Hour'}, ...
                     {'Minute'}, ...
                     {'Second'}, ...
                     {'Temperature'}, ...
                     {'Conductivity'}, ...
                     {'Pressure'}, ...
                     {'Depth'}, ...
                     {'Salinity'}, ...
                     {'Sigma_t'}];

               % SAVE OUT FILE (*.out):
               if ~isempty(fn2)
                  cd(pn2)
                  fid2 = fopen([pn2,filesep,fn2],'w');
                  fprintf(fid2,'%04d %02d %02d %02d %02d %02d %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f\n',data');
                  fclose(fid2);
               end

            end

         else

            % order columns of output file:
            data = [yr mo da hr mn sc temp90 condS_m press depth sal sigmat];

            colnames = [{'Year'}, ...
                  {'Month'}, ...
                  {'Day'}, ...
                  {'Hour'}, ...
                  {'Minute'}, ...
                  {'Second'}, ...
                  {'Temperature'}, ...
                  {'Conductivity'}, ...
                  {'Pressure'}, ...
                  {'Depth'}, ...
                  {'Salinity'}, ...
                  {'Sigma_t'}];

            % SAVE OUT FILE (*.out):
            if ~isempty(fn2)
               fid2 = fopen([pn2,filesep,fn2],'w');
               fprintf(fid2,'%04d %02d %02d %02d %02d %02d %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f\r',data');
               fclose(fid2);
            end

         end

      else  %couldn't parse data
         data = [];
         hdr = [];
      end

   end

end


%define subfunctions

function [sal,sigmat]=salsig2(depth,temp,cond)
% [sal,sigmat]=salsig2(depth,temp,cond);
%
% This matlab function calculates salinity and sigma-t values.
%
% It was modified by Julie Amft on 18 Mar 1992 from a script file that Tom Gross
% retrieved via TELEMAIL 8 Dec 1989 from V.Holliday.
% The original program (salsig.m) read several parameters from the keyboard,
% but these are now variables that are passed into the function;
% the parameters are depth (in meters), temperature (in deg C) and conductivity
% (in mmho/cm).
% The conductivity and temperature are used to calculate salinity.
% The salinity and temperature are used to calculate sigma-t.
%
% *** 2 constants were changed on 06 May 1992 to match Sea-Bird software:
% ***   (by J. Amft)
% ***
% ***   r18 = 42.914;
% ***   a2 = (((5.3875e-9.*t - 8.2467e-7*onev).*t + 7.6438e-5*onev).*t ...
% ***        - 4.0899e-3*onev).*t + 8.24493e-1*onev;

% Set constants for salinity calculation
r0 = .008;
r1 = -.1692;
r2 = 25.3851;
r3 = 14.0941;
r4 = -7.0261;
r5 = 2.7081;
r6 = .6766097;
r7 = 2.00564e-2;
r8 = 1.104259e-4;
r9 = -6.9698e-7;
r10 = 1.0031e-9;
r11 = 3.426e-2;
r12 = 4.464e-4;
r13 = .4215;
r14 = -3.107e-3;
r15 = 2.07e-4;
r16 = -6.37e-8;
r17 = 3.989e-12;

% in the orig program: r18 = 42.909;
r18 = 42.914;

r19 = .0005;
r20 = -.0056;
r21 = -.0066;
r22 = -.0375;
r23 = .0636;
r24 = -.0144;
r25 = .0162;

ndepth = - depth;

onev = ones(length(depth),1);
dcor = .1*depth;

% Calculate salinity:
a = r6*onev + r7*temp + r8*temp.^2 + r9*temp.^3 + r10*temp.^4;
r = cond / r18;
b = onev + dcor.*(r15*onev + r16*dcor + r17*dcor.^2) ./ ...
   (onev + r11*temp + r12*temp.^2 + r.*(r13*onev + r14*temp));
c = r ./ (b .* a);
s = r0*onev + r1*c.^0.5 + r2*c + r3*c.^1.5 + r4*c.^2 + r5*c.^2.5;
u = (temp-15*onev) ./ (onev + r25*(temp - 15*onev));
u = (r19*onev + r20*c.^.5 + r21*c + r22*c.^1.5 + r23*c.^2 + ...
   r24*c.^2.5) .* u;
sal = s + u;

% Calculate sigma-t:
t = temp;
s = sal;
a1 = ((((6.536332e-9*t - 1.120083e-6*onev).*t ...
   + 1.001685e-4*onev).*t -9.095290e-3*onev).*t...
   + 6.793952e-2*onev).*t + 999.842594*onev;

% in the orig program:
%      a2 = (((5.3875e-9.*t + 8.2467e-7*onev).*t + 7.6438e-5*onev).*t ...
%           - 4.0899e-3*onev).*t + 8.24493e-1*onev;
a2 = (((5.3875e-9.*t - 8.2467e-7*onev).*t + 7.6438e-5*onev).*t ...
   - 4.0899e-3*onev).*t + 8.24493e-1*onev;

a3 = (-1.6546e-6*t + 1.0227e-4*onev).*t - 5.72466e-3*onev;
a4 = 4.8314e-4;
rs = sqrt(abs(s));
sigmat = (a4*s + a3.*rs +a2.*onev).*s + a1.*onev - 1000*onev;
return

function DEPTHM = sw_dpth(P,LAT)

% SW_DPTH    Depth from pressure
%===========================================================================
% SW_DPTH   $Revision: 1.3 $  $Date: 1994/10/10 04:56:32 $
%           Copyright (C) CSIRO, Phil Morgan 1992.
%
% USAGE:  dpth = sw_dpth(P,LAT)
%
% DESCRIPTION:
%    Calculates depth in metres from pressure in dbars.
%
% INPUT:  (all must have same dimensions)
%   P   = Pressure    [db]
%   LAT = Latitude in decimal degress north [-90..+90]
%         (lat may have dimensions 1x1 or 1xn where P(mxn).
%
% OUTPUT:
%  dpth = depth [metres]
%
% AUTHOR:  Phil Morgan 92-04-06  (morgan@ml.csiro.au)
%
% DISCLAIMER:
%   This software is provided "as is" without warranty of any kind.
%   See the file sw_copy.m for conditions of use and licence.
%
% REFERENCES:
%    Unesco 1983. Algorithms for computation of fundamental properties of
%    seawater, 1983. _Unesco Tech. Pap. in Mar. Sci._, No. 44, 53 pp.
%=========================================================================

% CALLER:  general purpose
% CALLEE:  none

%-------------
% CHECK INPUTS
%-------------

[mP,nP] = size(P);
[mL,nL] = size(LAT);
if mL==1 && nL==1
   LAT = LAT*ones(size(P));
end %if

if (mP~=mL) || (nP~=nL)            % P & LAT are not the same shape
   if (nP==nL) && (mL==1)          % LAT for each column of P
      LAT = LAT( ones(1,mP), : ); %     copy LATS down each column
      %     s.t. dim(P)==dim(LAT)
   else
      error('sw_depth.m:  Inputs arguments have wrong dimensions')
   end %if
end %if

Transpose = 0;
if mP == 1  % row vector
   P         =  P(:);
   LAT       =  LAT(:);
   Transpose = 1;
end %if

%-------------
% BEGIN
%-------------
% Eqn 25, p26.  Unesco 1983.

DEG2RAD = pi/180;
c1 = +9.72659;
c2 = -2.2512E-5;
c3 = +2.279E-10;
c4 = -1.82E-15;
gam_dash = 2.184e-6;

LAT = abs(LAT);
X   = sin(LAT*DEG2RAD);  % convert to radians
X   = X.*X;
bot_line = 9.780318*(1.0+(5.2788E-3+2.36E-5*X).*X) + gam_dash*0.5*P;
top_line = (((c4*P+c3).*P+c2).*P+c1).*P;
DEPTHM   = top_line./bot_line;

if Transpose
   DEPTHM = DEPTHM';
end %if

return


function mo = sub_monthstring2num(mo_str)
%converts month strings to numerical months

mo = zeros(size(mo_str));
mo(strcmp(mo_str,'Jan')) = 1;
mo(strcmp(mo_str,'Feb')) = 2;
mo(strcmp(mo_str,'Mar')) = 3;
mo(strcmp(mo_str,'Apr')) = 4;
mo(strcmp(mo_str,'May')) = 5;
mo(strcmp(mo_str,'Jun')) = 6;
mo(strcmp(mo_str,'Jul')) = 7;
mo(strcmp(mo_str,'Aug')) = 8;
mo(strcmp(mo_str,'Sep')) = 9;
mo(strcmp(mo_str,'Oct')) = 10;
mo(strcmp(mo_str,'Nov')) = 11;
mo(strcmp(mo_str,'Dec')) = 12;

return