function [meta,msg] = meta_template(template,varnames,fn_templates)
%Generates data descriptor metadata for a GCE Data Structure by matching supplied variable names
%to records in a named metadata template stored in 'imp_templates.mat' or another data structure
%used as a template
%
%syntax:  [meta,msg] = meta_template(template,varnames,fn_templates)
%
%inputs:
%  template = named template, GCE data structure or metadata array to use as a template (string, struct or nx3 cell array; required)
%  varnames = variable names to match (cell array of strings; required)
%  fn_templates = filename of the metadata templates database to use (string; optional; default = 'imp_templates.mat')
%
%outputs:
%  meta = data descriptor metadata structure, with fields:
%     variable = variable name matched (cell array of strings)
%     name = column name (cell array of strings)
%     units = column units (cell array of strings)
%     description = column description (cell array of strings)
%     datatype = column datatype (cell array of strings)
%     variabletype = column variabletype (cell array of strings)
%     numbertype = column numbertype (cell array of strings)
%     precision = column precision (integer array)
%     criteria = column Q/C criteria (cell array of strings)
%     metadata = n x 3 cell array of documentation metadata
%  msg = text of any error message
%
%notes:
%  1) if fn_templates is not in the MATLAB search path the full path and filename must be used
%
%(c)2002-2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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

meta = [];
msg = '';

%check for required arguments
if nargin >= 2

   %validate varnames
   if ~isempty(varnames)
      if ~iscell(varnames)
         varnames = cellstr(varnames);
      end
   else
      msg = 'invalid array of variable names';
   end
   
   %validate fn_template
   if exist('fn_templates','var') ~= 1 || isempty(fn_templates)
      fn_templates = 'imp_templates.mat';
   end

   if ischar(template)

      %load master templates file
      templates = get_templates(fn_templates);

      if ~isempty(templates)
         Itemp = find(strcmp({templates.template},template));  %find specified template
         if isempty(Itemp)
            Itemp = find(strcmpi({templates.template},template));  %try case insensitive match
         end
      else
         Itemp = [];
      end

   elseif isstruct(template)
      
      s = template;

      try  %evaluate as manual templates
         templates = struct( ...
            'variable',{s.variable}, ...
            'name',{s.name}, ...
            'units',{s.units}, ...
            'description',{s.description}, ...
            'datatype',{s.datatype}, ...
            'variabletype',{s.variabletype}, ...
            'numbertype',{s.numbertype}, ...
            'precision',[s.precision], ...
            'criteria',{s.criteria}, ...
            'codes',{repmat({''},1,length(s.name))}, ...
            'metadata',{s.metadata});
         if isfield(s,'codes')
            templates.codes = s.codes;  %use codes if defined
         end
         Itemp = 1;
      catch
         try  %try to convert data structure to template by forcing column names as varnames
            templates = struct( ...
               'variable',{s.name}, ...
               'name',{s.name}, ...
               'units',{s.units}, ...
               'description',{s.description}, ...
               'datatype',{s.datatype}, ...
               'variabletype',{s.variabletype}, ...
               'numbertype',{s.numbertype}, ...
               'precision',[s.precision], ...
               'criteria',{s.criteria}, ...
               'codes',{repmat({''},1,length(s.name))}, ...
               'metadata',{s.metadata});
            Itemp = 1;
         catch
            templates = [];
            Itemp = [];
            msg = 'Invalid data structure (cannot be used as a metadata template)';
         end
      end

   else

      Itemp = [];
      msg = 'Invalid template name or template file ''imp_templates.mat'' is invalid or missing';

   end

   %check for matched template
   if ~isempty(Itemp)

      Itemp = Itemp(1);  %trim index in case of multiple matches (select first)

      numcols = length(varnames);  %get number of columns to match

      %initialize column descriptor metadata fields with default values
      name = repmat({'unknown'},1,numcols);
      datatype = repmat({'u'},1,numcols);
      units = repmat({'unspecified'},1,numcols);
      description = units;
      variabletype = units;
      numbertype = units;
      precision = zeros(1,numcols);
      criteria = repmat({''},1,numcols);
      
      %initialize value code array
      codes = [];

      %extract arrays from template
      t_var = templates(Itemp).variable;
      t_name = templates(Itemp).name;
      t_units = templates(Itemp).units;
      t_description = templates(Itemp).description;
      t_datatype = templates(Itemp).datatype;
      t_variabletype = templates(Itemp).variabletype;
      t_numbertype = templates(Itemp).numbertype;
      t_precision = templates(Itemp).precision;
      t_criteria = templates(Itemp).criteria;
      t_codes = templates(Itemp).codes;

      matches = 0;

      for n = 1:numcols  %search for matches, apply template values

         I = find(strcmp(t_var,varnames{n}));
         if isempty(I)
            I = find(strcmpi(t_var,varnames{n}));  %try case-insensitive match
            if isempty(I)
               I = find(strcmp(t_name,varnames{n}));  %try matching on name field instead of variable field
            end
         end

         if ~isempty(I)

            matches = matches + 1;  %increment match counter

            I = I(1);  %select first match to avoid index errors

            %populate column attributes
            name{n} = t_name{I};
            units{n} = t_units{I};
            description{n} = t_description{I};
            datatype{n} = t_datatype{I};
            variabletype{n} = t_variabletype{I};
            numbertype{n} = t_numbertype{I};
            precision(1,n) = t_precision(I);
            criteria{n} = t_criteria{I};
            
            %check for value codes
            if ~isempty(t_codes{I})
               codes = [codes ; t_name(I),t_codes(I)];
            end

         else
            name{n} = varnames{n};  %use variable name, defaults for other fields
         end

      end

      if matches > 0  %check for at least 1 match
         
         %extract metadata array
         metadata = templates(Itemp).metadata;
         
         %add/update code definitions if defined
         if ~isempty(codes)
            for n = 1:size(codes,1);
               colname = codes{n,1};
               [codenames,codevals] = splitcodes(codes{n,2});
               if ~isempty(codenames) && ~isempty(codevals)
                  metadata = update_codes(metadata,colname,codenames,codevals);
               end
            end
         end

         %generate output metadata
         meta = struct( ...
            'variable',{varnames(:)'}, ...
            'name',{name}, ...
            'units',{units}, ...
            'description',{description}, ...
            'datatype',{datatype}, ...
            'variabletype',{variabletype}, ...
            'numbertype',{numbertype}, ...
            'precision',precision, ...
            'criteria',{criteria}, ...
            'metadata',{metadata});

      else
         msg = 'No matching variables found';
      end

   end

end