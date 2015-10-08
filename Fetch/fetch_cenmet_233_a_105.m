function [data,msg] = fetch_cenmet_233_a_105(template)

%connect to the database
conn = database('metdat', '', '', 'Vendor', 'MICROSOFT SQL SERVER', 'Server', 'Stewartia', 'PortNumber', 1433, 'AuthType', 'Windows');

if exist('template','var') ~= 1
   template = '';
end

qry = ['SELECT CENT_233_Table105.TmStamp'...
    ' ,	CENT_233_Table105.RecNum'...
    ' ,	CENT_233_Table105.LOGGERID'...
    ' ,	CENT_233_Table105.PROGID'...
    ' ,	CENT_233_Table105.AIR_150_Avg'...
    ' ,	CENT_233_Table105.AIR_250_Avg'...
    ' ,	CENT_233_Table105.AIR_350_Avg'...
    ' ,	CENT_233_Table105.AIR_450_Avg'...
    ' ,	CENT_233_Table105.ASP_350_Avg'...
    ' ,	CENT_233_Table105.RH_150_Avg'...
    ' ,	CENT_233_Table105.RH_450_Avg'...
    ' ,	CENT_233_Table105.DEWPT150_Avg'...
    ' ,	CENT_233_Table105.DEWPT450_Avg'...
    ' ,	CENT_233_Table105.SOILT_10_Avg'...
    ' ,	CENT_233_Table105.SOILT_20_Avg'...
    ' ,	CENT_233_Table105.SOILT_50_Avg'...
    ' ,	CENT_233_Table105.SOILT_100_Avg'...
    ' ,	CENT_233_Table105.WCRWC_10_Avg'...
    ' ,	CENT_233_Table105.WCRWC_20_Avg'...
    ' ,	CENT_233_Table105.WCRWC_50_Avg'...
    ' ,	CENT_233_Table105.WCRWC_100_Avg'...
    ' ,	CENT_233_Table105.WINDSPEED_WVc_1'...
    ' ,	CENT_233_Table105.WINDSPEED_WVc_2'...
    ' ,	CENT_233_Table105.WINDSPEED_WVc_3'...
    ' ,	CENT_233_Table105.BATTERY_V_Avg'...
    ' ,	CENT_233_Table105.AIR_150_diag'...
    ' ,	CENT_233_Table105.AIR_250_diag'...
    ' ,	CENT_233_Table105.N_samples'...
    ' ,	CENT_233_Table105.N_samples_good'...
    ' ,	CENT_233_Table105.diag_Max'...
    ' ,	CENT_233_Table105.sncstring_bytes_Min'...
    ' ,	CENT_233_Table105.Ux_Avg'...
    ' ,	CENT_233_Table105.Uy_Avg'...
    ' ,	CENT_233_Table105.Ts_Avg'...
    ' ,	CENT_233_Table105.Ux_Std'...
    ' ,	CENT_233_Table105.Uy_Std'...
    ' ,	CENT_233_Table105.Ts_Std'...
    ' ,	CENT_233_Table105.SPD_mean'...
    ' ,	CENT_233_Table105.DIR_mean'...
    ' ,	CENT_233_Table105.DIR_std'...
    ' ,	CENT_233_Table105.SPD_Gust_max'...
    ' ,	CENT_233_Table105.AIR_150_Max'...
    ' ,	CENT_233_Table105.AIR_250_Max'...
    ' ,	CENT_233_Table105.AIR_350_Max'...
    ' ,	CENT_233_Table105.ASP_350_Max'...
    ' ,	CENT_233_Table105.AIR_450_Max'...
    ' ,	CENT_233_Table105.DEWPT150_Max'...
    ' ,	CENT_233_Table105.DEWPT450_Max'...
    ' ,	CENT_233_Table105.AIR_150_Min'...
    ' ,	CENT_233_Table105.AIR_250_Min'...
    ' ,	CENT_233_Table105.AIR_350_Min'...
    ' ,	CENT_233_Table105.ASP_350_Min'...
    ' ,	CENT_233_Table105.AIR_450_Min'...
    ' ,	CENT_233_Table105.DEWPT150_Min'...
    ' ,	CENT_233_Table105.DEWPT450_Min'...
    ' ,	CENT_233_Table105.WINDSPEED_Max'...
    ' FROM 	metdat.dbo.CENT_233_Table105'...
    ' WHERE LOGGERID = 233' ...
    ' AND year(TmStamp) = 2015'...
    ' ORDER BY TmStamp ASC '];

