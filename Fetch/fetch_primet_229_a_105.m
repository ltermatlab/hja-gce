function [data,msg] = fetch_primet_229_a_105(template)

%connect to the database
conn = database('metdat', '', '', 'Vendor', 'MICROSOFT SQL SERVER', 'Server', 'Stewartia', 'PortNumber', 1433, 'AuthType', 'Windows');

if exist('template','var') ~= 1
   template = '';
end

qry = ['SELECT PRIM_229_rad_temp_avg.TmStamp'...
    ' ,	PRIM_229_rad_temp_avg.RecNum'...
    ' ,	PRIM_229_rad_temp_avg.LOGGERID'...
    ' ,	PRIM_229_rad_temp_avg.PROGID'...
    ' ,	PRIM_229_rad_temp_avg.Albedo_Avg'...
    ' ,	PRIM_229_rad_temp_avg.Asp150_Avg'...
    ' ,	PRIM_229_rad_temp_avg.Asp250_Avg'...
    ' ,	PRIM_229_rad_temp_avg.Asp350_Avg'...
    ' ,	PRIM_229_rad_temp_avg.Asp450_Avg'...
    ' ,	PRIM_229_rad_temp_avg.Asp150_Max'...
    ' ,	PRIM_229_rad_temp_avg.Asp250_Max'...
    ' ,	PRIM_229_rad_temp_avg.Asp350_Max'...
    ' ,	PRIM_229_rad_temp_avg.Asp450_Max'...
    ' ,	PRIM_229_rad_temp_avg.Asp150_Min'...
    ' ,	PRIM_229_rad_temp_avg.Asp250_Min'...
    ' ,	PRIM_229_rad_temp_avg.Asp350_Min'...
    ' ,	PRIM_229_rad_temp_avg.Asp450_Min'...
    ' ,	PRIM_229_rad_temp_avg.batt_volt_Min'...
    ' ,	PRIM_229_rad_temp_avg.DnTot_Avg'...
    ' ,	PRIM_229_rad_temp_avg.IR01Dn_Avg'...
    ' ,	PRIM_229_rad_temp_avg.IR01DnCo_Avg'...
    ' ,	PRIM_229_rad_temp_avg.IR01Up_Avg'...
    ' ,	PRIM_229_rad_temp_avg.IR01UpCo_Avg'...
    ' ,	PRIM_229_rad_temp_avg.NetRl_Avg'...
    ' ,	PRIM_229_rad_temp_avg.NetRs_Avg'...
    ' ,	PRIM_229_rad_temp_avg.NetTot_Avg'...
    ' ,	PRIM_229_rad_temp_avg.NR01TC_Avg'...
    ' ,	PRIM_229_rad_temp_avg.NR01TK_Avg'...
    ' ,	PRIM_229_rad_temp_avg.PTemp_Avg'...
    ' ,	PRIM_229_rad_temp_avg.SR01Dn_Avg'...
    ' ,	PRIM_229_rad_temp_avg.SR01Up_Avg'...
    ' ,	PRIM_229_rad_temp_avg.UpTot_Avg'...
    ' FROM 	metdat.dbo.PRIM_229_rad_temp_avg'...
    ' WHERE year(TmStamp) = 2015' ...
    ' AND LOGGERID = 229' ...
    ' ORDER BY TmStamp ASC'];

% qry = ['SELECT PRIM_229_rad_temp_avg.TmStamp'...
%     ' ,	PRIM_229_rad_temp_avg.RecNum'...
%     ' ,	PRIM_229_rad_temp_avg.LOGGERID'...
%     ' ,	PRIM_229_rad_temp_avg.PROGID'...
%     ' ,	PRIM_229_rad_temp_avg.Albedo_Avg'...
%     ' ,	PRIM_229_rad_temp_avg.Asp150_Avg'...
%     ' ,	PRIM_229_rad_temp_avg.Asp250_Avg'...
%     ' ,	PRIM_229_rad_temp_avg.Asp350_Avg'...
%     ' ,	PRIM_229_rad_temp_avg.Asp450_Avg'...
%     ' ,	PRIM_229_rad_temp_avg.Asp150_Max'...
%     ' ,	PRIM_229_rad_temp_avg.Asp250_Max'...
%     ' ,	PRIM_229_rad_temp_avg.Asp350_Max'...
%     ' ,	PRIM_229_rad_temp_avg.Asp450_Max'...
%     ' ,	PRIM_229_rad_temp_avg.Asp150_Min'...
%     ' ,	PRIM_229_rad_temp_avg.Asp250_Min'...
%     ' ,	PRIM_229_rad_temp_avg.Asp350_Min'...
%     ' ,	PRIM_229_rad_temp_avg.Asp450_Min'...
%     ' ,	PRIM_229_rad_temp_avg.batt_volt_Min'...
%     ' ,	PRIM_229_rad_temp_avg.DnTot_Avg'...
%     ' ,	PRIM_229_rad_temp_avg.IR01Dn_Avg'...
%     ' ,	PRIM_229_rad_temp_avg.IR01DnCo_Avg'...
%     ' ,	PRIM_229_rad_temp_avg.IR01Up_Avg'...
%     ' ,	PRIM_229_rad_temp_avg.IR01UpCo_Avg'...
%     ' ,	PRIM_229_rad_temp_avg.NetRl_Avg'...
%     ' ,	PRIM_229_rad_temp_avg.NetRs_Avg'...
%     ' ,	PRIM_229_rad_temp_avg.NetTot_Avg'...
%     ' ,	PRIM_229_rad_temp_avg.NR01TC_Avg'...
%     ' ,	PRIM_229_rad_temp_avg.NR01TK_Avg'...
%     ' ,	PRIM_229_rad_temp_avg.PTemp_Avg'...
%     ' ,	PRIM_229_rad_temp_avg.SR01Dn_Avg'...
%     ' ,	PRIM_229_rad_temp_avg.SR01Up_Avg'...
%     ' ,	PRIM_229_rad_temp_avg.UpTot_Avg'...
%     ' FROM 	metdat.dbo.PRIM_229_rad_temp_avg'...
%     ' WHERE   TmStamp >= DATEADD(day, -21, GETDATE())'...
%     ' AND LOGGERID = 229' ...
%     ' ORDER BY TmStamp ASC '];

[data,msg] = sql2gceds(conn, ...
                        qry, ...
                        template, ...
                        1, ...
                        0, ...
                        1);

% %close database connection
 close(conn);


