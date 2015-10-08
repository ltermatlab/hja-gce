function [s2,msg] = add_locations(s,tol,qc_tol,loctype,offsetcol,loncol,latcol,colname,colposition,reffile)
%Adds a column of location names to a dataset based on geographic lookups of reference station coordinates
%(the closest match within the specified distance tolerance will be returned)
%
%syntax: [s2,msg] = add_locations(s,tol,qc_tol,loctype,offsetcol,loncol,latcol,colname,colposition,reffile)
%
%inputs:
%  s = data structure to modify
%  tol = distance offset tolerance for geographic lookups, in km (default = 0.5)
%  qc_tol = quality control tolerance for flagging location matches, in km (default = tol/2)
%  loctype = location types in the 'TypeCode' field of 'reffile' to query (default = all)
%  offset_col = option to include a column containing the offset distance between the reported coordinates
%     and the registered coordinates for the matched location (0 = no, 1 = yes/default)
%  longcol = name or index of a column containing Longitude in decimal degrees (default = automatic)
%  latcol = name or index of a column containing Latitude in decimal degrees (default = automatic)
%  colname = name to use for the added location column (default = 'Location')
%  colposition = column position index (default = following longcol and latcol)
%  reffile = name or fully-qualified pathname of the reference database file to use (default = 'geo_locations.mat')
%    (note: file must contain a MATLAB structure named 'locations' with fields 'Location', 'TypeCode',
%    'Longitude' and 'Latitude', containing location names, location type codes, longitude in decimal degrees,
%    and latitude in decimal degrees, resp.)
%
%outputs:
%  s2 = modified structure
%  msg = text of any error message
%
%
%(c)2008-2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 07-Jun-2013

s2 = [];
msg = '';

