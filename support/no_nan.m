function [a2,Ivalid] = no_nan(a,missingvals)
%Returns a numeric array stripped of NaN and other specified values plus an index of valid values
%
%syntax: [a2,Ivalid] = no_nan(a,missingvals)
%
%inputs:
%  a = numeric array (note: matrices will be converted to column arrays)
%  missingvals = numeric array of missing values to convert to NaN before removal
%
%outputs:
%  a2 = array devoid of NaNs
%  Ivalid = index of non-NaN elements in original array
%
%
%(c)2002-2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 19-Jun-2013

%init outout
a2 = [];
Ivalid = [];

%validate input
if nargin >= 1 && isnumeric(a) && ~isempty(a)
    
    %convert a to a single-column array
    a = a(:);
    
    %check for missingvals and remove
    if exist('missingvals','var') == 1 && isnumeric(missingvals) && ~isempty(missingvals)
        for n = 1:length(missingvals)
            a(a==missingvals(n)) = NaN;
        end
    end

    %get index of non-NaN values
    Ivalid = find(~isnan(a));
    
    %generate
    if ~isempty(Ivalid)
        a2 = a(Ivalid);
    end

end