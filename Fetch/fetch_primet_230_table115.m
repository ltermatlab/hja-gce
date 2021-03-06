function [data,msg] = fetch_primet_230_table115(template)

%connect to the database
conn = database('metdat', '', '', 'Vendor', 'MICROSOFT SQL SERVER', 'Server', 'Stewartia', 'PortNumber', 1433, 'AuthType', 'Windows');

if exist('template','var') ~= 1
   template = '';
end

qry = ['SELECT PRIM_230_Table115.TmStamp'...
    ' ,	PRIM_230_Table115.RecNum'...
    ' ,	PRIM_230_Table115.LOGGERID'...
    ' ,	PRIM_230_Table115.PROGID'...
    ' ,	PRIM_230_Table115.BP_mb'...
    ' ,	PRIM_230_Table115.SOLAR_MJ_Tot'...
    ' ,	PRIM_230_Table115.SOLAR_Wm2_Avg'...
    ' FROM 	metdat.dbo.PRIM_230_Table115'...
    ' WHERE   TmStamp >= DATEADD(day, -21, GETDATE())'...
    ' AND LOGGERID = 230' ...
    ' ORDER BY TmStamp ASC '];

% qry = ['SELECT PRIM_230_Table115.TmStamp'...
%     ' ,	PRIM_230_Table115.RecNum'...
%     ' ,	PRIM_230_Table115.LOGGERID'...
%     ' ,	PRIM_230_Table115.PROGID'...
%     ' ,	PRIM_230_Table115.BP_mb'...
%     ' ,	PRIM_230_Table115.SOLAR_Wm2_Avg'...
%     ' FROM 	metdat.dbo.PRIM_230_Table115'...
%     ' WHERE year(TmStamp) = 2013'...
%     ' AND LOGGERID = 230' ...
%     ' ORDER BY TmStamp ASC'];

% qry = ['SELECT PRIM_230_Table115_arch4.TmStamp'...
%     ' ,	PRIM_230_Table115_arch4.RecNum'...
%     ' ,	PRIM_230_Table115_arch4.LOGGERID'...
%     ' ,	PRIM_230_Table115_arch4.PROGID'...
%     ' ,	PRIM_230_Table115_arch4.BP_mb'...
%     ' ,	PRIM_230_Table115_arch4.SOLAR_Wm2_Avg'...
%     ' FROM 	metdat.dbo.PRIM_230_Table115_arch4'...
%     ' WHERE year(TmStamp) = 2013'...
%     ' AND LOGGERID = 230' ...
%     ' ORDER BY TmStamp ASC'];

% qry = ['SELECT PRIM_230_Table115_arch3.TmStamp'...
%     ' ,	PRIM_230_Table115_arch3.RecNum'...
%     ' ,	PRIM_230_Table115_arch3.LOGGERID'...
%     ' ,	PRIM_230_Table115_arch3.PROGID'...
%     ' ,	PRIM_230_Table115_arch3.BP_mb'...
%     ' ,	PRIM_230_Table115_arch3.SOLAR_Wm2_Avg'...
%     ' FROM 	metdat.dbo.PRIM_230_Table115_arch3'...
%     ' WHERE year(TmStamp) = 2013'...
%     ' AND LOGGERID = 230' ...
%     ' ORDER BY TmStamp ASC'];

% qry = ['SELECT PRIM_230_Table115_arch2.TmStamp'...
%     ' ,	PRIM_230_Table115_arch2.RecNum'...
%     ' ,	PRIM_230_Table115_arch2.LOGGERID'...
%     ' ,	PRIM_230_Table115_arch2.PROGID'...
%     ' ,	PRIM_230_Table115_arch2.BP_mb'...
%     ' ,	PRIM_230_Table115_arch2.SOLAR_Wm2_Avg'...
%     ' FROM 	metdat.dbo.PRIM_230_Table115_arch2'...
%     ' WHERE year(TmStamp) = 2013'...
%     ' AND LOGGERID = 230' ...
%     ' ORDER BY TmStamp ASC'];

[data,msg] = sql2gceds(conn, ...
                        qry, ...
                        template, ...
                        1, ...
                        0, ...
                        1);

% %close database connection
 close(conn);



