function edit_unitconv(op,data)
%Dialog for editing unit conversion tables used by the GCE Data Toolbox.
%
%syntax: edit_unitconv(op,table)
%
%inputs:
%  op = operation to perform:
%     'conversions' - opens unit conversions table for editing
%     'englishmetric' - opens English<->Metric conversions table for editing
%  table = table to edit:
%    'conversions' - unit conversion equations table
%    'englishmetric' - english<->metric conversion table
%
%outputs:
%  none
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
%last modified: 20-May-2013

if nargin == 0
   op = 'conversions';
end

switch op

case 'conversions'  %load unit conversions, populate structure, send to editor

   if exist('ui_unitconv.mat','file') == 2

      try
         v = load('ui_unitconv.mat');
      catch
         v = struct('null','');
      end

      if isfield(v,'conversions')

         %get variable
         conversions = v.conversions;
         
         %init basic data structure with unit info for editing
         tmp = {conversions.multiplier}';
         tmp(cellfun('isempty',tmp)) = {NaN};
         data = newstruct;
         data.name = fieldnames(conversions)';
         data.units = repmat({'none'},1,5);
         data.precision = [0 0 9 0 0];
         data.datatype = [{'s'},{'s'},{'f'},{'s'},{'s'}];
         data.variabletype = repmat({'nominal'},1,5);
         data.description = [{'Original units'}, ...
               {'Converted units'}, ...
               {'Multiplication factor'}, ...
               {'Format string for documenting multiplication factor in the metadata'}, ...
               {'Equation to be evaluated if no multiplication factor provided'}];
         data.numbertype = [{'none'},{'none'},{'continuous'},{'none'},{'none'}];
         vals = cell(1,5);
         vals{1} = {conversions.units1}';
         vals{2} = {conversions.units2}';
         vals{3} = cat(1,tmp{:});
         vals{4} = {conversions.formatstring}';
         vals{5} = {conversions.equation}';
         data.values = vals;
         data.criteria = repmat({''},1,5);
         data.flags = data.criteria;
         data.title = 'GCE Data Toolbox unit conversion table';
         data.metadata = [{'Dataset'},{'Title'},{data.title}];
         data.datafile = [{'none'},{0}];

      else
         data = [];
      end

      if ~isempty(data)
         ui_datagrid('init',data,[],'edit_unitconv(''save'',s)',120,'left');
      else
         messagebox('init','The unit conversions data file ''ui_unit_conv.mat'' is invalid',[],'Error',[.9 .9 .9])
      end

   else
      messagebox('init','The unit conversions data file ''ui_unit_conv.mat'' is invalid',[],'Error',[.9 .9 .9])
   end

case 'englishmetric'  %load english/metric table, populate structure, send to editor

   if exist('ui_unitconv.mat','file') == 2
      try
         v = load('ui_unitconv.mat');
         data = v.englishmetric;
      catch
         data = [];
      end
   else
      data = [];
   end

   if ~isempty(data)
      ui_datagrid('init',data,[],'edit_unitconv(''save'',s)',120,'left');
   else
      messagebox('init','The unit conversions data file ''ui_unit_conv.mat'' was not found',[],'Error',[.9 .9 .9])
   end

case 'save'  %process edited conversions

   if exist('data','var') == 1 && exist('ui_unitconv.mat','file') == 2

      try
         v = load('ui_unitconv.mat');
      catch
         v = struct('null','');
      end

      if gce_valid(data,'data') && isfield(v,'conversions') && isfield(v,'englishmetric')

          %grab original variables for disk file
          conversions = v.conversions;
          englishmetric = v.englishmetric;

         if length(data.name) == 2  %english-metric

            englishmetric = data;

         else  %unit conversions

            %extract data arrays, reformat into structure
            vals = data.values;
            tmp = vals{3};
            Inan = isnan(tmp);
            tmp2 = num2cell(tmp);
            tmp2(Inan) = {[]};
            
            %generate structure
            c = [vals{1},vals{2},tmp2,vals{4},vals{5}];
            conversions = cell2struct(c,data.name,2);
            
            %sort structure by units1, units2
            if ~isempty(conversions)
               [tmp,I2] = sort(lower({conversions.units2}));
               [tmp,I1] = sort(lower({conversions(I2).units1}));
               conversions = conversions(I2(I1));
            end

         end

         %save updated units file over original
         save(which('ui_unitconv.mat'),'conversions','englishmetric')

      end

   end

end