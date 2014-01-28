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
    doBreak = false;
    first_sample_info = true;
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
        
        res = mexRunADA( in_accel, in_gyros, first_sample_info );

        if( res == 1 )
            doBreak = true;
        end
    end
    if( 1 == res )
        fprintf( 'Swing Detected - YES\n' );
    else
        fprintf( 'Swing Detected - NO \n' );
    end
end
