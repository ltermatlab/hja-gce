function [s2,msg] = multi_templates(s,templates,datecol,logchanges)
%Applies multiple, date-dependent metadata templates to a data set to accomodate parameter metadata changes
%
%Note that general documentation metadata and parameter units will be standardized based on
%information in one designated 'primary' template (or the first listed template if no
%primary template is specified).
%
%syntax: [s2,msg] = multi_templates(s,templates,datecol)
%
%inputs:
%  s = data structure to modify
%  templates = structure containing the following fields specifying metadata templates and date ranges
%     'template' = string listing a valid metadata template in 'imp_templates.mat'
%     'start' = string specifying inclusive start date/time for applying the template
%        (format: MM/DD/YYYY hh:mm:ss, '' for indefinite)
%     'end' = string specifying inclusive ending date/time for applying the template
%        (format MM/DD/YYYY hh:mm:ss, '' for indefinite)
%     'primary' = integer indicating primary template for documentation metadata and parameter units
%        1 = yes (use template for metadata documentation and parameter units)
%        0 = no (do not import documentation, convert parameter units if different than primary template)
%        (note: the first template with primary = 1 will be used, and if no templates have primary = 1
%         then the first template will be assumed to be primary)
%  datecol = serial data column (automatically determined or calculated if omitted)
%  logchanges = option to log field changes to the structure processing history
%    0 = no
%    1 = yes (default)
%
%outputs:
%  s2 = modified structure
%  msg = text of any error message
%
%notes:
%  1) if a serial date column is not specified and cannot be determined automatically then
%     an empty structure will be returned with an error message
%  2) if column units differ between templates and a switch occurs within the data set, unit_convert()
%     will automatically be called to convert values to match the units of the earliest template; if
%     corresponding units are not present in the conversions database a warning emssage will be returned
%
%(c)2007-2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 30-Sep-2013

s2 = [];
msg = '';

