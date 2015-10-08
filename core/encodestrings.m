function [s2,msg] = encodestrings(s,reconcile)
%Encodes text columns in a GCE data structure as series of unique integers
%and documents the code values in the Data_ValueCodes section of the metadata
%
%syntax: [s2,msg] = encodestrings(s,reconcile)
%
%inputs:
%  s = data structure to update
%  reconcile = option to reconcile codes with prior code entries in the metadata (default = 1)
%     0 = no (new codes will be added, prior codes will be retained)
%     1 = yes (prior code lists will be modified to reflect new codes)
%
%outputs:
%  s2 = modified data structure
%  msg = text of any error messages
%
%
%(c)2002-2006 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 10-Nov-2005

s2 = [];
msg = '';

if nargin >= 1
   
   if gce_valid(s,'data') == 1
      
      if exist('reconcile','var') ~= 1
         reconcile = 1;
      end

      Istr = find(strcmp(s.datatype,'s'));

      if ~isempty(Istr)

         codes = [];
         metastr = lookupmeta(s,'Data','ValueCodes');
         if ~isempty(metastr)
            codes = splitstr(metastr,'|');
         end

         for n = 1:length(Istr)  %loop through string columns

            col = Istr(n);
            lbl = [s.name{col},': '];
            codestr = lbl;
            str = s.values{col};
            tkns = unique(str);
            vals = zeros(length(str),1);

            for m = 1:length(tkns)  %replace each unique string with a serial integer
               Ival = find(strcmp(str,tkns{m}));  %get index of values
               vals(Ival) = m;  %replace values
               codestr = [codestr,int2str(m),' = ',tkns{m},', ']; %build value code string for metadata
            end

            codestr = codestr(1:length(codestr)-2);  %trim trailing comma, space
            
            if reconcile == 1
               codes = sub_updatecodes(codes,codestr);  %reconcile new codes with old code list for parameter
            else
               codes = [codes ; {codestr}];
            end

            %update data descriptors for integers
            s.datatype{col} = 'd';
            s.variabletype{col} = 'code';
            if length(s.units{col}) > 1 & ~strcmp(lower(s.units{col}),'none')
               s.units{col} = 'none';  %update units if not null, "none"
            end
            s.numbertype{col} = 'discrete';
            s.description{col} = [s.description{col},' (encoded as unique integers)'];
            s.precision(col) = 0;
            if ~isempty(s.flags{col})  %check for flags
               flags = s.flags{col};
               if length(find(flags(:,1) ~= ' ')) > 0  %check for non-empty flag array
                  s.criteria{col} = 'manual';  %lock flags if not already locked
               else
                  s.criteria{col} = '';  %clear criteria
                  s.flags{col} = '';  %clear flags
               end
            else
               s.criteria{col} = '';  %clear criteria
               s.flags{col} = '';  %clear flags
            end
            s.values{col} = vals;  %update values

         end

         if length(codes) > 1
            codes = concatcellcols(codes','|');
         end
         newmeta = [{'Data'},{'ValueCodes'},{['|',char(codes)]}];

         s2 = addmeta(s,newmeta,1);  %perform silent metadata update

         if reconcile == 1
            reconcile_string = 'and updated existing code entries in the metadata';
         else
            reconcile_string = 'and documented the code entries in the metadata';
         end
         
         if length(Istr) == 1
            colstr = ['encoded string values in column ',s2.name{Istr},' as unique integers ',reconcile_string,' (''exp_matlab'')'];
         elseif length(Istr) > 1
            colstr = ['encoded string values in columns ',cell2commas(s2.name(Istr)),' as unique integers ',reconcile_string,' (''exp_matlab'')'];
         end

         s2.history = [s2.history ; {datestr(now)},{colstr}];

      else

         s2 = s;  %assign original structure as output
         msg = 'no string columns wer present in the data structure';

      end

   else

      msg = 'invalid data structure';

   end

else

   msg = 'insufficient arguments for function';

end


function codes2 = sub_updatecodes(codes,codestr)
%subfunction for reconciling codes

codes2 = [];

if isempty(codes)
   
   codes2 = {codestr};  %no prior codes - just append new entry
   
else
   
   try
      
      lbl = [strtok(codestr,':'),': '];  %parse parameter name from codestr
      
      Imatch = find(strncmp(codes,lbl,length(lbl)));  %look for prior entry for parameter name
      
      if isempty(Imatch)
         codes2 = [codes ; {codestr}];  %no prior codes for parameter name - just append new entry
      else  %reconcile last code defs
         codes2 = codes;
         Imatch = Imatch(end);
         ar_old = splitstr(codes{Imatch},':');
         ar_new = splitstr(codestr,':');
         if length(ar_old) == 2 & length(ar_new) == 2
            [codes_old,values_old] = splitcodes(ar_old{2});
            [codes_new,values_new] = splitcodes(ar_new{2});
            for n = 1:length(values_new)
               Imatch2 = find(strcmp(codes_old,values_new{n}));
               if length(Imatch2) == 1
                  values_new{n} = values_old{Imatch2};  %swap original value for new encoded value
               end
            end
            str = [lbl,cell2commas(concatcellcols([codes_new,values_new],' = '))];  %put code list in delimited string format
            codes2{Imatch} = str;  %update original code list
         else
            codes2 = [codes ; {codestr}];  %unsupported code format - just append new entry
         end
      end
      
   catch
      
      codes2 = [codes ; {codestr}];  %processing error - just append new entry
      
   end
   
end
