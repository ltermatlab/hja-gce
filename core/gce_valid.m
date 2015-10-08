function [val,stype,msg] = gce_valid(s,stype)
%Identifies and validates a GCE-LTER Data or Stat Structure by checking for required fields and verifying
%the correspondence of column and row elements in each value field.
%
%syntax:  [val,stype,msg] = gce_valid(s,stype)
%
%input:
%   s = structure to validate
%   stype = type of structure to validate (automatic if omitted)
%
%output:
%   val = validation results (1 = valid, 0 = invalid)
%   stype = type of structure ('data' or 'stat')
%   msg = text of any error messages
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
%last modified: 09-Oct-2011

%init output
val = 0;
if exist('stype','var') ~= 1
   stype = '';
elseif ~strcmp(stype,'data') && ~strcmp(stype,'stat')
   stype = '';
end
msg = '';

if nargin >= 1
   
   if isstruct(s)
      
      if isfield(s,'version')
         
         %get first version entry, pad to prevent errors
         ver = cellstr(s.version);
         ver = [ver{1} blanks(8)];
         
         %initialize check variables
         colcheck = 0;
         rowcheck = 0;
         
         if isempty(stype)
            if strcmp(ver(1,1:8),'GCE Data')
               stype = 'data';
            elseif strcmp(ver(1,1:8),'GCE Stat')
               stype = 'stat';
            end
         end
         
         switch stype
            
            case 'data'  %validate data structure
               
               flist = [{'version'}, ...
                     {'title'}, ...
                     {'metadata'}, ...
                     {'datafile'}, ...
                     {'createdate'}, ...
                     {'editdate'}, ...
                     {'history'}, ...
                     {'name'}, ...
                     {'units'}, ...
                     {'description'}, ...
                     {'datatype'}, ...
                     {'variabletype'}, ...
                     {'numbertype'}, ...
                     {'precision'}, ...
                     {'values'}, ...
                     {'criteria'}, ...
                     {'flags'}];
               
               %check fields
               fdtest = 0;
               for n = 1:length(flist)
                  fdtest = fdtest + isfield(s,flist{n});
               end
               
               if fdtest == length(flist)  %fields OK
                  
                  %init attribute metadata column list
                  collist = [{'name'}, ...
                        {'units'}, ...
                        {'description'}, ...
                        {'datatype'}, ...
                        {'variabletype'}, ...
                        {'numbertype'}, ...
                        {'precision'}, ...
                        {'values'}, ...
                        {'criteria'}, ...
                        {'flags'}];
                  
                  %init counters
                  numcols = length(s.name);
                  testcols = 0;
                  
                  %check for matching arrays in attribute fields
                  for n = 1:length(collist)
                     ar = s.(collist{n});
                     testcols = testcols + (size(ar,2) == numcols);
                  end
                  
                  if testcols == length(collist)
                     colcheck = 1;
                  else
                     msg = 'invalid number of column elements in one or more fields';
                  end
                  
                  %proceed if columns ok
                  if colcheck == 1
                     
                     %check for data arrays (non-empty structure)
                     if ~isempty(s.values)
                        
                        %check array lengths in value, flag fields
                        numrows = length(s.values{1});
                        
                        %init test counters
                        testvals = 0;
                        testflags = 0;
                        testdtypes = 0;
                        
                        %loop through columns to check lengths, datatypes, flag lengths
                        for n = 1:length(s.name)
                           
                           %check for single-column array consistent with data type
                           if size(s.values{n},2) == 1

                              %check array length
                              testvals = testvals + (length(s.values{n}) == numrows);
                           
                              %check data type
                              dtype = s.datatype{n};
                              if strcmp(dtype,'s')  %string
                                 %check cell array
                                 if iscell(s.values{n})
                                    testdtypes = testdtypes + 1;
                                 end
                              elseif strcmp(dtype,'d') || strcmp(dtype,'f') || strcmp(dtype,'e')
                                 %check numeric array
                                 if isnumeric(s.values{n}) && size(s.values{n},2) == 1
                                    testdtypes = testdtypes + 1;
                                 end
                              end
                           end
                           
                           %check flag arrays
                           if ~isempty(s.flags{n})
                              testflags = testflags + (size(s.flags{n},1) == numrows);
                           else
                              testflags = testflags + 1;
                           end
                           
                        end
                        
                        %check results of column checks
                        if testvals == numcols && testflags == numcols && testdtypes == numcols
                           rowcheck = 1;
                        else
                           msg = '';
                           if testvals < numcols
                              msg = [msg,'invalid number of data rows in ',int2str(numcols-testvals),' field(s); '];
                           end
                           if testdtypes < numcols
                              msg = [msg,'invalid data type or unsupported array type in ',int2str(numcols-testdtypes),' field(s); '];
                           end
                           if testflags < numcols
                              msg = [msg,'invalid number of flags in ',int2str(numcols-testflags),' field(s); '];
                           end
                           msg = msg(1:end-2);
                        end
                        
                     else  %no data, check flags
                        
                        if isempty(s.flags)
                           rowcheck = 1;
                        else
                           msg = 'invalid number or rows in one or more value or flag fields';
                        end
                        
                     end
                     
                  end
                  
               end
               
            case 'stat'  %stat structure
               
               flist = [{'version'}, ...
                     {'title'}, ...
                     {'metadata'}, ...
                     {'history'}, ...
                     {'analysisdate'}, ...
                     {'flagoption'}, ...
                     {'name'}, ...
                     {'units'}, ...
                     {'description'}, ...
                     {'datatype'}, ...
                     {'variabletype'}, ...
                     {'numbertype'}, ...
                     {'precision'}, ...
                     {'criteria'}, ...
                     {'group'}, ...
                     {'groupvalue'}, ...
                     {'observations'}, ...
                     {'missing'}, ...
                     {'valid'}, ...
                     {'flagged'}, ...
                     {'min'}, ...
                     {'max'}, ...
                     {'median'}, ...
                     {'total'}, ...
                     {'mean'}, ...
                     {'stddev'}, ...
                     {'se'}];
               
               %check fields
               fdtest = 0;
               for n = 1:length(flist)
                  fdtest = fdtest + isfield(s,flist{n});
               end
               
               if fdtest == length(flist)  %fields OK
                  
                  %check column lengths
                  collist = [{'name'}, ...
                        {'units'}, ...
                        {'description'}, ...
                        {'datatype'}, ...
                        {'variabletype'}, ...
                        {'numbertype'}, ...
                        {'precision'}, ...
                        {'observations'}, ...
                        {'missing'}, ...
                        {'valid'}, ...
                        {'flagged'}, ...
                        {'min'}, ...
                        {'max'}, ...
                        {'median'}, ...
                        {'total'}, ...
                        {'mean'}, ...
                        {'stddev'}, ....
                        {'se'}];
                  
                  numcols = length(s.name);
                  testcols = 0;
                  
                  for n = 1:length(collist)
                     ar = s.(collist{n});
                     testcols = testcols + (size(ar,2) == numcols);
                  end
                  
                  if testcols == length(collist)
                     colcheck = 1;
                  end
                  
                  if colcheck == 1  %columns OK
                     
                     rowlist = [{'observations'}, ...
                           {'missing'}, ...
                           {'valid'}, ...
                           {'flagged'}, ...
                           {'min'}, ...
                           {'max'}, ...
                           {'median'}, ...
                           {'total'}, ...
                           {'mean'}, ...
                           {'stddev'}, ...
                           {'se'}];
                     
                     numrows = max(1,size(s.groupvalue,1));
                     
                     %test number of rows in each stat field
                     testrows = 0;
                     for n = 1:length(rowlist)
                        ar = s.(rowlist{n});
                        testrows = testrows + (size(ar,1) == numrows);
                     end
                     
                     if testrows == length(rowlist)
                        rowcheck = 1;
                     else
                        rowcheck = 0;
                     end
                     
                  end
                  
               end
               
         end
         
         if rowcheck == 1  %passed all validations
            val = 1;
         end
         
      else
         msg = 'missing ''version'' field';
      end
      
   else
      msg = 'not a valid GCE data or stat structure';
   end
   
else
   msg = 'insufficient arguments for function';
end
