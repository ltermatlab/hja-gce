if gce_valid(data)
    % load the gce data structure into the workspace and set your working
    % directory to the GCE toolbox functions
    % correct precipitation tank volume level
    
    % define the variable to correct
    col = name2col(data,{'PPT_SA_INST'});
    if ~isempty(col)
        ppt_2           = extract_rows(data,'PPT_SA_INST');
        
        % correction function call goes here
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % add calculated precipitation column to data structure
        [data,msg] = addcol( ...
            data, ...                                        % original data structure (required)
            ppt_2, ...                                       % an array of calculated values (required)
            'PPT_SA_INST_CORR', ...                          % the name of the new column (required)
            'mm', ...                                    % the units string for the new column (required)
            'corrected instaneous precipitation', ...     % the description for the new column (optional - default = name)
            'f', ...                                         % the data type of the new column (optional - default = 'f' or 's')
            'calculation', ...                                      % the variable type of the new column (optional - default = 'calculation')
            'continuous', ...                                 % the numerical type of the new column (optional)
            2, ...                                           % the number of decimal places to use for text output
            '', ...                                          % the flagging criteria for the new column (optional - default = '')
            [] ...                                          % the column position (1 = beginning, [] = last)
            );
        
    end
end
