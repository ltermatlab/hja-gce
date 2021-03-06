function [data,msg] = fetch_cenmet_233_a_105_arch2(template)
% arch2 appended to table name following major reprogramming on 4/16/2015

%connect to the database
conn = database('metdat', '', '', 'Vendor', 'MICROSOFT SQL SERVER', 'Server', 'Stewartia', 'PortNumber', 1433, 'AuthType', 'Windows');

if exist('template','var') ~= 1
   template = '';
end

% qry = ['SELECT 	CENT_233_Table105_arch2.TmStamp'...
%     ' ,	CENT_233_Table105_arch2.RecNum'...
%     ' ,	CENT_233_Table105_arch2.LOGGERID'...
%     ' ,	CENT_233_Table105_arch2.PROGID'...
%     ' ,	CENT_233_Table105_arch2.AIR_150_Avg'...
%     ' ,	CENT_233_Table105_arch2.AIR_250_Avg'...
%     ' ,	CENT_233_Table105_arch2.AIR_350_Avg'...
%     ' ,	CENT_233_Table105_arch2.AIR_450_Avg'...
%     ' ,	CENT_233_Table105_arch2.ASP_350_Avg'...
%     ' ,	CENT_233_Table105_arch2.RH_150_Avg'...
%     ' ,	CENT_233_Table105_arch2.RH_450_Avg'...
%     ' ,	CENT_233_Table105_arch2.DEWPT150_Avg'...
%     ' ,	CENT_233_Table105_arch2.DEWPT450_Avg'...
%     ' ,	CENT_233_Table105_arch2.SOILT_10_Avg'...
%     ' ,	CENT_233_Table105_arch2.SOILT_20_Avg'...
%     ' ,	CENT_233_Table105_arch2.SOILT_50_Avg'...
%     ' ,	CENT_233_Table105_arch2.SOILT_100_Avg'...
%     ' ,	CENT_233_Table105_arch2.WCRWC_10_Avg'...
%     ' ,	CENT_233_Table105_arch2.WCRWC_20_Avg'...
%     ' ,	CENT_233_Table105_arch2.WCRWC_50_Avg'...
%     ' ,	CENT_233_Table105_arch2.WCRWC_100_Avg'...
%     ' ,	CENT_233_Table105_arch2.WINDSPEED_WVc_1'...
%     ' ,	CENT_233_Table105_arch2.WINDSPEED_WVc_2'...
%     ' ,	CENT_233_Table105_arch2.WINDSPEED_WVc_3'...
%     ' ,	CENT_233_Table105_arch2.BATTERY_V_Avg'...
%     ' ,	CENT_233_Table105_arch2.AIR_150_diag'...
%     ' ,	CENT_233_Table105_arch2.AIR_250_diag'...
%     ' ,	CENT_233_Table105_arch2.Ux_Avg'...
%     ' ,	CENT_233_Table105_arch2.Uy_Avg'...
%     ' ,	CENT_233_Table105_arch2.Ts_Avg'...
%     ' ,	CENT_233_Table105_arch2.Ux_Std'...
%     ' ,	CENT_233_Table105_arch2.Uy_Std'...
%     ' ,	CENT_233_Table105_arch2.Ts_Std'...
%     ' ,	CENT_233_Table105_arch2.SPD_mean'...
%     ' ,	CENT_233_Table105_arch2.DIR_mean'...
%     ' ,	CENT_233_Table105_arch2.DIR_std'...
%     ' ,	CENT_233_Table105_arch2.SPD_Gust_max'...
%     ' ,	CENT_233_Table105_arch2.AIR_150_Max'...
%     ' ,	CENT_233_Table105_arch2.AIR_250_Max'...
%     ' ,	CENT_233_Table105_arch2.AIR_350_Max'...
%     ' ,	CENT_233_Table105_arch2.ASP_350_Max'...
%     ' ,	CENT_233_Table105_arch2.AIR_450_Max'...
%     ' ,	CENT_233_Table105_arch2.AIR_150_Min'...
%     ' ,	CENT_233_Table105_arch2.AIR_250_Min'...
%     ' ,	CENT_233_Table105_arch2.AIR_350_Min'...
%     ' ,	CENT_233_Table105_arch2.ASP_350_Min'...
%     ' ,	CENT_233_Table105_arch2.AIR_450_Min'...
%     ' ,	CENT_233_Table105_arch2.WINDSPEED_Max'...
%     ' FROM 	metdat.dbo.CENT_233_Table105_arch2'...
%     ' WHERE LOGGERID = 233' ...
%     ' AND TmStamp >= ''2014-8-01'''...
%     ' AND year(TmStamp) = 2014' ...
%     ' ORDER BY TmStamp ASC '];

