function msg = exp_header(s,fn,pn,dataopt,flagopt,delim)
%Generates an ASCII import file header from a GCE Data Structure
%
%syntax: msg = exp_header(s,fn,pn,dataopt,flagopt,delim)
%
%input:
%  s = GCE Data Structure to export (struct; required)
%  fn = file name for export (string; optional; prompted if omitted)
%  pn = path for export (string; optional; pwd if omitted)
%  dataopt = option to include data values after header (integer; optional)
%     0 = no (default)
%     1 = yes
%  flagopt = option to instantiate flags as text columns prior to generating headers
%     0 = no (default)
%     1 = instantiate all flags as columns
%     2 = instantiate only manual/locked flags as columns
%  delim = field delimiter for data if dataopt = 1 (string; optional)
%     'tab' = tab delimiter (default)
%     'comma' = comma delimiter
%     'space' = single space delimiter
%
%output:
%  msg = statust or error message
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
%last modified: 19-Nov-2014

msg = '';

if nargin >= 1 && ~isempty(s) && gce_valid(s,'data')
   
   %validate dataopt, use default if omitted
   if exist('dataopt','var') ~= 1 || isempty(dataopt)
      dataopt = 0;
   elseif dataopt ~= 1
      dataopt = 0;
   end
   
   %validate flagopt, use default if omitted
   if exist('flagopt','var') ~= 1 || isempty(flagopt)
      flagopt = 0;
   elseif flagopt ~= 1 && flagopt ~= 2
      flagopt = 0;
   end
   
   %validate delim, use default if omitted
   if exist('delim','var') ~= 1
      delim = '';
   end
   if ~inlist(delim,{'tab','comma','space'},'insensitive')
      delim = 'tab';
   end
   
   %validate path
   if exist('pn','var') ~= 1 || isempty(pn) || ~isdir(pn)
      pn = pwd;
   else
      pn = clean_path(pn);
   end
   
   %validate file, prompt if omitted
   if exist('fn','var') ~= 1 || isempty(fn)
      curpath = pwd;
      cd(pn)
      [fn,pn] = uiputfile('*.txt','Generate text import header file');
      drawnow
      cd(curpath)
      if ~ischar(fn)
         fn = '';
         pn = '';
      end
   end
   
   %check for aborted export
   if ~isempty(fn)
      
      %check for instantiating flags
      if flagopt == 1  %all flags
         s = flags2cols(s,'all');
      elseif flagopt == 2  %only locked flags
         allcrit = s.criteria;  %get all criteria as an array
         Imanualcrit = zeros(1,length(allcrit));  %init index of manual flags
         for n = 1:length(allcrit)
            if strfind(allcrit{n},'manual')
               Imanualcrit(n) = 1;  %set manual flag
            end
         end
         if sum(Imanualcrit) > 0
            %instantiate only manually-flagged columns
            s = flags2cols(s,find(Imanualcrit==1));
         end
      end
      
      %check for flag instantiating errors
      if ~isempty(s)
         
         %get doc metadata
         meta = s.metadata;
         
         %get attribute metadata as delimited strings
         attribs = cell(8,1);
         attribs{1} = ['Name: ',char(concatcellcols(fillmissing(s.name,'~'),char(9)))];
         attribs{2} = ['Description: ',char(concatcellcols(fillmissing(s.description,'~'),char(9)))];
         attribs{3} = ['Units: ',char(concatcellcols(fillmissing(s.units,'~'),char(9)))];
         attribs{4} = ['Datatype: ',char(concatcellcols(fillmissing(s.datatype,'~'),char(9)))];
         attribs{5} = ['Variabletype: ',char(concatcellcols(fillmissing(s.variabletype,'~'),char(9)))];
         attribs{6} = ['Numbertype: ',char(concatcellcols(fillmissing(s.numbertype,'~'),char(9)))];
         attribs{7} = ['Precision: ',char(concatcellcols(cellstr(int2str(s.precision'))',char(9)))];
         attribs{8} = ['Criteria: ',char(concatcellcols(fillmissing(s.criteria,'~'),char(9)))];
         
         try
            fid = fopen([pn,filesep,fn],'w');
         catch
            fid = [];
         end
         
         if ~isempty(fid)
            
            %clean up and write doc metadata
            for n = 1:size(meta,1)
               catname = deblank(meta{n,1});
               fldname = deblank(meta{n,2});
               str = clean_str(meta{n,3});
               fprintf(fid,'%s_%s: %s\r\n',catname,fldname,str);
            end
            
            %write attributes
            for n = 1:length(attribs)
               fprintf(fid,'%s\r\n',attribs{n});
            end
            
            %close file
            fclose(fid);
            
            %check for data write option, call exp_ascii with append option
            if dataopt == 1
               msg2 = exp_ascii(s,delim,fn,pn,'','N','N','','','no','NaN','','N','T');
            else
               msg2 = '';
            end
            
            %generate message
            if dataopt == 0
               msg = 'Successfully generated text import header file';
            else
               if isempty(msg2)
                  msg2 = 'successfully appended data values';
               end
               msg = ['Successfully generated text import header file; ',msg2];
            end
            
         else
            msg = ['Error occurred opening ',pn,filesep,fn,' for writing'];
         end
         
      else
         msg = 'An error occurred instantiating flags as columns';
      end
      
   end
   
else
   msg = 'Valid data structure required';
end

return


function ar2 = fillmissing(ar,missingchar)
%Fills in empty cells in a cell array of strings with a designated missing value character
%
%syntax: ar2 = fillmissing(ar,missingchar)
%
%intput:
%  ar = cell array to fill
%  missingchar = string to substitute for empty cells
%
%output:
%  ar2 = filled cell array

ar2 = [];

if iscell(ar) && ischar(missingchar)
   
   %init output
   ar2 = ar;
   
   %perform substitution for empty cells
   ar2(cellfun('isempty',ar2)) = {missingchar};
   
end

return