function template = lookup_template(default)
%Opens a GUI list dialog for selecting a metadata template defined in imp_templates.mat
%
%syntax: template = lookup_template(default)
%
%input:
%  default = default template to select (default = '' for none)
%
%output:
%  template = selected template ('' for none if user cancels)
%
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
%last modified: 12-Oct-2011

template = '';

if exist('default','var') ~= 1
   default = '';
end

%get master template structure
templates = get_templates;

if ~isempty(templates)
   
   %get array of template names
   tempnames = {templates.template}';
   
   %set default initial value
   if ~isempty(default)
      initval = find(strcmpi(default,tempnames));
      if length(initval) > 1
         initval = initval(1);
      elseif isempty(initval)
         initval = 1;
      end
   else
      initval = 1;
   end
   
   Isel = listdialog('liststring',tempnames, ...
      'name','Template Selection', ...
      'promptstring','Select a metadata template', ...
      'initialvalue',initval, ...
      'selectionmode','single', ...
      'listsize',[0 0 300 500]);
   
   if ~isempty(Isel)
      template = tempnames{Isel};
   end
   
end
