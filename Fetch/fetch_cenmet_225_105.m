function [data,msg] = fetch_cenmet_225_105(template)

%connect to the database
conn = database('metdat', '', '', 'Vendor', 'MICROSOFT SQL SERVER', 'Server', 'Stewartia', 'PortNumber', 1433, 'AuthType', 'Windows');

if exist('template','var') ~= 1
   template = '';
end

qry = ['SELECT CENT_225_105.TmStamp'...
     ' ,	CENT_225_105.RecNum'...
     ' ,	CENT_225_105.LOGGERID'...
     ' ,	CENT_225_105.PROGID'...
     ' ,	CENT_225_105.BATTERY_V'...
     ' ,	CENT_225_105.SA_PRECIP'...
     ' ,	CENT_225_105.SA_TEMP'...
     ' ,	CENT_225_105.SH_PRECIP'...
     ' ,	CENT_225_105.SH_TEMP'...
     ' ,	CENT_225_105.SNOW_MOIS'...
     ' ,	CENT_225_105.SNOWDEPTH'...
     ' ,	CENT_225_105.TIPPING_B_TOT'...
     ' FROM metdat.dbo.CENT_225_105'...
     ' WHERE year(TmStamp) = 2015'...
     ' AND LOGGERID = 225' ...
     ' ORDER BY TmStamp ASC '];

% qry = ['SELECT CENT_225_105.TmStamp'...
%    ' ,	CENT_225_105.RecNum'...
%    ' ,	CENT_225_105.LOGGERID'...
%    ' ,	CENT_225_105.PROGID'...
%    ' ,	CENT_225_105.BATTERY_V'...
%    ' ,	CENT_225_105.SA_PRECIP'...
%    ' ,	CENT_225_105.SA_TEMP'...
%    ' ,	CENT_225_105.SH_PRECIP'...
%    ' ,	CENT_225_105.SH_TEMP'...
%    ' ,	CENT_225_105.SNOW_MOIS'...
%    ' ,	CENT_225_105.SNOWDEPTH'...
%    ' ,	CENT_225_105.TIPPING_B_TOT'...
%    ' FROM 	metdat.dbo.CENT_225_105'...
%    ' WHERE   TmStamp >= DATEADD(day, -21, GETDATE())'...
%    ' AND LOGGERID = 225' ...
%    ' ORDER BY TmStamp ASC '];

[data,msg] = sql2gceds(conn, ...
                        qry, ...
                        template, ...
                        1, ...
                        0, ...
                        1);

% %close database connection
 close(conn);



