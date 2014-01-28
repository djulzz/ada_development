clear all;
close all;
clc;


% addpath( 'functions' );
% addpath( 'classes' );


MSG_IMPACT_SIGNATURE      = 2;

os = 'win';
os = 'osx';


google_drive = [  ];

if( 0 == strcmp( os, 'win' ) )
    google_drive = '/Users/jesposito/Google Drive/';
else
    google_drive = 'C:/Users/djulzz/Google Drive/';
    addpath( '/Users/jesposito/RepoTop/julien_tests/mex' );
end

% google_drive = 'C:\Users\djulzz\Google Drive\';
base = 'Blast Motion Sensor-Recorder Data/';
base_ball = 'BB/';



nums = [1146, 1148, 1236, 1237, 1238, 1239, 1240, 1262, 1298, 1299];

num_nums = length( nums );
start = 1;
stop = 1;
vec_mean = [  ];
vec_std = [  ];
vec_min = [  ];
vec_max = [  ];
%google_drive = 'C:\Users\djulzz\Google Drive\';
%C:\Users\djulzz\Google Drive\John_Goree\Baseball filter tests\Invalid swings\Hitting shoe
%base = 'John_Goree\Baseball filter tests\Valid swings\';

% figure( 1 );
% hold on;
color = [1, 0, 0;
    0, 1, 0;
    0, 0, 1];


path = '/Users/jesposito/Desktop/Data/Baseball CSVs/Blast Data/2013_06_27 Easton/';
for i = start : 1 : stop
    %path = [google_drive, base];
    %path = [google_drive, base, base_ball, 'BB-', num2str( nums( i ) ), '/'];
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
            gx = RawSensorData.Gyroscopes( :, 1 );
            gy = RawSensorData.Gyroscopes( :, 2 );
            t = RawSensorData.TimeLine;
            gxgy = f_combine_gxgy( gx, gy );

            [val1, index1] = max( gxgy );
            [val2, index2] = min( gxgy );
            b3 = ( index1 < nSamples );
%             if( 1020 == nSamples )
%                 gxgy_pre = gxgy( 1000 - 50 : 999 );
%                 gxgy = gxgy( 1000 : 1020 );
%                 
%                 [val1, index1] = min( gxgy );
%                 [val2, index2] = max( gxgy );
%                 gxgy = movavgFilt( gxgy, length( gxgy ), 'Left' );
%                 h = figure( j );
%                 hold on;
%                 subplot( 2, 1, 1 );
%                 plot( gxgy );
%                 subplot( 2, 1, 2 );
%                 plot( gxgy_pre );
%                 str = num2str( j );
%                 if( length( str ) == 1 )
%                     str = ['00', str];
%                 elseif( length( str ) == 2 )
%                     str = ['0', str];
%                 end
%                 str = ['./pix/', str, '.png' ];
%                 saveas( h, str );
%                 close( h );
                %saveas(h,'filename.ext') 
%                 idx_start = index1 + 1;
%                 idx_stop  = index1 + 1 + samplesLeft;
%                 fprintf( '#samples = %i - idx_min = %i - idx_max = %i\n', nSamples, index1, index2 );
                %fprintf( '#samples = %i - max detected @ %i - #samples left = %i\n', nSamples, index1, samplesLeft );
%                 gxgy = gxgy( index1 + 1 : index1 + 1 + samplesLeft );
%                 reduced_size = length( gxgy );
%                 [val2, index2] = min( gxgy );
%                 [val3, index3] = max( gxgy( index2 : end ) );
%                 index3 = index2 + index3;
%                 gxgy = gxgy( index2 : index3 );
                %fprintf( 'size to be filtered = %i\n', length( gxgy ) );
                %gxgy = movavgFilt( gxgy, length( gxgy ), 'Left' );
                
                
                %index3 = index2 + index3;
                %dx = index3 - index2;
                %dy = val3 - val2;
                %dy = gxgy( end ) - gxgy( 1 );
                %fprintf( '#samples = %i - max = %.1f @ %i - min = %.1f @ %i\n', nSamples, val1, index1, val2, index2 );
                %fprintf( 'dx = %i - dy = %.1E - slope = %.1E\n', dx, dy, dy / dx );
% %                 plot( gxgy, 'Color', color( j, : ) );
%             end
            
            
            for k = 1 : 1 : nSamples
                in_accel = RawSensorData.Accelerations( k, : );
                in_gyros = RawSensorData.Gyroscopes( k, : );
                if( k == 1 )
                    b1.firstSampleOfCapture = true;
                else
                    b1.firstSampleOfCapture = false;
                end
                
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

% fprintf( 'Report - Missfires\n' );
% extrema_mins = [min( vec_min ), max( vec_min )];
% extrema_maxs = [min( vec_max ), max( vec_max )];
% extrema_mean = [min( vec_mean ), max( vec_mean )];
% extrema_std = [min( vec_std ), max( vec_std )];

% fprintf( 'MINS - min = %.3E - max = %.3E\n', extrema_mins( 1 ), extrema_mins( 2 ) );
% fprintf( 'MAXS - min = %.3E - max = %.3E\n', extrema_maxs( 1 ), extrema_maxs( 2 ) );
% fprintf( 'MEAN - min = %.3E - max = %.3E\n', extrema_mean( 1 ), extrema_mean( 2 ) );
% fprintf( 'STD. - min = %.3E - max = %.3E\n', extrema_std( 1 ), extrema_std( 2 ) );
