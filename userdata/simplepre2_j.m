%%% EASYPRE.m

function [Results] = simplepre2_j(GaugeCol, FlagCol, Station, data);

%%% SIMPLEPRE2 is a script to take raw gauge height and run it through a
%%% state algorithm, generating a smart precip diff that can then be put
%%% back into a GCE data structure. The function takes arguements of
%%% GaugeCol and FlagCol, respectively, which are the columns in
%%% data.values and data.flags from the GCE data structure that they
%%% represent. The third argument to the function is Station. Station, as
%%% long as it is not CS2MET, will not do anything. The reason for the
%%% Station arguement is to set a different tolerance threshold for the 15
%%% minute incoming data.

%%% The Results array was originally generated so that it could match with
%%% the outputs of MS043. Since this is no longer a priority, simmplepre2
%%% is designed to be more minimalist.

%%% DATENUM | ACCUMULATED RAIN | RAW GAUGE | BASELINE MEASUREMENTS |
%%% DIFFERENCE BETWEEN SUBSEQUENT MEASUREMENTS | FLAG | ORIGINAL GAGE |
%%% ORIGINAL FLAG

%%% The meaning of the loop will be described within the loop as comments.

%%% The loop initiates with 2 measurements from the data before moving into
%%% the main function.

%%% The initial measurement of the RawGauge is assumed to the the baseline,
%%% and it is likely not '0'. If this is not the case, one need take note so
%%% a conversion can be done.

%%% Station can be UPLMET, PRIMET, VANMET, H15MET, CENMET, CS2MET.
%%% GaugeCol is the column of the gauge. FlagCol is the column of the
%%% flags.


% beginning... if the station is NOT 'CS2MET'
if strcmpi(Station,'CS2MET')~= 1;
    
    %%% COMMENT IN A FILE FOR PROCESSING DEPENDING ON WHICH WE WANT TO
    %%% DO:
    
    % CENMET, SH
%     load cenmet_225_5min_2015.mat;
%     GaugeCol = 10;
%     FlagCol = 10;
%     Station = 'CENMET';
%     Probe_Code = 'PPTCEN02';
%     Height = 455;
%     Method = 'PPT017';
%     dMethod = 'PPT117';
%     HighResOut = 'CENMET_SHx2015.csv';
%     fid1 = fopen(HighResOut, 'w');
    
    % CENMET, SA
%     load cenmet_225_5min_2015.mat;
%     GaugeCol = 7;
%     FlagCol = 7;
%     Station = 'CENMET';
%     Probe_Code = 'PPTCEN01';
%     Height = 655;
%     Method = 'PPT017';
%     dMethod = 'PPT117';
%     HighResOut = 'CENMET_SAx2015.csv';
%     fid1 = fopen(HighResOut, 'w');
    
%     % UPLMET, SH
%     load uplmet_227_5min_2014.mat;
%     GaugeCol = 7;
%     FlagCol = 7;
%     Station = 'UPLMET';
%     Probe_Code = 'PPTUPL01';
%     Method = 'PPT015';
%     dMethod = 'PPT115';
%     Height = 455;
%     HighResOut = 'UPLMET_SAx2015.csv';
%     fid1 = fopen(HighResOut,'w');
    
    % UPLMET, SA
%     load uplmet_227_5min_2014.mat;
%     GaugeCol = 10;
%     FlagCol = 10;
%     Station = 'UPLMET';
%     Probe_Code = 'PPTUPL02';
%     Method = 'PPT015';
%     dMethod = 'PPT115';
%     Height = 455;
%     HighResOut = 'UPLMET_SHx2015.csv';
%     fid1 = fopen(HighResOut,'w');
    
    %VANILLA LEAF, SA
    %load varmet_302_a_5min_2015.mat;
    %GaugeCol = 5;
    %FlagCol = 5;
    %Station = 'VARMET';
%     Probe_Code = 'PPTVAR01';
%     Method = 'PPT015';
%     dMethod = 'PPT115';
%     Height = 455;
    HighResOut = 'x5.csv';
    fid1 = fopen(HighResOut,'w');
    
    % H15MET
%     load hi15_207_5min_2014.mat;
%     Station = 'H15MET';
%     Probe_Code = 'PPTH1502';
%     GaugeCol = 6;
%     FlagCol = 6;
%     dMethod = 'PPT118';
%     Method = 'PPT018';
%     Height = 250;
%     HighResOut = 'H15MET_SHx2015.csv';
%     fid1 = fopen(HighResOut,'w');
    
    % if the station is CS2MET, different behavior
elseif strcmpi(Station,'CS2MET') ==1 ;
    
    %load cs2met_clrg_15min_2015.mat;
    %GaugeCol = 6;
    %FlagCol = 6;
    %Station = 'CS2MET';
%     Probe_Code = 'PPTCS201';
%     Method = 'PPT018';
%     dMethod = 'PPt118';
%     Height = 455;
    HighResOut = 'x15.csv';
    fid1 = fopen(HighResOut,'w');
    
    
    % default exception handler
