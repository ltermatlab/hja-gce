function [data,msg] = fetch_gsws03_117_105(template)

%connect to the database
conn = database('metdat', '', '', 'Vendor', 'MICROSOFT SQL SERVER', 'Server', 'Stewartia', 'PortNumber', 1433, 'AuthType', 'Windows');

if exist('template','var') ~= 1
   template = '';
end

qry = ['SELECT 	WS03_117_Table105.TmStamp'...
    ' ,	WS03_117_Table105.RecNum'...
    ' ,	WS03_117_Table105.LoggerID'...
    ' ,	WS03_117_Table105.ProgID'...
    ' ,	WS03_117_Table105.V_NOTCH_WEIR'...
    ' ,	WS03_117_Table105.STAGE'...
    ' ,	WS03_117_Table105.C25mScm_1'...
    ' ,	WS03_117_Table105.CDH2O_TMP'...
    ' ,	WS03_117_Table105.AIR_TEMP_Avg'...
    ' ,	WS03_117_Table105.AIR_TEMP_Max'...
    ' ,	WS03_117_Table105.AIR_TEMP_Min'...
    ' ,	WS03_117_Table105.CDH2O_TMP_Avg'...
    ' ,	WS03_117_Table105.CDH2O_TMP_Max'...
    ' ,	WS03_117_Table105.CDH2O_TMP_Min'...
    ' ,	WS03_117_Table105.BATTERY_V'...
    ' FROM 	metdat.dbo.WS03_117_Table105'...
    ' WHERE LOGGERID = 117' ...
    ' ORDER BY TmStamp ASC'];

% qry = ['SELECT 	WS03_117_Table105.TmStamp'...
%     ' ,	WS03_117_Table105.RecNum'...
%     ' ,	WS03_117_Table105.LoggerID'...
%     ' ,	WS03_117_Table105.ProgID'...
%     ' ,	WS03_117_Table105.V_NOTCH_WEIR'...
%     ' ,	WS03_117_Table105.STAGE'...
%     ' ,	WS03_117_Table105.C25mScm_1'...
%     ' ,	WS03_117_Table105.CDH2O_TMP'...
%     ' ,	WS03_117_Table105.AIR_TEMP_Avg'...
%     ' ,	WS03_117_Table105.AIR_TEMP_Max'...
%     ' ,	WS03_117_Table105.AIR_TEMP_Min'...
%     ' ,	WS03_117_Table105.CDH2O_TMP_Avg'...
%     ' ,	WS03_117_Table105.CDH2O_TMP_Max'...
%     ' ,	WS03_117_Table105.CDH2O_TMP_Min'...
%     ' ,	WS03_117_Table105.BATTERY_V'...
%     ' FROM 	metdat.dbo.WS03_117_Table105'...
%     ' WHERE LOGGERID = 117' ...
%     ' AND TmStamp >= DATEADD(day, -31, GETDATE())'...
%     ' ORDER BY TmStamp ASC '];

[data,msg] = sql2gceds(conn, ...
                        qry, ...
                        template, ...
                        1, ...
                        0, ...
                        1);

% %close database connection
 close(conn);



