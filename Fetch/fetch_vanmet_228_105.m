function [data,msg] = fetch_vanmet_228_105(template)

%connect to the database
conn = database('metdat', '', '', 'Vendor', 'MICROSOFT SQL SERVER', 'Server', 'Stewartia', 'PortNumber', 1433, 'AuthType', 'Windows');

if exist('template','var') ~= 1
   template = 'LNDB_VanMet_1';
end

qry = ['SELECT VAN_228_105.TmStamp'...
    ' ,	VAN_228_105.RecNum'...
    ' ,	VAN_228_105.LOGGERID'...
    ' ,	VAN_228_105.PROGID'...
    ' ,	VAN_228_105.BATTERY_V'...
    ' ,	VAN_228_105.SNOW_PILL'...
    ' ,	VAN_228_105.SNOWDEPTH'...
    ' FROM 	metdat.dbo.VAN_228_105'...
    ' WHERE year(TmStamp) = 2013'...
    ' AND LOGGERID = 228' ...
    ' ORDER BY TmStamp ASC '];

% qry = ['SELECT VAN_228_105.TmStamp'...
%     ' ,	VAN_228_105.RecNum'...
%     ' ,	VAN_228_105.LOGGERID'...
%     ' ,	VAN_228_105.PROGID'...
%     ' ,	VAN_228_105.BATTERY_V'...
%     ' ,	VAN_228_105.SNOW_PILL'...
%     ' ,	VAN_228_105.SNOWDEPTH'...
%     ' FROM 	metdat.dbo.VAN_228_105'...
%     ' WHERE   TmStamp >= DATEADD(day, -21, GETDATE())'...
%     ' AND LOGGERID = 228' ...
%     ' ORDER BY TmStamp ASC '];

[data,msg] = sql2gceds(conn, ...
                        qry, ...
                        template, ...
                        1, ...
                        0, ...
                        1);

% %close database connection
 close(conn);



