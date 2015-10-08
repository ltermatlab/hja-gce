function signature_email(sitecode, data)

%% Data harvester processing signature. This script is triggered with each succesful completion of a GCE data harvester. To include other email recipients, use the following modification:
% matlabmail({'test@email.com','first.new@email.com','second.new@email.com'}, ...
% Note that this will send a lot of daily emails. Warn recipients hlkjhlkjh.

% Declare what you would like to say
 A1 = datestr(now);   % get the current datetime string
 A2 = sitecode;   % define the sitecode
 c1 = now;   % get the current datetime number
 c2 = datenum(data.values{2}(end));   % Get the current datetime number of the last row
 A3 = num2str(daysact(floor(c1-c2)));  % Subtrace current datenumber from date number of last row to calculate number of days behind.
 A4 = data.values{2};   %Get the Date column
    A4_beg = datestr(A4(1,:));
    A4_end = datestr(A4(end,:));
 A5 = data.name(1,1:length(data.name));             

% Stop the clock
%tEnd = toc;

% Send the email
matlabmail({'adam.kennedy@oregonstate.edu'}, ...
    [['[GCE@HJA] ' sitecode ' is behind ' A3 ' day(s)'] ...
    ['Date range of file is: ' A4_beg ' - ' A4_end '.'] ...
    ' ' ...
    'Processed variables include: ' A5], ...
    [A2 ' data harvester completed on ' A1]);