function [data,msg] = fetch_vanmet_231_Table160(template)

%connect to the database
conn = database('metdat', '', '', 'Vendor', 'MICROSOFT SQL SERVER', 'Server', 'Stewartia', 'PortNumber', 1433, 'AuthType', 'Windows');

if exist('template','var') ~= 1
   template = '';
end

% qry = ['SELECT Van_231_Table160.TmStamp'...
%     ' ,	Van_231_Table160.RecNum'...
%     ' ,	Van_231_Table160.PROGID'...
%     ' ,	Van_231_Table160.LOGGERID'...
%     ' ,	Van_231_Table160.SOILT_10_Avg'...
%     ' ,	Van_231_Table160.SOILT_20_Avg'...
%     ' ,	Van_231_Table160.SOILT_50_Avg'...
%     ' ,	Van_231_Table160.SOILT_100_Avg'...
%     ' ,	Van_231_Table160.WCRWC_10'...
%     ' ,	Van_231_Table160.WCRWC_20'...
%     ' ,	Van_231_Table160.WCRWC_50'...
%     ' ,	Van_231_Table160.WCRWC_100'...
%     ' FROM 	metdat.dbo.Van_231_Table160'...
%     ' WHERE   TmStamp >= DATEADD(day, -21, GETDATE())'...
%     ' ORDER BY TmStamp ASC '];

qry = ['SELECT Van_231_Table160.TmStamp'...
    ' ,	Van_231_Table160.RecNum'...
    ' ,	Van_231_Table160.PROGID'...
    ' ,	Van_231_Table160.LOGGERID'...
    ' ,	Van_231_Table160.SOILT_10_Avg'...
    ' ,	Van_231_Table160.SOILT_20_Avg'...
    ' ,	Van_231_Table160.SOILT_50_Avg'...
    ' ,	Van_231_Table160.SOILT_100_Avg'...
    ' ,	Van_231_Table160.WCRWC_10'...
    ' ,	Van_231_Table160.WCRWC_20'...
    ' ,	Van_231_Table160.WCRWC_50'...
    ' ,	Van_231_Table160.WCRWC_100'...
    ' FROM 	metdat.dbo.Van_231_Table160'...
    ' WHERE year(TmStamp) = 2013'...
    ' AND LOGGERID = 231' ...
    ' ORDER BY TmStamp ASC '];

[data,msg] = sql2gceds(conn, ...
                        qry, ...
                        template, ...
                        1, ...
                        0, ...
                        1);

% %close database connection
 close(conn);


