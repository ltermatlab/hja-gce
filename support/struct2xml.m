function xmlstr = struct2xml(s,outertag,emptyfld,wrap,indent,lmarg)
%Generates an xml fragment from a uni- or multi-dimensional structure 
%using field names for elements and nesting based on sub-structure hierarchy
%
%syntax: xmlstr = struct2xml(s,outertag,emptyfields,wrapcolumn,indent,leftmargin)
%
%input:
%  s = structure containing nested sub-structure fields or data fields composed of
%     character arrays, scalar numbers, or 1-2 dimensional numeric arrays
%  outertag = outer tag to use for wrapping each primary structure dimension (default = '')
%  emptyfields = option to include empty fields (0 = no/default, 1 = yes)
%  wrapcolumn = word wrap column for long strings (default = 80, 0 for no wrapping)
%  indent = number of characters to indent when nesting tags (default = 3)
%  leftmargin = number of characters to prepend to each line (default = 0)
%
%output:
%  xmlstr = padded character array containing xml fragment
%     (note: does NOT include xml declaration and namespace arguments)
%
%notes:
%  1. the outer structure will be converted to column-major orientation using s(:)', 
%     so re-order dimensions before calling struct2xml if this is not desired
%  2. if sub-structures are in column-major orientation (1xn), fields in each dimension
%     will be nested inside separate elements named according to the sub-structure field, 
%     otherwise all contents will be serialized and nested inside one element
%
%(c)2002-2011 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 25-Mar-2011

xmlstr = [];
err = 0;

