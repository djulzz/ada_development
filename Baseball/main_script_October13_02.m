clear all;
close all;
clc;

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



% gy_impact_threshold = 12000;
% threshold_interval = 3;
% parameters = [threshold_interval, gy_impact_threshold];

indices = [1 : 1 : 19];

fprintf( 'START\n' );

MinimumPostShockNumberRequired = 30;
nBBEntries = length( indices );
folder_used = folder_list_01;

processedFileNumber = zeros( 1, 4 );
scores = zeros( 1, 4 );
file = fopen( 'compare.csv', 'w' );
for i = 1 : 1 : nBBEntries
    idx = indices( i );
    folder_selected = char( cell2mat( folder_used( idx ) ) );
    nickname_used = char( cell2mat( folder_list_01_nickname( idx ) ) );
    TestBaseDirectoryPath = folder_selected;
    the_BL_ADA_Test = BL_ADA_Test( TestBaseDirectoryPath );
    expected_result_tf = folder_list_01_expected_result( idx );
    
    % test B1
    idx = 1;
    the_BL_ADA_Test.Initialize( TestBaseDirectoryPath );
    testName = 'B1';
    TestParameters = [0, 0];
    [nDiscarded, nCSV_Records] = the_BL_ADA_Test.Run( testName, expected_result_tf, TestParameters, MinimumPostShockNumberRequired );
    nProcess = nCSV_Records - nDiscarded;
    processedFileNumber( idx ) = processedFileNumber( idx ) + nProcess;
    percentageB1 = the_BL_ADA_Test.GetTestPassingPercentage(  );
    p = percentageB1;
    scores( idx ) = scores( idx ) + nProcess * p;

    % test B2 current
    idx = 2;
    the_BL_ADA_Test.Initialize( TestBaseDirectoryPath );
    testName = 'B2';
    TestParameters = [2, 2000];
    [nDiscarded, nCSV_Records] = the_BL_ADA_Test.Run( testName, expected_result_tf, TestParameters, MinimumPostShockNumberRequired );
    nProcess = nCSV_Records - nDiscarded;
    processedFileNumber( idx ) = processedFileNumber( idx ) + nProcess;
    percentageB2_current = the_BL_ADA_Test.GetTestPassingPercentage(  );
    p = percentageB2_current;
    scores( idx ) = scores( idx ) + nProcess * p;

    % test B2 tightened
    idx = 3;
    the_BL_ADA_Test.Initialize( TestBaseDirectoryPath );
    testName = 'B2';
    TestParameters = [10, 9000];
    %TestParameters = [25, 2000];
    [nDiscarded, nCSV_Records] = the_BL_ADA_Test.Run( testName, expected_result_tf, TestParameters, MinimumPostShockNumberRequired );
    nProcess = nCSV_Records - nDiscarded;
    processedFileNumber( idx ) = processedFileNumber( idx ) + nProcess;
    percentageB2_tightened = the_BL_ADA_Test.GetTestPassingPercentage(  );
    p = percentageB2_tightened;
    scores( idx ) = scores( idx ) + nProcess * p;

    % test B2.1
    idx = 4;
    the_BL_ADA_Test.Initialize( TestBaseDirectoryPath );
    testName = 'B2.1';
    TestParameters = [0, 0];
    [nDiscarded, nCSV_Records] = the_BL_ADA_Test.Run( testName, expected_result_tf, TestParameters, MinimumPostShockNumberRequired );
    nProcess = nCSV_Records - nDiscarded;
    processedFileNumber( idx ) = processedFileNumber( idx ) + nProcess;
    percentageB21 = the_BL_ADA_Test.GetTestPassingPercentage(  );
    p = percentageB1;
    scores( idx ) = scores( idx ) + nProcess * p;


%     fprintf( 'Test: %s...\n', nickname_used );
%     fprintf( '(B1) = %.2f%% - (B2,current) = %.2f%% -  (B2,tightened) = %.2f%% - (Scott) = %.2f%%\n', percentageB1, percentageB2_current, percentageB2_tightened, percentageB21 );
    fprintf( file, '%i,%i,%i,%s,%.2f,%.2f,%.2f,%.2f\n', nProcess, expected_result_tf, nCSV_Records, nickname_used, percentageB1, percentageB2_current, percentageB2_tightened, percentageB21 );
end
fclose( file )
fprintf( 'STOP\n' );

avg_scores = scores ./ processedFileNumber;

avg_scores

folder_list_03 = {'/Users/jesposito/Google Drive/data/2013-09-18 Batting Cage Testing/Cage Testing',
    '/Users/jesposito/Google Drive/data/2013-09-18 Batting Cage Testing/Lab - Misfire Testing' };


