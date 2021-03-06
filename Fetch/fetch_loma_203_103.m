function [data,msg] = fetch_loma_203_103(template)

%connect to the database
conn = database('metdat', '', '', 'Vendor', 'MICROSOFT SQL SERVER', 'Server', 'Stewartia', 'PortNumber', 1433, 'AuthType', 'Windows');

if exist('template','var') ~= 1
   template = '';
end

qry = ['SELECT LOMA_203_103.TmStamp'...
    ' ,	LOMA_203_103.RecNum'...
    ' ,	LOMA_203_103.SITE_ID'...
    ' ,	LOMA_203_103.AIR_TEMP_AVG'...
    ' ,	LOMA_203_103.LOOKOUT_W_AVG'...
    ' ,	LOMA_203_103.MACK_AVG'...
    ' FROM 	metdat.dbo.LOMA_203_103 '...
    ' WHERE SITE_ID = 203' ...
    ' AND year(TmStamp) = 2014'...
    ' ORDER BY TmStamp ASC '];

[data,msg] = sql2gceds(conn, ...
                        qry, ...
                        template, ...
                        1, ...
                        0, ...
                        1);

% %close database connection
 close(conn);



