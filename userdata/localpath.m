function pn = localpath(pathtype)
%Returns a localized path name stored as a variable in /userdata/localpaths.mat
%
%syntax: pn = localpath(pathtype)
%
%input:
%  pathtype = pathtype to match to a variable name in /userdata/localpaths.mat
%
%output:
%  pn = path (contents of pathtype variable in /userdata/localpaths.mat)
%
%usage notes:
%  1) use this function in a workflow function or script to dynamically return a localized path 
%     on a specific system (e.g. pn = localpath('rawdata'))
%  2) the file /userdata/localpaths.mat should contain character array variables for each
%     pathtype referenced in workflows functions or scripts
%
%by Wade Sheldon <sheldon@uga.edu>, GCE-LTER Project, University of Georgia
%
%last updated: 29-Aug-2013

if exist('localpaths.mat','file') == 2
   
   %load paths file
   vars = load('localpaths.mat');
   
   %return specific path variable
   try
      pn = vars.(pathtype);
   catch
      pn = '';
   end

else
   pn = '';
end