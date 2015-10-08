function [s,msg] = imp_hobo_tidbit(fn,pn,template,site,location)
%Imports data from a Hobo Tidbit temperature logger exported in ASCII boxcar format
%
%syntax:  [s,msg] = imp_hobo_tidbit(fn,pn,template,site,location)
%
%inputs:
%  fn = file name to import (prompted if omitted)
%  pn = pathname for fn (current directory if omitted)
%  template = metadata template to use (default = 'GCE_Hobo_Tidbit')
%  site = site code (default = '')
%  location = location code (default = '')
%
%outputs:
%  s = GCE Data Structure
%  msg = text of any error messages
%
%(c)2010-2012 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 06-Apr-2012

%initialize outputs:
s = [];
msg = '';

%define parameters
curpath = pwd;
format_string = '%d/%d/%d %d:%d:%f %f';
column_names = 'Month,Day,Year,Hour,Minute,Second,Temperature';
num_header_rows = 1;
missing_codes = '';

if exist('template','var') ~= 1
   template = 'GCE_Hobo_Tidbit';
end

%validate path
if exist('pn','var') ~= 1
   pn = curpath;
elseif exist(pn,'dir') ~= 7
   pn = curpath;
elseif strcmp(pn(end),filesep)
   pn = pn(1:end-1);
end

%prompt for file if omitted or invalid
if exist('fn','var') ~= 1
   cd(pn)
   [fn,pn] = uigetfile('*.txt;*.dat;*.prn;*.asc;*.ans','Select a text file to import');
   cd(curpath)
elseif exist([pn,filesep,fn],'file') ~= 2
   cd(pn)
   [fn,pn] = uigetfile(fn,'Locate the text file to import');
   cd(curpath)
end
drawnow

%pass filename, pathname, and static parameters to custom ASCII import filter
if fn ~= 0

  %import data
  [s,msg] = imp_ascii(fn,pn,'','',format_string,column_names,num_header_rows,missing_codes);

  if ~isempty(s)

     %convert year to 4 digits
     yr = extract(s,'Year');
     Iupdate = find(yr < 100);
     if ~isempty(Iupdate)
        yr(Iupdate) = yr(Iupdate) + 2000;
        s = update_data(s,'Year',yr,0);
     end

     %round to even 10 seconds
     sc = extract(s,'Second');
     sc = round(sc .* 0.1) .* 10;
     s = update_data(s,'Second',sc,0);

     %reorder columns
     s = copycols(s,{'Year','Month','Day','Hour','Minute','Second','Temperature'});

     %add metadata
     s = apply_template(s,template);

     %add MATLAB serial date column, get serial dates for title generation
     s = add_datecol(s);
     dt = extract(s,'Date');

     %check for site input
     if exist('site','var') == 1  && ~isempty(site)
        pos = name2col(s,'Temperature');
        s = addcol(s,site,'Site','none','Deployment site','s','nominal','none',0,'',pos);
     end

     %check for location input
     if exist('location','var') == 1 && ~isempty(location)
        pos = name2col(s,'Temperature');
        s = addcol(s,location,'Location','none','Deployment location','s','nominal','none',0,'',pos);
        s = add_sitemetadata(s,'Location');
        titlestr = ['Hobo TidBit temperature logger data from ',location];
     else
        titlestr = ['Hobo TidBit temperature logger data imported from ',fn];
     end
     titlestr = [titlestr,' for ',datestr(min(dt),1),' to ',datestr(max(dt),1)];

     %generate title
     s = newtitle(s,titlestr);

     %add relevant dates to metadata
     d = dir([pn,filesep,fn]);
     if length(d) == 1
        submitdate = datenum(d.date);
     else
        submitdate = now;
     end
     newmeta = {'Dataset','SubmitDate',datestr(submitdate,1); ...
        'Status','ProjectRelease',datestr(now,1); ...
        'Status','PublicRelease',datestr(now+365,1); ...
        'Status','MetadataUpdate',datestr(now,1)};
     s = addmeta(s,newmeta);

  end

else
  msg = 'import cancelled';
end