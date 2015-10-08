function [s2,msg,badfields] = imp_struct(source,pn,template,fields)
%Imports a MATLAB structure containing matching arrays or scalar values to a GCE Data Structure
%using field names as column names
%
%syntax: [s2,msg,badfields] = imp_struct(source,pn,template,fields)
%
%input:
%  source = structure to import (struct variable, filename. or 'workspace' to 
%     prompt for a workspace structure variable to import (default)
%  pn = pathname for source (default = pwd or none for source = 'workspace')
%  template = metadata template to apply after conversion
%  fields = list of fields to import:
%     'all' = all fields (default if no ui_editor.m instance is open)
%     'choose' = choose fields to import from a GUI listbox (default if a ui_editor.m instance is open)
%     cell array = array of specific fields to import
%
%output:
%  s2 = derived GCE Data Structure
%  msg = text of any error message
%  badfields = array of fieldnames that could not be converted
%
%notes:
%  1. each structure field imported must contain a consistent type of numeric or string data
%  2. for scalar structures, each field imported must include a matching-length numeric array or
%     cell array of strings
%  3. for multi-dimensional structures, each field must include a scalar number or character array
%
%(c)2009-2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 02-Apr-2013

%init output
s2 = [];
badfields = [];
msg = '';

%check for required input
if nargin >= 1
   
   %validate path and check for legacy syntax with template as second argument
   if exist('pn','var') == 1
      if ~isdir(pn)
         template = pn;
         pn = '';
      end
   else
      pn = '';
   end
   
   %set default fields option if omitted
   if exist('fields','var') ~= 1
      if length(findobj) > 1 && ~isempty(findobj('Tag','dlgDSEditor'))
         fields = 'choose';  %editor open - default to choose
      else
         fields = '';  %no editor - default to all
      end
   elseif ischar(fields) && strcmpi(fields,'all')
      fields = '';
   end
   
   %check for filename or workspace variable prompt
   if ischar(source)
      
      if strcmpi(source,'workspace')
         
         %get list of variables in workspace
         ws = evalin('base','whos');
         
      else  %file input
         
         %generate filename
         fn = source;
         if ~isempty(pn)
            fn = [clean_path(pn),filesep,source];  %pre-pend path to fn
         end
         
         %get list of variables in file
         try
            ws = whos('-file',fn);
         catch
            ws = [];
         end
         
      end
      
      if ~isempty(ws)
         
         %get index of structure arrays
         Ivalid = find(strcmp({ws.class},'struct'));
         
         %check for structure variables
         if ~isempty(Ivalid)
             ws = ws(Ivalid);  %remove unsupported variables
             numvars = length(Ivalid);
             if numvars > 1
                 varlist = concatcellcols([{ws.name}' ...
                         repmat({' ('},numvars,1) ...
                         strrep(cellstr(int2str([ws.bytes]')),' ','') ...
                         repmat({' bytes)'},numvars,1)],'');
                 res = get(0,'screensize');
                 Isel = listdialog('liststring',varlist, ...
                     'selectionmode','single', ...
                     'name','Select a structure variable to import', ...
                     'listsize',[max(0,0.5.*(res(3)-250)) max(50,0.5.*(res(4)-300)) 250 300]);
                 drawnow
             else
                 Isel = 1;
             end
         else
            Isel = [];
         end
         
         %check for a valid selection and retrieve data
         if ~isempty(Isel)
            if strcmpi(source,'workspace')
               s = evalin('base',ws(Isel).name,'[]');
            else
               vars = load(fn);
               s = vars.(ws(Isel).name);
            end
         else
            s = [];
         end
         
      else
         s = [];
      end
      
   else  %structure input
      s = source;      
   end
   
   %check for a valid structure to import
   if isstruct(s)
      
      %set empty template if omitted
      if exist('template','var') ~= 1
         template = '';
      end
      
      %check for GCE Data Structure - just apply template
      if gce_valid(s,'data')
         
         if ~isempty(template)
            [s2,msg] = apply_template(s,template);
         else
            s2 = s;
         end
         
      else
         
         %force single struct dimension
         s = s(:);
         
         %get field names
         allcols = fieldnames(s);
         colnames = [];
         
         %validate field selection
         if iscell(fields)
            
            %validate specified columns
            [colnames,idx] = intersect(fields,allcols);
            colnames = fields(sort(idx));
            
         else
            
            if isempty(fields)
               
               %all columns
               colnames = allcols;
               
            else  %choose
               
               %generate column description array
               numcols = length(allcols);
               if length(s) > 1
                  str = concatcellcols([allcols,repmat({'(',int2str(length(s)),' values)'},numcols,1)],'  ');
               else
                  str = repmat({''},numcols,1);
                  for n = 1:numcols
                     vals = s.(allcols{n});
                     [r,c] = size(vals);
                     if isnumeric(vals)
                        if exist('isfloat','builtin') == 5 && isfloat(vals)
                            dtype = 'floating-point array';
                        elseif exist('isinteger','builtin') == 5 && isinteger(vals)
                            dtype = 'integer array';
                        else
                            dtype = 'numeric array';
                        end
                     elseif ischar(vals)
                        dtype = 'character array';
                     elseif iscell(vals)
                        dtype = 'cell array';
                     else
                        dtype = 'other array';
                     end
                     str{n} = [allcols{n},'  (',int2str(r),'x',int2str(c),' ',dtype,')'];
                  end
               end
               
               %open list dialog for column selection
               Isel = listdialog('liststring',str, ...
                  'name','Select Fields', ...
                  'promptstring','Select fields to import', ...
                  'selectionmode','multiple', ...
                  'listsize',[0 0 350 400]);
            
               %apply selection index to column list
               if ~isempty(Isel)
                  colnames = allcols(Isel);
               end
               
            end
            
         end
         
         %check for fields to import
         if ~isempty(colnames)
            
            %init output data structure
            s2 = newstruct('data');
            
            %loop through fields importing data
            for n = 1:length(colnames)
               
               %init bad column flag
               Ibad = [];
               
               try
                  
                  %extract field values based on cardinality
                  if length(s) > 1
                     ar = {s.(colnames{n})};  %extract structure values as cell array
                  else
                     ar = s.(colnames{n});
                  end
                  
                  %force column orientation
                  ar = ar(:);
                  
                  %check for cell array - validate data types
                  if iscell(ar)
                     Inull = cellfun('isempty',ar);  %get index of empty cells
                     Istr = cellfun('isclass',ar,'char');  %get index of character array cells
                     Inum = ~Istr;  %get index of numeric cells by inverting Istr
                     len = cellfun('length',ar);  %get lengths of arrays
                     Ibad = find((~Istr & ~Inum) | (Inum & len > 1));  %check for unsupported values (non-string and non-numeric) or array lengths
                  end
                  
               catch
                  Ibad = 1;
               end
               
               if isempty(Ibad)
                  
                  try
                     
                     %determine column data type and fill in empty cells with empty string or NaN
                     if iscell(ar)
                        if ~isempty(find(Istr))  %check for any string cells - force column to all string
                           ar(Inull) = {''};  %replace empty array cells with an empty string
                           if ~isempty(find(Inum))  %convert numeric values to string
                              nums = [ar{Inum}]';
                              str = cellstr(num2str(nums));
                              ar(Inum) = trimstr(str);
                           end
                           s2_tmp = addcol(s2,ar,colnames{n},'unspecified','','s','nominal');
                        else
                           ar(Inull) = {NaN};  %replace empty cells with NaN
                           ar = [ar{:}]';  %convert to numeric array
                           ar = double(ar);  %force logical or typed numeric arrays (e.g. uint8, uint16) to double
                           s2_tmp = addcol(s2,ar,colnames{n},'unspecified','','f','data');
                        end
                     else
                        s2_tmp = addcol(s2,ar,colnames{n},'unspecified','','f','data');
                     end
                     
                  catch
                     s2_tmp = [];
                  end
                  
                  %copy temp structure to output if successfully added column, otherwise add to badfields list
                  if ~isempty(s2_tmp)
                     s2 = s2_tmp;
                  else
                     badfields = [badfields ; {colnames{n}}];
                  end
                  
               else
                  badfields = [badfields,{colnames{n}}];
               end
               
            end
            
            %check for successful conversion
            if length(badfields) < length(colnames)
               
               %generate error message if necessary
               if ~isempty(badfields)
                  msg = ['failed to convert field(s) ',cell2commas(badfields,1),' to GCE Data Structure columns'];
               end
               
               %apply template if specified, or evaluate numerical values and assign precisions automatically
               if ~isempty(template)
                  [s2,msg0] = apply_template(s2,template);
                  if ~isempty(msg0)
                     if isempty(msg)
                        msg = msg0;
                     else
                        msg = [msg,'; ',msg0];
                     end
                  end
               else
                  s2 = assign_numtype(s2);
               end
               
            else
               s2 = [];
               msg = 'failed to convert any fields to GCE Data Structure columns';
            end
            
         else
            s2 = [];
            msg = 'no valid structure fields were specified';
         end
         
      end
      
   else
      if strcmp(source,'workspace')
         msg = 'no variable selected - import cancelled';
      else
         msg = 'invalid structure';
      end
   end
   
else
   msg = 'invalid input - structure of ''workspace'' argument required';
end