else fprintf(1,'%s\n', 'Sorry, please put in a valid station!');
    
end

% Results holds all the records
% DATE TIME | RAW HEIGHT | RAW DIFF | CORR DIFF | RAW FLAG | OUR FLAG
Results = cell(length(data.values{1,1}),7);

% Height (RawGauge) of the first gauge height; no difference (Diff)
% since last, Baseline is same as raw height, Original Flag is given,
% human date is the ML Serial DN
RawGauge = data.values{1,GaugeCol}(1,1);  Diff = 0; Baseline = data.values{1,GaugeCol}(1,1); OriFlag = data.flags{1,FlagCol}(1,1); HumanDate = data.values{1,2}(1,1);
% Height (RawGauge) of the first gauge height; instantiate difference
% as 0, Baseline is same as raw height, Original Flag is given, human
% date is the ML Serial DN
RawGauge2 = data.values{1,GaugeCol}(2,1); Diff2 = 0; Baseline2 = data.values{1,GaugeCol}(2,1); OriFlag2 = data.flags{1,FlagCol}(2,1); HumanDate2 = data.values{1,2}(2,1);

% Corrected difference is 0- nothing has happened yet!
CorrDiff = 0;


% Assign "acceptable" flag,
Flag = 'A';

% Adding "I" criteria if the first flag seen is an "I"
if strcmpi(OriFlag,'I');
   Flag = 'I';
end

%%% Vectorized dates to be used for telling midnight to midnight diffs
%%% for checking.
vectordate = zeros(length(data.values{1,1}),6);
vectordate(1,:) = datevec(HumanDate);  % vectorized date
vectordate(2,:) = datevec(HumanDate2); % vectorized date

%%% "States" based on Diff. A state machine is a mathematical model of
%%% computation used to design both computer programs and sequential
%%% logic circuits. It is conceived as an abstract machine that can be
%%% in one of a finite number of states. The machine is in only one
%%% state at a time; the state it is in at any given time is called the
%%% current state. It can change from one state to another when
%%% initiated by a triggering event or condition; this is called a
%%% transition. A particular FSM is defined by a list of its states,
%%% and the triggering condition for each transition.

% start off assuming it IS raining (NotRaining is false or 0)
NotRaining = 0;

% Recent_Diffs is the 5-minute diffs that accumulate to cause a season
% (state) switch; We start with no recent differences.
Recent_Diffs = 0;

% The difference between subsequent raw records for the second record;
% It will be tested.

% The difference between height at time 2 and height at time 1 is the Diff2
% Remember Diff is 0 since coming onto the first measurement
Diff2 = RawGauge2 - RawGauge;


%%% In the Rainy State, if the difference is greater than 0, the
%%% baseline rises, and the data is accepted as the instantaneous
%%% precipitation for this five minute interval

if Diff2 > 0;
    % Baseline increases by the new Diff2 - new precip
    Baseline2 = Baseline + Diff2;
    % we flag the data as acceptable
    Flag2 = 'A';
    % there is no correction needed- we accept the Diff2 as CorrDiff2
    CorrDiff2 = Diff2;
    % We injest the additional rain into the recent precipitation
    % counter
    Recent_Diffs = Recent_Diffs + Diff2;
    
    % Adding "I" criteria if the first flag seen is an "I"
    if strcmpi(OriFlag2,'I');
        Flag2 = 'I';
    end
    
    
    
    %%% If the difference is negative and it is much greater (1 order of
    %%% magnitude give or take 0.1 to deal with the case of 0), then there
    %%% has probably been a reset of the gauge or an error. We do not want
    %%% to count this difference, and we want to reset the baseline to
    %%% represent the gauge when it stabilizes.
    
    % if the difference, is negative of significant value...
elseif Diff2 <= 0 && abs(Diff2)/10 >= abs(Diff)+0.1;  % add the 0.1 because of the 0 case
    
    % We reset the baseline. For subsequent resets, we are still
    % looking for a big change off this baseline, so it will continue
    % to flag.
    Baseline2 = RawGauge2; % Reset the baseline to the raw measurement
    
    % Flag the measurement as a "R" (reset) if the difference is big
    % and if the original flag contained an R.
    
    % Recall we are already in the condition where the Difference must
    % be negative.
    if abs(Diff2) > 5 && strcmp(OriFlag2,'"R"');
        Flag2 = 'R'; % the flag is R
        
        % New (04-08-2015)-- even if the original flag was not 'R', still
        % assign an 'R'.
    elseif abs(Diff2) > 5;
        Flag2 = 'R';
        
        % if the absolute difference is less than 5 or the original flag is Q
        % call a Q
    elseif abs(Diff2) < 5  || strcmp(OriFlag2,'"Q"')
        Flag2 = 'Q';
    end
    
    if strcmpi(OriFlag2,'I');
        Flag2 = 'I';
    end
    
    % We do not account the change due to 'R' or loss in the rain stage
    % to the daily precipitation. So the corrected Diff is 0.
    CorrDiff2 = 0; % The difference for this step isn't real, so it's 0
    
