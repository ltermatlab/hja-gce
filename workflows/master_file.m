%% This is a master file containing all the data harvester calls.
% Created by Adam Kennedy, adam.kennedy@oregonstate.edu

%% send an introductory email
command = 'cd';
[status,cmdout] = system(command);

matlabmail({'adam.kennedy@oregonstate.edu'}, ...
    ['DEV Data harvester began at ' datestr(now) '.' 10, ...
    'Dev Functions will be called from: ' cmdout '.' 10], ...
    'Dev Data harvester script starting again...');

%% start the timer
tic;

%% CENMET
% CENMET_225 logger retired 4/22/2015
% process_cenmet_225_105 % last run: 8/11/2015
% process_cenmet_225_115 % last run: 8/11/2015
% process_cenmet_225_160 % All 60min data moved to 5min, last run 2014.
% process_cenmet_225_440 %retired - does not run
% process_cenmet_233_a_105_v2_arch2 % Must run arch2 for first 4+ months of 2015. 
process_cenmet_233_a_105_v2
process_cenmet_234_a_105

%% Watershed 7 Tower
process_ws7met_125_a_105

%% Gaging Stations
% These loggers retired in 2015
% process_gsws01_101_105
% process_gsws02_102_105
% process_gsws03_103_105
% process_gsws06_106_105
% process_gsws07_107_105
% process_gsws08_108_105
% process_gsws10_110_105
% process_gsmack_111_105
% process_gsws01_101_115
% process_gsws02_102_115
% process_gsws03_103_115
% process_gsws06_106_115
% process_gsws07_107_115
% process_gsws08_108_115
% process_gsws10_110_115
% process_gsmack_111_115

%New stations added 2015
process_gsmack_114_105
process_gsws01_115_105
process_gsws02_116_105
process_gsws03_117_105
process_gsws06_118_105
process_gsws07_119_105
process_gsws08_120_105
process_gsws09_121_105
%process_gsws10_123_105 %needs process file updated and telemetry installed

%% VARA
%process_varmet_301_105
%process_varmet_301_115
process_varmet_302_105

%% VANMET
% process_vanmet_231_a_105_arch2 % this table was archived on 4-13-2015
process_vanmet_231_a_105
process_vanmet_232_a_105
process_vanmet_232_b_105

%% MISC
process_greena_400_115
process_greenb_401_115

%% UPLMET
%process_uplmet_227_105 %last run 20151006 Logger Retired Must run for 2015
%process_uplmet_227_115 %last run 20151006 Logger Retired Must run for 2015
%process_uplmet_227_160 %last run 20151006 Logger Retired Must run for 2015
%process_uplmet_227_440 %last run 20151006 Logger Retired Must run for 2015
process_uplmet_235_105

%% PHRSC
process_phrsc_Table1
process_phrsc_Table2

%% CS2Met CLRG (Annual processing)
process_cs2met_clrg_Table1
process_cs2met_113_a_105
%process_cs2met_104_105 % added to Dev the week of 3/14/2015
% process_cs2met_104_110 % added to Dev the week of 3/14/2015
% process_cs2met_104_115 % added to Dev the week of 3/14/2015 

%% Primet
process_primet_226_a_105
process_primet_229_a_105
process_primet_229_b_105
process_primet_230_a_105

%% Stream Carbgon WS1
process_hagg_01_TmpCnd_MP1
process_hagg_01_TmpCnd_MP2
 
%% GEM Energy Monitoring
% % process_gem_greenhouse
        
%% HI15 (Annual processing) Last run: 20150318
%        process_hi15_207_105
%        process_hi15_207_440
%        process_hi15_208_115
%        process_hi15_208_440
       
%% Stream Temperature Network (Annual processing) Last run: 20150318
 
%% Reference stand 5min data - updated CR1000 loggers.
process_rs02_90_105
process_rs04_91_105
process_rs12_94_105
process_rs20_95_105
process_rs26_96_105

% % % % % Reference Stands (hrly) (Annual processing)
% % process_refstand_02_hrly
% % process_refstand_04_hrly
% % process_refstand_05_hrly
% % process_refstand_10_hrly
% % process_refstand_12_hrly
% % process_refstand_20_hrly
% % process_refstand_26_hrly
% % process_refstand_38_hrly
% % process_refstand_86_hrly
% % process_refstand_89_hrly
% % % 
% % % % % Reference Stands (6hr) (Annual processing)
% % process_refstand_02_6hr
% % process_refstand_04_6hr
% % process_refstand_05_6hr
% % process_refstand_10_6hr
% % process_refstand_12_6hr
% % process_refstand_20_6hr
% % process_refstand_26_6hr
% % process_refstand_38_6hr
% % process_refstand_86_6hr
% % process_refstand_89_6hr
% % %     
% % % % % Reference Stands (dly) (Annual processing)
% % process_refstand_02_dly
% % process_refstand_04_dly
% % process_refstand_05_dly
% % process_refstand_10_dly
% % process_refstand_12_dly
% % process_refstand_20_dly
% % process_refstand_26_dly
% % process_refstand_38_dly
% % process_refstand_86_dly
% % process_refstand_89_dly
% % 

%% WS1 EC Avg
%process_primet_226_a_105
process_ws1met_409_a_101
process_ws1met_409_b_101
%process_ws1_ec2_avg_sub
%        process_hjaws1ec_avg_NR01
%        process_ws1_ec_avg
% %    process_ws1_ec_avg_arch1
% %    process_ws1_ec_avg_arch2
% %    process_ws1_ec_avg_arch3
%       process_ws1_ec2_avg_sub
%       process_ws1_hyd_avg
%       process_ws1_met_avg

%% Copy files to file server
dos('C:\Users\kennedad\backup-scripts\MirrorPORTAL.bat');

%% save the time it took to run entire harvester and email
tEnd = toc;
B = ['Last DEV harvester completed ' datestr(now) ' and required ' tEnd ' seconds.'];
filename = 'time2eval.mat';
save(filename,'B');

matlabmail('adam.kennedy@oregonstate.edu', 'All the data harvester are done', ...
    ['Last DEV harvester completed ' datestr(now) ' and required ' num2str(tEnd) ' seconds.']);

 %system('shutdown /r /t')
