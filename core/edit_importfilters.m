function edit_importfilters(op,data)
%Opens the list of GCE Data Toolbox import filter definitions stored in 'imp_filters.mat' into a grid for editing
%
%syntax: edit_importfilters(op,data)
%
%inputs:
%  op = operation ('init' to initialize dialog)
%  data = data structure (default = data in 'imp_filters.mat')
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
%last modified: 03-Jun-2013

if nargin == 0
   op = 'init';
end

switch op

case 'init'  %generate grid data for editing filters
   
   %load import filters database (using defaults if file not present)
   data = get_filters;
   
   %create blank structure to populate if imp_filters.mat missing or invalid
   if isempty(data)
      data = newstruct;
      data.title = 'GCE Data Toolbox External Import Filters';
      data.datafile = [{'none'},{0}];
      data.name = {'Label','Filemask','Fileprompt','Mfile','Argument1','Argument2','Argument3','Argument4','Argument5','Argument6'};
      data.units = {'none','none','none','none','none','none','none','none','none','none'};
      data.description = {'Menu label to display', ...
            'Filemask to use to identify candidate files for import', ...
            'Prompt to display when selecting files', ...
            'Function mfile to use for importing data (must accept filename and pathname and return a data structure and message string), e.g. [data,msg]=myfilter(filename,pathname)', ...
            'Optional argument to pass after filename and pathname, e.g. [data,msg]=myfilter(filename,pathname,argument1)', ...
            'Optional argument to pass after filename and pathname, e.g. [data,msg]=myfilter(filename,pathname,argument1,argument2)', ...
            'Optional argument to pass after filename and pathname, e.g. [data,msg]=myfilter(filename,pathname,argument1,argument2,argument3)', ...
            'Optional argument to pass after filename and pathname, e.g. [data,msg]=myfilter(filename,pathname,argument1,argument2,argument3,argument4)', ...
            'Optional argument to pass after filename and pathname, e.g. [data,msg]=myfilter(filename,pathname,argument1,argument2,argument3,argument4,argument5)', ...
            'Optional argument to pass after filename and pathname, e.g. [data,msg]=myfilter(filename,pathname,argument1,argument2,argument3,argument4,argument5,argument6)'};
      data.datatype = repmat({'s'},1,length(data.name));
      data.variabletype = repmat({'nominal'},1,length(data.name));
      data.numbertype = repmat({'none'},1,length(data.name));
      data.precision = zeros(1,length(data.name));
      data.values = [{{'mylabel'},{'*.*'},{'Select a file to import'},{'myfunc'}},repmat({{''}},1,length(data.name)-4)];
      data.criteria = repmat({''},1,length(data.name));
      data.flags = repmat({''},1,length(data.name));
   end

   %open structure in data grid with wide columns
   ui_datagrid('init',data,[],'edit_importfilters(''eval'',s)',180,'left');

case 'eval'  %process edits

   if exist('data','var') == 1

      if gce_valid(data,'data') == 1

         data = sortdata(data,{'Label','Subheading'},[1 1],0);

         %get import filters data
         fh = which('imp_filters.mat');
         if isempty(fh)
            pn = [gce_homepath,filesep,'userdata'];
            if ~isdir(pn)
               pn = fileparts(which('edit_importfilters'));
            end
            fh = [pn,filesep,'imp_filters.mat'];
         end

         save(fh,'data');
         h_edit = findobj('tag','dlgDSEditor');

         if ~isempty(h_edit)

            %loop through all editor instances
            for cnt = 1:length(h_edit)

               %delete prior filters from menus
               h_mnuImport = findobj(h_edit(cnt),'tag','mnuImport');
               h_child = get(h_mnuImport,'Children');
               if ~isempty(h_child)
                  for m = 1:length(h_child)
                     tag = get(h_child(m),'tag');
                     if ~strcmp(tag,'mnuImpAscii') && ~strcmp(tag,'mnuImpMatlab') && ~strncmp(tag,'mnuHarvest',10)
                        delete(h_child(m));
                     end
                  end
               end

               %get new list of labels, subheadings
               lbl = extract(data,'Label');
               subheads = extract(data,'Subheading');

               if ~isempty(lbl)
                  
                  %sort groups alphabetically ignoring case
                  gps = unique(lbl);
                  [tmp,Isort] = sort(lower(gps));  %get sort index
                  gps = gps(Isort); 
                  
                  %init loop variable for tracking top row
                  toprow = 0;
                  
                  %loop through groups generating menu items
                  for n = 1:length(gps)
                     
                     %determine separator setting
                     if toprow == 0
                        toprow = 1;
                        sep = 'on';
                     else
                        sep = 'off';
                     end
                     
                     Imatch = find(strcmp(lbl,gps{n}));  %get index of items of current group
                     
                     if length(Imatch) > 1
                        
                        %generate top menu
                        h = uimenu('Parent',h_mnuImport, ...
                           'Label',gps{n}, ...
                           'Separator',sep);
                        
                        %generate submenus
                        for m = 1:length(Imatch)
                           uimenu('Parent',h, ...
                              'Label',subheads{Imatch(m)}, ...
                              'Callback',['ui_editor(''imp_filter'',''',lbl{Imatch(m)},'_',subheads{Imatch(m)},''')']);
                        end
                        
                     elseif length(Imatch) == 1
                        
                        %generate single-tier menus
                        subhead = subheads{Imatch};
                        
                        if ~isempty(subhead)
                           h = uimenu('Parent',h_mnuImport, ...
                              'Label',lbl{Imatch}, ...
                              'Separator',sep);
                           uimenu('Parent',h, ...
                              'Label',subhead, ...
                              'Callback',['ui_editor(''imp_filter'',''',lbl{Imatch},'_',subhead,''')']);
                        else
                           uimenu('Parent',h_mnuImport, ...
                              'Label',lbl{Imatch}, ...
                              'Callback',['ui_editor(''imp_filter'',''',lbl{Imatch},''')'], ...
                              'Separator',sep);
                        end
                        
                     end
                     
                  end
                  
               end
               
            end
            
         end
         
      end
      
   end
   
end