if nargin >= 1

   %validate input, set defaults for omitted arguments
   if exist('tol','var') ~= 1
      tol = [];
   elseif ~isnumeric(tol)
      tol = [];
   end
   if isempty(tol)
      tol = 0.5;
   end

   if exist('qc_tol','var') ~= 1
      qc_tol = [];
   elseif ~isnumeric(qc_tol)
      qc_tol = [];
   end
   if isempty(qc_tol)
      qc_tol = tol ./ 2;
   end

   if exist('loctype','var') ~= 1
      loctype = '';
   end

   if exist('offsetcol','var') ~= 1
      offsetcol = 1;
   elseif offsetcol ~= 0
      offsetcol = 1;
   end

   if exist('loncol','var') ~= 1
      loncol = [];
   elseif ~isnumeric(loncol)
      loncol = name2col(s,loncol,0,'f','coord');
   end

   if exist('latcol','var') ~= 1
      latcol = [];
   elseif ~isnumeric(latcol)
      latcol = name2col(s,latcol,0,'f','coord');
   end

   if exist('colname','var') ~= 1
      colname = 'Location';
   end
   
   if exist('colposition','var') ~= 1
      colposition = [];
   elseif colposition < 0 || colposition > length(s.name)
      colposition = [];
   end

   if exist('reffile','var') ~= 1
      reffile = 'geo_locations.mat';
   end

   if gce_valid(s,'data')

      if exist(reffile,'file') == 2

         [lon,lat,loncol,latcol] = lookup_coords(s,loncol,latcol);

         if ~isempty(lon) && ~isempty(lat)

            try
               v = load(reffile,'-mat');
            catch
               v = struct('null','');
            end

            %check for valid locations database
            if isfield(v,'locations')

               locations = v.locations;

               %validate locations structure
               if isstruct(locations) && isfield(locations,'Location') && isfield(locations,'TypeCode') && ...
                     isfield(locations,'Longitude') && isfield(locations,'Latitude')

                  if ~isempty(loctype)
                     Isel = find(strcmp({locations.TypeCode}',loctype));
                     if ~isempty(Isel)
                        locations = locations(Isel);
                     else
                        locations = [];
                     end
                  end

                  if ~isempty(locations)

                     %extract lookup arrays from reference database file
                     numloc = length(locations);
                     loc = {locations.Location}';
                     lonlat_loc= [[locations.Longitude]',[locations.Latitude]'];

                     %get unique lat/lon coordinate pairs for analysis
                     [lonlat,I,J] = unique([lon,lat],'rows');
                     num = length(I);

                     %init match array and distance array
                     matches = repmat({''},num,1);
                     distances = repmat(NaN,num,1);

                     %calculate distances, find closest
                     for n = 1:num
                        dist = gpsdistk(lonlat_loc,repmat(lonlat(n,:),numloc,1));
                        [mindist,Imin] = min(dist);
                        if ~isempty(mindist) && mindist <= tol
                           matches(n) = loc(Imin);
                           distances(n) = mindist;
                        end
                     end

                     %populate final match, distance arrays
                     allmatches = matches(J);
                     alldistances = distances(J);

                     %calculate number of valid matches
                     num_matches = length(find(~isnan(alldistances)));

                     %generate q/c rules if qc_tol defined
                     qc_rule = '';
                     qc_rule2 = '';
                     if qc_tol > 0
                        qc_rule = ['flag_locationcoords(x,col_',s.name{loncol},',col_',s.name{latcol},',', ...
                              num2str(qc_tol),',''sensitive'',''',reffile,''')=''Q'''];
                        qc_rule2 = ['x>',num2str(qc_tol),'=''Q'''];
                     end

                     %copy original structure, add main processing history entry
                     s2 = s;
                     str_hist = ['matched ',int2str(num_matches),' out of ',int2str(length(alldistances)), ...
                           ' geographic coordinates in columns ',s.name{latcol},' and ',s.name{loncol}, ...
                           ' to coordinates for registered locations in the file ''',reffile,''' within a distance tolerance of ', ...
                           num2str(tol),'km (add_locations)'];
                     s2.history = [s2.history ; {datestr(now)},{str_hist}];

                     %determine column position
                     if isempty(colposition)
                        colposition = max([loncol,latcol]) + 1;
                     end
                     
                     %add or update location data
                     existingcol = name2col(s,colname);
                     if isempty(existingcol) || ~strcmp(s.datatype{existingcol(1)},'s')
                        s2 = addcol(s2,allmatches,colname,'none', ...
                           [colname,' determined by geographic database lookup of coordinates in columns ',s.name{latcol},' and ',s.name{loncol}, ...
                              ' using a distance tolerance of ',num2str(tol),'km from registered station location'], ...
                           's','nominal','none',0,qc_rule,colposition);
                     else  %update existing column with new values, description and criteria
                        colposition = existingcol(1);
                        s2 = update_data(s2,colposition,allmatches,50,'');
                        s2.description{colposition} = [colname,' determined by geographic database lookup of coordinates in columns ', ...
                           s.name{latcol},' and ',s.name{loncol},' using a distance tolerance of ',num2str(tol),'km from registered station location'];
                        s2.criteria{colposition} = qc_rule;
                     end

                     if ~isempty(s2)

                        %add offset column if specified
                        if offsetcol == 1
                           s2 = addcol(s2,alldistances,[colname,'_Offset'],'km', ...
                              ['Distance between the recorded geographic coordinates of locations in column ',colname, ...
                                 ' and the registered coordinates in reference database file ''',reffile,''''], ...
                              'f','calculation','continuous',2,qc_rule2,colposition+1);
                           if isempty(s2)
                              msg = 'an error occurred adding the location offset column';
                           end
                        end

                     else
                        msg = 'an error occurred adding the location column';
                     end

                  else
                     msg = 'no locations matched the specified type';
                  end

               else
                  msg = 'location reference file is invalid';
               end

            else
               msg = 'location reference file is invalid';
            end

         else
            if ~isempty(loncol) || ~isempty(latcol)
               msg = 'invalid geographic location columns';
            else
               msg = 'geographic coordinates could not be determined for the data set';
            end
         end

      else
         msg = 'location reference file not found';
      end

   else
      msg = 'invalid data structure';
   end

else
   msg = 'insufficient arguments for function';
end


function d = gpsdistk(gps1,gps2)
%Computes distance (in km) between GPS coordinates 'gps1' and 'gps2' using the
%cartographic formula for distance along great circle.  Arguments 'gps1' and 'gps2'
%are pairs of longitude/latitude values in degrees (individual coordinates or
%arrays of coordinates), and output is distance in km.
%
%syntax:  d = gpsdistk(gps1,gps2)
%
%
%(c)2002-2006 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
%
%contact:
%  Wade Sheldon
%  GCE-LTER Project
%  Department of Marine Sciences
%  University of Georgia
%  Athens, GA 30602-3636
%  sheldon@uga.edu
%
%modified 15-Nov-2005

%convert to radians
gps1 = abs((gps1)).*(pi./180);
gps2 = abs((gps2)).*(pi./180);

%calculate distance in degrees of arc
d = real(acos(sin(gps1(:,2)) .* sin(gps2(:,2)) + ...
   cos(gps1(:,2)) .* cos(gps2(:,2)) .* cos(abs(gps1(:,1)-gps2(:,1))))) .* (180./pi);

%convert to km
d =  d .* 111.111;