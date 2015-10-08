clc
clear
load space

if gce_valid(data)
    
    s = data;
    
    if ~isempty(s)
        col = name2col(s,'PRECIP_INST_455_0_01');
        %Diffs_455 = cell2mat(Diffs_455);
        A = cell2mat(Diffs_455);
        if ~isempty(col)
            % add new column for corrected precip diffs
            [s,msg] = addcol( ...
                s, ...                                                  % original data structure (required)
                A, ...                                                  % an array of calculated values (required)
                'PRECIP_DIFF_455_0_01', ...                             % the name of the new column (required)
                'mm', ...                                               % the units string for the new column (required)
                'Automatically corrected total precipitation', ...      % the description for the new column (optional - default = name)
                'f', ...                                                % the data type of the new column (optional - default = 'f' or 's')
                'data', ...                                             % the variable type of the new column (optional - default = 'calculation')
                'continuous', ...                                       % the numerical type of the new column (optional)
                2, ...                                                  % the number of decimal places to use for text output
                '', ...                                                 % the flagging criteria for the new column (optional - default = '')
                col+1 ...                                               % the column position (1 = beginning, [] = last)
                );
        end
    end
    
    % update diff_flag column with flags created by sub-function
    col      = {'PRECIP_DIFF_455_0_01'};        %values to be flagged
%    s        = flags2cols(s,col);
%    col      = {'Flag_PRECIP_DIFF_455_0_01'};   %flag column to be updated
    Icols    = name2col(s,col);
    Irows    = [];
    flag     = Flag_Diffs_455;                  %cell array of flags
    flagdef  = '';
    
    if ~isempty(col)
        [s,msg] = addflags( ...
            s, ...              % data structure to update (struct, required)
            Icols, ...          %Icols = array of column names or numeric indicies to update (numeric or cell array of strings, required)
            Irows, ...          %Irows = array of row numbers to update (numeric array, required, [] = all)
            flag ...            %flag = flag character or array of flags matching Irows to assign (character or cell array, required)
            );
    end
end

