function msg = gap_fill_report(dt_fill,fn,colname,fmt,interval,dateformat,appendopt)
%Generates or appends to a text report of dates gap-filled by pad_date_gaps.m
%
%syntax:  msg = gap_fill_report(dt_fill,fn,colname,fmt,interval,dateformat,appendopt)
%
%input:
%  dt_fill = array of MATLAB serial dates from pad_date_gaps.m (numeric array; required)
%  fn = fully-qualified filename for report (string; required)
%  colname = base name for filled value count field (string; optional; default = 'Filled')
%  fmt = text file format (string; optional; default = 'csv')
%    'csv' = comma-separated value with quoted column names (default)
%    'tab' = tab-delimited
%    'comma' = comma-delimited without quoted column names
%  interval = interval for summarizing filled values (string; optional; default = 'day')
%    'none' = do not summarize
%    'day' = summarize by day (default)
%    'month' = summarize by month
%  dateformat = format for Date column (integer or string for datestr(); optional; default = 'mm/dd/yyyy')
%  appendopt = option to append to existing report, if present (integer; optional; default = 1):
%     0 = do not append
%     1 = append (default)
%
%output:
%  msg = text of any error message
%
%
%(c)2015 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 23-Mar-2014

if nargin >= 2
   
   if ~isempty(dt_fill)
      
      %validate colname
      if exist('colname','var') ~= 1 || isempty(colname)
         colname = 'Filled';
      end
      
      %validate format
      if exist('fmt','var') ~= 1 || sum(inlist(fmt,{'csv','tab','comma'})) == 0
         fmt = 'csv';
      end
      
      %validate interval
      if exist('interval','var') ~= 1 || sum(inlist(interval,{'day','month','none'})) == 0
         interval = 'day';
      end
      
      %validate date format
      if exist('dateformat','var') ~= 1
         dateformat = 'mm/dd/yyyy';
      end
   
      %create temp structure of dates
      s_filled = newstruct('data');
      
      %add title
      s_filled = newtitle(s_filled,['Date gap filling on ',datestr(now,1)]);
      
      %add dates
      s_filled = addcol(s_filled,dt_fill,'Date','MATLAB serial date','Date values filled','f','datetime','continuous',7);
      
      %add dummy count column for aggregation
      s_filled = addcol(s_filled,ones(length(dt_fill),1),colname,'none','Filled missing time flag','d','data','discrete',0);
      
      %summarize
      switch interval
         
         case 'day'
            
            %aggregate
            s_summary = aggr_datetime(s_filled,'day','Date','','Filled',1);
            
            %format dates and omit Year, Month, Day columns
            s_summary = convert_date_format(copycols(s_summary,{'Date',['Daily_Num_',colname]}),'Date',dateformat);
            
         case 'month'
            
            %aggregate
            s_summary = aggr_datetime(s_filled,'month','Date','','Filled',1);
            
            %format dates and omit Year, Month, Day columns
            s_summary = convert_date_format(copycols(s_summary,{'Date',['Monthly_Num_',colname]}),'Date',dateformat);
            
         otherwise  %no aggregation
            
            %format dates and omit Year, Month, Day columns
            s_summary = convert_date_format(s_filled,'Date',dateformat);
            
      end
      
   else
      s_summary = [];
   end
   
   %write gap filling report to a file
   if ~isempty(s_summary)
      
      %validate appendopt
      if exist('appendopt','var') ~= 1 || ~isnumeric(appendopt) || appendopt ~= 0
         appendopt = 1;
      end        
      
      %generate format info for exp_ascii
      switch fmt
         case 'comma'
            fmt2 = 'del';
            del = ',';
         case 'tab'
            fmt2 = 'tab';
            del = char(9);
         otherwise
            fmt2 = 'csv';
            del = ',';
      end
      
      %generate file parts for exp_ascii.m
      [pn,fn_base,fn_ext] = fileparts(fn);
      fn2 = [fn_base,fn_ext];
      
      %create or append to file
      if exist(fn,'file') == 2 && appendopt == 1
         msg = exp_ascii(s_summary',fmt2,fn2,pn,'','N','N','','','N','NaN',del,'N','T');
      else
         msg = exp_ascii(s_summary',fmt2,fn2,pn,'','T','N','','','N','NaN',del,'N','N');
      end
      
   else
      msg = 'no filled values';      
   end
   
else
   msg = 'insufficient arguments';
end