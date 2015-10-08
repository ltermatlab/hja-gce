function [data,msg] = fetch_gsmack_111_105(template)

%connect to the database
conn = database('metdat', '', '', 'Vendor', 'MICROSOFT SQL SERVER', 'Server', 'Stewartia', 'PortNumber', 1433, 'AuthType', 'Windows');

if exist('template','var') ~= 1
   template = '';
end

qry = ['SELECT Mack_111_105.TmStamp'...
     ' ,	Mack_111_105.RecNum'...
     ' ,	Mack_111_105.LoggerID'...
     ' ,	Mack_111_105.ProgID'...
     ' ,	Mack_111_105.C25mScm_1'...
     ' ,	Mack_111_105.CDH2O_TMP'...
     ' ,	Mack_111_105.FISHSTAGE'...
     ' ,	Mack_111_105.PRECIP'...
     ' ,	Mack_111_105.STAGE'...
     ' FROM metdat.dbo.Mack_111_105'...
     ' WHERE LOGGERID = 111' ...
     ' ORDER BY TmStamp ASC'];

% qry = ['SELECT 	Mack_111_105.TmStamp'...
%   ' ,	Mack_111_105.RecNum'...
%    ' ,	Mack_111_105.LoggerID'...
%    ' ,	Mack_111_105.ProgID'...
%    ' ,	Mack_111_105.C25mScm_1'...
%    ' ,	Mack_111_105.CDH2O_TMP'...
%    ' ,	Mack_111_105.FISHSTAGE'...
%    ' ,	Mack_111_105.PRECIP'...
%    ' ,	Mack_111_105.STAGE'...
%    '    FROM metdat.dbo.Mack_111_105'...
%    '    WHERE LOGGERID = 111' ...
%    '    AND TmStamp >= DATEADD(day, -21, GETDATE())'...
%    '    ORDER BY TmStamp ASC '];

[data,msg] = sql2gceds(conn, ...
                        qry, ...
                        template, ...
                        1, ...
                        0, ...
                        1);

% %close database connection
 close(conn);



