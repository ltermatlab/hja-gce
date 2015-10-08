%% Generally useful functions for manually processing snow data.

col = name2col(data,'VARA_SWE');
                if ~isempty(col)
                    md = running_median(extract(data,'VARA_SWE'),12,1,'back');
                    
                    % add new column for running median snow depth
                    [data,msg] = addcol( ...
                        data, ...                                           % original data structure (required)
                        md, ...                                             % an array of calculated values (required)
                        'VARA_SWE_HRLY_MED', ...                            % the name of the new column (required)
                        'm', ...                                            % the units string for the new column (required)
                        '12 point running median of SWE', ...       % the description for the new column (optional - default = name)
                        'f', ...                                            % the data type of the new column (optional - default = 'f' or 's')
                        'data', ...                                         % the variable type of the new column (optional - default = 'calculation')
                        'continuous', ...                                   % the numerical type of the new column (optional)
                        2, ...                                              % the number of decimal places to use for text output
                        '', ...                                             % the flagging criteria for the new column (optional - default = '')
                        col+1 ...                                           % the column position (1 = beginning, [] = last)
                        );
                end

if ~isempty(data)
    %master list of columns to interpolate
    interpcols = {'VARA_SWE','CENMET_SWE'};
    
    %check for columns in active data structure, case-insensitively,
    %constraining to floating-point data columns
    cols = name2col(data,interpcols,0,'f','data');
    
    %interpolate any matched columns
    if ~isempty(cols)
        [data,msg] = interp_missing(data, ...
            'Date', ...
            cols,...
            'linear', ...
            5, ...
            inf ...
            );
    end
end

if ~isempty(data)
    
    %check new records for duplicate records
    [data,msg] = cleardupes( ...
        data, ...                   %data structure
        {'Date'}, ...               %{data.name{2}}, ...        %date column
        'verbose' ...               %logging option
        );
end

if ~isempty(data)
    %document anomalies (missing values and flags from QA/QC rules)
    [data,msg] = add_anomalies( ...
        data, ...   %data structure to update
        23, ...     %date format (see 'help datestr')
        '-', ...    %date range separator
        1, ...      %option to document missing values
        [] ...      %column selection ([] = all)
        );
end

if ~isempty(data)
    [data,msg] = pad_date_gaps( ...
        data, ...  %data structure to update
        [], ...    %date column ([] = auto)
        1, ...     %remove duplicates option (1 = yes)
        1 ...      %replicate non-data values option (1 = yes)
        );
end

if ~isempty(data)
    col = name2col(data,'SNODEP');
    %convert SNODEP absolute to difference per measurement
    if ~isempty(col)
        [data,msg] = add_calcexpr(data, ...
            '[NaN ; diff(SNODEP)]', ...                 %calculate difference between current and preceeding measurement
            'SNODEP_DIFF', ...                          %new column name
            'mm', ...                                   %new column units
            'Difference in SNODEP', ...                 %description
            col+1, ...                                  %position
            0, ...                                      %replicate scalar values (no)
            '', ...                                     %Q/C flag criteria for the new column
            'calculation');                             %variable type of the new column
    end
end

if ~isempty(data)
    col = name2col(data,'SWE');
    %convert SWE absolute to difference per measurement
    if ~isempty(col)
        [data,msg] = add_calcexpr(data, ...
            '[NaN ; diff(SWE)]', ...                    %calculate difference between current and preceeding measurement
            'SWE_DIFF', ...                             %new column name
            'mm', ...                                   %new column units
            'Difference in SWE', ...                    %description
            col+1, ...                                  %position
            0, ...                                      %replicate scalar values (no)
            'x>200=''Q''', ...                          %Q/C flag criteria for the new column
            'calculation');                             %variable type of the new column
    end
end

if ~isempty(data)
    %check new records for duplicate records
    [data,msg] = nullflags( ...
        data, ...                       %data
        'I', ...                      %flagchars
        [], ...                         %cols
        1, ...                          %metaopt
        0, ...                          %clearflags
        '', ...                         %newflag
        0 ...                           %logsize
        );
end

if ~isempty(data)
    col = name2col(data,{'SWE'});
    if ~isempty(col)
        [data,msg] = num_replace(data, ...
            {'SWE'}, ...                     %columns to update
            'SWE < 10', ...                  %criteria to match
            0, ...                                 %new value to assign
            1, ...                                 %change log option
            '' ...                                 %flag to assign for revised values ('' for none)
            );
    end
end

if ~isempty(data)
    col = name2col(data,{'SNODEP'});
    if ~isempty(col)
        [data,msg] = num_replace(data, ...
            {'SNODEP'}, ...                     %columns to update
            'SNODEP < 10', ...                  %criteria to match
            0, ...                                 %new value to assign
            1, ...                                 %change log option
            '' ...                                 %flag to assign for revised values ('' for none)
            );
    end
end

%manual zeroing during no snow periods
% col_Date>=datenum('1/1/2013 10:30:00')&col_Date<=datenum('4/18/2013 14:00:00')='I'
%range = 'Date < datenum(''10/1/2014 12:00:00'')&Date <datenum(''10/1/2015 12:00:00'')'; 
%range = 'Date < datenum(''10/1/2014 12:00:00'')'; 
%% WY2015
%Vanmet
% Begin Snow
if ~isempty(data)
    col = name2col(data,{'SNODEP_INST_0_0_01','SWE_INST_0_0_01','Date'});
    if ~isempty(col)
        [data,msg] = num_replace(data, ...
            {'SNODEP_INST_0_0_01','SWE_INST_0_0_01'}, ...                     %columns to update
            'Date < datenum(''11/12/2014 12:00:00'')', ...                  %criteria to match
            0, ...                                 %new value to assign
            1, ...                                 %change log option
            '' ...                                 %flag to assign for revised values ('' for none)
            );
    end
