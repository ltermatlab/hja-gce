function [s2,msg] = apply_template(s,template,metaopt,logchanges,fn_templates)
%Applies a metadata template to a data structure, matching parameters by name
%and confirming data type and units compatibility
%
%syntax: [s2,msg] = apply_template(s,template,metaopt,logchanges,fn_templates)
%
%input:
%  s = data structure to modify (struct; required)
%  template = name of metadata template or GCE Data Structure to use as a template (string or struct; required)
%  metaopt = metadata content import option (string; optional)
%    'all' = import all attribute metadata and documentation metadata (default)
%    'selected' = import all attribute metadata and selected documentation metadata
%    'attributes' or 'none' = import all attribute metadata and no documentation metadata
%    'doc_all' = import all documentation metadata and no attribute metadata
%    'doc_selected' = import selected documentation metadata and no attribute metadata
%  logchanges = option to log field changes to the structure processing history (integer; optional)
%    0 = no
%    1 = yes (default)
%  fn_templates = filename of the metadata templates database to use (string; optional; default = 'imp_templates.mat')
%
%output:
%  s2 = modified data structure
%  msg = text of any error message
%
%notes:
%  1) if fn_templates is not in the MATLAB search path the full path and filename must be used
%  2) for metaopt = all or doc_all, only non-empty metadata fields from tne specified template or dataset
%     will be imported, so data-set-specific metadata content (e.g. Site/Location, Data/Anomalies) 
%     will be retained
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

%init output
s2 = [];

