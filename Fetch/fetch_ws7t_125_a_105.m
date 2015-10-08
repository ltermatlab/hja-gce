function [data,msg] = fetch_ws7t_125_a_105(template)

%connect to the database
conn = database('metdat', '', '', 'Vendor', 'MICROSOFT SQL SERVER', 'Server', 'Stewartia', 'PortNumber', 1433, 'AuthType', 'Windows');

if exist('template','var') ~= 1
   template = '';
end

qry = ['SELECT WS7T_125_Table105.TmStamp'...
    ' ,	WS7T_125_Table105.RecNum'...
    ' ,	WS7T_125_Table105.LOGGERID'...
    ' ,	WS7T_125_Table105.PROGID'...
    ' ,	WS7T_125_Table105.AIR_150_Avg'...
    ' ,	WS7T_125_Table105.AIR_250_Avg'...
    ' ,	WS7T_125_Table105.AIR_350_Avg'...
    ' ,	WS7T_125_Table105.AIR_450_Avg'...
    ' ,	WS7T_125_Table105.ASP_350_Avg'...
    ' ,	WS7T_125_Table105.AIR_150_Max'...
    ' ,	WS7T_125_Table105.AIR_250_Max'...
    ' ,	WS7T_125_Table105.AIR_350_Max'...
    ' ,	WS7T_125_Table105.AIR_450_Max'...
    ' ,	WS7T_125_Table105.ASP_350_Max'...
    ' ,	WS7T_125_Table105.AIR_150_Min'...
    ' ,	WS7T_125_Table105.AIR_250_Min'...
    ' ,	WS7T_125_Table105.AIR_350_Min'...
    ' ,	WS7T_125_Table105.AIR_450_Min'...
    ' ,	WS7T_125_Table105.ASP_350_Min'...
    ' ,	WS7T_125_Table105.RH_150_Avg'...
    ' ,	WS7T_125_Table105.RH_450_Avg'...
    ' ,	WS7T_125_Table105.DEWPT150_Avg'...
    ' ,	WS7T_125_Table105.DEWPT450_Avg'...
    ' ,	WS7T_125_Table105.DEWPT150_Max'...
    ' ,	WS7T_125_Table105.DEWPT450_Max'...
    ' ,	WS7T_125_Table105.DEWPT150_Min'...
    ' ,	WS7T_125_Table105.DEWPT450_Min'...
    ' ,	WS7T_125_Table105.INCOMING_Avg'...
    ' ,	WS7T_125_Table105.OUTGOING_Avg'...
    ' ,	WS7T_125_Table105.INCOMING_Max'...
    ' ,	WS7T_125_Table105.OUTGOING_Max'...
    ' ,	WS7T_125_Table105.SOILT_10_Avg'...
    ' ,	WS7T_125_Table105.SOILT_20_Avg'...
    ' ,	WS7T_125_Table105.SOILT_50_Avg'...
    ' ,	WS7T_125_Table105.SOILT_100_Avg'...
    ' ,	WS7T_125_Table105.BATTERY_V_Avg'...
    ' ,	WS7T_125_Table105.SNOWDEPTH'...
    ' ,	WS7T_125_Table105.QUALITY'...
    ' ,	WS7T_125_Table105.SWE'...
    ' ,	WS7T_125_Table105.WINDSPEED_WVc_1'...
    ' ,	WS7T_125_Table105.WINDSPEED_WVc_2'...
    ' ,	WS7T_125_Table105.WINDSPEED_WVc_3'...
    ' ,	WS7T_125_Table105.WINDSPEED_Max'...
    ' FROM 	metdat.dbo.WS7T_125_Table105'...
    ' WHERE LOGGERID = 125' ...
    ' AND year(TmStamp) = 2015'...
    ' ORDER BY TmStamp ASC '];

% qry = ['SELECT WS7T_125_Table105.TmStamp'...
%     ' ,	WS7T_125_Table105.RecNum'...
%     ' ,	WS7T_125_Table105.LOGGERID'...
%     ' ,	WS7T_125_Table105.PROGID'...
%     ' ,	WS7T_125_Table105.AIR_150_Avg'...
%     ' ,	WS7T_125_Table105.AIR_250_Avg'...
%     ' ,	WS7T_125_Table105.AIR_350_Avg'...
%     ' ,	WS7T_125_Table105.AIR_450_Avg'...
%     ' ,	WS7T_125_Table105.ASP_350_Avg'...
%     ' ,	WS7T_125_Table105.AIR_150_Max'...
%     ' ,	WS7T_125_Table105.AIR_250_Max'...
%     ' ,	WS7T_125_Table105.AIR_350_Max'...
%     ' ,	WS7T_125_Table105.AIR_450_Max'...
%     ' ,	WS7T_125_Table105.ASP_350_Max'...
%     ' ,	WS7T_125_Table105.AIR_150_Min'...
%     ' ,	WS7T_125_Table105.AIR_250_Min'...
%     ' ,	WS7T_125_Table105.AIR_350_Min'...
%     ' ,	WS7T_125_Table105.AIR_450_Min'...
%     ' ,	WS7T_125_Table105.ASP_350_Min'...
%     ' ,	WS7T_125_Table105.RH_150_Avg'...
%     ' ,	WS7T_125_Table105.RH_450_Avg'...
%     ' ,	WS7T_125_Table105.DEWPT150_Avg'...
%     ' ,	WS7T_125_Table105.DEWPT450_Avg'...
%     ' ,	WS7T_125_Table105.DEWPT150_Max'...
%     ' ,	WS7T_125_Table105.DEWPT450_Max'...
%     ' ,	WS7T_125_Table105.DEWPT150_Min'...
%     ' ,	WS7T_125_Table105.DEWPT450_Min'...
%     ' ,	WS7T_125_Table105.INCOMING_Avg'...
%     ' ,	WS7T_125_Table105.OUTGOING_Avg'...
%     ' ,	WS7T_125_Table105.INCOMING_Max'...
%     ' ,	WS7T_125_Table105.OUTGOING_Max'...
%     ' ,	WS7T_125_Table105.SOILT_10_Avg'...
%     ' ,	WS7T_125_Table105.SOILT_20_Avg'...
%     ' ,	WS7T_125_Table105.SOILT_50_Avg'...
%     ' ,	WS7T_125_Table105.SOILT_100_Avg'...
%     ' ,	WS7T_125_Table105.BATTERY_V_Avg'...
%     ' ,	WS7T_125_Table105.SNOWDEPTH'...
%     ' ,	WS7T_125_Table105.QUALITY'...
%     ' ,	WS7T_125_Table105.SWE'...
%     ' ,	WS7T_125_Table105.WINDSPEED_WVc_1'...
%     ' ,	WS7T_125_Table105.WINDSPEED_WVc_2'...
%     ' ,	WS7T_125_Table105.WINDSPEED_WVc_3'...
%     ' ,	WS7T_125_Table105.WINDSPEED_Max'...
%     ' FROM 	metdat.dbo.WS7T_125_Table105'...
%     ' WHERE LOGGERID = 225' ...
%     ' AND   TmStamp >= DATEADD(day, -21, GETDATE())'...
%     ' ORDER BY TmStamp ASC '];

[data,msg] = sql2gceds(conn, ...
                        qry, ...
                        template, ...
                        1, ...
                        0, ...
                        1);

% %close database connection
 close(conn);



