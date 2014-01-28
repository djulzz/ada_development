clear all;
close all;
clc;

addpath( './functions' );
addpath( './classes' );
addpath( '/Users/jesposito/RepoTop/julien_tests/mex' );



MSG_SHOCK_ANY_ACCE_LAXIS  = 0;
MSG_GYROS_MATCH_DOWNSWING = 1;
MSG_IMPACT_SIGNATURE      = 2;
MSG_NOTHING               = 3;




%base = '/Users/jesposito/blast data/John_Goree/Baseball filter tests/Valid swings/';
%base = '/Users/jesposito/blast data/John_Goree/Baseball filter tests/Invalid swings/Hitting shoe/';
path = '/Users/jesposito/Desktop/Data/Baseball CSVs/Blast Data/2013_06_27 Easton/';
base = path;
%base = '/Users/jesposito/blast data/John_Goree/Baseball filter tests/Invalid swings/Tapping plate/';
%base = '/Users/jesposito/blast data/postimpact/';
folder = base;
files = dirrec( folder, '.csv' );
[nRows, nCols] = size( files );

MSG_SHOCK_ANY_ACCE_LAXIS  = 0;
MSG_GYROS_MATCH_DOWNSWING = 1;
MSG_IMPACT_SIGNATURE      = 2;
MSG_NOTHING               = 3;

% 
% figure( 1 );
% set( gcf, 'Color', 'White' );
for j = 1 : 1 : nCols
    cur_cell = files( 1, j );
    fullFileName = cell2mat( cur_cell );
    [pathstr, name, ext] = fileparts( fullFileName );
    RawSensorData = BLRawSensorData( fullFileName );
    nSamples = size( RawSensorData.Accelerations, 1 );



    pRec = im_rec_t(  );
    b1 = imCalcB1_t(  );


%         subplot( nCols, 1, j );
%         hold on;
% %         plot( testResults, 'LineWidth', 3 );
%         
%     testResults = zeros( 1, nSamples );
%     t = RawSensorData.TimeLine;
%     plot( t, testResults, 'Color', 'Blue' );
    testResults = [  ];
    doBreak = false;
    res = 0;
    for i = 1 : 1 : nSamples
        if( true == doBreak )
            break;
        end
        in_accel = RawSensorData.Accelerations( i, : );
        in_gyros = RawSensorData.Gyroscopes( i, : );
        if( i == 1 )
            first_sample_info = true;
        else
            first_sample_info = false;
        end
        b1.firstSampleOfCapture = first_sample_info;

        pRec.accel.x = in_accel( 1 );
        pRec.accel.y = in_accel( 2 );
        pRec.accel.z = in_accel( 3 );

        pRec.gyro.x = in_gyros( 1 );
        pRec.gyro.y = in_gyros( 2 );
        pRec.gyro.z = in_gyros( 3 );
        
        res = mexRunADA( in_accel, in_gyros, first_sample_info );
        [res, ret_val] = detect_swing( b1, pRec );

        if( res == MSG_IMPACT_SIGNATURE )
%             doBreak = true;
%             fprintf( 'Detected\n' );
%             fprintf( 'IMPACT detected at sample #%i of %i\n', i, nSamples );
%             break;
%             testResults( i ) = ret_val;
            testResults = [testResults, ret_val];
%             col = 'Green';
%             if( mod( i, 2 ) == 0 )
%                 col = 'Red';
%             end
%             x1 = t( i );
%             x2 = x1;
%             y1 = 0;
%             y2 = gxySquaredPrev;
%             vX = [x1, x2];
%             vY = [y1, y2];
%             plot( vX, vY, 'Color', col );
%             plot( x1, y2, 'Marker', 'Square', 'MarkerFaceColor', 'Black' );
        end
    end
    [c1, i1] = min( testResults );
    [c2, i2] = max( testResults );
    sz = length( testResults );
    fprintf( 'min = %.2E - max = %.2E - L = %i\n', c1, c2, sz );
%     if( 1 == res )
%         fprintf( 'Swing Detected - YES\n' );
%     else
%         fprintf( 'Swing Detected - NO \n' );
%     end
end
