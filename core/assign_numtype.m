function [s2,msg] = assign_numtype(s,exptol,cols)
%Automatically assigns numerical types and precisions to columns in a GCE Data Structure
%based on numerical characteristics and specified exponential tolerance
%
%syntax: [s2,msg] = assign_numtype(s,exptol,cols)
%
%inputs:
%  s = data structure to evaluate
%  exptol = tolerance for converting floating-point columns to exponential (val >= exptol)
%    (default = 0 - do not convert)
%  cols = array of column names or index numbers to evaluate (default = all)
%
%output:
%  s2 = modified structure
%  msg = text of any error messages
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
%last modified: 28-Mar-2013

%init output
s2 = [];
msg = '';

%validate input
if nargin >= 1 && gce_valid(s,'data')
   
   %copy input structure
   s2 = s;
   
   %init runtime variables
   editcols = [];
   ecols = [];
   dcols = [];
   fcols = [];
   
   %validate column selection, defaulting to all
   if exist('cols','var') ~= 1
      cols = [];
   end
   if isempty(cols)
      cols = (1:length(s.name));
   elseif ~isnumeric(cols)
      cols = name2col(s,cols);
   end
   
   if ~isempty(cols)
      
      %set default exponential tolerance to 0 to force assignment of big numbers as floating-point
      if exist('exptol','var') ~= 1
         exptol = 0;
      end
      
      %loop through columns checking scale
      for n = 1:length(cols)
         
         ptr = cols(n);  %get column pointer
         
         %check for string columns
         if strcmp(s.datatype{ptr},'s')
            
            s2.numbertype{ptr} = 'none';
            s2.precision(ptr) = 0;
            
         else  %evaluate column data
            
            editcols = [editcols,ptr];  %add column to edited list
            vals = s.values{ptr};  %extract values
            
            %get index of nonzero, non-NaN vals
            Ivalid = find((abs(vals)>0)+(~isnan(vals)) == 2);
            num_valid = length(Ivalid);
            
            %check for any valid values
            if num_valid > 0

               %check for integers, using an offset index to check for symmetric values oscillating
               if sum(vals(Ivalid) - fix(vals(Ivalid))) == 0 && sum(vals(Ivalid(min(2,num_valid):end)) - fix(vals(Ivalid(min(2,num_valid):end)))) == 0

                  if ~strcmp(s2.datatype{ptr},'d')
                     dcols = [dcols,ptr];
                     s2.datatype{ptr} = 'd';
                  end
                  s2.numbertype{ptr} = 'discrete';
                  s2.precision(ptr) = 0;
                  
               else  %evaluate floating-point/exponential
                  
                  s2.numbertype{ptr} = 'continuous';
                  
                  %determine precision based on order of magnitude
                  try
                     om = ceil(log10(max(abs(vals(Ivalid)))));
                     if exptol > 0 && 10.^om >= exptol
                        %assign exponential type if more significant digits than exp tolerance
                        ecols = [ecols,ptr];
                        s2.datatype{ptr} = 'e';
                        s2.precision(ptr) = 3;
                     else
                        if ~strcmp(s.datatype{ptr},'e')
                           fcols = [fcols,ptr];
                           s2.datatype{ptr} = 'f';  %force floating point
                           s2.precision(ptr) = max(0,6-om);  %default to >= 6 significant digits for floats
                        else  %set exponential to precision of 3                           
                           s2.precision(ptr) = 3;
                        end
                     end
                  catch
                     s2.precision(ptr) = 0;
                  end
                  
               end
               
            else  %all 0 or NaN - assign as integer
               
               if ~strcmp(s2.datatype{ptr},'d')
                  dcols = [dcols,ptr];
                  s2.datatype{ptr} = 'd';
               end
               s2.numbertype{ptr} = 'discrete';
               s2.precision(ptr) = 0;
               
            end
            
         end
         
      end
      
      if ~isempty(editcols)  %update history if columns edited
         
         reassignstr = '';
         
         %add reassignment string for exponential columns
         if ~isempty(ecols)
            if length(ecols) > 1
               reassignstr = [reassignstr, ...
                  '; assigned data types of columns ',cell2commas(s2.name(ecols),1),' to ''e'' (exponential)'];
            else
               reassignstr = [reassignstr, ...
                  '; assigned data type of column ',s2.name{ecols},' to ''e'' (exponential)'];
            end
         end
         
         %add reassignment string for integer columns
         if ~isempty(dcols)
            if length(dcols) > 1
               reassignstr = [reassignstr, ...
                  '; assigned data types of columns ',cell2commas(s2.name(dcols),1),' to ''d'' (integer)'];
            else
               reassignstr = [reassignstr, ...
                  '; assigned data type of column ',s2.name{dcols},' to ''d'' (integer)'];
            end
         end
         
         %add reassignment string for float columns
         if ~isempty(fcols)
            if length(fcols) > 1
               reassignstr = [reassignstr, ...
                  '; assigned data types of columns ',cell2commas(s2.name(fcols),1),' to ''f'' (floating-point)'];
            else
               reassignstr = [reassignstr, ...
                  '; assigned data type of column ',s2.name{fcols},' to ''f'' (floating-point)'];
            end
         end
         
         %generate complete history strings
         if length(editcols) > 1
            colnames = cell2commas(s2.name(editcols),1);
            histstr = ['automatically assigned numerical types and precisions for columns ', ...
               colnames,reassignstr,' (''assign_numtype'')'];
         else
            histstr = ['automatically assigned numerical type and precision for column ', ...
               s2.name{editcols},reassignstr,' (''assign_numtype'')'];
         end
         
         %update edit date
         s2.editdate = datestr(now);
         
         %update history field
         s2.history = [s2.history ; {datestr(now)},{histstr}];
         
      end
      
   else
      msg = 'column selections are invalid';
   end
   
else
   if nargin == 0
      msg = 'insufficient arguments for function';
   else
      msg = 'invalid data structure';
   end
end