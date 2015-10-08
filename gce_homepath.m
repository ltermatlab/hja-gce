function pn = gce_homepath(cd_option)
%Returns the base pathname of the current GCE Toolbox instance, optionally changing the working directory
%
%syntax: pn = gce_homepath(cd_option)
%
%input:
%  cd_option = option to change the working directory to the home path
%    0 = no/default
%    1 = yes
%
%output:
%  pn = pathname
%
%(c)2002-2010 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
%
%contact:
%  Wade Sheldon
%  GCE-LTER Project
%  Department of Marine Sciences
%  University of Georgia
%  Athens, GA 30602-3636
%  sheldon@uga.edu
%
%last modified: 12-Sep-2010

if nargin == 0
   cd_option = 0;
end

pn = fileparts(which('gce_homepath'));

if cd_option == 1
   cd(pn)
end