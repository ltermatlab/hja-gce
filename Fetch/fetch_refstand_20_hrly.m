function [data,msg] = fetch_refstand_20_hrly(template)

%connect to the database
conn = database('metdat', '', '', 'Vendor', 'MICROSOFT SQL SERVER', 'Server', 'Stewartia', 'PortNumber', 1433, 'AuthType', 'Windows');

if exist('template','var') ~= 1
   template = '';
end

qry = ['SELECT RS20_115.TmStamp'...
    ' ,	RS20_115.RecNum'...
    ' ,	RS20_115.SITE_ID'...
    ' ,	RS20_115.AIR_TEMP_AVG'...
    ' FROM 	metdat.dbo.RS20_115'...
    ' WHERE SITE_ID = 20' ...
    ' ORDER BY TmStamp ASC'];

[data,msg] = sql2gceds(conn, ...
                        qry, ...
                        template, ...
                        1, ...
                        0, ...
                        1);

% %close database connection
 close(conn);



