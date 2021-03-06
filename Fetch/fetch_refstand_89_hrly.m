function [data,msg] = fetch_refstand_89_hrly(template)

%connect to the database
conn = database('metdat', '', '', 'Vendor', 'MICROSOFT SQL SERVER', 'Server', 'Stewartia', 'PortNumber', 1433, 'AuthType', 'Windows');

if exist('template','var') ~= 1
   template = '';
end

qry = ['SELECT RS89_115.TmStamp'...
    ' ,	RS89_115.RecNum'...
    ' ,	RS89_115.SITE_ID'...
    ' ,	RS89_115.AIR_TEMP_AVG'...
    ' ,	RS89_115.REL_HUM_AVG'...
    ' FROM 	metdat.dbo.RS89_115 '...
    ' WHERE SITE_ID = 89' ...
    ' ORDER BY TmStamp ASC'];

[data,msg] = sql2gceds(conn, ...
                        qry, ...
                        template, ...
                        1, ...
                        0, ...
                        1);

% %close database connection
 close(conn);



