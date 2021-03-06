function [data,msg] = fetch_primet_226_a_105(template)

%connect to the database
conn = database('metdat', '', '', 'Vendor', 'MICROSOFT SQL SERVER', 'Server', 'Stewartia', 'PortNumber', 1433, 'AuthType', 'Windows');

if exist('template','var') ~= 1
   template = '';
end

qry = ['SELECT PRIM_226_table105.TmStamp'...
    ' ,	PRIM_226_table105.RecNum'...
    ' ,	PRIM_226_table105.LOGGERID'...
    ' ,	PRIM_226_table105.PROGID'...
    ' ,	PRIM_226_table105.AIR_150_AVG'...
    ' ,	PRIM_226_table105.AIR_250_AVG'...
    ' ,	PRIM_226_table105.AIR_350_AVG'...
    ' ,	PRIM_226_table105.AIR_450_AVG'...
    ' ,	PRIM_226_table105.AIR_150_MAX'...
    ' ,	PRIM_226_table105.AIR_250_MAX'...
    ' ,	PRIM_226_table105.AIR_350_MAX'...
    ' ,	PRIM_226_table105.AIR_450_MAX'...
    ' ,	PRIM_226_table105.AIR_150_MIN'...
    ' ,	PRIM_226_table105.AIR_250_MIN'...
    ' ,	PRIM_226_table105.AIR_350_MIN'...
    ' ,	PRIM_226_table105.AIR_450_MIN'...
    ' ,	PRIM_226_table105.RH_150_AVG'...
    ' ,	PRIM_226_table105.RH_450_AVG'...
    ' ,	PRIM_226_table105.DEWPT_150_AVG'...
    ' ,	PRIM_226_table105.DEWPT_450_AVG'...
    ' ,	PRIM_226_table105.DEWPT_150_MAX'...
    ' ,	PRIM_226_table105.DEWPT_450_MAX'...
    ' ,	PRIM_226_table105.DEWPT_150_MIN'...
    ' ,	PRIM_226_table105.DEWPT_450_MIN'...
    ' ,	PRIM_226_table105.BATTERY_AVG'...
    ' ,	PRIM_226_table105.SNOWDEPTH'...
    ' ,	PRIM_226_table105.QUALITY'...
    ' ,	PRIM_226_table105.WINDSPEED_S_WVT'...
    ' ,	PRIM_226_table105.WINDSPEED_U_WVT'...
    ' ,	PRIM_226_table105.WIND_DIR_DU_WVT'...
    ' ,	PRIM_226_table105.WIND_DIR_SDU_WVT'...
    ' ,	PRIM_226_table105.WINDSPEED_MAX'...
    ' FROM 	metdat.dbo.PRIM_226_table105' ...
    ' WHERE year(TmStamp) = 2015' ...
    ' AND LOGGERID = 226' ...
    ' ORDER BY TmStamp ASC'];

