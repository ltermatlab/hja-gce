function [s2,msg] = calc_yearday_stats(s,datecol,cols,flagopt,qcrules)
%Summarizes variables in a time series data set by year day (1-365) for plotting or use in date-based limit checks
%
%syntax: [s2,msg] = calc_yearday_stats(s,datecol,cols,flagopt,qcrules)
%
%input:
%   s = GCE Data Structure to summarize
%   datecol = name or index of a serial date column ([] to determine automatically)
%   cols = names or indices of data columns to summarize (default = all data/calculation columns)
%   flagopt = option for clearing QA/QC flagged values prior to aggregation
%      0 = retain flagged values (default)
%      1 = remove all flagged values (convert to NaN/'')
%      character array = selectively remove only values assigned any flag in the array
%   qcrules = 4-column cell array defining Q/C rules to add to the output structure to flag statistics
%      based on precence of missing and/or flagged values in each aggregate, as follows:
%         col 1: type of criteria ('flagged' or 'missing')
%         col 2: numerical criteria (character array containing a number >= 0)
%         col 3: units of criteria ('percent','count')
%         col 4: flag to assign (single character)
%      example:
%         {'flagged','0','count','Q'; 'missing','10','percent','Q'} --> 
%            rules: col_Flagged_[colname]>0='Q';col_Percent_Missing_[colname]>10='Q'     
%
%output:
%   s2 = summary data structure with column YearDay and relevant statistics for data columns
%   msg = text of any error or warning message
%
%
%(c)2011 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 17-Oct-2011

%init output
s2 = [];

if nargin >= 1 && gce_valid(s,'data') == 1
   
   %supply defaults to omitted arguments
   if exist('datecol','var') ~= 1
      datecol = [];  %use empty array to force auto-designation
   end
   
   if exist('cols','var') ~= 1
      cols = listdatacols(s);  %get index of data/calc columns
   end
   
   if exist('flagopt','var') ~= 1
      flagopt = 'IQ';  %default to null values flagged as 'I' or 'Q'
   end
   
   if exist('qcrules','var') ~= 1
      qcrules = [];  %default to no automatic q/c rules
   end
   
   %add YearDay column
   [s,msg] = add_yeardaycol(s,'floor',datecol);
      
   %check for errors nulling flags or adding YearDay column
   if ~isempty(s)
      [s2,msg] = aggr_stats(s,'YearDay',cols,0,flagopt,qcrules);
   end
      
else
   msg = 'invalid data structure';   
end