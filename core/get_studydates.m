function [dt,msg,s,datecol] = get_studydates(s,datecol)
%Retrieves serial dates for records in a GCE Data Structure based on analysis of datetime columns
%
%syntax: [dt,msg,s,datecol] = get_studydates(s,datecol)
%
%inputs:
%  s = GCE Data Structure
%  datecol = serial date column (automatically determined or calculated if omitted)
%
%outputs:
%  dt = array of MATLAB serial date numbers
%  msg = text of any error message
%  s = data structure (original structure or modified structure with added serial date column)
%  datecol = serial date column index
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
%last modified: 06-Mar-2013

dt = [];
msg = '';

if nargin >= 1

   if gce_valid(s,'data')

      if exist('datecol','var') ~= 1
         datecol = [];
      elseif ~isnumeric(datecol)
         datecol = name2col(s,datecol);
      end

      dt_data = [];  %init date val array

      %extract serial dates
      if ~isempty(datecol)
         
         dt_data = extract(s,datecol);
         
      else
         
         %check for datetime columns starting with 'date'
         Imatch = find(strncmpi(s.name,'date',4) & strcmp(s.variabletype,'datetime'));
         
         if ~isempty(Imatch)
            
            if length(Imatch) > 1
               Imatch2 = find(strcmp(s.datatype(Imatch),'f'));  %check for floating=point date column first
               if ~isempty(Imatch2)
                  datecol = Imatch(Imatch2(1));  %use first floating-point column
               else
                  datecol = Imatch(1);  %use first non floating-point column
               end
            else
               datecol = Imatch;
            end
            
            dt_data = extract(s,datecol);
            
         else
            
            %check for any string or floating-point column of type datetime
            Imatch = find((strcmp(s.datatype,'s') | strcmp(s.datatype,'f')) & strcmp(s.variabletype,'datetime'));
            
            if ~isempty(Imatch)
               
               datecol = Imatch(1);
               dt_data = extract(s,Imatch(1));  %take first match
               
            else  %try to generate date column from date part columns
               
               s_tmp = add_datecol(s);  
               if ~isempty(s_tmp)
                  s = s_tmp;
                  dt_data = extract(s,'Date');
               end
               
            end
            
         end
         
      end

      %determine date format, convert to ML serial date format
      if ~isempty(dt_data)

         if iscell(dt_data)  %assume string format
            try
               dt = datenum(char(dt_data));  %convert to character array, pass to datenum
               if ~isnumeric(dt)
                  dt = [];  %check for character array output from unsupported formats
               end
            catch
               try
                  dt = datenum_iso(char(dt_data));  %try ISO date format
               catch
                  dt = [];
               end
            end
         else
            dt = dt_data;
            if min(dt(~isnan(dt))) < 69000  %check for spreadsheet format, convert to MATLAB serial date
               dt = datecnv(dt,'xl2mat');
            end
         end

         if isempty(dt) || length(dt) ~= length(s.values{1})
            dt = [];  %null in case not empty
            msg = ['no valid date values were present in the selected column ''',s.name{datecol},''''];
         end

      else
         msg = 'date column was invalid or could not be automatically determined';
      end

   end
   
else
   msg = 'insufficient arguments for function';
end