function [template,msg] = make_template(template_name,fn,pn)
%Parses a text file to create a metadata template and opens it in the Template Editor application
%
%syntax:  [template,msg] = make_template(template_name,fn,pn)
%
%input:
%  template_name = name to use for the template (string; optional; default = ['New Template (yyyy-mm-dd)'])
%  fn = filename to import (string; optional; prompted if omitted)
%  pn = pathname (string; optional; current path if omitted)
%
%output:
%  template = metadata template structure with fields:
%     'template' = template name (string)
%     'variable' = raw data variable to match (cell array of strings)
%     'name' = data column name to assign (cell array of strings)
%     'units' = data column units to assign (cell array of strings)
%     'description' = data column description (cell array of strings)
%     'datatype' = data column data type to assign (cell array of strings)
%     'variabletype' = data column variable type to assign (cell array of strings)
%     'numbertype' = data column numeric type to assign (cell array of strings)
%     'precision' = data column decimal places (numeric array of integers)
%     'criteria' = data column Q/C flag criteria (cell array of strings)
%     'codes' = data column code definitions (cell array of strings)
%  msg = text of any error message
%
%notes:
%  1) the text file must include the following fields with a 1-line header
%       variable = variable name to match in raw data files (string; required)
%       name = data column name to assign (string; required; no spaces allowed)
%       units = data column units (string; optional)
%       description = data column description (string; optional)
%       datatype = data type to assign ('f','e','d','s' for floating-point, exponenential
%          decimal/integer, string; required)
%       variabletype = column variable type ('data','calculation','nominal','ordinal','logical',
%          'datetime','coord','code','text'; required)
%       numbertype = column numeric type ('continuous','discrete','angular','none')
%       precision = column decimal places (integer; required; 0 for non-numeric)
%       criteria = Q/C flag criteria (string; required)
%       codes = optional list of value codes (string; optional)
%  2) the template be open in the GUI Template Editor for editing - press the Accept button
%     to save the template for use with the GCE Data Toolbox
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
%last modified: 13-May-2013

%init output
template = [];
msg = '';

%set default template name if omitted
if exist('template_name','var') ~= 1 || isempty(template_name)
   template_name = ['New Template (',datestr(now,29),')'];
end

%set default path if omitted
if exist('pn','var') ~= 1 || ~isdir(pn)
   pn = pwd;
else
   pn = clean_path(pn);
end

%check for filename
if exist('fn','var') ~= 1
   fn = '';
end

%prompt for file if omitted or invalid
if isempty(fn) || exist([pn,filesep,fn],'file') ~= 2
   
   %set filemask
   if ~isempty(fn)
      filemask = fn;
   else
      filemask = '*.txt;*.asc;*.csv';
   end
   
   %cache working directory
   curpath = pwd;
   
   %change to toolbox load path if GUI editor(s) open
   pn = getpath('load');
   if ~isempty(pn)
      cd(pn)
   end
   
   %prompt file file
   [fn,pn] = uigetfile(filemask,'Select a Metadata file');
   cd(curpath); drawnow
   if ~ischar(fn)
      fn = '';
   end
   
end

%check for file to laod
if ~isempty(fn)
   
   %check for csv
   if strfind(fn,'.csv') > 0
      delim = ',';
   else
      delim = '';  %general whitespace (tab, space)
   end
   
   %import template
   [data,msg] = imp_ascii(fn,pn,'','','%s %s %s %s %s %s %s %d %s', ...
      {'variable','name','units','description','datatype','variabletype','numbertype','precision','criteria'}, ...
      1,'',delim);
   
   %try again on error with a codes field
   if isempty(data)
      [data,msg] = imp_ascii(fn,pn,'','','%s %s %s %s %s %s %s %d %s %s', ...
         {'variable','name','units','description','datatype','variabletype','numbertype','precision','criteria','codes'}, ...
         1,'',delim);
   end
   
   %check for valid import
   if ~isempty(data)
      
      %get variable column
      varname = extract(data,'variable');
      
      %check for parsed content
      if ~isempty(varname)
         
         %extract metadata
         colname = extract(data,'name');
         units = extract(data,'units');
         desc = extract(data,'description');
         datatype = extract(data,'datatype');
         variabletype = extract(data,'variabletype');
         numbertype = extract(data,'numbertype');
         precision = extract(data,'precision');
         criteria = extract(data,'criteria');
         codes = extract(data,'codes');
         
         if isempty(codes)
            codes = repmat({''},length(colname),1);
         end
         
         %get index of bad data types
         Ibad_dtype = find(~inlist(datatype,{'f','e','d','s'},'sensitive'));
         
         %get index of bad variable types
         Ibad_vtype = find(~inlist(variabletype,{'data','calculation','nominal','ordinal','logical',...
            'datetime','coord','code','text'},'sensitive'));
         
         %get index of bad number types
         Ibad_ntype = find(~inlist(numbertype,{'continuous','discrete','angular','none'},'sensitive'));
         
         %clear 'none' from criteria
         criteria = strrep(criteria,'none','');
         
         %generate warning messages for invalid contents
         if ~isempty(Ibad_dtype)
            datatype(Ibad_dtype) = {'u'};
            msg = [msg,'Invalid data type in ',int2str(length(Ibad_dtype)),' row(s) converted to ''u''; '];
         end
         
         if ~isempty(Ibad_vtype)
            variabletype(Ibad_vtype) = {'unspecified'};
            msg = [msg,'Invalid variable type in ',int2str(length(Ibad_vtype)),' row(s) converted to ''unspecified''; '];
         end
         
         if ~isempty(Ibad_ntype)
            datatype(Ibad_ntype) = {'unspecified'};
            msg = [msg,'Invalid numeric type in ',int2str(length(Ibad_ntype)),' row(s) converted to ''unspecified''; '];
         end
         
         %format warning
         if ~isempty(msg)
            msg = msg(1:end-2);
         end
         
         %get boilerplate metadata fields
         metaflds = meta_fields('FLED');
         
         %generate metadata structure
         template = struct( ...
            'template',template_name, ...
            'variable',{varname}, ...
            'name',{colname}, ...
            'units',{units}, ...
            'description',{desc}, ...
            'datatype',{datatype}, ...
            'variabletype',{variabletype}, ...
            'numbertype',{numbertype}, ...
            'precision',(precision), ...
            'criteria',{criteria}, ...
            'codes',{codes}, ...
            'metadata',{metaflds});
         
      else
         
         %generate error message
         msg = char('Invalid format - file must include a 1-line header and the following fields:',' ', ...
            'variable, name, units, description, datatype, variabletype, numbertype, precision, criteria, codes');
         
      end
      
   end
   
end