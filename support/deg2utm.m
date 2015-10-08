function [zone,utm_east,utm_north,hem,errormsg] = deg2utm(lon,lat,datum)
%Converts geographic coordinates from lat/lon degrees to UTM using the specified ellipsoid datum
%
%syntax:  [zone,utm_east,utm_north,hem,errormsg] = deg2utm(lon,lat,datum)
%
%inputs:
%  lon = numeric column vector of longitudes in degrees (-180 to 180)
%  lat = numeric column vector of latitudes in degrees (-90 to 90)
%  datum = character array containing reference ellipsoid datum to use:
%     'WGS84' (default)
%     'WGS72'
%     'WGS66'
%     'WGS60'
%     'NAD83'
%     'NAD27'
%     'CLARK1866'
%     'CLARK1800'
%
%outputs:
%  zone = vector of UTM zones (1-60) or a single zone for all coordinates
%  utm_east = vector of UTM eastings in m
%  utm_north = vector of UTM northings in m (length must match utm_east)
%  hem = vector of 'N' and 'S' indicating northern or southern hemisphere
%     for each coordinate, resp., or a single character for all coordinates
%     (defaults to 'N' if omitted)
%  errormsg = text of any error messages (blank if no errors)
%
%based on Javascript code written by Charles L. Taylor (1997-1998)
%  (http://home.hiwaay.net/~taylorc/toolbox/geography/geoutm.html)
%
%reference: Hoffmann-Wellenhof, B., Lichtenegger, H., and Collins, J.,
%   GPS: Theory and Practice, 3rd ed.  New York: Springer-Verlag Wien, 1994.
%
%originally converted to vectorized Matlab 5.x code in 2001
%
%revised NAD83 ellipsoid constants and added NAD27 in 2009 using reference values
%from http://www.colorado.edu/geography/gcraft/notes/datum/datum_f.html
%
%Wade M. Sheldon
%Georgia Coastal Ecosystems LTER
%Dept. of Marine Sciences
%University of Georgia
%Athens, GA 30602
%email: sheldon@uga.edu
%
%last modified: 07-May-2010

%initialize output variables
zone = [];
utm_east = [];
utm_north = [];
hem = [];
errormsg = '';
cancel = 0;

if nargin >= 2  %check for minimum arguments

   %set default datum if omitted
   if exist('datum','var') ~= 1
      datum = '';
   end
   if isempty(datum)
      datum = 'WGS84';
   else
      datum = upper(datum);
   end

   %initialize global variables
   global sm_a sm_b UTMScaleFactor
   UTMScaleFactor = 0.9996;

   %define global spheroid model constants (semi-major axis and inverse flattening)
   switch datum
   case 'WGS84'
      sm_a = 6378137;
      inv_flattening = 298.257223563;
   case 'WGS72'
      sm_a = 6378135;
      inv_flattening = 298.26;
   case 'WGS66'
      sm_a = 6378145;
      inv_flattening = 298.25;
   case 'WGS60'
      sm_a = 6378165;
      inv_flattening = 298.3;
   case 'NAD83'  %based on GRS 80
      sm_a = 6378137;
      inv_flattening = 298.257222101;
   case 'NAD27'  %same as CLARK1866
      sm_a = 6378206.4;
      inv_flattening = 294.9786982;
   case 'CLARK1866'
      sm_a = 6378206.4;
      inv_flattening = 294.9786982;
   case 'CLARK1880'
      sm_a = 6378249.145;
      inv_flattening = 293.465;
   otherwise
      cancel = 1;
      errormsg = 'invalid datum selection';
   end

   if cancel == 0  %datum OK, proceed

      %calculate semi-minor axis from semi-major axis and inverse flattening
      sm_b = sm_a - (sm_a ./ inv_flattening);
      sm_b = round(sm_b .* 10000) ./ 10000;  %truncate to 4 decimal places

      if length(lat) == length(lon)  %check vector sizes

         %force column vectors
         lon = lon(:);
         lat = lat(:);

         %validate coordinate values
         if min(lon) >= -180 && max(lon) <= 180 && min(lat) >= -90 && max(lat) <= 90

            %calculate initial UTM zones
            zone = fix((lon + 180) ./ 6) + 1;

            %calculate hemisphere using lat data
            if nargout > 2  %check to see if value requested
               hem = char(ones(length(lon),1).*'N');  %initialize all as north
               I = find(lat<0);
               if ~isempty(I)
                  hem(I) = 'S';  %set coordinates with negative lat as south
               end
               I = find(isnan(lat));
               if ~isempty(I)
                  hem(I) = ' ';  %clear spacer values
               end
            end

            %calculate UTM coordinates
            [utm_coord,zone] = LatLonToUTMXY(DegToRad(lat),DegToRad(lon),zone);

            %parse coordinates
            utm_east = utm_coord(:,1);
            utm_north = utm_coord(:,2);

         else
            errormsg = 'invalid longitude and/or latitude';
         end

      else
         errormsg = 'input argument must be an nx2 array of lon and lat in degrees';
      end

   end

   %clean up global variables
   clear global sm_a sm_b UTMScaleFactor

else

   errormsg = 'required argument omitted';

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%
% subfunction definitions %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

function result = DegToRad(deg)
%converts angles in degrees to radians
result = deg .* (pi./180);


function result = RadToDeg(rad)
%converts angles in radians to degrees
result = rad .* (180./pi);


function result = ArcLengthOfMeridian(phi)
% ArcLengthOfMeridian
%
% Computes the ellipsoidal distance from the equator to a point at a
% given latitude.
%
% Reference: Hoffmann-Wellenhof, B., Lichtenegger, H., and Collins, J.,
% GPS: Theory and Practice, 3rd ed.  New York: Springer-Verlag Wien, 1994.
%
% Inputs:
%     phi - Latitude of the point, in radians.
%
% Globals:
%     sm_a - Ellipsoid model major axis.
%     sm_b - Ellipsoid model minor axis.
%
% Returns:
%     The ellipsoidal distance of the point from the equator, in meters.

global sm_a sm_b

%Precalculate n
n = (sm_a - sm_b) / (sm_a + sm_b);

%Precalculate alpha
alpha = ((sm_a + sm_b) ./ 2) .* (1 + (n .^ 2 ./ 4) + (n .^ 4 ./ 64));

%Precalculate bta
bta = (-3 .* n ./ 2) + (9 .* n .^ 3 ./ 16) + (-3 .* n .^ 5 ./ 32);

%Precalculate gam
gam = (15 .* n .^ 2 ./ 16) + (-15 .* n .^ 4 ./ 32);

%Precalculate delta
delta = (-35 * n .^ 3 ./ 48) + (105 .* n .^ 5 ./ 256);

%Precalculate epsilon
epsilon = (315 * n .^ 4 ./ 512);

%Now calculate the sum of the series and return
result = alpha ...
   .* (phi + (bta .* sin(2 .* phi)) ...
   + (gam .* sin(4 .* phi)) ...
   + (delta .* sin(6 .* phi))  ...
   + (epsilon .* sin(8 .* phi)));


function result = UTMCentralMeridian(zone)
% UTMCentralMeridian
%
% Determines the central meridian for the given UTM zone.
%
% Inputs:
%     zone - An integer value designating the UTM zone, range [1,60].
%
% Returns:
%   The central meridian for the given UTM zone, in radians, or zero
%   if the UTM zone parameter is outside the range [1,60].
%   Range of the central meridian is the radian equivalent of [-177,+177].
%

result = DegToRad(-183.*ones(length(zone),1) + (zone .* 6));


function result = MapLatLonToXY(phi,lambda,lambda0)
% MapLatLonToXY
%
% Converts a latitude/longitude pair to x and y coordinates in the
% Transverse Mercator projection.  Note that Transverse Mercator is not
% the same as UTM; a scale factor is required to convert between them.
%
% Reference: Hoffmann-Wellenhof, B., Lichtenegger, H., and Collins, J.,
% GPS: Theory and Practice, 3rd ed.  New York: Springer-Verlag Wien, 1994.
%
% Inputs:
%    phi - Latitude of the point, in radians.
%    lambda - Longitude of the point, in radians.
%    lambda0 - Longitude of the central meridian to be used, in radians.
%
% Outputs:
%    result - A 2-element array containing the x and y coordinates
%         of the computed point.
%

global sm_a sm_b

%initialize output array
result = ones(length(phi),2).*NaN;

% Precalculate ep2
ep2 = (sm_a .^ 2 - sm_b .^ 2) ./ sm_b .^ 2;

% Precalculate nu2
nu2 = ep2 .* cos(phi) .^ 2;

% Precalculate N
N = sm_a .^ 2 ./ (sm_b .* sqrt(1 + nu2));

% Precalculate t
t = tan(phi);
t2 = t .^ 2;

% Precalculate l
L = lambda - lambda0;

% Precalculate coefficients for l**n in the equations below
% so a normal human being can read the expressions for easting
% and northing  -- l**1 and l**2 have coefficients of 1.0
L3coef = 1 - t2 + nu2;

L4coef = 5 - t2 + 9 .* nu2 + 4 .* (nu2 .^ 2);

L5coef = 5 - 18 .* t2 + (t2 .^ 2) + 14 .* nu2 - 58 .* t2 .* nu2;

L6coef = 61 - 58 .* t2 + (t2 .^ 2) + 270 .* nu2 - 330 .* t2 .* nu2;

L7coef = 61 - 479 .* t2 + 179 .* t2 .^ 2 - t2 .^ 3;

L8coef = 1385 - 3111 .* t2 + 543 .* t2 .^ 2 - t2 .^ 3;

% Calculate easting (x)
result(:,1) = (N .* cos(phi) .* L) ...
   + (N / 6 .* cos(phi).^3 .* L3coef .* L.^3) ...
   + (N / 120 .* cos(phi).^5 .* L5coef .* L.^5) ...
   + (N / 5040 .* cos(phi).^7 .* L7coef .* L.^7);

% Calculate northing (y)
result(:,2) = ArcLengthOfMeridian(phi) ...
   + (t ./ 2 .* N .* cos(phi).^2 .* L.^2) ...
   + (t ./ 24 .* N .* cos(phi).^4 .* L4coef .* L.^4) ...
   + (t ./ 720 .* N .* cos(phi).^6 .* L6coef .* L.^6) ...
   + (t ./ 40320 .* N .* cos(phi).^8 .* L8coef .* L.^8);


function [xy,zone] = LatLonToUTMXY(lat,lon,zone)
% LatLonToUTMXY
%
% Converts a latitude/longitude pair to x and y coordinates in the
% Universal Transverse Mercator projection.
%
% Inputs:
%   lat - Latitude of the point, in radians.
%   lon - Longitude of the point, in radians.
%   zone - UTM zone to be used for calculating values for x and y.
%          If zone is less than 1 or greater than 60, the routine
%          will determine the appropriate zone from the value of lon.
%
% Outputs:
%   xy - A 2-element array where the UTM x and y values will be stored.
%   The UTM zone used for calculating the values of x and y.

global UTMScaleFactor

xy = MapLatLonToXY(lat,lon,UTMCentralMeridian(zone));

%Adjust easting and northing for UTM system
xy(:,1) = xy(:,1) .* UTMScaleFactor + 500000;
xy(:,2) = xy(:,2) .* UTMScaleFactor;
I = find(xy(:,2) < 0);
xy(I,2) = xy(I,2) + 10000000;
