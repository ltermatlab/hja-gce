function flagdefs = get_flagdefs(s,flags,sep)
%Retrieves definitions for selected QA/QC flags from GCE Data Structure metadata
%(called by nullflags.m, cullflags.m and clearflags.m)
%
%syntax:  flagdefs = get_flagdefs(s,flags,sep)
%
%input:
%  s = data structure to query (struct; required)
%  flags = flags to match (string; required; e.g. 'IQE')
%  sep = terminal string separator for comma-delimited list if more than one flag is specified (integer; optional)
%    0 = none
%    1 = and
%    2 = or (default)
%
%output:
%  flagdefs = comma-delimited string containing flags and definitions
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
%last modified: 14-Jan-2015

flagdefs = '';

if nargin >= 2
   
   %set default for sep if omitted
   if exist('sep','var') ~= 1
      sep = 2;
   end
   
   %init array of flag codes
   flagcodes = [];
   
   %get flag definitions from metadata
   flaglist = lookupmeta(s,'Data','Codes');
   
   %parse flag definitions and perform lookups
   if ~isempty(flaglist)
      
      %strip out legacy code leaders
      flaglist = strrep(flaglist,'Flags: ','');
      if ~isempty(strfind(flaglist,'|'))
         flagdefs = splitstr(flaglist,'|');
      elseif ~isempty(strfind(flaglist,','))
         flagdefs = splitstr(flaglist,',');
      else
         flagdefs = cellstr(flaglist);
      end
      
      %generate definition strings
      if ~cellfun('isempty',flagdefs)
         allflagcodes = [];
         for n = 1:length(flagdefs)
            tmp = splitstr(flagdefs{n},'=');
            if length(tmp) == 2
               allflagcodes = [allflagcodes ; tmp(1),{[tmp{1},' (',tmp{2},')']}];
            end
         end
         for n = 1:length(flags)
            I = find(strcmp(allflagcodes(:,1),flags(n)));
            if ~isempty(I)
               flagcodes = [flagcodes,allflagcodes(I(1),2)];
            else
               flagcodes = [flagcodes,{[flags(n),' (unspecified)']}];
            end
         end
      end
      
   end
   
   %no definitions parsed - list all as unspecified
   if isempty(flagcodes)
      for n = 1:length(flags)
         flagcodes = [flagcodes ; {[flags(n),' (unspecified)']}];
      end
   end
   
   flagdefs = cell2commas(flagcodes,sep);
   
end
