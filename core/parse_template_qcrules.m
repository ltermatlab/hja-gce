function qcrules = parse_template_qcrules(templates)
%Parses Q/C rules in the GCE Data Toolbox metadata templates library and lists rules by variable
%
%syntax: qcrules = parse_template_qcrules(templates)
%
%input:
%  templates = GCE Data Toolbox templates database structure (struct; optional; default = get_templates())
%
%output:
%  qcrules = cell array of unique Q/C rule sets by variable
%
%(c)2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 18-Dec-2014

%init output
qcrules = [];

%load metadata templates
if nargin == 0
   templates = get_templates;
end

if isstruct(templates) && isfield(templates,'criteria') && isfield(templates,'name')

   %init master criteria list
   allcrit = cell(length(templates),1);   

   %generate master criteria list for each template
   for n = 1:length(templates)
      
      %get arrays of criteria, variable names
      crit = templates(n).criteria;
      vars = templates(n).name;
      
      %get index of non-empty rules
      Ivalid = find(~cellfun('isempty',strrep(crit,' ','')));
      
      %prepend column name to criteria
      allcrit{n} = concatcellcols([vars(Ivalid),repmat({': '},length(Ivalid),1),crit(Ivalid)],'');
      
   end
   
   %remove empty cells
   allcrit = allcrit(~cellfun('isempty',allcrit));
   
   %count total rules
   numrules = sum(cellfun('length',allcrit),1);
   
   %init master list of rules
   qcrules = cell(numrules,1);
   
   %split out parsed rules into individual cells
   Iend = 0;
   for n = 1:length(allcrit)
      ar = allcrit{n};
      len = length(ar);
      Istart = Iend + 1;
      Iend = Istart + len - 1;
      qcrules(Istart:Iend) = ar;
   end
   
   %generate unique rules
   qcrules = unique(qcrules);
   
   %sort rules case-insensitively
   [~,Isort] = sort(lower(qcrules));
   qcrules = qcrules(Isort);
   
end