qry = ['SELECT 	CENT_233_Table105_arch2.TmStamp'...
    ' ,	CENT_233_Table105_arch2.RecNum'...
    ' ,	CENT_233_Table105_arch2.LOGGERID'...
    ' ,	CENT_233_Table105_arch2.PROGID'...
    ' ,	CENT_233_Table105_arch2.AIR_150_Avg'...
    ' ,	CENT_233_Table105_arch2.AIR_250_Avg'...
    ' ,	CENT_233_Table105_arch2.AIR_350_Avg'...
    ' ,	CENT_233_Table105_arch2.AIR_450_Avg'...
    ' ,	CENT_233_Table105_arch2.ASP_350_Avg'...
    ' ,	CENT_233_Table105_arch2.RH_150_Avg'...
    ' ,	CENT_233_Table105_arch2.RH_450_Avg'...
    ' ,	CENT_233_Table105_arch2.DEWPT150_Avg'...
    ' ,	CENT_233_Table105_arch2.DEWPT450_Avg'...
    ' ,	CENT_233_Table105_arch2.SOILT_10_Avg'...
    ' ,	CENT_233_Table105_arch2.SOILT_20_Avg'...
    ' ,	CENT_233_Table105_arch2.SOILT_50_Avg'...
    ' ,	CENT_233_Table105_arch2.SOILT_100_Avg'...
    ' ,	CENT_233_Table105_arch2.WCRWC_10_Avg'...
    ' ,	CENT_233_Table105_arch2.WCRWC_20_Avg'...
    ' ,	CENT_233_Table105_arch2.WCRWC_50_Avg'...
    ' ,	CENT_233_Table105_arch2.WCRWC_100_Avg'...
    ' ,	CENT_233_Table105_arch2.WINDSPEED_WVc_1'...
    ' ,	CENT_233_Table105_arch2.WINDSPEED_WVc_2'...
    ' ,	CENT_233_Table105_arch2.WINDSPEED_WVc_3'...
    ' ,	CENT_233_Table105_arch2.BATTERY_V_Avg'...
    ' ,	CENT_233_Table105_arch2.AIR_150_diag'...
    ' ,	CENT_233_Table105_arch2.AIR_250_diag'...
    ' ,	CENT_233_Table105_arch2.Ux_Avg'...
    ' ,	CENT_233_Table105_arch2.Uy_Avg'...
    ' ,	CENT_233_Table105_arch2.Ts_Avg'...
    ' ,	CENT_233_Table105_arch2.Ux_Std'...
    ' ,	CENT_233_Table105_arch2.Uy_Std'...
    ' ,	CENT_233_Table105_arch2.Ts_Std'...
    ' ,	CENT_233_Table105_arch2.SPD_mean'...
    ' ,	CENT_233_Table105_arch2.DIR_mean'...
    ' ,	CENT_233_Table105_arch2.DIR_std'...
    ' ,	CENT_233_Table105_arch2.SPD_Gust_max'...
    ' ,	CENT_233_Table105_arch2.AIR_150_Max'...
    ' ,	CENT_233_Table105_arch2.AIR_250_Max'...
    ' ,	CENT_233_Table105_arch2.AIR_350_Max'...
    ' ,	CENT_233_Table105_arch2.ASP_350_Max'...
    ' ,	CENT_233_Table105_arch2.AIR_450_Max'...
    ' ,	CENT_233_Table105_arch2.AIR_150_Min'...
    ' ,	CENT_233_Table105_arch2.AIR_250_Min'...
    ' ,	CENT_233_Table105_arch2.AIR_350_Min'...
    ' ,	CENT_233_Table105_arch2.ASP_350_Min'...
    ' ,	CENT_233_Table105_arch2.AIR_450_Min'...
    ' ,	CENT_233_Table105_arch2.WINDSPEED_Max'...
    ' FROM 	metdat.dbo.CENT_233_Table105_arch2'...
    ' WHERE LOGGERID = 233' ...
    ' AND year(TmStamp) = 2015' ...
    ' ORDER BY TmStamp ASC '];