end
%%% If there is not very much loss, it's just a fluctuation in the
%%% sensor, not worth counting. We do not want to add it to the diffs
%%% but we need to account it towards the baseline's balance

% If the difference is small
if Diff2 <= 0 && abs(Diff2)/10 < abs(Diff) + 0.1;
    % Flag as acceptable
    Flag2 = 'A';
    % Do not count negative to corrected value, CorrDiff2 is 0
    CorrDiff2 = 0;
    % Baseline 2 represents the small loss
    Baseline2 = Baseline + Diff2;
    % Recent Diffs includes this small loss.
    Recent_Diffs = Recent_Diffs + Diff2;
    
    %%% If all these cases fail (for example a NaN in the data, which is the
    %%% fail case I can think of), then the Flag is 'M' and the data is just
    %%% repeated from the previous good measurement to keep the program
    %%% running.
elseif isnan(Baseline2);
    Baseline2 = Baseline; Flag2 = 'M'; RawGauge2 = RawGauge; CorrDiff2 = 0; Diff2 = 0;
    
    %%% If some other condition occurs that we didn't think of...
else Baseline2 = Baseline; Flag2 = 'Q'; RawGauge2 = RawGauge; CorrDiff2 = Diff2; Recent_Diffs = Recent_Diffs + Diff2;
    
end



% Check that the dates are continuous, the serial date num has not
% performed evils
if rem(vectordate(1,5),5) ~= 0;
    output = vectordate(1,5);
    vectordate(1,5) = output + 1; % tested, if it adds to 60 it will roll into the hour NICE.
end

if rem(vectordate(2,5),5) ~= 0;
    output = vectordate(2,5);
    vectordate(2,5) = output + 1; % tested, if it adds to 60 it will roll into the hour NICE.
end

%%% convert the dates to things humans can use:
cHumanDate = datestr(vectordate(1,:),'yyyy-mm-dd HH:MM:SS');
cHumanDate2 = datestr(vectordate(2,:),'yyyy-mm-dd HH:MM:SS');

%%% Turn off warning about converting strings to doubles versus to numbers
warning off


% CS2MET may not be happy because it has a different interval, so
% assign it an "A" flag (it may see a difference that is too large)
if strcmp(Station, 'CS2MET');
    Flag2 = 'A';
end

Baseline2 = Baseline;

%%% Save the "records" from these first two measurements
FirstRecord = {cHumanDate, RawGauge, Baseline, Diff, CorrDiff, Flag, OriFlag};


if strcmpi(OriFlag2,'I');
   Flag2 = 'I';
end

%%% The second record reflects these criteria:
SecondRecord = {cHumanDate2, RawGauge2, Baseline2, Diff2, CorrDiff2, Flag2, OriFlag2};

%%% Both the second and first record are given to the results.
Results(1,:) = FirstRecord;
Results(2,:) = SecondRecord;

%%% Now the main loop!

% Create an array to track midnight-to-midnight differences for
% checking.
Approx_data_length = ceil(length(Results)/288);

% Set the tolerance for the happy case (not CS2met). This is about
% 5 days.
tolerance = 1200;

% if the station is CS2MET, then we don't need as much tolerance or
% check array space because samples less frequent!
if strcmpi(Station,'CS2MET') ==1;
    Approx_data_length = ceil(length(Results)/96);
    tolerance = 450;
end

%%% M2M (midnight-to-midnight) will be used to do the midnight to
%%% midnight data checks. It can be output also.
M2M = zeros(Approx_data_length,11);

%%% Each says accumulation is held in an array of
%%% Daily_Accumulation
Daily_Acc = zeros(Approx_data_length,2);

%%% Trackers
M2Mcount = 0; % start count for midnight to midnight at 0;
Count    = 0; % count days during Raining state that are not very different from the prior day
MaybeDry = 0; % only use the counter for the not different days when the MaybeDry flag is on
CountM   = 0; % start a count for number of M flag values

% Can be turned on to deal with mainenance.
Rebounding = 0; % keeps the gauge in "draining" mode

%%% ENTER LOOP ASSUMING RAINY SEASON
% fprintf(1,'%s%s\n','entering rainy mode on ', cHumanDate2);