if nargin >= 1
   
   if isstruct(s)
      
      s = s(:)';  %convert multidimensional structures to row-major orientation
      
      %get field names for current structure dimension
      fn = fieldnames(s);
      num = length(fn);
      
      %validate input, supply defaults
      if exist('lmarg','var') ~= 1  %apply default left margin if omitted
         lmarg = 0;
      end
      
      if exist('indent','var') ~= 1  %apply default indent if omitted
         indent = 3;
      end
      
      if exist('wrap','var') ~= 1  %apply default wrap if omitted
         wrap = 80;
      elseif wrap > 0 && wrap < 30
         wrap = 30;  %set minimum wrap to prevent margin offset errors with long strings
      end
      
      if exist('emptyfld','var') ~= 1
         emptyfld = 0;
      end
      
      %evalulate outer tag input
      if exist('outertag','var') ~= 1  %handle outertag tag permutations
         outertag = '';  %default to empty string
      elseif isempty(outertag)
         outertag = '';  %force empty string if omitted
      elseif iscell(outertag)
         if length(outertag) == 1
            outertag = repmat(outertag,length(s),1);  %replicate single outertag array
         elseif length(outertag) ~= length(s)
            err = 1;  %invalid number of outertag elements - abort
         end
      elseif ischar(outertag)  %replicate single string
         outertag = repmat(cellstr(outertag),length(s),1);
      elseif isnumeric(outertag)  %pull outertag tags from an indexed field, delete field
         fld = fn{fix(outertag(1))};  %look up field name using index
         outertag = {s.(fld)};  %get field name values as cell array
         s = rmfield(s,fld);  %remove field
         fn = fieldnames(s);  %refresh field names
         num = length(fn);  %refresh field count
      end
      
      %process structure fields
      if err == 0
         
         pad = '';  %init padding string
         
         for n = 1:size(s,2)  %loop through struct dimensions
         
            tempstr = [];
            
            for m = 1:num  %loop through struct elements
            
               f = fn{m};  %look up field name
               v = getfield(s,{n},f);  %get field contents
               
               if isstruct(v) %structure field - recurse
                  
                  %check for substructure orientation
                  if size(v,2) > 1  %column-major, wrap contents in field name tags                     
                     tempstr = [tempstr ; {struct2xml(v',f,emptyfld,wrap,indent)}];
                  else  %row-major, serialize contents without field name tags
                     str = struct2xml(v,'',emptyfld,wrap,indent,indent);  %recurse substructure
                     if m > 1
                        tempstr = [tempstr ; {['<',f,'>']} ; {str}; {['</',f,'>']}];  %prepend previous elements
                     else
                        tempstr = [{['<',f,'>']} ; {str}; {['</',f,'>']}];
                     end
                  end
                  
               else  %data field
                  
                  %check type
                  if ischar(v)
                     str = v;
                  elseif isnumeric(v)
                     str = num2str(v);
                  else
                     str = '';  %empty string or unsupported field type
                  end
                  
                  %process string
                  if ~isempty(str)
                     
                     if wrap > 0
                        if size(str,2) > wrap  %word wrap if necessary
                           str = wordwrap(str,wrap,0,'char');
                        end
                     end
                     
                     str = cleanmarkup(str);  %escape markup characters

                     %wrap string in element tags named for structure fields
                     if m > 1
                     
                        if size(str,1) <= 1  %1 line - use inline tags
                           tempstr = [tempstr ; {['<',f,'>',str,'</',f,'>']}];
                        else  %multiple lines - use nested tags
                           tempstr = [tempstr ; ...
                                 {['<',f,'>',deblank(str(1,:))]}];
                           if size(str,1) > 2
                              tempstr = [tempstr ; ...
                                    {[repmat(' ',size(str,1)-2,indent),str(2:size(str,1)-1,:)]}];
                           end
                           tempstr = [tempstr ; ...
                                 {[blanks(indent),deblank(str(end,:)),'</',f,'>']}];
                        end
                        
                     else
                        
                        if size(str,1) <= 1  %1 line - use inline tags
                           tempstr = {['<',f,'>',str,'</',f,'>']};
                        else  %multiple lines - use nested tags
                           tempstr = [{['<',f,'>',deblank(str(1,:))]}];
                           if size(str,1) > 2
                              tempstr = [tempstr ; ...
                                    {[repmat(' ',size(str,1)-2,indent),str(2:size(str,1)-1,:)]}];
                           end
                           tempstr = [tempstr ; ...
                                 {[blanks(indent),deblank(str(end,:)),'</',f,'>']}];
                        end
                        
                     end
                     
                  elseif emptyfld == 1
                  
                     if m > 1
                        tempstr = [tempstr ; {['<',f,'/>']}];
                     else
                        tempstr = {['<',f,'/>']};
                     end
                     
                  end
                  
               end
               
            end
            
            %add processed text to xml fragment
            if ~isempty(tempstr)
            
               tempstr = char(tempstr);  %convert from cell to char array
               
               if ~isempty(outertag)  %wrap child elements in outer tags
                  
                  pad = blanks(lmarg);
                  pad2 = blanks(lmarg + indent);
                  
                  if n > 1
                     xmlstr = char(xmlstr,[pad,'<',outertag{n},'>'], ...
                        [repmat(pad2,size(tempstr,1),1),tempstr], ...
                        [pad,'</',outertag{n},'>']);
                  else
                     xmlstr = char([pad,'<',outertag{n},'>'], ...
                        [repmat(pad2,size(tempstr,1),1),tempstr], ...
                        [pad,'</',outertag{n},'>']);
                  end
                  
               else  %no outertag specified - concatenate elements
                  
                  if n > 1
                     xmlstr = char(xmlstr,[repmat(' ',size(tempstr,1),lmarg),tempstr]);
                  else
                     xmlstr = [repmat(' ',size(tempstr,1),lmarg),tempstr];
                  end
                  
               end
               
            end
            
         end
         
      end
      
   end
   
end

return


%define subfunction for escaping invalid xml character data
function str2 = cleanmarkup(str)
if size(str,1) > 1
   str = cellstr(str);
end
str = strrep(str,'&','&amp;');
str = strrep(str,'<','&lt;');
str = strrep(str,'>','&gt;');
%str = strrep(str,'''''','&apos;');
%str = strrep(str,'"','&quot;');
str2 = char(str);

return