clear all;
close all;
clc;

addpath( './functions' );
addpath( './classes' );
addpath( './mex' );

MSG_SHOCK_ANY_ACCE_LAXIS  = 0;
MSG_GYROS_MATCH_DOWNSWING = 1;
MSG_IMPACT_SIGNATURE      = 2;
MSG_NOTHING               = 3;
threshold = 1500;

delete( 'log.txt' );
k1 = {
    '/Users/jesposito/Desktop/julian/20 post impacts/victor/',
    '/Users/jesposito/Desktop/julian/20 post impacts/granger/',
    '/Users/jesposito/Desktop/julian/20 post impacts/misfires/'
    };

v1 = { 
    true, ...
    true,...
    false...
    };


test_prediction_Map = containers.Map( k1, v1 );


number_of_tests = length( k1 );
fprintf( 'Number of tests = %i\n', number_of_tests );
for index_test = 1 : 1 : number_of_tests
    
    base = char( cell2mat( k1( index_test ) ) );
    expected_result = test_prediction_Map( base );
    expected_result_str = [];
    if( true == expected_result )
        expected_result_str = 'true';
    else
        expected_result_str = 'false';
    end
    fprintf( '\n\nEntering directory \"%s\". Expected result = %s...\n', base, expected_result_str );
    folder = base;
    files = dirrec( folder, '.csv' );
    [nRows, nCols] = size( files );

    
    current_test_res = [  ];

    nFiles = nCols;
    for Index_Current_File = 1 : 1 : nFiles
        cur_cell = files( 1, Index_Current_File );
        fullFileName = cell2mat( cur_cell );
        [pathstr, name, ext] = fileparts( fullFileName );
        RawSensorData = BLRawSensorData( fullFileName );
        %res = f_scripted_mexRunADA( RawSensorData );
        [res, values] = f_detect_swing( RawSensorData );

        [ delta_t, range ] = f_analyze_discontinuity( RawSensorData );
        nPts = length( range );

        fprintf( '%s - %i\n', name, res );
        Limit_nPoints_Matching_Criteria = 1;
        bb = ( nPts < Limit_nPoints_Matching_Criteria );
%         if( true == expected_result )
%             bb = ( nPts >= Limit_nPoints_Matching_Criteria );
%             res = ~res;
%         end
%         res = res && bb;

        current_test_res = [current_test_res, res];

    end
    results = [  ];
    qualifier = [  ];

    if( true == expected_result )
        qualifier = 'Acceptance';
        results = ( current_test_res == ones( 1, nFiles ) );
    else
        qualifier = 'Discrimination';
        results = ( current_test_res == zeros( 1, nFiles ) );
    end
    nOnes = sum( results );
    rate = ( nOnes / nFiles );
    percentage_success = rate * 100;
    fprintf( 'Expected: %s\t%s rate = %.2f %% (num. files = %i)\n', expected_result_str, qualifier, percentage_success, nFiles );
end
