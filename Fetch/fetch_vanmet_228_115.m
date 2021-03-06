function [data,msg] = fetch_vanmet_228_115(template)

%connect to the database
conn = database('metdat', '', '', 'Vendor', 'MICROSOFT SQL SERVER', 'Server', 'Stewartia', 'PortNumber', 1433, 'AuthType', 'Windows');

if exist('template','var') ~= 1
   template = 'LNDB_VanMet_1';
end

qry = ['SELECT VAN_228_115.TmStamp'...
    ' ,	VAN_228_115.RecNum'...
    ' ,	VAN_228_115.LOGGERID'...
    ' ,	VAN_228_115.PROGID'...
    ' ,	VAN_228_115.AIR_150_AVG'...
    ' ,	VAN_228_115.AIR_250_AVG'...
    ' ,	VAN_228_115.AIR_350_AVG'...
    ' ,	VAN_228_115.AIR_450_AVG'...
    ' ,	VAN_228_115.SOLAR_MJ_TOT'...
    ' ,	VAN_228_115.SOLAR_Wm2_AVG'...
    ' FROM 	metdat.dbo.VAN_228_115'...
    ' WHERE year(TmStamp) = 2013'...
    ' AND LOGGERID = 228' ...
    ' ORDER BY TmStamp ASC '];

% qry = ['SELECT 	VAN_228_115.TmStamp'...
%     ' ,	VAN_228_115.RecNum'...
%     ' ,	VAN_228_115.LOGGERID'...
%     ' ,	VAN_228_115.PROGID'...
%     ' ,	VAN_228_115.AIR_150_AVG'...
%     ' ,	VAN_228_115.AIR_250_AVG'...
%     ' ,	VAN_228_115.AIR_350_AVG'...
%     ' ,	VAN_228_115.AIR_450_AVG'...
%     ' ,	VAN_228_115.SOLAR_MJ_TOT'...
%     ' ,	VAN_228_115.SOLAR_Wm2_AVG'...
%     ' FROM 	metdat.dbo.VAN_228_115'...
%     ' WHERE   TmStamp >= DATEADD(day, -21, GETDATE())'...
% ' AND LOGGERID = 228' ...
%     ' ORDER BY TmStamp ASC '];

[data,msg] = sql2gceds(conn, ...
                        qry, ...
                        template, ...
                        1, ...
                        0, ...
                        1);

% %close database connection
 close(conn);


