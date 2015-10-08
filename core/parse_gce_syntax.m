function [syntax,fnc_desc,fnc_help,parms,modified] = parse_gce_syntax(fnc)
%Parses syntax and parameter information from GCE Data Toolbox function help text
%
%syntax: [syntax,fnc_desc,fnc_help,parms,modified] = parse_gce_syntax(fnc)
%
%inputs:
%  fnc = function name
%
%outputs:
%  syntax = syntax string
%  fnc_desc = one line function description
%  fnc_help = function help text string
%  parms = structure listing input and output parameters with fields:
%    'type' = parameter type ('input','output')
%    'name' = parameter name
%  modified = date last modified
%
%(c)2008-2011 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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

%init output
syntax = '';
fnc_desc = '';
fnc_help = '';
parms = [];
modified = '';

%check for missing input
if nargin == 1

   %get help text for function
   try
      fnc_help = help(fnc);
   catch
      fnc_help = '';
   end

   %init parsed help array
   ar_help = [];

   if ~isempty(fnc_help)

      %split help text by newlines, trimming leading/trailing blanks
      ar_help = splitstr(fnc_help,char(10),0,1);

      %grab first line as function description
      fnc_desc = ar_help{1};

      %get index of syntax line
      Isyn = find(strncmp('syntax:',ar_help,7));

      if ~isempty(Isyn)

         %parse syntax string
         syntax = trimstr(ar_help{Isyn(1)}(9:end));

         %parse output parameters
         str_out = strtok(syntax,'=');
         out_parms = [];
         if ~isempty(str_out)
            out_parms = splitstr(strrep(strrep(str_out,'[',''),']',''),',',1,1);
            parms = cell2struct([repmat({'output'},length(out_parms),1),out_parms,repmat({''},length(out_parms),1)],{'type','name','description'},2);
         end

         %parse input parameters
         [tmp,rem] = strtok(syntax,'(');
         in_parms = splitstr(rem(2:end-1),',',1,1);
         parms = [parms ; cell2struct([repmat({'input'},length(in_parms),1),in_parms,repmat({''},length(in_parms),1)],{'type','name','description'},2)];

         %try to parse descriptions
         for n = 1:length(parms)
            teststr = parms(n).name;
            tkn = [teststr,' = '];
            Itest = find(strncmp(tkn,ar_help,length(tkn)));
            if ~isempty(Itest)
               rowptr = max(Itest);
               desc = ar_help{rowptr}(length(tkn)+1:end);  %get description, removing leading label
               for m = rowptr+1:length(ar_help)  %add additional help text rows
                  str = ar_help{m};
                  if ~isempty(str) && isempty(strfind(str,' = '))  %check for spacer rows, other parameter def lines
                     desc = [desc,' ',str];
                  else
                     break
                  end
               end
               parms(n).description = desc;  %add description to parm structure
            end
         end

      end

   end

   Imod = find(strncmp('last modified',ar_help,13));

   if ~isempty(Imod)
      str = ar_help{Imod(end)};
      if isempty(strfind(str,':'))
         str = strrep(str,'modified','modified:');
      end
      [tmp,rem] = strtok(str,':');
      if ~isempty(rem)
         modified = trimstr(rem(2:end));
      end
   end


end