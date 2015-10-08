function [msg,unmapped] = add_unit_mappings(units1,units2)
%Adds units to the GCE Data Toolbox unit conversion database by mapping to existing units
%
%syntax: [msg,unmapped] = add_unit_mappings(units1,units2)
%
%inputs:
%  units1 = cell array of units to add to the conversions database
%  units2 = cell array of units to match for each entry of units1
%
%outputs:
%  msg = status message
%  unmapped = cell array containing unmapped units from units1
%
%
%(c)2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 19-Jun-2013

unmapped = [];

%validate input
if nargin == 2 && iscell(units1) && iscell(units2) && length(units1)==length(units2)
   
   %get location of conversions database
   fn = which('ui_unitconv.mat');
   
   if ~isempty(fn)
      
      try
         v = load(fn);
      catch e
         v = struct('null','');
      end
      
      %check for valid unit conversions variable
      if isfield(v,'conversions') && isstruct(v.conversions)
         
         %get conversions struct
         conversions = v.conversions;
         unitcomp1 = {conversions.units1}';
         unitcomp2 = {conversions.units2}';
         
         %init new record pointer
         ptr = length(conversions)+1;
         
         %init match index
         matched = zeros(length(units1),1);
         
         %loop through new units, matching to existing units
         for n = 1:length(units1)
            
            %get match index to units1
            Imatch1 = find(strcmp(units2{n},unitcomp1) & ~strcmp(units1{n},unitcomp1));
            
            %check for any matches
            if ~isempty(Imatch1)
               
               %set matched flag
               matched(n) = 1;
               
               %loop through all conversions for matched unit, adding entries for new unit
               for m = 1:length(Imatch1)
                  conversions(ptr) = conversions(Imatch1(m));  %copy matched conversion to new structure dimension
                  conversions(ptr).units1 = units1{n};  %update units1 to new unit
                  ptr = ptr + 1; %increment pointer
               end
               
               %add reciprocal 1:1 match
               conversions(ptr).units1 = units1{n};
               conversions(ptr).units2 = units2{n};
               conversions(ptr).multiplier = 1;
               conversions(ptr).formatstring = '%0d';
               conversions(ptr).equation = '';
               ptr = ptr + 1;
               
            end  
            
            %get match index to units2
            Imatch2 = find(strcmp(units2{n},unitcomp2) & ~strcmp(units1{n},unitcomp2));
            
            %check for any matches
            if ~isempty(Imatch2)
               
               %set matched flag
               matched(n) = 1;
               
               %loop through all conversions for matched unit, adding entries for new unit
               for m = 1:length(Imatch2)
                  conversions(ptr) = conversions(Imatch2(m));  %copy matched conversion to new structure dimension
                  conversions(ptr).units2 = units1{n};  %update units2 to new unit
                  ptr = ptr + 1; %increment pointer
               end
               
               %add reciprocal 1:1 reverse match
               conversions(ptr).units1 = units2{n};
               conversions(ptr).units2 = units1{n};
               conversions(ptr).multiplier = 1;
               conversions(ptr).formatstring = '%0d';
               conversions(ptr).equation = '';
               ptr = ptr + 1;
               
            end  
            
         end
         
         %check for any matches
         if sum(matched) > 0
           
            %sort conversions by units1, units2
            [tmp,I2] = sort(lower({conversions.units2}));                                %#ok<ASGLU>
            [tmp,I1] = sort(lower({conversions(I2).units1}));                            %#ok<ASGLU>
            conversions = conversions(I2(I1));                                           %#ok<NASGU>
                     
            %generate list of unmapped units
            unmapped = units1(~matched);
            
            %save conversions
            save(fn,'conversions','-append')

            msg = ['matched ',int2str(sum(matched)),' of ',int2str(length(matched)), ...
               ' units and updated the conversions database (',fn,')'];
            
         else
            unmapped = units1;
            msg = 'no units were matched - database not updated';
         end
         
      else  %bad database
         
         if isobject(e)
            msg = ['an error occurred loading the unit conversions database (',e.message,')'];
         else
            msg = 'the unit conversion database is invalid';
         end
         
      end
      
   else
      msg = 'the unit conversions database ''ui_unitconv.mat'' is not present in the MATLAB path';
   end
   
else
   msg = 'invalid input - matching cell arrays required';
end