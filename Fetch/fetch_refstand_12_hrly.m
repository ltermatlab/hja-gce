function [data,msg] = fetch_refstand_12_hrly(template)

%connect to the database
conn = database('metdat', '', '', 'Vendor', 'MICROSOFT SQL SERVER', 'Server', 'Stewartia', 'PortNumber', 1433, 'AuthType', 'Windows');

if exist('template','var') ~= 1
   template = '';
end

qry = ['SELECT RS12_115.TmStamp'...
    ' ,	RS12_115.RecNum'...
    ' ,	RS12_115.SITE_ID'...
    ' ,	RS12_115.AIR_TEMP_AVG'...
    ' FROM 	metdat.dbo.RS12_115'...
    ' WHERE SITE_ID = 12' ...
    ' ORDER BY TmStamp ASC'];

[data,msg] = sql2gceds(conn, ...
                        qry, ...
                        template, ...
                        1, ...
                        0, ...
                        1);

% %close database connection
 close(conn);


