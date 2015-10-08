function [s2,msg] = add_anomalies(s,fmt,datesep,missing,cols,overwrite)
%Summarizes flagged and missing values for specified parameters and stores the report in the Data/Anomalies
%section of the metadata. Reports can be generated for all records or by date range (with resolution based
%on date format)
%
%syntax: [s2,msg] = add_anomalies(s,format,datesep,missing,cols,overwrite)
%
%inputs:
%  s = GCE Data Structure to modify
%  format = format to use for dates ([] for none, default = 23 for mm/dd/yyyy -- see 'datestr')
%  datesep = date separator string for date ranges (default = '-', e.g. 01/13/2004-01/19/2004)
%  missing = option to also document missing values as anomalies
%    0 = no (default)
%    1 = yes
%  cols = array of column numbers or names to document (all if omitted or [], select from
%    a list if cols = -1)
%  overwrite = option to overwrite existing Data/Anomalies metadata
%    0 = no (default)
%    1 = yes
%
%outputs:
%  s2 = modified structure
%  msg = text of any error message
%
%
%(c)2002-2012 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project-2006 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 26-Jun-2012

s2 = [];
msg = '';

if nargin >= 1

   if gce_valid(s,'data')

      %supply defaults for omitted parameters
      if exist('fmt','var') ~= 1
         fmt = 23;
      end
      if mlversion < 6 && fmt > 18  %validate input against ML version
         fmt = 2;
      end

      if exist('datesep','var') ~= 1
         datesep = '-';
      end

      if exist('missing','var') ~= 1
         missing = 0;
      end

      if exist('overwrite','var') ~= 1
         overwrite = 0;
      end

      if exist('cols','var') ~= 1
         cols = [];
      end

      if isempty(cols)
         cols = (1:length(s.name));
      elseif ~isnumeric(cols)
         cols = name2col(s,cols);  %lookup named columns
      elseif cols == -1
         %select columns from a list
         cols = listdialog('liststring',s.name','name','Document Anomalies','promptstring', ...
            'Choose columns to document','selectionmode','multiple','listsize',[0 0 250 400]);
      end

      %validate columns to summarize
      if ~isempty(cols)

         %retrieve/validate dates if relevant
         if ~isempty(fmt)
            dt = get_studydates(s);  %extract/calculate study dates from date/time columns
            if isempty(dt)
               fmt = [];
               msg = 'No date/time columns could be identified - date format ignored';
            end
         end

         anom = '';  %init anomaly string
         flaglist_ar2 = [];  %init flag code/flag def array
         usedcols = zeros(1,length(cols));  %init array for counting columns documented

         %retrieve and parse flag codes in the metadata
         flaglist = lookupmeta(s,'Data','Codes');  %get list of flag codes
         if isempty(flaglist)  %supply default flags to init lookup array
            flaglist = 'Q = questionable value, I = invalid valud (out of range)';
         end

         if ~isempty(strfind(flaglist,'|'))  %check for outdated delim
            flaglist_ar = splitstr(flaglist,'|',1,1);
         else
            flaglist_ar = splitstr(flaglist,',',1,1);
         end
         
         for n = 1:length(flaglist_ar)
            [flagcode,flagdef] = strtok(flaglist_ar{n},'=');
            if length(flagdef) >= 3  %check for valid definition
               flaglist_ar2 = [flaglist_ar2 ; {deblank(flagcode)},{deblank(flagdef(3:end))}];
            end
         end

         %document flags for each parameter
         for n = 1:length(cols)

            flags = s.flags{cols(n)};  %get flags

            if ~isempty(flags)

               usedcols(n) = 1;  %set used flag

               Iflags = find(flags(:,1)~=' ');  %get index of values assigned flags

               if ~isempty(Iflags)

                  usedflags = cellstr(unique(flags(Iflags,1)));  %get list of unique used flags

                  %generate anomaly strings for each type of flag
                  for m = 1:length(usedflags)

                     Iflag = find(flags(Iflags)==usedflags{m});  %get subindex of flags
                     numflags = length(Iflag);  %generate appropriate flag count string
                     if numflags > 1
                        numflagstr = [' Values of ',int2str(numflags),' records'];
                        numflagstr2 = ' were flagged as ';
                     else
                        numflagstr = [' The value of one record'];
                        numflagstr2 = ' was flagged as ';
                     end

                     %generate flag description string using flag definition if available
                     Iflagstr = find(strcmp(flaglist_ar2(:,1),usedflags{m}));
                     if ~isempty(Iflagstr)
                        flagstr = [usedflags{m},' (',flaglist_ar2{Iflagstr(1),2},')'];
                     else
                        flagstr = [usedflags{m},' (undefined flag)'];
                     end

                     if ~isempty(fmt)  %summarize by date
                        dstr = daterange2str(dt,Iflags(Iflag),fmt,datesep);  %get textual description of date range
                        if ~isempty(strfind(dstr,',')) || ~isempty(strfind(dstr,datesep))  %generate appropriate date description string
                           dstr = [' for dates: ',dstr];
                        else  %single date
                           dstr = [' for date ',dstr];
                        end
                     else  %summarize entire column only
                        dstr = '';
                     end

                     %append to cumulative anomaly string
                     anom = [anom,numflagstr,' in ',s.name{cols(n)},numflagstr2,flagstr,dstr,'.'];

                  end

               end
            end

            if missing == 1  %document missing values

               if strcmp(s.datatype{cols(n)},'s')  %check for string column
                  Imissing = find(cellfun('isempty',s.values{cols(n)}));
               else
                  Imissing = find(isnan(s.values{cols(n)}));
               end

               if ~isempty(Imissing)

                  usedcols(n) = 1;  %set used flag

                  if ~isempty(fmt)  %summarize by date
                     dstr = daterange2str(dt,Imissing,fmt,datesep);  %get textual description of date range
                     if ~isempty(strfind(dstr,',')) || ~isempty(strfind(dstr,datesep))  %generate appropriate date description string
                        dstr = [' for dates: ',dstr];
                     else  %single date
                        dstr = [' for date ',dstr];
                     end
                  else  %summarize entire column
                     dstr = '';
                  end

                  nmissing = length(Imissing);
                  if nmissing > 1
                     anom = [anom,' Values of ',int2str(nmissing),' records in ',s.name{cols(n)},' are missing',dstr,'.'];
                  else
                     anom = [anom,' The value of one record in ',s.name{cols(n)},' is missing',dstr,'.'];
                  end

               end
            end
         end

         if ~isempty(anom)

            if overwrite == 0
               anom_old = lookupmeta(s,'Data','Anomalies');
               if ~isempty(anom_old)
                  anom = [anom_old,anom];  %append new text
               else
                  anom = anom(2:end);  %strip leading space
               end
            else
               anom = anom(2:end);
            end

            [s2,msg] = addmeta(s,{'Data','Anomalies',anom},1);

            Iused = find(usedcols);
            if ~isempty(Iused)
               if length(Iused) > 1
                  usedcolstr = 'columns ';
               else
                  usedcolstr = 'column ';
               end
               usedcolstr = [usedcolstr,cell2commas(s.name(cols(Iused)),1)];
            else
               usedcolstr = 'columns';
            end
            if missing == 0
               histstr = ['documented flagged values in ',usedcolstr, ...
                     ' as data set anomalies in the metadata (''add_anomalies'')'];
            else
               histstr = ['documented flagged and missing values in ',usedcolstr, ...
                     ' as data set anomalies in the metadata (''add_anomalies'')'];
            end

            s2.history = [s2.history ; {datestr(now)},{histstr}];

         else  %no anomalies -- just copy original structure

            s2 = s;
            if overwrite == 1  %clear anomalies metadata
               s2 = addmeta(s2,{'Data','Anomalies',''},1);
            end

         end

      end

   else  %bad struct
      msg = 'invalid GCE Data Structure';
   end

else  %insufficient input
   msg = 'data structure required';
end