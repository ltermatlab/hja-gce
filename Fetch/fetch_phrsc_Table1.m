function [data,msg] = fetch_phrsc_Table1(template)

%connect to the database
conn = database('metdat', '', '', 'Vendor', 'MICROSOFT SQL SERVER', 'Server', 'Stewartia', 'PortNumber', 1433, 'AuthType', 'Windows');

if exist('template','var') ~= 1
   template = '';
end

qry = ['SELECT PHRSC_Table1.TmStamp'...
    ' ,	PHRSC_Table1.RecNum'...
    ' ,	PHRSC_Table1.CM3_Dn_Avg'...
    ' ,	PHRSC_Table1.CM3_Up_Avg'...
    ' ,	PHRSC_Table1.Cotton_Avg'...
    ' ,	PHRSC_Table1.Gill_AF_Avg'...
    ' ,	PHRSC_Table1.Gill_Lg_Avg'...
    ' ,	PHRSC_Table1.Gill_Sh_Avg'...
    ' ,	PHRSC_Table1.HJA_Lg_Avg'...
    ' ,	PHRSC_Table1.HJA_Sh_Avg'...
    ' ,	PHRSC_Table1.RMY_ASP_Avg'...
    ' ,	PHRSC_Table1.WindDir'...
    ' ,	PHRSC_Table1.WindSp_Avg'...
    '   FROM metdat.dbo.PHRSC_Table1'...
    '   WHERE year(TmStamp) = 2015'...
    '   ORDER BY TmStamp ASC '];

% qry = ['SELECT PHRSC_Table1.TmStamp'...
%     ' ,	PHRSC_Table1.RecNum'...
%     ' ,	PHRSC_Table1.CM3_Dn_Avg'...
%     ' ,	PHRSC_Table1.CM3_Up_Avg'...
%     ' ,	PHRSC_Table1.Cotton_Avg'...
%     ' ,	PHRSC_Table1.Gill_AF_Avg'...
%     ' ,	PHRSC_Table1.Gill_Lg_Avg'...
%     ' ,	PHRSC_Table1.Gill_Sh_Avg'...
%     ' ,	PHRSC_Table1.HJA_Lg_Avg'...
%     ' ,	PHRSC_Table1.HJA_Sh_Avg'...
%     ' ,	PHRSC_Table1.RMY_ASP_Avg'...
%     ' ,	PHRSC_Table1.WindDir'...
%     ' ,	PHRSC_Table1.WindSp_Avg'...
%     '     FROM metdat.dbo.PHRSC_Table1'...
%     '     WHERE TmStamp >= DATEADD(day, -31, GETDATE())'...
%     '     ORDER BY TmStamp ASC '];

[data,msg] = sql2gceds(conn, ...
                        qry, ...
                        template, ...
                        1, ...
                        0, ...
                        1);

% %close database connection
 close(conn);


