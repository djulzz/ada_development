clear all;
close all;
clc;


addpath( '/Users/jesposito/RepoTop/julien_tests/mex' );



MSG_SHOCK_ANY_ACCE_LAXIS  = 0;
MSG_GYROS_MATCH_DOWNSWING = 1;
MSG_IMPACT_SIGNATURE      = 2;
MSG_NOTHING               = 3;



%base = '/Users/jesposito/blast data/John_Goree/Baseball filter tests/Valid swings/';
%base = '/Users/jesposito/blast data/John_Goree/Baseball filter tests/Invalid swings/Hitting shoe/';
%base = '/Users/jesposito/blast data/John_Goree/Baseball filter tests/Invalid swings/Tapping plate/';
base = '//Users/jesposito/blast data/postimpact/';
folder = base;
files = dirrec( folder, '.csv' );
[nRows, nCols] = size( files );

MSG_SHOCK_ANY_ACCE_LAXIS  = 0;
MSG_GYROS_MATCH_DOWNSWING = 1;
MSG_IMPACT_SIGNATURE      = 2;
MSG_NOTHING               = 3;


figure( 1 );
set( gcf, 'Color', 'White' );
for j = 1 : 1 : nCols
    cur_cell = files( 1, j );
    fullFileName = cell2mat( cur_cell );
    [pathstr, name, ext] = fileparts( fullFileName );
    RawSensorData = BLRawSensorData( fullFileName );
    nSamples = size( RawSensorData.Accelerations, 1 );



    pRec = im_rec_t(  );
    b1 = imCalcB1_t(  );



    testResults = zeros( 1, nSamples );
    t = RawSensorData.TimeLine;
%     plot( testResults, 'Color', 'Blue' );

    values = [  ];
    for i = 1 : 1 : nSamples

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
        
        [res, ret_val] = detect_swing( b1, pRec );


        if( res ~= MSG_NOTHING )
%             x1 = i;
%             x2 = x1;
%             y1 = 0;
%             y2 = ret_val;
%             vX = [x1, x2];
%             vY = [y1, y2];
%             plot( vX, vY, 'Color', col );
            values = [values; [i, ret_val, res]];
            %plot( x1, y2, 'Marker', 'Square', 'MarkerFaceColor', 'Black' );
        end
    end % end for all samples
    subplot( nCols, 1, j );
    hold on;   
    plot( values( :, 1 ), values( :, 2 ) );
    vector_observed = values( :, 2 );

    str = sprintf( 'Std. Dev = %.0E - Mean = %.0E', std( vector_observed ), mean( vector_observed ) );
    xlabel( ['Std. Dev. = ', str] );
    n = size( values, 1 );
    for k = 1 : 1 : n
        ret = values( k, 3 );
        col = 'Black';
        if( MSG_SHOCK_ANY_ACCE_LAXIS == res )
            col = 'Red';
        elseif( MSG_GYROS_MATCH_DOWNSWING == res )
            col = 'Blue';
        else
            col = 'Green';
        end
        plot( values( k, 1 ), values( k, 2 ), 'Marker', 'Square', 'MarkerFaceColor', col, 'MarkerEdgeColor', col );
    end
end
