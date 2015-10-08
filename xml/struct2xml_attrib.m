function [xmlstr,attribs] = struct2xml_attrib(s,outertag,emptyfld,wrap,indent,lmarg,attrib,level)
%Generates an xml fragment with attributes from a uni- or multi-dimensional structure 
%using field names for elements and nesting based on sub-structure hierarchy
%
%syntax: xmlstr = struct2xml_attrib(s,outertag,emptyfields,wrapcolumn,indent,leftmargin,attr)
%
%input:
%  s = structure containing nested sub-structure fields or data fields composed of
%     character arrays, scalar numbers, or 1-2 dimensional numeric arrays
%  outertag = outer tag to use for wrapping each primary structure dimension (default = '')
%  emptyfields = option to include empty fields (0 = no/default, 1 = yes)
%  wrapcolumn = word wrap column for long strings (default = 80, 0 for no wrapping)
%  indent = number of characters to indent when nesting tags (default = 3)
%  leftmargin = number of characters to prepend to each line (default = 0)
%  attr = attributes string to include in the outertag element (default = '')
%  level = recursion level (default = 1)
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
%  3. fieldnames containing double underscore will be converted to namespace format with colons
%     (e.g. 'eml__eml' -> 'eml:eml')
%  4. struct fieldnames beginning with 'attrib_' will be included as attributes of the parent element
%  5. to include attributes on terminal elements, use a 2-element cell array for the field value
%     with the attribute(s) in the first cell, e.g. root.sub.subsub = {'att="123"','xyz'}
%  6. attribute-only elements will be renderered as <element attribute="value" />
%  7. angle brackets (<>) and ampersands (&) will be escaped in element contents unless preceeded
%     by the prefix 'raw:', e.g. 'raw:<a href="#">test</a>' --> <a href="#">test</a>
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
%last modified: 29-Jul-2014

xmlstr = [];
err = 0;
attribs = '';

