function filters = get_importfilters()
%Returns a database of GCE Data Toolbox import filter definitions stored in 'imp_filters.mat'
%
%syntax: filters = get_importfilters()
%
%inputs:
%  none
%
%outputs:
%  filters = GCE Data Structure containing import filter database
%
%notes:
%  1) if no imp_filters.mat file is found in the search path, the default database
%     stored in /settings/imp_filters_default.mat will be copied to 
%     /userdata/imp_filters.mat and returned
%
%(c)2013-2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 21-Nov-2014

filters = [];

%get filename of import filters database
fn = which('imp_filters.mat');

%if not present check for default database and copy to create impo_filters.mat
if isempty(fn)
   fn_default = which('imp_filters_default.mat');
   if ~isempty(fn_default)
      fn = [gce_homepath,filesep,'userdata',filesep,'imp_filters.mat'];
      status = copyfile(fn_default,fn);
      if status == 0
         fn = '';
      end
   end
end   

if ~isempty(fn)
   try
      v = load(fn,'-mat');
   catch
      v = struct('null','');
   end
   if isfield(v,'data') && isstruct(v.data)
      filters = v.data;
   end
end
