clear all;
close all;
clc;

str_username = 'jesposito';

addpath( ['/Users/', str_username, '/Google Drive/Julien_Code/matlab_code/functions'] );
addpath( ['/Users/', str_username, '/Google Drive/Julien_Code/matlab_code/classes'] );
addpath( ['/Users/', str_username, '/Google Drive/Julien_Code/matlab_code/mex_files'] );

MSG_SHOCK_ANY_ACCE_LAXIS  = 0;
MSG_GYROS_MATCH_DOWNSWING = 1;
MSG_IMPACT_SIGNATURE      = 2;
MSG_NOTHING               = 3;
threshold = 1500;


k1 = { ['/Users/', str_username, '/Google Drive/Julien_Code/matlab_code/resources/missfire/'] };
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
    cur_cell = files( 1, Index_Current_File );
    fullFileName = cell2mat( cur_cell );
    [pathstr, name, ext] = fileparts( fullFileName );
    s = dir( fullFileName );
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

gy_impact_threshold = 2000;
threshold_interval = 2;
parameters = [threshold_interval, gy_impact_threshold];
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
% index_file_stop = nFiles;
index_file_stop = 1;
for Index_Current_File = index_file_start : 1 : index_file_stop
    cur_cell = files( 1, Index_Current_File );
    fullFileName = cell2mat( cur_cell );
    [pathstr, name, ext] = fileparts( fullFileName );
    RawSensorData = BLRawSensorData( fullFileName );
    fprintf( 'analyzing file %s...\n', name );
    [res, report] = mexRunADA( RawSensorData.Accelerations, RawSensorData.Gyroscopes, true, parameters, 1 );
    deltaX = report( 1 );
    deltaY = report( 2 );
    deltaZ = report( 3 );
    sampleIndex = report( 4 );
    consecutiveGyAboveThreshold = report( 5 );
    gxPrev = report( 6 );
    gyPrev = report( 7 );
    
    fprintf( 'delta(X,Y,Z) = (%i,%i,%i) - @(%i/%i) - #consecutiveGyAboveThreshold = %i - gPrev(x,y) = (%i,%i)\n', deltaX, deltaY, deltaZ,...
        sampleIndex + 1, length( RawSensorData.TimeLine ),...
        consecutiveGyAboveThreshold, gxPrev, gyPrev );
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

