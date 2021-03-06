function [data,msg] = fetch_gsws02_116_105(template)

%connect to the database
conn = database('metdat', '', '', 'Vendor', 'MICROSOFT SQL SERVER', 'Server', 'Stewartia', 'PortNumber', 1433, 'AuthType', 'Windows');

if exist('template','var') ~= 1
   template = '';
end

qry = ['SELECT 	WS02_116_Table105.TmStamp'...
    ' ,	WS02_116_Table105.RecNum'...
    ' ,	WS02_116_Table105.LoggerID'...
    ' ,	WS02_116_Table105.ProgID'...
    ' ,	WS02_116_Table105.V_NOTCH_WEIR'...
    ' ,	WS02_116_Table105.STAGE'...
    ' ,	WS02_116_Table105.C25mScm_1'...
    ' ,	WS02_116_Table105.CDH2O_TMP'...
    ' ,	WS02_116_Table105.AIR_TEMP_Avg'...
    ' ,	WS02_116_Table105.AIR_TEMP_Max'...
    ' ,	WS02_116_Table105.AIR_TEMP_Min'...
    ' ,	WS02_116_Table105.CDH2O_TMP_Avg'...
    ' ,	WS02_116_Table105.CDH2O_TMP_Max'...
    ' ,	WS02_116_Table105.CDH2O_TMP_Min'...
    ' ,	WS02_116_Table105.BATTERY_V'...
    ' FROM 	metdat.dbo.WS02_116_Table105'...
   ' WHERE LOGGERID = 116' ...
   ' ORDER BY TmStamp ASC'];

% qry = ['SELECT 	WS02_116_Table105.TmStamp'...
%     ' ,	WS02_116_Table105.RecNum'...
%     ' ,	WS02_116_Table105.LoggerID'...
%     ' ,	WS02_116_Table105.ProgID'...
%     ' ,	WS02_116_Table105.V_NOTCH_WEIR'...
%     ' ,	WS02_116_Table105.STAGE'...
%     ' ,	WS02_116_Table105.C25mScm_1'...
%     ' ,	WS02_116_Table105.CDH2O_TMP'...
%     ' ,	WS02_116_Table105.AIR_TEMP_Avg'...
%     ' ,	WS02_116_Table105.AIR_TEMP_Max'...
%     ' ,	WS02_116_Table105.AIR_TEMP_Min'...
%     ' ,	WS02_116_Table105.CDH2O_TMP_Avg'...
%     ' ,	WS02_116_Table105.CDH2O_TMP_Max'...
%     ' ,	WS02_116_Table105.CDH2O_TMP_Min'...
%     ' ,	WS02_116_Table105.BATTERY_V'...
%     ' FROM 	metdat.dbo.WS02_116_Table105'...
%     '      WHERE LOGGERID = 116' ...
%     '      AND TmStamp >= DATEADD(day, -31, GETDATE())'...
%     '      ORDER BY TmStamp ASC '];

[data,msg] = sql2gceds(conn, ...
                        qry, ...
                        template, ...
                        1, ...
                        0, ...
                        1);

% %close database connection
 close(conn);



