function [lat,lon] = parse_gps(gps,format)
%Parses latitude and longitude from formatted GPS data strings
%
%syntax: [lat,lon] = parse_gps(gps,format)
%
%input:
%  gps = GPS data (character array or cell-array of strings with consistent formatting)
%  format = coordinate format option:
%    0 = automatic
%    1 = degrees and minutes (e.g. 29° 30.9' N, 81° 25.55' W)
%    2 = degrees, minutes and seconds (e.g. 29° 20' 30.9" N, 81° 30' 25.55" W)
%
%output:
%  lat = latitude in decimal degrees
%  lon = longitude in decimal degrees
%
%(c)2010 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 03-Jan-2010

%init output
lat = [];
lon = [];

if nargin >= 1
   
   %apply default format option if omitted
   if exist('format','var') ~= 1
      format = 0;
   end
   
   %convert character array to cell array
   if ischar(gps)
      gps = cellstr(gps);
   end
   
   %remove degree, minute, second symbols from strings and replace N/E and S/W with integer multipliers
   gps = regexprep(gps,'°|''|"',' ');
   gps = regexprep(gps,'N|E','1');
   gps = regexprep(gps,'S|W','-1');
   
   %determine format automatically
   if format == 0
      try
         ar = sscanf(gps{1},'%d %f %d, %d %f %d');
      catch
         ar = [];
      end
      if length(ar) == 6
         format = 1;
      else
         try
            ar = sscanf(gps{1},'%d %d %f %d, %d %d %f %d');
         catch
            ar = [];
         end
         if length(ar) == 8
            format = 2;
         end
      end      
   end
   
   %generate format string
   switch format
      case 1
         fstr = '%d %f %d, %d %f %d';
         num = 6;
      case 2
         fstr = '%d %d %f %d, %d %d %f %d';
         num = 8;
      otherwise
         fstr = '';
         num = 0;
   end

   if ~isempty(fstr)
      
      %init lat, lon
      lat = repmat(NaN,length(gps),1);
      lon = lat;
      
      %loop through gps, parsing strings
      for n = 1:length(gps)
         try
            ar = sscanf(gps{n},fstr);
         catch
            ar = [];
         end
         if length(ar) == num  %check for successful parsing of all terms
            if format == 1
               lat(n) = (ar(1) + ar(2)./60) .* ar(3);  %calc lat from deg, min
               lon(n) = (ar(4) + ar(5)./60) .* ar(6);  %calc lon from deg, min
            else
               lat(n) = (ar(1) + ar(2)./60 + ar(3)./3600) .* ar(4);  %calc lat from deg, min, sec
               lon(n) = (ar(5) + ar(6)./60 + ar(7)./3600) .* ar(8);  %calc lon from deg, min, sec
            end
         end
      end
      
      %check for empty lon/lat arrays, return null results
      if isempty(find(~isnan(lat))) || isempty(find(~isnan(lon)))
         lon = [];
         lat = [];
      end
   end
      
end