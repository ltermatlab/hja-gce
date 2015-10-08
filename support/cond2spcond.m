function spcond = cond2spcond(conductivity,temperature,coeff)
%Calculates specific conductance at 25C from conductivity and temperature
%
%syntax: spcond = cond2spcond(conductivity,temperature,coeff)
%
%input:
%  conductivity = water conductivity (mS/cm, microS/cm, etc)
%  temperature = water temperature in degrees C
%  coeff = coefficient (change in specific conductance per degree C; default = 0.02)
%
%output:
%  spcond = specific conductance at 25C (units same as conductivity)
%
%notes:
%  based on the equation: CT = C25 [1 + coeff * (T - 25)]
%     where: CT = the measured conductivity of a solution at sample temperature
%            C25 = the conductivity of the solution at 25C
%            coeff = temperature change coefficient
%            T = the sample temperature (C)
%
%reference:
%  Standard Methods for the Examination of Water and Wastewater (1989), chapter 2, p 2-57 to 2-65, 
%      L.S. Clesceri, A.E. Greenberg, R.R. Trussell, M.H. Franson, Eds., American Public Health 
%      Association, Washington, D.C., 17th edition.
%
%(c)2011 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 10-Aug-2011

spcond = [];

if nargin >= 2 && ~isempty(conductivity) && ~isempty(temperature)
   
   if exist('coeff','var') ~= 1
      coeff = 0.02;
   end
   
   spcond = conductivity ./ (1 + coeff .* (temperature - 25));
   
end