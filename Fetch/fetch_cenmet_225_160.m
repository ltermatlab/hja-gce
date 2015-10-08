function [data,msg] = fetch_cenmet_225_160(template)

%connect to the database
conn = database('metdat', '', '', 'Vendor', 'MICROSOFT SQL SERVER', 'Server', 'Stewartia', 'PortNumber', 1433, 'AuthType', 'Windows');

if exist('template','var') ~= 1
   template = '';
end

qry = ['SELECT CENT_225_160.TmStamp'...
    ' ,	CENT_225_160.RecNum'...
    ' ,	CENT_225_160.LOGGERID'...
    ' ,	CENT_225_160.PROGID'...
    ' ,	CENT_225_160.NSOILT_10_AVG'...
    ' ,	CENT_225_160.NSOILT_20_AVG'...
    ' ,	CENT_225_160.NSOILT_50_AVG'...
    ' ,	CENT_225_160.NSOILT100_AVG'...
    ' ,	CENT_225_160.RH_150_AVG'...
    ' ,	CENT_225_160.RH_450_AVG'...
    ' ,	CENT_225_160.DEWPT_150_AVG'...
    ' ,	CENT_225_160.DEWPT_450_AVG'...
    ' ,	CENT_225_160.VAPDEF150_AVG'...
    ' ,	CENT_225_160.VAPDEF450_AVG'...
    ' ,	CENT_225_160.WINDSPEED_S_WVT'...
    ' ,	CENT_225_160.WINDSPEED_U_WVT'...
    ' ,	CENT_225_160.WIND_DIR_DU_WVT'...
    ' ,	CENT_225_160.WIND_DIR_SDU_WVT'...
    ' ,	CENT_225_160.WCRPA_10'...
    ' ,	CENT_225_160.WCRPA_20'...
    ' ,	CENT_225_160.WCRPA_50'...
    ' ,	CENT_225_160.WCRPA100'...
    ' ,	CENT_225_160.SNOWDEPTH'...
    ' ,	CENT_225_160.QUALITY'...
    ' FROM 	metdat.dbo.CENT_225_160'...
    ' WHERE YEAR(TmStamp) = 2015 AND DATEPART(mi, TmStamp) = 00'...
    ' AND LOGGERID = 225' ...
    ' ORDER BY TmStamp ASC '];

% qry = ['SELECT 	CENT_225_160.TmStamp'...
%     ' ,	CENT_225_160.RecNum'...
%     ' ,	CENT_225_160.LOGGERID'...
%     ' ,	CENT_225_160.PROGID'...
%     ' ,	CENT_225_160.NSOILT_10_AVG'...
%     ' ,	CENT_225_160.NSOILT_20_AVG'...
%     ' ,	CENT_225_160.NSOILT_50_AVG'...
%     ' ,	CENT_225_160.NSOILT100_AVG'...
%     ' ,	CENT_225_160.RH_150_AVG'...
%     ' ,	CENT_225_160.RH_450_AVG'...
%     ' ,	CENT_225_160.DEWPT_150_AVG'...
%     ' ,	CENT_225_160.DEWPT_450_AVG'...
%     ' ,	CENT_225_160.VAPDEF150_AVG'...
%     ' ,	CENT_225_160.VAPDEF450_AVG'...
%     ' ,	CENT_225_160.WINDSPEED_S_WVT'...
%     ' ,	CENT_225_160.WINDSPEED_U_WVT'...
%     ' ,	CENT_225_160.WIND_DIR_DU_WVT'...
%     ' ,	CENT_225_160.WIND_DIR_SDU_WVT'...
%     ' ,	CENT_225_160.WCRPA_10'...
%     ' ,	CENT_225_160.WCRPA_20'...
%     ' ,	CENT_225_160.WCRPA_50'...
%     ' ,	CENT_225_160.WCRPA100'...
%     ' ,	CENT_225_160.SNOWDEPTH'...
%     ' ,	CENT_225_160.QUALITY'...
%     ' FROM 	metdat.dbo.CENT_225_160'...
%     ' WHERE   TmStamp >= DATEADD(day, -21, GETDATE())'...
%     ' AND LOGGERID = 225' ...
%     ' ORDER BY TmStamp ASC '];

[data,msg] = sql2gceds(conn, ...
                        qry, ...
                        template, ...
                        1, ...
                        0, ...
                        1);

% %close database connection
 close(conn);


