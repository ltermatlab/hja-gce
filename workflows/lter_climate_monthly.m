function [s_monthly,msg] = lter_climate_monthly(s_daily,min_year,max_year,fn_export,missingchar)
%Workflow that generates integrated monthly LTER climate description datasets from integrated daily data
%using the GCE Data Toolbox for MATLAB (https://gce-svn.marsci.uga.edu/trac/GCE_Toolbox)
%
%syntax: [s_monthly,msg] = lter_climate_monthly(s_daily,min_year,max_year,fn_export,missingchar)
%
%input:
%   s_daily = integrated daily LTER climate data from lter_climate_daily.m
%   min_year = minimum year to include for monthly summary data sets (default = [] for earliest)
%   max_year = maximum year to include for monthly summary data sets (default = [] for latest)
%   fn_export = fully-qualified filename for exporting monthly data in CSV text format
%      (string; optional; default = '' for none)
%   missingchar = missing value character for text file output (string; optional; default = '')
%
%output:
%   s_monthly = GCE Data Structure containing monthly-aggregated data from all stations
%   msg = text of any error message
%
%by Wade Sheldon
%Georgia Coastal Ecosystems LTER
%University of Georgia
%Athens, GA 30602
%email: sheldon@uga.edu
%
%last updated: 27-Jun-2013

if nargin >= 1 && ~isempty(s_daily)
   
   %set default years if omitted
   if exist('min_year','var') ~= 1
      min_year = [];
   end
   if exist('max_year','var') ~= 1
      max_year = [];
   end
   
   %validate fn_export
   if exist('fn_export','var') ~= 1
      fn_export = '';
   end
   
   %validate missingchar
   if exist('missingchar','var') ~= 1
      missingchar = '';
   end
   
   %init monthly column list to extract (original name, final name, interpolate)
   cols_monthly = { ...
      'Site','Site',0; ...
      'Station','Station',0; ...
      'Year','Year',0; ...
      'Month','Month',0; ...
      'Monthly_Mean_Daily_AirTemp_AbsMax_C','Monthly_AirTemp_AbsMax_C',1; ...
      'Monthly_Mean_Daily_AirTemp_Mean_C','Monthly_AirTemp_Mean_C',0; ...
      'Monthly_Mean_Daily_AirTemp_AbsMin_C','Monthly_AirTemp_AbsMin_C',1; ...
      'Monthly_Total_Daily_Precip_Total_MM','Monthly_Precip_Total_MM',0 ...
      };
   
   %get list of data/calc columns to generating stats
   vtype = get_type(s_daily,'variabletype');
   datacols = find(strcmp('data',vtype) | strcmp('calculation',vtype));
   
   %generate q/c rules
   qcrules = {'missing','7','count','I'; ...
      'missing','0','count','Q'; ...
      'missing','5','consecutive','I'; ...
      'flagged','7','count','Q'};
   
   %generate monthly summary stats
   [s_monthly,msg] = aggr_datetime(s_daily, ...
      'month', ...                 %interval
      {'Year','Month'}, ...        %date part columns
      {'Site','Station'}, ...      %grouping columns
      datacols, ...                %date columns to aggregate
      0, ...                       %stat option (auto)
      0, ...                       %flag option (retain)
      qcrules ...                  %qc rule options
      );
   
   %lock flags
   s_monthly = flag_locks(s_monthly,'lock',datacols);
   
   %copy output columns
   s_monthly = copycols(s_monthly,cols_monthly(:,1));
   
   %get list of data/calc columns for locking flags
   vtype = get_type(s_monthly,'variabletype');
   datacols = find(strcmp('data',vtype) | strcmp('calculation',vtype));
   
   %null invalid values
   s_monthly = nullflags(s_monthly,'I',datacols);
   
   %rename columns as necessary
   for cnt = 1:size(cols_monthly,1)
      if ~strcmp(cols_monthly{cnt,1},cols_monthly{cnt,2})
         s_monthly = rename_column(s_monthly,cols_monthly{cnt,1},cols_monthly{cnt,2});
      end
   end
   
   %subset monthly data if required
   if ~isempty(min_year) || ~isempty(max_year)
      yr = extract(s_monthly,'Year');
      if isempty(min_year)
         min_year = min(yr);
      end
      if isempty(max_year)
         max_year = max(yr);
      end
      s_monthly = querydata(s_monthly,['Year >= ',int2str(min_year),' & Year <= ',int2str(max_year)]);
   end
   
   %export monthly file
   if ~isempty(s_monthly) && ~isempty(fn_export)
      [pn,fn_base,fn_ext] = fileparts(fn_export);
      msg = exp_ascii(s_monthly, ...
         'comma', ...        %format
         [fn_base,fn_ext], ...  %filename
         pn, ...           %path
         '', ...           %report title
         'T', ...          %header option (column titles only)
         'N', ...          %flag option (do not display)
         '', ...           %metadata style (none)
         '', ...           %row leader (none)
         'no', ...         %row numbers (no)
         missingchar);     %missing value character
   end
   
else
   msg = 'invalid daily data file';
end