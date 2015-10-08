function [lon,lat,errormsg] = utm2deg(zone,utm_east,utm_north,hem,datum)
%Converts geographic coordinates from UTM to decimal degrees (lon,lat)
%
%syntax:  [lon,lat,errormsg] = utm2deg(zone,utm_east,utm_north,hem,datum)
%
%input:
%  zone = numeric vector of UTM zones (1-60) or a single zone for all coordinates
%  utm_east = numeric vector of UTM eastings in m
%  utm_north = numeric vector of UTM northings in m (length must match utm_east)
%  hem = character array of 'N' and 'S' indicating northern or southern hemisphere
%     for each coordinate or a single character for all coordinates
%     (defaults to 'N' if omitted)
%  datum = reference ellipsoid datum to use:
%     'WGS84' (default)
%     'WGS72'
%     'WGS66'
%     'WGS60'
%     'NAD83'
%     'NAD27'
%     'CLARK1866'
%     'CLARK1800'
%
%output:
%  lon = column vector of longitudes in degrees (-180 to 180)
%  lat = column vector of latitudes in degrees (-90 to 90)
%  errormsg = text of any error messages (blank if no errors)
%
%based on Javascript code written by Charles L. Taylor (1997-1998)
%  (http://home.hiwaay.net/~taylorc/toolbox/geography/geoutm.html)
%
%reference: Hoffmann-Wellenhof, B., Lichtenegger, H., and Collins, J.,
%   GPS: Theory and Practice, 3rd ed.  New York: Springer-Verlag Wien, 1994.
%
%originally converted to vectorized Matlab 5.x code in 2001
%revised NAD83 ellipsoid constants and added NAD27 in 2009
%
%Wade M. Sheldon
%Georgia Coastal Ecosystems LTER
%Dept. of Marine Sciences
%University of Georgia
%Athens, GA 30602
%email: sheldon@uga.edu
%
%last modified: 18-Feb-2009


%initialize output vars
lon = [];
lat = [];
errormsg = '';

cancel = 0;

if nargin >= 3  %check for minimum arguments

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
   
   if cancel == 0  %datum OK - proceed
      
      %calculate semi-minor axis from semi-major axis and inverse flattening
      sm_b = sm_a - (sm_a ./ inv_flattening);
      sm_b = round(sm_b .* 10000) ./ 10000;  %truncate to 4 decimal places
      
      if exist('hem','var') ~= 1
         hem = 'N';
      end

      num = length(utm_east);

      %replicate scalar zone, hemisphere
      if num > 1
         if length(zone) == 1
            zone = repmat(zone,num,1);
         end
         if length(hem) == 1
            hem = repmat(hem(:,1),num,1);
         end
      end

      %validate utm array sizes
      if length(utm_east) ~= length(utm_north)
         cancel = 1;
         errormsg = 'The number of eastings and northings do not match';
      end

      %validate zone
      if cancel == 0
         if length(zone) == num
            I = find(zone<1 | zone>60);
            if ~isempty(I)
               cancel = 1;
               errormsg = '''zone'' values must be valid UTM zones between 1 and 60';
            end
         else
            cancel = 1;
            errormsg = 'invalid zone array (length must be 1 or match the number or coordinates)';
         end
      end

      %validate hemisphere
      if cancel == 0
         %convert to upper case string
         if ischar(hem)
            hem = upper(hem(:,1));
         else
            cancel = 1;
            errormsg = '''hem'' must be either ''N'' or ''S''';
         end
         %check for valid values
         if cancel == 0
            if length(hem) == num
               I = find(hem~='N' & hem~='S');
               if ~isempty(I)
                  cancel = 1;
                  errormsg = '''hem'' must be a character array containing only ''N'' or ''S''';
               end
            else
               cancel = 1;
               errormsg = 'invalid number of elements in ''hem''';
            end
         end
      end

      if cancel == 0  %inputs OK, proceed

         southhemi = (hem == 'S');

         %process coordinates
         latlon = UTMXYToLatLon (utm_east(:), utm_north(:), zone, southhemi);

         %parse coordinates and convert to degrees
         lon = RadToDeg(latlon(:,2));
         lat = RadToDeg(latlon(:,1));

      end

   end

   %clean up global constants
   clear global sm_a sm_b UTMScaleFactor

else
   errormsg = 'insufficient argments for function';
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

result = DegToRad(-183 + (zone .* 6));


function result = FootpointLatitude(y)
% FootpointLatitude
%
% Computes the footpoint latitude for use in converting transverse
% Mercator coordinates to ellipsoidal coordinates.
%
% Reference: Hoffmann-Wellenhof, B., Lichtenegger, H., and Collins, J.,
%   GPS: Theory and Practice, 3rd ed.  New York: Springer-Verlag Wien, 1994.
%
% Inputs:
%   y - The UTM northing coordinate, in meters.
%
% Returns:
%   The footpoint latitude, in radians.

global sm_a sm_b

% Precalculate n (Eq. 10.18)
n = (sm_a - sm_b) / (sm_a + sm_b);

% Precalculate alpha_ (Eq. 10.22)
% (Same as alpha in Eq. 10.17)
alpha_ = ((sm_a + sm_b) ./ 2) .* (1 + (n .^ 2 ./ 4) + (n .^ 4 ./ 64));

% Precalculate y_ (Eq. 10.23)
y_ = y ./ alpha_;

% Precalculate bta_ (Eq. 10.22)
bta_ = (3 .* n ./ 2) + (-27 .* n .^ 3 ./ 32) + (269 .* n .^ 5 ./ 512);

% Precalculate gam_ (Eq. 10.22)
gam_ = (21 .* n .^ 2 ./ 16) + (-55 .* n .^ 4 ./ 32);

% Precalculate delta_ (Eq. 10.22)
delta_ = (151 .* n .^ 3 ./ 96) + (-417 .* n .^ 5 ./ 128);

% Precalculate epsilon_ (Eq. 10.22)
epsilon_ = (1097 .* n .^ 4 ./ 512);

% Now calculate the sum of the series (Eq. 10.21)
result = y_ + (bta_ .* sin (2 .* y_)) ...
   + (gam_ .* sin (4 .* y_)) ...
   + (delta_ .* sin (6 .* y_)) ...
   + (epsilon_ .* sin (8 .* y_));


function philambda = MapXYToLatLon(x,y,lambda0)
% MapXYToLatLon
%
% Converts x and y coordinates in the Transverse Mercator projection to
% a latitude/longitude pair.  Note that Transverse Mercator is not
% the same as UTM; a scale factor is required to convert between them.
%
% Reference: Hoffmann-Wellenhof, B., Lichtenegger, H., and Collins, J.,
%   GPS: Theory and Practice, 3rd ed.  New York: Springer-Verlag Wien, 1994.
%
% Inputs:
%   x - The easting of the point, in meters.
%   y - The northing of the point, in meters.
%   lambda0 - Longitude of the central meridian to be used, in radians.
%
% Returns:
%   philambda - A 2-element containing the latitude and longitude
%               in radians.
%
% Remarks:
%   The local variables Nf, nuf2, tf, and tf2 serve the same purpose as
%   N, nu2, t, and t2 in MapLatLonToXY, but they are computed with respect
%   to the footpoint latitude phif.
%
%   x1frac, x2frac, x2poly, x3poly, etc. are to enhance readability and
%   to optimize computations.

%initialize output
philambda = ones(length(x),2).*NaN;

%instantiate global vars
global sm_a sm_b

%Get the value of phif, the footpoint latitude.
phif = FootpointLatitude(y);

%Precalculate ep2
ep2 = (sm_a.^2 - sm_b.^2) ./ sm_b.^2;

%Precalculate cos (phif)
cf = cos(phif);

%Precalculate nuf2
nuf2 = ep2 .* cf.^2;

%Precalculate Nf and initialize Nfpow
Nf = sm_a.^2 ./ (sm_b * sqrt(1 + nuf2));
Nfpow = Nf;

%Precalculate tf
tf = tan(phif);
tf2 = tf.^2;
tf4 = tf2.^2;

%Precalculate fractional coefficients for x**n in the equations
%below to simplify the expressions for latitude and longitude.
x1frac = 1 ./ (Nfpow .* cf);

Nfpow = Nfpow .* Nf;   %now equals Nf**2)
x2frac = tf ./ (2 .* Nfpow);

