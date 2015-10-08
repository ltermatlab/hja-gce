function [s2,msg] = codes2criteria(s,cols,flagcode)
%Generates QA/QC criteria for coded columns in a GCE Data Structure based on code definitions
%in the metadata
%
%syntax: [s2,msg] = codes2criteria(s,cols,flagcode)
%
%input:
%  s = data structure to update
%  cols = array of column names or index numbers to generate criteria for
%    (default = all columns with variabletype = 'code')
%  flagcode = flag code to assign for values not in the list (default = 'I')
%
%output:
%  s2 = updated structure
%  msg = text of any error message
%
%(c)2010-2011 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 07-Sep-2011

s2 = [];
msg = '';

if nargin >= 1 && gce_valid(s,'data') == 1

   s2 = s;  %init output

   %set default flag code if not specified
   if exist('flagcode','var') ~= 1
      flagcode = 'I';
   end

   %get index of all string code cols
   code_cols = find(strcmp(get_type(s,'variabletype'),'code'));

   %validate cols input
   if exist('cols','var') ~= 1
      cols = [];
   elseif ~isnumeric(cols)
      cols = name2col(s,cols);
   end

   %use default cols if empty, otherwise limit to columns with variabletype = code
   if isempty(cols)
      cols = code_cols;
   else
      cols = intersect(code_cols,cols);  %remove non-code columns from cols array
   end

   if ~isempty(cols)

      %get codes from metadata
      codemeta = lookupmeta(s,'Data','ValueCodes');

      %parse codes if column name leaders are present
      if ~isempty(strfind(codemeta,':'))

         %parse multiple code definitions based on pipe separators
         codelist = splitstr(codemeta,'|');

         %init status index
         badcol = zeros(length(cols),1);

         %loop through columns
         for n = 1:length(cols)

            pos = cols(n);  %get column index
            str = [s.name{pos},':'];
            Imatch = find(strncmp(str,codelist,length(str))); %get index of codes for column

            if ~isempty(Imatch)
               Imatch = Imatch(end);  %only use last match if multiples
               ar = splitstr(codelist{Imatch},':');  %parse out column name from cole list
               if length(ar) == 2
                  dtype = s.datatype{pos};  %get column datatype
                  codes = splitcodes(ar{2}); %parse codes
                  if strcmp(dtype,'s')
                     fnc = 'flag_notinlist(x,''';
                     fnc2 = ''')=''';
                  else
                     fnc = 'flag_notinarray(x,[';
                     fnc2 = '])=''';
                  end
                  codecrit = [fnc,strrep(cell2commas(codes,0),', ',','),fnc2,flagcode,''''];
                  crit = subfun_addcriteria(s.criteria{pos},codecrit);
                  s2.criteria{pos} = crit;
               else
                  badcol(n) = 1;
               end
            else
               badcol(n) = 1;
            end

         end

         Ibadcol = find(badcol == 1);
         Igoodcol = find(badcol == 0);

         if ~isempty(Igoodcol)

            %add history entry and update edit date
            s2.history = [s2.history ; {datestr(now)}, ...
               {['added or updated Q/C criteria for checking coded values against the code list in the metadata for column(s) ', ...
                  cell2commas(s.name(cols(Igoodcol)),1),' (''codes2criteria'')']}];
            s2.editdate = datestr(now);

            %update flags for edited columns
            s2 = dataflag(s2,cols(Igoodcol));

            %generate warning message
            if ~isempty(Ibadcol)
               msg = ['failed to create Q/C criteria for column(s): ',cell2commas(s.name(cols(Ibadcol)),1)];
            end

         else
            msg = 'no codes were identified in the metadata for the specified column(s)';
         end

      else
         msg = 'unsupported code list format in dataset metadata';
      end

   else
      msg = 'column selections were invalid or no coded columns were found';
   end

else
   if nargin == 0
      msg = 'insufficient arguments for function';
   else
      msg = 'invalid data structure';
   end
end
return


function crit2 = subfun_addcriteria(crit,newcrit)
%adds a Q/C criteria rule to column criteria, replacing existing rules of the same type

if isempty(crit)
   crit2 = newcrit;
else
   ar = splitstr(crit,';');
   fcn = strtok(newcrit,'(');
   Idupe = find(strncmpi(ar,fcn,length(fcn)));
   if isempty(Idupe)
      crit2 = [crit,';',newcrit];
   else
      ar(Idupe) = {newcrit};
      crit2 = char(concatcellcols(ar(:)',';'));
   end
end