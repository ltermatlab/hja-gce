function [axlims,aspect] = gpsaxis(gps,mode,boundary)
%Returns axis scaling array and aspect ratio to plot 'gps' on a map
%
%syntax: [axlims,aspect] = gpsaxis(gps,mode,boundary)
%
%input:
%  gps = 2-column array of longitudes and latitudes in degrees
%
%  mode = specifies the form factor for calculations:
%     0 - calculates appropriate limits for the prevaling axis aspect ratio (default)
%     1 - calculates appropriate limits for a fixed 1:1 aspect ratio
%       with the 'gps' data range centered in the plot; note that the
%       actual aspect ratio of the current axes will not be changed by
%       running GPSAXIS, so this mode setting may yield inaccurate results
%       unless the axis aspect ratio is set to 'aspect'
%     2 - calculates both the limits and appropriate aspect ratio for
%       an optimal (i.e. tightly conscribed) geographically-correct plot
%
%output:
%  boundary = specifies the minimum whitespace between the gps data and axes in km (default = 0)
%  axlims = a 4-element vector for use with Matlab's 'axis' command
%  aspect = a 2- or 3-element vector of values to set the appropriate
%     aspect ratio for the current axis (ML 4.x: 2-element vector formatted
%     for the 'AspectRatio' property; ML 5.x: 3-element vector formatted for
%     the 'PlotBoxAspectRatio' property)
%
%Matlab 4.x Example: axis(axlims); set(gca,'AspectRatio',aspect)
%Matlab 5.x Example: axis(axlims); set(gca,'PlotBoxAspectRatio',aspect)
%
%(c)2004 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 30-Jun-2004

%get Matlab version number
mlverstr = version;
mlversion = str2num(mlverstr(1:3));

if exist('mode') ~= 1
   mode = 0;
end

if exist('boundary') ~= 1
   boundary = 0;
end

if ~isempty(gps)

   gps = gps(find(gps(:,1)),1:2);  %compress data to remove blanks
   midlat = (max(gps(:,2)-min(gps(:,2))))./2;

   if boundary > 1
      if abs(gps(1,1)) <= 360
         offsets = [boundary./(cos(midlat.*pi./180).*111.111) boundary./111.111];
      else
         offsets = offsets .* 1000;  %assume utm in m
      end
   else
      offsets = [0 0];
   end

   if mode < 2

      if mlversion(1) < 5
         if mode == 0
            ar = get(gca,'AspectRatio');
            if ~isnan(ar(1))
               ar_factor = 1./ar(1);
            else
               ar_factor = 1;
            end
         else
            ar = [1 NaN];
            ar_factor = 1;
         end
      else
         if mode == 0
            ar = get(gca,'PlotboxAspectRatio');
            ar_factor = 1./ar(1);
         else
            ar = [1 1 1];
            ar_factor = 1;
         end
      end

      if abs(gps(1,1)) <= 360  %degrees

         long_rng = max(gps(:,1)) - min(gps(:,1));
         lat_rng = max(gps(:,2)) - min(gps(:,2));

         longctr = min(gps(:,1)) + long_rng * 0.5;
         latctr = min(gps(:,2)) + lat_rng * 0.5;

         if (lat_rng * ar_factor) > long_rng.*(cos(latctr*pi/180))  %vertical bias
            dlong = (lat_rng + offsets(1)) / cos(latctr * pi/180) / 2;
            dlat = (lat_rng + offsets(1)) * ar_factor / 2;
         else  %horizontal bias
            dlong = (long_rng + offsets(2)) / 2;
            dlat = (long_rng + offsets(2)) * cos(latctr * pi/180) * ar_factor/2;
         end

         axlims = [longctr-dlong longctr+dlong latctr-dlat latctr+dlat];

      else  %utm or unspecified

         axlims = [min(gps(:,1)),max(gps(:,1)),min(gps(:,2)),max(gps(:,2))];

      end

      aspect = ar;

   else  %determine optimal axis properties

      long_rng = max(gps(:,1)) - min(gps(:,1));
      lat_rng = max(gps(:,2)) - min(gps(:,2));

      longctr = min(gps(:,1)) + long_rng * 0.5;
      latctr = min(gps(:,2)) + lat_rng * 0.5;

      dlong = (long_rng + offsets(2)) / 2;
      dlat = (lat_rng + offsets(2)) / 2;

      axlims = [longctr-dlong longctr+dlong latctr-dlat latctr+dlat];

      latdist = gpsdistk([axlims(1) axlims(3)],[axlims(1) axlims(4)]);
      londist = gpsdistk([axlims(1) mean([axlims(3) axlims(4)])], ...
         [axlims(2) mean([axlims(3) axlims(4)])]);

      if mlversion < 5
         aspect = [(londist ./ latdist) NaN];
      else
         aspect = [(londist ./ latdist) 1 1];
      end

   end

else

   axlims = [];
   aspect = [];

end