end
% End Snow
if ~isempty(data)
    col = name2col(data,{'SNODEP_INST_0_0_01','SWE_INST_0_0_01','SWE_MEAN_0_0_05','Date'});
    if ~isempty(col)
        [data,msg] = num_replace(data, ...
            {'SNODEP_INST_0_0_01','SWE_INST_0_0_01'}, ...                     %columns to update
            'Date > datenum(''5/7/2015 12:00:00'')', ...                  %criteria to match
            0, ...                                 %new value to assign
            1, ...                                 %change log option
            '' ...                                 %flag to assign for revised values ('' for none)
            );
    end
end

%Varmet
% Begin Snow
if ~isempty(data)
    col = name2col(data,{'SNODEP_INST_0_0_05','SWE_INST_0_0_05','Date'});
    if ~isempty(col)
        [data,msg] = num_replace(data, ...
            {'SNODEP_INST_0_0_05','SWE_INST_0_0_05'}, ...                     %columns to update
            'Date < datenum(''11/12/2014 12:00:00'')', ...                  %criteria to match
            0, ...                                 %new value to assign
            1, ...                                 %change log option
            '' ...                                 %flag to assign for revised values ('' for none)
            );
    end
end
% End Snow
if ~isempty(data)
    col = name2col(data,{'SNODEP_INST_0_0_05','SWE_INST_0_0_05','Date'});
    if ~isempty(col)
        [data,msg] = num_replace(data, ...
            {'SNODEP_INST_0_0_05','SWE_INST_0_0_05'}, ...                     %columns to update
            'Date > datenum(''5/11/2015 12:00:00'')', ...                  %criteria to match
            0, ...                                 %new value to assign
            1, ...                                 %change log option
            '' ...                                 %flag to assign for revised values ('' for none)
            );
    end
end

%Cenmet
% Begin Snow
if ~isempty(data)
    col = name2col(data,{'SNODEP_INST_0_0_01','SWE_INST_0_0_01','SWE_MEAN_0_0_05','Date'});
    if ~isempty(col)
        [data,msg] = num_replace(data, ...
            {'SNODEP_INST_0_0_01','SWE_INST_0_0_01'}, ...                     %columns to update
            'Date < datenum(''11/12/2014 12:00:00'')', ...                  %criteria to match
            0, ...                                 %new value to assign
            1, ...                                 %change log option
            '' ...                                 %flag to assign for revised values ('' for none)
            );
    end
end
% End Snow
if ~isempty(data)
    col = name2col(data,{'SNODEP_INST_0_0_01','SWE_INST_0_0_01','SWE_MEAN_0_0_05','Date'});
    if ~isempty(col)
        [data,msg] = num_replace(data, ...
            {'SNODEP_INST_0_0_01','SWE_INST_0_0_01'}, ...                     %columns to update
            'Date > datenum(''4/18/2015 12:00:00'')', ...                  %criteria to match
            0, ...                                 %new value to assign
            1, ...                                 %change log option
            '' ...                                 %flag to assign for revised values ('' for none)
            );
    end
end

%Uplmet
% Begin Snow
if ~isempty(data)
    col = name2col(data,{'SNODEP_INST_0_0_01','SWE_INST_0_0_01','SWE_MEAN_0_0_05','SWE_INST','SNODEP_INST','Date'});
    if ~isempty(col)
        [data,msg] = num_replace(data, ...
            {'SNODEP_INST','SWE_INST'}, ...                     %columns to update
            'Date < datenum(''10/26/2014 12:00:00'')', ...                  %criteria to match
            0, ...                                 %new value to assign
            1, ...                                 %change log option
            '' ...                                 %flag to assign for revised values ('' for none)
            );
    end
end
% End Snow
if ~isempty(data)
    col = name2col(data,{'SNODEP_INST_0_0_01','SWE_INST_0_0_01','SWE_MEAN_0_0_05','SWE_INST','Date'});
    if ~isempty(col)
        [data,msg] = num_replace(data, ...
            {'SNODEP_INST','SWE_INST'}, ...                     %columns to update
            'Date > datenum(''5/13/2015 12:00:00'')', ...                  %criteria to match
            0, ...                                 %new value to assign
            1, ...                                 %change log option
            '' ...                                 %flag to assign for revised values ('' for none)
            );
    end
end

%% Create statistical summaries
% calculate hourly median values for snow depth and swe variables

if ~isempty(data)
    s = data;
    interval = 'hour';
    dtcols = [];
    aggrcols = [];
    statcols = [];
    statopt = 3;
    flagopt = 0;
    qcrules = [];
    missing_anom = 1;
    
    [s2,msg] = aggr_datetime(s,interval,dtcols,aggrcols,statcols,statopt,flagopt,qcrules,missing_anom);
end

%% Compute differences on timeseries data
if ~isempty(data)
    col = name2col(data,'Asp150_Avg');
    %convert SWE absolute to difference per measurement
    if ~isempty(col)
        [data,msg] = add_calcexpr(data, ...
            '[NaN ; diff(Asp150_Avg)]', ...                    %calculate difference between current and preceeding measurement
            'Asp150_Avg_DIFF', ...                             %new column name
            'mm', ...                                   %new column units
            'Difference in Asp150_Avg', ...                    %description
            col+1, ...                                  %position
            0, ...                                      %replicate scalar values (no)
            'x>5=''Q''', ...                          %Q/C flag criteria for the new column
            'calculation');                             %variable type of the new column
    end
end


            
            