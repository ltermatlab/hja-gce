function [data,msg] = fetch_refstand_86_dly(template)

%connect to the database
conn = database('metdat', '', '', 'Vendor', 'MICROSOFT SQL SERVER', 'Server', 'Stewartia', 'PortNumber', 1433, 'AuthType', 'Windows');

if exist('template','var') ~= 1
   template = '';
end

qry = ['SELECT RS86_105.TmStamp'...
    ' ,	RS86_105.RecNum'...
    ' ,	RS86_105.SITE_ID'...
    ' ,	RS86_105.AIR_TEMP_AVG'...
    ' ,	RS86_105.SOILT_10_AVG'...
    ' ,	RS86_105.SOILT_20_AVG'...
    ' ,	RS86_105.SOILT_30_AVG'...
    ' ,	RS86_105.REL_HUM_AVG'...
    ' ,	RS86_105.AIR_TEMP_MAX'...
    ' ,	RS86_105.AIR_TEMP_Hr_Min_MAX'...
    ' ,	RS86_105.SOILT_10_MAX'...
    ' ,	RS86_105.SOILT_10_Hr_Min_MAX'...
    ' ,	RS86_105.SOILT_20_MAX'...
    ' ,	RS86_105.SOILT_20_Hr_Min_MAX'...
    ' ,	RS86_105.SOILT_30_MAX'...
    ' ,	RS86_105.SOILT_30_Hr_Min_MAX'...
    ' ,	RS86_105.REL_HUM_MAX'...
    ' ,	RS86_105.REL_HUM_Hr_Min_MAX'...
    ' ,	RS86_105.AIR_TEMP_MIN'...
    ' ,	RS86_105.AIR_TEMP_Hr_Min_MIN'...
    ' ,	RS86_105.SOILT_10_MIN'...
    ' ,	RS86_105.SOILT_10_Hr_Min_MIN'...
    ' ,	RS86_105.SOILT_20_MIN'...
    ' ,	RS86_105.SOILT_20_Hr_Min_MIN'...
    ' ,	RS86_105.SOILT_30_MIN'...
    ' ,	RS86_105.SOILT_30_Hr_Min_MIN'...
    ' ,	RS86_105.REL_HUM_MIN'...
    ' ,	RS86_105.REL_HUM_Hr_Min_MIN'...
    ' FROM 	metdat.dbo.RS86_105 '...
    ' WHERE DATEPART(hh, TmStamp) = 00'...
    ' AND SITE_ID = 86' ...
    ' ORDER BY TmStamp ASC '];

[data,msg] = sql2gceds(conn, ...
                        qry, ...
                        template, ...
                        1, ...
                        0, ...
                        1);

% %close database connection
 close(conn);


