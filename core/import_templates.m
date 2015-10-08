function [templates,msg] = import_templates(templates_new,tempnames,templates_old)
%Imports metadata templates to add to or update a GCE Data Toolbox templates database
%
%syntax: [templates,msg] = import_templates(templates_new,tempnames,templates_old)
%
%input:
%   templates_new = templates structure or fully qualified filename of the template database to import
%      (optional; default = prompt for file)
%   tempnames = array of template names to import (cell array of strings - optional; default = prompted)
%   template_old = template structure to update (default = current template database file returned
%       by get_templates.m)
%
%output:
%   templates = structure array with fields:
%      'template' = template name
%      'variable' = nx1 array of variable names
%      'name' = nx1 array of data set column names
%      'units' = nx1 array of column units
%      'description' = nx1 array of column descriptions
%      'datatype' = nx1 array of column data types
%      'variabletype' = nx1 array of column variable types
%      'numbertype' = nx1 array of column number types
%      'precision' = nx1 array of column numeric precisions
%      'criteria' = nx1 array of column QA/QC criteria
%      'codes' = nx1 array of column code definitions
%      'datadata' = nx3 array of column documentation metadata
%   msg = status or error message
%
%(c)2012 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 01-Nov-2012

%initialize output
templates = [];
msg = '';

%check for omitted template or filename
if exist('templates_new','var') ~= 1
   templates_new = '';
end

%check for omitted/invalid templates_old
if exist('templates_old','var') ~= 1 || ~isstruct(templates_old) || ~isfield(templates_old,'template')
   templates_old = [];
end

%check for omitted or character tempnames array
if exist('tempnames','var') ~= 1
   tempnames = [];
elseif ~isempty(tempnames) && ischar(tempnames)
   tempnames = cellstr(tempnames);
end

%check for templates structure as first argument
if ~isstruct(templates_new)
   
   %get filename from templates_new argument
   fn = templates_new;
   
   if isempty(fn) || exist(fn,'file') ~= 2
   
      %cache working directory
      curpath = pwd;
      
      %determine file specifier and starting directory for file prompt
      if isempty(fn)
         filespec = 'imp_templates.mat';
         pn = pwd;
      else
         [pn,fn_base,fn_ext] = fileparts(fn);
         filespec = [fn_base,fn_ext];
         if isempty(pn)
            pn = curpath;
         end
      end
      
      %invoke file prompt dialog
      cd(pn)
      [fn,pn] = uigetfile(filespec,'Select a metadata template file to import');
      cd(curpath)
      drawnow
      
      %form full filename
      if ischar(fn)
         fn = [pn,filesep,fn];  %generate full filename
      else
         fn = '';
      end
         
   end
   
   %load templates from file
   if ~isempty(fn)
      templates_new = get_templates(fn);
      if isempty(templates_new)
         msg = [fn,' does not contain a valid metadata templates structure'];
      end
   else
      templates_new = [];  %import cancelled
   end
   
end

%check for valid template
if isstruct(templates_new) && isfield(templates_new,'template')
   
   %get default working copy of import templates if omitted
   if isempty(templates_old)
      templates_old = get_templates;
   end
   
   %check for templates variables in both files
   if isstruct(templates_old)
      
      %init output using old templates
      templates = templates_old;
      
      %get index of templates to import
      if isempty(tempnames)
         
         %get array of template names
         tempnames = {templates_new.template}';
         
         %prompt using GUI list dialog if none specified
         Isel = listdialog('liststring',tempnames, ...
            'name','Import Templates', ...
            'promptstring','Select metadata templates to import', ...
            'selectionmode','multiple', ...
            'listsize',[0 0 300 500]);
         
         %subset template names to match selection index
         if ~isempty(Isel)
            tempnames = tempnames(Isel);
         end
         
      else
         
         %match names to templates
         tempnames = tempnames(:);  %force column orientation of names
         tempnames_all = {templates_new.template}';  %get cell array of all template names
         [tempnames,Inull,Isel] = intersect(tempnames,tempnames_all);  %get index of matching templates

      end
      
      %check for matched
      if ~isempty(Isel)

         %get array of original template names
         tempnames_orig = {templates_old.template}';
         
         %get array of fieldnames from original structure
         flds = fieldnames(templates_old);
         
         %init counters for creating output message
         num_added = 0;
         num_updated = 0;
         
         %check for add/update by matching to original template names
         for n = 1:length(Isel)
            
            %get match index to original templates
            Imatch = find(strcmpi(tempnames{n},tempnames_orig));
            
            %set add/update index for merged templates
            if ~isempty(Imatch)
               Iupdate = Imatch(1);  %update
               num_updated = num_updated + 1;
            else
               Iupdate = length(templates) + 1;  %add as last element
               num_added = num_added + 1;
            end
            
            %loop through template fields and copy contents if new templates has matching fields
            for m = 1:length(flds)
               if isfield(templates_new,flds{m})
                  templates(Iupdate).(flds{m}) = templates_new(Isel(n)).(flds{m});
               end
            end
            
         end
         
         %generate success message
         msg = ['Import successful - updated ',int2str(num_updated),' existing template(s) and added ',int2str(num_added),' new template(s)'];
         
      end
      
   else
      msg = 'Failed to load original templates database structure';
   end
   
else
   if isempty(msg)
      msg = 'No valid templates database specified - update cancelled';
   end
end