if nargin >= 1
   
   if isstruct(s)
      
      s = s(:)';  %convert multidimensional structures to row-major orientation
      
      %get field names for current structure dimension
      fn = fieldnames(s);
      num = length(fn);
      
      %get list of attributes, based on 'attrib_' prefix of fieldname
      Iatt = find(strncmpi(fn,'attrib_',7));
      if ~isempty(Iatt)
         attribs = sub_attributes(s,fn,Iatt);
      else
         attribs = '';
      end
      
      %validate input, supply defaults
      if exist('lmarg','var') ~= 1  %apply default left margin if omitted
         lmarg = 0;
      end
      
      if exist('indent','var') ~= 1  %apply default indent if omitted
         indent = 3;
      end
      
      if exist('wrap','var') ~= 1  %apply default wrap if omitted
         wrap = 100;
      elseif wrap < 30
         wrap = 30;  %set minimum wrap to prevent margin offset errors with long strings
      end
      
      if exist('emptyfld','var') ~= 1
         emptyfld = 0;
      end
      
      if exist('attrib','var') ~= 1
         attrib = '';
      end
      
      if exist('level','var') ~= 1
         level = 1;
      end
      
      %cache outer attributes if recursion level = 1
      attrib0 = '';
      if level == 1 && ~isempty(attrib)
         attrib0 = [' ',attrib];  %prepend space for inclusion in root element
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
         
         for n = 1:size(s,2)  %loop through struct dimensions
         
            tempstr = [];
            
            for m = 1:num  %loop through struct elements
            
               f = fn{m};  %look up field name
               v = s(n).(f);  %get field contents

               if isstruct(v) %structure field - recurse
                  
                  %check for substructure orientation
                  if size(v,2) > 1  %column-major, wrap contents in field name tags
                     
                     s_tmp = struct2xml_attrib(v',f,emptyfld,wrap,indent,0,'',level+1);
                     tempstr = [tempstr ; {s_tmp}];
                     
                  else  %row-major, serialize contents without field name tags
                     
                     [str,attrib] = struct2xml_attrib(v,'',emptyfld,wrap,indent,indent,attribs,level+1);
                     
                     el = strrep(f,'__',':');
                     
                     if m > 1
                        %prepend previous elements and add attributes to parent
                        if ~isempty(str)
                           tempstr = [tempstr ; {['<',strrep(el,'__',':'),attrib,'>']} ; {str}; {['</',el,'>']}];
                        else
                           tempstr = [tempstr ; {['<',strrep(el,'__',':'),attrib,' />']}];
                        end
                     else
                        if ~isempty(str)
                           tempstr = [{['<',el,attrib,'>']} ; {str}; {['</',el,'>']}];
                        else
                           tempstr = {['<',el,attrib,' />']};
                        end
                     end
                     
                  end
                  
               elseif ~strncmpi('attrib_',f,7)   %value field
                  
                  %generate element name
                  el = strrep(f,'__',':');
                  
                  %init value-field attribute
                  att = '';
                  
                  %check for compound field with attributes and value
                  if iscell(v) && length(v) == 2
                     att = [' ',v{1}];
                     v = v{2};
                  end
                  
                  %check value field type
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
                     
                     %escape markup characters unless raw: prefix added
                     if ~strncmpi('raw:',str(1,:),4)
                        str = cleanmarkup(str);
                     else
                        if size(str,1) > 1
                           wid = size(str,2);
                           str(1,1:wid) = [str(1,5:wid),'    '];  %remove raw: from first line and adjust
                        elseif length(str) > 4
                           str = str(5:end);  %remove raw: from single line
                        else
                           str = '';
                        end
                     end
                     
                     %wrap string in element tags named for structure fields
                     if m > 1
                        
                        if size(str,1) <= 1  %1 line - use inline tags
                           tempstr = [tempstr ; {['<',el,att,'>',str,'</',el,'>']}];
                        else  %multiple lines - use nested tags
                           tempstr = [tempstr ; ...
                              {['<',el,att,'>',deblank(str(1,:))]}];
                           if size(str,1) > 2
                              tempstr = [tempstr ; ...
                                 {[repmat(' ',size(str,1)-2,indent),str(2:size(str,1)-1,:)]}];
                           end
                           tempstr = [tempstr ; ...
                              {[blanks(indent),deblank(str(end,:)),'</',el,'>']}];
                        end
                        
                     else
                        
                        if size(str,1) <= 1  %1 line - use inline tags
                           tempstr = {['<',el,att,'>',str,'</',el,'>']};
                        else  %multiple lines - use nested tags
                           tempstr = {['<',el,att,'>',deblank(str(1,:))]};
                           if size(str,1) > 2
                              tempstr = [tempstr ; ...
                                 {[repmat(' ',size(str,1)-2,indent),str(2:size(str,1)-1,:)]}];
                           end
                           tempstr = [tempstr ; ...
                              {[blanks(indent),deblank(str(end,:)),'</',el,'>']}];
                        end
                        
                     end
                     
                  elseif emptyfld == 1
                     
                     if m > 1
                        tempstr = [tempstr ; {['<',el,att,'/>']}];
                     else
                        tempstr = {['<',el,att,'/>']};
                     end
                     
                  end
                  
               elseif ischar(v) && ~isempty(outertag) && m == num  %catch single attribute nodes
                  
                  attrib = [' ',f(8:end),'="',v,'"'];
                  el = outertag{n};
                  outertag{n} = '';  %clear outertag
                  
                  if m > 1
                     tempstr = [tempstr ; {['<',el,attrib,'/>']}];
                  else
                     tempstr = {['<',el,attrib,'/>']};
                  end
                  
               end
               
            end
            
            %add processed text to xml fragment
            if ~isempty(tempstr)
            
               %remove empty cells
               Ivalid = ~cellfun('isempty',tempstr);
               tempstr = tempstr(Ivalid);
               
               %convert from cell to char array
               tempstr = char(tempstr); 
               
               %wrap child elements in outer tags
               if ~isempty(outertag) && ~isempty(outertag{n})
                  
                  pad = blanks(lmarg);
                  pad2 = blanks(lmarg + indent);
                  
                  el = strrep(outertag{n},'__',':');
                  
                  if n > 1
                     xmlstr = char(xmlstr,[pad,'<',el,attrib0,'>'], ...
                        [repmat(pad2,size(tempstr,1),1),tempstr], ...
                        [pad,'</',el,'>']);
                  else
                     xmlstr = char([pad,'<',el,attrib0,'>'], ...
                        [repmat(pad2,size(tempstr,1),1),tempstr], ...
                        [pad,'</',el,'>']);
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
str2 = char(str);

return

%define subfunction for pre-processing attributes for inclusion with the element
function attribs = sub_attributes(s,fn,Iatt)

%init attribute cell array
attriblist = cell(length(Iatt),2);

%loop throug attributes
for n = 1:length(Iatt)
   
   %get fieldname and field value
   f = fn{Iatt(n)};
   v = s.(f);
      
   if length(f) > 7 && (ischar(v) || isnumeric(v))
      
      %generate attribute name
      attriblist{n,1} = f(8:end);
      
      %get attribute value
      if isnumeric(v)
         str = num2str(v);
      else
         str = v;
      end
      attriblist{n,2} = ['"',str,'"'];
      
   end
   
end

%get index of valid attributes
Ivalid = ~cellfun('isempty',attriblist(:,1)) & ~cellfun('isempty',attriblist(:,2));

%format attributes
if ~isempty(Ivalid)
   attribs = [' ',char(concatcellcols(concatcellcols(attriblist(Ivalid,:),'=')',' '))];  %prepend space
else
   attribs = '';
end
      
return