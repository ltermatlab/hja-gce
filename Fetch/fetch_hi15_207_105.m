function [data,msg] = fetch_hi15_207_105(template)

%connect to the database
conn = database('metdat', '', '', 'Vendor', 'MICROSOFT SQL SERVER', 'Server', 'Stewartia', 'PortNumber', 1433, 'AuthType', 'Windows');

if exist('template','var') ~= 1
   template = '';
end

qry = ['SELECT HI15_207_105.TmStamp'...
    ' ,	HI15_207_105.RecNum'...
    ' ,	HI15_207_105.LOGGERID'...
    ' ,	HI15_207_105.PROGID'...
    ' ,	HI15_207_105.PRECIP_PR'...
    ' ,	HI15_207_105.TIPPING_B_TOT'...
    ' FROM 	metdat.dbo.HI15_207_105 '...
    ' WHERE LOGGERID = 207' ...
    ' AND year(TmStamp) = 2014'...
    ' ORDER BY TmStamp ASC '];

% qry = ['SELECT 	HI15_207_105.TmStamp'...
%     ' ,	HI15_207_105.RecNum'...
%     ' ,	HI15_207_105.LOGGERID'...
%     ' ,	HI15_207_105.PROGID'...
%     ' ,	HI15_207_105.PRECIP_PR'...
%     ' ,	HI15_207_105.TIPPING_B_TOT'...
%     ' FROM 	metdat.dbo.HI15_207_105 '...
%     ' WHERE   TmStamp >= DATEADD(day, -21, GETDATE())'...
%     ' ORDER BY TmStamp ASC '];

[data,msg] = sql2gceds(conn, ...
                        qry, ...
                        template, ...
                        1, ...
                        0, ...
                        1);

% %close database connection
 close(conn);