% qry = ['SELECT CENT_233_Table105_arch2.TmStamp'...
%     ' ,	CENT_233_Table105_arch2.RecNum'...
%     ' ,	CENT_233_Table105_arch2.LOGGERID'...
%     ' ,	CENT_233_Table105_arch2.PROGID'...
%     ' ,	CENT_233_Table105_arch2.AIR_150_Avg'...
%     ' ,	CENT_233_Table105_arch2.AIR_150_diag'...
%     ' ,	CENT_233_Table105_arch2.AIR_250_Avg'...
%     ' ,	CENT_233_Table105_arch2.AIR_250_diag'...
%     ' ,	CENT_233_Table105_arch2.AIR_350_Avg'...
%     ' ,	CENT_233_Table105_arch2.AIR_450_Avg'...
%     ' ,	CENT_233_Table105_arch2.BATTERY_V_Avg'...
%     ' ,	CENT_233_Table105_arch2.DEWPT150_Avg'...
%     ' ,	CENT_233_Table105_arch2.DEWPT450_Avg'...
%     ' ,	CENT_233_Table105_arch2.DIR_mean'...
%     ' ,	CENT_233_Table105_arch2.DIR_std'...
%     ' ,	CENT_233_Table105_arch2.RH_150_Avg'...
%     ' ,	CENT_233_Table105_arch2.RH_450_Avg'...
%     ' ,	CENT_233_Table105_arch2.SATVP_150_Avg'...
%     ' ,	CENT_233_Table105_arch2.SATVP_450_Avg'...
%     ' ,	CENT_233_Table105_arch2.SOILT_100_Avg'...
%     ' ,	CENT_233_Table105_arch2.SOILT_10_Avg'...
%     ' ,	CENT_233_Table105_arch2.SOILT_20_Avg'...
%     ' ,	CENT_233_Table105_arch2.SOILT_50_Avg'...
%     ' ,	CENT_233_Table105_arch2.SPD_Gust_max'...
%     ' ,	CENT_233_Table105_arch2.SPD_mean'...
%     ' ,	CENT_233_Table105_arch2.Ts_Avg'...
%     ' ,	CENT_233_Table105_arch2.Ts_Std'...
%     ' ,	CENT_233_Table105_arch2.VAPDEF150_Avg'...
%     ' ,	CENT_233_Table105_arch2.VAPDEF450_Avg'...
%     ' ,	CENT_233_Table105_arch2.VP_150_Avg'...
%     ' ,	CENT_233_Table105_arch2.VP_450_Avg'...
%     ' ,	CENT_233_Table105_arch2.WCRWC_100_Avg'...
%     ' ,	CENT_233_Table105_arch2.WCRWC_10_Avg'...
%     ' ,	CENT_233_Table105_arch2.WCRWC_20_Avg'...
%     ' ,	CENT_233_Table105_arch2.WCRWC_50_Avg'...
%     ' ,	CENT_233_Table105_arch2.WIND_DIR'...
%     ' ,	CENT_233_Table105_arch2.WINDSPEED_WVc_1'...
%     ' ,	CENT_233_Table105_arch2.WINDSPEED_WVc_2'...
%     ' ,	CENT_233_Table105_arch2.WINDSPEED_WVc_3'...
%     ' ,	CENT_233_Table105_arch2.WINDSPEED_Max'...
%     ' FROM 	metdat.dbo.CENT_233_Table105'...
%     ' WHERE LOGGERID = 233' ...
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



