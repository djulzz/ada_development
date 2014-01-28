clear all;
close all;
clc;
MSG_IMPACT_SIGNATURE      = 2;

google_drive = 'C:\Users\djulzz\Google Drive\';
base = 'Blast Motion Sensor-Recorder Data\';
base_ball = 'BB\';

r = 'C:\Users\djulzz\Google Drive\Blast Motion Sensor-Recorder Data\BB\BB-1146';

nums = [1146, 1148, 1236, 1237, 1238, 1239, 1240, 1262, 1298, 1299];

num_nums = length( nums );
start = 1;
stop = num_nums;
vec_mean = [  ];
vec_std = [  ];
vec_min = [  ];
vec_max = [  ];

for i = start : 1 : stop
    path = [google_drive, base, base_ball, 'BB-', num2str( nums( i ) ), '\'];
    files = dirrec( path, '.csv' );
    [nRows, nCols] = size( files );
    nFiles = nCols;
    fprintf( 'scanning directory \"%s\"... #files = %i\n', path, nFiles );
    if( nFiles > 0 )
        for j = 1 : 1 : nFiles
            cur_cell = files( 1, j );
            fullFileName = cell2mat( cur_cell );
            RawSensorData = BLRawSensorData( fullFileName );
            nSamples = size( RawSensorData.Accelerations, 1 );
            pRec = im_rec_t(  );
            b1 = imCalcB1_t(  );
            values = [  ];
            for k = 1 : 1 : nSamples
                in_accel = RawSensorData.Accelerations( k, : );
                in_gyros = RawSensorData.Gyroscopes( k, : );
                if( k == 1 )
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
                if( res == MSG_IMPACT_SIGNATURE )
                    values = [values; [k, ret_val]];
                end
            end
            if( isempty( values ) == false )
                mini = min( values( :, 2 ) );
                maxi = max( values( :, 2 ) );
                v_std = std( values( :, 2 ) );
                v_mean = mean( values( :, 2 ) );
                fprintf( '\tFile %i of %i - signature info. Min = %.3E - Max = %.3E - Std = %.3E - Mean = %.3E\n', j, nFiles, mini, maxi, v_std, v_mean );
                vec_mean = [vec_mean, v_mean];
                vec_std = [vec_std, v_std];
                vec_min = [vec_min, mini];
                vec_max = [vec_max, maxi];
            end
        end
    else
        fprintf( '\tDirectory empty\n' );
    end
    fprintf( '\n\n' );
end

fprintf( 'Report - Missfires\n' );
extrema_mins = [min( vec_min ), max( vec_min )];
extrema_maxs = [min( vec_max ), max( vec_max )];
extrema_mean = [min( vec_mean ), max( vec_mean )];
extrema_std = [min( vec_std ), max( vec_std )];

fprintf( 'MINS - min = %.3E - max = %.3E\n', extrema_mins( 1 ), extrema_mins( 2 ) );
fprintf( 'MAXS - min = %.3E - max = %.3E\n', extrema_maxs( 1 ), extrema_maxs( 2 ) );
fprintf( 'MEAN - min = %.3E - max = %.3E\n', extrema_mean( 1 ), extrema_mean( 2 ) );
fprintf( 'STD. - min = %.3E - max = %.3E\n', extrema_std( 1 ), extrema_std( 2 ) );