Nfpow = Nfpow .* Nf;   %now equals Nf**3)
x3frac = 1 ./ (6 .* Nfpow .* cf);

Nfpow = Nfpow .* Nf;   %now equals Nf**4)
x4frac = tf ./ (24 .* Nfpow);

Nfpow = Nfpow .* Nf;   %now equals Nf**5)
x5frac = 1 ./ (120 .* Nfpow .* cf);

Nfpow = Nfpow .* Nf;   %now equals Nf**6)
x6frac = tf ./ (720 .* Nfpow);

Nfpow = Nfpow .* Nf;   %now equals Nf**7)
x7frac = 1 ./ (5040 .* Nfpow .* cf);

Nfpow = Nfpow .* Nf;   %now equals Nf**8)
x8frac = tf ./ (40320 .* Nfpow);

%Precalculate polynomial coefficients for x**n.
%-- x**1 does not have a polynomial coefficient.
x2poly = -1 - nuf2;

x3poly = -1 - 2 .* tf2 - nuf2;

x4poly = 5 + 3 .* tf2 + 6 .* nuf2 - 6 .* tf2 .* nuf2 ...
   - 3 .* (nuf2 .* nuf2) - 9 .* tf2 .* (nuf2 .* nuf2);

x5poly = 5 + 28 .* tf2 + 24 .* tf4 + 6 .* nuf2 + 8 .* tf2 .* nuf2;

