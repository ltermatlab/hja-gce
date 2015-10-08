function [data,msg] = fetch_refstand_02_dly(template)

%connect to the database
conn = database('metdat', '', '', 'Vendor', 'MICROSOFT SQL SERVER', 'Server', 'Stewartia', 'PortNumber', 1433, 'AuthType', 'Windows');

if exist('template','var') ~= 1
   template = 'LNDB_RefStand_Daily_1';
end

qry = ['SELECT RS02_105.TmStamp'...
    ' ,	RS02_105.RecNum'...
    ' ,	RS02_105.SITE_ID'...
    ' ,	RS02_105.AIR_TEMP_AVG'...
    ' ,	RS02_105.SOILT_10_AVG'...
    ' ,	RS02_105.SOILT_20_AVG'...
    ' ,	RS02_105.SOILT_30_AVG'...
    ' ,	RS02_105.AIR_TEMP_MAX'...
    ' ,	RS02_105.AIR_TEMP_Hr_Min_MAX'...
    ' ,	RS02_105.SOILT_10_MAX'...
    ' ,	RS02_105.SOILT_10_Hr_Min_MAX'...
    ' ,	RS02_105.SOILT_20_MAX'...
    ' ,	RS02_105.SOILT_20_Hr_Min_MAX'...
    ' ,	RS02_105.SOILT_30_MAX'...
    ' ,	RS02_105.SOILT_30_Hr_Min_MAX'...
    ' ,	RS02_105.AIR_TEMP_MIN'...
    ' ,	RS02_105.AIR_TEMP_Hr_Min_MIN'...
    ' ,	RS02_105.SOILT_10_MIN'...
    ' ,	RS02_105.SOILT_10_Hr_Min_MIN'...
    ' ,	RS02_105.SOILT_20_MIN'...
    ' ,	RS02_105.SOILT_20_Hr_Min_MIN'...
    ' ,	RS02_105.SOILT_30_MIN'...
    ' ,	RS02_105.SOILT_30_Hr_Min_MIN'...
    ' FROM 	metdat.dbo.RS02_105'...
    ' WHERE DATEPART(hh, TmStamp) = 00'...
    ' AND year(TmStamp) = 2014'...
    ' AND SITE_ID = 2' ...
    ' ORDER BY TmStamp ASC '];

[data,msg] = sql2gceds(conn, ...
                        qry, ...
                        template, ...
                        1, ...
                        0, ...
                        1);

% %close database connection
 close(conn);


