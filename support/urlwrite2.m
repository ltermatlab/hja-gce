function [f,status] = urlwrite2(urlChar,location,method,params,timeout)
%URLWRITE Save the contents of a URL to a file.
%   URLWRITE(URL,FILENAME) saves the contents of a URL to a file.  FILENAME
%   can specify the complete path to a file.  If it is just the name, it will
%   be created in the current directory.
%
%   F = URLWRITE(...) returns the path to the file.
%
%   F = URLWRITE(...,METHOD,PARAMS,TIMEOUT) passes information to the server as
%   part of the request.  The 'method' can be 'get', or 'post' and PARAMS is a
%   cell array of param/value pairs, TIMEOUT is response timeout limit in milliseconds
%
%   [F,STATUS] = URLWRITE(...) catches any errors and returns the error code. 
%
%   Examples:
%   urlwrite('http://www.mathworks.com/',[tempname '.html'])
%   urlwrite('ftp://ftp.mathworks.com/pub/pentium/Moler_1.txt','cleve.txt')
%   urlwrite('file:///C:\winnt\matlab.ini',fullfile(pwd,'my.ini'))
% 
%   From behind a firewall, use the Preferences to set your proxy server.
%
%   See also URLREAD.

%   Matthew J. Simoneau, 13-Nov-2001
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.4 $ $Date: 2004/12/27 23:33:07 $

% =========================================================================
% timeout: the reqest will be stop at a time you specified.
%
% An enhancement of urlwrite and all the modifications are labeled with (*)
% Fu-Sung Wang, 13-Sep-2005
% =========================================================================

% additional modifications to function help and syntax by Wade Sheldon on 31-Aug-2008

% This function requires Java.
if ~usejava('jvm')
   error('MATLAB:urlwrite:NoJvm','URLWRITE requires Java.');
end

import com.mathworks.mlwidgets.io.InterruptibleStreamCopier;

% Be sure the proxy settings are set.
com.mathworks.mlwidgets.html.HTMLPrefs.setProxySettings

% Check number of inputs and outputs.
% error(nargchk(2,4,nargin))
%% (*) 
error(nargchk(2,5,nargin))                
error(nargoutchk(0,2,nargout))

%% (*)
if (nargin > 2) && ~strcmpi(method,'get') && ~strcmpi(method,'post')
    error('MATLAB:urlwrite:InvalidInput','Second argument must be either "get" or "post".');
end

%set default timeout
if exist('timeout','var') ~= 1
   timeout = 60000;  %default to 60 sec
end

% Do we want to throw errors or catch them?
if nargout == 2
    catchErrors = true;
else
    catchErrors = false;
end

% Set default outputs.
f = '';
status = 0;

% GET method.  Tack param/value to end of URL.
if (nargin > 2) && strcmpi(method,'get')
    if mod(length(params),2) == 1
        error('MATLAB:urlwrite:InvalidInput','Invalid parameter/value pair arguments.');
    end
    for i=1:2:length(params)
        if (i == 1), separator = '?'; else, separator = '&'; end
        param = char(java.net.URLEncoder.encode(params{i}));
        value = char(java.net.URLEncoder.encode(params{i+1}));
        urlChar = [urlChar separator param '=' value];
    end
end

% Try to use the native handler, not the ice.* classes.
if strncmpi('http:',urlChar,5)
    try
        handler = sun.net.www.protocol.http.Handler;
    catch
        handler = [];
    end
else
    handler = [];
end

% Create the URL object.
try
    if isempty(handler)
        url = java.net.URL(urlChar);
    else
        url = java.net.URL([],urlChar,handler);
    end
catch
    if catchErrors, return
    else error('MATLAB:urlwrite:InvalidUrl','Either this URL could not be parsed or the protocol is not supported.',catchErrors);
    end
end

% Open a connection to the URL.
urlConnection = url.openConnection;

%% (*) 
urlConnection.setReadTimeout(timeout);

% POST method.  Write param/values to server.
if (nargin > 2) && strcmpi(method,'post')
    try
        urlConnection.setDoOutput(true);
        urlConnection.setRequestProperty( ...
            'Content-Type','application/x-www-form-urlencoded');
        printStream = java.io.PrintStream(urlConnection.getOutputStream);
        for i=1:2:length(params)
            if (i > 1), printStream.print('&'); end
            param = char(java.net.URLEncoder.encode(params{i}));
            value = char(java.net.URLEncoder.encode(params{i+1}));
            printStream.print([param '=' value]);
        end
        printStream.close;
    catch
        if catchErrors, return
        else error('MATLAB:urlwrite:ConnectionFailed','Could not POST to URL.');
        end
    end
end

% Specify the full path to the file so that getAbsolutePath will work when the
% current directory is not the startup directory and urlwrite is given a
% relative path.
file = java.io.File(location);
if ~file.isAbsolute
   location = fullfile(pwd,location);
   file = java.io.File(location);
end

% Make sure the path isn't nonsense.
try
   file = file.getCanonicalFile;
catch
   error('MATLAB:urlwrite:InvalidOutputLocation','Could not resolve file "%s".',char(file.getAbsolutePath));
end

% Open the output file.
try
    fileOutputStream = java.io.FileOutputStream(file);
catch
    error('MATLAB:urlwrite:InvalidOutputLocation','Could not open output file "%s".',char(file.getAbsolutePath));
end

% Read the data from the connection.
try
    inputStream = urlConnection.getInputStream;
    % This StreamCopier is unsupported and may change at any time.
    isc = InterruptibleStreamCopier.getInterruptibleStreamCopier;
    isc.copyStream(inputStream,fileOutputStream);
    inputStream.close;
    fileOutputStream.close;
    f = char(file.getAbsolutePath);
    status = 1;
catch
    if catchErrors, return
    else error('MATLAB:urlwrite:ConnectionFailed','Error downloading URL.');
    end
end
