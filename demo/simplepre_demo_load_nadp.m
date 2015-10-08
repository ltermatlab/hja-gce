clc
clear
load nadp

%check for valid data structure from import filter
if gce_valid(data)
    
    % run the simiplepre.m post processor
    % Define constant variable col
    % This will define both the value and flag
    %Use station CENMET for every 5min station, use CS2MET for every 15 minute station
    Station     = 'CS2MET';
    col         = {'ActDepth'};
    dt          = 'Date';
    
    % Convert to format for simple precip function
    %data        = flags2cols(data,flag_col);
    if ~isempty(col)
        DateCol     = name2col(data,dt);
        GaugeCol    = name2col(data,col);
        FlagCol     = name2col(data,col);
        clear dt
        
        Results = simplepre(GaugeCol, FlagCol, Station, data);
        
        Diffs_NADP       = cell2mat(Results(:,7));
        Flag_Diffs_NADP  = Results(:,8);
        
        col = name2col(data,'ActDepth');
        if ~isempty(col)
            % add new column for corrected precip diffs
            [data,msg] = addcol( ...
                data, ...                                        % original data structure (required)
                Diffs_NADP, ...                                       % an array of calculated values (required)
                'PRECIP_NADP_DIFF', ...                       % the name of the new column (required)
                'mm', ...                                    % the units string for the new column (required)
                'Automatically corrected total precipitation', ...     % the description for the new column (optional - default = name)
                'f', ...                                         % the data type of the new column (optional - default = 'f' or 's')
                'data', ...                                      % the variable type of the new column (optional - default = 'calculation')
                'continuous', ...                                 % the numerical type of the new column (optional)
                2, ...                                           % the number of decimal places to use for text output
                '', ...                                          % the flagging criteria for the new column (optional - default = '')
                col+1 ...                                          % the column position (1 = beginning, [] = last)
                );
        end
    end
    clearvars Station col dt Results DateCol GaugeCol FlagCol Diffs_NADP Flag_Diffs_NADP msg
    
    save E:\temp\NADP\data\data.m
    
end
        