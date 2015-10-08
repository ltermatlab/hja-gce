%% Filename: reprocess_cenmet_225_ppt.m

load Z:\HJA\Portal_dev\CENMET\data\cenmet_225_5min_2015.mat;
%check for valid data structure from import filter
if gce_valid(data)
    if ~isempty(data)
        % Define constant variables
        col         = {'PRECIP_INST_455_0_01'};
        flag        = 'FLAG_PRECIP_INST_455_0_01';
        dt          = 'Date';
        
        % Convert to format for simple precip function
        data        = flags2cols(data,col);
        DateCol     = name2col(data,dt);
        GaugeCol    = name2col(data,col);
        FlagCol     = name2col(data,flag);
        clear col flag dt
        
        % Call simple precip function here
        
        % Save GCE as gce data structure
        
        % Export as csv
        
        
    end
end
%               GaugeCol = 10;
%               FlagCol = 10;
%               Station = 'CENMET';
%               Probe_Code = 'PPTCEN01';
%               Height = 455;
%               Method = 'PPT017';
%               dMethod = 'PPT117';
%               HighResOut = 'Z:\HJA\Portal_dev\CENMET\data\xxxxxxxx.csv';
%               fid1 = fopen(HighResOut, 'w');
              