% MAIN LOOP
for i = 3:length(Results)
    
    %%% Raw measurement is taken from the third line
    % RawGauge3 is the height, which comes from the gauge column,
    % the ith measurement, and we must specify we want the contents
    % of that one cell, so use (i,1) index.
    RawGauge3 = data.values{1,GaugeCol}(i,1);
    %OriFlag3 is the given height by GCE, which comes from the
    %flags column, same deal as above re. specs.
    OriFlag3 = data.flags{1, GaugeCol}(i,1);
    
    %%% Comparative measurements are taken from the Results in the
    %%% previous index.
    
    % The previous "Raw" is the previous raw gauge height, the
    % previous baseline is the previous baseline height, the
    % previous flag is the previous flag, etc. etc.
    CompareRaw = Results{i-1,2}; CompareFlag = Results{i-1,6}; CompareOriFlag = Results{i-1,7};
    CompareBase = Results{i-1,3}; CompareDiff = Results{i-1,4}; CompareCorr = Results{i-1,5};
    
    % if the last CompareDiff was NaN (coming from a NaN), we just
    % say it was zero (it is not output so it is only to stop an
    % error)
    CompareDiff(isnan(CompareDiff)) = 0;
    
    % Gather the date
    HumanDate3 = data.values{1,2}(i,1);
    
    % calculate the datevec for midnight to midnight capture the
    % evil matlab date and test that the minutes are 5 minute if
    % they are not, add 1 to the minutes, then reconvert to vector
    capture = datevec(HumanDate3);
    
    % if the remainder of the minutes vector after dividing by five
    % is not 0, grab the seconds, add 1 second to it, which forces
    % it to round up, and forces the round up to propogate back
    % through. THANK YOU HANS.
    if rem(capture(1,5),5) ~= 0;
        output = capture(1,6);
        
        capture(1,6) = output + 1; % tested, if it adds to 60 it will roll into the hour NICE.
        
        capture = datevec(datenum(capture));
    end
    
    % put out a corrected human date
    cHumanDate3 = datestr(capture, 'yyyy-mm-dd HH:MM:SS');
    
    %%% re-date-vec the new date (or perhaps the old one, depending
    %%% if you fixed it)
    vectordate(i,:) = capture;
    
    %%% if it is the 0 hour - why it is giving these conditional
    %%% warnings is stupid - if it is the 0 hour and the 5 minute
    %%% is 0 OR if it's the 23rd hour and you could round up to 60
    %%% (last day measurement). Over this is the day!
    if vectordate(i,4) == 0 & round(vectordate(i,5)/5)*5 == 0 | vectordate(i,4) == 23 & round(vectordate(i,5)/5)*5 == 60;
        
        % Grab the raw gauge measurement
        catchhour = RawGauge3;
        
        % Add one to the midnight to midnight count
        M2Mcount = M2Mcount + 1;
        
        % set the midnight to midnight count's first six values to the date vector
        M2M(M2Mcount,1:6) = vectordate(i,1:6);
        
        % set the midnight to midnight count's seventh value to the caught raw value
        M2M(M2Mcount,7) = catchhour;
        
        % Put the number of missing values in the array
        M2M(M2Mcount,9) = CountM; % the midnight to midnight count of Missing Values
        
        % Now, reset the count of missing values to 0 for tomorrow
        CountM = 0; % then set the CountM back to 0 for subsequent day
        
        % record the index number for accumulation so we can
        % iterate through later in daily summaries
        M2M(M2Mcount,10) = i;
        
        %%% Don't do this for when we have only 2 days of record.
        if M2Mcount >= 2;
            %Get the previous days midnight-to-midnight
            M2M(M2Mcount,8) = M2M(M2Mcount,7) - M2M(M2Mcount-1,7);
        end
    end
    
    %%% The difference is the difference between the raw measurement
    %%% and the running "baseline" which is not the same thing as the raw
    %%% or the accumulated (represents the 'state of the gauge' regardless of loss
    
    %%% The actual change in this interval is the change between the raw gauge and the baseline which
    %%% was set in the previous measurements
    
    Diff3 = RawGauge3 - CompareBase;   % the Differences are comparisons of the Raw and the Base
    
    
    %%% During the rainy season....
    if NotRaining == 0;
        
        % Figure out what the measurement of recent differences
        % were before we entered this interval
        PriorRD = Recent_Diffs; % catch the previous measurements's Recent Differences
        
        % If the MaybeDry flag is on, we may be transitioning to dryness?
        if MaybeDry == 1;
            
            % if the Recent differences are within a 1.2 mm range
            % of the last count of recent differences, then there
            % is a chance that it could be not raining. I.E. we
            % haven't had a sudden onset of rain.
            
            if Recent_Diffs - 1.2 <= PriorRD | PriorRD <= Recent_Diffs + 1.2;
                % This is a count against the "tolerance". When the
                % count exceeds the tolerance, we switch the state.
                Count = Count+1;
                
                % If we get a sudden burst of rain, though, we jump
                % back into the state of rainy-ness
            else Count = 0;
                
            end
            
            
            % If it's been more than about the tolerance # of
            % measurements where there hasn't been much
            % differences, then we can switch to the not raining
            % state, setting MaybeDry back to 0 (because of course
            % it IS dry), Recent_Differences back to 0, and the
            % Count back to 0.
            
            if Count > tolerance;
                NotRaining = 1;
                MaybeDry = 0;
                Recent_Diffs = 0;
                Count = 0;
                %fprintf(1,'%s%s\n','switching to the dry state on ', cHumanDate3);
            else NotRaining = 0;
            end
            
            % this is the "end of the maybe dry testing loop"
        end
        
        %%% Recall, we are in the raining season! So if the
        %%% difference is positive, it's "real"
        if Diff3 >= 0;
            Baseline3 = CompareBase + Diff3; % baseline accumulates rain
            
            %%% A  positive difference of more than 4 needs to
            %%% be flagged. This could be a "snow J"
            
            % if the difference is greater than 0 but less than 4
            % it's A
            if Diff3 < 4;
                Flag3 = 'A';
                
                % if the Difference is > 4 and the last measurement was
                % a J it's Q
            elseif Diff3 > 4 && strcmp(CompareFlag,'J') ==1;
                Flag3 = 'Q';
                
                % if the diff > 4 and the last measurement was ok, it's
                % ok to add, but it's a J to investigate
            elseif Diff3 > 4 && strcmp(CompareFlag,'A') ==1;
                Flag3 = 'J';
                %fprintf(1,'%s%s%s%4.2f\n','a J was flagged on ', cHumanDate3, ' because the raw difference was ', Diff3);
                
                % if Adam's code is not empty it's questionable
            elseif Diff3 > 4 && strcmp(OriFlag3,'""')==0;
                Flag3 = 'A';
            
            elseif Diff3 > 4 && strcmp(OriFlag3,'"I"')==0;
                Flag3 = 'I';
                % otherwise its ok
            else Flag3 = 'A'; % if the previous flag was not acceptable and there's a big increase
                
            end
            
            %%% in the rainy season we accept the positive differences
            
            CorrDiff3 = Diff3; % In all of the above cases, the difference is correct and added in
            Recent_Diffs = Recent_Diffs + Diff3; % recent differences always increases in rainy state if diff is +
            Rebounding = 0; % check that Rebounding is still set to 0.
            
            %%% in the rainy state, if the difference is big, it's a reset!
        elseif Diff3 < 0 & abs(Diff3)/10 >= abs(CompareDiff)+0.1
            
            % always reset the baseline after a reset
            Baseline3 = RawGauge3; % the baseline is reset
            
            
            % if the absolute value of the diff is > 10, it's
            % definitely a reset
            if abs(Diff3) > 10;
                Flag3 = 'R'; % the flag is R
                
                % start the check if it is rebounding - after a
                % reset the gauge may bounce
                Rebounding = 1; % Continue the Rebounding flag at 1.
                
                % otherwise if its less than 10 and the original flag is an R, give an R
            elseif abs(Diff3) < 10 && abs(Diff3) > 4 && strcmp(OriFlag3,'"R"') ==1 && Rebounding == 0;
                Flag3 = 'R';
                
                % since you just assigned a reset, you must now
                % assign a rebounding flag
                Rebounding = 1; % Continue the Rebounding flag at 1.
                
                % print that the gauge has been reset more than
                % 1x in a row!
                %fprintf(1,'%s%s%s%4.2f\n','a subsequent maintenance was triggered on ', cHumanDate3, ' due to a drop of ', Diff3);
                
                % otherise if the gauge has a large difference but
                % it is not flagged originally as reset, we still
                % want to detect this.
            elseif Rebounding == 1 && abs(Diff3) > 4 | strcmpi(OriFlag3,'"R"') == 1;
                Flag3 = 'R';
                % since you just assigned a reset assign the
                % rebounding flag
                Rebounding = 1; % Continue the Rebounding flag at 1.
                %fprintf(1,'%s%s%s%4.2f\n','a subsequent maintenance was triggered on ', cHumanDate3, ' due to a drop of ', Diff3);
                
                % finally, if the rebounding flag is on, but the
                % next difference is small, you are moving out of
                % reset mode.
            elseif Rebounding == 1 && abs(Diff3) <= 4;
                Rebounding = 0;
                Flag3 = 'A';
                %fprintf(1,'%s%s%s%4.2f\n','the maintenance stops on ', cHumanDate3, ' because the drop is only ', Diff3);
                
            end
            
            CorrDiff3 = 0;
                       
            %%% if there is just a small negative difference in the
            %%% raining mode:
        elseif Diff3 < 0 && abs(Diff3)/10 < abs(CompareDiff) + 0.1;
            % there is a chance that a very small drain occured (it
            % can happen)
            if abs(Diff3) > 4 && Rebounding == 1;
                Flag3 = 'R';
                Rebounding = 0;
                CorrDiff3 = 0;
                Baseline = RawGauge;
                %fprintf(1,'%s%s%s%4.2f\n','a lower-magnitude maintenance was triggered on ', cHumanDate3, ' due to a drop of ', Diff3);
                
                % for example, sometimes we see an "R" flag for some
                % minor event we need to deal with.
            elseif strcmpi(OriFlag3,'"R"')==1;
                Flag3 = 'R';
                Baseline3 = RawGauge3;
                %fprintf(1,'%s%s%s\n','a maintenance was marked in the field on ', cHumanDate3, ' due to adams flag');
                
                
                % This clause was added later to deal with "sloshing"
                % from humans
            elseif abs(Diff3)>3;
                Baseline3 = RawGauge3;
                Flag3 = 'R';
                %fprintf(1,'%s%s%s%4.2f\n','we saw sloshing in the tank on ', cHumanDate3, ' with a drop of ', Diff3);
                Rebounding = 0;
                
                % in most cases none of this even happens, and the
                % Baseline is the same, and the precip doesn't change
            else Baseline3 = CompareBase; % it's not really a difference
                Flag3 = 'A'; % the difference is not real
            end
            
            Rebounding = 0; % set the rebounding flag to 0
            CorrDiff3 = 0; % set the corrected Diff to 0
            
            %%% If the Raw gauge measurement previously is a nan, and the new raw gauge is not a nan
        elseif isnan(CompareRaw) & ~isnan(RawGauge3);
            
            % the baseline is the same as the raw
            Baseline3 = RawGauge3; % set the new baseline to something which is a real #
            % the value is acceptable, since it's a new values
            Flag3 = 'A';
            %RawGauge3 = num2str(CompareRaw);
            Rebounding = 0;
            % count the number of missing - reset to 0
            CountM = 0;
            % since you are coming off a missing value you don't really know the Diff3, it could be anything
            Diff3 = 0;
            CorrDiff3 = 0;
            
            %%% If any other case exists,
        else Baseline3 = CompareBase; Flag3 = 'M'; RawGauge3 = CompareRaw; Rebounding = 0; CountM = CountM + 1;
            
        end
        
        %%% Recent_diffs only shows the accumulation of recent positive rain.
        %%% The thought is that if there is a steady increase in this value we are still in the
        %%% rainy season. When it starts to level off, then we are moving to the dryness...
        %%% If the recent diffs are the same as the previous diffs and MaybeDry is not initialized
        %%% initialize it and start counting -- this isn't an immediate change, but just a lookout
        
        if Recent_Diffs == PriorRD & MaybeDry == 0;
            MaybeDry = 1;
            Count = Count + 1;
            CorrDiff3 = 0;
        end
        
        % Adding "I" criteria if the first flag seen is an "I"
        if strcmpi(OriFlag3,'I');
            Flag3 = 'I';
        end
        
        %%% The baseline can stay the Same as it is in this case since it's probably not draining
        ThirdRecord = {cHumanDate3, RawGauge3, Baseline3, Diff3, CorrDiff3, Flag3, OriFlag3};
        
        Results(i,:) = ThirdRecord;
        
        clearvars ThirdRecord
        
        
    elseif NotRaining == 1;
        
        %%% similar to above, if the Diff > 0 or = 0 then the base and
        %%% accumulation reflect this change and it is accepted
        
        if Diff3 >= 0;
            Rebounding = 0;
            Baseline3 = CompareBase; % a positive change in summer does not change the baseline
            if Diff3 < 4;
                Flag3 = 'A'; % probably is ok
                CorrDiff3 = 0;
                Recent_Diffs = Recent_Diffs + Diff3;
                
                % if the Difference is > 4 and the last measurement was ok it's a "J"
            elseif Diff3 > 4 && strcmp(CompareFlag,'A') ==1;
                Flag3 = 'J';
                %fprintf(1,'%s%s%s%4.2f\n','a summer J was triggered on ', cHumanDate3, ' due to a gain of ', Diff3);
                CorrDiff3 = Diff3;
                
                
                % there is the chance that it could be the "rebound" from a reset
            elseif Diff3 > 4 && strcmp(CompareFlag,'R')==1;
                Flag3 = 'E';
                CorrDiff3 = Diff3;
                %Results{i,9} = 'MAINTE';
                %fprintf(1,'%s%s%s\n','the maintenance flag was applied to ', cHumanDate3, ' because a positive difference occured following a reset')
                % do not upgrade the recent diffs if a J occurs
                
            elseif Diff3 > 4 && strcmp(CompareFlag,'E') ==1;
                Flag3 = 'A';
                CorrDiff3 = Diff3;
                Recent_Diffs = Recent_Diffs + Diff3;
               % fprintf(fid_log,'%s%s%s%4.2f\n','post-reset gain is counted from ', cHumanDate3, ' with a magnitude of ', Diff3);
                
                % if the diff > 4 and the last measurement was a J, especially in the summer, we question it...
            elseif Diff3 > 4 && strcmp(CompareFlag,'J') ==1;
                Flag3 = 'Q';
                CorrDiff3 = 0;
                % we add it to the recent diffs though, to move us towards rain
                Recent_Diffs = Recent_Diffs + Diff3;
                % AK commented out this line. Fox said this was legacy from
                % testing period. 
                % fprintf(fid_log,'%s%s%s%4.2f\n','post-J gain is counted from ', cHumanDate3, ' with a magnitude of ', Diff3);
                
                % if Adam's code gives empty and the original flag is empty, we accept it and add to recent diffs
            elseif Diff3 > 4 && strcmp(OriFlag3,'""')==0;
                Flag3 = 'A';
                CorrDiff3 = 0;
                Recent_Diffs = Recent_Diffs + Diff3;
                
            end
            
            
            % in all of these do not rebound
            Rebounding = 0;
            
            %%% Now, dealing with resets!
        elseif Diff3 < 0 & abs(Diff3)/10 >= abs(CompareDiff)+0.1
            % reset the baseline
            Baseline3 = RawGauge3; % the baseline is reset
            
            if abs(Diff3) > 10;
                Flag3 = 'R'; % the flag is R
                % start the check if it is rebounding
                Rebounding = 1; % Continue the Rebounding flag at 1.
                %fprintf(1,'%s%s%s%4.2f\n','a drain is detected on ', cHumanDate3, ' with a magnitude of ', Diff3);
                
                %%% otherwise if its less than 10 and the original flag is an R, give an R
            elseif abs(Diff3) < 10 & abs(Diff3) > 4 & strcmp(OriFlag3,'"R"')==1 & Rebounding == 0;
                Flag3 = 'R';
                % note that it is rebounding
                Rebounding = 1; % Continue the Rebounding flag at 1.
                %fprintf(1,'%s%s%s%4.2f\n','a subsequent drain is continued on ', cHumanDate3,' with a magnitude of ', Diff3);
                
                %%% otherwise if it's less than 10 and the original flag is an R give it an Rf
            elseif Rebounding == 1 & abs(Diff3)>4 | strcmpi(OriFlag3,'"R"')==1;
                Flag3 = 'R';
                Rebounding = 1; % Continue the Rebounding flag at 1.
                CorrDiff3 = 0;
                %fprintf(1,'%s%s%s%4.2f\n','continued drain is detected on ', cHumanDate3, ' with a magnitude of ', Diff3);
                
            elseif Rebounding == 1 & abs(Diff3) <= 4;
                Rebounding = 0;
                Flag3 = 'A';
                %fprintf(1,'%s%s%s%4.2f\n','the drain has ended on ', cHumanDate3, ' because the difference magnitude was ', Diff3);
                
            end
            
            CorrDiff3 = 0;
            
            
            %%% a small change in the summer is probbaly a non-event
        elseif Diff3 < 0 & abs(Diff3)/10 < abs(CompareDiff) + 0.1;
            
            % unless we have a note that there is some event we
            % need to work around
            if strcmpi(OriFlag3,'"R"') == 1;
                Flag3 = 'R';
                Baseline3 = RawGauge3;
                CorrDiff3 = 0; % there isn't a corrected difference
                Rebounding = 0;
                %fprintf(1,'%s%s%s%4.2f\n','a very small drain is noted on ', cHumanDate3, ' with a magnitude of ', Diff3);
                
            elseif abs(Diff3)>3;
                Baseline3 = RawGauge3;
                CorrDiff = 0;
                Flag3 = 'R';
                Rebounding = 0;
                %fprintf(1,'%s%s%s%4.2f\n','the newest drain criteria applies on ', cHumanDate3, ' due to a drop of ', Diff3);
                
            else Baseline3 = CompareBase; % the baseline does not change from the previous
                Flag3 = 'A'; % the difference is probably evaporation
                Rebounding = 0;
                
            end
            
            Rebounding = 0;
            
            % if the raw gauge is Nan or adam flags missing...
        elseif isnan(RawGauge3) | strcmpi(OriFlag3, '"M"') ==1;
            Baseline3 = CompareBase;
            Flag3 = 'M';
            RawGauge3 = NaN;
            CorrDiff3 = NaN;
            Diff3 = 0;
            Rebounding = 0;
            CountM = 1;
            
            %%Recent_Diffs = Recent_Diffs + Diff3; % recent diffs counts the small flux, in case there is a leak
        elseif isnan(CompareRaw) & ~isnan(RawGauge3);
            Baseline3 = RawGauge3;
            Flag3 = 'A';
%            AccGauge3 = CompareAcc;
            CorrDiff3 = 0;
            Diff3 = 0;
            %RawGauge3 = num2str(CompareRaw);
            Rebounding = 0;
            CountM = 0;
            
        else Baseline3 = CompareBase; Flag3 = 'M'; RawGauge3 = CompareRaw; Rebounding =0; CountM = CountM+1;
        end % end the loop of simmer conditions
        
        %%% if the recent_diffs is more than 2, move into raining mode.
        if Recent_Diffs > 2 & strcmp(Flag3,'J')==0;
            NotRaining = 0;
            
            
            Baseline3 = RawGauge3; % reset the baseline
            
            
            MaybeDry = 0;
            Flag3 = 'F'; % flag for winter mode switch
            CorrDiff3 = Diff3;
            Recent_Diffs = CorrDiff3; % reset the difference counter
            Count = 0; % reset the count to 0 just in case it's not
            %fprintf(1,'%s%s%s%4.2f\n','the raining mode is activated on ', cHumanDate3, ' since we have accumulated ', Recent_Diffs);
        end
        
        % try
        if strcmpi(OriFlag3,'I');
           Flag3 = 'I';
        end
        ThirdRecord = {cHumanDate3, RawGauge3, Baseline3, Diff3, CorrDiff3, Flag3, OriFlag3};
        % catch
        %     ThirdRecord = {DN3, cHumanDate3, AccGauge3, RawGauge3, Baseline3, Diff3, CorrDiff3, Flag3, OriFlag3};
        % end
        Results(i,:) = ThirdRecord;
        
        clearvars ThirdRecord
        
    end
    
    
end

fprintf(1,'%s\n','Hey, its done');
clearvars i % could this have been the error?
clearvars d  HighResOut FirstRecord SecondRecord M2M M2Mout M2Mcount

%             %%% IF YOU CHOOSE TO WRITE OUT THE HIGH RESOLUTION DATA COMMENT
%             %%% ALL OF THIS STUFF IN!! FROM HERE ------>>>>>>>
%             % open file title writing
%             fprintf(fid1,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s, %s\n','DBCODE','ENTITY','SITECODE','PRECIP_METHOD','HEIGHT','QC_LEVEL','PROBE_CODE','DATE_TIME','PRECIP_TOT','PRECIP_TOT_FLAG','GAUGE_HEIGHT','ORIGINAL_FLAG','EVENT_CODE');
%             fprintf(fid1,'%s,%s,%s,%s,%d,%s,%s,%s,%4.2f,%s,%4.2f,%s,%s\n', 'MS043','13', Station, Method, Height,'1P', Probe_Code, cHumanDate2, 0, 'A', Results{1,2}, Results{1,7}, 'NA');
%             % assign event codes to the high res
%             for i = 2:length(Results)
%                 % if Adamn flagged a 'T' it is the orifice temperature, that's a Questionable
%                 if strcmpi(Results{i,7},'"T"');
%                     Results{i,6} = 'Q';
%                     fprintf(fid_log,'%s%s%s%s\n','a T flag was replaced with Q for ', Probe_Code, ' on ',Results{i,1});
%                 end
% 
%                 % if it's estimated by adam then its estimated
%                 if strcmpi(Results{i,7},'"E"');
%                     Results{i,6} = 'E';
%                 end
%                 
% 
%                 % if the Results in that corrected difference is a NaN but the prior is not a nan, then
%                 % the current one is the same as the prior and it's estimated
%                 if Results{i,5} == NaN & Results{i-1,5} ~=NaN;
%                     Results{i,5} = Results{i-1,5};
%                     Results{i,6} = 'E';
%                     Event_Code = 'INTPRO';
%                 end
% 
%                 %% Assign Event Codes
%                 if strcmpi(Results{i,7},'R')==1;
%                     Event_Code = 'MAINTE';
%                     Results{i,6} = 'E';
%                     Results{i,5} = 0;
%                    % fprintf(fid_log,'%s%s%s%s%s%4.2f\n','a maintenance was detected for ', Probe_Code, ' on ',Results{i,2}, 'with a magnitude of ', Results{i,6});
%                 elseif strcmpi(Results{i,6},'F')==1 & Results{i,5} >= 1;
%                     Event_Code = 'INTPRO';
%                     Results{i,6} = 'Q';
%                 elseif strcmpi(Results{i,6},'F')== 1 & Results{i,5} < 1;
%                     Event_Code = 'INTPRO';
%                     Results{i,8} = 'A';
%                 elseif strcmpi(Results{i,6},'J')==1;
%                     Event_Code = 'WEATHR';
%                    % fprintf(fid_log,'%s%s%s%s%s%4.2f\n','a J was detected for ', Probe_Code, ' on ',Results{i,2}, 'with a magnitude of ', Results{i,6});
%                 elseif strcmpi(Results{i,6},'M') ==1
%                     Results{i,2} = NaN;
%                     Results{i,5} = NaN;
%                     Event_Code = 'NA';
%                 else Event_Code = 'NA';
%                 end
%                 
%                 % if it's invalidated by adam then its I
%                 if strcmpi(Results{i,7},'"I"');
%                     Results{i,6} = 'I';
%                 end
%                 %fprintf(fid1,'%s,%s,%s,%s,%d,%s,%s,%s,%4.2f,%s,%4.2f,%s,%s\n', 'MS043','13', Station, Method, Height,'1P', Probe_Code, Results{i,2}, 0, 'A', Results{i,4}, Results{i,9}, Event_Code);
%                 % print the high res
%                 fprintf(fid1,'%s,%s,%s,%s,%d,%s,%s,%s,%4.2f,%s,%4.2f,%s,%s\n', 'MS043','13', Station, Method, Height,'1P', Probe_Code, Results{i,1}, Results{i,5}, Results{i,6}, Results{i,2}, Results{i,7}, Event_Code);
% 
%             end
%             fclose(fid1)
% 
%             clearvars Event_Code