% qry = ['SELECT CENT_233_Table105.TmStamp'...
%     ' ,	CENT_233_Table105.RecNum'...
%     ' ,	CENT_233_Table105.LOGGERID'...
%     ' ,	CENT_233_Table105.PROGID'...
%     ' ,	CENT_233_Table105.AIR_150_Avg'...
%     ' ,	CENT_233_Table105.AIR_150_diag'...
%     ' ,	CENT_233_Table105.AIR_250_Avg'...
%     ' ,	CENT_233_Table105.AIR_250_diag'...
%     ' ,	CENT_233_Table105.AIR_350_Avg'...
%     ' ,	CENT_233_Table105.AIR_450_Avg'...
%     ' ,	CENT_233_Table105.BATTERY_V_Avg'...
%     ' ,	CENT_233_Table105.DEWPT150_Avg'...
%     ' ,	CENT_233_Table105.DEWPT450_Avg'...
%     ' ,	CENT_233_Table105.DIR_mean'...
%     ' ,	CENT_233_Table105.DIR_std'...
%     ' ,	CENT_233_Table105.RH_150_Avg'...
%     ' ,	CENT_233_Table105.RH_450_Avg'...
%     ' ,	CENT_233_Table105.SATVP_150_Avg'...
%     ' ,	CENT_233_Table105.SATVP_450_Avg'...
%     ' ,	CENT_233_Table105.SOILT_100_Avg'...
%     ' ,	CENT_233_Table105.SOILT_10_Avg'...
%     ' ,	CENT_233_Table105.SOILT_20_Avg'...
%     ' ,	CENT_233_Table105.SOILT_50_Avg'...
%     ' ,	CENT_233_Table105.SPD_Gust_max'...
%     ' ,	CENT_233_Table105.SPD_mean'...
%     ' ,	CENT_233_Table105.Ts_Avg'...
%     ' ,	CENT_233_Table105.Ts_Std'...
%     ' ,	CENT_233_Table105.VAPDEF150_Avg'...
%     ' ,	CENT_233_Table105.VAPDEF450_Avg'...
%     ' ,	CENT_233_Table105.VP_150_Avg'...
%     ' ,	CENT_233_Table105.VP_450_Avg'...
%     ' ,	CENT_233_Table105.WCRWC_100_Avg'...
%     ' ,	CENT_233_Table105.WCRWC_10_Avg'...
%     ' ,	CENT_233_Table105.WCRWC_20_Avg'...
%     ' ,	CENT_233_Table105.WCRWC_50_Avg'...
%     ' ,	CENT_233_Table105.WIND_DIR'...
%     ' ,	CENT_233_Table105.WINDSPEED_WVc_1'...
%     ' ,	CENT_233_Table105.WINDSPEED_WVc_2'...
%     ' ,	CENT_233_Table105.WINDSPEED_WVc_3'...
%     ' ,	CENT_233_Table105.WINDSPEED_Max'...
%     ' FROM 	metdat.dbo.CENT_233_Table105'...
%     ' WHERE LOGGERID = 233' ...
%     ' AND   TmStamp >= DATEADD(day, -100, GETDATE())'...
%     ' ORDER BY TmStamp ASC '];

[data,msg] = sql2gceds(conn, ...
                        qry, ...
                        template, ...
                        1, ...
                        0, ...
                        1);

% %close database connection
 close(conn);


