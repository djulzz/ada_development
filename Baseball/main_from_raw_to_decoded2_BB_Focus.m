clear all;
close all;
clc;

% addpath( '/Users/jesposito/Google Drive/Julien_Code/matlab_code/functions' );
% addpath( './classes' );

addpath( 'mex' );
addpath( 'functions' );
addpath( 'classes' );
%addpath( 'C:\Users\djulzz\Desktop\blast-api_win\mex_files\' );
MSG_SHOCK_ANY_ACCE_LAXIS  = 0;
MSG_GYROS_MATCH_DOWNSWING = 1;
MSG_IMPACT_SIGNATURE      = 2;
MSG_NOTHING               = 3;
threshold = 1500;

google_drive = '/Users/jesposito/Google Drive/';
%google_drive = 'C:/Users/djulzz/Google Drive/';

delete( 'log.txt' );
k1 = {
    [google_drive, 'Blast Motion Sensor-Recorder Data/BB/BB-1146/'],
    [google_drive, 'Blast Motion Sensor-Recorder Data/BB/BB-1148/'],
    [google_drive, 'Blast Motion Sensor-Recorder Data/BB/BB-1236/'],
    
    [google_drive, 'Blast Motion Sensor-Recorder Data/BB/BB-1237/'],
    [google_drive, 'Blast Motion Sensor-Recorder Data/BB/BB-1238/'],
    [google_drive, 'Blast Motion Sensor-Recorder Data/BB/BB-1239/'],
    
    [google_drive, 'Blast Motion Sensor-Recorder Data/BB/BB-1240/'],
    [google_drive, 'Blast Motion Sensor-Recorder Data/BB/BB-1298/'],
    [google_drive, 'Blast Motion Sensor-Recorder Data/BB/BB-1299/']
    };


v1 = { 
    false,
    false,
    false,
    
    false,
    false,
    false,
    
    false,
    false,
    false,
    };


nFiles_vec = [];
div = max(nFiles_vec);
nFiles_vec = nFiles_vec / div;
test_prediction_Map = containers.Map( k1, v1 );
number_of_tests = test_prediction_Map.Count(  );
for index_test = 1 : 1 : number_of_tests
    base = char( cell2mat( k1( index_test ) ) );
    folder = base;
    files = dirrec( folder, '.csv' );
    [nRows, nFiles] = size( files );
%     fprintf( 'Current Test - #files = %i\n', nFiles );
    nActualGoodFiles = 0;
    nFiles_vec = [nFiles_vec, nFiles];
    for Index_Current_File = 1 : 1 : nFiles
        cur_cell = files( 1, Index_Current_File );
        fullFileName = cell2mat( cur_cell );
        [pathstr, name, ext] = fileparts( fullFileName );
        s = dir( fullFileName );
        sz = s.bytes;
%         fprintf( 'file %i of %i...', Index_Current_File, nFiles );
        if( sz < 1000 )
            ;
%             fprintf( ' CORRUPTED\n' );
        else
%             fprintf( ' OK\n' );
            nActualGoodFiles = nActualGoodFiles + 1;
        end
    end
    fprintf( 'Percentage good files in current test folder = %.2f%%\n', ( nActualGoodFiles / nFiles ) * 100 );
end
% pause( 300000000 );


w_misfire = 1;
w_swing   = 1;
all_records = [  ];
all_scores = [  ];

Interval = 3;
gyThreshold = 5000;
AccelDiscontinuityThreshold = 1500;
GxySquaredImpactThreshold = 8000^2;
   
param( 1 ) = Interval;
param( 2 ) = gyThreshold;
param( 3 ) = AccelDiscontinuityThreshold;
param( 4 ) = GxySquaredImpactThreshold;

for gyThreshold = 3000 : 500 : 9000
    
        %GxySquaredImpactThreshold = GxyImpactThreshold^2;
        param( 1 ) = Interval;
        param( 2 ) = gyThreshold;
        param( 3 ) = AccelDiscontinuityThreshold;
        param( 4 ) = GxySquaredImpactThreshold;
        
        score = 0;
        percentage_accum = [  ];
        
        %fprintf( 'Number of tests = %i\n', number_of_tests );
        for index_test = 1 : 1 : number_of_tests
            base = char( cell2mat( k1( index_test ) ) );
            expected_result = test_prediction_Map( base );
            expected_result_str = [];
            if( true == expected_result )
                expected_result_str = 'true';
            else
                expected_result_str = 'false';
            end
            %fprintf( '\n\nEntering directory \"%s\". Expected result = %s...\n', base, expected_result_str );
            folder = base;
            files = dirrec( folder, '.csv' );
            [nRows, nCols] = size( files );


            current_test_res = [  ];

            nFiles = nCols;
%             nFiles = 1;
            interv = [  ];
            for Index_Current_File = 1 : 1 : nFiles
                cur_cell = files( 1, Index_Current_File );
                fullFileName = cell2mat( cur_cell );
                [pathstr, name, ext] = fileparts( fullFileName );
                RawSensorData = BLRawSensorData( fullFileName );
%                 [res, values] = f_detect_swing( RawSensorData, threshold_interval, gy_impact_threshold );
                res = mexRunADA( RawSensorData.Accelerations, RawSensorData.Gyroscopes, true, param, 1 );
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
        end
        nScores = length( percentage_accum );
        %fprintf( 'GxyImpactThreshold = %i - ', GxyImpactThreshold );
        fprintf( 'indiv. percents: ' );
        all_records = [all_records; percentage_accum];
        for m = 1 : 1 : nScores
            fprintf( '%.2f - ', percentage_accum( m ) );
        end
        fprintf( ' - TOTAL score = %.3f\n', score );
end