%check for required input
if nargin >= 2
   
   %default to 'all' sections if not specified
   if exist('metaopt','var') ~= 1 || isempty(metaopt)
      metaopt = 'all';
   else
      metaopt = lower(metaopt);
      if sum(inlist(metaopt,{'all','selected','none','attributes','doc_all','doc_selected'})) == 0
         metaopt = 'all';
      end
   end
   
   %default to logging all metadata changes
   if exist('logchanges','var') ~= 1 || isempty(logchanges)
      logchanges = 1;
   end
   
   %validate fn_template
   if exist('fn_templates','var') ~= 1 || isempty(fn_templates)
      fn_templates = 'imp_templates.mat';
   end
   
   %validate data structure
   if gce_valid(s,'data')
      
      %get descriptors for all matched columns
      [meta,msg] = meta_template(template,s.name,fn_templates);
      
      %check for structure template, convert to label for metadata updates
      if isstruct(template)
         template = 'data structure';
      end
      
      %check for match
      if ~isempty(meta)
         
         %check for doc-only options
         if ~strncmpi(metaopt,'doc',3)
            
            %use input structure to init output
            s2 = s;
            numcols = length(s2.name);
            
            %init match/unmatched indices
            Iupdate = zeros(1,numcols);
            Ibadunits = Iupdate;
            Ibaddtype = Iupdate;
            Inomatch = Iupdate;
            
            %loop through data structure, updating attribute metadata if matched
            for n = 1:numcols
               
               %check for matched parameters based on datatype 'u' = 'unspecified'
               if ~strcmp(meta.datatype{n},'u')
                  
                  Iupdate(n) = 1;  %add column to matched index
                  
                  s2.name{n} = meta.name{n};  %update name
                  
                  %update units, checking compatibility
                  if isempty(deblank(s2.units{n})) || strcmpi(deblank(s2.units{n}),'unspecified')
                     s2.units{n} = meta.units{n};  %update units if originally blank or unspecified
                  elseif strcmpi(deblank(s2.units{n}),deblank(meta.units{n})) ~= 1
                     Ibadunits(n) = 1;  %add to failed unit update index if existing units don't match template
                  end
                  
                  s2.description{n} = meta.description{n};  %update description
                  
                  %update data type, numbertype and precision, checking for numeric/string compatibility
                  dtype = s2.datatype{n};
                  dtype_new = meta.datatype{n};
                  if (strcmp(dtype,'s') && strcmp(dtype_new,'s')) || (~strcmp(dtype,'s') && ~strcmp(dtype_new,'s'))
                     s2.datatype{n} = meta.datatype{n};
                     s2.numbertype{n} = meta.numbertype{n};
                     s2.precision(n) = meta.precision(n);
                  else
                     Ibaddtype(n) = 1;
                  end
                  
                  s2.variabletype{n} = meta.variabletype{n};  %update variable type
                  
                  s2.criteria{n} = meta.criteria{n};  %update criteria
                  
               else
                  Inomatch(n) = 1;  %add column to unmatched index
               end
               
            end
            
            %resolve match indices
            Iupdate = find(Iupdate);
            Ibadunits = find(Ibadunits);
            Ibaddtype = find(Ibaddtype);
            Inomatch = find(Inomatch);
            
         else  %doc only
            
            s2 = s;
            Iupdate = NaN;
            Ibadunits = [];
            Ibaddtype = [];
            Inomatch = [];
            
         end
         
      else  %no match
         
         Iupdate = [];
         Ibadunits = [];
         Ibaddtype = [];
         Inomatch = [];
         
      end
      
      %check for any updates and validate data structure
      if ~isempty(Iupdate) && gce_valid(s2,'data') == 1
         
         %init metadata record update index
         Imetasection = [];
         
         if strcmpi(metaopt,'all') || strcmpi(metaopt,'doc_all')
            
            %select all non-empty template metadata fields for updating
            if ~isempty(meta.metadata)
               Imetasection = find(~cellfun('isempty',meta.metadata(:,3)));
            end
            
         elseif strcmpi(metaopt,'selected') || strcmpi(metaopt,'doc_selected')
            
            %bring up a dialog for choosing metadata sections to update from template
            if ~isempty(meta.metadata)
               
               %get index of non-empty template metadata fields
               Ivalid = find(~cellfun('isempty',meta.metadata(:,3)));
               
               if ~isempty(Ivalid)
                  
                  %generate cell array for list dialog
                  metastr = concatcellcols([concatcellcols(meta.metadata(Ivalid,1:2),'_'),meta.metadata(Ivalid,3)],':   ');
                  
                  %open list dialog for choosing sections
                  Isel = listdialog('liststring',metastr, ...
                     'selectionmode','multiple', ...
                     'promptstring','Select metadata content to import', ...
                     'name','Import Metadata', ...
                     'listsize',[0 0 640 500]);
                  
                  %update main metadata record selector index
                  if ~isempty(Isel)
                     Imetasection = Ivalid(Isel);
                  end
                  
               end
            end
            
         end
         
         %generate processing history string based on metaopt
         if strcmpi(metaopt,'selected') || strcmpi(metaopt,'doc_selected')
            str_hist = 'imported selected documentation metadata';
         else
            str_hist = 'imported all documentation metadata';
         end         
         
         if strcmp(template,'data structure')
            str_hist = [str_hist,' from another data structure'];
         else
            str_hist = [str_hist,' from the template ''',template,''''];
         end
         
         %check for metadata only
         if ~strncmpi(metaopt,'doc',3)
            if length(Iupdate) == 1
               colstr = 'column ';
            else
               colstr = 'columns ';
            end
            str_hist = [str_hist,', updating descriptors for ',colstr,cell2commas(s2.name(Iupdate),1)];
         else
            str_hist = [str_hist,', retaining existing attribute descriptors for all columns'];
         end
         
         %update processing history
         s2.history = [s2.history ; ...
            {datestr(now)},{[str_hist,' (''meta_template'')']}];
         
         %incorporate template metadata sections
         if ~isempty(Imetasection)
            s2 = addmeta(s2,meta.metadata(Imetasection,:),0,'apply_template');
         end
         
         %check for title in selection, call newtitle function to sync to data set title
         if ~isempty(meta.metadata)
            Ititle = find(strcmpi('Dataset',meta.metadata(Imetasection,1)) & strcmpi('Title',meta.metadata(Imetasection,2)));
            if ~isempty(Ititle)
               tstr = char(meta.metadata(Imetasection(Ititle),3));
               s2 = newtitle(s2,tstr,0);
            end
         end
         
         %update qc flags if criteria defined
         if ~strncmpi(metaopt,'doc',3) && sum(~cellfun('isempty',s2.criteria)) > 0
            s2 = dataflag(s2);
         end
         
         %generate output message strings for non-updated units, unmatched parameters
         if ~isempty(Ibadunits) || ~isempty(Inomatch)
            
            msg = '';  %init message string to clear residual message from meta_template
            
            %check for non-updated datatype, numbertype, precision
            if ~isempty(Ibaddtype)
               if length(Ibaddtype) > 1
                  colstr = 'columns ';
               else
                  colstr = 'column ';
               end
               msg = ['Data Type, Numerical Type and Precision were not updated for ',colstr,cell2commas(s2.name(Ibaddtype),1), ...
                  ' due to column incompatibility'];
            end
            
            %check for non-updated units
            if ~isempty(Ibadunits)
               if length(Ibadunits) > 1
                  colstr = 'columns ';
               else
                  colstr = 'column ';
               end
               msg2 = ['Units were not updated for ',colstr,cell2commas(s2.name(Ibadunits),1), ...
                  ' to prevent possible invalidation  '];
               if isempty(msg)
                  msg = msg2;
               else
                  msg = char(msg,' ',msg2);
               end
            end
            
            %check for unmatched parameters
            if ~isempty(Inomatch)
               if length(Inomatch) > 1
                  colstr = 'columns ';
               else
                  colstr = 'column ';
               end
               msg2 = ['Metadata were not updated for ',colstr,cell2commas(s2.name(Inomatch),1), ...
                  ' because no matching ',colstr,'were present in the specified template'];
               if isempty(msg)
                  msg = msg2;
               else
                  msg = char(msg,' ',msg2);
               end
            end
            
            %log changes
            if ~isempty(s2) && logchanges == 1
               editstr = log_metachanges(s,s2,'cell');
               num = length(editstr);
               if num > 0
                  ar = [repmat({datestr(now)},num,1) concatcellcols([editstr repmat({'(''apply_template'')'},num,1)],' ')];
                  s2.history = [s2.history ; ar];
               end
            end
            
         end
         
      else  %no matched variables or invalid data structure
         s2 = [];
         msg = ['the ''',template,''' template was not found in ''imp_templates.mat'' or no variables were matched'];
      end
      
   else
      msg = 'invalid data structure';
   end
   
else
   msg = 'insufficient arguments for function';
end
