function [data,msg] = fetch_rs20_95_table105(template)

%connect to the database
conn = database('metdat', '', '', 'Vendor', 'MICROSOFT SQL SERVER', 'Server', 'Stewartia', 'PortNumber', 1433, 'AuthType', 'Windows');

if exist('template','var') ~= 1
   template = '';
end

qry = ['SELECT RS20_95_Table105.TmStamp'...
    ' ,	RS20_95_Table105.RecNum'...
    ' ,	RS20_95_Table105.LOGGERID'...
    ' ,	RS20_95_Table105.PROGID'...
    ' ,	RS20_95_Table105.AIR_02_Avg'...
    ' ,	RS20_95_Table105.AIR_03_Avg'...
    ' ,	RS20_95_Table105.SOILT_10_Avg'...
    ' ,	RS20_95_Table105.SOILT_20_Avg'...
    ' ,	RS20_95_Table105.SOILT_30_Avg'...
    ' ,	RS20_95_Table105.BATT_Avg'...
    ' FROM 	metdat.dbo.RS20_95_Table105'...
    ' WHERE LOGGERID = 95' ...
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


