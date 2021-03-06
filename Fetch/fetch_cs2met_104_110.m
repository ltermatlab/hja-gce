function [data,msg] = fetch_cs2met_104_110(template)

%connect to the database
conn = database('metdat', '', '', 'Vendor', 'MICROSOFT SQL SERVER', 'Server', 'Stewartia', 'PortNumber', 1433, 'AuthType', 'Windows');

if exist('template','var') ~= 1
   template = '';
end

qry = ['SELECT 	CS2MET_CLIM_110.TmStamp'...
    ' ,	CS2MET_CLIM_110.RecNum'...
    ' ,	CS2MET_CLIM_110.SITE_ID'...
    ' ,	CS2MET_CLIM_110.RH_150_AVG'...
    ' ,	CS2MET_CLIM_110.DEWPT_150_AVG'...
    ' ,	CS2MET_CLIM_110.VAPDEF150_AVG'...
    '   FROM 	metdat.dbo.CS2MET_CLIM_110 '...
    '   WHERE SITE_ID = 104' ...
    '   AND year(TmStamp) 2014'...
    '   ORDER BY TmStamp ASC '];

[data,msg] = sql2gceds(conn, ...
                        qry, ...
                        template, ...
                        1, ...
                        0, ...
                        1);

% %close database connection
 close(conn);



