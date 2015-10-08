function [data,msg] = fetch_hi15_208_440(template)

%connect to the database
conn = database('metdat', '', '', 'Vendor', 'MICROSOFT SQL SERVER', 'Server', 'Stewartia', 'PortNumber', 1433, 'AuthType', 'Windows');

if exist('template','var') ~= 1
   template = '';
end

qry = ['SELECT TOP 20 HI15_208_440.TmStamp'...
    ' ,	HI15_208_440.RecNum'...
    ' ,	HI15_208_440.LOGGERID'...
    ' ,	HI15_208_440.PROGID'...
    ' ,	HI15_208_440.WINDSPEED_S_WVT'...
    ' ,	HI15_208_440.WINDSPEED_U_WVT'...
    ' ,	HI15_208_440.WIND_DIR_DU_WVT'...
    ' ,	HI15_208_440.WIND_DIR_SDU_WVT'...
    ' ,	HI15_208_440.WIND_DIR_BIN01'...
    ' ,	HI15_208_440.WIND_DIR_BIN02'...
    ' ,	HI15_208_440.WIND_DIR_BIN03'...
    ' ,	HI15_208_440.WIND_DIR_BIN04'...
    ' ,	HI15_208_440.WIND_DIR_BIN05'...
    ' ,	HI15_208_440.WIND_DIR_BIN06'...
    ' ,	HI15_208_440.WIND_DIR_BIN07'...
    ' ,	HI15_208_440.WIND_DIR_BIN08'...
    ' ,	HI15_208_440.AIR_150_AVG'...
    ' ,	HI15_208_440.AIR_450_AVG'...
    ' ,	HI15_208_440.RH_150_AVG'...
    ' ,	HI15_208_440.RH_450_AVG'...
    ' ,	HI15_208_440.DEWPT_150_AVG'...
    ' ,	HI15_208_440.DEWPT_450_AVG'...
    ' ,	HI15_208_440.VAPDEF150_AVG'...
    ' ,	HI15_208_440.VAPDEF450_AVG'...
    ' ,	HI15_208_440.WINDSPEED_MAX'...
    ' ,	HI15_208_440.WINDSPEED_Hr_Min_MAX'...
    ' ,	HI15_208_440.AIR_150_MAX'...
    ' ,	HI15_208_440.AIR_150_Hr_Min_MAX'...
    ' ,	HI15_208_440.AIR_450_MAX'...
    ' ,	HI15_208_440.AIR_450_Hr_Min_MAX'...
    ' ,	HI15_208_440.RH_150_MAX'...
    ' ,	HI15_208_440.RH_150_Hr_Min_MAX'...
    ' ,	HI15_208_440.RH_450_MAX'...
    ' ,	HI15_208_440.RH_450_Hr_Min_MAX'...
    ' ,	HI15_208_440.DEWPT_150_MAX'...
    ' ,	HI15_208_440.DEWPT_150_Hr_Min_MAX'...
    ' ,	HI15_208_440.DEWPT_450_MAX'...
    ' ,	HI15_208_440.DEWPT_450_Hr_Min_MAX'...
    ' ,	HI15_208_440.VAPDEF150_MAX'...
    ' ,	HI15_208_440.VAPDEF150_Hr_Min_MAX'...
    ' ,	HI15_208_440.VAPDEF450_MAX'...
    ' ,	HI15_208_440.VAPDEF450_Hr_Min_MAX'...
    ' ,	HI15_208_440.AIR_150_MIN'...
    ' ,	HI15_208_440.AIR_150_Hr_Min_MIN'...
    ' ,	HI15_208_440.AIR_450_MIN'...
    ' ,	HI15_208_440.AIR_450_Hr_Min_MIN'...
    ' ,	HI15_208_440.RH_150_MIN'...
    ' ,	HI15_208_440.RH_150_Hr_Min_MIN'...
    ' ,	HI15_208_440.RH_450_MIN'...
    ' ,	HI15_208_440.RH_450_Hr_Min_MIN'...
    ' ,	HI15_208_440.DEWPT_150_MIN'...
    ' ,	HI15_208_440.DEWPT_150_Hr_Min_MIN'...
    ' ,	HI15_208_440.DEWPT_450_MIN'...
    ' ,	HI15_208_440.DEWPT_450_Hr_Min_MIN'...
    ' ,	HI15_208_440.VAPDEF150_MIN'...
    ' ,	HI15_208_440.VAPDEF150_Hr_Min_MIN'...
    ' ,	HI15_208_440.VAPDEF450_MIN'...
    ' ,	HI15_208_440.VAPDEF450_Hr_Min_MIN'...
    ' FROM 	metdat.dbo.HI15_208_440 '...
    ' WHERE LOGGERID = 208' ...
    ' AND year(TmStamp) = 2014'...
    ' AND DATEPART(hh, TmStamp) = 00'...
    ' ORDER BY TmStamp ASC '];

% qry = ['SELECT 	HI15_207_105.TmStamp'...
%     ' ,	HI15_207_105.RecNum'...
%     ' ,	HI15_207_105.LOGGERID'...
%     ' ,	HI15_207_105.PROGID'...
%     ' ,	HI15_207_105.PRECIP_PR'...
%     ' ,	HI15_207_105.TIPPING_B_TOT'...
%     ' FROM 	metdat.dbo.HI15_207_105 '...
%     ' WHERE   TmStamp >= DATEADD(day, -21, GETDATE())'...
%     ' AND DATEPART(hh, TmStamp) = 00'...
%     ' ORDER BY TmStamp ASC '];

[data,msg] = sql2gceds(conn, ...
                        qry, ...
                        template, ...
                        1, ...
                        0, ...
                        1);

% %close database connection
 close(conn);



