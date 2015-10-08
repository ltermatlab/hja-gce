function msg = writepoly(polydata,fn,pn)
%Writes full geographic information about map polygons to disk in tab-delimited
%ASCII format (called by 'poly_mgr.m' using the 'export' button)
%
%syntax: msg = writepoly(polydata,fn,pn)
%
%input:
%  polydata = polydata structure (from poly_mgr.m)
%  fn = filename
%  pn = pathname for file
%
%output:
%  msg = status message
%
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
%last modified: 02-Sep-2004

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

         if fn ~= 0

            eval(['cd ''',pn,''''])

            listitems = polydata.list;
            data = polydata.data;
            ctrpos = polydata.center;

            if abs(data{1}(1,1)) <= 360
               mode = 'deg';
            else
               mode = 'utm';
            end

            fid = fopen(fn,'w');

            for n = 1:length(data)

               ctr = ctrpos{n};
               pos = data{n};

               if strcmp(mode,'deg')

                  ctrlon = ctr(1);
                  ctrlat = ctr(2);
                  [ctrzone,ctre,ctrn,ctrhem] = deg2utm(ctrlon,ctrlat);

                  lon = pos(:,1);
                  lat = pos(:,2);
                  [zone,east,north,hem] = deg2utm(lon,lat);

                  minlon = min(lon);
                  maxlon = max(lon);
                  minlat = min(lat);
                  maxlat = max(lat);

                  [zone_sw,e_sw,n_sw,hem_sw] = deg2utm(minlon,minlat);
                  [zone_nw,e_nw,n_nw,hem_nw] = deg2utm(minlon,maxlat);
                  [zone_ne,e_ne,n_ne,hem_ne] = deg2utm(maxlon,maxlat);
                  [zone_se,e_se,n_se,hem_se] = deg2utm(maxlon,minlat);

                  ar_km2 = sitearea([lon,lat],'km2','deg');
                  ar_hect = ar_km2 .* 100;

               else  %utm

                  ctrzone = 17;
                  ctre = ctr(1);
                  ctrn = ctr(2);
                  ctrhem = 'N';
                  [ctrlon,ctrlat] = utm2deg(ctrzone,ctre,ctrn,ctrhem,'WGS84');

                  east = pos(:,1);
                  north = pos(:,2);
                  zone = repmat(17,size(east,1),1);
                  hem = repmat('N',size(east,1),1);
                  [lon,lat] = utm2deg(zone,east,north,hem,'WGS84');

                  minlon = min(lon);
                  maxlon = max(lon);
                  minlat = min(lat);
                  maxlat = max(lat);

                  zone_sw = 17; zone_nw = 17; zone_ne = 17; zone_se = 17;
                  hem_sw = 'N'; hem_nw = 'N'; hem_ne = 'N'; hem_se = 'N';
                  e_sw = min(east);
                  e_nw = e_sw;
                  e_ne = max(east);
                  e_se = e_ne;
                  n_sw = min(north);
                  n_se = n_sw;
                  n_nw = max(north);
                  n_ne = n_nw;

                  ar_km2 = sitearea([lon,lat],'km2','deg');
                  ar_hect = ar_km2 .* 100;

               end

               lonstr = 'EW';
               latstr = 'NS';

               fstr = '\t%0.6f\t%0.6f\t%03d %02d %05.2f %s\t%02d %02d %05.2f %s\t%d\t%0.2f\t%0.2f\t%s\r';
               hstr = '\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\r';

               fprintf(fid,'Polygon name:\t%s\r\r',listitems{n});

               if ~isempty(ar_km2)
                  fprintf(fid,'Surface Area:\t%0.4f km^2\t%0.2f hectares\r\r',ar_km2,ar_hect);
               end

               fprintf(fid,['Parameter',hstr],'Lon(deg)','Lat(deg)','Lon(dms)', ...
                     'Lat(dms)','UTM_Zone','UTM_East(m)','UTM_North(m)','UTM_Hem');

               fprintf(fid,['Geo Center',fstr], ...
                  ctrlon,ctrlat,ddeg2dms(abs(ctrlon)),lonstr(1,(ctrlon<0)+1),ddeg2dms(abs(ctrlat)), ...
                  latstr(1,(ctrlat<0)+1),ctrzone,ctre,ctrn,ctrhem);
               fprintf(fid,['SW Boundary',fstr], ...
                  minlon,minlat,ddeg2dms(abs(minlon)),lonstr(1,(minlon<0)+1),ddeg2dms(abs(minlat)), ...
                  latstr(1,(minlat<0)+1),zone_sw,e_sw,n_sw,hem_sw);
               fprintf(fid,['NW Boundary',fstr], ...
                  minlon,maxlat,ddeg2dms(abs(minlon)),lonstr(1,(minlon<0)+1),ddeg2dms(abs(maxlat)), ...
                  latstr(1,(maxlat<0)+1),zone_nw,e_nw,n_nw,hem_nw);
               fprintf(fid,['NE Boundary',fstr], ...
                  maxlon,maxlat,ddeg2dms(abs(maxlon)),lonstr(1,(maxlon<0)+1),ddeg2dms(abs(maxlat)), ...
                  latstr(1,(maxlat<0)+1),zone_ne,e_ne,n_ne,hem_ne);
               fprintf(fid,['SE Boundary',fstr], ...
                  maxlon,minlat,ddeg2dms(abs(maxlon)),lonstr(1,(maxlon<0)+1),ddeg2dms(abs(minlat)), ...
                  latstr(1,(minlat<0)+1),zone_se,e_se,n_se,hem_se);

               fprintf(fid,['\rCoordinate',hstr],'Lon(deg)','Lat(deg)','Lon(dms)', ...
                     'Lat(dms)','UTM_Zone','UTM_East(m)','UTM_North(m)','UTM_Hem');

               for m = 1:size(pos,1)
	               fprintf(fid,['%d',fstr], ...
                     m,lon(m),lat(m),ddeg2dms(abs(lon(m))),lonstr(1,(lon(m)<0)+1), ...
                     ddeg2dms(abs(lat(m))),latstr(1,(lat(m)<0)+1),zone(m),east(m),north(m),hem(m));
               end

               fprintf(fid,'\r\r\r');

            end

            fclose(fid);

            eval(['cd ''',curpath,''''])

         end

      end

   end

end
