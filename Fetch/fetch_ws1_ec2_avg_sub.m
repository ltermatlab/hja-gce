function [data,msg] = fetch_ws1_ec2_avg_sub(template)

%connect to the database
conn = database('metdat', '', '', 'Vendor', 'MICROSOFT SQL SERVER', 'Server', 'Stewartia', 'PortNumber', 1433, 'AuthType', 'Windows');

if exist('template','var') ~= 1
   template = 'LNDB_Ws1_2';
end

qry = ['SELECT hjaws1ec2_avg_sub.TmStamp'...
    ' ,	hjaws1ec2_avg_sub.RecNum'...
    ' ,	hjaws1ec2_avg_sub.batt_volt_Min'...
    ' ,	hjaws1ec2_avg_sub.diag_sub_Max'...
    ' ,	hjaws1ec2_avg_sub.Panel_T_Avg'...
    ' ,	hjaws1ec2_avg_sub.Ts_sub_Avg'...
    ' ,	hjaws1ec2_avg_sub.Ts_sub_Std'...
    ' ,	hjaws1ec2_avg_sub.Ux_sub_Avg'...
    ' ,	hjaws1ec2_avg_sub.Ux_sub_Std'...
    ' ,	hjaws1ec2_avg_sub.Uy_sub_Avg'...
    ' ,	hjaws1ec2_avg_sub.Uy_sub_Std'...
    ' ,	hjaws1ec2_avg_sub.Uz_sub_Avg'...
    ' ,	hjaws1ec2_avg_sub.Uz_sub_Std'...
    ' ,	hjaws1ec2_avg_sub.WDir_mean_sub'...
    ' ,	hjaws1ec2_avg_sub.WDir_std_sub'...
    ' ,	hjaws1ec2_avg_sub.WSpd_mean_sub'...
    ' FROM 	metdat.dbo.hjaws1ec2_avg_sub'...
    ' WHERE   TmStamp >= DATEADD(day, -21, GETDATE())'...
    ' ORDER BY TmStamp ASC '];

% qry = ['SELECT hjaws1ec2_avg_sub.TmStamp'...
%     ' ,	hjaws1ec2_avg_sub.RecNum'...
%     ' ,	hjaws1ec2_avg_sub.batt_volt_Min'...
%     ' ,	hjaws1ec2_avg_sub.diag_sub_Max'...
%     ' ,	hjaws1ec2_avg_sub.Panel_T_Avg'...
%     ' ,	hjaws1ec2_avg_sub.Ts_sub_Avg'...
%     ' ,	hjaws1ec2_avg_sub.Ts_sub_Std'...
%     ' ,	hjaws1ec2_avg_sub.Ux_sub_Avg'...
%     ' ,	hjaws1ec2_avg_sub.Ux_sub_Std'...
%     ' ,	hjaws1ec2_avg_sub.Uy_sub_Avg'...
%     ' ,	hjaws1ec2_avg_sub.Uy_sub_Std'...
%     ' ,	hjaws1ec2_avg_sub.Uz_sub_Avg'...
%     ' ,	hjaws1ec2_avg_sub.Uz_sub_Std'...
%     ' ,	hjaws1ec2_avg_sub.WDir_mean_sub'...
%     ' ,	hjaws1ec2_avg_sub.WDir_std_sub'...
%     ' ,	hjaws1ec2_avg_sub.WSpd_mean_sub'...
%     ' FROM 	metdat.dbo.hjaws1ec2_avg_sub'...
%     ' WHERE year(TmStamp) = 2013'...
%     ' ORDER BY TmStamp ASC '];

% qry = ['SELECT hjaws1ec2_avg_sub_arch1.TmStamp'...
%     ' ,	hjaws1ec2_avg_sub_arch1.RecNum'...
%     ' ,	hjaws1ec2_avg_sub_arch1.batt_volt_Min'...
%     ' ,	hjaws1ec2_avg_sub_arch1.diag_sub_Max'...
%     ' ,	hjaws1ec2_avg_sub_arch1.Panel_T_Avg'...
%     ' ,	hjaws1ec2_avg_sub_arch1.Ts_sub_Avg'...
%     ' ,	hjaws1ec2_avg_sub_arch1.Ts_sub_Std'...
%     ' ,	hjaws1ec2_avg_sub_arch1.Ux_sub_Avg'...
%     ' ,	hjaws1ec2_avg_sub_arch1.Ux_sub_Std'...
%     ' ,	hjaws1ec2_avg_sub_arch1.Uy_sub_Avg'...
%     ' ,	hjaws1ec2_avg_sub_arch1.Uy_sub_Std'...
%     ' ,	hjaws1ec2_avg_sub_arch1.Uz_sub_Avg'...
%     ' ,	hjaws1ec2_avg_sub_arch1.Uz_sub_Std'...
%     ' ,	hjaws1ec2_avg_sub_arch1.WDir_mean_sub'...
%     ' ,	hjaws1ec2_avg_sub_arch1.WDir_std_sub'...
%     ' ,	hjaws1ec2_avg_sub_arch1.WSpd_mean_sub'...
%     ' FROM 	metdat.dbo.hjaws1ec2_avg_sub_arch1'...
%     ' WHERE year(TmStamp) = 2013'...
%     ' ORDER BY TmStamp ASC '];

[data,msg] = sql2gceds(conn, ...
                        qry, ...
                        template, ...
                        1, ...
                        0, ...
                        1);

% %close database connection
 close(conn);


