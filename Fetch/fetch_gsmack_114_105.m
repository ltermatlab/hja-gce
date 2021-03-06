function [data,msg] = fetch_gsmack_114_105(template)

%connect to the database
conn = database('metdat', '', '', 'Vendor', 'MICROSOFT SQL SERVER', 'Server', 'Stewartia', 'PortNumber', 1433, 'AuthType', 'Windows');

if exist('template','var') ~= 1
   template = '';
end

qry = ['SELECT 	MACK_114_Table105.TmStamp'...
    ' ,	MACK_114_Table105.RecNum'...
    ' ,	MACK_114_Table105.LoggerID'...
    ' ,	MACK_114_Table105.ProgID'...
    ' ,	MACK_114_Table105.STAGE'...
    ' ,	MACK_114_Table105.FISHSTAGE'...
    ' ,	MACK_114_Table105.PRECIP'...
    ' ,	MACK_114_Table105.C25mScm_1'...
    ' ,	MACK_114_Table105.CDH2O_TMP'...
    ' ,	MACK_114_Table105.AIR_TEMP_Avg'...
    ' ,	MACK_114_Table105.AIR_TEMP_Max'...
    ' ,	MACK_114_Table105.AIR_TEMP_Min'...
    ' ,	MACK_114_Table105.CDH2O_TMP_Avg'...
    ' ,	MACK_114_Table105.CDH2O_TMP_Max'...
    ' ,	MACK_114_Table105.CDH2O_TMP_Min'...
    ' ,	MACK_114_Table105.BATTERY_V'...
    ' FROM 	metdat.dbo.MACK_114_Table105'...
     ' WHERE LOGGERID = 114' ...
     ' AND year(TmStamp) = 2015'...
     ' ORDER BY TmStamp ASC'];

% qry = ['SELECT 	MACK_114_Table105.TmStamp'...
%     ' ,	MACK_114_Table105.RecNum'...
%     ' ,	MACK_114_Table105.LoggerID'...
%     ' ,	MACK_114_Table105.ProgID'...
%     ' ,	MACK_114_Table105.STAGE'...
%     ' ,	MACK_114_Table105.FISHSTAGE'...
%     ' ,	MACK_114_Table105.PRECIP'...
%     ' ,	MACK_114_Table105.C25mScm_1'...
%     ' ,	MACK_114_Table105.CDH2O_TMP'...
%     ' ,	MACK_114_Table105.AIR_TEMP_Avg'...
%     ' ,	MACK_114_Table105.AIR_TEMP_Max'...
%     ' ,	MACK_114_Table105.AIR_TEMP_Min'...
%     ' ,	MACK_114_Table105.CDH2O_TMP_Avg'...
%     ' ,	MACK_114_Table105.CDH2O_TMP_Max'...
%     ' ,	MACK_114_Table105.CDH2O_TMP_Min'...
%     ' ,	MACK_114_Table105.BATTERY_V'...
%     ' FROM 	metdat.dbo.MACK_114_Table105'...
%    '    WHERE LOGGERID = 114' ...
%    '    AND TmStamp >= DATEADD(day, -31, GETDATE())'...
%    '    ORDER BY TmStamp ASC '];

[data,msg] = sql2gceds(conn, ...
                        qry, ...
                        template, ...
                        1, ...
                        0, ...
                        1);

% %close database connection
 close(conn);