x6poly = -61 - 90 .* tf2 - 45 .* tf4 - 107 .* nuf2 ...
   + 162 .* tf2 .* nuf2;

x7poly = -61 - 662 .* tf2 - 1320 .* tf4 - 720 .* (tf4 .* tf2);

x8poly = 1385 + 3633 .* tf2 + 4095 .* tf4 + 1575 .* (tf4 .* tf2);

%Calculate latitude
philambda(:,1) = phif + x2frac .* x2poly .* x.^2 ...
   + x4frac .* x4poly .* x.^4 ...
   + x6frac .* x6poly .* x.^6 ...
   + x8frac .* x8poly .* x.^8;

%Calculate longitude
philambda(:,2) = lambda0 + x1frac .* x ...
   + x3frac .* x3poly .* x.^3 ...
   + x5frac .* x5poly .* x.^5 ...
   + x7frac .* x7poly .* x.^7;


function latlon = UTMXYToLatLon(x,y,zone,southhemi)
% UTMXYToLatLon
%
% Converts x and y coordinates in the Universal Transverse Mercator
% projection to a latitude/longitude pair.
%
% Inputs:
%	x - The easting of the point, in meters.
%	y - The northing of the point, in meters.
%	zone - The UTM zone in which the point lies.
%	southhemi - True if the point is in the southern hemisphere;
%               false otherwise.
%
% Returns:
%	latlon - A 2-element array containing the latitude and
%            longitude of the point, in radians.

global UTMScaleFactor;

x = x - 500000;
x = x ./ UTMScaleFactor;

%If in southern hemisphere, adjust y accordingly
I = find(southhemi);  %form index of southern coordinates
if ~isempty(I)
   y(I) = y(I) - 10000000;  %adjust northings
end

y = y ./ UTMScaleFactor;

cmeridian = UTMCentralMeridian(zone);
latlon = MapXYToLatLon(x,y,cmeridian);