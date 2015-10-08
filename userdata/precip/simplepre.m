%%% EASYPRE.m

function [Results] = simplepre(GaugeCol, FlagCol, Station, data);


%%% SIMPLEPRE s a script to take precipitation data and
%%% run it through a state algorithm to generate MS04313 style outputs.
%%% It is based on the differences between raw measurements. 
%%% It uses an accumulating array called RESULTS and writes out to .csv
%%% file.

%%% The Results array will move to the workspace following a run so that 
%%% it can be examined within MATLAB: Here is the arrangement of that array:

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

%%% Make a small look up for the columns and files:
    fprintf(1,'%s\n','first site')

    file_log = 'log_processing.txt';
    fid_log = fopen(file_log,'w');

    fprintf(fid_log,'%s%s%s\n','hello, today is ', datestr(now),' and you are processing:')
    
    %%% For all the datasets (8 of them): 
    %while dataset <8;
    dataset = 1;
        %%% Sheltered CENMET
        if dataset == 1;
              %fprintf(fid_log,'%s\n','cenmet stand sheltered-->')
              %load cenmet_225_5min_2015.mat;
              %GaugeCol = 10;
              %FlagCol = 10;
              %Station = 'CENMET';
              Probe_Code = 'PPTCEN02';
              Height = 455;
              Method = 'PPT017';
              dMethod = 'PPT117';
              HighResOut = 'x.csv';
              fid1 = fopen(HighResOut, 'w');
              
        %%% Regular CENMET
        elseif dataset == 2;
              fprintf(fid_log,'%s\n','cenmet stand alone-->')
              load cenmet_225_5min_2015.mat;
              GaugeCol = 7;
              FlagCol = 7;
              Station = 'CENMET';
              Probe_Code = 'PPTCEN01';
              Height = 455;
              Method = 'PPT017';
              dMethod = 'PPT117';
              HighResOut = 'CENMET_SAx2015.csv';
              fid1 = fopen(HighResOut, 'w');

        %%% Sheltered UPLMET
        elseif dataset == 3;
            fprintf(fid_log,'%s\n','uplmet stand alone-->')
            load uplmet_227_5min_2014.mat;
            GaugeCol = 7;
            FlagCol = 7;
            Station = 'UPLMET';
            Probe_Code = 'PPTUPL01';
            Method = 'PPT015';
            dMethod = 'PPt115';
            Height = 455;
            %M2Mout = 'UPLMET_SAx2015.csv';
            HighResOut = 'UPLMET_SAx2015.csv';
            fid1 = fopen(HighResOut,'w');

        elseif dataset == 4;
            fprintf(fid_log,'%s\n','uplmet sheltered-->')
            load uplmet_227_5min_2014.mat;
            GaugeCol = 10;
            FlagCol = 10;
            Station = 'UPLMET';
            Probe_Code = 'PPTUPL02';
            Method = 'PPT015';
            dMethod = 'PPt115';
            Height = 455;
            %M2Mout = 'UPLMET_SAx2015.csv';
            HighResOut = 'UPLMET_SHx2015.csv';
            fid1 = fopen(HighResOut,'w');

        elseif dataset == 5;
            fprintf(fid_log,'%s\n','varmet stand alone-->')
            load varmet_301_a_5min_2015.mat;
            GaugeCol = 7;
            FlagCol = 7;
            Station = 'VARMET';
            Probe_Code = 'PPTVAR01';
            Method = 'PPT015';
            dMethod = 'PPt115';
            Height = 455;
            %M2Mout = 'UPLMET_SAx2015.csv';
            HighResOut = 'VARMET_SAx2015.csv';
            fid1 = fopen(HighResOut,'w');

        elseif dataset == 6;
