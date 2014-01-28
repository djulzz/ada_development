clear all;
close all;
clc;

format bank;

load( 'reference_scores.mat' );

global g_verbose;

g_verbose = false;
google_drive = '/Users/jesposito/Google Drive/';
str_username = 'jesposito';

addpath( ['/Users/', str_username, '/Google Drive/Julien_Code/matlab_code/functions'] );
addpath( ['/Users/', str_username, '/Google Drive/Julien_Code/matlab_code/classes'] );
%addpath( ['/Users/', str_username, '/Google Drive/Julien_Code/matlab_code/mex_files'] );
addpath( '/Users/jesposito/RepoTop/julien_tests/mex' );
addpath( ['functions'] );
addpath( ['classes'] );

folder_list_01 =    {
    [google_drive, 'John_Goree/Baseball filter tests/Valid swings/'],   % 01 +
    [google_drive, '2013_06_27 Easton/'],                               % 02 +
    [google_drive, 'Granger Good Baseball Swings/'],                    % 03 +
    [google_drive, 'postimpact/'],                                      % 04 +
    [google_drive, '20 post impacts/granger/'],                         % 05 +
    [google_drive, '20 post impacts/victor/'],                          % 06 +
    [google_drive, 'John_Goree/Baseball filter tests/Invalid swings/'], % 07
    [google_drive, '20 post impacts/misfires/'],                        % 08
    [google_drive, 'Blast Motion Sensor-Recorder Data/BB/BB-1146/'],    % 09
    [google_drive, 'Blast Motion Sensor-Recorder Data/BB/BB-1148/'],    % 10
    [google_drive, 'Blast Motion Sensor-Recorder Data/BB/BB-1236/'],    % 11
    [google_drive, 'Blast Motion Sensor-Recorder Data/BB/BB-1237/'],    % 12
    [google_drive, 'Blast Motion Sensor-Recorder Data/BB/BB-1238/'],    % 13
    [google_drive, 'Blast Motion Sensor-Recorder Data/BB/BB-1239/'],    % 14
    [google_drive, 'Blast Motion Sensor-Recorder Data/BB/BB-1240/'],    % 15
    [google_drive, 'Blast Motion Sensor-Recorder Data/BB/BB-1298/'],    % 16
    [google_drive, 'Blast Motion Sensor-Recorder Data/BB/BB-1299/'],    % 17
    [google_drive, 'Blast Motion Sensor-Recorder Data/BB/BB-2931/'],    % 18
    [google_drive, 'data/Scotts_Swings/']                               % 19
};

folder_list_01_nickname = {

    '"1 - Goree Valid"',
    '"1 - Easton"',
    '"1 - Granger Many Swings"',
    '"1 - Victor First Batch"',
    '"1 - Granger 2nd Batch"',
    '"1 - Victor 2nd Batch"',
    '"0 - Goree Invalid"',
    '"0 - Julien Missfires"',
    '"0 - Knocking ball back to pitcher"',
    '"0 - Hold bat against body, hit ground"',
    '"0 - Backhand ball towards batter"',
    '"0 - Hit plate then waggle"',
    '"0 - Waggle, hit plate, then waggle"',
    '"0 - Dropping the bat"',
    '"0 - Swing, no impact, then drop the bat"',
    '"0 - Throw and catch sensor/isolator"',
    '"0 - Banging/Tapping sensor/isolator on table"',
    '"0 - Practice swing (no impact), dropping bat, knocking ball back to pitcher, bat fell from leaning on a net"',
    '"1 - Scott Swings"'};


folder_list_01_expected_result = [true( 1, 6 ), false( 1, 12 ), true( 1, 1 ) ];


indices = [1 : 1 : 19];
% indices = [3, 4, 6];

fprintf( 'START\n' );

MinimumPostShockNumberRequired = 30;
nBBEntries = length( indices );
folder_used = folder_list_01;

processedFileNumber = zeros( 1, 4 );
scores = zeros( 1, 4 );

saved_scores = zeros( 1, nBBEntries );


for i = 1 : 1 : nBBEntries
    idx = indices( i );
    folder_selected = char( cell2mat( folder_used( idx ) ) );
    nickname_used = char( cell2mat( folder_list_01_nickname( idx ) ) );
    TestBaseDirectoryPath = folder_selected;
    the_BL_ADA_Test = BL_ADA_Test( TestBaseDirectoryPath );
    expected_result_tf = folder_list_01_expected_result( idx );
    expected_result_str = '"swing"';
    if( false == expected_result_tf )
        expected_result_str = '"missfire"';
    end

    % test B2.1
    idx_test = 4;
    the_BL_ADA_Test.Initialize( TestBaseDirectoryPath );
    testName = 'B2.1';
    TestParameters = [0, 0];
    [nDiscarded, nCSV_Records] = the_BL_ADA_Test.Run( testName, expected_result_tf, TestParameters, MinimumPostShockNumberRequired );
    nProcess = nCSV_Records - nDiscarded;
    processedFileNumber( idx_test ) = processedFileNumber( idx_test ) + nProcess;
    percentageB21 = the_BL_ADA_Test.GetTestPassingPercentage(  );
%     saved_scores( i ) = percentageB21;

    ref_percentage = reference_scores( idx );
    cur_percentage = percentageB21;
    test = ( cur_percentage >= ref_percentage );
    [ref_percentage, cur_percentage]
%     str = sprintf( 'files processed = (%i/%i) - test type = %s - Success Rate = %.2f%%', nProcess, nCSV_Records, expected_result_str, percentageB21 );
%     if( percentageB21 < 80 )
%         s2 = sprintf( ' - WARNING for test "%s"', nickname_used );
%         str = [str, s2];
%     end
%     fprintf( '%s\n', str );
end

fprintf( 'STOP\n' );
