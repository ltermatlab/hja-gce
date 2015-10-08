%Startup script for the GCE Data Toolbox
%
%last modified: 01-Dec-2014

%get current MATLAB search path and working directory
search_path = path;
working_dir = pwd;

%check for toolbox subdirectories, add to top of path if exist and not already in path
if isdir('demo') && isempty(strfind(search_path,[working_dir,filesep,'demo']))
   path([working_dir,filesep,'demo'],path);
end

if isdir('workflows') && isempty(strfind(search_path,[working_dir,filesep,'workflows']))
   path([working_dir,filesep,'workflows'],path);
end

if isdir('extensions') && isempty(strfind(search_path,[working_dir,filesep,'extensions']))
   path([working_dir,filesep,'extensions'],path);
end

if isdir('settings') && isempty(strfind(search_path,[working_dir,filesep,'settings']))
   path([working_dir,filesep,'settings'],path);
end

if isdir('userdata') && isempty(strfind(search_path,[working_dir,filesep,'userdata']))
   path([working_dir,filesep,'userdata'],path);
end

if isdir('xml') && isempty(strfind(search_path,[working_dir,filesep,'xml']))
   path([working_dir,filesep,'xml'],path);
end

if isdir('support') && isempty(strfind(search_path,[working_dir,filesep,'support']))
   path([working_dir,filesep,'support'],path);
end

if isdir('database') && isempty(strfind(search_path,[working_dir,filesep,'database']))
   path([working_dir,filesep,'database'],path);
end

if isdir('mapping') && isempty(strfind(search_path,[working_dir,filesep,'mapping']))
   path([working_dir,filesep,'mapping'],path);
end

if isdir('qaqc') && isempty(strfind(search_path,[working_dir,filesep,'qaqc']))
   path([working_dir,filesep,'qaqc'],path);
end

if isdir('parsers') && isempty(strfind(search_path,[working_dir,filesep,'parsers']))
   path([working_dir,filesep,'parsers'],path);
end

if isdir('plotting') && isempty(strfind(search_path,[working_dir,filesep,'plotting']))
   path([working_dir,filesep,'plotting'],path);
end

if isdir('gui') && isempty(strfind(search_path,[working_dir,filesep,'gui']))
   path([working_dir,filesep,'gui'],path);
end

if isdir('core') && isempty(strfind(search_path,[working_dir,filesep,'core']))
   path([working_dir,filesep,'core'],path);
end

%add main toolbox directory to top of path
if isempty(strfind(search_path,pwd))
   path(working_dir,path)
end

%check for custom paths in localpaths.txt, add to top of runtime path
if exist('localpaths.txt','file') == 2
   try
      ar = textfile2cell('localpaths.txt',fileparts(which('localpaths.txt')));
   catch
      ar = [];
   end
   for cnt = length(ar):-1:1
      pn = strrep(strrep(ar{cnt},'"',''),'''','');  %remove quotes
      if ~isempty(pn) && ~strncmpi('%',pn,1) && isdir(pn) && isempty(strfind(search_path,pn))
         path(pn,path)  %add to path
      end
   end
   clear cnt ar pn
end

%change console dpi scaling factor for non-Windows systems to improve GUI layout
set(0,'ScreenPixelsPerInch',96)

%delete temporary workspace variable
clear search_path working_dir

%open splash dialog
ui_aboutgce