% nMainFolders = length( folder_list_01 );
% for i = 1 : 1 : nMainFolders
%     str = char( cell2mat( folder_list_01( i ) ) );
%     path = str;
%     some_CSV_Directory = CSV_Directory( path );
%     n = some_CSV_Directory.GetNumberOfFiles(  );
%     fprintf( 'path  - # of files = %i - ', n );
%     avg = 0;
%     for j = 1 : 1 : n
%         current_file = some_CSV_Directory.getFileAt( j );
%         RawSensorData = BLRawSensorData( current_file );
%         nSamples = RawSensorData.NumberOfSamples(  );
%         %fprintf( 'current file = %s - Number of Samples = %i\n', current_file, nSamples );
%         range = ShockAnalyzer.DetectDiscontinuityAcc( RawSensorData, 1500 );
%         CommonRange = ShockAnalyzer.ComputeDiscontinuityCommonRange( range );
%         nPostShock = 0;
%         if( ~isempty( CommonRange ) && ( CommonRange( 1 ) > 0 ) )
%             nPostShock = ( nSamples - CommonRange( 1 ) ) + 1;
%             %fprintf( 'LB = %i - number post shock = %i\n', CommonRange( 1 ), nPostShock );
%             avg = avg + nPostShock;
%         end
%         
%     end
%     avg = avg / n;
%     fprintf( 'avg. post shock = %.2f\n', avg );
% end

    
threshold = 1500;
csv_base = ['/Users/', str_username, '/Google Drive/Julien_Code/matlab_code/resources/missfire/'];

the_CSV_Directory = CSV_Directory( csv_base );
the_CSV_Directory.ListFiles(  );



k1 = { csv_base };
v1 = { false };


nFiles_vec = [];
div = max(nFiles_vec);
nFiles_vec = nFiles_vec / div;
test_prediction_Map = containers.Map( k1, v1 );
number_of_tests = test_prediction_Map.Count(  );


base = char( cell2mat( k1( 1 ) ) );
folder = base;
files = dirrec( folder, '.csv' );
[nRows, nFiles] = size( files );
nActualGoodFiles = 0;
nFiles_vec = [nFiles_vec, nFiles];
index_file_start = 1;
% index_file_stop = nFiles;
index_file_stop = 1;
for Index_Current_File = index_file_start : 1 : index_file_stop
    current_filename = the_CSV_Directory.getFileAt( Index_Current_File );
%     [pathstr, name, ext] = fileparts( current_filename );
    s = dir( current_filename );
    sz = s.bytes;

    if( sz < 1000 )
        ;
    else
        nActualGoodFiles = nActualGoodFiles + 1;
    end
end
fprintf( 'Percentage good files in current test folder = %.2f%%\n', ( nActualGoodFiles / nFiles ) * 100 );




w_misfire = 1;
w_swing   = 1;
all_records = [  ];
all_scores = [  ];


score = 0;
percentage_accum = [  ];

base = char( cell2mat( k1( 1 ) ) );
expected_result = test_prediction_Map( base );
expected_result_str = [];
if( true == expected_result )
    expected_result_str = 'true';
else
    expected_result_str = 'false';
end
folder = base;
files = dirrec( folder, '.csv' );
[nRows, nCols] = size( files );


current_test_res = [  ];

nFiles = nCols;

interv = [  ];
index_file_start = 1;

algorithm_used = 'B1';


the_BlastPlotter = BlastPlotter(  );

index_file_stop = 1;
for Index_Current_File = index_file_start : 1 : index_file_stop
    cur_cell = files( 1, Index_Current_File );
    fullFileName = cell2mat( cur_cell );
    [pathstr, name, ext] = fileparts( fullFileName );
    RawSensorData = BLRawSensorData( fullFileName );
    fprintf( 'analyzing file %s...\n', name );
    %figure( 1 );
    %the_BlastPlotter.Plot( RawSensorData );

    range = ShockAnalyzer.DetectDiscontinuityAcc( RawSensorData, 1500 );
    CommonRange = ShockAnalyzer.ComputeDiscontinuityCommonRange( range );
    CommonRange
    [index ,values] = the_Algorithm_Functor.CollectDiscontinuities( RawSensorData.Gyroscopes( :, 1 ) );
    [index', values']
    [res, report] = mexRunADA( algorithm_used, RawSensorData.Accelerations, RawSensorData.Gyroscopes, true, parameters, 1 );
    %[res, report] = mexRunADA( algorithm_used, RawSensorData.Accelerations, RawSensorData.Gyroscopes, true, parameters, 1 );
    f_handle_Piyush_report( algorithm_used, report, length( RawSensorData.Accelerations ) );
    current_test_res = [current_test_res, res];
end

results = [  ];
qualifier = [  ];
w = 0;
nActualTests = length( current_test_res );
if( true == expected_result )
    w = w_swing;
    qualifier = 'Acceptance';
    results = ( current_test_res == ones( 1, nActualTests ) );
else
    qualifier = 'Discrimination';
    w = w_misfire;
    results = ( current_test_res == zeros( 1, nActualTests ) );
end
nOnes = sum( results );
rate = ( nOnes / nFiles );
percentage_success = rate * 100;
score = score + w * percentage_success;
percentage_accum = [percentage_accum, percentage_success];
all_scores = [all_scores, score];

nScores = length( percentage_accum );
fprintf( 'INTERVAL = %i - GY_THR. = %i - ', threshold_interval, gy_impact_threshold );
all_records = [all_records; percentage_accum];
fprintf( ' - TOTAL score = %.3f\n', score );

