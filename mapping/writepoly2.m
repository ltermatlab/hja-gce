function writepoly2(polydata,units,fn,pn)
%Writes specific geographic information about map polygons to disk in tabular
%form as a tab-delimited ASCII file.
%
%syntax: writepoly2(polydata,units,fn,pn)
%
%input:
%  polydata = structure containing polygon data (from 'poly_mgr.m')
%  units = deg, dms, utm (default = utm)
%  fn = filename
%  pn = pathname
%
%output:
%  none
%
%(c)2002,2003,2004 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 30-Nov-2001

msg = '';

if nargin >= 1

   if isstruct(polydata)

      if isfield(polydata,'list')

         curpath = pwd;

         if ~exist('pn')
            pn = curpath;
         end

         eval(['cd ''',pn,''''],['cd ''',curpath,''''])

         if ~exist('fn')
            [fn,pn] = uiputfile('*.txt','Select a file name and directory for the output file');
            drawnow
         end

         if ~exist('units')
            units = UTM;
         else
            units = upper(units);
         end

         if fn ~= 0

            eval(['cd ''',pn,''''])

            listitems = polydata.list;
            data = polydata.data;
            ctrpos = polydata.center;

            fid = fopen(fn,'w');

            switch units

            case 'DEG'

               fprintf(fid,'Name\tCenter_Lon\tCenter_Lat\tW_Lon\tE_Lon\tS_Lat\tN_Lat\tPolygon\r');

               for n = 1:length(data)

                  ctr = ctrpos{n};
                  ctrlon = ctr(1);
                  ctrlat = ctr(2);

                  pos = data{n};
                  lon = pos(:,1);
                  lat = pos(:,2);

                  minlon = min(lon);
                  maxlon = max(lon);
                  minlat = min(lat);
                  maxlat = max(lat);

                  polyname = listitems{n};

                  polygon = sprintf('%0.6f, %0.6f',pos(1,1),pos(1,2));
                  for m = 2:size(pos,1)
                     polygon = [polygon,'; ',sprintf('%0.6f, %0.6f',pos(m,1),pos(m,2))];
                  end

                  fprintf(fid,'%s\t%0.6f\t%0.6f\t%0.6f\t%0.6f\t%0.6f\t%0.6f\t%s\r', ...
                     polyname,ctrlon,ctrlat,minlon,maxlon,minlat,maxlat,polygon);

               end

            case 'DMS'

               fprintf(fid,'Name\tCenter_Lon\tCenter_Lat\tW_Lon\tE_Lon\tS_Lat\tN_Lat\tPolygon\r');

               for n = 1:length(data)

                  ctr = ctrpos{n};
                  ctrlon = ctr(1);
                  ctrlat = ctr(2);

                  pos = data{n};
                  lon = pos(:,1);
                  lat = pos(:,2);

                  minlon = min(lon);
                  maxlon = max(lon);
                  minlat = min(lat);
                  maxlat = max(lat);

                  polyname = listitems{n};

                  lonstr = 'EW';
                  latstr = 'NS';

                  ctrstr = sprintf('%03d %02d %05.2f %s\t%02d %02d %05.2f %s',ddeg2dms(abs(ctr(1))),lonstr(1,(ctr(1)<0)+1),ddeg2dms(ctr(2)),latstr(1,(ctr(2)<0)+1));
                  wbound = sprintf('%03d %02d %05.2f %s',ddeg2dms(abs(minlon)),lonstr(1,(minlon<0)+1));
                  ebound = sprintf('%03d %02d %05.2f %s',ddeg2dms(abs(maxlon)),lonstr(1,(maxlon<0)+1));
                  nbound = sprintf('%02d %02d %05.2f %s',ddeg2dms(maxlat),latstr(1,(maxlat<0)+1));
               	sbound = sprintf('%02d %02d %05.2f %s',ddeg2dms(minlat),latstr(1,(minlat<0)+1));

                  fstr = '%03d %02d %05.2f %s, %02d %02d %05.2f %s';
                  polygon = sprintf(fstr,ddeg2dms(abs(pos(1,1))),lonstr(1,(pos(1,1)<0)+1), ...
                           ddeg2dms(abs(pos(1,2))),latstr(1,(pos(1,2)<0)+1));
                  for m = 2:size(pos,1)
                     polygon = [polygon,'; ',sprintf(fstr,ddeg2dms(abs(pos(m,1))),lonstr(1,(pos(m,1)<0)+1), ...
                           ddeg2dms(abs(pos(m,2))),latstr(1,(pos(m,2)<0)+1))];
                  end

                  fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\r', ...
                     polyname,ctrstr,wbound,ebound,sbound,nbound,polygon);

               end

            otherwise  %UTM (or default to UTM if invalid)

               fprintf(fid,'Name\tCenter_Easting\tCenter_Northing\tW_Easting\tE_Easting\tS_Northing\tN_Northing\tPolygon\tZone\tHemisphere\r');

               for n = 1:length(data)

                  ctr = ctrpos{n};
                  ctrlon = ctr(1);
                  ctrlat = ctr(2);

                  pos = data{n};
                  lon = pos(:,1);
                  lat = pos(:,2);

                  minlon = min(lon);
                  maxlon = max(lon);
                  minlat = min(lat);
                  maxlat = max(lat);

                  [ctrzone,ctre,ctrn,ctrhem] = deg2utm(ctrlon,ctrlat);
                  [zone,east,north,hem] = deg2utm(lon,lat);
                  [zone_sw,e_sw,n_sw,hem_sw] = deg2utm(minlon,minlat);
                  [zone_ne,e_ne,n_ne,hem_ne] = deg2utm(maxlon,maxlat);

                  polyname = listitems{n};

                  polygon = sprintf('%d, %0.2f, %0.2f, %s',zone(1),east(1),north(1),hem(1));
                  for m = 2:size(pos,1)
                     polygon = [polygon,'; ',sprintf('%d, %0.2f, %0.2f, %s',zone(1),east(m),north(m),hem(1))];
                  end

                  fprintf(fid,'%s\t%0.2f\t%0.2f\t%0.2f\t%0.2f\t%0.2f\t%0.2f\t%s\t%d\t%s\r', ...
                     polyname,ctre,ctrn,e_sw,e_ne,n_sw,n_ne,polygon,zone_sw,hem_sw);

               end

            end

            fclose(fid);

            eval(['cd ''',curpath,''''])

         end

      end

   end

end
