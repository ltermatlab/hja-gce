function [data,msg] = fetch_rs04_91_table105(template)

%connect to the database
conn = database('metdat', '', '', 'Vendor', 'MICROSOFT SQL SERVER', 'Server', 'Stewartia', 'PortNumber', 1433, 'AuthType', 'Windows');

if exist('template','var') ~= 1
   template = '';
end

qry = ['SELECT RS04_91_Table105.TmStamp'...
    ' ,	RS04_91_Table105.RecNum'...
    ' ,	RS04_91_Table105.LOGGERID'...
    ' ,	RS04_91_Table105.PROGID'...
    ' ,	RS04_91_Table105.AIR_02_Avg'...
    ' ,	RS04_91_Table105.AIR_03_Avg'...
    ' ,	RS04_91_Table105.SOILT_10_Avg'...
    ' ,	RS04_91_Table105.SOILT_20_Avg'...
    ' ,	RS04_91_Table105.SOILT_30_Avg'...
    ' ,	RS04_91_Table105.BATT_Avg'...
    ' FROM 	metdat.dbo.RS04_91_Table105'...
    ' WHERE LOGGERID = 91' ...
    ' AND year(TmStamp) = 2015'...
    ' ORDER BY TmStamp ASC'];

[data,msg] = sql2gceds(conn, ...
                        qry, ...
                        template, ...
                        1, ...
                        0, ...
                        1);

% %close database connection
 close(conn);



