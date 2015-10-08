function [s2,msg] = aggr_sums(s,agcols,statcols,statopt,flagopt)
%Sorts and aggregates data in a GCE-LTER data structure by one or more columns,
%then optionally calculates sums within each group for the specified columns and generates
%a new data structure containing the results. Note that any columns in 'statcols'
%that are also listed in 'agcols' will be ignored.
%
%syntax:  [s2,msg] = aggr_sums(s,aggrcols,statcols,statopt,flagopt)
%
%inputs:
%   s = original data structure
%   aggrcols = an ordered array of columns to sort and aggregate by
%   statcols = an ordered array of columns to calculate sums for
%   statopt = an array of integers specifying the statistics to calculate
%      for each column in 'statcols':
%        -1 = do not sum (only first non-NaN value in group will be retained)
%        0 = do not sum (only last non-NaN value in group will be retained) - default
%        1 = sum values in each group
%      (Notes: scalar values will be replicated to match the length of 'statcols',
%       and options = 1 on string columns will be overridden with 0).
%   flagopt = option for clearing QA/QC flagged values prior to aggregation
%        0 = retain flagged values (default)
%        1 = remove flagged values using 'nullflags' (i.e. convert to NaN/'')
%
%outputs:
%   s2 = summarized data structure
%   msg = text of any error messages
%
%(note: column properties and metadata are copied or created as appropriate)
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
%last modified: 24-Apr-2013

s2 = [];
msg = '';