% qry = ['SELECT PRIM_226_table105.TmStamp'...
%     ' ,	PRIM_226_table105.RecNum'...
%     ' ,	PRIM_226_table105.LOGGERID'...
%     ' ,	PRIM_226_table105.PROGID'...
%     ' ,	PRIM_226_table105.AIR_150_AVG'...
%     ' ,	PRIM_226_table105.AIR_250_AVG'...
%     ' ,	PRIM_226_table105.AIR_350_AVG'...
%     ' ,	PRIM_226_table105.AIR_450_AVG'...
%     ' ,	PRIM_226_table105.AIR_150_MAX'...
%     ' ,	PRIM_226_table105.AIR_250_MAX'...
%     ' ,	PRIM_226_table105.AIR_350_MAX'...
%     ' ,	PRIM_226_table105.AIR_450_MAX'...
%     ' ,	PRIM_226_table105.AIR_150_MIN'...
%     ' ,	PRIM_226_table105.AIR_250_MIN'...
%     ' ,	PRIM_226_table105.AIR_350_MIN'...
%     ' ,	PRIM_226_table105.AIR_450_MIN'...
%     ' ,	PRIM_226_table105.RH_150_AVG'...
%     ' ,	PRIM_226_table105.RH_450_AVG'...
%     ' ,	PRIM_226_table105.DEWPT_150_AVG'...
%     ' ,	PRIM_226_table105.DEWPT_450_AVG'...
%     ' ,	PRIM_226_table105.DEWPT_150_MAX'...
%     ' ,	PRIM_226_table105.DEWPT_450_MAX'...
%     ' ,	PRIM_226_table105.DEWPT_150_MIN'...
%     ' ,	PRIM_226_table105.DEWPT_450_MIN'...
%     ' ,	PRIM_226_table105.BATTERY_AVG'...
%     ' ,	PRIM_226_table105.SNOWDEPTH'...
%     ' ,	PRIM_226_table105.QUALITY'...
%     ' ,	PRIM_226_table105.WINDSPEED_S_WVT'...
%     ' ,	PRIM_226_table105.WINDSPEED_U_WVT'...
%     ' ,	PRIM_226_table105.WIND_DIR_DU_WVT'...
%     ' ,	PRIM_226_table105.WIND_DIR_SDU_WVT'...
%     ' ,	PRIM_226_table105.WINDSPEED_MAX'...
%     ' FROM 	metdat.dbo.PRIM_226_table105'...
%     ' WHERE   TmStamp >= DATEADD(day, -21, GETDATE())'...
%     ' AND LOGGERID = 226' ...
%     ' ORDER BY TmStamp ASC '];


% old query before 5min consolidation
% qry = ['SELECT PRIM_226_table105.TmStamp'...
%     ' ,	PRIM_226_table105.RecNum'...
%     ' ,	PRIM_226_table105.LOGGERID'...
%     ' ,	PRIM_226_table105.PROGID'...
%     ' ,	PRIM_226_table105.BATTERY_AVG'...
%     ' ,	PRIM_226_table105.QUALITY'...
%     ' ,	PRIM_226_table105.SNOWDEPTH'...
%     ' ,	PRIM_226_table105.WIND_DIR_DU_WVT'...
%     ' ,	PRIM_226_table105.WIND_DIR_SDU_WVT'...
%     ' ,	PRIM_226_table105.WINDSPEED_S_WVT'...
%     ' ,	PRIM_226_table105.WINDSPEED_U_WVT'...
%     ' FROM 	metdat.dbo.PRIM_226_table105'...
%     ' WHERE year(TmStamp) = 2013'...
%     ' AND LOGGERID = 226' ...
%     ' ORDER BY TmStamp ASC'];

% qry = ['SELECT PRIM_226_table105.TmStamp'...
%     ' ,	PRIM_226_table105.RecNum'...
%     ' ,	PRIM_226_table105.LOGGERID'...
%     ' ,	PRIM_226_table105.PROGID'...
%     ' ,	PRIM_226_table105.BATTERY_AVG'...
%     ' ,	PRIM_226_table105.QUALITY'...
%     ' ,	PRIM_226_table105.SNOWDEPTH'...
%     ' ,	PRIM_226_table105.WIND_DIR_DU_WVT'...
%     ' ,	PRIM_226_table105.WIND_DIR_SDU_WVT'...
%     ' ,	PRIM_226_table105.WINDSPEED_S_WVT'...
%     ' ,	PRIM_226_table105.WINDSPEED_U_WVT'...
%     ' FROM 	metdat.dbo.PRIM_226_table105'...
%     ' WHERE   TmStamp >= DATEADD(day, -21, GETDATE())'...
%     ' AND LOGGERID = 226' ...
%     ' ORDER BY TmStamp ASC '];

[data,msg] = sql2gceds(conn, ...
                        qry, ...
                        template, ...
                        1, ...
                        0, ...
                        1);

% %close database connection
 close(conn);



