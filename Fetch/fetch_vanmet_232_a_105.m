function [data,msg] = fetch_vanmet_232_a_105(template)

%connect to the database
conn = database('metdat', '', '', 'Vendor', 'MICROSOFT SQL SERVER', 'Server', 'Stewartia', 'PortNumber', 1433, 'AuthType', 'Windows');

if exist('template','var') ~= 1
   template = '';
end

qry = ['SELECT VAN_232_rad_temp_avg.TmStamp'...
    ' ,	VAN_232_rad_temp_avg.RecNum'...
    ' ,	VAN_232_rad_temp_avg.LOGGERID'...
    ' ,	VAN_232_rad_temp_avg.PROGID'...
    ' ,	VAN_232_rad_temp_avg.IR01DnCo_Avg'...
    ' ,	VAN_232_rad_temp_avg.IR01UpCo_Avg'...
    ' ,	VAN_232_rad_temp_avg.NetTot_Avg'...
    ' ,	VAN_232_rad_temp_avg.SR01Dn_Avg'...
    ' ,	VAN_232_rad_temp_avg.SR01Up_Avg'...
    ' ,	VAN_232_rad_temp_avg.NR01TC_Avg'...
    ' FROM 	metdat.dbo.VAN_232_rad_temp_avg'...
    ' WHERE year(TmStamp) = 2015'...
    ' ORDER BY TmStamp ASC '];

% qry = ['SELECT VAN_232_rad_temp_avg.TmStamp'...
%     ' ,	VAN_232_rad_temp_avg.RecNum'...
%     ' ,	VAN_232_rad_temp_avg.LOGGERID'...
%     ' ,	VAN_232_rad_temp_avg.PROGID'...
%     ' ,	VAN_232_rad_temp_avg.IR01DnCo_Avg'...
%     ' ,	VAN_232_rad_temp_avg.IR01UpCo_Avg'...
%     ' ,	VAN_232_rad_temp_avg.NetTot_Avg'...
%     ' ,	VAN_232_rad_temp_avg.SR01Dn_Avg'...
%     ' ,	VAN_232_rad_temp_avg.SR01Up_Avg'...
%     ' ,	VAN_232_rad_temp_avg.NR01TC_Avg'...
%     ' FROM 	metdat.dbo.VAN_232_rad_temp_avg'...
%     ' WHERE   TmStamp >= DATEADD(day, -21, GETDATE())'...
%     ' AND LOGGERID = 232' ...
%     ' ORDER BY TmStamp ASC '];

[data,msg] = sql2gceds(conn, ...
                        qry, ...
                        template, ...
                        1, ...
                        0, ...
                        1);

% %close database connection
 close(conn);

