function [wboundlon,eboundlon,sboundlat,nboundlat] = get_metadata_bbox(s)
%Parses geographic coordinates in GCE Data Structure metadata to return bounding box coordinates
%based on formatted bounding box and point location coordinates in the Site/Coordinates metadata
%
%syntax: [wboundlon,eboundlon,sboundlat,nboundlat] = get_metadata_bbox(s)
%
%input:
%  s = data structure to evaluate
%
%output:
%  wboundlon = west bounding longitude in decimal degrees
%  eboundlon = east bounding longitude in decimal degrees
%  sboundlat = south bounding latitude in decimal degrees
%  nboundlat = norht bounding latitude in decimal degrees
%
%usage notes:
%  1) unmatched boundaries return NaN
%
%
%(c)2010-2011 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 07-Sep-2011

%init output
wboundlon = NaN;
eboundlon = NaN;
sboundlat = NaN;
nboundlat = NaN;

if gce_valid(s,'data') == 1

   %get formatted coordinates from metadata
   str = lookupmeta(s,'Site','Coordinates');

   if ~isempty(str)

      %init boundaries
      wboundlon = inf;
      eboundlon = -inf;
      sboundlat = inf;
      nboundlat = -inf;

      %remove geo corner labels
      str = strrep(strrep(strrep(strrep(str,'NW: ',''),'SW: ',''),'NE: ',''),'SE: ','');

      %split compound coordinates on pipes
      ar = splitstr(str,'|');

      for n = 1:length(ar)
         str = ar{n};
         Idash = strfind(str,'-');  %check for site labels based on dash separator
         if ~isempty(Idash)
            if max(Idash) < length(str)
               str = str(max(Idash)+1:end);  %strip all leading text based on last dash
            else
               str = '';
            end
         end
         if ~isempty(str)
            %check for West, North, East, South labels for resolving coordinate hemispheres
            if ~isempty(strfind(str,'W')) || ~isempty(strfind(str,'N')) || ~isempty(strfind(str,'E')) || ~isempty(strfind(str,'S'))
               str = strrep(strrep(strrep(str,'°',' '),'''',' '),'"',' ');  %strip degree, min, sec symbols
               ar2 = splitstr(str,',');  %split on commas
               if length(ar2) ~= 2
                  ar2 = splitstr(str,'/');  %try splitting by slash
                  if length(ar2) ~= 1
                     ar2 = splitstr(str,';');  %try splitting by semicolon
                  end
               end
               if length(ar2) == 2  %check for 2 coordinate strings
                  lonstr = '';
                  latstr = '';
                  lonmult = 1;  %init longitude hemisphere sign multiplier
                  latmult = 1;  %init latitude hemisphere sign multiplier
                  for m = 1:2
                     cstr = ar2{m};
                     if ~isempty(strfind(cstr,' W'))  %W longitude
                        lonmult = -1;
                        lonstr = strrep(cstr,' W','');
                     elseif ~isempty(strfind(cstr,' N')) %N latitude
                        latstr = strrep(cstr,' N','');
                     elseif ~isempty(strfind(cstr,' E'))  %E longitude
                        lonstr = strrep(cstr,' E','');
                     elseif ~isempty(strfind(cstr,' S'))  %S latitude
                        latmult = -1;
                        latstr = strrep(cstr,' S','');
                     end
                  end
                  if ~isempty(lonstr) && ~isempty(latstr)
                     %calculate longitude in decimal degrees
                     lon = 0;  %init numeric lon
                     cnt = 0;  %init term counter
                     while ~isempty(lonstr)
                        [str,lonstr] = strtok(lonstr,' ');
                        cnt = cnt + 1;
                        if cnt <= 3  %check for excess components/unrecognized format
                           lon = lon + abs((str2double(str) ./ 60^(cnt-1)));  %add next component converted to dec. degrees
                        else
                           lon = 0;
                           break
                        end
                     end
                     %calculate latitude in decimal degrees
                     lat = 0;  %init numeric lat
                     cnt = 0;
                     while ~isempty(latstr)
                        [str,latstr] = strtok(latstr,' ');
                        cnt = cnt + 1;
                        if cnt <= 3  %check for excess components/unrecognized format
                           lat = lat + abs((str2double(str) ./ 60^(cnt-1))); %add next component converted to dec. degrees
                        else
                           lat = 0;
                           break
                        end
                     end
                     if lon > 0 && lat > 0  %check for valid coordinate pair
                        %apply hemisphere signs
                        lon = lon .* lonmult;
                        lat = lat .* latmult;
                        wboundlon = min(wboundlon,lon);
                        eboundlon = max(eboundlon,lon);
                        sboundlat = min(sboundlat,lat);
                        nboundlat = max(nboundlat,lat);
                     end
                  end
               end
            end
         end
      end

      %replace unmatched coords with NaN
      if wboundlon == inf; wboundlon = NaN; end
      if eboundlon == -inf; eboundlon = NaN; end
      if sboundlat == inf; sboundlat = NaN; end
      if nboundlat == -inf; nboundlat = NaN; end

   end

end