if nargin >= 2
   
   %default to logging all metadata changes
   if exist('logchanges','var') ~= 1
      logchanges = 1;
   end
   
   %load templates database
   all_templates = get_templates;
   
   %check for valid database
   if ~isempty(all_templates) && isstruct(all_templates) && isfield(all_templates,'template')
      
      %validate database
      if gce_valid(s,'data')
         
         if exist('datecol','var') ~= 1
            datecol = [];
         end
         
         %look up dates for observations
         dt = get_studydates(s,datecol);
         
         if ~isempty(dt)
            
            err = 0;
            
            %validate templates structure format
            if ~isstruct(templates)
               err = 1;
            elseif ~isfield(templates,'template')
               err = 1;
            elseif ~isfield(templates,'start') || ~isfield(templates,'end') || ~isfield(templates,'primary')
               err = 1;
            end
            
            if err == 0
               
               %get index of primary template
               try
                  Iprimary = min(find([templates.primary] == 1));
               catch
                  Iprimary = [];
               end
               if isempty(Iprimary)
                  Iprimary = 1;  %use first template if none flagged as primary or invalid field format
               end
               
               %get indices for template matches
               Itemplate = zeros(length(templates),1);
               num_templates = length(templates);
               all_temp = {all_templates.template};
               for n = 1:num_templates
                  %find first matching template, case insensitively
                  Itemplate(n) = min(find(strcmpi(templates(n).template,all_temp)));
               end
               
               if length(find(Itemplate)) == num_templates
                  
                  %get metadata array from primary template
                  metadata = all_templates(Itemplate(Iprimary)).metadata;
                  
                  %get column names
                  parms = s.name;
                  
                  %get master metadata template
                  meta0 = meta_template(templates(Iprimary).template,parms);
                  
                  %use existing structure metadata for any unmatched fields
                  Iunmatched = find(strcmp({meta0.datatype},'u'));
                  for n = 1:length(Iunmatched)
                     col = {Iunmatched(n)};
                     meta0.name{col} = s.name{col};
                     meta0.units{col} = s.units{col};
                     meta0.description{col} = s.description{col};
                     meta0.datatype{col} = s.datatype{col};
                     meta0.variabletype{col} = s.variabletype{col};
                     meta0.numbertype{col} = s.numbertype{col};
                     meta0.precision(col) = s.precision(col);
                     meta0.criteria{col} = s.criteria{col};
                  end
                  
                  %init master row selection index, row counter
                  Irows = cell(num_templates,1);
                  Iallrows = [];
                  
                  %look up row indices for each template
                  for n = 1:num_templates
                     dstart = templates(n).start;
                     dend = templates(n).end;
                     if isempty(dstart)
                        d1 = -inf;
                     else
                        try
                           d1 = datenum(dstart);
                        catch
                           d1 = NaN;
                        end
                     end
                     if isempty(dend)
                        d2 = inf;
                     else
                        try
                           d2 = datenum(dend);
                        catch
                           d2 = NaN;
                        end
                     end
                     if ~isnan(d1) && ~isnan(d2)
                        Irows{n} = find(dt>=d1 & dt<=d2);    %look up records with dates between start & end
                        Iallrows = [Iallrows ; Irows{n}];    %update cumulative row match array
                     end
                  end
                  
                  %validate row matches
                  numrows = length(Iallrows);
                  numdatarows = length(s.values{1});
                  numrowsunique = length(unique(Iallrows));
                  
                  if numrows == numdatarows && numrows == numrowsunique
                     
                     %get index of matched templates
                     Ivalid = find(~cellfun('isempty',Irows));
                     num_matched = length(Ivalid);
                     
                     %initcell array for split structures
                     s_all = cell(num_matched,1);
                     
                     %init conversion failure array
                     badconvert = zeros(1,length(s.name));
                     
                     %init history string
                     histstr = 'applied date-specific metadata templates to structure (''multi_templates''): ';
                     
                     for n = 1:num_matched
                        
                        %extract subset of rows
                        s_tmp = copyrows(s,Irows{Ivalid(n)},'Y');
                        
                        %apply master metadata array if first structure, otherwise clear metadata to speed merge
                        if n == 1
                           s_tmp.metadata = metadata;
                        else
                           s_tmp.metadata = [];
                        end
                        
                        %perform parameter lookups
                        matched_template = all_templates(Itemplate(Ivalid(n))).template;
                        meta_tmp = meta_template(matched_template,s_tmp.name);
                        
                        %loop through columns to apply matched template metadata, convert units
                        for m = 1:length(s_tmp.name)
                           
                           %apply template metadata if matched
                           if ~strcmp(meta_tmp.datatype{m},'u')
                              s_tmp.name{m} = meta_tmp.name{m};
                              s_tmp.units{m} = meta_tmp.units{m};
                              s_tmp.description{m} = meta_tmp.description{m};
                              s_tmp.datatype{m} = meta_tmp.datatype{m};
                              s_tmp.variabletype{m} = meta_tmp.variabletype{m};
                              s_tmp.numbertype{m} = meta_tmp.numbertype{m};
                              s_tmp.precision(m) = meta_tmp.precision(m);
                              s_tmp.criteria{m} = meta_tmp.criteria{m};
                           end
                           
                           %perform unit conversions if units don't match master template
                           %(note: if conversion fails leaves units unchanged for column offsetting in datamerge)
                           if ~strcmp(meta0.units{m},s_tmp.units{m})
                              [s_tmp2,msg] = unit_convert(s_tmp,m,meta0.units{m});  %perform conversion
                              if ~isempty(s_tmp2)
                                 s_tmp = s_tmp2;  %conversion successful - apply to current structure
                              else
                                 badconvert(m) = 1;  %flag column as bad conversion
                              end
                           end
                           
                        end
                        
                        %add modified structure to main output array
                        s_all{n} = s_tmp;
                        
                        %generate history string entry
                        dstart = templates(Ivalid(n)).start;
                        if isempty(dstart)
                           dstart = datestr(min(dt),0);
                        else
                           dstart = datestr(datenum(dstart),0);
                        end
                        
                        dend = templates(Ivalid(n)).end;
                        if isempty(dend)
                           dend = datestr(max(dt),0);
                        else
                           dend = datestr(datenum(dend),0);
                        end
                        
                        histstr = [histstr,'template ''',templates(Ivalid(n)).template,''' applied for dates ', ...
                           dstart,' to ',dend, ...
                           ' (',int2str(length(Irows{Ivalid(n)})),' record(s)), '];
                        
                     end
                     
                     histstr = histstr(1:end-2);
                     
                     %merge all structures
                     s2 = s_all{1};
                     for n = 2:length(s_all)
                        s2 = datamerge(s2,s_all{n},1,1,1,0,0);
                     end                     
                     
                     %replace merge title with original
                     s2 = newtitle(s2,s.title);
                     
                     %update original history to include multi templates
                     s2.history = [s.history ; {datestr(now)},{histstr}];
                     
                     %update q/c flags
                     s2 = dataflag(s2);
                     
                     %log changes
                     if ~isempty(s2) && logchanges == 1
                        editstr = log_metachanges(s,s2,'cell');
                        num = length(editstr);
                        if num > 0
                           ar = [repmat({datestr(now)},num,1) concatcellcols([editstr repmat({'(''apply_template'')'},num,1)],' ')];
                           s2.history = [s2.history ; ar];
                        end
                     end
                     
                     %check for bad unit conversions
                     if sum(badconvert) > 0
                        msg = ['automatic unit conversions failed for column(s): ',cell2commas(s.name(badconvert==1),1)];
                     end
                     
                  else
                     if numrows > numdatarows || numrows > numrowsunique
                        msg = 'overlapping date ranges in templates (rows would be duplicated)';
                     else
                        msg = 'incomplete date range coverage in specified templates (rows would be deleted)';
                     end
                  end
                  
               else
                  msg = 'one or more specified templates are not present in ''imp_templates.mat''';
               end
               
            else
               msg = 'unrecognized ''templates'' format';
            end
            
         else
            msg = 'no date/time columns could be identified in the data structure';
         end
         
      else
         msg = 'invalid data structure';
      end
      
   else
      msg = 'required master metadata templates file ''imp_templates.mat'' not found or is invalid';
   end
   
else
   msg = 'insufficient arguments for function';
end