if nargin >= 3

   if gce_valid(s,'data')

      if ~isempty(agcols) & ~isempty(statcols)

         %add default flagopt if omitted
         if exist('flagopt','var') ~= 1
            flagopt = 0;
         elseif flagopt ~= 1
            flagopt = 0;
         end

         %validate stat options, apply defaults
         if exist('statopt','var') ~= 1
            statopt = zeros(1,length(statcols));
         elseif isempty(statopt)
            statopt = zeros(1,length(statcols));
         elseif isstr(statopt) | iscell(statopt)
            statopt = zeros(1,length(statcols));
         elseif length(statopt) == 1
            statopt = repmat(statopt,1,length(statcols));
         elseif length(statopt) < length(statcols)
            statopt = repmat(statopt,1,ceil(length(statcols)./length(statopt)));
         end

         %replace column names with column numbers
         if iscell(agcols) | isstr(agcols)
            agcols = name2col(s,agcols);
         end
         if iscell(statcols) | isstr(statcols)
            statcols = name2col(s,statcols);
         end

         %validate columns (ensure in-range columns, and no overlap)
         I = find(agcols > 0 & agcols <= length(s.values));
         if ~isempty(I)
            agcols = agcols(I);
         end

         I = find(statcols > 0 & statcols <= length(s.values));
         if ~isempty(I)
            statcols = statcols(I);
         end

         [teststat,testag] = meshgrid(statcols,agcols');
         I = find(sum(teststat~=testag)==length(agcols));
         if ~isempty(I)
            statcols = statcols(I);
         end

         %presort by aggregate columns, return only needed columns and metadata
         s = sortdata(s,agcols,1,1);

         if ~isempty(s) & flagopt == 1
            s = nullflags(s);
         end

         if ~isempty(s)

            types = s.datatype;
            vals = s.values;
            flags = s.flags;
            numrows = length(vals{1});
            numcols = length(agcols);
            numstats = length(statcols);

            %produce all-numerical comparison matrix
            compmat = ones(numrows,numcols);
            for n = 1:length(agcols)
               x = vals{agcols(n)};
               if strcmp(types{agcols(n)},'s')  %substitute unique integers for strings
                  Igp = [find([0;strcmp(x(1:length(x)-1),x(2:length(x)))]==0) ; numrows+1];
                  for m = 1:length(Igp)-1
                     compmat(Igp(m):Igp(m+1)-1,n) = m;
                  end
               else
                  compmat(:,n) = x;
               end
            end

            %calculate master grouping index by comparing row-to-row diffs and padding array
            if numcols == 1
               I_breaks = [1 ; find([0 ; (abs(compmat(1:numrows-1,:)-compmat(2:numrows,:))')']) ; ...
                     numrows+1];
            else
               I_breaks = [1 ; find([0 ; sum(abs(compmat(1:numrows-1,:)-compmat(2:numrows,:))')']) ; ...
                     numrows+1];
            end

            if length(I_breaks) < numrows  %check for unique grouping index - no aggregation possible

               %initialize new columns for totals/last vals
               newdata = cell(1,numcols+numstats);
               newnames = newdata;
               newprec = zeros(1,length(newnames));
               newtypes = newdata;
               newvartypes = newdata;
               newnumtypes = newdata;
               newunits = newdata;
               newdesc = newdata;
               newcrit = newdata;
               newflags = newdata;

               %process each aggregation group
               for n = 1:numcols
                  pos = agcols(n);
                  x = vals{pos};
                  newnames{n} = s.name{pos};
                  newdata{n} = x(I_breaks(1:length(I_breaks)-1));
                  newprec(n) = s.precision(pos);
                  newtypes{n} = types{pos};
                  newvartypes{n} = s.variabletype{pos};
                  newnumtypes{n} = s.numbertype{pos};
                  newunits{n} = s.units{pos};
                  newdesc{n} = s.description{pos};
                  newcrit{n} = s.criteria{pos};
                  newflags{n} = s.flags{pos};
               end

               %calculate # of groups
               numgps = [I_breaks(2:length(I_breaks))-I_breaks(1:length(I_breaks)-1)];

               %process each stat group
               for n = 1:numstats

                  %initialize arrays
                  tot = ones(length(numgps),1) .* NaN;
                  val = tot;

                  %declare constants
                  pos = statcols(n);
                  coltype = lower(types{pos});
                  vartype = lower(s.variabletype{pos});
                  numtype = lower(s.numbertype{pos});
                  prec = s.precision(pos);
                  x = s.values{pos};  %get column data

                  if statopt(n) == 1  %override sum option for unsupported types
                     if strcmp(coltype,'s')
                        statopt(n) = 0;
                     elseif ~strcmp(vartype,'data') & ~strcmp(vartype,'calculation')
                        statopt(n) = 0;
                     elseif strcmp(numtype,'angular')
                        statopt(n) = 0;
                     end
                  end

                  if statopt(n) == 1

                     for m = 1:length(I_breaks)-1
                        I = [I_breaks(m):I_breaks(m+1)-1]';
                        v = x(I);
                        v = v(find(~isnan(v)));
                        if ~isempty(v)
                           tot(m) = sum(v);  %total non-empty values
                        end
                     end

                     newdata{numcols+n} = tot;
                     newdesc{numcols+n} = [s.description{pos},' (totalled within aggregates of ', ...
                           cell2commas(s.name(agcols),1),')'];  %amend description

                  else  %copy first/last val

                     for m = 1:length(I_breaks)-1
                        I = [I_breaks(m):I_breaks(m+1)-1]';
                        v = x(I);
                        if isnumeric(v)
                           Ivalid = find(~isnan(v));
                        else
                           Ivalid = find(~cellfun('isempty',v));
                        end
                        if isempty(Ivalid)
                           Ivalid = 1;  %catch all empty arrays
                        end
                        if statopt(n) == -1
                           val(m) = v(Ivalid(1));  %grab first valid value/string
                        else
                           val(m) = v(Ivalid(end));  %grab last valid value/string
                        end
                     end

                     newdata{numcols+n} = val;
                     newdesc{numcols+n} = s.description{pos};  %just copy description

                  end

                  %copy remaining descriptors
                  newnames{numcols+n} = s.name{pos};
                  newprec(numcols+n) = s.precision(pos);
                  newtypes{numcols+n} = types{pos};
                  newvartypes{numcols+n} = s.variabletype{pos};
                  newnumtypes{numcols+n} = s.numbertype{pos};
                  newunits{numcols+n} = s.units{pos};
                  newcrit{numcols+n} = s.criteria{pos};
                  newflags{numcols+n} = s.flags{pos};

               end

               %generate history strings
               aglist = s.name{agcols(1)};
               for n = 2:length(agcols)
                  aglist = [aglist ', ' s.name{agcols(n)}];
               end
               if length(agcols) > 1
                  agstr = ['sorted, aggregated on columns ' aglist];
               else
                  agstr = ['sorted, aggregated on column ' aglist];
               end

               I = find(statopt==1);
               statstr = '';
               if length(I) > 1
                  statstr = ['; totalled values in each aggregate for columns ',cell2commas(s.name(statcols(I)),1)];
               elseif length(I) == 1
                  statstr = ['; totalled values in each aggregate for column ',s.name{statcols(I)}];
               end

               %use original (modified) data as a template
               s2 = s;

               %put new values into return structure, update headers and history
               curdate = datestr(now);
               s2.title = ['Statistical analysis of data aggregated by ' aglist ': ' s.title];
               s2.createdate = curdate;
               s2.editdate = '';
               s2.history = [s.history ; {curdate},{[agstr,statstr,' (''aggr_sums'')']}];
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

               if ~cellfun('isempty',newcrit);
                  s2 = dataflag(s2);
               end

            else

               msg = 'invalid grouping columns - no repeating values to aggregate over';

            end

         else

            msg = 'invalid GCE data structure';

         end

      else

         msg = 'unspecified aggregation and/or statistics column selections';

      end

   else

      msg = 'invalid GCE data structure';

   end

else

   msg = 'insufficient arguments for function';

end
