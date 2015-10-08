function [stats,msg] = querystats(data,qry,flagopt,groupcol,cols)
%Calculates descriptive statistics for values in a GCE-LTER data structure
%after performing a query and selecting output columns
%
%syntax:  [stats,msg] = querystats(data,query,flagopt,groupcol,cols)
%
%inputs:
%   'data' is the data structure to analyze
%   'query' is a string containing one or more column criteria separated
%      by semicolons, formatted as follows:
%         col1>13;col2<20;col12~='unknown'
%   'flagopt' is a character specifying whether to include ('I') or exclude ('E')
%      flagged values from the statistical analysis (flagopt = 'E' if omitted, and
%      missing values are always excluded regardless of flagopt)
%   'groupcol' is a single column in the original data structure to sort and group
%      by before performing analyses
%   'cols' is an array of columns to include (columns may be reordered or replicated)
%
%outputs:
%   'stats' is a GCE-LTER stat structure containing the results of the analysis
%   'msg' is the text of any error messages
%
%
%(c)2002-2006 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 13-Mar-2002

stats = [];
msg = '';

if nargin >= 2

   if isstruct(data) & isstr(qry)

      if exist('cols','var') ~= 1
         cols = [];
      elseif isstr(cols)
         cols = [];
      end

      if exist('groupcol','var') ~= 1
         groupcol = [];
      elseif isstr(groupcol)
         groupcol = [];
      else
         groupcol = groupcol(1);
      end

      if exist('flagopt','var') ~= 1
         flagopt = 'E';
      end

      %run query
      [data,msg] = querydata(data,qry);

      if ~isempty(data)

         %apply column selection
         if ~isempty(cols)

            [data,msg] = copycols(data,cols,'Y');

         end

         %run stats
         if ~isempty(data)

            [stats,msg] = colstats(data,flagopt,groupcol);

         end

      end

   else

      msg = 'invalid data structure or query string';

   end

else

   msg = 'insufficient arguments';

end