%             fprintf(fid_log,'%s\n','cs2met n4-->')
%             load cs2met_clrg_15min_2015.mat;
%             GaugeCol = 6;
%             FlagCol = 6;
%             Station = 'CS2MET';
            Probe_Code = 'PPTCS201';
            Method = 'PPT018';
            dMethod = 'PPt118';
            Height = 455;
            %M2Mout = 'UPLMET_SAx2015.csv';
            HighResOut = 'CS2MET_N4x2015.csv';
            fid1 = fopen(HighResOut,'w');


        elseif dataset == 7;
            fprintf(fid_log,'%s\n','h15met-->')
            load hi15_207_5min_2014.mat;
            % d = importdata('filename.csv', ',',5)
            %d = importdata('NEW_CS2_PRE.csv');
            Station = 'H15MET';
            Probe_Code = 'PPTH1502';
            GaugeCol = 6;
            FlagCol = 6;
            dMethod = 'PPT118';
            Method = 'PPT018';
            Height = 250;
            HighResOut = 'H15MET_SHx2015.csv';
            fid1 = fopen(HighResOut,'w');

        else fprintf(1,'%s\n', 'you stink at life!')
        end

            % Results holds all the records
            % Results = cell(length(d),9);
            %Results = cell(length(data.values{1,9}),9);
            Results = cell(length(data.values{1,1}),9);
            
            %%% first two records
            %FirstLine = regexp(d{1},',','split');
            %SecondLine = regexp(d{2},',','split');
            
            RawGauge = data.values{1,GaugeCol}(1,1); AccGauge = data.values{1,GaugeCol}(1,1); Diff = 0; Baseline = data.values{1,GaugeCol}(1,1); OriFlag = data.flags{1,FlagCol}(1,1);
            RawGauge2 = data.values{1,GaugeCol}(2,1); AccGauge2 = data.values{1,GaugeCol}(2,1); Baseline2 = data.values{1,GaugeCol}(2,1); OriFlag2 = data.flags{1,FlagCol}(2,1); 


            %%% In the first record and second record, the RawGauge is the Accumulated gauge and the Baseline
            %%% Raw Gauge == Accumulated Gauge == Baseline

            %RawGauge = FirstLine{1,GaugeCol}; AccGauge = FirstLine{1,GaugeCol}; Diff= 0; Baseline = FirstLine{1,GaugeCol}; OriFlag = FirstLine{1,13};
            %RawGauge2 = SecondLine{1,GaugeCol}; AccGauge2 = SecondLine{1,GaugeCol}; Baseline2 = SecondLine{1,GaugeCol}; OriFlag2 = SecondLine{1,13}; 

            %%% MatlabDateNum for records 1 and 2
            % DN = str2num(FirstLine{1,2}); % add 1 second
            % DN2 = str2num(SecondLine{1,2}); % add 1 second
            DN = 0;
            DN2 = 0;

            %%% Human Dates to be used in the output and for calculation
            %% ADAM CHANGED THE FILE, ALL OF THIS MUST BE CHANGED TO COLUMN 2 or THE WHOLE THING WILL FAIL.
           %HumanDate = FirstLine{1,2};
           % HumanDate2 = SecondLine{1,2};
            
            HumanDate = data.values{1,2}(1,1);
            HumanDate2 = data.values{1,2}(2,1);
            CorrDiff = 0;

            Flag = '';
            %%% Vectorized dates to be used for telling midnights etc.
            vectordate = zeros(length(data.values{1,2}),6);
            vectordate(1,:) = datevec(HumanDate);  % vectorized date
            vectordate(2,:) = datevec(HumanDate2); % vectorized date

            %%% States based on Diff
             
            NotRaining = 0;

            %%% Recent_Diffs is the differences that accumulate to cause a season switch;
            %%% We start with no recent differences.
            Recent_Diffs = 0;

            %%% The difference between subsequent raw records for the second record;
            %%% It will be tested.
            
            
            try % assume numeric, if not, convert from string
                Diff2 = RawGauge2 - RawGauge;
                
            catch ME
                fprintf(1, ME);
                Diff2 = str2num(RawGauge2) - str2num(RawGauge); %#ok<*ST2NM>
            
            end;

            %%% If the difference is greater than 0, the baseline rises,
            %%% accumulation rises, and the data is accepted.
            % Diff
             if Diff2 > 0;
                 % Baseline increases with an increasing diff
                Baseline2 = Baseline + Diff2;
                % Accumulation increases to include this Diff
                AccGauge2 = AccGauge + Diff2;
           %     % the data is accepted
                Flag2 = '';
           %     % The corrected diff is +
                CorrDiff2 = Diff2;
           %     % The recent-differences takes this diff in.
                Recent_Diffs = Recent_Diffs + Diff2;

            %%% If the difference is negative and it is much greater (1 order of
            %%% magnitude give or take 0.1 to deal with the case of 0):
            %%% This is just the 0th measurement so we're not concerned as much, more later

            elseif Diff2 <= 0 & abs(Diff2)/10 >= abs(Diff)+0.1;  % add the 0.1 because of the 0 case   
                 Baseline2 = str2num(RawGauge2); % Reset the baseline to the raw measurement

                %%% if the absolute difference is more than 10 and the original flag is R
                %%% call a reset
                if abs(Diff2) > 10 && strcmp(OriFlag2,'"R"');  
                    Flag2 = 'R'; % the flag is R

                %%% if the absolute difference is less than 5 or the original flag is Q
                %%% call a Q
                elseif abs(Diff2) < 10  || strcmp(OriFlag2,'"Q"')
                    Flag2 = 'Q';
                end

                CorrDiff2 = 0; % The difference for this step isn't real, so it's 0
                AccGauge2 = str2num(AccGauge); % The accumulated gauge does not change 
                %%% There is no recent difference in a maintenance;

            %%% If the differences is negative and it is smaller than the previous
            %%% difference after the aforementioned one-order-of-magnitude-iSA buffer
            %%% is applied, then the Baseline is adjusted to this negative difference,
            %%% but the accumulation remains, and this baseline is used for the next
            %%% measurement. The flag is 'Ae' for accepted but maybe evaporation

            %%% This routine is better exemplified when the counters initiate after this step!
         %   elseif Diff2 <= 0 & abs(Diff2)/10 < abs(Diff) + 0.1;
         
                Flag2 = 'Ae';
                CorrDiff2 = 0;
                AccGauge2 = str2num(AccGauge) + CorrDiff2;
                Recent_Diffs = Recent_Diffs + Diff2;

            %%% If all these cases fail (for example a NaN in the data, which is the
            %%% fail case I can think of), then the Flag is 'M' and the data is just
            %%% repeated from the previous good measurement to keep the program
            %%% running.
            else Baseline2 = Baseline; Flag2 = 'Q'; AccGauge2 = AccGauge; RawGauge2 = RawGauge; CorrDiff2 = Diff2; Recent_Diffs = Recent_Diffs + Diff2;
            
            end

            if isnumeric(AccGauge2);
                AccGauge2 = num2str(AccGauge2);
            end

            FirstRecord = {DN, HumanDate, AccGauge, RawGauge, Baseline, Diff, CorrDiff, Flag, OriFlag}; 
            %%% The second record reflects these criteria:
            SecondRecord = {DN2, HumanDate2, str2num(AccGauge2), RawGauge2, Baseline2, Diff2, CorrDiff2, Flag2, OriFlag2};

            %%% Both the second and first record are given to the results.
            Results(1,:) = FirstRecord;
            Results(2,:) = SecondRecord;

            if rem(vectordate(1,5),5) ~= 0;
                output = vectordate(1,5);
                vectordate(1,5) = output + 1; % tested, if it adds to 60 it will roll into the hour NICE.
            end

            if rem(vectordate(2,5),5) ~= 0;
                output = vectordate(2,5);
                vectordate(2,5) = output + 1; % tested, if it adds to 60 it will roll into the hour NICE.
            end

            %%% corrected human dates for the output
            cHumanDate = datestr(vectordate(1,:),'yyyy-mm-dd HH:MM:SS');
            cHumanDate2 = datestr(vectordate(2,:),'yyyy-mm-dd HH:MM:SS');

            %%% Turn off warning about converting strings to doubles versus to numbers
            warning off


            if strcmp(Station, 'CS2MET');
                Flag2 = '';
            end

            Baseline2 = Baseline; 
            %%% The second record reflects these criteria:
            SecondRecord = {DN2, cHumanDate2, AccGauge2, RawGauge2, Baseline2, Diff2, CorrDiff2, Flag2, OriFlag2};

            %%% Both the second and first record are given to the results.
            %Results(1,:) = FirstRecord;
            %Results(2,:) = SecondRecord;

            %%%%%%%%%%%%%%% Now the main loop! 
            %%% holds output for midnight to midnight
            Approx_data_length = ceil(length(Results)/288);
            tolerance = 1200;

            %%% if the station is CS2MET, then we don't need as much because samples less frequent!
            if strcmpi(Station,'CS2MET') ==1;
                Approx_data_length = ceil(length(Results)/96);
                tolerance = 450;
            end

            %%%% M2M will be used to do the midnight to midnight data summation and outputs!
            M2M = zeros(Approx_data_length,11);
            %%% holds the output for sums from m to m
            Daily_Acc = zeros(Approx_data_length,2);

            %%% Trackers
            M2Mcount = 0; % start count for midnight to midnight at 0;
            Count    = 0; % count days during Raining state that are not very different from the prior day
            MaybeDry = 0; % only use the counter for the not different days when the MaybeDry flag is on
            CountM   = 0; % start a count for number of M flag values


            Rebounding = 0; % keeps the gauge in "draining" mode

            %%% ENTER LOOP ASSUMING RAINY SEASON
            fprintf(fid_log,'%s%s\n','entering rainy mode on ', cHumanDate2);


            % MAIN LOOP
            for i = 3:length(Results)

                %%% The third line is parsed
                %ThirdLine = regexp(d{i},',','split');
                %AccGauge3 = data.values{1,GaugeCol}(1,i); Baseline2 = data.values{1,GaugeCol}(1,1); OriFlag2 = data.flags{1,FlagCol}(1,1); 

                %%% Raw measurement is taken from the third line
                %RawGauge3  = ThirdLine{1,GaugeCol};
                RawGauge3 = data.values{1,GaugeCol}(i,1);
                %OriFlag3   = ThirdLine{1,FlagCol};
                OriFlag3 = data.flags{1, GaugeCol}(i,1);
                
                %%% Comparative measurements are taken from the Results array,
                %%% so they are all numeric (see else clause below!)
                CompareRaw = Results{i-1,4}; CompareAcc = Results{i-1,3}; CompareFlag = Results{i-1,8}; CompareOriFlag = Results{i-1,9};
                CompareBase = Results{i-1,5}; CompareDiff = Results{i-1,6}; CompareCorr = Results{i-1,7}; 

                if ~isnumeric(CompareBase)
                    CompareBase = str2num(CompareBase);
                end
                if ~isnumeric(CompareAcc)
                    CompareAcc = str2num(CompareAcc);
                end

                CompareDiff(CompareDiff==NaN) =0;

                %%% The third Datenum comes from the raw data
                % ADAM CHANGED THIS SO ALL MUST BE CHANGED TO 2 or THE WHOLE THING WILL FAIL
                DN3 = 0;
                % DN3 = str2num(ThirdLine{1,2});
                HumanDate3 = data.values{1,2}(i,1);

                %%% calculate the datevec for midnight to midnight
                %%% capture the human date and test that the minutes are 5 minute 
                %%% if they are not, add 1 to the minutes, then reconvert to vector
                capture = datevec(HumanDate3);

                if rem(capture(1,5),5) ~= 0;
                    output = capture(1,6);
                    
                    capture(1,6) = output + 1; % tested, if it adds to 60 it will roll into the hour NICE.
                     
                    capture = datevec(datenum(capture));
                end

                cHumanDate3 = datestr(capture, 'yyyy-mm-dd HH:MM:SS');
                
                %%% re-date-vec it.-- done before, wild times.
                vectordate(i,:) = capture;

                    %%% if it is the 0 hour
                    if vectordate(i,4) == 0 & round(vectordate(i,5)/5)*5 == 0 | vectordate(i,4) == 23 & round(vectordate(i,5)/5)*5 == 60;

                            %%% This part appears to work now
                            %%% catch the RawGauge Measurement
                           
                            catchhour = RawGauge3;
                            
                            %%% Add one to the midnight to midnight count
                            M2Mcount = M2Mcount + 1;
                            %%% set the midnight to midnight count's first six values to the date vector
                            M2M(M2Mcount,1:6) = vectordate(i,1:6);
                            %%% set the midnight to midnight count's seventh value to the caught raw value
                            M2M(M2Mcount,7) = catchhour;
                            M2M(M2Mcount,9) = CountM; % the midnight to midnight count of Missing Values
                            CountM = 0; % then set the CountM back to 0 for subsequent day
                            %%% record the index number for accumulation so we can iterate through
                            M2M(M2Mcount,10) = i;
                            %%% if there are more than 2 values there,
                            if M2Mcount >= 2;
                                %%% calculate the daily midnight to midnight difference on the raw
                                %%% gauge and put it in M2M
                                M2M(M2Mcount,8) = M2M(M2Mcount,7) - M2M(M2Mcount-1,7);
                            end
                    end

                %%% The difference is the difference between the raw measurement 
                %%% and the running "baseline" which is not the same thing as the raw
                %%% or the accumulated (represents the 'state of the gauge' regardless of loss

                %%% The actual change in this interval is the change between the raw gauge and the baseline which 
                %%% was set in the previous measurements
                
                Diff3 = RawGauge3 - CompareBase;   % the Differences are comparisons of the Raw and the Base

                
                %%% During the rainy season
                if NotRaining == 0;

                    %% Figure out what the measurement of recent differences were before went into the loop
                    PriorRD = Recent_Diffs; % catch the previous measurements's Recent Differences

                    %%% If the MaybeDry flag is on, we are transitioning to dryness?
                    if MaybeDry == 1;

                        % if the Recent differences are within a 1.2 mm range of the last count of recent differences, then
                        % there is a chance that it could be not raining. 
                        if Recent_Diffs - 1.2 <= PriorRD | PriorRD <= Recent_Diffs + 1.2; 
                            Count = Count+1;
                        else Count = 0;
                        end


                        %%% If it's been more than about 3.5 days of measurements where there hasn't been much differences,
                        %%% Then we can switch to the not raining state, setting MaybeDry back to 0, Recent_Differences back 
                        %%% to 0, and the Count back to 0.
                        
                        if Count > tolerance;
                            NotRaining = 1;
                            MaybeDry = 0;
                            Recent_Diffs = 0;
                            Count = 0;
                            fprintf(fid_log,'%s%s\n','switching to the dry state on ', cHumanDate3);
                        else NotRaining = 0;
                        end
                    end

                    %% if the difference is positive or 0 it's probably real in the rainy season
                    if Diff3 >= 0;
                        Baseline3 = CompareBase + Diff3; % baseline accumulates rain
             
                        %%% A  positive difference of more than 4 needs to be flagged
                        %%% This flag occurs within the positive difference loop so not apply
                        %%% to other data with small difference.

                        % if the difference is greater than 0 but less than 4 it's A
                        if Diff3 < 4;
                            Flag3 = '';
                        % if the Difference is > 4 and the last measurement was a bomb it's Q
                        elseif Diff3 > 4 && strcmp(CompareFlag,'Bomb') ==1;
                            Flag3 = 'Q';
                        % if the diff > 4 and the last measurement was ok, it's ok
                        elseif Diff3 > 4 && strcmp(CompareFlag,'') ==1;
                            Flag3 = 'Bomb';
                            fprintf(fid_log,'%s%s%s%4.2f\n','a bomb was flagged on ', cHumanDate3, ' because the raw difference was ', Diff3);
                        % if Adam's code is not empty it's questionable
                        elseif Diff3 > 4 && strcmp(OriFlag3,'""')==0;
                            Flag3 = '';
                        % otherwise its ok
                        else Flag3 = ''; % if the previous flag was not acceptable and there's a big increase

                        end

                        %% in the rainy season we accept the positive differences
                        AccGauge3 = CompareAcc + Diff3; % accumulation occurs on the height
                        CorrDiff3 = Diff3; % difference is correct and added in
                        Recent_Diffs = Recent_Diffs + Diff3; % recent differences increases
                        Rebounding = 0; % check that Rebounding is still set to 0.

                    %%% if a very large drop occurs then the gauge has been reset
                    %elseif Diff3 < 0 & abs(Diff3)/10 >= abs(str2num(RawGauge3)- CompareRaw)+0.1;

                    elseif Diff3 < 0 & abs(Diff3)/10 >= abs(CompareDiff)+0.1


                        Baseline3 = RawGauge3; % the baseline is reset


                        % if the absolute value of the diff is > 10
                        if abs(Diff3) > 10;  
                            Flag3 = 'R'; % the flag is R
                            %% start the check if it is rebounding
                            Rebounding = 1; % Continue the Rebounding flag at 1.

                        %%% otherwise if its less than 10 and the original flag is an R, give an R
                        elseif abs(Diff3) < 10 & abs(Diff3) > 4 & strcmp(OriFlag3,'"R"') ==1 & Rebounding == 0;
                            Flag3 = 'R';
                            %% start the check if it is rebounding
                            Rebounding = 1; % Continue the Rebounding flag at 1.
                            fprintf(fid_log,'%s%s%s%4.2f\n','a subsequent maintenance was triggered on ', cHumanDate3, ' due to a drop of ', Diff3);
                        %%% otherwise if it's less than 10 and the original flag is an R give it an Rf
                        elseif Rebounding == 1 & abs(Diff3) > 4 | strcmpi(OriFlag3,'"R"') == 1;
                            Flag3 = 'R';
                            %% start the check if it is rebounding
                            Rebounding = 1; % Continue the Rebounding flag at 1.
                            fprintf(fid_log,'%s%s%s%4.2f\n','a subsequent maintenance was triggered on ', cHumanDate3, ' due to a drop of ', Diff3);
                        elseif Rebounding == 1 & abs(Diff3) <= 4;
                            Rebounding = 0;
                            Flag3 = '';
                            fprintf(fid_log,'%s%s%s%4.2f\n','the maintenance stops on ', cHumanDate3, ' because the drop is only ', Diff3);

                        end

                        CorrDiff3 = 0;
                        AccGauge3 = CompareAcc; % the accumulation is the SAme

                    elseif Diff3 < 0 & abs(Diff3)/10 < abs(CompareDiff) + 0.1;
                        if abs(Diff3) > 4 & Rebounding == 1;
                            Flag3 = 'R';
                            Rebounding = 0;
                            CorrDiff3 = 0;
                            Baseline = RawGauge;
                            fprintf(fid_log,'%s%s%s%4.2f\n','a lower-magnitude maintenance was triggered on ', cHumanDate3, ' due to a drop of ', Diff3);
                        
                        elseif strcmpi(OriFlag3,'"R"')==1;
                            Flag3 = 'R';
                            Baseline3 = RawGauge3;
                            fprintf(fid_log,'%s%s%s\n','a maintenance was triggered on ', cHumanDate3, ' due to adams flag');
                       % elseif strcmpi(CompareOriFlag,'"R"') == 1 & abs(Diff3) > 10;
                       %     Flag3 = 'R';
                       %     Baseline3 = str2num(RawGauge3);
                       %     CorrDiff3 = 0; % there isn't a corrected difference
                       %     Rebounding = 0;
                       %     Baseline3 = str2num(RawGauge3);
                        
                        %% may hace to delete this clause
                        elseif abs(Diff3)>3;
                            Baseline3 = RawGauge3;
                            Flag3 = 'R';
                            fprintf(fid_log,'%s%s%s%4.2f\n','the 3mm continuing maintenance was triggered on ', cHumanDate3, ' due to a drop of ', Diff3);
                            Rebounding = 0;

                        else Baseline3 = CompareBase; % it's not really a difference
                            Flag3 = ''; % the difference is probably evaporation
                        end

                        Rebounding = 0; % set the rebounding flag to 0
                        CorrDiff3 = 0; % set the corrected Diff to 0

                        AccGauge3 = CompareAcc;

                    %%% If the Raw gauge measurement previously is a nan, and the new raw gauge is not a nan
                    elseif CompareRaw == NaN & RawGauge3 ~= NaN;

                        % the baseline is the same as the raw
                        Baseline3 = RawGauge3; % set the new baseline to something which is a real #
                        % the value is acceptable, since it's a new values
                        Flag3 = '';
                        % no accumulation
                        AccGauge3 = CompareAcc;
                        %RawGauge3 = num2str(CompareRaw);
                        Rebounding = 0;
                        % count the number of missing - reset to 0
                        CountM = 0;
                        % since you are coming off a missing value you don't really know the Diff3, it could be anything
                        Diff3 = 0;
                        CorrDiff3 = 0;
                        AccGauge3 = CompareAcc;
                   
                    %%% If any other case exists, 
                    else Baseline3 = CompareBase; Flag3 = 'M'; AccGauge3 = CompareAcc; RawGauge3 = CompareRaw; Rebounding = 0; CountM = CountM + 1;

                    end

                    %%% Recent_diffs only shows the accumulation of recent positive rain.
                    %%% The thought is that if there is a steady increase in this value we are still in the 
                    %%% rainy season. When it starts to level off, then we are moving to the dryness...
                    %%% If the recent diffs are the same as the previous diffs and MaybeDry is not initialized
                    %% initialize it and start counting -- this isn't an immediate change, but just a lookout
                    
                    if Recent_Diffs == PriorRD & MaybeDry == 0;
                        MaybeDry = 1;
                        Count = Count + 1;
                        CorrDiff3 = 0;
                    end
                    
                    
                    
                    %%% The baseline can stay the Same as it is in this case since it's probably not draining
                    ThirdRecord = {DN3, cHumanDate3, AccGauge3, RawGauge3, Baseline3, Diff3, CorrDiff3, Flag3, OriFlag3};    

                    Results(i,:) = ThirdRecord;
                    
                    clearvars ThirdRecord


                elseif NotRaining == 1;

                    %%% similar to above, if the Diff > 0 or = 0 then the base and
                    %%% accumulation reflect this change and it is accepted

                    if Diff3 >= 0 
                        Rebounding = 0;
                        Baseline3 = CompareBase; % a positive change in summer does not change the baseline
                        if Diff3 < 4;
                           Flag3 = 'Ae'; % probably is ok
                           CorrDiff3 = 0;
                           Recent_Diffs = Recent_Diffs + Diff3;

                        % if the Difference is > 4 and the last measurement was ok it's a "Bomb"
                        elseif Diff3 > 4 && strcmp(CompareFlag,'') ==1;
                            Flag3 = 'Bomb';
                            fprintf(fid_log,'%s%s%s%4.2f\n','a dry-state bomb was triggered on ', cHumanDate3, ' due to a gain of ', Diff3);
                            CorrDiff3 = Diff3;

                        % if the Difference is > 4 and the last measurement was ok it's a "Bomb"
                        elseif Diff3 > 4 && strcmp(CompareFlag,'Ae') ==1;
                            Flag3 = 'Bomb';
                            fprintf(fid_log,'%s%s%s%4.2f\n','a dry-state bomb was triggered on ', cHumanDate3, ' due to a gain of ', Diff3);
                            CorrDiff3 = Diff3;

                        % there is the chance that it could be the "rebound" from a reset
                        elseif Diff3 > 4 && strcmp(CompareFlag,'R')==1;
                            Flag3 = 'E';
                            CorrDiff3 = Diff3; 
                            Results{i,9} = 'MAINTE';
                            fprintf(fid_log,'%s%s%s\n','the maintenance flag was applied to ', cHumanDate3, ' because a positive difference occured following a reset')
                            % do not upgrade the recent diffs if a bomb occurs

                        elseif Diff3 > 4 && strcmp(CompareFlag,'E') ==1;
                            Flag3 = '';
                            CorrDiff3 = Diff3;
                            Recent_Diffs = Recent_Diffs + Diff3;
                            fprintf(fid_log,'%s%s%s%4.2f\n','post-reset gain is counted from ', cHumanDate3, ' with a magnitude of ', Diff3);

                        % if the diff > 4 and the last measurement was a Bomb, especially in the summer, we question it...
                        elseif Diff3 > 4 && strcmp(CompareFlag,'Bomb') ==1;
                            Flag3 = 'Q';
                            CorrDiff3 = 0;
                            % we add it to the recent diffs though, to move us towards rain
                            Recent_Diffs = Recent_Diffs + Diff3;
                            fprintf(fid_log,'%s%s%s%4.2f\n','post-bomb gain is counted from ', cHumanDate3, ' with a magnitude of ', Diff3);

                        % if Adam's code gives empty and the original flag is empty, we accept it and add to recent diffs
                        elseif Diff3 > 4 && strcmp(OriFlag3,'""')==0;
                             Flag3 = '';
                             CorrDiff3 = 0;
                            Recent_Diffs = Recent_Diffs + Diff3;

                        end

                        AccGauge3 = CompareAcc + Diff3;
                        
                        % in all of these do not rebound
                        Rebounding = 0;

                    %%% if a very large drop occurs then the gauge has been reset
                    %elseif Diff3 < 0 & abs(Diff3)/10 >= abs(str2num(RawGauge3)- CompareRaw)+0.1;
                    

                    elseif Diff3 < 0 & abs(Diff3)/10 >= abs(CompareDiff)+0.1
                        Baseline3 = RawGauge3; % the baseline is reset 

                        if abs(Diff3) > 10;  
                            Flag3 = 'R'; % the flag is R
                            %% start the check if it is rebounding
                            Rebounding = 1; % Continue the Rebounding flag at 1.
                            fprintf(fid_log,'%s%s%s%4.2f\n','a drain is detected on ', cHumanDate3, ' with a magnitude of ', Diff3);
                        %%% otherwise if its less than 10 and the original flag is an R, give an R
                        elseif abs(Diff3) < 10 & abs(Diff3) > 4 & strcmp(OriFlag3,'"R"')==1 & Rebounding == 0;
                            Flag3 = 'R';
                            %% start the check if it is rebounding
                            Rebounding = 1; % Continue the Rebounding flag at 1.
                            fprintf(fid_log,'%s%s%s%4.2f\n','a subsequent drain is continued on ', cHumanDate3,' with a magnitude of ', Diff3);
                        %%% otherwise if it's less than 10 and the original flag is an R give it an Rf
                        elseif Rebounding == 1 & abs(Diff3)>4 | strcmpi(OriFlag3,'"R"')==1;;
                            Flag3 = 'R';
                            %% start the check if it is rebounding
                            Rebounding = 1; % Continue the Rebounding flag at 1.
                            CorrDiff3 = 0;
                            fprintf(fid_log,'%s%s%s%4.2f\n','continued drain is detected on ', cHumanDate3, ' with a magnitude of ', Diff3);
                        elseif Rebounding == 1 & abs(Diff3) <= 4;
                            Rebounding = 0;
                            Flag3 = '';
                            fprintf(fid_log,'%s%s%s%4.2f\n','the drain has ended on ', cHumanDate3, ' because the difference magnitude was ', Diff3);

                        end

                        CorrDiff3 = 0;
                        AccGauge3 = CompareAcc; % the accumulation is the SAme

                        %%% Recent diffs ignores the unreal flux
                            
                    
                    %%% a small change in the summer is probbaly a non-event
                    elseif Diff3 < 0 & abs(Diff3)/10 < abs(CompareDiff) + 0.1;

                        if strcmpi(OriFlag3,'"R"') == 1;
                            Flag3 = 'R';
                            Baseline3 = RawGauge3;
                            CorrDiff3 = 0; % there isn't a corrected difference
                            Rebounding = 0;
                            fprintf(fid_log,'%s%s%s%4.2f\n','a very small drain is noted on ', cHumanDate3, ' with a magnitude of ', Diff3);
                      % good for all but h15met
                      %  elseif strcmpi(CompareOriFlag,'"R"') == 1 & abs(Diff3) > 10;
                      %      Flag3 = 'R';
                      %      Baseline3 = str2num(RawGauge3);
                      %      CorrDiff3 = 0; % there isn't a corrected difference
                      %      Rebounding = 0;
                      %      Baseline3 = str2num(RawGauge3);

                        %% may hace to delete this clause
                        elseif abs(Diff3)>3;
                            Baseline3 = RawGauge3;
                            CorrDiff = 0;
                            Flag3 = 'R';
                            Rebounding = 0;
                            fprintf(fid_log,'%s%s%s%4.2f\n','the newest drain criteria applies on ', cHumanDate3, ' due to a drop of ', Diff3);
                        else Baseline3 = CompareBase; % the baseline does not change from the previous
                            Flag3 = 'Ae'; % the difference is probably evaporation
                            Rebounding = 0;
                            %fprintf(1,'%s%4.2f\n','the value of recent diffs is ', Recent_Diffs)
                        end

                        AccGauge3 = CompareAcc; % the accumulation does not change
                        Rebounding = 0;

                    % if the raw gauge is Nan or adam flags missing...
                    elseif RawGauge3 == NaN | strcmpi(OriFlag3, '"M"') ==1;
                        Baseline3 = CompareBase;
                        Flag3 = 'M';
                        RawGauge3 = NaN;
                        CorrDiff3 = NaN;
                        Diff3 = 0;
                        Rebounding = 0;
                        CountM = 1;

                    %%Recent_Diffs = Recent_Diffs + Diff3; % recent diffs counts the small flux, in case there is a leak
                    elseif CompareRaw == NaN & RawGauge3 ~= NaN;
                        Baseline3 = RawGauge3;
                        Flag3 = '';
                        AccGauge3 = CompareAcc;
                        CorrDiff3 = 0;
                        Diff3 = 0; 
                        %RawGauge3 = num2str(CompareRaw);
                        Rebounding = 0;
                        CountM = 0;

                    else Baseline3 = CompareBase; Flag3 = 'M'; AccGauge3 = CompareAcc; RawGauge3 = CompareRaw; Rebounding =0; CountM = CountM+1;
                    end % end the loop of simmer conditions

                    %%% if the recent_diffs is more than 2, move into raining mode.
                    if Recent_Diffs > 2 & strcmp(Flag3,'Bomb')==0;
                        NotRaining = 0;
                        
                        
                        Baseline3 = RawGauge3; % reset the baseline
                        
                      
                        MaybeDry = 0;
                        Flag3 = 'F'; % flag for winter mode switch
                        CorrDiff3 = Diff3;
                        Recent_Diffs = CorrDiff3; % reset the difference counter
                        Count = 0; % reset the count to 0 just in case it's not
                        fprintf(fid_log,'%s%s%s%4.2f\n','the raining mode is activated on ', cHumanDate3, ' since we have accumulated ', Recent_Diffs);
                    end
                    
                   % try
                        ThirdRecord = {DN3, cHumanDate3, AccGauge3, RawGauge3, Baseline3, Diff3, CorrDiff3, Flag3, OriFlag3};    
                   % catch
                   %     ThirdRecord = {DN3, cHumanDate3, AccGauge3, RawGauge3, Baseline3, Diff3, CorrDiff3, Flag3, OriFlag3};    
                   % end
                    Results(i,:) = ThirdRecord;
                
                    clearvars ThirdRecord

                end
                %TrackSeasons(i) = NotRaining;

            end

            fprintf(1,'%s\n','Hey, its done');
            clearvars i % could this have been the error?

            %%%%% DIARY
            % HighResOut = 'VANMET_SA_09202014.csv';
            % HighResOut = 'H15MET_SA_09202014.csv';
            % HighResOut = 'UPLMET_SA_09202014.csv';
            % HighResOut = 'UPLMET_SH_09202014.csv';
            % HighResOut = 'CENMET_SA_09212014.csv';
            % HighResOut = 'CENMET_SH_09202014.csv';
            % HighResOut = 'CS2MET_NL4_09202014.csv';

            %%%%% OUTPUT
            %% I keep the files in a folder called DAILYSUMS. You may need to mkdir.
            % filename2 = HighResOut;
            % fid1 = fopen(filename2,'w');

            % open file title writing
            fprintf(fid1,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s, %s\n','DBCODE','ENTITY','SITECODE','PRECIP_METHOD','HEIGHT','QC_LEVEL','PROBE_CODE','DATE_TIME','PRECIP_TOT','PRECIP_TOT_FLAG','GAUGE_HEIGHT','ORIGINAL_FLAG','EVENT_CODE');
            fprintf(fid1,'%s,%s,%s,%s,%d,%s,%s,%s,%4.2f,%s,%4.2f,%s,%s\n', 'MS043','13', Station, Method, Height,'1P', Probe_Code, cHumanDate2, 0, '', Results{1,4}, Results{1,9}, 'NA');
            % assign event codes to the high res
            for i = 2:length(Results)
                % if Adamn flagged a 'T' it is the orifice temperature, that's a Questionable
                if strcmpi(Results{i,9},'"T"');
                    Results{i,8} = 'Q';
                    fprintf(fid_log,'%s%s%s%s\n','a T flag was replaced with Q for ', Probe_Code, ' on ',Results{i,2});
                end

                % if it's estimated by adam then its estimated
                if strcmpi(Results{i,9},'"E"');
                    Results{i,8} = 'E';
                end

                % if the Results in that corrected difference is a NaN but the prior is not a nan, then 
                % the current one is the same as the prior and it's estimated
                if Results{i,7} == NaN & Results{i-1,7} ~=NaN;
                    Results{i,7} = Results{i-1,7};
                    Results{i,8} = 'E';
                    Results{i,9} = 'INTPRO';
                end

                %% Assign Event Codes
                if strcmpi(Results{i,8},'R')==1;
                    Event_Code = 'MAINTE';
                    Results{i,8} = 'E';
                    Results{i,7} = 0;
                    fprintf(fid_log,'%s%s%s%s%s%4.2f\n','a maintenance was detected for ', Probe_Code, ' on ',Results{i,2}, 'with a magnitude of ', Results{i,6});
                elseif strcmpi(Results{i,8},'F')==1 & Results{i,7} >= 1;
                    Event_Code = 'INTPRO';
                    Results{i,8} = 'Q';
                elseif strcmpi(Results{i,8},'F')== 1 & Results{i,7} < 1;
                    Event_Code = 'INTPRO';
                    Results{i,8} = '';
                elseif strcmpi(Results{i,8},'Bomb')==1;
                    Event_Code = 'WEATHR';
                    fprintf(fid_log,'%s%s%s%s%s%4.2f\n','a bomb was detected for ', Probe_Code, ' on ',Results{i,2}, 'with a magnitude of ', Results{i,6});
                elseif strcmpi(Results{i,8},'M') ==1
                    Results{i,4} = NaN;
                    Results{i,7} = NaN;
                    Event_Code = 'NA';
                else Event_Code = 'NA';
                end
                %fprintf(fid1,'%s,%s,%s,%s,%d,%s,%s,%s,%4.2f,%s,%4.2f,%s,%s\n', 'MS043','13', Station, Method, Height,'1P', Probe_Code, Results{i,2}, 0, '', Results{i,4}, Results{i,9}, Event_Code);
                % print the high res
                fprintf(fid1,'%s,%s,%s,%s,%d,%s,%s,%s,%4.2f,%s,%4.2f,%s,%s\n', 'MS043','13', Station, Method, Height,'1P', Probe_Code, Results{i,2}, Results{i,7}, Results{i,8}, Results{i,4}, Results{i,9}, Event_Code);

            end
            fclose(fid1)

            clearvars Event_Code
            %end
            %fclose(fid1);

            %%%%% FOR MS043 METHODS
            %filename = 'MS043_VANMET_SA_09202014.csv';
            % filename = 'MS043_H15MET_SA_09202014.csv';
            % filename = 'MS043_UPLMET_SA_09202014.csv';
            % filename = 'MS043_CS2MET_NL4_09202014.csv';
            % filename = 'MS043_highres_CENMET_SA_09212014.csv';
            % filename = 'MS043_H15MET_SA_09202014.csv';
            % filename = 'MS043_highres_CENMET_SH_09232014.csv';
            %filename = HighResOut;
            %fid1 = fopen(filename,'w');

            % open file title writing
            %fprintf(fid1,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n','DBCODE','ENTITY','SITECODE','PRECIP_METHOD','HEIGHT','QC_LEVEL','PROBE_CODE','DATE_TIME','PRECIP_TOT','PRECIP_TOT_FLAG','EVENT_CODE');

            % assign event codes to the high res
            %for i = 2:length(Results)
                
            %     %% Assign Event Codes
            %     if strcmpi(Results{i,8},'R')==1;
            %         Event_Code = 'MAINTE';
            %     elseif strcmpi(Results{i,8},'Rf')==1;
            %         Event_Code = 'MAINTE';
            %     elseif strcmpi(Results{i,8},'F')==1;
            %         Event_Code = 'INTPRO';
            %     elseif strcmpi(Results{i,8},'Bomb')==1 & vectordate(i,2) > 9 & vectordate(i,2) <= 5;
            %         Event_Code = 'WEATHE';
            %     elseif strcmpi(Results{i,8},'M')==1;
            %         Results{i,4} = NaN;
            %         Results{i,7} = NaN;
            %         Event_Code = 'NA';
            %     else Event_Code = 'NA';
            %     end

            %     % print the high res
            %     fprintf(fid1,'%s,%s,%s,%s,%d,%s,%s,%s,%4.2f,%s,%s\n', 'MS043','13', Station, Method, Height,'1P', Probe_Code, Results{i,2}, Results{i,7}, Results{i,8}, Event_Code);

            %     clearvars Event_Code
            % end
            % fclose(fid1);




            % a possible daily flagging method to incorporate adam's codes: 
            %% Adam's codes, potential correlates in our codes, event tags, priority
            %codebase = {{'"R"',{'Q','','M'},{'MAINTE','NA','NA'},{'Q','Q','M'}}; 
            %            {'"T"',{'Q','','M'},{'MAINTE','NA','NA'},{'Q','Q','M'}};
            %            {'"I"',{'Q','','M'},{'NA','NA','NA'},{'Q','','M'}};
            %            {'"E"',{'Q','E',''},{'NA','INTPRO'},{'Q','E','E'}}};


            %filename = fullfile('DAILYSUMS',QuickSums);
            % the quick sums file has the date vector also to help with checking
            %fid = fopen(filename,'w');
            %fprintf(fid,'%s,%s,%s,%s,%s,%s,%s,%s\n','YEAR','MONTH','DAY','HOURS','MINUTES','SECONDS','SUM RESULTS','SUM_FLAGS');
                

            %%% Quick Sums contains daily summary data before missings are removed. This can be used to look back and salvage any days where we have 1 or more important flows!
            %try
            % get the corrected differences as a matrix for doing daily sums
%             numerical_diff = cell2mat(Results(:,7));

%             % if the flag is an 'R' put the R in the daily_flags!
%             isR = zeros(length(Results),1);
%             isBomb = zeros(length(Results),1);
%             isRf   = zeros(length(Results),1);
%             for k = 1:length(Results);
%                 isR(k,1) = strcmpi(Results{k,8},'R'); % if there is an R 1, else 0
%                 isBomb(k,1) = strcmpi(Results{k,8},'Bomb')*(Results{k,7}); % times if there is a bomb (0 or 1) by the results
%                 isRf(k,1) =strcmpi(Results{k,8},'Rf')*(Results{k,7});
%             end

%             fprintf(1,'%s\n','analyzed daily flags for resets and bombs')

%             % daily flags contains the flags on the day - A, E, M, Q, and R
%             daily_flag = cell(length(M2M-1),1);
               
%             % temporary storage of the daily values    
%             value = zeros(length(M2M),1);
                
%             % the daily vector!
%             % this_val is the day in vector form
%             this_val = M2M(:,1:6);

%             event_code = cell(length(M2M)-1,1);

%             % for each day:
%             for j = 1:length(M2M)-1;

%                 % the daily sum is the sum of the corrected differences from the first index to the next index
%                 % the column 10 in the M2M counter contains the indices for each day
%                 value(j) = nansum(numerical_diff(M2M(j,10):M2M(j+1,10)));
%                 missings(j) = 100*(M2M(j,9)/(M2M(j+1,10)-M2M(j,10))); 
%                 isBombChk(j) = sum(isBomb(M2M(j,10):M2M(j+1,10)))/value(j); % sum the values with bomb and see what percent of day they are
%                 isR(j) = any(isR(M2M(j,10):M2M(j+1,10))); % any non zero R?
                        
%                     if isBombChk(j) > 0.2;
%                         daily_flag{j} = 'Q';
%                         %fprintf(fid,'%d,%d,%d,%d,%d,%d,%4.2f,%s\n',this_val(j+1,1), this_val(j+1,2), this_val(j+1,3), this_val(j+1,4), this_val(j+1,5), this_val(j+1,6),value(j),daily_flag{j});
%                         continue;

%                     elseif isR(j) == 1;
%                         daily_flag{j} = 'Q';
%                         event_code{j} = 'MAINTE'
%                         %fprintf(fid,'%d,%d,%d,%d,%d,%d,%4.2f,%s\n',this_val(j+1,1), this_val(j+1,2), this_val(j+1,3), this_val(j+1,4), this_val(j+1,5), this_val(j+1,6),value(j),daily_flag{j});
%                         continue; 

%                     %%% DAILY FLAGS
%                     % if there aren't any missing or reset values, the day is ok
%                     elseif ~any(M2M(j,9));
%                         daily_flag{j} = ''
%                         %fprintf(fid,'%d,%d,%d,%d,%d,%d,%4.2f,%s\n',this_val(j+1,1), this_val(j+1,2), this_val(j+1,3), this_val(j+1,4), this_val(j+1,5), this_val(j+1,6),value(j),daily_flag{j});
%                         continue;

%                     % if 5 percent or less is missing or reset, the day is ok
%                     elseif 5 < missings(j);
%                         daily_flag{j} = '';
%                         event_code{j} = 'NA'
%                         %fprintf(fid,'%d,%d,%d,%d,%d,%d,%4.2f,%s\n',this_val(j+1,1), this_val(j+1,2), this_val(j+1,3), this_val(j+1,4), this_val(j+1,5), this_val(j+1,6),value(j),daily_flag{j});
%                         continue;

%                         % if there is more than 50 % missing but there is one big value we want to keep that value around!
%                         elseif 5 >= missings(j) & missings(j) <=20;
%                             daily_flag{j} = 'Q';
%                             %fprintf(fid,'%d,%d,%d,%d,%d,%d,%4.2f,%s\n',this_val(j+1,1), this_val(j+1,2), this_val(j+1,3), this_val(j+1,4), this_val(j+1,5), this_val(j+1,6),value(j),daily_flag{j});
%                             continue;

%                         % if there are values around which sum to less than 3, and less than 50% data is present,
%                         % the day is probably a missing
%                         elseif 20 <= missings(j);
%                             daily_flag{j} = 'M';
%                             value(j) = NaN;
%                             %fprintf(fid,'%d,%d,%d,%d,%d,%d,%4.2f,%s\n',this_val(j+1,1), this_val(j+1,2), this_val(j+1,3), this_val(j+1,4), this_val(j+1,5), this_val(j+1,6),value(j),daily_flag{j});
%                             continue;

                        
%                         % if a Q flag is triggered as an exception to all other clauses, alert me
%                         else daily_flag{j} = 'Q';
%                             fprintf(1,'%s\n',['Hey on iteration ' num2str(j) 'of the Daily Sums, I did something weird.']);
%                             %fprintf(fid,'%d,%d,%d,%d,%d,%d,%4.2f,%s\n',this_val(j+1,1), this_val(j+1,2), this_val(j+1,3), this_val(j+1,4), this_val(j+1,5), this_val(j+1,6),value(j),daily_flag{j});
%                         end
                    
%                 end

%             %catch ME % catch the exception if the data is not an even day length, which will glitch out here
%             %end

%             %%% for determining the daily sums
%             %M2Mout = 'MSO43_daily_CENMET_SH_09232014.csv';
%             filename1 = M2Mout;
%             fid2 = fopen(filename1,'w');
%             fprintf(1,'s\n','writing the daily file')
%             fprintf(fid2,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n','DBCODE','ENTITY','SITECODE','PRECIP_METHOD','HEIGHT','QC_LEVEL','PROBE_CODE','DATE_TIME','PRECIP_TOT','PRECIP_TOT_FLAG','EVENT_CODE');

%             % for the length of all days - 1
%             for i = 2:length(M2M);  
%                 % get the datestring and the maintenance flag
%                 ds = datestr(M2M(i,1:6),'yyyy-mm-dd HH:MM:SS');

%                 % Maintenance should be flagged in the daily 
%                 if strcmpi(daily_flag{i},'M')==1;
%                     value(i) = NaN;
%                     EventCode = 'NA';
%                 end

%                 if strcmpi(daily_flag{i},'R') ==1;
%                     EventCode = 'MAINTE';
%                 else EventCode = 'NA';
%                 end

%                 % write the output for all but one
%                 fprintf(fid2,'%s,%s,%s,%s,%d,%s,%s,%s,%4.2f,%s,%s\n','MS043','13', Station, dMethod, Height, '1P', Probe_Code,ds,value(i),daily_flag{i},EventCode);
%             end
%                 % write the final output as 0 since the day is not done
%                 fprintf(fid2,'%s,%s,%s,%s,%d,%s,%s,%s,%4.2f,%s,%s\n','MS043','13', Station, dMethod, Height, '1P', Probe_Code,ds,value(i),'',EventCode);
%             fclose(fid2)

         clearvars d  HighResOut FirstRecord SecondRecord M2M M2Mout M2Mcount
         dataset = dataset + 1;
     fprintf(1,'s\n',' i am done processing your files!')
 %end

%fclose(fid_log)







