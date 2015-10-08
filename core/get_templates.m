function templates = get_templates(fn,upgradefile)
%Retrieves a structure containing GCE Data Toolbox metadata templates
%
%syntax: templates = get_templates(fn,upgradefile)
%
%input:
%   fn = filename of the template file to update (string; optional; default = which('imp_templates.mat'))
%   upgradefile = option to upgrade the templates file if a 'codes' field is not present (integer; optional; default = 1)
%      0 = no
%      1 = yes (default)
%
%output:
%   msg = status message
%
%notes:
%  1) if fn is not in the MATLAB search path the full path and filename must be used
%
%
%(c)2011-2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 28-May-2015

templates = [];

%get filename of templates database
if exist('fn','var') ~= 1
   
   %check for working copy of database
   fn = which('imp_templates.mat');
   
   %if not present copy default database from settings to userdata
   if isempty(fn)
      fn_default = which('imp_templates_default.mat');
      if ~isempty(fn_default)
         fn = [gce_homepath,filesep,'userdata',filesep,'imp_templates.mat'];
         status = copyfile(fn_default,fn);
         if status == 0
            fn = '';
         end
      end
   end
   
end

%verify file existence
if exist(fn,'file') == 2
   
   %set default upgrade option if omitted
   if exist('upgradefile','var') ~= 1
      upgradefile = 1;
   end

   %load the templates file
   try
      vars = load(fn,'-mat');
   catch
      vars = struct('null','');
   end
   
   %validate file
   if isstruct(vars) && isfield(vars,'templates')
      
      %cache original templates
      templates = vars.templates;
      
      %check for missing codes field
      if ~isfield(templates,'codes')

         %buffer old templates
         oldtemplates = templates;
         
         %look up fieldnames
         fields = fieldnames(oldtemplates);
         
         %init new templates struct
         templates = struct('template','');
         
         %loop through template records
         for n = 1:length(oldtemplates)
            
            %copy all fields except metadata (to keep at the end)
            for f = 1:length(fields)
               fname = fields{f};
               if ~strcmp(fname,'metadata')
                  templates(n).(fname) = oldtemplates(n).(fname);
               end
            end
            
            %add new codes field with empty string for each variable
            numcols = length(oldtemplates(n).variable);
            templates(n).codes = repmat({''},numcols,1);

            %add metadata as last field
            templates(n).metadata = oldtemplates(n).metadata;
            
         end

         if upgradefile == 1
            %save revised templates structure to disk, preserving any other variables
            save(fn,'templates','-append')
         end
         
      end
      
   end
   
end
