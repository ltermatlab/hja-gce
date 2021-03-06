function [data,msg] = fetch_rs02_90_table105(template)

%connect to the database
conn = database('metdat', '', '', 'Vendor', 'MICROSOFT SQL SERVER', 'Server', 'Stewartia', 'PortNumber', 1433, 'AuthType', 'Windows');

if exist('template','var') ~= 1
   template = '';
end

qry = ['SELECT RS02_90_Table105.TmStamp'...
    ' ,	RS02_90_Table105.RecNum'...
    ' ,	RS02_90_Table105.LOGGERID'...
    ' ,	RS02_90_Table105.PROGID'...
    ' ,	RS02_90_Table105.AIR_02_Avg'...
    ' ,	RS02_90_Table105.AIR_03_Avg'...
    ' ,	RS02_90_Table105.SOILT_10_Avg'...
    ' ,	RS02_90_Table105.SOILT_20_Avg'...
    ' ,	RS02_90_Table105.SOILT_30_Avg'...
    ' ,	RS02_90_Table105.BATT_Avg'...
    ' FROM 	metdat.dbo.RS02_90_Table105'...
    ' WHERE LOGGERID = 90' ...
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



