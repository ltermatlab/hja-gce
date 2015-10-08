function [s2,msg] = fixprec(s,cols,opt)
%Sets numerical precision of specified columns in a GCE Data Structure equal to the display precision
%by rounding or truncation.
%
%syntax:  [s2,msg] = fixprec(s,cols,opt)
%
%inputs:
%  s = input data structure
%  cols = array of column numbers or names to fix (default = all)
%  opt = rounding/truncation option:
%    'round' = round to nearest decimal (e.g. 5.433, prec=1 --> 5.4)
%    'ceil' = round up to next decimal (e.g. 5.433, prec=1 --> 5.5)
%    'floor' = round down to next decimal  (e.g. 5.433, prec=1 --> 5.4)
%    'fix' = truncate (e.g. 5.433, prec=1 --> 5.4)
%
%outputs:
%  s2 = modified data structure
%  msg = text of any error message
%
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
%last modified: 15-Jul-2013

%init output
s2 = [];
msg = '';

%check for required arguments
if nargin >= 1
   
   if gce_valid(s,'data') == 1
      
      %check for missing cols, default to empty
      if exist('cols','var') ~= 1
         cols = [];
      end
      
      %validate column selection
      if isempty(cols)
         cols = 1:length(s.name);
      elseif ~isnumeric(cols)
         cols = name2col(s,cols);
      else
         try
            cols = intersect((1:length(s.name)),cols);
         catch e
            cols = [];
            msg = ['an error occurred validating column selections (',e.message,')'];
         end
      end
      
      if ~isempty(cols)
         
         %set default option if omitted
         if exist('opt','var') ~= 1
            opt = 'round';
         end
         
         %set function name and description string based on option
         switch opt
            case 'ceil'
               fnc = 'ceil';
               fncstr = 'rounding up to the next decimal';
            case 'floor'
               fnc = 'floor';
               fncstr = 'rounding down to the next decimal';
            case 'fix'
               fnc = 'fix';
               fncstr = 'truncation';
            otherwise
               fnc = 'round';
               fncstr = 'rounding to the nearest decimal';
         end
         
         %extract values array
         vals = s.values;
         
         %init array of bad columns
         badcols = zeros(length(cols),1);
         
         %loop through columns
         for n = 1:length(cols)
            
            %get data type
            dtype = s.datatype{cols(n)};
            
            if ~strcmp(dtype,'s')
               
               %get precision
               prec = s.precision(cols(n));
               
               try
                  if strcmp(dtype,'e')  %exponential
                     v = roundsig(vals{cols(n)},prec+1,fnc);  %use external func to round to significant digits
                  else  %float, integer
                     if prec > 0
                        v = feval(fnc,vals{cols(n)}.*10^prec) ./ 10^prec;
                     else
                        v = feval(fnc,vals{cols(n)});
                     end
                  end
               catch e
                  v = [];
               end
               if ~isempty(v)
                  vals{cols(n)} = v;
               else
                  badcols(n) = 1;
                  msg = ['a MATLAB error occurred setting precision (',e.message,')'];
               end
            else
               badcols(n) = 1;
            end
            
         end
         
         %get index of bad columns
         Ibadcols = find(badcols);
         
         %copy input structure
         s2 = s;
         
         %check for any valid conversions
         if sum(badcols) < length(cols)
            
            %get index of good columns
            Igoodcols = setdiff(cols,Ibadcols);
            
            %update value array
            s2.values = vals;
            
            %cache current date
            curdate = datestr(now);
            
            %generate history entry
            if length(Igoodcols) > 1
               histstr = ['Set numeric precision of columns ',cell2commas(s2.name(Igoodcols),1), ...
                  ' equal to display precision by ',fncstr,' (''fixprec'')'];
            else
               histstr = ['Set numeric precision of column ',cell2commas(s2.name(Igoodcols),1), ...
                  ' equal to display precision by ',fncstr,' (''fixprec'')'];
            end
            
            %update history
            s2.history = [s2.history ; {curdate},{histstr}];
            
            %update Q/C flags
            s2 = dataflag(s2,Igoodcols);
            
         end
         
         if ~isempty(Ibadcols)
            msg = ['Could not set precision of non-numeric column(s): ',cell2commas(s2.name(Ibadcols),1)];
         end
         
      else         
         msg = 'Invalid column selections';         
      end
      
   else      
      msg = 'Input must be a valid GCE Data Structure';      
   end
   
else   
   msg = 'insufficient arguments for function';   
end
