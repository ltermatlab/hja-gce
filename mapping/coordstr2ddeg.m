function deg = coordstr2ddeg(coordstr,hem_all)
%Converts an array of geographic coordinate strings to decimal degrees, stripping any non-numeric characters
%
%syntax: coord = coordstr2ddeg(coordstr,hem)
%
%inputs:
%  coordstr = string or cell array containing coordinate strings
%  hem = hemisphere code (for determination of negative sign on latitudes, longitudes)
%    ''/omitted = hemisphere or negative signs parsed from coordinate strings
%    'N' = north latitude (positive deg)
%    'E' = east longitude (positive deg)
%    'S' = south latitude (negative deg)
%    'W' = west longitude (negative deg)
%
%outputs:
%  deg = array of coordinates in decimal degrees (with NaN for unparsable or invalid coordinates)
%     (note: if no coordinates can be parsed, an empty array will be returned)
%
%
%(c)2006-2011 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 05-Oct-2011

%init output
deg = [];

if nargin >= 1

   %init degree multiplier
   mult = 1;

   if exist('hem_all','var') ~= 1
      hem_all = '';
   elseif ischar(hem_all)
      hem_all = upper(hem_all);
      if strcmp(hem_all,'W') || strcmp(hem_all,'S')
         mult = -1;  %set negative multiplier for W/S hemisphere
      end
   end

   %convert character array to cell array
   if ischar(coordstr)
      coordstr = cellstr(coordstr);
   end

   %get index of first non-empty cell
   Inotnull = find(~cellfun('isempty',coordstr));

   if ~isempty(Inotnull)

      %predimension output array
      deg = repmat(NaN,length(coordstr),1);

      %replace special characters in non-empty strings with blanks
      specchars = {'°','"','''','º'};
      for n = 1:length(specchars)
         coordstr(Inotnull) = strrep(coordstr(Inotnull),specchars{n},' ');
      end

      for n = 1:length(Inotnull)

         %get string
         str = upper(deblank(coordstr{Inotnull(n)}));

         %init hem with hem_all
         hem = hem_all;

         %parse hemisphere if not specified, setting appropriate multiplier for each string
         if isempty(hem)
            if ~isempty(strfind(str,'W'))
               hem = 'W';
               mult = -1;
            elseif ~isempty(strfind(str,'S'))
               hem = 'S';
               mult = -1;
            elseif ~isempty(strfind(str,'N'))
               hem = 'N';
               mult = 1;
            elseif ~isempty(strfind(str,'E'))
               hem = 'E';
               mult = 1;
            elseif ~isempty(strfind(str,'-'))  %check for existing negative sign
               hem = '';
               mult = -1;
            else
               hem = '';
               mult = 1;
            end
         end

         %clear W/S/E/N and negative signs
         str = strrep(strrep(strrep(strrep(strrep(str,'W',''),'S',''),'E',''),'N',''),'-','');

         %parse string
         try
            ar = sscanf(str,'%f');
         catch
            ar = [];
         end

         %convert to decimal degrees
         if ~isempty(ar)

            ar = [ar(:)',0,0];  %pad array with zeros for deg, degmin formats
            newdeg = ar(1:3) * [1 1/60 1/3600]';  %calculate decimal degrees

            %validate coordinate based on hemisphere (if known), apply negative to S/W coords
            if isempty(hem)
               if newdeg <= 180
                  newdeg = newdeg .* mult;  %apply negative sign for W/S coords
               else
                  newdeg = NaN;
               end
            elseif hem == 'S' || hem == 'N'
               if newdeg <= 90
                  newdeg = newdeg .* mult;
               else
                  newdeg = NaN;
               end
            else  %hem = 'E' or 'W'
               if newdeg <= 180
                  newdeg = newdeg .* mult;
               else
                  newdeg = NaN;
               end
            end

            %update output array
            deg(Inotnull(n)) = newdeg;

         end

      end

      %return empty array if non non-NaN values
      if isempty(find(~isnan(deg)))
         deg = [];
      end

   end

end