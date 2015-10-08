function [s2,msg] = aggr_topbottom(s,depcol,agcols,datacols,compactrowsopt)
%Returns top and bottom values for data columns in a data structure based on values in a depth or pressure column,
%after optionally aggregating by values in one or more grouping columns.
%
%syntax: [s2,msg] = aggr_topbottom(s,depcol,agcols,datacols,compactrowsopt)
%
%inputs:
%  s = data structure to aggregate
%  depcol = name or number of depth or pressure column
%  agcols = array of column names or numbers to aggregate by (none if omitted)
%  datacols = data columns to analyze (all columns except depcol, agcols if omitted)
%  compactrowsopt = option to remove rows with all NaN/null values in datacols prior to
%     summarization (0 = no, 1 = yes/default)
%
%outputs:
%  s2 = aggregated data structure
%  msg = text of any error message
%
%
%(c)2002-2008 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 24-Feb-2008

s2 = [];
msg = '';

if nargin >= 1

   if gce_valid(s,'data')
      
      if exist('compactrowsopt','var') ~= 1
         compactrowsopt = 1;
      end
      if compactrowsopt == 1
         s = compactrows(s,datacols);
      end

      if exist('agcols','var') ~= 1
         agcols = [];
      elseif ~isnumeric(agcols)
         agcols = name2col(s,agcols);
      end

      %sort structure by aggregation cols, get grouping index
      if ~isempty(agcols)
         I = find(agcols > 0 & agcols <= length(s.values));
         if ~isempty(I)
            agcols = agcols(I);
            [s2,I_breaks] = aggr_index(s,agcols);
         else
            s2 = s;
            I_breaks = [1 ; length(s.values{1})+1];
         end
      else
         s2 = s;
         I_breaks = [1 ; length(s.values{1})+1];
      end

      if ~isempty(s2)

         if exist('depcol','var') ~= 1
            depcol = [];
         elseif ~isnumeric(depcol)
            depcol = name2col(s2,depcol);
         end

         %look up depth column based on name or validate selection is numeric, singular
         if isempty(depcol)
            I = find((strncmpi(s2.name,'depth',5) | strncmpi(s2.name,'press',4)) & ...
               ~strcmp(s2.datatype,'s'));
            if ~isempty(I)
               depcol = I(1);
            end
         elseif length(depcol) == 1
            if strcmp(s2.datatype{depcol},'s')
               depcol = [];
            end
         else
            depcol = [];
         end

         if ~isempty(depcol)

            if exist('datacols','var') ~= 1
               datacols = [];
            elseif ~isnumeric(datacols)
               datacols = name2col(s2,datacols);
            end

            %remove depth column from data columns list if present
            if isempty(datacols)
               datacols = setdiff([1:length(s2.name)],[agcols(:)',depcol]);
            end

            %get array metrics
            numrows = length(s2.values{1});
            numcols = length(agcols)+2;
            numdata = length(datacols);

            %initialize new columns for totals/last vals
            newdata = cell(1,numcols+(numdata).*2);
            newflags = repmat({''},1,numcols+(numdata).*2);
            newnames = newdata;
            newprec = zeros(1,length(newnames));
            newtypes = newdata;
            newvartypes = newdata;
            newnumtypes = newdata;
            newunits = newdata;
            newdesc = newdata;
            newcrit = newdata;

            %process each aggregation group
            if numcols > 1
               for n = 1:length(agcols)
                  pos = agcols(n);
                  x = s2.values{pos};
                  flags = s2.flags{pos};
                  newnames{n} = s.name{pos};
                  newdata{n} = x(I_breaks(1:length(I_breaks)-1));
                  if ~isempty(flags)
                     newflags{n} = flags(I_breaks(1:length(I_breaks)-1),:);
                  end
                  newprec(n) = s.precision(pos);
                  newtypes{n} = s.datatype{pos};
                  newvartypes{n} = s.variabletype{pos};
                  newnumtypes{n} = s.numbertype{pos};
                  newunits{n} = s.units{pos};
                  newdesc{n} = s.description{pos};
                  newcrit{n} = s.criteria{pos};
               end
            end

            %calculate # of groups
            numgps = length(I_breaks)-1;
            dep = extract(s2,depcol);
            I_dep = repmat(NaN,numgps,2);
            mindep_all = repmat(NaN,numgps,1);
            maxdep_all = mindep_all;

            %get min, max depth/pressure for each group
            for m = 1:numgps
               Igp = [I_breaks(m):I_breaks(m+1)-1];
               d = dep(Igp);
               d = d(~isnan(d));
               if ~isempty(d)
                  [mindep,Imin] = min(d);
                  [maxdep,Imax] = max(d);
                  mindep_all(m) = mindep;
                  maxdep_all(m) = maxdep;
                  I_dep(m,1) = Igp(Imin);
                  I_dep(m,2) = Igp(Imax);
               end
            end
            
            pos = length(agcols)+1;
            newnames{pos} = [s.name{depcol},'_Top'];
            newnames{pos+1} = [s.name{depcol},'_Bottom'];
            newdata{pos} = mindep_all;
            newdata{pos+1} = maxdep_all;
            newprec(pos:pos+1) = s.precision(depcol);
            newtypes(pos:pos+1) = s.datatype(depcol);
            newvartypes(pos:pos+1) = s.variabletype(depcol);
            newnumtypes(pos:pos+1) = s.numbertype(depcol);
            newunits(pos:pos+1) = s.units(depcol);
            newdesc{pos} = ['Minimum ',s.description{depcol}];
            newdesc{pos+1} = ['Maximum ',s.description{depcol}];
            newcrit(pos:pos+1) = s.criteria(depcol);

            %look up corresponding top/bottom values in data columns
            for n = 1:numdata
               
               %get runtime value arrays
               pos = length(agcols) + (n-1).*2 + 3;
               vals = s2.values{datacols(n)};
               flags = s2.flags{datacols(n)};
               
               %check for non-numeric data
               if strcmp(s2.datatype{datacols(n)},'s')
                  topvals = repmat({''},numgps,1);
               else
                  topvals = repmat(NaN,numgps,1);
               end
               
               %init value arrays
               botvals = topvals;
               
               %check for flags
               if isempty(flags)
                  topflags = '';
                  botflags = '';
	               for m = 1:numgps
   	               if ~isnan(I_dep(m,1))
      	               topvals(m) = vals(I_dep(m,1));
         	         end
            	      if ~isnan(I_dep(m,2))
               	      botvals(m) = vals(I_dep(m,2));
                  	end
                  end
               else  %process data and flags
                  wid = size(flags,2);
                  topflags = repmat(' ',numgps,wid);
                  botflags = topflags;
	               for m = 1:numgps
   	               if ~isnan(I_dep(m,1))
                        topvals(m) = vals(I_dep(m,1));
                        topflags(m,1:wid) = flags(I_dep(m,1),1:wid);
         	         end
            	      if ~isnan(I_dep(m,2))
                        botvals(m) = vals(I_dep(m,2));
                        botflags(m,1:wid) = flags(I_dep(m,2),1:wid);
                     end
                  end
                  %check for all empty flags
                  if length(find(topflags(:,1)==' ')) == size(topflags,1)
                     topflags = '';
                  end
                  if length(find(botflags(:,1)==' ')) == size(botflags,1)
                     botflags = '';
                  end
               end
               
               %generate attribute metadata for derived columns
               newnames{pos} = [s.name{datacols(n)},'_Top'];
               newnames{pos+1} = [s.name{datacols(n)},'_Bottom'];
               newdata{pos} = topvals;
               newdata{pos+1} = botvals;
               newflags{pos} = topflags;
               newflags{pos+1} = botflags;
               newprec(pos:pos+1) = repmat(s.precision(datacols(n)),1,2);
               newtypes(pos:pos+1) = repmat(s.datatype(datacols(n)),1,2);
               newvartypes(pos:pos+1) = repmat(s.variabletype(datacols(n)),1,2);
               newnumtypes(pos:pos+1) = repmat(s.numbertype(datacols(n)),1,2);
               newunits(pos:pos+1) = repmat(s.units(datacols(n)),1,2);
               newdesc{pos} = [s.description{datacols(n)},' at top ',s.name{depcol},' value'];
               newdesc{pos+1} = [s.description{datacols(n)},' at bottom ',s.name{depcol},' value'];
               newcrit(pos:pos+1) = repmat(s.criteria(datacols(n)),1,2);
               
            end

            %generate history string
            curdate = datestr(now);
            if ~isempty(agcols)
               agstr = [' after aggregation by column(s) ',cell2commas(s.name(agcols),1)];
            else
               agstr = '';
            end
            str = ['Top and bottom records for data column(s) ',cell2commas(s.name(datacols),1), ...
                  ' determined based on values in column ',s.name{depcol},agstr];
            
            %update output structure
            s2.title = [str,': ',s.title];
            s2.createdate = curdate;
            s2.editdate = '';
            s2.history = [s.history ; {curdate},{[str,' (''aggr_topbottom'')']}];
            s2.name = newnames;
            s2.units = newunits;
            s2.description = newdesc;
            s2.datatype = newtypes;
            s2.variabletype = newvartypes;
            s2.numbertype = newnumtypes;
            s2.precision = newprec;
            s2.values = newdata;
            s2.criteria = newcrit;
            s2.flags = newflags;

            %check for validation errors
            if gce_valid(s2,'data') ~= 1
               s2 = [];
               msg = 'an error occurred during processing and resultant structure failed validation';
            end

         else
            msg = 'no valid depth or pressure column could be identified';
         end

      else
         msg = 'the structure could not be aggregated by the specified columns';
      end

   else
      msg = 'input data structure is not valid';
   end

else
   msg = 'insufficient arguments for function';
end