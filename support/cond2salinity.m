function [sal,sigmat] = cond2salinity(depth,temp,cond)
%Calculates salinity and sigma-t from water depth, temperature and conductivity measurements
%
%syntax: [sal,sigmat] = cond2salinity(depth,temp,cond);
%
%input:
%  depth = water depth in meters
%  temp = water temperature in degrees C
%  cond = conductivity is mS/cm (note: do not use specific conductance at 25C)
%
%output:
%  sal = salinity in PSU (or unitless)
%  sigmat = sigma-t (specific gravity anomaly)
%
%Notes:
% This function was created by Julie Amft on 18 Mar 1992 from a script file that
% Dr. Tom Gross retrieved via TELEMAIL 8 Dec 1989 from V. Holliday.
% The original program (salsig.m) read several parameters from the keyboard,
% but these are now variables that are passed into the function;
% the parameters are depth (in meters), temperature (in deg C) and conductivity
% (in mS/cm).
% The conductivity and temperature are used to calculate salinity.
% The salinity and temperature are used to calculate sigma-t.
%
% *** 2 constants were changed on 06 May 1992 to match Sea-Bird software:
% ***   (by J. Amft)
% ***
% ***   r18 = 42.914;
% ***   a2 = (((5.3875e-9.*t - 8.2467e-7*onev).*t + 7.6438e-5*onev).*t ...
% ***        - 4.0899e-3*onev).*t + 8.24493e-1*onev;
%
% *** syntax and help text updated by W. Sheldon on 22 Jul 2011
% ***    for inclusion in the GCE Data Toolbox for MATLAB
%
%last modified: 22-Jul-2011

sal = [];
sigmat = [];

if nargin == 3 && ~isempty(depth) && ~isempty(temp) && ~isempty(cond)
   
   % Set constants for salinity calculation
   r0 = 0.008;
   r1 = -0.1692;
   r2 = 25.3851;
   r3 = 14.0941;
   r4 = -7.0261;
   r5 = 2.7081;
   r6 = 0.6766097;
   r7 = 2.00564e-2;
   r8 = 1.104259e-4;
   r9 = -6.9698e-7;
   r10 = 1.0031e-9;
   r11 = 3.426e-2;
   r12 = 4.464e-4;
   r13 = 0.4215;
   r14 = -3.107e-3;
   r15 = 2.07e-4;
   r16 = -6.37e-8;
   r17 = 3.989e-12;
   r18 = 42.914;  % in the original program: r18 = 42.909;
   r19 = 0.0005;
   r20 = -0.0056;
   r21 = -0.0066;
   r22 = -0.0375;
   r23 = 0.0636;
   r24 = -0.0144;
   r25 = 0.0162;
   
   ndepth = - depth;
   
   onev = ones(length(depth),1);
   dcor = 0.1*depth;
   
   % Calculate salinity:
   a = r6*onev + r7*temp + r8*temp.^2 + r9*temp.^3 + r10*temp.^4;
   r = cond / r18;
   b = onev + dcor.*(r15*onev + r16*dcor + r17*dcor.^2) ./ ...
      (onev + r11*temp + r12*temp.^2 + r.*(r13*onev + r14*temp));
   c = r ./ (b .* a);
   s = r0*onev + r1*c.^0.5 + r2*c + r3*c.^1.5 + r4*c.^2 + r5*c.^2.5;
   u = (temp-15*onev) ./ (onev + r25*(temp - 15*onev));
   u = (r19*onev + r20*c.^.5 + r21*c + r22*c.^1.5 + r23*c.^2 + ...
      r24*c.^2.5) .* u;
   sal = s + u;
   
   % Calculate sigma-t:
   t = temp;
   s = sal;
   a1 = ((((6.536332e-9*t - 1.120083e-6*onev).*t ...
      + 1.001685e-4*onev).*t -9.095290e-3*onev).*t...
      + 6.793952e-2*onev).*t + 999.842594*onev;
   
   % in the orig program:
   %      a2 = (((5.3875e-9.*t + 8.2467e-7*onev).*t + 7.6438e-5*onev).*t ...
   %           - 4.0899e-3*onev).*t + 8.24493e-1*onev;
   a2 = (((5.3875e-9.*t - 8.2467e-7*onev).*t + 7.6438e-5*onev).*t ...
      - 4.0899e-3*onev).*t + 8.24493e-1*onev;
   
   a3 = (-1.6546e-6*t + 1.0227e-4*onev).*t - 5.72466e-3*onev;
   a4 = 4.8314e-4;
   rs = sqrt(abs(s));
   
   sigmat = (a4*s + a3.*rs +a2.*onev).*s + a1.*onev - 1000*onev;
   
end